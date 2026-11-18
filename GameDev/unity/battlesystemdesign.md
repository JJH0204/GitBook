# 전투 시스템 투사체 발사 설계

## 문서 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UNI-004-DO |
| 유형 | D&O (설계 문서) |
| 목적 | 투사체 기반 공격(대상 지정, 발사, 사거리 제한)의 설계 의도와 구현 코드를 기록한다 |
| 적용 대상 | Unity 3D, `Rigidbody`·`Collider` 사용. 렌더 파이프라인과 무관하다 |
| 확인 상태 | 미검증 (코드를 읽고 정리했으며 Unity에서 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 작성자의 설계 메모다. 설계 구조는 원본을 따르고, 코드와 API 이름의 오류만 정정했다. Unity 6에서는 `Rigidbody.velocity`가 `linearVelocity`로 바뀌었다. 사용하는 Unity 버전을 확인한다.
{% endhint %}

## 1. 목적

공격을 주고받는 행위를 투사체로 구현한다. 투사체의 피격 판정으로 피해를 준다.

| 투사체 사거리 | 공격 유형 |
|---|---|
| 짧다 | 근거리 공격 |
| 길다 | 원거리 공격 |

공격은 "대상을 지정한다 → 공격한다 → 투사체가 발사된다" 순서로 진행한다.

## 2. 구성 요소

| 구성 요소 | 종류 | 역할 |
|---|---|---|
| 플레이어 공격 스크립트 (`Attack`) | `MonoBehaviour` | 입력을 받아 투사체를 생성하고 속도와 사거리를 전달한다 |
| 발사 투사체 스크립트 (`ProjectileController`) | `MonoBehaviour` | 발사 위치에서 이동한 거리를 계산하고 사거리를 넘으면 제거한다 |
| 투사체 프리팹 | `GameObject` | `Rigidbody`, `Collider`, `ProjectileController`를 가진다 |
| 감지 공간 | `Collider` (Trigger) | 캐릭터 중심의 구형 영역에 들어온 오브젝트를 감지한다 |

## 3. 동작 원리

### 3.1 대상 지정

{% stepper %}
{% step %}
### 대상 지정: 공간 기반 감지

* 캐릭터 자신을 중심으로 지정된 반지름만큼의 공간을 미리 할당한다.
* 공간에 들어온(`OnTrigger`) 오브젝트의 타입을 판단한다(적인지 판단).
* 다수의 적이 공간 안에 있으면 캐릭터와의 거리가 가장 가까운 대상을 공격 대상으로 지정한다.
* 위 조건 값은 실시간으로 바뀌므로 갱신하면서 공격 대상을 타격해야 한다.
{% endstep %}
{% endstepper %}

### 3.2 공격 절차

{% stepper %}
{% step %}
### 공격 절차

* 공격 대상이 지정되어 있는지 확인한다. 지정되어 있지 않으면 캐릭터가 바라보는 방향으로 공격한다.
* 공격 대상이 지정되어 있으면 바라보는 방향으로 투사체가 날아갈 수 있도록 탄(오브젝트)을 생성한다.
* 공격 대상이 있는 방향으로 투사체에 힘을 전달한다.
{% endstep %}
{% endstepper %}

### 3.3 투사체 속성 결정

| 항목 | 결정 | 이유 |
|---|---|---|
| `Rigidbody` | 쓰되 중력은 끈다 | 중력의 영향을 받는 것은 의도한 게임성과 다르다 (3.4절 참조) |
| `Collider` | 사용한다 | 충돌로 피격을 판정한다 |
| 스크립트 | 플레이어 공격 스크립트, 발사 투사체 스크립트로 나눈다 | 발사와 사거리 관리의 책임을 분리한다 |

### 3.4 설계 변경 메모

* 기획서를 읽지 않고 공격 대상을 지정하는 방식을 임의로 정했다. 사용 방법만 달라졌고 원리는 같다고 판단한다.
* 대안: 레이캐스트로 대상을 지정한다.
  * 마우스 클릭으로 대상을 지정한다.
  * 지정한 대상을 향하는 최단 경로를 계산한다.
  * 경로를 따라 이동하고 일정 주기로 갱신한다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 투사체(projectile) | 발사되어 날아가는 공격 오브젝트 |
| 트리거(Trigger) | 물리 충돌 없이 겹침만 감지하는 콜라이더 설정 |
| 레이캐스트(Raycast) | 한 점에서 한 방향으로 선을 쏘아 부딪히는 대상을 찾는 검사 |
| 사거리 | 발사 위치에서 투사체가 이동할 수 있는 최대 거리 |

## 5. 코드

{% hint style="info" %}
NOTE: `rb.velocity`는 Unity 6에서 `rb.linearVelocity`다. Unity 6 이상이면 해당 줄을 바꾼다. 아래 코드는 원본 그대로다.
{% endhint %}

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


## 6. 알아 둘 사실

{% hint style="warning" %}
CAUTION: 아래 항목은 코드와 설계의 불일치 또는 위험이다. 투사체 속도를 올리거나 발사 횟수를 늘리기 전에 확인한다.
{% endhint %}

| 번호 | 사실 | 대응 |
|---|---|---|
| 1 | `rb.velocity`는 Unity 6에서 `rb.linearVelocity`로 이름이 바뀌었다 | 버전 확인 필요. 사용하는 버전의 이름을 쓴다 |
| 2 | 설계 메모는 중력 때문에 `Rigidbody`를 쓰지 않는다고 했지만 코드는 `Rigidbody`를 쓴다 | `Rigidbody`의 `Use Gravity`를 끄면 중력 없이 쓸 수 있다 |
| 3 | 충돌·트리거 이벤트(`OnTriggerEnter` 등)는 부딪힌 둘 중 하나에 `Rigidbody`가 있어야 발생한다 | 투사체 또는 대상에 `Rigidbody`를 둔다 |
| 4 | 빠른 투사체는 한 물리 프레임에 벽 두께보다 멀리 이동해 충돌 없이 통과할 수 있다(터널링) | `Collision Detection`을 `Continuous Dynamic`으로 바꾸거나 이동 구간을 레이캐스트로 검사한다 |
| 5 | 공간 기반 감지는 트리거 콜라이더를 계속 켜 두는 대신 공격 시점에 `Physics.OverlapSphere`로 주변 콜라이더를 모아 가장 가까운 적을 고르는 방법도 있다 | 비교 후 선택한다 |
| 6 | 발사마다 `Instantiate`, 사거리 끝에서 `Destroy`하면 GC 할당이 쌓여 프레임 스파이크가 생길 수 있다 | 오브젝트 풀(`UnityEngine.Pool.ObjectPool<T>`)로 재사용한다 |

## 7. 참조

| 참조 문서 | 제목 |
|---|---|
| [Day 12 · \[실습\] 오브젝트 풀](../unity-csharp/day12-lab-object-pool.md) | 오브젝트 풀 구현 |
| [Day 23 · 트러블슈팅 노트 ②: 투사체가 바닥에 먹히는 버그](../unity-csharp/day23-troubleshooting-bug.md) | 투사체 관련 버그 사례 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `Attack`과 `ProjectileController`를 오브젝트 풀 버전으로 바꾼다. 투사체를 풀에 돌려줄 때 무엇을 초기화해야 하는지 적는다.
- [ ] 대상 지정을 트리거 콜라이더 방식과 `OverlapSphere` 방식으로 각각 구현해 보고 차이를 쓴다.
- [ ] `projectileSpeed`를 200으로 올려 얇은 벽을 뚫는지 확인하고, 뚫는다면 왜 그런지와 어떻게 막았는지 쓴다.
