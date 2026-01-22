# Rigidbody

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

## Excalidraw Data

### Text Elements

사용자의 입력을 받아 캐릭터를 이동 시키는 것을 게임에서 매우 기본인 기능이다. 이것을 구현하는 방법 중 Rigidbody를 활용한 방법을 알아보자 ^SQ5gj038

빈 GameObject를 생성해 다음과 같이 구성한다. ^qQW0gFd4

충돌 처리를 위한 Collider ^V0SgelFZ

물리 처리를 위한 Rigidbody ^akPbrfSv

이동을 처리하기 위한 Script ^Q7pkQgAB

캐릭터 몸체를 나타낼 Capsule Mesh (GameObject) ^J1nBOmyi

캐릭터가 바라보는 방향(눈) 역할의 GameObject ^LqxQybbn

RigidbodyCharacter 를 이동시키면 하위 객체들도 함께 움직인다. ^ckfTIehK

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

} ^844PQiJP

### Embedded Files

588b5e7ef76ff9a746d53ad4f6a5c04e6b02be60: \[\[topics/assets/images/스크린샷 2025-06-13 오후 11.07.34.png]]

5779aec433ae8fc5bfb22aac40e55d20b2e98b04: \[\[topics/assets/images/스크린샷 2025-06-13 오후 11.08.47.png]]

### Drawing

```compressed-json
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
```
