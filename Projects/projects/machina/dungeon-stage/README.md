# 던전·스테이지·씬 관리

{% hint style="info" %}
이 영역의 코드 해석은 저장소의 main 브랜치 파일을 읽고 판단한 것이다. Unity에서 실행해 확인하지 않았다(**unverified**).
{% endhint %}

## 한눈에 보기

이 영역은 게임이 켜진 순간부터 던전 끝까지, "어떤 씬이 언제 메모리에 올라오고 내려가는가"를 책임지는 코드를 다룬다. 핵심은 세 가지다.

- 부트스트랩 씬이 Persistent 씬을 불러오고, Persistent 씬이 매니저 프리팹을 한꺼번에 생성한다.
- 던전은 스테이지마다 씬 하나(Addressables 주소)로 쪼개져 있고, 플레이어가 있는 스테이지와 바로 다음 스테이지만 메모리에 둔다.
- 플레이어가 스테이지 끝의 트리거를 지나가면 `DungeonManager`가 다음 스테이지를 로드하고 이전 스테이지를 내린다.

## 전체 구조

```text
[Bootstrap 씬]  InitBootstrap
      |  Addressables 로 "Scene_Persistent" 를 Additive 로드, Active 씬으로 지정
      v
[Persistent 씬]  InitPersistent
      |  매니저 프리팹 생성 -> GameManager.SceneLoaded() -> 자기 자신 Destroy
      |  OnDestroy -> GameManager.EnterTitle()  (GUI 로드, 사운드 초기화, 상태 Title)
      v
  GameManager.EnterPrologue()
      |-- DungeonManager.Init()        스테이지 0, 1 로드 + 미니맵 생성
      |-- PoolManager.Init()           오브젝트 풀 생성
      |-- Scene_Player 로드            InitPlayer 가 플레이어 관련 프리팹 생성
      '-- SetPlayerStartPosition()     시작 위치로 이동 -> 상태 Prologue
      v
  플레이 중
      |  StageUpdateTrigger (스테이지 출구) -> DungeonManager.UpdatePlayerStageIndex()
      |     -> 다음 스테이지 로드 / 이전 스테이지 언로드 (SceneController 경유)
      |  DungeonStateManager : 오브젝트 상태(id -> bool) 보관
      |  PoolManager / MonsterManager : 몬스터·투사체 재사용, 일괄 회수
      '  사망 -> GameManager.RebirthGame() -> (하드 모드) 몬스터 회수 + 스테이지 리셋
```

## 읽는 순서

1. [씬 부트스트랩과 Persistent 씬](scene-bootstrap.md): 게임이 켜지고 매니저가 만들어지는 과정, `SceneController`
2. [DungeonManager: 스테이지 스트리밍](dungeon-manager.md): 스테이지 로드·언로드와 인덱스 관리
3. [StageUpdateTrigger: 스테이지 전환 감지](stage-trigger.md): 트리거로 전환을 일으키는 방법과 한계
4. [GameManager 흐름과 부활·리셋](game-flow.md): 상태 머신, 프롤로그 준비, 하드 모드 리셋
5. [오브젝트 상태 보관과 풀링](object-state-pooling.md): `DungeonStateManager`, `PoolManager`, `MonsterManager`

## 파일 목록과 한 줄 역할

저장소 기준 경로의 앞부분은 `Branch/Assets/_GameAssets/01. Scripts/`이다. 과제 지시문에 적힌 `_Project`와 `_Test/Script` 경로는 이후 폴더 정리 커밋으로 이 경로 아래로 합쳐졌다.

| 파일 | 한 줄 역할 |
| --- | --- |
| `Bootstrap/InitBootstrap.cs` | 해상도 설정 후 Persistent 씬을 Additive 로드 |
| `Persistent/InitPersistent.cs` | 매니저 프리팹 일괄 생성, 로드 완료 통지, 타이틀 진입 |
| `Persistent/SceneController.cs` | Addressables 씬의 Additive 로드·언로드·활성 씬 지정 |
| `Managers/Singleton.cs` | 매니저 공용 싱글턴 베이스 (이 영역 전체가 의존) |
| `Managers/GameManager.cs` | 게임 상태 머신, 프롤로그 준비, 종료, 사망·부활 |
| `Managers/DungeonManager.cs` | 스테이지 데이터, 로드·언로드, 현재 스테이지 인덱스, 리셋, 보스 페이즈 이동 |
| `Managers/DungeonStateManager.cs` | 오브젝트 id별 bool 상태 저장소 |
| `Managers/PoolManager.cs` | 프리팹별 오브젝트 풀 (Unity `ObjectPool` 기반) |
| `Managers/MonsterManager.cs` | 살아 있는 몬스터 목록 관리와 일괄 회수 |
| `Game/StageUpdateTrigger.cs` | 스테이지 출구 트리거, 리스폰 위치 갱신 |
| `Game/Init1stGameScene.cs` | 첫 스테이지의 시작 위치를 `DungeonManager`에 등록 |
| `Player/InitPlayer.cs` | Player 씬의 프리팹 생성과 참조 연결 |
| `Editor/StartBootstrap.cs` | 에디터 메뉴로 Bootstrap 씬부터 플레이 시작 |
| `Editor/LoadAllGameScene.cs` | 에디터 메뉴로 모든 스테이지 씬을 Additive로 열기 |

`MapManager`는 `Persistent/MapManager.prefab`(프리팹)과 `EManagerType`의 항목으로만 확인되며, 같은 이름의 C# 파일은 저장소에서 찾지 못했다. 자세한 내용은 [씬 부트스트랩과 Persistent 씬](scene-bootstrap.md)에서 다룬다.
