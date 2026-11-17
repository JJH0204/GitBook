# Unity 6 이전과 Cinemachine 3.0 대응

## 무엇이 바뀌었나

포크의 첫 변경 커밋(38f2e184, "GOS-Unity6 마이그레이션 - 시네머신 3.0 미테스트")은 프로젝트를 Unity 6으로 올리면서 컷씬 노드 `CameraControl`을 Cinemachine 3 이름에 맞게 바꿨다. 이어서 842c05d8("카메라 컨트롤 시네머신 3.0에 사용가능하도록 변경")이 `CameraControl`을 다시 설계했다.

### 엔진·패키지

| 항목 | 원본 | 포크 |
| --- | --- | --- |
| Unity 에디터 | 2022.3.62f1 | 6000.3.16f1 |
| `com.unity.cinemachine` | 2.10.4 | 3.1.6 |
| `com.unity.timeline` | 1.7.7 | 1.8.12 (fd1e5bfa 이후) |
| `com.unity.ugui` | 1.0.0 | 2.0.0 |
| `com.unity.textmeshpro` | 3.0.7 | 항목 삭제 |
| `com.unity.visualscripting` | 1.9.4 | 1.9.11 (fd1e5bfa 이후) |

`textmeshpro`가 매니페스트에서 사라진 것은 Unity 6의 `ugui` 2.0 패키지가 TextMeshPro를 포함하기 때문으로 알려져 있다(Unity 일반 지식이며 이 레포에서 따로 확인하지는 않았다). 원본의 `GUIManager`가 `using TMPro;`를 썼는데, 이 파일은 5e073b03에서 삭제됐다.

### API 대응표

원본 `CameraControl.cs`와 포크의 38f2e184 시점 파일을 비교하면 Cinemachine 2.x에서 3.x로 바뀐 이름은 다음과 같다. 포크 쪽 이름은 이후 재설계에서도 유지된다.

| 원본 (Cinemachine 2.10) | 포크 (Cinemachine 3.1) |
| --- | --- |
| `using Cinemachine;` | `using Unity.Cinemachine;` |
| `CinemachineVirtualCamera` | `CinemachineCamera` |
| `CinemachineBlendDefinition.Style` (열거형) | `CinemachineBlendDefinition.Styles` |
| `blend.m_Style`, `blend.m_Time` | `blend.Style`, `blend.Time` |
| `cinemachineBrain.m_DefaultBlend` | `cinemachineBrain.DefaultBlend` |

Unity 6 쪽에서는 `ManagerBase`가 `FindObjectOfType(typeof(T))` 대신 `GameObject.FindAnyObjectByType(typeof(T))`를 쓰도록 바뀌었다(5e073b03). 앞의 것은 Unity 2023 이후 사용 중단 예고된 API다(일반 지식).

## 왜

* 엔진을 올리면 패키지 버전이 따라 올라가고, Cinemachine은 2에서 3으로 가면서 네임스페이스와 클래스 이름이 바뀌었다. 그대로 두면 컴파일이 되지 않는다. 38f2e184의 커밋 메시지 둘째 줄 "시네머신 3.0 미테스트"는 이름만 바꾸고 동작은 확인하지 않았다는 뜻으로 읽힌다.
* 842c05d8에서 구조까지 바꾼 이유는 코드에서 두 가지가 읽힌다. 첫째, 원본의 페이드 연출은 삭제된 `GUIManager`에 의존했다. 둘째, 컷씬 길이를 `WaitForSeconds`로 직접 재는 대신, 이미 만든 Timeline(`PlayableDirector`)이 끝날 때까지 기다리면 컷씬 길이를 Timeline 에셋 한 곳에서만 관리하면 된다. 후자는 코드 구조에서 추정한 이유이며 커밋 메시지에는 적혀 있지 않다.

## 핵심 코드

원본은 컷씬 카메라를 배열로 받아 일정 시간씩 순서대로 보여 줬다. 포크는 메인 카메라 1대, 컷씬 카메라 1대, `PlayableDirector` 1개를 받는다.

{% code title="Output/CameraControl.cs (포크, 일부)" %}
```csharp
using Unity.Cinemachine;
using UnityEngine.Playables;

public class CameraControl : ProcessBase
{
    [SerializeField] private CinemachineCamera mainVirtualCamera;
    [SerializeField] private CinemachineCamera cutsceneVirtualCamera;
    [SerializeField] private PlayableDirector playableDirector;
    [SerializeField] private int mainVirtualCameraPriority;
    [SerializeField] private int cutceneVirtualCameraPriority;

    private void Start()
    {
        if (mainVirtualCamera is not null && cutsceneVirtualCamera is not null && playableDirector)
        {
            mainVirtualCameraPriority = mainVirtualCamera.Priority;
            cutceneVirtualCameraPriority = cutsceneVirtualCamera.Priority;
        }
        // else: 비어 있는 항목마다 VisualLogger.LogError
    }

    public override void Execute()
    {
        if (mainVirtualCamera is null || cutsceneVirtualCamera is null || playableDirector is null) return;
        if (IsOn) return;
        playableDirector.Play();
        StartCoroutine(SwitchToCutscene());
        IsOn = true;
    }

    private IEnumerator SwitchToCutscene()
    {
        cutsceneVirtualCamera.Priority = mainVirtualCameraPriority + 1;
        mainVirtualCamera.Priority = cutceneVirtualCameraPriority;
        while (playableDirector.state == PlayState.Playing) yield return null;
        cutsceneVirtualCamera.Priority = cutceneVirtualCameraPriority;
        mainVirtualCamera.Priority = mainVirtualCameraPriority;
    }
}
```
{% endcode %}

줄 단위 설명.

* `using Unity.Cinemachine;`, `CinemachineCamera`: 위 대응표의 Cinemachine 3 이름이다.
* `mainVirtualCameraPriority`, `cutceneVirtualCameraPriority`: `Start`에서 두 카메라의 **원래 우선순위**를 저장해 둔다. 컷씬이 끝난 뒤 원래대로 되돌리기 위해서다.
* `Execute()`: 설정이 하나라도 비어 있으면 아무것도 하지 않고 돌아온다. `IsOn`이 이미 `true`이면 다시 실행하지 않는다. 즉 한 번 재생하면 끝이다.
* `SwitchToCutscene()`: 컷씬 카메라를 "메인 우선순위 + 1"로 올려 Cinemachine Brain이 컷씬 카메라를 선택하게 만든다. 메인 카메라에는 컷씬 카메라의 원래 우선순위를 준다. 두 카메라의 우선순위를 맞바꾸는 셈이다.
* `while (playableDirector.state == PlayState.Playing)`: Timeline이 재생되는 동안 한 프레임씩 기다렸다가, 끝나면 우선순위를 원상복구한다.

원본에서 삭제된 부분은 `CutsceneMode`(FadeInNOut/CameraMove), `CinemachineCutsceneData[]`(카메라와 지속 시간 쌍), `cinemachineBrain` 블렌드 설정, `GUIManager.FadeOut/FadeIn` 호출이다. 원본의 `Start()`가 `GameObject.Find("FollowCamera")`로 메인 카메라를 찾던 코드도 사라졌고, 대신 인스펙터에 직접 넣도록 오류 로그를 낸다.

## 따라 만들기

1. Unity 6(6000.x) 프로젝트를 만들고 Package Manager에서 Cinemachine 3.x와 Timeline을 설치한다. 확인 방법: `Packages/manifest.json`에 `com.unity.cinemachine`이 3.x로, `com.unity.timeline`이 있다.
2. `Cinemachine` 메뉴로 `CinemachineBrain`이 붙은 메인 카메라와 `CinemachineCamera` 2개(메인용, 컷씬용)를 만든다. 메인용의 우선순위를 컷씬용보다 높게 둔다(소스 주석: "메인카메라가 반드시 우선순위가 높아야함"). 확인 방법: 플레이하면 Game 뷰가 메인용 카메라 시점이다.
3. 컷씬용 `CinemachineCamera`를 움직이는 Timeline을 만든다. 빈 오브젝트에 `PlayableDirector`를 붙이고 Timeline 에셋을 지정하고 `Play On Awake`를 끈다. 확인 방법: 에디터에서 Timeline을 재생해 컷씬 카메라가 움직인다.
4. 위 발췌를 참고해 `CameraControl`을 작성한다. 이 노드는 `ProcessBase`가 필요하므로 원본 GOS의 `ProcessBase`·`ProcessData`가 먼저 있어야 한다([../gos/README.md](../gos/README.md)). 포크 코드가 쓰는 `VisualLogger`가 없다면 `Debug.LogError`로 바꿔도 된다.
5. 빈 오브젝트에 `CameraControl`을 붙이고 메인 카메라, 컷씬 카메라, `PlayableDirector`를 인스펙터에서 지정한다. 확인 방법: 컴포넌트의 컨텍스트 메뉴 "강제 실행 (테스트)"(`ProcessBase.ForceExecute`)를 플레이 중에 실행하면 컷씬이 재생되고, 끝나면 메인 카메라로 돌아온다.
6. 트리거와 이어 본다. `Conditional`의 `inputData`에 `Trigger`를, `outputData`에 이 노드를 연결하면 플레이어가 영역에 들어갈 때 컷씬이 시작된다.

## 한계·주의

* 38f2e184 메시지가 "미테스트"라고 밝혔고, 842c05d8 이후의 재설계가 실제로 테스트됐는지는 레포에서 확인되지 않는다. 이 페이지의 설명은 코드를 읽은 것이다(unverified).
* `Priority`를 정수로 대입하고 읽는 코드가 Cinemachine 3.1에서 그대로 컴파일되는지는 이 문서가 직접 확인하지 못했다. 다만 레포에 커밋된 `unity_build.log`에는 컴파일 오류가 없다. 이 로그는 d3cfe625 시점의 기록이다.
* 컷씬 카메라 우선순위가 메인 카메라보다 높게 설정돼 있으면(소스 주석의 조건 위반) 우선순위 맞바꾸기가 의도대로 동작하지 않는다.
* `IsOn`이 한 번 `true`가 되면 `Execute()`가 다시 실행되지 않는다. 같은 컷씬을 반복하려면 `Reset()`이 필요한데, `Conditional.isLoop`가 이를 대신 호출해 준다.
* Cinemachine, Timeline 패키지 자체의 내부 동작은 설명하지 않고 사용 사실만 적었다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 컷씬 카메라와 메인 카메라의 "우선순위"를 바꾸는 것만으로 화면이 전환되는 이유를, Cinemachine Brain이 하는 일과 연결해서 설명해 보자.
- [ ] 컷씬 길이를 `WaitForSeconds`로 정하는 방식과 `PlayableDirector.state`를 기다리는 방식은 무엇이 다른가? 직접 컷씬을 만들어 본 경험이 있다면 어느 쪽이 편했는지 적어 보자.
- [ ] 엔진이나 패키지를 올렸을 때 컴파일이 깨진 경험이 있는가? 그때 무엇부터 확인했는지 적어 보자.
