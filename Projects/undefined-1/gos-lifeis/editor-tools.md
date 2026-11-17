# 에디터 도구: 팔레트 창, 강제 실행 버튼, Animator 생성기

## 무엇이 바뀌었나

원본 GOS에서 노드를 만드는 방법은 Hierarchy 우클릭 `GameObject/VisualScripting/...` 메뉴였다. 노드마다 `[MenuItem]` 메서드를 손으로 하나씩 작성한 `VisualScriptingEditor.cs`(284줄)가 그 역할을 했다. 새 노드를 만들면 메뉴 코드도 직접 추가해야 했다.

포크는 에디터 쪽을 이렇게 바꿨다.

| 도구 | 파일 | 하는 일 |
| --- | --- | --- |
| 팔레트 창 | `Scripts/VisualScripting/Editor/VisualScriptingPalette.cs` | `ProcessBase`를 상속한 클래스를 자동으로 찾아 버튼 목록으로 보여 주고, 검색으로 거른다 |
| 강제 실행 버튼 | `Scripts/VisualScripting/Editor/ProcessBaseEditor.cs` | 모든 노드의 인스펙터 아래에 "강제 실행 (Execute)" 버튼을 붙인다 |
| Animator 생성기 | `Editor/AnimatorGenerator.cs` | JSON 텍스트로 Animator Controller 에셋을 만든다 |
| `EntryClonerEditor` | `Editor/EntryClonerEditor.cs` | 파일 이름은 에디터 확장이지만 내용은 Unity 기본 템플릿 스크립트다 |

* 우클릭 메뉴(`VisualScriptingEditor.cs`)는 d3cfe625에서 삭제됐다. 포크 README는 아직 "Hierarchy > (우클릭) > VisualScripting"이라고 안내한다.
* 팔레트는 38f2e184에서 처음 생겼고, fd1e5bfa에서 검색창이 붙으면서 분류 방식과 새로고침 버튼이 바뀌었다. 92dcef6e는 같은 메시지의 `.gitignore` 변경뿐이다.

## 왜

* 노드가 늘어나면 `[MenuItem]`을 일일이 쓰는 방식은 따라가기 어렵다. 팔레트는 `TypeCache`로 `ProcessBase` 하위 클래스를 자동 수집하므로, 새 노드는 스크립트만 추가하면 목록에 나온다(코드에서 읽히는 이유).
* 노드가 늘어난 뒤 fd1e5bfa에서 검색창을 붙였다. 메시지는 "비쥬얼 스크립트 팔레트 윈도우 검색기능 추가"다. `ProcessBase`를 상속한 클래스는 원본 21개에서 포크 33개로 늘었다.
* 인스펙터의 "강제 실행" 버튼은 노드 하나를 플레이 중에 바로 눌러 보는 테스트용이다. 입력 조건(트리거 진입 등)을 매번 재현하지 않아도 된다.
* `AnimatorGenerator`가 왜 들어왔는지는 커밋 메시지에 없다(1094d49c "불필요한 구성 삭제및 샘플 새구성, 패키지관리자 업데이"). 코드 주석에 "ComboLink or ReturnLink"가 있어 콤보 공격 같은 Animator 구성을 JSON으로 받아 만들려는 용도로 보인다. 이는 추정이다.

## 핵심 코드

### 팔레트 창: 노드 수집과 검색

{% code title="Editor/VisualScriptingPalette.cs (일부)" %}
```csharp
[MenuItem("Visual Scripting/GameObject/Pallete Window")]
public static void ShowWindow() { GetWindow<VisualScriptingPalette>("Visual Scripting Pallete Window").Show(); }

private void RefreshNodeList()
{
    _categorizedNodes.Clear();
    var nodeTypes = TypeCache.GetTypesDerivedFrom<ProcessBase>()
        .Where(t => !t.IsAbstract && !t.IsInterface);

    foreach (Type type in nodeTypes)
    {
        string[] guids = AssetDatabase.FindAssets($"{type.Name} t:MonoScript");
        string categoryName = "ETC (미분류)";
        foreach (string guid in guids)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            if (path.EndsWith($"/{type.Name}.cs"))
            {
                string[] parts = path.Split('/');
                if (parts.Length > 2) categoryName = parts[parts.Length - 2];
                break;
            }
        }
        if (!_categorizedNodes.ContainsKey(categoryName))
            _categorizedNodes[categoryName] = new List<Type>();
        _categorizedNodes[categoryName].Add(type);
    }
}

// OnGUI 안: 검색어로 거른 뒤, 남은 노드가 없는 카테고리는 제목도 그리지 않는다
var filteredNodes = category.Value
    .Where(t => string.IsNullOrEmpty(_searchQuery) || t.Name.IndexOf(_searchQuery, StringComparison.OrdinalIgnoreCase) >= 0)
    .OrderBy(t => t.Name).ToList();
if (filteredNodes.Count == 0) continue;
```
{% endcode %}

* `TypeCache.GetTypesDerivedFrom<ProcessBase>()`: 에디터가 캐시해 둔 타입 목록에서 `ProcessBase` 자손을 즉시 가져온다. 어셈블리 전체를 리플렉션으로 훑는 것보다 빠르다. 추상 클래스는 제외한다.
* `AssetDatabase.FindAssets($"{type.Name} t:MonoScript")`: 클래스 이름으로 스크립트 에셋을 찾는다. 경로가 `/클래스이름.cs`로 끝나는 것을 고른다. 즉 **파일 이름이 클래스 이름과 같아야 분류된다.**
* `parts[parts.Length - 2]`: 경로의 **바로 위 폴더 이름**이 카테고리다. 38f2e184 버전은 경로에 `/Input/`, `/Logic/`, `/Output/`이 들어 있는지로 세 가지로만 분류했다. fd1e5bfa에서 폴더 이름 그대로로 바뀌었다. 코드 주석의 예시는 `Output_Camera` 같은 폴더를 가정한다.
* 검색: `IndexOf(..., OrdinalIgnoreCase)`로 대소문자 구분 없이 부분 일치한다. 일치하는 노드가 없는 카테고리는 제목째로 숨긴다.

### 팔레트 창: 노드 생성

{% code title="Editor/VisualScriptingPalette.cs (일부)" %}
```csharp
private void CreateNode(Type nodeType, string category)
{
    GameObject go = new GameObject(nodeType.Name);
    go.AddComponent(nodeType);

    if (nodeType.Name.Contains("Trigger"))
    {
        BoxCollider col = go.AddComponent<BoxCollider>();
        col.isTrigger = true;
    }

    GameObject activeObj = Selection.activeGameObject;
    if (activeObj != null) GameObjectUtility.SetParentAndAlign(go, activeObj);

    Undo.RegisterCreatedObjectUndo(go, $"Create {nodeType.Name}");
    Selection.activeObject = go;
}
```
{% endcode %}

* 이름에 "Trigger"가 들어가면 `BoxCollider`를 붙이고 `isTrigger`를 켠다. 원본 우클릭 메뉴가 `Trigger`, `TriggerEnter`, `TriggerExit`에만 이렇게 하던 것을 이름 규칙으로 일반화한 것이다.
* `SetParentAndAlign`: 이미 선택된 오브젝트가 있으면 그 자식으로 만든다.
* `Undo.RegisterCreatedObjectUndo`: `Ctrl+Z`로 생성을 취소할 수 있다.

### 인스펙터의 강제 실행 버튼

{% code title="Editor/ProcessBaseEditor.cs" %}
```csharp
[CustomEditor(typeof(ProcessBase), true)]
public class ProcessBaseEditor : UnityEditor.Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        EditorGUILayout.Space();

        ProcessBase process = (ProcessBase)target;
        if (GUILayout.Button("강제 실행 (Execute)", GUILayout.Height(30)))
        {
            process.ForceExecute();
        }
    }
}
```
{% endcode %}

* `[CustomEditor(typeof(ProcessBase), true)]`: 두 번째 인자 `true`가 "자손 클래스에도 적용"이다. 그래서 `ProcessBase`를 상속한 모든 노드의 인스펙터가 이 에디터로 그려진다.
* `base.OnInspectorGUI()`: 기존 필드를 먼저 그리고, 그 아래에 버튼을 붙인다.
* `ForceExecute()`는 `ProcessBase`에 `#if UNITY_EDITOR`로 들어 있는 메서드다. 로그를 찍고 `Execute()`를 부른다. 같은 메서드가 `[ContextMenu("강제 실행 (테스트)")]`로 컴포넌트 우클릭 메뉴에도 나온다.

### Animator 생성기: 상태와 전환 만들기

{% code title="Editor/AnimatorGenerator.cs (일부)" %}
```csharp
[MenuItem("Tools/Generate Animator from JSON")]
public static void ShowWindow() { GetWindow<AnimatorGenerator>("Animator Generator"); }

// ... JsonUtility.FromJson<RootObject>(jsonContent) 로 파싱, CreateAnimatorControllerAtPath 로 컨트롤러 생성

foreach (var stateData in layerData.States)
{
    AnimatorState newState = sm.AddState(stateData.Name, new Vector3(250, index * 70, 0));
    if (!string.IsNullOrEmpty(stateData.MotionGUID))
    {
        string assetPath = AssetDatabase.GUIDToAssetPath(stateData.MotionGUID);
        Motion motion = AssetDatabase.LoadAssetAtPath<Motion>(assetPath);
        if (motion != null) newState.motion = motion;
    }
    stateMap.Add(stateData.Name, newState);
    index++;
}

foreach (var stateData in layerData.States)
{
    AnimatorState sourceState = stateMap[stateData.Name];
    foreach (var transData in stateData.Transitions)
    {
        AnimatorState destState = stateMap[transData.DestinationState];
        AnimatorStateTransition transition = sourceState.AddTransition(destState);
        transition.hasExitTime = transData.HasExitTime;
        transition.exitTime = transData.ExitTime;
        transition.duration = transData.TransitionDuration;
        foreach (var cond in transData.Conditions)
            transition.AddCondition(ParseConditionMode(cond.Mode), cond.Threshold, cond.Parameter);
    }
}
```
{% endcode %}

* 상태를 먼저 모두 만들어 `stateMap`(이름으로 찾는 딕셔너리)에 넣고, 그 다음 두 번째 루프에서 전환을 잇는다. 전환의 도착 상태가 아직 만들어지지 않은 상황을 피하는 2단계 구성이다.
* `MotionGUID`: JSON에는 애니메이션 클립의 GUID가 들어간다. `AssetDatabase.GUIDToAssetPath`로 경로를 얻어 클립을 불러 `newState.motion`에 넣는다.
* 전환 조건은 `Mode` 문자열(`If`, `IfNot`, `Greater`, `Less`, `Equals`, `NotEqual`)을 `AnimatorConditionMode`로 바꿔 넣는다. 파라미터 타입은 `Float`, `Int`, `Bool`, `Trigger` 문자열을 같은 방식으로 바꾼다.
* JSON 구조: `{ "AnimatorController": { "Name", "Parameters": [{Name, Type}], "Layers": [{Name, States: [{Name, MotionGUID, Transitions: [{DestinationState, HasExitTime, ExitTime, TransitionDuration, Conditions: [{Parameter, Mode, Threshold}]}]}]}] } }`. 코드는 `Layers`의 **첫 번째 레이어만** 처리한다.

## 따라 만들기

1. 원본 GOS의 `ProcessBase`와 노드 몇 개(`Trigger`, `Activate` 등)를 준비한다. 확인 방법: 프로젝트가 컴파일된다.
2. 노드 스크립트를 `Input/`, `Logic/`, `Output/` 같은 폴더로 나눠 둔다. 폴더 이름이 곧 카테고리가 되므로 의미 있는 이름을 쓴다. 확인 방법: 폴더 구조가 Project 창에 보인다.
3. `Editor` 폴더 안에 `VisualScriptingPalette`를 만든다. `EditorWindow`를 상속하고 `[MenuItem]`으로 창을 연다. 확인 방법: 상단 메뉴에 `Visual Scripting/GameObject/Pallete Window`가 나오고 창이 열린다.
4. `RefreshNodeList`를 위 발췌대로 작성하고 `OnEnable`에서 호출한다. 확인 방법: 창에 카테고리 제목과 `➕ 노드이름` 버튼이 보인다. 폴더를 바꾸면 카테고리가 바뀐다.
5. `OnGUI`에 검색 텍스트 필드와 `X` 버튼을 넣고 필터를 연결한다. 확인 방법: "trig"를 입력하면 이름에 Trigger가 든 노드만 남는다.
6. `CreateNode`를 작성한다. 확인 방법: `TriggerEnter` 버튼을 누르면 `BoxCollider`(Is Trigger 켜짐)가 붙은 오브젝트가 선택된 오브젝트 아래에 생기고 `Ctrl+Z`로 취소된다.
7. `ProcessBase`에 `#if UNITY_EDITOR` 블록으로 `ForceExecute()`를 넣고, `Editor` 폴더에 `ProcessBaseEditor`를 만든다. 확인 방법: 아무 노드의 인스펙터 맨 아래에 큰 버튼이 생기고, 누르면 콘솔에 "강제 실행 명령을 받았습니다."가 찍히며 노드가 실행된다.
8. (선택) `AnimatorGenerator`를 만들고 예시 JSON을 붙여 넣는다. 아래는 학습용으로 새로 만든 짧은 예시다(레포의 파일이 아니다).

```json
{ "AnimatorController": { "Name": "Test",
  "Parameters": [ { "Name": "Speed", "Type": "Float" } ],
  "Layers": [ { "Name": "Base", "States": [
    { "Name": "Idle", "MotionGUID": "", "Transitions": [
      { "DestinationState": "Run", "HasExitTime": false, "ExitTime": 0, "TransitionDuration": 0.1,
        "Conditions": [ { "Parameter": "Speed", "Mode": "Greater", "Threshold": 0.1 } ] } ] },
    { "Name": "Run", "MotionGUID": "", "Transitions": [] } ] } ] } }
```

   확인 방법: 메뉴 `Tools/Generate Animator from JSON`에서 출력 경로(기본 `Assets/PlayerAnimator.controller`)를 두고 생성하면 `Idle`과 `Run` 상태, `Speed` 파라미터, 전환 하나가 있는 컨트롤러가 만들어진다.

## 한계·주의

* 팔레트의 카테고리는 폴더 이름이므로 `Input/Trigger/` 안의 노드는 카테고리가 `Trigger`가 된다. 정렬 함수가 이름이 `Input`·`Logic`·`Output`으로 **시작하는** 카테고리만 앞쪽에 두기 때문에, `Trigger`나 `SetActivate`, `Interaction` 같은 카테고리는 모두 맨 뒤(순위 99)에 온다. 코드 읽기에서 나온 결론이다.
* 클래스 이름과 파일 이름이 다르면 경로 검사(`EndsWith("/클래스.cs")`)에 걸리지 않아 `ETC (미분류)`로 분류된다. 이 레포의 `GameTimeAdjust.cs`(클래스는 `GameTimeAdject`)가 해당할 것으로 보인다.
* `Name.Contains("Trigger")`로 `BoxCollider`를 붙이므로 `RaycastTrigger`, `TriggerTimmer`처럼 이름에 Trigger가 들어간 노드는 모두 콜라이더가 붙는다. `RaycastTrigger`는 콜라이더가 필요 없는 노드다.
* 새로고침 버튼은 fd1e5bfa에서 사라졌고 `OnEnable`에서만 목록을 만든다. 스크립트를 추가하면 도메인 리로드로 창이 다시 활성화되겠지만, 폴더만 옮긴 경우는 창을 다시 열어야 할 수 있다(**확인 필요**).
* `EntryClonerEditor.cs`의 내용은 `NewMonoBehaviourScript`라는 빈 `MonoBehaviour`다(`Start`, `Update` 주석만 있다). `UnityEditor`를 쓰지 않으며 `EntryCloner`를 위한 에디터 코드가 아니다. 파일 이름과 클래스 이름이 달라 컴포넌트로 붙이기도 어렵다. 문서 `Docs/GOS_Framework_Analysis.md`는 이를 `EntryCloner` 에디터라고 소개하지만 코드와 맞지 않는다.
* `AnimatorGenerator`는 `RootObject`, `ControllerData` 같은 흔한 이름의 클래스를 전역 네임스페이스에 선언한다. 같은 이름이 다른 곳에 있으면 충돌한다. 또 상태의 `Transitions`와 전환의 `Conditions`는 `null` 검사가 있지만, `Parameters`나 `Layers`가 JSON에 없으면 접근하는 순간 예외가 난다. 예외는 `try/catch`에 잡혀 콘솔 오류로만 남는다.
* 레이어 이름 설정(`baseLayer.name = ...`)이 컨트롤러에 실제로 저장되는지는 확인하지 못했다. `controller.layers`가 복사본을 돌려주기 때문에 반영되지 않을 수 있다(**확인 필요**, unverified).
* 팔레트·버튼 동작은 모두 코드 읽기로 판단했다(unverified).

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `[MenuItem]`을 노드마다 쓰는 방식과 `TypeCache`로 자동 수집하는 방식의 장단점을 내 말로 비교해 보자.
- [ ] 폴더 이름으로 카테고리를 정하는 방식이 편한 경우와 불편한 경우는 언제인가? 내가 만든 프로젝트라면 어떻게 나누겠는가?
- [ ] 인스펙터에 테스트용 버튼을 붙여 본 적이 있는가? 없다면 어떤 컴포넌트에 붙이고 싶은지 적어 보자.
