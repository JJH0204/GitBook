# Day 06. 첫 조명 — 손전등과 내적

> ⏱ **약 1시간** — 개념 20분 · 코드 15분 · 실험 25분
> 🧸 **오늘의 비유**: 빛은 **손전등**, 내적은 **"두 화살표가 얼마나 같은 쪽을 보나" 점수**예요.

![Day 06 결과](../.gitbook/assets/day06-half-lambert.png)

## 오늘 만들 것

드디어 **해를 받아요.** 빛을 정면으로 받는 쪽은 밝고, 등진 쪽은 어두워요. 아직 계단(툰)이 아니라 **미끄럼틀처럼 부드러운** 밝기예요. 이 밝기 값 `lightVal`이 툰 셰이더의 심장이 돼요.

## 오늘 배울 것

- [ ] N(노멀)과 L(빛 방향) 화살표를 안다
- [ ] 내적 `dot(N, L)`이 밝기가 되는 이유를 손전등으로 설명할 수 있다
- [ ] 램버트와 하프 램버트의 차이를 안다
- [ ] `GetMainLight()`로 해의 방향과 색을 받는다

---

## 1. 손전등과 내적 (개념 20분)

손전등으로 벽을 **정면에서** 비추면 작고 밝은 동그라미가 생겨요. **비스듬히** 비추면 같은 빛이 넓게 퍼져서 어두워지고, 벽과 **나란히** 비추면 거의 안 닿아요. 이 "얼마나 정면으로 비추나"를 숫자로 만든 게 **내적**이에요.

![내적](../.gitbook/assets/concept-dot-product.png)

```
dot(A, B) = A.x·B.x + A.y·B.y + A.z·B.z
```

길이가 1인 두 화살표의 내적은 둘 사이 각도의 cos 값이에요. 같은 방향 **1**, 직각 **0**, 반대 **-1**.

| 화살표 | 뜻 |
|---|---|
| **N** | 표면이 바라보는 방향 (Day 04의 `N`) |
| **L** | 표면에서 **해를 가리키는** 방향 (URP의 `mainLight.direction`) |

### 램버트 vs 하프 램버트

![램버트 vs 하프 램버트](../.gitbook/assets/concept-lambert-vs-half.png)

- **램버트** `max(0, N·L)`: 해를 등진 절반이 전부 0이라 똑같이 깜깜해요.
- **하프 램버트** `N·L × 0.5 + 0.5`: -1~1을 **0~1로 옮겨요.** 뒤쪽까지 고르게 변해서, 내일 "어디서부터 그림자로 할까" 경계선을 0.5에 두면 딱 **빛과 직각인 곳**이 돼요. 툰 셰이더에 딱 맞아요.

## 2. 코드 고치기 (15분)

### ① 조명 공구함 가져오기

`Core.hlsl` include **바로 아래**에:

```hlsl
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"   // ← 추가
```

### ② Debug View에 LightVal 추가

Properties의 Debug View 줄을 바꿔요.

```shaderlab
        [Enum(Off,0,Normal,1,UV,2,LightVal,3)] _DebugView ("Debug View", Float) = 0
```

### ③ frag: 빛 계산

`half3 N = ...` 다음에 빛 계산 두 줄, 디버그 줄 하나, 그리고 마지막 `return`을 바꿔요.

```hlsl
    half3 N = normalize(input.normalWS);

    Light mainLight = GetMainLight();
    half lightVal = dot(N, mainLight.direction) * 0.5h + 0.5h;   // 하프 램버트: 0(뒤) ~ 1(정면)

    // 디버그 보기: 눈에 안 보이는 값을 색으로 꺼내 본다
    if (_DebugView > 2.5h) return half4(lightVal.xxx, 1.0h);
    if (_DebugView > 1.5h) return half4(input.uv, 0.0h, 1.0h);
    if (_DebugView > 0.5h) return half4(N * 0.5h + 0.5h, 1.0h);

    half3 color = baseColor.rgb * mainLight.color * lightVal;
    return half4(color, baseColor.a);
}
```

- `Light`는 URP가 정한 구조체예요. `direction`(해 쪽 방향), `color`(색 × 세기), 그리고 나중에 쓸 `shadowAttenuation`(그림자) 등이 들어 있어요.
- `lightVal.xxx` — 숫자 하나를 세 칸에 복사해 흑백 색으로 (Day 04의 스위즐!).
- `baseColor.rgb * mainLight.color * lightVal` — 바탕색 × 빛 색 × 밝기. 색끼리 곱하면 **필터를 씌운** 색이 돼요.

정답: [`Assets/Solutions/Day06/MyToon.shader`](https://github.com/JJH0204/toon-shader-lab/blob/main/Assets/Solutions/Day06/MyToon.shader)

## 3. 확인하기

- **Debug View = LightVal**: 해 쪽(오른쪽 위)이 하얗고 반대쪽으로 갈수록 회색. 완전히 검지는 않아요(하프 램버트라서).
- **Debug View = Off**: 오른쪽이 밝고 왼쪽이 어두운 주황색 물체.

## 4. 실험해 보기 (25분)

1. **해 돌리기** — Hierarchy에서 Directional Light를 선택하고 Rotation Y를 돌려 보세요. 밝은 쪽이 따라 돌아요. 해를 물체 뒤로 보내면 앞면이 어두워져요.
2. **램버트로 바꾸기** — `lightVal`을 `saturate(dot(N, mainLight.direction))`로 바꿔 보세요. 뒤쪽 절반이 **새까매요.** `saturate`는 0~1 울타리예요. 비교 후 되돌려요.
3. **해 색** — Directional Light의 Color를 주황으로 바꾸면 물체도 물들어요. `mainLight.color`가 곱해지니까요.
4. **손계산** — N = (0, 1, 0), L = (0.6, 0.8, 0)이면 `dot = 0.8`, `lightVal = 0.9`. L = (1, 0, 0)이면? (`dot = 0`, `lightVal = 0.5` — 딱 경계)
5. 커밋: `git commit -am "Day 06: 하프 램버트 조명"`

## 5. 오늘의 액기스

👉 [ESSENCE.md — Day 06](essence.md#day-06)

## 수학 참고 자료

- 🎥 [3Blue1Brown — 내적](https://www.3blue1brown.com/lessons/dot-products) — 내적이 왜 "같은 쪽을 보는 정도"인지 애니메이션으로
- [위키백과 — 스칼라곱(내적)](https://ko.wikipedia.org/wiki/%EC%8A%A4%EC%B9%BC%EB%9D%BC%EA%B3%B1) · [Khan Academy — 벡터](https://www.khanacademy.org/math/linear-algebra/vectors-and-spaces)
- [Valve — Half Lambert](https://developer.valvesoftware.com/wiki/Half_Lambert) · [Wikipedia — Lambertian reflectance](https://en.wikipedia.org/wiki/Lambertian_reflectance)
- [LearnOpenGL — Basic Lighting](https://learnopengl.com/Lighting/Basic-Lighting) · [Catlike Coding — The First Light](https://catlikecoding.com/unity/tutorials/rendering/part-4/)
- 더 깊이: [toon-shader-study Day 06 — 빛의 수학](../toon-shader-study/day06-vectors-and-light.md)

---

[← Day 05](day05-textures.md) · [목차](README.md) · [다음: Day 07 →](day07-toon-steps.md)
