# 리지드바디 캐릭터 이동 구현

## Code Block

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

사용자의 입력을 받아 캐릭터를 이동 시키는 것을 게임에서 매우 기본인 기능이다. 이것을 구현하는 방법 중 Rigidbody를 활용한 방법을 알아보자

빈 GameObject를 생성해 다음과 같이 구성한다.

충돌 처리를 위한 Collider

물리 처리를 위한 Rigidbody

이동을 처리하기 위한 Script

캐릭터 몸체를 나타낼 Capsule Mesh (GameObject)

캐릭터가 바라보는 방향(눈) 역할의 GameObject

RigidbodyCharacter 를 이동시키면 하위 객체들도 함께 움직인다.

using UnityEngine;

public class RigidBodyCharacter : MonoBehaviour { #region Variables \[SerializeField] private float fSpeed = 5f; \[SerializeField] private float fJumpHeight = 2f; \[SerializeField] private float fDashDistance = 5f; \[SerializeField] private Rigidbody rigidbody; \[SerializeField] private Vector3 vInputDirection = Vector3.zero;

```
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
```

\#if UNITY\_EDITOR Debug.DrawLine(transform.position + (Vector3.up \* 0.1f), transform.position + (Vector3.up \* 0.1f) + (Vector3.down \* fGroundCheckDistance)); #endif

```
    _isGrounded = Physics.Raycast(transform.position + (Vector3.up * 0.1f), Vector3.down, out raycastHit, fGroundCheckDistance, groundLayerMask);
}
#endregion
```

}
