# Day 05. 텍스처와 UV — 그림을 입히고, 가위로 오리기

> ⏱ **약 1시간** — 읽기 25분 · 코드 따라 읽기 20분 · 해보기 15분
> 🧸 **오늘의 비유**: UV는 **상자 전개도에 적힌 좌표**, `clip`은 **가위**예요.

## 오늘 배울 것

- [ ] UV가 무엇이고 왜 0~1 범위인지 안다
- [ ] `SAMPLE_TEXTURE2D`로 텍스처 색을 읽는 법을 안다
- [ ] `_BaseMap_ST`(타일링·오프셋)가 하는 일을 안다
- [ ] 한 텍스처의 R·G·B·A 칸에 서로 다른 정보를 담는 "채널 패킹"을 이해한다
- [ ] `clip()`으로 픽셀을 버리는 알파 클립을 이해한다

---

## 1. UV = 전개도 좌표

종이 상자를 펼치면 **전개도**가 되죠. 3D 모델도 마찬가지로 펼쳐서 평평한 그림 위에 놓아요. 모델의 점마다 "나는 그림의 **어디**에 해당해" 하는 좌표가 붙어 있는데, 그게 **UV**예요.

- `u` = 그림의 가로 위치, `v` = 그림의 세로 위치
- 그림 크기가 512×512든 4096×4096이든 **항상 0~1**로 써요. "왼쪽 끝 0, 오른쪽 끝 1". 그래서 텍스처 해상도를 바꿔도 모델을 다시 만들 필요가 없어요.

## 2. 텍스처 읽기

[ToonInput.hlsl L13](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonInput.hlsl#L13)에서 텍스처와 **샘플러**를 선언해요.

```hlsl
TEXTURE2D(_BaseMap);        SAMPLER(sampler_BaseMap);
```

- **텍스처** = 그림 자체
- **샘플러** = 그림을 **읽는 방법** (돋보기 규칙). 확대할 때 부드럽게 섞을지(Bilinear), 모서리 밖은 반복할지(Repeat) 같은 규칙이에요.

그리고 프래그먼트 셰이더에서 읽어요. [CharacterToon.shader L292](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L292)

```hlsl
half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;
```

"`_BaseMap` 그림의 `input.uv` 위치 색을 읽어서, 머티리얼의 Base Color를 곱해라." 흰 텍스처(1,1,1)에 빨간 Base Color를 곱하면 빨강, 무늬 텍스처에 흰색을 곱하면 무늬 그대로예요.

## 3. 타일링과 오프셋: `_ST`

머티리얼 인스펙터의 텍스처 칸 아래에 **Tiling**과 **Offset**이 있죠? 그 값이 `_BaseMap_ST`에 담겨요. (ST = Scale·Translate)

- `_BaseMap_ST.xy` = Tiling (몇 번 반복할지)
- `_BaseMap_ST.zw` = Offset (얼마나 밀지)

`TRANSFORM_TEX(uv, _BaseMap)`는 이 계산을 해 주는 매크로예요. 지형 셰이더는 매크로 없이 직접 풀어 써서 보기 좋아요. [SceneTerrainInput.hlsl L76](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/ShaderLibrary/SceneTerrainInput.hlsl#L76)

```hlsl
uv * _Splat0_ST.xy + _Splat0_ST.zw     // 크기를 곱하고, 위치를 더한다
```

Tiling이 (2, 2)면 UV가 0~2가 되고, 샘플러가 Repeat이면 그림이 2×2번 반복돼요.

## 4. 물감 네 통을 한 상자에: 채널 패킹

텍스처 한 장에는 R·G·B·A **네 칸**이 있어요. 꼭 색을 담을 필요는 없어요. 흑백 정보 네 개를 각 칸에 하나씩 담으면 텍스처 네 장을 한 장으로 줄일 수 있죠. 이걸 **채널 패킹**이라고 해요.

이 셰이더의 **ILM 맵**이 그 예예요. ([CharacterToon.shader L340–343](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L340-L343))

```hlsl
half4 ilm = half4(0.0h, 0.5h, 0.5h, 0.0h);           // ILM이 없을 때의 '중립' 값
#if defined(_USE_ILM)
    ilm = SAMPLE_TEXTURE2D(_ILMMap, sampler_ILMMap, input.uv);
#endif
```

| 칸 | 뜻 | 쓰이는 곳 | 중립 값 |
|---|---|---|---|
| R | MatCap 반사 마스크 | Day 17 | 0 |
| G | **그림자 잘 생기는 곳** (0.5보다 작으면 그림자 쪽으로) | Day 07 | 0.5 = 영향 없음 |
| B | 스펙큘러 하이라이트 폭 | Day 17 | 0.5 |
| A | 외곽선 지우기 (1이면 그 부위 외곽선 없음) | Day 12 | 0 = 외곽선 있음 |

{% hint style="success" %}
"중립 값"이 중요해요. ILM을 안 쓰는 머티리얼도 같은 계산을 거치는데, 중립 값을 넣으면 **계산은 하되 결과가 바뀌지 않아요.** 예를 들어 G=0.5면 `(0.5 - 0.5) × 크기 = 0`이라 그림자가 밀리지 않아요.
{% endhint %}

같은 이유로 텍스처 기본값을 고를 때도 신경 써요. 마스크는 대부분 `"white"`(곱해도 그대로), 더하는 효과(Emission, MatCap)는 `"black"`(더해도 그대로)이에요.

## 5. 가위로 오리기: `clip()`

머리카락 끝이나 속눈썹은 판때기(사각형) 하나에 그림을 그리고, **투명한 부분을 오려 내서** 만들어요. 이걸 **알파 클립**(Alpha Clip, 컷아웃)이라고 해요.

`clip(x)`는 x가 **0보다 작으면 이 픽셀을 버려요.** 색도 안 칠하고, 깊이도 안 남겨요.

[ToonInput.hlsl L183–191](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonInput.hlsl#L183-L191)

```hlsl
void ClipToonSurface(float2 uv)
{
#if defined(_USE_STENCIL_MASK)
    clip(SAMPLE_TEXTURE2D(_StencilMask, sampler_StencilMask, uv).r - _StencilMaskCutoff);
#endif
#if defined(_ALPHATEST_ON)
    clip(SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv).a * _BaseColor.a - _Cutoff);
#endif
}
```

- 그림의 투명도(a)가 0.3이고 `_Cutoff`가 0.5면 `0.3 - 0.5 = -0.2` → 음수 → **오려 냄** ✂️
- 투명도가 0.8이면 `0.8 - 0.5 = 0.3` → 양수 → 남김

![알파 클립 전후](../.gitbook/assets/toon-shader-study-day05-alpha-clip.png)

{% hint style="warning" %}
**💡 이 프로젝트에서 실제로 있었던 일 (C3, A4)**
처음엔 색칠 패스만 오렸어요. 그랬더니 구멍 뚫린 자리에 **그림자와 외곽선이 그대로** 남았어요. 그림자 패스와 외곽선 패스는 "여기 구멍 있음"을 몰랐거든요. 그래서 오리는 규칙을 `ClipToonSurface()` 함수 하나로 만들고, **모든 패스가 이 함수를 부르게** 고쳤어요. 위 사진 오른쪽을 보면 그림자에도 구멍이 뚫렸죠? (Day 18에서 다시 봐요.)
{% endhint %}

## 6. 버텍스 셰이더에서 텍스처 읽기

외곽선 패스는 **버텍스 셰이더에서** 텍스처를 읽어요. [CharacterToon.shader L723](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L723)

```hlsl
half widthMul = SAMPLE_TEXTURE2D_LOD(_OutlineMask, sampler_OutlineMask, input.uv, 0).r;
```

왜 `_LOD`가 붙었을까요? 텍스처에는 멀리서 볼 때 쓰는 **작은 사본들**(밉맵)이 있어요. 프래그먼트 셰이더는 "이웃 픽셀과 UV가 얼마나 차이 나나"를 보고 알아서 사본 크기를 골라요(Day 16에서 배우는 `ddx/ddy`). 버텍스 셰이더에는 이웃 픽셀이 없으니까 **"0번(원본 크기) 써"** 하고 직접 알려 줘야 해요.

## 7. 해보기 (15분)

1. **타일링 계산** — UV가 (0.3, 0.4)이고 Tiling (2, 2), Offset (0.1, 0)이면 최종 UV는? `(0.3×2+0.1, 0.4×2+0) = (0.7, 0.8)`.
2. **ILM 해석** — ILM 픽셀 값이 (0, 0.2, 0.5, 1)이면 이 부위는 어떤 특징일까요? (힌트: G가 0.5보다 작다 = 그림자가 잘 생긴다, A=1 = 외곽선 없음)
3. **clip 계산** — `_Cutoff = 0.5`, 텍스처 a = 0.6, `_BaseColor.a = 0.7`이면 오려질까요? (`0.6 × 0.7 = 0.42 < 0.5` → 오려짐!) Base Color의 알파도 곱해진다는 점에 주의하세요.
4. **ClipToonSurface 찾기** — [CharacterToon.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader)에서 `ClipToonSurface`를 검색해 보세요. 몇 개 패스에서 부르나요? (정답: 5곳 + MotionVectors 패스는 [ToonMotionVectors.hlsl L40](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonMotionVectors.hlsl#L40)에서)

## 8. 오늘의 액기스

👉 [ESSENCE.md — Day 05](essence.md#day-05)

## 더 읽을거리

- [LearnOpenGL — Textures](https://learnopengl.com/Getting-started/Textures) — 샘플러, 필터링, 반복 모드, 밉맵을 그림으로 설명 (영어)
- [Wikipedia — UV mapping](https://en.wikipedia.org/wiki/UV_mapping) · [Mipmap](https://en.wikipedia.org/wiki/Mipmap) (영어)
- [Microsoft — clip](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-clip)
- [Catlike Coding — Rendering 3: Combining Textures](https://catlikecoding.com/unity/tutorials/rendering/part-3/) (영어)

---

[← Day 04](day04-hlsl-basics.md) · [목차](README.md) · [다음: Day 06 →](day06-vectors-and-light.md)
