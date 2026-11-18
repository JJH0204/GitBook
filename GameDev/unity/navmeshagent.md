# 내비메시 에이전트 클릭 이동

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UNI-003-MP |
| 목적 | `NavMeshAgent`와 `CharacterController`를 함께 써서 마우스 클릭으로 캐릭터를 이동시킨다 |
| 적용 대상 | Unity 2022.2 이상, AI Navigation 패키지(`com.unity.ai.navigation`). 버전 확인 필요 |
| 소요 시간 | 약 30분 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정리했으며 Unity에서 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [charactercontroller.md](charactercontroller.md) | GMD-UNI-001-MP | 캐릭터 컨트롤러 이동 구현 |
| [AI Navigation 패키지 문서](https://docs.unity3d.com/Packages/com.unity.ai.navigation@latest) | | 외부 문서 |
| [NavMeshAgent.nextPosition](https://docs.unity3d.com/ScriptReference/AI.NavMeshAgent-nextPosition.html) | | Unity ScriptReference |

### 1.1 NavMeshAgent 속성

| 설정 | 뜻 |
|---|---|
| `Agent Type` | 반지름, 높이, 오를 수 있는 경사·턱. `NavMeshSurface`와 같은 타입이어야 한다 |
| `Base Offset` | 에이전트 기준점과 오브젝트 피벗 사이의 높이 차이 |
| `Speed` / `Angular Speed` / `Acceleration` | 최고 속도, 회전 속도, 가속도 |
| `Stopping Distance` | 목적지에서 이만큼 떨어지면 멈춘다 |
| `Auto Braking` | 목적지 근처에서 감속한다 |
| `Obstacle Avoidance` | 다른 에이전트를 피하는 품질과 우선순위(`Priority`) |
| `Area Mask` | 지나갈 수 있는 영역 종류 |

### 1.2 NavMeshAgent 주요 멤버

| 멤버 | 설명 |
|---|---|
| `SetDestination(Vector3)` | 목적지를 지정하고 경로 계산을 요청한다. 계산은 비동기로 진행될 수 있다 |
| `pathPending` | 경로 계산이 끝나지 않았으면 true다 |
| `remainingDistance` | 목적지까지 남은 거리다. `pathPending`이 true인 동안은 정확하지 않고 0일 수 있다 |
| `velocity` | 에이전트가 계산한 현재 속도다 |
| `nextPosition` | 에이전트가 계산한 다음 위치다. `updatePosition = false`일 때 이 값으로 직접 위치를 맞춘다 |
| `updatePosition` / `updateRotation` | 에이전트가 위치와 회전을 직접 갱신할지 정한다 |

* 움직이는 장애물은 `NavMeshObstacle`을 쓴다. `Carve`를 켜면 NavMesh에 구멍을 낸다.
* 떨어진 발판 사이 점프는 `NavMeshLink`로 만든다.

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Unity Editor | 2022.2 이상 | |
| 2 | AI Navigation 패키지 | `com.unity.ai.navigation` | Package Manager에서 설치 |
| 3 | 캐릭터 | `CharacterController` 포함 오브젝트 | GMD-UNI-001-MP |
| 4 | 바닥 | `Collider` 포함, 레이어 `Ground` | 클릭 위치 검사용 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: `remainingDistance`는 `pathPending`이 true인 동안 0일 수 있다. 이 값만 보고 "도착했다"고 판단하면 클릭 직후 캐릭터가 멈춘다. 코드는 `!pathPending` 조건을 함께 검사한다.
{% endhint %}

{% hint style="info" %}
NOTE: `updatePosition = false`로 직접 옮길 때는 `navMeshAgent.nextPosition`과 실제 위치가 어긋나지 않게 맞춘다. 어긋나면 에이전트의 내부 위치와 캐릭터 위치가 달라져 경로가 틀어진다.
{% endhint %}

{% hint style="info" %}
NOTE: Unity 6 기본 설정(새 Input System 전용)에서는 `Input.GetMouseButton`이 동작하지 않는다. `Project Settings > Player > Active Input Handling`을 확인한다. 버전 확인 필요.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 씬을 저장한다(`Ctrl+S`) | 제목 표시줄에 `*`가 없다 |
| 2 | `Window > Package Manager`에서 `AI Navigation`을 설치한다 | 목록에 `AI Navigation`이 설치됨으로 표시된다 |
| 3 | 캐릭터에 `CharacterController`가 있는지 확인한다 | Inspector에 `Character Controller`가 보인다 |

## 5. 절차

### A. NavMesh 굽기

1. (5-A-01) 바닥(또는 바닥들의 부모)에 `NavMeshSurface` 컴포넌트를 추가한다. → 결과: Inspector에 `Agent Type`, `Collect Objects`, `Include Layers`, `Use Geometry`가 보인다.
2. (5-A-02) NavMesh를 만들 대상을 정한다: `Collect Objects`(전체 / 볼륨 안 / 이 오브젝트의 자식), `Include Layers`, `Use Geometry`(렌더 메시 / 물리 콜라이더).
3. (5-A-03) `Bake` 버튼을 누른다. → 결과: Scene 뷰에서 걸을 수 있는 영역이 파랗게 표시된다.

### B. 에이전트 구성

1. (5-B-01) 캐릭터에 `NavMeshAgent`를 추가한다. → 결과: Inspector에 `Agent Type`, `Speed`, `Stopping Distance` 등이 보인다.
2. (5-B-02) `Agent Type`을 `NavMeshSurface`와 같은 타입으로 맞춘다.
3. (5-B-03) 캐릭터를 NavMesh 위(파란 영역)에 놓는다.

### C. 스크립트 작성

1. (5-C-01) `ClickMove.cs`를 만들어 캐릭터에 붙인다.
2. (5-C-02) 아래 코드를 붙여 넣는다.
3. (5-C-03) `Ground Layer Mask`를 `Ground`로 지정한다.

{% code title="ClickMove.cs" %}
```csharp
using UnityEngine;
using UnityEngine.AI;

public class ClickMove : MonoBehaviour
{
    [SerializeField] private LayerMask groundLayerMask;

    private CharacterController characterController;
    private NavMeshAgent navMeshAgent;
    private Camera cam;

    private void Awake()
    {
        characterController = GetComponent<CharacterController>();
        navMeshAgent = GetComponent<NavMeshAgent>();
        navMeshAgent.updatePosition = false;
        navMeshAgent.updateRotation = true;

        cam = Camera.main;
    }

    private void Update()
    {
        if (Input.GetMouseButton(0))
        {
            // 카메라 피킹으로 이동할 위치 계산
            var ray = cam.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit, 100f, groundLayerMask))
            {
                // NavMeshAgent를 사용하여 이동
                navMeshAgent.SetDestination(hit.point);
            }
        }

        // 경로 계산이 끝난 뒤에만 남은 거리를 비교한다
        if (!navMeshAgent.pathPending && navMeshAgent.remainingDistance > navMeshAgent.stoppingDistance)
            characterController.Move(navMeshAgent.velocity * Time.deltaTime);
        else
            characterController.Move(Vector3.zero);
    }

    // 캐릭터가 바닥에 박혀 시작해서 주석 처리했다 (6.1절 참조)
    //private void LateUpdate()
    //{
    //    transform.position = navMeshAgent.nextPosition;
    //}
}
```
{% endcode %}

### D. 코드 흐름

1. (5-D-01) `Awake`: 에이전트가 위치를 직접 옮기지 않게(`updatePosition = false`) 하고 회전만 맡긴다.
2. (5-D-02) `Update`: 마우스 좌클릭 입력을 확인한다.
3. (5-D-03) 클릭한 스크린 좌표를 `Ray`로 바꾸고 `Raycast`로 지면과 충돌했는지 검사한다.
4. (5-D-04) 충돌한 지점을 목적지로 설정한다(`SetDestination`).
5. (5-D-05) 경로 계산이 끝났고 남은 거리가 멈춤 거리보다 크면 에이전트가 계산한 속도로 `CharacterController`를 이동하고, 아니면 정지한다.
6. (5-D-06) `LateUpdate`에서 캐릭터 위치를 에이전트 위치(`nextPosition`)로 보정한다. 현재는 주석 처리했다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | Play 후 바닥을 좌클릭 | 캐릭터가 클릭 지점으로 이동한다 | 클릭 직후 멈추지 않는다 |
| 2 | 도착 | 목적지 근처에서 멈춘다 | `Stopping Distance` 이내에서 정지한다 |
| 3 | 장애물 뒤를 클릭 | 장애물을 돌아간다 | 장애물을 통과하지 않는다 |

### 6.1 알려진 문제

| 증상 | 가능 원인 | 조치 |
|---|---|---|
| Scene 실행 시 캐릭터가 바닥에 박힌 채 시작한다 | 원인 미확인. `nextPosition`이 가리키는 높이와 `CharacterController` 중심 높이의 차이로 추정한다 | `LateUpdate` 보정을 주석 처리했다. 플레이어의 초기 위치를 직접 설정한다. 확인 필요 |

## 7. 복구

1. (7-01) 변경을 되돌린다: `Ctrl+Z`를 누른다. 저장 후에는 `NavMeshSurface`, `NavMeshAgent`, `ClickMove`를 제거한다.
2. (7-02) 굽기 결과를 지우려면 `NavMeshSurface`의 `Clear`를 누른다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | AMM 형식으로 재작성. `remainingDistance` 비교에 `!pathPending`을 추가했고 원본에 없던 필드 선언과 `using`을 보충했다 |
