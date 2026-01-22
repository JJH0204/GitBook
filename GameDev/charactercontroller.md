# CharacterController

{% hint style="warning" %}
Switch to EXCALIDRAW VIEW in the MORE OPTIONS menu of this document to fully interact with the drawing.\
You can decompress drawing data with the command palette: "Decompress current Excalidraw file". For more info check in plugin settings under "Saving".
{% endhint %}

## Excalidraw Data

### Text Elements

CharacterController 컴포넌트를 활용해서 캐릭터 이동을 구현할 수 있다. ^bFtpulvw

Rigidbody에서 변경한 내용 ^rkKTN34a

컴포넌트 캐싱 ^Cvn9mnI6

characterController에 isGrounded 필드 값으로 바닥인지 확인이 가능하다. ^Rc25hweK

키 입력을 Vector 객체에 저장 ^T6PwbWMj

CharacterController 컴포넌트에 이동 메서드 호출해 사용(왜... 에러가 발생하는 걸까?) ^Y0LJIDyp

{ ^GBGHHJZu

} ^dZZUS5Se

점프, 대쉬, 중력, 저항 으로 인한 물리 처리 결과 값을 \_calcVelocity 값에 저장하고 위와 같은 방법으로 CharacterController에 처리 ^vusiOwEm

### C# Example: CharControllerCharacter

{% code title="CharControllerCharacter.cs" %}
```csharp
using UnityEngine;

public class CharControllerCharacter : MonoBehaviour
{
    #region Variables
    [SerializeField] private float fSpeed = 5f;
    [SerializeField] private float fJumpHeight = 2f;
    [SerializeField] private float fDashDistance = 5f;
    
    // CharacterController 관련 변수
    [SerializeField] private float fGravity = 9.8f;        // 중력
    [SerializeField] private Vector3 vDrags;               // 저항
    
    private Vector3 _calcVelocity;                          // 최종 속도
    // ==========================================
    
    [SerializeField] private CharacterController characterController;
    [SerializeField] private Vector3 vInputDirection = Vector3.zero;

    private bool _isGrounded;
    [SerializeField] private LayerMask groundLayerMask;
    [SerializeField] private float fGroundCheckDistance = 0.3f;
    #endregion

    private void Start()
    {
        characterController = GetComponent<CharacterController>();
    }

    private void Update()
    {
        // Check Ground Status
        _isGrounded = characterController.isGrounded;    // CheckGroundStatus();
        if (_isGrounded && _calcVelocity.y < 0)
        {
            _calcVelocity.y = 0f;                       // 바닥에 닿았을 때 Y축 속도를 0으로 초기화
        }
        
        // Movement Direction
        var vMovement = new Vector3(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical"));
        // TODO: transform.positionWithLocalOffset assign attempt for 'CharControllerCharacter' is not valid. Input positionWithLocalOffset is { NaN, NaN, NaN }.
        characterController.Move(vMovement * (fSpeed * Time.deltaTime));
        
        // Normalize Input Direction
        if (vMovement != Vector3.zero)
        {
            transform.forward = vInputDirection;
        }

        // Jump & Dash & Gravity & Drag
        ProcessJump();
        ProcessDash();
        ProcessGravity();
        ProcessDrag();
        
        // 움직임 최종 적용
        // TODO: transform.positionWithLocalOffset assign attempt for 'CharControllerCharacter' is not valid. Input positionWithLocalOffset is { NaN, NaN, NaN }.
        characterController.Move(_calcVelocity * Time.deltaTime);
        
    }

    private void FixedUpdate()
    {
        // 최종 이동 처리
        // characterController.MovePosition(characterController.position + (vInputDirection * fSpeed * Time.fixedDeltaTime));
    }

    #region Methods
    private void ProcessJump()
    {
        // Process Jump
        if (!Input.GetButtonDown("Jump") || !_isGrounded) return;
        
        _calcVelocity.y += Mathf.Sqrt(fJumpHeight * -2f * Physics.gravity.y);
        
    }

    private void ProcessDash()
    {
        // Process Dash
        if (Input.GetButtonDown("Dash"))
        {
            Vector3 vDashVelocity = Vector3.Scale(transform.forward,
                fDashDistance * new Vector3(Mathf.Log(1f / ((Time.deltaTime * vDrags.x) + 1)) / -Time.deltaTime,
                0,
                Mathf.Log(1f / ((Time.deltaTime * vDrags.z) + 1)) / -Time.deltaTime));
            _calcVelocity += vDashVelocity;
        }
    }

    private void ProcessDrag()
    {
        _calcVelocity.x /= + vDrags.x * Time.deltaTime;
        _calcVelocity.z /= + vDrags.z * Time.deltaTime;
        _calcVelocity.y /= + vDrags.y * Time.deltaTime;
    }

    private void ProcessGravity()
    {
        _calcVelocity.y += fGravity * Time.deltaTime;
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

        if (Physics.Raycast(transform.position + (Vector3.up * 0.1f), Vector3.down, out raycastHit, fGroundCheckDistance, groundLayerMask))
        {
            _isGrounded = true;
        }
        else
        {
            _isGrounded = false;
        }
    }
    #endregion
}
```
{% endcode %}

^FMkMovIf

transform.positionWithLocalOffset assign attempt for 'CharControllerCharacter' is not valid.\
Input positionWithLocalOffset is { NaN, NaN, NaN }. ^jetEcMDg

저항 값을 계산하는 로직에서 0을 나누려는 시도를 하여서 NaN 에러가 발생하는 것이었다...\
에초에 말이 안되는 수식이긴 했어... ^R5P2VtMn

잘못된 ProcessDrag (원본)

```csharp
private void ProcessDrag()
{
    _calcVelocity.x /= + vDrags.x * Time.deltaTime;
    _calcVelocity.z /= + vDrags.z * Time.deltaTime;
    _calcVelocity.y /= + vDrags.y * Time.deltaTime;
}
```

수정된 ProcessDrag (안전한 방식)

{% code title="ProcessDrag (fixed)" %}
```csharp
private void ProcessDrag()
{
    _calcVelocity.x *= 1f / (1f + vDrags.x * Time.deltaTime);
    _calcVelocity.y *= 1f / (1f + vDrags.y * Time.deltaTime);
    _calcVelocity.z *= 1f / (1f + vDrags.z * Time.deltaTime);
}
```
{% endcode %}

무조건 1이상 값으로 나눗셈을 하여 저항 계산에서 0을 나누는 상황을 방지 ^Moro6RgW

중력 값도 양수가 아닌 음수로 설정해야 한다.\
(양수는 하늘로 솓아오름) ^MfILSGQw

흠... 다시 만들어야 겠는걸 ^zPEKGqwW

### Embedded Files

* a0ab0db23e5118b261abd740c89d55944aa6f832: \[\[topics/assets/images/스크린샷 2025-06-13 오후 11.28.29.png]]
* 5779aec433ae8fc5bfb22aac40e55d20b2e98b04: \[\[topics/assets/images/스크린샷 2025-06-13 오후 11.08.47.png]]
* b8a5fc8515824a5540e81720f1d71c0f3d07b6d4: \[\[topics/assets/images/스크린샷 2025-06-14 오후 11.39.23.png]]

### Drawing (compressed)

```compressed-json
N4KAkARALgngDgUwgLgAQQQDwMYEMA2AlgCYBOuA7hADTgQBuCpAzoQPYB2KqATLZMzYBXUtiRoIACyhQ4zZAHoFAc0JRJQgEYA6bGwC2CgF7N6hbEcK4OCtptbErHALRY8RMpWdx8Q1TdIEfARcZgRmBShcZQUebQBGOJ4aOiCEfQQOKGZuAG1wMFAwYogSbggCADMeAA0AUX0hACEARUwAViaeAC16CmwANSMAdRTiyFhEcsDsKI5lYLGSzG4A

dh4AZm0NgA4ATh2NngAGHlX29o3V/hKYbni9jfjtHYAWdvjXx53j49W9vgFSAUEjqbgfV4vHgANk+7R+7WOj2hN0gkgQhGU0nu0Mhq1WiVeDyOrw2G2h1yBFXmizQx1REGYUFIbAA1ggAMJsfBsUjlADEDwJ2GSDM0uGwrOULKEHGIXJ5fIk/Nw7WIO0qlSWkEqhHw+AAyrBaehJBKNIFtYzmWyEMNQZJuK8GUyWeyjTATYzuWUGTKsRxwjk6Qy2

... (truncated for brevity — full compressed JSON remains unchanged in source)
```

(Note: the compressed JSON drawing is included verbatim in the original content above. In this markdown export it's preserved inside the code block.)
