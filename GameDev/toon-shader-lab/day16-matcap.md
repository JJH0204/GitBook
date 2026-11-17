# Day 16. MatCap — 반사가 그려진 구슬 스티커

> ⏱ **약 1시간** — 개념 15분 · 코드 15분 · 실험 30분
> 🧸 **오늘의 비유**: MatCap은 **반짝이는 공을 찍은 사진 한 장**이에요. 노멀 방향만 알면 "그 방향 표면이 사진에서 어떻게 보였는지"를 찾아 붙일 수 있어요.

![Day 16 결과](../.gitbook/assets/day16-matcap.png)

## 오늘 만들 것

구 왼쪽 위에 **부드러운 광택**이 더해져요(오른쪽). 빛 계산 없이 그림 한 장으로 재질감을 내는 기술이에요.

## 오늘 배울 것

- [ ] 노멀을 **뷰 공간**(내 눈 기준)으로 바꾼다
- [ ] 뷰 공간 노멀의 xy를 UV로 쓰는 원리를 안다
- [ ] 텍스처 하나로 재질을 흉내 내는 MatCap의 장단점을 안다

---

## 1. 원리 (개념 15분)

![MatCap 원리](../.gitbook/assets/concept-matcap-principle.png)

1. 노멀을 **내 눈 기준**(뷰 공간, Day 02)으로 바꿔요. 그러면 "화면에서 이 표면이 어느 쪽을 보나"가 돼요.
2. 노멀의 x, y는 -1~1이에요. `× 0.5 + 0.5`로 0~1로 옮기면 **UV**가 돼요.
3. 정면을 보는 표면 → UV (0.5, 0.5) = 공 사진 가운데. 오른쪽을 보는 표면 → 공 사진 오른쪽 끝.

공 사진은 **모든 방향의 표면**을 한 장에 담고 있으니까, 노멀만 알면 색을 찾아올 수 있어요. `Assets/Textures/Lab_MatCap`을 열어 보세요. 검은 공 왼쪽 위에 반짝임이 그려져 있어요.

## 2. 코드 고치기 (15분)

### ① Properties (Specular 다음, Outline 위)

```shaderlab

        [Header(MatCap)]
        _MatCap ("MatCap", 2D) = "black" {}
        _MatCapStrength ("MatCap Strength", Range(0, 2)) = 1
```

기본 텍스처가 `"black"`인 이유: MatCap은 **더하기**라서 검정(0)을 더하면 아무 변화가 없어요. "안 넣으면 효과 없음" 규칙이에요.

### ② 텍스처 선언 (HLSLINCLUDE, `_BaseMap` 줄 아래) + CBUFFER

```hlsl
        TEXTURE2D(_MatCap);     SAMPLER(sampler_MatCap);
```

```hlsl
            half   _MatCapStrength;     // CBUFFER, _SpecularStep 아래
```

### ③ frag (스펙큘러 다음, `MixFog` 전)

```hlsl
                // MatCap: 내 눈 기준 노멀로 '반사 구슬 사진'에서 색을 찾아 붙인다
                half3 normalVS = mul((float3x3)UNITY_MATRIX_V, N);
                half2 matcapUV = normalVS.xy * 0.5h + 0.5h;
                color += SAMPLE_TEXTURE2D(_MatCap, sampler_MatCap, matcapUV).rgb * _MatCapStrength;
```

`UNITY_MATRIX_V`는 월드 → 뷰 기계. 노멀은 방향이라 이동을 빼고 3×3만 써요.

### ④ 텍스처 넣기

머티리얼의 **MatCap** 칸에 `Assets/Textures/Lab_MatCap`을 넣어요.

정답: [`Assets/Solutions/Day16/MyToon.shader`](https://github.com/JJH0204/toon-shader-lab/blob/main/Assets/Solutions/Day16/MyToon.shader)

## 3. 확인하기

물체 왼쪽 위에 은은한 광택이 생겨요. **해를 돌려도 광택은 안 움직여요!** 빛이 아니라 "보는 방향"으로 정해지니까요. 대신 Scene 뷰 카메라를 돌리면 광택이 **화면에서 같은 자리**에 붙어 따라와요.

| | 스펙큘러 (Day 15) | MatCap (Day 16) |
|---|---|---|
| 무엇으로 정하나 | 빛 방향 + 보는 방향 | 보는 방향만 |
| 해를 돌리면 | 따라 움직임 | 그대로 |
| 좋은 점 | 진짜 빛처럼 반응 | 그림 한 장으로 금속·유리 느낌을 자유롭게 |
| 쓰는 곳 | 빛을 따라가야 하는 하이라이트 | 금속 장신구, 머리카락 광택, 눈동자 |

## 4. 실험해 보기 (30분)

1. **MatCap 그려 보기** — 아무 그림판에서 256×256 검은 바탕에 원을 그리고 그 안 **오른쪽 아래**에 흰 점을 찍어 저장해 보세요. 넣으면 광택이 오른쪽 아래로 가요.
2. **세기** — MatCap Strength 2. 금속처럼 번쩍여요.
3. **곱하기로** — `color +=` 대신 `color *= lerp(1, SAMPLE_TEXTURE2D(...).rgb, 0.5);`처럼 **곱하면** 어둡게 만드는 MatCap(가짜 그늘)이 돼요. 실험 후 되돌려요.
4. **화면 가장자리** — 물체를 화면 구석으로 옮기면 MatCap이 살짝 어긋나 보여요. 뷰 공간 노멀은 카메라가 "정면"이라고 가정해서 원근 가장자리에선 오차가 있어요. MatCap의 한계예요.
5. 커밋: `git commit -am "Day 16: MatCap"`

## 5. 오늘의 액기스

👉 [ESSENCE.md — Day 16](essence.md#day-16)

## 더 읽을거리

- [Wikipedia — Sphere mapping](https://en.wikipedia.org/wiki/Sphere_mapping) — MatCap의 원조 기법
- 더 깊이: [toon-shader-study Day 17 — 반짝임 3종](../toon-shader-study/day17-highlights.md) (MatCap 마스크, 블러, 두 번째 MatCap)

---

[← Day 15](day15-specular.md) · [목차](README.md) · [다음: Day 17 →](day17-normal-map.md)
