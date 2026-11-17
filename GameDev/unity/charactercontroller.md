# 캐릭터 컨트롤러 이동 구현

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UNI-001-MP |
| 목적 | `CharacterController.Move`로 입력 이동, 점프, 대시, 중력을 구현한다 |
| 적용 대상 | Unity 3D, 기존 Input Manager 사용 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 코드를 읽고 오류를 정정했으며 Unity에서 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [rigidbody.md](rigidbody.md) | GMD-UNI-002-MP | 리지드바디 캐릭터 이동 구현 |
| [navmeshagent.md](navmeshagent.md) | GMD-UNI-003-MP | 내비메시 에이전트 클릭 이동 |

### 1.1 CharacterController 속성

| 항목 | 내용 |
|---|---|
| `Move(motion)` | 이번 프레임에 움직일 **거리**를 받는다. `Time.deltaTime`을 직접 곱해야 하고 중력은 적용하지 않는다 |
| `SimpleMove(speed)` | 초당 **속도**를 받는다. 중력을 자동 적용하고 y 성분은 무시하므로 점프가 안 된다 |
| `isGrounded` | 마지막 `Move` 호출 중에 아래쪽이 무언가에 닿았는지 나타낸다 |
| 충돌 콜백 | `OnCollisionEnter` 대신 `OnControllerColliderHit(ControllerColliderHit hit)`를 쓴다 |
| `Slope Limit` | 오를 수 있는 경사 각도 |
| `Step Offset` | 오를 수 있는 턱 높이 |
| `Skin Width` | 겹침 여유 |
| `Rigidbody`와 함께 사용 | 같은 오브젝트에 함께 쓰지 않는다. 물리 엔진이 밀어내지 않으므로 넉백 같은 힘은 직접 계산한다 |

### 1.2 Rigidbody 버전과 바뀐 점

* 컴포넌트를 캐싱한다.
* `isGrounded`로 접지를 확인한다.
* 키 입력을 `Vector3`에 저장한다.
* 이동 메서드 `Move`를 호출해 이동한다.
* 점프, 대시, 중력, 저항의 계산 결과를 `_calcVelocity`에 저장하고 `Move`로 처리한다.

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Unity Editor | 버전 확인 필요 | 3D 프로젝트 |
| 2 | 바닥 오브젝트 | `Collider` 포함 | |
| 3 | Input Manager 축 | `Horizontal`, `Vertical`, `Jump`, `Dash` | `Dash`는 기본으로 없어 직접 추가한다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 값이 NaN인 벡터로 `Move`를 호출하면 `transform.positionWithLocalOffset assign attempt ... is not valid. Input positionWithLocalOffset is { NaN, NaN, NaN }` 오류가 나고 위치 전체가 망가진다. 0으로 나누는 계산(저항 처리)을 쓰지 않는다. NaN 원인과 정정은 6.1절에 정리했다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `CharacterController.Move`는 중력을 적용하지 않는다. 중력은 코드에서 직접 더해야 하며 값은 음수(-9.81 등)여야 한다. 양수를 쓰면 캐릭터가 위로 솟는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `isGrounded`는 마지막 `Move` 결과만 반영한다. 바닥에서 y 속도를 0으로 만들면 프레임마다 true와 false를 오간다. 바닥에서는 작은 음수(-2)로 눌러 둔다. 경사면과 가장자리에서도 값이 흔들릴 수 있다.
{% endhint %}

{% hint style="info" %}
NOTE: Unity 6 기본 설정(새 Input System 전용)에서는 `Input.GetAxis`가 예외를 던진다. `Project Settings > Player > Active Input Handling`을 확인한다. 버전 확인 필요.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 씬을 저장한다(`Ctrl+S`) | 제목 표시줄에 `*`가 없다 |
| 2 | `Edit > Project Settings > Input Manager`에서 `Dash` 축을 추가한다 | 축 목록에 `Dash`가 있다 |
| 3 | 바닥에 `Collider`가 있는지 확인한다 | Inspector에 `Collider`가 보인다 |

## 5. 절차

### A. 캐릭터 구성

1. (5-A-01) 빈 `GameObject`를 만들고 `CharacterController` 컴포넌트를 추가한다. → 결과: Inspector에 `Slope Limit`, `Step Offset`, `Skin Width`가 보인다.
2. (5-A-02) 몸체로 쓸 `Capsule` 메시를 자식으로 추가한다.
3. (5-A-03) `CharControllerCharacter.cs`를 만든다.
4. (5-A-04) 아래 코드를 붙여 넣는다.
5. (5-A-05) 스크립트를 오브젝트에 붙이고 `V Drags`를 설정한다(예: x=5, y=0, z=5). → 결과: `Speed`, `Jump Height`, `Dash Distance`, `Gravity`, `V Drags`가 보인다.
6. (5-A-06) `Gravity`를 -9.81로 설정한다.

{% hint style="info" %}
NOTE: `V Drags`의 x, z가 0이면 대시 속도가 0이 된다(`Mathf.Log(1)`이 0). 0보다 큰 값을 넣는다.
{% endhint %}

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
    [SerializeField] private float fGravity = -9.81f;      // 중력 (음수)
    [SerializeField] private Vector3 vDrags;               // 저항

    private Vector3 _calcVelocity;                          // 최종 속도
    // ==========================================

    [SerializeField] private CharacterController characterController;

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
            _calcVelocity.y = -2f;                       // 바닥에 눌러 둔다(0이면 isGrounded가 흔들린다)
        }

        // Movement Direction
        var vMovement = new Vector3(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical"));

        // Normalize Input Direction
        if (vMovement != Vector3.zero)
        {
            transform.forward = vMovement;
        }

        // Jump & Dash & Gravity & Drag
        ProcessJump();
        ProcessDash();
        ProcessGravity();
        ProcessDrag();

        // 움직임 최종 적용: Move는 한 프레임에 한 번만 호출한다
        characterController.Move((vMovement * fSpeed + _calcVelocity) * Time.deltaTime);
    }

    #region Methods
    private void ProcessJump()
    {
        // Process Jump
        if (!Input.GetButtonDown("Jump") || !_isGrounded) return;

        _calcVelocity.y += Mathf.Sqrt(fJumpHeight * -2f * fGravity);
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
        // 1 이상의 값으로 나누므로 0으로 나누는 상황이 없다
        _calcVelocity.x *= 1f / (1f + vDrags.x * Time.deltaTime);
        _calcVelocity.y *= 1f / (1f + vDrags.y * Time.deltaTime);
        _calcVelocity.z *= 1f / (1f + vDrags.z * Time.deltaTime);
    }

    private void ProcessGravity()
    {
        _calcVelocity.y += fGravity * Time.deltaTime;
    }
    #endregion

    #region Helper Methods
    // 사용하지 않는 대체 접지 검사 (isGrounded 대신 레이캐스트로 확인할 때 쓴다)
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

### B. 실행

1. (5-B-01) Play를 누른다. → 결과: 캐릭터가 바닥 위에 선다.
2. (5-B-02) `WASD`와 `Space`, `Dash` 입력을 시험한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | Play 후 입력 없이 5초 대기 | 캐릭터가 바닥에 서 있다 | 위로 솟거나 가라앉지 않는다. `Console`에 오류가 없다 |
| 2 | `WASD` 입력 | 입력 방향으로 이동하고 바라본다 | 입력을 떼면 정지한다 |
| 3 | 바닥에서 `Space` | 점프 후 착지한다 | 최고 높이가 `Jump Height`(2) 근처다 |
| 4 | `Dash` 입력 | 바라보는 방향으로 빠르게 이동한다 | `Console`에 NaN 오류가 없다 |

### 6.1 원본의 오류와 정정 (참조)

| 번호 | 원본 증상 | 원인 | 정정 |
|---|---|---|---|
| 1 | NaN 오류, 위치 전체가 망가진다 | `ProcessDrag`가 `/= + vDrags.x * Time.deltaTime`로 나눠 `vDrags`가 0이면 0으로 나눈다 | `*= 1f / (1f + vDrags.x * Time.deltaTime)` |
| 2 | 캐릭터가 위로 솟는다 | `ProcessGravity`가 `+fGravity`를 더하고 값이 양수였다 | `fGravity`를 음수(-9.81)로 하고 그대로 더한다 |
| 3 | 회전이 안 되고 경고가 난다 | `transform.forward = vInputDirection`인데 `vInputDirection`에 값을 넣는 곳이 없어 항상 (0,0,0)이다 | 입력 벡터(`vMovement`)를 쓴다. 사용하지 않는 `vInputDirection` 필드는 삭제했다 |
| 4 | 점프 높이가 `Jump Height`와 맞지 않는다 | 점프는 `Physics.gravity.y`, 중력은 `fGravity`로 서로 다른 값을 썼다 | 점프도 `fGravity`를 쓴다 (v = √(2gh)) |
| 5 | `isGrounded`가 true와 false를 오간다 | 바닥에서 y 속도를 0으로 만들었다 | -2로 눌러 둔다 |
| 6 | 접지 상태가 한 프레임 늦거나 틀리다 | `Move`를 한 프레임에 두 번 호출했고 `isGrounded`는 마지막 `Move`만 반영한다 | 입력 이동과 속도를 더해 `Move`를 한 번 호출한다 |
| 7 | `Dash` 축 오류 | Input Manager에 `Dash` 축이 없다 | 4절 준비 2번에서 축을 추가한다 |
| 8 | 컴파일은 되지만 쓰이지 않는 `FixedUpdate` | `CharacterController`에는 `MovePosition`이 없다 | 빈 `FixedUpdate`를 삭제했다 |

## 7. 복구

1. (7-01) 변경을 되돌린다: `Ctrl+Z`를 누른다. 저장 후에는 5-A에서 만든 오브젝트와 스크립트를 삭제한다.
2. (7-02) 준비 2번에서 추가한 `Dash` 축을 삭제한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | AMM 형식으로 재작성. 원본 코드의 NaN, 중력 부호, 방향 입력, `Move` 이중 호출 오류를 정정(6.1절) |
