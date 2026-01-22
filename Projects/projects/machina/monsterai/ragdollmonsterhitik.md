# RagdollMonsterHitIK

{% hint style="warning" %}
Switch to EXCALIDRAW VIEW in the MORE OPTIONS menu of this document. You can decompress Drawing data with the command palette: "Decompress current Excalidraw file". For more info check in plugin settings under "Saving".
{% endhint %}

## Excalidraw Data

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

### Drawing (압축된 Excalidraw 데이터)

<details>

<summary>압축된 JSON 보기 / 복원용</summary>

```compressed-json
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

... (중략) ...
```

</details>
