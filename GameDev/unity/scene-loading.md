# [생성형 AI] 씬 로딩: SceneManager와 비동기 로드

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UNI-009-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | `SceneManager.LoadScene`과 `LoadSceneAsync`의 차이와 로딩 화면, Additive 로드의 동작을 이해한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (Unity에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 1. 정의

Unity 게임은 보통 여러 씬(Scene)으로 나뉜다. 씬 전환은 `UnityEngine.SceneManagement.SceneManager`가 맡는다. 동기 로드는 로딩이 끝날 때까지 프레임이 멈추고, 비동기 로드는 여러 프레임에 걸쳐 진행해 로딩 화면을 보여줄 수 있다.

## 2. 구성 요소

| API | 동작 |
|---|---|
| `SceneManager.LoadScene(name 또는 index)` | 동기 로드. 다음 프레임에 전환된다 |
| `SceneManager.LoadSceneAsync(name, mode)` | 비동기 로드. `AsyncOperation`을 돌려준다 |
| `LoadSceneMode.Single` | 현재 씬을 모두 내리고 새 씬을 연다 |
| `LoadSceneMode.Additive` | 현재 씬을 유지한 채 새 씬을 추가한다 |
| `AsyncOperation.progress` | 0~1 진행도. `allowSceneActivation`이 false이면 0.9에서 멈춘다 |
| `AsyncOperation.allowSceneActivation` | false이면 로드를 끝내지 않고 대기한다 |
| `SceneManager.UnloadSceneAsync` | Additive로 올린 씬을 내린다 |
| `SceneManager.sceneLoaded` | 로드 완료 이벤트(`Scene`, `LoadSceneMode` 전달) |
| `Object.DontDestroyOnLoad(go)` | `Single` 로드 시에도 오브젝트를 유지한다 |

## 3. 동작 원리

### 3.1 빌드에 씬 등록

씬은 빌드 목록에 등록해야 이름이나 인덱스로 로드할 수 있다(`File > Build Settings`의 Scenes In Build. Unity 6에서는 `File > Build Profiles` 계열 화면이다. 버전 확인 필요). 등록하지 않은 씬을 로드하면 오류가 난다.

### 3.2 로딩 화면 예제

```csharp
using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneLoader : MonoBehaviour
{
    [SerializeField] UnityEngine.UI.Image progressBar;

    public void Load(string sceneName) => StartCoroutine(LoadRoutine(sceneName));

    IEnumerator LoadRoutine(string sceneName)
    {
        AsyncOperation op = SceneManager.LoadSceneAsync(sceneName, LoadSceneMode.Single);
        op.allowSceneActivation = false;

        while (op.progress < 0.9f)
        {
            progressBar.fillAmount = op.progress / 0.9f;   // 0~0.9를 0~1로 환산
            yield return null;
        }

        progressBar.fillAmount = 1f;
        yield return new WaitForSecondsRealtime(0.3f);   // 마무리 연출(예시)
        op.allowSceneActivation = true;                  // 전환 실행
    }
}
```

`allowSceneActivation = false`일 때 `progress`는 0.9에서 멈추고 `isDone`은 false다. 그래서 위처럼 0.9를 완료로 취급한다.

### 3.3 Additive 로드

| 용도 | 방법 |
|---|---|
| 공통 UI·관리자 씬 유지 | 시작 시 `Additive`로 한 번만 올린다 |
| 레벨 청크 | 필요한 구역 씬을 올리고 벗어나면 `UnloadSceneAsync`로 내린다 |
| 활성 씬 지정 | `SceneManager.SetActiveScene`. 새로 `Instantiate`되는 오브젝트와 조명 설정의 기준 씬이 된다 |

### 3.4 주의

{% hint style="warning" %}
CAUTION: `Time.timeScale`이 0이면 `WaitForSeconds`가 끝나지 않는다. 일시정지 상태에서 씬을 넘길 때는 `WaitForSecondsRealtime`을 쓰거나 `timeScale`을 1로 되돌린다.
{% endhint %}

| 문제 | 원인과 대응 |
|---|---|
| 다음 씬에 이전 오브젝트가 남음 | `DontDestroyOnLoad` 오브젝트가 씬마다 중복 생성되지 않게 싱글턴으로 막는다 |
| `sceneLoaded` 구독이 누적됨 | `OnEnable`에서 구독하고 `OnDisable`에서 해제한다 |
| 로드 중 `Awake` 시점 | 로드된 씬의 `Awake`와 `OnEnable`은 활성화되는 시점에 호출된다. 로딩 화면 로직은 `allowSceneActivation` 이후를 가정하지 않는다 |
| 에디터에서만 빠르게 로드됨 | 실기기 저장장치는 느리므로 실기기에서 측정한다 |

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 씬(Scene) | 오브젝트와 설정을 담은 Unity 파일 단위 |
| Additive | 현재 씬을 유지한 채 추가 로드하는 방식 |
| AsyncOperation | 비동기 작업 진행 상태를 담은 객체 |

## 5. 더 보기

* [시간: deltaTime, fixedDeltaTime, timeScale](time-deltatime.md)
* [Unity 코루틴의 내부](../unity-csharp/day08-unity-coroutine.md)
* [Unity ScriptReference: SceneManager](https://docs.unity3d.com/ScriptReference/SceneManagement.SceneManager.html)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 동기 로드와 비동기 로드 중 지금 만드는 게임에 맞는 방식을 고르고 이유를 쓴다.
- [ ] 씬 전환 때 유지해야 하는 데이터(점수, 설정 등)를 어떻게 넘길지 쓴다.
