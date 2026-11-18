# Day 15. 반짝임 — 거울에 비친 해

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSL-015-MP |
| 목적 | 블린-퐁 스페큘러(하프 벡터)를 `CelStep`으로 끊어 만화식 하이라이트를 만들고 그림자 속에서는 끈다 |
| 적용 대상 | Unity 6000.3, URP 17.x. Day 14 완료 상태의 `MyToon.shader` |
| 소요 시간 | 약 60분 (개념 20분, 코드 15분, 실험 25분) |
| 확인 상태 | 미검증 (원본 코드를 읽고 정리한 것이며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: `SafeNormalize`는 URP(SRP Core) 버전에 따라 오버로드가 다를 수 있다. URP 버전 확인 필요.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [day08-receive-shadows.md](day08-receive-shadows.md) | GMD-TSL-008-MP | `receive` 변수 |
| [day12-rim-light.md](day12-rim-light.md) | GMD-TSL-012-MP | 시선 방향 `V` |
| [day14-outline-pixels.md](day14-outline-pixels.md) | GMD-TSL-014-MP | 이전: 외곽선 2 |
| [day16-matcap.md](day16-matcap.md) | GMD-TSL-016-MP | 다음: MatCap |
| [toon-shader-study Day 17](../toon-shader-study/day17-highlights.md) | - | 반짝임 3종 (짝꿍 과정) |
| [Blinn-Phong reflection model](https://en.wikipedia.org/wiki/Blinn%E2%80%93Phong_reflection_model), [Specular highlight](https://en.wikipedia.org/wiki/Specular_highlight), [LearnOpenGL Advanced Lighting](https://learnopengl.com/Advanced-Lighting/Advanced-Lighting), [Desmos](https://www.desmos.com/calculator) | - | 수식 참고 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | `Assets/MyToon/MyToon.shader` | Day 14 완료 상태 | |
| 2 | Lab 씬의 `Shadow Beam` | 그림자 속 하이라이트 확인용 | |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 하이라이트에 `receive`(Day 08의 그림자 값)를 곱하지 않으면 그림자 속에서도 하이라이트가 남는다. 실제 프로젝트에서 출시 직전까지 남아 있던 버그다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Day 14 코드가 컴파일된다 | Console 오류 0건 |
| 2 | `V`, `receive`, `mainLight` 변수가 frag에 있다 | 코드 확인 |

## 5. 절차

### A. 개념 확인

빛 방향 L과 시선 방향 V의 중간 방향을 하프 벡터 H라 한다. 노멀 N이 H와 같은 방향이면 빛이 거울처럼 반사되어 눈으로 들어온다.

| 수식 | 의미 |
|---|---|
| `H = normalize(L + V)` | 하프 벡터 |
| `spec = pow(saturate(dot(N, H)), n)` | 블린-퐁 스페큘러. n이 클수록 하이라이트가 작고 날카롭다 |

| `dot(N, H)` | `pow(..., 20)` | `pow(..., 200)` |
|---|---|---|
| 1.00 | 1.00 | 1.00 |
| 0.99 | 0.82 | 0.13 |
| 0.95 | 0.36 | 0.00 |

### B. Properties와 CBUFFER

1. (5-B-01) `Rim` 묶음 다음, `Outline` 위에 Properties를 추가한다. → 결과: Inspector에 `Specular` 묶음이 나타난다.

```shaderlab

        [Header(Specular)]
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _Smoothness ("Smoothness", Range(0, 1)) = 0.6
        _SpecularStep ("Specular Step", Range(0, 0.5)) = 0.02
```

2. (5-B-02) CBUFFER의 `_RimStrength` 아래에 추가한다.

```hlsl
            half4  _SpecularColor;    // CBUFFER, _RimStrength 아래
            half   _Smoothness;
            half   _SpecularStep;
```

### C. frag 수정

1. (5-C-01) 림 코드 다음, `MixFog` 앞에 추가한다. → 결과: 컴파일 오류가 없다.

```hlsl
                // 반짝임: 빛과 눈의 중간 방향(H)이 노멀과 겹치는 곳
                half3 H = SafeNormalize(mainLight.direction + V);
                half spec = pow(saturate(dot(N, H)), exp2(_Smoothness * 11.0h));   // 매끈할수록 작고 날카롭게
                half specMask = CelStep(spec, 0.5h, _SpecularStep);
                color += specMask * _SpecularColor.rgb * mainLight.color * receive;  // 그림자 속에선 끈다
```

| 줄 | 의미 |
|---|---|
| `SafeNormalize` | L과 V가 정반대면 `L + V = 0`이 되어 정규화가 0으로 나눈다. 이 경우에도 안전한 함수다 |
| `exp2(_Smoothness * 11)` | 슬라이더 0~1을 지수 1~2048로 바꾼다. 0.6이면 약 97 |
| `CelStep(spec, 0.5, ...)` | 부드러운 하이라이트를 0.5에서 끊는다 |
| `* receive` | 그림자 속에서는 하이라이트를 끈다 |

정답 파일: [`Assets/Solutions/Day15/MyToon.shader`](https://github.com/JJH0204/toon-shader-lab/blob/main/Assets/Solutions/Day15/MyToon.shader)

### D. 화면 확인

1. (5-D-01) Sphere와 Capsule을 본다. → 결과: 흰 점 하이라이트가 생긴다.
2. (5-D-02) Directional Light를 회전한다. → 결과: 점이 따라 움직인다.
3. (5-D-03) Cube를 본다. → 결과: 평평한 면은 노멀이 한 방향이라 `N`이 `H`와 맞는 각도가 아니면 하이라이트가 보이지 않는다.

![Day 15 결과: 툰 스페큘러](../.gitbook/assets/day15-specular.png)

### E. 실험

1. (5-E-01) `Smoothness`를 0.3과 0.9로 바꾼다. → 결과: 0.3은 넓은 하이라이트, 0.9는 바늘 끝처럼 작은 하이라이트가 된다.
2. (5-E-02) `Specular Step`을 0.2로 올린다. → 결과: 경계가 부드러운 실사풍 하이라이트가 된다.
3. (5-E-03) `Shadow Beam`을 켜고 하이라이트가 그림자 띠에 들어가게 한다. `* receive`를 지운다. → 결과: 그림자 속에서도 하이라이트가 남는다. 확인 후 되돌린다.
4. (5-E-04) Scene 뷰를 회전한다. → 결과: 보는 방향에 따라 하이라이트 위치가 바뀐다(`V`가 계산에 들어가기 때문). 림(Day 12)과 같은 성질이다.
5. (5-E-05) 커밋한다: `git commit -am "Day 15: 툰 스페큘러"`

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | Sphere를 본다 | 경계가 뚜렷한 흰 점 | 점이 하나 생긴다 |
| 2 | 하이라이트를 그림자 띠 안으로 옮긴다 | 하이라이트가 꺼진다 | 그림자 안에 점이 없다 |
| 3 | `Smoothness = 0.9` | 하이라이트가 작아진다 | 0.3보다 작다 |

## 7. 복구

1. (7-01) 변경을 되돌린다: `Ctrl+Z` 또는 `git restore Assets/MyToon/MyToon.shader`.
2. (7-02) `Shadow Beam`을 끈다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 Day 15 페이지를 AMM 형식으로 재작성. 원본의 "IMPORTANT 상자" 표기를 CAUTION으로 정리 |

[← Day 14](day14-outline-pixels.md) · [목차](README.md) · [다음: Day 16 →](day16-matcap.md)
