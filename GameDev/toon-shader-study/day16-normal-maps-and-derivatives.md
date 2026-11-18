# Day 16. 노멀맵과 미분 — 옆 픽셀에게 물어보기

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSS-017-DO |
| 유형 | D&O (개념) + 코드 읽기 + 실습 |
| 목적 | 노멀맵과 탄젠트 공간, 화면 공간 미분(`ddx`, `ddy`, `fwidth`), 탄젠트 없는 노멀맵 구성을 설명한다 |
| 소요 시간 | 약 1시간 (읽기 25분, 코드 읽기 25분, 실습 10분) |
| 선수 지식 | [Day 02](day02-coordinate-spaces.md) 좌표 변환, [Day 05](day05-textures-and-uv.md) UV·밉맵, [Day 06](day06-vectors-and-light.md) |
| 확인 상태 | 미검증 (소스를 읽고 작성했으며 Unity에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- [ ] 노멀맵이 무엇이고 색 (0.5, 0.5, 1)이 왜 평평함인지 안다
- [ ] 탄젠트 공간(T, B, N)이 무엇인지 안다
- [ ] `ddx`, `ddy`, `fwidth`가 2×2 픽셀 묶음에서 계산된다는 것을 안다
- [ ] 캐릭터 셰이더가 메시 탄젠트 없이 노멀맵을 쓰는 이유를 안다
- [ ] 미분을 쓰면 안 되는 곳(분기 안)을 안다

## 1. 정의

- 노멀맵: 표면 각 점의 노멀을 색으로 저장한 텍스처. 형상은 그대로 두고 빛 계산에만 쓰는 노멀을 바꿔 요철을 표현한다. 비유: 빛에게만 하는 거짓말.
- 화면 공간 미분: 같은 2×2 픽셀 묶음(쿼드) 안의 이웃 픽셀 값 차이로 변화율을 근사하는 `ddx`, `ddy`. 비유: 옆자리 친구 답안 보기.

## 2. 구성 요소

### 2.1 노멀맵 인코딩

노멀은 -1~1, 색은 0~1이므로 변환해 저장한다.

| 방향 | 식 |
|---|---|
| 저장 | `색 = 노멀 × 0.5 + 0.5` |
| 읽기 | `노멀 = 색 × 2 − 1` (`UnpackNormal`이 수행) |

평평한 곳의 노멀은 `(0, 0, 1)`이고 색은 `(0.5, 0.5, 1)`(연한 보라색)이다. 텍스처 기본값 `"bump"`도 이 색이다.

{% hint style="info" %}
NOTE: `UnpackNormal`은 플랫폼별 압축 형식(DXT5nm은 xy를 a·g 채널에, BC5, ASTC 등)에 맞춰 z를 복원한다. 직접 `색 × 2 − 1`만 쓰면 압축 노멀맵에서 틀린 값이 나온다. 텍스처의 Texture Type을 Normal map으로 두고 `UnpackNormal`/`UnpackNormalScale`을 쓴다. 지원 형식은 플랫폼과 Unity 버전에 따라 다르다.
{% endhint %}

### 2.2 탄젠트 공간

노멀맵의 벡터는 표면 기준 좌표계(탄젠트 공간)로 적혀 있다.

| 축 | 이름 | 방향 |
|---|---|---|
| T | 탄젠트 | 텍스처 u가 커지는 방향 |
| B | 바이탄젠트 | v가 커지는 방향 |
| N | 노멀 | 표면 바깥쪽 |

노멀맵 벡터를 월드로 옮기려면 T, B, N을 열(또는 행)로 하는 행렬(TBN)에 곱한다([Day 02](day02-coordinate-spaces.md)).

### 2.3 미분 함수

![2x2 쿼드 미분](../.gitbook/assets/day16-quad-derivatives.png)

| 함수 | 뜻 |
|---|---|
| `ddx(v)` | 가로로 한 칸 이웃 픽셀의 v 차이(오른쪽 − 왼쪽) |
| `ddy(v)` | 세로로 한 칸 이웃 픽셀의 v 차이(아래 − 위) |
| `fwidth(v)` | `abs(ddx(v)) + abs(ddy(v))` |

GPU는 픽셀을 2×2 묶음(쿼드)으로 동시에 처리하므로 이웃 픽셀의 값을 읽을 수 있다. 이웃과의 차이로 미분을 근사하는 방식을 유한 차분이라 한다.

{% hint style="info" %}
NOTE: HLSL의 `ddx`/`ddy`는 하드웨어에 따라 coarse(쿼드당 한 값) 또는 fine(픽셀별) 미분으로 구현된다. 정밀도를 고르려면 `ddx_fine`/`ddx_coarse`를 쓴다. 플랫폼별 동작 확인 필요.
{% endhint %}

## 3. 동작 원리

### 3.1 메시 탄젠트를 쓰는 방법

배경 셰이더의 방식이다. [SceneToon.shader L211–217](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Shaders/SceneToon.shader#L211-L217)

```hlsl
half3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, input.uv), _BumpScale);
half3 Tn = normalize(input.tangentWS.xyz);
half3 Bn = normalize(cross(N, Tn) * input.tangentWS.w);   // B = N과 T에 모두 수직 (cross)
N = normalize(mul(normalTS, half3x3(Tn, Bn, N)));          // 표면 지도 → 월드
```

| 줄 | 설명 |
|---|---|
| `cross(N, Tn)` | 두 벡터에 모두 수직인 벡터(외적) |
| `tangentWS.w` | 거울처럼 뒤집힌 UV를 위한 ±1 부호 |
| `mul(normalTS, half3x3(...))` | 벡터를 왼쪽에 둔 곱이므로 행렬의 행이 T, B, N이다 |

### 3.2 탄젠트 없는 방법

캐릭터는 `TANGENT` 칸에 외곽선용 스무스 노멀을 넣었으므로([Day 12](day12-outline-inverted-hull.md)) 진짜 탄젠트가 없다. 픽셀마다 이웃과의 위치·UV 변화에서 T, B를 즉석으로 만든다. 화면 미분으로 TBN을 구성하는 이 방법은 Christian Schüler의 글에서 왔다(6절 참조).

[ToonLighting.hlsl L33–55](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonLighting.hlsl#L33-L55)

```hlsl
half3 ApplyNormalMapDerivative(half3 N, float3 positionWS, float2 uv, half3 normalTS)
{
    float3 dp1 = ddx(positionWS); float3 dp2 = ddy(positionWS);   // 옆 픽셀로 갈 때 위치가 어떻게 변하나
    float2 duv1 = ddx(uv);        float2 duv2 = ddy(uv);          // 옆 픽셀로 갈 때 UV가 어떻게 변하나

    float3 dp2perp = cross(dp2, (float3)N);
    float3 dp1perp = cross((float3)N, dp1);
    float3 T = dp2perp * duv1.x + dp1perp * duv2.x;               // "u가 커지는 월드 방향"
    float3 B = dp2perp * duv1.y + dp1perp * duv2.y;               // "v가 커지는 월드 방향"

    float maxLenSq = max(dot(T, T), dot(B, B));
    float invmax = rsqrt(max(maxLenSq, 1e-30));                   // 크기 맞추기 (0 나눗셈만 방지)
    float3x3 tangentToWorld = float3x3(T * invmax, B * invmax, (float3)N);
    return (half3)normalize(mul((float3)normalTS, tangentToWorld));
}
```

| 단계 | 설명 |
|---|---|
| `dp1`, `dp2` | 가로·세로로 한 픽셀 이동할 때 월드 위치 변화 |
| `duv1`, `duv2` | 같은 이동에서 UV 변화 |
| `T`, `B` | 위치 변화와 UV 변화를 연결해 u, v가 커지는 월드 방향을 구한다 |
| `invmax` | 두 벡터의 큰 쪽 길이로 나눠 크기를 맞춘다. 방향만 쓰므로 0 나눗셈 방지만 한다 |

장점은 메시 탄젠트가 필요 없고, 애니메이션으로 휘어도 그 순간의 표면으로 계산한다는 점이다.

{% hint style="warning" %}
CAUTION (이 프로젝트의 실제 사례): 예전 코드는 `if (maxLenSq < 1e-12) return N;`으로 T, B가 작으면 포기했다. T, B의 크기는 픽셀이 덮는 면적에 비례하므로 카메라가 가까워지면 정상인데도 작아져, 가까이 갈수록 노멀맵이 꺼졌다. 크기가 아니라 방향만 쓰므로 0 나눗셈만 막는 바닥 값으로 바꿨다. [L45–49 주석](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonLighting.hlsl#L45-L49)
{% endhint %}

### 3.3 UV 방향 벡터만 구하기

[ToonLighting.hlsl L18–26](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonLighting.hlsl#L18-L26)

```hlsl
float3 GetUVTangentWS(float3 positionWS, float2 uv)
{
    float3 dpdx = ddx(positionWS); float3 dpdy = ddy(positionWS);
    float2 duvdx = ddx(uv);        float2 duvdy = ddy(uv);
    float det = duvdx.x * duvdy.y - duvdy.x * duvdx.y;
    float3 t = (dpdx * duvdy.y - dpdy * duvdx.y) * (det >= 0.0 ? 1.0 : -1.0);
    float lenSq = dot(t, t);
    return lenSq > 1e-8 ? t * rsqrt(lenSq) : float3(1.0, 0.0, 0.0);
}
```

같은 원리로 u가 커지는 방향 하나만 구한다. 머리카락 결 방향이 필요한 천사 고리([Day 17](day17-highlights.md))와 눈 시차 효과가 쓴다.

## 4. 주의

{% hint style="warning" %}
CAUTION: 미분은 쿼드의 4픽셀이 같은 경로를 실행할 때만 신뢰할 수 있다. `if` 안에서 일부 픽셀만 들어가면 이웃 값이 정의되지 않은 값이 된다. 텍스처 밉맵 선택([Day 05](day05-textures-and-uv.md))도 내부적으로 미분을 쓴다.
{% endhint %}

품질 페이드([Day 20](day20-performance.md))는 픽셀 위치가 아니라 물체 원점으로 거리를 잰다. 한 물체의 모든 픽셀이 같은 결과를 내므로 `if` 안에서 미분을 써도 안전하다. [CharacterToon.shader L323–325 주석](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L323-L325)

## 5. 실습

1. 색을 노멀로 읽는다. 색 (0.5, 0.5, 1)이다. → 결과: 노멀 `(0, 0, 1)`(평평)이다.
2. 색 (1, 0.5, 0.5)를 읽는다. → 결과: 노멀 `(1, 0, 0)`이며 오른쪽으로 완전히 누운 노멀이다.
3. 쿼드 미분을 계산한다. 2×2 묶음의 u가 왼쪽 위 0.30, 오른쪽 위 0.34, 왼쪽 아래 0.31이다. → 결과: `ddx(u) = 0.04`, `ddy(u) = 0.01`, `fwidth(u) = 0.05`이다.
4. 거리 효과를 추정한다. 카메라가 2배 가까워지면 한 픽셀이 덮는 표면이 반으로 준다. → 결과: `ddx(positionWS)` 길이는 약 절반이다. T는 `dp × duv` 꼴이라 약 1/4이므로 절대 기준 값은 근거리에서 틀린다.
5. 분기를 판단한다. `if (input.uv.x > 0.5) { x = fwidth(sdf); }`가 안전한지 따진다. → 결과: 안전하지 않다. 같은 쿼드 안에서 일부 픽셀만 분기에 들어갈 수 있다.

## 6. 참조

- [Day 16 액기스](essence.md#day-16)
- [LearnOpenGL — Normal Mapping](https://learnopengl.com/Advanced-Lighting/Normal-Mapping)
- [Christian Schüler — Followup: Normal Mapping Without Precomputed Tangents](http://www.thetenthplanet.de/archives/1180): 이 셰이더가 쓴 방법의 원문
- [Wikipedia — Normal mapping](https://en.wikipedia.org/wiki/Normal_mapping), [Finite difference](https://en.wikipedia.org/wiki/Finite_difference)
- [3Blue1Brown — 외적](https://www.3blue1brown.com/lessons/cross-products), [위키백과 — 벡터곱](https://ko.wikipedia.org/wiki/%EB%B2%A1%ED%84%B0%EA%B3%B1)
- [Microsoft — ddx](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-ddx), [fwidth](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-fwidth)
- [Catlike Coding — Rendering 6: Bumpiness](https://catlikecoding.com/unity/tutorials/rendering/part-6/)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 노멀맵이 "빛에게만 하는 거짓말"인 이유를 내 말로 설명한다.
- [ ] `ddx`가 이웃 픽셀을 볼 수 있는 이유를 GPU 처리 방식으로 설명한다.
- [ ] 탄젠트가 없을 때 위치 변화와 UV 변화를 연결해 T를 구한다는 아이디어를 내 말로 적는다.

---

[← Day 15](day15-face-sdf.md) · [목차](README.md) · [다음: Day 17 →](day17-highlights.md)
