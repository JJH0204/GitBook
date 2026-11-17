# BT 기초: 노드 상태와 기반 클래스

## 무엇을 하는가

Behavior Tree는 "지금 무엇을 할까"를 트리 구조로 표현하는 AI 설계 방식이다. 매 프레임 루트에서 시작해 자식 노드를 차례로 평가하고, 각 노드는 자신의 결과를 세 가지 상태 중 하나로 부모에게 돌려준다. 이 레포에서는 그 상태가 `NodeState`, 모든 노드의 부모가 `BTNode`, 트리 한 그루를 담는 에셋이 `BehaviorTree`다.

| 상태 | 의미 | 부모가 하는 일 (Selector / Sequence 기준) |
| --- | --- | --- |
| `Success` | 노드가 할 일을 끝냈거나 조건이 참이다 | Selector는 멈추고 Success, Sequence는 다음 자식으로 간다 |
| `Failure` | 실패했거나 조건이 거짓이다 | Selector는 다음 자식으로 간다, Sequence는 멈추고 Failure |
| `Running` | 아직 진행 중이다 | 둘 다 멈추고 Running을 위로 올린다 |

## 왜 이렇게 설계했나

* **노드를 `ScriptableObject`로 만든 이유.** README가 "각 행동 노드는 ScriptableObject로 구현"이라고 밝히는 대로, 노드가 곧 에셋이다. 트리 구조(부모-자식 참조)와 노드별 설정값(쿨타임, 스킬 ID 등)이 Unity 직렬화로 저장되고, 같은 노드 에셋을 여러 몬스터가 공유할 수 있다. 대신 노드 인스턴스는 몬스터마다 복제되지 않으므로, 노드 안의 런타임 상태(예: 쿨다운의 마지막 실행 시각)도 공유된다는 한계가 생긴다(아래 "막히기 쉬운 곳" 참고).
* **`Evaluate`의 인자가 계속 바뀐 이유.** 첫 커밋(2025-08-03)의 `Evaluate`는 `Blackboard`를 받았다. 이후 몬스터 스탯 객체를 거쳐, 2025-08-14의 구조 개편에서 `NodeContext`(블랙보드 + 명령 큐 등록 함수)로 정착했다. 노드가 필요로 하는 정보가 늘 때마다 시그니처를 바꾸는 대신, 한 묶음(`NodeContext`)을 넘기는 쪽으로 수렴한 것이다.
* **`visited` 집합을 넘기는 이유.** 2025-08-06 커밋에서 순환 참조 방지 로직이 들어갔다. 처음에는 `SafeEvaluate`라는 별도 오버로드로 만들었다가, 곧바로 모든 `Evaluate`가 `HashSet<BTNode> visited`를 받는 형태로 바뀌었다. 에디터에서 사용자가 엣지를 잘못 이어 순환을 만들어도 무한 재귀로 에디터가 멈추지 않게 하려는 안전장치다.

## 핵심 코드 발췌

{% code title="Nodes/BTNode.cs" %}
```csharp
public enum NodeState { Success, Failure, Running }

public abstract class BTNode : ScriptableObject
{
    [HideInInspector] public NodeState state;
    public new string name;
    [HideInInspector] public string guid;
    [HideInInspector] public Vector2 position;
    [HideInInspector] public BTNode input;
    [HideInInspector] public List<BTNode> outputs;

    public virtual void OnEnter() { }
    public virtual void OnExit() { }
    public virtual void Reset() { }

    public abstract NodeState Evaluate(NodeContext context, HashSet<BTNode> visited);
    public virtual void OnValidateNode() { }

    protected bool CheckCycle(HashSet<BTNode> visited)
    {
        if (visited.Contains(this))
        {
            Debug.LogError($"[BehaviorTree] 순환 참조 감지: {name}");
            return true;
        }
        visited.Add(this);
        return false;
    }
}
```
{% endcode %}

줄 단위 설명:

* `public enum NodeState`: 세 가지 상태. 노드는 매번 이 중 하나를 반환한다.
* `: ScriptableObject`: 노드가 에셋이 되는 지점이다.
* `public new string name`: `UnityEngine.Object.name`을 가리는(hide) 필드다. 에디터에서 쓰는 노드 이름을 별도로 들고 있다. 이 때문에 `node.name`이 어느 쪽을 가리키는지 주의해야 한다.
* `guid`, `position`: 그래프 에디터가 노드를 식별하고 좌표를 복원하는 데 쓴다. 런타임 평가에는 필요 없다. `[HideInInspector]`로 인스펙터에서는 숨긴다.
* `input`, `outputs`: `input`은 부모 노드 참조다. 실제 자식 연결은 `BTComposite.children`, `BTDecorator.child`가 담당하며, `outputs` 리스트는 이 레포의 다른 코드에서 읽거나 쓰는 곳을 찾지 못했다(생성자에서 빈 리스트로 만들 뿐이다).
* `OnEnter/OnExit/Reset`: 훅이지만, 레포에서 호출하는 곳은 `BTDelay.OnEnter`를 `Evaluate` 안에서 직접 부르는 한 군데뿐이다. 즉 "진입/종료 시 자동 호출" 구조는 아직 없다.
* `Evaluate(context, visited)`: 모든 노드가 구현해야 하는 단 하나의 추상 메서드.
* `CheckCycle`: 이미 방문한 노드면 에러를 찍고 `true`. 아니면 방문 목록에 넣고 `false`. 각 `Evaluate`의 첫 줄에서 부른다.

트리 에셋 쪽 발췌:

{% code title="BehaviorTree.cs" %}
```csharp
[CreateAssetMenu(fileName = "New BT", menuName = "AI/New BehaviorTree")]
public sealed class BehaviorTree : ScriptableObject
{
    public BTNode rootNode;

    public NodeState Tick(NodeContext context)
    {
        var visited = new HashSet<BTNode>();
        return rootNode?.Evaluate(context, visited) ?? NodeState.Failure;
    }
}
```
{% endcode %}

* `Tick`은 호출될 때마다 새 `visited`를 만든다. 즉 한 번의 Tick 안에서만 순환/중복 방문을 검사한다.
* 루트가 없으면 `Failure`를 돌려준다.
* 같은 노드가 한 Tick 안에서 두 번 평가되면(트리가 그래프처럼 노드를 공유하는 경우) 순환이 아니어도 에러로 취급된다. 이 검사는 "자식이 하나의 부모만 갖는 진짜 트리"를 전제한다.

`BehaviorTree`에는 이 외에 `Init()`(GUID가 비어 있는 노드에 새 GUID를 채우고 `OnValidateNode`로 자식의 `input`을 부모로 맞춤)과 에디터 전용 `OnEnable()`(루트가 없으면 `Root`라는 이름의 `BTSelector`를 만들어 에셋에 넣음)이 있다. 읽은 범위에서는 `AIController`가 `BehaviorTree.Init()`을 호출하지 않는다(과거의 `Start()` 호출이 주석 처리되어 있다).

## 따라 만들기: 최소 BT

빈 Unity 프로젝트에서 에디터 없이 동작하는 최소 BT를 만든다. 아래는 원본을 단순화한 학습용 코드이며, 원본과 이름을 맞췄다. 폴더는 `Assets/BT/`로 가정한다.

1. **상태 열거형과 컨텍스트를 만든다.** `BTNode.cs`에 `NodeState`를 넣고, 노드들이 공유할 정보를 담는 `NodeContext`를 만든다. 최소판에서는 몬스터 오브젝트와 타겟만 있으면 된다.

   ```csharp
   public enum NodeState { Success, Failure, Running }

   public class NodeContext
   {
       public Transform Agent;
       public Transform Target;
   }
   ```

   확인 방법: 콘솔에 컴파일 에러가 없다.

2. **`BTNode` 추상 클래스를 만든다.** `ScriptableObject`를 상속하고 `Evaluate(NodeContext, HashSet<BTNode>)`를 추상으로 둔다. `CheckCycle`도 그대로 옮긴다.

   확인 방법: 컴파일이 되고, `BTNode`는 추상이라 Create 메뉴에 나타나지 않는다.

3. **`BTComposite`를 만든다.** `List<BTNode> children`을 `[SerializeField]`로 두고, `BTNode`를 상속한다. 이 클래스도 추상으로 두는 편이 안전하다(원본은 일반 클래스라서 에디터의 노드 타입 목록에 나타난다. [그래프 에디터 (2)](graph-editor-2.md) 참고).

   확인 방법: 컴파일 에러가 없다.

4. **`BTSelector`와 `BTSequence`를 만든다.** 구현은 [컴포짓 노드](composite-nodes.md)를 따른다. `[CreateAssetMenu]` 속성을 붙여 Project 창에서 에셋으로 만들 수 있게 한다.

   확인 방법: Project 창 우클릭 메뉴에서 두 노드를 만들 수 있다.

5. **`BTCondition`과 `BTAction` 리프를 만든다.** `BTCondition`은 `CheckCondition(context)`가 `bool`을 반환하게 하고, `Evaluate`가 이를 Success/Failure로 바꾼다. 테스트용 조건 하나(`BTIsTrue`처럼 항상 `true`)와 액션 하나(`Debug.Log`만 찍고 Success)를 만든다.

   확인 방법: 두 노드를 에셋으로 만들 수 있다.

6. **`BehaviorTree` 에셋 클래스를 만든다.** `rootNode`와 `Tick(NodeContext)`만 둔다(위 발췌 그대로).

   확인 방법: Create 메뉴에서 BehaviorTree 에셋을 만들면 인스펙터에 `Root Node` 슬롯이 보인다.

7. **에셋을 손으로 조립한다.** 에디터가 아직 없으므로 `Selector` 에셋 하나, 그 아래 `Sequence` 에셋 하나와 `Action` 에셋 하나를 만들고, 인스펙터에서 `children` 리스트에 끌어다 놓는다. `BehaviorTree.rootNode`에 `Selector`를 넣는다.

   확인 방법: 인스펙터에서 참조가 이어져 있고, 에셋을 저장했다 다시 열어도 유지된다.

8. **`MonoBehaviour`로 매 프레임 Tick한다.** `BehaviorTree` 필드를 가진 테스트 스크립트를 만들어 `Update`에서 `tree.Tick(new NodeContext{...})`를 호출한다.

   ```csharp
   public class BTRunner : MonoBehaviour
   {
       [SerializeField] BehaviorTree tree;
       void Update() => tree?.Tick(new NodeContext { Agent = transform });
   }
   ```

   확인 방법: Play 시 액션의 `Debug.Log`가 매 프레임 출력된다. 조건을 항상 `false`로 바꾸면 Sequence가 중단되어 로그가 사라진다.

## 막히기 쉬운 곳, 한계

* **노드 인스턴스 공유.** 노드가 에셋이라 같은 `BehaviorTree`를 쓰는 몬스터 전부가 노드 객체를 공유한다. `BTCooldown._lastExecuted`, `BTDelay._startTime`, `BTRepeater.currentCount` 같은 인스턴스 필드는 몬스터 간에 공유된다. 몬스터 여러 마리가 같은 트리를 쓰면 쿨다운이 서로 영향을 줄 수 있다. 원본의 `BTCooldown`을 읽은 판단이며 unverified다.
* **`Running` 재개 방식.** 컴포짓은 어느 자식이 Running이었는지 기억하지 않는다. 매 Tick마다 처음부터 다시 평가한다. 자세한 내용은 [컴포짓 노드](composite-nodes.md).
* **`BehaviorTree.cs`의 `using UnityEditor;`.** 파일 맨 위에 `#if` 없이 `using UnityEditor;`가 있다. 실제 `AssetDatabase` 호출은 `#if UNITY_EDITOR` 안에 있지만, using 자체는 플레이어 빌드에서 컴파일 에러를 낼 수 있다(빌드해 보지 못함).
* **`BTNode.cs`의 불필요한 using.** `Unity.VisualScripting.Antlr3.Runtime.Tree`를 가져오는 줄이 있다(자동 완성이 넣은 것으로 보이며 사용되지 않는다). 따라 만들 때는 넣지 않는다.
* **`state` 필드의 의미.** 노드는 마지막 평가 결과를 `state`에 저장한다. 에디터 노드 뷰가 이 값을 색 클래스로 쓰지만, 그래프를 다시 그릴 때만 반영되므로 실시간 디버거는 아니다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `Success`, `Failure`, `Running`이 각각 필요한 이유를, 몬스터가 "추적하다가 공격 범위에 들어가면 공격한다"는 예로 설명한다.
- [ ] 노드를 `ScriptableObject`로 만들었을 때 좋은 점과 곤란한 점을 각각 하나씩, 내 프로젝트에 대입해서 적는다.
- [ ] 최소 BT를 따라 만들면서 가장 막힌 단계가 어디였고, 어떻게 해결했는지 적는다.
