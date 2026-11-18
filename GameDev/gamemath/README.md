# 게임 수학 (Game Math)

게임 구현에 필요한 수학(벡터, 삼각함수)을 Unity API와 함께 정리한 그룹이다. 문서 번호(Task ID)는 `GMD-MTH-<번호>-<유형>` 형식이다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| GMD-MTH-001-DO | D&O | [벡터 기초와 연산 (Vector)](vector.md) | 크기, 정규화, 내적, 외적의 정의와 Unity API를 이해한다 |
| GMD-MTH-002-DO | D&O + 예제 | [삼각함수 기초 (Trigonometry)](trigonometry.md) | sin, cos, tan의 정의와 `Mathf` 사용 시 단위(라디안)를 이해한다 |
| GMD-MTH-003-DO | D&O + 예제 | [\[생성형 AI\] 쿼터니언과 회전](quaternion.md) | `Quaternion`의 구조와 `Euler`, `AngleAxis`, `Slerp` 사용을 이해한다 |
| GMD-MTH-004-DO | D&O + 예제 | [\[생성형 AI\] 보간: Lerp, MoveTowards, SmoothDamp](lerp-interpolation.md) | 보간 함수의 차이와 프레임 속도 의존 문제를 이해한다 |
| GMD-MTH-005-DO | D&O + 예제 | [\[생성형 AI\] 좌표 변환과 행렬(TRS)](transform-matrix.md) | 로컬/월드 좌표 변환과 `TransformPoint`, `TransformDirection`의 차이를 이해한다 |
| GMD-MTH-006-DO | D&O + 예제 | [\[생성형 AI\] 충돌 판정 수학: AABB, 구, 레이](collision-math.md) | 박스, 구, 레이의 교차 판정 수식을 이해한다 |
| GMD-MTH-007-DO | D&O + 예제 | [\[생성형 AI\] 난수와 확률](random-probability.md) | `Random` API와 가중치 추첨, 기댓값을 이해한다 |

## 읽는 순서

1. GMD-MTH-001-DO로 벡터 연산을 익힌다.
2. GMD-MTH-002-DO로 각도와 방향 벡터의 관계를 익힌다.
3. GMD-MTH-005-DO와 GMD-MTH-003-DO로 좌표 변환과 회전을 익힌다.
4. GMD-MTH-004-DO, GMD-MTH-006-DO, GMD-MTH-007-DO를 필요할 때 본다.
