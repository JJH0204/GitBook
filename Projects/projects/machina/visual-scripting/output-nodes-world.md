# 월드·연출 출력 노드

## 무엇을 하는가

월드에 변화를 일으키는 출력 노드를 다룬다.

| 노드 | 하는 일 |
|---|---|
| `Instance` | 오브젝트 풀에서 프리팹을 꺼내 지정 범위 안 무작위 위치에 소환한다 |
| `CameraControl` | Cinemachine 가상 카메라를 순서대로 전환하는 컷씬을 재생한다 |
| `ExcutionerDummy` | 발걸음 이벤트에 맞춰 카메라를 흔든다 |
| `PlaySoundSimple` | 같은 오브젝트의 `AudioSource`를 재생한다 |
| `GetItem` | 플레이어 인벤토리에 파츠 아이템을 지급하고 UI를 해금한다 |

## 왜 이렇게 설계했나

- `Instance`는 `Instantiate` 대신 `PoolManager`를 쓴다. 전투 중 반복 소환 비용을 줄이기 위해서다. 소환 직후 `IsDestroy`, `IsDead`, `IsDisable` 입력 노드에 대상을 등록해 "소환된 적을 모두 처치하면 다음 단계로"를 만들 수 있다.
- `CameraControl`은 카메라 우선순위(Priority)만 바꾸고 이동은 Cinemachine의 블렌드에 맡긴다. 컷씬 동안 게임 오브젝트를 일시정지하고 HUD를 숨겼다가 끝난 뒤 복구한다.
- `ExcutionerDummy`는 `Execute()`가 아니라 `OneStepShake()`를 외부에서 호출받는 특이한 노드다. 발걸음 이벤트처럼 애니메이션/캐릭터 쪽 `UnityEvent`가 직접 호출하도록 하기 위해서다. 실제 프리팹에서 한 `UnityEvent`(`Event_OnStep`)가 이 메서드를 가리키는 것을 확인했다.

## 핵심 코드

{% code title="Instance.cs (발췌, 주석 일부 생략)" %}
```csharp
public override void Execute()
{
    if (IsOn) return;
    if (instancePrefab is null) { Debug.LogError("Instance prefab is not assigned."); return; }

    for (int i = 0; i < count; i++)
    {
        float x = Random.Range(-spawnArea.x / 2, spawnArea.x / 2);
        float y = Random.Range(-spawnArea.y / 2, spawnArea.y / 2);
        float z = Random.Range(-spawnArea.z / 2, spawnArea.z / 2);
        Vector3 pos = transform.position + new Vector3(x, y, z);

        GameObject obj = PoolManager.Instance.GetObject(instancePrefab);
        if (obj is null) continue;

        if (obj.CompareTag("Enemy")) MonsterManager.Instance.AddMonster(obj);

        NavMeshAgent agent = obj.GetComponentInChildren<NavMeshAgent>();
        if (agent is not null) agent.Warp(pos);
        else obj.transform.position = pos;

        destroyTrigger?.AddObject(obj.GetComponent<GlobalGameObject>());
        disableTrigger?.AddObject(obj.GetComponent<GlobalGameObject>());
        deadTrigger?.AddObject(obj.GetComponent<DamagableObject>());
    }
    IsOn = true;
}
```
{% endcode %}

- `spawnArea`는 상자 크기다. 각 축을 절반씩 나눠 노드 위치 중심의 무작위 오프셋을 만든다. `OnDrawGizmosSelected`가 이 상자를 빨간 와이어로 그려 준다.
- `PoolManager.GetObject`가 오브젝트를 돌려주면, `Enemy` 태그일 때 `MonsterManager`에 등록한다.
- `NavMeshAgent`가 있으면 `transform.position`을 바꾸지 않고 `Warp`로 옮긴다. 에이전트는 직접 위치를 바꾸면 내비게이션 상태가 어긋날 수 있기 때문이다.
- `destroyTrigger?.AddObject(...)`처럼 `?.`로 입력 노드가 비어 있어도 동작한다. 단, `GetComponent`가 `null`을 돌려주면 `AddObject(null)`이 호출되어 입력 노드 쪽에서 문제가 될 수 있다. (코드 읽기, unverified)

{% code title="ExcutionerDummy.cs (발췌)" %}
```csharp
public void OneStepShake()
{
    objectToShake = GameManager.Instance.FollowCamera.gameObject;

    FollowCameraController followCamera = objectToShake.GetComponent<FollowCameraController>();
    impulseSource = GetComponent<CinemachineImpulseSource>();

    if (followCamera != null && impulseSource != null)
    {
        followCamera.ApplyShake(impulseSource, shakeMagnitude * 50.0f);
        return;
    }

    if (!repeat)
        objectToShake.transform.DOShakePosition(shakeDuration, shakeMagnitude)
            .OnComplete(() => { IsOn = false; });
    else
        objectToShake.transform.DOShakePosition(shakeDuration, shakeMagnitude).SetLoops(-1);
}
```
{% endcode %}

- 흔들 대상은 `GameManager.Instance.FollowCamera`다. 이전에는 인스펙터에서 `objectToShake`가 비어 있으면 그냥 반환했다. 커밋 `bc23a743`은 이를 "비어 있으면 게임 매니저의 따라가기 카메라를 자동으로 쓴다"로 바꿨다. 지금 main의 코드는 값을 항상 덮어쓰는 형태다. (두 버전의 차이는 diff와 현재 파일을 비교한 결과다.)
- 카메라에 `FollowCameraController`(프로젝트 자체 클래스)가 있고 같은 오브젝트에 `CinemachineImpulseSource`가 있으면, Impulse 방식으로 흔들고 끝낸다. 진폭은 `shakeMagnitude * 50`으로 키운다.
- 둘 중 하나가 없으면 DOTween의 `DOShakePosition`으로 폴백한다. 반복이 꺼져 있으면 끝났을 때 `IsOn`을 `false`로, 켜져 있으면 무한 루프를 건다.
- `Execute()`는 비어 있다. 이 노드는 `Conditional`이 아니라 `UnityEvent`로 호출하는 쓰임이 실제 사용처다.

{% code title="CameraControl.cs (SwitchToCutscene 발췌)" %}
```csharp
public override void Execute()
{
    if (IsOn) return;
    BlendToCutscene();
    StartCoroutine(SwitchToCutscene());
    IsOn = true;
}

private IEnumerator SwitchToCutscene()
{
    int originalPriority = mainVirtualCamera.Priority;
    GameManager.Instance.PauseObjects();
    GUIManager.Instance.GameUIController.SetIndicator(false);
    GUIManager.Instance.GameUIController.HUD.SetActive(false);

    for (int i = 0; i < cutsceneData.Length; i++)
    {
        var cutscene = cutsceneData[i];
        if (cutscene.cutsceneVirtualCamera is null) continue;
        cutscene.cutsceneVirtualCamera.Priority = originalPriority + 1 + i;
        yield return new WaitForSeconds(cutscene.cutsceneDuration);
    }

    foreach (var cutscene in cutsceneData)
        cutscene.cutsceneVirtualCamera.Priority = originalPriority - 1;
    StartCoroutine(CoCheckBlendCamera());
}
```
{% endcode %}

- `Execute`는 블렌드 방식을 정한 뒤 코루틴을 시작하고 즉시 `IsOn`을 켠다. 컷씬이 끝나기 전에 이미 켜져 있다.
- 컷씬 카메라의 `Priority`를 메인 카메라보다 높이면 Cinemachine이 그 카메라로 전환한다. `i`를 더해 순서대로 우선순위를 높이므로 배열 순서가 컷 순서가 된다.
- 끝나면 모든 컷씬 카메라의 우선순위를 낮춰 메인 카메라로 돌아가게 한다. 이후 `CoCheckBlendCamera`가 `CinemachineBrain.IsBlending`이 끝날 때까지 기다렸다가 HUD를 켜고 일시정지를 푼다.
- `BlendToCutscene`은 `CutsceneMode.FadeInNOut`이면 `Cut`, `CameraMove`면 `EaseInOut` 블렌드를 `CinemachineBrain.m_DefaultBlend`에 지정한다. (페이드 연출 자체는 UI 컨트롤러의 `FadeIn/FadeOut` 호출이 담당한다.)

`PlaySoundSimple`은 `Start`에서 `AudioSource`를 찾고 `audioClip`이 있으면 지정한다. `Execute`는 `isLoop`가 꺼져 있고 이미 실행됐다면 반환하고, 아니면 `Play()`한다. 반복 모드에서는 `IsOn`을 올리지 않으므로 여러 번 재생된다. `GetItem`은 `Update`에서 플레이어가 준비될 때까지 기다렸다가 파츠 이름 목록으로 인벤토리 파츠를 조회해 두고, `Execute`에서 `Inven.GetItem`으로 지급한 뒤 `unlockIndex`가 있으면 UI의 파츠 슬롯을 해금한다.

## 따라 만들기

1. 오브젝트 풀을 간단히 만든다(`GetObject(prefab)`가 비활성 오브젝트를 재사용하거나 새로 만든다). 풀 구현이 없다면 `Instantiate`로 대체해도 된다.
   - 확인 방법: `GetObject`를 두 번 호출하면 서로 다른 오브젝트가 반환된다.
2. `Instance`를 작성한다. 확인 방법: 노드 선택 시 씬 뷰에 빨간 상자가 보이고, `Execute` 후 상자 안 무작위 위치에 `count`만큼 소환된다.
3. `GlobalGameObject`와 `IsDestroy`([입력 노드](input-nodes.md))를 연결한다. 확인 방법: 소환된 오브젝트를 전부 지우면 `IsDestroy`가 켜진다.
4. Cinemachine 2.x 패키지를 설치하고 메인 카메라에 `CinemachineBrain`, 가상 카메라 2개를 만든다. `CameraControl`을 작성하고 `cutsceneData`에 두 번째 가상 카메라와 시간을 넣는다.
   - 확인 방법: 실행하면 설정한 시간 동안 컷씬 카메라 시점으로 가고, 이후 메인 카메라로 부드럽게 돌아온다.
5. `ExcutionerDummy`를 작성한다. 프로젝트 자체 `FollowCameraController` 부분을 빼고 DOTween 폴백만 먼저 만든다. 애니메이션 이벤트나 `UnityEvent`에서 `OneStepShake`를 연결한다.
   - 확인 방법: 이벤트가 불릴 때 카메라가 `shakeDuration` 동안 흔들린다.

## 막히기 쉬운 곳과 한계

- `CameraControl`은 `Awake`에서 `Camera.main.GetComponent<CinemachineBrain>()`를 호출하고, `Update`에서 `GameManager.FollowCamera`가 준비될 때까지 기다린다. 원본 주석도 이 방식이 안전한지 의문을 남기고 있다. 준비 전에 `Execute`가 호출되면 `mainVirtualCamera`가 비어 있을 수 있다.
- `SwitchToCutscene`의 페이드 모드에서 `FadeOut`과 `FadeIn`이 같은 프레임에 연속 호출된다. 의도한 연출 타이밍인지는 확인하지 못했다.
- `CoCheckBlendCamera`는 우선순위를 되돌린 직후 `IsBlending`을 읽는다. 블렌드가 시작되기 전 프레임이면 곧바로 끝나 HUD가 일찍 켜질 수 있다. (코드 읽기, unverified)
- `ExcutionerDummy`의 클래스 이름은 `ExcutionerDumy`이고 파일 이름은 `ExcutionerDummy.cs`다. 따라 만들 때는 클래스와 파일 이름을 반드시 일치시킨다. Unity 에디터에서 컴포넌트로 붙이려면 일치해야 한다.
- `Execute()`가 비어 있는 노드는 `Conditional`로 연결해도 아무 일도 일어나지 않는다. 호출 경로를 `UnityEvent`로 따로 두었음을 기억한다.
- `Instance`의 `GetComponent` 결과가 `null`이면 `AddObject(null)`이 입력 노드로 전달된다.
- `GetItem`의 `Execute`는 `IsOn`을 올리지 않아 여러 번 호출하면 아이템이 반복 지급될 수 있다. (코드 읽기, unverified)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 카메라 컷씬을 위치 보간이 아니라 Cinemachine의 `Priority` 변경으로 구현한 방식의 장점을 내 말로 설명해 보자.
- [ ] `NavMeshAgent`가 있는 오브젝트에 `Warp`를 써야 하는 이유를 직접 확인해 본 적이 있는가? 있다면 어떤 현상이었는지 적어 보자.
- [ ] `Execute()`가 아닌 `UnityEvent`로 호출되는 노드를 같은 체계에 섞어 두었을 때 생기는 혼란을 하나 적어 보자.
