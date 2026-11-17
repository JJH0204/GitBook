# Unity·C# 기초 체력: 하루 한 장

AI가 만든 결과물의 한계를 알아보고 직접 고칠 수 있는 기초 체력을 기르는 4주 과정.
하루에 한 장, 한 시간씩 한다. 읽고, AI 없이 손으로 짜 보고, 면접 질문에 소리 내어 답한다.

## 하루 한 시간 사용법

| 시간 | 할 일 |
|---|---|
| 20분 | **읽기**: 개념과 짧은 예제 |
| 30분 | **손으로 확인**: 내 컴퓨터의 작업 폴더 `practice/dayNN/`에 직접 코드를 친다. 결과를 먼저 예측해 적고 실행한다 |
| 10분 | **면접 대비**: 질문에 소리 내어 답한 뒤 모범 답안을 펼친다 |

실습 날(Day 06, 12, 18, 24)은 읽기 10분, 구현 45분, 회고 5분으로 나눈다.

**규칙**
- 이 한 시간 동안은 AI 채팅, 코드 자동완성(Copilot 등), 검색을 쓰지 않는다. 막히면 그날 페이지의 읽기 부분과 `더 보기`의 공식 문서만 본다.
- 정답과 모범 답안은 끝까지 해 본 다음에 펼친다. 못 풀었으면 어디서 막혔는지 한 줄 적어 둔다.
- 끝나면 그날 페이지 맨 아래 `오늘의 한 줄`을 GitBook에서 내 말로 고쳐 쓰고, 이 페이지의 체크박스를 채운다. 예: "값 타입은 선언된 곳에 산다"
- 밀린 날은 건너뛰지 말고 다음 날 이어서 한다. 날짜보다 순서가 중요하다.

## 준비 (Mac)

실습 코드는 GitBook이 아니라 내 컴퓨터의 작업 폴더(예: `~/study/unity-csharp/`)에 둔다. 아래의 `practice/`는 그 폴더 안의 경로다.

- .NET SDK 8 이상: `brew install --cask dotnet-sdk` 후 `dotnet --version`으로 확인
- 콘솔 실습: `dotnet new console -o practice/day01 && cd practice/day01 && dotnet run`
- 🎮 표시가 있는 날은 Unity가 필요하다. Unity 6 빈 프로젝트(URP) 하나를 `practice/UnityLab`에 만들어 계속 쓴다. 실습 스크립트 일부가 예전 `Input` 클래스를 쓰므로 `Project Settings > Player > Active Input Handling`을 `Both`로 바꿔 둔다.
- 에디터의 AI 기능을 끈다. VS Code는 Copilot 확장을 비활성화하고, Rider는 AI Assistant와 Full Line Code Completion을 끈다.
- 콘솔(.NET 8 이상)은 최신 C#을 쓰지만 Unity 6은 C# 9까지만 지원한다. 차이가 있는 곳은 본문에 따로 표시했다.

## 커리큘럼

### 1주차: C# 메모리
- [ ] Day 01 [값 타입과 참조 타입](day01-value-vs-reference.md)
- [ ] Day 02 [박싱과 언박싱](day02-boxing.md)
- [ ] Day 03 [GC와 할당](day03-gc-allocation.md)
- [ ] Day 04 [struct 제대로 쓰기](day04-struct-in-practice.md)
- [ ] Day 05 [델리게이트, 람다, 클로저](day05-delegate-closure.md)
- [ ] Day 06 [실습: 상태 패턴](day06-lab-state-pattern.md)

### 2주차: 비동기
- [ ] Day 07 [IEnumerator와 yield의 정체](day07-iterator-yield.md)
- [ ] Day 08 [Unity 코루틴의 내부](day08-unity-coroutine.md) 🎮
- [ ] Day 09 [Task와 async/await](day09-task-async-await.md)
- [ ] Day 10 [UniTask와 Awaitable](day10-unitask-awaitable.md) 🎮
- [ ] Day 11 [취소, 예외, 수명](day11-cancellation-exceptions.md)
- [ ] Day 12 [실습: 오브젝트 풀](day12-lab-object-pool.md)

### 3주차: 렌더링과 측정
- [ ] Day 13 [렌더링 파이프라인 한 바퀴](day13-rendering-pipeline.md) 🎮
- [ ] Day 14 [배칭](day14-batching.md) 🎮
- [ ] Day 15 [오버드로우, 투명, 컬링](day15-overdraw-culling.md) 🎮
- [ ] Day 16 [셰이더 variant와 첫 사용 스톨](day16-shader-variants-warmup.md) 🎮
- [ ] Day 17 [프로파일러 읽는 법](day17-profiler.md) 🎮
- [ ] Day 18 [실습: 이벤트 버스](day18-lab-event-bus.md)

### 4주차: Unity 코어와 트러블슈팅
- [ ] Day 19 [MonoBehaviour 생명주기](day19-monobehaviour-lifecycle.md) 🎮
- [ ] Day 20 [UnityEngine.Object와 null](day20-unity-object-null.md) 🎮
- [ ] Day 21 [직렬화와 ScriptableObject](day21-serialization-scriptableobject.md) 🎮
- [ ] Day 22 [트러블슈팅 노트 ①: 프레임 스파이크](day22-troubleshooting-performance.md)
- [ ] Day 23 [트러블슈팅 노트 ②: 투사체가 바닥에 먹히는 버그](day23-troubleshooting-bug.md) 🎮
- [ ] Day 24 [실습: 종합 미니 게임](day24-lab-mini-game.md)

## 트러블슈팅 노트

[troubleshooting/](troubleshooting/README.md)에는 실제로 겪은 문제를 `문제 상황 → 원인 분석 → 해결 과정 → 수치화된 결과` 4단계로 정리한다.
Day 22–23에서 처음 두 개를 쓰고, 나머지 후보는 [troubleshooting/README.md](troubleshooting/README.md)에 있다. 이 노트가 이력서의 경력 기술서가 된다.

## 4주가 끝나면

각 Day의 면접 질문 중 아직 막히는 것에 표시해 두고, 그 Day부터 한 번 더 돈다.
두 번째 바퀴에서는 모범 답안을 보지 않고 답한 다음 내 답을 페이지에 적는다.

## 원본 레포

* [JJH0204/unity-csharp-study](https://github.com/JJH0204/unity-csharp-study) (비공개, 참고용): 이 과정의 원본 레포다. 레슨은 이 GitBook에서 보고 고친다.
