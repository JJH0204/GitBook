# Day 06. 빛의 수학 — 화살표와 내적, 그리고 램버트

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSS-007-DO |
| 유형 | D&O (개념) + 코드 읽기·실습 |
| 목적 | 벡터와 내적으로 표면 밝기(램버트, 하프 램버트)를 계산하는 방법과 이 셰이더의 `lightVal` 생성 과정을 설명한다 |
| 소요 시간 | 약 1시간 (읽기 25분, 코드 읽기 15분, 실습 20분) |
| 선수 지식 | Day 02 (좌표 공간, 월드 공간 노멀), Day 05 (ILM 맵) |
| 확인 상태 | 미검증 (소스를 읽고 작성했으며 Unity에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

비유: 내적은 "두 화살표가 얼마나 같은 쪽을 보나"를 매기는 점수이고, 빛은 손전등이다.

## 학습 목표

- [ ] 벡터(화살표)와 노멀이 무엇인지 안다
- [ ] `normalize`가 왜 필요한지 안다
- [ ] 내적 `dot(N, L)`이 밝기가 되는 이유를 안다
- [ ] 램버트와 하프 램버트의 차이를 그래프로 설명할 수 있다
- [ ] 이 셰이더의 `lightVal`이 어떻게 만들어지는지 안다

## 1. 정의

벡터는 방향과 길이를 가진 화살표다. `(0, 1, 0)`은 위쪽으로 길이 1, `(1, 0, 0)`은 오른쪽으로 길이 1이다.

내적(dot product)은 두 벡터를 받아 숫자 하나를 돌려주는 연산이다. 두 벡터의 길이가 1이면 내적은 두 벡터 사이 각도 θ의 코사인(cos θ)과 같다.

램버트(Lambert) 반사는 표면 밝기가 표면 노멀과 빛 방향의 내적에 비례한다는 확산 반사 모델이다. 하프 램버트(Half-Lambert)는 Valve가 만든 변형으로, 내적 범위 -1~1을 0~1로 옮긴 값이다.

## 2. 구성 요소

| 기호 | 이름 | 의미 | 비유 |
|---|---|---|---|
| `N` | 노멀 (Normal) | 표면이 바라보는 방향 | 해바라기 얼굴 |
| `L` | 빛 방향 (Light) | 표면에서 빛 쪽을 가리키는 방향 | 표면에서 해를 가리키는 손가락 |
| `V` | 시선 방향 (View) | 표면에서 카메라를 가리키는 방향 | 표면에서 내 눈을 가리키는 손가락 |

{% hint style="info" %}
NOTE: URP의 `light.direction`은 빛이 날아가는 방향이 아니라 표면에서 빛 쪽을 가리키는 방향이다. 해가 위에 있으면 `L = (0, 1, 0)`이다.
{% endhint %}

## 3. 동작 원리

### 3.1 정규화

내적이 각도(코사인)가 되려면 두 벡터의 길이가 모두 1이어야 한다. 길이를 1로 맞추는 연산이 정규화(`normalize`)다.

```hlsl
half3 N = normalize(input.normalWS);              // L302
half3 V = normalize(GetWorldSpaceViewDir(...));   // L307
```

{% hint style="warning" %}
CAUTION: 길이가 0인 벡터 `(0, 0, 0)`을 정규화하면 0으로 나누어 NaN(숫자가 아님)이 나온다. NaN은 이후 계산으로 전파되어 화면이 검게 되거나 깜빡인다. 이 셰이더는 위험한 곳에서 안전 정규화를 쓴다. [ToonLighting.hlsl L9–13](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonLighting.hlsl#L9-L13)
{% endhint %}

```hlsl
float2 SafeNormalizeXZ(float2 v, float2 fallback)
{
    float lenSq = dot(v, v);                                  // 길이의 제곱
    return lenSq > 1e-6 ? v * rsqrt(lenSq) : fallback;       // 너무 짧으면 예비 방향
}
```

`rsqrt(x)`는 `1 / sqrt(x)`다. `v * (1 / 길이)`는 길이 1인 벡터다.

### 3.2 내적

```
dot(A, B) = A.x × B.x + A.y × B.y + A.z × B.z
```

| 두 벡터(길이 1)의 관계 | 각도 | `dot` |
|---|---|---|
| 같은 방향 | 0° | 1 |
| 비스듬히 | 60° | 0.5 |
| 직각 | 90° | 0 |
| 반대 방향 | 180° | -1 |

![내적](../.gitbook/assets/concept-dot-product.png)

손전등 비유로 밝기와 내적의 관계를 설명한다. 벽을 정면에서 비추면 작고 밝은 원이 생긴다. 비스듬히 비추면 같은 양의 빛이 넓은 면적에 나뉘어 어두워진다. 벽과 나란히 비추면 빛이 거의 닿지 않는다. 이 "얼마나 정면으로 비추나"가 `dot(N, L)`이다.

### 3.3 램버트와 하프 램버트

| 모델 | 수식 | 값 범위 | 특징 |
|---|---|---|---|
| 램버트 | `max(0, dot(N, L))` (`saturate(dot(N, L))`과 같다) | 0~1 | 90°를 넘으면 0으로 고정된다. 뒤쪽 절반은 구별이 안 된다 |
| 하프 램버트 | `dot(N, L) * 0.5 + 0.5` | 0~1 | 뒤쪽까지 0~0.5로 계속 변한다. 0~1 구간 전체를 쓴다 |

![램버트 vs 하프 램버트](../.gitbook/assets/concept-lambert-vs-half.png)

그래프에서 램버트(파랑)는 90°를 넘는 순간 0으로 떨어지고, 하프 램버트(주황)는 뒤쪽에서도 연속으로 변한다.

{% hint style="info" %}
NOTE: 하프 램버트는 값이 0~1을 고르게 쓰므로 Day 07의 경계선(Border)을 0.5에 두면 빛과 직각인 곳(`dot = 0`)에서 그림자가 시작된다. 경계선을 옮기기도 쉽다. 이 셰이더 패키지의 모든 셰이더가 하프 램버트를 쓴다. Valve 원 구현은 결과를 제곱하는 변형(`pow(x, 2)`)도 쓰지만 이 소스는 제곱하지 않는다.
{% endhint %}

## 4. 코드 읽기

### 4.1 빛 방향 고르기

[CharacterToon.shader L347–352](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L347-L352)

```hlsl
half3 L;
if (_CharacterLightDirWS.w > 0.5h && dot(_CharacterLightDirWS.xyz, _CharacterLightDirWS.xyz) > 1e-6) {
    L = normalize(_CharacterLightDirWS.xyz);    // 캐릭터 전용 조명이 있으면 그걸 쓰고
} else {
    L = mainLight.direction;                     // 없으면 씬의 해(메인 라이트)를 쓴다
}
```

| 대상 | 설명 |
|---|---|
| `_CharacterLightDirWS.w` | 1이면 캐릭터 전용 조명 사용, 0이면 미사용 (Day 09) |
| `dot(v, v)` | 자기 자신과의 내적이며 길이의 제곱이다. 0이 아닌지 확인하는 방법이다 |
| `mainLight.direction` | 씬의 메인 라이트 방향 |

### 4.2 하프 램버트와 ILM 편향

[CharacterToon.shader L355–358](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L355-L358)

```hlsl
half ndotl = dot(N, L);                                   // 손전등 점수 (-1~1)
half halfLambert = ndotl * 0.5h + 0.5h;                    // 0~1 로 옮김
half shadowBias = (ilm.g - 0.5h) * _ShadowOffsetScale;     // ILM.G: 그림자 잘 생기는 곳 지도
half lightVal = saturate(halfLambert + shadowBias);        // 0=그림자, 1=빛
```

| 변수 | 범위 | 의미 |
|---|---|---|
| `ndotl` | -1~1 | `N`, `L`이 모두 정규화된 경우의 코사인 |
| `halfLambert` | 0~1 | 하프 램버트 |
| `shadowBias` | `±0.5 × _ShadowOffsetScale` | ILM 맵 G 채널 기반 편향. 0.5보다 작게 칠한 곳은 음수가 되어 그림자가 먼저 생긴다 |
| `lightVal` | 0~1 | 0이 그림자, 1이 빛 |

`lightVal`은 이 셰이더의 중심 값이다. 그림자 단계(Day 07), 드리운 그림자(Day 08), 얼굴 그림자(Day 15)가 모두 이 값을 가공한다. ILM의 G 채널은 겨드랑이와 옷 주름처럼 빛이 와도 그림자가 졌으면 하는 곳을 미리 어둡게 칠해 두는 용도다(Day 05).

### 4.3 배경 셰이더는 같은 식을 함수로 쓴다

[ToonRamp.hlsl L13–16](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/ToonShared/ShaderLibrary/ToonRamp.hlsl#L13-L16) · [SceneToon.shader L239–241](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Shaders/SceneToon.shader#L239-L241)

```hlsl
half ToonHalfLambert(half ndotl) { return ndotl * 0.5h + 0.5h; }
...
half hl = ToonHalfLambert(dot(N, L));
half lightVal = ToonRampU(hl, shadowBias);    // saturate(hl + bias)
```

{% hint style="info" %}
NOTE: 캐릭터 셰이더는 공식을 직접 쓰고 배경 셰이더는 `ToonShared`의 함수를 부른다. 같은 식을 두 곳에 둔 이유는 [ToonRamp.hlsl L5–7 주석](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/ToonShared/ShaderLibrary/ToonRamp.hlsl#L5-L7)에 있다. 안정된 캐릭터 셰이더가 배경 작업 때문에 흔들리지 않도록 독립시킨 것이다. 한쪽을 고치면 다른 쪽도 직접 맞춰야 한다.
{% endhint %}

## 5. 주의

- `normalize`하지 않은 벡터로 `dot`을 구하면 코사인이 아니라 길이가 곱해진 값이 나온다. 보간된 노멀(`input.normalWS`)은 길이가 1이 아닐 수 있으므로 프래그먼트 셰이더에서 다시 정규화한다.
- 내적 결과를 0~1로 쓰려면 램버트는 `saturate`/`max(0, …)`, 하프 램버트는 `*0.5+0.5`로 범위를 정한다. 범위를 정하지 않으면 음수가 이후 계산(예: `pow`)에서 NaN을 만들 수 있다.
- `L`의 부호 규약(표면에서 빛 쪽)이 틀리면 밝기가 뒤집힌다. 직접 만든 빛 벡터는 URP 규약에 맞춘다.

## 6. 실습

1. 내적을 손으로 계산한다. `N = (0, 1, 0)`, `L = (0.6, 0.8, 0)`이면 `dot = 0×0.6 + 1×0.8 + 0×0 = 0.8`이다. → 결과: 하프 램버트는 `0.8×0.5+0.5 = 0.9`다.
2. 반대편 빛을 계산한다. `L = (0, -1, 0)`이면 램버트는 `max(0, -1) = 0`, 하프 램버트는 `-1×0.5+0.5 = 0`이다. → 결과: 두 값이 같다.
3. 옆에서 오는 빛을 계산한다. `L = (1, 0, 0)`이면 → 결과: 램버트 0, 하프 램버트 0.5로 다르다. 이 차이가 그래프의 차이다.
4. ILM 편향을 계산한다. `halfLambert = 0.55`, `ILM.G = 0.2`, `_ShadowOffsetScale = 0.2`이면 `lightVal = 0.55 + (0.2-0.5)×0.2 = 0.49`다. → 결과: 경계선 0.5 아래이므로 그림자 쪽이다.
5. [Desmos](https://www.desmos.com/calculator)에 `y = max(0, cos(x))`와 `y = cos(x)*0.5+0.5`를 입력한다. x는 라디안이며 π ≈ 3.14가 180°다. → 결과: 램버트는 π/2 이후 0으로 고정되고 하프 램버트는 계속 변한다.

## 7. 참조

- [3Blue1Brown — 벡터](https://www.3blue1brown.com/lessons/vectors) · [내적과 쌍대성](https://www.3blue1brown.com/lessons/dot-products)
- [Khan Academy — 벡터와 공간](https://www.khanacademy.org/math/linear-algebra/vectors-and-spaces) (영어)
- [위키백과 — 스칼라곱(내적)](https://ko.wikipedia.org/wiki/%EC%8A%A4%EC%B9%BC%EB%9D%BC%EA%B3%B1) · [삼각함수](https://ko.wikipedia.org/wiki/%EC%82%BC%EA%B0%81%ED%95%A8%EC%88%98)
- [Valve Developer — Half Lambert](https://developer.valvesoftware.com/wiki/Half_Lambert) (영어)
- [Wikipedia — Lambertian reflectance](https://en.wikipedia.org/wiki/Lambertian_reflectance) (영어)
- [LearnOpenGL — Basic Lighting](https://learnopengl.com/Lighting/Basic-Lighting) · [Catlike Coding — Rendering 4: The First Light](https://catlikecoding.com/unity/tutorials/rendering/part-4/) (영어)
- [Microsoft — dot](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-dot)
- 오늘의 요약: [ESSENCE.md — Day 06](essence.md#day-06)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 내적이 "정면으로 비추는 정도"가 되는 이유를 손전등 예로 설명한다.
- [ ] 램버트 대신 하프 램버트를 툰 셰이더에서 쓰는 이유를 적는다.
- [ ] 직접 셰이더를 짜다가 `normalize` 때문에 화면이 깨진 경험이 있다면 적는다. 없다면 어떤 경우에 깨질지 예상해 적는다.

---

[← Day 05](day05-textures-and-uv.md) · [목차](README.md) · [다음: Day 07 →](day07-toon-steps.md)
