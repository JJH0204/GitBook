# 기획자 가이드: 코드 없이 기믹 만들기

## GOS란

GOS(Game Object Scripting)는 유니티 에디터에서 코드를 쓰지 않고 기믹을 만드는 도구다. 기능이 들어 있는 빈 오브젝트(노드)를 Hierarchy에서 만들고, 노드끼리 인스펙터 칸으로 연결한다.

{% hint style="warning" %}
이 문서는 소스 코드를 읽고 쓴 것이며 유니티에서 직접 실행해 확인하지 않았다(unverified). 수업 전에 [examples.md](examples.md)를 한 번 따라 해 본다.
{% endhint %}

## 세 가지 노드 종류

기믹은 "언제(입력) → 판단(처리) → 무엇을 한다(출력)"로 나뉜다.

```
 입력(언제)                  처리(판단·연결)            출력(무엇을)
 트리거에 들어왔을 때  ─▶   Conditional(연결)   ─▶   문 열기, 오브젝트 켜기, 컷씬 ...
 3초가 지났을 때
 오브젝트가 사라졌을 때     Logic(그리고/또는)
```

## 노드를 기획 용어로 보기

| 노드 | 기획 용어 | 설정할 것 |
|---|---|---|
| `Trigger`, `TriggerEnter` | 구역 안에 있음, 구역 진입 | `Selected Tag`: 감지할 대상의 태그(예: Player) |
| `TriggerExit` | 구역 이탈 | 위와 같음 |
| `Timer` | 시간 지연 | `Seconds`: 기다릴 시간(초). 시작은 다른 노드가 시켜 줘야 함 |
| `IsDestroy` | 대상이 사라졌을 때 | `Cach`: 감시할 오브젝트(`GlobalGameObject`가 붙은 것) |
| `OnEvent` | 수동 신호 | 없음 |
| `Conditional` | "~하면 ~한다" 연결선 | `Input Data`: 조건, `Output Data`: 실행할 것들 |
| `Logic` | 그리고(And) / 또는(Or) | 두 조건과 연산 종류 |
| `Activate`, `Deactivate`, `ToggleActivate` | 켜기, 끄기, 뒤집기 | `Obj`: 대상 오브젝트 |
| `Instance` | 생성(스폰) | 프리팹, 수량, 생성 범위, 감시용 `IsDestroy` |
| `Destroy` | 제거 | `Target` |
| `MoveObject` | 이동(경유점 순서대로) | 대상, 목적지 목록과 각 구간 시간 |
| `RotateObject` | 회전 | 대상, 각도(-90~90), 축, 시간, 한 번만 여부 |
| `PlayAnimation` | 애니메이션 재생 | `AnimCheck`가 붙은 오브젝트 목록 |
| `CameraControl` | 컷씬(카메라 연출) | 메인 카메라, 컷씬 카메라와 시간, Brain, 방식 |

## 설치 방법

1. Unity 2022.3 LTS로 3D 프로젝트를 새로 만든다(GOS는 2022.3.62f1로 만들어졌다. 다른 버전은 확인하지 못했다).
2. Package Manager에서 `Cinemachine`을 설치한다. 버전은 2.10.x를 쓴다(레포는 2.10.4). 3.x는 스크립트가 호환되지 않을 수 있다(unverified).
3. GOS 레포의 `Assets/Scripts` 폴더를 프로젝트의 `Assets` 아래로 복사한다. `VisualScripting`, `AnimCheck.cs`, `GUIManager.cs`, `ManagerBase.cs`가 들어 있다.
4. `GUIManager.cs`는 TextMeshPro를 쓰므로, 처음 열면 TMP Essentials 가져오기 창이 뜰 수 있다. 가져온다.
5. 콘솔에 컴파일 오류가 없는지 본다. Cinemachine을 설치하지 않을 거라면 `Output/CameraControl.cs`를 지워야 오류가 없어진다.
6. Hierarchy를 우클릭해 `VisualScripting` 메뉴가 보이면 설치가 끝난 것이다.

## 기본 사용법

1. Hierarchy에서 정리용 빈 오브젝트(예: `GOS`)를 만들고, 그 아래에 노드를 만든다. 노드가 꺼진 오브젝트 아래에 있으면 동작하지 않기 때문이다.
2. 우클릭 > VisualScripting > Input/Process/Output에서 노드를 만든다.
3. `Conditional`을 만들어 `Input Data`에 입력 노드를 끌어다 놓는다.
4. `Output Data`의 `+`를 눌러 칸을 늘리고 출력 노드를 끌어다 놓는다.
5. 각 노드의 설정(태그, 대상 오브젝트, 시간)을 채운다.
6. Play를 눌러 확인한다.

연결 칸 옆의 `Is Not`을 체크하면 조건이 반대가 된다(예: "구역 밖에 있을 때").

## 확인하고 디버깅하는 법

- 모든 노드의 인스펙터에 `Is On` 체크박스가 있다. 실행 중 켜졌는지 바로 볼 수 있다.
- 트리거 노드는 Scene 창에 파란 상자로 영역이 보인다. 크기는 Transform의 Scale로 조절한다.
- `Instance` 노드를 선택하면 빨간 상자로 생성 범위가 보인다.
- 콘솔의 빨간 오류가 `NullReferenceException`이면 비어 있는 연결 칸이 있다는 뜻이다.

## 알아 둘 점(한계)

- 트리거가 반응하려면 감지될 대상(예: Player)에 Rigidbody가 있어야 하고, 태그가 설정되어 있어야 한다.
- `Conditional`은 조건이 "켜지는 순간" 한 번 실행한다. 조건이 계속 켜져 있다고 반복 실행하지 않는다.
- 출력 노드 중 `Instance`, `PlayAnimation`, `CameraControl`은 한 번 실행하면 다시 실행되지 않는다.
- `Timer`는 `Conditional`이 시작시켜 줘야 동작하고, 한 번 끝나면 다시 쓸 수 없다.
- `IsDestroy`에 오브젝트를 여러 개 등록하면 모두 사라질 때까지 기다리지 않고 첫 번째에서 켜질 수 있다(unverified). 한 개만 등록하는 것이 안전하다.
- `Loop`, `Register`, `Unregister`는 완성되지 않았다. 수업에서 사용하지 않는다.
- `Destroy`는 메뉴에 없어서 빈 오브젝트를 만든 뒤 Add Component로 붙인다.

다음 문서: [examples.md](examples.md)에서 조합 예제 5개를 따라 한다. 수업을 진행하는 강사는 [lesson-plan.md](lesson-plan.md)를 본다. 구현 원리가 궁금하면 [README.md](README.md)에서 시작한다.

## 실습 체크리스트

- [ ] 새 3D 프로젝트에 Cinemachine 2.10.x를 설치했다.
- [ ] `Assets/Scripts`를 복사했고 콘솔에 오류가 없다.
- [ ] Hierarchy 우클릭에 `VisualScripting` 메뉴가 보인다.
- [ ] 입력·처리·출력의 차이를 내 말로 설명할 수 있다.
- [ ] `Is On` 체크박스와 Scene 창의 파란 상자를 확인했다.
