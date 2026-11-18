# 에디터 메뉴: Hierarchy 우클릭으로 노드 만들기

## 무엇을 하는가

`VisualScriptingEditor` 클래스는 Hierarchy 창에서 우클릭했을 때 나오는 `VisualScripting` 메뉴를 만든다. 항목을 누르면 해당 노드 컴포넌트가 붙은 빈 게임 오브젝트가 생기고, 선택된 오브젝트가 있으면 그 자식으로 들어간다.

## 왜 이렇게 설계했나

- 기획자가 "빈 오브젝트 만들기 → Add Component → 노드 이름 검색" 과정을 거치지 않고 한 번에 노드를 만들게 한다.
- 메뉴 경로를 `GameObject/` 로 시작하면 Hierarchy 우클릭 메뉴와 상단 GameObject 메뉴 양쪽에 나온다. 코드 주석도 이 규칙을 적고 있다.
- 트리거 계열은 `BoxCollider`를 붙이고 `isTrigger`를 켜 주어, 만들자마자 감지 영역으로 쓸 수 있다.
- `Undo.RegisterCreatedObjectUndo`로 실행 취소(Ctrl+Z)를 지원하고, `Selection.activeObject`로 만든 오브젝트를 바로 선택해 인스펙터에서 편집하게 한다.

## 핵심 코드 발췌

{% code title="VisualScripting/Editor/VisualScriptingEditor.cs" %}
```csharp
using UnityEditor;
using UnityEngine;

namespace _Project.Scripts.VisualScripting.Editor
{
    public class VisualScriptingEditor
    {
        [MenuItem("GameObject/VisualScripting/Input/TriggerEnter", false, 10)]
        private static void CreateTriggerEnterAsset(MenuCommand menuCommand)
        {
            GameObject go = new GameObject("NewTriggerEnter");
            go.AddComponent<TriggerEnter>();
            go.AddComponent<BoxCollider>();

            // BoxCollider를 Trigger로 설정한다.
            go.GetComponent<BoxCollider>().isTrigger = true;

            // 선택된 오브젝트가 있으면 그 자식으로 만든다.
            GameObjectUtility.SetParentAndAlign(go, menuCommand.context as GameObject);

            // Undo 등록 및 선택
            Undo.RegisterCreatedObjectUndo(go, "Create " + go.name);
            Selection.activeObject = go;
        }
    }
}
```
{% endcode %}

줄 단위 설명은 다음과 같다.

- `using UnityEditor`: 에디터 전용 API다. 이 파일은 반드시 `Editor`라는 이름의 폴더 안에 있어야 빌드에서 제외된다.
- `[MenuItem(경로, false, 10)]`: 두 번째 인자 `false`는 "검증 함수가 아님", 세 번째 `10`은 메뉴 정렬 우선순위다. 모든 항목이 10이라 같은 묶음으로 나온다.
- `static void ...(MenuCommand menuCommand)`: 메뉴 항목 함수는 static이어야 한다. `menuCommand.context`는 우클릭한 오브젝트다.
- `new GameObject("NewTriggerEnter")` 이후 `AddComponent<TriggerEnter>()`: 노드를 컴포넌트로 붙인다.
- `SetParentAndAlign`: 우클릭한 오브젝트 아래로 넣고 위치·회전을 맞춘다. 아무것도 없는 곳에서 우클릭하면 `context`가 null이므로 루트에 생성된다.
- `Undo.RegisterCreatedObjectUndo`와 `Selection.activeObject`: 실행 취소 등록과 선택.

코드에서 확인한 메뉴 항목은 다음과 같다.

| 메뉴 경로 | 만들어지는 노드 | 이름 | 비고 |
|---|---|---|---|
| Input/Trigger | Trigger + BoxCollider(트리거) | NewTrigger | |
| Input/TriggerEnter | TriggerEnter + BoxCollider(트리거) | NewTriggerEnter | |
| Input/TriggerExit | TriggerExit + BoxCollider(트리거) | NewTriggerEnter | 이름이 Enter로 되어 있음 |
| Input/Timer | Timer | NewTimer | |
| Input/OnEvent | OnEvent | NewEvent | |
| Process/IsDestroy | IsDestroy | NewIsDestroy | 입력 노드지만 Process 아래 |
| Process/LogicalOperation | Logic | NewLogic | |
| Process/Conditional | Conditional | NewConditional | |
| Output/Activate, Deactivate, ToggleActivate | 각 노드 | NewActivate 등 | |
| Output/Cutscene | CameraControl | NewCutscene | |
| Output/Instance | Instance | NewInstance | |
| Output/Move | MoveObject | NewMove | |
| Output/Rotate | RotateObject | NewRotateObject | |
| Output/PlayAnimation | PlayAnimation | NewPlayAnimation | |
| Output/Register, Unregister | 각 노드 | NewRegister 등 | 동작 코드가 주석 처리됨 |

메뉴가 없는 노드는 `Destroy`, `ForLoop`, `WhileLoop`이다. 이들은 빈 오브젝트에 Add Component로 붙인다. 예제 씬에 `NewDestroy`라는 이름의 오브젝트가 있어 직접 붙여 쓴 흔적이 보인다.

## 따라 만들기

1. `Assets/Scripts/VisualScripting/Editor` 폴더를 만든다. 폴더 이름이 정확히 `Editor`여야 한다.
   - 확인 방법: Project 창에서 폴더가 보인다.
2. `VisualScriptingEditor.cs`를 만들고 위 발췌의 메뉴 항목 하나를 입력한다. 아직 `TriggerEnter` 클래스가 없다면 [input-nodes.md](input-nodes.md)에서 먼저 만든다. 임시로 `OnEvent`를 쓰고 `BoxCollider` 줄을 빼도 된다.
   - 확인 방법: 컴파일 오류가 없다.
3. Hierarchy 빈 곳을 우클릭한다.
   - 확인 방법: `VisualScripting > Input > ...` 메뉴가 보인다. 메뉴가 안 보이면 스크립트가 컴파일되지 않았거나 Editor 폴더 밖에 있는 것이다.
4. 메뉴 항목을 눌러 오브젝트를 만들고 Ctrl+Z로 취소해 본다.
   - 확인 방법: 오브젝트가 생기고 인스펙터에 노드 컴포넌트가 보이며, Ctrl+Z로 사라진다.
5. 부모 오브젝트를 선택한 상태에서 우클릭해 만든다.
   - 확인 방법: 새 오브젝트가 선택한 오브젝트의 자식으로 들어간다.
6. 나머지 노드를 같은 방식으로 추가한다. 같은 패턴이 20번 가까이 반복되므로, 직접 만들 때는 "이름과 컴포넌트 타입을 받아 생성하는 도우미 함수"로 묶는 편이 낫다.

## 막히기 쉬운 곳·한계

- 같은 코드 블록이 항목마다 복사되어 있어 길이가 284줄이다. 노드를 추가할 때마다 복사해야 하고, 그 과정에서 `TriggerExit`의 오브젝트 이름이 `NewTriggerEnter`로 남은 것 같은 실수가 생긴다.
- 메뉴 분류와 README의 분류가 다르다(`IsDestroy`가 Process 아래).
- `Destroy`, `ForLoop`, `WhileLoop`은 메뉴가 없다.
- `Editor` 폴더를 `Editor`가 아닌 이름으로 두면 `UnityEditor` 참조 때문에 빌드가 실패한다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 우클릭 메뉴로 노드를 만드는 방식이 Add Component 방식보다 기획자에게 나은 점을 내 말로 적어 보자.
- [ ] 반복되는 메뉴 코드를 줄이려면 어떻게 정리하겠는가? 내 생각을 적어 보자.
- [ ] 직접 따라 만들면서 메뉴가 나타나지 않았던 경험이 있다면 원인과 해결 과정을 적어 보자.
