# 전투 시스템 투사체 발사 설계

## Code Block

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

## Code Block 1

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

### 참고 링크

* 2025/GameDev/전투 시스템.md#Code Block
* 2025/GameDev/전투 시스템.md#Code Block 1
