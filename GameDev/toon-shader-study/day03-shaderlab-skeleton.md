# Day 03. 셰이더 파일의 뼈대 — 하늘 셰이더 통째로 읽기

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSS-004-DO |
| 유형 | D&O (개념) + 코드 읽기 |
| 목적 | ShaderLab 구조(`Shader`, `Properties`, `SubShader`, `Pass`, `HLSLPROGRAM`), `LightMode`, 렌더 스테이트를 설명하고 70줄짜리 하늘 셰이더를 끝까지 읽는다 |
| 소요 시간 | 약 1시간 (읽기 20분, 코드 읽기 25분, 실습 15분) |
| 선수 지식 | [Day 01](day01-what-is-a-shader.md), [Day 02](day02-coordinate-spaces.md) |
| 확인 상태 | 미검증 (소스를 읽고 작성했으며 Unity에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

비유: `.shader` 파일은 요리책 한 권이다.

## 학습 목표

- [ ] `Shader`, `Properties`, `SubShader`, `Pass`, `HLSLPROGRAM`의 역할을 안다
- [ ] `Tags`의 `LightMode`가 렌더러가 패스를 호출하는 시점을 정하는 이름표라는 것을 안다
- [ ] `Cull`, `ZWrite`, `ZTest`, `Blend` 같은 렌더 스테이트를 읽을 수 있다
- [ ] 70줄짜리 하늘 셰이더를 처음부터 끝까지 설명할 수 있다

## 1. 정의

{% hint style="info" %}
NOTE: Unity 셰이더 파일은 ShaderLab과 HLSL 두 언어로 이루어진다. ShaderLab은 셰이더 이름, 프로퍼티, 패스 구조, 렌더 스테이트를 기술하는 Unity 전용 형식이다. HLSL은 GPU에서 실행되는 코드이며 `HLSLPROGRAM`과 `ENDHLSL` 사이에만 쓴다.
{% endhint %}

## 2. 구성 요소

```shaderlab
Shader "셰이더 이름"                // 머티리얼 드롭다운에 보이는 이름
{
    Properties { ... }              // 인스펙터에 나타나는 칸
    SubShader                       // 파이프라인별 구현 단위
    {
        Tags { ... }                // SubShader 전체에 적용되는 태그
        Pass                        // 화면에 한 번 그리는 단위
        {
            Name "..."
            Tags { "LightMode" = "..." }   // 렌더러가 이 패스를 부르는 시점
            Cull / ZWrite / Blend ...      // 렌더 스테이트
            HLSLPROGRAM
                ... GPU 코드 ...
            ENDHLSL
        }
        Pass { ... }                // 패스는 여러 개일 수 있다
    }
    CustomEditor "..."              // 인스펙터 UI를 만드는 C# 클래스
    FallBack "..."                  // 이 셰이더를 쓸 수 없을 때 대신 쓸 셰이더
}
```

| 블록 | 역할 | 비유 |
|---|---|---|
| `Shader` | 이름과 최상위 컨테이너 | 책 제목 |
| `Properties` | 머티리얼 인스펙터 칸 | 재료 목록 |
| `SubShader` | 파이프라인·플랫폼별 구현 | 주방별 레시피 |
| `Pass` | 한 번의 그리기 | 조리 단계 |
| `HLSLPROGRAM` | GPU 코드 | 조리법 |

## 3. 동작 원리

### 3.1 프로퍼티 선언 형식

```
[꾸밈] 변수이름 ("인스펙터 표시 이름", 종류) = 기본값
```

| 종류 | 인스펙터 칸 |
|---|---|
| `Color` | 색 선택 |
| `Range(0.1, 8)` | 0.1~8 슬라이더 |
| `Float` | 숫자 |
| `2D` | 텍스처 |

`[HDR]`은 1보다 큰 색 값을 허용한다. 변수 이름은 관례상 `_`로 시작한다.

### 3.2 렌더 스테이트

[CharacterToon.shader L197–206](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L197-L206)

```shaderlab
Pass
{
    Name "ForwardToon"
    Tags { "LightMode" = "UniversalForwardOnly" }
    Cull [_Cull]
    Blend [_SrcBlend] [_DstBlend]
    ZWrite [_ZWrite]
    ZTest [_ZTestMode]
    Stencil { Ref [_StencilRef] Comp [_StencilComp] Pass [_StencilPass] }
```

대괄호 `[_Cull]`은 프로퍼티 값을 참조한다. 값을 머티리얼에서 정할 수 있다.

| 규칙 | 의미 | 값 |
|---|---|---|
| `Cull` | 어느 면을 그리지 않을지 | `Back`(기본, 앞면만 그림) / `Front` / `Off`(양면) |
| `ZWrite` | 깊이 버퍼에 기록할지 | `On` / `Off` |
| `ZTest` | 깊이 비교 조건 | `LEqual`(기본) / `Always` / `Equal` 등 |
| `Blend` | 이미 칠해진 색과 섞는 방식 | `One Zero`(덮어쓰기) / `SrcAlpha OneMinusSrcAlpha`(반투명) |
| `Stencil` | 스텐실 값에 따라 그릴지 결정 (Day 18) | `Ref` / `Comp` / `Pass` |
| `ColorMask` | 색상 채널 쓰기 | `0`(색 기록 없음), `R`, `RG` 등 |

### 3.3 `Queue` 값

| 큐 | 값 | 용도 |
|---|---|---|
| Background | 1000 | 하늘 등 가장 먼저 그리는 것 |
| Geometry | 2000 | 불투명 물체 (기본) |
| Transparent | 3000 | 투명 물체 |

## 4. 코드 읽기: 하늘 셰이더

[SceneToon_Sky.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Shaders/SceneToon_Sky.shader)는 70줄이다.

### 4.1 이름과 프로퍼티 (L1–13)

```shaderlab
Shader "com.blueigloo/SceneToon/Sky"
{
    Properties
    {
        [HDR] _SkyZenithColor  ("Zenith Color (위)",   Color) = (0.35,0.55,0.85,1)
        [HDR] _SkyHorizonColor ("Horizon Color (수평)", Color) = (0.8,0.85,0.9,1)
        [HDR] _SkyGroundColor  ("Ground Color (아래)",  Color) = (0.5,0.48,0.45,1)
        _SkyHorizonSharp ("Horizon Sharpness", Range(0.1,8)) = 2.0
        _SkyExposure ("Exposure", Range(0,4)) = 1.0
    }
```

### 4.2 SubShader 태그 (L15–17)

```shaderlab
SubShader
{
    Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Background" "Queue" = "Background" }
```

| 태그 | 의미 |
|---|---|
| `RenderPipeline = UniversalPipeline` | URP에서만 사용하는 SubShader |
| `Queue = Background` | 그리는 순서. 하늘은 가장 먼저 그린다 |

### 4.3 패스와 렌더 스테이트 (L19–25)

```shaderlab
Pass
{
    Name "SceneSky"
    Tags { "LightMode" = "UniversalForwardOnly" }
    ZWrite Off
    Cull Off
```

| 줄 | 의미 |
|---|---|
| `LightMode = UniversalForwardOnly` | URP가 불투명 물체를 색칠하는 단계에서 이 패스를 호출한다 |
| `ZWrite Off` | 깊이를 기록하지 않는다. 하늘이 다른 물체를 가리지 않게 한다 |
| `Cull Off` | 앞면·뒷면을 모두 그린다. 하늘 돔의 안쪽에서 보므로 뒷면이 보인다 |

{% hint style="info" %}
NOTE: `UniversalForwardOnly`는 URP 12(Unity 2021.2) 이후에 있는 LightMode이다. Built-in 파이프라인은 `ForwardBase`, `ForwardAdd` 등 다른 이름을 쓰고, URP의 오래된 버전은 `UniversalForward`를 쓴다. 사용 중인 URP 버전에서 확인한다.
{% endhint %}

### 4.4 GPU 코드 (L27–65)

```hlsl
HLSLPROGRAM
#pragma vertex vert          // 버텍스 셰이더 = vert 함수
#pragma fragment frag        // 프래그먼트 셰이더 = frag 함수
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"   // URP 공구함

CBUFFER_START(UnityPerMaterial)   // 머티리얼 값 상자 (Day 04, Day 20)
    half4 _SkyZenithColor;
    ...
CBUFFER_END
```

`Properties`는 인스펙터 칸을 만들고, `CBUFFER`는 HLSL에서 그 값을 읽도록 같은 이름으로 다시 선언한다. 두 곳의 이름과 종류가 일치해야 한다.

```hlsl
half4 frag(Varyings input) : SV_TARGET
{
    half3 dir = normalize(input.dirWS);   // 카메라에서 이 픽셀로 향하는 방향 (길이 1)
    half h = dir.y;                       // 위로 얼마나 향했나: -1(바로 아래) ~ 1(바로 위)
    half up   = saturate(pow(saturate( h), 1.0h / _SkyHorizonSharp));   // 위쪽 정도
    half down = saturate(pow(saturate(-h), 1.0h / _SkyHorizonSharp));   // 아래쪽 정도
    half3 col = _SkyHorizonColor.rgb;                  // 수평선 색에서 시작해서
    col = lerp(col, _SkyZenithColor.rgb, up);          // 위를 볼수록 하늘색 섞기
    col = lerp(col, _SkyGroundColor.rgb, down);        // 아래를 볼수록 땅색 섞기
    return half4(col * _SkyExposure, 1.0h);
}
```

| 함수 | 의미 | 예 |
|---|---|---|
| `saturate(x)` | 0~1로 자른다 | `saturate(1.3) = 1`, `saturate(-0.2) = 0` |
| `pow(x, n)` | x의 n제곱 | `pow(0.5, 2) = 0.25` |
| `lerp(a, b, t)` | `a + (b - a) * t`. t=0이면 a, t=1이면 b | `lerp(0, 10, 0.3) = 3` |

![하늘 그라데이션](../.gitbook/assets/day03-sky-gradient.png)

`_SkyHorizonSharp`를 키우면 지수 `1/sharp`가 작아지고 `pow`가 0 근처의 값을 빠르게 1로 끌어올린다. 그래서 수평선 색의 띠가 얇아진다. 위 그림 오른쪽(8.0)이 그 경우다.

### 4.5 FallBack (L69)

```shaderlab
FallBack "Hidden/Universal Render Pipeline/FallbackError"
```

이 셰이더를 쓸 수 없으면 분홍색(마젠타) 오류 셰이더로 그려 문제를 알린다.

## 5. 캐릭터 셰이더의 패스 6개와 Properties 꾸밈말

[CharacterToon.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader)의 패스는 6개이며 URP가 각 `LightMode`를 보고 해당 시점에 호출한다.

| 패스 이름 | LightMode | 호출 시점 | 배우는 날 |
|---|---|---|---|
| ForwardToon | `UniversalForwardOnly` | 색칠 | Day 06–17 |
| Outline | `SRPDefaultUnlit` | 색칠 직후 추가 패스 | Day 12–13 |
| ShadowCaster | `ShadowCaster` | 그림자 맵 생성 | Day 08 |
| DepthOnly | `DepthOnly` | 깊이 텍스처 생성 | Day 18 |
| DepthNormals | `DepthNormals` | 깊이+노멀 텍스처 생성 (SSAO 등) | Day 18 |
| MotionVectors | `MotionVectors` | 모션 벡터 생성 (모션 블러, TAA) | Day 18 |

{% hint style="info" %}
NOTE: `UniversalForwardOnly`를 쓰는 이유는 [L190–196 주석](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L190-L196)에 있다. 렌더러를 Deferred로 바꿔도 이 캐릭터는 Forward로 그려지게 하려는 선택이다.
{% endhint %}

Properties 꾸밈말은 [CharacterToon.shader L5–184](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L5-L184)에서 확인한다.

| 꾸밈말 | 하는 일 | 예 (줄) |
|---|---|---|
| `[Header(글자)]` | 인스펙터 제목 줄 | `[Header(Base)]` L17 |
| `[HideInInspector]` | 인스펙터에서 숨김 | `_SrcBlend` L10 |
| `[Enum(이름,값,...)]` | 드롭다운 | `_Surface` L9 |
| `[Toggle(키워드)]` | 체크박스 + 셰이더 키워드 켜기 (Day 19) | `_ALPHATEST_ON` L21 |
| `[ToggleUI]` | 체크박스만 (키워드 없음) | `_UseShadowMask` L50 |
| `[KeywordEnum(...)]` | 드롭다운 + 키워드 | `_Part` L54 |
| `[Normal]` | 노멀맵 텍스처 칸 | `_BumpMap` L26 |
| `[IntRange]` | 정수 슬라이더 | `_StencilRef` L170 |

텍스처 기본값 `"white"`, `"black"`, `"bump"`는 텍스처를 지정하지 않았을 때 쓰는 값이다. 마스크 기본값을 `"white"`(= 1)로 두면 곱해도 변화가 없어 효과가 꺼진 상태가 된다.

## 6. 주의

{% hint style="warning" %}
CAUTION: `Properties`에 선언한 값이 `CBUFFER(UnityPerMaterial)`에 없으면 값이 GPU에 올바르게 전달되지 않는다. 또 `UnityPerMaterial` 상자의 구성이 패스마다 다르면 SRP Batcher가 호환되지 않는다(Day 04, Day 20).
{% endhint %}

## 7. 실습 (15분)

1. `dir.y = 0.25`, `_SkyHorizonSharp = 2`일 때 `up`을 계산한다. → 결과: `pow(0.25, 0.5) = 0.5`. `down = 0`이므로 최종 색은 수평선 색과 하늘 색을 1:1로 섞은 색이다.
2. [Desmos](https://www.desmos.com/calculator)에 `y = x^(1/s)`를 입력하고 `s` 슬라이더를 0.5~8로 움직인다. → 결과: `s`가 클수록 곡선이 왼쪽 위로 꺾인다. 수평선 띠가 얇아진다는 뜻이다.
3. [CharacterToon.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader)에서 `Name "`을 검색하고 6개 패스의 이름과 `LightMode`를 표로 적는다. → 결과: 5절 표와 일치한다.
4. ShadowCaster 패스([L759](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L759))가 `ColorMask 0`인 이유를 적는다. → 결과: 그림자 맵에는 색이 필요 없고 깊이만 필요하기 때문이다.

오늘의 요약: [essence.md — Day 03](essence.md#day-03)

## 8. 참조

- Unity 매뉴얼: [Shader 오브젝트](https://docs.unity3d.com/Manual/SL-Shader.html), [Properties](https://docs.unity3d.com/Manual/SL-Properties.html), [SubShader](https://docs.unity3d.com/Manual/SL-SubShader.html), [Pass](https://docs.unity3d.com/Manual/SL-Pass.html)
- 렌더 스테이트: [Cull](https://docs.unity3d.com/Manual/SL-Cull.html), [ZTest](https://docs.unity3d.com/Manual/SL-ZTest.html), [Blend](https://docs.unity3d.com/Manual/SL-Blend.html)
- [URP에서 셰이더 쓰기](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@17.0/manual/writing-custom-shaders-urp.html) (영어)
- [Wikipedia — Linear interpolation](https://en.wikipedia.org/wiki/Linear_interpolation) (영어), [Desmos 그래프 계산기](https://www.desmos.com/calculator)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `Properties`와 `CBUFFER`가 각각 무슨 일을 하는지, 왜 둘 다 필요한지 적는다
- [ ] 하늘 셰이더가 `ZWrite Off`와 `Cull Off`를 쓰는 이유를 내 말로 적는다
- [ ] `LightMode`가 달라야 하는 패스를 한 프로젝트에서 직접 본 경험이 있으면 적는다

---

[← Day 02](day02-coordinate-spaces.md) · [목차](README.md) · [다음: Day 04 →](day04-hlsl-basics.md)
