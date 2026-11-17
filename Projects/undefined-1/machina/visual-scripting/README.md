# 비주얼 스크립팅 노드 체계


{% hint style="info" %}
이 노드 체계는 내가 만든 GOS(Game Object Scripting)를 팀 프로젝트에 맞게 가져다 쓴 것이다. 원본의 해체 문서는 [GOS 해체 분석](../../gos/README.md), 이를 포크해 개선한 버전의 변경점은 [GOS-Lifeis 해체 분석](../../gos-lifeis/README.md)에 있다.
{% endhint %}

## 한눈에 보기

{% hint style="info" %}
이 영역은 유료 그래프 에디터 에셋이 아니라, **MonoBehaviour 컴포넌트 하나를 노드 하나로 취급하는 자체 제작 체계**를 다룬다. 노드끼리의 연결은 인스펙터의 직렬화 참조 필드로 이루어진다. (코드 읽기 기준, 실행 검증은 하지 않았다: **unverified**)
{% endhint %}

마키나의 컷씬, 문 열기, 몬스터 소환, 안내 메시지 같은 이벤트·연출은 씬 안에 놓인 작은 컴포넌트들로 조립한다. 기획자가 코드를 만지지 않고 "조건이 맞으면 이 연출을 실행한다"를 하이어라키에서 구성하도록 만든 구조다.

코드에서 확인한 의존성은 다음과 같다.

| 구분 | 사용처 | 비고 |
|---|---|---|
| Unity 기본 API | `MonoBehaviour`, `SerializeField`, 코루틴 | 노드 체계의 핵심은 이것만으로 동작한다 |
| Cinemachine 2.x (`using Cinemachine`) | `CameraControl`, `ExcutionerDummy` | `CinemachineVirtualCamera`, `CinemachineBrain` 사용 |
| DOTween (`using DG.Tweening`) | `ExcutionerDummy` | `DOShakePosition` |
| 프로젝트 자체 매니저 | `GUIManager`, `GameManager`, `EventManager`, `PoolManager` 등 | 출력 노드가 호출하는 대상 |

서드파티 에셋의 소스는 이 문서에 싣지 않는다. 그래프 편집 창 에셋(Visual Scripting, xNode 등)에 의존하는 코드는 이 영역에서 발견하지 못했다.

## 노드 체계 구조

```
 [입력 노드]                 [처리 노드]                    [출력 노드]
 Input / Process            Logic · Conditional            Output

 Trigger / TriggerEnter ─┐
 IsDestroy / IsDead     ─┼─> Logic (And/Or, Not) ─┐
 Timer / OnEvent        ─┘                        ├─> Conditional ──Execute()──> Instance
                                                  │   (참이 되는 순간 1회)        CameraControl
 모든 노드의 공통 부모:                              │                             SetNoticeMessage
 ProcessBase { IsOn, Execute() }                  │                             ToggleUI ...
 ProcessData { process, isNot }  <────────────────┘
                                                      Register ──> EventManager ──> OnEvent
                                                      (상호작용 키)   (Interaction)     (다시 입력 노드로)
```

핵심 규칙은 두 가지다.

1. 모든 노드는 `ProcessBase`를 상속하며 `IsOn`(켜짐 여부)과 `Execute()`(동작)를 가진다.
2. 입력 노드는 조건이 맞으면 `IsOn`을 `true`로 만들고, `Conditional`이 이를 읽어 출력 노드의 `Execute()`를 호출한다.

## 읽는 순서

1. [ProcessBase와 연결 규칙](process-base.md): 모든 노드의 뼈대와 `Logic`·`Conditional`
2. [입력 노드](input-nodes.md): `IsDestroy`와 이벤트 구독 방식
3. [UI 출력 노드](output-nodes-ui.md): 메시지, 목표, HUD, 보스 이름
4. [월드·연출 출력 노드](output-nodes-world.md): 소환, 카메라 컷씬, 흔들림, 사운드, 아이템
5. [상호작용 노드](interaction-nodes.md): `Register`/`Unregister`와 `OnEvent`

## 파일 목록

경로 기준은 `Assets/_GameAssets/01. Scripts/VisualScripting/`이다. 작성 당시 커밋 이력에서는 폴더 이름이 `_Project`였고, 이후 폴더 정리 커밋에서 `_GameAssets`로 옮겨졌다.

| 파일 | 한 줄 역할 | 다룬 페이지 |
|---|---|---|
| `ProcessBase.cs` | 모든 노드의 추상 부모 (`IsOn`, `Execute`) | process-base |
| `ProcessData.cs` | 노드 참조와 Not 반전 플래그 묶음 | process-base |
| `Logic/Logic.cs`, `Logic/Conditional.cs` | AND/OR 결합, 참이 될 때 출력 실행 | process-base |
| `Input/IsDestroy.cs` | 지정 오브젝트가 모두 파괴되면 켜짐 | input-nodes |
| `Output/SetNoticeMessage.cs` | 안내 메시지 표시 | output-nodes-ui |
| `Output/SetObjectText.cs` | 현재 목표 문구와 지시 마커 설정 | output-nodes-ui |
| `Output/SetIndicatorTarget.cs` | 지시 마커 대상 지정 | output-nodes-ui |
| `Output/ToggleUI.cs` | HUD 켜기/끄기 | output-nodes-ui |
| `Output/ToggleInteractionHUD.cs` | 상호작용 안내 UI 켜기/끄기 | output-nodes-ui |
| `Output/StartBoss.cs` | 보스 이름과 체력바 표시 | output-nodes-ui |
| `Output/Instance.cs` | 풀에서 오브젝트를 꺼내 랜덤 위치에 소환 | output-nodes-world |
| `Output/CameraControl.cs` | Cinemachine 컷씬 전환 | output-nodes-world |
| `Output/ExcutionerDummy.cs` | 발걸음 이벤트에 맞춘 카메라 흔들림 | output-nodes-world |
| `Output/PlaySoundSimple.cs` | AudioSource 재생 | output-nodes-world |
| `Output/GetItem.cs` | 파츠 아이템 지급과 UI 해금 | output-nodes-world |
| `Output/Interaction/Register.cs`, `Unregister.cs` | 상호작용 키 이벤트 등록/해제 | interaction-nodes |

{% hint style="warning" %}
플레이어 파츠(`Player/Parts`)는 이 영역에서 다루지 않는다.
{% endhint %}
