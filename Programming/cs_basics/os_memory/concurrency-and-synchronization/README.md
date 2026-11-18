# 동시성 및 동기화 (Concurrency)

프로세스와 스레드의 동시 실행, 컨텍스트 전환, 임계 구역과 동기화, 스케줄링을 정리한다. 문서 번호(Task ID)는 `PRG-CON-<번호>-<유형>` 형식이다. 이 그룹의 문서는 모두 D&O(개념)다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| PRG-CON-001-DO | 개념 | [병행 프로세스](concurrentprocessoverview.md) | 병행과 병렬의 차이, 프로세스 간 관계를 이해한다 |
| PRG-CON-002-DO | 개념 | [컨텍스트 개념](context.md) | CPU 컨텍스트와 컨텍스트 스위치를 이해한다 |
| PRG-CON-003-DO | 개념 | [프로세스 제어 블록](pcb.md) | PCB가 저장하는 정보를 찾는다 |
| PRG-CON-004-DO | 개념 | [스레드 개념](thread.md) | 프로세스와 스레드의 차이, 스레드 모델을 이해한다 |
| PRG-CON-005-DO | 개념 | [임계 구역](criticalsection.md) | 경쟁 상태와 임계 구역 해결 3요건을 이해한다 |
| PRG-CON-006-DO | 개념 | [상호 배제](mutualexclusion.md) | 상호 배제 원칙과 교착 상태 조건과의 차이를 구분한다 |
| PRG-CON-007-DO | 개념 | [동기화 도구와 교착 상태](synchronization-primitives.md) | 뮤텍스, 세마포어, 모니터와 교착 상태 4조건을 이해한다 |
| PRG-CON-008-DO | 개념 | [프로세스 스케줄링](processscheduling.md) | 스케줄링 알고리즘의 분류와 장단점을 비교한다 |

## 읽는 순서

1. PRG-CON-001-DO로 병행의 뜻을 잡는다.
2. PRG-CON-004-DO, PRG-CON-003-DO, PRG-CON-002-DO 순서로 프로세스·스레드·컨텍스트를 읽는다.
3. PRG-CON-005-DO, PRG-CON-006-DO, PRG-CON-007-DO 순서로 동기화를 읽는다.
4. PRG-CON-008-DO로 CPU 스케줄링을 읽는다.
