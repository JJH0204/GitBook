# 맵 동적 로딩 시스템 설계

## Code Block

{% code title="DungeonManager.cs" %}
```csharp
private async Task LoadStage(StageData stageData)
{
    if (LoadedStages.ContainsKey(stageData.stageIndex)) return;
    
    await SceneController.Instance.LoadSceneAdditive(stageData.stageName + "/Static");
    await SceneController.Instance.LoadSceneAdditive(stageData.stageName + "/Dynamic");
    await SceneController.Instance.LoadSceneAdditive(stageData.stageName + "/Hybrid");
    
    LoadedStages.Add(stageData.stageIndex, stageData.stageName);
}

private async Task UnloadStage(StageData stageData)
{
    if (!LoadedStages.ContainsKey(stageData.stageIndex)) return;
    
    await SceneController.Instance.UnloadScene(stageData.stageName + "/Static");
    await SceneController.Instance.UnloadScene(stageData.stageName + "/Dynamic");
    await SceneController.Instance.UnloadScene(stageData.stageName + "/Hybrid");
    
    LoadedStages.Remove(stageData.stageIndex);
}

public async void UpdatePlayerStageIndex(int newStageIndex)
{
    try
    {
        if (newStageIndex == CurrentPlayerStageIndex) return;
        
        // 새로운 스테이지 인덱스에 따라 필요한 스테이지 로드/언로드
        {
            // newStageIndex 값이 현재 플레이어 스테이지 인덱스보다 작아지는 경우 (뒤로 이동)
            if (newStageIndex < CurrentPlayerStageIndex)
            {
                if (LoadedStages.ContainsKey(CurrentPlayerStageIndex + 1))
                    await UnloadStage(stageDatas[CurrentPlayerStageIndex + 1]);
                
                await LoadStage(stageDatas[newStageIndex - 1 < 0 ? 0 : newStageIndex - 1]);
            }
            // newStageIndex 값이 현재 플레이어 스테이지 인덱스보다 커지는 경우 (앞으로 이동)
            else if (newStageIndex > CurrentPlayerStageIndex)
            {
                if (LoadedStages.ContainsKey(CurrentPlayerStageIndex - 1))
                    await UnloadStage(stageDatas[CurrentPlayerStageIndex - 1]);

                await LoadStage(stageDatas[newStageIndex + 1]);
            }
        }
        
        CurrentPlayerStageIndex = newStageIndex;
        
        // 현재 플레이어가 있는 스테이지의 Dynamic 씬을 Active 씬으로 설정
        SceneController.Instance.SetActiveScene(LoadedStages[CurrentPlayerStageIndex] + "/Dynamic");
    }
    catch (Exception e)
    {
        Debug.LogWarning($"[DungeonManager] 플레이어 스테이지 인덱스 업데이트 중 예외 발생: {e}");
    }
}
```
{% endcode %}

## Code Block 1

{% code title="DungeonStateManager.cs" %}
```csharp
using System.Collections.Generic;

namespace Managers
{
    public class DungeonStateManager: Singleton<DungeonStateManager>
    {
        private Dictionary<int, bool> _objStates = new ();
        
        public void SetState(int objId, bool state)
        {
            if (_objStates.ContainsKey(objId))
                _objStates[objId] = state;
            else
            {
                _objStates.Add(objId, state);
            }
        }
        
        public bool GetState(int objId)
        {
            return _objStates.TryGetValue(objId, out bool state) && state;
        }
        
        public void ClearStates()
        {
            _objStates.Clear();
        }
    }
}
```
{% endcode %}

플레이어 캐릭터가 트리거를 통과 할때 Public 메서드를 실행해 필요한 맵 리소스를 미리 로드 하는 기능의 스크립트다.

이 경우 모든 맵 리소스를 다시 로드하기 때문에 특정상황(예를 들어 플레이어가 이미 지난 구역에 방문할 때)에서 이미 상호작용하여 사용이 불가능한 리소스와 다시 상호작용할 수 있게 되거나, 몬스터 스폰 트리거가 동작하는 상황이 발생할 수도 있다.

오브젝트에 고유ID 값(GID)을 활용해 상호작용 여부를 기록

* Global State Manager
* GameObject
* Start() 또는 OnEnable() 에서 매니저에 자신의 ID를 조회
* GameObject
* 몬스터, 상자, 트리거가 동작할 때
* 변경된 상태를 매니저에 갱신
* 씬 언로드
* GameObject

플레이어를 뒤로 가지 못하게 레벨디자인을 수정하는 걸로 기획을 수정함\
그래서 해당 시스템은 필요 없음

### 참고 링크

* 2025/GameDev/재조합(팀플)/최적화/맵 동적 로딩 시스템 설계.md#Code Block
* 2025/GameDev/재조합(팀플)/최적화/맵 동적 로딩 시스템 설계.md#Code Block 1
