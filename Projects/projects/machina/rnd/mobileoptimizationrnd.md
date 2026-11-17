# 모바일 최적화 연구 개발 (R&D)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-MRD-003-DO |
| 유형 | D&O (조사·설계 기록) |
| 목적 | 모바일 최적화 방침(텍스처, 오디오, 로딩, 메모리)과 부트스트랩 씬 구조를 기록한다 |
| 확인 상태 | 미검증 (조사 메모와 코드를 정리했으며 이 환경에서 컴파일·실행·측정하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 Addressables 설치·등록 절차는 [Addressables 설정과 씬 로드](addressablessetup.md)(PRJ-MRD-004-MP)로, 적용 중 나온 문제는 [모바일 최적화 적용 중 문제 기록](mobileoptimizationissues.md)(PRJ-MRD-005-TS)로 나눴다. 이 문서에 성능 측정값(FPS, 메모리)은 원본에 없다.
{% endhint %}

## 1. 최적화 방침

| 영역 | 방침 | 비고 |
|---|---|---|
| 에셋 관리 | Addressables를 도입한다. Resources 폴더 사용은 피한다 | 아래 NOTE 참조 |
| 텍스처 압축 | iOS와 Android 공통으로 ASTC를 쓴다. 블록 크기는 4x4~12x12 사이에서 조절하고 보통 6x6 또는 8x8을 권장한다 | 구형 Android는 ETC2, iOS는 PVRTC를 쓴다. 대부분의 기기가 ASTC를 지원한다 |
| 오디오 | BGM은 스트리밍한다. SFX는 `Decompress on Load` 또는 `Compressed in Memory`를 쓴다. `Force to Mono`를 켜 메모리를 줄인다 | 스테레오 클립 기준 약 절반 |
| 로딩 | 메인 스레드를 막지 않도록 모든 리소스 로딩을 비동기(Async)로 한다 | |
| 오브젝트 풀링 | 자주 생성·파괴하는 객체는 풀로 관리한다(이미 적용) | [오브젝트 풀링 조사](objectpoolingresearch.md) |
| 메모리 해제 | 씬 전환 시 `Resources.UnloadUnusedAssets()`를 호출하거나 Addressables 참조 카운트가 0이 되면 즉시 해제되게 설계한다 | 아래 NOTE 참조 |
| 프레임 | `Application.targetFrameRate = 60`을 시작 시 설정한다 | `InitManager.Init()` |
| 생명주기 | `OnApplicationPause(bool isPaused)`에서 백그라운드 진입 시 타이머와 물리 연산을 멈추고 인벤토리 같은 중요 데이터를 즉시 로컬에 저장한다 | DataManager 흐름에 포함 |
| 그 외 | 셰이더 컴파일 비용, 코루틴·비동기 작업의 부하 분산 | 상세는 원본에 없음 |

Addressables 도입 이유는 다음과 같다.

- 로컬과 원격 로딩 경로를 코드 수정 없이 바꿀 수 있다.
- 종속성을 자동으로 관리한다.
- 메모리 로드·언로드 추적이 쉽다.
- 자주 갱신하는 콘텐츠는 원격(CDN) 그룹으로, 기본 콘텐츠는 로컬 그룹으로 나눈다.

{% hint style="info" %}
NOTE: 원본은 "Resources 폴더의 모든 에셋이 앱 시작 시 인덱싱되어 시작 시간을 늦춘다"고 적었다. Unity 문서 기준으로 시작 시 읽는 것은 Resources 에셋의 조회 정보(인덱스)이며 에셋 본체는 요청할 때 로드된다. 시작 시간이 느려지고 메모리 관리가 어려워진다는 결론은 같다. Unity 버전별 동작은 확인하지 못했다. 버전 확인 필요.
{% endhint %}

{% hint style="info" %}
NOTE: Addressables로 로드한 에셋은 `Addressables.Release` 또는 `ReleaseInstance`(씬은 `UnloadSceneAsync`)로 해제해야 참조 카운트가 줄어든다. 해제 호출 없이 "참조가 0이 되면 자동 해제"되지는 않는다. 번들이 공유 종속성을 가지면 모든 참조가 풀릴 때까지 메모리에 남을 수 있다.
{% endhint %}

번들 중복 문제: 서로 다른 번들이 같은 텍스처나 셰이더를 참조하면 메모리에 두 번 로드될 수 있다. Addressables의 Analyze 도구(`Window > Asset Management > Addressables > Analyze`)로 중복 종속성을 찾아 공통 의존성 번들로 분리한다.

## 2. 씬 구조 (부트스트랩 패턴)

절대 파괴되지 않는 관리자 씬을 두고 그 위에 씬을 적층(Additive)한다.

| 씬 | 역할 | 포함 요소 |
|---|---|---|
| Bootstrap (Entry) | 가장 먼저 로드한다. 게임 플레이 요소는 없다. 필요하면 시스템 초기화(서버 설정, 버전 확인, 마스터 데이터 로드)를 맡는다 | `DontDestroyOnLoad` 싱글톤 매니저 |
| Persistent (영구 씬) | 항상 존재해야 하는 것 | Game Manager, Scene Manager, Data Manager, Init Manager, Event Manager, UI Manager, Sound Manager, Map Manager, Pool Manager, 공용 카메라, 오디오 리스너 |
| UI Scene | 캔버스, 팝업, HUD. 별도로 로드하며 카메라 설정과 무관하게 렌더링한다 | Loading Canvas, Title Canvas 등 |
| Environment (Static) | 지형, 라이트맵, 정적 오브젝트. 플레이 공간이 바뀔 때만 교체한다 | |
| Gameplay (Dynamic) | 스포너, 게임 규칙, 동적 객체. 동적으로 생성하는 오브젝트는 코드에서 이 씬에 만들도록 명시한다 | |
| Player Scene | 플레이어 프리팹 | |
| Event Scene (AddOn) | 로그 등 별도 관리자 배치용 | |

씬을 기능별로 쪼개 Additive로 로드하는 이유는 다음과 같다.

- 이전 씬을 모두 내리고 새 씬을 올리는 `LoadSceneMode.Single`은 로딩 끊김(스파이크)을 만든다고 판단했다. (원본은 메모리 단편화도 원인으로 적었으나 근거는 원본에 없다.)
- 거대한 씬 하나 대신 여러 씬으로 나누면 메모리 피크가 분산된다.

{% hint style="info" %}
NOTE: 원본의 로드 순서 설명이 두 가지다. 한 곳은 "Bootstrap 초기화 후 Persistent 씬을 Single 방식으로 로드", 다른 곳은 "부트스트랩 씬에서 영구 씬을 Additive로 로드"다. 코드(`InitManager`)는 `Addressables.LoadSceneAsync(address)`를 기본값(Single)으로 호출한다. 최종 채택안은 원본에서 구분되지 않는다. 확인 필요.
{% endhint %}

### 2.1 초기화 흐름

1. Bootstrap 씬이 시작되고 `InitManager`가 `Init()`으로 프레임 레이트 등 전역 설정을 적용한다.
2. `InitManager`가 Persistent 씬을 로드한다.
3. Persistent 씬의 Init 객체가 필요한 매니저 객체를 일괄 생성한다.
4. 모든 객체가 생성되면 Init 객체가 GameManager에 플래그를 남긴다.
5. GameManager가 생성되고 Init 플래그가 켜져 있으면 필요한 하위 씬(Loading, Title)을 Additive로 로드한다.
6. 다른 매니저는 GameManager의 상태(enum)를 보고 스스로 동작 여부를 판단한다.
7. Title UI의 클릭 이벤트로 GameManager 상태가 바뀌고 SceneManager가 다음 씬(GameScene, PlayerScene)을 로드한다. 준비될 때까지 UI Manager가 Loading Canvas를 켠다.
8. 게임을 종료할 때 씬을 생성의 역순으로 언로드해 메모리를 반환한다.

씬별 Init 객체는 해당 씬이 로드될 때 가장 우선하는 초기화를 맡는다(예: 생성한 객체를 상위 씬 매니저에 등록, 플레이어 스폰). Persistent 씬은 비휘발(항상 유지), 나머지는 휘발(교체 가능)로 구분했다.

{% hint style="warning" %}
CAUTION: Init 객체가 매니저를 생성할 때 각 매니저의 `Awake`, `Start`가 실행되어 의도하지 않은 null 오류가 날 수 있다. 각 매니저 스크립트에 예외 처리를 추가한다. Scene Manager는 GameManager가 없으면 아무 동작도 하지 않게 했다.
{% endhint %}

## 3. 코드 (원본 보존)

### 3.1 using 선언

```csharp
using UnityEngine;
using UnityEngine.AddressableAssets; // 핵심 기능
using UnityEngine.ResourceManagement.AsyncOperations; // 비동기 핸들(AsyncOperationHandle) 사용 시 필요
```

### 3.2 InitManager

```csharp
using Managers;
using System;
using UnityEngine;
using UnityEngine.AddressableAssets;
// using UnityEngine.ResourceManagement.AsyncOperations;
// using UnityEngine.ResourceManagement.ResourceProviders;
// using UnityEngine.SceneManagement;

public class InitManager : Singleton<InitManager>
{
    [SerializeField] private string persistentSceneAddress = "Scene_Persistent";
    
    private void Start()
    {
        Debug.Log("[InitManager] 시스템 초기화 시작...");

        // 1. 필요한 초기 설정 (예: 프레임 레이트, 로깅 설정)
        Init();
        
        // 2. Persistent 씬 로드
        LoadPersistentScene();
    }

    private static void Init()
    {
        Application.targetFrameRate = 60;
    }

    private async void LoadPersistentScene()
    {
        try
        {
            Debug.Log("[InitManager] Persistent 씬 로딩 중...");
        
            await Addressables.LoadSceneAsync(persistentSceneAddress).Task; // await Addressables.LoadSceneAsync(persistentSceneAddress, LoadSceneMode.Single).Task; 과 동일
        
            Debug.Log("[InitManager] 역할 종료. 제어권은 Game Manager로 넘어감.");
        }
        catch (Exception e)
        {
            Debug.LogError($"[InitManager] Persistent 씬 로드 실패: {e.Message}");
        }
    }
}
```

{% hint style="info" %}
NOTE: `Addressables.LoadSceneAsync`의 기본 로드 모드는 `LoadSceneMode.Single`이므로 코드 주석의 "동일"은 맞다. 단, 주석 처리된 `using UnityEngine.SceneManagement;`를 풀지 않으면 `LoadSceneMode`를 직접 쓸 수 없다. `Application.targetFrameRate`는 모바일에서 `QualitySettings.vSyncCount`가 0이 아니면 무시될 수 있다. 버전 확인 필요.
{% endhint %}

## 4. Addressables.LoadSceneAsync와 SceneManager.LoadScene의 차이

- `LoadSceneAsync`는 씬 로드를 Addressables 시스템으로 감싼 메서드다.
- 씬이 참조하는 에셋을 다운로드, 메모리 로드, 씬 활성화하고 참조 카운트를 올리는 복합 과정을 수행한다.
- 씬을 적층하는 구조에 더 알맞다.

## 5. 참조

- [참고 영상 (YouTube)](https://youtu.be/_s2V5qODbgs)

## 6. 약어·용어

| 용어 | 뜻 |
|---|---|
| ASTC | 모바일 GPU용 텍스처 압축 형식 |
| Additive | 기존 씬을 유지한 채 씬을 추가로 로드하는 방식 |
| Persistent 씬 | 게임 내내 유지되는 관리자 씬 |
| CDN | 원격으로 에셋을 배포하는 서버 네트워크 |

## 7. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM D&O 형식으로 재구성, 절차와 문제 기록을 별도 문서로 분리, 흩어진 다이어그램 텍스트를 표로 통합 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 부트스트랩 씬과 영구 씬을 분리한 이유를 내 말로 설명한다.
- [ ] 모바일 최적화에서 내가 직접 측정하거나 적용한 항목은 무엇이고 그 결과는 어땠는가?
- [ ] 이벤트 버스를 도입하지 않고 기존 코드를 최대한 유지하기로 한 판단이 옳았는가?
