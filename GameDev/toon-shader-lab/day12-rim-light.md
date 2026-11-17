# Day 12. 림 라이트 — 테두리만 빛나게

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSL-012-MP |
| 목적 | 프레넬 `1 - dot(N, V)`를 `CelStep`으로 끊어 물체 가장자리에 림 라이트를 더한다 |
| 적용 대상 | Unity 6000.3, URP 17.x. Day 11 완료 상태의 `MyToon.shader`, `MyToonLighting.hlsl` |
| 소요 시간 | 약 60분 (개념 15분, 코드 15분, 실험 30분) |
| 확인 상태 | 미검증 (원본 코드를 읽고 정리한 것이며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: `GetWorldSpaceNormalizeViewDir`는 URP 버전에 따라 이름과 인자가 다를 수 있다. URP 버전 확인 필요.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [day11-additional-lights.md](day11-additional-lights.md) | GMD-TSL-011-MP | 이전: 보조 조명 (`CelStep` 공구함) |
| [day13-outline-pass.md](day13-outline-pass.md) | GMD-TSL-013-MP | 다음: 외곽선 1 |
| [toon-shader-study Day 11](../toon-shader-study/day11-rim-light.md) | - | 깊이 림 (짝꿍 과정) |
| [Schlick's approximation](https://en.wikipedia.org/wiki/Schlick%27s_approximation), [Fresnel equations](https://en.wikipedia.org/wiki/Fresnel_equations), [3Blue1Brown 내적](https://www.3blue1brown.com/lessons/dot-products) | - | 프레넬, 내적 참고 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | `Assets/MyToon/MyToon.shader`, `MyToonLighting.hlsl` | Day 11 완료 상태 | |

## 3. 안전 사항

{% hint style="info" %}
NOTE: 프레넬 림은 곡면에서 잘 동작하고 평평한 면에서는 약하다. Cube 윗면 전체가 빛나는 것은 오류가 아니다(5-D-02 참조).
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Day 11 코드가 컴파일된다 | Console 오류 0건 |
| 2 | `Point Light`가 꺼져 있다 | Hierarchy 확인 |

## 5. 절차

### A. 개념 확인

정면에서 본 공의 중앙은 노멀과 시선이 같아 `N·V = 1`이고, 가장자리로 갈수록 노멀이 옆을 향해 테두리에서 `N·V = 0`이다. 따라서 테두리 정도는 다음과 같다.

| 수식 | 의미 |
|---|---|
| `fresnel = 1 - dot(N, V)` | 중앙 0, 테두리 1 (프레넬의 단순 근사) |
| `V` | 표면에서 카메라를 향하는 단위 벡터(시선 방향) |

이 값을 `CelStep`에 넣으면 테두리만 끊겨서 빛난다.

### B. Properties와 CBUFFER

1. (5-B-01) `Toon Shading` 묶음 다음, `Debug` 위에 Properties를 추가한다. `[HDR]`은 1보다 밝은 색도 고를 수 있게 한다. → 결과: Inspector에 `Rim` 묶음이 나타난다.

```shaderlab

        [Header(Rim)]
        [HDR] _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimThreshold ("Rim Threshold", Range(0, 1)) = 0.7
        _RimSoftness ("Rim Softness", Range(0, 0.5)) = 0.02
        _RimStrength ("Rim Strength", Range(0, 4)) = 0.5
```

2. (5-B-02) CBUFFER의 `_AdditionalLightStrength` 아래에 추가한다.

```hlsl
            half4  _RimColor;
            half   _RimThreshold;
            half   _RimSoftness;
            half   _RimStrength;
```

### C. frag 수정

1. (5-C-01) `N` 줄 바로 다음에 시선 방향을 추가한다.

```hlsl
                half3 N = normalize(input.normalWS);
                half3 V = GetWorldSpaceNormalizeViewDir(input.positionWS);   // 표면 → 내 눈 (길이 1)
```

2. (5-C-02) 보조 조명 줄 다음, `MixFog` 앞에 추가한다. `saturate(dot(N, V))`는 뒷면에서 내적이 음수가 되는 것을 0으로 막는다. → 결과: 컴파일 오류가 없다.

```hlsl
                // 림: 테두리(시선과 직각인 곳)만 빛나게
                half fresnel = 1.0h - saturate(dot(N, V));
                half rim = CelStep(fresnel, _RimThreshold, _RimSoftness);
                color += rim * _RimColor.rgb * _RimStrength;
```

정답 파일: [`Assets/Solutions/Day12/MyToon.shader`](https://github.com/JJH0204/toon-shader-lab/blob/main/Assets/Solutions/Day12/MyToon.shader)

### D. 화면 확인

1. (5-D-01) Sphere와 Capsule을 본다. → 결과: 둘레에 하얀 테두리가 생긴다.
2. (5-D-02) Cube를 본다. → 결과: 윗면 전체가 하얗게 뜬다. 윗면은 면 전체의 노멀이 같고 카메라가 비스듬히 내려다보므로 전체가 시선과 거의 직각으로 판정되기 때문이다.

{% hint style="warning" %}
CAUTION: 프레넬 림은 평평한 면에서 약하다. 실제 툰 셰이더는 화면 깊이 차이로 테두리를 찾는 깊이 림을 함께 쓴다. 상세는 짝꿍 과정 [toon-shader-study Day 11](../toon-shader-study/day11-rim-light.md)을 본다.
{% endhint %}

![Day 12 결과: 림 라이트](../.gitbook/assets/day12-rim.png)

### E. 실험

1. (5-E-01) `Rim Threshold`를 0.5와 0.9로 바꾼다. → 결과: 0.5는 테두리가 두꺼워지고 0.9는 얇아진다.
2. (5-E-02) `Rim Softness`를 0.02에서 0.2로 바꾼다. → 결과: 경계가 번진다. 만화 느낌은 값이 작을수록 강하다.
3. (5-E-03) 빛을 등진 테두리만 남긴다. `color +=` 앞에 `rim *= saturate(dot(-N, mainLight.direction) + 0.5h);`를 넣는다. → 결과: 광원 반대쪽 테두리만 남는다. 정답 코드에는 없는 응용이다.
4. (5-E-04) `Rim Color`를 하늘색 HDR(`Intensity` 1~2)로 바꾼다. → 결과: 차가운 역광 느낌이 난다.
5. (5-E-05) 커밋한다: `git commit -am "Day 12: 림 라이트"`

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | Sphere를 본다 | 둘레에 하얀 테두리 | 중앙은 변화 없음 |
| 2 | `Rim Threshold = 0.9` | 테두리가 얇아진다 | 폭이 줄어든다 |
| 3 | `Rim Strength = 0` | 림 없음 | Day 11 화면과 같다 |

## 7. 복구

1. (7-01) 변경을 되돌린다: `Ctrl+Z` 또는 `git restore Assets/MyToon/MyToon.shader`.
2. (7-02) 5-E-03의 응용 줄을 삭제한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 Day 12 페이지를 AMM 형식으로 재작성. 비유 삭제 |

[← Day 11](day11-additional-lights.md) · [목차](README.md) · [다음: Day 13 →](day13-outline-pass.md)
