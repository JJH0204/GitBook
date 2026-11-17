# GOS-Lifeis 해체 분석: 포크 개선판은 원본 GOS에서 무엇이 달라졌나

## 한눈에 보기

GOS(Game Object Scripting)는 Unity의 Hierarchy에서 게임 오브젝트를 만들어 "입력 → 처리 → 출력" 노드를 잇는 것만으로 기믹을 구현하는 플러그인이다. 이 레포의 원본은 `JJH0204/GOS`다. 포크 개선판 `GOS-Lifeis`는 원본을 포크한 강사가 대폭 개선한 공개 레포이며, 수업 자료로 쓰인다. 이 문서 묶음은 두 레포를 직접 열어 비교한 결과를 정리하고, 개선된 부분을 빈 Unity 프로젝트에서 따라 만들 수 있게 풀어 쓴 것이다.

* 원본: [https://github.com/JJH0204/GOS](https://github.com/JJH0204/GOS)
* 포크 개선판: [https://github.com/downkhg/GOS-Lifeis](https://github.com/downkhg/GOS-Lifeis)
* 원본 GOS 자체의 해체 문서: [../gos/README.md](../gos/README.md)

{% hint style="warning" %}
Unity를 실행하지 못한 상태에서 소스와 커밋 diff를 읽고 쓴 문서다. 모든 "동작한다/안 한다" 판단은 코드 읽기에서 나온 것이며 **unverified**(실행 검증 안 됨)다. 단, 포크 레포에 커밋된 `unity_build.log`에는 Unity 6000.3.16f1 배치 모드에서 스크립트 컴파일이 성공했고 경고가 2건뿐이었다는 기록이 있다(이 문서가 직접 재현한 것은 아니다).
{% endhint %}

{% hint style="info" %}
포크 레포에는 라이선스가 명시돼 있지 않다(루트에 LICENSE 파일이 없다). 이 문서의 코드 발췌는 설명에 필요한 짧은 조각뿐이다. 전체 코드는 위 레포에서 직접 확인하고, 재사용하기 전에 저작자에게 허락 범위를 확인해야 한다.
{% endhint %}

## 원본과의 관계

두 레포는 커밋 이력을 공유한다. 포크 레포의 커밋 23개 중 앞의 9개(2025-08 ~ 2026-01)는 원본과 같은 이력이고, 그 뒤 14개가 포크에서 새로 쌓은 변경이다. 원본의 마지막 커밋(`99cb7e6`)이 포크 쪽 변경의 출발점이다. 포크의 변경은 2026-03-03 Unity 6 마이그레이션에서 시작해 2026-06-11 스포너 추가까지 이어진다.

원본 README의 기능 목록(입력 5종, 처리 3종, 출력 7종)은 포크 README에도 한 글자도 바뀌지 않은 채 남아 있다. 즉 포크가 추가한 기능 대부분은 README에 설명이 없고, 코드를 읽어야 알 수 있다. 이 문서 묶음이 그 빈칸을 메운다.

## 변경 요약

| 영역 | 변경 내용 | 관련 파일 | 상세 |
| --- | --- | --- | --- |
| 엔진·패키지 | Unity 2022.3.62f1에서 6000.3.16f1로, Cinemachine 2.10.4에서 3.1.6으로 올림. 카메라 컷씬 노드를 Timeline 재생 방식으로 재설계 | `Packages/manifest.json`, `Output/CameraControl.cs`, `Etc/ManagerBase.cs` | [unity6-cinemachine3.md](unity6-cinemachine3.md) |
| 디버그·시각화 | 로그 확장 메서드, 런타임 콘솔(OnGUI), 트리거 영역 선 그리기, 생명주기 로그 | `Debug/*.cs` 4개 | [debugger-visualization.md](debugger-visualization.md) |
| 에디터 도구 | 하이어라키 우클릭 메뉴를 팔레트 창(검색 포함)으로 교체, 인스펙터 "강제 실행" 버튼, JSON으로 Animator 생성 | `Editor/VisualScriptingPalette.cs`, `Editor/ProcessBaseEditor.cs`, `Editor/AnimatorGenerator.cs`, `Editor/EntryClonerEditor.cs` | [editor-tools.md](editor-tools.md) |
| CSV 데이터 | CSV를 읽어 테이블·행으로 만들고, 오브젝트에 스탯을 복사해 주는 계층 추가. 복사값/참조값을 컬럼 타입으로 구분 | `CustumData/*.cs` 5개, `Output/EntryModifierEvent.cs`, `Resources/data/*.csv` | [custom-data.md](custom-data.md) |
| 신규 노드 | 레이캐스트·키 입력·체류 시간 입력, 이동·순간이동·문·조명·시간 배속·타임라인·스폰 출력 | `Input/*`, `Output/*` 11개 | [new-nodes.md](new-nodes.md) |
| 샘플 게임플레이 | FSM 기반 플레이어·AI, 웨이포인트, 오브젝트 풀, 캐릭터 밀기, GameManager | `Etc/*.cs` | [etc-gameplay.md](etc-gameplay.md) |
| 패키징·구성 | `Assets/Scripts`를 `Assets/GOS`로 옮기고 `.unitypackage`로 배포, 샘플 씬·프리팹 재구성 | `PackageManager/GOS_lifeis.unitypackage`, `Assets/GOS/**` | [etc-gameplay.md](etc-gameplay.md), [changes-overview.md](changes-overview.md) |
| 기존 노드 보강 | `ProcessBase`에 `Reset`·강제 실행, `Trigger`에 대상 저장, `Conditional`에 자기 참조 차단·`isLoop`, `Activate`·`Deactivate` 로그와 자기 대상 처리 | `ProcessBase.cs`, `Input/Trigger/Trigger.cs`, `Logic/Conditional.cs`, `Output/SetActivate/*.cs` | [changes-overview.md](changes-overview.md) |

## 읽는 순서

1. [changes-overview.md](changes-overview.md): 전체 지도. 커밋 타임라인, 폴더 구조 변화, 신규·변경·삭제 파일 표를 먼저 본다.
2. [unity6-cinemachine3.md](unity6-cinemachine3.md): 이후 모든 코드의 전제인 엔진·패키지 변화.
3. [editor-tools.md](editor-tools.md): 노드를 만드는 도구가 어떻게 바뀌었는지.
4. [new-nodes.md](new-nodes.md): 새 노드 11종의 입력·동작·사용 예.
5. [custom-data.md](custom-data.md): CSV 데이터와 `EntryCloner`. 가장 구조가 큰 추가분이다.
6. [debugger-visualization.md](debugger-visualization.md): 디버깅 도구.
7. [etc-gameplay.md](etc-gameplay.md): 샘플용 게임플레이 코드와 패키징.

## 문서를 읽는 법

* 각 페이지는 "무엇이 바뀌었나 → 왜 → 핵심 코드 → 따라 만들기 → 한계·주의" 순서다. "왜"는 커밋 메시지와 코드에서 읽히는 범위까지만 적었고, 확인할 수 없는 의도는 추측하지 않았다.
* 포크의 소스 파일 상당수는 UTF-8이 아니라 CP949(한국어 Windows 기본 인코딩)로 저장돼 있다. 일부 파일은 다른 도구에서 열면 한글 주석이 깨져 보인다.
* 포크의 파일·클래스 이름에는 철자 오류가 그대로 있다(`CustumData`, `Prefaps`, `TriggerTimmer`, `DebuggerMassge`, `WaypontPath` 등). 이 문서는 레포의 실제 이름을 그대로 쓴다.
