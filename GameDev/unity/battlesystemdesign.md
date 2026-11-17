# 전투 시스템 투사체 발사 설계

## 설계 메모

* 공격을 주고 받는 행위
* 어떻게 주고 받으면 되는 걸까?
* 투사체를 기반으로 피격 시 피해를 받는 방식으로 구현할 수 있을 것 같다.
* 투사체의 사거리가 짧다 = 근거리 공격
* 투사체의 사거리가 길다 = 원거리 공격
* 대상을 지정한다.
* 공격한다.
* 투사체가 발사된다.
* 대상은 어떻게 지정하면 좋을까? 아래에 절차를 정리함.

{% stepper %}
{% step %}
### 대상 지정: 공간 기반 감지

* 캐릭터 자신을 중심으로 지정된 반지름만큼의 공간을 미리 할당
* 공간에 들어와 있는(온 트리거) 오브젝트의 타입을 판단(적인지 판단)
* 다수의 적이 공간안에 들어와 있는 경우 캐릭터 자신과의 거리가 가장 가까운 대상을 공격 대상으로 지정
* 실시간으로 변경되는 위 조건 값들을 갱신하면서 공격 대상을 타격해야 한다.
{% endstep %}
{% endstepper %}

* 공격은 어떻게 하면 될까? 절차를 정리함.

{% stepper %}
{% step %}
### 공격 절차

* 공격 대상이 지정되어 있는지 확인 (지정되어 있지 않다면 캐릭터가 바라보는 방향으로 공격)
* 공격 대상이 지정되어 있다면 바라보는 방향으로 투사체가 날아갈 수 있도록 탄(오브젝트) 생성
* 공격 대상이 있는 방향으로 투사체에 힘 전달
{% endstep %}
{% endstepper %}

* 투사체가 발사되는 것은 좋은데 투사체의 속성을 어떻게 정의하면 좋을까?
* rigidbody는 적용하면 안될 것 같다. - 중력의 영향을 받는 것은 현재 의도하는 게임성과 다름
* collision 은 적용하자
* 플레이어 공격 스크립트
* 발사 투사체 스크립트
* 기획서를 안 읽고 마음데로 공격 대상을 지정하는 방식을 지정했다. 하지만 사용 방법에 대해서만 달라졌을 뿐 원리는 동일하다고 생각한다.
* 레이케스트를 사용해 대상을 지정해보자
* 마우스 클릭으로 대상을 지정한다.
* 지정된 대상을 향하는 최단 경로를 계산하자
* 경로를 따라 이동하고 일정 주기로 갱신하자

## 코드

### Attack.cs

{% code title="Attack.cs" %}
```cs
using UnityEngine;

/// <summary>
/// 투사체 발사를 관리하는 클래스
/// </summary>
public class Attack : MonoBehaviour
{
    [SerializeField] private GameObject projectilePrefab;      // 발사할 투사체 프리팹
    [SerializeField] private float projectileSpeed = 20f;      // 투사체의 이동 속도
    [SerializeField] private float maxProjectileDistance = 10f;// 투사체가 이동할 수 있는 최대 거리
    
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    /// <summary>
    /// 매 프레임마다 마우스 입력을 체크
    /// </summary>
    void Update()
    {
        // 마우스 좌클릭 감지
        if (Input.GetMouseButtonDown(0))
        {
            FireProjectile();
        }
    }

    /// <summary>
    /// 투사체를 생성하고 발사하는 메서드
    /// </summary>
    void FireProjectile()
    {
        // 현재 위치와 회전값으로 투사체 생성
        GameObject projectile = Instantiate(projectilePrefab, transform.position, transform.rotation);
        
        // 투사체의 물리 컴포넌트와 컨트롤러 컴포넌트 가져오기
        Rigidbody rb = projectile.GetComponent<Rigidbody>();
        ProjectileController controller = projectile.GetComponent<ProjectileController>();
        
        // 투사체에 속도 적용
        if (rb != null)
        {
            rb.velocity = transform.forward * projectileSpeed;
        }
        
        // 투사체 컨트롤러에 최대 거리와 시작 위치 설정
        if (controller != null)
        {
            controller.SetMaxDistance(maxProjectileDistance);
            controller.SetStartPosition(transform.position);
        }
    }
}
```
{% endcode %}

### ProjectileController.cs

{% code title="ProjectileController.cs" %}
```cs
using UnityEngine;

/// <summary>
/// 투사체의 동작을 제어하는 클래스
/// </summary>
public class ProjectileController : MonoBehaviour
{
    private float maxDistance;    // 투사체가 이동할 수 있는 최대 거리
    private Vector3 startPosition;// 투사체의 발사 시작 위치

    /// <summary>
    /// 투사체의 최대 이동 거리를 설정하는 메서드
    /// </summary>
    /// <param name="distance">설정할 최대 거리</param>
    public void SetMaxDistance(float distance)
    {
        maxDistance = distance;
    }
    
    /// <summary>
    /// 투사체의 시작 위치를 설정하는 메서드
    /// </summary>
    /// <param name="position">발사 시작 위치</param>
    public void SetStartPosition(Vector3 position)
    {
        startPosition = position;
    }
    
    /// <summary>
    /// 매 프레임마다 이동 거리를 체크하여 최대 거리 도달 시 제거
    /// </summary>
    void Update()
    {
        // 시작 위치로부터의 현재 이동 거리 계산
        float traveledDistance = Vector3.Distance(startPosition, transform.position);

        // 최대 거리 도달 시 오브젝트 제거
        if (traveledDistance >= maxDistance)
        {
            Destroy(gameObject);
        }
    }
}
```
{% endcode %}

## 알아 둘 사실

* `rb.velocity`는 Unity 6에서 `rb.linearVelocity`로 이름이 바뀌었다.
* 메모에 "중력 때문에 Rigidbody는 안 될 것 같다"고 적었지만, Rigidbody의 Use Gravity를 끄면 중력 없이 쓸 수 있다. 또 충돌·트리거 이벤트(`OnTriggerEnter` 등)는 부딪힌 둘 중 하나에 Rigidbody가 있어야 발생한다.
* 빠른 투사체는 한 물리 프레임에 벽 두께보다 멀리 이동해서 충돌 없이 뚫고 지나갈 수 있다(터널링). Collision Detection을 Continuous Dynamic으로 바꾸거나, 이동 구간을 레이캐스트로 검사한다.
* 대상 지정의 "공간 기반 감지"는 트리거 콜라이더를 계속 켜 두는 대신, 공격할 때만 `Physics.OverlapSphere`로 주변 콜라이더를 모아 가장 가까운 적을 고르는 방법도 있다.
* 발사할 때마다 `Instantiate`, 사거리 끝에서 `Destroy`하면 GC 할당이 쌓여 프레임 스파이크가 생길 수 있다. 자주 생겼다 사라지는 오브젝트는 오브젝트 풀(`UnityEngine.Pool.ObjectPool<T>`)로 재사용한다.

## 더 보기

* [Unity·C# Day 12 · 실습: 오브젝트 풀](../unity-csharp/day12-lab-object-pool.md)
* [Unity·C# Day 23 · 트러블슈팅 ②: 투사체가 바닥에 먹히는 버그](../unity-csharp/day23-troubleshooting-bug.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `Attack`과 `ProjectileController`를 오브젝트 풀 버전으로 바꾼다. 투사체를 풀에 돌려줄 때 무엇을 초기화해야 하는지 적는다.
- [ ] 대상 지정을 트리거 콜라이더 방식과 `OverlapSphere` 방식으로 각각 구현해 보고 차이를 쓴다.
- [ ] `projectileSpeed`를 200으로 올려 얇은 벽을 뚫는지 확인하고, 뚫는다면 왜 그런지와 어떻게 막았는지 쓴다.
