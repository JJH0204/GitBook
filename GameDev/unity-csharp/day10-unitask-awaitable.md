# Day 10 · UniTask와 Awaitable 🎮

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UCS-011-DO |
| 유형 | D&O (개념) + 확인 실습 |
| 목적 | 게임에서 `Task`가 불편한 이유와, UniTask·Unity `Awaitable`이 할당을 줄이고 플레이어 루프에 붙는 방식을 코루틴·`Task`와 비교한다. |
| 적용 대상 | Unity 6 (URP 프로젝트), .NET SDK 8 이상 콘솔 앱(대체 실습). UniTask는 선택 |
| 소요 시간 | 60분 (2주차 비동기) |
| 준비물 | 🎮 Unity 6 (URP), `dotnet new console -o practice/day10` (콘솔 대체 실습). UniTask는 패키지 설치 필요(선택) |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 학습 목표

- 게임에서 `Task`가 불편한 이유 네 가지를 말할 수 있다.
- UniTask와 Unity `Awaitable`이 각각 어떻게 할당을 줄이고 플레이어 루프에 붙는지 설명할 수 있다.
- 코루틴 / `Task` / UniTask / `Awaitable`을 표로 비교하고 상황에 맞게 고를 수 있다.

## 2. 구성 요소

| 요소 | 위치 | 역할 |
|---|---|---|
| `UniTask` | Cysharp 패키지 | `struct` + 풀링된 소스로 할당을 줄이고 플레이어 루프 대기를 제공한다 |
| `Awaitable` | Unity 내장 (2023.1 이상) | 내부 풀링된 클래스. 프레임·`FixedUpdate`·스레드 전환 대기를 제공한다 |
| `PlayerLoopTiming` | UniTask | `UniTask.Yield`가 재개될 플레이어 루프 위치 |
| `CancellationToken` | 공통 | `GetCancellationTokenOnDestroy()`(UniTask) 또는 `destroyCancellationToken`(Unity 2022.2 이상)로 오브젝트 파괴 시 취소한다 |
| `Preserve()` | UniTask | 한 번만 `await`하는 제약을 풀어 복제 가능한 형태로 바꾼다 |
| UniTask Tracker | `Window > UniTask Tracker` | 실행 중인 `UniTask`를 보여 준다 |

## 3. 동작 원리

### 3-1. `Task`가 게임에서 불편한 이유

| 문제 | 내용 |
|---|---|
| 할당 | 비동기로 끝나는 호출마다 `Task`와 상태 기계 박스가 힙에 생긴다 (Day 09). 프레임마다 호출하면 GC 압력이다 |
| 프레임 개념 없음 | "다음 프레임", "`Update` 직후", "`FixedUpdate`에서" 같은 플레이어 루프 시점을 표현하지 못한다 |
| `timeScale` 무시 | `Task.Delay`는 실제 시간이다. 일시정지(`timeScale = 0`) 중에도 흘러간다 |
| 스레드 의존 | 타이머와 `Task.Run`이 스레드를 쓴다. WebGL처럼 스레드가 없는 플랫폼에서는 기대대로 동작하지 않는다 |

### 3-2. UniTask (Cysharp, 오픈소스)

`UniTask`는 **`struct`** 이고, 완료 상태를 풀링된 `IUniTaskSource` 객체가 들고 있다. 그래서 비동기로 완료되는 호출도 **거의 할당이 없다.** Unity의 플레이어 루프에 직접 끼어들어 프레임 단위 대기를 제공한다.

| 기능 | 코드 |
|---|---|
| 다음 프레임 | `await UniTask.NextFrame();` |
| 특정 시점으로 | `await UniTask.Yield(PlayerLoopTiming.Update);` |
| 게임 시간 지연 | `await UniTask.Delay(3000);` (기본은 `timeScale` 적용. `ignoreTimeScale: true`로 무시) |
| 조건 대기 | `await UniTask.WaitUntil(() => ready);` |
| 코루틴/`AsyncOperation` | `await SceneManager.LoadSceneAsync("Game");` 처럼 바로 `await` |
| 취소와 수명 | `this.GetCancellationTokenOnDestroy()`로 오브젝트 파괴 시 취소 (Day 11) |
| 진단 | `Window > UniTask Tracker`에서 실행 중인 `UniTask`를 본다 |

규칙: **`UniTask`는 한 번만 `await`한다.** 풀링된 소스를 재사용하기 때문이다. 여러 번 필요하면 `Preserve()`로 복제 가능한 형태로 바꾼다. 설치는 패키지 매니저의 git URL로 한다(저장소: [github.com/Cysharp/UniTask](https://github.com/Cysharp/UniTask), 설치 URL은 README를 확인한다).

### 3-3. Unity `Awaitable` (Unity 2023.1부터 내장, Unity 6 포함)

패키지 없이 쓰는 Unity 공식 대안이다. `Awaitable`은 **클래스이지만 내부에서 풀링**해서 할당을 줄인다.

| API | 하는 일 |
|---|---|
| `Awaitable.NextFrameAsync(ct)` | 다음 프레임 |
| `Awaitable.WaitForSecondsAsync(sec, ct)` | 게임 시간으로 대기 |
| `Awaitable.FixedUpdateAsync(ct)` | 다음 `FixedUpdate` |
| `Awaitable.EndOfFrameAsync(ct)` | 프레임 끝 |
| `Awaitable.MainThreadAsync()` / `BackgroundThreadAsync()` | 메인 스레드 ↔ 백그라운드 스레드 전환 |
| `Awaitable.FromAsyncOperation(op, ct)` | `AsyncOperation`을 `Awaitable`로 |

`async Awaitable`, `async Awaitable<T>` 메서드를 만들 수 있다. 이것도 **한 번만 `await`** 한다. 풀링 방식과 세부 동작은 버전에 따라 다르므로 직접 측정해 확인한다.

### 3-4. 비교표

| | 코루틴 | `Task` | UniTask | `Awaitable` |
|---|---|---|---|---|
| 할당 | 시작마다 상태 기계 + `Coroutine` | 비동기 완료마다 `Task` + 박스 | 거의 없음 (`struct` + 풀링) | 내부 풀링 (클래스) |
| 반환값 | 없음 | 있음 | 있음 | 있음 (`Awaitable<T>`) |
| 예외 | 그 코루틴만 종료, 로그 | `await`에서 다시 던져짐 | `await`에서 다시 던져짐 | `await`에서 다시 던져짐 |
| 취소 | `StopCoroutine`, 오브젝트 소멸 | `CancellationToken` | `CancellationToken` | `CancellationToken` |
| 오브젝트와 수명 | 묶여 있음 | 안 묶임 (Day 11) | 안 묶임 (토큰 연결) | 안 묶임 (토큰 연결) |
| 스레드 | 메인만 | 어디든 | 플레이어 루프(메인) + 전환 API | 메인 + `BackgroundThreadAsync` |
| 의존성 | 없음 | .NET (BCL) | 패키지 | 내장 (2023.1+) |

고르는 기준: 오브젝트에 묶인 단순한 연출은 코루틴, 외부 패키지 없이 가볍게는 `Awaitable`, 팀이 이미 쓰고 있고 풍부한 조합/진단이 필요하면 UniTask. 팀에서 쓰는 것을 따르는 것이 가장 중요한 기준이다.

{% hint style="info" %}
NOTE: Unity 6 = C# 9. `async Awaitable`, `UniTask` 모두 C# 9에서 동작한다. `Awaitable`은 Unity 2023.1 이상에서만 있다. 사용하는 Unity 버전에서 API 이름을 확인한다(버전 확인 필요).
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| UniTask | Cysharp의 오픈소스 비동기 라이브러리. `struct` 기반, 거의 할당 없음 |
| `Awaitable` | Unity가 제공하는 `await` 가능 타입. `async Awaitable` 메서드를 만들 수 있다 |
| 풀링(pooling) | 객체를 버리지 않고 모아 두었다가 재사용해 GC 할당을 줄이는 방식 |
| `timeScale` | `Time.timeScale`. `0`이면 게임 시간이 멈춘다. `Task.Delay`는 영향을 받지 않는다 |
| `PlayerLoopTiming` | `Update`, `FixedUpdate` 등 플레이어 루프의 단계 |
| `IValueTaskSource` | 풀링 가능한 `ValueTask`의 완료 상태를 제공하는 .NET 인터페이스 |

## 5. 확인 실습

{% hint style="info" %}
NOTE: AI, 자동완성, 검색 없이 한다. 막히면 `3. 동작 원리`로 돌아간다.
{% endhint %}

### 실습 (Unity, 20분) 🎮: "3초 뒤 로그"를 세 가지로 만들고 GC Alloc 비교

각 방식으로 "3초 기다린 뒤 끝났음을 센다"를 구현하고, **한 프레임에 1000개를 동시에 시작**해서 Profiler(CPU Usage → GC Alloc 열)의 할당을 비교한다. 로그는 마지막 1개만 찍어서 로그 문자열 할당이 섞이지 않게 한다.

**먼저 예측한다:** 코루틴 1000개와 `Awaitable` 1000개 중 어느 쪽이 그 프레임에 더 할당할까?

```csharp
// Unity: CountdownCompare.cs
using System.Collections;
using UnityEngine;

public class CountdownCompare : MonoBehaviour
{
    private const int N = 1000;
    private readonly WaitForSeconds _wait3 = new WaitForSeconds(3f);   // 캐시
    private int _finished;

    [ContextMenu("1) Coroutine x1000")]
    private void RunCoroutines()
    {
        _finished = 0;
        for (int i = 0; i < N; i++) StartCoroutine(CountdownCoroutine());
    }

    private IEnumerator CountdownCoroutine()
    {
        yield return _wait3;
        Done();
    }

    [ContextMenu("2) Awaitable x1000")]
    private void RunAwaitables()
    {
        _finished = 0;
        for (int i = 0; i < N; i++) _ = CountdownAwaitable();
    }

    private async Awaitable CountdownAwaitable()
    {
        await Awaitable.WaitForSecondsAsync(3f, destroyCancellationToken);
        Done();
    }

    private void Done()
    {
        if (++_finished == N) Debug.Log("done x1000");
    }
}
```

선택: UniTask 패키지를 설치했다면 `using Cysharp.Threading.Tasks;`를 추가하고 아래를 같은 클래스에 넣어 3번째 메뉴로 비교한다.

```csharp
[ContextMenu("3) UniTask x1000")]
private void RunUniTasks()
{
    _finished = 0;
    for (int i = 0; i < N; i++) CountdownUniTask().Forget();
}

private async UniTaskVoid CountdownUniTask()
{
    await UniTask.Delay(3000, cancellationToken: this.GetCancellationTokenOnDestroy());
    Done();
}
```

Play 중 `⋮` 메뉴에서 실행하고, Profiler에서 **시작한 프레임**의 `GC Alloc`을 읽어 적어 둔다. 에디터에서는 첫 호출에 풀을 채우는 할당이 있으므로 같은 메뉴를 두 번 실행해서 두 번째 값을 본다.

<details><summary>기대 결과와 해설</summary>

- 정확한 바이트는 Unity/패키지 버전과 에디터/빌드에 따라 다르다. 직접 측정한 값을 적는다.
- 일반적인 경향: 코루틴은 시작마다 상태 기계와 `Coroutine`이 생겨 할당이 시작 횟수에 비례해 보인다. `Awaitable`/UniTask는 풀링 덕에 반복 실행(두 번째 이후)에서 줄어드는지 확인한다. 줄지 않았다면 어디서 할당되는지 Profiler의 호출 스택(Deep Profile 또는 Hierarchy)로 찾아본다.
- `WaitForSeconds`를 캐시하지 않고 `new`로 바꾸면 코루틴의 할당이 얼마나 늘어나는지도 비교해 본다.

</details>

### 대체 실습 (콘솔, 20분): Day 09의 awaiter를 풀링으로 바꿔 바이트 재기

Unity가 없을 때 쓴다. Day 09 `FrameAwaiter`로 `async Task`가 한 번 돌 때의 할당과, 풀링되는 `IValueTaskSource` 기반 `ValueTask`로 만든 `async ValueTask`의 할당을 `GC.GetAllocatedBytesForCurrentThread()`로 비교한다. 요구사항:

1. `FrameLoop`에서 `NextFrame` 한 번이 "다음 `Run` 때 이어서 실행"이 되게 한다. 1000번 반복하고 호출당 평균 바이트를 출력한다(워밍업 후에 잰다).
2. 풀링 쪽은 `FrameSource : IValueTaskSource`(`ManualResetValueTaskSourceCore<int>` 사용)를 `Stack`에 모아 재사용한다. `GetResult`에서 `Reset()` 후 풀에 반환한다.
3. 호출하는 `async ValueTask`에 `[AsyncMethodBuilder(typeof(PoolingAsyncValueTaskMethodBuilder))]`를 붙여 상태 기계 박스까지 풀링한다. **반드시 결과를 소비한다**(`GetAwaiter().GetResult()` 등). 소비하지 않으면 풀로 돌아오지 않는다.

**예측:** 두 값은 대략 얼마일까? 풀링 쪽은 0에 가까울까?

<details><summary>정답 코드와 예상 출력</summary>

```csharp
// 실행 가능: Program.cs
using System.Runtime.CompilerServices;
using System.Threading.Tasks.Sources;

const int N = 1000;
var loop = new FrameLoop();

// 워밍업 (JIT, 풀 채우기)
for (int i = 0; i < 10; i++) { RunTask(loop); RunPooled(loop); }

long b = GC.GetAllocatedBytesForCurrentThread();
for (int i = 0; i < N; i++) RunTask(loop);
long taskBytes = GC.GetAllocatedBytesForCurrentThread() - b;

b = GC.GetAllocatedBytesForCurrentThread();
for (int i = 0; i < N; i++) RunPooled(loop);
long pooledBytes = GC.GetAllocatedBytesForCurrentThread() - b;

Console.WriteLine($"async Task + 일반 awaiter     : {taskBytes / N} B/호출");
Console.WriteLine($"async ValueTask + 풀링 awaiter : {pooledBytes / N} B/호출");

static void RunTask(FrameLoop loop)
{
    _ = CountTask(loop);
    loop.Run(3);
}

static void RunPooled(FrameLoop loop)
{
    var t = CountPooled(loop);
    loop.Run(3);
    t.GetAwaiter().GetResult();      // 결과를 소비해야 풀로 돌아간다
}

static async Task CountTask(FrameLoop loop)
{
    for (int i = 0; i < 3; i++) await new TaskFrameAwaitable(loop);
}

[AsyncMethodBuilder(typeof(PoolingAsyncValueTaskMethodBuilder))]
static async ValueTask CountPooled(FrameLoop loop)
{
    for (int i = 0; i < 3; i++) await loop.NextFramePooled();
}

// Day 09의 awaiter: 매번 새 큐 항목, 구조체라 awaiter 자체는 할당 없음
readonly struct TaskFrameAwaitable
{
    private readonly FrameLoop _loop;
    public TaskFrameAwaitable(FrameLoop loop) => _loop = loop;
    public TaskFrameAwaiter GetAwaiter() => new TaskFrameAwaiter(_loop);
}

readonly struct TaskFrameAwaiter : INotifyCompletion
{
    private readonly FrameLoop _loop;
    public TaskFrameAwaiter(FrameLoop loop) => _loop = loop;
    public bool IsCompleted => false;
    public void OnCompleted(Action continuation) => _loop.Enqueue(continuation);
    public void GetResult() { }
}

// 풀링되는 ValueTask 소스: 재사용 가능한 IValueTaskSource
sealed class FrameSource : IValueTaskSource
{
    private ManualResetValueTaskSourceCore<int> _core;
    private readonly FrameLoop _loop;
    private readonly Action _complete;

    public FrameSource(FrameLoop loop)
    {
        _loop = loop;
        _complete = () => _core.SetResult(0);     // 한 번만 만든 델리게이트
    }

    public ValueTask Start()
    {
        _loop.Enqueue(_complete);
        return new ValueTask(this, _core.Version);
    }

    public void GetResult(short token)
    {
        _core.GetResult(token);
        _core.Reset();                            // 버전을 올리고
        _loop.Return(this);                       // 풀로 돌려준다
    }

    public ValueTaskSourceStatus GetStatus(short token) => _core.GetStatus(token);
    public void OnCompleted(Action<object?> c, object? s, short token, ValueTaskSourceOnCompletedFlags f)
        => _core.OnCompleted(c, s, token, f);
}

class FrameLoop
{
    private List<Action> _next = new(16);
    private List<Action> _cur = new(16);
    private readonly Stack<FrameSource> _pool = new();

    public void Enqueue(Action a) => _next.Add(a);

    public ValueTask NextFramePooled()
    {
        var src = _pool.Count > 0 ? _pool.Pop() : new FrameSource(this);
        return src.Start();
    }

    public void Return(FrameSource s) => _pool.Push(s);

    public void Run(int frames)
    {
        for (int i = 0; i < frames; i++)
        {
            (_cur, _next) = (_next, _cur);
            _next.Clear();
            for (int j = 0; j < _cur.Count; j++) _cur[j]();
        }
    }
}
```

원본 노트가 기록한 출력(64비트, .NET 10 환경. 이 문서 작성 중 다시 측정하지 않았다):
```
async Task + 일반 awaiter     : 168 B/호출
async ValueTask + 풀링 awaiter : 0 B/호출
```

- 정확한 바이트(168)는 .NET 버전에 따라 다르다, 직접 측정해 확인한다. 달라지지 않는 것은 "풀링 쪽이 0에 가깝다"는 경향이다.
- 이것이 UniTask의 원리다. `struct` + 풀링되는 소스 + 풀링되는 상태 기계 박스. 비용은 **한 번만 `await`해야 한다**는 제약이다(`GetResult()` 때 소스가 풀로 돌아가므로 같은 `ValueTask`를 다시 읽으면 안 된다).
- 마이크로 벤치마크라서 수치는 참고용이다. `dotnet run -c Release`로 돌린다.

</details>

## 6. 확인 문제

소리 내어 30초 안에 답해 보고 펼쳐서 비교한다.

**Q1. Unity 프로젝트에서 왜 `Task` 대신 UniTask를 쓰나요?**
<details><summary>모범 답안</summary>
`Task`는 비동기 호출마다 힙 할당이 생기고, 프레임이나 플레이어 루프 시점 개념이 없고, `Task.Delay`가 `timeScale`을 무시하고, 스레드를 쓰는 부분이 WebGL 같은 플랫폼에서 문제가 됩니다. UniTask는 `struct`와 풀링된 소스로 할당이 거의 없고, 플레이어 루프에 붙어서 `NextFrame`, `Yield(PlayerLoopTiming)`, `Delay(ignoreTimeScale)` 같은 게임용 대기를 제공합니다. 취소 토큰 연동과 Tracker 같은 진단 도구도 있습니다.

</details>

**Q2. Unity의 `Awaitable`과 UniTask는 어떻게 다른가요?**
<details><summary>모범 답안</summary>
`Awaitable`은 Unity 2023.1부터 엔진에 내장되어 패키지가 필요 없고, 클래스지만 내부적으로 풀링해서 할당을 줄입니다. UniTask는 외부 오픈소스 패키지로 `struct` 기반이고 대기 종류와 조합, 진단 기능이 더 풍부합니다. 둘 다 한 번만 `await`해야 하고 취소는 `CancellationToken`으로 합니다. 팀이 이미 쓰는 것과 필요한 기능을 보고 고릅니다.

</details>

**Q3. 코루틴 대비 `async` 방식의 장점은 무엇인가요?**
<details><summary>모범 답안</summary>
반환값을 줄 수 있고, `try/catch`로 예외를 호출자가 잡을 수 있고, `CancellationToken`으로 취소를 표준적으로 전파하고, 여러 작업을 조합하기 쉽습니다. 반대로 코루틴은 오브젝트에 수명이 자동으로 묶인다는 장점이 있어서, `async`에서는 오브젝트 파괴 시 취소를 직접 연결해야 합니다.

</details>

**Q4. `UniTask`를 두 번 `await`하면 어떻게 되나요?**
<details><summary>모범 답안</summary>
풀링된 소스를 첫 `await`가 끝나면서 반환하기 때문에, 같은 `UniTask`를 다시 `await`하면 예외가 나거나 잘못된 결과가 나올 수 있습니다. 여러 번 필요하면 `Preserve()`로 복제 가능한 형태로 바꿔야 합니다. `Awaitable`도 마찬가지로 한 번만 `await`합니다.

</details>

## 참조

- [Cysharp/UniTask (GitHub)](https://github.com/Cysharp/UniTask)
- [Unity ScriptReference — Awaitable](https://docs.unity3d.com/ScriptReference/Awaitable.html)
- [Unity ScriptReference — MonoBehaviour.destroyCancellationToken](https://docs.unity3d.com/ScriptReference/MonoBehaviour-destroyCancellationToken.html)
- [ValueTask 구조체](https://learn.microsoft.com/ko-kr/dotnet/api/system.threading.tasks.valuetask)
- [IValueTaskSource 인터페이스](https://learn.microsoft.com/ko-kr/dotnet/api/system.threading.tasks.sources.ivaluetasksource)

이전: [Day 09 · Task와 async/await](day09-task-async-await.md) · 다음: [Day 11 · 취소, 예외, 수명](day11-cancellation-exceptions.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 오늘의 한 줄: 이 날의 핵심을 내 말로 한 문장
- [ ] 코루틴, `Task`, UniTask, `Awaitable` 중 내 프로젝트에 고른다면 무엇이고 그 이유는 무엇인가?
- [ ] `await`한 작업이 오브젝트가 파괴된 뒤에도 계속 실행되어 문제가 된 경험이 있는가? 없다면 어떤 상황에서 생길 수 있는가?
