# Unity 우선순위 큐 몬스터 AI 초기 실험 해체

직접 만든 이진 힙 우선순위 큐와, 이를 몬스터 AI의 행동 선택에 써 본 초기 실험(`UnityPriorityQueue`)을 코드 단위로 분해한 기록이다. 이 레포는 이후 Behavior Tree 기반의 MonsterAI로 이어졌다. 이어진 흐름은 [MonsterAI 문서](../monster-ai/README.md)에서 다룬다.

{% hint style="warning" %}
이 문서의 동작 판단은 코드를 읽은 결과이며, Unity에서 실행해 확인하지 않았다(unverified). 따라 만들기의 확인 방법은 직접 실행해서 확인해야 한다.
{% endhint %}

## 한눈에 보기

| 항목 | 내용 |
|---|---|
| 목적 | 우선순위 큐 직접 구현, 그리고 State + Action 구조의 몬스터 AI에서 "다음 행동" 고르기 |
| 엔진 | Unity 2022.3.62f1 (`ProjectVersion.txt`) |
| 규모 | C# 파일 10개(약 680줄), 씬 1개(`SampleScene`) |
| 커밋 | 실질 커밋 1개(`First Commit`, 2025-08-04) + 레포 생성 커밋 |
| 핵심 | 델리게이트 비교자를 받는 제네릭 이진 힙, 매 프레임 큐를 비우고 다시 채우는 행동 선택 |
| 상태 | 실험 단계. 행동 대부분이 빈 코루틴 |

## 구조

```text
Assets/_Tests/Script/
├─ CustomCollections/
│   └─ PriorityQueue.cs        이진 힙 (List 기반, 비교 델리게이트)
└─ Monster/
    ├─ Base/
    │   ├─ AI.cs               MonoBehaviour. 현재 State 보유 + 행동 큐 + 코루틴 실행
    │   ├─ State.cs            상태 추상 클래스 (OnEnter/OnUpdate/OnExit)
    │   └─ Action.cs           ActionType enum + 행동 데이터(종류, 우선순위, 대상)
    ├─ MonsterNormal/
    │   ├─ NormalAI.cs         AI 구현체. 코루틴 8개 중 Spawn, Idle만 내용 있음
    │   ├─ Spawn.cs            State 구현. 매 프레임 Spawn 행동 제안
    │   └─ Idle.cs             State 구현. 매 프레임 Idle 행동 3개 제안
    └─ History/                더 이전 방식의 흔적(Old_monster 네임스페이스)
        ├─ MonsterBase.cs      전체가 주석 처리된 switch 기반 구현
        ├─ MonsterData.cs      이동/전투 설정 클래스
        └─ MonsterPatrol.cs    순찰 지점 선택 MonoBehaviour
```

실행 흐름은 다음과 같다.

```text
AI.Update (매 프레임)
  1. 행동 큐 비우기
  2. 현재 State.OnUpdate()  → AI.AddAction(...)으로 후보 행동을 큐에 넣음
  3. 이미 행동 중이거나 큐가 비었으면 종료
  4. 큐에서 우선순위가 가장 높은 행동 1개를 꺼내 코루틴으로 실행
  5. 코루틴이 끝나면 IsActing = false
```

## 읽는 순서

1. [이진 힙 우선순위 큐 해체](priority-queue.md): 자료구조와 레포 구현, 따라 만들기
2. [몬스터 AI 실험 해체](monster-ai-experiment.md): 큐를 State·Action 구조에 연결한 방식과 한계

## 파일 표

| 파일 | 줄 수 | 역할 | 상태 |
|---|---|---|---|
| `CustomCollections/PriorityQueue.cs` | 147 | 최소/최대 힙 우선순위 큐 | 동작하는 구현 |
| `Monster/Base/AI.cs` | 124 | 행동 큐 소비, 코루틴 실행 | 동작하는 뼈대 |
| `Monster/Base/State.cs` | 16 | 상태 추상 클래스 | 완성 |
| `Monster/Base/Action.cs` | 37 | 행동 종류와 데이터 | 완성 |
| `Monster/MonsterNormal/NormalAI.cs` | 57 | AI 구현체 | Spawn, Idle 외 빈 코루틴 |
| `Monster/MonsterNormal/Spawn.cs` | 27 | Spawn 상태 | 동작 |
| `Monster/MonsterNormal/Idle.cs` | 28 | Idle 상태 | 우선순위 정렬 시험용 |
| `Monster/History/MonsterBase.cs` | 175 | 이전 switch 방식 | 전부 주석 |
| `Monster/History/MonsterData.cs` | 31 | 설정 클래스 | 사용처 없음(주석 처리된 코드만 참조) |
| `Monster/History/MonsterPatrol.cs` | 41 | 순찰 지점 선택 | 사용처 없음, 버그 후보 있음 |

## 이후 MonsterAI로 발전한 흐름

- 이 레포의 코드와 커밋에서 읽히는 사실: 행동 8종(`ActionType`)을 가진 AI가 State로 후보를 만들고, 큐가 그중 하나를 고른다. 대부분의 행동은 아직 비어 있다.
- 이후 `JJH0204/MonsterAI`에서 Behavior Tree로 옮겨 갔다. 옮겨 간 이유는 코드에서 직접 확인되지 않으므로, 한계로 읽히는 부분을 [몬스터 AI 실험 해체](monster-ai-experiment.md)에 "추정"으로 표시해 적었다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 이 실험을 한 줄로 설명하면 무엇을 시험해 본 것인가?
- [ ] 이 레포에서 가장 먼저 읽어야 하는 파일은 무엇이고, 그 이유는 무엇인가?
