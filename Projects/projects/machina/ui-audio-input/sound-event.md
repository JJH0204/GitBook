# 사운드와 이벤트 (SoundManager, FollowAudioListener, EventManager)

## 무엇을 하는가

- `SoundManager`는 오디오 리스너 프리팹을 한 번만 만들어 두는 싱글톤이다. 효과음 재생 API는 없다.
- `FollowAudioListener`는 그 리스너(와 미니맵 카메라)가 플레이어를 따라다니게 한다.
- `EventManager`는 `EEventType`별로 리스너 델리게이트를 모아 두는 싱글톤으로, 보내는 쪽과 받는 쪽이 서로를 참조하지 않게 한다.
- 볼륨은 `GUIManager.SetVolumeOptions`가 `AudioMixer`의 파라미터를 dB로 바꿔 넣는다.

## 왜 이렇게 설계했나

커밋 `cc61a4f3`(2025-12-09, "Add SoundManager and EventManager classes")에서 둘이 함께 들어왔다.

- `EventManager`는 원래 `MonoBehaviour`였고 `@Manager_Event`라는 오브젝트를 직접 `GameObject.Find`/`new GameObject`로 만들고 `lock`과 `applicationQuitting` 플래그를 가진 싱글톤이었다. 이 커밋에서 `Singleton<EventManager>` 상속과 `namespace Managers`로 옮기고 그 보일러플레이트를 삭제했다(이 커밋 diff는 57줄 추가, 95줄 삭제). 다른 매니저와 같은 기반 클래스, 같은 프리팹 생성 경로(`InitPersistent`의 `EManagerType`)를 쓰게 된 것이다.
- `SoundManager`가 오디오 리스너를 프리팹으로 따로 만드는 이유는 코드에서 두 가지로 읽힌다(추론). 하나는 플레이어 씬이 언로드·재로드돼도 리스너가 살아 있게 하는 것, 다른 하나는 플레이어 위치에 붙이되 높이 오프셋과 Y축만 회전을 선택할 수 있게 하는 것이다.
- `GameManager.SceneLoaded()`에서 `SoundManager.Instance.Init()`을 부른다. 같은 커밋이 `GameManager.CurrentState` 기본값을 `Title`에서 `Loading`으로 바꿨다. 매니저가 다 로드되기 전에는 `Loading`이라는 뜻이다.
- `79ca56c1`에서 `FollowAudioListener`에 `Init(player)`와 `_isInit` 가드가 추가됐다. 이전에는 인스펙터 참조로 대상을 고정해 두었으므로, 플레이어가 나중에 생성되는 구조에서는 `Update`가 `null`을 만졌을 것이다.

## 핵심 코드

{% code title="SoundManager.cs" %}
```csharp
public class SoundManager : Singleton<SoundManager>
{
    [SerializeField] private GameObject audioListenerPrefab;
    public GameObject AudioListener { get; private set; }
    private bool _isInit;

    public Task Init()
    {
        try
        {
            if (_isInit) return Task.CompletedTask;
            AudioListener = Instantiate(audioListenerPrefab);
            _isInit = true;
            return Task.CompletedTask;
        }
        catch (Exception e)
        {
            Debug.LogWarning($"[SoundManager] 초기화 중 예외 발생: {e}");
            return Task.CompletedTask;
        }
    }
}
```
{% endcode %}

- `Init`이 `Task`를 돌려주는 이유는 다른 매니저(`DungeonManager.Init` 등)와 같은 `await`형 초기화 규약을 맞추기 위해서로 보인다. 지금은 비동기 작업이 없어 `Task.CompletedTask`만 돌려준다.
- `_isInit`이 중복 호출에서 리스너가 두 개 생기는 것을 막는다.

{% code title="FollowAudioListener.cs (발췌)" %}
```csharp
private void Update()
{
    if (!_isInit) return;
    transform.position = positionTarget.position + offset;

    if (isYRotation)
    {
        Vector3 currentEuler = transform.rotation.eulerAngles;
        Vector3 targetEuler = rotationTarget.rotation.eulerAngles;
        transform.rotation = Quaternion.Euler(currentEuler.x, targetEuler.y, currentEuler.z);
    }
    else transform.rotation = rotationTarget.rotation;
}

public void Init(GameObject player)
{
    if (_isInit) return;
    positionTarget = player.GetComponent<Transform>();
    rotationTarget = player.GetComponent<Transform>();
    _isInit = true;
}
```
{% endcode %}

- `offset`은 플레이어 위치에서 얼마나 띄울지, `isYRotation`은 플레이어의 Y 회전만 따를지 결정한다. 미니맵 카메라는 위에서 내려다보므로 Y만 따라야 해서 같은 컴포넌트를 재사용한다.
- `InitPlayer.Init`에서 `SoundManager.Instance.AudioListener.GetComponent<FollowAudioListener>()?.Init(player)`로 연결한다. 미니맵 쪽 오브젝트도 같은 방식이다.
- `Unload()`는 `_isInit`을 끄고 참조를 비운다. 플레이어 씬을 내릴 때 대상이 사라진 뒤 `Update`가 돌지 않게 한다.

{% code title="EventManager.cs (발췌)" %}
```csharp
private Dictionary<EEventType, Action<EEventType, Component, object>> listeners = new ();

public void AddListener(EEventType eventType, Action<EEventType, Component, object> action)
{
    if (!listeners.ContainsKey(eventType))
        listeners.Add(eventType, null);

    listeners[eventType] -= action;   // 중복 등록 방지
    listeners[eventType] += action;
}

public void PostNotification(EEventType eventType, Component sender, object param = null)
{
    if (!listeners.ContainsKey(eventType)) return;
    listeners[eventType].Invoke(eventType, sender, param);
}
```
{% endcode %}

- 델리게이트 `-=` 후 `+=`로 같은 함수가 두 번 등록되는 것을 막는다.
- 이벤트 종류는 `EEventType`(`Interaction`, `SensitivityChangeX`, `SensitivityChangeY`, `LanguageChange`)이다. 플레이어가 상호작용하면 `PostNotification(EEventType.Interaction, this, null)`로 알린다.
- 보내는 쪽은 `Component sender`와 `object param`을 넘긴다. 받는 쪽은 `param`을 꺼내 캐스팅해야 하므로 타입 안정성은 없다.

{% code title="GUIManager.cs (볼륨 변환)" %}
```csharp
public void SetVolumeOptions()
{
    float volume = PlayerPrefs.GetFloat("BGMParam", 0.8f);
    volume = Mathf.Clamp(volume, 0.0001f, 1.0f);
    audioMixer.SetFloat("BGMParam", Mathf.Log10(volume) * 20);
    // "SEParam" 도 동일
}
```
{% endcode %}

슬라이더 값(0~1)을 `20 * log10(v)`로 데시벨로 바꿔 믹서에 넣는다. 0을 그대로 넣으면 로그가 음의 무한대가 되므로 하한을 `0.0001`(약 -80dB)로 고정한다.

## 따라 만들기 단계

1. `Singleton<T>`(`MonoBehaviour` 제네릭 싱글톤)를 준비한다. 이 레포의 기반 클래스 구현은 이 영역 대상이 아니므로 가져와 쓰거나 직접 만든다. 확인 방법: `Singleton<EventManager>.Instance`가 `null`이 아니다.
2. `EEventType` 열거형과 `EventManager`(`AddListener`, `RemoveListener`, `PostNotification`)를 만든다. 확인 방법: 테스트 스크립트 두 개 중 하나가 `AddListener`, 다른 하나가 `PostNotification`을 호출했을 때 콘솔에 받은 값이 찍힌다.
3. `AudioListener` 컴포넌트를 가진 빈 프리팹 `Audio_Listener`를 만들고 `FollowAudioListener`를 붙인다. 씬의 기본 `Main Camera`에서는 `AudioListener`를 제거한다. 확인 방법: 플레이 시 "There are 2 audio listeners" 경고가 나오지 않는다.
4. `SoundManager`에 프리팹 슬롯을 두고 `Init`에서 `Instantiate`한다. 확인 방법: 하이어라키에 `Audio_Listener(Clone)`이 정확히 하나 생긴다.
5. 플레이어 생성 코드에서 `SoundManager.Instance.AudioListener.GetComponent<FollowAudioListener>().Init(player)`를 부른다. 확인 방법: 플레이어를 움직이면 리스너 오브젝트의 위치가 따라온다.
6. `AudioMixer`를 만들고 BGM, SE 그룹의 볼륨을 `BGMParam`, `SEParam`으로 노출한다. `SetVolumeOptions`를 부른다. 확인 방법: `PlayerPrefs` 값을 0.1로 바꾸고 재생하면 소리가 확연히 작아진다.

## 막히기 쉬운 곳과 한계

- 믹서 파라미터는 반드시 "Expose"해야 `SetFloat`이 동작한다. 이름 철자가 틀리면 조용히 `false`만 반환한다.
- `EventManager.Clear()`는 `listeners.Keys`를 순회하면서 `RemoveEvent`로 같은 사전을 수정한다. 비어 있지 않을 때 `InvalidOperationException`이 날 수 있다. 코드를 읽은 판단이며 실행하지 않았다.
- `PostNotification`에 대해 `listeners[eventType]`이 `null`(모든 구독자가 `RemoveListener`한 뒤)일 수 있다. `Invoke`는 `?.`가 아니라서 이 경우 예외 가능성이 있다.
- `SoundManager.cs` 맨 위에 `using UnityEditor;`가 있다. 런타임 어셈블리에서 이 using은 플레이어 빌드에서 컴파일 오류가 날 수 있는 형태다. 확인 필요(이 레포의 Android 빌드가 어떻게 통과했는지는 코드만으로 판단할 수 없다).
- `SoundManager`에는 BGM/효과음 재생 메서드가 없다. 효과음은 비주얼 스크립팅 노드 `PlaySoundSimple`이 `audioSource.Play()`를 직접 호출한다(같은 커밋에서 비활성 상태일 때 재생하지 않도록 `isActiveAndEnabled` 검사가 추가됐다).

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 이벤트 버스를 두기 전에는 "상호작용 발생"을 받는 쪽이 보내는 쪽을 어떻게 알았을까? 도입 후 무엇이 편해졌는가?
- [ ] 오디오 리스너를 플레이어에 붙이지 않고 따로 따라가게 만든 이유를, 내가 겪은 상황과 함께 적어 보자.
- [ ] 슬라이더 값을 로그로 바꾸는 이유를 소리의 느낌 측면에서 설명해 보자.
