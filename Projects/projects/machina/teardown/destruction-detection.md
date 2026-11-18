# 오브젝트 파괴 감지 해체

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-MCH-102-DO |
| 유형 | D&O (소스 해체) |
| 목적 | 오브젝트가 파괴·비활성화될 때 이벤트로 알리고, 비주얼 스크립팅 입력 노드가 그것을 조건으로 쓰는 구조를 해체한다 |
| 확인 상태 | 미검증 (코드를 읽기만 했고 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="warning" %}
WARNING: 비공개 레포, 접근 권한 필요. 코드는 소스 레포의 git 오브젝트를 읽기 전용으로 읽었다. 설계 의도는 기존 [오브젝트 파괴 감지 설계](../rnd/objectdestructiondecision.md)에 있고, 이 문서는 현재 소스와의 차이를 중심으로 쓴다.
{% endhint %}

## 1. 이 영역이 하는 일

기획자가 만든 "가스통이 터지면 문이 열린다" 같은 조건을 코드 없이 잇기 위해, 오브젝트의 파괴·비활성화를 이벤트로 내보내고 입력 노드가 이를 받아 `IsOn`을 켠다. 비주얼 스크립팅의 연결 규칙은 [ProcessBase와 연결 규칙](../visual-scripting/process-base.md)을 본다.

## 2. 구성 요소

| 파일(`Branch/Assets/_GameAssets/01. Scripts/` 기준) | 역할 |
|---|---|
| `GameObjects/GlobalGameObject.cs` | `OnDestroy`에서 `OnObjectDestroyed`, `OnDisable`에서 `OnObjectDisabled` 이벤트를 발생시키는 기반 클래스 |
| `GameObjects/GasBarrel.cs` | `GlobalGameObject` 상속. 지정 태그와 충돌·트리거가 일어나면 자신을 `Destroy` |
| `VisualScripting/Input/IsDestroy.cs` | 지정 객체 목록이 모두 파괴되면 `IsOn`을 켜는 입력 노드 |
| `VisualScripting/Input/IsDisable.cs` | 같은 구조로 비활성화를 감지하는 입력 노드 |
| `VisualScripting/Output/Instance.cs` | 풀에서 객체를 꺼낸 뒤 위 입력 노드에 동적으로 등록하는 출력 노드 |

## 3. 데이터 흐름

```
GasBarrel --Destroy--> Unity OnDestroy --> GlobalGameObject.OnObjectDestroyed
                                                  |  (구독: IsDestroy.Execute)
                                                  v
                              IsDestroy: _count-- ; _count <= 0 이면 IsOn = true
                                                  |
                                      Conditional(처리 노드)가 IsOn을 읽고 출력 노드 실행

풀 반납(SetActive false) --> OnDisable --> OnObjectDisabled --> IsDisable (같은 방식)

Instance 노드: 풀에서 Get --> destroyTrigger/disableTrigger.AddObject(obj) 로 구독 추가
```

## 4. 핵심 코드 해설

{% code title="GameObjects/GlobalGameObject.cs" %}
```csharp
public class GlobalGameObject : MonoBehaviour
{
    public event Action OnObjectDestroyed;
    public event Action OnObjectDisabled;

    private void OnDestroy()  { OnObjectDestroyed?.Invoke(); }
    private void OnDisable()  { OnObjectDisabled?.Invoke(); }
}
```
{% endcode %}

- 기존 설계 기록(R&D)에는 `OnObjectDestroyed`만 있었다. 현재 소스는 `OnObjectDisabled`가 추가되어 있다. 이유는 풀링이다. 풀로 반납된 객체는 `Destroy`되지 않고 `SetActive(false)`만 되므로 `OnDestroy`가 불리지 않는다. 풀링 대상의 "사라짐"은 `OnDisable`로 감지한다([풀링 해체](pooling-optimization.md) 참조). 이 연결 의도는 소스에 주석이 없어 코드 구조에서 추론한 것이다.

{% code title="VisualScripting/Input/IsDestroy.cs (핵심)" %}
```csharp
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

public void AddObject(GlobalGameObject obj)   // 동적 생성 객체 등록
{
    obj.OnObjectDestroyed += Execute;
    cach.Add(obj);
    _count++;
}

public override void Execute()
{
    if (IsOn) return;
    _count--;
    if (_count <= 0) IsOn = true;
}
```
{% endcode %}

- 기존 기록의 단일 객체(`GlobalGameObject cach`)가 현재는 **목록 + 카운터**다. 감시 대상이 모두 파괴되어야 `IsOn`이 켜지므로 "몬스터 N마리를 모두 처치하면 문이 열린다"를 표현한다.
- `AddObject`가 있어 `Instance` 노드가 런타임에 만든 객체도 감시할 수 있다. `Instance.cs`는 꺼낸 객체의 `GlobalGameObject`를 `destroyTrigger`/`disableTrigger`에 등록하고, `DamagableObject`는 `deadTrigger`(`IsDead`)에 등록한다.
- `IsDisable.Execute`는 `_count`가 0이 되면 `cach.Clear()` 후 `IsOn`을 켠다. `IsDestroy`는 목록을 비우지 않는다.

## 5. 따라 만들기

확인 상태: 미검증.

1. `OnDestroy`·`OnDisable`에서 `event Action`을 호출하는 `GlobalGameObject` 기반 클래스를 만든다. 기대 결과: 상속한 오브젝트가 파괴·비활성화될 때 이벤트가 발생한다.
2. `Destroy`를 일으킬 테스트 오브젝트(`GasBarrel` 유사)를 만든다. 지정 태그 목록과 `CompareTag`로 충돌 대상을 거른다. 기대 결과: 해당 태그와 닿으면 오브젝트가 사라진다.
3. 입력 노드 기반 클래스(`IsOn`, `Execute`)를 둔다. 기대 결과: 노드가 켜짐 상태를 가진다.
4. `IsDestroy`를 만든다: 목록을 구독하고 카운터를 줄여 0 이하이면 `IsOn`을 켠다. 기대 결과: 목록의 마지막 객체가 파괴될 때 한 번 켜진다.
5. 런타임 생성 객체용 `AddObject`를 추가하고 생성 노드에서 호출한다. 기대 결과: 풀에서 꺼낸 객체도 카운트에 포함된다.
6. 풀링 객체를 쓰면 `IsDisable`도 만들어 `OnDisable`을 감지한다. 기대 결과: 풀 반납으로 비활성화될 때 `IsOn`이 켜진다.

## 6. 알려진 한계·주의

{% hint style="warning" %}
CAUTION: 아래는 코드를 읽고 찾은 위험이며 실행하지 않았다.
{% endhint %}

| 번호 | 위험 | 설명 |
|---|---|---|
| 1 | 구독 미해제 | `IsDestroy`·`IsDisable`이 `-=`를 하지 않는다. 입력 노드가 먼저 파괴되면 이후 이벤트가 파괴된 객체의 `Execute`를 호출할 수 있다 |
| 2 | 풀 재사용과 카운트 | 풀에서 같은 객체를 다시 꺼내 `AddObject`하면 같은 이벤트에 `Execute`가 중복 구독되고 `_count`가 늘어난다. 반납 때마다 `OnDisable`이 불리므로 카운트가 어긋날 수 있다 |
| 3 | 종료·언로드 | 플레이 종료나 씬 언로드 때도 `OnDestroy`/`OnDisable`이 불려 의도하지 않은 `Execute`가 실행될 수 있다 |
| 4 | 자식 클래스 | 자식이 `OnDestroy`/`OnDisable`을 따로 정의하면 부모의 `private` 메서드는 호출되지 않는다(Unity 메시지 규칙) |
| 5 | `item is null` | `IsDestroy.Start`가 Unity 객체를 `is null`로 검사해 파괴된 참조를 걸러내지 못할 수 있다 |

{% hint style="info" %}
NOTE: `IsDestroy.Execute`의 `if (IsOn) return;`은 한 번 켜진 뒤의 호출을 무시한다. 두 이벤트(파괴·비활성화) 중 어느 쪽을 쓸지는 씬 배치(`Instance`의 `destroyTrigger`/`disableTrigger` 지정)에 달려 있으며 어떤 씬에서 쓰는지는 소스에서 확인 못함.
{% endhint %}

## 7. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 최초 작성 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 단일 객체 감시에서 목록과 카운터로 바꾼 계기는 무엇이고, 풀링과는 어떻게 충돌했는가?
- [ ] `OnDestroy`와 `OnDisable` 중 어떤 상황에 무엇을 쓰도록 정했는가?
