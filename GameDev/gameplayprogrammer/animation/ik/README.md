# 역운동학 (IK)

역운동학(Inverse Kinematics) 문서 그룹이다. 문서 번호(Task ID)는 `GMD-GPP-<번호>-<유형>` 형식이다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| GMD-GPP-002-DO | D&O + 예제 | [역운동학 원리와 활용 (IK)](ikinversekinematics.md) | FK와 IK의 차이, Animator IK와 Animation Rigging의 차이를 이해한다 |

## 이 그룹의 범위

IK는 말단(손, 발)의 목표 위치에서 관절 회전을 거꾸로 계산하는 기술이다. 이 그룹은 개념과 Unity의 구현 방법을 다룬다.

| 알고 싶은 것 | 볼 곳 |
|---|---|
| FK와 IK의 차이 | [역운동학 원리와 활용 (IK)](ikinversekinematics.md)의 1절 |
| Unity에서 IK를 쓰는 방법 비교 (Animator IK, Animation Rigging, Final IK, 직접 구현) | 같은 문서의 2절 |
| 애니메이션 상태 머신 | [\[생성형 AI\] Animator 컨트롤러 기초](../animator-state-machine.md) |

## 읽기 전에

1. 회전은 쿼터니언으로 다룬다. [\[생성형 AI\] 쿼터니언과 회전](../../../gamemath/quaternion.md)을 먼저 본다.
2. 발 접지 같은 지면 정렬은 지면 위치를 알아야 한다. 접지 검사에 쓰는 레이는 [\[생성형 AI\] 물리 질의와 충돌 이벤트](../../../unity/physics-queries.md)를 본다.

## 작업 식별

| 항목 | 내용 |
|---|---|
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (Unity에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |
