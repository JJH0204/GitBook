# 몬스터 신규 투사체 추가

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-MAI-005-DO |
| 유형 | D&O (구현 기록) |
| 목적 | 플레이어의 미사일 투사체를 참고해 몬스터용 중력 투사체(`GravityBullet`)를 만든 방식을 정리한다 |
| 적용 대상 | Unity, 오브젝트 풀(`PoolManager`)을 쓰는 프로젝트 |
| 확인 상태 | 미검증 (코드를 읽고 정리했으며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="warning" %}
CAUTION: 아래 코드는 작성 당시 버전이다. 팀 레포 `main`의 `GravityBullet.cs`는 본문이 모두 주석 처리되어 있고, 주석에 남은 시그니처(`DestroyBullet(Transform parent = null)`, `SetBulletLogic`, `_rb`)로 보아 부모 `Bullet` 클래스의 API가 바뀌었다. 현재 코드와 일치하지 않으므로 그대로 복사하지 않는다.
{% endhint %}

## 1. 목적

몬스터가 발사하는 투사체를 새로 추가한다. 기존에 플레이어가 쓰는 미사일 투사체 스크립트를 참고해 설계했다. 투사체는 `Bullet` 클래스를 상속해 충돌 처리, 이동 시작, 폭발을 재정의한다.

## 2. 미사일과 다른 점

| 번호 | 항목 | 내용 |
|---|---|---|
| 1 | 이펙트 | 투사체 트리거가 동작하면 투사체 중심 좌표에 이펙트를 생성한다 |
| 2 | 피해 | 트리거와 충돌한 대상이 몬스터 또는 플레이어이면 피해를 처리한다(원본 설명) |

{% hint style="danger" %}
WARNING: 원본 설명과 아래 코드가 어긋난다. 피해를 주는 `OverlapSphere` 반복문이 주석 처리되어 있어, 이 코드만으로는 피해가 적용되지 않는다. 피해 처리가 부모 클래스에 있는지는 확인 필요.
{% endhint %}

## 3. 동작 원리

| 순서 | 메서드 | 동작 |
|---|---|---|
| 1 | `StartBulletLogic` | 발사 방향 × 투사체 속도를 `rb.velocity`로 설정한다 |
| 2 | `OnTriggerEnter` | 발사자와 충돌 대상의 태그 조합(플레이어→적, 적→플레이어, 벽 또는 장애물)을 검사해 `DestroyBullet`을 호출한다 |
| 3 | `DestroyBullet` | `Explode`를 호출한다 |
| 4 | `Explode` | 폭발 이펙트를 생성하고 투사체를 풀에 반환한다 |

## 4. 코드

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

## 5. 코드 확인 결과

| 번호 | 위치 | 내용 | 분류 |
|---|---|---|---|
| 1 | `OnTriggerEnter` | `from`이 null이면 `CompareTag`에서 예외가 난다. 풀에서 재사용할 때 `from`이 매번 설정되는지 확인 필요 | 널 검사 |
| 2 | `Explode` | 이펙트는 `Instantiate`로 만들고 투사체는 풀에 반환한다. 이펙트가 풀링되지 않아 발사량이 많으면 생성 비용이 쌓인다 | 성능 |
| 3 | `StartBulletLogic` | `Rigidbody.velocity`는 Unity 6에서 `linearVelocity`로 바뀌었다. 사용 버전에서 확인 필요 | 버전 |
| 4 | 상단 `using` | `System.Collections`, `System.Collections.Generic`, `System.Reflection`, `UnityEngine.Rendering`은 이 코드에서 쓰이지 않는다 | 정리 |
| 5 | `collisionBulletPrefab` | 쓰는 곳이 주석 처리된 블록뿐이다 | 정리 |

## 6. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [monstermaniacrnd.md](monstermaniacrnd.md) | PRJ-MAI-004-DO | 특수 몬스터 연구 개발 일지 |
| [GravityBullet.cs](https://github.com/shion0202/2025_Project_ProjectRecombination/blob/main/Branch/Assets/_GameAssets/01.%20Scripts/GameObjects/Bullet/GravityBullet.cs) | | 팀 레포. 접근 권한이 필요할 수 있다 |

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM D&O 형식으로 재작성. 코드는 원본 그대로 두고 확인 결과를 표로 추가 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 투사체를 `Destroy` 대신 풀에 반환하는 이유는 무엇인가?
- [ ] 상속으로 투사체를 늘릴 때의 장점과 부모 API가 바뀔 때의 문제를 내 경험으로 설명하면?
