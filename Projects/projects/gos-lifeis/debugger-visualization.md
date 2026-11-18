# 런타임 디버거와 시각화

## 무엇이 바뀌었나

원본 GOS에는 디버깅 도구가 없었다. 노드가 동작하는지 보려면 `Debug.Log`를 직접 넣거나 `OnDrawGizmos`에 의존해야 했다. 포크는 `VisualScripting/Debug/` 폴더에 도구 4개를 추가했다.

| 파일 | 하는 일 | 추가 커밋 |
| --- | --- | --- |
| `VisualLogger.cs` | `this.Log("...")`처럼 어떤 `UnityEngine.Object`에서든 부를 수 있는 로그 확장 메서드. 에디터에서만 동작 | 38f2e184 (a69677bc, 842c05d8에서 수정) |
| `RuntimeConsole.cs` | 플레이 중 화면에 로그 창을 그리는 `OnGUI` 콘솔. 백틱(`~`) 키로 열고 닫음 | a69677bc |
| `BoxColliderVisualizer.cs` | `BoxCollider` 영역을 `LineRenderer`로 그려 Game 뷰에서도 트리거 범위를 보이게 함 | 38f2e184 |
| `DebuggerMassge.cs` | 생명주기 함수(`Awake`, `OnEnable`, `Start`, `Update` 등)가 처음 불릴 때 한 번씩 로그 | 38f2e184 |

노드 쪽에서는 `Trigger`, `TriggerTimmer`, `LightingControl`, `CameraControl` 등이 `this.Log(...)` 또는 `VisualLogger.LogError(this, ...)`를 쓰도록 바뀌었다. `ProcessBase`에는 에디터 전용 `ForceExecute()`가 추가돼, 인스펙터에서 노드를 강제로 실행할 수 있다([editor-tools.md](editor-tools.md)).

## 왜

커밋 메시지는 a69677bc "디버그 시각화 및 런타임 디버거 업데이트"가 전부다. 코드에서 읽히는 이유는 이렇다.

* GOS 노드는 서로를 참조하는 연결(`ProcessData`)로 동작하므로, "어느 노드가 언제 켜졌는지"를 알아야 연결 오류를 찾을 수 있다. 그래서 로그에 오브젝트 이름을 색으로 붙여 콘솔에서 구분한다.
* 트리거는 눈에 보이지 않는 `BoxCollider`다. 에디터 기즈모(`OnDrawGizmos`)는 Game 뷰와 빌드에서 안 보이므로 `LineRenderer`로 따로 그린다.
* 빌드된 게임에서는 Unity 콘솔을 볼 수 없다. 그래서 `Application.logMessageReceived`를 받아 `OnGUI`로 그리는 콘솔을 만든다.

`VisualLogger`는 두 번 바뀌었다. 38f2e184는 화면 출력용 `OnLogReceived` 이벤트가 있는 버전, a69677bc는 이벤트를 빼고 `[Conditional("DEBUG"), Conditional("UNITY_EDITOR")]`를 쓰는 단순 버전이고, 842c05d8이 다시 이벤트 버전으로 되돌렸다. 되돌린 이유는 메시지에 없다.

## 핵심 코드

### VisualLogger

{% code title="Debug/VisualLogger.cs" %}
```csharp
public static class VisualLogger
{
    public static event Action<string, Color> OnLogReceived;

    [Conditional("UNITY_EDITOR")]
    public static void Log(this UnityEngine.Object context, string message, bool showLog = true)
    {
        if (!showLog) return;

        string objectName = (context != null) ? context.name : "Global";
        Debug.Log($"<color=#00FF00>[{objectName}]</color> {message}", context);

        OnLogReceived?.Invoke($"[{objectName}] {message}", Color.white);
    }

    [Conditional("UNITY_EDITOR")]
    public static void LogError(this UnityEngine.Object context, string message)
    {
        Debug.LogError($"[{context.name}] {message}", context);
        OnLogReceived?.Invoke($"[Error] {message}", Color.red);
    }
}
```
{% endcode %}

* `this UnityEngine.Object context`: 확장 메서드라서 `MonoBehaviour` 안에서 `this.Log("...")`로 부를 수 있다. 이름 앞의 초록색 `[오브젝트 이름]`이 콘솔에서 로그를 구분해 준다. 두 번째 인자 `context`를 `Debug.Log`에 넘기므로 콘솔의 로그를 클릭하면 Hierarchy에서 해당 오브젝트가 선택된다.
* `[Conditional("UNITY_EDITOR")]`: 에디터가 아닌 빌드에서는 **호출 자체가 컴파일에서 제거된다.** 그래서 노드 코드가 `#if UNITY_EDITOR`로 감싸지 않고 `VisualLogger.LogError(this, "...")`를 불러도 빌드가 깨지지 않는다.
* `OnLogReceived`: 화면 출력 도구가 구독하도록 만든 이벤트다. 다만 이 레포 안에 구독하는 코드가 없고, `RuntimeConsole`도 이 이벤트가 아니라 `Application.logMessageReceived`를 쓴다.

### RuntimeConsole

{% code title="Debug/RuntimeConsole.cs (일부)" %}
```csharp
public KeyCode toggleKey = KeyCode.BackQuote;
public int maxLogs = 1000;
[SerializeField] private bool isVisible = false;
private List<LogEntry> logs = new List<LogEntry>();

private void OnEnable()  { Application.logMessageReceived += HandleUnityLog; }
private void OnDisable() { Application.logMessageReceived -= HandleUnityLog; }

private void Update()
{
    if (Input.GetKeyDown(toggleKey)) isVisible = !isVisible;
}

private void HandleUnityLog(string logString, string stackTrace, LogType type)
{
    Color logColor = Color.white;
    string finalMessage = logString;
    switch (type)
    {
        case LogType.Error:
        case LogType.Exception:
        case LogType.Assert:
            logColor = Color.red;
            if (type == LogType.Exception)
                finalMessage = $"{logString}\n<size=11>{stackTrace}</size>";
            break;
        case LogType.Warning: logColor = Color.yellow; break;
    }
    logs.Add(new LogEntry { message = finalMessage, color = logColor, count = 1 });
    if (logs.Count > maxLogs) logs.RemoveAt(0);
}
```
{% endcode %}

* `Application.logMessageReceived`: Unity가 모든 `Debug.Log` 계열 호출과 예외를 알려 주는 이벤트다. 구독하면 우리 코드 밖에서 나온 로그까지 전부 받는다.
* `OnEnable`/`OnDisable`: 구독과 해제를 짝으로 둔다. 해제하지 않으면 오브젝트가 사라진 뒤에도 콜백이 남는다.
* `HandleUnityLog`: 로그 종류에 따라 색을 정하고(오류는 빨강, 경고는 노랑), 예외에는 스택 트레이스를 붙인다. `maxLogs`를 넘으면 가장 오래된 것을 지운다.
* 같은 파일의 `OnGUI`는 `Clear`, `Collapse`(같은 메시지 묶기), `Auto Scroll`, `Errors Only` 토글과 `Save to Log.txt` 버튼을 그린다. 저장은 `Application.persistentDataPath` 아래 `RuntimeLog_날짜시각.txt`로 한다.
* `Input.GetKeyDown`은 구 Input Manager 방식이다. 이 프로젝트의 `ProjectSettings`는 `activeInputHandler: 0`이라 구 방식으로 설정돼 있다.

### BoxColliderVisualizer

{% code title="Debug/BoxColliderVisualizer.cs (일부)" %}
```csharp
[ExecuteInEditMode]
[RequireComponent(typeof(BoxCollider))]
[RequireComponent(typeof(LineRenderer))]
public class BoxColliderVisualizer : MonoBehaviour
{
    [SerializeField] private Color lineColor = Color.green;
    [SerializeField] private float lineWidth = 0.05f;

    private void Initialize()
    {
        _boxCollider = GetComponent<BoxCollider>();
        _lineRenderer = GetComponent<LineRenderer>();
        _lineRenderer.useWorldSpace = false;
        if (_lineRenderer.sharedMaterial == null)
            _lineRenderer.sharedMaterial = new Material(Shader.Find("Sprites/Default"));
    }

    private void DrawBox()
    {
        Vector3 center = _boxCollider.center;
        Vector3 half = _boxCollider.size * 0.5f;
        Vector3 p0 = center + new Vector3(-half.x, -half.y, -half.z);
        // ... p1~p7 도 같은 방식으로 8개 꼭짓점 계산
        Vector3[] positions = { p0, p1, p2, p3, p0, p4, p5, p6, p7, p4, p5, p1, p1, p2, p2, p6, p6, p7, p7, p3 };
        _lineRenderer.positionCount = positions.Length;
        _lineRenderer.SetPositions(positions);
    }
}
```
{% endcode %}

* `[RequireComponent]`: `BoxCollider`와 `LineRenderer`가 없으면 자동으로 붙인다.
* `useWorldSpace = false`: 선의 좌표를 오브젝트 로컬 기준으로 둔다. 오브젝트가 움직이거나 회전해도 박스가 같이 따라간다.
* `DrawBox`: 콜라이더의 `center`와 `size`로 꼭짓점 8개를 구해, 선 하나로 이어지게 경로를 짠다. 선분이 끊기지 않으므로 같은 꼭짓점을 두 번 지나가는 구간이 있다(발췌의 `positions`는 줄이기 위해 원문의 주석과 줄바꿈을 줄였다).
* `[ExecuteInEditMode]`와 `OnValidate`: 에디터에서 값을 바꾸는 즉시 반영된다. `Update`에서도 매 프레임 `DrawBox`를 부르므로 콜라이더가 런타임에 바뀌어도 따라간다.

### DebuggerMassge

생명주기 함수마다 `Debug.Log($"{gameObject.name}.Awake()")` 같은 한 줄을 넣은 컴포넌트다. `Update`, `FixedUpdate`, `LateUpdate`는 불린 적이 있으면 `isLogged...` 플래그로 한 번만 찍는다. 이름 그대로 "실행 순서를 눈으로 확인하는" 학습용이다. `updateLogger` 필드는 선언만 있고 쓰이지 않는다(컴파일 경고 CS0414, 레포의 `unity_build.log`에 기록).

## 따라 만들기

1. `Assets/Scripts/Debug/VisualLogger.cs`를 만든다. 발췌의 `Log` 확장 메서드만 우선 작성한다(이벤트는 뒤에서 써 볼 때만 추가). 확인 방법: 아무 `MonoBehaviour`의 `Start()`에서 `this.Log("hello")`를 부르면 콘솔에 초록색 `[오브젝트이름] hello`가 보이고, 로그를 클릭하면 해당 오브젝트가 선택된다.
2. 에디터가 아닌 플레이어 빌드를 한 번 만들어 컴파일 오류가 없는지 본다. 확인 방법: 호출부에 `#if`가 없는데도 빌드가 통과한다. 이것이 `[Conditional]`의 효과다.
3. `RuntimeConsole`을 만든다. `Application.logMessageReceived`를 구독하고 리스트에 쌓는 부분부터 쓴다. 확인 방법: 씬에 빈 오브젝트를 만들어 붙이고 플레이한 뒤, 인스펙터의 `isVisible`을 켜 보면 `OnGUI`에 로그가 보인다.
4. `OnGUI`를 완성한다. `GUI.Box`로 창 배경, `GUILayout.Toggle`/`Button`으로 상단 바, `GUI.BeginScrollView`로 로그 목록을 그린다. 확인 방법: `~` 키를 누를 때마다 창이 열리고 닫히며, `Debug.LogWarning`은 노랑, `Debug.LogError`는 빨강으로 나온다.
5. `Save to Log.txt` 버튼에 `Application.persistentDataPath`로 파일을 쓰는 `SaveLogToFile`을 연결한다. 확인 방법: 버튼을 누른 뒤 콘솔에 저장 경로 로그가 나오고 그 경로에 파일이 생긴다.
6. `BoxColliderVisualizer`를 만든다. 확인 방법: `BoxCollider`가 있는 오브젝트에 붙이면 `LineRenderer`가 자동으로 붙고, Game 뷰에서도 초록 선 상자가 보인다. `size`를 바꾸면 선이 따라 바뀐다.
7. 기존 노드 `Trigger`의 `OnTriggerEnter`에 `this.Log($"진입 감지: {other.name}")`를 넣어 본다. 확인 방법: 태그가 맞는 오브젝트가 들어올 때 콘솔에 로그가 나온다.

## 한계·주의

* `VisualLogger.LogError`는 `context.name`을 널 검사 없이 읽는다. `context`가 `null`이면 예외가 난다. a69677bc 버전은 널 검사가 있었는데 842c05d8에서 되돌린 버전에는 없다.
* `RuntimeConsole`은 이 레포의 어떤 프리팹·씬에도 배치돼 있지 않다(스크립트 GUID로 검색해 확인). `DebuggerMassge`도 같다. 쓰려면 직접 붙여야 한다. `BoxColliderVisualizer`는 프리팹 7개(`TriggerObject`, `TriggeEnterObject`, `TeleportTrigger`, `TimmerActive`, `RotateDoorTrigger`, `Door(MoveTo)`, `PuzzleDoor`)에서 쓰인다.
* `RuntimeConsole`의 `Errors Only`는 로그 색이 빨강인지로 걸러낸다. `Collapse`의 개수 표시는 화면용 목록에서만 계산된다. 로그를 파일로 저장할 때는 묶지 않은 원본 목록이 저장된다.
* `LineRenderer`로 그린 선은 렌더러라서 실제 게임 화면에도 보인다. 배포 빌드에서는 컴포넌트를 떼거나 끄는 별도 처리가 필요하다. 이 처리는 코드에 없다.
* 같은 폴더의 `DatabaseManager`에도 `OnGUI` 기반 "Database Runtime Debugger"가 있다([custom-data.md](custom-data.md)).
* 모든 판단은 코드 읽기에서 나온 것이며 **unverified**다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `[Conditional("UNITY_EDITOR")]`가 붙은 메서드와 `#if UNITY_EDITOR`로 감싼 호출은 무엇이 같고 무엇이 다른가? 내 말로 비교해 보자.
- [ ] 콘솔 창 없이 디버깅해야 했던 경험(모바일 빌드 등)이 있는가? 그때 어떻게 로그를 확인했는지 적어 보자.
- [ ] 눈에 보이지 않는 트리거 범위를 Game 뷰에서 확인하고 싶다면 기즈모와 `LineRenderer` 중 어느 쪽을 고를지, 이유와 함께 적어 보자.
