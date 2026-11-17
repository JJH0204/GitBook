# 오브젝트 파괴 감지 설계

```csharp
public class GlobalGameObject : MonoBehaviour
{
    public event Action OnObjectDestroyed;
    
    private void OnDestroy()
    {
        // 오브젝트가 파괴되었음을 외부에 알림
        Debug.Log(gameObject.name + "is Destroy");

        OnObjectDestroyed?.Invoke();
    }
}
```

```csharp
public class GasBarrel : GlobalGameObject
{
    // [SerializeField] private List<string> target;
    [SerializeField] private List<string> target;
    
    private void OnTriggerEnter(Collider other)
    {
        // Debug.Log("OnCollisionEnter called " + other.gameObject.name);
        if (!CheckTriggerTarget(other)) return;
        Debug.Log(other.gameObject.name);
        Destroy(gameObject);
    }

    private void OnCollisionEnter(Collision collision)
    {
        // Debug.Log("OnCollisionEnter called " + other.gameObject.name);
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
        if (cach is not null)
        {
            cach.OnObjectDestroyed += Execute;
        }
    }
    
    // 
    public override void Execute()
    {
        Debug.Log("IsDestroy called");
        if (IsOn) return;   // 한번도 함수가 호출되지 않았으면 실행
        
        IsOn = true;        // 함수 호출 여부를 수정
    }
}
```

1

2

3

OnDestory 함수를 호출해 외부에 이벤트를 발생시킬 게임 오브젝트들은 GlobalGameObject를 상속받는다.\
상속 받은 객체에서 또는 다른 주체에서 Destroy() 메서드를 호출한다.\
파괴여부 이벤트를 참조할 객체에서 해당 객체가 파괴될 때 실행할 메서드를 작성 후 액션으로 등록\
Invoke 메서드를 통해 파괴시 지정된 이벤트가 실행된다.

***
