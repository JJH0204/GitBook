# 그래프 에디터 (1): 창, GraphView, 노드 뷰, 엣지 연결

## 무엇을 하는가

BT 에셋을 노드 그래프로 보여 주고 편집하는 에디터 창이다. 이 프로젝트의 가장 큰 덩어리이며, 이 문서는 둘로 나눈 것의 앞부분이다. 이 페이지는 "화면에 그리고 연결한다"를 다루고, [그래프 에디터 (2)](graph-editor-2.md)는 "노드를 만들고, 값을 고치고, 저장한다"를 다룬다.

프로젝트의 Unity 버전은 2022.3.62f1이다(`ProjectSettings/ProjectVersion.txt`). `UnityEditor.Experimental.GraphView` API를 쓰므로 이 버전 근처에서 따라 만드는 것이 안전하다. 이후 Unity 버전에서는 GraphView API의 위치와 지원 상태가 달라질 수 있으니 따라 만들기 전에 확인한다(확인하지 못했다).

이 페이지의 클래스는 다음과 같다.

| 클래스 | 부모 | 역할 |
| --- | --- | --- |
| `BTEditorWindow` | `EditorWindow` | 창. 상단 툴바, 그래프 뷰, 오른쪽 설정 패널을 조립하고 선택 변화를 감시한다 |
| `BTGraphView` | `GraphView` | 캔버스. 노드/엣지 그리기, 연결/해제를 트리 데이터에 반영 |
| `BTNodeView` | `Node` | 노드 한 개의 모양. 입력 포트 1개, 출력 포트 N개 |
| `BTEdgeConnectorListener` | `IEdgeConnectorListener` | 입력 포트 쪽 엣지 드롭 처리 |
| `EdgeConnectorListenerWithPopup` | `IEdgeConnectorListener` | 출력 포트 쪽 엣지 드롭 처리 (`BTNodeView.cs` 안) |

## 왜 이렇게 설계했나

* **GraphView를 쓴 이유.** README가 "UnityEditor의 GraphView API 활용"이라고 밝힌다. 줌, 패닝, 그리드, 노드 이동, 사각형 선택, 포트/엣지 연결이 기본 제공되므로, 직접 구현해야 할 것은 "BT 데이터 ↔ 뷰" 변환뿐이다.
* **뷰는 데이터의 투영이다.** 노드의 좌표(`position`), 부모(`input`), 자식(`children`/`child`)이 전부 `BTNode` 에셋 안에 저장된다. 뷰 쪽에는 상태를 따로 두지 않고, 데이터를 바꾸면 `RedrawTree()`로 통째로 다시 그린다. 구현이 단순하고 뷰와 데이터가 어긋나지 않는다. 대가로 매번 뷰 전체를 지우고 다시 만든다(그리고 `DrawTree` 끝의 `FrameAllNodes`가 화면 위치를 재조정하므로 편집할 때마다 시점이 움직일 수 있다. 코드 읽기, unverified).
* **히스토리.** 에디터는 2025-08-03~04에 첫 커밋 후 여러 번 이동·재작성되었다(`Assets/Editor/` → `Assets/Scripts/AI/Editor/BehaviorTreeEditor/` → `Assets/Scripts/AI/BehaviorTree/Editor/`). 2025-08-06의 두 번째 큰 재작성(+893줄)에서 지금의 파일 구성(`BTEditorWindow`, `BTGraphView`, `BTNodeView`, `BTNodeCreatePopupWindow`, `BTNodeSettingsPopupWindow`, `BTInspector`)이 정해졌고, 2025-08-07에 포트 드래그 팝업, 컨텍스트 메뉴, 자동 저장 토글이 붙었다.
* **출력 포트 = 자식 슬롯.** 컴포짓 노드는 `children` 개수만큼 출력 포트(`Out 1`, `Out 2`...)를 만든다. 데코레이터는 `Out` 하나다. 포트 번호와 리스트 인덱스가 일치하므로 "몇 번째 자식인지"가 곧 우선순위이고, 엣지를 그릴 때도 `OutputPorts[i]`와 `children[i]`를 짝짓는다.
* **고아 노드도 보인다.** `DrawTree`는 루트에서 따라 내려가는 대신 `GetAllAssetNodes()`(에셋에 들어 있는 모든 `BTNode`)를 그린다. 연결이 끊긴 노드도 사라지지 않고 화면에 남는다. 대신 "고아 일괄 삭제" 버튼이 따로 있다.

## 핵심 코드 발췌

{% code title="Editor/BTEditorWindow.cs (Refresh, 발췌)" %}
```csharp
private void OnEnable()
{
    Selection.selectionChanged += OnSelectionChanged;
    EditorApplication.update += OnEditorUpdate;
    Refresh();
}

private void Refresh()
{
    rootVisualElement.Clear();

    var container = new VisualElement();
    container.style.flexDirection = FlexDirection.Column;
    container.style.flexGrow = 1;
    // ... 상단 바: 자동 저장 토글, Save Tree, 고아 일괄 삭제 ...

    if (Selection.activeObject is BehaviorTree selectedTree)
    {
        _currentTree = selectedTree;
        _graphView = new BTGraphView(_currentTree);
        _graphView.style.flexGrow = 1;
        _graphView.OnNodeSelectionChanged += OnNodeSelectionChanged;
        container.Add(_graphView);
        _graphView.FrameAllNodes();
    }
    else
    {
        container.Add(new Label("BehaviorTree ScriptableObject를 선택하세요."));
    }
    rootVisualElement.Add(container);
    // ... 오른쪽 설정 패널 붙이기 ...
}
```
{% endcode %}

* `Selection.selectionChanged`: Project 창에서 다른 `BehaviorTree` 에셋을 선택하면 `Refresh()`가 호출되어 창 내용이 바뀐다.
* `EditorApplication.update`에 `OnEditorUpdate`를 걸어, 그래프 뷰의 `selection`이 바뀌었는지 매 업데이트마다 비교한다. GraphView의 선택 변화 이벤트를 쓰지 않고 폴링한다.
* `rootVisualElement`: UI Toolkit 방식이다. `OnGUI`를 쓰지 않는다.
* `Refresh`는 호출될 때마다 `BTGraphView`를 새로 만든다. 창 전체를 갈아엎는 방식이다.

{% code title="Editor/BTGraphView.cs (생성자, DrawTree 발췌)" %}
```csharp
public BTGraphView(BehaviorTree tree)
{
    _tree = tree;
    var styleSheet = Resources.Load<StyleSheet>("BTStyles");
    if (styleSheet != null)
        styleSheets.Add(styleSheet);

    SetupZoom(ContentZoomer.DefaultMinScale, ContentZoomer.DefaultMaxScale);
    this.AddManipulator(new ContentDragger());
    this.AddManipulator(new SelectionDragger());
    this.AddManipulator(new RectangleSelector());

    var grid = new GridBackground();
    Insert(0, grid);
    grid.StretchToParentSize();

    this.graphViewChanged += OnGraphViewChanged;

    if (_tree == null || _tree.rootNode == null) return;
    DrawTree();
    // (이 아래에 우클릭 노드 생성 콜백 등록)
}

private void DrawTree()
{
    foreach (var view in _nodeViews.Values) RemoveElement(view);
    foreach (var edge in edges.ToList()) RemoveElement(edge);
    _nodeViews.Clear();

    var allNodes = _tree.GetAllAssetNodes();
    foreach (var node in allNodes)
    {
        var view = new BTNodeView(node, _tree.rootNode, this);
        view.SetPosition(new Rect(node.position, new Vector2(200, 100)));
        _nodeViews[node.guid] = view;
        AddElement(view);
    }
    DrawEdges();
    FrameAllNodes();
}
```
{% endcode %}

* `Resources.Load<StyleSheet>("BTStyles")`: `Assets/Resources/BTStyles.uss`를 불러온다. `Resources` 폴더에 이름이 정확히 있어야 한다.
* `SetupZoom`, `ContentDragger`(캔버스 이동), `SelectionDragger`(선택한 노드 이동), `RectangleSelector`(드래그 선택): GraphView의 기본 조작 4종.
* `GridBackground`를 0번 자식으로 넣고 부모 크기에 맞춘다.
* `graphViewChanged`: 엣지가 만들어지거나 요소가 삭제될 때 호출되는 콜백. 여기서 데이터 쪽을 갱신한다.
* `if (_tree.rootNode == null) return;`: 루트가 없으면 `DrawTree()`와 그 아래 우클릭 콜백 등록까지 건너뛴다. 아래 "막히기 쉬운 곳" 참고.
* `_nodeViews`: `guid → BTNodeView` 사전. 엣지를 그릴 때 자식 노드의 뷰를 찾는 데 쓴다. 그래서 GUID가 비어 있거나 중복되면 곤란하다(`BehaviorTree.Init()`이 빈 GUID를 채워 주는 이유).
* `SetPosition(new Rect(node.position, ...))`: 노드의 저장된 좌표로 뷰를 놓는다. `BTNodeView.SetPosition`이 다시 `Node.position`을 갱신하므로, 노드 이동이 곧 데이터 변경이다.

{% code title="Editor/BTNodeView.cs (포트 만들기 발췌)" %}
```csharp
public BTNodeView(BTNode node, BTNode rootNode, BTGraphView graphView)
{
    Node = node;
    _graphView = graphView;
    title = node.name ?? node.GetType().Name;
    viewDataKey = node.guid;

    if (node != rootNode)
    {
        InputPort = InstantiatePort(Orientation.Horizontal, Direction.Input, Port.Capacity.Single, typeof(bool));
        InputPort.portName = "In";
        InputPort.AddManipulator(new EdgeConnector<Edge>(new BTEdgeConnectorListener()));
        inputContainer.Add(InputPort);
    }

    if (node is BTComposite composite && composite.children != null)
    {
        for (int i = 0; i < composite.children.Count; i++)
        {
            var outPort = InstantiatePort(Orientation.Horizontal, Direction.Output, Port.Capacity.Single, typeof(bool));
            outPort.portName = $"Out {i + 1}";
            outPort.AddManipulator(new EdgeConnector<Edge>(new EdgeConnectorListenerWithPopup(this, i)));
            outputContainer.Add(outPort);
            OutputPorts.Add(outPort);
        }
    }
    else if (node is BTDecorator)
    {
        // 데코레이터: 출력 포트 1개 "Out" (같은 방식)
    }
    // ... 상태/타입 클래스 추가, RefreshExpandedState, RefreshPorts ...
}
```
{% endcode %}

* `node != rootNode`: 루트에는 입력 포트가 없다(부모가 없으므로).
* `InstantiatePort(Horizontal, Direction, Capacity.Single, typeof(bool))`: 입력·출력 모두 용량 1. 한 포트에 엣지가 하나만 붙는다. 타입 `bool`은 의미 없이 쓰는 자리표시자다.
* `EdgeConnector<Edge>(listener)`를 포트에 `AddManipulator`로 달아야 포트에서 드래그가 시작된다. 코드 주석대로 "EdgeConnector는 포트에 직접 할당해야 하므로 GraphView에는 추가하지 않는다".
* 리프 노드는 출력 포트가 없다(`BTAction`/`BTCondition`은 어느 분기에도 걸리지 않는다).
* 출력 포트는 `children.Count`개다. 자식이 0개인 컴포짓은 출력 포트가 없다. 포트를 늘리는 방법은 설정 패널의 "자식 노드 추가" 버튼이다([그래프 에디터 (2)](graph-editor-2.md)).

{% code title="Editor/BTGraphView.cs (OnEdgeConnected 발췌)" %}
```csharp
public void OnEdgeConnected(Edge edge)
{
    var parentView = edge.output.node as BTNodeView;
    var childView = edge.input.node as BTNodeView;
    if (parentView == null || childView == null) return;
    var parentNode = parentView.Node;
    var childNode = childView.Node;

    // 자기 자신 연결 금지
    if (parentNode == childNode) { RemoveElement(edge); return; }

    // 순환 참조 체크
    if (CheckCycle(parentNode, childNode, new HashSet<BTNode>()))
    {
        RemoveElement(edge);
        return;
    }

    // 실제 트리 구조에 반영
    if (parentNode is BTComposite composite)
    {
        if (!composite.children.Contains(childNode))
        {
            composite.children.Add(childNode);
            childNode.input = parentNode;
        }
    }
    else if (parentNode is BTDecorator decorator)
    {
        decorator.child = childNode;   // 기존 child가 있으면 기존 child.input = null 처리
        childNode.input = parentNode;
    }
    EditorUtility.SetDirty(parentNode);
    EditorUtility.SetDirty(childNode);
    // ... 자동 저장이 켜져 있으면 AssetDatabase.SaveAssets() ...
    RedrawTree();
}
```
{% endcode %}

* 엣지의 `output.node`가 부모, `input.node`가 자식이다(출력 포트 → 입력 포트 방향이 부모 → 자식).
* 자기 연결과 순환을 막는다. `CheckCycle(parent, child, visited)`는 자식 쪽 하위 트리를 내려가며 부모가 나오는지 본다. 나오면 엣지를 지운다.
* 컴포짓이면 `children.Add`다. 즉 드래그한 포트가 몇 번이든 새 자식은 리스트 끝에 붙는다. 빈 슬롯(`null`)을 채우는 것이 아니다. 따라서 `Out 1`에서 끌었는데 `Out 3` 자리에 들어갈 수 있고, 빈 슬롯(null)은 그대로 남는다.
* 데코레이터면 `child`를 교체한다.
* 데이터를 바꾼 뒤 `SetDirty`로 Unity에 "저장 대상"임을 알리고 `RedrawTree`로 뷰를 새로 그린다.

## 따라 만들기: 창에서 엣지 연결까지

[BT 기초](bt-basics.md), [컴포짓 노드](composite-nodes.md), [데코레이터 노드](decorator-nodes.md)가 있어야 한다. 모든 에디터 스크립트는 `Editor/` 폴더에 둔다(이 폴더의 스크립트는 빌드에 포함되지 않는다). 노드 클래스에 `guid`, `position`, `input`을 추가해 둔다.

1. **에디터 창을 연다.** `Editor/BTEditorWindow.cs`에 `EditorWindow`를 상속하고 `[MenuItem("Window/AI/Behavior Tree Editor")]` 정적 메서드에서 `GetWindow<BTEditorWindow>("Behavior Tree")`를 호출한다.

   확인 방법: 메뉴 `Window/AI/Behavior Tree Editor`로 빈 창이 열린다.

2. **선택을 감시한다.** `OnEnable`에서 `Selection.selectionChanged`에 `Refresh`를 걸고, `Refresh`에서 `rootVisualElement.Clear()` 후 `Selection.activeObject is BehaviorTree`인지 검사한다. 아니면 안내 `Label`을 띄운다.

   확인 방법: BT 에셋을 선택하면 로그나 라벨이 바뀌고, 다른 에셋을 선택하면 안내 문구가 나온다.

3. **`BehaviorTree`에 서브에셋 조회를 넣는다.** `GetAllAssetNodes()`를 `AssetDatabase.LoadAllAssetsAtPath(AssetDatabase.GetAssetPath(this))` 후 `BTNode`만 걸러 반환하도록 만든다. 에디터 전용 코드는 `#if UNITY_EDITOR`로 감싼다.

   확인 방법: 에셋 안에 노드가 있는 트리에서 호출하면 개수가 노드 수와 같다.

4. **빈 `BTGraphView`를 띄운다.** `GraphView`를 상속하고 `SetupZoom`, `ContentDragger`, `SelectionDragger`, `RectangleSelector`, `GridBackground`를 넣는다. `Refresh`에서 `new BTGraphView(tree)`를 `flexGrow = 1`로 추가한다.

   확인 방법: 격자 배경이 보이고, 휠로 줌, 가운데 버튼이나 알트 드래그로 이동한다.

5. **노드 뷰를 그린다.** `BTNodeView : Node`를 만들어 `title`, `style.left/top`을 설정하고, `DrawTree`에서 `GetAllAssetNodes()` 결과마다 뷰를 만들어 `AddElement`한다. 각 뷰를 `guid → 뷰` 사전에 담는다.

   확인 방법: 노드마다 상자가 하나씩 생기고, 저장된 `position`에 놓인다.

6. **포트를 만든다.** 루트가 아니면 입력 포트 `In`, 컴포짓이면 `children.Count`개의 출력 포트, 데코레이터면 `Out` 1개. 포트에 `EdgeConnector<Edge>(listener)`를 `AddManipulator`한다. 리스너는 우선 `OnDrop`에서 `graphView.AddElement(edge)`만 하는 최소 구현으로 시작한다.

   확인 방법: 출력 포트에서 입력 포트로 끌면 곡선이 이어진다(아직 데이터에는 반영되지 않는다).

7. **저장된 연결을 엣지로 그린다.** `DrawEdges`에서 컴포짓은 `OutputPorts[i].ConnectTo(childView.InputPort)`, 데코레이터는 `OutputPorts[0]`로 연결해 `AddElement`한다. `child`가 `null`이거나 `_nodeViews`에 없는 경우는 건너뛴다.

   확인 방법: 이미 구성된 트리를 열면 부모-자식 엣지가 모두 그려진다.

8. **연결을 데이터에 반영한다.** 위 `OnEdgeConnected`를 구현한다. 자기 연결 금지, 순환 검사, `children.Add` 또는 `child` 설정, `SetDirty`, `RedrawTree`. 출력 포트의 리스너에서 엣지 드롭 시 `OnEdgeConnected`를 직접 호출한다.

   확인 방법: 엣지를 이은 뒤 에셋을 선택해 인스펙터에서 `children` 리스트에 해당 노드가 들어가 있는지 본다. 창을 닫고 다시 열어도 엣지가 남아 있다. 자기 자신이나 조상을 자식으로 잇는 시도는 엣지가 사라진다.

9. **연결 해제를 반영한다.** `graphViewChanged.elementsToRemove`에서 `Edge`를 찾아 `OnEdgeDisconnected`를 호출하고, 컴포짓이면 `children[idx] = null`(슬롯 유지) 또는 `RemoveAt`(슬롯 제거) 중 하나를 선택해 구현한다. 원본은 슬롯을 `null`로 남긴다.

   확인 방법: 엣지를 선택하고 Delete를 누르면 `children`에서 참조가 사라지고, 다시 그려도 엣지가 돌아오지 않는다.

10. **스타일을 입힌다.** `Resources/BTStyles.uss`를 만들어 `.node.selector`, `.node.sequence`, `.node.action`, `.node.condition`, `.node.decorator`에 색을 주고, `BTNodeView`가 타입에 맞는 클래스(`AddToClassList("selector")` 등)와 `node`를 붙인다.

    확인 방법: 노드 종류별로 색이 다르게 나온다. 원본은 Selector 파랑, Sequence 분홍, Condition 초록, Action 노랑, Decorator 보라다.

## 막히기 쉬운 곳, 한계

* **루트가 없으면 우클릭 메뉴도 없다.** `BTGraphView` 생성자에서 `_tree.rootNode == null`이면 `return`한다. 노드 생성 팝업을 띄우는 우클릭 콜백 등록이 그 `return`보다 아래에 있다. 루트가 비어 있는 트리에서는 빈 공간 우클릭으로 노드를 만들 수 없다(코드 읽기, unverified). `BehaviorTree.OnEnable()`이 루트 `Selector`를 자동 생성해 주는 이유가 여기에 있어 보인다.
* **입력 포트에서 시작한 드래그.** 입력 포트의 `BTEdgeConnectorListener.OnDrop`은 `AddElement(edge)`만 하고 `OnEdgeConnected`를 호출하지 않는다. 입력 포트 쪽에서 끌어 출력 포트에 놓으면 화면에는 엣지가 생기지만 데이터에 반영되지 않을 수 있다(`graphViewChanged`의 `edgesToCreate` 경로가 대신 처리하는지는 실행해 보지 못했다).
* **입력 포트 `Capacity.Single`.** 한 노드에 부모 엣지는 하나다. 이미 부모가 있는 노드를 다른 부모에 이으면 기존 부모의 `children`에 참조가 남을 수 있다(`OnEdgeConnected`는 이전 부모의 참조를 지우지 않는다, 코드 읽기).
* **순환 검사 오탐.** 에디터의 `CheckCycle`은 `visited.Add(child)`가 실패하면 순환으로 본다. 같은 하위 트리가 두 경로로 이어진 다이아몬드 구조도 순환으로 처리된다. 런타임의 `visited` 검사와 같은 성격의 제약이다.
* **내용이 비어 있는 자식 슬롯.** 연결을 끊거나 설정 패널의 "자식 노드 추가"를 쓰면 `children`에 `null`이 들어간다. 포트 자리를 유지하려는 설계이지만 런타임 컴포짓이 `null`을 만나면 예외가 난다([컴포짓 노드](composite-nodes.md)).
* **창/뷰와의 결합 방식.** `BTNodeView`와 `BTGraphView`는 `GetWindow<BTEditorWindow>()`로 창을 얻어, 리플렉션으로 비공개 필드 `autoSaveEnabled`를 읽고 비공개 메서드 `DeleteSelectedNode`를 호출한다. 동작은 하지만 이름이 바뀌면 조용히 실패한다. 직접 만든다면 창에 공개 프로퍼티나 이벤트를 두는 편이 안전하다.
* **쓰이지 않는 코드.** `BTEditorWindow.AddNode`, `DeleteOrphanNode`, `BTGraphView.Traverse`, `BTNodeView.OnNodeClicked`, `BTEditorUtils`의 일부 메서드는 읽은 범위에서 호출하는 곳이 없다. 따라 만들 때는 생략해도 된다.
* **GraphView는 실험적 API.** 네임스페이스에 `Experimental`이 붙어 있다. 버전을 올릴 때 깨질 수 있다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] "뷰는 데이터를 투영하고, 바뀔 때마다 통째로 다시 그린다"는 방식의 장점과 단점을 내 말로 적는다.
- [ ] 출력 포트를 "자식 슬롯"으로 대응시킨 설계에서, 내가 에디터 사용자라면 어떤 불편을 느낄지 상상해서 적는다.
- [ ] 직접 따라 만들면서 가장 오래 걸린 단계와 그 이유를 적는다.
