# Day 12. 외곽선 ① — 뒤집힌 풍선 (인버티드 헐)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSS-013-DO |
| 유형 | D&O (개념) + 코드 읽기 + 실습 |
| 목적 | 인버티드 헐 외곽선의 원리와 스무스 노멀, 폭 조절 장치를 설명한다 |
| 소요 시간 | 약 1시간 (읽기 25분, 코드 읽기 20분, 실습 15분) |
| 선수 지식 | [Day 06](day06-vectors-and-light.md) 노멀과 내적, [Day 11](day11-rim-light.md) |
| 확인 상태 | 미검증 (소스를 읽고 작성했으며 Unity에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- [ ] 인버티드 헐 외곽선의 원리(부풀리기 + `Cull Front`)를 안다
- [ ] 각진 모델에서 외곽선이 갈라지는 이유와 스무스 노멀 해결법을 안다
- [ ] 스무스 노멀을 TANGENT 칸에 숨기는 이유를 안다
- [ ] 외곽선 폭을 부위별로 조절하는 마스크들을 안다

## 1. 정의

인버티드 헐(Inverted Hull)은 메시를 한 번 더 그리되, 각 정점을 노멀 방향으로 밀어 부풀리고 앞면 대신 뒷면만 그려 외곽선을 만드는 기법이다.

비유: 캐릭터보다 조금 큰 검은 풍선을 뒤집어 씌우면 몸 뒤로 테두리만 보인다.

## 2. 구성 요소

| 구성 요소 | 역할 |
|---|---|
| 부풀린 메시 | 정점을 (스무스) 노멀 방향으로 이동한 두 번째 그리기 |
| `Cull Front` | 앞면을 버리고 뒷면만 그린다 |
| 단색 프래그먼트 | 외곽선 색 × 외곽선 텍스처, 안개 적용 |
| 스무스 노멀 | 같은 위치 정점의 노멀 평균. 모서리 갈라짐을 막는다 |
| 폭 조절 장치 | 마스크 텍스처, ILM.A, 정점 색, 거리 보정 |

## 3. 동작 원리

1. 모델을 한 번 더 그린다. 정점을 노멀 방향으로 밀어 부풀린다.
2. 부푼 껍질의 앞면을 버리고 뒷면만 그린다(`Cull Front`).
3. 외곽선 색으로 칠한다.
4. 정면에서 보면 부푼 껍질의 뒷면은 원래 몸에 가려지고, 몸 바깥으로 나온 가장자리만 남는다. 이것이 외곽선이다.

![인버티드 헐](../.gitbook/assets/concept-inverted-hull.png)

### 각진 모델의 문제

정육면체 모서리의 정점은 면마다 따로 존재하고 노멀이 서로 다르다. 면 노멀 방향으로 밀면 면들이 각자 다른 방향으로 벌어져 모서리에 틈이 생긴다.

| 방식 | 밀어내는 방향 | 결과 |
|---|---|---|
| 면 노멀 | 정점마다 다름 | 모서리가 벌어진다 |
| 스무스 노멀 | 같은 위치 정점의 노멀 평균 | 면이 같이 움직여 이어진다 |

![밀어내는 방향 비교](../.gitbook/assets/day12-outline-push-direction.png)

스무스 노멀은 빛 계산용 `NORMAL` 칸을 쓸 수 없다. 각진 음영을 유지하려면 원래 노멀이 필요하기 때문이다. 이 패키지는 스무스 노멀을 `TANGENT` 칸에 저장한다. 다른 구현은 UV 채널이나 정점 색에 저장하기도 한다.

- 모델 임포트 시 에디터 스크립트가 굽는다: [SmoothNormalModelPostprocessor.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/SmoothNormalModelPostprocessor.cs)
- 계산: [SmoothNormalUtil.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/SmoothNormalUtil.cs), [SmoothNormalBaker.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/SmoothNormalBaker.cs)

{% hint style="info" %}
NOTE: `TANGENT` 칸은 원래 노멀맵 계산용이다. 이 칸을 쓰기 때문에 캐릭터는 노멀맵을 픽셀 미분으로 계산한다([Day 16](day16-normal-maps-and-derivatives.md)).
{% endhint %}

## 4. 코드 읽기

### 4.1 Outline 패스

[CharacterToon.shader L673–681](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L673-L681)

```shaderlab
Pass
{
    Name "Outline"
    Tags { "LightMode" = "SRPDefaultUnlit" }   // URP가 색칠 패스 다음에 '덤으로' 그려 주는 이름표
    Cull Front                                 // ★ 뒷면만
    Blend [_SrcBlend] [_DstBlend]
    ZWrite [_ZWrite]
    ZTest LEqual
```

| 줄 | 설명 |
|---|---|
| `LightMode = "SRPDefaultUnlit"` | URP가 같은 물체의 패스를 하나 더 그릴 때 쓰는 이름표다. 별도 설정 없이 캐릭터와 함께 그려진다 |
| `Cull Front` | 앞면을 컬링하고 뒷면만 그린다 |

버텍스 셰이더는 부풀리기를 공용 함수에 맡긴다. [L712–735](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L712-L735)

```hlsl
half widthMul = SAMPLE_TEXTURE2D_LOD(_OutlineMask, sampler_OutlineMask, input.uv, 0).r;   // 부위별 폭
#if defined(_USE_ILM)
    widthMul *= 1.0h - SAMPLE_TEXTURE2D_LOD(_ILMMap, sampler_ILMMap, input.uv, 0).a;      // ILM.A=1 이면 외곽선 끔
#endif
o.positionCS = CharacterToonOutlinePositionCS(
    input.positionOS.xyz, input.normalOS, input.tangentOS.xyz, input.color, widthMul);
```

프래그먼트 셰이더는 외곽선 색 × 외곽선 텍스처에 안개를 적용한다. [L737–745](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L737-L745)

### 4.2 공용 함수 (1부)

[ToonOutline.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonOutline.hlsl) 앞부분이다. 픽셀 단위 폭은 [Day 13](day13-outline-pixel-width.md)에서 읽는다.

스무스 노멀 검증 (L30–38):

```hlsl
float3 smoothNormalOS = bakedSmoothNormalOS;   // TANGENT.xyz
float  tlen = length(smoothNormalOS);
if (tlen < 1e-4 || dot(smoothNormalOS / max(tlen, 1e-5), normalOS) < 0.02)
    smoothNormalOS = normalOS;                 // 가짜 같으면 원래 노멀로
```

스무스 노멀을 굽지 않은 모델의 `TANGENT`에는 진짜 탄젠트가 들어 있다. 탄젠트는 표면을 따라 눕는 벡터라 노멀과 직각(`dot ≈ 0`)이다. 노멀과 거의 직각이면 굽지 않은 것으로 보고 원래 노멀을 쓴다.

{% hint style="warning" %}
CAUTION (이 프로젝트의 실제 사례, C5): 판별 기준이 `< 0.3`(약 72.5°)이던 때, 머리카락 끝이나 옷 끝처럼 날카롭게 접힌 곳의 진짜 스무스 노멀도 원래 노멀과 72° 넘게 벌어져 "가짜"로 판정됐다. 그 점들이 원래 노멀로 돌아가 외곽선이 갈라졌다. 가짜 탄젠트는 거의 정확히 직각이므로 기준을 `0.02`로 낮춰 해결했다.
{% endhint %}

폭 조절 (L43–55):

```hlsl
float widthScale = widthMul;                                         // 마스크 텍스처 R × (1 - ILM.A)
if (_OutlineVertexColorWidth > 1.5h)      widthScale *= vertexColor.a;   // 정점 색으로도 조절 가능
else if (_OutlineVertexColorWidth > 0.5h) widthScale *= vertexColor.r;
float3 toCam   = _WorldSpaceCameraPos - positionWS;
float  camDist = length(toCam);
widthScale *= lerp(1.0, saturate(camDist), _OutlineFixWidth);                          // 아주 가까우면 얇게
widthScale *= lerp(1.0, saturate(_OutlineFadeStart / max(camDist, 1e-3)), _OutlineDistanceFade);   // 멀면 얇게
```

| 장치 | 쓰는 곳 |
|---|---|
| 외곽선 마스크 텍스처 (R) | 눈·입 안쪽처럼 외곽선이 없어야 하는 부위 |
| ILM.A | 같은 목적을 ILM 맵 하나로 해결할 때 |
| 정점 색 R 또는 A | 모델러가 정점마다 두께를 칠할 때 |
| Fix Width | 카메라가 얼굴에 바짝 붙었을 때 외곽선이 두꺼워지는 것을 막는다 |
| Distance Fade | 멀리 있는 캐릭터의 외곽선을 얇게 한다 |

이 조절 방식은 lilToon에서 가져왔다. 코드 주석에 `lilToon _OutlineFixWidth` 같은 원래 이름이 남아 있다.

외곽선 끄기 (L715–719):

```hlsl
#if !defined(_USE_OUTLINE)
    o.positionCS = float4(2.0, 2.0, 2.0, 1.0);   // 세 점을 모두 화면 밖 한 점으로
    return o;
#endif
```

모든 정점을 클립 범위 밖 한 점에 모아 삼각형을 사라지게 한다. GPU는 이 패스를 여전히 실행하므로 정점 처리 비용은 남는다. 그래서 패스 자체를 끄는 방법을 함께 쓴다([Day 19](day19-keywords-and-variants.md)).

## 5. 주의

{% hint style="warning" %}
CAUTION: 인버티드 헐은 외곽선을 쓰는 물체마다 드로우를 한 번 더 늘린다. 물체 수가 많으면 화면 공간 외곽선([Day 14](day14-screen-space-outline.md))과 비용 구조가 다르다.
{% endhint %}

## 6. 실습

1. 스무스 노멀을 손으로 계산한다. 정육면체 모서리 정점에 면 노멀 (1,0,0), (0,1,0), (0,0,1)이 모인다. → 결과: 합 (1,1,1)을 정규화하면 약 (0.577, 0.577, 0.577)이다.
2. 원래 노멀 (1,0,0)과 스무스 노멀의 내적을 구한다. → 결과: 0.577이며 0.02보다 크므로 진짜 스무스 노멀로 통과한다.
3. 가짜 판별을 확인한다. `TANGENT = (0,0,1)`, 노멀 `(1,0,0)`이다. → 결과: 내적 0은 0.02 미만이므로 원래 노멀을 쓴다.
4. 폭 마스크를 곱한다. 마스크 R = 0.5, ILM.A = 0.4, 정점 색 끔이다. → 결과: `widthMul = 0.5 × (1 − 0.4) = 0.3`, 기본 두께의 30%다.
5. (Unity가 있다면) 샘플 캐릭터 머티리얼의 Outline Width를 0에서 1로 올리고 카메라를 멀리 보낸다. 되돌리려면 Ctrl+Z 또는 값을 원래대로 둔다. → 결과: 거리에 따라 외곽선 두께가 변한다([Day 13](day13-outline-pixel-width.md)의 문제).

## 7. 참조

- [Day 12 액기스](essence.md#day-12)
- [lilToon (GitHub)](https://github.com/lilxyzw/lilToon): 외곽선 조절 장치의 원조
- [LearnOpenGL — Face culling](https://learnopengl.com/Advanced-OpenGL/Face-culling), [Wikipedia — Back-face culling](https://en.wikipedia.org/wiki/Back-face_culling)
- [Unity — Cull 명령](https://docs.unity3d.com/Manual/SL-Cull.html)
- [3Blue1Brown — 벡터](https://www.3blue1brown.com/lessons/vectors): 벡터 합이 평균 노멀의 원리다

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 인버티드 헐 외곽선이 정면에서는 가장자리만 보이는 이유를 내 말로 설명한다.
- [ ] 각진 모델에서 스무스 노멀이 없으면 어떤 모양이 되는지 직접 본 경험이나 예상을 적는다.
- [ ] 이 외곽선 방식이 내가 만들 캐릭터에 맞는지, 어떤 부위에 마스크가 필요할지 적는다.

---

[← Day 11](day11-rim-light.md) · [목차](README.md) · [다음: Day 13 →](day13-outline-pixel-width.md)
