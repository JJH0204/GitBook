# Day 13. 외곽선 ② — 두께를 픽셀로 고정하기

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSS-014-DO |
| 유형 | D&O (개념) + 코드 읽기 + 실습 |
| 목적 | 클립 공간 오프셋에 `w`를 곱해 외곽선 두께를 화면 픽셀 단위로 고정하는 원리를 설명한다 |
| 소요 시간 | 약 1시간 (읽기 25분, 코드 읽기 25분, 실습 10분) |
| 선수 지식 | [Day 02](day02-coordinate-spaces.md) 클립 공간과 `w` 나눗셈, [Day 12](day12-outline-inverted-hull.md) |
| 확인 상태 | 미검증 (소스를 읽고 작성했으며 Unity에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- [ ] 월드 단위 외곽선이 멀리서 자글거리는 이유를 안다
- [ ] 클립 공간 오프셋에 `w`를 곱하면 화면 두께가 고정되는 원리를 이해한다
- [ ] NDC에서 1픽셀이 `2 / 화면폭`인 이유를 안다
- [ ] 최소 1픽셀 클램프와 그 게이트를 이해한다
- [ ] Depth Priming이 외곽선을 지우는 이유를 안다

## 1. 정의

픽셀 고정 두께 외곽선은 정점 오프셋을 클립 공간에서 `d × w`로 더해, 원근 나눗셈 후 NDC 오프셋이 거리와 무관하게 `d`가 되게 하는 방식이다.

비유: 아주 가는 실은 멀리서 보였다 안 보였다 반짝인다. 실의 두께를 눈에 보이는 굵기로 정하는 것과 같다.

## 2. 구성 요소

| 구성 요소 | 역할 |
|---|---|
| `posCS.w` | 원근 나눗셈의 분모. 거리에 비례한다 |
| `_OutlineWidthMode` | World(월드 폭) 또는 Screen(픽셀 폭) 선택 |
| `_OutlineWidthPixels` | Screen 모드의 목표 두께(px) |
| `_OutlineMinPixels` | 최소 두께(px), 기본 1 |
| `enable` 게이트 | 폭 0이거나 마스크 0인 곳에서 최소 두께가 되살아나지 않게 한다 |
| `_ScaledScreenParams` | 렌더 스케일이 반영된 실제 렌더 타깃 크기 |

## 3. 동작 원리

### 3.1 문제: 1픽셀보다 얇은 선

[Day 12](day12-outline-inverted-hull.md)의 외곽선은 월드 단위(미터)로 민다. 멀리 있는 물체는 작게 보이므로(`w` 나눗셈) 화면 두께는 거리에 반비례한다.

![외곽선 폭 vs 거리](../.gitbook/assets/concept-outline-width-vs-distance.png)

[ToonOutline.hlsl L10–13 주석](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonOutline.hlsl#L10-L13)의 실측 값이다.

> `_OutlineWidth = 0.113` → 월드 1.13mm → FOV 60°, 1080p 기준 6m에서 0.18px.

래스터라이저는 픽셀 중심이 삼각형에 덮였는지로 칠할지 정한다. 0.18px 띠는 프레임에 따라 픽셀 중심을 덮기도 못 덮기도 하며, 외곽선이 깜빡이며 기어다니는 것처럼 보인다. 이것이 자글거림이다. 해결은 두께를 픽셀 단위로 정하고 최소 1px을 보장하는 것이다.

### 3.2 원리: 나눌 값을 미리 곱한다

GPU는 클립 좌표 `x, y`를 `w`로 나눠 NDC를 만든다.

| 오프셋 | 계산 | NDC 결과 |
|---|---|---|
| `d` 를 더함 | `(clip.x + d) / w` | `NDC.x + d / w` (멀수록 작아짐) |
| `d × w` 를 더함 | `(clip.x + d × w) / w` | `NDC.x + d` (`w` 소거, 거리 무관) |

비유: 받은 돈을 4명이 나눠 가진다는 것을 알면, 한 명에게 1000원을 주려고 처음부터 4000원을 준다.

### 3.3 NDC에서 1픽셀

NDC의 가로 폭은 -1에서 +1까지 2이다. 화면 폭이 1920픽셀이면 1픽셀은 `2 / 1920`이다. N픽셀 오프셋의 클립 값은 다음과 같다.

```
clip 오프셋 = 방향 × N × (2 / 화면폭) × w
```

{% hint style="info" %}
NOTE: 가로와 세로에 각각 `2 / 화면크기`를 쓰므로 화면 비율이 자동으로 보정된다. 가로·세로 해상도가 다른 화면에서도 두께가 정사각 픽셀 기준으로 같아진다. NDC y 방향은 API(OpenGL/Direct3D)마다 다르지만 오프셋은 방향 벡터와 함께 변환되므로 이 계산에는 영향이 없다.
{% endhint %}

## 4. 코드 읽기

[ToonOutline.hlsl L61–95](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonOutline.hlsl#L61-L95)

```hlsl
float4 posCS = TransformWorldToHClip(positionWS);     // 아직 부풀리지 않은 원래 위치
float w = max(posCS.w, 1e-4);                          // 카메라 뒤(w≤0) 안전장치

// ① 노멀을 클립 공간으로 → 픽셀 공간에서의 방향과 '월드 폭이면 몇 픽셀인지'
float2 dirCS = mul(GetWorldToHClipMatrix(), float4(normalWS, 0.0)).xy;
float2 wPix  = dirCS * ((_OutlineWidth * 0.01 * widthScale) / w) * 0.5 * _ScaledScreenParams.xy;
float  pixLen = length(wPix);                          // World 모드라면 화면에서 몇 px 일까

// ② 화면에서 밀 방향 (길이 1)
float2 dirPix = (pixLen > 1e-6) ? (wPix / pixLen) : ...;

// ③ 목표 두께(px): Screen 모드는 지정한 px, World 모드는 ①에서 환산한 px
float screenPix = _OutlineWidthPixels * widthScale;
float targetPix = (_OutlineWidthMode > 0.5h) ? screenPix : pixLen;

// ④ 최소 두께 — 단, 원래 외곽선이 있어야 할 곳만
half  baseWidth = (_OutlineWidthMode > 0.5h) ? _OutlineWidthPixels : _OutlineWidth;
float enable    = step(1e-6, baseWidth) * saturate(widthScale);
targetPix = max(targetPix, _OutlineMinPixels * enable);

// ⑤ 픽셀 → NDC (×2/화면크기) → 클립 (×w)
posCS.xy += dirPix * (targetPix * 2.0 / _ScaledScreenParams.xy) * w;
return posCS;
```

| 단계 | 설명 |
|---|---|
| ① | 월드 폭으로 밀면 화면에서 몇 픽셀인지 계산한다. `0.5 × 화면크기`는 폭 2인 NDC를 픽셀로 바꾸는 값이다 |
| ② | 화면에서 밀 방향(길이 1)을 구한다 |
| ③ | Screen 모드는 픽셀 값을 직접 쓴다. World 모드는 ①의 환산 값을 쓴다 |
| ④ | 어느 모드든 최소 `_OutlineMinPixels`를 보장해 서브픽셀 외곽선을 없앤다 |
| ⑤ | 3.2절의 공식이다. `w`로 나눠진 뒤 오프셋이 정확히 `targetPix` 픽셀이 된다 |

(`...`는 원본 소스의 생략 표기이며 실제 폴백 값은 소스를 본다.)

### 4.1 ④의 게이트

`max(targetPix, 1px)`만 쓰면 마스크로 외곽선을 지운 곳(`widthScale = 0`)과 폭 0인 머티리얼에서 1px 외곽선이 되살아난다. `enable`을 곱해 막는다.

| 조건 | `enable` |
|---|---|
| 기본 폭 0 | `step(1e-6, 0) = 0` → 0 |
| 마스크 0 | `saturate(0) = 0` → 0 |

[L20–22 주석](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonOutline.hlsl#L20-L22)이 폭 가중(`widthMul`)과 폭 자체를 분리해 받는 이유를 설명한다.

{% hint style="info" %}
NOTE: 이 함수는 `_ScreenParams` 대신 `_ScaledScreenParams`를 쓴다([Day 11](day11-rim-light.md)). 렌더 스케일 0.8에서 `_ScreenParams`를 쓰면 1px이 실제 렌더 타깃에서 0.8px이 되어 자글거림이 돌아온다. 래스터화가 일어나는 렌더 타깃 기준으로 재야 한다([L69–70 주석](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonOutline.hlsl#L69-L70)). `_ScaledScreenParams`는 URP 전용이며 Built-in에는 없다.
{% endhint %}

## 5. 주의: Depth Priming

URP의 Depth Priming은 최적화 기능이다.

1. 불투명 물체의 깊이만 먼저 그린다(DepthOnly 패스).
2. 색칠 단계에서 `ZTest Equal`로 깊이 버퍼와 정확히 같은 깊이의 픽셀만 칠한다. 가려질 픽셀은 계산하지 않는다.

외곽선은 몸보다 약간 뒤에 있는 부푼 껍질이다. 깊이 버퍼에는 몸의 깊이만 기록돼 있으므로 같은 깊이인 외곽선 픽셀이 없고, 외곽선이 모두 탈락한다.

![Depth Priming 함정](../.gitbook/assets/day13-depth-priming.png)

{% hint style="warning" %}
CAUTION (이 프로젝트의 실제 사례, C2): 셰이더 안에서는 고칠 수 없다(URP가 패스의 ZTest를 강제로 바꾼다). 대신 머티리얼 인스펙터에 경고 상자를 띄운다. 렌더러 에셋 중 Depth Priming을 쓰는 것이 있으면 외곽선이 사라질 수 있다고 알린다. 코드: [CharacterToonManager.AnyRendererUsesDepthPriming()](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Runtime/CharacterToonManager.cs), [CharacterToonShaderGUI.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/CharacterToonShaderGUI.cs)
{% endhint %}

{% hint style="info" %}
NOTE: Depth Priming 옵션(Disabled/Auto/Forced)과 동작은 URP 버전에 따라 다르다. 버전 확인 필요.
{% endhint %}

## 6. 실습

1. 픽셀을 클립 오프셋으로 환산한다. 화면 높이 1080, 목표 1.5px이다. → 결과: NDC 오프셋은 `1.5 × 2 / 1080 ≈ 0.00278`이다.
2. `w = 6`(약 6m)인 점의 클립 오프셋을 구한다. → 결과: `0.00278 × 6 ≈ 0.0167`이다.
3. `w = 60`인 점의 클립 오프셋을 구한다. → 결과: `0.167`이며 10배 크게 더해야 화면에서 같은 1.5px이 된다.
4. 게이트를 확인한다. `_OutlineWidthMode = 1`, `_OutlineWidthPixels = 1.5`, `widthScale = 0`이다. → 결과: `screenPix = 0`, `enable = 0`, `max(0, 0) = 0`이므로 외곽선이 없다.
5. 월드 모드를 환산한다. 3.1절 실측에서 6m일 때 두께를 읽는다. → 결과: 약 0.18px이다. 최소 1px 클램프를 켜면 1px이다.

## 7. 참조

- [Day 13 액기스](essence.md#day-13)
- [LearnOpenGL — Coordinate Systems](https://learnopengl.com/Getting-started/Coordinate-Systems): 원근 투영과 `w` 나눗셈
- [위키백과 — 동차좌표](https://ko.wikipedia.org/wiki/%EB%8F%99%EC%B0%A8%EC%A2%8C%ED%91%9C), [Wikipedia — Homogeneous coordinates](https://en.wikipedia.org/wiki/Homogeneous_coordinates)
- [Wikipedia — Spatial anti-aliasing](https://en.wikipedia.org/wiki/Spatial_anti-aliasing)
- [LearnOpenGL — Depth testing](https://learnopengl.com/Advanced-OpenGL/Depth-testing), [Unity — ZTest](https://docs.unity3d.com/Manual/SL-ZTest.html)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 외곽선이 멀리서 자글거리는 이유를 내 말로 설명한다.
- [ ] 오프셋에 `w`를 미리 곱하는 이유를 나눗셈 순서로 설명한다.
- [ ] 최소 두께 게이트가 없으면 어떤 화면이 되는지 상상해 적는다.

---

[← Day 12](day12-outline-inverted-hull.md) · [목차](README.md) · [다음: Day 14 →](day14-screen-space-outline.md)
