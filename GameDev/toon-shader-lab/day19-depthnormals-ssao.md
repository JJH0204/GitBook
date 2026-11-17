# Day 19. 노멀 지도와 SSAO — 구석의 그늘

> ⏱ **약 1시간** — 개념 15분 · 코드 25분 · 실험 20분
> 🧸 **오늘의 비유**: SSAO는 **방 구석에 쌓인 그늘**이에요. 화면의 깊이·노멀 지도를 보고 "주변이 벽으로 많이 둘러싸인 곳"을 찾아 어둡게 해요.

![Day 19 결과](../.gitbook/assets/day19-ssao.png)

## 오늘 만들 것

물체가 바닥에 닿는 곳과 물체끼리 가까운 곳에 **은은한 접지 그늘**이 생겨요(오른쪽). 물체가 바닥에 "붙어" 보여요.

## 오늘 배울 것

- [ ] DepthNormals 패스를 짠다
- [ ] URP의 SSAO 결과를 받아 직접광·간접광에 곱한다
- [ ] "패스가 없으면 다른 효과가 나를 못 본다"는 걸 안다

---

## 1. 왜 패스가 필요할까 (개념 15분)

이 프로젝트의 렌더러(`Assets/Settings/PC_Renderer`)에는 처음부터 **SSAO**가 켜져 있어요. SSAO는 화면 전체의 **깊이 + 노멀 지도**를 보고 구석을 찾아요. 그 지도는 각 물체의 **DepthNormals 패스**가 그려요.

어제까지 우리 셰이더에는 DepthNormals 패스가 없었어요. 그래서 SSAO 입장에서 우리 물체는 **투명 인간**이었어요. 바닥(Unity Lit)에도 우리 물체 주변 그늘이 안 생겼죠.

해야 할 일 두 가지:
1. **DepthNormals 패스**로 노멀 지도에 찍히기 → 다른 물체가 우리를 봄
2. **SSAO 결과 받기** → 우리 물체도 구석이 어두워짐

## 2. 코드 고치기 (25분)

### ① DepthNormals 패스 (DepthOnly 패스 다음, SubShader 끝 전)

```hlsl
        // 깊이 + 노멀 지도 찍기: SSAO 와 화면 공간 효과들이 쓴다
        Pass
        {
            Name "DepthNormals"
            Tags { "LightMode" = "DepthNormals" }
            ZWrite On

            HLSLPROGRAM
            #pragma vertex DepthNormalsVert
            #pragma fragment DepthNormalsFrag
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON

            struct DepthNormalsAttributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
            };

            struct DepthNormalsVaryings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS   : TEXCOORD0;
                float2 uv         : TEXCOORD1;
            };

            DepthNormalsVaryings DepthNormalsVert(DepthNormalsAttributes input)
            {
                DepthNormalsVaryings o = (DepthNormalsVaryings)0;
                o.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                o.normalWS = TransformObjectToWorldNormal(input.normalOS);
                o.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                return o;
            }

            half4 DepthNormalsFrag(DepthNormalsVaryings input) : SV_Target
            {
                ClipAlpha(input.uv);
                return half4(normalize(input.normalWS), 0.0h);
            }
            ENDHLSL
        }
```

색 대신 **월드 노멀**을 돌려줘요. 깊이는 GPU가 알아서 적어요(`ZWrite On`).

### ② SSAO 받기 (Forward 패스)

키워드:

```hlsl
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
```

frag에서 `shadeMask` 줄 다음에 AO 값을 받고, 아래 두 줄에 곱해요.

```hlsl
                half shadeMask = max(shadow1, shadow2);   // 얼마나 그림자인가 (0~1)

                half aoDirect = 1.0h, aoIndirect = 1.0h;
            #if defined(_SCREEN_SPACE_OCCLUSION)
                AmbientOcclusionFactor ao = GetScreenSpaceAmbientOcclusion(GetNormalizedScreenSpaceUV(input.positionCS));
                aoDirect   = ao.directAmbientOcclusion;
                aoIndirect = ao.indirectAmbientOcclusion;
            #endif

                half3 color = toon * mainLight.color * aoDirect;                  // ← * aoDirect 추가
                half3 ambient = SampleSH(N) * albedo * _AmbientStrength;   // 하늘에서 오는 은은한 빛
                color += ambient * (1.0h - shadeMask) * aoIndirect;        // ← * aoIndirect 추가
```

| 값 | 곱하는 곳 | 뜻 |
|---|---|---|
| `indirectAmbientOcclusion` | 하늘빛(간접광) | 구석엔 하늘빛이 덜 들어와요 — 주된 효과 |
| `directAmbientOcclusion` | 해(직접광) | 아주 약하게 |

`GetNormalizedScreenSpaceUV`는 "내가 화면 어디 있나"(0~1)를 줘요. SSAO 결과가 화면 크기 텍스처라서 그 자리를 읽어요.

정답: [`Assets/Solutions/Day19/MyToon.shader`](https://github.com/JJH0204/toon-shader-lab/blob/main/Assets/Solutions/Day19/MyToon.shader)

## 3. 확인하기

- 물체 아래 바닥에 **접지 그늘**이 생겨요(맨 위 오른쪽, 바닥 쪽). 바닥(Unity Lit)이 이제 우리 물체를 "봐요."
- 효과가 약하면 `Assets/Settings/PC_Renderer` → **Screen Space Ambient Occlusion** 피처의 Intensity를 잠깐 올려서 확인해 보세요(확인 후 원래 값으로).

## 4. 실험해 보기 (20분)

1. **패스 끄기 실험** — DepthNormals 패스를 주석 처리하면 바닥의 접지 그늘이 다시 사라져요. "패스가 없으면 남이 나를 못 본다." 되돌려요.
2. **AO 세게** — SSAO 피처의 Intensity를 4로. 툰에선 진한 AO가 깔끔한 셀 그림자를 뭉개 보이게 해요. 그래서 실제 툰 셰이더는 AO 세기 다이얼을 따로 둬요.
3. **SSAO 끄기** — 렌더러에서 SSAO 피처 체크를 끄면 `_SCREEN_SPACE_OCCLUSION` 키워드가 꺼져 `aoDirect = aoIndirect = 1`이 돼요. 다시 켜 둬요.
4. 커밋: `git commit -am "Day 19: DepthNormals와 SSAO"`

## 5. 오늘의 액기스

👉 [ESSENCE.md — Day 19](essence.md#day-19)

## 더 읽을거리

- [Wikipedia — Screen space ambient occlusion](https://en.wikipedia.org/wiki/Screen_space_ambient_occlusion) · [LearnOpenGL — SSAO](https://learnopengl.com/Advanced-Lighting/SSAO)
- [URP — Ambient Occlusion 설정](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@17.0/manual/post-processing-ssao.html)
- 더 깊이: [toon-shader-study Day 10 — 환경광, GI, SSAO](../toon-shader-study/day10-ambient-gi-ssao.md) · [Day 18 — 패스 총정리](../toon-shader-study/day18-passes.md)

---

[← Day 18](day18-keywords.md) · [목차](README.md) · [다음: Day 20 →](day20-two-sided.md)
