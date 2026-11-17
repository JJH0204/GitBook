# 원본 대비 전체 변경 지도

## 무엇이 바뀌었나

원본 GOS는 `Assets/Scripts/` 아래에 입력·처리·출력 노드 20여 개를 둔 "Unity 2022.3용 소스 프로젝트"였다. 포크 개선판 GOS-Lifeis는 같은 노드 구조를 유지하면서 다음 네 가지를 바꿨다.

* 엔진을 Unity 6(6000.3.16f1)으로 올리고 Cinemachine을 3.x로 옮겼다.
* 노드를 만드는 방식을 우클릭 메뉴에서 팔레트 창으로 바꿨고, 디버깅·CSV 데이터·샘플 게임플레이 코드를 얹었다.
* 신규 노드 11종을 추가했다.
* 소스를 `Assets/GOS/` 아래로 모아 `.unitypackage`로 배포할 수 있게 구성했다.

원본의 `ProcessBase`(상태 `IsOn` + `Execute()`), `ProcessData`(연결 구조체), `Logic`, `IsDestroy`, `OnEvent`, `Instance`, `Destroy`, `MoveObject`, `RotateObject`, `PlayAnimation`, `Register`, `Unregister`, `TriggerEnter`, `TriggerExit`, `ToggleActivate`, `ForLoop`, `WhileLoop`는 내용 변경 없이 그대로다(폴더만 옮겨졌다). 두 레포의 `Assets` 스크립트를 `diff`로 비교해 확인했다.

## 왜

커밋 메시지에서 읽히는 목적은 다음과 같다. 메시지는 한 줄짜리가 대부분이라 그 이상의 의도는 코드에서 추정할 수밖에 없다.

* 38f2e184 "GOS-Unity6 마이그레이션 - 시네머신 3.0 미테스트": 엔진 업그레이드가 출발점이다. 같은 커밋에서 신규 노드와 샘플이 한꺼번에 들어왔다.
* 842c05d8 "카메라 컨트롤 시네머신 3.0에 사용가능하도록 변경": 위 "미테스트" 상태를 실제로 쓸 수 있게 고쳤다.
* a9aecf4a "GOS 패키징 릴리즈": 수업 자료로 배포하기 위한 패키지화.
* 1e254931 이후 커밋의 `change_log.csv`와 `change_log_rules.md`: 이후 작업에서 AI 에이전트가 변경 사항을 CSV에 기록하도록 한 규칙 파일이다. 저장소 루트에 같이 커밋돼 있다.

## 커밋 타임라인

날짜는 GitHub API가 돌려준 UTC 기준 커밋 날짜다. 앞 9개 커밋은 원본과 공유하는 이력이므로 표에서 제외했다. 작성자 정보는 적지 않는다.

| 날짜 | 커밋 | 메시지(원문) | 하는 일 |
| --- | --- | --- | --- |
| 2026-03-03 | 38f2e184 | GOS-Unity6 마이그레이션 | 엔진·패키지 업그레이드, `CameraControl` Cinemachine 3 이름으로 변환, `ManagerBase.Instance`를 `instance`로 변경, 신규 노드 대량 추가(`MoveTo`, `Teleport`, `RotateDoor`, `SlidingDoor`, `LightingControl`, `GameTimeAdjust`, `TimelineController`, `TriggerTimmer`), 팔레트 창·`ProcessBaseEditor`·디버그 3종·FSM 샘플 추가, 프리팹·샘플 씬 대량 추가 |
| 2026-03-03 | a69677bc | 디버그 시각화 및 런타임 디버거 업데이트 | `RuntimeConsole` 추가, `VisualLogger` 단순화, `Trigger` 로그 정리 |
| 2026-03-14 | 842c05d8 | 카메라 컨트롤 시네머신 3.0에 사용가능하도록 변경 | `CameraControl` 재설계(Timeline 연동), `VisualLogger`의 화면 출력 이벤트 복원, `ForLoop`·`WhileLoop` 추가 위치 정리 |
| 2026-03-14 | 5e073b03 | 테스트데이터 추가 및 메니저베이스 안정 | `ManagerBase` 싱글톤 안정화, CSV 데이터 계층 5개 파일과 테스트 CSV 추가, `ObjectPoolManager` 추가, `GUIManager` 삭제 |
| 2026-03-14 | 636bc697 | 복사값과 참조값을 선택가능하도록 변경 | `EntryCloner`·`CSVParser` 등 재작성. 컬럼 타입으로 복사/참조 구분. 메시지 둘째 줄에 "오류: 데이터베이스 디버깅파싱 오류있음"이라고 적혀 있다 |
| 2026-03-15 | 9fe07e51 | 변경없음 프로젝트 업데이트 | 스크립트 변경 없음. 샘플 씬·애니메이션 에셋 추가 |
| 2026-04-05 | a9aecf4a | GOS 패키징 릴리즈 | `Assets/` 아래 거의 전부를 `Assets/GOS/`로 이동, `.unitypackage` 첫 추가(약 18.8MB), `.slnx` 추가 |
| 2026-04-05 | ab0ce9cf | 병합충 | 위 두 갈래(a9aecf4a, 9fe07e51)의 병합 커밋 |
| 2026-04-05 | 4221c076 | 유니티패키지업데이 | `.unitypackage` 갱신 |
| 2026-04-06 | 1094d49c | 불필요한 구성 삭제및 샘플 새구성, 패키지관리자 업데이 | `AnimatorGenerator`, `EntryClonerEditor`, `GameManager` 추가. 번들 이펙트 에셋·옛 샘플 씬 삭제, `Logic/Loop/` 정리, 샘플 프리팹·씬 재구성. `.unitypackage`가 약 18.8MB에서 약 156KB로 줄었다 |
| 2026-06-06 | 1e254931 | 인풋드리거, 레이케이스트 | `InputEvent`, `RaycastTrigger`, `EntryModifierEvent` 추가, `change_log.csv` 도입 |
| 2026-06-09 | 92dcef6e | 비쥬얼 스크립트 팔레트 윈도우 검색기능 추가 | `.gitignore`만 변경 |
| 2026-06-09 | fd1e5bfa | 비쥬얼 스크립트 팔레트 윈도우 검색기능 추가 | 팔레트에 검색창 추가, 카테고리를 폴더 이름 기반으로 변경, 패키지 버전 소폭 상향 |
| 2026-06-11 | d3cfe625 | 스포너추가 | `Spawner`와 테스트 씬 추가, `VisualScriptingEditor`(우클릭 메뉴) 삭제, `Docs/GOS_Framework_Analysis.md`·`unity_build.log` 추가 |

## 구조 변화

### 폴더

```
원본 (JJH0204/GOS)                      포크 (GOS-Lifeis)       
Assets/                                 Assets/
  Scripts/                                GOS/
    AnimCheck.cs                            Editor/            (AnimatorGenerator, EntryClonerEditor)
    GUIManager.cs                           Materials/ Prefaps/ Resources/data/ Scenes/ Timelines/
    ManagerBase.cs                          Scripts/
    VisualScripting/                          AnimCheck.cs
      Editor/VisualScriptingEditor.cs         VisualScripting/
      GlobalGameObject.cs                       CustumData/  Debug/  Editor/  Etc/
      ProcessBase.cs, ProcessData.cs            Input/  Logic/  Output/
      Input/ Logic/(Loop/) Output/              ProcessBase.cs, ProcessData.cs
  Scenes/GOS.unity                        Resources/data/    (GOS/Resources/data와 같은 CSV 사본)
  Mirza Beig/ (이펙트 에셋)               MoveAnimation.anim, Sphere.controller (Assets 루트에 남은 에셋)
                                        PackageManager/GOS_lifeis.unitypackage
                                        Docs/  change_log.csv  GOS-Lifeis.slnx
```

* `ManagerBase.cs`, `GlobalGameObject.cs`는 `VisualScripting/Etc/`로 모였다. `Etc/`가 "노드가 아닌 보조·샘플 코드" 폴더가 됐다.
* `Logic/Loop/ForLoop.cs`, `WhileLoop.cs`는 `Logic/` 바로 아래로 올라왔고 `Loop/`는 사라졌다. 파일 내용은 원본과 같다.
* `Output/SetActivate/ToggleActivate.cs`는 `Output/ToggleActivate.cs`로 올라왔다. `Activate`, `Deactivate`, `TimelineController`는 `SetActivate/`에 남았다.
* 팔레트 창이 "스크립트의 부모 폴더 이름"으로 카테고리를 정하기 때문에([editor-tools.md](editor-tools.md)), 폴더 이동이 곧 팔레트 분류 변경이다.

### 노드 연결 모델은 그대로

모든 노드가 `ProcessBase`를 상속하고, 노드 사이의 연결은 `ProcessData { process, isNot }` 구조체로 직렬화되는 방식은 포크에서도 같다. 포크는 이 모델을 건드리지 않고 그 위에 노드와 도구를 쌓았다. 그래서 원본에서 배운 사용법은 그대로 통한다.

## 기존 기능이 어떻게 바뀌었나

| 원본 기능 | 포크에서의 모습 |
| --- | --- |
| 하이어라키 우클릭 `GameObject/VisualScripting/...` 메뉴(`VisualScriptingEditor.cs`) | d3cfe625에서 파일 삭제. 대신 상단 메뉴 `Visual Scripting/GameObject/Pallete Window`의 팔레트 창. 포크 README에는 여전히 우클릭 메뉴가 안내돼 있다 |
| `ManagerBase<T>.Instance` | `instance`(소문자)로 이름 변경. `lock`, 종료 중 생성 차단, `Awake`의 중복 파괴 추가 |
| `CameraControl` (`CinemachineVirtualCamera` 배열, 페이드 인/아웃, 블렌드 설정) | `CinemachineCamera` 2대와 `PlayableDirector`를 쓰는 구조로 단순화. 페이드·블렌드 옵션 삭제 |
| `GUIManager`(페이드 패널, UI 텍스트) | 5e073b03에서 삭제. `CameraControl`의 페이드 호출이 같이 사라졌다 |
| `Trigger` | 충돌한 오브젝트를 `objTarget`으로 저장하고 `GetTarget()`으로 공개. 로그 추가 |
| `Timer` | 시작·종료 로그만 추가 |
| `Conditional` | `isLoop` 옵션, 에디터에서 자기 자신을 output으로 잇는 순환 참조를 감지해 연결을 끊는 `OnValidate` 추가 |
| `Activate` | `obj`가 비어 있으면 자기 자신을 대상으로 삼는 `Awake`, 로그 추가 |
| `Deactivate` | 대상을 항상 자기 자신으로 고정하고 `OnDisable`에서 `Execute`를 부르게 바꿨다. `IsOn`도 `false`에서 `true`로 바뀌었다 |
| `ProcessBase` | `Reset()`과 에디터 전용 `ForceExecute()`(컨텍스트 메뉴) 추가 |

## 파일 표

### 신규 (원본에 없음)

| 영역 | 파일 | 상세 |
| --- | --- | --- |
| Editor | `Editor/AnimatorGenerator.cs`, `Editor/EntryClonerEditor.cs`, `Scripts/VisualScripting/Editor/{ProcessBaseEditor,VisualScriptingPalette}.cs` | [editor-tools.md](editor-tools.md) |
| CustumData | `CSVParser`, `DatabaseManager`, `EntryCloner`, `RowEntity`, `TableData` | [custom-data.md](custom-data.md) |
| Debug | `BoxColliderVisualizer`, `DebuggerMassge`, `RuntimeConsole`, `VisualLogger` | [debugger-visualization.md](debugger-visualization.md) |
| Etc | `AIContller`, `BaseFSM`, `CharacterPush`, `GameManager`, `ObjectPoolManager`, `PlayerController`, `WaypontPath` | [etc-gameplay.md](etc-gameplay.md) |
| Input | `InputEvent`, `Trigger/RaycastTrigger`, `Trigger/TriggerTimmer` | [new-nodes.md](new-nodes.md) |
| Output | `EntryModifierEvent`, `GameTimeAdjust`, `LightingControl`, `MoveTo`, `RotateDoor`, `SlidingDoor`, `Spawner`, `Teleport`, `SetActivate/TimelineController` | [new-nodes.md](new-nodes.md) |
| 데이터 | `Resources/data/TestData - {Schema,Class,Character,Character.class}.csv` | [custom-data.md](custom-data.md) |
| 기타 | `Docs/GOS_Framework_Analysis.md`, `change_log.csv`, `change_log_rules.md`, `unity_build.log`, `GOS-Lifeis.slnx` | 아래 주의 참고 |

### 변경 (원본에도 있으나 내용이 다름)

`ProcessBase.cs`, `Input/Timer.cs`, `Input/Trigger/Trigger.cs`, `Logic/Conditional.cs`, `Output/CameraControl.cs`, `Output/SetActivate/Activate.cs`, `Output/SetActivate/Deactivate.cs`, `ManagerBase.cs`(위치도 이동), `Packages/manifest.json`, `ProjectSettings/ProjectVersion.txt`.

### 삭제

| 파일 | 삭제 커밋 | 비고 |
| --- | --- | --- |
| `GUIManager.cs` | 5e073b03 | 페이드 패널·HP 바 등을 가진 UI 싱글톤 |
| `Editor/VisualScriptingEditor.cs` | d3cfe625 | 우클릭 메뉴 생성기 |
| `Logic/Loop/ForLoop.cs`, `WhileLoop.cs` | 1094d49c | `Logic/`로 올려 사본이 남았으므로 사실상 이동 |
| `Mirza Beig/` 이펙트 에셋 | 1094d49c | 서드파티 에셋. 패키지 용량이 크게 줄었다 |
| `Scenes/GOS.unity`와 `GimmickSample/` 씬들 | 1094d49c | `GOSSampleScenes.unity` 하나로 통합 |

### 이름만 바뀌거나 이동 (내용 동일)

`AnimCheck`, `GlobalGameObject`, `IsDestroy`, `OnEvent`, `Logic`, `Instance`, `Destroy`, `MoveObject`, `RotateObject`, `PlayAnimation`, `Register`, `Unregister`, `TriggerEnter`, `TriggerExit`, `ToggleActivate`, `ForLoop`, `WhileLoop`, `ProcessData`. 모두 `Assets/Scripts/...`에서 `Assets/GOS/Scripts/...`로 이동했다.

## 한계·주의

* `Docs/GOS_Framework_Analysis.md`는 포크 레포가 자체 포함한 분석 문서인데, 같은 커밋(d3cfe625)에서 삭제된 `VisualScriptingEditor`를 현재 기능처럼 설명하는 등 코드와 어긋난 곳이 있다. 이 문서 묶음은 코드를 직접 읽은 내용을 기준으로 했다.
* 파일 이름과 클래스 이름이 다른 경우가 여럿이다(`AIContller.cs` 안의 클래스는 `AIController`, `WaypontPath.cs`는 `WaypointPath`, `GameTimeAdjust.cs`는 `GameTimeAdject`, `EntryClonerEditor.cs`는 `NewMonoBehaviourScript`). Unity에서 컴포넌트로 붙이려면 일반적으로 파일명과 클래스명이 같아야 하므로, 이 파일들이 인스펙터에서 정상 동작하는지는 **확인 필요**다. 상세는 각 페이지에 적었다.
* 테스트 CSV가 `Assets/Resources/data/`와 `Assets/GOS/Resources/data/`에 같은 내용으로 두 벌 있다(`.meta`의 guid만 다르다). `Resources.Load`는 두 `Resources` 폴더를 합쳐서 찾으므로 같은 경로 이름이 겹친다. 어느 쪽이 로드되는지는 **확인 필요**다.
* 변경 이력의 "복사/참조", "테스트 완료" 같은 표현은 커밋 메시지에서 가져온 것이다. 실제로 테스트됐는지는 확인하지 못했다.
