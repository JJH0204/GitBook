# 씬 테스트 도구: 런처, 무적 모드, 적 피해 배율

## 무엇을 하는가

보스 스킬을 확인하려면 원래는 게임을 처음부터 해서 보스 방까지 가야 한다. 이 도구들은 지정한 씬을 바로 실행해서 "보스 방에 서 있는 상태"를 만든다.

| 구성 요소 | 위치 | 역할 |
| --- | --- | --- |
| `SceneTestLauncher` | `Editor/` | `Tools > Scene Test Launcher` 창과 `F6` 단축키. 씬, 로드 방식, 무적 모드, 적 피해 배율을 고르고 플레이한다. |
| `ISceneTestHook` | `Test/` | 인게임 셋업이 끝난 직후 호출되는 인터페이스(`OnTestStart`). |
| `SceneTestFSMActivator` | `Test/` | 훅 구현. 지정한 FSM(예: 아몬 2페이즈)의 `isEnabled`를 켠다. |
| `SceneTestInvincibility` | `Test/` | 플레이어에 동적으로 붙어 무적을 유지한다. |
| `TestManager` | `Test/` | 적 피해 배율과 무적 여부를 담는 정적 클래스. |

로드 방식은 세 가지다.

* `Direct`: 대상 씬을 에디터에서 그대로 열고 플레이한다. Addressables에 등록되지 않은 씬용이다.
* `BootstrapAdditive`: 부트스트랩 씬부터 시작해 대상 씬만 Additive로 로드한다.
* `BootstrapInGame`: 위에 더해 풀 초기화, 플레이어 씬 로드, 시작 위치 이동, 게임 시작까지 재현한다. 무적 모드와 피해 배율은 이 모드에서만 적용된다.

{% hint style="info" %}
동작 설명은 코드를 읽고 쓴 것이다. Unity 에디터에서 실행해 확인하지 않았다(unverified).
{% endhint %}

## 왜 이렇게 설계했나

커밋 순서(`d80d9ae9` 런처 추가, `256d5718` 훅 추가, `900df9f4` 무적과 배율, `7b289ce5` 무적 플래그 보정)를 따라가면 필요가 생길 때마다 한 층씩 얹힌 모양이다.

* **부트스트랩을 거친다.** 이 게임은 매니저와 로딩 파이프라인이 부트스트랩 씬에서 만들어진다. 대상 씬을 그냥 열면 매니저가 없어서 동작하지 않는다. 그래서 `playModeStartScene`을 부트스트랩으로 바꾸고, 플레이 진입 후 대상 씬을 로드한다.
* **`SessionState`로 값을 넘긴다.** 플레이 모드에 들어가면 도메인 리로드가 일어나 정적 변수가 사라질 수 있다. 에디터 창에서 고른 키, 모드, 옵션을 `SessionState`에 저장했다가 `EnteredPlayMode`에서 읽는다. 읽은 뒤에는 바로 지운다.
* **훅 인터페이스.** 아몬 2페이즈 FSM은 실제 게임에서 1페이즈가 끝나야만 켜진다. 선행 조건 없이 보려고 `ISceneTestHook`을 만들고, 테스트 씬에 `SceneTestFSMActivator`를 두어 FSM을 직접 켠다. 런처는 구체적인 보스를 모른 채 훅 구현만 찾아서 호출한다.
* **런타임 코드와 에디터 코드의 경계.** 런처는 `Editor` 폴더에 있어 빌드에 들어가지 않는다. 반면 몬스터 피해 코드(`FSM.OnHit`, `DamagableObject.ApplyDamage`)는 런타임이라 에디터 클래스를 못 본다. 그래서 값을 `TestManager`라는 정적 클래스에 두고, 런처는 쓰기만, 게임 코드는 읽기만 한다. 기본값(배율 1, 무적 아님)은 일반 플레이에서 영향이 없다.
* **무적을 매 프레임 다시 건다.** 한 번만 켜면 대시 무적 프레임 종료 등으로 플래그가 꺼질 수 있어서 `LateUpdate`마다 다시 켠다. 이때 안전지대 같은 게임 로직이 무적을 해제하지 못하게 `TestManager.PlayerInvincible`로 "테스트 무적 중"을 알린다(`7b289ce5`). 이후 무적이 참조 카운트로 바뀌면서(`5737a138`) 해제 조건 안에 이 값이 남았다. [안전지대 문서](safe-zone.md)를 참고한다.
* **배율은 종료 때 되돌린다.** 플레이 종료(`ExitingPlayMode`) 시 `EnemyDamageMultiplier`를 1로 되돌려, 다음 실행에 값이 새지 않게 한다.

## 핵심 코드

{% code title="SceneTestLauncher.cs (LoadInGame, 발췌)" %}
```csharp
private static async Task LoadInGame(string key)
{
    // 0. 테스트용 적 데미지 배수 적용
    TestManager.EnemyDamageMultiplier = _pendingMultiplier;

    // 1. 몬스터 풀 초기화 (대상 씬의 몬스터가 풀을 참조하므로 가장 먼저)
    await PoolManager.Instance.Init();

    // 2. 플레이어 씬 로드
    await SceneController.Instance.LoadSceneAdditive(PlayerSceneKey);

    // 3. 대상 스테이지 씬 로드 후 액티브 씬으로 전환
    await SceneController.Instance.LoadSceneAdditive(key);
    SceneController.Instance.SetActiveScene(key);

    // 5. 플레이어를 'TestPlayerStart' 위치로 이동
    MovePlayerToTestStart();

    // 6. 프롤로그를 건너뛰고 바로 플레이 상태로
    GameManager.Instance.StartGame();

    // 7. 씬에 배치된 테스트 훅 실행
    InvokeSceneTestHooks();

    // 8. 무적 모드가 켜져 있으면 플레이어에 컴포넌트 부착
    if (_pendingInvincible) EnableInvincibility();
}
```
{% endcode %}

* 4줄: 배율을 가장 먼저 넣어 이후 어떤 피해 계산에서도 반영되게 한다.
* 7~14줄: 순서가 곧 의존성이다. 풀 -> 플레이어 -> 대상 씬 순서를 지킨다. 대상 씬의 몬스터가 풀을 참조하고, 플레이어 씬이 플레이어와 카메라를 등록한다.
* 16~17줄: 플레이어는 `CharacterController`가 위치 대입을 무시하므로 이동 함수 안에서 잠시 끄고 위치를 바꾼 뒤 다시 켠다(`MovePlayerToTestStart`, 발췌 생략).
* 22~26줄: 훅은 셋업이 끝난 뒤에만 호출한다. 무적 부착도 플레이어가 준비된 뒤다.

{% code title="ISceneTestHook.cs / SceneTestFSMActivator.cs (발췌)" %}
```csharp
public interface ISceneTestHook
{
    void OnTestStart();
}

public class SceneTestFSMActivator : MonoBehaviour, ISceneTestHook
{
    [SerializeField] private List<FSM> fsmToEnable = new();

    public void OnTestStart()
    {
        foreach (FSM fsm in fsmToEnable)
        {
            if (fsm == null) continue;
            fsm.isEnabled = true;
            Debug.Log($"[SceneTest] FSM 활성화: {fsm.name}");
        }
    }
}

// SceneTestLauncher 쪽: 비활성 오브젝트까지 훑어 훅을 호출
foreach (MonoBehaviour b in Object.FindObjectsOfType<MonoBehaviour>(true))
    if (b is ISceneTestHook hook) hook.OnTestStart();
```
{% endcode %}

* 훅은 "언제 호출되는가"(런처가 정한다)와 "무엇을 하는가"(씬에 놓은 컴포넌트가 정한다)를 분리한다. 새 테스트 시나리오는 훅 구현을 새로 만들어 씬에 두기만 하면 된다.
* `FindObjectsOfType<MonoBehaviour>(true)`의 `true`는 비활성 오브젝트까지 포함한다. 처음엔 꺼져 있는 보스 오브젝트의 훅도 찾기 위함이다.

{% code title="TestManager.cs / SceneTestInvincibility.cs (발췌)" %}
```csharp
public static class TestManager
{
    public static float EnemyDamageMultiplier = 1f;
    public static bool PlayerInvincible = false;
}

[DisallowMultipleComponent]
public class SceneTestInvincibility : MonoBehaviour
{
    private PlayerController _player;

    private void Awake()     { _player = GetComponent<PlayerController>(); }
    private void OnEnable()  { TestManager.PlayerInvincible = true; }
    private void OnDisable() { TestManager.PlayerInvincible = false; }

    private void LateUpdate()
    {
        if (_player == null) return;
        _player.SetPlayerState(EPlayerState.Invincibility, true);
    }
}
```
{% endcode %}

* `TestManager`는 정적 클래스라 씬 오브젝트나 싱글톤 없이 피해 계산에서 바로 읽을 수 있다. `FSM.OnHit`에서는 `blackboard.CurrentHealth -= damage * TestManager.EnemyDamageMultiplier;`, `DamagableObject.ApplyDamage`에서는 계산된 피해에 같은 배율을 곱한다(`900df9f4`).
* `OnEnable`/`OnDisable`로 플래그를 컴포넌트 수명에 묶었다. 컴포넌트가 제거되면 플래그도 함께 꺼진다.
* `LateUpdate`는 같은 프레임의 다른 `Update`가 플래그를 끈 뒤에 다시 켜기 위한 위치다.
* 이 경로는 `AddInvincibility` 카운트를 거치지 않고 플래그를 직접 켠다. 카운트 쪽 해제 조건이 `TestManager.PlayerInvincible`을 보기 때문에 두 경로가 서로를 끄지 않는다.

## 따라 만들기

원본은 Addressables와 자체 매니저를 쓴다. 빈 프로젝트에서는 `Direct` 모드 + 옵션 두 개로 시작하는 축소판을 만든다.

1. `Assets/Editor/SceneTestLauncher.cs`를 만들고 `EditorWindow`를 상속한다. `[MenuItem("Tools/Scene Test Launcher")]`로 창을 연다. 확인 방법: 메뉴에 항목이 생기고 창이 열린다.
2. `[SerializeField] SceneAsset _targetScene`을 `ObjectField`로 그리고, 선택한 씬의 GUID를 `EditorPrefs`에 저장한다. 키에 `PlayerSettings.productName`을 붙여 프로젝트별로 나눈다. 확인 방법: 창을 닫고 다시 열어도 씬이 복원된다.
3. 실행 버튼에서 `EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo()` 후 `EditorSceneManager.OpenScene(path)`, `EditorApplication.isPlaying = true` 순서로 실행한다. 확인 방법: 버튼 한 번으로 지정한 씬이 플레이 상태로 시작된다.
4. `[MenuItem("Tools/Play Target Test Scene _F6")]`로 단축키를 만든다. 플레이 중이면 정지로 동작하게 한다. 확인 방법: `F6`로 시작과 정지가 된다.
5. 정적 `TestManager`(`EnemyDamageMultiplier = 1f`, `PlayerInvincible = false`)를 `Assets/Scripts/Test/`에 만든다. 창에 `FloatField`와 토글을 추가하고, 배율은 1~1000으로 `Mathf.Clamp`한다. 확인 방법: 값을 바꾸고 재시작해도 에디터 설정으로 유지된다.
6. 값을 플레이 모드로 넘긴다. 실행 직전에 `SessionState.SetFloat(...)`, 플레이 진입 후 `EditorApplication.playModeStateChanged`(`EnteredPlayMode`)에서 읽어 `TestManager`에 대입한다. `ExitingPlayMode`에서는 1로 되돌린다. 확인 방법: 플레이 중 `Debug.Log(TestManager.EnemyDamageMultiplier)`가 창에 넣은 값이고, 종료 후 다음 실행에서 기본값 1이 된다.
7. 몬스터 더미(체력 100)에 피해 함수를 만들고 `damage * TestManager.EnemyDamageMultiplier`로 깎는다. 확인 방법: 배율 10일 때 10 피해에 체력 100이 한 번에 사라진다.
8. `ISceneTestHook`과 훅 구현 컴포넌트를 만든다. 런처는 플레이 진입 후 한 프레임 기다렸다가 `FindObjectsOfType<MonoBehaviour>(true)`로 훅을 호출한다. 확인 방법: 비활성 상태의 적 오브젝트를 훅이 켜고, 시작 직후 적이 움직인다.
9. `SceneTestInvincibility`를 붙인다. 플레이어에 `EnableInvincibility`처럼 `AddComponent`로 부착한다. 확인 방법: 적 공격을 맞아도 체력이 줄지 않고, 컴포넌트를 제거하면 다시 줄어든다.
10. (선택) 씬에 `TestPlayerStart` 빈 오브젝트를 두고, 플레이어의 `CharacterController`를 끄고 위치를 대입한 뒤 켜서 시작 위치로 이동시킨다. 확인 방법: 플레이어가 항상 그 위치에서 시작한다.

## 막히기 쉬운 곳과 한계

* 부트스트랩 경유 모드는 선택한 씬이 Addressables에 등록되어 있어야 한다. 등록되지 않으면 창에 경고가 뜨고 실행하지 않는다. `Direct` 모드를 쓰면 된다.
* `SceneController` 생성 대기는 최대 300프레임이다. 넘기면 강제로 진행한다(`MaxWaitFrames`). 부트스트랩이 느린 환경에서 매니저가 아직 없으면 오류가 날 수 있다.
* 배율은 1~1000으로 고정되어 있어서 피해를 줄이는 용도로는 쓸 수 없다.
* 무적은 피격 체크의 한 경로만 막는다. 즉사나 환경 피해가 별도 경로를 쓰면 막지 못할 수 있다. 이 도구가 어디까지 막는지 전부 확인하지는 않았다.
* 정적 `TestManager`는 빌드에도 포함된다. 에디터 밖에서는 기본값만 쓰이지만, 게임 로직이 테스트 클래스를 참조하는 결합은 남는다. `#if UNITY_EDITOR`로 감싸는 방법도 있지만 이 프로젝트가 그렇게 하지는 않았다.
* 요청된 `_Test/AmonP1Skill.cs`, `AmonP2Skill.cs`는 `main` 트리에서 찾지 못했다. 여기서 다루는 테스트 코드는 위 표의 다섯 파일이다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 도메인 리로드가 일어나는 플레이 모드 진입에서 정적 변수 대신 `SessionState`를 쓰는 이유를 내 말로 설명해 보라.
- [ ] 내 프로젝트에서 "선행 조건 때문에 확인하기 번거로운 기능"이 있다면 무엇이고, 훅 방식으로 푼다면 어떻게 하겠는가?
- [ ] 게임 코드가 테스트용 정적 클래스를 읽는 구조의 장단점은 무엇이라고 생각하는가?
