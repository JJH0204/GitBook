# Unity·C# 기초 체력: 하루 한 장

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UCS-001-REF |
| 유형 | REF (그룹 안내와 커리큘럼 표) |
| 목적 | AI가 만든 결과물의 한계를 알아보고 직접 고칠 수 있는 기초 체력을 기르는 4주 과정(24일)의 사용법과 순서를 안내한다 |
| 적용 대상 | .NET SDK 8 이상 콘솔, Unity 6 (URP) 빈 프로젝트, macOS 기준 |
| 소요 시간 | 하루 60분, 총 24일 |
| 확인 상태 | 미검증 (원본 페이지를 정리한 것이며 이 환경에서 설치·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

하루에 한 장, 한 시간씩 한다. 읽고, AI 없이 손으로 짜 보고, 면접 질문에 소리 내어 답한다.

## 1. 하루 한 시간 사용법

| 시간 | 할 일 |
|---|---|
| 20분 | **읽기**: 개념과 짧은 예제 |
| 30분 | **손으로 확인**: 내 컴퓨터의 작업 폴더 `practice/dayNN/`에 직접 코드를 친다. 결과를 먼저 예측해 적고 실행한다 |
| 10분 | **면접 대비**: 질문에 소리 내어 답한 뒤 모범 답안을 펼친다 |

실습 날(Day 06, 12, 18, 24)은 읽기 10분, 구현 45분, 회고 5분으로 나눈다.

규칙은 다음과 같다.

- 이 한 시간 동안은 AI 채팅, 코드 자동완성(Copilot 등), 검색을 쓰지 않는다. 막히면 그날 페이지의 읽기 부분과 `참조`의 공식 문서만 본다.
- 정답과 모범 답안은 끝까지 해 본 다음에 펼친다. 못 풀었으면 어디서 막혔는지 한 줄 적어 둔다.
- 끝나면 그날 페이지 맨 아래 `내 말로 채우기`의 `오늘의 한 줄`을 GitBook에서 내 말로 적고, 이 페이지의 체크박스를 채운다. 예: "값 타입은 선언된 곳에 산다"
- 밀린 날은 건너뛰지 말고 다음 날 이어서 한다. 날짜보다 순서가 중요하다.

## 2. 준비 (macOS)

실습 코드는 GitBook이 아니라 내 컴퓨터의 작업 폴더(예: `~/study/unity-csharp/`)에 둔다. 아래의 `practice/`는 그 폴더 안의 경로다.

| 번호 | 항목 | 방법 | 확인 |
|---|---|---|---|
| 1 | .NET SDK 8 이상 | `brew install --cask dotnet-sdk` | `dotnet --version`이 8 이상을 출력한다 |
| 2 | 콘솔 실습 프로젝트 | `dotnet new console -o practice/day01 && cd practice/day01 && dotnet run` | 프로그램이 실행된다 |
| 3 | Unity 프로젝트 (🎮 표시 날) | Unity 6 빈 프로젝트(URP) 하나를 `practice/UnityLab`에 만들어 계속 쓴다 | 프로젝트가 열린다 |
| 4 | 입력 처리 설정 | 실습 스크립트 일부가 예전 `Input` 클래스를 쓴다. `Project Settings > Player > Active Input Handling`을 `Both`로 바꾼다 | 설정값이 `Both`다 |
| 5 | 에디터의 AI 기능 끄기 | VS Code는 Copilot 확장을 비활성화한다. Rider는 AI Assistant와 Full Line Code Completion을 끈다 | 자동완성 제안이 나타나지 않는다 |

{% hint style="info" %}
NOTE: 콘솔(.NET 8 이상)은 최신 C#을 쓰지만 Unity 6은 C# 9까지만 지원한다. 차이가 있는 곳은 본문에 따로 표시했다. 🎮 표시는 Unity가 필요한 날이다.
{% endhint %}

## 3. 커리큘럼

각 줄의 괄호는 문서 번호(Task ID)다.

### 1주차: C# 메모리

- [ ] Day 01 [값 타입과 참조 타입](day01-value-vs-reference.md) (GMD-UCS-002-DO)
- [ ] Day 02 [박싱과 언박싱](day02-boxing.md) (GMD-UCS-003-DO)
- [ ] Day 03 [GC와 할당](day03-gc-allocation.md) (GMD-UCS-004-DO)
- [ ] Day 04 [struct 제대로 쓰기](day04-struct-in-practice.md) (GMD-UCS-005-DO)
- [ ] Day 05 [델리게이트, 람다, 클로저](day05-delegate-closure.md) (GMD-UCS-006-DO)
- [ ] Day 06 [실습: 상태 패턴](day06-lab-state-pattern.md) (GMD-UCS-007-MP)

### 2주차: 비동기

- [ ] Day 07 [IEnumerator와 yield의 정체](day07-iterator-yield.md) (GMD-UCS-008-DO)
- [ ] Day 08 [Unity 코루틴의 내부](day08-unity-coroutine.md) 🎮 (GMD-UCS-009-DO)
- [ ] Day 09 [Task와 async/await](day09-task-async-await.md) (GMD-UCS-010-DO)
- [ ] Day 10 [UniTask와 Awaitable](day10-unitask-awaitable.md) 🎮 (GMD-UCS-011-DO)
- [ ] Day 11 [취소, 예외, 수명](day11-cancellation-exceptions.md) (GMD-UCS-012-DO)
- [ ] Day 12 [실습: 오브젝트 풀](day12-lab-object-pool.md) (GMD-UCS-013-MP)

### 3주차: 렌더링과 측정

- [ ] Day 13 [렌더링 파이프라인 한 바퀴](day13-rendering-pipeline.md) 🎮 (GMD-UCS-014-DO)
- [ ] Day 14 [배칭](day14-batching.md) 🎮 (GMD-UCS-015-DO)
- [ ] Day 15 [오버드로우, 투명, 컬링](day15-overdraw-culling.md) 🎮 (GMD-UCS-016-DO)
- [ ] Day 16 [셰이더 variant와 첫 사용 스톨](day16-shader-variants-warmup.md) 🎮 (GMD-UCS-017-DO)
- [ ] Day 17 [프로파일러 읽는 법](day17-profiler.md) 🎮 (GMD-UCS-018-DO)
- [ ] Day 18 [실습: 이벤트 버스](day18-lab-event-bus.md) (GMD-UCS-019-MP)

### 4주차: Unity 코어와 트러블슈팅

- [ ] Day 19 [MonoBehaviour 생명주기](day19-monobehaviour-lifecycle.md) 🎮 (GMD-UCS-020-DO)
- [ ] Day 20 [UnityEngine.Object와 null](day20-unity-object-null.md) 🎮 (GMD-UCS-021-DO)
- [ ] Day 21 [직렬화와 ScriptableObject](day21-serialization-scriptableobject.md) 🎮 (GMD-UCS-022-DO)
- [ ] Day 22 [트러블슈팅 노트 ①: 프레임 스파이크](day22-troubleshooting-performance.md) (GMD-UCS-023-TS)
- [ ] Day 23 [트러블슈팅 노트 ②: 투사체가 바닥에 먹히는 버그](day23-troubleshooting-bug.md) 🎮 (GMD-UCS-024-TS)
- [ ] Day 24 [실습: 종합 미니 게임](day24-lab-mini-game.md) (GMD-UCS-025-MP)

## 4. 트러블슈팅 노트

[troubleshooting/](troubleshooting/README.md)(GMD-UTS-001-REF)에는 실제로 겪은 문제를 `문제 상황 → 원인 분석 → 해결 과정 → 수치화된 결과` 4단계로 정리한다.
Day 22–23에서 처음 두 개를 쓰고, 나머지 후보는 [troubleshooting/README.md](troubleshooting/README.md)에 있다. 이 노트가 이력서의 경력 기술서가 된다.

## 5. 4주가 끝난 뒤

1. 각 Day의 면접 질문 중 아직 막히는 것에 표시해 둔다.
2. 표시한 Day부터 한 번 더 돈다.
3. 두 번째 바퀴에서는 모범 답안을 보지 않고 답한 다음 내 답을 페이지에 적는다.

## 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [troubleshooting/README.md](troubleshooting/README.md) | GMD-UTS-001-REF | 트러블슈팅 노트 |
| [troubleshooting/template.md](troubleshooting/template.md) | GMD-UTS-002-REF | 트러블슈팅 노트 템플릿 |

- [JJH0204/unity-csharp-study](https://github.com/JJH0204/unity-csharp-study) (비공개, 참고용): 이 과정의 원본 레포다. 레슨은 이 GitBook에서 보고 고친다.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | AMM 형식으로 재작성. 커리큘럼에 Task ID 추가, 준비 절을 표로 정리 |
