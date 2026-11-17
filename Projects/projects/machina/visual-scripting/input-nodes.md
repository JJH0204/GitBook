# 입력 노드: IsDestroy와 이벤트 구독

## 무엇을 하는가

입력 노드는 "조건이 충족되었는가"를 `IsOn`으로 알려 주는 노드다. 이 페이지는 `IsDestroy`를 중심으로 다룬다. `IsDestroy`는 인스펙터에 담긴 오브젝트들이 **모두** 파괴되었을 때 `IsOn`을 `true`로 만든다. 예를 들어 "방 안의 적을 전부 처치하면 문이 열린다"의 조건 부분이다.

같은 폴더의 `IsDead`(체력 0 이하), `IsDisable`, `Trigger`, `TriggerEnter`, `OnEvent`도 같은 방식이다. 이들은 대상 영역이 아니므로 구조 비교용으로만 언급한다.

## 왜 이렇게 설계했나

- 대상 오브젝트에는 `GlobalGameObject`라는 얇은 컴포넌트를 붙인다. 이 컴포넌트는 `OnDestroy`에서 `OnObjectDestroyed` 이벤트를 발생시킨다. 입력 노드가 매 프레임 대상을 감시하지 않고 이벤트를 구독하므로 비용이 적다.
- 개수를 센다. 대상이 여러 개일 때 마지막 하나가 사라지는 순간 켜진다.
- 풀에서 꺼낸 오브젝트처럼 **씬에 미리 없던 대상**은 `AddObject`로 나중에 등록한다. `Instance` 출력 노드가 이 함수를 호출한다.

## 핵심 코드

{% code title="IsDestroy.cs" %}
```csharp
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
            _count++;
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

- `cach`는 감시할 `GlobalGameObject` 목록이다. 인스펙터에서 끌어다 넣는다. (필드 이름 철자는 원본 그대로다.)
- `Start`에서 각 대상의 `OnObjectDestroyed` 이벤트에 자기 자신의 `Execute`를 등록하고 `_count`를 센다. 즉 `Execute`는 "대상 하나가 파괴되었다"는 콜백이다.
- `Execute`는 호출될 때마다 `_count`를 줄이고 0 이하가 되면 `IsOn`을 켠다. 이미 켜져 있으면 바로 반환한다.
- `AddObject`는 런타임 등록용이다. 목록에도 추가해 `Cach` 프로퍼티로 읽을 수 있다.

대상 쪽 코드는 다음과 같다. (`GlobalGameObject.cs`, 디버그 로그 생략)

{% code title="GlobalGameObject.cs" %}
```csharp
public class GlobalGameObject : MonoBehaviour
{
    public event Action OnObjectDestroyed;
    public event Action OnObjectDisabled;

    private void OnDestroy() { OnObjectDestroyed?.Invoke(); }
    private void OnDisable() { OnObjectDisabled?.Invoke(); }
}
```
{% endcode %}

### 이 파일에 대한 변경 이력

이 영역 작성자의 커밋(`bc23a743`)은 `IsDestroy`를 다시 정리한 것이다. 변경분을 읽어 보면 네임스페이스 안쪽 들여쓰기를 바로잡는 것이 대부분이며, 이벤트 등록과 카운트 로직은 그대로다. 로직 변화는 같은 커밋의 `ExcutionerDummy`(출력 노드 페이지)에 있다. (diff를 읽은 결과이며 실행으로 확인하지 않았다.)

## 따라 만들기

1. `GlobalGameObject`를 위 코드대로 만든다. 확인 방법: 오브젝트에 붙이고 `Destroy` 시 이벤트가 호출되는지 `Debug.Log`로 본다.
2. `IsDestroy`를 작성해 빈 오브젝트에 붙이고, 큐브 두 개에 `GlobalGameObject`를 붙여 `cach`에 넣는다. 확인 방법: 인스펙터에 `Cach` 리스트(크기 2)가 보인다.
3. 테스트용 스크립트로 큐브를 하나씩 `Destroy`한다. 확인 방법: 첫 번째에서는 `Is On`이 꺼져 있고, 두 번째에서 켜진다.
4. [ProcessBase와 연결 규칙](process-base.md)의 `Conditional`로 `IsDestroy`를 입력, 로그 출력 노드를 출력으로 연결한다. 확인 방법: 마지막 큐브가 사라질 때 로그가 한 번 찍힌다.
5. 스폰 노드가 있다면 소환한 오브젝트를 `AddObject`로 등록해 본다. 확인 방법: 소환한 개수만큼 `Cach`가 늘고 전부 파괴되면 켜진다. ([월드·연출 출력 노드](output-nodes-world.md)의 `Instance` 참고)

## 막히기 쉬운 곳과 한계

- `OnDestroy`는 씬 전환이나 플레이 종료 때도 호출된다. 이때 이벤트가 연쇄 발생해 의도치 않게 `IsOn`이 켜질 수 있다. 원본에서 이를 막는 코드는 확인하지 못했다. (추정, unverified)
- `Start`에서 등록하므로 `Start` 이전에 파괴된 대상은 세지 못한다.
- `IsDestroy`는 이벤트 등록 전에 `-=`로 중복을 막지 않는다. 같은 오브젝트를 `cach`에 두 번 넣거나 `AddObject`를 중복 호출하면 `_count`가 어긋난다. `IsDead`는 `-=` 후 `+=`로 중복을 막고 있어 대조적이다.
- `cach`에 비어 있는 슬롯이 있으면 `Start`에서는 건너뛰지만 `AddObject`에는 검사가 없다.
- 원본에는 `Execute`에 디버그 로그가 남아 있다. 따라 만들 때는 지워도 된다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 입력 노드가 매 프레임 대상을 검사하지 않고 `event`를 구독하도록 만든 이유를 내 말로 설명해 보자.
- [ ] 런타임에 소환된 오브젝트를 `IsDestroy`가 감시하게 하려면 어떤 일이 필요했는가? 직접 만들어 보며 막혔던 지점이 있었다면 적어 보자.
