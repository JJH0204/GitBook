# 그래프 에디터 (2): 팝업, 설정 패널, 직렬화, 저장/불러오기

## 무엇을 하는가

[그래프 에디터 (1)](graph-editor.md)에서 화면에 그리고 연결하는 부분을 봤다면, 이 페이지는 나머지 네 가지를 다룬다.

| 기능 | 클래스 | 한 줄 설명 |
| --- | --- | --- |
| 에디터 열기 | `BTInspector` | `BehaviorTree` 에셋의 인스펙터에 "Open Behavior Tree Editor" 버튼을 붙인다 |
| 노드 만들기 | `BTNodeCreatePopupWindow` | 타입을 고르고 이름을 입력해 노드를 만들고, 부모 슬롯에 연결한다 |
| 노드 값 고치기 | `BTNodeSettingsPopupWindow` | 선택한 노드의 이름, 자식 목록, 타입별 값을 편집하는 오른쪽 패널 |
| 저장과 불러오기 | `BehaviorTree` + `BTEditorWindow` + `BTEditorUtils` | 노드를 트리 에셋의 서브에셋으로 저장하고, 에셋을 선택하면 다시 그린다 |

## 왜 이렇게 설계했나

* **노드를 트리 에셋의 서브에셋으로 저장한다.** 노드마다 별도 `.asset` 파일을 만들지 않고 `AssetDatabase.AddObjectToAsset(node, tree)`로 트리 에셋 파일 안에 넣는다. 트리 하나가 파일 하나이므로 에셋 관리가 단순하고, 노드끼리의 참조(`children`, `input`)가 한 파일 안에서 이어진다. 초기 커밋(2025-08-03)과 이후 한동안은 노드마다 `ScriptableAssets/` 아래에 `.asset` 파일이 따로 있었고, 현재의 `Resources/AI/GlobalBT.asset`처럼 노드가 한 파일에 모인 형태가 최종 구조다(커밋 diff상의 추정이며 전환 시점은 확인하지 않았다).
* **저장은 `SetDirty` + `SaveAssets`.** 별도의 JSON 변환이나 "저장 형식"을 만들지 않는다. 노드는 이미 Unity가 직렬화하는 `ScriptableObject`이므로, 필드를 바꾸고 `EditorUtility.SetDirty`로 표시한 뒤 `AssetDatabase.SaveAssets()`를 부르면 끝이다. "자동 저장" 토글은 `SaveAssets()` 호출 여부만 제어한다.
* **설정 패널이 따로 있는 이유.** 기본 인스펙터로도 노드 값은 고칠 수 있지만, 그래프를 보면서 바로 옆에서 고치고 싶었기 때문으로 보인다(소스 주석 "UIElements 기반 커스텀 인스팩터 예시"). 패널은 `EditorWindow`가 아니라 창 안에 `Position.Absolute`로 띄우는 `VisualElement`다. 클래스 이름이 `...PopupWindow`지만 별도 창이 아니다.
* **노드 타입을 리플렉션으로 모은다.** 노드 생성 팝업은 `BTNode`의 비추상 하위 클래스를 전부 찾아 목록으로 만든다. 새 노드 클래스를 추가하면 팝업 코드를 고치지 않아도 목록에 나온다([리프 노드](leaf-nodes.md)의 "새 노드 추가").

## 핵심 코드 발췌

{% code title="Editor/BTInspector.cs" %}
```csharp
[CustomEditor(typeof(BehaviorTree))]
public class BTInspector : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();
        GUILayout.Space(10);
        if (GUILayout.Button("Open Behavior Tree Editor"))
        {
            BTEditorWindow.Open();
        }
    }
}
```
{% endcode %}

* `[CustomEditor(typeof(BehaviorTree))]`: 이 타입의 인스펙터를 대체한다. README의 사용법 "생성한 트리 선택 > 인스펙터 창 > Open Behavior Tree Editor 클릭"이 이 버튼이다.
* `DrawDefaultInspector()`로 기본 필드(`rootNode`)를 먼저 그리고 그 밑에 버튼을 붙인다.
* 창을 열 때 트리 에셋이 선택되어 있어야 한다. 창이 `Selection.activeObject`를 보기 때문이다.

{% code title="Editor/BTNodeCreatePopupWindow.cs (OnCreateNode)" %}
```csharp
private void OnCreateNode()
{
    int idx = _typeField.index;
    if (idx < 0 || idx >= _nodeTypes.Count) return;
    var nodeType = _nodeTypes[idx];
    var node = ScriptableObject.CreateInstance(nodeType) as BTNode;
    if (node == null) return;
    node.position = _popupPosition;
    node.guid = System.Guid.NewGuid().ToString();
    node.name = _nameField.value;
    AssetDatabase.AddObjectToAsset(node, _tree);
    AssetDatabase.SaveAssets();
    // 부모 노드에 연결
    if (_parentNodeView != null && _parentNodeView.Node is BTComposite composite)
    {
        if (_outPortIndex < composite.children.Count)
            composite.children[_outPortIndex] = node;
        else
            composite.children.Add(node);
        node.input = _parentNodeView.Node;
    }
    else if (_parentNodeView != null && _parentNodeView.Node is BTDecorator decorator)
    {
        decorator.child = node;
        node.input = _parentNodeView.Node;
    }
    EditorUtility.SetDirty(node);
    if (_parentNodeView != null) EditorUtility.SetDirty(_parentNodeView.Node);
    AssetDatabase.SaveAssets();
    Close();
    _graphView?.RedrawTree();
}
```
{% endcode %}

* `ScriptableObject.CreateInstance(nodeType)`: 타입 객체로 노드를 만든다. 타입 목록은 `typeof(BTNode).Assembly.GetTypes()`에서 `IsSubclassOf(BTNode) && !IsAbstract`로 거른 것이다.
* `node.position`: 팝업을 연 마우스 위치를 `contentViewContainer.WorldToLocal`로 그래프 좌표로 바꿔 둔 값이다. 새 노드가 마우스를 놓은 곳에 생긴다.
* `AddObjectToAsset(node, _tree)`: 이 한 줄이 노드를 트리 에셋 파일 안에 영구 저장한다. 이 호출이 없으면 노드는 메모리에만 있다가 사라진다.
* 부모 연결: 컴포짓이면 `_outPortIndex` 슬롯에 넣거나 끝에 추가하고, 데코레이터면 `child`로 설정한다. 우클릭으로 만들었다면(`_parentNodeView == null`) 연결 없이 노드만 생긴다(고아 노드).
* `Close()` 후 `RedrawTree()`로 그래프를 갱신한다.

{% code title="Editor/BTNodeCreatePopupWindow.cs (OnDisable)" %}
```csharp
private void OnDisable()
{
    EditorApplication.update -= CheckFocus;
    // 팝업이 닫힐 때 연결되지 않은 임시 간선 및 아웃 포트 정리
    if (_parentNodeView != null && _outPortIndex >= 0 && _parentNodeView.OutputPorts.Count > _outPortIndex)
    {
        // 연결된 노드 정보만 null로 변경
        if (_parentNodeView.Node is BTComposite composite)
        {
            if (_outPortIndex < composite.children.Count)
                composite.children[_outPortIndex] = null;
        }
        else if (_parentNodeView.Node is BTDecorator decorator)
        {
            decorator.child = null;
        }
    }
    if (_graphView != null)
    {
        _graphView.RedrawTree();
    }
}
```
{% endcode %}

* 이 코드는 창이 닫힐 때(`OnDisable`) 부모의 해당 슬롯을 `null`로 되돌린다. "연결하지 않고 닫았을 때의 정리"가 의도다.
* 문제 후보: `OnCreateNode`가 연결을 끝낸 뒤 `Close()`를 부르면 같은 `OnDisable`이 실행되어 방금 연결한 슬롯을 다시 `null`로 만들 수 있다. 부모 뷰가 있고 포트 인덱스가 유효한 "포트에서 끌어서 만들기" 경로에서만 해당한다. 원본 README의 알려진 이슈 "간선을 드래그 앤 드롭 하여 노드 생성 시 노드 간 연결이 자동으로 설정되지 않음"의 원인 후보다(코드 읽기, **unverified**). 확인하려면 포트에서 끌어 노드를 만든 뒤 부모의 `children`을 인스펙터에서 본다. 고친다면 `OnCreateNode`에 "연결 완료" 플래그를 두고 `OnDisable`에서 그 플래그가 켜져 있으면 정리를 건너뛰면 된다.
* 또 `RegisterPopupCallbacks()`(포커스를 잃으면 닫는 `CheckFocus` 등록)는 읽은 범위에서 호출되는 곳이 없다.

{% code title="Editor/BTNodeSettingsPopupWindow.cs (이름, 컴포짓 자식 목록)" %}
```csharp
var nameField = new TextField("노드 이름") { value = _targetNode.name };
nameField.isDelayed = true;
nameField.RegisterValueChangedCallback(evt =>
{
    if (_targetNode.name != evt.newValue)
    {
        _targetNode.name = evt.newValue;
        EditorUtility.SetDirty(_targetNode);
        AssetDatabase.SaveAssets();
        _graphView?.RedrawTree();
        nameField.Focus();
    }
});
Add(nameField);

if (_targetNode is BTComposite composite)
{
    for (int i = 0; i < composite.children.Count; i++)
    {
        var childField = new ObjectField($"자식 {i + 1}")
        {
            objectType = typeof(BTNode),
            value = composite.children[i],
            allowSceneObjects = false
        };
        int idx = i;
        childField.RegisterValueChangedCallback(evt =>
        {
            composite.children[idx] = evt.newValue as BTNode;
            EditorUtility.SetDirty(_targetNode);
            AssetDatabase.SaveAssets();
            _graphView?.RedrawTree();
        });
        Add(childField);
    }
    // "자식 노드 추가" 버튼: composite.children.Add(null) 후 저장, RedrawTree
}
```
{% endcode %}

* `isDelayed = true`: 입력 중에는 이벤트가 발생하지 않고 Enter/포커스 이동 때 한 번만 발생한다. 한 글자마다 저장과 다시 그리기가 일어나는 것을 막는다.
* 값이 바뀌면 `SetDirty` → `SaveAssets` → `RedrawTree`가 한 묶음이다. 모든 필드 편집 콜백이 이 패턴을 따른다. 다시 그린 뒤 `Focus()`로 입력 포커스를 되찾는다.
* `ObjectField`: 자식 슬롯을 숫자(`자식 1`, `자식 2`)로 보여 주고 에셋 참조를 직접 끌어 놓을 수 있다. 이 필드로 바꾼 자식은 `input`(부모 참조)이 갱신되지 않는다. 런타임 평가는 `children`만 쓰므로 동작에는 영향이 없어 보이지만, `input`을 읽는 에디터 코드(`IsOrphanNode`)는 영향을 받는다(코드 읽기).
* "자식 노드 추가" 버튼은 `children.Add(null)`을 해서 출력 포트 자리를 하나 늘린다. 빈 슬롯이 `null`로 직렬화된다. 이 레포의 `Resources/AI/GlobalBT.asset`에도 `children:` 아래에 `- {fileID: 0}`(null 참조) 항목이 14개 들어 있다(파일을 직접 확인). README가 말하는 "null 노드 참조 오류(구동에는 문제 없음)"는 이런 빈 슬롯에서 나오는 것으로 보이나, 실행해 보지 못했다.
* 타입별 필드는 `if (condition is BTIsRandom ...)` 식으로 하나씩 하드코딩되어 있다. 편집 UI가 있는 타입은 `BTCooldown`, `BTDelay`, `BTIsRandom`, `BTIsInSkillRange`, `BTIsCooldown`, `BTIsHealthLow`, 모든 `BTAction`의 `priority`, `BTActionAttack`, `BTActionSystemMessage`, `BTActionChangeState`다. 나머지(예: `BTRepeater`의 횟수)는 기본 인스펙터에서 고친다.

{% code title="직렬화된 노드 (Resources/AI/GlobalBT.asset 일부, fileID 생략)" %}
```yaml
MonoBehaviour:
  m_Script: {fileID: 11500000, guid: <스크립트 GUID>, type: 3}
  m_Name:
  state: 0
  name: UseSkill Parallel
  guid: a1b7e918-4427-4406-af50-7899a616b7c8
  position: {x: 984, y: 993}
  input: {fileID: <부모 노드 fileID>}
  outputs: []
  children:
  - {fileID: 0}
  - {fileID: 0}
```
{% endcode %}

* 한 노드가 YAML 문서 하나다. 트리 에셋 파일 안에 이런 `MonoBehaviour` 문서가 노드 수만큼 들어 있다.
* `m_Name`은 비어 있고 에디터가 쓰는 이름은 `name:`에 따로 저장된다. `BTNode`가 `Object.name`을 `new string name`으로 가린 결과다.
* `position`, `guid`, `input`, `children`이 그래프를 복원하는 데 필요한 전부다. `outputs`는 항상 빈 리스트다.
* `children`의 `{fileID: 0}`이 null 슬롯이다.

{% code title="Editor/BTEditorWindow.cs (저장, 삭제)" %}
```csharp
private void SaveTreeNodes()
{
    if (_currentTree == null || _currentTree.rootNode == null) return;
    var visited = new HashSet<BTNode>();
    SaveNodeRecursive(_currentTree.rootNode, visited);
    EditorUtility.SetDirty(_currentTree);
    AssetDatabase.SaveAssets();
}

private void DeleteSelectedNode()
{
    if (_selectedNode == null || _currentTree == null) return;
    if (_selectedNode.input is BTComposite parentComposite)
        parentComposite.children.Remove(_selectedNode);
    else if (_selectedNode.input is BTDecorator parentDecorator && parentDecorator.child == _selectedNode)
        parentDecorator.child = null;
    if (_currentTree.rootNode == _selectedNode)
        _currentTree.rootNode = null;

    AssetDatabase.RemoveObjectFromAsset(_selectedNode);
    DestroyImmediate(_selectedNode, true);
    AssetDatabase.SaveAssets();
    _selectedNode = null;
    Refresh();
}
```
{% endcode %}

* `SaveTreeNodes`는 루트에서 내려가며 도달 가능한 노드에 `SetDirty`를 건다. 루트에 닿지 않는 고아 노드는 이 경로로는 표시되지 않는다.
* 삭제는 (1) 부모에서 참조 제거, (2) 루트면 `rootNode`를 비움, (3) `RemoveObjectFromAsset`으로 에셋에서 제거, (4) `DestroyImmediate(obj, true)`로 메모리에서 제거 순서다. `true`는 에셋 객체를 파괴할 때 필요하다.
* 이 메서드는 노드 우클릭 메뉴("노드 삭제")에서 `BTNodeView`가 리플렉션으로 부른다. 삭제 대상은 우클릭한 노드가 아니라 창이 기억하는 `_selectedNode`다(우클릭이 선택을 바꾸는지는 실행해 보지 못했다).
* 불러오기는 별도 코드가 없다. 트리 에셋을 선택하면 `Refresh()` → `BTGraphView` 생성 → `DrawTree`가 에셋에 저장된 노드와 좌표를 다시 읽어 그린다.

## 따라 만들기: 팝업에서 저장까지

[그래프 에디터 (1)](graph-editor.md)의 창, 노드 뷰, 엣지 연결이 되어 있다고 가정한다.

1. **인스펙터 버튼을 만든다.** `Editor/BTInspector.cs`에 위 코드를 넣는다.

   확인 방법: `BehaviorTree` 에셋을 선택하면 기본 필드 아래에 버튼이 보이고, 누르면 에디터 창이 열린다.

2. **노드 타입 목록을 만든다.** `typeof(BTNode).Assembly.GetTypes().Where(t => t.IsSubclassOf(typeof(BTNode)) && !t.IsAbstract && t.IsClass)`로 목록을 만든다. 처음에는 `Debug.Log`로 타입 이름만 출력한다.

   확인 방법: 콘솔에 Selector, Sequence, Parallel, Inverter, 각종 액션/조건 이름이 나온다. `BTComposite`나 `BTAction`처럼 직접 쓰면 안 되는 기반 클래스가 목록에 섞이면 `abstract`로 바꿔 제외한다(원본은 제외하지 않는다).

3. **생성 팝업 UI를 만든다.** `EditorWindow`를 상속한 `BTNodeCreatePopupWindow`에 `PopupField<string>`(타입 목록)과 `TextField`(이름), `Button`을 `rootVisualElement`에 추가한다. `ShowPopup(...)` 정적 메서드에서 `CreateInstance`, 위치 지정, `ShowModalUtility()`를 호출한다.

   확인 방법: 그래프 뷰 빈 곳을 우클릭하면 팝업이 마우스 근처에 열린다(루트가 있는 트리여야 한다).

4. **노드를 에셋에 넣는다.** `OnCreateNode`에서 `CreateInstance`, `guid`, `position`, `name`을 설정하고 `AssetDatabase.AddObjectToAsset(node, tree)` + `SaveAssets()`를 호출한다.

   확인 방법: Project 창에서 트리 에셋을 펼치면 새 노드가 서브에셋으로 보인다. 창을 닫고 Unity를 재시작해도 남아 있다.

5. **팝업을 엣지 드롭에 연결한다.** 출력 포트용 리스너의 `OnDropOutsidePort`에서 드롭 위치 아래에 노드가 없으면 `ShowNodeCreatePopup(parentView, portIndex, position)`을 호출한다. 위치에 노드가 있으면 그 노드를 곧바로 자식으로 연결한다(원본은 사각형 중 마우스 안에 있고 중심이 가장 가까운 노드를 고른다).

   확인 방법: 출력 포트에서 빈 곳으로 끌면 팝업이 뜨고, 노드를 만들면 부모에 이어진다. 이어지지 않는다면 위 `OnDisable` 문제 후보를 확인한다.

6. **설정 패널을 만든다.** `VisualElement`를 상속한 패널에 `SetTargetNode(node, graphView)`를 만들고, 선택된 노드가 없으면 "노드가 선택되지 않았습니다." 라벨을 보인다. 창의 `Refresh`에서 `Position.Absolute`, `right`/`top`을 지정해 오른쪽에 붙인다. 창의 `EditorApplication.update` 폴링으로 선택 변화를 감지해 `SetTargetNode`를 호출한다.

   확인 방법: 노드를 클릭하면 패널의 내용이 선택한 노드로 바뀌고, 빈 곳을 클릭하면 안내 문구가 나온다.

7. **이름과 자식 목록 편집을 넣는다.** 위 발췌처럼 `TextField(isDelayed)`와 컴포짓의 `ObjectField` 목록, "자식 노드 추가/삭제" 버튼을 만든다. 모든 콜백은 `SetDirty` → `SaveAssets` → `RedrawTree`로 끝낸다.

   확인 방법: 이름을 바꾸면 그래프의 노드 제목이 바뀌고, "자식 노드 추가"를 누르면 출력 포트가 하나 늘어난다.

8. **타입별 필드를 넣는다.** `BTCooldown.cooldownTime`처럼 자주 바꾸는 값만 `FloatField`/`IntegerField`로 연결한다. 모든 타입을 하드코딩하는 대신 `SerializedObject`/`PropertyField`로 기본 인스펙터를 `InspectorElement`에 그리는 방법도 있다(원본은 하드코딩이다).

   확인 방법: 값을 바꾸고 에셋을 다시 열었을 때 값이 유지된다.

9. **자동 저장 토글을 넣는다.** 창에 `bool autoSaveEnabled`와 `Toggle`을 두고, 연결/해제/이동 이후 `SetDirty`는 항상, `SaveAssets`는 토글이 켜져 있을 때만 호출한다. 리플렉션 대신 공개 프로퍼티로 뷰들이 읽도록 만든다.

   확인 방법: 토글을 끄고 노드를 옮긴 뒤 Unity를 저장하지 않고 닫으면(저장 거부) 위치가 되돌아간다. 켜 두면 유지된다.

10. **삭제를 넣는다.** `DeleteSelectedNode`(부모 참조 제거 → `RemoveObjectFromAsset` → `DestroyImmediate(obj, true)`)와 노드 우클릭 메뉴("노드 삭제")를 만든다.

    확인 방법: 노드를 삭제하면 Project 창의 서브에셋 목록에서도 사라진다. 부모의 `children`에서 참조가 제거되었는지 인스펙터로 확인한다.

11. **루트를 자동 생성한다.** `BehaviorTree.OnEnable`(에디터 전용)에서 `rootNode`가 없으면 `Root`라는 이름의 `BTSelector`를 `CreateInstance`하고 `AddObjectToAsset`으로 트리에 넣는다.

    확인 방법: Create 메뉴로 새 BehaviorTree를 만들면 에셋 안에 `Root` 서브에셋이 생기고 에디터 창에서 보인다. (이 동작은 코드에서만 읽었고 실행해 보지 않았다.)

12. **저장과 불러오기를 확인한다.** 노드 3개 이상을 만들어 이은 뒤 Unity를 재시작하고 에디터 창으로 다시 연다.

    확인 방법: 노드 위치와 연결이 그대로 복원된다. 인스펙터의 `children`에 `None`(null) 항목이 없는지도 본다.

## 막히기 쉬운 곳, 한계

* **포트에서 끌어 만든 노드가 연결 안 되는 문제.** 위 `OnDisable` 설명대로 원인 후보가 코드에서 읽힌다. 확인되지 않은 후보이므로 직접 실험해서 확인해야 한다.
* **null 슬롯.** 연결 해제(`children[idx] = null`)와 "자식 노드 추가", 팝업 `OnDisable`이 모두 `null`을 남기는 경로다. 런타임에서 컴포짓이 `null` 자식을 만나면 예외가 난다. 방지책은 평가 루프의 `if (child == null) continue;`나, 에셋 저장 전에 `RemoveAll(c => c == null)`로 정리하는 것이다.
* **`BTNode.name`이 `Object.name`을 가린다.** 서브에셋의 `m_Name`이 비어 Project 창에서 이름이 보이지 않을 수 있다. `BTGraphView`는 `node.name`(가린 필드)으로 제목을 단다.
* **기본 이름 `Root`.** `BTNode`의 생성자 기본 이름이 `"Root"`이고 `BehaviorTree.OnEnable`이 "이름이 Root인 노드"를 루트로 찾는다. 사용자가 `Root`라는 이름의 노드를 따로 만들거나 루트 이름을 바꾸면 의도와 다르게 동작할 수 있다.
* **`OnEnable`에서 서브에셋 만들기.** 새 에셋을 만든 직후 `OnEnable`에서 `AddObjectToAsset`을 호출하는 방식은 에셋 경로가 아직 없는 시점에 부르면 실패할 수 있다. 원본이 실제로 문제없이 도는지는 실행해 보지 못했다.
* **선택 갱신 빈도.** `BTNodeView.SetPosition`이 호출될 때마다 `UpdateNodeSelection`이 불려 설정 패널을 통째로 다시 만든다. 노드를 끄는 동안 패널이 계속 재생성될 수 있다(코드 읽기).
* **자동 저장 비용.** 거의 모든 편집이 `AssetDatabase.SaveAssets()`를 호출한다. 노드가 많아지면 저장이 느려질 수 있다.
* **`using UnityEditor` 의존.** 에디터 스크립트는 `Editor` 폴더 아래에 있어야 빌드에서 빠진다. 다만 `BehaviorTree.cs`(런타임)가 `using UnityEditor;`를 쓰고 있어 빌드 가능성은 별도 확인이 필요하다([BT 기초](bt-basics.md)).

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 노드를 "트리 에셋의 서브에셋"으로 저장하는 방식이 "노드마다 별도 에셋"이나 "JSON 파일"에 비해 어떤 점이 다른지 내 말로 적는다.
- [ ] 직접 따라 만들다가 노드 연결이 끊기거나 null이 생긴 경험이 있다면, 어떤 조작에서 생겼고 어떻게 확인했는지 적는다.
- [ ] 설정 패널의 타입별 필드를 하드코딩하는 방식을 내가 다시 설계한다면 어떻게 바꿀지 적는다.
