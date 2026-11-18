# UI·사운드·이벤트·입력·Android 빌드

{% hint style="info" %}
이 영역은 공개 레포에서 내가 작성한 커밋의 코드를 읽고 해체한 기록이다. 코드를 실행하거나 Unity에서 빌드해 확인하지 않았고, 모든 동작 설명은 소스와 커밋 diff를 읽은 해석이다(unverified).
{% endhint %}

## 한눈에 보기

팀 프로젝트(Unity TPS)의 "게임 바깥을 감싸는 층"을 맡았다. 화면에 뜨는 UI를 한곳에서 만들고 전환하는 구조, 오디오 리스너와 볼륨, 컴포넌트끼리 직접 참조하지 않게 하는 이벤트 버스, 모바일 터치 카메라와 게임패드, Android 빌드를 위한 설정이 여기에 속한다.

핵심 결정은 세 가지다.

1. 거대한 `GUIManager`(약 1000줄)를 "전환 담당"과 "HUD 담당"으로 쪼갰다. 전환은 `GUIManager`가, HUD 갱신은 `GameUIController`가 맡는다.
2. 화면(UI)은 씬에 미리 박아 두지 않고 `InitUI`가 프리팹을 `Instantiate`한 뒤 `GUIManager.Init`에 사전 형태로 넘긴다.
3. 영상은 `VideoClip` 에셋이 아니라 파일 이름(문자열)으로 가리키고 `StreamingAssets`에서 URL로 재생한다.

## 전체 구조

```
Persistent 씬
  └─ InitPersistent ── 매니저 프리팹 생성 ─ GameManager.SceneLoaded()
                                              └─ SoundManager.Init()  (AudioListener 프리팹 생성)
                                              └─ (OnDestroy) GameManager.EnterTitle()
                                                     └─ Scene_UI 추가 로드
Scene_UI 씬
  └─ InitUI [UIInfo[]: 종류 + 프리팹 + 활성 여부]
        ├─ Instantiate: Title / Prologue / GameUIController / Epilogue / Loading / Credit
        └─ GUIManager.Init(Dictionary<EUIType, GameObject>)
              ├─ Update(): GameManager.CurrentState 에 따라 화면 하나만 SetActive(true)
              ├─ 하드웨어 보고 HDR 기본값 결정, 볼륨(dB) 적용, 언어 적용
              └─ GameUIController  ← HP·탄약·스킬·라디얼·알림·페이드·진동 등 HUD 갱신
Player 씬
  └─ InitPlayer ── FollowAudioListener.Init(player) ← SoundManager.AudioListener
입력: PlayerActions(InputSystem 생성 코드) ── UI_Title / UI_Prologue (UIActionMap)
      MobileDragCamera (EnhancedTouch → Cinemachine POV)
이벤트: EventManager.PostNotification(EEventType, sender, param)
```

## 읽는 순서

1. [UI 컨트롤러 분리](ui-controller.md): GUIManager에서 GameUIController로 나눈 이유와 구조
2. [UI 초기화와 화면 전환](ui-init-flow.md): InitUI, EUIType, 상태에 따른 전환, 타이틀과 프롤로그
3. [사운드와 이벤트](sound-event.md): SoundManager, FollowAudioListener, EventManager
4. [모바일 입력과 게임패드](mobile-input.md): MobileDragCamera, 게임패드 바인딩, 진동
5. [Android 빌드 설정](android-build.md): 빌드 설정 커밋, URP와 HDR, StreamingAssets, Android용 UI 프리팹

## 파일 목록

경로는 레포의 `Branch/Assets/` 아래 기준이다. 커밋 당시에는 `_Project`와 `_Test`였던 폴더가 이후 정리 커밋에서 `_GameAssets` 아래로 모였고, 아래는 현재 `main` 기준이다.

| 파일 | 한 줄 역할 |
| --- | --- |
| `_GameAssets/01. Scripts/Managers/GameUIController.cs` | 게임 중 HUD와 팝업을 갱신하는 컨트롤러(리팩터링으로 분리) |
| `_GameAssets/01. Scripts/Managers/GUIManager.cs` | UI 인스턴스 보관, 상태별 화면 전환, HDR·볼륨·언어 초기 설정 |
| `_GameAssets/01. Scripts/GUI/InitUI.cs` | UI 프리팹을 생성해 GUIManager에 넘기는 진입점 |
| `_GameAssets/01. Scripts/GUI/EUIType.cs`, `SUIInfo.cs` | UI 종류 열거형과 (종류, 프리팹, 활성 여부) 구조체 |
| `_GameAssets/01. Scripts/GUI/UI_Title.cs`, `UI_Prologue.cs` | 타이틀 버튼 처리, 프롤로그 영상 대사 연출 |
| `_GameAssets/01. Scripts/Managers/SoundManager.cs` | 오디오 리스너 프리팹을 만드는 싱글톤 |
| `_GameAssets/01. Scripts/Managers/EventManager.cs` | 이벤트 종류별 리스너 목록을 가진 싱글톤 버스 |
| `_GameAssets/01. Scripts/Player/Components/FollowAudioListener.cs` | 오디오 리스너가 플레이어를 따라가게 하는 컴포넌트 |
| `_GameAssets/01. Scripts/Player/Camera/MobileDragCamera.cs` | 터치 드래그로 Cinemachine POV를 돌리는 카메라 |
| `_GameAssets/01. Scripts/Player/Input/PlayerActions.cs` | Input Actions 에셋에서 생성된 코드(게임패드 바인딩 포함) |
| `_GameAssets/02. Prefabs/UI/GameUIController_Android.prefab` | 모바일 HUD 프리팹(구조만 설명) |
| `Settings/URP-Balanced.asset`, `URP-HighFidelity.asset` | URP 품질 자산(HDR 출력 프리필터 플래그 변경) |

## 다루지 않는 것

- `PlayerController.cs`는 리팩터링으로 GUIManager 호출이 GameUIController로 바뀐 부분만 언급한다. 게임패드 전용 변경은 이 파일에서 찾지 못했다.
- 서드파티 패키지(lilToon, Google Play 플러그인, HotReload 등)와 유료 에셋은 사용 사실만 적고 코드는 싣지 않는다.
- Android 서명 정보는 다루지 않는다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 이 영역을 "게임 바깥을 감싸는 층"이라고 했다. 내가 맡은 부분이 게임플레이 코드와 어떻게 맞물리는지 내 말로 설명해 보자.
- [ ] 위 구조 그림에서 내가 가장 먼저 만든 부분은 어디였고, 그 뒤에 무엇이 따라 붙었는가?
