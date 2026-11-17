# Day 09 · Task와 async/await

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UCS-010-DO |
| 유형 | D&O (개념) + 확인 실습 |
| 목적 | `async`/`await`의 상태 기계 변환, `SynchronizationContext`에 따른 재개 위치, Unity에서의 스레드 규칙을 설명한다. |
| 적용 대상 | .NET SDK 8 이상 콘솔 앱, Unity 6 (설명) |
| 소요 시간 | 60분 (2주차 비동기) |
| 준비물 | `dotnet new console -o practice/day09` |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 학습 목표

- `async` 메서드가 상태 기계로 바뀌고 `await`가 `GetAwaiter()`로 풀리는 과정을 설명할 수 있다.
- `await` 뒤에 어느 스레드에서 재개되는지(`SynchronizationContext`)를 콘솔과 Unity로 나눠 설명할 수 있다.
- `Task.Run` 안에서 Unity API를 부르면 안 되는 이유와 `ConfigureAwait(false)`의 뜻을 설명할 수 있다.

## 2. 구성 요소

| 요소 | 위치 | 역할 |
|---|---|---|
| 상태 기계 | 컴파일러가 `async` 메서드에서 생성 | 지역 변수를 필드로 승격하고 `_state`로 재개 지점을 기억한다 |
| `AsyncTaskMethodBuilder` | 컴파일러 생성 코드 | 반환 `Task`를 만들고 결과·예외를 채운다 |
| awaiter (`GetAwaiter()`의 반환) | 대기 대상 | `IsCompleted`, `OnCompleted`, `GetResult()`를 제공한다 |
| `SynchronizationContext` | 스레드 | `await` 뒤 이어갈 코드를 보낼 곳. 콘솔은 없음, Unity는 `UnitySynchronizationContext` |
| `Task.Run` | 스레드 풀 | 무거운 계산을 메인 스레드 밖에서 실행한다 |
| `ConfigureAwait(false)` | `await` 대상 | 컨텍스트를 캡처하지 않고 끝난 스레드에서 이어간다 |

## 3. 동작 원리

### 3-1. `async` 메서드 = 상태 기계 + 빌더

[Day 07](day07-iterator-yield.md)의 `yield` 메서드처럼, `async` 메서드도 컴파일러가 **상태 기계**로 바꾼다. 차이는 소비자다. `yield`는 `foreach`가 `MoveNext()`를 부르고, `async`는 **`await`한 대상이 끝났을 때 상태 기계의 `MoveNext()`가 다시 불린다.**

| 요소 | 하는 일 |
|---|---|
| 상태 기계 | 지역 변수를 필드로 승격하고 `_state`로 "몇 번째 `await` 뒤인가"를 기억한다 |
| `AsyncTaskMethodBuilder` | 반환할 `Task`를 만들고 결과/예외를 채운다. `await`가 끝나지 않았을 때 상태 기계를 힙에 올려 둔다 |
| 상태 기계의 형식 | Release 빌드에서는 `struct`, Debug 빌드에서는 `class` |

Release의 `struct` 상태 기계는 **끝까지 동기적으로 완료되면 힙에 올라가지 않는다.** 처음으로 "아직 안 끝난" `await`를 만나면 힙의 박스로 옮겨진다. Unity에서 어느 쪽인지는 코드 최적화 모드(Debug/Release)에 따라 다르다.

### 3-2. `await x`는 무엇으로 풀리나

```csharp
// await x; 가 풀린 모습 (개념)
var awaiter = x.GetAwaiter();
if (awaiter.IsCompleted)
{
    // 이미 끝났다: 비동기로 가지 않고 곧바로 다음 줄 실행
    awaiter.GetResult();
}
else
{
    awaiter.OnCompleted(continuation);   // continuation = 상태 기계의 MoveNext
    return;                              // 지금은 호출자에게 Task를 돌려주고 빠진다
}
// continuation이 불리면 GetResult()로 결과(또는 예외)를 꺼내 다음 줄부터 이어간다
```

`await`는 `Task`에만 되는 게 아니다. **`GetAwaiter()` 메서드가 있고, 그 반환형에 `IsCompleted`, `OnCompleted`(`INotifyCompletion`), `GetResult()`가 있으면 무엇이든** `await`할 수 있다. `foreach`의 덕 타이핑과 같은 발상이다. 실습 3에서 직접 만든다.

### 3-3. 어디서 재개되나: `SynchronizationContext`

`await`는 `OnCompleted`를 걸기 전에 **`SynchronizationContext.Current`를 캡처**한다. 대상이 끝나면 이어갈 코드를 그 컨텍스트의 `Post`로 보낸다.

| 환경 | `SynchronizationContext.Current` | `await` 뒤에 재개되는 곳 |
|---|---|---|
| 콘솔 앱 | 없음(`null`) | 스레드 풀 스레드 (그래서 `await` 전후 스레드 id가 바뀔 수 있다) |
| Unity | `UnitySynchronizationContext` | **메인 스레드**. 플레이어 루프가 컨텍스트에 쌓인 작업을 처리할 때 이어서 실행된다 |

`ConfigureAwait(false)`는 "컨텍스트를 캡처하지 않겠다"는 뜻이다. 끝난 스레드(보통 풀 스레드)에서 그대로 이어간다. 라이브러리 코드에서는 불필요한 전환을 피하려고 쓴다. **Unity 게임 코드에서는 메인 스레드로 돌아오는 것이 필요하므로 보통 쓰지 않는다.**

### 3-4. 스레드와 Unity

- `Task.Run(...)`은 **스레드 풀**에서 실행한다. Unity API(`transform`, `GameObject` 등)는 **메인 스레드 전용**이라서, `Task.Run` 안에서 부르면 대개 예외가 나고, 아니더라도 동작이 보장되지 않는다.
- 안전한 패턴: 무거운 계산만 `Task.Run`에서 하고, `await`로 돌아온 뒤(메인 스레드) 결과를 Unity API에 쓴다.

### 3-5. 비용과 함정

| 주제 | 내용 |
|---|---|
| `Task` | 클래스다. 비동기로 완료되는 호출마다 `Task`와 상태 기계 박스가 힙에 생긴다 |
| `ValueTask` | 구조체. 결과가 **자주 동기로 나오는** 메서드(캐시 히트 등)에서 할당을 줄인다. 한 번만 `await`해야 한다 |
| `Task.Delay` | 실제 시간(타이머)을 쓴다. `Time.timeScale`과 무관하다. 게임 시간으로 기다리려면 Day 10 |
| `async void` | 호출자가 `await`도 예외 처리도 못 한다. 이벤트 핸들러에만 쓴다 (Day 11) |
| 취소 | `Task`는 Unity 플레이 종료나 오브젝트 파괴로 자동 취소되지 않는다. 에디터에서 Play를 멈춰도 `Task.Delay` 뒤의 코드가 이어질 수 있다. 취소 방법은 Day 11 |

{% hint style="info" %}
NOTE: Unity 6 = C# 9 + Mono/IL2CPP. `async`/`await`와 `Task`는 쓸 수 있지만, 위의 컨텍스트 동작은 Unity 전용 `UnitySynchronizationContext` 덕분이다. WebGL처럼 스레드가 없는 플랫폼에서는 `Task.Run`/`Task.Delay`가 기대대로 동작하지 않는다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| awaiter | `await`가 호출하는 `IsCompleted`/`OnCompleted`/`GetResult()` 묶음을 가진 객체 |
| `SynchronizationContext` | `Post`로 콜백을 특정 스레드·루프에 보내는 추상 클래스 |
| `UnitySynchronizationContext` | Unity 메인 스레드에서 `await` 이후 코드를 실행하게 하는 컨텍스트 |
| 스레드 풀(thread pool) | `Task.Run`과 타이머가 쓰는 .NET 작업 스레드 집합 |
| `ValueTask` | 결과가 자주 동기로 나오는 비동기 메서드의 할당을 줄이는 구조체. 한 번만 `await`한다 |
| `async void` | `Task`를 돌려주지 않는 비동기 메서드. 호출자가 완료·예외를 다룰 수 없다 |

## 5. 확인 실습

{% hint style="info" %}
NOTE: AI, 자동완성, 검색 없이 한다. 막히면 `3. 동작 원리`로 돌아간다.
{% endhint %}

### 실습 1: `await` 전후의 스레드 id (5분)

```csharp
// 실행 가능: Program.cs
Console.WriteLine($"SynchronizationContext: {SynchronizationContext.Current?.GetType().Name ?? "null"}");
Console.WriteLine($"before: thread {Environment.CurrentManagedThreadId}");
await Task.Delay(100);
Console.WriteLine($"after : thread {Environment.CurrentManagedThreadId}");
```

**실행 전에 예측한다:** `SynchronizationContext`는? `before`와 `after`의 스레드 id는 같을까?

<details><summary>예상 출력과 해설</summary>

```
SynchronizationContext: null
before: thread 2
after : thread 5
```

스레드 id 숫자는 실행할 때마다/머신마다 다르다. 같은 것은 구조다: 컨텍스트는 `null`이고, `after`는 스레드 풀 스레드라서 `before`와 **다를 수 있다**(같을 수도 있다).
컨텍스트가 없으니 `Task.Delay`가 끝났을 때 "돌아갈 곳"이 없어서, 타이머가 가리킨 풀 스레드에서 이어진다.

</details>

### 실습 2: 단일 스레드 `SynchronizationContext` 만들기 (15분)

Unity의 `UnitySynchronizationContext`를 흉내 낸다. 요구사항:

1. `SynchronizationContext`를 상속한 `LoopContext`. `Post(cb, state)`는 큐에 넣기만 한다(스레드 안전하게).
2. `Run()`은 호출한 스레드("main")에서 큐를 비우며 콜백을 실행한다. `Stop()`이 호출되면 끝낸다.
3. `SetSynchronizationContext`로 설치하고, `Task.Delay` → `Task.Run` → `Task.Delay(...).ConfigureAwait(false)` 순서로 `await`하며 각 지점이 `main`인지 `pool`인지 출력한다.

**예측:** 5개 지점 중 `pool`은 어디인가?

<details><summary>정답 코드와 예상 출력</summary>

```csharp
// 실행 가능: Program.cs
using System.Collections.Concurrent;

var ctx = new LoopContext();
SynchronizationContext.SetSynchronizationContext(ctx);
int mainId = Environment.CurrentManagedThreadId;

void Log(string msg) =>
    Console.WriteLine($"{msg}: {(Environment.CurrentManagedThreadId == mainId ? "main" : "pool")}");

async Task Demo()
{
    Log("start");
    await Task.Delay(50);
    Log("after Task.Delay");
    await Task.Run(() => Log("in Task.Run"));
    Log("after Task.Run");
    await Task.Delay(50).ConfigureAwait(false);
    Log("after ConfigureAwait(false)");
    ctx.Stop();
}

ctx.Post(_ => Demo(), null);        // 루프 안(= main)에서 시작. 반환된 Task는 쓰지 않는다
ctx.Run();                          // main 스레드는 여기서 큐만 처리한다
Console.WriteLine("loop end");

class LoopContext : SynchronizationContext
{
    private readonly BlockingCollection<(SendOrPostCallback cb, object? state)> _queue = new();

    public override void Post(SendOrPostCallback d, object? state) => _queue.Add((d, state));
    public void Stop() => _queue.CompleteAdding();

    public void Run()
    {
        foreach (var (cb, state) in _queue.GetConsumingEnumerable())
            cb(state);
    }
}
```

출력:
```
start: main
after Task.Delay: main
in Task.Run: pool
after Task.Run: main
after ConfigureAwait(false): pool
loop end
```

- `Task.Delay` 뒤: 캡처된 컨텍스트의 `Post`로 가서 `Run()` 루프(main)에서 재개된다. Unity에서 `await` 뒤에 메인 스레드로 돌아오는 것과 같은 원리다.
- `Task.Run` 안쪽은 스레드 풀. 끝난 뒤의 `await`는 다시 main으로 돌아온다.
- `ConfigureAwait(false)` 뒤: 컨텍스트를 쓰지 않아 풀 스레드에서 이어진다. 그래서 `Stop()`은 스레드 안전해야 한다(`BlockingCollection`).

</details>

### 실습 3: 직접 만든 awaitable — `FrameAwaiter` (10분)

`FrameLoop`가 있다. `await loop.NextFrame()`이 "다음 프레임에 이어서 실행"이 되도록 `GetAwaiter()`와 `INotifyCompletion`을 구현한다. 요구사항:

1. `NextFrame()`이 돌려주는 값에 `GetAwaiter()`가 있고, awaiter에 `IsCompleted`(항상 `false`), `OnCompleted(Action)`, `GetResult()`가 있다.
2. `OnCompleted`는 받은 `continuation`을 루프의 "다음 프레임 목록"에 넣는다. `Run(frames)`은 프레임마다 목록을 꺼내 실행한다.
3. 두 개의 `async Task`를 동시에 돌린다: `A`는 3번, `B`는 2번 `await loop.NextFrame()`하며 `frame {번호}: {이름} {i}`를 출력하고 끝나면 `done`을 출력한다.

<details><summary>정답 코드와 예상 출력</summary>

```csharp
// 실행 가능: Program.cs
using System.Runtime.CompilerServices;

var loop = new FrameLoop();
_ = Count(loop, "A", 3);
_ = Count(loop, "B", 2);
loop.Run(5);

static async Task Count(FrameLoop loop, string name, int n)
{
    for (int i = 0; i < n; i++)
    {
        Console.WriteLine($"frame {loop.Frame}: {name} {i}");
        await loop.NextFrame();
    }
    Console.WriteLine($"frame {loop.Frame}: {name} done");
}

class FrameLoop
{
    private List<Action> _next = new();
    public int Frame { get; private set; }

    public FrameAwaitable NextFrame() => new FrameAwaitable(this);
    internal void Enqueue(Action continuation) => _next.Add(continuation);

    public void Run(int frames)
    {
        for (int i = 0; i < frames; i++)
        {
            Frame++;
            var current = _next;
            _next = new List<Action>();
            foreach (var c in current) c();
        }
    }
}

readonly struct FrameAwaitable
{
    private readonly FrameLoop _loop;
    public FrameAwaitable(FrameLoop loop) => _loop = loop;
    public FrameAwaiter GetAwaiter() => new FrameAwaiter(_loop);
}

readonly struct FrameAwaiter : INotifyCompletion
{
    private readonly FrameLoop _loop;
    public FrameAwaiter(FrameLoop loop) => _loop = loop;
    public bool IsCompleted => false;                      // 항상 "아직"
    public void OnCompleted(Action continuation) => _loop.Enqueue(continuation);
    public void GetResult() { }
}
```

출력:
```
frame 0: A 0
frame 0: B 0
frame 1: A 1
frame 1: B 1
frame 2: A 2
frame 2: B done
frame 3: A done
```

- `IsCompleted`가 `false`라서 매번 `OnCompleted`가 불리고, 상태 기계는 `continuation`(= `MoveNext`)을 넘기고 빠진다.
- 프레임 1에서 `continuation`이 실행될 때 `Task` 기계가 `A 1`을 찍고 다시 `await`한다. 같은 프레임 안의 순서는 목록에 들어간 순서(A, B)다.
- Day 08 스케줄러, Unity의 `UnitySynchronizationContext`, 다음 날의 UniTask가 모두 이 모양이다. "누가 `continuation`을 언제 부르는가"만 다르다.

</details>

## 6. 확인 문제

소리 내어 30초 안에 답해 보고 펼쳐서 비교한다.

**Q1. `async`/`await`는 내부적으로 어떻게 동작하나요?**
<details><summary>모범 답안</summary>
컴파일러가 `async` 메서드를 상태 기계로 바꿉니다. `await x`는 `x.GetAwaiter()`를 얻어 `IsCompleted`가 `true`면 동기로 계속 가고, 아니면 `OnCompleted`에 상태 기계의 `MoveNext`를 이어갈 코드로 등록한 뒤 호출자에게 `Task`를 돌려주고 빠집니다. 대상이 끝나면 그 코드가 호출되어 `GetResult()`로 결과나 예외를 꺼내 다음 줄부터 실행합니다. 스레드를 새로 만드는 것은 `await` 자체가 아니라, 대기하는 대상(`Task.Run`, 타이머 등)입니다.

</details>

**Q2. `await` 뒤에 어느 스레드에서 실행되나요? Unity에서는 어떤가요?**
<details><summary>모범 답안</summary>
`await`는 시작할 때의 `SynchronizationContext.Current`를 캡처하고, 끝나면 그 컨텍스트로 이어갈 코드를 보냅니다. 콘솔 앱은 컨텍스트가 없어서 스레드 풀에서 재개되고, Unity는 `UnitySynchronizationContext`가 있어서 플레이어 루프가 메인 스레드에서 이어갈 코드를 실행합니다. 그래서 Unity에서 `await` 뒤에는 `transform` 같은 API를 안전하게 쓸 수 있습니다.

</details>

**Q3. `Task.Run` 안에서 `transform.position`을 바꾸면 어떻게 되나요?**
<details><summary>모범 답안</summary>
`Task.Run`은 스레드 풀에서 실행되고 Unity API는 메인 스레드에서만 호출할 수 있어서, 예외가 나거나 동작이 보장되지 않습니다. 계산만 `Task.Run`에서 하고 `await`로 메인 스레드로 돌아온 뒤 결과를 Unity 오브젝트에 반영해야 합니다.

</details>

**Q4. `ConfigureAwait(false)`는 무슨 뜻인가요?**
<details><summary>모범 답안</summary>
`await` 뒤에 원래의 `SynchronizationContext`로 돌아가지 않고, 작업이 끝난 스레드에서 그대로 이어가라는 뜻입니다. 라이브러리 코드에서 불필요한 컨텍스트 전환을 줄이는 데 씁니다. Unity 게임 코드에서는 메인 스레드로 돌아와야 Unity API를 쓸 수 있으므로 보통 붙이지 않습니다.

</details>

**Q5. `async void`는 왜 피하나요?**
<details><summary>모범 답안</summary>
`Task`를 돌려주지 않아서 호출자가 완료를 기다릴 수도, 예외를 잡을 수도 없기 때문입니다. 예외는 `SynchronizationContext`로 던져져서 Unity에서는 콘솔 로그로 남을 뿐입니다. 이벤트 핸들러처럼 시그니처가 `void`로 고정된 곳에만 씁니다.

</details>

## 참조

- [Task 기반 비동기 패턴 (TAP)](https://learn.microsoft.com/ko-kr/dotnet/standard/asynchronous-programming-patterns/task-based-asynchronous-pattern-tap)
- [async 및 await를 사용한 비동기 프로그래밍](https://learn.microsoft.com/ko-kr/dotnet/csharp/asynchronous-programming/)
- [SynchronizationContext 클래스](https://learn.microsoft.com/ko-kr/dotnet/api/system.threading.synchronizationcontext)
- [Unity ScriptReference — Awaitable](https://docs.unity3d.com/ScriptReference/Awaitable.html)

이전: [Day 08 · Unity 코루틴의 내부 🎮](day08-unity-coroutine.md) · 다음: [Day 10 · UniTask와 Awaitable 🎮](day10-unitask-awaitable.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 오늘의 한 줄: 이 날의 핵심을 내 말로 한 문장
- [ ] `await` 앞뒤에서 코드가 실행되는 스레드가 달라질 수 있는 이유를 콘솔과 Unity로 나눠 내 말로 설명하면?
- [ ] 내가 `async void`를 썼거나 쓸 뻔한 곳이 있는가? 그 자리에 무엇을 써야 하는가?
