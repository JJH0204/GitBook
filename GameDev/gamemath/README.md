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
| GMD-MTH-008-DO | D&O + 예제 | [\[생성형 AI\] 이징 함수와 커브](easing-curves.md) | `t`를 변형하는 이징 함수와 `SmoothStep`, `AnimationCurve`를 이해한다 |
| GMD-MTH-009-DO | D&O + 예제 | [\[생성형 AI\] 베지어 곡선](bezier-curves.md) | 2차·3차 베지어 곡선의 식과 구현을 이해한다 |
| GMD-MTH-010-DO | D&O + 예제 | [\[생성형 AI\] 반사와 투영: Reflect, Project, ProjectOnPlane](reflect-project.md) | `Reflect`, `Project`, `ProjectOnPlane`의 식과 쓰임을 구분한다 |
| GMD-MTH-011-DO | D&O + 예제 | [\[생성형 AI\] 선행 조준: 움직이는 목표 맞히기](intercept-aiming.md) | 움직이는 목표를 맞히는 선행 조준 식을 이해한다 |
| GMD-MTH-012-DO | D&O + 예제 | [\[생성형 AI\] 스티어링 기초: Seek, Flee, Arrive](steering-behaviors.md) | Seek, Flee, Arrive 조향 이동을 이해한다 |
| GMD-MTH-013-DO | D&O + 예제 | [\[생성형 AI\] 노이즈: 부드러운 난수와 Mathf.PerlinNoise](noise.md) | 부드러운 노이즈의 원리와 `Mathf.PerlinNoise`를 이해한다 |
| GMD-MTH-014-DO | D&O + 예제 | [\[생성형 AI\] 격자 경로 탐색: A*](pathfinding-astar.md) | 격자에서 A* 최단 경로 탐색의 원리를 이해한다 |

## 읽는 순서

1. GMD-MTH-001-DO로 벡터 연산을 익힌다.
2. GMD-MTH-002-DO로 각도와 방향 벡터의 관계를 익힌다.
3. GMD-MTH-005-DO와 GMD-MTH-003-DO로 좌표 변환과 회전을 익힌다.
4. GMD-MTH-004-DO, GMD-MTH-006-DO, GMD-MTH-007-DO를 필요할 때 본다.
5. GMD-MTH-008-DO부터 GMD-MTH-014-DO는 연출, 조준, 이동 AI에 필요한 주제를 골라 본다.
