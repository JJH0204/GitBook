# 입력 노드: 조건을 감지해 IsOn을 켠다

## 무엇을 하는가

입력 노드는 게임 안에서 일어난 일(트리거 진입, 시간 경과, 오브젝트 파괴)을 감지해 자신의 `IsOn`을 켜거나 끈다. 입력 노드는 출력을 직접 실행하지 않는다. 켜진 상태를 `Conditional`, `Logic` 같은 처리 노드가 읽어 간다.

| 노드 | 켜지는 조건 | 꺼지는 조건 |
|---|---|---|
| `Trigger` | 지정 태그가 트리거 안에 들어옴 | 그 태그가 트리거 밖으로 나감 |
| `TriggerEnter` | 위와 같음 | 위와 같음 |
| `TriggerExit` | 지정 태그가 트리거 밖으로 나감 | 그 태그가 다시 들어옴 |
| `Timer` | `Execute()`가 불린 뒤 지정 초가 지남 | 꺼지지 않음 |
| `IsDestroy` | 등록한 오브젝트가 파괴됨 | 꺼지지 않음 |
| `OnEvent` | `Execute()`가 불림 | 꺼지지 않음 |

## 왜 이렇게 설계했나

- 유니티의 충돌 콜백(`OnTriggerEnter`, `OnTriggerExit`)을 노드 안에 가려 두어, 기획자는 태그 문자열만 넣으면 된다.
- 입력을 "순간 신호"가 아니라 "상태(IsOn)"로 두었다. 상태로 두면 `Logic`의 And/Or 계산, `isNot` 반전, 여러 노드에서 같은 입력 재사용이 쉬워진다.
- `IsDestroy`는 파괴를 알려 주는 `GlobalGameObject` 컴포넌트와 짝을 이룬다. 유니티는 오브젝트가 파괴될 때 외부에 알리는 기능을 직접 주지 않으므로 `OnDestroy()`를 이용한 표식 컴포넌트를 둔 것이다.

## 핵심 코드 발췌

{% code title="VisualScripting/Input/Trigger/TriggerEnter.cs" %}
```csharp
public class TriggerEnter : ProcessBase
{
    [SerializeField] private string selectedTag = "";

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag(selectedTag))
            IsOn = true;
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag(selectedTag))
            IsOn = false;
    }

    public override void Execute()
    {
        IsOn = true;
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.blue;
        Gizmos.matrix = transform.localToWorldMatrix;
        Gizmos.DrawWireCube(Vector3.zero, Vector3.one);
    }
}
```
{% endcode %}

- `selectedTag`: 인스펙터에서 입력하는 태그 이름. 이 태그를 가진 콜라이더만 반응한다.
- `OnTriggerEnter/Exit`: 유니티가 트리거 콜라이더에 다른 콜라이더가 들어오고 나갈 때 부르는 함수다.
- `Execute()`: 다른 노드가 이 노드를 호출하면 강제로 켠다.
- `OnDrawGizmos`: Scene 창에서 노드 크기만큼 파란 와이어 박스를 그려 영역을 보여 준다.
- 코드 주석에 `// Execute();`가 남아 있다. 예전에는 진입 시 `Execute()`를 호출하는 구조였다가 상태 방식으로 바뀐 흔적이다.

{% code title="VisualScripting/Input/Timer.cs" %}
```csharp
public class Timer : ProcessBase
{
    [SerializeField] private float seconds;

    public override void Execute()
    {
        StartCoroutine(WaitForSeconds());
    }

    private IEnumerator WaitForSeconds()
    {
        yield return new WaitForSeconds(seconds);
        IsOn = true;
    }
}
```
{% endcode %}

- `Timer`는 스스로 시작하지 않는다. 누군가 `Execute()`를 불러야 `seconds` 초 뒤에 켜진다. 보통 `Conditional`의 출력 목록에 넣어 시작시킨다.
- 한 번 켜진 뒤 다시 꺼지는 코드가 없다.

{% code title="VisualScripting/Input/IsDestroy.cs, GlobalGameObject.cs" %}
```csharp
public class GlobalGameObject : MonoBehaviour
{
    public event Action OnObjectDestroyed;

    private void OnDestroy()
    {
        OnObjectDestroyed?.Invoke();
    }
}

public class IsDestroy : ProcessBase
{
    [SerializeField] private List<GlobalGameObject> cach;
    private int _count;

    private void Start()
    {
        if (cach.Count <= 0) return;
        foreach (var item in cach)
        {
            if (item is null) continue;
            item.OnObjectDestroyed += Execute;
        }
    }

    public void AddObject(GlobalGameObject obj)
    {
        obj.OnObjectDestroyed += Execute;
        cach.Add(obj);
        _count++;
    }

    public override void Execute()
    {
        if (IsOn) return;
        _count--;
        if (_count <= 0)
            IsOn = true;
    }
}
```
{% endcode %}

- `GlobalGameObject`: 파괴되는 순간 `OnObjectDestroyed` 이벤트를 발생시킨다. GOS가 감시할 오브젝트에 컴포넌트로 붙인다.
- `IsDestroy.Start`: 인스펙터에 등록한 `cach` 목록의 오브젝트마다 이벤트를 구독한다. 파괴되면 `Execute`가 불린다.
- `AddObject`: 실행 중에 생긴 오브젝트(`Instance` 노드가 만든 것)를 등록할 때 쓴다. 이때만 `_count`가 올라간다.
- `Execute`: 파괴가 일어날 때마다 `_count`를 줄이고, 0 이하가 되면 켠다.

## 따라 만들기

1. [process-base.md](process-base.md)를 마친 상태에서 `OnEvent.cs`를 만든다. 본체는 `Execute()`에서 `IsOn = true`만 하는 한 줄이다.
   - 확인 방법: 빈 오브젝트에 붙이고 Play. 인스펙터의 Is On 체크박스를 직접 눌러 바뀌는지 본다(직접 `Execute`를 부르는 방법은 [logic-nodes.md](logic-nodes.md)에서 확인).
2. `TriggerEnter.cs`를 만든다. 오브젝트에 BoxCollider를 붙이고 Is Trigger를 켠다. `Player` 태그를 가진 캡슐에 Rigidbody를 붙여 둔다.
   - 확인 방법: Play 중 캡슐을 Scene 창에서 상자 안으로 옮기면 Is On이 켜지고, 나오면 꺼진다.
3. `TriggerExit.cs`를 만든다. 진입·탈출 로직만 반대다.
   - 확인 방법: 상자를 나갔을 때 Is On이 켜진다.
4. `Trigger.cs`를 만든다. `TriggerEnter`와 감지 로직은 같고 `Execute()`가 토글(`IsOn = !IsOn`)이라는 점만 다르다.
   - 확인 방법: 진입하면 켜지고 나가면 꺼진다.
5. `Timer.cs`를 만든다. `Execute()`를 부르는 노드가 아직 없으므로, 임시로 `[ContextMenu("Run")]`을 단 함수를 만들어 인스펙터 우클릭으로 `Execute()`를 부르는 방법이 있다.
   - 확인 방법: 설정한 초가 지나면 Is On이 켜진다.
6. `GlobalGameObject.cs`와 `IsDestroy.cs`를 만든다. 감시할 큐브에 `GlobalGameObject`를 붙이고, `IsDestroy`의 `Cach` 목록에 등록한다. 큐브를 Hierarchy에서 Play 중 삭제한다.
   - 확인 방법: 큐브를 삭제하면 `IsDestroy`의 Is On이 켜진다. 콘솔에 `IsDestroy called`와 `... is Destroy` 로그가 찍힌다.

## 막히기 쉬운 곳·한계

- 트리거 이벤트는 두 오브젝트 중 하나에 Rigidbody가 있어야 발생한다. 태그를 입력했는데도 반응하지 않으면 Rigidbody와 `Is Trigger` 체크, 태그 철자를 확인한다.
- `selectedTag`의 기본값은 빈 문자열이다. 태그를 비워 두거나 정의되지 않은 태그를 쓰면 `CompareTag`가 오류를 낼 수 있다(unverified).
- `Trigger`와 `TriggerEnter`는 감지 로직이 같다. 둘의 차이는 `Execute()` 동작뿐이며, README의 "Trigger = 트리거 상주(Stay)"는 "안에 있는 동안 켜짐"으로 이해하면 된다.
- `TriggerEnter`는 "들어온 순간"이 아니라 "안에 있는 동안" true다. 한 번만 실행하게 하려면 `Conditional`이 켜지는 순간만 감지하는 성질을 이용한다.
- 같은 태그를 가진 콜라이더가 둘 이상일 때, 하나가 나가면 안에 다른 하나가 남아 있어도 꺼진다.
- `Timer`는 한 번 켜지면 다시 꺼지지 않으므로 반복 타이머로 쓸 수 없다. `Execute()`를 여러 번 부르면 코루틴이 중복으로 돈다.
- `IsDestroy`의 `_count`는 `AddObject`에서만 올라가고, 인스펙터로 `cach`에 등록한 오브젝트는 세지 않는다. 코드를 읽으면 인스펙터에 오브젝트를 여러 개 넣어도 첫 번째 파괴에서 켜지는 것으로 보인다(unverified). 여러 개가 모두 파괴되어야 켜지게 하려면 `Start`에서 `_count = cach.Count`로 초기화하는 수정이 필요하다.
- `GlobalGameObject.OnDestroy`는 오브젝트를 직접 파괴할 때뿐 아니라 씬 전환·Play 종료 때도 호출되므로, 의도하지 않은 시점에 신호가 갈 수 있다.
- `Instance`가 만든 프리팹에 `GlobalGameObject`가 없으면 `AddObject`가 null 참조 오류를 낸다([output-nodes.md](output-nodes.md)).

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 입력을 "신호"가 아니라 "켜짐 상태(IsOn)"로 만든 설계의 장단점을 내 말로 적어 보자.
- [ ] 트리거가 반응하지 않았던 경험이 있다면 원인이 무엇이었는지 적어 보자.
- [ ] `IsDestroy`가 여러 오브젝트를 감시할 때 무엇이 문제인지 내 말로 설명하고, 고치는 방법을 적어 보자.
