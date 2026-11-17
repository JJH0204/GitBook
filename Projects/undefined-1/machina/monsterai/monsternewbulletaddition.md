# 몬스터 신규 투사체 추가

기존 Player가 사용 중인 Missile 불릿의 스크립트를 참고해서 디자인

{% code title="GravityBullet.cs" %}
```csharp
using Managers;
using Monster;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEngine.Rendering;

public class GravityBullet : Bullet
{
    [SerializeField] protected GameObject collisionBulletPrefab;

    protected override void OnTriggerEnter(Collider other)
    {
        if (!isCheckCollisionByBullet) return;

        // 플레이어가 발사한 총알
        if (from.CompareTag("Player") && other.CompareTag("Enemy"))
        {
            DestroyBullet();
            return;
        }

        // 적이 발사한 총알
        if (from.CompareTag("Enemy") && other.CompareTag("Player"))
        {
            DestroyBullet();
            return;
        }

        // 벽(또는 기타 오브젝트)에 닿은 경우
        if (other.CompareTag("Wall") || other.CompareTag("Obstacle"))
        {
            DestroyBullet();
            return;
        }
    }

    protected override void DestroyBullet()
    {
        Explode();
    }

    protected override void StartBulletLogic(Vector3 direction, Vector3 start)
    {
        rb.velocity = direction * bulletSpeed;
    }

    protected override void Explode()
    {
        if (explosionEffectPrefab != null)
        {
            Instantiate(explosionEffectPrefab, transform.position, Quaternion.identity);
        }

        // Collider[] colliders = Physics.OverlapSphere(transform.position, explosionRadius);
        // foreach (Collider collider in colliders)
        // {
        //    TakeDamage(collider.transform);
        //
        //    Destroy(Instantiate(collisionBulletPrefab, collider.transform.position, Quaternion.identity), 0.1f);
        // }

        // Destroy(gameObject);
        PoolManager.Instance.ReleaseObject(gameObject);
    }
}
```
{% endcode %}

미사일과 다른 점

* 불릿의 트리거가 동작하면 불릿의 중심 좌표에 이팩트를 생성한다.
* 트리거와 충돌한 대상이 몬스터 또는 플레이어 일 경우 데미지 처리를 진행한다.

***
