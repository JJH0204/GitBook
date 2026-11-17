# UI 출력 노드

## 무엇을 하는가

UI 출력 노드는 `Conditional` 등에 의해 `Execute()`가 호출되었을 때 화면의 UI를 바꾼다. 이 페이지에서 다루는 노드는 다음과 같다.

| 노드 | 하는 일 |
|---|---|
| `SetNoticeMessage` | 화면에 안내 메시지를 띄운다 (한국어/영어 문자열 선택) |
| `SetObjectText` | 현재 목표 문구를 바꾸고, 대상이 있으면 지시 마커를 켠다 |
| `SetIndicatorTarget` | 지시 마커의 대상을 지정하고 켠다 |
| `ToggleUI` | HUD 루트를 켜거나 끈다 |
| `ToggleInteractionHUD` | 상호작용 안내 UI를 켜거나 끄고 문구를 채운다 |
| `StartBoss` | 보스 이름을 설정하고 보스 체력바를 켠다 |

## 왜 이렇게 설계했나

- 모든 UI 접근은 `GUIManager.Instance.GameUIController` 하나로 모인다. 노드는 UI 오브젝트를 직접 찾지 않고 매니저에 위임하므로, UI 구조가 바뀌어도 노드는 호출부 한 줄만 고치면 된다.
- 문구는 한국어/영어 두 필드를 가지고 `LocalizationManager.IsKorean`으로 고른다. 씬에 직렬화된 문자열이라 기획자가 바로 수정한다.
- 대부분 `if (IsOn) return;`으로 시작해 "한 번만 실행"을 보장한다. 단 `ToggleUI`, `ToggleInteractionHUD`는 이 검사가 없어 여러 번 호출해도 된다.
- 대상의 일부 파일은 이전 UI 관리 코드를 `GameUIController`로 옮기는 커밋(`b312ef9f`)에서 호출 경로가 바뀌었다. 변경분은 매니저 호출 한 줄씩이고 노드 구조는 그대로다.

## 핵심 코드

{% code title="SetObjectText.cs" %}
```csharp
public class SetObjectText : ProcessBase
{
    [SerializeField] private Transform target;
    [SerializeField, TextArea(3, 5)] private string objectDescription;
    [SerializeField, TextArea(3, 5)] private string enObjectDescription;

    public override void Execute()
    {
        if (IsOn) return;

        var ui = Managers.GUIManager.Instance.GameUIController;
        ui.ObjectText.text = LocalizationManager.IsKorean ? objectDescription : enObjectDescription;
        Managers.LocalizationManager.CurrentObjective[0] = objectDescription;
        Managers.LocalizationManager.CurrentObjective[1] = enObjectDescription;

        if (target)
        {
            ui.SetIndicatorTarget(target);
            ui.SetIndicator(true);
        }
        IsOn = true;
    }
}
```
{% endcode %}

(원본은 `GameUIController`를 매번 풀어 쓴다. 가독성을 위해 지역 변수로 줄였다.)

- `TextArea(3, 5)`는 인스펙터에서 여러 줄 입력칸을 만든다.
- 문구를 화면에 반영한 뒤 `CurrentObjective[0]`, `[1]`에 한국어/영어 문구를 저장한다. 언어를 바꿀 때 목표 문구를 다시 그리기 위한 값으로 보인다. (용도는 코드 이름에서 추정한 것이다.)
- `target`이 지정되어 있으면 지시 마커를 켠다. 목표 문구와 마커를 한 노드에서 같이 다룬다.

{% code title="ToggleInteractionHUD.cs" %}
```csharp
public class ToggleInteractionHUD : ProcessBase
{
    [SerializeField] private bool isActivate;
    [SerializeField] private string interactionName;

    public override void Execute()
    {
        var ui = Managers.GUIManager.Instance.GameUIController;
        ui.InteractionUI.SetActive(isActivate);
        if (isActivate)
            ui.InteractionText.text = LocalizationManager.GetLocalizedString(interactionName);
    }
}
```
{% endcode %}

- 이 노드는 `IsOn` 검사가 없다. 같은 오브젝트가 구역 진입(켜기)과 이탈(끄기)에 번갈아 쓰이도록, `isActivate`가 서로 다른 노드 두 개를 만들어 쓰는 방식이다. (이 사용 방식은 필드 구성에서 추정한 것이다.)
- `interactionName`은 문구 자체가 아니라 현지화 키로 보이며, `GetLocalizedString`이 해당 언어 문자열을 돌려준다.

`SetNoticeMessage`는 `ActivateMessage(string)` 한 줄, `SetIndicatorTarget`은 `SetIndicatorTarget(target)`과 `SetIndicator(true)` 두 줄, `ToggleUI`는 `HUD.SetActive(isActivate)` 한 줄이 본문이다. `StartBoss`는 `SetBossName`과 `ToggleBossHp(true)`를 호출한다.

## 따라 만들기

1. 자신의 UI 매니저에 `ActivateMessage(string)`, `SetIndicator(bool)`, `SetIndicatorTarget(Transform)`, `HUD`(GameObject), `ObjectText`(TMP_Text)를 노출하는 `GameUIController`를 만든다. 매니저는 `Instance` 싱글턴으로 접근하게 한다.
   - 확인 방법: 테스트 스크립트에서 `GUIManager.Instance.GameUIController.ActivateMessage("test")`를 호출하면 메시지가 뜬다.
2. `SetNoticeMessage`를 작성한다. 확인 방법: `Conditional`의 출력에 넣고 입력을 켜면 메시지가 한 번만 뜨고, 다시 켜도 뜨지 않는다.
3. `ToggleUI`를 작성한다. 확인 방법: `isActivate`를 `false`로 둔 노드가 실행되면 HUD가 사라진다.
4. `SetObjectText`와 `SetIndicatorTarget`을 작성한다. 확인 방법: `target`을 비워 두면 문구만 바뀌고, 지정하면 마커도 켜진다.
5. (선택) 현지화가 필요하면 `IsKorean` 플래그로 두 문자열 중 하나를 고르는 정적 클래스를 만든다. 확인 방법: 플래그를 바꿔 다시 실행하면 다른 언어가 나온다.

## 막히기 쉬운 곳과 한계

- 매니저 싱글턴이 아직 만들어지지 않은 시점에 `Execute`가 호출되면 `NullReferenceException`이 난다. 씬 로딩 순서에 주의해야 한다. 원본은 `Persistent` 씬을 따로 두고 초기화하는 구조로 보인다. (확인 필요)
- `StartBoss`는 `enBossName`이 빈 문자열이 기본값이라 영어 이름을 채우지 않으면 영어 모드에서 이름이 비어 보인다.
- 문자열을 씬에 직렬화하는 방식은 번역 파일 관리가 불편하다. 현지화 키 방식인 `ToggleInteractionHUD`와 섞여 있어 일관성이 없다.
- `IsOn` 검사가 있는 노드는 한 번 실행되면 오브젝트를 껐다 켜기 전에는 다시 동작하지 않는다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 노드가 UI 오브젝트를 직접 참조하지 않고 매니저를 거치게 한 설계가 어떤 점에서 유리했는지 적어 보자.
- [ ] 같은 UI 노드를 여러 번 실행해야 할 때 `if (IsOn) return;` 가드를 어떻게 다루는 것이 좋을까? 내 생각을 적어 보자.
- [ ] 다국어 문구를 직렬화 문자열로 둘지 키로 둘지 고민해 본 경험이 있는가?
