# [생성형 AI] 새 Input System 기초

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UNI-007-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | 기존 Input Manager와 새 Input System 패키지의 차이, 액션 기반 입력의 구조를 이해한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (Unity에서 실행하지 않았다. 패키지 버전 확인 필요) |
| 개정 | R1 (2026-11-19) |

## 1. 정의

Unity에는 입력 API가 두 가지 있다.

| 구분 | 기존 Input Manager | 새 Input System |
|---|---|---|
| 클래스 | `UnityEngine.Input` (`Input.GetAxis`, `Input.GetKeyDown`) | 패키지 `com.unity.inputsystem`, 네임스페이스 `UnityEngine.InputSystem` |
| 설정 | `Edit > Project Settings > Input Manager` | Input Actions 에셋 |
| 방식 | 축 이름 문자열을 직접 읽는다 | 동작(Action)을 정의하고 장치별 바인딩(Binding)을 연결한다 |
| 장치 | 키보드, 마우스, 일부 컨트롤러 | 키보드, 마우스, 게임패드, 터치 등을 같은 액션에 연결한다 |

`Edit > Project Settings > Player > Other Settings > Active Input Handling`에서 `Input Manager (Old)`, `Input System Package (New)`, `Both`를 고른다. 값을 바꾸면 에디터 재시작을 요구한다. [유니티 (Unity) 그룹](README.md)의 코드 예제는 기존 Input Manager 기준이므로 새 방식만 켜면 그 예제는 동작하지 않는다.

## 2. 구성 요소

| 용어 | 설명 |
|---|---|
| Input Actions 에셋 | `.inputactions` 파일. 액션 맵과 액션, 바인딩을 저장한다 |
| Action Map | 액션 묶음(예: Player, UI) |
| Action | 게임 동작(Move, Jump, Fire). 값 타입이 있다(버튼, `Vector2` 등) |
| Binding | 액션과 실제 키·버튼의 연결(`<Keyboard>/space`, `<Gamepad>/buttonSouth`) |
| Composite | 여러 키를 하나의 값으로 합친다(`2DVector`: W, A, S, D → `Vector2`) |
| `PlayerInput` | 에셋을 오브젝트에 연결하는 컴포넌트. 입력을 메시지나 이벤트로 전달한다 |

## 3. 동작 원리

### 3.1 코드에서 직접 액션 만들기

에셋 없이 코드로 액션을 정의하는 최소 예제다.

```csharp
using UnityEngine;
using UnityEngine.InputSystem;

public class SimpleMove : MonoBehaviour
{
    InputAction move;
    InputAction jump;

    void Awake()
    {
        move = new InputAction("Move", InputActionType.Value);
        move.AddCompositeBinding("2DVector")
            .With("Up", "<Keyboard>/w")
            .With("Down", "<Keyboard>/s")
            .With("Left", "<Keyboard>/a")
            .With("Right", "<Keyboard>/d");
        move.AddBinding("<Gamepad>/leftStick");

        jump = new InputAction("Jump", InputActionType.Button, "<Keyboard>/space");
    }

    void OnEnable()  { move.Enable();  jump.Enable(); }
    void OnDisable() { move.Disable(); jump.Disable(); }

    void Update()
    {
        Vector2 v = move.ReadValue<Vector2>();
        transform.position += new Vector3(v.x, 0f, v.y) * (5f * Time.deltaTime);

        if (jump.WasPressedThisFrame())
            Debug.Log("Jump");
    }
}
```

{% hint style="warning" %}
CAUTION: 액션은 `Enable()`을 호출해야 값을 읽을 수 있다. `OnEnable`에서 켜고 `OnDisable`에서 끈다. 켜지 않으면 `ReadValue`는 기본값(0)을 돌려준다.
{% endhint %}

### 3.2 읽는 방식 세 가지

| 방식 | 코드 | 쓰임 |
|---|---|---|
| 폴링(Polling) | `action.ReadValue<T>()`, `action.WasPressedThisFrame()` | `Update`에서 매 프레임 확인 |
| 콜백 | `action.performed += ctx => ...` | 한 번 발생하는 이벤트. 해제도 직접 한다 (`-=`) |
| `PlayerInput` 컴포넌트 | `Behavior`를 `Send Messages`로 두면 `OnMove(InputValue value)` 호출 | Inspector 설정 중심 |

`WasPressedThisFrame` 같은 메서드의 제공 여부는 패키지 버전에 따라 다르다. 사용하는 버전의 문서를 확인한다.

### 3.3 장치를 직접 읽기

액션을 쓰지 않고 장치 객체를 바로 읽는 방법도 있다. 프로토타입에는 짧고 편하지만 키 변경과 컨트롤러 지원이 어려워진다.

```csharp
if (Keyboard.current != null && Keyboard.current.spaceKey.wasPressedThisFrame) { /* ... */ }
Vector2 mousePos = Mouse.current.position.ReadValue();
```

장치가 연결되지 않으면 `current`가 `null`이므로 널 검사를 한다.

### 3.4 기존 Input Manager와 대응

| 기존 | 새 방식 |
|---|---|
| `Input.GetAxis("Horizontal")` | Move 액션의 `ReadValue<Vector2>().x` |
| `Input.GetButtonDown("Jump")` | Jump 액션의 `WasPressedThisFrame()` |
| `Input.mousePosition` | `Mouse.current.position.ReadValue()` |

{% hint style="info" %}
NOTE: 패키지 설치는 `Window > Package Manager`에서 한다. 설치 직후 Unity가 활성 입력 처리 방식 변경을 묻는 창을 띄울 수 있다. 되돌리려면 `Active Input Handling`을 원래 값으로 바꾸고 에디터를 재시작한다. 버전 확인 필요.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| Action | 게임 동작 단위 입력 |
| Binding | 액션과 장치 컨트롤의 연결 |
| Polling | 매 프레임 직접 값을 확인하는 방식 |

## 5. 더 보기

* [캐릭터 컨트롤러 이동 구현](charactercontroller.md), [리지드바디 캐릭터 이동 구현](rigidbody.md): 기존 입력 방식 예제
* [Unity Input System 매뉴얼](https://docs.unity3d.com/Packages/com.unity.inputsystem@latest)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 키 입력을 코드에 직접 쓰지 않고 액션으로 한 번 더 감싸면 어떤 점이 좋은지 자신의 말로 쓴다.
- [ ] 자신의 게임이 지원해야 할 입력 장치를 쓰고, 그 이유를 적는다.
