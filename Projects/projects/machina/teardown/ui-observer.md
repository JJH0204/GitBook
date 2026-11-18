# UI 옵서버 패턴 해체

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-MCH-103-DO |
| 유형 | D&O (소스 해체) |
| 목적 | 시스템 메시지 UI가 정적 이벤트 버스를 구독해 메시지를 받는 구조와, 범용 `EventManager`를 해체한다 |
| 확인 상태 | 미검증 (코드를 읽기만 했고 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="warning" %}
WARNING: 비공개 레포, 접근 권한 필요. 코드는 소스 레포의 git 오브젝트를 읽기 전용으로 읽었다. 조사 당시 설계는 기존 [UI 옵서버 패턴](../rnd/observerpatternforui.md)에 있다.
{% endhint %}

## 1. 이 영역이 하는 일

게임 로직(몬스터 행동 트리 등)이 UI를 직접 참조하지 않고 메시지를 "발행"하면, 켜져 있는 UI가 "구독"해 표시한다. 소스에는 목적이 다른 두 옵서버가 있다.

| 구분 | 파일(`Branch/Assets/_GameAssets/01. Scripts/` 기준) | 성격 |
|---|---|---|
| 시스템 메시지 버스 | `GUI/SystemMessageUI.cs` | 정적 `event Action<SystemMessage>`. 대사 UI 전용 |
| 범용 이벤트 매니저 | `Managers/EventManager.cs` | 이벤트 종류(`EEventType`)별 리스너 딕셔너리. 발신자와 `object` 인자를 전달 |

## 2. 기존 설계 기록과 소스의 차이

| 항목 | 기존 R&D 기록 | 현재 소스 |
|---|---|---|
| 데이터 | `DialogEvent`(화자, 내용, 우선순위, 자동 닫힘) | `SystemMessage`(화자, 내용). 우선순위·자동 닫힘은 주석 처리 |
| 옵서버 | `IDialogObserver` 인터페이스 + `DialogEventChannel`(목록 + 스냅샷) | 인터페이스·채널 클래스 없음. `static event`가 채널 역할 |
| 구독 시점 | `OnEnable`/`OnDisable` 권고(CAUTION) | 실제로 `OnEnable`에서 `+=`, `OnDisable`에서 `-=` |
| 우선순위 | 정렬 가능 | "우선순위가 필요 없어서 정렬은 따로 하지 않는다"(주석) |

## 3. 데이터 흐름

```
BTActionSystemMessage.Evaluate()          (행동 트리 노드, 발행자)
   --> SystemMessageBus.Publish(new SystemMessage{Speaker, Text})
          --> static event OnDialogEvent  (= 채널)
                 --> SystemMessageUI.HandleDialogEvent(e)   (구독자)
                        --> _queue.Add(e); 4개 초과 시 오래된 것 제거
                        --> TryShowSystemMessage() 로 TMP 텍스트 갱신
```

## 4. 핵심 코드 해설

{% code title="GUI/SystemMessageUI.cs (버스와 구독)" %}
```csharp
public static class SystemMessageBus
{
    public static event Action<SystemMessage> OnDialogEvent;
    public static void Publish(SystemMessage e) => OnDialogEvent?.Invoke(e);
}

public class SystemMessageUI : MonoBehaviour
{
    private readonly List<SystemMessage> _queue = new();
    [SerializeField] private TextMeshProUGUI systemMessageText;

    void OnEnable()  => SystemMessageBus.OnDialogEvent += HandleDialogEvent;
    void OnDisable() => SystemMessageBus.OnDialogEvent -= HandleDialogEvent;
}
```
{% endcode %}

- 발행자는 UI 타입을 모르고 `SystemMessageBus.Publish`만 안다. UI는 켜져 있는 동안만 구독하므로 UI가 꺼진 씬에서는 메시지가 버려진다.
- 목록 스냅샷(`ToArray`) 대신 C# `event`를 쓴다. 기존 기록의 NOTE("호출이 잦으면 C# `event`로 바꿀 수 있다")와 같은 방향이며, 배열 할당이 없다.

{% code title="Monster/AI/BehaviorTree/Nodes/LeafNodes/Actions/BTActionSystemMessage.cs (발행)" %}
```csharp
SystemMessageBus.Publish(new SystemMessage
{
    Speaker = string.IsNullOrEmpty(speaker) ? context.Blackboard.Agent.name : speaker,
    Text    = string.IsNullOrEmpty(message) ? <기본 문구> : message
});
return state = NodeState.Success;
```
{% endcode %}

- 행동 트리의 리프 노드가 발행자다. 화자와 문구는 에셋(ScriptableObject)에서 정하고, 비우면 몬스터 이름과 기본 문구를 쓴다.

{% code title="Managers/EventManager.cs (요지)" %}
```csharp
private Dictionary<EEventType, Action<EEventType, Component, object>> listeners = new();

public void AddListener(EEventType t, Action<EEventType, Component, object> a)
{
    if (!listeners.ContainsKey(t)) listeners.Add(t, null);
    listeners[t] -= a;   // 중복 등록 방지
    listeners[t] += a;
}
public void PostNotification(EEventType t, Component sender, object param = null)
{
    if (!listeners.ContainsKey(t)) return;
    listeners[t].Invoke(t, sender, param);
}
```
{% endcode %}

- `-=` 후 `+=`로 같은 리스너의 중복 등록을 막는다.
- 이벤트 종류별로 델리게이트를 하나씩 둔다. `ToString()`이 종류별 리스너 수를 출력해 구독 누수를 점검할 수 있다.
- 비주얼 스크립팅과의 연결(`OnEvent` 입력 노드, `Register` 출력 노드)은 [상호작용 노드](../visual-scripting/interaction-nodes.md)를 본다. `OnEvent` 자체는 `Execute`가 `IsOn = true`만 하는 단순 노드다.

## 5. 따라 만들기

확인 상태: 미검증.

1. 메시지 데이터 클래스(화자, 내용)를 만든다. 기대 결과: `ToString()`이 `화자: 내용`을 반환한다.
2. `static class`에 `event Action<메시지>`와 `Publish`를 둔다. 기대 결과: 구독자가 없어도 `Publish`가 오류 없이 지나간다(`?.Invoke`).
3. UI `MonoBehaviour`가 `OnEnable`에서 구독하고 `OnDisable`에서 해제한다. 기대 결과: UI를 껐다 켜도 중복 구독이 없다.
4. UI는 큐에 쌓고 최근 N개(소스는 4개)만 남겨 텍스트에 표시한다. 기대 결과: 오래된 메시지가 밀려난다.
5. 행동 트리 등 발행 쪽에서 `Publish`를 호출한다. 기대 결과: 발행 쪽이 UI를 참조하지 않는다.
6. 종류별로 나눠야 하면 `EventManager`처럼 열거형 키 딕셔너리를 쓴다. 기대 결과: 이벤트 종류마다 독립 구독이 된다.

## 6. 알려진 한계·주의

{% hint style="warning" %}
CAUTION: 코드를 읽고 찾은 문제이며 실행하지 않았다.
{% endhint %}

- `SystemMessageUI.TryShowSystemMessage`는 `string.Join(systemMessageText.text, dialogEvents)`를 쓴다. 여기서 첫 인자는 구분자이고 `dialogEvents`는 한 메시지를 줄 단위로 나눈 배열이라, 반복마다 현재 메시지만 남는다(구분자 `systemMessageText.text`는 배열 요소가 둘 이상일 때만 끼어든다). 의도(최근 4개를 채팅처럼 나열)대로 누적되지 않을 가능성이 크다. 실행해 확인하지 않았다.
- `static event`는 씬이 바뀌어도 살아 있다. 구독 해제가 빠진 UI가 있으면 파괴된 객체가 남는다. 이 UI는 `OnDisable`에서 해제하므로 해당 문제는 없다.
- `EventManager.Clear()`는 `foreach`로 딕셔너리를 순회하며 `RemoveEvent`로 항목을 지운다. 순회 중 컬렉션 변경이라 예외가 날 수 있다(코드 읽기, 실행 안 함).
- 시스템 메시지의 우선순위와 자동 닫힘은 구현되지 않았다(주석 처리).
- 어떤 UI가 `EventManager`를 구독하는지 전수 확인은 하지 않았다. 소스에서 확인 못함.

## 7. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 최초 작성 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 인터페이스 채널 설계에서 `static event`로 단순화한 이유는 무엇인가?
- [ ] 시스템 메시지 버스와 `EventManager`를 나눠 둔 기준은 무엇인가?
