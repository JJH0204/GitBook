# 오브젝트 풀링 조사 (Object Pooling)

오브젝트 풀링

* 게임의 최적화를 위해 자주 생성하고 삭제하는 객체를 미리 만들어 두고 다른 시스템에서 해당 객체를 필요로 할때 불러와 사용할 수 있도록 만들어 준다.
* 어떻게 하면 오브젝트 풀링을 구현할 수 있을까?

Unity API Pool 을 활용해 비교적 쉽게 오브젝트 풀링을 구현할 수 있다.

몬스터의 종류를 열거형으로 정의

```csharp
public enum MonsterType
{
    Normal,
    Ranged,
    Rapid,
}
```

^3lAqarDv

각종 몬스터의 프리팹과 풀 설정을 Editor에서 쉽게 설정할 수 있도록 구조체 생성

```csharp
public struct MonsterPoolData
{
    public MonsterType type;
    public GameObject prefab;
    public int defaultSize;
    public int maxSize;
}
```

^4ftC6v3E

풀 관리자 클래스(MonsterManager) 구현

```csharp
public class MonsterManager : MonoBehaviour
{
    [SerializeField] private MonsterPoolData[] monsterPoolsData;

    // 몬스터를 종류별로 풀을 만들어 저장할 딕셔너리
    private Dictionary<MonsterType, ObjectPool<GameObject>> monsterPools;

    private void Awake()
    {
        monsterPools = new Dictionary<MonsterType, ObjectPool<GameObject>>();
        
        // pool 객체를 초기화하는 코드
    }
}
```

^dHP5TE6V

Type을 매번 관리하는게 번거로운데 이것을 동적으로 관리할 수 없을까?

현재 프로젝트에서 고려할 열거형 값을 대신할 키 역할의 데이터는 다음과 같다.

{% stepper %}
{% step %}
캐릭터 아이디 (int)

* 직관적이지 않지만 데이터베이스에서 관리되는 하나의 공리에 가깝기에 간결하게 사용하기 좋을 것 같다.
{% endstep %}

{% step %}
캐릭터 이름 (string)

* 확실히 직관적으로 어떤 몬스터인지 인지할 수 있어 좋지만 오탈자에 영향으로 인해 안정성이 떨어진다.
{% endstep %}

{% step %}
프리팹의 이름 (string)

* 사용성이 훨씬 간결해지고 오탈자 문제에서 일부 자유로우나 성능 문제가 있을 수 있다.
{% endstep %}
{% endstepper %}

25.09.03 이슈

* 풀링 메니저 구현은 완료했다.
* 몬스터에 적용하는 과정에서 문제가 발생한다.

몬스터에는 Behavior Tree가 적용되어 있어 상태처리를 3개의 시스템이 나눠서 담당한다.

* Sence / Tink / Act 로 나뉘는 시스템 구조

Death -> Idle 로 상태가 전환되어야 하는데 (풀링을 위해) 이 과정에서 원활한 처리가 이뤄지지 않고 있어 객체의 재활용에 문제가 발생한다.

풀링 이전에 사용한 컴포넌트를 초기 상태로 전환하는 Init 메서드를 구현

> 풀링 이후 다시 사용할 수 있도록 Init 호출로 문제 해결

디폴트 사이즈 / 맥스 사이즈가 정상적으로 동작하는지 점검 필요

* 디폴트 사이즈는 의도한 결과가 나오지 않고 있음
  * 객체 생성까지는 진행한 것으로 보이는데 정작 씬에는 풀링 오브젝트가 1개 밖에 생성되어 있지 않음
* 객체의 인스턴스를 극한으로 시도해보면 맥스 사이즈가 정상 동작하는지 알 수 있을 것 같다.
