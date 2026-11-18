# 래그돌 피격 및 사망 처리 (Ragdoll)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-MAI-008-DO |
| 유형 | D&O (구현 기록) |
| 목적 | 몬스터 사망 시 애니메이션에서 래그돌(ragdoll)로 전환하는 방법과, 피격 시 애니메이션과 물리를 섞는 IK 블렌딩을 정리한다 |
| 적용 대상 | Unity, Animator, Animation Rigging 패키지, 오브젝트 풀 사용 프로젝트 |
| 확인 상태 | 미검증 (코드를 읽고 정리했으며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 구성 요소

| 구성 요소 | 위치 | 역할 |
|---|---|---|
| `RagdollController` | 몬스터 루트 | 래그돌 켜기와 끄기, 래그돌에 힘 가하기 |
| 뼈대 콜라이더, 리지드바디, Character Joint | 모델의 뼈 게임 오브젝트 | 래그돌 물리 구성. `isKinematic`을 일괄로 켜고 끄는 방식이다 |
| `HitReactionController` | 몬스터 | 피격 시 리그 제약(constraint) 가중치를 블렌딩한다 |
| `HitboxToRigidbodyMapper` | 히트박스 | 히트박스에 대응하는 리지드바디를 반환한다 |
| 블랙보드 | AI | `RagdollController`를 가진 게임 오브젝트를 등록해 둔다 |

## 2. 동작 원리

### 2.1 사망 처리 (애니메이션 → 래그돌)

`RagdollController`는 시작할 때 다음을 한다.

1. 애니메이터가 등록되어 있지 않으면 같은 오브젝트에서 찾아 등록한다.
2. 중력을 받을 중심 리지드바디가 등록되어 있지 않으면 같은 오브젝트에서 찾아 등록한다.
3. 자식에 있는 리지드바디와 콜라이더를 모두 찾아 등록한다.
4. 래그돌을 비활성 상태로 둔다.

`SetRagdollState(b)`는 인자 `b`로 활성 여부를 정한다.

| 대상 | 활성(b = true) | 비활성(b = false) |
|---|---|---|
| Animator | 끈다 | 켠다 |
| 래그돌 리지드바디 `isKinematic` | 끈다(엔진 물리가 관리한다) | 켠다 |
| 콜라이더 | 켠다(이름이 `Heatbox`인 콜라이더는 제외) | 끈다(같은 예외) |

몬스터가 사망하면 FSM이 블랙보드에 등록된 `RagdollController`의 `ActivateRagdoll()`을 호출한다. 풀에 반환하기 전에는 `DeactivateRagdoll()`로 되돌린다. 필요하면 `ApplyForceToRagdoll`로 총알 충격 방향 같은 외부 힘을 준다.

### 2.2 피격 반응 (애니메이션 ↔ 물리 IK 블렌딩)

사망이 아닌 피격에서는 몸 전체를 래그돌로 바꾸지 않는다. 실제 뼈와 따로 움직이는 고스트 뼈를 두고, 리그 제약의 가중치로 애니메이션과 물리 결과를 섞는다.

| 순서 | 동작 |
|---|---|
| 1 | 맞은 히트박스에서 고스트 뼈의 리지드바디를 얻는다(`HitboxToRigidbodyMapper`) |
| 2 | `TakeHit`이 그 리지드바디의 `isKinematic`을 끄고 공격 방향으로 충격(Impulse, 크기 100)을 준다 |
| 3 | 목표 가중치(`targetWeight`)를 1로 설정한다. 0은 애니메이션, 1은 물리다 |
| 4 | `Update`에서 모든 `MultiParentConstraint`의 가중치를 목표 값으로 `Lerp`한다(`blendSpeed` 기본 10) |
| 5 | 반응 시간(`reactionDuration`, 기본 0.2초) 뒤 목표 가중치를 0으로 되돌려 애니메이션으로 복귀한다 |

{% hint style="info" %}
NOTE: 이 절의 내용은 원본 페이지에 구상 메모만 있던 부분(고스트 뼈, 일정 시간 뒤 복귀)을 팀 레포의 `HitReactionController.cs`를 읽고 보충한 것이다.
{% endhint %}

## 3. 코드: RagdollController.cs

원본 코드이며 `SetRagdollState`의 한 줄만 정정했다.

{% code title="RagdollController.cs" %}
```csharp
using UnityEngine;

public class RagdollController : MonoBehaviour
{
    [SerializeField] private Rigidbody[] ragdollRigidbodies;
    [SerializeField] private Collider[] ragdollColliders;
    
    [SerializeField] private Animator animator;
    [SerializeField] private Rigidbody mainRigidbody;

    private void Awake()
    {
        animator ??= GetComponent<Animator>();
        mainRigidbody ??= GetComponent<Rigidbody>();
        
        ragdollRigidbodies = GetComponentsInChildren<Rigidbody>();
        ragdollColliders = GetComponentsInChildren<Collider>();

        SetRagdollState(false);
    }

    private void SetRagdollState(bool b)
    {
        if (animator is not null)
        {
            animator.enabled = !b;
        }
        
        if (mainRigidbody is not null)
            mainRigidbody.isKinematic = !b; // 정정: 원본은 `= b`

        foreach (Rigidbody r in ragdollRigidbodies)
        {
            // if (r == mainRigidbody) continue;
            r.isKinematic = !b;
        }
        
        foreach (Collider c in ragdollColliders)
        {
            if (c.gameObject.name == "Heatbox") continue;
            c.enabled = b;
        }
    }

    public void ActivateRagdoll()
    {
        SetRagdollState(true);
    }

    public void DeactivateRagdoll()
    {
        SetRagdollState(false);
    }
    
    public void ApplyForceToRagdoll(Vector3 force, ForceMode forceMode = ForceMode.Impulse)
    {
        foreach (Rigidbody r in ragdollRigidbodies)
        {
            r.AddForce(force, forceMode);
        }
    }
}
```
{% endcode %}

### 3.1 코드 확인 결과

| 번호 | 위치 | 내용 | 분류 |
|---|---|---|---|
| 1 | `mainRigidbody.isKinematic = b` | 활성 때 `isKinematic`을 켜서 설명("물리 통제를 받도록 끈다")과 반대다. `!b`로 정정했다. 다만 `GetComponentsInChildren<Rigidbody>()`는 자기 자신도 포함하므로 뒤의 반복문이 같은 값을 다시 덮어써, 결과는 원본과 같았을 가능성이 크다 | 의미 오류 |
| 2 | `animator ??= ...`, `is not null` | `UnityEngine.Object`는 `==` 연산자를 재정의해 "파괴된 객체"를 null처럼 취급하는데, `??=`와 `is not null`은 이를 우회한다. 인스펙터에서 비운 필드가 있으면 검사가 의도와 다르게 동작할 수 있다. `== null`로 바꾸는 쪽이 안전하다 | 널 검사 |
| 3 | `"Heatbox"` | 문자열 비교다. 히트박스 이름의 오타(Hitbox)인지 실제 오브젝트 이름인지 씬에서 확인 필요. 값이 다르면 예외 처리가 동작하지 않는다 | 확인 필요 |
| 4 | `ApplyForceToRagdoll` | 모든 리지드바디에 같은 힘을 준다. 뼈 개수만큼 힘이 합쳐지므로 의도한 세기보다 크게 날아갈 수 있다 | 동작 주의 |
| 5 | `Awake` | 래그돌 비활성 때 `Heatbox` 외 모든 콜라이더를 끈다. 몸체용 콜라이더가 따로 있다면 함께 꺼진다 | 동작 주의 |

{% hint style="warning" %}
CAUTION: 사용하는 Unity 버전과 Animation Rigging 패키지 버전에 따라 `MultiParentConstraint`의 API와 동작이 다를 수 있다. 버전 확인 필요.
{% endhint %}

## 4. 코드 확인: 피격 반응 (`HitReactionController`)

| 번호 | 내용 | 분류 |
|---|---|---|
| 1 | `Update`에서 `Mathf.Lerp(현재, 목표, Time.deltaTime * blendSpeed)`를 쓴다. 프레임 속도에 따라 수렴 속도가 달라지는 지수 감쇠형 보간이다 | 동작 설명 |
| 2 | 현재 가중치는 첫 번째 제약(`rigConstraints[0]`)만 읽고 모든 제약에 같은 값을 적용한다 | 동작 설명 |
| 3 | `TakeHit`은 고스트 리지드바디의 `isKinematic`을 끄지만 다시 켜는 코드가 없다. `isKinematic`을 되돌리는 `ApplyHitReaction` 코루틴은 `private`이고 호출하는 곳이 없다 | 확인 필요 |
| 4 | `TakeHit`을 연속으로 맞으면 복귀 코루틴이 여러 개 돌아, 이전 코루틴이 가중치를 일찍 0으로 되돌릴 수 있다 | 동작 주의 |

## 5. 사용 시나리오

| 시나리오 | 호출 |
|---|---|
| 몬스터 사망 | 블랙보드의 `RagdollController.ActivateRagdoll()` |
| 사망 시 충격 방향 반영 | `ApplyForceToRagdoll(힘)` |
| 풀 반환 전 복구 | `DeactivateRagdoll()` |
| 피격 | `HitReactionController.TakeHit(공격 방향, 고스트 리지드바디)` |

원본의 추가 메모에는 "총알 피격 시 플레이어의 블랙박스에 접근해 처리를 수행한다"는 문장이 있다. 문맥이 남아 있지 않아 옮기지 않았다.

## 6. 참조

| 대상 | 링크 | 비고 |
|---|---|---|
| `RagdollController.cs` | [링크](https://github.com/shion0202/2025_Project_ProjectRecombination/blob/main/Branch/Assets/_GameAssets/01.%20Scripts/Monster/Animator/RagdollController.cs) | 팀 레포. 접근 권한이 필요할 수 있다 |
| `HitReactionController.cs` | [링크](https://github.com/shion0202/2025_Project_ProjectRecombination/blob/main/Branch/Assets/_GameAssets/01.%20Scripts/Monster/Animator/HitReactionController.cs) | 같은 레포 |
| `HitboxToRigidbodyMapper.cs` | [링크](https://github.com/shion0202/2025_Project_ProjectRecombination/blob/main/Branch/Assets/_GameAssets/01.%20Scripts/Monster/Animator/HitboxToRigidbodyMapper.cs) | 같은 레포 |
| FSM의 사망 처리 | [FSM 몬스터 AI](fsmmonsterai.md) | PRJ-MAI-001-DO |

## 7. 약어·용어

| 용어 | 뜻 |
|---|---|
| 래그돌(ragdoll) | 뼈마다 리지드바디와 조인트를 달아 물리로 늘어지게 만든 상태 |
| `isKinematic` | 켜면 물리 엔진의 힘을 받지 않고 코드나 애니메이션이 움직이는 리지드바디 |
| IK | Inverse Kinematics. 끝 지점의 목표 위치에 맞춰 관절을 계산하는 방식 |
| 고스트 뼈 | 실제 뼈와 따로 움직이는 물리용 뼈. 피격 반응에서 목표로 쓴다 |

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM D&O 형식으로 재작성. 깨진 이미지 참조 4건 삭제, 피격 반응(IK 블렌딩) 절 추가 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 사망은 전체 래그돌, 피격은 가중치 블렌딩으로 나눈 이유를 내 말로 설명하면?
- [ ] 래그돌을 켤 때 Animator를 꺼야 하는 이유는 무엇인가?
- [ ] 래그돌을 구현하다 겪은 문제와 해결 과정은 무엇인가?
