# Day 14. 외곽선 ② — 두께를 픽셀로 고정하기

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSL-014-MP |
| 목적 | 클립 공간에서 `w`를 곱한 픽셀 단위 오프셋으로 외곽선 두께를 카메라 거리와 무관하게 고정한다 |
| 적용 대상 | Unity 6000.3, URP 17.x. Day 13 완료 상태의 `MyToon.shader` |
| 소요 시간 | 약 60분 (개념 20분, 코드 15분, 실험 25분) |
| 확인 상태 | 미검증 (원본 코드를 읽고 정리한 것이며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: `GetWorldToHClipMatrix`, `_ScaledScreenParams`(Render Scale 반영 해상도), `_ScreenParams`는 URP 버전에 따라 제공 여부와 의미가 다를 수 있다. 렌더 타깃이 뒤집히는 플랫폼에서는 y 방향 보정이 필요할 수 있다. URP 버전 확인 필요.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [day02-vertex-shader.md](day02-vertex-shader.md) | GMD-TSL-002-MP | 클립 좌표와 `w` |
| [day13-outline-pass.md](day13-outline-pass.md) | GMD-TSL-013-MP | 이전: 외곽선 1 |
| [day15-specular.md](day15-specular.md) | GMD-TSL-015-MP | 다음: 스페큘러 |
| [toon-shader-study Day 13](../toon-shader-study/day13-outline-pixel-width.md) | - | 최소 1px 보장, Depth Priming (짝꿍 과정) |
| [LearnOpenGL Coordinate Systems](https://learnopengl.com/Getting-started/Coordinate-Systems), [위키백과 동차좌표](https://ko.wikipedia.org/wiki/%EB%8F%99%EC%B0%A8%EC%A2%8C%ED%91%9C), [Spatial anti-aliasing](https://en.wikipedia.org/wiki/Spatial_anti-aliasing) | - | 원근 나눗셈, `w`, 앨리어싱 참고 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | `Assets/MyToon/MyToon.shader` | Day 13 완료 상태 | |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 외곽선 두께를 출력 해상도(`_ScreenParams`)로 재면 Render Scale이 1이 아닐 때 두께가 줄어 끊김이 돌아온다. 실제로 그리는 렌더 타깃 크기인 `_ScaledScreenParams`를 쓴다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Day 13 코드가 컴파일된다 | Console 오류 0건 |
| 2 | 멀리서 외곽선이 끊기는 현상을 본다 | Scene 뷰 카메라를 멀리 뺀다 |

## 5. 절차

### A. 개념 확인

월드에서 1cm 민 외곽선도 멀어지면 화면에서 1픽셀보다 얇아진다. 픽셀은 중심점이 덮일 때만 칠해지므로 0.2픽셀짜리 띠는 프레임마다 칠해졌다 안 칠해졌다 한다. 그래서 끊기고 반짝인다.

GPU는 클립 좌표 `x, y`를 `w`로 나눠 NDC로 만든다. 나눗셈 전에 `w`를 미리 곱해 두면 나눗셈 후 오프셋이 정확히 원하는 값이 된다.

| 수식 | 의미 |
|---|---|
| `NDC.x = clip.x / w` | GPU가 나중에 수행하는 원근 나눗셈 |
| `(clip.x + d * w) / w = NDC.x + d` | `w`를 미리 곱하면 NDC에서 정확히 `d`만큼 이동한다 |
| NDC 폭 = 2 (-1 ~ +1) | 화면 가로가 1920 픽셀이면 1픽셀 = `2 / 1920` |
| `클립 오프셋 = 방향 * (원하는 픽셀 * 2 / 화면 크기) * w` | 이 Day의 최종 수식 |

### B. 슬라이더 단위 변경

1. (5-B-01) `_OutlineWidth` 줄을 다음으로 바꾼다. → 결과: Inspector 라벨이 `Outline Width (px)`가 된다.

```shaderlab
        _OutlineWidth ("Outline Width (px)", Range(0, 8)) = 2
```

2. (5-B-02) 머티리얼에 이미 저장된 값(1)을 Inspector에서 2로 바꾼다. 기본값을 바꿔도 저장된 값은 유지된다.

### C. OutlineVert 수정

1. (5-C-01) `OutlineVert`의 위치 계산 부분(`positionWS` 줄부터 `o.positionCS = ...` 줄까지)을 다음으로 바꾼다. `uv`, `fogFactor` 줄은 유지한다. → 결과: 컴파일 오류가 없다.

```hlsl
                float4 positionCS = TransformObjectToHClip(input.positionOS.xyz);
                float3 normalWS   = TransformObjectToWorldNormal(input.normalOS);
                // 노멀이 화면 위에서 가리키는 방향. 가로세로 비율을 맞추려고 픽셀 단위로 바꾼다.
                float2 dirPx = mul((float3x3)GetWorldToHClipMatrix(), normalWS).xy * _ScaledScreenParams.xy;
                float  len   = length(dirPx);
                if (len > 1e-5)
                {
                    // 픽셀 → NDC(화면 폭 = 2) → 클립(× w). GPU 가 나중에 w 로 나누니 미리 곱해 둔다.
                    positionCS.xy += (dirPx / len) * (_OutlineWidth * 2.0 / _ScaledScreenParams.xy) * positionCS.w;
                }
                o.positionCS = positionCS;
```

| 줄 | 의미 |
|---|---|
| `mul((float3x3)GetWorldToHClipMatrix(), normalWS)` | 노멀(방향)을 클립 공간으로 변환한다. 방향이므로 이동 성분 없이 3x3만 쓴다 |
| `.xy * _ScaledScreenParams.xy` | 화면 가로세로 비율을 반영해 픽셀 단위 방향을 만든다 |
| `if (len > 1e-5)` | 노멀이 카메라를 정면으로 향하면 화면 방향이 없다(길이 0). 0으로 나누지 않게 건너뛴다 |
| `dirPx / len` | 길이 1인 화면 방향 |
| `_OutlineWidth * 2.0 / _ScaledScreenParams.xy` | 픽셀을 NDC 단위로 바꾼다 |
| `* positionCS.w` | 나중의 `w` 나눗셈을 상쇄한다 |

정답 파일: [`Assets/Solutions/Day14/MyToon.shader`](https://github.com/JJH0204/toon-shader-lab/blob/main/Assets/Solutions/Day14/MyToon.shader)

### D. 화면 확인

1. (5-D-01) Scene 뷰 또는 Main Camera를 멀리 뺀다. → 결과: 물체가 작아져도 외곽선 두께가 일정(약 2픽셀)하다. 가까이 가면 물체에 비해 상대적으로 얇아 보인다. 화면 기준이기 때문이다.

![Day 14 결과: 멀리서도 같은 두께](../.gitbook/assets/day14-far.png)

### E. 실험

1. (5-E-01) 손계산을 한다. 화면 높이 1080, 2픽셀이면 NDC 오프셋은 `2 * 2 / 1080 = 0.0037`이다. 그 점의 `w`가 6이면 클립 오프셋은 `0.022`, `w`가 60이면 `0.22`다. → 결과: 멀수록 10배 크게 밀어야 화면에서 같은 2픽셀이다.
2. (5-E-02) `* positionCS.w`를 지운다. → 결과: 가까운 물체는 외곽선이 거의 안 보이고 먼 물체는 두꺼워진다(반대 동작). 확인 후 되돌린다.
3. (5-E-03) `Outline Width`를 8로 올린다. → 결과: Cube 모서리 틈이 더 크게 벌어진다. 화면 공간에서 밀어도 노멀이 다르면 갈라지는 것은 같다.
4. (5-E-04) 커밋한다: `git commit -am "Day 14: 픽셀 단위 외곽선"`

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 카메라를 가까이/멀리 이동 | 외곽선 두께가 거의 일정 | 멀리서도 끊기지 않는다 |
| 2 | `Outline Width = 0` | 외곽선 없음 | 선이 보이지 않는다 |
| 3 | 손계산 | `0.0037`, `0.022`, `0.22` | 값 일치 |

## 7. 복구

1. (7-01) 변경을 되돌린다: `Ctrl+Z` 또는 `git restore Assets/MyToon/MyToon.shader`.
2. (7-02) `Outline Width` 값을 기본값 2로 둔다(Day 13의 cm 값으로 돌아가면 값을 1로 설정한다).

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 Day 14 페이지를 AMM 형식으로 재작성. 비유 삭제, 수식을 표로 정리 |

[← Day 13](day13-outline-pass.md) · [목차](README.md) · [다음: Day 15 →](day15-specular.md)
