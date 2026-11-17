# 리지드바디 캐릭터 이동 구현

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UNI-002-MP |
| 목적 | `Rigidbody`로 입력 이동, 점프, 대시를 하는 캐릭터를 만든다 |
| 적용 대상 | Unity 3D, 기존 Input Manager 사용. Unity 6에서는 일부 속성 이름이 다르다(3절) |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정리했으며 Unity에서 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [charactercontroller.md](charactercontroller.md) | GMD-UNI-001-MP | 캐릭터 컨트롤러 이동 구현 |
| [navmeshagent.md](navmeshagent.md) | GMD-UNI-003-MP | 내비메시 에이전트 클릭 이동 |

### 1.1 이동 방법 비교

| 이동 방법 | 특징 |
|---|---|
| 속도 직접 설정 (`linearVelocity`) | 즉시 원하는 속도가 된다. 조작감이 단단하다 |
| `AddForce(force, mode)` | 힘을 더한다. 관성과 질량이 반영된다 |
| `MovePosition(pos)` | 키네마틱 `Rigidbody`를 보간과 함께 옮길 때 쓴다. 키네마틱이 아니면 충돌 처리가 부정확할 수 있다(확인 필요) |
| `transform.position` 직접 변경 | 물리를 무시한다. 벽을 뚫거나 충돌이 튈 수 있어 피한다 |

### 1.2 `ForceMode`

| `ForceMode` | 질량 반영 | 적용 방식 | 쓰임 |
|---|---|---|---|
| `Force` | O | 계속 (매 물리 프레임) | 추진, 바람 |
| `Acceleration` | X | 계속 | 질량과 무관한 가속 |
| `Impulse` | O | 한 번에 | 폭발, 타격 |
| `VelocityChange` | X | 한 번에 | 점프, 대시 (아래 코드) |

### 1.3 Unity 6 이름 변경

| 이전 이름 | Unity 6 이름 |
|---|---|
| `velocity` | `linearVelocity` |
| `drag` | `linearDamping` |
| `angularDrag` | `angularDamping` |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Unity Editor | 버전 확인 필요 | 3D 프로젝트 |
| 2 | 바닥 오브젝트 | `Collider` 포함, 레이어 `Ground` | 접지 검사용 |
| 3 | Input Manager 축 | `Horizontal`, `Vertical`, `Jump`, `Dash` | `Dash`는 기본으로 없어 직접 추가한다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 입력은 `Update`에서 읽고 물리 처리(`MovePosition`, `AddForce`)는 `FixedUpdate`에서 한다. `GetButtonDown`은 한 프레임만 true이므로 `FixedUpdate`에서 읽으면 입력을 놓친다. 아래 코드는 `Update`에서 플래그를 세우고 `FixedUpdate`에서 처리한다.
{% endhint %}

{% hint style="info" %}
NOTE: 대시 계산은 `rigidbody.drag`를 쓴다. Unity 6에서는 `drag`가 `linearDamping`으로 바뀌었다(1.3절). 버전 확인 필요. `drag`가 0이면 대시 속도가 0이 된다. Inspector에서 `Drag`를 0보다 크게 설정한다.
{% endhint %}

{% hint style="info" %}
NOTE: Unity 6 기본 설정(새 Input System 전용)에서는 `Input.GetAxis`가 예외를 던진다. `Project Settings > Player > Active Input Handling`을 확인한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 씬을 저장한다(`Ctrl+S`) | 제목 표시줄에 `*`가 없다 |
| 2 | `Edit > Project Settings > Input Manager`에서 `Dash` 축을 추가한다 | 축 목록에 `Dash`가 있다 |
| 3 | 바닥 오브젝트의 레이어를 `Ground`로 지정한다 | Inspector의 `Layer`가 `Ground`다 |

## 5. 절차

### A. 캐릭터 오브젝트 구성

1. (5-A-01) 빈 `GameObject`를 만들고 이름을 `RigidbodyCharacter`로 정한다. → 결과: `Hierarchy`에 오브젝트가 보인다.
2. (5-A-02) `Collider`를 추가한다. → 결과: Inspector에 `Collider`가 보인다.
3. (5-A-03) `Rigidbody`를 추가한다. → 결과: Inspector에 `Rigidbody`가 보인다.
4. (5-A-04) 자식으로 `Capsule` 메시를 추가한다(몸체). → 결과: 캡슐이 보인다.
5. (5-A-05) 자식으로 빈 `GameObject`를 추가한다(바라보는 방향, 눈 역할). → 결과: 부모를 옮기면 자식도 함께 움직인다.
6. (5-A-06) `Rigidbody`의 `Constraints`에서 `Freeze Rotation`의 X와 Z를 켠다. → 결과: 캡슐이 넘어지지 않는다.

{% hint style="info" %}
NOTE: 카메라가 따라갈 때 떨리면 `Interpolate`를 켠다. 빠른 물체가 벽을 뚫으면 `Collision Detection`을 `Continuous`로 바꾼다.
{% endhint %}

### B. 스크립트 작성

1. (5-B-01) `RigidBodyCharacter.cs`를 만든다.
2. (5-B-02) 아래 코드를 붙여 넣는다.
3. (5-B-03) 스크립트를 `RigidbodyCharacter` 오브젝트에 붙인다. → 결과: Inspector에 `Speed`, `Jump Height`, `Dash Distance`, `Ground Layer Mask` 등이 보인다.
4. (5-B-04) `Ground Layer Mask`를 `Ground`로 지정한다.

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
    private bool _jumpRequested;   // Update에서 세우고 FixedUpdate에서 처리
    private bool _dashRequested;   // Update에서 세우고 FixedUpdate에서 처리
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

        // Jump & Dash 입력은 여기서 읽고, 물리 적용은 FixedUpdate에서 한다
        if (Input.GetButtonDown("Jump") && _isGrounded) _jumpRequested = true;
        if (Input.GetButtonDown("Dash")) _dashRequested = true;
    }

    /// <summary>
    /// FixedUpdate 메소드는 물리 엔진 위에서 실행되는 메소드이다.
    /// 게임의 프레임과 상관없이 고정적으로 호출되어 실행된다.
    /// 따라서 물리 연산을 수행하는 메소드는 FixedUpdate에서 실행해야 한다.
    /// </summary>
    private void FixedUpdate()
    {
        // 최종 이동 처리
        rigidbody.MovePosition(rigidbody.position + vInputDirection * (fSpeed * Time.fixedDeltaTime));

        ProcessJump();
        ProcessDash();
    }

    #region Methods
    private void ProcessJump()
    {
        // Process Jump
        if (!_jumpRequested) return;
        _jumpRequested = false;
        var vJumpVelocity = Vector3.up * Mathf.Sqrt(fJumpHeight * -2f * Physics.gravity.y);
        rigidbody.AddForce(vJumpVelocity, ForceMode.VelocityChange);
    }

    private void ProcessDash()
    {
        // Process Dash
        if (!_dashRequested) return;
        _dashRequested = false;
        var vDashVelocity = Vector3.Scale(transform.forward,
            fDashDistance * new Vector3(Mathf.Log(1f / ((Time.fixedDeltaTime * rigidbody.drag) + 1)) / -Time.fixedDeltaTime,
                0,
                Mathf.Log(1f / ((Time.fixedDeltaTime * rigidbody.drag) + 1)) / -Time.fixedDeltaTime));
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

### C. 점프 공식

1. (5-C-01) 높이 h까지 올라가는 데 필요한 초기 속도를 v = √(2gh)로 구한다.
2. (5-C-02) 코드의 `Mathf.Sqrt(fJumpHeight * -2f * Physics.gravity.y)`가 이 식이다. `gravity.y`는 음수이므로 -2를 곱한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | Play 후 `WASD` 입력 | 캐릭터가 입력 방향으로 이동하고 바라본다 | 입력을 떼면 이동이 멈춘다 |
| 2 | 바닥에서 `Space` | 캐릭터가 점프한다 | 최고 높이가 `Jump Height`(2) 근처다 |
| 3 | 공중에서 `Space` | 점프하지 않는다 | `_isGrounded`가 false인 동안 반응이 없다 |
| 4 | `Dash` 입력 (`Drag`가 0보다 크게 설정된 상태) | 바라보는 방향으로 순간 이동한다 | 이동 거리가 `Dash Distance` 근처다 |

## 7. 복구

1. (7-01) 변경을 되돌린다: `Ctrl+Z`를 누른다. 저장 후에는 5-A와 5-B에서 만든 오브젝트와 스크립트를 삭제한다.
2. (7-02) 준비 2번에서 추가한 `Dash` 축을 삭제한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | AMM 형식으로 재작성. 점프·대시의 `AddForce`를 `FixedUpdate`로 옮김(`Update`에서는 플래그만 설정), 대시 계산의 `Time.deltaTime`을 `Time.fixedDeltaTime`으로 변경 |
