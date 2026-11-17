# 상호작용 노드: Register와 Unregister

## 무엇을 하는가

`Register`는 "플레이어가 상호작용 키를 누르면 연결된 입력 노드를 실행한다"는 구독을 만든다. `Unregister`는 그 구독을 해제한다. 이 둘과 `OnEvent` 입력 노드가 합쳐져 "구역에 들어가 안내가 뜨고, 키를 누르면 문이 열린다" 같은 흐름이 만들어진다.

## 왜 이렇게 설계했나

- 노드 체계는 기본이 "상태를 폴링"하는 구조라서, 키 입력처럼 한 번 일어나는 사건을 그대로 표현하기 어렵다. 그래서 전역 `EventManager`의 이벤트를 `OnEvent` 입력 노드로 되돌려 보낸다.
- 원본 주석이 이 구조를 한 줄로 요약한다. `Input → Output(Register) → Input(OnEvent) → Output`.
- 구독 대상은 노드 자신이 아니라 `EventManager`다. 플레이어 컨트롤러는 노드 체계를 몰라도 되고, 키를 누를 때 이벤트만 알린다.

## 핵심 코드

{% code title="Register.cs" %}
```csharp
public class Register : ProcessBase
{
    [SerializeField] private ProcessBase nextInput;

    public override void Execute()
    {
        IsOn = true;
        EventManager.Instance.AddListener(EEventType.Interaction, OnRegister);
    }

    private void OnRegister(EEventType eventType, Component sender, object param = null)
    {
        nextInput.Execute();
    }
}
```
{% endcode %}

{% code title="Unregister.cs (발췌)" %}
```csharp
public override void Execute()
{
    IsOn = true;
    EventManager.Instance.RemoveEvent(EEventType.Interaction);
}
```
{% endcode %}

{% code title="OnEvent.cs" %}
```csharp
public class OnEvent : ProcessBase
{
    public override void Execute()
    {
        IsOn = true;
    }
}
```
{% endcode %}

- `nextInput`은 보통 `OnEvent`다. `Register`가 "이 입력 노드를 나중에 깨워 달라"고 이벤트 매니저에 맡기는 셈이다.
- `Execute`는 구독만 걸고, 실제 `nextInput.Execute()`는 `OnRegister` 콜백 안에서 키 입력 시점에 일어난다.
- `OnEvent.Execute`는 `IsOn`을 `true`로 만든다. 그 뒤 `Conditional`이 이를 읽어 출력을 실행한다.
- 이벤트를 알리는 쪽은 플레이어 컨트롤러다. 상호작용 입력이 `started`일 때 `EventManager.Instance.PostNotification(EEventType.Interaction, this, null)`을 호출한다. (이 코드는 이 영역 밖이며 호출 지점만 확인했다.)
- `EventManager`는 `Action<EEventType, Component, object>` 딕셔너리다. `AddListener`는 `-=` 후 `+=`로 중복 등록을 막는다.
- `Unregister`는 특정 리스너가 아니라 `Interaction` 이벤트 전체를 `RemoveEvent`로 지운다. `nextInput` 필드는 선언만 있고 쓰이지 않는다.

연결 예시는 다음과 같다. (구성 방식은 코드에서 읽은 것이며 실제 씬 구성은 확인하지 못했다.)

```
Trigger(구역 진입) ─> Conditional ─┬─> ToggleInteractionHUD(isActivate=true)
                                  └─> Register(nextInput=OnEvent)

OnEvent ─> Conditional ─┬─> (문 열기 등 출력 노드)
                        └─> Unregister
```

## 따라 만들기

1. `EEventType` 열거형(`Interaction` 포함)과 `EventManager`를 만든다. 딕셔너리, `AddListener`, `RemoveEvent`, `PostNotification`만 있으면 된다.
   - 확인 방법: 테스트 스크립트에서 `AddListener` 후 `PostNotification`을 호출하면 콜백이 불린다.
2. 플레이어 입력 스크립트에서 상호작용 키가 눌릴 때 `PostNotification(EEventType.Interaction, this)`를 호출한다.
   - 확인 방법: 리스너가 없을 때 키를 눌러도 오류가 나지 않는다. `PostNotification`이 키 존재 여부를 먼저 검사한다.
3. `OnEvent`, `Register`, `Unregister`를 작성한다. `Register.nextInput`에 `OnEvent`를 넣는다.
   - 확인 방법: `Register`를 실행한 뒤 키를 누르면 `OnEvent`의 `Is On`이 켜진다.
4. [ProcessBase와 연결 규칙](process-base.md)의 `Conditional`로 `OnEvent`를 입력, 간단한 출력 노드(예: 문 비활성화)를 출력으로 연결한다.
   - 확인 방법: 키를 누르면 출력이 한 번 실행된다.
5. `Unregister`를 같은 `Conditional` 출력에 추가한다.
   - 확인 방법: 이후 키를 눌러도 `OnEvent`가 더 이상 반응하지 않는다.

## 막히기 쉬운 곳과 한계

- `OnEvent`는 한 번 켜지면 끌 방법이 노드 안에 없다. `OnEnable`에서 초기화되는 것에 의존한다.
- 같은 `EEventType.Interaction`을 쓰는 `Register`가 씬 곳곳에 있을 때, 키를 한 번 누르면 **등록된 모든 `OnEvent`가 동시에** 켜진다. 구역을 벗어날 때 반드시 `Unregister`로 정리해야 한다. 정리하지 않으면 다른 구역에서도 반응한다. (코드 읽기, unverified)
- `Unregister`가 모든 리스너를 지우므로 다른 구역의 `Register`도 함께 사라진다.
- `Register.OnRegister`는 `nextInput`이 비어 있으면 `NullReferenceException`이 난다.
- 씬이 전환될 때 `EventManager`는 싱글턴이라 리스너가 남는다. 파괴된 노드를 가리키는 콜백이 불리면 오류가 날 수 있다. 원본에는 `Clear()`가 있으나 호출 시점은 확인하지 못했다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 폴링 방식 노드 체계에서 "키 입력" 같은 일회성 사건을 다루기 위해 이벤트 매니저를 거치게 한 이유를 내 말로 설명해 보자.
- [ ] `Unregister`가 이벤트 전체를 지우는 방식에서 생길 수 있는 문제를 내가 겪어 본 비슷한 사례와 함께 적어 보자.
