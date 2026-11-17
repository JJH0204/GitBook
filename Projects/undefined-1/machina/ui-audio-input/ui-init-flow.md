# UI 초기화와 화면 전환

## 무엇을 하는가

게임이 켜지면 `Scene_UI` 씬이 추가 로드되고, 그 안의 `InitUI`가 UI 프리팹 여섯 종류(타이틀, 프롤로그, 게임 HUD, 에필로그, 로딩, 크레딧)를 만들어 `GUIManager`에 넘긴다. 이후 `GUIManager`는 매 프레임 `GameManager.CurrentState`를 보고 그 상태에 해당하는 화면 하나만 켠다. 타이틀 버튼과 프롤로그 영상 대사도 이 흐름 안에 있다.

## 왜 이렇게 설계했나

- 최초 커밋 `a1affe0e`(2025-12-04, "Add UI initialization and management scripts")에서 `InitUI`, `UIInfo`, `EUIType`가 처음 들어왔다. 같은 시기 다른 매니저도 `InitPersistent`가 `(종류, 프리팹)` 배열을 받아 생성하는 같은 패턴을 쓴다. UI도 이 패턴에 맞춘 것이다.
- UI를 프리팹 배열로 만들면, 인스펙터에서 항목의 `isActive`와 프리팹만 바꿔 플랫폼별·테스트별 구성을 갈아 끼울 수 있다. 같은 종류가 두 번 들어와도 `ContainsKey`로 막는다.
- 화면 전환을 `GameManager`의 상태 열거형 하나로 통제한다. 커밋 `836e87fe`에서 `GameManager`에 `GameState`(Loading, Title, Prologue, Epilogue, Playing, Paused, GameOver)가 들어오고, 타이틀 버튼이 `SceneManager.LoadScene("PrologueScene")`에서 `GameManager.Instance.EnterPrologue()`로 바뀌었다. 씬을 통째로 교체하지 않고 한 씬 안에서 UI 오브젝트를 켜고 끄는 구조로 옮긴 것이다.
- `423a7400`에서 `EnterTitle`, `EnterPrologue`가 `async`가 되고 `await SceneController.Instance.LoadSceneAdditive(...)`를 쓴다. 씬 로드가 끝난 뒤에 상태를 바꿔 화면이 먼저 뜨는 것을 막는다.
- `893446b0`(2026-01-15)에서 프롤로그 영상 필드가 `VideoClip video`에서 `string videoName`으로 바뀌었다(아래 참고).

## 핵심 코드

{% code title="InitUI.cs" %}
```csharp
public class InitUI : MonoBehaviour
{
    [SerializeField] private UIInfo[] uiInfos;

    private void Awake()
    {
        Dictionary<EUIType, GameObject> createdUIs = new ();
        try
        {
            foreach (UIInfo ui in uiInfos)
            {
                if (!ui.uiPrefab) continue;
                if (createdUIs.ContainsKey(ui.uiType)) continue;

                GameObject uiInstance = Instantiate(ui.uiPrefab);
                uiInstance.SetActive(ui.isActive);
                createdUIs.Add(ui.uiType, uiInstance);
            }
            GUIManager.Instance.Init(createdUIs);
        }
        catch (Exception e) { Debug.Log(e); }
    }
}
```
{% endcode %}

- `UIInfo`(`SUIInfo.cs`)는 `[Serializable] struct`로 `uiType`, `uiPrefab`, `isActive` 세 필드를 가진다. 인스펙터 배열에 바로 나타나게 하려는 것이다.
- `EUIType`은 `None = 0, Title, Prologue, GameUIController, Epilogue, Loading, Credit`이다. `None`을 0으로 두어 기본값이 "미지정"이 되게 했다.
- 루프는 프리팹이 비었거나 종류가 중복이면 건너뛴다. 만든 인스턴스를 사전에 담고, 끝나면 한 번에 `GUIManager.Init`을 부른다.
- `try/catch`가 예외를 `Debug.Log`로만 남기므로, 프리팹 하나가 잘못돼도 게임이 멈추지 않지만 원인 추적은 콘솔에 의존한다.

{% code title="GUIManager.cs (발췌)" %}
```csharp
public void Init(Dictionary<EUIType, GameObject> uiInstances)
{
    if (uiInstances.TryGetValue(EUIType.Title, out GameObject titleUI) && titleUI != null)
        TitleUI = titleUI;
    // ... Prologue, Epilogue, Loading, Credit 동일
    if (uiInstances.TryGetValue(EUIType.GameUIController, out GameObject gameUIController)
        && gameUIController != null)
        GameUIController = gameUIController.GetComponent<GameUIController>();

    CheckValidation(EUIType.Title, titleUI);
    _isInit = true;
    AutoDetectHardwarePerformance();
    SetVolumeOptions();
    LoadLanguageSettings();
}

private void Update()
{
    if (!_isInit) return;
    switch (GameManager.Instance.CurrentState)
    {
        case GameManager.GameState.Title:
            TitleUI.SetActive(true);
            PrologueUI.SetActive(false);
            GameUIController.gameObject.SetActive(false);
            // ... 나머지 화면 false
            break;
        // Prologue, Playing, Epilogue, Loading, Credit 도 같은 형태
    }
}
```
{% endcode %}

- `TryGetValue`로 꺼내 `null`이 아니면 속성에 저장한다. 게임 HUD는 `GetComponent<GameUIController>()`로 컨트롤러 참조를 얻는다. [UI 컨트롤러 분리](ui-controller.md)와 만나는 지점이다.
- `CheckValidation`은 없는 UI를 에러 로그로 알린다. 그러나 이후 `Update`의 `switch`는 `null` 검사를 하지 않는다.
- `_isInit`은 `Update`의 안전장치다. 초기화 전에는 아무 화면도 건드리지 않는다.
- `Update`가 매 프레임 `SetActive`를 반복한다. 같은 값이면 비용은 작지만 상태가 바뀔 때만 호출하는 방식이 더 깔끔하다(개선 여지).

{% code title="UI_Title.cs (발췌)" %}
```csharp
public class UI_Title : MonoBehaviour, PlayerActions.IUIActionMapActions
{
    [SerializeField] private GameObject _optionPanel;
    private PlayerActions _uiActions;

    private void Awake()
    {
        _uiActions = new PlayerActions();
        _uiActions.UIActionMap.SetCallbacks(this);
        _uiActions.UIActionMap.Enable();
    }

    void PlayerActions.IUIActionMapActions.OnSkip(InputAction.CallbackContext context)
    {
        if (context.started) OnClickOptionExit();
    }

    public void OnClickStart() => GameManager.Instance.EnterPrologue();
    public void OnClickExit()  => GameManager.Instance.ExitGame();
}
```
{% endcode %}

- `IUIActionMapActions`는 `PlayerActions.inputactions`의 `UIActionMap`(`NextDialogue`, `Skip`)에서 생성된 인터페이스다. 입력 장치와 무관하게 액션 단위로 콜백을 받는다.
- 타이틀에서는 `Skip` 액션이 들어오면 옵션 패널을 닫는다(어떤 키에 묶였는지는 확인하지 않았다).
- `OnEnable`/`OnDisable`에서 맵을 켜고 끄고 `OnDestroy`에서 `Dispose`한다. 생성한 `PlayerActions`는 해제하지 않으면 입력 구독이 남는다.

### 프롤로그 영상을 이름으로 처리하기

`893446b0`의 diff에서 핵심만 옮긴다.

{% code title="UI_Prologue.cs (893446b0 변경 요지)" %}
```csharp
public struct DialogVideoData
{
    // public VideoClip video;
    public string videoName;
    [TextArea(3, 5)] public string dialog;
}

videoPlayer.source = VideoSource.Url;
videoPlayer.url = System.IO.Path.Combine(
    Application.streamingAssetsPath, dialogs[_currentDialogIndex].videoName);
```
{% endcode %}

- `VideoClip`을 직접 들고 있으면 클립이 프리팹과 함께 빌드에 묶인다. 이름 문자열로 바꾸면 영상은 `StreamingAssets`의 파일이 되어 Addressables 그룹과 프리팹 크기에서 빠진다. 이 커밋은 같은 날 `Addressables`의 "Duplicate Asset Isolation" 그룹 추가와 `Assets/_ProjectAssets/07. Art/Dialogue`의 mp4 삭제도 함께 들어왔다(`06a4bf07`에서 `StreamingAssets`로 이동 추가).
- 영상이 없는 대사 판정이 `!dialogs[i].video`에서 `!...videoName.Equals("")`로 바뀐다. 현재 `main`은 `string.IsNullOrEmpty(videoName)`을 쓰고, 영상 두 개를 번갈아 미리 로드(`Prepare`)하는 구조로 더 발전했다. 이후 변경은 다른 커밋의 작업이므로 여기서는 이름 기반 전환만 다룬다.
- 프롤로그 끝에서는 `SceneManager.LoadScene(nextSceneName)` 대신 `GameManager.Instance.StartGame()`이 상태를 `Playing`으로 바꾼다.

## 따라 만들기 단계

1. `enum EUIType { None = 0, Title, Prologue, GameUIController, Epilogue, Loading, Credit }`와 `[Serializable] struct UIInfo { EUIType uiType; GameObject uiPrefab; bool isActive; }`를 만든다. 확인 방법: 컴파일 후 `UIInfo[]` 필드를 가진 임시 컴포넌트에서 인스펙터에 종류 드롭다운이 보인다.
2. 각 화면용 빈 프리팹(Canvas 하나씩)을 여섯 개 만든다. 확인 방법: 프로젝트 창에 프리팹 여섯 개가 있다.
3. `GameManager`(싱글톤)에 `GameState` 열거형과 `CurrentState`를 둔다. 확인 방법: 다른 스크립트에서 `GameManager.Instance.CurrentState`를 읽을 수 있다.
4. `GUIManager.Init(Dictionary<EUIType, GameObject>)`와 `Update`의 상태별 `SetActive`를 구현한다. 확인 방법: 아직 `InitUI`가 없으면 `Init`을 임시로 호출해 보고 `CurrentState` 값을 바꿀 때마다 한 화면만 켜지는지 본다.
5. `Scene_UI` 씬에 `InitUI`를 올리고 `uiInfos`에 여섯 프리팹과 `isActive`를 채운다. 확인 방법: 플레이하면 `Scene_UI` 안에 인스턴스가 여섯 개 생긴다.
6. `GameManager.EnterTitle`을 `async`로 만들어 `Scene_UI`를 추가 로드하고 그다음 상태를 `Title`로 바꾼다. 확인 방법: 플레이 시작 직후 타이틀 UI만 보인다.
7. 타이틀에 `UI_Title`을 붙이고 시작 버튼의 `OnClick`에 `OnClickStart`를 연결한다. 확인 방법: 버튼을 누르면 `CurrentState`가 `Prologue`로 바뀌고 프롤로그 UI가 켜진다.
8. 프롤로그에서 `VideoPlayer.source = VideoSource.Url`, `url = Path.Combine(Application.streamingAssetsPath, videoName)`로 영상을 재생한다. mp4는 `Assets/StreamingAssets`에 둔다. 확인 방법: 에디터에서 인스펙터에 파일명만 적어도 영상이 재생된다.

## 막히기 쉬운 곳과 한계

- `GUIManager.Update`가 `GameManager.Instance`를 매 프레임 읽는다. `GameManager`가 아직 없는 순서에서 호출되면 예외가 난다. 이 프로젝트는 `InitPersistent`가 먼저 매니저들을 만든 뒤 `Scene_UI`를 불러 순서를 맞춘다.
- `UnloadGUI`가 씬 언로드 전에 참조를 `null`로 만들고 `DOTween.KillAll()`을 부른다. 언로드와 참조 정리 순서를 바꾸면 안 된다.
- `StreamingAssets`의 영상은 Android에서 `file://`이 아니라 `jar:file://` 경로가 된다. 이 레포는 `Path.Combine`으로 합친 문자열을 `VideoPlayer.url`에 직접 넣는다. Android 실기기에서 재생 확인한 기록은 코드에서 확인하지 못했다(**unverified**).
- `LoadLanguageSettings`는 `"IsKorean"` 키로 기본값을 쓰지만 읽을 때는 `"Language"` 키를 쓴다. 키가 서로 다르다. 확인 필요.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 씬을 통째로 바꾸는 방식과 한 씬에서 UI를 켜고 끄는 방식의 차이를, 내가 만난 문제와 연결해 설명해 보자.
- [ ] 영상을 `VideoClip`이 아니라 파일 이름으로 바꾸게 된 계기는 무엇이었는가?
- [ ] `InitUI`의 `try/catch`가 예외를 로그로만 남기는 선택이 디버깅에 어떤 영향을 줬는가?
