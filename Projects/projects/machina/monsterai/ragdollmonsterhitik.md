# 래그돌 피격 및 사망 처리 (Ragdoll)

{% hint style="warning" %}
{% endhint %}

### 요약 / 개요

기존의 3D 모델 리소스의 본 게임 오브젝트에 콜라이더 컴포넌트와 리지드바디, Character Joint를 활용해 isKinematic 설정을 일괄적으로 켜고 끄는 것으로 활성화 가능한 레그돌(ragdoll)을 구현했다.

레그돌의 상태는 RagdollController 클래스에서 관리한다.

* 애니메이터가 등록되어 있지 않으면 직접 찾아서 등록한다.
* 중력을 받을 중심 리지드바디가 등록되어 있지 않으면 직접 찾아 등록한다.
* 레그돌 구현을 위해 설정한 리지드바디 게임 오브젝트와 콜라이더를 전부 찾아 등록한다.
* 초기에는 레그돌을 비활성화 상태로 설정한다.
* 메서드의 인자로 입력되는 불값에 의해 레그돌 활성화 여부를 결정한다.

활성화(b = true) 시의 동작:

* animator 비활성화
* mainRigidbody는 물리 통제를 받도록 isKinematic 비활성화
* 모든 레그돌 리지드바디의 isKinematic을 비활성화하여 엔진에서 물리 관리하도록 함
* 콜라이더 활성화 (특정 이름의 콜라이더는 제외)

인터페이스 메서드로 레그돌을 켜고 끄기 쉽게 구현되어 있으며, 레그돌이 활성화된 후 죽은 바디에 특정 방향으로 힘을 줄 수 있도록 ApplyForceToRagdoll 메서드를 추가했다.

몬스터가 사망하면 레그돌을 활성화해 축 늘어지게 만들 수 있다. 이를 위해 블랙보드에 RagdollController 컴포넌트를 가진 게임오브젝트를 등록해야 한다.

추가 메모:

* 실제 본과 따로 움직이는 고스트 본을 만들어, 오브젝트 충돌 시 움직일 리지드바디를 선택하고 충돌한 오브젝트의 이동 방향으로 힘을 가해 밀어낸 후 일정 시간 뒤 원래 위치로 되돌아오도록 구현할 수 있다.
* 총알 피격 시 플레이어의 블랙박스에 접근해 처리를 수행한다.

### 코드: RagdollController.cs

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
            mainRigidbody.isKinematic = b;

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

### 사용 시나리오 요약

* 몬스터가 사망하면 블랙보드에 등록된 RagdollController를 호출해 ActivateRagdoll()을 실행한다.
* 필요에 따라 ApplyForceToRagdoll로 외부 힘(예: 총알 충격 방향)을 가해 더 자연스러운 반응을 만들 수 있다.
* 고스트 본 및 충돌 처리 로직을 추가하면 충돌 시 특정 파트만 물리적으로 반응하게 하거나 일정 시간 뒤 원위치 복귀 같은 행동을 구현할 수 있다.

### 임베디드 이미지

* topics/assets/images/스크린샷 2025-11-17 13.28.20.png
* topics/assets/images/스크린샷 2025-11-17 13.58.04.png
* topics/assets/images/스크린샷 2025-11-17 14.17.12.png
* topics/assets/images/스크린샷 2025-11-17 14.33.55.png

(위 파일들은 문서에 첨부된 이미지 자원입니다.)
