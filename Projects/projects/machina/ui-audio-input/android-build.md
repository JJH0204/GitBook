# Android 빌드 설정과 모바일용 UI

## 무엇을 하는가

PC용으로 만든 프로젝트를 Android 기기에서 돌리기 위해 손댄 것들이다. 렌더링 비용을 줄인 URP 자산 설정, 하드웨어를 보고 HDR을 켜고 끄는 코드, 큰 영상 파일을 `StreamingAssets`로 옮긴 일, 모바일 전용 HUD 프리팹, 에셋 번들(Addressables) 그룹 정리가 포함된다.

{% hint style="warning" %}
서명(키스토어) 설정은 이 문서에서 다루지 않는다. 공개 문서에 싣지 않는 정보이다. 이 문서의 내용은 커밋 diff와 소스를 읽은 해석이며 직접 빌드해 확인하지 않았다(unverified).
{% endhint %}

## 왜 이렇게 설계했나

### 커밋 `52f829bd` "Commint Android Build Settings" (2026-01-13)

한 커밋에 서로 다른 성격의 변경이 묶여 있다. 파일별로 풀면 다음과 같다.

| 변경 | 내용 | 읽히는 이유 |
| --- | --- | --- |
| `Settings/URP-Balanced.asset` | 메인 라이트 그림자 해상도 1024 → 256, 추가 라이트 모드 1 → 0, 소프트 섀도 끔 | 모바일 GPU 부담 축소 |
| `Settings/URP-HighFidelity.asset` | 추가 라이트 그림자, 리플렉션 프로브 블렌딩과 박스 프로젝션 끔 | 같은 이유 |
| `Game_LightingSettings.lighting` | `m_PVRSampleCount` 256 → 128 | 라이트맵 베이크 시간 단축 |
| `ProjectSettings/GraphicsSettings.asset` | 기본 렌더 파이프라인 자산 GUID 교체, 에디터 버전에 따른 직렬화 갱신 | 빌드가 사용할 URP 자산 지정 |
| `ProjectSettings/ProjectSettings.asset` | Android 아이콘 슬롯 구성 변경 | 플랫폼별 아이콘 |
| Addressables `Shared Asstes` 그룹 추가 | 공유 에셋을 따로 묶음(그룹 이름의 철자 `Asstes`는 원문 그대로) | 번들 간 중복 방지 |
| `Resources_moved/Skill/...` | 스킬 에셋을 `Resources` 폴더 밖으로 이동 | `Resources`는 항상 빌드에 포함되어 용량을 키우므로, Addressables 주소(`Skill/Flying/FlyingRush` 등)로 대체한 것으로 보인다(추론) |
| lilToon 패키지 파일 2개 | 렌더 파이프라인 표기 파일과 씬 복구 오류 방어 코드 | 서드파티 패키지에 가한 로컬 수정이다. 코드는 싣지 않는다 |

### HDR 설정의 오락가락 (`eaab122a`, `356088f0`)

- `eaab122a`(2026-01-15) "Disable HDR output in URP asset configurations for improved performance": 두 URP 자산에서 `m_PrefilterHDROutput`을 1에서 0으로 바꿨다.
- `356088f0`(2026-01-21) "Enable HDR output in URP asset configurations for enhanced visual quality": 같은 항목을 다시 0에서 1로 되돌렸다. 같은 커밋에서 `AddressableAssetsData/link.xml`(전날 `785e68f7`에서 추가된 457줄)도 삭제됐다.
- 커밋 메시지는 "HDR 출력"이라 쓰지만 diff의 필드 이름은 `m_PrefilterHDROutput`(셰이더 변형을 미리 거르는 설정)이다. 이 값이 정확히 어떤 변형을 빌드에서 빼는지는 이 레포만으로 확정하지 못했다. 확인 필요.
- 대신 실제로 기기마다 다르게 정하는 코드는 `GUIManager`에 있다.

{% code title="GUIManager.cs (HDR 자동 결정, 발췌)" %}
```csharp
private void AutoDetectHardwarePerformance()
{
    if (PlayerPrefs.HasKey("HDREnabled"))
    {
        SetHDR(PlayerPrefs.GetInt("HDREnabled") == 1);
        return;                              // 사용자가 정한 값이 있으면 존중
    }

    int vram = SystemInfo.graphicsMemorySize; // MB
    int cpuCount = SystemInfo.processorCount;
    bool isHDREnabled;
#if UNITY_EDITOR || UNITY_STANDALONE
    isHDREnabled = vram > 3000 && cpuCount >= 6;
#else
    isHDREnabled = vram > 1500 && cpuCount >= 8;   // 모바일은 코어 수를 더 중시
#endif
    PlayerPrefs.SetInt("HDREnabled", isHDREnabled ? 1 : 0);
    SetHDR(isHDREnabled);
}

public void SetHDR(bool enable)
{
    var urpAsset = GraphicsSettings.currentRenderPipeline as UniversalRenderPipelineAsset;
    if (urpAsset != null) urpAsset.supportsHDR = enable;
    PlayerPrefs.SetInt("HDREnabled", enable ? 1 : 0);
}
```
{% endcode %}

- 첫 실행에서는 VRAM과 CPU 코어 수로 기본값을 정하고 `PlayerPrefs`에 저장한다. 두 번째 실행부터는 저장된 값을 그대로 쓴다.
- 플랫폼 분기는 전처리기(`#if UNITY_EDITOR || UNITY_STANDALONE`)로 한다. 모바일은 VRAM 수치가 기기마다 흔들려서 임계값을 낮추고 코어 수 조건(8 이상)을 더한다. 주석이 이를 직접 설명한다.
- `supportsHDR`는 URP 자산의 런타임 속성이다. 에디터에서 자산 객체를 직접 바꾸므로 에디터에서는 변경이 자산에 남을 수 있다. 빌드된 앱에서는 앱 내 메모리 값이다(추론).

### 영상은 StreamingAssets로 (`06a4bf07`, `893446b0`)

프롤로그·에필로그 영상 mp4(`Prologue1~4`, `Epilogue_New_1~6`)가 `Assets/_ProjectAssets/07. Art/Dialogue`에서 `Assets/StreamingAssets`로 옮겨졌다. 코드 쪽 변경(영상 이름으로 참조)은 [UI 초기화와 화면 전환](ui-init-flow.md)에 있다. 이점은 번들·프리팹에서 큰 파일이 빠지는 것이고, 비용은 Android에서 `StreamingAssets`가 APK 내부 경로가 된다는 점이다.

### Android용 HUD 프리팹

`GameUIController_Android.prefab`는 PC용과 같은 `GameUIController` 컴포넌트를 쓰고 레이아웃만 다르다. 커밋 이력은 다음과 같다.

- `785e68f7`: 파일이 +3450/-9175로 크게 줄었다. 중복·불필요한 오브젝트를 정리한 변경으로 보이지만, 프리팹 YAML만으로 세부 내용은 확정하지 않았다.
- `893446b0`: `GameUIController`와 `_Android` 프리팹에 +112/-8이 들어갔다. 이 변경이 어떤 UI 항목인지는 diff 요약만으로 특정하지 못했다.
- `5c36fdb7`(2026-03-18): 한 `RectTransform`의 앵커 최소·최대가 오른쪽 중앙(1, 0.5)에서 화면 중앙(0.5, 0.5)으로, 위치가 (-250, -100)에서 (565, -7)로 바뀌었다. 같은 위치를 다른 해상도·비율에서 유지하려는 조정으로 읽힌다(대상 오브젝트 이름은 확인하지 못했다).

프리팹 구조는 `Canvas` 아래에 HUD 루트(`GUI`), 조준점, 페이드 패널, 슬라이더류, 라디얼, 알림, 일시정지·도움말·옵션 패널이 있고 모두 `GameUIController`의 `[SerializeField]`에 연결된다. 세부 계층은 프리팹을 열어 확인해야 한다.

## 따라 만들기 단계

1. `File > Build Profiles`(또는 Build Settings)에서 Android를 선택하고 `Switch Platform`한다. 확인 방법: 에디터 오른쪽 아래 플랫폼 표시가 Android로 바뀐다.
2. Player Settings에서 패키지 이름, 최소 API 레벨, 스크립팅 백엔드, 아이콘을 지정한다. 서명은 팀 규칙에 맞춰 별도로 설정하고 저장소에 올리지 않는다. 확인 방법: 설정 값을 바꾼 뒤 `ProjectSettings/ProjectSettings.asset`에 변경이 잡힌다.
3. 모바일용 URP 품질 자산을 따로 두거나 기존 것을 줄인다. 메인 라이트 그림자 해상도, 추가 라이트 모드, 소프트 섀도, 추가 라이트 그림자를 낮춘다. 확인 방법: 프레임 디버거 또는 Stats 창에서 배치와 그림자 비용이 줄어든다.
4. 큰 영상은 `Assets/StreamingAssets`에 넣고 이름으로 재생한다. 확인 방법: 에디터에서 `Application.streamingAssetsPath`와 파일 이름을 합친 경로가 존재한다. 실기기에서는 재생까지 확인한다.
5. `AutoDetectHardwarePerformance` 같은 코드를 `GUIManager.Init` 끝에 호출해 첫 실행 기본값을 정한다. 확인 방법: 에디터에서 `PlayerPrefs.DeleteKey("HDREnabled")` 후 플레이하면 키가 새로 생기고 `PlayerPrefs.GetInt`로 읽힌다.
6. Android용 HUD 프리팹을 PC 프리팹에서 복제하고 앵커를 화면 가장자리나 중앙 기준으로 다시 잡는다. 확인 방법: Game 뷰에서 여러 해상도(16:9, 20:9 등)를 바꿔 보며 버튼이 잘리지 않는다.
7. 리소스를 `Resources`에서 Addressables로 옮길 때는 그룹을 만들고 주소를 부여한 뒤 `Addressables.LoadAssetAsync`로 읽는다. 확인 방법: 플레이 모드와 빌드 모두에서 같은 에셋을 불러온다.
8. 빌드한 APK를 기기에 설치해 시작, 영상, HUD, 터치 카메라를 확인한다. 확인 방법: [모바일 입력과 게임패드](mobile-input.md)의 체크리스트를 기기에서 다시 돈다.

## 막히기 쉬운 곳과 한계

- 이 레포에는 Android 빌드 스크립트나 CI 설정을 이 영역 파일 안에서 찾지 못했다. 빌드 설정은 에디터 안의 `ProjectSettings` 변경으로만 남았다.
- `Prefilter HDR Output`을 끈 채 빌드하면 런타임에 `supportsHDR`를 켜도 변형이 없을 수 있다. 커밋 이력에서 이 값이 두 번 뒤집힌 이유일 가능성이 있으나 확정하지 못했다. 확인 필요.
- `link.xml`이 한 번 추가됐다가 다음 날 삭제됐다. IL2CPP 코드 스트리핑으로 Addressables 타입이 사라지는 문제를 다룬 파일로 보이지만 삭제 사유는 커밋 메시지에 없다. 확인 필요.
- `SoundManager.cs`의 `using UnityEditor;`는 플레이어 빌드에서 문제가 될 수 있다([사운드와 이벤트](sound-event.md) 참고). 확인 필요.
- 한 커밋에 여러 성격의 변경이 섞여 있어 되돌리기 어렵다. 설정 변경과 에셋 이동은 나눠 커밋하는 편이 낫다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] Android 빌드를 처음 돌렸을 때 막힌 문제와, 그것을 어떻게 알아내고 풀었는지 적어 보자.
- [ ] HDR 설정을 껐다 켰다 한 이유를 기억나는 대로 설명해 보자.
- [ ] `Resources`에서 Addressables로 옮기면서 얻은 것과 번거로워진 것은 무엇인가?
