# Day 09. 그림자 드리우기 — 패스를 더 만들고 코드를 나눠 쓰기

> ⏱ **약 1시간** — 정리 15분 · 새 패스 두 개 30분 · 확인 15분
> 🧸 **오늘의 비유**: 한 물체를 그리는 **촬영 팀**이 늘어나요. 색칠 팀 말고 **그림자 팀**(빛 자리에서 거리 사진 찍기)과 **깊이 팀**(카메라에서 거리 사진 찍기)이 생겨요. 팀이 여럿이면 **공용 준비물**을 한곳에 둬요.

![Day 09 결과](../.gitbook/assets/day09-cast-shadow.png)

## 오늘 만들 것

우리 물체가 바닥과 서로에게 **그림자를 드리워요**(오른쪽). 그리고 깊이 지도에도 찍혀요(나중에 SSAO와 화면 외곽선이 써요).

## 오늘 배울 것

- [ ] `HLSLINCLUDE`로 여러 패스가 같은 코드를 나눠 쓴다
- [ ] 모든 패스가 **같은 CBUFFER**를 써야 하는 이유를 안다
- [ ] ShadowCaster 패스와 `ApplyShadowBias`를 짠다
- [ ] DepthOnly 패스를 짠다
- [ ] "모든 패스가 같은 가위를 쓴다"는 규칙을 안다

---

## 1. 공용 준비물 모으기: HLSLINCLUDE (15분)

패스를 더 만들면 각 패스도 `_BaseMap`, `_BaseColor`, `_Cutoff`가 필요해요. 그리고 SRP Batcher는 **모든 패스의 CBUFFER 모양이 똑같아야** 동작해요. 패스마다 따로 적다가 하나만 빠뜨리면 끝이에요.

그래서 `SubShader` 안, `Pass`보다 **위에** `HLSLINCLUDE` 블록을 만들어요. 여기 적은 코드는 **모든 패스의 `HLSLPROGRAM` 앞에 자동으로 붙어요.**

### ① Forward 패스에서 잘라 내서 위로 옮기기

Forward 패스의 `HLSLPROGRAM` 안에서 아래 세 가지를 **잘라 내요.**
- `#include ".../Core.hlsl"` 줄
- `TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);` 줄
- `CBUFFER_START` … `CBUFFER_END` 블록 전체

그리고 `Tags { "RenderPipeline" ... }` 줄 **아래**에 붙여 넣고, 가위 함수 `ClipAlpha`를 추가해요.

```hlsl
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }

        // 여러 패스가 함께 쓰는 코드. 모든 패스의 HLSLPROGRAM 앞에 자동으로 붙는다.
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        TEXTURE2D(_BaseMap);    SAMPLER(sampler_BaseMap);

        // 머티리얼 값 상자. 모든 패스가 같은 모양이어야 SRP Batcher 가 동작한다.
        CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4  _BaseColor;
            half   _Cutoff;
            half4  _ShadowColor;
            half   _ShadowBorder;
            half   _ShadowBlur;
            half4  _Shadow2ndColor;
            half   _Shadow2ndBorder;
            half   _Shadow2ndBlur;
            half   _ReceiveShadow;
            half   _DebugView;
        CBUFFER_END

        // 모든 패스가 같은 가위를 쓴다: 투명도가 기준보다 낮으면 버린다.
        void ClipAlpha(float2 uv)
        {
            half alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv).a * _BaseColor.a;
            clip(alpha - _Cutoff);
        }
        ENDHLSL

        Pass
        {
            Name "Forward"
            ...
```

Forward 패스에는 `#include ".../Lighting.hlsl"`만 남아요.

### ② Forward의 가위도 공용 함수로

frag의 `clip(baseColor.a - _Cutoff);`를 바꿔요.

```hlsl
    half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;
    ClipAlpha(input.uv);
```

`void`는 "돌려주는 값 없음"이에요. 가위질만 하는 함수니까요.

{% hint style="success" %}
여기까지 저장하면 화면은 **어제와 똑같아야** 해요. 코드를 옮기기만 했으니까요. 이렇게 "모양만 바꾸고 결과는 그대로"인 정리를 **리팩터링**이라고 해요. 정리할 때마다 결과가 그대로인지 확인하는 습관을 들이세요.
{% endhint %}

## 2. 그림자 팀: ShadowCaster 패스 (20분)

Forward 패스의 마지막 `}` **다음**(SubShader 안)에 새 패스를 추가해요.

```hlsl
        // 그림자 지도 찍기: 빛의 자리에서 '거리'만 기록한다
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            ZWrite On
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM
            #pragma vertex ShadowVert
            #pragma fragment ShadowFrag
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            float3 _LightDirection;   // URP 가 채워 준다: 해의 방향
            float3 _LightPosition;    // 포인트·스폿 조명의 위치

            struct ShadowAttributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
            };

            struct ShadowVaryings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
            };

            ShadowVaryings ShadowVert(ShadowAttributes input)
            {
                ShadowVaryings o = (ShadowVaryings)0;
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 normalWS   = TransformObjectToWorldNormal(input.normalOS);
            #if defined(_CASTING_PUNCTUAL_LIGHT_SHADOW)
                float3 lightDirWS = normalize(_LightPosition - positionWS);
            #else
                float3 lightDirWS = _LightDirection;
            #endif
                // 표면을 살짝 밀어서 '그림자 여드름'(자기 자신을 가리는 착각)을 막는다
                o.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirWS));
            #if UNITY_REVERSED_Z
                o.positionCS.z = min(o.positionCS.z, UNITY_NEAR_CLIP_VALUE);
            #else
                o.positionCS.z = max(o.positionCS.z, UNITY_NEAR_CLIP_VALUE);
            #endif
                o.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                return o;
            }

            half4 ShadowFrag(ShadowVaryings input) : SV_Target
            {
                ClipAlpha(input.uv);   // 오려 낸 곳은 그림자도 안 생긴다
                return 0;
            }
            ENDHLSL
        }
```

| 부분 | 뜻 |
|---|---|
| `LightMode = ShadowCaster` | "그림자 지도 찍을 때 불러 주세요" |
| `ColorMask 0` | 색은 안 써요. 거리(깊이)만 기록하니까 |
| `_CASTING_PUNCTUAL_LIGHT_SHADOW` | 포인트·스폿 조명은 위치가 있어서 점마다 방향을 따로 계산 |
| `_LightDirection`, `_LightPosition` | 이름만 맞춰 선언하면 URP가 값을 넣어 줘요 |
| `ApplyShadowBias` | 섀도맵은 픽셀로 된 사진이라 비스듬한 면은 **자기 자신을 가린다고 착각**해요(그림자 여드름). 표면을 빛·노멀 쪽으로 살짝 밀어서 막아요 |
| `UNITY_REVERSED_Z` 블록 | 빛 카메라 앞쪽 경계를 넘어간 점을 경계에 붙여서 그림자가 잘리지 않게 해요 (URP 표준 코드) |
| `ClipAlpha` | 공용 가위 — Day 05의 구멍이 그림자에도 뚫려요 |

패스마다 함수 이름이 달라요(`ShadowVert`/`ShadowFrag`). 같은 이름을 써도 패스끼리는 남남이지만, 다르게 지으면 읽기 쉬워요.

## 3. 깊이 팀: DepthOnly 패스 (10분)

ShadowCaster 패스 다음에 추가해요. 카메라 기준 **깊이 지도**(`_CameraDepthTexture`)에 우리 물체를 찍는 패스예요. 나중에 SSAO(Day 19)와 화면 외곽선(Day 21)이 이 지도를 읽어요.

```hlsl
        // 깊이 지도 찍기: 카메라에서 얼마나 먼지만 기록한다
        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }
            ZWrite On
            ColorMask R

            HLSLPROGRAM
            #pragma vertex DepthVert
            #pragma fragment DepthFrag

            struct DepthAttributes
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
            };

            struct DepthVaryings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
            };

            DepthVaryings DepthVert(DepthAttributes input)
            {
                DepthVaryings o = (DepthVaryings)0;
                o.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                o.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                return o;
            }

            half4 DepthFrag(DepthVaryings input) : SV_Target
            {
                ClipAlpha(input.uv);
                return 0;
            }
            ENDHLSL
        }
```

정답: [`Assets/Solutions/Day09/MyToon.shader`](https://github.com/JJH0204/toon-shader-lab/blob/main/Assets/Solutions/Day09/MyToon.shader)

## 4. 확인하기 (15분)

- 바닥에 물체 세 개의 **그림자**가 생겨요(맨 위 오른쪽). 캡슐 그림자가 큐브에도 떨어져요.
- 머티리얼 Alpha Cutoff를 0.5로 올리면 바닥 그림자에도 **구멍**이 보여요. 공용 가위 덕분이에요. 확인 후 0으로 되돌려요.
- **모든 패스가 같은 가위를 써야 하는 이유**: 색칠 팀만 오리면 없는 부분이 그림자를 드리우고, 깊이 지도에 유령 모양이 남아요. 실제 게임 셰이더에서도 자주 나오는 버그예요([toon-shader-study Day 18](../toon-shader-study/day18-passes.md) 참고).

{% hint style="info" %}
구의 그림자 쪽 경계에 **얼룩덜룩한 계단**이 보일 수 있어요. 자기 그림자가 빛과 거의 직각인 곳(경계)에 걸리면서 툰 계단이 그 오차를 키워서 생기는 현상이에요. Directional Light의 Shadows → **Bias**를 Custom으로 바꾸고 Normal 값을 올리거나 머티리얼의 **Receive Shadow**를 낮추면 줄어요. 툰 셰이더에서 흔히 만나는 숙제예요.
{% endhint %}

## 5. 실험해 보기

1. **패스 하나 지워 보기** — ShadowCaster 패스를 통째로 주석 처리(`/* … */`)하면 그림자가 사라져요. 되돌려요.
2. **Bias 체험** — Directional Light의 Shadows → Bias를 **Custom**으로 바꾸고 Depth·Normal을 0으로 내리면 물체 표면에 줄무늬 **그림자 여드름**이 생겨요. 다 보면 Bias를 다시 *Use settings from Render Pipeline Asset*으로 돌려놔요.
3. 커밋: `git commit -am "Day 09: 그림자 드리우기와 깊이 패스"`

## 6. 오늘의 액기스

👉 [ESSENCE.md — Day 09](essence.md#day-09)

## 더 읽을거리

- [LearnOpenGL — Shadow Mapping](https://learnopengl.com/Advanced-Lighting/Shadows/Shadow-Mapping) (그림자 여드름, 피터팬 현상 그림)
- [Unity — Pass 태그(LightMode)](https://docs.unity3d.com/Manual/SL-Pass.html)
- 더 깊이: [toon-shader-study Day 08 — 그림자](../toon-shader-study/day08-shadows.md) · [Day 18 — 패스 총정리](../toon-shader-study/day18-passes.md)

---

[← Day 08](day08-receive-shadows.md) · [목차](README.md) · [다음: Day 10 →](day10-ambient-fog.md)
