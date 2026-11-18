# [생성형 AI] 물리 질의와 충돌 이벤트

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UNI-005-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | `Physics.Raycast` 등 물리 질의와 `OnCollision`/`OnTrigger` 이벤트의 차이와 발생 조건을 이해한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (Unity에서 실행하지 않았다. 3D 물리(PhysX) 기준이다) |
| 개정 | R1 (2026-11-19) |

## 1. 정의

Unity 물리 엔진을 쓰는 방법은 두 가지다.

| 방식 | 설명 | 예 |
|---|---|---|
| 질의(Query) | 원하는 시점에 코드에서 "저기에 무엇이 있는가"를 묻는다 | 접지 검사, 시야 검사, 범위 공격 |
| 이벤트(Event) | 엔진이 접촉을 감지하면 메서드를 호출한다 | 총알 명중, 아이템 획득 영역 |

2D 물리는 `Physics2D`와 `OnCollisionEnter2D` 같은 별도 API를 쓴다. 이 문서는 3D 기준이다.

## 2. 구성 요소

### 2.1 질의 API

| API | 용도 | 반환 |
|---|---|---|
| `Physics.Raycast(origin, direction, out hit, maxDistance, layerMask)` | 직선으로 첫 충돌을 찾는다 | `bool`, `RaycastHit` |
| `Physics.SphereCast(origin, radius, direction, out hit, maxDistance, layerMask)` | 굵은 레이. 좁은 틈 검사에 쓴다 | `bool`, `RaycastHit` |
| `Physics.OverlapSphere(position, radius, layerMask)` | 구 범위 안의 콜라이더를 모두 찾는다 | `Collider[]` |
| `Physics.CheckSphere(position, radius, layerMask)` | 구 범위 안에 콜라이더가 있는지만 본다 | `bool` |
| `Physics.RaycastAll(...)` | 레이가 통과하는 모든 콜라이더 | `RaycastHit[]` |

`RaycastHit`의 주요 값은 다음과 같다.

| 필드 | 뜻 |
|---|---|
| `point` | 맞은 위치(월드 좌표) |
| `normal` | 맞은 면의 법선 |
| `distance` | 시작점에서 맞은 위치까지의 거리 |
| `collider` | 맞은 콜라이더 |

### 2.2 이벤트 메서드

| 메서드 | 호출 시점 | 인자 |
|---|---|---|
| `OnCollisionEnter` | 두 콜라이더가 닿기 시작한 프레임 | `Collision` |
| `OnCollisionStay` | 닿은 동안 매 물리 프레임 | `Collision` |
| `OnCollisionExit` | 떨어진 프레임 | `Collision` |
| `OnTriggerEnter` | 트리거 영역에 들어간 프레임 | `Collider` (상대) |
| `OnTriggerStay` | 영역 안에 있는 동안 매 물리 프레임 | `Collider` |
| `OnTriggerExit` | 영역을 나간 프레임 | `Collider` |

## 3. 동작 원리

### 3.1 충돌과 트리거의 차이

| 구분 | 충돌(Collision) | 트리거(Trigger) |
|---|---|---|
| 설정 | 일반 콜라이더 | 콜라이더의 `Is Trigger`를 켠다 |
| 물리 반응 | 서로 밀어낸다 | 통과한다. 겹침만 감지한다 |
| 이벤트 | `OnCollision...` | `OnTrigger...` |

### 3.2 이벤트가 오지 않을 때 확인할 것

| 확인 | 설명 |
|---|---|
| Rigidbody | 접촉하는 두 오브젝트 중 최소 하나(보통 움직이는 쪽)에 `Rigidbody`가 있어야 한다. 둘 다 정적 콜라이더면 이벤트가 없다 |
| Collider | 두 오브젝트 모두 `Collider`가 있어야 한다 |
| Is Trigger | 트리거 이벤트를 받으려면 한쪽 콜라이더의 `Is Trigger`를 켠다 |
| 메서드 위치 | 이벤트 메서드는 `Collider`나 `Rigidbody`가 있는 오브젝트의 스크립트에 있어야 한다 |
| 레이어 | `Edit > Project Settings > Physics`의 Layer Collision Matrix에서 두 레이어가 충돌하도록 켜져 있어야 한다 |
| 2D와 3D 혼용 | `Rigidbody2D`와 3D `Collider`는 서로 감지하지 않는다 |

키네마틱 `Rigidbody`가 포함된 조합의 세부 규칙은 Unity 매뉴얼의 충돌 조합 표를 본다. 버전 확인 필요.

### 3.3 Raycast 예제

```csharp
using UnityEngine;

public class GroundProbe : MonoBehaviour
{
    [SerializeField] LayerMask groundMask;   // Inspector에서 Ground 레이어를 고른다
    [SerializeField] float checkDistance = 0.3f;

    public bool IsGrounded()
    {
        // 발끝 약간 위에서 아래로 쏜다
        Vector3 origin = transform.position + Vector3.up * 0.1f;
        return Physics.Raycast(origin, Vector3.down, checkDistance, groundMask);
    }
}
```

### 3.4 범위 공격 예제

```csharp
// 반경 3 안의 Enemy 레이어 콜라이더를 찾는다
Collider[] hits = Physics.OverlapSphere(transform.position, 3f, enemyMask);
foreach (Collider c in hits)
{
    if (c.TryGetComponent(out Health health))   // Health는 직접 만든 컴포넌트라고 가정한다
        health.Take(10);
}
```

{% hint style="warning" %}
CAUTION: `OverlapSphere`는 호출마다 배열을 새로 만든다. 매 프레임 호출하면 GC 할당이 생긴다. 이 경우 미리 만든 배열을 넘기는 `Physics.OverlapSphereNonAlloc`을 쓴다. 이 API는 Unity 버전에 따라 이름과 상태가 바뀔 수 있으므로 버전 확인 필요. 할당 이야기는 [GC와 할당](../unity-csharp/day03-gc-allocation.md)을 본다.
{% endhint %}

{% hint style="info" %}
NOTE: 레이의 시작점이 콜라이더 안쪽이면 그 콜라이더는 맞지 않는 것으로 처리된다. 레이를 몸 안쪽에서 쏘지 않는다.
{% endhint %}

{% hint style="info" %}
NOTE: `layerMask`를 생략하면 대부분의 레이어에 맞는다. 자기 자신의 콜라이더에 맞아 오작동하는 경우가 많으므로 접지 검사나 시야 검사에는 마스크를 지정한다. 마스크를 코드에서 만들 때는 `1 << layerIndex`를 쓴다.
{% endhint %}

### 3.5 물리 호출 시점

물리 이벤트와 `Rigidbody` 제어는 `FixedUpdate` 주기로 처리된다. 입력은 `Update`에서 읽고, 힘을 가하는 일은 `FixedUpdate`에서 한다. 자세한 내용은 [시간: deltaTime, fixedDeltaTime, timeScale](time-deltatime.md)와 [MonoBehaviour 생명주기](../unity-csharp/day19-monobehaviour-lifecycle.md)를 본다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 콜라이더(Collider) | 충돌 모양을 나타내는 컴포넌트 |
| 트리거(Trigger) | 물리 반응 없이 겹침만 감지하는 콜라이더 |
| LayerMask | 질의가 포함할 레이어를 비트로 나타낸 값 |
| 키네마틱 | 물리 힘이 아니라 코드로만 움직이는 `Rigidbody` 설정 |

## 5. 더 보기

* [리지드바디 캐릭터 이동 구현](rigidbody.md): 접지 검사에 Raycast를 쓴다
* [전투 시스템 투사체 발사 설계](battlesystemdesign.md)
* [충돌 판정 수학](../gamemath/collision-math.md)
* [Unity ScriptReference: Physics](https://docs.unity3d.com/ScriptReference/Physics.html)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 충돌 이벤트가 오지 않았던 경험이 있으면 원인과 해결 방법을 적는다.
- [ ] 아이템 획득 영역에 충돌과 트리거 중 무엇을 쓸지, 이유와 함께 쓴다.
