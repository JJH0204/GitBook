# MonsterAI 해체 분석: Behavior Tree와 그래프 뷰 에디터

## 한눈에 보기

MonsterAI는 Unity에서 몬스터 AI를 Behavior Tree(이하 BT)로 짜는 시스템과, 그 트리를 노드 그래프로 편집하는 에디터 창을 함께 담은 프로젝트다. 이 문서 묶음은 공개 레포 `JJH0204/MonsterAI`의 소스를 읽고, 빈 Unity 프로젝트에서 같은 구조를 따라 만들 수 있게 단계별로 풀어 쓴 것이다. 레포의 모든 커밋은 이 문서의 저자 본인이 작성했다.

{% hint style="warning" %}
Unity를 실행하지 못한 상태에서 소스를 읽고 쓴 문서다. 모든 "동작한다/안 한다" 판단은 코드 읽기에서 나온 것이며 **unverified**(실행 검증 안 됨)다. 레포의 라이선스 항목은 GitHub 기준 NOASSERTION(명시 없음)이므로, 코드를 그대로 재사용하기 전에 저자에게 확인해야 한다.
{% endhint %}

레포의 `ProjectSettings/ProjectVersion.txt` 기준 Unity 버전은 2022.3.62f1이고, `com.unity.ai.navigation`(NavMesh)과 Visual Scripting 패키지가 매니페스트에 들어 있다. 서드파티 패키지는 사용 사실만 적는다.

이 시스템의 핵심 아이디어는 세 가지다.

* BT의 노드를 전부 `ScriptableObject`로 만든다. 노드가 에셋이라서 트리 구조가 Unity의 직렬화로 그대로 저장되고, 인스펙터에서 값을 고칠 수 있다.
* 리프 액션 노드는 몬스터를 직접 움직이지 않고 "명령(Command)"을 우선순위 큐에 넣기만 한다. 실제 이동·공격은 `LateUpdate`에서 한 번에 하나만 실행한다.
* 트리를 코드가 아니라 `GraphView` 기반 에디터 창에서 연결해 만든다. 노드의 좌표·부모·자식이 모두 노드 에셋 안에 저장된다.

## 전체 구조

```
        Update()                              LateUpdate()
   ┌───────────────┐                      ┌─────────────────┐
   │ AIController  │  Sense(): 쿨타임 갱신  │  Act()          │
   │  (MonoBehav.) │  Think(): 트리 Tick   │  큐에서 1개 꺼냄  │
   └──────┬────────┘                      │  우선순위 비교    │
          │ Tick(NodeContext)             │  Command 실행    │
          ▼                               └────────▲────────┘
   ┌───────────────┐                               │ Enqueue(command, priority)
   │ BehaviorTree  │ (ScriptableObject)            │
   │  rootNode     │                               │
   └──────┬────────┘                               │
          │ Evaluate(context, visited)             │
          ▼                                        │
   ┌───────────────┐   자식 평가   ┌──────────────┐  │
   │ Composite     │ ───────────▶ │ Decorator    │  │
   │ Selector      │              │ Inverter ... │  │
   │ Sequence      │              └──────┬───────┘  │
   │ Parallel      │                     ▼          │
   └──────┬────────┘              ┌──────────────┐  │
          └─────────────────────▶ │ Leaf         │──┘
                                  │ Condition    │  Blackboard 읽기
                                  │ Action       │  (체력, 타겟, 스킬, 쿨타임)
                                  └──────────────┘

   [에디터]  BTEditorWindow ─ BTGraphView ─ BTNodeView(포트/엣지)
                 │              │
                 └─ 설정 패널    └─ 팝업(노드 생성)
                        │
                        ▼  (에셋 직렬화)
        BehaviorTree.asset 안에 BTNode 서브에셋들이 들어 있고,
        각 노드는 guid / position / input(부모) / children(자식)을 저장한다.
```

## 읽는 순서

1. [BT 기초](bt-basics.md): 노드 상태와 기반 클래스, 최소 BT 직접 구현
2. [컴포짓 노드](composite-nodes.md): Selector, Sequence, Parallel
3. [데코레이터 노드](decorator-nodes.md): Inverter, Repeater, UntilSuccess/UntilFailure, Cooldown, Delay
4. [리프 노드](leaf-nodes.md): 조건/액션과 새 노드 추가하는 법
5. [AIController와 데이터](ai-controller.md): 트리를 돌리고 명령을 실행하는 쪽
6. [그래프 에디터 (1)](graph-editor.md): 창, GraphView, 노드 뷰, 엣지 연결
7. [그래프 에디터 (2)](graph-editor-2.md): 팝업, 설정 패널, 직렬화, 저장/불러오기

1~5는 런타임, 6~7은 에디터다. 에디터는 런타임 노드 클래스(`BTNode`, `BTComposite`, `BTDecorator`)에 의존하므로 반드시 1~3을 먼저 읽는다.

## 파일 표

경로는 레포의 `Assets/_Project/` 기준이다.

| 파일 | 역할 | 다루는 페이지 |
| --- | --- | --- |
| `Monster/AI/BehaviorTree/BehaviorTree.cs` | 트리 에셋. `rootNode`, `Tick`, 루트 자동 생성 | bt-basics |
| `.../Nodes/BTNode.cs` | 노드 기반 클래스, `NodeState`, 순환 검사 | bt-basics |
| `.../Nodes/Composite/*` | `BTComposite`, `BTSelector`, `BTSequence`, `BTParallel` | composite-nodes |
| `.../Nodes/Decorator/*` | `BTDecorator`, Inverter, Repeater, UntilSuccess, UntilFailure | decorator-nodes |
| `.../Nodes/Decorator/Time/*` | `BTCooldown`, `BTDelay` | decorator-nodes |
| `.../Nodes/LeafNodes/*` | `BTAction`, `BTCondition`, `Actions/*`, `Condition/*` | leaf-nodes |
| `Monster/AI/AIController.cs` | 트리 실행, 명령 큐, 명령 실행 | ai-controller |
| `Monster/AI/Command/*` | `AICommand` 및 Attack/Chase/Patrol 등 | ai-controller, leaf-nodes |
| `Monster/AI/Blackboard/*` | 몬스터 현재 상태 저장소 | ai-controller |
| `Monster/MonsterState.cs`, `Monster/Data/StateData.cs` | 비트마스크 상태, 상태 이름 정의 | ai-controller |
| `Data/Datas.cs`, `Managers/DataManager.cs` | 몬스터/스킬 수치 데이터 | ai-controller |
| `Managers/MonsterManager.cs`, `Singleton.cs` | 몬스터 목록, 플레이어 참조 | ai-controller |
| `CustomCollections/PriorityQueue.cs` | 명령 큐의 자료구조 (별도 문서가 다룸) | ai-controller (한 줄) |
| `.../BehaviorTree/Editor/BTEditorWindow.cs` | 에디터 창 | graph-editor |
| `.../Editor/BTGraphView.cs` | GraphView, 그리기, 엣지 연결/해제 | graph-editor |
| `.../Editor/BTNodeView.cs` | 노드 한 개의 시각 요소와 포트 | graph-editor |
| `.../Editor/BTEdgeConnectorListener.cs` | 입력 포트용 엣지 리스너 | graph-editor |
| `.../Editor/BTNodeCreatePopupWindow.cs` | 노드 생성 팝업 | graph-editor-2 |
| `.../Editor/BTNodeSettingsPopupWindow.cs` | 선택 노드 설정 패널 | graph-editor-2 |
| `.../Editor/BTInspector.cs` | 트리 에셋 인스펙터 버튼 | graph-editor-2 |
| `.../Editor/BTEditorUtils.cs` | 노드 생성/조회 유틸 | graph-editor-2 |
| `Assets/Resources/BTStyles.uss` | 노드 색상 스타일시트 | graph-editor |

## 설계가 발전한 순서

커밋 기록을 읽으면 이 구조가 한 번에 설계된 것이 아니라 단계적으로 바뀌었음을 알 수 있다. 각 페이지의 "왜 이렇게 설계했나"는 이 흐름을 근거로 쓴다.

| 시기 | 변화 |
| --- | --- |
| 2025-08-03 | `ScriptableObject` 기반 `BTNode`, `BehaviorTree`(rootNode + blackboard), Selector/Sequence 최소 구현 |
| 2025-08-03~04 | 그래프 뷰 에디터 첫 커밋, 노드 스타일시트(`BTStyles.uss`) 추가 |
| 2025-08-05 | Parallel/Decorator/Cooldown/Delay 추가. `Evaluate`의 인자가 몬스터 스탯으로 바뀜 |
| 2025-08-06 | 순환 참조 방지용 `visited` 집합 도입. 에디터 스크립트가 폴더를 여러 번 옮기며 현재 위치로 정착 |
| 2025-08-07 | 에디터에 포트·팝업·설정 패널 보강, README 작성 |
| 2025-08-14 | `AIController`, `Blackboard`(MonoBehaviour), Command 패턴, `NodeContext` 도입. 액션이 직접 이동하지 않고 명령을 큐에 넣는 구조로 전환 |
| 2025-09-10 | 비트마스크 기반 동적 상태, 전역 BT + 상태별 BT, `BTActionChangeState` |
| 2026-01-07 | 보스 페이즈 상태 추가, 상태별 BT를 하나만 돌리던 `break` 제거 |

## 알려진 이슈 (README 기준)

원본 README는 두 가지를 알려진 이슈로 적는다. 하나는 간선을 끌어다 놓아 노드를 만들 때 연결이 자동 설정되지 않는 문제, 다른 하나는 null 노드 참조 오류(구동에는 문제 없음)다. 두 문제의 원인 후보는 [그래프 에디터 (2)](graph-editor-2.md)에서 코드를 근거로 다룬다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 이 시스템에서 "트리 구조(에셋)"와 "트리 실행(AIController)"이 왜 서로 다른 파일로 나뉘어 있는지, 내가 몬스터 AI를 만든다면 어디까지 나눌지 적는다.
- [ ] 평소 AI 행동을 if/else나 상태 머신으로 짜 본 경험이 있다면, BT로 바꿨을 때 무엇이 쉬워지고 무엇이 어려워질지 적는다.
