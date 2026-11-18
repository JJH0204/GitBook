# Day 11 · 취소, 예외, 수명

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UCS-012-DO |
| 유형 | D&O (개념) + 확인 실습 |
| 목적 | `async` 메서드의 수명 문제와 취소 토큰, 예외 전달 경로를 설명한다. |
| 적용 대상 | .NET 8 이상 콘솔(실습), Unity 6 / C# 9(Unity 예제) |
| 소요 시간 | 60분 (2주차 비동기) |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 준비물: .NET SDK (`dotnet new console -o practice/day11`)
{% endhint %}

## 1. 학습 목표

- 코루틴과 달리 `async` 메서드가 오브젝트가 사라진 뒤에도 계속 도는 문제와 해결책(취소 토큰)을 설명할 수 있다.
- `CancellationToken`을 만들고, 내려보내고, 정리하는 표준 패턴(`CancelAfter`, `finally`, `Dispose`)을 쓸 수 있다.
- `await` 한 `Task`, 안 한 `Task`, `async void`, `Task.WhenAll`에서 예외가 어디로 가는지 설명할 수 있다.

## 2. 구성 요소

| 요소 | 위치 | 역할 |
|---|---|---|
| `CancellationTokenSource` (CTS) | 취소를 요청하는 쪽 | `Cancel()` 또는 `CancelAfter(ms)`로 취소를 요청한다. 다 쓰면 `Dispose()`한다 |
| `CancellationToken` | 비동기 메서드의 매개변수 | 취소 요청 여부를 확인하는 쪽에 전달한다 |
| `ThrowIfCancellationRequested()` | 긴 루프 중간 | 취소됐으면 `OperationCanceledException`을 던진다 |
| `CreateLinkedTokenSource(a, b)` | 취소 원인이 여럿일 때 | 둘 중 하나만 취소돼도 취소되는 토큰을 만든다 |
| `MonoBehaviour.destroyCancellationToken` | Unity `MonoBehaviour` | 오브젝트가 파괴되면 취소된다 (Unity 2022.2 이상) |
| `Application.exitCancellationToken` | Unity 전역 | 플레이 종료(에디터 Play 모드 종료 포함) 때 취소된다 (Unity 2022.2 이상) |
| `Forget()` 래퍼 | 직접 만드는 확장 메서드 | `await`하지 않는 `Task`의 예외를 로그로 남긴다 |

## 3. 동작 원리

### 3-1. 수명 문제: 코루틴은 같이 죽고, `async`는 안 죽는다

[Day 08](day08-unity-coroutine.md)의 코루틴은 시작한 `MonoBehaviour`가 파괴되면 같이 멈춘다. `async` 메서드는 **오브젝트와 상관없이 끝까지 간다.**

```csharp
// Unity: 오브젝트가 파괴된 뒤에도 await 뒤가 실행된다
private async void Start()        // Unity 메시지 함수는 async void가 허용되는 대표적인 자리다
{
    await Awaitable.WaitForSecondsAsync(5f);
    transform.position = Vector3.zero;     // 그 사이 파괴됐다면?
}
```

{% hint style="info" %}
NOTE: `Awaitable`은 Unity 2023.1 이상(Unity 6 포함)의 API다. 쓰는 Unity 버전에서 `Awaitable.WaitForSecondsAsync`가 있는지 버전 확인 필요.
{% endhint %}

- `await` 뒤에서 파괴된 오브젝트를 쓰면 `MissingReferenceException`이 나거나, `==` 비교로 `null` 취급되어(Day 20) 조용히 아무 일도 안 일어나는 버그가 된다.
- **에디터에서는 Play 모드를 끝낸 뒤에도 `Task` 기반 `async` 반복이 계속 돌 수 있다.** `Task`는 플레이 종료나 앱 종료 때 자동으로 취소되지 않는다. 무한 루프 `async` 메서드는 반드시 취소 가능하게 만들고, 종료 시 취소는 `Application.exitCancellationToken`(Unity 2022.2 이상)을 연결해 처리한다.

### 3-2. `CancellationToken` 패턴

취소는 **협력적(cooperative)** 이다. 취소 요청을 하는 쪽(`CancellationTokenSource`)과 확인하는 쪽(`CancellationToken`)이 나뉘고, 작업이 스스로 확인해서 멈춘다.

| 요소 | 역할 |
|---|---|
| `CancellationTokenSource` (CTS) | `Cancel()`로 요청. `CancelAfter(ms)`로 지연 요청. `Dispose()` 필요 |
| `CancellationToken` | `cts.Token`. **메서드 매개변수로 아래로 계속 내려보낸다** |
| `ct.ThrowIfCancellationRequested()` | 취소됐으면 `OperationCanceledException`을 던진다. 긴 루프 중간에 부른다 |
| `Task.Delay(ms, ct)` 등 | 토큰을 받는 API는 취소되면 스스로 `OperationCanceledException`(의 파생형 `TaskCanceledException`)을 던진다 |
| 연결(linked) 토큰 | `CancellationTokenSource.CreateLinkedTokenSource(a, b)`: 둘 중 하나만 취소돼도 취소된다 |

```csharp
using var cts = new CancellationTokenSource();
cts.CancelAfter(1000);                       // 1초 뒤 자동 취소
try { await WorkAsync(cts.Token); }
catch (OperationCanceledException) { /* 취소는 오류가 아니다: 조용히 처리 */ }
```

- 정리 코드는 `finally`에 둔다. 취소도 예외로 흘러서 `finally`가 실행된다.
- **취소 예외는 다시 던져서 호출자까지 전파**하는 것이 기본이다. 중간에서 삼키면 위쪽이 취소된 줄 모르고 계속 진행한다.
- Unity: **`MonoBehaviour.destroyCancellationToken`** (Unity 2022.2+)이 오브젝트 파괴 시 취소된다. 코루틴의 "같이 죽음"을 `async`에 돌려주는 도구다. UniTask는 `GetCancellationTokenOnDestroy()`로 같은 일을 한다.

```csharp
private async void Start()
{
    try
    {
        await Awaitable.WaitForSecondsAsync(5f, destroyCancellationToken);   // 파괴되면 여기서 취소 예외
        transform.position = Vector3.zero;
    }
    catch (OperationCanceledException) { }   // 취소는 오류가 아니다. async void라서 여기서 직접 처리한다 (using System; 필요)
}
```

### 3-3. 예외는 어디로 가나

| 상황 | 예외의 행방 |
|---|---|
| `await task` | `await`하는 곳에서 **다시 던져진다.** `try/catch`로 잡는다 |
| `await` 안 한 `Task`가 실패 | **사라진다.** 호출자는 모른다. 나중에 GC가 `Task`를 finalize할 때 `TaskScheduler.UnobservedTaskException`이 발생할 뿐이다. 즉 GC 시점에 달려 있어 즉각적이지 않다 |
| `async void`에서 예외 | 호출자가 못 잡는다. `SynchronizationContext`로 던져진다. Unity에서는 콘솔에 로그가 남는다 |
| `Task.WhenAll(a, b)` | `await`는 **첫 번째 예외 하나만** 다시 던진다. 전부는 `task.Exception.InnerExceptions`에 있다 |

버려도 되는 작업(fire-and-forget)은 **명시적 래퍼**로 예외를 로깅한다. UniTask에는 `.Forget()`이 있고, `Task`에는 직접 만든다(실습 2).

{% hint style="info" %}
NOTE: Unity 6 = C# 9 + Mono/IL2CPP. `destroyCancellationToken`은 Unity 2022.2 이상 API이고, `CancellationToken`/`Task` 자체는 .NET 클래스라서 콘솔 실습과 같은 규칙이 적용된다. 위 `Start()`에서 `async void`를 쓴 것은 메시지 함수의 시그니처 때문이며, 그래서 예외는 콘솔 로그로만 남는다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 협력적 취소(cooperative cancellation) | 취소를 강제로 끊지 않고, 작업이 토큰을 확인해 스스로 멈추는 방식 |
| `OperationCanceledException` | 취소를 알리는 예외. `Task.Delay`는 파생형 `TaskCanceledException`을 던진다 |
| fire-and-forget | 결과를 `await`하지 않고 시작만 하는 호출 |
| `UnobservedTaskException` | 아무도 관찰하지 않은 `Task`의 예외를 GC가 `Task`를 finalize할 때 알리는 이벤트 |
| `async void` | `Task`를 돌려주지 않는 비동기 메서드. 예외를 호출자가 잡지 못한다 |
| `AggregateException` | 여러 예외를 묶은 예외. `Task.WhenAll`의 `Exception`에 담긴다 |

## 5. 확인 실습

{% hint style="info" %}
NOTE: 이 절은 AI, 자동완성, 검색 없이 진행한다. 막히면 3절로 돌아간다.
{% endhint %}

### 실습 1: 취소 가능한 다운로드 시뮬레이터 (10분)

요구사항:

1. `DownloadAsync(chunks, ct)`: 청크 하나당 `await Task.Delay(300, ct)` 후 `진행 i/chunks`를 출력. 10청크.
2. `try/finally`로 마지막에 `정리: 임시 파일 삭제`를 출력(취소/완료 모두).
3. `Main`: `CancellationTokenSource`를 `using var`로 만들고 `CancelAfter(1000)`. `OperationCanceledException`을 잡아 예외 형식 이름과 `IsCancellationRequested`를 출력.

**예측:** 몇 번째 청크까지 출력되고, `정리`와 `취소됨` 중 무엇이 먼저 찍히는가?

<details><summary>정답 코드와 예상 출력</summary>

```csharp
// 실행 가능: Program.cs
using var cts = new CancellationTokenSource();
cts.CancelAfter(1000);

try
{
    await DownloadAsync(10, cts.Token);
    Console.WriteLine("완료");
}
catch (OperationCanceledException ex)
{
    Console.WriteLine($"취소됨: {ex.GetType().Name}, IsCancellationRequested={cts.IsCancellationRequested}");
}

static async Task DownloadAsync(int chunks, CancellationToken ct)
{
    Console.WriteLine("다운로드 시작");
    try
    {
        for (int i = 1; i <= chunks; i++)
        {
            await Task.Delay(300, ct);            // 청크 하나 = 300ms
            Console.WriteLine($"  진행 {i}/{chunks}");
        }
    }
    finally
    {
        Console.WriteLine("정리: 임시 파일 삭제");
    }
}
```

출력:
```
다운로드 시작
  진행 1/10
  진행 2/10
  진행 3/10
정리: 임시 파일 삭제
취소됨: TaskCanceledException, IsCancellationRequested=True
```

- 300, 600, 900ms에 청크가 끝나고, 1000ms에 취소되어 네 번째 `Delay`가 중단된다. (타이밍 기반이라 매우 느린 머신에서는 어긋날 수 있다.)
- `finally`가 먼저 실행되고 예외가 호출자까지 올라가 `catch`가 실행된다.
- `Task.Delay`가 던지는 것은 `OperationCanceledException`의 파생형인 `TaskCanceledException`이다. `catch (OperationCanceledException)`이 둘 다 잡는다.

</details>

### 실습 2: 사라지는 예외와 `Forget()` (10분)

1. 던지고 끝나는 `async Task Fail(string msg)`를 만들고, **`await` 없이** `_ = Fail("lost");`로 호출한다. 300ms를 기다린 뒤 예외가 어디서도 보이지 않음을 확인한다.
2. `Task`용 확장 메서드 `Forget()`을 만든다. 실패하면 `[Forget] 예외형식: 메시지`를 출력해야 한다.
3. (선택) `TaskScheduler.UnobservedTaskException`을 구독하고 `GC.Collect(); GC.WaitForPendingFinalizers();`를 불러 "lost"가 그제야 보고되는지 본다.

**예측:** `lost`는 `Forget()`한 것보다 먼저 보일까, 나중에 보일까, 아예 안 보일까?

<details><summary>정답 코드와 예상 출력</summary>

```csharp
// 실행 가능: Program.cs
TaskScheduler.UnobservedTaskException += (_, e) =>
    Console.WriteLine($"[Unobserved] {e.Exception.InnerException!.Message}");

_ = Fail("lost");                      // await도 안 하고 Forget도 안 함
Fail("forgotten").Forget();            // 로그를 남기는 래퍼
await Task.Delay(300);
Console.WriteLine("1) 여기까지 아무 예외도 올라오지 않았다 (lost는 사라졌다)");

GC.Collect();
GC.WaitForPendingFinalizers();         // 미관찰 예외는 Task가 finalize될 때에야 보고된다
Console.WriteLine("2) GC 후");

static async Task Fail(string msg)
{
    await Task.Delay(50);
    throw new InvalidOperationException(msg);
}

static class TaskExt
{
    public static void Forget(this Task task) => _ = Observe(task);

    private static async Task Observe(Task task)
    {
        try { await task; }
        catch (Exception ex) { Console.WriteLine($"[Forget] {ex.GetType().Name}: {ex.Message}"); }
    }
}
```

출력:
```
[Forget] InvalidOperationException: forgotten
1) 여기까지 아무 예외도 올라오지 않았다 (lost는 사라졌다)
[Unobserved] lost
2) GC 후
```

- `forgotten`은 래퍼가 `await`해서 잡으므로 50ms 뒤 즉시 로그가 나온다.
- `lost`는 아무도 보지 않아서 호출 흐름에서는 사라진다. `[Unobserved]`는 `GC.Collect()` 뒤에야 나온다(Release 빌드 기준. Debug 빌드나 GC 타이밍에 따라 다르다, 직접 확인한다).
- `Forget`의 `Observe`는 `async Task`다. `async void`를 쓰지 않고도 예외를 한곳에서 잡는다.

</details>

### 실습 3: `Task.WhenAll`의 예외 두 개 (10분)

`Fail("A 실패", 100)`과 `Fail("B 실패", 50)`(각각 지연 뒤 `InvalidOperationException`)을 `Task.WhenAll`로 묶고 `await`한다. `catch`에서 잡힌 예외 메시지를 출력하고, 이어서 `all.Exception.InnerExceptions`의 모든 메시지를 출력한다.

**예측:** `catch`에는 A와 B 중 무엇이 오는가? `InnerExceptions`의 순서는?

<details><summary>정답 코드와 예상 출력</summary>

```csharp
// 실행 가능: Program.cs
var a = Fail("A 실패", 100);
var b = Fail("B 실패", 50);          // 시간상 B가 먼저 실패한다
var all = Task.WhenAll(a, b);

try
{
    await all;
}
catch (Exception ex)
{
    Console.WriteLine($"await가 던진 예외: {ex.Message}");
}

foreach (var ex in all.Exception!.InnerExceptions)
    Console.WriteLine($"  Inner: {ex.Message}");

static async Task Fail(string msg, int ms)
{
    await Task.Delay(ms);
    throw new InvalidOperationException(msg);
}
```

출력:
```
await가 던진 예외: B 실패
  Inner: B 실패
  Inner: A 실패
```

- `await`는 `InnerExceptions`의 **첫 번째**만 던진다. 이 실행에서는 먼저 실패한 B가 첫 번째였다. 이 순서(완료 순서)는 구현에 의존하니 "항상 인자 순서"라고 외우지 말고 직접 확인한다.
- 모든 예외가 필요하면 `await` 대신 `WhenAll`이 돌려준 `Task`의 `Exception.InnerExceptions`를 순회한다.

</details>

## 6. 확인 문제

소리 내어 30초 안에 답해 본 뒤 펼쳐서 비교한다.

**Q1. 비동기 작업 중에 오브젝트가 파괴되면 어떻게 처리하나요?**
<details><summary>모범 답안</summary>
코루틴은 오브젝트와 함께 멈추지만 `async` 메서드는 계속 실행되어, `await` 뒤에서 파괴된 오브젝트를 건드리면 `MissingReferenceException`이나 조용한 버그가 납니다. 그래서 `destroyCancellationToken`(UniTask는 `GetCancellationTokenOnDestroy`)을 비동기 호출에 넘겨 오브젝트 파괴 시 취소되게 하고, 취소 예외는 호출자까지 전파합니다. 토큰을 받지 않는 구간에서는 `await` 뒤에 오브젝트가 유효한지 확인합니다.

</details>

**Q2. `async void`를 왜 피하나요?**
<details><summary>모범 답안</summary>
`Task`를 돌려주지 않아서 호출자가 완료를 `await`할 수도 예외를 `try/catch`로 잡을 수도 없습니다. 예외는 `SynchronizationContext`로 던져져 Unity에서는 콘솔 로그로만 남고, 실행 순서 제어와 테스트도 어렵습니다. 이벤트 핸들러처럼 `void`가 강제되는 곳에만 쓰고, 그 안은 `try/catch`로 감쌉니다.

</details>

**Q3. 취소를 어떻게 전파하나요?**
<details><summary>모범 답안</summary>
`CancellationTokenSource`를 만들어 `Token`을 비동기 메서드의 매개변수로 끝까지 내려보내고, 토큰을 받는 API(`Task.Delay` 등)에 넘기거나 긴 루프에서 `ThrowIfCancellationRequested`를 호출합니다. 취소는 `OperationCanceledException`으로 전파되며 정리는 `finally`에서 합니다. 사용이 끝난 CTS는 `Dispose`하고, 시간 제한은 `CancelAfter`, 여러 취소 원인은 `CreateLinkedTokenSource`로 합칩니다.

</details>

**Q4. `await` 하지 않은 `Task`가 예외를 던지면 어떻게 되나요?**
<details><summary>모범 답안</summary>
호출자는 알 수 없고, 예외는 `Task` 안에 갇힙니다. 나중에 GC가 그 `Task`를 finalize할 때 `TaskScheduler.UnobservedTaskException`이 발생하지만 즉각적이지 않습니다. 그래서 버려도 되는 작업은 예외를 로깅하는 `Forget` 같은 래퍼로 명시적으로 처리합니다.

</details>

**Q5. `Task.WhenAll`에서 여러 작업이 실패하면 예외는 어떻게 되나요?**
<details><summary>모범 답안</summary>
`await Task.WhenAll(...)`은 실패한 예외들 중 첫 번째 하나만 다시 던집니다. 모든 예외는 `WhenAll`이 돌려준 `Task`의 `Exception.InnerExceptions`에 `AggregateException`으로 담겨 있어서, 전부 필요하면 그것을 순회해야 합니다.

</details>

## 참조

- [관리되는 스레드의 취소](https://learn.microsoft.com/ko-kr/dotnet/standard/threading/cancellation-in-managed-threads)
- [CancellationTokenSource 클래스](https://learn.microsoft.com/ko-kr/dotnet/api/system.threading.cancellationtokensource)
- [TaskScheduler.UnobservedTaskException 이벤트](https://learn.microsoft.com/ko-kr/dotnet/api/system.threading.tasks.taskscheduler.unobservedtaskexception)
- [Unity ScriptReference — MonoBehaviour.destroyCancellationToken](https://docs.unity3d.com/ScriptReference/MonoBehaviour-destroyCancellationToken.html)
- [Cysharp/UniTask — 취소와 예외 처리](https://github.com/Cysharp/UniTask)

이전: [Day 10 · UniTask와 Awaitable 🎮](day10-unitask-awaitable.md) · 다음: [Day 12 · \[실습\] 오브젝트 풀](day12-lab-object-pool.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 오늘의 한 줄: 이 날의 핵심을 내 말로 한 문장으로 적는다.
- [ ] `async` 메서드에 취소 토큰을 넘기지 않았다가 겪은(또는 겪을 뻔한) 문제를 내 말로 설명하면?
- [ ] 내 코드에서 `await` 없이 호출하는 `Task`는 어디이며, 그 예외를 누가 보는가?
