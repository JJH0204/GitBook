# GameManager 흐름과 부활·리셋

## 무엇을 하는가

`GameManager`는 게임 상태(`Loading`, `Title`, `Prologue`, `Epilogue`, `Playing`, `Paused`, `GameOver`, `Credit`)를 들고, 상태가 바뀌는 지점마다 씬 로드·언로드를 `DungeonManager`, `PoolManager`, `SceneController`에 시킨다. 이 페이지는 그중 "프롤로그 준비", "종료·에필로그 정리", "사망 후 부활과 하드 모드 리셋"을 다룬다.

## 왜 이렇게 설계했나

- 커밋 `8fec0375`(씬 전환을 GameManager 메서드로 정리): 씬 전환 코드가 여러 곳에 흩어져 있던 것을 `EnterTitle`, `EnterPrologue`, `ExitGame`, `EnterEpilogue`, `EnterCredit`로 모았다. 이전의 `ExitGame`은 `UnloadScene("Scene_Game")` 한 줄뿐이었다. 동시에 `DungeonManager.UnloadAllStage`가 추가되었다.
- 커밋 `cc1d0011`(리스폰·리셋 기능): `isHardMode` 옵션과 `MonsterManager.ReleaseAllMonsters`, `DungeonManager.ResetCurrentStage`를 추가해 하드 모드에서는 죽으면 현재 스테이지를 처음부터 다시 시작하게 했다. 사망 처리가 매 프레임 반복 실행되던 문제도 `_rebirthRoutine` 검사로 막았다.
- 플레이어 씬이 따로 있으므로 종료할 때 오디오 리스너와 미니맵이 플레이어를 계속 참조하지 않도록 먼저 `Unload()`를 호출하고 씬을 내린다(코드 주석에서 읽은 이유).

## 핵심 코드

{% code title="GameManager.cs (프롤로그 준비·사망 처리 발췌)" %}
```csharp
public async void EnterPrologue()
{
    try
    {
        CurrentState = GameState.Loading;

        await DungeonManager.Instance.Init();     // 스테이지 0, 1
        await PoolManager.Instance.Init();        // 오브젝트 풀
        await LoadPlayerScene();                  // "Scene_Player" Additive

        DungeonManager.Instance.SetPlayerStartPosition();
        CurrentState = GameState.Prologue;
    }
    catch (Exception e) { Debug.LogWarning($"... 예외 발생: {e}"); }
}

private void PlayingProcess()
{
    if (_rebirthRoutine != null) return;
    if (Player.Stats.CurrentHealth <= 0f) CurrentState = GameState.GameOver;
}

private IEnumerator RebirthGame()
{
    yield return new WaitForSeconds(5.0f);
    GUIManager.Instance.GameUIController.CloseGameOverPanel();

    if (IsHardMode)
    {
        MonsterManager.Instance.ReleaseAllMonsters();      // 1. 몬스터 회수
        DungeonManager.Instance.ResetCurrentStage();       // 2. 현재 스테이지 리셋
    }

    Player.Stats.CurrentHealth = Player.Stats.MaxHealth;
    Player.Spawn();

    _rebirthRoutine = null;
    CurrentState = GameState.Playing;
}
```
{% endcode %}

- `EnterPrologue`의 순서가 중요하다. 스테이지와 풀이 준비된 뒤에 플레이어 씬을 올려야 `InitPlayer`가 `MonsterManager`, `GameManager`에 플레이어를 등록할 때 모든 매니저가 이미 있다. 시작 위치 이동은 플레이어가 생성된 뒤에만 의미가 있다(`SetPlayerStartPosition`은 플레이어가 없으면 반환한다).
- `PlayingProcess`: `Update`가 `Playing` 상태일 때만 호출하고, 부활 코루틴이 진행 중이면 체력 검사를 건너뛴다.
- `RebirthGame`: 5초 대기 후 패널을 닫고, 하드 모드면 몬스터 회수와 스테이지 리셋을 한 다음, 체력을 채우고 `Player.Spawn()`을 호출한다. 마지막에 `_rebirthRoutine`을 비우고 상태를 `Playing`으로 되돌린다.

{% code title="DungeonManager.cs (ResetCurrentStage 발췌)" %}
```csharp
public async void ResetCurrentStage()
{
    if (!LoadedStages.ContainsKey(CurrentPlayerStageIndex)) return;

    StageData currentStageData = stageDatas[CurrentPlayerStageIndex];

    await SceneController.Instance.UnloadScene(currentStageData.stageName);   // 1. 언로드
    await SceneController.Instance.LoadSceneAdditive(currentStageData.stageName); // 2. 재로드

    if (GameManager.Instance.Player)                                          // 3. 리스폰 위치로
    {
        GameManager.Instance.Player.enabled = false;
        GameManager.Instance.Player.transform.position = RestartPosition;
        GameManager.Instance.Player.enabled = true;
    }

    currentPlayerStageIndex--;
}
```
{% endcode %}

- 씬을 내렸다 다시 올리는 것만으로 스테이지 안의 오브젝트(문, 몬스터 스폰, 상태)가 초기 상태로 돌아간다. 하나하나 되돌리는 코드를 짤 필요가 없다는 점이 이 방식의 이점이다.
- `LoadedStages`는 그대로 두고 `SceneController`를 직접 호출한다. `LoadStage`를 쓰면 이미 키가 있어서 아무 일도 하지 않기 때문으로 읽힌다.
- 플레이어 위치를 바꿀 때 `PlayerController`를 껐다 켠다. 이동 컴포넌트가 위치를 덮어쓰지 않게 하려는 의도로 보인다.
- 끝의 `currentPlayerStageIndex--`의 의도는 확인하지 못했다([막히기 쉬운 곳](#막히기-쉬운-곳과-한계) 참고).

## 따라 만들기 단계

1. `GameManager : Singleton<GameManager>`에 `enum GameState`와 `CurrentState` 프로퍼티를 만든다. `Update`에서 상태별 처리(`Playing`, `GameOver`)를 `switch`로 분기한다.
   - 확인 방법: Inspector에서 확인할 수 있게 상태를 로그로 찍는다.
2. `EnterPrologue`를 만든다. 호출 순서는 `DungeonManager.Init` -> `PoolManager.Init` -> 플레이어 씬 로드 -> 시작 위치 이동이다.
   - 확인 방법: 플레이하면 스테이지와 플레이어가 올라오고 플레이어가 시작 위치에 있다. 상태가 `Prologue`로 바뀐다.
3. `PlayingProcess`에서 체력이 0 이하면 `GameOver`로 바꾼다. 중복 실행을 막으려고 `_rebirthRoutine`을 둔다.
   - 확인 방법: 체력을 0으로 만들면 부활 코루틴이 한 번만 시작된다.
4. `MonsterManager.ReleaseAllMonsters`를 만들고(다음 페이지 참고) `DungeonManager.ResetCurrentStage`를 위 발췌대로 만든다.
   - 확인 방법: 하드 모드를 켜고 스테이지 안에서 몬스터를 처치하거나 오브젝트를 파괴한 뒤 사망한다. 부활 후 스테이지가 처음 상태로 돌아와 있어야 한다.
5. `ExitGame`, `EnterEpilogue`에서 `UnloadAllStage`와 플레이어 씬 언로드를 호출한다.
   - 확인 방법: 에필로그 진입 시 스테이지 씬들이 하이어라키에서 사라진다.

## 막히기 쉬운 곳과 한계

- **리셋 뒤의 인덱스 감소**: `ResetCurrentStage` 끝에서 `currentPlayerStageIndex`를 1 줄인다. `StageUpdateTrigger`는 출구를 지나갈 때 인덱스를 올리므로, 사망 후 같은 출구를 다시 지나갈 때 `_previousStageIndex == stageIndex`가 성립하게 하려는 보정일 가능성이 있다. 코드만 보고는 단정할 수 없어 확인이 필요하다.
- **스테이지 리셋과 풀 오브젝트**: 풀에서 꺼낸 몬스터는 스테이지 씬이 내려가도 풀 부모 아래에 남아 있다. 그래서 리셋 전에 `ReleaseAllMonsters`로 회수한다.
- **풀 초기화 문제**: `ExitGame`의 `ClearPools` 호출은 "풀을 리셋하면 오류가 난다"는 주석과 함께 주석 처리되어 있다. 원인은 확인하지 못했다.
- **리셋 후 활성 씬**: 초기 구현(`ef4674dd`)에는 리셋 뒤 `SetActiveScene`이 있었지만 현재는 주석 처리되어 있다.
- **`GameOver` 상태 대입**: `GameOverProcess`의 `CurrentState = GameState.GameOver` 줄은 주석 처리되어 있다. `PlayingProcess`가 이미 상태를 `GameOver`로 바꾸기 때문으로 읽힌다.
- **`PauseObjects`**: `MonsterManager.PauseMonsters/UnpauseMonsters`는 아직 본문이 비어 있는 할 일 목록 상태다.
- **`StartGame`의 자기 대입**: `Player = Instance.Player;`처럼 자기 자신을 대입하는 줄이 있다. 동작에는 영향이 없다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `EnterPrologue`에서 `Init` 호출 순서를 바꾸면 어떤 문제가 생길지, 내가 아는 범위에서 예상해 적어 본다.
- [ ] 씬을 다시 로드하는 방식으로 스테이지를 리셋하는 것과 오브젝트를 하나씩 되돌리는 방식을 비교한다.
- [ ] 게임 상태를 enum으로 관리하면서 겪은 어려움이나 버그가 있었는가?
