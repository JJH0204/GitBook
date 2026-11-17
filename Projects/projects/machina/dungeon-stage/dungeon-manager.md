# DungeonManager: 스테이지 스트리밍

## 무엇을 하는가

던전은 스테이지(방) 단위의 씬 여러 개로 나뉘어 있다. `DungeonManager`는 `StageData`(번호 + 씬 주소) 배열을 들고 있다가, 게임 시작 때 첫 스테이지와 그다음 스테이지만 로드한다. 플레이어가 앞으로 나아가면 다음 스테이지를 미리 올리고 지나온 스테이지를 내린다. 현재 스테이지 인덱스, 리스폰 위치, 현재 스테이지 리셋, 보스 페이즈 이동도 이 클래스가 맡는다.

## 왜 이렇게 설계했나

커밋에서 읽히는 변화는 다음과 같다.

- 커밋 `58146a54`(DungeonManager 스테이지 로드 정리): `StageData`에서 `Static/Hybrid/Dynamic` 경로 필드를 지우고 `stageName` 하나만 남겼다. 로드한 스테이지는 `LoadedStages` 딕셔너리로 추적한다.
- 커밋 `ef4674dd`(시작 위치를 GameObject로 변경): 스테이지 하나를 `/Static`, `/Dynamic`, `/Hybrid` 세 씬으로 따로 올리던 코드를 지우고 `LoadSceneAdditive(stageData.stageName)` 한 번으로 줄였다. 시작 위치도 `Vector3`에서 `GameObject`로 바꿨다. 씬 안의 오브젝트가 자기 위치를 등록하는 방식(`SetStartPosition`)으로 바뀐 것이다.
- 커밋 `e20761a7`(스테이지 로드 로직 정리): 앞으로 이동과 뒤로 이동을 나눠 "현재 기준 한 칸 앞은 로드, 두 칸 이상 뒤는 언로드"가 되도록 `UpdatePlayerStageIndex`를 다시 썼다.
- 이후 팀 동료가 `_isUpdatingStage` 가드를 추가하고, `LoadStage`가 await 전에 딕셔너리를 먼저 갱신하도록 고쳤다(비동기 로드 중 중복 호출 문제의 수정으로 읽힌다). 아래 발췌는 main의 최신 상태다.
- 이유는 코드 구조에서 읽은 것이다. 모바일까지 빌드 대상이므로 모든 스테이지를 한꺼번에 올리지 않고 필요한 것만 메모리에 두려는 목적이 가장 그럴듯하다.

## 핵심 코드

{% code title="DungeonManager.cs (스테이지 로드·언로드 발췌)" %}
```csharp
private async Task LoadStage(StageData stageData)
{
    if (LoadedStages.ContainsKey(stageData.stageIndex)) return;

    LoadedStages.Add(stageData.stageIndex, stageData.stageName);
    await SceneController.Instance.LoadSceneAdditive(stageData.stageName);
}

private async Task UnloadStage(StageData stageData)
{
    if (!LoadedStages.ContainsKey(stageData.stageIndex)) return;

    LoadedStages.Remove(stageData.stageIndex);
    await SceneController.Instance.UnloadScene(stageData.stageName);
}

public async void UpdatePlayerStageIndex(int newStageIndex)
{
    if (_isUpdatingStage) return;          // 갱신 중이면 추가 요청 무시
    try
    {
        if (newStageIndex == CurrentPlayerStageIndex) return;
        _isUpdatingStage = true;

        if (newStageIndex < CurrentPlayerStageIndex)        // 뒤로 이동
        {
            if (LoadedStages.ContainsKey(CurrentPlayerStageIndex + 1))
                await UnloadStage(stageDatas[CurrentPlayerStageIndex + 1]);
            await LoadStage(stageDatas[newStageIndex - 1 < 0 ? 0 : newStageIndex - 1]);
        }
        else if (newStageIndex > CurrentPlayerStageIndex)   // 앞으로 이동
        {
            if (LoadedStages.ContainsKey(CurrentPlayerStageIndex - 1))
                await UnloadStage(stageDatas[CurrentPlayerStageIndex - 1]);
            await LoadStage(stageDatas[newStageIndex + 1]);
        }
        CurrentPlayerStageIndex = newStageIndex;
    }
    catch (Exception e) { Debug.LogWarning($"... 예외 발생: {e}"); }
    finally { _isUpdatingStage = false; }
}
```
{% endcode %}

- `LoadStage`: 이미 로드된 번호면 아무것도 하지 않는다. 딕셔너리에 먼저 넣고 씬을 기다리므로, 로드 도중 같은 스테이지를 또 요청해도 두 번 올라가지 않는다.
- `UnloadStage`: `LoadedStages`에 없으면 건너뛴다. 대칭 구조다.
- `_isUpdatingStage`: `async void`는 호출자가 끝을 기다릴 수 없으므로 플래그로 재진입을 막는다. `finally`에서 반드시 내린다.
- 앞으로 이동 분기: 새 인덱스가 `n`이면 `n+1`을 로드하고 `현재-1`을 언로드한다. 그 결과 메모리에 있는 스테이지는 "현재, 다음, 그리고 방금 지나온 이전" 정도로 유지된다.
- 뒤로 이동 분기: 현재보다 한 칸 앞(`현재+1`)을 내리고, `새 인덱스-1`을 로드한다.
- `stageDatas[...]`의 인덱스는 배열 위치다. `StageData.stageIndex`와 배열 위치가 같다는 가정이 깔려 있다.

초기화는 다음과 같다.

{% code title="DungeonManager.cs (Init 발췌)" %}
```csharp
public async Task Init()
{
    if (_isInit) return;

    CurrentPlayerStageIndex = 0;
    LoadedStages.Clear();

    foreach (StageData stageData in stageDatas)
    {
        if (stageData.stageIndex != CurrentPlayerStageIndex + 1 &&
            stageData.stageIndex != CurrentPlayerStageIndex) continue;

        await LoadStage(stageData);   // 0번과 1번만 로드
    }

    LoadMiniMap();
    _isInit = true;
}
```
{% endcode %}

- 시작 시점에는 현재(0)와 다음(1)만 올린다. 커밋 `58146a54`에서는 `-1`도 조건에 있었지만 현재 main에서는 빠져 있다.
- `GameManager.EnterPrologue`가 이 `Init`을 `await`한 뒤에 상태를 `Prologue`로 바꾼다. 코드의 주석은 "프롤로그 재생하는 동안 로드"라고 적혀 있지만, 읽은 바로는 로드가 끝난 뒤에 프롤로그 상태로 넘어간다.

## 따라 만들기 단계

1. 스테이지 씬을 2~3개 만든다(예: `Stage_0`, `Stage_1`, `Stage_2`). 각 씬에 바닥과 구분되는 오브젝트를 하나씩 둔다. 모두 Addressable로 등록하고 주소를 씬 이름과 같게 맞춘다.
   - 확인 방법: Addressables Groups에 세 씬의 주소가 보인다.
2. `StageData`(`int stageIndex`, `string stageName`)를 `[Serializable] struct`로 만든다.
3. `DungeonManager : Singleton<DungeonManager>`를 만들고 `StageData[] stageDatas`, `Dictionary<int,string> LoadedStages`, `int CurrentPlayerStageIndex`를 둔다. 프리팹으로 만들어 Persistent 씬의 `managersPrefabs`에 등록한다.
   - 확인 방법: Inspector에서 스테이지 배열에 세 항목을 입력할 수 있다.
4. `LoadStage`와 `UnloadStage`를 위 발췌대로 만든다. 로그를 찍어 호출 순서를 볼 수 있게 한다.
5. `Init()`을 만든다. 게임 시작 시 `GameManager`(또는 임시 테스트 스크립트)에서 `await DungeonManager.Instance.Init()`을 호출한다.
   - 확인 방법: 플레이하면 하이어라키에 `Stage_0`, `Stage_1`만 올라오고 `Stage_2`는 없다.
6. `UpdatePlayerStageIndex(int)`를 만든다. 테스트로 키 입력에서 `1`, `2`를 순서대로 넘겨 본다.
   - 확인 방법: `1`을 넘기면 `Stage_2`가 올라오고 `Stage_0`이 내려간다. 같은 호출을 연속으로 빠르게 보내도 한 번만 처리된다(로그로 확인).
7. 시작 위치: `SetStartPosition(GameObject)`와 `SetPlayerStartPosition()`을 만든다. 첫 스테이지 씬에 `Init1stGameScene`을 붙여 `Awake`에서 `DungeonManager.Instance.SetStartPosition(startPosition)`과 `RestartPosition`을 등록한다.
   - 확인 방법: 플레이어 오브젝트가 있을 때 `SetPlayerStartPosition()`을 호출하면 지정한 위치로 이동한다.

## 막히기 쉬운 곳과 한계

- **배열 범위**: 앞으로 이동 분기의 `stageDatas[newStageIndex + 1]`은 마지막 스테이지에서 범위를 벗어난다. 예외는 `catch`에서 로그로만 처리되어 조용히 지나간다. 마지막 스테이지에 도달하는 조건을 데이터와 맞춰 두었는지는 확인하지 못했다.
- **인덱스 가정**: 배열 위치와 `stageIndex`가 같아야 한다. 데이터를 중간에 끼워 넣으면 어긋난다.
- **비동기 중 상태**: `UpdatePlayerStageIndex`가 진행 중일 때 들어온 요청은 버려진다. 트리거를 짧은 시간에 연속으로 밟으면 한 번이 누락될 수 있다.
- **활성 씬 지정**: 초기 구현(`58146a54`, `ef4674dd`)은 스테이지를 로드할 때마다 `SetActiveScene`으로 활성 씬을 바꿨다. 현재 main에서는 해당 호출이 주석 처리되어 있다. 이후 커밋 메시지(팀 동료 작성)에 "스테이지 스트리밍 중 라이트맵 손실을 막기 위해 Persistence 씬을 Active Scene으로 둔다"는 취지가 적혀 있어, 활성 씬이 바뀌면 라이팅 데이터가 영향을 받은 것으로 읽힌다. 확실한 원인은 확인하지 못했다.
- **테스트용 코드**: `LoadAllStage`는 `/Static`, `/Dynamic`, `/Hybrid` 접미사를 붙여 씬을 로드한다. 한 스테이지를 단일 씬으로 합친 이후의 구조와 맞지 않아 보이며, 실제로 호출되는지는 확인하지 못했다.
- **`UnloadAllStage`**: `LoadedStages`를 정리하지 않고 모든 스테이지 이름으로 `UnloadScene`을 부른다. `SceneController`가 핸들이 없는 키는 건너뛰므로 무해하지만, `LoadedStages`는 남는다.
- **`_isInit`**: `Init`이 한 번 끝나면 다시 호출해도 아무 일도 하지 않는다. 에필로그 후 다시 시작하는 흐름은 확인하지 못했다.
- 보스 페이즈 이동(`AmonSecondPhase`, `AmonEndPhase`)은 같은 클래스에 있지만 던전 스트리밍과 별개의 기능이다. 플레이어를 순간이동시키기 전에 `CharacterController`를 끄고 이동 뒤에 다시 켠다(켜 둔 채로 `transform.position`을 바꾸면 컨트롤러가 위치를 되돌리는 경우가 있다).

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 모든 스테이지를 한꺼번에 올리지 않고 현재와 다음 스테이지만 올리는 방식의 장점과 단점을 각각 적어 본다.
- [ ] `async void`와 `async Task`의 차이를 설명하고, `UpdatePlayerStageIndex`에 `_isUpdatingStage` 플래그가 필요했던 이유를 내 말로 적어 본다.
- [ ] 스테이지 스트리밍을 구현하며 비동기 로드 때문에 겪은 문제가 있다면 무엇이었는가?
