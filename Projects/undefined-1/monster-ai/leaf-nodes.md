# 리프 노드: 조건과 액션, 새 노드 추가하는 법

## 무엇을 하는가

리프(Leaf)는 자식이 없는 트리의 끝 노드다. 두 종류가 있고, 에디터에서도 색이 다르다(`BTStyles.uss` 기준 Action은 노랑, Condition은 초록).

* **Condition(조건).** 블랙보드를 읽어 참/거짓을 반환한다. 참이면 Success, 거짓이면 Failure. 몬스터에게 아무 영향을 주지 않는다. 부모는 `BTCondition`.
* **Action(행동).** 몬스터에게 무언가를 시킨다. 이 프로젝트에서는 대부분 직접 움직이지 않고 `NodeContext.Enqueue`로 **명령(Command)을 큐에 넣는다.** 부모는 `BTAction`.

### 구현된 액션

| 노드 | 하는 일 | 반환 |
| --- | --- | --- |
| `BTActionPatrol` | `PatrolCommand`를 큐에 넣는다 | Running |
| `BTActionChase` | `ChaseCommand`를 큐에 넣는다 | Success |
| `BTActionAttack` | `skillId`(기본 4001)의 스킬 데이터를 블랙보드에서 찾아 `AttackCommand`를 큐에 넣는다. 스킬이 없으면 에러 로그와 함께 Failure | Success/Failure |
| `BTActionWander` | `WanderCommand`를 큐에 넣는다 | Success |
| `BTActionIdle` | `IdleCommand`를 큐에 넣는다 | Success |
| `BTActionDeath` | `DeathCommand`를 큐에 넣는다 | Success |
| `BTActionChangeState` | 블랙보드의 상태를 모두 지우고 `newState` 하나를 켠다. 큐를 쓰지 않는다 | Success |
| `BTActionStopMove` | `NavMeshAgent.isStopped = true`. 큐를 쓰지 않는다. 에이전트가 없으면 Failure | Success/Failure |
| `BTActionSystemMessage` | `speaker: message`를 `Debug.Log`로 출력한다. 메시지 버스 호출은 주석 처리되어 있다 | Success |

### 구현된 조건

| 노드 | 판정 (코드 기준) |
| --- | --- |
| `BTIsTrue` | 항상 참. 테스트나 자리표시자 |
| `BTIsRandom` | `Random.value < threshold`(기본 0.2) |
| `BTIsDeath` | `CharData.health <= 0` |
| `BTIsHit` | `CharData.health < CharData.maxHealth`. "지금 맞았다"가 아니라 "체력이 최대보다 낮다"이다 |
| `BTIsHealthLow` | `현재체력 / 최대체력 <= healthThreshold`(기본 0.3) |
| `BTTargetAlive` 파일의 `BTIsTargetAlive` | `Target != null`. 파일 안 TODO 주석이 "실제로 살아있는지 확인하는 로직 추가 필요"라고 적고 있다 |
| `BTIsMaxDetection` | 타겟과의 거리 `<= maxDetectiveRange` |
| `BTIsMinDetection` | 타겟과의 거리 `>= minDetectiveRange`. `minDetectiveRange <= 0`이면 항상 거짓 |
| `BTIsInSkillRange` | 타겟과의 거리 `<= 스킬 range`(`skillId` 기본 4001) |
| `BTIsCooldown` | `Blackboard.IsSkillReady(skillId)`. 이름과 달리 **쿨타임이 끝나 사용 가능하면 참**이다 |
| `BTIsObstacleBlocking` | 몬스터에서 타겟으로 `Physics.Raycast`. 중간에 다른 것이 맞으면 **거짓**, 아니면 참. 이름과 반대로 "가로막히지 않았다"가 참이다 |
| `BTIsCombatNearby` | `MonsterManager.GetBattleMonsters()`의 다른 몬스터 중 `maxDetectiveRange` 안에 있는 것이 있으면 참 |
| `BTIsAttackRange` | 파일 전체가 주석 처리되어 있다. 활성 클래스가 없다. `BTIsInSkillRange`가 대체한 것으로 보이나(커밋 기록상 추정), 확인 필요 |

## 왜 이렇게 설계했나

* **액션은 "명령을 요청"만 한다.** 2025-08-14 이전의 액션은 `NavMeshAgent`를 직접 움직였다(주석으로 남은 옛 코드에서 확인된다. `BTActionChase`의 주석 처리된 `SetDestination` 등). 구조 개편 이후에는 이동·애니메이션·쿨타임 같은 부수 효과를 `Command` 클래스로 옮기고, 액션은 `context.Enqueue(new XCommand(), priority)`만 한다. 이렇게 하면 (1) BT는 매 프레임 가볍게 돌려도 되고, (2) 한 프레임에 여러 액션이 선택되어도 `AIController`가 하나만 골라 실행할 수 있고, (3) 같은 Command를 BT 밖(피격 처리의 `HitCommand` 등)에서도 재사용할 수 있다([AIController와 데이터](ai-controller.md)).
* **`priority`가 액션에 있다.** `BTAction`이 `int priority`를 갖고, 에디터 설정 패널의 "우선순위" 필드로 고친다. 같은 Command라도 트리 위치에 따라 우선순위를 다르게 줄 수 있다.
* **조건이 블랙보드만 읽는다.** 조건 노드는 `NodeContext.Blackboard`로 체력, 타겟, 거리, 스킬 데이터를 읽는다. 모든 정보가 블랙보드 한곳에 모이므로 새 조건을 만들 때 읽을 곳이 명확하다.
* **`CharData`/스킬 수치를 데이터로 뺐다.** `BTIsInSkillRange`가 `skillData.range`를 읽는 것처럼 노드가 숫자를 하드코딩하지 않는다. 주석 처리된 옛 코드는 `DataManager.GetRowDataByIndex("MonsterSkill", ...)`와 `EStatType`을 썼고, 현재는 `SkillData`/`CharData` 클래스로 바뀌어 있다.

## 핵심 코드 발췌

{% code title="Nodes/LeafNodes/BTAction.cs, BTCondition.cs" %}
```csharp
public class BTAction : BTNode
{
    public int priority;

    public override NodeState Evaluate(NodeContext context, HashSet<BTNode> visited)
    {
        return CheckCycle(visited) ? NodeState.Failure : NodeState.Success;
    }
}

public abstract class BTCondition : BTNode
{
    public override NodeState Evaluate(NodeContext context, HashSet<BTNode> visited)
    {
        if (CheckCycle(visited))
            return NodeState.Failure;

        return CheckCondition(context) ? state = NodeState.Success : state = NodeState.Failure;
    }

    protected abstract bool CheckCondition(NodeContext context);
}
```
{% endcode %}

* `BTAction`은 `priority`만 추가하고, `Evaluate`는 하위 클래스가 `override`한다. 기본 구현은 Success다.
* `BTCondition`은 템플릿 메서드 패턴이다. 순환 검사와 상태 기록은 부모가 하고, 하위 클래스는 `CheckCondition`만 구현한다. 새 조건은 이 한 메서드만 쓰면 된다.
* `BTAction`은 `abstract`가 아니라서 그대로 인스턴스를 만들 수 있다. 이름이 `BTAction`인 노드가 에디터의 노드 타입 목록에 나온다.

{% code title="Nodes/LeafNodes/Actions/BTActionAttack.cs" %}
```csharp
[CreateAssetMenu(fileName = "BTActionAttack", menuName = "AI/BehaviorTree/Nodes/LeafNodes/Actions/BTActionAttack")]
public class BTActionAttack : BTAction
{
    public int skillId = 4001;

    public override NodeState Evaluate(NodeContext context, HashSet<BTNode> visited)
    {
        if (CheckCycle(visited))
            return NodeState.Failure;

        Blackboard.Blackboard blackboard = context.Blackboard;
        SkillData skillData = blackboard.GetSkillDataByID(skillId);
        if (skillData == null)
        {
            Debug.LogError($"Skill data not found for skill ID: {skillId}");
            return NodeState.Failure;
        }

        // 공격 명령을 행동 대기열에 추가
        context.Enqueue(new AttackCommand(skillData), priority);
        return state = NodeState.Success;
    }
}
```
{% endcode %}

* `[CreateAssetMenu]`: Project 창의 Create 메뉴에서 이 노드 에셋을 만들 수 있게 한다. 그래프 에디터의 노드 생성 팝업은 이 속성과 무관하게 리플렉션으로 타입을 찾는다.
* `skillId`: 인스펙터와 설정 패널에서 바꾸는 값. 기본 4001.
* `GetSkillDataByID`: 이 몬스터가 가진 스킬 목록(`Blackboard.Skills`)에서 찾는다. 목록에 없으면 Failure.
* `context.Enqueue(command, priority)`: `AIController.EnqueueCommand`가 델리게이트로 넘어온 것이다. 노드는 `AIController`를 몰라도 된다.
* 반환값이 Success인 것은 "명령을 넣었다"는 뜻이지 "공격이 끝났다"가 아니다.

{% code title="Nodes/LeafNodes/Condition/BTIsInSkillRange.cs" %}
```csharp
public class BTIsInSkillRange : BTCondition
{
    public int skillId = 4001;

    protected override bool CheckCondition(NodeContext nodeContext)
    {
        var skillData = nodeContext.Blackboard.GetSkillDataByID(skillId);
        if (skillData == null)
        {
            Debug.LogError($"Skill not found in Blackboard for skill ID: {skillId}");
            return false;
        }

        float skillRange = skillData.range;

        Vector3 targetPosition = nodeContext.Blackboard.Target.transform.position;
        Vector3 selfPosition = nodeContext.Blackboard.Agent.transform.position;
        float distanceToTarget = Vector3.Distance(selfPosition, targetPosition);

        return distanceToTarget <= skillRange;
    }
}
```
{% endcode %}

* 스킬 데이터가 없으면 에러를 찍고 거짓.
* `Target`이 `null`이면 `Target.transform`에서 예외가 난다. 호출 전에 `BTIsTargetAlive`나 `BTIsMaxDetection`으로 걸러 두는 트리 구성이 전제다(코드 읽기, unverified).
* 거리 비교는 3D 거리(`Vector3.Distance`)다.

## 따라 만들기: 새 노드 추가

예시로 조건 하나(`BTIsTargetNear`: 타겟이 N미터 안)와 액션 하나(`BTActionRoar`: 포효 명령)를 추가한다. [AIController와 데이터](ai-controller.md)의 블랙보드/명령 구조가 있다고 가정한다.

1. **조건 클래스를 만든다.** `LeafNodes/Condition/BTIsTargetNear.cs`에 `BTCondition`을 상속하고 `[CreateAssetMenu]`, `public float distance = 5f`, `CheckCondition`을 쓴다.

   ```csharp
   [CreateAssetMenu(fileName = "BTIsTargetNear", menuName = "AI/BehaviorTree/Nodes/LeafNodes/Condition/BTIsTargetNear")]
   public class BTIsTargetNear : BTCondition
   {
       public float distance = 5f;

       protected override bool CheckCondition(NodeContext context)
       {
           var bb = context.Blackboard;
           if (bb.Target == null || bb.Agent == null) return false;
           return Vector3.Distance(bb.Agent.transform.position, bb.Target.transform.position) <= distance;
       }
   }
   ```

   확인 방법: 컴파일이 되고, Project 창 Create 메뉴 `AI/BehaviorTree/Nodes/LeafNodes/Condition`에 새 항목이 보인다.

2. **그래프 에디터에서 노드가 나타나는지 본다.** 노드 생성 팝업은 `typeof(BTNode).Assembly`의 `BTNode` 하위 비추상 클래스를 전부 모으므로 목록에 `BTIsTargetNear`가 자동으로 생긴다. 새 노드를 다른 어셈블리(asmdef)에 두면 이 목록에 나타나지 않는다.

   확인 방법: 에디터 창에서 우클릭 → 팝업의 타입 목록에 `BTIsTargetNear`가 있다.

3. **(선택) 설정 패널에 값 필드를 추가한다.** `BTNodeSettingsPopupWindow.CreateUI`의 `BTCondition` 분기에 `if (condition is BTIsTargetNear near)` 블록을 추가하고 `FloatField("거리")`를 `near.distance`에 연결한다. `RegisterValueChangedCallback`에서 `EditorUtility.SetDirty`와 `AssetDatabase.SaveAssets`를 호출한다([그래프 에디터 (2)](graph-editor-2.md)). 이 단계를 건너뛰면 값은 기본 인스펙터에서만 고칠 수 있다.

   확인 방법: 노드를 선택하면 설정 패널에 필드가 보이고, 값을 바꾼 뒤 창을 닫았다 열어도 유지된다.

4. **액션용 명령을 만든다.** `Command/RoarCommand.cs`에 `AICommand`를 상속해 `Execute(blackboard, onComplete)`를 구현한다. 한 번에 끝나는 명령이면 `Execute`에서 처리 후 `OnExit(blackboard); onComplete?.Invoke();`를 부르는 `IdleCommand` 패턴을 따른다.

   확인 방법: 컴파일이 된다.

5. **액션 클래스를 만든다.** `BTAction`을 상속하고 `Evaluate`에서 `context.Enqueue(new RoarCommand(), priority)`를 호출한 뒤 Success를 반환한다. 첫 줄에 `if (CheckCycle(visited)) return NodeState.Failure;`를 잊지 않는다.

   확인 방법: Create 메뉴와 노드 생성 팝업 목록에 `BTActionRoar`가 있다.

6. **트리에 연결한다.** `Selector → Sequence[ BTIsTargetNear, BTActionRoar ]`를 에디터에서 만든다. 액션의 우선순위는 다른 명령보다 높게(원본 규칙을 따르려면 [AIController와 데이터](ai-controller.md)의 우선순위 설명을 읽고 정한다).

   확인 방법: Play 중 타겟이 거리 안으로 들어오면 `RoarCommand`의 로그가 출력된다.

7. **예외 경우를 점검한다.** `Target == null`, `Agent == null`, 스킬 목록 없음 같은 경우에 노드가 예외 대신 Failure를 반환하는지 확인한다(원본 `BTIsInSkillRange`는 타겟 `null`을 검사하지 않는다).

   확인 방법: Player 참조를 비운 상태로 Play해도 콘솔에 `NullReferenceException`이 없다.

## 막히기 쉬운 곳, 한계

* **이름과 반환값이 반대인 조건.** `BTIsCooldown`(참 = 사용 가능)과 `BTIsObstacleBlocking`(참 = 가로막히지 않음)은 이름과 의미가 어긋난다. 트리를 읽을 때 `Inverter`로 감싼 노드가 보이면 이 점을 먼저 확인한다.
* **`BTIsHit`의 의미.** 한 번이라도 맞아 체력이 줄었다면 계속 참이다. "방금 피격"이 아니다.
* **`BTActionPatrol`만 Running을 반환한다.** 나머지는 즉시 Success라서 `Sequence[액션A, 액션B]`가 매 프레임 둘 다 명령을 넣는다. 한 프레임에 큐에 여러 명령이 들어갈 수 있고, `AIController`가 그중 하나만 고른다는 점을 알아야 한다.
* **`BTActionStopMove`, `BTActionChangeState`는 큐를 우회한다.** 이 둘은 즉시 상태를 바꾸므로 명령 우선순위의 영향을 받지 않는다.
* **`BTActionSystemMessage`는 로그만 찍는다.** 화면에 표시하는 메시지 버스 연동은 주석 처리되어 있다.
* **상태 이름 오타 위험.** `BTActionChangeState.newState`는 문자열이다. `StateData`에 없는 이름이면 `DynamicState.GetStateMask`가 경고를 찍고 0을 반환하므로 아무 상태도 켜지지 않는다(그런데 `ClearStates`는 이미 실행된 뒤다. 코드 읽기, unverified).
* **데이터 의존.** 많은 조건이 `CharData`/`Skills`를 읽는다. `Blackboard.id`가 1000~1999 범위가 아니면 `InitMonsterStatsByID`가 아무것도 채우지 않는다([AIController와 데이터](ai-controller.md)).

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 액션이 몬스터를 직접 움직이지 않고 "명령을 큐에 넣는" 방식의 장점과 불편한 점을 각각 내 말로 적는다.
- [ ] 내가 만들고 싶은 몬스터 행동 하나를 골라 필요한 조건 노드와 액션 노드를 나눠 적는다.
- [ ] 새 노드를 직접 추가해 봤다면 가장 헷갈렸던 단계(Create 메뉴, 팝업 목록, 설정 패널)가 어디였는지 적는다.
