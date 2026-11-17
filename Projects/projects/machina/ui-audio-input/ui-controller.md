# UI 컨트롤러 분리 (GUIManager → GameUIController)

## 무엇을 하는가

`GameUIController`는 게임 중 화면에 보이는 모든 HUD를 갱신한다. HP 바, 좌우 탄약 슬라이더, 스킬 쿨다운, 라디얼(파츠 선택) 메뉴, 알림 메시지, 보스 HP, 인디케이터, 페이드 인/아웃, 일시정지·도움말·옵션 패널, 게임패드 진동이 모두 이 한 클래스의 공개 메서드다. 다른 스크립트는 `GUIManager.Instance.GameUIController.SetHpSlider(...)`처럼 접근한다.

## 왜 이렇게 설계했나

커밋 `836e87fe`(2025-12-09)가 분기점이다. 변경량은 `GUIManager.cs`가 +81/-996, 새 `GameUIController.cs`가 +1034다. 이전 `GUIManager`는 `[SerializeField]` 필드 수십 개와 HUD 메서드를 전부 가진 파일이었고, 이후 두 클래스로 나뉘었다.

| 구분 | 이전 `GUIManager` | 이후 |
| --- | --- | --- |
| 역할 | HUD 필드, 갱신 코드 전부 | `GUIManager`: UI 인스턴스 보관과 전환 |
| | | `GameUIController`: HUD 갱신 |
| UI 연결 | 씬에 놓인 하나의 오브젝트에 인스펙터로 연결 | `InitUI`가 프리팹을 생성해 사전으로 전달 |
| 호출 | `GUIManager.Instance.OnGameOverPanel()` | `GUIManager.Instance.GameUIController.OnGameOverPanel()` |

이유는 코드에서 다음처럼 읽힌다(추론).

- 타이틀·프롤로그·에필로그·로딩·크레딧까지 화면 종류가 늘면서, "게임 중 HUD"를 갖는 클래스와 "어떤 화면을 켤지" 정하는 클래스를 분리할 필요가 생겼다.
- 플랫폼별 HUD 프리팹이 따로 있다(`GameUIController_Windows`, `GameUIController_Android`, 이전 구조는 `_Old`). 필드가 전부 프리팹 안에 있으면 프리팹만 갈아 끼워 플랫폼을 바꿀 수 있다.
- 호출부는 같은 날 이어진 커밋 `79ca56c1`(플레이어 파츠, 카메라, 미니맵 등 약 30개 파일), `b312ef9f`(비주얼 스크립팅 출력 노드)에서 일괄 치환됐다. 메서드 이름은 그대로 두고 앞의 접근 경로만 바꾼 변경이어서 파일당 변경량이 작다.

원래 코드에 `// 꽤 급하게 작업하였으므로 리팩토링 필요`라는 주석이 라디얼 UI 구간에 남아 있다. 이 리팩터링은 구조를 나눴을 뿐 라디얼 로직 자체는 정리하지 않았다.

## 핵심 코드

{% code title="GameUIController.cs (발췌)" %}
```csharp
namespace Managers
{
    public class GameUIController : MonoBehaviour
    {
        [Header("UI")]
        [SerializeField] private GameObject GUI;
        [SerializeField] private Image fadeInOutPanel;
        [SerializeField] private Slider testHpBar;
        [SerializeField] private TextMeshProUGUI playerHpText;
        private Coroutine _runningFadeCoroutine;

        public GameObject HUD { get => GUI; set => GUI = value; }

        public void SetHpSlider(float currentHealth, float maxHealth)
        {
            float rate = currentHealth / maxHealth;
            testHpBar.value = rate;
            playerHpText.text = string.Format("{0:F0} / {1:F0}", currentHealth, maxHealth);
        }

        public void FadeTo(float targetAlpha, float duration = 1.0f)
        {
            if (_runningFadeCoroutine != null)
                StopCoroutine(_runningFadeCoroutine);
            _runningFadeCoroutine = StartCoroutine(
                CoroutineFadeInOut(fadeInOutPanel.color.a, targetAlpha, duration));
        }
    }
}
```
{% endcode %}

줄 단위 설명이다.

- `namespace Managers`: 매니저류와 같은 네임스페이스에 둬서 `GUIManager`가 `using` 없이 참조한다.
- `[SerializeField] private ...`: 모든 UI 참조는 프리팹 안에서 인스펙터로 연결한다. 코드에서 `Find`로 찾지 않는다.
- `HUD` 프로퍼티: 외부에는 `GUI` 오브젝트를 읽기·쓰기 프로퍼티로 노출한다. 일시정지나 도움말이 HUD를 껐다 켤 때 쓴다.
- `SetHpSlider`: 비율(0~1)을 슬라이더에, `{0:F0} / {1:F0}` 형식의 문자열을 텍스트에 넣는다. 최대 체력이 0이면 나눗셈 보호가 없다.
- `FadeTo`: 이미 돌고 있는 코루틴을 멈추고 새로 시작한다. 페이드 중 다른 페이드가 호출돼도 알파값이 서로 싸우지 않게 하는 기본 패턴이다. 시작값은 현재 알파라서 중간에 끊겨도 튀지 않는다.

{% code title="GameUIController.cs (알림 메시지 호출 패턴)" %}
```csharp
public void ActivateMessage(string message, float activeTime = 5.0f)
{
    if (_messageRoutine != null)
    {
        StopCoroutine(_messageRoutine);
        _messageRoutine = null;
        // 알파 0으로 초기화하고 숨김
        messageObject.SetActive(false);
    }

    messageText.text = message;
    _messageRoutine = StartCoroutine(CoActivateMessage(activeTime));
}
```
{% endcode %}

알림은 "이전 알림을 끊고 새로 시작"하는 같은 패턴이다. 코루틴 안에서 1초 페이드 인, `activeTime` 유지, 1초 페이드 아웃을 거친다.

## 따라 만들기 단계

1. 빈 프로젝트에 TextMeshPro와 uGUI를 준비하고 `Canvas` 안에 HP `Slider`, HP `TextMeshPro`, 전체 화면 검은 `Image`(페이드용)를 만든다. 확인 방법: 씬 뷰에서 세 요소가 보이고 `Image`의 알파를 0으로 둘 수 있다.
2. `GameUIController` 스크립트를 만들어 위 세 요소를 `[SerializeField]`로 선언하고 `SetHpSlider`, `FadeTo`를 구현한다. 확인 방법: 컴파일 후 인스펙터에 세 슬롯이 보이고, 빈 슬롯 없이 연결할 수 있다.
3. Canvas 루트를 프리팹 `GameUIController.prefab`으로 저장한다. 확인 방법: 프로젝트 창에 프리팹이 생기고 씬의 인스턴스는 지워도 된다.
4. 싱글톤 `GUIManager`를 만들고 `public GameUIController GameUIController { get; private set; }`를 둔다. 값 주입은 [UI 초기화와 화면 전환](ui-init-flow.md)에서 한다. 확인 방법: 다른 스크립트에서 `GUIManager.Instance.GameUIController.SetHpSlider(50, 100)`이 컴파일된다.
5. 임시 테스트 스크립트에서 시작 시 `FadeTo(0, 1f)`와 HP 갱신을 호출한다. 확인 방법: 플레이 시 HP 바가 절반으로 차 있고 검은 화면이 1초에 걸쳐 사라진다.
6. 플랫폼별 HUD가 필요하면 프리팹을 복제해 `_Windows`, `_Android`로 나누고 같은 `GameUIController` 컴포넌트를 둔다. 확인 방법: 두 프리팹 모두 필드 연결에 빈 슬롯이 없다.

## 막히기 쉬운 곳과 한계

- 프리팹 안의 참조 하나가 비면 `Awake`나 첫 호출에서 `NullReferenceException`이 난다. `Awake`는 `messageImage.color`를 바로 읽으므로 알림 이미지 슬롯이 비면 시작 시점에 터진다.
- 한 클래스가 약 1170줄이다. 분리했지만 HUD 전체가 한 파일에 남아 있어, 라디얼·알림·보스 UI를 더 쪼갤 여지가 크다.
- `SetLeftPartText` 등은 본문이 주석 처리된 빈 메서드다. 이전 테스트 UI의 흔적이며 호출부 호환을 위해 남긴 것으로 보인다(추론).
- `CoActivateMessage`는 `_originalMessageTextColor.a`를 0으로 바꾸는데(`startTextColor`가 아니라 원본 필드), 이후 호출에서 텍스트 알파 기준값이 오염될 수 있다. 코드를 읽은 판단이며 실행해 확인하지 않았다.
- `GUIManager` 쪽에는 다른 스크립트가 새 공개 멤버를 다시 얹기 쉽다. 분리 효과를 유지하려면 "HUD 갱신은 컨트롤러" 규칙을 팀이 지켜야 한다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `GUIManager`를 둘로 나눴을 때 호출하는 쪽 코드는 어떻게 달라졌는가? 직접 겪은 불편(또는 이득)을 적어 보자.
- [ ] 한 코루틴 핸들(`_runningFadeCoroutine`)을 필드로 들고 `StopCoroutine`하는 이유를, 이를 안 했을 때 생길 일과 함께 설명해 보자.
- [ ] 플랫폼마다 HUD 프리팹을 따로 둔 선택의 장단점은 무엇인가?
