# 모바일 입력과 게임패드

## 무엇을 하는가

- `MobileDragCamera`는 화면을 드래그한 거리로 Cinemachine 가상 카메라의 POV(시점)를 돌린다. 한 손가락만 카메라가 소유하고, UI 위 터치와 멀티터치는 걸러낸다.
- `PlayerActions.inputactions`(Input System 에셋)에는 `PC_Keyboard`, `Mobile` 두 컨트롤 스킴이 있고, 이 에셋에서 생성된 `PlayerActions.cs`가 `Move`, `Look` 등의 바인딩을 담는다. 게임패드 스틱 바인딩이 이 에셋에 추가됐다.
- `GameUIController.PlayVibration`/`StopVibration`이 게임패드 진동을 구동한다.

## 왜 이렇게 설계했나

### MobileDragCamera 재작성 (`785e68f7`, 2026-01-20, +332/-46)

이전 버전은 짧았다. 변경 전 로직을 diff로 읽으면 다음과 같다.

- `#if UNITY_EDITOR || UNITY_STANDALONE`에서는 아예 `return`해 PC에서는 동작하지 않았다.
- 새 터치가 시작될 때(`Began`)만 손가락을 잡았다.
- 회전은 `deltaInches * rotationSpeed * dt`였다. 터치 `delta`는 이미 "이전 프레임 이후 이동량"이라서 거기에 다시 `dt`를 곱하면 프레임레이트에 따라 감도가 달라진다.
- UI 위 터치를 걸러내는 처리가 없어 버튼을 누르다 카메라가 돌 수 있었다.

새 버전은 같은 목적을 이렇게 바꿨다(코드에서 읽은 내용).

- 인치 단위로 정규화(`Screen.dpi`, 값이 없으면 `dpiFallback`)해서 해상도·기기 차이를 줄인다.
- `Began`을 먼저, 없으면 `Moved/Stationary`인 터치를 차선으로 잡는다. 손가락이 UI에서 시작했다가 UI 밖으로 나온 경우도 이어서 쓰기 위해서다.
- 노치 등 안전영역(`Screen.safeArea`)을 고려한 "오른쪽 절반" 영역 옵션, 드래그 중 UI 진입/영역 이탈 시 해제 옵션, 멀티터치 시 해제 옵션을 인스펙터에서 켜고 끈다.
- Cinemachine이 같은 입력을 이중으로 받지 않게 `CinemachineInputProvider`를 끄고 POV 축의 입력 이름을 비운 뒤, 비활성/파괴 시 원래 값으로 복원한다.
- `dt`를 곱하지 않는 대신 데드존, 최대 이동량 클램프, 지수 스무딩을 넣었다.

### 게임패드 (`423a7400`, 2025-12-10)

커밋 메시지는 "Add support for gamepad controls". diff에서 확인되는 것은 다음이다.

- `PlayerActions.inputactions`와 생성 코드에 `<Gamepad>/leftStick`(액션 `Move`), `<Gamepad>/rightStick`(액션 `Look`) 바인딩이 추가됐다.
- 그룹은 `;Mobile;PC_Keyboard` 등으로 지정되어 별도 `Gamepad` 컨트롤 스킴은 만들지 않았다.
- 같은 날 `GameManager.EnterPrologue`가 `await DungeonManager.Instance.LoadAllStage()`를 쓰도록 바뀌었다(테스트용 전체 스테이지 로드).

이후 `79ca56c1`에서 Input System 버전 표기가 1.14.0에서 1.14.2로 바뀌며 `PlayerActions.cs`가 재생성됐다. 이 커밋 diff에는 위 두 스틱 바인딩이 삭제된 것으로 나오지만, 현재 `main`의 `PlayerActions.cs`에는 `<Gamepad>/leftStick` 항목이 남아 있다. 중간 이력은 확인하지 못했다. 확인 필요.

## 핵심 코드

{% code title="MobileDragCamera.cs (회전 부분)" %}
```csharp
Vector2 deltaInches = ComputeDeltaInches(currentTouch.delta);

if (deltaInches.sqrMagnitude < deadZoneInches * deadZoneInches) return;
deltaInches = Vector2.ClampMagnitude(deltaInches, maxDeltaInches);

float dt = Time.unscaledDeltaTime;
float alpha = (smoothingTime < 1e-4f) ? 1f : 1f - Mathf.Exp(-dt / Mathf.Max(1e-4f, smoothingTime));
_filteredDelta = Vector2.Lerp(_filteredDelta, deltaInches, alpha);

float yFactor = invertY ? 1f : -1f;
_pov.m_HorizontalAxis.Value += _filteredDelta.x * sensitivity;
_pov.m_VerticalAxis.Value   += _filteredDelta.y * sensitivity * yFactor;

private Vector2 ComputeDeltaInches(Vector2 pixelDelta)
{
    float dpi = Screen.dpi > 0f ? Screen.dpi : dpiFallback;
    return pixelDelta / dpi;
}
```
{% endcode %}

- 1줄: 픽셀 이동량을 DPI로 나눠 인치로 바꾼다. 어떤 폰이든 "손가락을 1인치 움직였다"가 같은 값이 된다.
- 3줄: 데드존보다 작은 움직임은 무시해 손 떨림을 없앤다.
- 4줄: 한 프레임에 너무 큰 값이 들어오는 스와이프 튐을 `maxDeltaInches`로 자른다.
- 6~8줄: 프레임레이트와 무관한 지수 스무딩이다. `Time.unscaledDeltaTime`을 써서 `Time.timeScale = 0`(일시정지)에서도 계산이 깨지지 않는다.
- 10~12줄: 수평은 더하고 수직은 기본이 반전(`-1`)이다. 화면에서 손가락을 아래로 끌면 위를 보는 일반 모바일 FPS 감각이다.

{% code title="MobileDragCamera.cs (UI 위 터치 판정)" %}
```csharp
private bool IsTouchOverUI(Touch t)
{
    if (EventSystem.current == null) return false;
    if (EventSystem.current.IsPointerOverGameObject(t.touchId)) return true;

    if (_pointerEventData == null || _cachedEventSystem != EventSystem.current)
    {
        _cachedEventSystem = EventSystem.current;
        _pointerEventData = new PointerEventData(_cachedEventSystem);
    }
    _pointerEventData.position = t.screenPosition;
    _raycastResults.Clear();
    EventSystem.current.RaycastAll(_pointerEventData, _raycastResults);
    return _raycastResults.Count > 0;
}
```
{% endcode %}

- 먼저 가벼운 `IsPointerOverGameObject(touchId)`로 판정하고, 아니라고 나오면 `RaycastAll`로 한 번 더 확인한다. 이는 터치 시작 프레임에 값이 늦게 갱신되는 경우를 위한 보조 확인이다(추론).
- `PointerEventData`와 결과 리스트를 `Awake`에서 한 번 만들어 재사용한다(GC 방지). `EventSystem`이 씬 전환으로 바뀌면 다시 만든다.
- 주의: `RaycastAll` 결과가 하나라도 있으면 UI로 본다. 투명한 `Image`가 화면을 덮으면 항상 "UI 위"가 되어 드래그가 안 된다. `Raycast Target`을 꺼야 한다.

{% code title="GameUIController.cs (진동)" %}
```csharp
public void PlayVibration(float lowFrequency, float highFrequency, float duration)
{
    if (Gamepad.current == null) return;
    if (_hapticCoroutine != null) StopCoroutine(_hapticCoroutine);

    lowFrequency = Mathf.Clamp01(lowFrequency);
    highFrequency = Mathf.Clamp01(highFrequency);
    _hapticCoroutine = StartCoroutine(CoVibrationRoutine(lowFrequency, highFrequency, duration));
}

private IEnumerator CoVibrationRoutine(float lowFreq, float highFreq, float duration)
{
    if (Gamepad.current == null) yield break;
    Gamepad.current.SetMotorSpeeds(lowFreq, highFreq);
    yield return new WaitForSecondsRealtime(duration);
    if (Gamepad.current != null) Gamepad.current.SetMotorSpeeds(0.0f, 0.0f);
    _hapticCoroutine = null;
}
```
{% endcode %}

- `Gamepad.current`가 `null`이면 아무것도 하지 않는다. 키보드 전용 플레이에서도 호출이 안전하다.
- 새 진동 요청이 오면 이전 타이머를 끊어, 끄는 코루틴이 새 진동을 도중에 끄는 일을 막는다.
- `WaitForSecondsRealtime`으로 일시정지 중에도 시간이 흘러 모터가 영원히 돌지 않게 한다.
- `StartHitCrosshair` 안의 `PlayVibration(0.02f, 0.3f, 0.06f)` 호출은 현재 주석 처리돼 있다.

## 따라 만들기 단계

1. Package Manager에서 Input System과 Cinemachine(2.x, `CinemachineVirtualCamera`)을 설치한다. Player Settings의 Active Input Handling을 `Input System Package`(또는 Both)로 둔다. 확인 방법: 재시작 후 `Window > Analysis > Input Debugger`가 열린다.
2. `Input Actions` 에셋을 만들고 `Move`(Vector2), `Look`(Vector2) 액션을 추가한다. 컨트롤 스킴은 `PC_Keyboard`, `Mobile`을 만든다. `Move`에 `<Gamepad>/leftStick`, `Look`에 `<Gamepad>/rightStick`을 바인딩한다. 확인 방법: 에셋 창에서 `Generate C# Class`로 생성하고 컴파일 오류가 없다.
3. 가상 카메라에 `CinemachinePOV`를 쓰도록 구성한다. 확인 방법: 에디터에서 POV의 수평/수직 축 값을 손으로 바꾸면 화면이 돈다.
4. `MobileDragCamera`를 가상 카메라에 붙이고 `OnEnable`에서 `EnhancedTouchSupport.Enable()`을 부른다. 에디터 테스트용으로 `TouchSimulation.Enable()`도 켠다. 확인 방법: 에디터에서 마우스로 드래그하면 시점이 회전한다.
5. 터치 한 개를 `Finger`로 소유(`TryAcquireFinger`)하고 매 프레임 `currentTouch.delta`를 인치로 변환해 POV에 더한다. 확인 방법: 감도와 데드존을 바꿔 가며 미세한 손 떨림에 시점이 흔들리지 않는지 본다.
6. `IsTouchOverUI`를 붙이고 버튼 위에서 드래그를 시작해 본다. 확인 방법: 버튼 위 터치로는 카메라가 돌지 않는다.
7. 게임패드를 연결하고 `PlayVibration(0.3f, 0.6f, 0.2f)`를 호출해 본다. 확인 방법: 패드가 0.2초 진동하고 멈춘다.

## 막히기 쉬운 곳과 한계

- `Screen.dpi`는 일부 기기와 에디터에서 `0`을 돌려준다. 그래서 `dpiFallback`이 필요하다.
- `EnhancedTouchSupport.Disable()`은 안전을 위해 주석 처리돼 있다. 다른 스크립트도 EnhancedTouch를 쓰면 한쪽이 꺼서 다른 쪽이 죽는 일을 피하려는 선택으로 보인다.
- 터치 기본값은 `useRightHalfOnly = false`다. 화면 왼쪽에 가상 조이스틱을 둘 구성이라면 인스펙터에서 켜야 한다. 프리팹 값은 확인하지 않았다.
- 코드 주석이 스스로 "수정됨"이라고 적은 부분(`EventSystem` 캐싱, `PointerEventData`)이 있어, 컴파일 오류를 한 차례 고친 흔적이다.
- 실기기 터치감은 확인하지 못했다(**unverified**). 감도 기본값 `15`가 기기별로 적절한지는 미검증이다.
- 이 영역 안에서 `PlayerController.cs`의 모바일·게임패드 관련 변경은 찾지 못했다. `79ca56c1`의 이 파일 변경은 `GUIManager` 호출 치환과 초기화 분리 위주다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 모바일에서 카메라를 돌릴 때 실제로 겪은 불편(UI 위 터치, 감도, 튐 등)은 무엇이었고, 어떤 옵션으로 해결했는가?
- [ ] 픽셀이 아니라 인치로 정규화하는 이유를 내 말로 설명해 보자.
- [ ] 게임패드와 터치를 한 입력 에셋에서 같이 다루게 되면서 헷갈린 점이 있었다면 적어 보자.
