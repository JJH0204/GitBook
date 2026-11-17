# 샘플 게임플레이 코드와 패키징·릴리즈

## 무엇이 바뀌었나

### 샘플용 게임플레이 코드

포크는 GOS 노드를 시험해 볼 수 있는 작은 게임 요소를 `Scripts/VisualScripting/Etc/`에 넣었다. 이 폴더는 원본에서 `ManagerBase`와 `GlobalGameObject`만 모여 있던 곳이다. 아래 7개는 `ProcessBase`를 상속하지 않는 일반 `MonoBehaviour`라 노드가 아니고, 팔레트 창에도 나오지 않는다.

| 파일 (클래스) | 하는 일 | 샘플에서 쓰이는 곳 |
| --- | --- | --- |
| `BaseFSM.cs` (`BaseFSM`, `UnitState`) | 상태 머신 뼈대. `Idle`, `Move`, `Patrol`, `Finish` 상태별 `Enter_`/`Update_`/`Exit_` 가상 함수 | `PlayerController`, `AIController`의 부모 |
| `PlayerController.cs` | WASD 이동, `R`키 자동 달리기 | `PlayerBlue` 프리팹 |
| `AIContller.cs` (클래스 `AIController`) | 웨이포인트 순찰, 플레이어가 범위에 들어오면 추적 | `PlayerAI`, `PatrolSample` 프리팹 |
| `WaypontPath.cs` (클래스 `WaypointPath`) | 순찰 지점 목록과 다음 지점 계산 | `GOSSampleScenes` 씬 |
| `ObjectPoolManager.cs` | 프리팹 단위 오브젝트 풀 | 레포 안에서 호출하는 곳 없음 |
| `CharacterPush.cs` | `CharacterController`가 `Rigidbody`를 밀게 함 | 프리팹·씬 어디에도 없음 |
| `GameManager.cs` | `ManagerBase`를 상속한 게임 관리자. 데이터 로드와 메인 카메라 제공 | 코드에서 `GameManager.instance`로 접근([custom-data.md](custom-data.md)) |

`ManagerBase<T>`도 이 폴더로 옮겨지면서 다시 쓰였다. 위 사용처는 프리팹·씬 파일의 스크립트 GUID를 검색해 확인했다.

### 패키징·릴리즈

| 항목 | 원본 | 포크 |
| --- | --- | --- |
| 소스 위치 | `Assets/Scripts/...` | `Assets/GOS/Scripts/...` (a9aecf4a에서 일괄 이동) |
| 에셋 위치 | `Assets/Scenes`, `Assets/Mirza Beig`, `Assets/Material.mat` | `Assets/GOS/Scenes`, `Prefaps`, `Materials`, `Resources`, `Timelines` |
| 배포 형태 | 소스 그대로(과거에 `.unitypackage` 커밋 후 삭제) | `PackageManager/GOS_lifeis.unitypackage` |
| 샘플 | `GOS.unity` 하나와 `GimmickSample/` 씬 여러 개 | `GOSSampleScenes.unity`, `SpawnerTestScene.unity` 두 개 |
| 솔루션 | 없음 | `GOS-Lifeis.slnx` 추가(a9aecf4a) |

패키지 구성은 두 단계를 거쳤다.

1. a9aecf4a "GOS 패키징 릴리즈": `Assets/` 아래 거의 모든 것을 `Assets/GOS/`로 옮기고 `.unitypackage`를 처음 추가했다(약 18.8MB). 이름을 바꿀 때 내용은 그대로였다(rename).
2. 1094d49c "불필요한 구성 삭제및 샘플 새구성, 패키지관리자 업데이": 번들돼 있던 이펙트 에셋(Mirza Beig)과 옛 샘플 씬을 지우고 샘플 프리팹·씬을 새로 구성했다. `.unitypackage`가 약 18.8MB에서 약 156KB로 줄었다.

4221c076 "유니티패키지업데이"는 패키지 파일만 갱신한 커밋이다.

## 왜

* 수업 자료로 배포하려면 폴더 하나로 묶여 있어야 다른 프로젝트에서 가져올 수 있다. 그래서 `Assets/GOS/` 아래로 모았다. 커밋 메시지가 "패키징 릴리즈"라고 밝힌 목적이다.
* 이펙트 에셋은 GOS의 본질이 아니라 샘플에 쓰던 서드파티 에셋이었다. 삭제 커밋 메시지는 "불필요한 구성 삭제"이고, 그 결과 패키지가 1% 미만 크기로 줄었다.
* `BaseFSM` 같은 FSM 코드는 노드로 만들 만한 기능이 아니라, GOS 노드(`InputEvent`, `RaycastTrigger`, 트리거)와 함께 돌릴 "플레이어와 적"이 필요해서 들어온 것으로 읽힌다(추정). 코드 주석에는 `[변경]`, `Hit -> Finish` 같은 수정 흔적이 남아 있다.
* `GameManager`는 `EntryCloner`가 데이터베이스와 카메라를 찾는 진입점이다.

## 핵심 코드

### ManagerBase: 안정화된 싱글톤

{% code title="Etc/ManagerBase.cs (일부)" %}
```csharp
public abstract class ManagerBase<T> : MonoBehaviour where T : MonoBehaviour
{
    private static T _instance;
    private static readonly object _lock = new object();
    private static bool _isApplicationQuitting = false;

    public static T instance
    {
        get
        {
            if (_isApplicationQuitting) return null;     // 종료 중에는 새로 만들지 않는다
            lock (_lock)
            {
                if (_instance == null)
                {
                    _instance = (T)GameObject.FindAnyObjectByType(typeof(T));
                    if (_instance == null)
                    {
                        var singleton = new GameObject();
                        _instance = singleton.AddComponent<T>();
                        singleton.name = typeof(T).Name + " (Singleton)";
                        DontDestroyOnLoad(singleton);
                    }
                }
                return _instance;
            }
        }
    }

    protected virtual void Awake()
    {
        if (_instance == null) { _instance = this as T; DontDestroyOnLoad(gameObject); }
        else if (_instance != this) Destroy(gameObject);   // 중복 생성 파괴
    }
    protected virtual void OnApplicationQuit() { _isApplicationQuitting = true; }
}
```
{% endcode %}

* 원본(`Instance`, 대문자)은 "있으면 반환, 없으면 `FindObjectOfType`, 그래도 없으면 새로 생성"만 했다. 포크는 이름을 `instance`로 바꾸고 세 가지를 더했다.
* `_isApplicationQuitting`: 앱을 닫는 도중 다른 오브젝트의 `OnDestroy`가 `instance`를 부르면 새 오브젝트가 생겨 남는 문제를 막는다.
* `Awake`의 중복 처리: 씬에 `GameManager`를 직접 두었는데 코드가 또 만들어도, 두 번째 것을 파괴한다.
* `lock`: Unity 메인 스레드만 이 속성을 부르므로 실제로는 필요하지 않다. 방어적으로 넣은 것으로 보인다.

### BaseFSM

{% code title="Etc/BaseFSM.cs (일부)" %}
```csharp
public enum UnitState { Idle, Move, Patrol, Finish }

public abstract class BaseFSM : MonoBehaviour
{
    [SerializeField] protected UnitState currentState = UnitState.Idle;

    protected virtual void Start()  { OnEnterState(currentState); }
    protected virtual void Update() { OnUpdateState(currentState); }

    public void ChangeState(UnitState newState)
    {
        if (currentState == newState) return;
        OnExitState(currentState);
        currentState = newState;
        OnEnterState(currentState);
    }

    protected virtual void OnEnterState(UnitState state)
    {
        switch (state)
        {
            case UnitState.Idle:   Enter_Idle(); break;
            case UnitState.Move:   Enter_Move(); break;
            case UnitState.Patrol: Enter_Patrol(); break;
            case UnitState.Finish: Enter_Finish(); break;
        }
    }
    protected virtual void Enter_Idle() { }
    protected virtual void Update_Idle() { }
    protected virtual void Exit_Idle() { }
    // Move, Patrol, Finish도 같은 3개 쌍
}
```
{% endcode %}

* 상태마다 `Enter_`(들어갈 때 한 번), `Update_`(매 프레임), `Exit_`(나갈 때 한 번)를 가상 함수로 두고, 자식이 필요한 것만 `override`한다. `OnEnterState`/`OnExitState`/`OnUpdateState`의 `switch`는 같은 모양이다.
* `ChangeState`: 같은 상태로는 바뀌지 않고, 나가는 함수를 부른 뒤 상태를 바꾸고 들어가는 함수를 부른다.
* `Finish`는 주석에 "피격 후 소멸(처형) 상태"라고 돼 있으나, `PlayerController`와 `AIController` 어디서도 쓰이지 않는다. 예전 `Hit` 상태를 바꾼 흔적이다.

### PlayerController

{% code title="Etc/PlayerController.cs (일부)" %}
```csharp
public class PlayerController : BaseFSM
{
    public float moveSpeed = 6.0f;
    public float autoRunSpeed = 8.0f;
    public float rotateSpeed = 10.0f;

    protected override void Update_Idle()
    {
        if (IsMoveInputActive()) { ChangeState(UnitState.Move); return; }
        if (Input.GetKeyDown(KeyCode.R)) ChangeState(UnitState.Patrol);
    }

    protected override void Update_Move()
    {
        if (!IsMoveInputActive()) { ChangeState(UnitState.Idle); return; }
        ProcessMovement(moveSpeed);
        if (Input.GetKeyDown(KeyCode.R)) ChangeState(UnitState.Patrol);
    }

    protected override void Update_Patrol()
    {
        if (Input.GetAxisRaw("Vertical") < -0.1f) { ChangeState(UnitState.Idle); return; }
        transform.Translate(Vector3.forward * autoRunSpeed * Time.deltaTime);
        float h = Input.GetAxisRaw("Horizontal");
        if (Mathf.Abs(h) > 0.01f) transform.Rotate(Vector3.up * h * rotateSpeed * Time.deltaTime);
    }

    private void ProcessMovement(float speed)
    {
        Vector3 targetDir = new Vector3(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical")).normalized;
        transform.Translate(targetDir * speed * Time.deltaTime, Space.World);
        if (targetDir != Vector3.zero)
            transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.LookRotation(targetDir), Time.deltaTime * rotateSpeed);
    }
}
```
{% endcode %}

* `Idle`에서 입력이 생기면 `Move`, `R` 키를 누르면 `Patrol`(여기서는 자동 달리기)로 간다. `Move`에서 입력이 사라지면 `Idle`로 돌아간다.
* 이동은 월드 축 기준(`Space.World`)이고 카메라 방향과 무관하다. 이동하는 쪽을 보도록 `Slerp`로 천천히 회전한다.
* 자동 달리기는 캐릭터의 앞 방향(`Vector3.forward`, 로컬)으로 가며, `S`(뒤로)를 누르면 해제된다.
* 구 Input Manager(`Input.GetAxis`)를 쓴다. 이 프로젝트의 설정이 구 방식이다.

### AIController

{% code title="Etc/AIContller.cs (일부)" %}
```csharp
public class AIController : BaseFSM
{
    public float patrolSpeed = 3.0f, chaseSpeed = 5.5f, waitTime = 2.0f, detectRange = 5.0f;
    public WaypointPath path;
    private int currentWaypointIndex = 0;
    public Transform playerTarget;

    protected override void Update_Idle()
    {
        if (CheckPlayerInRange()) { ChangeState(UnitState.Move); return; }
        timer -= Time.deltaTime;
        if (timer <= 0f)
        {
            if (path != null) currentWaypointIndex = path.GetNextIndex(currentWaypointIndex);
            ChangeState(UnitState.Patrol);
        }
    }

    protected override void Update_Patrol()
    {
        if (CheckPlayerInRange()) { ChangeState(UnitState.Move); return; }
        if (path == null) return;
        Transform target = path.GetWaypoint(currentWaypointIndex);
        if (target == null) return;
        MoveTo(target.position, patrolSpeed);
        if (Vector3.SqrMagnitude(target.position - transform.position) < 0.1f) ChangeState(UnitState.Idle);
    }

    private bool CheckPlayerInRange()
    {
        if (playerTarget == null) return false;
        return Vector3.SqrMagnitude(playerTarget.position - transform.position) < (detectRange * detectRange);
    }
}
```
{% endcode %}

* 흐름: `Idle`(대기) → 시간이 차면 다음 웨이포인트 선택 → `Patrol`(이동) → 도착하면 `Idle`. 어느 상태에서든 플레이어가 `detectRange` 안에 들어오면 `Move`(추적)로 가고, 벗어나면 `Patrol`로 돌아온다.
* 거리 비교에 `SqrMagnitude`(거리의 제곱)를 쓰고 `detectRange * detectRange`와 비교한다. 제곱근 계산을 피하는 일반적인 최적화다.
* 순찰 지점 계산은 `WaypointPath`에게 넘겼다. 주석 "[삭제] NextWaypoint() 함수는 WaypointPath 클래스로 로직이 이전되어 삭제되었습니다."가 그 변경을 설명한다.
* `Idle`에 들어갈 때 `timer = waitTime`으로 초기화한다. 이동 함수 이름 `MoveTo`는 GOS의 `MoveTo` 노드와 이름이 같지만 이 클래스 안의 가상 메서드이며 별개다.

### WaypointPath

{% code title="Etc/WaypontPath.cs (일부)" %}
```csharp
public class WaypointPath : MonoBehaviour
{
    public Transform[] points;
    public bool loop = true;

    public Transform GetWaypoint(int index)
    {
        if (points == null || points.Length == 0) return null;
        return points[index % points.Length];
    }

    public int GetNextIndex(int currentIndex)
    {
        if (points == null || points.Length == 0) return 0;
        int nextIndex = currentIndex + 1;
        if (nextIndex >= points.Length) return loop ? 0 : points.Length - 1;
        return nextIndex;
    }

    private void OnDrawGizmos()
    {
        if (points == null || points.Length < 2) return;
        Gizmos.color = Color.cyan;
        for (int i = 0; i < points.Length; i++)
        {
            if (points[i] == null) continue;
            Gizmos.DrawSphere(points[i].position, 0.3f);
            int next = (i + 1) % points.Length;
            if (points[next] != null) Gizmos.DrawLine(points[i].position, points[next].position);
        }
    }
}
```
{% endcode %}

* `loop`가 켜지면 마지막 다음에 0번으로, 꺼지면 마지막 지점에 머문다.
* `OnDrawGizmos`는 Scene 뷰에서 지점마다 청록색 구를, 지점 사이에 선을 그린다. 마지막과 0번도 이어서 보여 주므로 `loop`가 꺼져 있어도 선은 닫혀 보인다.

### ObjectPoolManager, CharacterPush

{% code title="Etc/ObjectPoolManager.cs (일부)" %}
```csharp
private Dictionary<string, Queue<GameObject>> _poolDict = new Dictionary<string, Queue<GameObject>>();

public GameObject Spawn(GameObject prefab, Vector3 position, Quaternion rotation)
{
    string key = prefab.name;
    if (!_poolDict.ContainsKey(key)) _poolDict.Add(key, new Queue<GameObject>());

    GameObject obj;
    if (_poolDict[key].Count > 0)
    {
        obj = _poolDict[key].Dequeue();
        obj.SetActive(true);
        obj.transform.position = position;
        obj.transform.rotation = rotation;
    }
    else obj = Instantiate(prefab, position, rotation);
    return obj;
}

public void Despawn(GameObject obj)
{
    obj.SetActive(false);
    string key = obj.name.Replace("(Clone)", "").Trim();
    if (_poolDict.ContainsKey(key)) _poolDict[key].Enqueue(obj);
}
```
{% endcode %}

* 프리팹 이름을 키로, 꺼 둔 오브젝트를 큐에 쌓아 두었다가 재사용한다. 반납(`Despawn`)은 오브젝트를 끄고 큐에 넣는다. 키는 `(Clone)`을 뗀 이름이다.
* `CharacterPush`는 `OnControllerColliderHit`에서 부딪힌 `Rigidbody`에 `pushDir * pushPower`를 `Impulse`로 가한다. 발 아래(`moveDirection.y < -0.3`)와 `Kinematic` 물체는 무시한다. 이 콜백은 `CharacterController`가 있을 때만 불리는데, `PlayerController`는 `CharacterController` 없이 `Translate`로 움직이므로 샘플 구성에서는 쓰이지 않는다.

## 따라 만들기

1. 빈 프로젝트에서 `ManagerBase<T>`를 발췌대로 작성한다. 확인 방법: `GameManager : ManagerBase<GameManager>`를 만들고 씬에 아무것도 두지 않은 채 `GameManager.instance`를 부르면 `GameManager (Singleton)`이라는 오브젝트가 생기고, 같은 오브젝트가 씬 전환 후에도 유지된다.
2. `BaseFSM`과 `UnitState`를 작성한다. 확인 방법: `Debug.Log`만 넣은 자식 클래스를 만들어 상태를 바꿔 보면 `Exit → Enter` 순서로 로그가 나온다.
3. `PlayerController`를 작성해 `Cube`에 붙인다. 확인 방법: WASD로 이동하고 이동 방향으로 회전한다. `R`을 누르면 앞으로 계속 달리고 `S`를 누르면 멈춘다. 인스펙터의 `currentState`가 따라 바뀐다.
4. `WaypointPath`를 빈 오브젝트에 붙이고 지점 3~4개를 `points`에 넣는다. 확인 방법: Scene 뷰에서 청록색 구와 선이 보인다.
5. `AIController`를 다른 `Cube`에 붙이고 `path`와 `playerTarget`(플레이어)을 지정한다. 확인 방법: 대기 → 순찰을 반복하고, 플레이어가 5미터 안으로 오면 `!! 침입자 발견 !! 추적 시작` 로그와 함께 쫓아온다. 멀어지면 `추적 종료. 정찰 복귀.`가 찍힌다.
6. `ObjectPoolManager`를 빈 오브젝트에 붙이고 테스트 스크립트에서 `Spawn`/`Despawn`을 번갈아 부른다. 확인 방법: 두 번째 `Spawn`부터 `Instantiate`가 아니라 꺼져 있던 오브젝트가 다시 켜진다(Hierarchy의 오브젝트 수가 늘지 않는다).
7. 패키지를 만든다. 공유할 폴더(`Assets/GOS`)를 Project 창에서 우클릭해 `Export Package...`를 고르고 `Include dependencies`를 켠 뒤 `.unitypackage`로 저장한다(Unity 일반 기능). 확인 방법: 비어 있는 새 프로젝트에 `Assets > Import Package > Custom Package`로 가져오면 `Assets/GOS` 구조가 그대로 생긴다. Cinemachine, Timeline 등 패키지는 가져온 프로젝트에서 따로 설치해야 한다(`.unitypackage`는 패키지 의존성을 담지 않는다).

## 한계·주의

* **레포의 `.unitypackage`는 소스보다 오래됐다.** 파일은 1094d49c에서 마지막으로 갱신됐다. 안의 항목 111개(폴더 포함)를 풀어 보면 `VisualScriptingEditor.cs`가 있고, 이후 추가된 `InputEvent`, `RaycastTrigger`, `EntryModifierEvent`, `Spawner`가 없다. 패키지로 가져오는 수업 환경에서는 레포 최신 소스와 기능이 다를 수 있다.
* 이 레포의 스크립트 상당수가 CP949로 저장돼 있다는 점을 기억하자. 다른 에디터로 열어 저장하면 한글 주석이 깨질 수 있다.
* 파일 이름과 클래스 이름이 다른 `AIContller.cs`(클래스 `AIController`), `WaypontPath.cs`(`WaypointPath`)는 샘플 프리팹·씬이 스크립트 GUID로 직접 참조하고 있다. 레포 안에서는 의도적으로 쓰이는 셈이지만, Unity 6에서 이 참조가 정상적으로 풀리는지는 **확인 필요**다. 새로 만들 때는 파일 이름과 클래스 이름을 같게 하는 것이 안전하다.
* `ObjectPoolManager`와 `CharacterPush`는 레포 안에서 쓰는 곳이 없다. `ObjectPoolManager`는 싱글톤이 아니고 미리 만들어 두는(prewarm) 기능도 없으며, `Despawn`은 `Spawn`으로 만든 적이 있는 프리팹 이름만 큐에 넣는다. 이름이 같은 다른 프리팹은 섞인다.
* `AIController`의 첫 순찰은 0번이 아니라 1번 지점부터다. 시작 시 `currentWaypointIndex`가 0이고 `Idle`이 끝날 때 먼저 `GetNextIndex`를 부르기 때문이다(코드 읽기).
* `PlayerController`는 `Finish` 상태를 쓰지 않는다. `Docs/GOS_Framework_Analysis.md`가 "카메라 방향 정렬"을 한다고 쓴 것과 달리 코드는 월드 축 기준으로 움직인다.
* `ManagerBase`의 `lock`은 Unity 메인 스레드 전용 속성에서는 효과가 없다.
* 모든 동작 판단은 코드 읽기에 근거한 것이며 **unverified**다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 상태 머신(FSM)으로 캐릭터를 만들면 `if`/`else`를 나열하는 방식보다 무엇이 나아지는가? 직접 겪은 예가 있다면 적어 보자.
- [ ] 싱글톤 `GameManager`가 편리한 점과 위험한 점을 각각 한 가지씩 적어 보자.
- [ ] 내 프로젝트를 `.unitypackage`로 배포한다면 무엇을 넣고 무엇을 뺄지, 이 레포가 이펙트 에셋을 지운 결정과 비교해서 적어 보자.
