# 캐릭터 컨트롤러 이동 구현

CharacterController 컴포넌트를 활용해서 캐릭터 이동을 구현할 수 있다.

Rigidbody 버전([리지드바디 캐릭터 이동 구현](rigidbody.md))에서 바꾼 점

* 컴포넌트 캐싱
* characterController의 isGrounded 필드 값으로 바닥인지 확인이 가능하다.
* 키 입력을 Vector 객체에 저장
* CharacterController 컴포넌트의 이동 메서드(`Move`)를 호출해 이동한다. 처음엔 NaN 에러가 났다 (원인은 아래 코드 뒤에 정리).

점프, 대쉬, 중력, 저항 으로 인한 물리 처리 결과 값을 \_calcVelocity 값에 저장하고 위와 같은 방법으로 CharacterController에 처리

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

transform.positionWithLocalOffset assign attempt for 'CharControllerCharacter' is not valid.\
Input positionWithLocalOffset is { NaN, NaN, NaN }.

저항 값을 계산하는 로직에서 0을 나누려는 시도를 하여서 NaN 에러가 발생하는 것이었다...\
에초에 말이 안되는 수식이긴 했어...

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

무조건 1이상 값으로 나눗셈을 하여 저항 계산에서 0을 나누는 상황을 방지

중력 값도 양수가 아닌 음수로 설정해야 한다.\
(양수는 하늘로 솓아오름)

흠... 다시 만들어야 겠는걸

## 이 코드에 남은 문제

NaN 말고도 코드를 다시 읽어 보면 고칠 곳이 더 있다.

* `transform.forward = vInputDirection;`: `vInputDirection`은 어디서도 값을 넣지 않아 항상 (0, 0, 0)이다. 방향이 0 벡터라 회전이 안 되고 경고가 난다. 입력 벡터(`vMovement`)를 써야 한다.
* `ProcessGravity`가 `+fGravity`를 더해서 위로 솟는다 (위에서 직접 찾은 문제).
* 점프는 `Physics.gravity.y`로 계산하고 중력은 `fGravity`로 적용해서 두 값이 다르다. 같은 중력 값을 써야 점프 높이가 `fJumpHeight`와 맞는다 (v = √(2gh)).
* 바닥에서 y 속도를 0으로 만들면 `isGrounded`가 프레임마다 true/false를 오간다. 바닥에서는 작은 음수(예: -2)로 눌러 둔다.
* `Move`를 한 프레임에 두 번 호출한다. `isGrounded`는 마지막 `Move` 결과만 반영하므로, 입력 이동과 속도를 더해 한 번에 호출하는 편이 낫다.
* `Input.GetButtonDown("Dash")`는 Input Manager에 "Dash" 축이 없으면 에러가 난다. Unity 6 기본 설정(새 Input System 전용)에서는 `Input.GetAxis` 자체가 예외를 던진다. `Project Settings > Player > Active Input Handling`을 확인한다.

## CharacterController 정리

| 항목 | 내용 |
|---|---|
| `Move(motion)` | 이번 프레임에 움직일 **거리**를 받는다. `Time.deltaTime`을 직접 곱해야 하고, 중력은 적용하지 않는다 |
| `SimpleMove(speed)` | 초당 **속도**를 받는다. 중력을 자동 적용하고 y 성분은 무시해서 점프가 안 된다 |
| `isGrounded` | 마지막 `Move` 호출 중에 아래쪽이 무언가에 닿았는지 |
| 충돌 콜백 | `OnCollisionEnter` 대신 `OnControllerColliderHit(ControllerColliderHit hit)` |
| 주요 설정 | Slope Limit(오를 수 있는 경사), Step Offset(오를 수 있는 턱 높이), Skin Width(겹침 여유) |
| Rigidbody와 함께 | 같은 오브젝트에 함께 쓰지 않는다. 물리 엔진이 밀어내지 않으므로 넉백 같은 힘은 직접 계산한다 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 페이지 끝의 "다시 만들어야겠다"를 실행한다. 위 문제를 반영해 `Move`를 한 번만 호출하는 버전으로 다시 짠다.
- [ ] CharacterController와 Rigidbody 이동을 각각 언제 고를지, 장단점 2개씩 쓴다.
- [ ] NaN이 한 번 생기면 왜 위치 전체가 망가지는지(NaN의 연산 성질) 쓴다.
