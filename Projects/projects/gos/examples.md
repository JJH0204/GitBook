# 조합 예제 5개

모든 예제는 GOS 코드에 실제로 있는 노드만 사용한다. 설정은 [guide-for-designers.md](guide-for-designers.md)의 설치를 마친 상태를 전제로 한다.

{% hint style="warning" %}
예제의 기대 결과는 코드를 읽고 판단한 것이며 유니티에서 실행해 확인하지 않았다(unverified). 수업 전에 강사가 먼저 따라 해 본다.
{% endhint %}

## 공통 준비

- Hierarchy에 `Ground`(Plane), `Player`(Capsule)를 만든다. `Player`의 Tag를 `Player`로 두고 `Rigidbody`를 추가한다.
- Hierarchy에 빈 오브젝트 `GOS`를 만들고 모든 노드를 이 아래에 만든다.
- 플레이어를 움직일 방법이 필요하다. 가장 쉬운 방법은 Play 중 Scene 창에서 `Player`를 직접 옮기는 것이다. 키보드로 움직이려면 아래 임시 스크립트를 `Player`에 붙인다(구 Input Manager 기준, unverified).

{% code title="PlayerMove.cs (수업용 임시 스크립트, GOS와 무관)" %}
```csharp
using UnityEngine;

public class PlayerMove : MonoBehaviour
{
    [SerializeField] private float speed = 5f;
    private Rigidbody _rb;

    private void Awake() { _rb = GetComponent<Rigidbody>(); }

    private void FixedUpdate()
    {
        var move = new Vector3(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical"));
        _rb.MovePosition(_rb.position + move * speed * Time.fixedDeltaTime);
    }
}
```
{% endcode %}

`Player`의 Rigidbody는 넘어지지 않게 Constraints의 Freeze Rotation X, Z를 체크해 둔다.

## 예제 1. 구역에 들어가면 문이 열린다

기대 결과: `Player`가 구역에 들어가면 문이 90도 회전해 열린다.

Hierarchy 구성

```
GOS
├─ DoorTrigger      (TriggerEnter + BoxCollider)
├─ OpenDoorIf       (Conditional)
└─ OpenDoor         (RotateObject)
DoorPivot           (빈 오브젝트, 문 경첩 위치)
└─ Door             (Cube, Scale 예: 2,3,0.2)
```

1. `DoorPivot`을 문의 경첩(회전축) 위치에 두고, `Door` 큐브를 그 자식으로 넣어 문 한쪽 끝이 `DoorPivot`에 오도록 옮긴다.
2. 우클릭 > VisualScripting > Input > TriggerEnter로 `DoorTrigger`를 만든다. 문 앞 영역에 놓고 Scale로 크기를 키운다.

| 노드 | 설정 |
|---|---|
| `DoorTrigger` (TriggerEnter) | `Selected Tag` = `Player` |
| `OpenDoorIf` (Conditional) | `Input Data > Process` = `DoorTrigger`, `Output Data` 요소 1개 = `OpenDoor` |
| `OpenDoor` (RotateObject) | `Object To Rotate` = `DoorPivot`, `Rotate Angle` = 90, `Axis` Y 체크, `Time To Rotate` = 1, `Rotate Once` 체크 |

확인 방법: Play 후 `Player`를 파란 상자 안으로 옮긴다. 인스펙터에서 `DoorTrigger`의 Is On이 켜지고 `OpenDoorIf`가 실행되어 문이 1초 동안 열린다. `OpenDoor`의 Is On이 켜진 채 남는다. 상자를 나갔다 다시 들어가도 문이 다시 회전하지 않는다(`Rotate Once`).

## 예제 2. 구역에 들어가고 3초 뒤 함정이 발동한다

기대 결과: 구역 진입 3초 뒤 숨겨진 가시(비활성 오브젝트)가 나타난다.

```
GOS
├─ TrapTrigger      (TriggerEnter + BoxCollider)
├─ StartTimerIf     (Conditional)
├─ TrapTimer        (Timer)
├─ ActivateSpikeIf  (Conditional)
└─ ShowSpike        (Activate)
Spike               (Cube, 비활성 상태)
```

| 노드 | 설정 |
|---|---|
| `TrapTrigger` | `Selected Tag` = `Player` |
| `StartTimerIf` (Conditional) | 입력 = `TrapTrigger`, 출력 1개 = `TrapTimer` |
| `TrapTimer` (Timer) | `Seconds` = 3 |
| `ActivateSpikeIf` (Conditional) | 입력 = `TrapTimer`, 출력 1개 = `ShowSpike` |
| `ShowSpike` (Activate) | `Obj` = `Spike` |

확인 방법: 구역에 들어가면 `StartTimerIf`가 `TrapTimer`를 시작시킨다. 3초 뒤 `TrapTimer`의 Is On이 켜지고 `Spike`가 나타난다. `Timer`는 한 번 켜지면 꺼지지 않으므로 함정은 한 번만 발동한다. Play를 다시 시작해야 반복해 볼 수 있다.

## 예제 3. 오브젝트를 파괴하면 다음 단계가 활성화된다

기대 결과: 구역에 들어가면 장애물이 파괴되고, 그것을 감지해 다음 구역의 보상 오브젝트가 나타난다.

```
GOS
├─ BreakTrigger     (TriggerEnter + BoxCollider)
├─ BreakIf          (Conditional)
├─ BreakObstacle    (Destroy, Add Component로 추가)
├─ ObstacleGone     (IsDestroy)
├─ NextStageIf      (Conditional)
└─ ShowReward       (Activate)
Obstacle            (Cube + GlobalGameObject)
Reward              (Sphere, 비활성 상태)
```

| 노드 | 설정 |
|---|---|
| `BreakTrigger` | `Selected Tag` = `Player` |
| `BreakIf` (Conditional) | 입력 = `BreakTrigger`, 출력 1개 = `BreakObstacle` |
| `BreakObstacle` (Destroy) | `Target` = `Obstacle` |
| `ObstacleGone` (IsDestroy) | `Cach` 요소 1개 = `Obstacle`(`GlobalGameObject` 컴포넌트) |
| `NextStageIf` (Conditional) | 입력 = `ObstacleGone`, 출력 1개 = `ShowReward` |
| `ShowReward` (Activate) | `Obj` = `Reward` |

준비: `Destroy`는 메뉴에 없으므로 빈 오브젝트를 만든 뒤 Add Component에서 `Destroy`(GOS의 것)를 붙인다. `Obstacle`에는 Add Component로 `GlobalGameObject`를 붙인다.

확인 방법: 구역에 들어가면 `Obstacle`이 사라지고 콘솔에 `... is Destroy` 로그가 찍히며 `ObstacleGone`의 Is On이 켜진다. 이어서 `Reward`가 나타난다. `Cach`에는 오브젝트를 하나만 등록한다(여러 개일 때의 동작은 [guide-for-designers.md](guide-for-designers.md)의 한계 참고).

## 예제 4. 구역에 들어가면 컷씬이 재생된다

기대 결과: 구역에 들어가면 카메라가 컷씬 카메라 두 대를 차례로 비춘 뒤 원래 카메라로 돌아온다.

준비: Package Manager의 Cinemachine 2.10.x가 설치되어 있어야 한다. Main Camera에는 `Cinemachine Brain`이 있어야 한다(Cinemachine 메뉴에서 Virtual Camera를 만들면 자동으로 붙는다).

```
GOS
├─ CutsceneTrigger  (TriggerEnter + BoxCollider)
├─ PlayCutsceneIf   (Conditional)
└─ Cutscene         (CameraControl)
Main Camera         (Cinemachine Brain)
MainVCam            (Virtual Camera, Priority 10, Player 따라가기 등)
CutVCam1            (Virtual Camera, Priority 0, 보여 줄 장면을 향함)
CutVCam2            (Virtual Camera, Priority 0, 다른 장면을 향함)
```

| 노드 | 설정 |
|---|---|
| `CutsceneTrigger` | `Selected Tag` = `Player` |
| `PlayCutsceneIf` (Conditional) | 입력 = `CutsceneTrigger`, 출력 1개 = `Cutscene` |
| `Cutscene` (CameraControl) | `Main Virtual Camera` = `MainVCam`, `Cutscene Data` 요소 2개(1번: `CutVCam1` / 3초, 2번: `CutVCam2` / 3초), `Cinemachine Brain` = Main Camera, `Cutscene Mode` = `CameraMove`, `Cutscene Blend Time` = 1 |

핵심 규칙: 컷씬 카메라의 Priority는 메인 카메라보다 낮게 둔다. 컷씬 중에 코드가 컷씬 카메라의 Priority를 메인보다 높여 전환시키기 때문이다.

확인 방법: 구역에 들어가면 카메라가 1초에 걸쳐 `CutVCam1`로 이동해 3초 머물고, `CutVCam2`로 이어서 3초, 이후 메인으로 돌아온다. `Cutscene`의 Is On이 켜진 채 남아 컷씬은 한 번만 재생된다. `FadeInNOut` 모드는 `GUIManager`와 페이드 패널 설정이 추가로 필요하고 동작을 확인하지 못했으므로 쓰지 않는다.

## 예제 5. 발판 두 개를 동시에 밟으면 엘리베이터가 올라간다

기대 결과: 두 발판 위에 모두 서 있을 때만 플랫폼이 위로 이동한다.

플레이어가 한 명이면 동시에 두 발판에 설 수 없다. `Player`와 같은 태그를 가진 `Cube` 하나를 더 두어 Scene 창에서 옮기거나, 한 발판에는 `Player`, 다른 발판에는 `Box` 태그를 지정해 상자를 올려 두는 구성으로 연습한다.

```
GOS
├─ PadA             (TriggerEnter + BoxCollider)
├─ PadB             (TriggerEnter + BoxCollider)
├─ BothPads         (Logic)
├─ LiftIf           (Conditional)
└─ LiftMove         (MoveObject)
Platform            (Cube)
LiftTop             (빈 오브젝트, 올라갈 목적지)
```

| 노드 | 설정 |
|---|---|
| `PadA` | `Selected Tag` = `Player` |
| `PadB` | `Selected Tag` = `Box`(Tag 목록에서 새로 만든다) |
| `BothPads` (Logic) | `Processes1` = `PadA`, `Logic Type` = And, `Processes2` = `PadB` |
| `LiftIf` (Conditional) | 입력 = `BothPads`, 출력 1개 = `LiftMove` |
| `LiftMove` (MoveObject) | `Object To Move` = `Platform`, `Move Target Pos` 요소 1개(`Transform` = `LiftTop`, `Time` = 3) |

확인 방법: 한쪽만 밟으면 `BothPads`의 Is On이 꺼진 채 유지된다. 둘 다 밟으면 켜지고 `Platform`이 3초 동안 `LiftTop`까지 이동한다. 응용: `Logic Type`을 Or로 바꾸면 하나만 밟아도 올라간다. `MoveObject`는 한 번 실행되면 `IsOn`이 바뀌지 않고, 켜지는 순간마다 새로 이동이 시작되므로 짧은 시간에 반복해 밟지 않는다.

## 흔한 실패와 확인 순서

1. 트리거의 Is On이 안 켜진다: 태그 철자, `Player`의 Rigidbody, 상자의 `Is Trigger` 체크를 본다.
2. Is On은 켜지는데 결과가 없다: `Conditional`의 출력 목록에 노드가 들어 있는지, 출력 노드의 대상 칸이 채워졌는지 본다.
3. 콘솔에 `NullReferenceException`: 비어 있는 연결 칸을 찾는다.
4. 출력 노드가 한 번 쓰고 끝난다: 그 노드의 Is On이 켜진 채 남아 있기 때문이다. Play를 다시 시작한다.

## 실습 체크리스트

- [ ] 예제 1: 문이 열리고, 다시 들어가도 반복 회전하지 않음을 확인했다.
- [ ] 예제 2: 3초 지연 후 함정이 나타남을 확인했다.
- [ ] 예제 3: `Destroy`를 Add Component로 붙였고, 보상이 나타남을 확인했다.
- [ ] 예제 4: 컷씬 카메라 Priority를 메인보다 낮게 두고 컷씬이 재생됨을 확인했다.
- [ ] 예제 5: And를 Or로 바꿔 동작 차이를 확인했다.
- [ ] 한 가지 기믹을 내가 직접 정해 위 노드들로 구성해 보았다.
