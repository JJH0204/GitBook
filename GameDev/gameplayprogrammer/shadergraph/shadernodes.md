# Shader Graph 핵심 노드 입출력 표

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-SGR-005-REF |
| 유형 | REF (노드 입력·출력·수식) |
| 목적 | 타임라인 문서에 나오는 주요 노드의 입력, 출력, 수식을 한 표에서 찾는다 |
| 확인 상태 | 미검증 (기억과 Unity 문서 기준으로 정리했으며 Unity Editor에서 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 원본 페이지에 없던 내용을 새로 정리한 것이다. 노드의 기본 입력값과 포트 이름은 Shader Graph 버전에 따라 다르다. 사용 중인 버전의 공식 노드 라이브러리 문서로 확인해야 한다(확인 필요).
{% endhint %}

{% hint style="info" %}
NOTE: Shader Graph는 URP와 HDRP를 기본 대상으로 한다. Built-in 렌더 파이프라인 지원은 Unity·Shader Graph 버전에 따라 다르다(버전 확인 필요). 아래 노드 자체는 파이프라인과 무관하게 같은 계산을 하지만, `Scene Color`, `Scene Depth`처럼 렌더 파이프라인 설정에 의존하는 노드는 별도 확인이 필요하다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [goranitvshadertimeline.md](goranitvshadertimeline.md) | GMD-SGR-004-REF | 고라니TV 셰이더 강의 타임라인 |
| [shaderlecture2.md](shaderlecture2.md) | GMD-SGR-003-DO | 셰이더 강의 메모 (노멀맵, 툰 셰이딩) |

## 2. 입력과 UV

| 노드 | 입력 | 출력 | 수식·동작 |
|---|---|---|---|
| UV | Channel 선택(UV0~UV3) | Vector4 (`xy`가 UV) | 메시의 텍스처 좌표를 읽는다 |
| Tiling And Offset | UV(Vector2), Tiling(Vector2), Offset(Vector2) | Vector2 | `UV × Tiling + Offset` |
| Time | 없음 | Time, Sine Time, Cosine Time, Delta Time, Smooth Delta | Time은 경과 시간(초). Sine Time·Cosine Time은 시간의 사인·코사인 값 |
| View Direction | Space 선택 | Vector3 | 표면에서 카메라로 향하는 방향 |
| Normal Vector | Space 선택 | Vector3 | 표면의 법선 방향 |
| Sample Texture 2D | Texture, UV, Sampler | RGBA, R, G, B, A | UV 위치의 텍스처 색을 읽는다 |

## 3. 계산

| 노드 | 입력 | 출력 | 수식 |
|---|---|---|---|
| Lerp | A, B, T | 같은 차원 | `A + T × (B − A)`. T=0이면 A, T=1이면 B |
| Inverse Lerp | A, B, T | 같은 차원 | `(T − A) / (B − A)` |
| Smoothstep | Edge1, Edge2, In | Float | In이 Edge1~Edge2 사이일 때 0~1을 부드러운 곡선(3t²−2t³)으로 반환 |
| Step | Edge, In | Float | `In >= Edge`이면 1, 아니면 0 |
| One Minus | In | 같은 차원 | `1 − In` |
| Saturate | In | 같은 차원 | 값을 0~1로 제한 |
| Power | A, B | 같은 차원 | `A ^ B` |
| Dot Product | A, B | Float | `A.x×B.x + A.y×B.y + ...`. 단위 벡터면 두 방향 사이 각의 코사인 |
| Remap | In, In Min Max, Out Min Max | 같은 차원 | In을 입력 범위에서 출력 범위로 선형 변환 |

## 4. 효과용 노드

| 노드 | 입력 | 출력 | 수식·용도 |
|---|---|---|---|
| Fresnel Effect | Normal, View Dir, Power | Float | `pow(1 − saturate(dot(Normal, ViewDir)), Power)`. 테두리일수록 1에 가깝다. 림 라이트, 보호막 윤곽에 쓴다 |
| Simple Noise | UV, Scale | Float | 0~1 노이즈 값. Dissolve의 기준 값으로 쓴다 |
| Gradient Noise | UV, Scale | Float | 부드럽게 이어지는 노이즈 값 |

## 5. 조합 예: Dissolve (사라지는 효과)

Dissolve는 단일 노드가 아니라 노드 조합이다. 노이즈 값이 기준값(Threshold)보다 작은 픽셀을 투명하게 자르는 방식이다.

| 순서 | 노드 | 연결 |
|---|---|---|
| 1 | Simple Noise | UV(또는 Tiling And Offset 결과), Scale 입력 → Out |
| 2 | Float 속성 (예: Threshold, 0~1) | 스크립트나 머티리얼에서 값을 바꾼다 |
| 3 | Step 또는 Subtract | 노이즈 Out과 Threshold 비교 → 0 또는 1 |
| 4 | Fragment 블록 Alpha | 3번 결과 연결 |
| 5 | Alpha Clipping | Graph Settings에서 켜고 Alpha Clip Threshold를 설정한다 |

{% hint style="info" %}
NOTE: Alpha Clipping 항목의 위치와 이름은 버전에 따라 다르다(예: 구버전은 마스터 노드의 Alpha Clip Threshold 포트). 버전 확인 필요.
{% endhint %}

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 새 문서. 타임라인에 나오는 Fresnel Effect, Lerp, UV, Dissolve 등을 입력·출력·수식 표로 정리 |
