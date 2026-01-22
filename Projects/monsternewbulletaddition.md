# MonsterNewBulletAddition

{% hint style="warning" %}
Switch to EXCALIDRAW VIEW in the MORE OPTIONS menu of this document to view the drawing correctly.\
You can decompress drawing data with the command palette: "Decompress current Excalidraw file". For more info, check the plugin settings under "Saving".
{% endhint %}

## Excalidraw Data

### Text Elements

기존 Player가 사용 중인 Missile 불릿의 스크립트를 참고해서 디자인 ^IN2TU4n6

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

^pu54ZEmo

미사일과 다른 점

* 불릿의 트리거가 동작하면 불릿의 중심 좌표에 이팩트를 생성한다.
* 트리거와 충돌한 대상이 몬스터 또는 플레이어 일 경우 데미지 처리를 진행한다. ^oW1EgUSx

***

### Embedded Files

* 5b15c0331534b392064d169cb21f16f4740db18b: \[\[topics/assets/images/스크린샷 2025-09-05 오후 5.01.30.png]]

***

### Drawing

```compressed-json
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
```
