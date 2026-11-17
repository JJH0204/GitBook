# 출력 노드: 결과 행동을 실행한다

## 무엇을 하는가

출력 노드는 `Execute()`가 불렸을 때 실제로 게임 오브젝트에 변화를 준다. 보통 `Conditional`의 출력 목록에 넣어 사용한다.

| 노드 | 하는 일 | 다시 실행 가능? |
|---|---|---|
| `Activate` | 대상 오브젝트를 켠다 | 가능 |
| `Deactivate` | 대상 오브젝트를 끈다 | 가능 |
| `ToggleActivate` | 대상 오브젝트의 켜짐/꺼짐을 뒤집는다 | 가능 |
| `Instance` | 프리팹을 지정 범위 안에 생성한다 | 한 번만 |
| `Destroy` | 대상 오브젝트를 파괴한다 | 가능(대상이 이미 없으면 무시) |
| `MoveObject` | 대상을 경유점 목록을 따라 이동시킨다 | 가능(중복 실행 주의) |
| `RotateObject` | 대상을 지정 각도만큼 회전시킨다 | `Rotate Once` 옵션에 따름 |
| `PlayAnimation` | `AnimCheck`가 붙은 오브젝트의 애니메이션을 재생한다 | 한 번만 |
| `CameraControl` | Cinemachine 카메라를 차례로 전환해 컷씬을 재생한다 | 한 번만 |
| `Register`, `Unregister` | 상호작용 등록/해제(본체 주석 처리) | 해당 없음 |

## 왜 이렇게 설계했나

- 출력 노드는 "대상 오브젝트 칸"과 "옵션"만 노출하고, 이동·회전은 코루틴으로 시간을 두고 보간한다. 기획자는 목표 위치와 시간만 정하면 된다.
- 대부분 `if (IsOn) return;`으로 시작하고 실행 후 `IsOn = true`로 만든다. 같은 노드가 여러 번 호출돼도 한 번만 동작하게 하는 장치이자, 다른 `Conditional`이 "이 일이 끝났는가"를 읽는 신호가 된다.
- 위치·회전의 목표를 숫자가 아니라 "빈 오브젝트(Transform)"로 받는다. Scene 창에서 위치를 눈으로 보며 정할 수 있다.

## 핵심 코드 발췌

{% code title="VisualScripting/Output/SetActivate/Activate.cs, ToggleActivate.cs" %}
```csharp
public class Activate : ProcessBase
{
    [SerializeField] private GameObject obj;

    public override void Execute()
    {
        IsOn = true;
        obj.SetActive(true);
    }
}

public class ToggleActivate : ProcessBase
{
    [SerializeField] private GameObject obj;

    private void Start()
    {
        IsOn = obj.activeSelf;
    }

    public override void Execute()
    {
        IsOn = obj.activeSelf;
        obj.SetActive(!IsOn);
    }
}
```
{% endcode %}

- `Activate`와 `Deactivate`는 대칭이다. `Deactivate`는 `IsOn = false`로 두고 `SetActive(false)`를 호출한다.
- `ToggleActivate`는 시작할 때 대상의 켜짐 상태를 `IsOn`에 복사하고, 실행할 때 반대로 만든다. 실행 후의 `IsOn`은 토글 직전의 상태를 가진다(새 상태와 반대).
- `obj`가 비어 있으면 세 노드 모두 null 참조 오류가 난다.

{% code title="VisualScripting/Output/Instance.cs" %}
```csharp
public class Instance : ProcessBase
{
    [SerializeField] private GameObject instancePrefab;
    [SerializeField] private int count = 1;
    [SerializeField] private Vector3 spawnArea;
    [SerializeField] private IsDestroy destroyTrigger;

    public override void Execute()
    {
        if (IsOn) return;
        if (instancePrefab is null) { Debug.LogError("Instance prefab is not assigned."); return; }
        IsOn = true;

        for (var i = 0; i < count; i++)
        {
            var randomX = Random.Range(-spawnArea.x / 2, spawnArea.x / 2);
            var randomY = Random.Range(-spawnArea.y / 2, spawnArea.y / 2);
            var randomZ = Random.Range(-spawnArea.z / 2, spawnArea.z / 2);

            var randomPosition = transform.position + new Vector3(randomX, randomY, randomZ);

            var obj = Instantiate(instancePrefab, transform);
            obj.transform.position = randomPosition;

            destroyTrigger?.AddObject(obj.GetComponent<GlobalGameObject>());
        }
    }
}
```
{% endcode %}

- `spawnArea`: 노드 위치를 중심으로 한 생성 범위(상자 크기). 노드를 선택하면 빨간 와이어 박스로 보인다.
- `Instantiate(prefab, transform)`: 노드의 자식으로 만든다. 그래서 Hierarchy에서 생성물을 찾기 쉽다.
- `destroyTrigger`: 생성한 오브젝트가 모두 파괴되면 켜질 `IsDestroy` 노드. 프리팹에 `GlobalGameObject`가 있어야 한다.

{% code title="VisualScripting/Output/MoveObject.cs (C_Move)" %}
```csharp
private IEnumerator C_Move()
{
    for (var i = 0; i < moveTargetPos.Count; i++)
    {
        var target = moveTargetPos[i].transform.position;
        var timer = moveTargetPos[i].time;
        var startPosition = objectToMove.transform.position;
        var elapsedTime = 0f;

        while (elapsedTime < timer)
        {
            elapsedTime += Time.deltaTime;
            var t = elapsedTime / timer;
            objectToMove.transform.position = Vector3.Lerp(startPosition, target, t);
            yield return null;
        }

        objectToMove.transform.position = target;
    }
    yield return null;
}
```
{% endcode %}

- `moveTargetPos`: `MoveData`(Transform + 시간)의 목록. 위에서부터 차례로 이동한다.
- 각 구간에서 시작 위치를 새로 읽고 `Lerp`로 선형 보간한다. 구간이 끝나면 목표 위치에 정확히 놓는다(부동소수 오차 방지).
- 이 노드는 `IsOn`을 바꾸지 않는다. 그래서 `Execute()`가 여러 번 불리면 이동 코루틴이 겹쳐 돈다.

{% code title="VisualScripting/Output/RotateObject.cs (핵심)" %}
```csharp
[Range(-90f, 90f)][SerializeField] private float rotateAngle;
[SerializeField] private RotateAxis axis;
[SerializeField] private float timeToRotate = 1f;
[SerializeField] private bool rotateOnce = true;

private IEnumerator C_Rotate()
{
    IsOn = true;
    Transform tf = objectToRotate.transform;
    Quaternion start = tf.localRotation;

    bool anyAxis = axis.x || axis.y || axis.z;
    Vector3 eulerDelta = anyAxis
        ? new Vector3(axis.x ? rotateAngle : 0f, axis.y ? rotateAngle : 0f, axis.z ? rotateAngle : 0f)
        : new Vector3(0f, rotateAngle, 0f);   // 축 미선택 시 Y축

    Quaternion target = start * Quaternion.Euler(eulerDelta);
    float elapsedTime = 0f;
    while (elapsedTime < timeToRotate)
    {
        elapsedTime += Time.deltaTime;
        float t = Mathf.Clamp01(elapsedTime / timeToRotate);
        tf.localRotation = Quaternion.Slerp(start, target, t);
        yield return null;
    }
    tf.localRotation = target;
    IsOn = rotateOnce;
}
```
{% endcode %}

- 회전은 현재 `localRotation`에서 `rotateAngle`만큼 더한 값이 목표다(절대 각도가 아니라 상대 각도).
- 체크한 모든 축에 같은 각도가 들어간다. 축을 하나도 체크하지 않으면 Y축으로 회전한다.
- `IsOn = rotateOnce`: 끝난 뒤 `rotateOnce`가 true면 켜진 채로 남아 다시 실행되지 않고, false면 꺼져 다시 실행할 수 있다.
- 회전 중심은 오브젝트의 피벗이므로 문은 경첩 위치에 피벗을 둔 부모 오브젝트를 대상으로 삼는다.

{% code title="VisualScripting/Output/CameraControl.cs (핵심)" %}
```csharp
[SerializeField] private CinemachineVirtualCamera mainVirtualCamera;
[SerializeField] private CinemachineCutsceneData[] cutsceneData;   // 카메라 + 재생 시간
[SerializeField] private CinemachineBrain cinemachineBrain;
[SerializeField] private CutsceneMode cutsceneMode = CutsceneMode.CameraMove;
[SerializeField] private float cutsceneBlendTime = 1f;

public override void Execute()
{
    if (IsOn) return;
    BlendToCutscene();                        // 모드에 따라 블렌드 방식 설정
    StartCoroutine(SwitchToCutscene());
    IsOn = true;
}

private IEnumerator SwitchToCutscene()
{
    int originalPriority = mainVirtualCamera.Priority;
    for (int i = 0; i < cutsceneData.Length; i++)
    {
        var cutscene = cutsceneData[i];
        cutscene.cutsceneVirtualCamera.Priority = originalPriority + 1 + i;
        yield return new WaitForSeconds(cutscene.cutsceneDuration);
    }
    foreach (var cutscene in cutsceneData)
        cutscene.cutsceneVirtualCamera.Priority = originalPriority - 1;
}
```
{% endcode %}

- Cinemachine은 우선순위(Priority)가 가장 높은 가상 카메라를 화면에 보여 준다. 컷씬은 이 성질을 이용해 컷씬 카메라의 우선순위를 메인 카메라보다 높이는 것으로 전환한다.
- `i`번째 컷씬 카메라는 `원래 우선순위 + 1 + i`를 받아 앞 카메라보다 더 높아지므로 순서대로 이어서 전환된다. 각 컷씬은 `cutsceneDuration`초 동안 유지된다.
- 마지막 `foreach`는 모든 컷씬 카메라를 `원래 우선순위 - 1`로 낮춰 메인 카메라로 돌아간다.
- `BlendToCutscene`은 `CinemachineBrain`의 기본 블렌드를 설정한다. `CameraMove`는 EaseInOut으로 부드럽게 이동하고, `FadeInNOut`은 Cut(즉시 전환)으로 하고 `GUIManager`의 페이드 패널을 사용한다.
- 위 발췌는 페이드 호출과 null 검사 로그를 생략했다. 전체는 `CameraControl.cs`에 있다.

{% code title="VisualScripting/Output/PlayAnimation.cs, AnimCheck.cs (핵심)" %}
```csharp
public class PlayAnimation : ProcessBase
{
    [SerializeField] private List<AnimCheck> objects = new();

    public override void Execute()
    {
        if (IsOn) return;
        if (objects.Count <= 0) return;
        foreach (AnimCheck obj in objects) obj.Play();
        IsOn = true;
    }
}

public class AnimCheck : MonoBehaviour
{
    [SerializeField] private Animator _animator;
    [SerializeField] private AnimationClip animationClip;
    [SerializeField, Range(0.0f, 5.0f)] private float animSpeed = 1.0f;
    [SerializeField] private bool isPlay = false;

    private void Update()
    {
        _overrideController["Take 001"] = animationClip;
        _animator.SetFloat("animSpeed", animSpeed);
        _animator.SetBool("isPlay", isPlay);
    }

    public void Play() { isPlay = true; }
}
```
{% endcode %}

- `PlayAnimation`은 자기가 애니메이션을 재생하지 않고, 대상 오브젝트에 붙은 `AnimCheck.Play()`를 부른다.
- `AnimCheck`는 Animator의 파라미터 `animSpeed`(float)와 `isPlay`(bool)를 매 프레임 갱신하고, Awake에서 만든 `AnimatorOverrideController`의 `"Take 001"` 상태 클립을 지정 클립으로 바꾼다. 즉 Animator Controller가 `Take 001`이라는 이름의 상태와 이 두 파라미터를 미리 갖고 있어야 한다(코드에서 읽은 전제이며 unverified).
- `defaultObject`와 `animObject`를 지정하면 재생 여부에 따라 둘 중 하나만 켠다. 발췌에서는 생략했다.

## 따라 만들기

1. `Activate.cs`, `Deactivate.cs`, `ToggleActivate.cs`를 만든다. 각 노드는 `ProcessBase`를 상속하고 `GameObject obj` 칸 하나를 가진다.
   - 확인 방법: 비활성 큐브를 대상으로 두고 `OnEvent → Conditional → Activate`를 구성한 뒤 Is On을 켜면 큐브가 나타난다. `ToggleActivate`로 바꾸면 한 번 실행할 때마다 반대로 바뀌는지 본다(단, `Conditional`은 입력이 꺼졌다 켜져야 다시 실행된다).
2. `Destroy.cs`를 만든다. 클래스 이름이 `Destroy`라 유니티의 `Destroy()`와 같은 이름이므로 메서드 호출이 `Object.Destroy`로 해석되는지 컴파일로 확인한다.
   - 확인 방법: 연결한 오브젝트가 Play 중 사라진다.
3. `MoveObject.cs`를 만든다. 빈 오브젝트 두 개(`pos1`, `pos2`)를 경유점으로 두고, `Move Target Pos`에 요소 두 개(시간 2, 3초)를 넣는다.
   - 확인 방법: 대상 큐브가 `pos1`로 2초, 이어서 `pos2`로 3초에 걸쳐 이동하고 정확히 도착한다.
4. `RotateObject.cs`를 만든다. 문 역할의 큐브를 경첩 위치에 피벗이 있는 빈 부모에 넣고 부모를 대상으로 지정한다. Axis는 Y, 각도 90.
   - 확인 방법: 실행하면 1초 동안 90도 회전해 멈춘다.
5. `Instance.cs`를 만든다. 프리팹은 `GlobalGameObject`가 붙은 간단한 큐브 프리팹이면 된다.
   - 확인 방법: 노드를 선택하면 빨간 상자가 보이고, 실행하면 그 안에 `count`개가 노드의 자식으로 생긴다.
6. `PlayAnimation.cs`와 `AnimCheck.cs`는 Animator Controller 준비가 필요하다. `Take 001` 상태와 두 파라미터를 가진 Controller를 만든 뒤 시도한다.
   - 확인 방법: 실행하면 대상의 Animator가 재생 상태가 된다. 준비가 어려우면 이 단계는 건너뛴다.
7. Cinemachine 2.10.x를 Package Manager에서 설치하고 `CameraControl.cs`를 만든다. 메인·컷씬 가상 카메라를 만들고, 컷씬 카메라의 Priority를 메인보다 낮게 둔다. `Cinemachine Brain`은 Main Camera에 붙어 있어야 한다.
   - 확인 방법: 실행하면 컷씬 카메라 시점으로 부드럽게 전환되고, 지정 시간이 지나면 메인 카메라로 돌아온다.
8. `Register.cs`, `Unregister.cs`는 `nextInput` 칸만 있고 `IsOn = true`만 수행한다. `PlayerController`의 이벤트 등록 호출이 주석 처리되어 있다. 이 레포에는 `PlayerController`가 없으므로 따라 만들 필요가 없다.

## 막히기 쉬운 곳·한계

- `obj`, `target` 등 대상 칸을 비우면 null 참조 오류가 난다. `Destroy`, `MoveObject`, `RotateObject`는 일부 검사가 있지만 `Activate`, `Deactivate`, `ToggleActivate`에는 없다.
- 코드에는 `is null`, `is not null`로 유니티 오브젝트를 검사하는 부분이 여럿 있다(`Instance`, `MoveObject`, `RotateObject`, `CameraControl`). 유니티 오브젝트는 "빈 칸"이 일반 null과 다른 상태일 수 있어 이 검사가 빈 칸을 못 잡을 수 있다(unverified). 새 노드를 만들 때는 `== null` 또는 `!obj` 형태를 쓰는 편이 안전하다.
- `Instance`는 `IsOn`이 켜지면 다시 실행되지 않으므로 반복 생성은 못 한다. `count`가 2 이상일 때의 위치 지정은 코드 주석에 TODO로 남아 있고, 현재는 무작위 위치이므로 겹칠 수 있다.
- `MoveObject`는 월드 좌표를 사용하고 `IsOn`을 바꾸지 않아, 여러 번 부르면 이동이 겹친다. 또한 이 노드가 끝났는지 알려 주는 신호가 없어 "이동이 끝나면 다음 단계"는 `Timer`로 시간을 맞춰 구성해야 한다.
- `RotateObject`의 각도 범위는 -90~90이다. 180도 회전은 한 번에 못 하며, 노드를 두 개 쓰거나 코드를 고쳐야 한다. 시간이 0 이하이면 실행되지 않는다.
- `CameraControl`: 메인 카메라 칸이 비어 있을 때 `GameObject.Find("FollowCamera")`로 찾는 보조 코드가 있으나, `is not null` 검사 때문에 실제로 동작하는지 불확실하다(unverified). 항상 인스펙터에서 직접 지정한다. 컷씬 카메라 칸이 비면 오류 로그 후 건너뛰지만 마지막 복귀 반복문은 null 검사가 없어 오류가 날 수 있다. 페이드 모드(`FadeInNOut`)는 `GUIManager`와 페이드용 Image 패널이 씬에 있어야 한다. `FadeOut`과 `FadeIn`을 같은 프레임에 연달아 호출하는 구조라 의도한 페이드가 나오는지는 확인하지 못했다(unverified). 수업에서는 `CameraMove` 모드를 권한다.
- `PlayAnimation`/`AnimCheck`: `AnimCheck`는 매 프레임 `Update`에서 값을 쓰고, 상태 이름 `"Take 001"`이 코드에 고정되어 있어 Animator 구성에 제약이 크다.
- `Register`/`Unregister`는 호출해도 아무 변화가 없다. 기획자에게 사용을 안내하지 않는다.
- 프로젝트에 `Timer`, `Instance`, `Destroy`, `Logic`처럼 흔한 이름의 클래스가 있어 다른 라이브러리와 이름이 겹치면 모호성 오류가 날 수 있다(unverified).

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 출력 노드가 `if (IsOn) return;`으로 시작하는 이유를 내 말로 설명해 보자.
- [ ] Cinemachine의 우선순위(Priority)로 컷씬을 전환하는 방식이 어떻게 동작하는지 내 말로 정리해 보자.
- [ ] 출력 노드가 "끝났다"는 신호를 주지 않아 불편했던 기믹이 있었다면 어떤 것이었는지 적어 보자.
