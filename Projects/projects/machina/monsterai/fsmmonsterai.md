# FSM 몬스터 AI (FSM)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-MAI-001-DO |
| 유형 | D&O (개념) |
| 목적 | 유한 상태 머신(FSM)으로 몬스터 AI를 구현할 때의 상태, 전이, 진입 훅을 정리한다 |
| 적용 대상 | Unity, NavMesh, Animator 사용 프로젝트 |
| 확인 상태 | 미검증 (팀 레포의 소스를 읽고 정리했으며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

FSM은 대상이 가질 수 있는 상태를 유한 개로 정하고, 한 시점에 하나의 상태만 활성으로 두는 모델이다. 몬스터 AI에서는 "배회", "추적", "공격" 같은 행동 단위를 상태로 두고, 조건이 바뀔 때 상태를 전환한다.

FSM의 세 요소는 다음과 같다.

| 요소 | 뜻 |
|---|---|
| 상태(State) | 몬스터가 지금 하는 행동 단위 |
| 전이(Transition) | 한 상태에서 다른 상태로 바뀌는 규칙. 조건이 참이면 전환한다 |
| 진입 훅(Enter) / 종료 훅(Exit) | 상태에 들어갈 때 한 번, 상태에서 나갈 때 한 번 실행하는 처리 |

## 2. 초기 설계 메모

원본 메모에는 다이어그램의 라벨만 남아 있다. 화살표는 남아 있지 않아 전이 방향은 확인할 수 없다.

| 구분 | 원본에 남은 라벨 |
|---|---|
| 상태 | Find aid, Wander, Attack, Evade |
| 전이 조건 | Found aid, Player is near, Player is out of sight |

## 3. 구현된 FSM의 구성 (팀 레포)

`MonsterFSM`은 공통 부모 클래스 `FSM`을 상속한다. 부모 클래스가 틀을 잡고, 자식 클래스가 세 가지 메서드를 구현한다.

| 메서드 | 호출 시점 | 역할 |
|---|---|---|
| `Think()` | `Update`에서 매 프레임 | 조건을 검사해 다음 상태를 정한다 |
| `Act()` | `LateUpdate`에서 매 프레임 | 현재 상태의 행동을 수행한다 |
| `EnterState(상태 이름)` | 상태가 바뀔 때 1회 | 진입 처리를 한다 (진입 훅) |

상태는 문자열 이름으로 구분하며 `ChangeState(이름)` 한 곳에서 전환한다. 전환 규칙은 다음과 같다.

- 현재 상태와 같은 이름이면 전환하지 않는다.
- 상태 데이터에 없는 이름이면 전환하지 않는다.
- 전환하면 상태 값을 바꾼 뒤 `EnterState`를 호출한다.

{% hint style="info" %}
NOTE: 종료 훅(Exit)에 해당하는 메서드는 `FSM` 클래스에 없다. 상태에서 나갈 때 처리할 일은 다음 상태의 `EnterState`에서 다시 설정하는 방식이다. 종료 훅은 애니메이션 쪽에만 있다(5절).
{% endhint %}

## 4. 상태와 전이 (`MonsterFSM`)

### 4.1 상태 목록

| 상태 | 진입 처리 (`EnterState`) | 행동 (`Act`) |
|---|---|---|
| Spawn | 길찾기 에이전트 이동 허용 | 스폰 사운드 재생, 디졸브 시작, Idle로 전환 |
| Idle | 에이전트 정지 | 없음 |
| Patrol | 다음 경유지를 목적지로 지정, 걷기 속도 설정, 걷기 애니메이션 켬 | 목적지에 도착하면 순찰 플래그를 끈다 |
| Chase | 달리기 속도 설정, 달리기 애니메이션 켬 | 매 프레임 타겟 위치로 목적지를 갱신한다 |
| Attack | 에이전트 정지 | 타겟을 바라보고 선택된 스킬을 실행한다 |
| Hit | 에이전트 정지, 경로 초기화 | 진행 중인 스킬을 중단하고 경직 시간(기본 0.5초) 뒤 Idle로 전환한다 |
| Death | 에이전트 정지, 경로 초기화 | 사망 이펙트, 레이어 변경, 래그돌 활성화, 디졸브 후 풀에 반환한다 |

### 4.2 전이 규칙 (`Think` 순서)

위에서부터 먼저 맞는 규칙이 적용된다.

| 순서 | 조건 | 결과 |
|---|---|---|
| 1 | 비활성이거나 사망 처리 중이다 | 판단하지 않는다 |
| 2 | 현재 상태가 Spawn이다 | 판단하지 않는다 |
| 3 | 현재 체력이 0 이하다 | Death로 전환한다 |
| 4 | 현재 상태가 Hit이다 | 판단하지 않는다 |
| 5 | 스킬이 실행 중이다 | 타겟이 스킬 사거리 밖으로 벗어나면 스킬을 중단하고 Chase로 전환한다. 그 외에는 상태를 유지한다 |
| 6 | 준비된 스킬이 있고 타겟이 그 사거리 안이다 | 그 스킬을 선택하고 Attack으로 전환한다 |
| 7 | 타겟 거리가 최소 감지 거리보다 크다 | Chase로 전환한다 |
| 8 | 위 조건이 모두 아니다 | Idle로 전환한다 |

피격은 `Think`가 아니라 피해 처리에서 전이한다. 피해를 받고 체력이 0보다 크면 `ChangeState("Hit")`를 호출한다.

{% hint style="info" %}
NOTE: `MonsterFSM.Think` 안에는 Patrol로 전환하는 코드가 없다. Patrol 상태의 진입·행동 코드는 있으나 이 클래스만으로는 전이되지 않는다. Patrol을 쓰는 경로는 확인 필요.
{% endhint %}

{% hint style="warning" %}
CAUTION: `Think`는 타겟(`blackboard.Target`)의 위치를 널 검사 없이 사용한다. 타겟이 없는 상태에서 호출되면 예외가 날 수 있다. 실행해 확인하지 않았다.
{% endhint %}

## 5. NavMesh와 Animator의 연동

| 대상 | 연동 방식 |
|---|---|
| NavMeshAgent | 상태에 따라 `isStopped`, `speed`, 목적지(`SetDestination`)를 바꾼다. Chase는 매 프레임 목적지를 타겟 위치로 갱신한다 |
| 겹침 방지 | Chase 중 `Physics.OverlapSphereNonAlloc`으로 가까운 같은 편 몬스터를 찾아, 가까울수록 더 크게 밀어내는 값을 목적지에 더한다 |
| Animator 파라미터 | 상태 진입 때 `IsWalk`, `IsRun` 같은 불 값을 켠다 |
| Animator 종료 훅 | `StateMachineBehaviour`의 `OnStateExit`가 공격 애니메이션이 끝날 때 FSM의 `OnAttackAnimationEnd`를 호출한다. 이 메서드는 근접 공격 판정 오브젝트를 제거한다 |
| 애니메이션 이벤트 | 발사, 근접 판정 생성, 사망, 발소리 같은 시점에 FSM 메서드를 호출한다 |

{% hint style="info" %}
NOTE: 원본 메모에는 레이캐스트 시야 처리가 적혀 있지 않았다. 이 문서에서는 다루지 않는다.
{% endhint %}

## 6. 참조

| 대상 | 링크 | 비고 |
|---|---|---|
| FSM 부모 클래스 | [FSM.cs](https://github.com/shion0202/2025_Project_ProjectRecombination/blob/main/Branch/Assets/_GameAssets/01.%20Scripts/Monster/AI/FSM/FSM.cs) | 팀 레포. 접근 권한이 필요할 수 있다 |
| 일반 몬스터 FSM | [MonsterFSM.cs](https://github.com/shion0202/2025_Project_ProjectRecombination/blob/main/Branch/Assets/_GameAssets/01.%20Scripts/Monster/AI/FSM/MonsterFSM.cs) | 같은 레포 |
| 상태 비트 마스크 | [MonsterState.cs](https://github.com/shion0202/2025_Project_ProjectRecombination/blob/main/Branch/Assets/_GameAssets/01.%20Scripts/Monster/State/MonsterState.cs) | 같은 레포 |
| 공격 종료 훅 | [AttackStateExitBehaviour.cs](https://github.com/shion0202/2025_Project_ProjectRecombination/blob/main/Branch/Assets/_GameAssets/01.%20Scripts/Monster/Animator/StateBehavior/AttackStateExitBehaviour.cs) | 같은 레포 |
| BT에서 FSM으로 간 배경 | [몬스터 시스템 아키텍처 (BT)](monstersystemstructure.md) | PRJ-MAI-007-DO |

## 7. 약어·용어

| 용어 | 뜻 |
|---|---|
| FSM | Finite State Machine. 유한 상태 머신 |
| NavMesh | 길찾기용 이동 가능 영역 데이터 |
| 진입 훅 | 상태에 들어갈 때 한 번 실행하는 처리 |

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지(다이어그램 라벨만 남은 상태)를 AMM D&O 형식으로 재작성하고 팀 레포 코드 기준의 구성을 추가 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 행동 트리 대신 FSM을 선택한 이유를, 내가 겪은 문제와 함께 설명하면?
- [ ] 상태가 늘어날 때 FSM에서 가장 먼저 어려워지는 부분은 무엇인가?
- [ ] 진입 훅이 없었다면 어떤 버그를 겪었을까?
