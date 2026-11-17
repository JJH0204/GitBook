# 몬스터 시스템 아키텍처 (BT)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-MAI-007-DO |
| 유형 | D&O (구조 설명과 개발 기록) |
| 목적 | 행동 트리(Behavior Tree, BT) 기반 몬스터 AI의 구성 요소, 실행 순서, 겪은 문제, FSM을 더한 이유를 정리한다 |
| 적용 대상 | Unity, ScriptableObject 기반 BT |
| 확인 상태 | 미검증 (원본 메모와 팀 레포 코드를 읽고 정리했으며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 구성 요소

| 구성 요소 | 종류 | 역할 |
|---|---|---|
| Behavior Tree | ScriptableObject | 노드 트리 에셋. `Tick(문맥)`으로 루트 노드를 평가한다 |
| AIController | MonoBehaviour | 감지(Sense), 판단(Think), 행동(Act)을 순서대로 실행한다. 초기에는 별도의 BT 실행기(Runner)를 두었으나 이 클래스로 합쳤다 |
| Blackboard | MonoBehaviour | 몬스터의 현재 상태(체력, 타겟, 쿨타임 등)를 보관하고 노드가 읽고 쓰는 공용 저장소다 |
| MonsterStats | ScriptableObject | 몬스터의 초기 스탯. 시트에서 지정한 인덱스 번호의 값을 불러와 Blackboard에 파라미터로 전달한다 |
| 명령(Command) 큐 | 우선순위 큐 | 노드가 낸 행동 명령(공격, 추적, 사망, 피격 등)을 모은다 |

{% hint style="info" %}
NOTE: MonsterStats의 값을 Google Sheets에서 불러오는 데 성공했다고 원본에 적혀 있다. 팀 레포에는 시트 로더(`GoogleSheetLoader`)가 있다. 시트 주소와 인증 값은 이 문서에 적지 않았다.
{% endhint %}

## 2. 동작 원리

### 2.1 한 프레임의 흐름

| 순서 | 시점 | 처리 |
|---|---|---|
| 1 | `Update` | Sense: 상태를 감지하고 비용 높은 계산은 여기서 한다 |
| 2 | `Update` | Think: BT를 `Tick`한다. 노드는 Blackboard를 읽고 행동 명령을 큐에 넣는다(`Enqueue`) |
| 3 | `LateUpdate` | Act: 큐에서 명령을 꺼내(`Dequeue`) 실행한다 |

처음에는 BT 실행기, 컨트롤러가 각각 다른 `Update` 시점에 돌아 순서가 꼬일 수 있어, `DefaultExecutionOrder`로 순서를 지정하는 초안을 만들었다. 이후 AIController 안에서 Sense, Think, Act를 순서대로 호출하게 바꾸어 이 설정이 필요 없어졌다.

원본의 초안 코드는 다음과 같다. 최종 구조에서는 쓰지 않는다.

```csharp
[DefaultExecutionOrder(-200)]
public sealed class AIController : MonoBehaviour { void Update() { /* Sense & High-cost compute -> BB */ } }

[DefaultExecutionOrder(-100)]
public sealed class BehaviorTreeRunner : MonoBehaviour { void Update() { /* Tick -> BB.Intent */ } }

[DefaultExecutionOrder( +50)]
public sealed class AIController : MonoBehaviour { void LateUpdate() { /* Consume Intent */ } }
```

{% hint style="info" %}
NOTE: 초안 코드에서 `AIController`가 두 번 선언되어 있다. 첫째는 감지 담당, 셋째는 명령 소비 담당이며 같은 이름이므로 한 클래스로 합칠 의도의 슈도코드로 읽는다.
{% endhint %}

### 2.2 노드 종류와 평가 규칙

| 노드 | 규칙 |
|---|---|
| Sequence | 자식을 순서대로 평가한다 |
| Selector | 자식을 순서대로 평가해 처음 성공(또는 실행 중)인 자식의 결과를 반환한다. 모두 실패하면 실패다 |
| Parallel | 자식을 모두 평가하고 결과와 관계없이 즉시 성공을 반환한다 |
| 조건 노드 | 사망 여부, 피격 여부, 감지 범위, 스킬 사거리, 쿨타임, 체력 비율 등을 검사한다 |
| 행동 노드 | 추적, 공격, 순찰, 배회, 회피, 사망, 상태 변경 등 명령을 낸다 |

Parallel이 항상 성공을 반환하는 점이 설계 문제로 이어졌다. 사용 가능한 스킬이 없어도 공격 명령을 낸 것으로 판단해 이후 판단(추적 등)을 하지 않게 된다.

### 2.3 BT 초안

원본은 노드 이름만 남은 다이어그램이다. 연결 관계는 아래 설명 범위만 확인된다.

| 가지 | 내용 |
|---|---|
| Root → Death | 현재 HP가 0 이하이면 성공 |
| Root → Battle | 전투 시퀀스. 판단 1: 전투 상태에 들어갈 것인가. 판단 2: 어떤 행동을 할 것인가. 이후 실행 |
| 판단 1(Check the combat) | 감지 범위 안에 타겟이 있는가. 주변 동료가 전투 중인가 |
| 판단 2(Check Skill) | 모든 스킬의 사용 가능 여부를 확인하고 가능한 스킬을 실행한다. 스킬 A, B, C마다 "사용할 수 있는가 → 사용" 쌍을 둔다. 자식을 모두 실행하는 Parallel로 묶는다 |
| Root → Chase | 패트롤 데이터 초기화 여부 확인, 배회(Wander), 추적(Chase), 대기 행동 선택(Idle Action Choice), 순찰(Patrol), 대기(Idle). 피격 여부, 타겟 생존 여부도 확인한다 |

### 2.4 스킬 사용 가능 조건

| 조건 | 판정 |
|---|---|
| 조건 1: 스킬 사거리에 타겟이 들어왔는가 | 예이면 공격 가능 |
| 조건 2: 스킬이 쿨타임 중이 아닌가 | 예이면 공격 가능 |
| 조건 3: 내 체력이 n % 미만인가 | 예이면 공격 가능 |

세 조건은 각각 `Is In Skill Range`, `Is In Skill Cooldown-Time`, `Check My Health` 노드이며, 모든 검사를 묶는 `Can Use Skill ID` 노드는 몬스터의 사용 가능 스킬 목록에 그 스킬 ID가 등록되어 있는지 검사한다.

추적 노드는 전투 가능 여부를 이미 판단한 뒤 들어온다. `minDetection` 값 이하이면 추적을 멈추고, 아니면 계속한다.

## 3. 겪은 문제와 해결

| 번호 | 문제 | 해결 또는 상태 |
|---|---|---|
| 1 | 스크립터블 오브젝트(SO) 에셋이 고장났다 | `[CreateAssetMenu]` 속성이 적용되어야 SO 에셋으로 만들 수 있다 |
| 2 | 명령을 처리하는 중에 다른 명령이 끼어들어 실행이 취소됐다 | 명령 실행 전 우선순위 값을 비교하도록 했다. 해결됨 |
| 3 | 애니메이션이 중간에 취소됐다 | 애니메이션 실행 전 Animator 초기화 메서드로 상태를 초기 상태로 되돌렸다. 해결됨 |
| 4 | 공격 중 타겟이 멀어지면, 공격 모션이 끝난 뒤 추적해야 하는데 추적이 안 되고 이전 공격 모션이 반복 재생된다 | 미해결(원본 시점). 공격 기능은 아직 구현하지 않았다. 피격 이벤트부터 만들기로 했다. Animator 트리거 기능을 더 조사해야 한다 |
| 5 | 몬스터가 의도한 대로 움직이지 않는다 | BT를 잘못 짠 것인지 의심했다. 애니메이션을 취소하면서 행동을 처리하는 것이 원인 후보다 |
| 6 | 달리기 애니메이션만 재생된다 | 몬스터 AI와 애니메이션 병합 과정에서 발생. 플레이어가 최소 추적 범위 안이면 공격하고, 할 행동이 없으면 Idle을 취해야 한다 |
| 7 | 몬스터가 피격 이후 멍청해진다(2025-09-05 메모) | 느낌 때문인지 점검이 필요하다고 적었다. 원인은 원본에 없음 |

우선순위 큐를 써서 로직을 더 정교하게 만들 수 있다는 아이디어도 적었다. 팀 레포의 AIController는 우선순위 큐(`PriorityQueue<AICommand>`)로 명령을 처리하며, 피격 명령(`HitCommand`)은 높은 우선순위 값(100)으로 넣는다.

## 4. BT의 한계와 FSM 도입

BT만으로는 상태가 고정되어 다양한 상태 표현과 행동 설정이 어려웠다. FSM을 적용해 BT의 단점을 보완하기로 한 이유는 세 가지다.

| 번호 | 이유 |
|---|---|
| 1 | 구조화를 통해 재사용성을 높인다 |
| 2 | 프로그래머의 개입 없이 쉽게 수정할 수 있어야 한다 |
| 3 | 확장성이 필요하다. 여러 BT를 원하는 조건(상태)에서 실행할 수 있어야 한다 |

개선안은 다음과 같다.

| 번호 | 개선 | 내용 |
|---|---|---|
| 1 | 서브트리 개념 추가 | 재사용성과 모듈화를 높인다 |
| 2 | Global BT 추가 | 전역에서 AI의 상태 전환만 처리하는 BT다 |
| 3 | 비트 마스크(BitMask) 사용 | 상태를 동적으로 추가·수정할 수 있다 |

구조는 다음과 같이 확인된다.

| 요소 | 내용 |
|---|---|
| `BTData` | 문자열 키(`stateName`)와 BT(`behaviorTree`) 한 쌍 |
| AIController | Global BT를 매 프레임 `Tick`하고, `BTData` 중 현재 상태에 해당하는 항목의 BT만 `Tick`한다 |
| Global BT | 상태 제어를 맡는다. 예: Death, Battle, Patrol 같은 Sub BT를 상태로 호출한다 |
| 상태 값 | 비트 마스크 정수 하나로 여러 상태를 겹쳐 표현할 수 있다. 상태 이름과 비트 번호는 데이터 에셋에서 읽는다 |
| 상태 변경 노드 | 상태를 모두 지우고 새 상태 하나를 설정한다 |

FSM 구현은 [FSM 몬스터 AI](fsmmonsterai.md)(PRJ-MAI-001-DO)를 참조한다.

## 5. 배운 점

원본에 남긴 교훈은 다음과 같다.

- 코드를 신뢰하지 않는다. 언제나 예상과 다르게 동작한다.
- 구조화가 잘된 코드일수록 수정 사항이 생겼을 때 취약하다.
- 체력 관리를 잘한다. 양질의 수면이 양질의 코드로 이어진다.

남은 TODO는 두 가지다.

| 번호 | TODO |
|---|---|
| 1 | 몬스터 사망 시 디졸브 효과로 사라지게 한다 |
| 2 | 장애물을 뛰어넘도록 NavMesh 링크를 사용한다 |

## 6. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [fsmmonsterai.md](fsmmonsterai.md) | PRJ-MAI-001-DO | FSM 몬스터 AI |
| [bossmonsterrndlog.md](bossmonsterrndlog.md) | PRJ-MAI-002-DO | 보스 몬스터 연구 개발 일지 |
| [AIController.cs](https://github.com/shion0202/2025_Project_ProjectRecombination/blob/main/Branch/Assets/_GameAssets/01.%20Scripts/Monster/AI/AIController.cs) | | 팀 레포. 접근 권한이 필요할 수 있다 |
| [BehaviorTree.cs](https://github.com/shion0202/2025_Project_ProjectRecombination/blob/main/Branch/Assets/_GameAssets/01.%20Scripts/Monster/AI/BehaviorTree/BehaviorTree.cs) | | 같은 레포 |

## 7. 약어·용어

| 용어 | 뜻 |
|---|---|
| BT | Behavior Tree. 행동 트리 |
| Blackboard | 노드들이 공유하는 상태 저장소 |
| SO | ScriptableObject |
| Tick | BT를 한 번 평가하는 호출 |
| Sense / Think / Act | 감지 / 판단 / 행동 |
| CTC | 원본에 약어만 남아 있음(뜻 확인 필요) |

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지(다이어그램 라벨과 개발 메모가 섞인 상태)를 AMM D&O 형식으로 재작성. 욕설, 개인 일정, 마감일 메모 삭제. 팀 레포 코드 사실 추가 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] Sense, Think, Act를 나눈 이유와, 나누지 않았을 때 생기는 문제를 내 경험으로 설명하면?
- [ ] BT만으로 부족하다고 느낀 순간은 언제였고, FSM이 그것을 어떻게 풀었는가?
- [ ] 명령 우선순위를 도입하기 전과 후에 몬스터 행동이 어떻게 달라졌는가?
