# 오브젝트 파괴 감지 설계

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-MRD-009-DO |
| 유형 | D&O (설계 기록) |
| 목적 | 오브젝트가 파괴될 때 `OnDestroy`로 이벤트를 발생시켜 다른 객체가 반응하게 하는 설계를 기록한다 |
| 확인 상태 | 미검증 (코드를 읽고 정리했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 구성 요소

| 번호 | 구성 요소 | 역할 |
|---|---|---|
| 1 | `GlobalGameObject` | `OnDestroy`에서 `OnObjectDestroyed` 이벤트를 발생시키는 기반 클래스 |
| 2 | `GasBarrel` | `GlobalGameObject`를 상속하는 가스통. 지정 태그의 대상과 충돌·트리거가 일어나면 자신을 `Destroy`한다 |
| 3 | `IsDestroy` | 지정한 `GlobalGameObject`의 파괴 이벤트를 구독하는 처리 객체(`ProcessBase` 상속) |

## 2. 동작 원리

1. 파괴를 외부에 알릴 오브젝트는 `GlobalGameObject`를 상속한다.
2. 상속한 객체 또는 다른 주체가 `Destroy()`를 호출한다.
3. 파괴를 감지할 객체가 파괴 때 실행할 메서드를 작성하고 `OnObjectDestroyed`에 등록한다.
4. Unity가 `OnDestroy`를 호출하면 `Invoke`로 등록된 메서드가 실행된다.

## 3. 코드 (원본 보존, 오류 정정 표시)

```csharp
public class GlobalGameObject : MonoBehaviour
{
    public event Action OnObjectDestroyed;
    
    private void OnDestroy()
    {
        // 오브젝트가 파괴되었음을 외부에 알림
        Debug.Log(gameObject.name + " is Destroy");   // 정정: "is Destroy" 앞에 공백 추가

        OnObjectDestroyed?.Invoke();
    }
}
```

```csharp
public class GasBarrel : GlobalGameObject
{
    [SerializeField] private List<string> target;
    
    private void OnTriggerEnter(Collider other)
    {
        if (!CheckTriggerTarget(other)) return;
        Debug.Log(other.gameObject.name);
        Destroy(gameObject);
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (!CheckCollisionTarget(collision)) return;
        Debug.Log(collision.gameObject.name);
        Destroy(gameObject);
    }

    private bool CheckTriggerTarget(Collider collision)
    {
        foreach (var item in target)
        {
            if (collision.CompareTag(item))
                return true;
        }
        return false;
    }
    
    private bool CheckCollisionTarget(Collision collision)
    {
        foreach (var item in target)
        {
            if (collision.gameObject.CompareTag(item))
                return true;
        }
        return false;
    }
}
```

```csharp
public class IsDestroy : ProcessBase
{
    // 지정된 오브젝트가 파괴되었을 경우 알림
    [SerializeField] private GlobalGameObject cach; // 파괴 여부를 참조할 객체

    private void Start()
    {
        // 씬 시작 시 
        if (cach != null)   // 정정: Unity 객체는 `is not null`이 아니라 `!= null`로 비교한다
        {
            cach.OnObjectDestroyed += Execute;
        }
    }
    
    public override void Execute()
    {
        Debug.Log("IsDestroy called");
        if (IsOn) return;   // 한번도 함수가 호출되지 않았으면 실행
        
        IsOn = true;        // 함수 호출 여부를 수정
    }
}
```

정정 내용은 다음과 같다.

- `GasBarrel`의 중복된 주석 줄과 `OnCollisionEnter called` 디버그 주석 줄을 삭제했다.
- `cach is not null`은 Unity의 `UnityEngine.Object` 오버로드된 `==`/`!=`를 우회한다. 파괴된 참조나 에디터에서 비어 있는 필드를 "있음"으로 판단할 수 있어 `!= null`로 고쳤다.
- 원본 문구 "OnDestory"는 `OnDestroy`의 오타다.

{% hint style="warning" %}
CAUTION: 아래는 코드를 읽고 찾은 동작상 위험이다. 원본은 수정하지 않았고 실행하지 않았다.
{% endhint %}

| 번호 | 위험 | 설명 |
|---|---|---|
| 1 | 씬 종료·언로드 때도 `OnDestroy` 호출 | 플레이 종료나 씬 언로드 시에도 이벤트가 발생해 의도하지 않은 `Execute`가 실행될 수 있다 |
| 2 | 구독 미해제 | `IsDestroy`가 이벤트에서 해제하지 않는다. `IsDestroy`가 먼저 파괴되면 이후 이벤트가 파괴된 객체의 `Execute`를 호출한다(`OnDestroy`에서 `-=` 필요) |
| 3 | 자식 클래스의 `OnDestroy` | 자식이 `OnDestroy`를 따로 정의하면 부모의 `private OnDestroy`가 호출되지 않는다. `protected virtual`로 바꾸고 `base.OnDestroy()`를 호출하는 방식이 필요하다 |
| 4 | 같은 프레임 중복 파괴 | `OnTriggerEnter`와 `OnCollisionEnter`가 같은 프레임에 둘 다 호출되면 `Destroy`가 두 번 호출된다. 오브젝트는 프레임 끝에 한 번만 파괴되므로 문제는 없으나 로그가 두 번 나올 수 있다 |

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| `OnDestroy` | `MonoBehaviour`가 파괴될 때 Unity가 호출하는 메시지 함수 |
| `event Action` | 인자와 반환값이 없는 이벤트 델리게이트 |

## 5. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM D&O 형식으로 재작성, 번호만 있던 설명을 동작 원리로 정리, 2곳 정정 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 오브젝트 파괴를 폴링하지 않고 이벤트로 알리는 방식을 택한 이유는 무엇인가?
- [ ] 가스통이 파괴될 때 어떤 게임 동작이 이어지도록 이 설계를 썼는가?
