# [생성형 AI] uGUI 기초: Canvas와 이벤트

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UNI-011-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | uGUI의 Canvas, RectTransform 앵커, Canvas Scaler, EventSystem과 버튼 이벤트 연결을 이해한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (Unity에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 1. 정의

uGUI는 Unity의 `Canvas` 기반 UI 시스템이다. UI 요소는 `Canvas` 아래 `RectTransform`을 가진 오브젝트로 만든다. 입력은 `EventSystem`이 받아 UI 요소에 전달한다. Unity에는 UI Toolkit도 있으며, 새 프로젝트에서는 둘 중 하나를 고른다. 선택 기준은 해당 버전의 공식 문서를 확인한다.

## 2. 구성 요소

| 요소 | 역할 |
|---|---|
| `Canvas` | UI를 그리는 루트. 모든 UI 오브젝트는 그 자식이다 |
| `Canvas Scaler` | 화면 해상도에 따라 UI 배율을 정한다 |
| `Graphic Raycaster` | 캔버스 위 UI 클릭을 판정한다 |
| `EventSystem` | 입력을 UI로 전달한다. 씬에 하나 필요하다 |
| `RectTransform` | 위치·크기를 앵커와 피벗으로 정하는 Transform |
| `Image`, `Button`, `Text` 계열 | 화면에 그리는 요소 |

### 2.1 Canvas Render Mode

| 모드 | 동작 | 쓰임새 |
|---|---|---|
| Screen Space - Overlay | 화면 위에 그린다. 카메라 무관 | 일반 HUD, 메뉴 |
| Screen Space - Camera | 지정 카메라 앞에 그린다 | 3D 효과·후처리를 UI에 적용 |
| World Space | 3D 공간의 평면으로 둔다 | 머리 위 체력 바, VR |

### 2.2 앵커와 Canvas Scaler

| 설정 | 의미 |
|---|---|
| 앵커 | 부모 사각형에서 기준이 되는 위치(점 또는 영역). 부모가 변하면 앵커를 따라 위치와 크기가 변한다 |
| 피벗 | 요소 자신의 기준점(회전과 크기 변화의 중심) |
| `UI Scale Mode = Scale With Screen Size` | 기준 해상도(Reference Resolution)에 맞춰 배율을 정한다. 일반적인 선택 |
| `Match` | 0이면 가로, 1이면 세로 기준으로 배율을 정한다 |

화면 모서리에 붙이는 요소는 해당 모서리 앵커를 쓰고, 중앙 요소는 중앙 앵커를 쓴다.

## 3. 동작 원리

### 3.1 만들기

1. 메뉴 `GameObject > UI`에서 요소(Button, Image 등)를 만든다. 캔버스가 없으면 `Canvas`와 `EventSystem`이 같이 만들어진다.
2. `Canvas`의 `Canvas Scaler`를 `Scale With Screen Size`로 바꾸고 기준 해상도를 정한다(예: 1920x1080).
3. 각 요소의 앵커를 배치 위치에 맞게 정한다.

씬 저장 전에 백업하거나 `Ctrl+Z`로 되돌린다.

{% hint style="info" %}
NOTE: 새 Input System만 활성화한 프로젝트에서는 `EventSystem`의 입력 모듈을 `Input System UI Input Module`로 바꿔야 클릭이 동작한다. Unity 버전별 자동 변환 버튼의 유무는 확인 필요.
{% endhint %}

### 3.2 버튼 이벤트 연결

```csharp
using UnityEngine;
using UnityEngine.UI;

public class StartMenu : MonoBehaviour
{
    [SerializeField] Button startButton;

    void OnEnable()  => startButton.onClick.AddListener(OnStart);
    void OnDisable() => startButton.onClick.RemoveListener(OnStart);

    void OnStart() => Debug.Log("Start clicked");
}
```

인스펙터의 `On Click ()`에 연결하는 방법도 있다. 코드로 연결할 때는 `OnDisable`에서 해제해 중복 호출을 막는다.

### 3.3 자주 겪는 문제

| 증상 | 확인할 것 |
|---|---|
| 버튼이 눌리지 않는다 | 씬에 `EventSystem`이 있는지, 위에 클릭을 가로채는 `Raycast Target`이 켜진 큰 이미지가 있는지 |
| 해상도를 바꾸면 UI가 깨진다 | 앵커와 `Canvas Scaler` 설정 |
| UI 갱신이 느리다 | 자주 바뀌는 요소를 별도 `Canvas`로 분리한다(Canvas가 바뀌면 다시 구성되기 때문). 프로파일러로 확인 |
| 텍스트 폰트 | TextMeshPro가 일반적이다. 한글 폰트는 별도 에셋 생성이 필요하다 |

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| Canvas | UI 요소의 루트 컴포넌트 |
| 앵커 | 부모 대비 위치 기준점 |
| EventSystem | 입력을 UI에 전달하는 오브젝트 |

## 5. 더 보기

* [새 Input System 기초](input-system.md)
* [Unity Manual: Unity UI](https://docs.unity3d.com/Manual/UISystem.html)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 앵커를 잘못 두었을 때 해상도에 따라 UI가 어떻게 보일지 자신의 말로 설명한다.
- [ ] 만들려는 게임의 HUD에 꼭 필요한 요소를 3개 쓴다.
