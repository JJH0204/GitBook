# 씬 부트스트랩과 Persistent 씬

## 무엇을 하는가

게임은 한 개의 큰 씬으로 돌아가지 않고 여러 씬을 겹쳐 올리는 구조다. 가장 먼저 실행되는 Bootstrap 씬은 아주 작고, 하는 일은 "Persistent 씬을 불러오는 것" 하나다. Persistent 씬은 `GameManager`, `DungeonManager`, `PoolManager` 같은 매니저 프리팹을 한꺼번에 만들고 사라진다. 이후 모든 씬 로드와 언로드는 `SceneController` 하나를 거친다.

## 왜 이렇게 설계했나

- 매니저를 씬마다 배치하면 어느 씬에서 시작해도 동작하도록 중복 배치와 순서 문제를 신경 써야 한다. 한 씬(Persistent)에 모아 두고 목록(`managersPrefabs`)으로 생성하면 "어떤 매니저가 있는가"가 Inspector 한 곳에 보인다.
- 씬 로드를 `SceneController`로 감싸 Addressables 핸들을 키(주소 문자열)별로 보관한다. 같은 키의 중복 로드를 막고, 언로드할 때 핸들을 그대로 넘길 수 있다. (코드 구조에서 읽은 이유이며, 커밋 메시지에 직접 적힌 설명은 아니다.)
- 에디터에서 어느 씬을 열어 두었든 Bootstrap부터 시작하도록 메뉴 도구를 추가했다(커밋 `40a8977b`, 에디터 도구 추가).

## 핵심 코드

{% code title="InitPersistent.cs (발췌)" %}
```csharp
[Serializable]
public struct ManagerInfo
{
    public EManagerType managerType;
    public GameObject managerPrefab;
}

public class InitPersistent : MonoBehaviour
{
    [SerializeField] private ManagerInfo[] managersPrefabs;

    private void Awake()
    {
        Dictionary<EManagerType, GameObject> createdManagers = new ();

        foreach (ManagerInfo managerInfo in managersPrefabs)
        {
            if (!managerInfo.managerPrefab) continue;
            if (createdManagers.ContainsKey(managerInfo.managerType)) continue;

            GameObject managerInstance = Instantiate(managerInfo.managerPrefab);
            createdManagers.Add(managerInfo.managerType, managerInstance);
        }

        GameManager.Instance.SceneLoaded();   // 모든 매니저가 만들어졌음을 알림
        Destroy(gameObject);
    }

    private void OnDestroy()
    {
        GameManager.Instance.EnterTitle();
    }
}
```
{% endcode %}

- `ManagerInfo`: "종류 + 프리팹" 한 쌍. `EManagerType` 열거형에는 `DungeonStateManager`, `MapManager` 등이 추가되어 왔다(커밋 `39ce46d4`, `eee92801`에서 `InitPersistent.cs`가 수정됨).
- `Awake`의 `foreach`: 프리팹이 비어 있거나 같은 종류가 이미 만들어졌으면 건너뛴다. 실수로 같은 매니저를 두 번 넣어도 한 번만 만들어진다.
- `GameManager.Instance.SceneLoaded()`: `GameManager`는 `Singleton<T>`다. 위 루프에서 `GameManager` 프리팹이 이미 생성되었으면 `FindObjectOfType`으로 그 인스턴스를 찾고, 없으면 빈 오브젝트를 새로 만든다.
- `Destroy(gameObject)` 직후 `OnDestroy`가 불려 `EnterTitle()`이 시작된다. 즉 "초기화 완료 뒤 스스로 사라지면서 다음 단계(타이틀)를 연다"는 구조다.

{% code title="SceneController.cs (발췌)" %}
```csharp
public class SceneController : Singleton<SceneController>
{
    private Dictionary<string, AsyncOperationHandle<SceneInstance>> _loadedScenes = new();

    public async Task LoadSceneAdditive(string key)
    {
        if (_loadedScenes.ContainsKey(key)) return;   // 중복 로드 방지

        AsyncOperationHandle<SceneInstance> handle =
            Addressables.LoadSceneAsync(key, LoadSceneMode.Additive);
        await handle.Task;

        if (handle.Status == AsyncOperationStatus.Succeeded)
            _loadedScenes.Add(key, handle);
        else
            Debug.LogError($"[SceneController] {key} 로드 실패!");
    }

    public async Task UnloadScene(string key)
    {
        if (!_loadedScenes.TryGetValue(key, out var handle)) return;

        await Addressables.UnloadSceneAsync(handle).Task;
        _loadedScenes.Remove(key);
    }
}
```
{% endcode %}

- 키는 Addressables에 등록한 주소 문자열이다. `LoadSceneMode.Additive`이므로 기존 씬은 유지된다.
- 핸들은 성공했을 때만 딕셔너리에 저장한다. 언로드는 저장된 핸들로만 가능하므로, 이 클래스를 거치지 않고 로드한 씬은 `UnloadScene`으로 내릴 수 없다.
- 실제 파일에는 `try/catch`와 로그, 활성 씬을 지정하는 `SetActiveScene`도 있다. 위 발췌에서는 생략했다.

`InitBootstrap`은 `Start`에서 `Addressables.LoadSceneAsync("Scene_Persistent", Additive)`를 기다린 뒤 성공하면 그 씬을 활성 씬으로 지정한다. 시작할 때 `Screen.SetResolution`으로 가로 720 기준의 해상도를 설정하는 코드도 같은 파일에 있다(모바일 빌드를 고려한 설정으로 보이나 확신할 수 없다).

`InitPlayer`는 Player 씬에 놓인 같은 방식의 초기화기다. 프리팹 목록(`Player`, `Minimap`, `FollowCamera` 등)을 만들고, `GameManager.Player`와 `MonsterManager.Player`에 플레이어를 등록하고, Cinemachine 가상 카메라의 `Follow`와 `LookAt`을 플레이어의 카메라 타깃에 연결한 뒤 자신을 파괴한다.

## 따라 만들기 단계

1. 빈 Unity 프로젝트에 Addressables 패키지를 설치하고 `Window > Asset Management > Addressables > Groups`에서 기본 그룹을 만든다.
   - 확인 방법: Groups 창이 열리고 `Default Local Group`이 보인다.
2. `Singleton<T>`를 만든다. `Instance`는 `FindObjectOfType`으로 찾고, 없으면 `new GameObject`에 `AddComponent<T>()`한 뒤 `DontDestroyOnLoad`를 호출한다.
   - 확인 방법: 임의의 싱글턴 클래스를 씬에 두지 않고 `Instance`를 호출하면 하이어라키에 `(Singleton)`이라는 이름의 오브젝트가 생긴다.
3. `SceneController`를 위 발췌대로 만든다(`LoadSceneAdditive`, `UnloadScene`).
   - 확인 방법: 테스트 씬을 Addressable로 등록해 키를 정하고, 버튼 하나로 로드·언로드를 호출했을 때 하이어라키에서 씬이 겹쳐 올라오고 사라진다.
4. `Scene_Persistent` 씬을 만들고 `InitPersistent`를 빈 오브젝트에 붙인다. 매니저 프리팹(우선 `GameManager` 하나)을 `managersPrefabs`에 넣는다. 이 씬도 Addressable로 등록하고 주소를 `Scene_Persistent`로 둔다.
   - 확인 방법: 이 씬을 단독으로 플레이하면 `GameManager` 인스턴스가 생기고 `InitPersistent` 오브젝트는 사라진다.
5. `Bootstrap` 씬을 만들고 `InitBootstrap`을 붙인다. Build Settings에는 Bootstrap 씬만 넣는다.
   - 확인 방법: Bootstrap 씬에서 플레이하면 Persistent 씬이 Additive로 올라오고 활성 씬이 Persistent로 바뀐다.
6. (선택) `StartBootstrap` 에디터 스크립트로 메뉴 `Tools/Play Bootstrap Scene`을 만든다. 현재 씬을 저장할지 묻고(`SaveCurrentModifiedScenesIfUserWantsTo`), Bootstrap 씬을 열고, `EditorApplication.isPlaying = true`를 설정한다. 이미 플레이 중이면 정지만 한다.
   - 확인 방법: 아무 씬을 열어 둔 상태에서 메뉴를 누르면 Bootstrap부터 플레이된다.

## 막히기 쉬운 곳과 한계

- 씬 경로가 상수로 박혀 있다. `StartBootstrap`의 `BootstrapScenePath`는 `Assets/_GameAssets/04. Scenes/Bootstrap.unity`이고, `LoadAllGameScene`의 폴더 경로(`Assets/_Test/Scene/GameScene`)는 폴더 정리 이후의 구조와 맞는지 확인되지 않았다. 코드상으로는 폴더가 없으면 오류 로그만 남기고 중단한다. 따라 만들 때는 자기 프로젝트의 경로로 바꿔야 한다.
- `InitPersistent.Awake`가 예외를 삼키고 `Debug.Log`만 남긴다. 매니저 생성이 중간에 실패해도 `OnDestroy`나 이후 단계에서 다른 증상으로 나타날 수 있다.
- `OnDestroy`에서 `GameManager.Instance`를 호출하므로, 종료 시점에 `OnDestroy`가 불리면 싱글턴이 다시 만들어질 가능성이 있다. 이 구조의 위험은 코드를 읽고 짐작한 것이며 확인하지 않았다.
- `InitBootstrap`에서 Bootstrap 씬 자신을 내리는 줄은 주석 처리되어 있다. 즉 Bootstrap 씬은 계속 남는다.
- `EManagerType`에는 `SceneManager`, `MapManager` 같은 항목이 있지만, 이 영역의 코드에서 `MapManager` 스크립트는 찾지 못했다. 프리팹 구성은 확인하지 못했다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 매니저를 씬에 직접 배치하지 않고 `InitPersistent`가 프리팹으로 생성하게 만든 이유는 무엇이라고 생각하는가?
- [ ] `LoadSceneMode.Additive`와 `Single`의 차이를 내 말로 설명하고, 이 프로젝트에서 Additive가 필요한 이유를 적어 본다.
- [ ] 직접 Bootstrap 구조를 만들어 보며 처음 막힌 지점은 어디였고 어떻게 풀었는가?
