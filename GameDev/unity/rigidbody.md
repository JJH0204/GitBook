# 리지드바디 캐릭터 이동 구현

사용자의 입력을 받아 캐릭터를 이동 시키는 것을 게임에서 매우 기본인 기능이다. 이것을 구현하는 방법 중 Rigidbody를 활용한 방법을 알아보자

빈 GameObject를 생성해 다음과 같이 구성한다.

* 충돌 처리를 위한 Collider
* 물리 처리를 위한 Rigidbody
* 이동을 처리하기 위한 Script
* 캐릭터 몸체를 나타낼 Capsule Mesh (GameObject)
* 캐릭터가 바라보는 방향(눈) 역할의 GameObject

RigidbodyCharacter 를 이동시키면 하위 객체들도 함께 움직인다.

{% code title="RigidBodyCharacter.cs" %}
```csharp
using UnityEngine;

public class RigidBodyCharacter : MonoBehaviour
{
    #region Variables
    [SerializeField] private float fSpeed = 5f;
    [SerializeField] private float fJumpHeight = 2f;
    [SerializeField] private float fDashDistance = 5f;
    [SerializeField] private Rigidbody rigidbody;
    [SerializeField] private Vector3 vInputDirection = Vector3.zero;

    private bool _isGrounded;
    [SerializeField] private LayerMask groundLayerMask;
    [SerializeField] private float fGroundCheckDistance = 0.3f;
    #endregion
    private void Start()
    {
        rigidbody = GetComponent<Rigidbody>();
    }

    private void Update()
    {
        // Check Ground Status
        CheckGroundStatus();

        // Init Direction
        vInputDirection = Vector3.zero;

        // Get Input Direction
        vInputDirection.x = Input.GetAxis("Horizontal");
        vInputDirection.z = Input.GetAxis("Vertical");

        // Normalize Input Direction
        if (vInputDirection != Vector3.zero)
        {
            transform.forward = vInputDirection;
        }

        // Jump & Dash
        ProcessJump();
        ProcessDash();
    }

    /// <summary>
    /// FixedUpdate 메소드는 물리 앤진 위에서 실행되는 메소드이다.
    /// 게임의 프레임과 상관없이 고정적으로 호출되어 실행된다.
    /// 따라서 물리 연산을 수행하는 메소드는 FixedUpdate에서 실행해야 한다.
    /// </summary>
    private void FixedUpdate()
    {
        // 최종 이동 처리
        rigidbody.MovePosition(rigidbody.position + vInputDirection * (fSpeed * Time.fixedDeltaTime));
    }

    #region Methods
    private void ProcessJump()
    {
        // Process Jump
        if (!Input.GetButtonDown("Jump") || !_isGrounded) return;
        var vJumpVelocity = Vector3.up * Mathf.Sqrt(fJumpHeight * -2f * Physics.gravity.y);
        rigidbody.AddForce(vJumpVelocity, ForceMode.VelocityChange);
    }

    private void ProcessDash()
    {
        // Process Dash
        if (!Input.GetButtonDown("Dash")) return;
        var vDashVelocity = Vector3.Scale(transform.forward,
            fDashDistance * new Vector3(Mathf.Log(1f / ((Time.deltaTime * rigidbody.drag) + 1)) / -Time.deltaTime,
                0,
                Mathf.Log(1f / ((Time.deltaTime * rigidbody.drag) + 1)) / -Time.deltaTime));
        rigidbody.AddForce(vDashVelocity, ForceMode.VelocityChange);
    }
    #endregion

    #region Helper Methods
    private void CheckGroundStatus()
    {
        RaycastHit raycastHit;

#if UNITY_EDITOR
        Debug.DrawLine(transform.position + (Vector3.up * 0.1f),
            transform.position + (Vector3.up * 0.1f) + (Vector3.down * fGroundCheckDistance));
#endif

        _isGrounded = Physics.Raycast(transform.position + (Vector3.up * 0.1f), Vector3.down, out raycastHit, fGroundCheckDistance, groundLayerMask);
    }
    #endregion
}
```
{% endcode %}

## Rigidbody 이동 정리

입력은 `Update`에서 읽고, 물리 처리는 `FixedUpdate`에서 한다. `GetButtonDown`처럼 한 프레임만 true인 입력은 `FixedUpdate`에서 읽으면 놓칠 수 있다.

| 이동 방법 | 특징 |
|---|---|
| 속도 직접 설정 (`linearVelocity`) | 즉시 원하는 속도가 된다. 조작감이 단단하다 |
| `AddForce(force, mode)` | 힘을 더한다. 관성과 질량이 자연스럽게 반영된다 |
| `MovePosition(pos)` | 키네마틱 Rigidbody를 보간과 함께 옮길 때 쓴다. 키네마틱이 아니면 순간이동처럼 동작한다 |
| `transform.position` 직접 변경 | 물리를 무시한다. 벽을 뚫거나 충돌이 튈 수 있어 피한다 |

| `ForceMode` | 질량 반영 | 적용 방식 | 쓰임 |
|---|---|---|---|
| `Force` | O | 계속 (매 물리 프레임) | 추진, 바람 |
| `Acceleration` | X | 계속 | 질량과 무관한 가속 |
| `Impulse` | O | 한 번에 | 폭발, 타격 |
| `VelocityChange` | X | 한 번에 | 점프, 대시 (위 코드) |

* 점프 속도 v = √(2gh): 높이 h까지 올라가려면 처음에 필요한 속도. 위 코드의 `Mathf.Sqrt(fJumpHeight * -2f * Physics.gravity.y)`가 이 식이다 (`gravity.y`는 음수라 -2를 곱한다).
* Unity 6에서 이름이 바뀌었다: `velocity` → `linearVelocity`, `drag` → `linearDamping`, `angularDrag` → `angularDamping`. 위 코드의 `rigidbody.drag`도 Unity 6에서는 `linearDamping`이다.
* 캡슐이 넘어지지 않게 Constraints에서 Freeze Rotation X, Z를 켠다.
* 카메라가 따라갈 때 떨리면 Interpolate를 켠다. 빠른 물체가 벽을 뚫으면 Collision Detection을 Continuous로 바꾼다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 점프 공식 v = √(2gh)를 "올라가는 동안 속도가 0이 될 때까지"라는 조건에서 직접 유도한다.
- [ ] `MovePosition` 대신 `linearVelocity`로 이동하도록 바꿔 보고, 벽에 부딪히거나 경사를 오를 때 무엇이 달라지는지 적는다.
- [ ] [캐릭터 컨트롤러 버전](charactercontroller.md)과 비교해서, 이 프로젝트에서 어느 쪽을 고를지 이유와 함께 쓴다.
