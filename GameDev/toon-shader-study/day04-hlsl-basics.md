# Day 04. HLSL 문법 기초 — GPU의 말 배우기

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSS-005-DO |
| 유형 | D&O (개념) + 코드 읽기 |
| 목적 | HLSL 자료형, 스위즐, 입출력 구조체와 시맨틱, 전처리기, `CBUFFER`, 자주 쓰는 내장 함수를 설명한다 |
| 소요 시간 | 약 1시간 (읽기 30분, 코드 읽기 15분, 실습 15분) |
| 선수 지식 | [Day 02](day02-coordinate-spaces.md), [Day 03](day03-shaderlab-skeleton.md) |
| 확인 상태 | 미검증 (소스를 읽고 작성했으며 Unity에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

비유: `struct`는 택배 상자이고, 시맨틱은 상자 칸의 이름표다.

## 학습 목표

- [ ] `float`, `half`, `float3`, `half4` 같은 자료형을 읽을 수 있다
- [ ] 스위즐(`.xyz`, `.rgb`, `.xz`)로 값을 꺼낼 수 있다
- [ ] `Attributes`, `Varyings` 구조체와 시맨틱의 역할을 안다
- [ ] `#include`, `#ifndef`, `#define`, `#if defined()`를 읽을 수 있다
- [ ] 자주 나오는 내장 함수 10개를 안다

## 1. 정의

{% hint style="info" %}
NOTE: HLSL(High-Level Shading Language)은 GPU 코드를 작성하는 C 계열 언어다. 데이터는 메시 → 버텍스 셰이더 → 프래그먼트 셰이더 순서로 구조체에 담겨 전달되고, 구조체 멤버에 붙은 시맨틱이 각 칸의 용도를 GPU에 알려 준다.
{% endhint %}

## 2. 구성 요소

### 2.1 자료형

| 자료형 | 의미 | 쓰는 곳 |
|---|---|---|
| `float` | 32비트 부동소수점 | 위치, 깊이, UV처럼 정밀도가 필요한 값 |
| `half` | 16비트 부동소수점 | 색, 노멀, 밝기처럼 0~1 근처 값 |
| `float2` | 숫자 2개 | UV |
| `float3`, `half3` | 숫자 3개 | 위치 `xyz`, 색 `rgb`, 방향 |
| `float4`, `half4` | 숫자 4개 | 색+투명도 `rgba`, 클립 좌표 `xyzw` |
| `float3x3`, `float4x4` | 행렬 | 좌표 변환 (Day 02) |

이 패키지는 위치는 `float`, 색과 빛은 `half`를 쓴다. 숫자 뒤의 `h`(`1.0h`, `0.5h`)는 half 리터럴 표시다.

{% hint style="info" %}
NOTE: `half`의 실제 정밀도는 플랫폼에 따라 다르다. 모바일 GPU는 16비트로 처리해 빠르지만 많은 데스크톱 GPU는 `half`를 32비트로 처리한다. 이 경우 정밀도와 속도 차이가 없다.
{% endhint %}

### 2.2 구조체와 시맨틱

[CharacterToon.shader L256–270](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L256-L270)

```hlsl
struct Attributes                      // 상자 1: 메시 → 버텍스 셰이더
{
    float4 positionOS : POSITION;      //   POSITION = 정점 위치
    float3 normalOS   : NORMAL;        //   NORMAL = 노멀
    float2 uv         : TEXCOORD0;     //   TEXCOORD0 = 첫 번째 UV
};

struct Varyings                        // 상자 2: 버텍스 셰이더 → 프래그먼트 셰이더
{
    float4 positionCS : SV_POSITION;   //   SV_ = 시스템 값. 화면 위치 (필수)
    float2 uv         : TEXCOORD0;     //   여기부터는 임의 데이터 칸
    float3 normalWS   : TEXCOORD1;
    float3 positionWS : TEXCOORD2;
    half   fogFactor  : TEXCOORD3;
};
```

| 구조체 | 시맨틱 | 의미 |
|---|---|---|
| `Attributes` | `POSITION`, `NORMAL`, `TANGENT`, `COLOR`, `TEXCOORD0~7` | 메시의 어느 데이터를 이 멤버에 넣을지 지정 |
| `Varyings` | `SV_POSITION` | 클립 공간 위치. 버텍스 셰이더의 필수 출력 |
| `Varyings` | `TEXCOORD1, 2, 3...` | 보간할 임의 데이터 칸. 이름과 달리 UV가 아니어도 된다 |
| 프래그먼트 함수 | `: SV_TARGET` | 반환값이 최종 렌더 타깃 색 |

{% hint style="info" %}
NOTE: 프래그먼트 셰이더에서 `SV_POSITION` 입력은 클립 좌표가 아니라 화면 픽셀 좌표(`xy`는 픽셀 위치)다. 버텍스 단계의 출력은 클립 공간 값이고, 래스터라이저를 거치면서 값의 의미가 바뀐다.
{% endhint %}

## 3. 동작 원리

### 3.1 스위즐

`float4 v = (1, 2, 3, 4);`에서 점 뒤에 성분 이름을 붙여 원하는 칸만 꺼낸다.

| 식 | 결과 | 설명 |
|---|---|---|
| `v.x` | 1 | 한 성분 |
| `v.xyz` | (1, 2, 3) | 앞 세 성분 |
| `v.xz` | (1, 3) | 높이(y)를 빼고 바닥 평면 성분만 |
| `v.zyx` | (3, 2, 1) | 순서 변경 |
| `v.xxx` | (1, 1, 1) | 같은 성분 반복 |
| `v.rgb` | (1, 2, 3) | `xyz`와 같다. 색에는 `rgba` 표기가 읽기 좋다 |

{% hint style="warning" %}
CAUTION: 한 스위즐에서 `xyzw` 계열과 `rgba` 계열을 섞어 쓰면 컴파일 오류가 난다(`v.xg` 불가).
{% endhint %}

실제 예: 얼굴 그림자는 빛 방향을 바닥 평면(XZ)에 투영해 쓴다. [CharacterToon.shader L372](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L372)

```hlsl
float2 lightXZ = SafeNormalizeXZ(L.xz, float2(0.0, 1.0));   // 빛 방향에서 x와 z만 꺼냄
```

### 3.2 보간

버텍스 셰이더는 삼각형 꼭짓점에서만 실행되지만 프래그먼트 셰이더는 삼각형 안의 모든 픽셀에서 실행된다. `Varyings` 값은 래스터라이저가 세 꼭짓점 값을 무게중심 좌표로 섞어 픽셀마다 만든다(원근 보정 보간). 이것을 보간(interpolation)이라 한다.

![정점 보간](../.gitbook/assets/concept-interpolation.png)

{% hint style="warning" %}
CAUTION: 길이가 1인 노멀 두 개를 섞으면 길이가 1보다 짧아진다. 프래그먼트 셰이더 첫머리에서 노멀을 다시 `normalize`한다. [L302](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L302): `half3 N = normalize(input.normalWS);`
{% endhint %}

### 3.3 전처리기

`#`로 시작하는 줄은 컴파일 전에 처리된다.

| 명령 | 의미 | 예 |
|---|---|---|
| `#include "파일"` | 그 파일 내용을 그 자리에 붙여 넣는다 | `#include "../ShaderLibrary/ToonInput.hlsl"` |
| `#ifndef X` / `#define X` / `#endif` | 중복 포함 방지 (include guard) | 모든 `.hlsl` 파일의 첫 두 줄과 끝 |
| `#define 이름 값` | 상수 매크로 | `#define CHARACTER_EXTRA_LIGHT_MAX 3` |
| `#if defined(키워드)` / `#endif` | 키워드가 꺼져 있으면 그 코드는 컴파일되지 않는다 | `#if defined(_USE_RIM)` |
| `#pragma` | 컴파일러 지시 | `#pragma vertex vert` |

[ToonRim.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/ToonShared/ShaderLibrary/ToonRim.hlsl)의 중복 방지 구조다.

```hlsl
#ifndef TOONSHARED_RIM_INCLUDED     // 아직 정의돼 있지 않으면
#define TOONSHARED_RIM_INCLUDED     //   정의하고
...                                 //   내용을 넣는다
#endif                              // 이미 정의돼 있었으면 통째로 건너뛴다
```

### 3.4 머티리얼 값 상자: CBUFFER

[ToonInput.hlsl L34–178](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonInput.hlsl#L34-L178)

```hlsl
CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    half4  _BaseColor;
    ...
CBUFFER_END
```

머티리얼의 숫자·색 값을 한 상수 버퍼(`UnityPerMaterial`)에 모아 GPU에 넘긴다. 텍스처와 샘플러는 상수 버퍼에 넣을 수 없어 별도로 선언한다([L13–31](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonInput.hlsl#L13-L31)).

{% hint style="warning" %}
CAUTION: [L4–5 주석](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonInput.hlsl#L4-L5)대로 모든 패스가 이 파일 하나만 include한다. SRP Batcher는 같은 셰이더의 모든 패스에서 `UnityPerMaterial` 상수 버퍼의 구성이 동일하고 Properties의 모든 값이 그 안에 있어야 호환된다. 상자 내용은 이 한 곳에서만 정의한다(Day 20).
{% endhint %}

## 4. 코드 읽기

[ToonRim.hlsl L10–15](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/ToonShared/ShaderLibrary/ToonRim.hlsl#L10-L15)

```hlsl
half3 ToonRim(half3 N, half3 V, half threshold, half softness, half3 rimColor, half intensity)
{
    half fresnel = 1.0h - saturate(dot(N, V));
    half rim = smoothstep(threshold, threshold + max(softness, 1e-4h), fresnel);
    return rim * rimColor * intensity;
}
```

| 대상 | 설명 |
|---|---|
| 함수 선언 | `반환형 이름(인자...)` |
| `dot`, `saturate`, `smoothstep`, `max` | HLSL 내장 함수 (Day 06, 07, 11) |
| `1e-4h` | 0.0001 (half). `softness`가 0일 때 `smoothstep`의 두 경계가 같아져 결과가 정의되지 않는 것을 막는 하한 |
| `half3 * half3` | 성분별 곱. `(r1·r2, g1·g2, b1·b2)` |

### 내장 함수 10개

| 함수 | 의미 | 예 |
|---|---|---|
| `saturate(x)` | 0~1로 자른다 | `saturate(1.5) = 1` |
| `lerp(a, b, t)` | 선형 보간 | `lerp(a, b, 0.5)` = 중간 값 |
| `min(a,b)`, `max(a,b)` | 작은 쪽, 큰 쪽 | `max(x, 1e-4)` = 하한 |
| `normalize(v)` | 벡터 길이를 1로 | Day 06 |
| `dot(a, b)` | 내적. 두 벡터가 같은 방향인 정도 | Day 06 |
| `cross(a, b)` | 외적. 두 벡터에 수직인 벡터 | Day 16 |
| `pow(x, n)` | x의 n제곱 | Day 03, 17 |
| `step(a, x)` | x가 a 이상이면 1, 아니면 0 | Day 07 |
| `smoothstep(a, b, x)` | a~b 구간에서 부드럽게 0→1 | Day 07 |
| `clip(x)` | x가 0보다 작으면 이 픽셀을 버린다 | Day 05 |

## 5. 주의

{% hint style="info" %}
NOTE: `half` 처리, `SV_POSITION`의 프래그먼트 단계 의미, `UnityPerMaterial` 선언 매크로(`CBUFFER_START`)는 URP/SRP 기준이다. Built-in 파이프라인은 `UnityPerMaterial` 상수 버퍼를 쓰지 않으며 SRP Batcher도 없다.
{% endhint %}

## 6. 실습 (15분)

1. `ToonRim`을 손으로 계산한다. `threshold = 0.6`, `softness = 0.05`일 때 `dot(N, V) = 0.3`이면 `fresnel = 0.7`이다. → 결과: 0.7은 0.65 이상이므로 `rim = 1`.
2. 같은 조건에서 `dot(N, V) = 0.38`이면 `fresnel = 0.62`다. → 결과: 0.6~0.65 구간 안이다. `smoothstep` 입력 `t = (0.62 - 0.6) / 0.05 = 0.4`이고 `t²(3 - 2t) = 0.352`이다.
3. [ToonInput.hlsl CBUFFER](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonInput.hlsl#L34-L178) 안의 `half4` 선언 개수를 센다. → 결과: 개수를 기록한다.
4. `float4 c = (0.2, 0.4, 0.6, 1.0);`일 때 `c.bgr`와 `c.ww`를 쓴다. → 결과: `(0.6, 0.4, 0.2)`, `(1.0, 1.0)`.
5. `fogFactor`를 버텍스 셰이더 [L281](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L281)에서 넣고 프래그먼트 셰이더에서 꺼내는 곳을 찾는다. → 결과: [L664](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L664) 부근에서 사용된다.

오늘의 요약: [essence.md — Day 04](essence.md#day-04)

## 7. 참조

- Microsoft HLSL 문서: [언어 레퍼런스](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-reference), [자료형](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-data-types), [시맨틱](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-semantics), [saturate](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-saturate), [lerp](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-lerp)
- [LearnOpenGL — Shaders](https://learnopengl.com/Getting-started/Shaders): GLSL이지만 입력·출력·보간 개념이 같다 (영어)
- [Catlike Coding — Rendering 2: Shader Fundamentals](https://catlikecoding.com/unity/tutorials/rendering/part-2/) (영어)
- [Wikipedia — Barycentric coordinates](https://en.wikipedia.org/wiki/Barycentric_coordinate_system), [Half-precision float](https://en.wikipedia.org/wiki/Half-precision_floating-point_format), [Swizzling](https://en.wikipedia.org/wiki/Swizzling_(computer_graphics))

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `Attributes`와 `Varyings`가 각각 어디서 어디로 데이터를 전달하는지 내 말로 적는다
- [ ] 프래그먼트 셰이더에서 노멀을 다시 `normalize`해야 하는 이유를 적는다
- [ ] `float`과 `half`를 나눠 쓴 경험이 있으면 어떤 값에 무엇을 썼는지 적는다

---

[← Day 03](day03-shaderlab-skeleton.md) · [목차](README.md) · [다음: Day 05 →](day05-textures-and-uv.md)
