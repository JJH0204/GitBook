# Day 02. 버텍스 셰이더 — 점을 움직여 보자

> ⏱ **약 1시간** — 개념 20분 · 코드 15분 · 실험 25분
> 🧸 **오늘의 비유**: 좌표 공간은 **주소 체계**("내 방 책상 위" → "서울시 ○○동" → "모니터 몇 번째 칸"), 행렬은 **주소를 바꿔 주는 기계**예요.

![Day 02 결과](../.gitbook/assets/day02-breathing.png)

## 오늘 만들 것

물체가 **숨을 쉬어요.** 표면이 노멀 방향으로 부풀었다 줄었다 하고, 높이마다 박자가 달라서 물결이 위로 올라가는 것처럼 보여요. 위 사진의 구가 울퉁불퉁한 게 그 순간을 찍은 거예요.

## 오늘 배울 것

- [ ] 오브젝트(OS) · 월드(WS) · 클립(CS) 공간을 구분한다
- [ ] `TransformObjectToWorld`, `TransformWorldToHClip`으로 주소를 바꿀 수 있다
- [ ] 노멀(`NORMAL`)을 받아 월드 노멀로 바꿀 수 있다
- [ ] `_Time`과 `sin`으로 시간에 따라 움직이는 값을 만든다

---

## 1. 같은 점, 다른 주소 (개념 20분)

![좌표 공간](../.gitbook/assets/concept-coordinate-spaces.png)

| 공간 | 변수 끝 | 기준 | 비유 |
|---|---|---|---|
| 오브젝트 | `OS` | 모델 자기 자신 | 내 방 책상 왼쪽에서 10cm |
| 월드 | `WS` | 세상 전체 | 서울시 ○○동 123번지 |
| 뷰 | `VS` | 카메라 | 내 눈에서 앞으로 50cm |
| 클립 | `CS` | 화면 직전 상자 (`x, y, z, w`) | 사진기 뷰파인더 안 |

Day 01의 `TransformObjectToHClip`은 오브젝트 → 클립을 **한 번에** 했어요. 오늘은 중간에 **월드에 들렀다 가요.** 월드에서 위치를 고치려고요.

![행렬 기계](../.gitbook/assets/concept-matrix-machine.png)

행렬은 이동·회전·크기를 한 번에 하는 기계예요. URP가 기계를 미리 만들어 둬서 우리는 함수 이름만 부르면 돼요. `Transform A To B` = "A 동네 주소를 B 동네 주소로".

{% hint style="info" %}
`HClip`의 H는 "동차(Homogeneous)"예요. 클립 주소는 숫자가 4개(`x, y, z, w`)이고, GPU가 마지막에 `x, y`를 `w`로 나눠서 **먼 것을 작게** 만들어요. `w`는 Day 14에서 아주 중요하게 다시 만나요.
{% endhint %}

## 2. 코드 고치기 (15분)

### ① 택배 상자에 노멀 칸 추가

`Attributes`에 한 줄을 추가해요.

```hlsl
struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;      // ← 추가: 표면이 바라보는 방향
};
```

**노멀**(normal)은 표면이 바라보는 방향이에요. 해바라기 얼굴이 향하는 쪽이라고 생각하세요. `: NORMAL` 이름표를 붙이면 Unity가 메시의 노멀을 이 칸에 넣어 줘요.

### ② vert 함수 바꾸기

`vert` 안의 `o.positionCS = ...` 한 줄을 아래 네 줄로 바꿔요.

```hlsl
Varyings vert(Attributes input)
{
    Varyings o = (Varyings)0;
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    float3 normalWS   = TransformObjectToWorldNormal(input.normalOS);
    // 숨쉬기: 시간에 따라 노멀 방향으로 부풀었다 줄었다 한다. 높이마다 박자가 다르다.
    positionWS += normalWS * (sin(_Time.y * 3.0 + positionWS.y * 8.0) * 0.03);
    o.positionCS = TransformWorldToHClip(positionWS);
    return o;
}
```

| 줄 | 하는 일 |
|---|---|
| `TransformObjectToWorld` | 오브젝트 주소 → **월드 주소** |
| `TransformObjectToWorldNormal` | 노멀도 월드로. 노멀은 위치가 아니라 **방향**이라 전용 함수가 있어요(물체를 한쪽으로 납작하게 늘려도 노멀이 비뚤어지지 않게) |
| `_Time.y` | 게임 시작 후 흐른 **초**. URP가 매 프레임 넣어 줘요 |
| `sin(...)` | -1과 1 사이를 오가는 **파도**. 시간을 넣으면 앞뒤로 흔들려요 |
| `positionWS.y * 8.0` | 높이를 섞어서 **위치마다 박자를 다르게** |
| `* 0.03` | 최대 3cm만 움직이게 |
| `positionWS += normalWS * (...)` | **노멀 방향으로** 밀기 = 부풀리기 |
| `TransformWorldToHClip` | 고친 월드 주소 → 클립 주소 |

{% hint style="success" %}
"**노멀 방향으로 밀기**"를 꼭 기억하세요. Day 13에서 이 기술로 **외곽선**을 만들어요.
{% endhint %}

## 3. 확인하기

- Scene 뷰는 평소에 멈춰 있어요. Scene 뷰 위쪽 툴바의 **효과(Effects) 메뉴 → Always Refresh**를 켜거나, **Play** 버튼을 누르면 숨쉬는 모습이 보여요.
- 숨쉬지 않는다면? Console에 오류가 있는지 먼저 보세요. 오타가 가장 흔해요(`TransformObjectToWorldNormal`은 길어서 잘 틀려요).

정답: [`Assets/Solutions/Day02/MyToon.shader`](https://github.com/JJH0204/toon-shader-lab/blob/main/Assets/Solutions/Day02/MyToon.shader)

## 4. 실험해 보기 (25분)

1. **크게 숨쉬기** — `0.03`을 `0.2`로. 풍선처럼 부풀어요. 큐브는 **면이 따로따로 떨어지는 것**이 보이나요? 큐브는 모서리 점이 면마다 따로 있어서 노멀이 달라요. (Day 13에서 외곽선을 만들 때 이 문제를 다시 만나요.)
2. **월드 vs 오브젝트** — `positionWS.y * 8.0`을 `input.positionOS.y * 8.0`으로 바꿔 보세요. 그리고 Capsule을 위로 들어 올려 보세요.
   - `positionWS.y`일 때: 물결 무늬가 **세상에 붙어 있어서** 물체를 움직이면 무늬가 물체 위를 미끄러져요.
   - `positionOS.y`일 때: 물결 무늬가 **물체에 붙어서** 같이 따라와요.
   - 어떤 주소로 계산하느냐에 따라 결과가 달라진다는 게 핵심이에요.
3. **옆으로 흔들기** — 마지막 줄 전에 `positionWS.x += sin(_Time.y * 2.0) * 0.3;`을 넣으면? 셋이 똑같이 좌우로 흔들려요.
4. 커밋: `git commit -am "Day 02: 숨쉬는 버텍스 셰이더"`

{% hint style="info" %}
숨쉬기는 오늘만 하는 실험이에요. Day 03에서 원래대로 되돌려요. 실제 툰 셰이더는 점을 움직이지 않지만, 버텍스 셰이더가 무엇을 할 수 있는지 손으로 느껴 보는 게 목적이에요.
{% endhint %}

## 5. 오늘의 액기스

👉 [ESSENCE.md — Day 02](essence.md#day-02)

## 수학 참고 자료

- 🎥 [3Blue1Brown — 벡터](https://www.3blue1brown.com/lessons/vectors) · [선형 변환과 행렬](https://www.3blue1brown.com/lessons/linear-transformations) · [행렬 곱셈 = 변환 이어 붙이기](https://www.3blue1brown.com/lessons/matrix-multiplication)
- [LearnOpenGL — Transformations](https://learnopengl.com/Getting-started/Transformations) · [Coordinate Systems](https://learnopengl.com/Getting-started/Coordinate-Systems)
- [위키백과 — 삼각함수](https://ko.wikipedia.org/wiki/%EC%82%BC%EA%B0%81%ED%95%A8%EC%88%98) — sin 파도가 처음이면 · [Desmos](https://www.desmos.com/calculator)에서 `y = \sin(3x)`를 그려 보세요
- 더 깊이: [toon-shader-study Day 02 — 좌표 공간 여행](../toon-shader-study/day02-coordinate-spaces.md)

---

[← Day 01](day01-first-shader.md) · [목차](README.md) · [다음: Day 03 →](day03-properties.md)
