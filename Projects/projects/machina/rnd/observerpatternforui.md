# UI 옵서버 패턴 (Observer)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-MRD-007-DO |
| 유형 | D&O (설계 기록) |
| 목적 | 대사 UI에 옵서버 패턴을 적용한 이벤트 채널 코드를 기록한다 |
| 확인 상태 | 미검증 (코드를 읽고 정리했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 구성 요소

| 번호 | 구성 요소 | 역할 |
|---|---|---|
| 1 | `DialogEvent` | 대사 데이터. 화자, 내용, 우선순위(0이 높음, 10이 낮음 등), 자동 닫힘 시간(초) |
| 2 | `IDialogObserver` | 대사 이벤트를 받는 쪽이 구현하는 인터페이스 |
| 3 | `DialogEventChannel` | 옵서버를 구독·해제하고 이벤트를 발행한다 |

## 2. 코드

원본의 코드가 한 줄로 합쳐져 있어 줄을 나누었다. 제네릭 형식 인자 `<IDialogObserver>`가 원본에서 빠져 있어 복원했다.

```csharp
public class DialogEvent
{
    public string Speaker;
    public string Text;
    public int Priority;        // 0=높음, 10=낮음 등
    public float AutoCloseSec;
}

public interface IDialogObserver
{
    void OnDialogEvent(DialogEvent e);
}

public class DialogEventChannel
{
    private readonly List<IDialogObserver> _observers = new();

    public void Subscribe(IDialogObserver obs)
    {
        if (!_observers.Contains(obs)) _observers.Add(obs);
    }

    public void Unsubscribe(IDialogObserver obs) => _observers.Remove(obs);

    public void Publish(DialogEvent e)
    {
        // snapshot 후 순회(중간 구독/해제 안전)
        var snapshot = _observers.ToArray();
        foreach (var obs in snapshot) obs.OnDialogEvent(e);
    }
}
```

## 3. 동작 원리

1. 대사를 받을 UI가 `Subscribe`로 채널에 등록한다.
2. 대사를 내보낼 쪽이 `DialogEvent`를 만들어 `Publish`를 호출한다.
3. `Publish`는 옵서버 목록의 복사본을 순회하며 `OnDialogEvent`를 호출한다.
4. 순회 중 옵서버가 구독을 해제하거나 추가해도 복사본이라 목록 변경 오류가 나지 않는다.

{% hint style="warning" %}
CAUTION: 옵서버가 `MonoBehaviour`이면 `OnEnable`에서 `Subscribe`, `OnDisable`(또는 `OnDestroy`)에서 `Unsubscribe`를 호출한다. 해제하지 않으면 파괴된 오브젝트를 채널이 계속 참조해 메모리 누수와 파괴된 오브젝트 접근 오류가 생긴다.
{% endhint %}

{% hint style="info" %}
NOTE: `Publish`마다 `ToArray()`로 배열을 새로 만들어 GC 할당이 생긴다. 호출이 잦으면 재사용 버퍼를 쓰거나, C# `event`/`UnityEvent`로 바꿀 수 있다. `Priority`와 `AutoCloseSec`을 처리하는 코드는 원본에 없다. 코드에는 `using System.Collections.Generic;`가 필요하다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 옵서버(Observer) 패턴 | 상태 변화를 구독자들에게 알리는 설계 패턴 |
| 구독(Subscribe) | 이벤트를 받기 위해 채널에 등록하는 것 |

## 5. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM D&O 형식으로 재작성, 합쳐진 코드 서식과 제네릭 인자 복원 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] UI가 대사를 만드는 쪽을 직접 참조하지 않게 하려고 옵서버 패턴을 고른 이유는 무엇인가?
- [ ] 구독 해제를 빠뜨리면 어떤 문제가 생기는지 겪은 경험이나 예상을 적는다.
