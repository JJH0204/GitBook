# GOS 해체 분석: 코드 없이 기믹을 만드는 노드 시스템

GOS(Game Object Scripting)는 유니티 게임 오브젝트를 "노드"처럼 사용해 기믹을 만드는 에디터 플러그인 형태의 프로젝트다. 기획자가 코드를 쓰지 않고 Hierarchy에서 오브젝트를 만들고 인스펙터 칸에 서로를 끌어다 놓는 것만으로 "트리거에 들어가면 문이 열린다" 같은 동작을 만든다.

{% hint style="info" %}
이 문서는 `JJH0204/GOS`(원본)를 해체한 것이다. 이 레포를 포크해 개선한 버전이 있고(Unity 6 이전, 디버거, 노드 추가 등), 변경점은 별도 문서 [포크 개선판](../gos-lifeis/README.md)에 정리한다.
{% endhint %}

{% hint style="info" %}
팀 프로젝트(Machina)에서는 이 체계를 가져다 써서 UI·연출 노드를 더했다. 그 노드들은 [비주얼 스크립팅 노드 체계](../machina/visual-scripting/README.md)에 정리했다.
{% endhint %}

{% hint style="success" %}
GOS는 다른 강사가 실제 수업에서 사용하고 있다. 아래 수업용 문서(`lesson-plan.md` 등)는 그 수업을 대신하는 것이 아니라, 이 도구를 가르칠 때 참고할 수 있게 정리한 제안이다. 실제 수업 진행 방식은 담당 강사가 정한다.
{% endhint %}

{% hint style="warning" %}
이 문서의 모든 동작 설명은 소스 코드를 읽고 판단한 것이며, Unity 에디터에서 실행해 확인하지 않았다(unverified). 수업이나 따라 만들기 전에 직접 한 번 실행해 확인한다.
{% endhint %}

## 이 문서의 구성

개발자용(해체·따라 만들기)과 기획자용(사용법·수업)으로 나뉜다.

| 대상 | 페이지 | 내용 |
|---|---|---|
| 개발자 | [process-base.md](process-base.md) | 모든 노드의 부모 클래스와 노드 연결 방식 |
| 개발자 | [editor-menu.md](editor-menu.md) | Hierarchy 우클릭 메뉴로 노드 오브젝트를 만드는 에디터 확장 |
| 개발자 | [input-nodes.md](input-nodes.md) | Trigger, Timer, IsDestroy 등 입력 노드 |
| 개발자 | [logic-nodes.md](logic-nodes.md) | Conditional, Logic, Loop 처리 노드 |
| 개발자 | [output-nodes.md](output-nodes.md) | 활성화, 생성, 파괴, 이동, 회전, 애니메이션, 컷씬 출력 노드 |
| 개발자 | [build-your-own.md](build-your-own.md) | 새 노드를 추가하는 방법 따라 만들기 |
| 기획자·수업 | [guide-for-designers.md](guide-for-designers.md) | 코드 없이 쓰는 법, 설치 방법 |
| 기획자·수업 | [examples.md](examples.md) | 노드 조합 예제 5개 |
| 기획자·수업 | [lesson-plan.md](lesson-plan.md) | 강사용 수업 진행안 |

## 한눈에 보는 구조

GOS의 노드는 전부 `ProcessBase`를 상속한 MonoBehaviour이며, 노드 하나가 게임 오브젝트 하나(컴포넌트 하나)에 대응한다. 노드는 두 가지 방식으로 서로 이어진다.

```
 입력 (조건을 감지)        처리 (판단·연결)               출력 (결과 행동)

 TriggerEnter  ─┐
 Timer         ─┤  IsOn(켜짐/꺼짐)   Conditional ─ Execute() ─▶ Activate
 IsDestroy     ─┼───── 읽기 ─────▶  Logic(And/Or)            ─▶ MoveObject
 OnEvent       ─┘  (ProcessData)     (IsOn을 다시 제공)         ─▶ RotateObject
                                                              ─▶ CameraControl
                                                              ─▶ Instance / Destroy ...

 연결 방식 A (읽기): 처리 노드가 다른 노드의 IsOn 값을 매 프레임 읽는다.
 연결 방식 B (호출): 처리 노드가 출력 노드의 Execute()를 호출한다.
```

핵심은 `ProcessBase`가 가진 두 가지다.

- `IsOn` : 이 노드가 지금 "켜진 상태"인지 나타내는 bool. 입력 노드는 조건이 만족되면 켜고, 출력 노드는 한 번 실행하면 켠다.
- `Execute()` : 이 노드가 해야 할 일을 하라는 호출 신호. 출력 노드의 본체이며, 이를 부르는 것은 주로 `Conditional`(및 Loop)이다.

`Conditional`은 "입력 노드 하나가 켜지면(IsOn이 true가 되는 순간) 출력 노드 목록의 `Execute()`를 한 번 부른다". 즉 입력과 출력을 잇는 전선 역할을 한다.

## 읽는 순서

1. [process-base.md](process-base.md): 두 약속(`IsOn`, `Execute`)을 먼저 이해한다.
2. [input-nodes.md](input-nodes.md) → [logic-nodes.md](logic-nodes.md) → [output-nodes.md](output-nodes.md): 데이터가 흐르는 순서대로 읽는다.
3. [editor-menu.md](editor-menu.md): 노드를 편하게 만드는 메뉴를 본다.
4. [build-your-own.md](build-your-own.md): 직접 노드를 하나 추가한다.

기획자는 [guide-for-designers.md](guide-for-designers.md)부터 읽고 [examples.md](examples.md)를 따라 한다.

## 환경과 의존성

| 항목 | 값 | 출처 |
|---|---|---|
| Unity 버전 | 2022.3.62f1 (레포가 사용한 버전) | `ProjectSettings/ProjectVersion.txt` |
| Cinemachine | 2.10.4 (`Cinemachine` 네임스페이스) | `Packages/manifest.json`, `CameraControl.cs` |
| TextMeshPro | 3.0.7 (`GUIManager`가 사용) | `Packages/manifest.json` |
| 외부 에셋 | Cinematic Explosions FREE 등 (예제 씬용, 핵심 아님) | `Assets/Mirza Beig` |

`CameraControl.cs`가 Cinemachine에 의존하므로, Cinemachine 없이 스크립트 폴더를 통째로 복사하면 컴파일 오류가 난다. 해결 방법은 [guide-for-designers.md](guide-for-designers.md)에 적었다.

## 파일 표

경로는 `Assets/Scripts/` 기준이다. 줄 수는 가져온 시점의 값이다.

| 파일 | 줄 | 역할 |
|---|---|---|
| `VisualScripting/ProcessBase.cs` | 24 | 모든 노드의 부모. `IsOn`, `Execute()` |
| `VisualScripting/ProcessData.cs` | 10 | 다른 노드 참조 + NOT 체크 |
| `VisualScripting/GlobalGameObject.cs` | 14 | 파괴 시 이벤트를 알리는 표식 컴포넌트 |
| `VisualScripting/Editor/VisualScriptingEditor.cs` | 284 | Hierarchy 우클릭 메뉴 |
| `VisualScripting/Input/OnEvent.cs` | 14 | `Execute()`가 불리면 켜지는 입력 |
| `VisualScripting/Input/Timer.cs` | 22 | 지정 시간 뒤 켜지는 입력 |
| `VisualScripting/Input/IsDestroy.cs` | 52 | 대상 오브젝트가 파괴되면 켜지는 입력 |
| `VisualScripting/Input/Trigger/Trigger.cs` | 32 | 트리거 안에 있는 동안 켜짐(Stay) |
| `VisualScripting/Input/Trigger/TriggerEnter.cs` | 34 | 트리거 진입 감지 |
| `VisualScripting/Input/Trigger/TriggerExit.cs` | 35 | 트리거 탈출 감지 |
| `VisualScripting/Logic/Conditional.cs` | 38 | 입력이 켜지면 출력 목록 실행 |
| `VisualScripting/Logic/Logic.cs` | 39 | 두 입력의 And/Or |
| `VisualScripting/Logic/Loop/ForLoop.cs` | 52 | 반복 실행(미완) |
| `VisualScripting/Logic/Loop/WhileLoop.cs` | 40 | 입력이 켜진 동안 반복(미완) |
| `VisualScripting/Output/SetActivate/*.cs` | 16~20 | Activate, Deactivate, ToggleActivate |
| `VisualScripting/Output/Instance.cs` | 57 | 프리팹 생성 |
| `VisualScripting/Output/Destroy.cs` | 15 | 오브젝트 파괴 |
| `VisualScripting/Output/MoveObject.cs` | 67 | 경유점 이동 |
| `VisualScripting/Output/RotateObject.cs` | 71 | 회전 |
| `VisualScripting/Output/PlayAnimation.cs` | 28 | `AnimCheck`를 통한 애니메이션 재생 |
| `VisualScripting/Output/CameraControl.cs` | 110 | Cinemachine 컷씬 |
| `VisualScripting/Output/Interaction/Register.cs`, `Unregister.cs` | 16 | 상호작용 등록/해제(본체 주석 처리됨) |
| `AnimCheck.cs` | 50 | 애니메이션 상태를 바꾸는 보조 컴포넌트 |
| `GUIManager.cs`, `ManagerBase.cs` | 121, 23 | 페이드 UI, 싱글톤 베이스 |

## 변경 이력으로 본 성장 과정

레포는 2025년 8월에 시작해 2026년 1월까지 총 9개 커밋으로 이루어진다.

1. 2025-08: 기본 구조(`ProcessBase`, Trigger 계열, `Conditional`, `Logic`, `Activate` 계열, `Instance`, `MoveObject`, `CameraControl`)가 올라간다. 이후 `Destroy`, `TriggerEnter/Exit` 개선, `ToggleActivate` 수정이 추가된다.
2. 2026-01: "새 출력 액션과 카메라 컷씬 지원" 커밋에서 `Register`, `Unregister`, `PlayAnimation`, `RotateObject`, `OnEvent`, `AnimCheck`가 추가되고, `CameraControl`이 카메라 한 대 컷씬에서 여러 대를 순서대로 재생하는 `CinemachineCutsceneData[]` 구조로 바뀐다. 같은 커밋에서 에디터 메뉴에도 해당 항목이 들어간다.

## 확인 필요

README와 코드가 다른 부분이다. 이 문서는 코드를 기준으로 썼다.

- README의 지원 목록에 `RotateObject`, `PlayAnimation`, `Register`, `Unregister`, `OnEvent`가 없지만 코드에는 있다.
- README는 `IsDestroy`를 입력으로 분류하지만, 에디터 메뉴에서는 `Process/IsDestroy` 아래에 있다. `Logic`은 메뉴에서 `Process/LogicalOperation`이고, `CameraControl`은 `Output/Cutscene`이다.
- README의 `Destroy`, `Loop`은 메뉴 항목이 없다. 컴포넌트를 직접 붙여야 한다.
- `Register`/`Unregister`는 실제 동작 코드가 주석 처리되어 있어 호출해도 `IsOn`만 켜진다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 입력·처리·출력 세 단계로 나눈 설계가 기획자에게 왜 이해하기 쉬운지 내 말로 설명해 보자.
- [ ] `IsOn`(읽기)과 `Execute()`(호출)가 각각 어떤 상황에서 쓰이는지 한 가지씩 예를 들어 보자.
- [ ] 이 도구를 만들면서 가장 어려웠던 설계 결정이 무엇이었는지 적어 보자.
