# 맵 동적 로딩 시스템 설계

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-MRD-006-DO |
| 유형 | D&O (설계 기록) |
| 목적 | 플레이어가 있는 스테이지 앞뒤의 씬만 로드하는 설계와, 이 설계를 폐기한 이유를 기록한다 |
| 확인 상태 | 미검증 (코드를 읽고 정리했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 구성 요소

| 번호 | 구성 요소 | 역할 |
|---|---|---|
| 1 | `DungeonManager` | 스테이지 씬을 로드·언로드하고 현재 스테이지 인덱스를 갱신한다 |
| 2 | `SceneController` | Additive 로드, 언로드, 활성 씬 지정을 맡는다(코드는 원본에 없음) |
| 3 | 스테이지당 씬 3개 | `<스테이지>/Static`, `<스테이지>/Dynamic`, `<스테이지>/Hybrid` |
| 4 | `DungeonStateManager` | 오브젝트 고유 ID별 상태(`bool`)를 저장하는 싱글톤 |

## 2. 동작 원리

1. 플레이어가 트리거를 지나면 `UpdatePlayerStageIndex`가 호출된다.
2. 뒤로 이동하면 현재 인덱스 +1 스테이지를 언로드하고 `newStageIndex - 1` 스테이지를 로드한다.
3. 앞으로 이동하면 현재 인덱스 -1 스테이지를 언로드하고 `newStageIndex + 1` 스테이지를 로드한다.
4. 현재 인덱스를 갱신하고 해당 스테이지의 `Dynamic` 씬을 활성 씬으로 지정한다.

## 3. 코드 (원본 보존)

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

{% hint style="info" %}
NOTE: 코드를 읽고 찾은 오류 후보다. 원본은 수정하지 않았고 실행하지 않았다.
{% endhint %}

| 번호 | 위치 | 문제 |
|---|---|---|
| 1 | 앞으로 이동 분기 `stageDatas[newStageIndex + 1]` | 마지막 스테이지에서 인덱스 범위를 벗어난다. 뒤로 이동 분기처럼 경계 검사가 없다 |
| 2 | `LoadedStages[CurrentPlayerStageIndex]` | 해당 스테이지가 로드되어 있지 않으면 `KeyNotFoundException`이 난다. 첫 호출에서 현재 스테이지를 로드하는 부분은 원본에 없다 |
| 3 | `async void UpdatePlayerStageIndex` | 호출자가 완료를 기다릴 수 없다. 트리거가 연속으로 발동하면 로드·언로드가 겹칠 수 있다 |
| 4 | 반환 형식 `Task` + Unity 씬 로드 | `SceneController`가 `AsyncOperation`을 `Task`로 바꾸는 방식은 원본에 없다. 확인 필요 |

## 4. 문제와 대안

이 구성은 트리거를 지날 때 필요한 맵 리소스를 미리 로드한다. 모든 맵 리소스를 다시 로드하므로 플레이어가 이미 지난 구역을 다시 방문하면 다음 문제가 생긴다.

- 이미 상호작용해 사용 불가가 된 리소스와 다시 상호작용할 수 있다.
- 몬스터 스폰 트리거가 다시 동작할 수 있다.

대안으로 오브젝트 고유 ID(GID)에 상호작용 여부를 기록하는 방식을 구상했다.

1. 각 게임 오브젝트가 `Start()` 또는 `OnEnable()`에서 글로벌 상태 매니저에 자기 ID로 상태를 조회한다.
2. 몬스터, 상자, 트리거가 동작하면 변경된 상태를 매니저에 갱신한다.
3. 씬이 언로드되어도 매니저의 상태는 남는다. 다시 로드된 오브젝트가 상태를 조회해 이미 사용된 것은 비활성으로 시작한다.

## 5. 결정

플레이어가 뒤로 가지 못하게 레벨 디자인을 수정하는 쪽으로 기획을 바꿨다. 그래서 이 시스템은 필요하지 않게 되었다.

## 6. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [mobileoptimizationrnd.md](mobileoptimizationrnd.md) | PRJ-MRD-003-DO | 모바일 최적화 연구 개발 (R&D) |
| [addressablessetup.md](addressablessetup.md) | PRJ-MRD-004-MP | Addressables 설정과 씬 로드 |

## 7. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM D&O 형식으로 재작성, 코드는 원본 보존, 오류 후보 표 추가, 개인 노트 경로 링크 삭제 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 상태 저장 시스템을 만드는 대신 레벨 디자인을 바꾸기로 한 판단을 어떻게 평가하는가?
- [ ] 씬을 Additive로 로드·언로드할 때 오브젝트 상태가 사라지는 이유를 내 말로 설명한다.
