# Day 10. 하늘빛과 안개 — 그림자 속이 깜깜하지 않은 이유

> ⏱ **약 1시간** — 개념 15분 · 코드 25분 · 실험 20분
> 🧸 **오늘의 비유**: 직접광은 **해가 직접 비추는 빛**, 간접광은 **하늘과 벽에 튕겨서 온 빛**이에요. SH는 사방의 하늘빛을 **숫자 몇 개로 줄인 날씨 엽서**예요.

![Day 10 결과](../.gitbook/assets/day10-ambient.png)

## 오늘 만들 것

그림자 쪽에 **은은한 하늘빛**이 더해져서 탁하던 그림자가 맑아져요(오른쪽). 덤으로 **안개**도 받아요.

## 오늘 배울 것

- [ ] `SampleSH(N)`으로 하늘빛(환경광)을 받는다
- [ ] 환경광을 **그림자 쪽엔 덜** 더하는 이유를 안다
- [ ] 그림자 바닥(Shade Floor)으로 너무 까매지는 걸 막는다
- [ ] URP 안개를 셰이더에 연결한다

---

## 1. 간접광 (개념 15분)

해가 직접 닿지 않는 그늘도 물체가 보이죠. 하늘의 파란빛, 땅에서 튕긴 빛이 사방에서 조금씩 들어오기 때문이에요. 정확히 계산하면 너무 비싸서 Unity는 사방에서 오는 빛을 **SH**(구면 조화)라는 숫자 몇 개로 요약해 둬요. 노멀 방향을 넣으면 "그쪽에서 오는 하늘빛"을 돌려줘요: `SampleSH(N)`.

### 그냥 더하면 안 될까?

툰에서는 조심해야 해요. 밝은 조명에서 빛 쪽과 그림자 쪽 **둘 다** 큰 값을 더하면 둘 다 1을 넘어 하얗게 잘리고, 애써 만든 계단이 사라져요. 그래서 **그림자 쪽엔 덜** 더해서 명암 대비를 지켜요.

```
환경광 × (1 - 그림자 정도)
```

## 2. 코드 고치기 (25분)

### ① Properties (`_ReceiveShadow` 아래) + CBUFFER

```shaderlab
        _AmbientStrength ("Ambient Strength", Range(0, 2)) = 1
        _ShadeFloor ("Shade Floor", Range(0, 1)) = 0.15
```

```hlsl
            half   _AmbientStrength;
            half   _ShadeFloor;
```

CBUFFER는 이제 `HLSLINCLUDE` 안에 있다는 것, 잊지 마세요. (`_ReceiveShadow` 아래에 추가)

### ② 안개 키워드 (Forward 패스의 pragma들 아래)

```hlsl
            #pragma multi_compile_fog
```

### ③ 택배 상자와 vert

```hlsl
                half   fogFactor  : TEXCOORD3;    // Varyings 에 추가
```

```hlsl
                o.fogFactor  = ComputeFogFactor(o.positionCS.z);   // vert 의 return 바로 위
```

안개는 **카메라에서 먼 정도**에 따라 정해지니까, 점마다 한 번 계산해서 넘겨요(픽셀마다 하는 것보다 싸요).

### ④ frag 끝부분

`toon = lerp(...)` 두 줄 다음부터 끝까지를 이렇게 바꿔요.

```hlsl
                half shadeMask = max(shadow1, shadow2);   // 얼마나 그림자인가 (0~1)

                half3 color = toon * mainLight.color;
                half3 ambient = SampleSH(N) * albedo * _AmbientStrength;   // 하늘에서 오는 은은한 빛
                color += ambient * (1.0h - shadeMask);                     // 그림자 쪽엔 덜 더한다
                color = max(color, albedo * _ShadeFloor);                  // 너무 까매지지 않게 바닥

                color = MixFog(color, input.fogFactor);
                return half4(color, baseColor.a);
            }
```

| 줄 | 뜻 |
|---|---|
| `shadeMask` | 1차·2차 중 더 진한 그림자 정도. 0 = 빛, 1 = 그림자 |
| `SampleSH(N) * albedo` | 하늘빛 × 바탕색 |
| `* (1 - shadeMask)` | 그림자 쪽엔 덜 |
| `max(color, albedo * _ShadeFloor)` | 아무리 어두워도 바탕색의 15% 아래로는 안 내려가게 |
| `MixFog` | 안개 색과 섞기. 안개가 꺼져 있으면 아무 일도 안 해요 |

정답: [`Assets/Solutions/Day10/MyToon.shader`](https://github.com/JJH0204/toon-shader-lab/blob/main/Assets/Solutions/Day10/MyToon.shader)

## 3. 확인하기

- 그림자 쪽이 살짝 **푸르고 맑게** 밝아져요(맨 위 오른쪽). 하늘(스카이박스)이 파래서 하늘빛도 파래요.
- **안개**: Window → Rendering → **Lighting** → Environment 탭 → **Fog** 체크. Mode를 Exponential Squared, Density 0.08 정도로 하면 멀리 있는 것이 안개에 묻혀요.

![안개](../.gitbook/assets/day10-fog.png)

확인 후 Fog는 꺼 두세요. (켜 두면 앞으로의 화면이 정답 사진과 달라 보여요.)

## 4. 실험해 보기 (20분)

1. **그냥 더하기** — `color += ambient;`로 바꾸고 Directional Light Intensity를 3으로 올려 보세요. 그림자 계단이 하얗게 사라지는 게 보여요. 되돌리면 계단이 살아나요. Intensity도 1.2로 되돌려요.
2. **Shade Floor** — Ambient Strength를 0으로 하고 Shade Floor를 0 ↔ 0.5로 움직여 보세요. 2차 그림자가 바닥에 닿는 곳이 들렸다 내려갔다 해요.
3. **하늘색 바꾸기** — Lighting 창 Environment의 Environment Lighting Source를 Color로, 색을 주황으로 바꾸면 그림자 쪽이 주황빛이 돼요. 확인 후 Skybox로 되돌려요.
4. 커밋: `git commit -am "Day 10: 환경광과 안개"`

## 5. 오늘의 액기스

👉 [ESSENCE.md — Day 10](essence.md#day-10)

## 더 읽을거리

- [Wikipedia — Spherical harmonic lighting](https://en.wikipedia.org/wiki/Spherical_harmonic_lighting) · [Unity — 라이트 프로브 기술 정보](https://docs.unity3d.com/Manual/LightProbes-TechnicalInformation.html)
- 더 깊이: [toon-shader-study Day 10 — 환경광, GI, SSAO](../toon-shader-study/day10-ambient-gi-ssao.md) (라이트맵을 계단으로 만드는 배경 셰이더 방식)

---

[← Day 09](day09-cast-shadows.md) · [목차](README.md) · [다음: Day 11 →](day11-additional-lights.md)
