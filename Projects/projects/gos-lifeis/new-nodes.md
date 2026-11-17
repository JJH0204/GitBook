# 신규 노드 11종

## 무엇이 바뀌었나

포크는 원본의 노드 연결 모델(`ProcessBase`의 `IsOn`과 `Execute()`)을 그대로 쓰면서 입력 노드 3개와 출력 노드 8개를 추가했다. 모두 `Scripts/VisualScripting/` 아래에 있다.

| 구분 | 노드 | 파일 | 한 줄 설명 | 추가 커밋 |
| --- | --- | --- | --- | --- |
| 입력 | `RaycastTrigger` | `Input/Trigger/RaycastTrigger.cs` | 정면으로 레이를 쏴 맞은 오브젝트를 대상으로 저장한다 | 1e254931 |
| 입력 | `InputEvent` | `Input/InputEvent.cs` | 키/마우스를 누르면 연결된 출력들을 바로 실행한다 | 1e254931 |
| 입력 | `TriggerTimmer` | `Input/Trigger/TriggerTimmer.cs` | 트리거 안에 일정 시간 머물러야 켜진다 | 38f2e184 |
| 출력 | `MoveTo` | `Output/MoveTo.cs` | 오브젝트를 목적지로 곡선을 따라 이동한다 | 38f2e184 |
| 출력 | `Teleport` | `Output/Teleport.cs` | 트리거에 들어온 대상을 이 오브젝트 위치로 순간이동한다 | 38f2e184 |
| 출력 | `RotateDoor` | `Output/RotateDoor.cs` | 피벗을 중심으로 문을 열고 닫는다(토글) | 38f2e184 |
| 출력 | `SlidingDoor` | `Output/SlidingDoor.cs` | 정해진 방향·거리만큼 문을 밀어 열고 닫는다(토글) | 38f2e184 |
| 출력 | `LightingControl` | `Output/LightingControl.cs` | 조명을 켜고 끄거나 밝기·색을 바꾸고, 시간이 지나면 복구한다 | 38f2e184 |
| 출력 | `GameTimeAdjust` | `Output/GameTimeAdjust.cs` | `Time.timeScale`을 바꾼다(슬로모션·정지) | 38f2e184 |
| 출력 | `TimelineController` | `Output/SetActivate/TimelineController.cs` | `PlayableDirector`를 재생·일시정지·재개·정지한다 | 38f2e184 |
| 출력 | `Spawner` | `Output/Spawner.cs` | 프리팹을 지정 위치에 생성한다 | d3cfe625 |

`GameTimeAdjust.cs` 안의 클래스 이름은 `GameTimeAdject`다(철자 오류). 이 문서는 파일 이름으로 `GameTimeAdjust`라고 부르되 코드 발췌는 클래스 이름 그대로 둔다. 데이터 계층의 `EntryModifierEvent`도 신규 노드지만 [custom-data.md](custom-data.md)에서 다룬다.

## 왜

* 커밋 메시지는 대부분 "마이그레이션", "인풋드리거, 레이케이스트", "스포너추가"처럼 짧다. 이유는 노드의 이름과 코드 주석에서 읽을 수밖에 없다. 문, 조명, 시간, 순간이동, 컷씬은 퍼즐·기믹 게임에서 자주 쓰이는 연출이라 입력→출력 모델 위에 부품으로 얹은 것으로 보인다(추정).
* 입력 노드가 `Trigger`(범위 안에 들어옴) 하나뿐이었던 원본에 "시선 방향으로 맞힘"(`RaycastTrigger`), "버튼을 누름"(`InputEvent`), "일정 시간 머묾"(`TriggerTimmer`)이 더해져 입력의 종류가 넓어졌다.
* `InputEvent`·`RaycastTrigger`·`EntryModifierEvent`는 한 세트다. 샘플 프리팹 `PlayerBlue`는 `InputEvent`(마우스 왼쪽 버튼) → `RaycastTrigger` → `Conditional`(`isLoop` 켬) → `EntryModifierEvent`로 연결돼 "클릭하면 정면 대상의 HP를 깎는" 구성이다. 프리팹의 직렬화 값을 읽어 확인했다.

## 핵심 코드

모든 노드는 두 가지 중 하나로 동작한다. 입력 노드는 조건이 맞으면 `IsOn`을 `true`로 만들고, 출력 노드는 `Execute()`가 불렸을 때 일을 한다. 둘을 이어 주는 것은 `Conditional`이다(`inputData`의 `IsOn`이 켜지면 `outputData` 목록의 `Execute()`를 한 번 부른다).

### RaycastTrigger

{% code title="Input/Trigger/RaycastTrigger.cs (일부)" %}
```csharp
[SerializeField] private GameObject objTarget;
[SerializeField] private Transform muzzleTransform;
[SerializeField] private float maxDistance = 100f;
[SerializeField] private LayerMask layerMask = ~0;

public GameObject GetTarget() { return objTarget; }

public void Fire()
{
    Transform originTransform = muzzleTransform != null ? muzzleTransform : transform;
    Vector3 origin = originTransform.position + originTransform.forward * 0.8f;
    Vector3 direction = originTransform.forward;

    if (Physics.Raycast(origin, direction, out RaycastHit hit, maxDistance, layerMask))
    {
        objTarget = hit.collider.gameObject;
        IsOn = true;
    }
    else
    {
        objTarget = null;
        IsOn = false;
    }
}

public override void Execute() { Fire(); }
```
{% endcode %}

* 입력: `Execute()`가 불릴 때마다 한 번 쏜다. 스스로 `Update`에서 쏘지 않으므로 `InputEvent` 같은 다른 노드가 `Execute()`를 불러 줘야 한다.
* 동작: 발사 방향은 오브젝트의 `forward`(마우스 위치가 아니다)다. 자기 콜라이더에 맞는 것을 피하려고 시작점을 앞으로 0.8만큼 민다. 맞으면 `objTarget`에 저장하고 `IsOn`을 켠다.
* 사용 예: `EntryModifierEvent`의 `targetSource`로 연결해 "정면에 있는 대상"에게 효과를 준다.

### InputEvent

{% code title="Input/InputEvent.cs (일부)" %}
```csharp
[SerializeField] private KeyCode triggerKey = KeyCode.Mouse0;
[SerializeField] private List<ProcessData> outputs;

private void Update()
{
    if (Input.GetKeyDown(triggerKey)) { IsOn = true; Execute(); }
    else if (Input.GetKeyUp(triggerKey)) { IsOn = false; }
}

public override void Execute()
{
    if (outputs == null) return;
    foreach (var output in outputs)
        if (output.process != null) output.process.Execute();
}
```
{% endcode %}

* 입력: `triggerKey`(기본 마우스 왼쪽 버튼)를 누른 프레임.
* 동작: 누른 프레임에 `outputs`의 모든 노드를 **직접** 실행한다. `Conditional`을 거치지 않는 점이 다른 입력 노드와 다르다. 키를 떼면 `IsOn`만 `false`로 돌린다.
* 사용 예: `outputs`에 `RaycastTrigger`나 `SlidingDoor`를 넣어 "키를 누르면 문이 열린다"를 만든다. 구 Input Manager(`Input.GetKeyDown`)를 쓴다.

### TriggerTimmer

{% code title="Input/Trigger/TriggerTimmer.cs (일부)" %}
```csharp
[SerializeField] private string selectedTag;
[SerializeField] float TimeDelay = 0.1f;
private Coroutine _waitCoroutine;

IEnumerator WaitForSeconds(float waitTime)
{
    if (TimeDelay > 0) yield return new WaitForSeconds(waitTime);
    IsOn = true;
    _waitCoroutine = null;
}

private void OnTriggerEnter(Collider other)
{
    if (other.CompareTag(selectedTag))
    {
        objTarget = other.gameObject;
        if (_waitCoroutine == null) _waitCoroutine = StartCoroutine(WaitForSeconds(TimeDelay));
    }
}

private void OnTriggerExit(Collider other)
{
    if (other.CompareTag(selectedTag))
    {
        IsOn = false;
        if (_waitCoroutine != null) { StopCoroutine(_waitCoroutine); _waitCoroutine = null; }
    }
}
```
{% endcode %}

* 입력: 태그가 맞는 오브젝트가 `BoxCollider(Is Trigger)` 안에 `TimeDelay`초 이상 머무는 것.
* 동작: 들어오면 타이머 코루틴을 시작하고, 시간이 다 차면 `IsOn`을 켠다. 중간에 나가면 코루틴을 멈추고 `IsOn`을 끈다. 대기 중 재진입은 이미 돌고 있는 코루틴을 그대로 둔다.
* 사용 예: 발판 위에 2초 서 있어야 문이 열리는 구성. 샘플 프리팹 `TimmerActive`가 이름상 이 용도로 보인다.

### MoveTo

{% code title="Output/MoveTo.cs (일부)" %}
```csharp
[SerializeField] private GameObject objToMove;       // 비우면 자기 자신
[SerializeField] private Transform destination;
[SerializeField] private float duration = 1.0f;
[SerializeField] private AnimationCurve movementCurve = AnimationCurve.Linear(0, 0, 1, 1);

private IEnumerator MoveRoutine()
{
    Vector3 startPosition = objToMove.transform.position;
    Vector3 targetPosition = destination.position;
    float elapsedTime = 0f;
    while (elapsedTime < duration)
    {
        elapsedTime += Time.deltaTime;
        float curveValue = movementCurve.Evaluate(elapsedTime / duration);
        objToMove.transform.position = Vector3.Lerp(startPosition, targetPosition, curveValue);
        yield return null;
    }
    objToMove.transform.position = targetPosition;
}
```
{% endcode %}

* 입력: `Execute()`. 이동 중에 다시 불리면 진행 중 코루틴을 멈추고 현재 위치에서 새로 시작한다.
* 동작: `AnimationCurve`로 보간 비율을 바꿔 가속·감속을 표현한다. 끝에서 목표 위치로 정확히 맞춘다. `Awake`에서 `objToMove`가 비어 있으면 자기 자신을 대상으로 삼는다. 원본 `MoveObject`가 시간이 달린 지점 목록을 따라가던 것과 달리 목적지는 하나다.
* 사용 예: 샘플 프리팹 `Door(MoveTo)`.

### Teleport

{% code title="Output/Teleport.cs (일부)" %}
```csharp
[SerializeField] Trigger trigger;
[SerializeField] float timeDelay = 0.0f;
private WaitForSeconds _wait;

private void Start() { if (timeDelay > 0) _wait = new WaitForSeconds(timeDelay); }

public override void Execute()
{
    if (timeDelay > 0.0f) StartCoroutine(TeleportRoutine());
    else PerformTeleport();
}

private void PerformTeleport()
{
    if (trigger != null && trigger.GetTarget())
        trigger.GetTarget().transform.position = this.transform.position;
    else
        Debug.LogWarning("Trigger Target Error or Target is missing!");
}
```
{% endcode %}

* 입력: `Execute()`와, 대상을 알려 줄 `Trigger`(`GetTarget()`으로 마지막에 들어온 오브젝트를 돌려준다).
* 동작: 대상의 위치를 이 오브젝트(Teleport가 붙은 오브젝트)의 위치로 바꾼다. `timeDelay`가 0보다 크면 그만큼 기다렸다가 옮긴다. 이 노드는 전역 네임스페이스에 있고 `IsOn`을 바꾸지 않는다.
* 사용 예: 입구에 `Trigger`, 출구에 `Teleport`를 두고 `Conditional`로 이은 뒤 `Teleport.trigger`에 입구의 `Trigger`를 넣는다. 샘플 프리팹 `TeleportTrigger`.

### RotateDoor

{% code title="Output/RotateDoor.cs (일부)" %}
```csharp
[SerializeField] private PivotPosition pivotPosition = PivotPosition.MiddleLeft;
[SerializeField] private Vector3 rotationAxis = Vector3.up;
[SerializeField] private float openAngle = 90f;
[SerializeField] private float duration = 1.0f;

private void Start()
{
    _initialPosition = transform.position;
    _initialRotation = transform.rotation;
    CalculatePivot();                    // MeshFilter의 Bounds로 피벗 좌표를 구한다
}

public override void Execute()
{
    _isOpenState = !_isOpenState;
    IsOn = _isOpenState;
    if (_animationCoroutine != null) StopCoroutine(_animationCoroutine);
    _animationCoroutine = StartCoroutine(RotateRoutine());
}

// RotateRoutine 안:
Quaternion rot = Quaternion.AngleAxis(angleNow, rotationAxis);
transform.position = _worldPivotPoint + (rot * (_initialPosition - _worldPivotPoint));
transform.rotation = rot * _initialRotation;
```
{% endcode %}

* 입력: `Execute()`가 불릴 때마다 열림↔닫힘을 뒤집는다(토글).
* 동작: 메시의 로컬 경계(`bounds`)에서 9개 위치(TopLeft, ... BottomRight)와 `Custom` 중 하나를 피벗으로 골라 월드 좌표로 바꾼다. 문을 **피벗을 중심으로 공전**시키는 방식이라(위치를 피벗 기준으로 돌리고 회전도 같이 더한다), 문 메시의 원점이 가운데여도 한쪽 가장자리를 경첩처럼 쓸 수 있다. 진행도(0~1)를 유지해 중간에 다시 눌러도 현재 각도에서 반대로 이어서 움직인다.
* 사용 예: 샘플 프리팹 `RotateDoorTrigger`. `MeshFilter`가 없으면 오브젝트 중심으로 돌고 경고를 낸다.

### SlidingDoor

{% code title="Output/SlidingDoor.cs (일부)" %}
```csharp
[SerializeField] private Vector3 slideDirection = Vector3.right;
[SerializeField] private float slideDistance = 3.0f;
[SerializeField] private float duration = 1.0f;

private void Awake()
{
    _closedPosition = transform.position;
    _openPosition = _closedPosition + (slideDirection.normalized * slideDistance);
}

public override void Execute()
{
    _isOpenState = !_isOpenState;
    IsOn = _isOpenState;
    if (_animationCoroutine != null) StopCoroutine(_animationCoroutine);
    _animationCoroutine = StartCoroutine(AnimateDoor());
}

public void Open()  { if (_isOpenState) return; _isOpenState = true;  IsOn = true;  /* 코루틴 시작 */ }
public void Close() { if (!_isOpenState) return; _isOpenState = false; IsOn = false; /* 코루틴 시작 */ }
```
{% endcode %}

* 입력: `Execute()`(토글). 코드에서 직접 부를 수 있는 `Open()`/`Close()`도 있다.
* 동작: 시작 위치를 닫힌 위치로 기억하고, 방향×거리만큼 간 곳을 열린 위치로 계산한다. 위치는 월드 좌표다.
* 사용 예: `slideDirection`을 `(0,1,0)`으로 두면 위로 올라가는 문. `Trigger` → `Conditional` → `SlidingDoor`로 잇는다.

### LightingControl

{% code title="Output/LightingControl.cs (일부)" %}
```csharp
[SerializeField] private Light targetLight;
[SerializeField] private float duration = -1f;       // -1 영구, 양수는 그 시간 뒤 복구
[SerializeField] private bool disable = true;
[SerializeField] private bool controlIntensity = false;
[SerializeField] private float setIntensity = 1.0f;
[SerializeField] private bool controlColor = false;
[SerializeField] private Color setColor = Color.white;

public override void Execute()
{
    if (targetLight == null) { Debug.LogWarning("..."); return; }
    if (_activeCoroutine != null) StopCoroutine(_activeCoroutine);

    if (duration == -1f)  { ApplyLighting(); IsOn = true; }
    else if (duration > 0f) { _activeCoroutine = StartCoroutine(Co_TemporaryLightChange()); IsOn = true; }
}

private void ApplyLighting()
{
    targetLight.enabled = !disable;
    if (controlIntensity) targetLight.intensity = setIntensity;
    if (controlColor)     targetLight.color = setColor;
}
```
{% endcode %}

* 입력: `Execute()`. `targetLight`가 비어 있으면 같은 오브젝트의 `Light`를 `Awake`에서 찾는다.
* 동작: `disable`이 참이면 조명을 끄고(`enabled = !disable`), 밝기·색은 체크한 것만 바꾼다. 임시 모드(`duration > 0`)에서는 원래 밝기와 색을 백업했다가 시간이 지나면 되돌린다.
* 사용 예: 샘플 프리팹 `LightControlTriggerObject`, `LightController`. `showDebugLog`는 에디터에서만 존재하는 필드로 `VisualLogger.Log`의 출력 여부를 정한다.

### GameTimeAdjust (클래스 `GameTimeAdject`)

{% code title="Output/GameTimeAdjust.cs (일부)" %}
```csharp
[SerializeField, Range(0f, 5f)] private float targetScale = 0f;
[SerializeField] private float duration = -1f;
[SerializeField] private float safetyDuration = 3.0f;
[SerializeField] private bool syncFixedDeltaTime = true;

public override void Execute()
{
    if (duration == 0f) return;
    if (_activeCoroutine != null) StopCoroutine(_activeCoroutine);

    bool isStop = Mathf.Approximately(targetScale, 0f);
    bool isInfinite = Mathf.Approximately(duration, -1f);

    if (isInfinite && isStop) _activeCoroutine = StartCoroutine(Co_TemporaryTimeChange(safetyDuration));
    else if (isInfinite)      ApplyTimeScale(targetScale);
    else                      _activeCoroutine = StartCoroutine(Co_TemporaryTimeChange(duration));
    IsOn = true;
}

private IEnumerator Co_TemporaryTimeChange(float waitTime)
{
    float prevScale = Time.timeScale;
    ApplyTimeScale(targetScale);
    yield return new WaitForSecondsRealtime(waitTime);
    ApplyTimeScale(prevScale);
}
private void ApplyTimeScale(float scale)
{
    Time.timeScale = Mathf.Max(0f, scale);
    if (syncFixedDeltaTime) Time.fixedDeltaTime = _defaultFixedDeltaTime * Time.timeScale;
}
```
{% endcode %}

* 입력: `Execute()`. `targetScale`(0은 정지, 1은 정상, 0.5는 느리게)과 `duration`(-1은 무한).
* 동작: 무한 정지(`duration = -1`, `targetScale = 0`)는 게임이 영영 멈추는 것을 막기 위해 `safetyDuration`초만 멈춘다. 대기에 `WaitForSecondsRealtime`을 써서 `timeScale`이 0이어도 시간이 흐른다. `syncFixedDeltaTime`이 켜져 있으면 물리 시간 간격도 같은 비율로 바꾼다.
* 사용 예: 샘플 프리팹 `GameSpeedAdjustTrigger`.

### TimelineController

{% code title="Output/SetActivate/TimelineController.cs (일부)" %}
```csharp
public enum TimelineAction { Play, Pause, Resume, Stop }

[SerializeField] private PlayableDirector director;
[SerializeField] private TimelineAction action = TimelineAction.Play;
[SerializeField] private bool playFromStart = true;

public void Start()
{
    if (director == null) director = GetComponent<PlayableDirector>();
    director.Stop();
}

public override void Execute()
{
    if (!director.gameObject.activeInHierarchy) director.gameObject.SetActive(true);
    IsOn = true;
    switch (action)
    {
        case TimelineAction.Play:   if (playFromStart) director.time = 0; director.Play(); break;
        case TimelineAction.Pause:  director.Pause(); break;
        case TimelineAction.Resume: director.Resume(); break;
        case TimelineAction.Stop:   director.Stop(); break;
    }
}
```
{% endcode %}

* 입력: `Execute()`와 인스펙터에서 고른 `action`.
* 동작: 시작할 때 `director.Stop()`으로 Timeline이 자동으로 돌지 않게 한다. 비활성 오브젝트면 먼저 활성화한다. 한 노드가 한 가지 동작만 하므로 "재생"과 "정지"를 하려면 노드를 둘 둔다.
* 사용 예: 컷씬은 [unity6-cinemachine3.md](unity6-cinemachine3.md)의 `CameraControl`이 카메라 전환까지 포함해 다루고, 이 노드는 카메라와 무관한 Timeline(연출, 문 열림 애니메이션 등)에 쓴다. 샘플 타임라인은 `Timelines/GimickTestTimeline.playable`.

### Spawner

{% code title="Output/Spawner.cs (일부)" %}
```csharp
[Tooltip("생성할 특정 프리팹")]
[SerializeField] private GameObject prefabToSpawn;
[SerializeField] private Transform spawnPoint;
[SerializeField] private Transform parentTransform;

public override void Execute()
{
    if (prefabToSpawn == null) { Debug.LogError("..."); return; }

    Vector3 position = spawnPoint != null ? spawnPoint.position : transform.position;
    Quaternion rotation = spawnPoint != null ? spawnPoint.rotation : transform.rotation;

    GameObject spawnedObj = Instantiate(prefabToSpawn, position, rotation, parentTransform);
    IsOn = true;
}
```
{% endcode %}

* 입력: `Execute()`. 프리팹, 생성 위치(`spawnPoint`, 없으면 자기 위치), 부모(`parentTransform`).
* 동작: 호출될 때마다 한 개씩 생성한다. 원본 `Instance`는 `IsOn`이 켜지면 두 번째 호출을 무시하고, 범위 안 무작위 위치에 `count`개를 만들며, `IsDestroy`와 연결할 수 있었다. `Spawner`는 이 세 가지가 모두 없고 대신 위치·회전을 정확히 지정한다.
* 사용 예: 테스트 씬 `SpawnerTestScene`.

## 따라 만들기

원본 GOS의 `ProcessBase`, `ProcessData`, `Conditional`, `Trigger`가 있는 프로젝트를 전제로 한다([../gos/README.md](../gos/README.md)). "발판에 올라서면 문이 열리고 클릭하면 앞의 대상을 공격한다"까지 만든다.

1. `SlidingDoor`부터 만든다. 문으로 쓸 `Cube`에 `SlidingDoor`를 붙이고 `slideDirection`을 `(0,1,0)`, `slideDistance`를 3으로 둔다. 확인 방법: 플레이 중 컴포넌트 우클릭 메뉴 "강제 실행 (테스트)"를 누르면 문이 위로 올라가고 다시 누르면 내려온다. `IsOn`이 따라 바뀐다.
2. 같은 방식으로 `RotateDoor`를 만든다. 확인 방법: Scene 뷰에서 문을 선택하면 보라색 피벗 구와 축 선이 보이고, `pivotPosition`을 바꾸면 피벗 점이 옮겨 간다.
3. 발판용 `Cube`를 만들고 `BoxCollider(Is Trigger)`와 `Trigger`(원본)를 붙인다. `selectedTag`는 `Player`로 한다(Tag를 먼저 지정한다). 확인 방법: 플레이어가 들어가면 `Trigger`의 `IsOn`이 켜진다.
4. 빈 오브젝트에 `Conditional`을 붙인다. `inputData`는 `Trigger`, `outputData`에 `SlidingDoor`를 넣는다. 확인 방법: 플레이어가 발판에 들어가는 순간 문이 열린다. 한 번 열린 뒤에는 `Conditional`이 같은 신호로 다시 실행하지 않는다(상승 에지에서만 실행).
5. `Trigger`를 `TriggerTimmer`로 바꿔 본다. `TimeDelay`를 2로 둔다. 확인 방법: 2초 머물러야 문이 열리고, 1초 만에 나가면 열리지 않는다.
6. `MoveTo`로 엘리베이터를 만든다. 목적지로 쓸 빈 오브젝트를 두고 `destination`에 넣는다. 확인 방법: `Execute` 시 오브젝트가 `duration`초 동안 목적지로 이동하고, Scene 뷰에 초록 선과 구가 보인다.
7. 플레이어 오브젝트에 `RaycastTrigger`, `InputEvent`, `Conditional`을 붙이고 `InputEvent.outputs`에 `RaycastTrigger`를 넣는다. `Conditional.inputData`는 `RaycastTrigger`, `isLoop`를 켠다. 확인 방법: 클릭할 때마다 콘솔에 `Raycast Hit: 대상이름` 로그가 나온다(정면에 콜라이더가 있을 때). 공격은 [custom-data.md](custom-data.md)에서 이어 붙인다.
8. `Teleport`, `LightingControl`, `GameTimeAdjust`, `Spawner`, `TimelineController`도 같은 방식으로 `Conditional`에 출력으로 붙여 하나씩 확인한다. 확인 방법: 각각 순간이동, 조명 변경, 슬로모션(`targetScale` 0.3, `duration` 2), 프리팹 생성, Timeline 재생이 일어난다.

## 한계·주의

* **`Trigger`가 원본과 달라진 점**(이 문서의 `Trigger` 사용에 영향): 포크의 `Trigger.OnTriggerExit`는 `IsOn`을 `false`가 아니라 `true`로 둔다. 원본은 `false`였다. 코드 읽기에서 읽은 사실이며 의도인지 오타인지는 **확인 필요**다. 또 `objTarget`을 비우는 조건이 `if (!objTarget && other.gameObject.GetInstanceID() == objTarget.GetInstanceID())`로 되어 있어, 대상이 `null`일 때만 안으로 들어가 `NullReferenceException`이 날 수 있고 대상이 있을 때는 비워지지 않는다. `TriggerTimmer.OnTriggerExit`에도 같은 줄이 있다.
* `GameTimeAdjust`: 지속 시간이 지나기 전에 `Execute`가 다시 불리면 앞의 코루틴을 멈추기만 하고 `timeScale`을 복원하지 않는다. 새 코루틴이 "현재(이미 바뀐) 값"을 이전 값으로 기억하므로, 끝난 뒤에도 원래 속도로 돌아오지 않을 수 있다(코드 읽기, unverified). 클래스가 `GameTimeAdject`여서 파일 이름과 다르므로 인스펙터에 붙는지도 **확인 필요**다. 팔레트에서는 분류가 `ETC (미분류)`가 될 것으로 보인다([editor-tools.md](editor-tools.md)).
* `LightingControl`: 임시 모드에서 `enabled`는 복구하지 않는다(복구 코드가 주석 처리돼 있다). `disable`이 참이면 시간이 지나도 조명이 꺼진 채로 남는다. `duration`이 0이거나 -1이 아닌 음수이면 아무 일도 하지 않는다. `isToggle` 필드는 선언만 있고 쓰이지 않는다(컴파일 경고 CS0414).
* `TimelineController.Start`는 `director`를 못 찾으면 `null`에 `Stop()`을 불러 예외가 난다. 같은 오브젝트에 `PlayableDirector`를 두거나 인스펙터에서 지정해야 한다.
* `RotateDoor`·`SlidingDoor`는 시작 위치를 월드 좌표로 저장한다. 부모가 움직이는 문에 쓰면 어긋난다. `RotateDoor`는 `MeshFilter`의 메시 경계를 쓰므로 메시가 없으면 중심 회전이다.
* `RaycastTrigger`는 시작점 오프셋 0.8과 발사 방향(오브젝트 정면)이 코드에 고정돼 있다. 마우스 위치로 조준하는 노드가 아니다.
* `Teleport`는 `Trigger`만 대상 출처로 받는다. `RaycastTrigger`를 넣을 수 없다.
* 11개 노드 모두 실제 Unity에서 실행해 보지 못했다. 설명은 코드 읽기에 근거한 것이며 **unverified**다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 입력 노드와 출력 노드를 `Conditional`로 잇는다는 구조를 내 말로 설명해 보자. `InputEvent`는 왜 `Conditional` 없이도 동작하는가?
- [ ] 문을 여닫는 방식으로 `RotateDoor`(피벗을 중심으로 공전)와 `SlidingDoor`(직선 이동)를 비교했을 때, 내 프로젝트라면 어느 쪽을 먼저 만들겠는가? 이유와 함께 적어 보자.
- [ ] `Time.timeScale`을 건드리는 기능에서 생길 수 있는 문제를 한 가지 이상 떠올려 보고, 어떻게 막겠는지 적어 보자.
