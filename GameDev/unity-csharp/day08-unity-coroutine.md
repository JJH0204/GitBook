# Day 08 · Unity 코루틴의 내부 🎮

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UCS-009-DO |
| 유형 | D&O (개념) + 확인 실습 |
| 목적 | Unity 코루틴이 스레드가 아니라 Unity가 보관한 `IEnumerator`의 `MoveNext()` 호출임을 설명하고, 재개 시점·수명·한계를 정리한다. |
| 적용 대상 | .NET SDK 8 이상 콘솔 앱(실습 A), Unity 6 (실습 B, 선택) |
| 소요 시간 | 60분 (2주차 비동기) |
| 준비물 | `dotnet new console -o practice/day08`, 🎮 Unity 6 (실습 B, 선택) |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 학습 목표

- 코루틴이 스레드가 아니라 "Unity가 보관한 `IEnumerator`에 `MoveNext()`를 호출하는 것"임을 설명할 수 있다.
- `yield return` 값에 따라 코루틴이 프레임 루프의 어디에서 재개되는지 순서대로 말할 수 있다.
- 코루틴의 수명(`enabled = false`는 못 멈춘다)과 한계(반환값 없음, `try/catch` 안 `yield`, 할당)를 설명할 수 있다.

## 2. 구성 요소

| 요소 | 위치 | 역할 |
|---|---|---|
| `StartCoroutine(IEnumerator)` | `MonoBehaviour` | 상태 기계를 보관하고 첫 `yield return`까지 동기 실행한 뒤 `Coroutine`을 돌려준다 |
| `yield return` 값 | 코루틴 본문 | Unity가 다음 `MoveNext()` 시점을 정하는 기준 |
| `YieldInstruction` 계열 | `WaitForSeconds`, `WaitForFixedUpdate`, `WaitForEndOfFrame` 등 | 대기 조건을 나타내는 객체 |
| `CustomYieldInstruction` | 사용자 정의 | `keepWaiting`이 `false`가 될 때까지 대기 |
| `StopCoroutine` / `StopAllCoroutines` | `MonoBehaviour` | 코루틴을 명시적으로 멈춘다 |
| 소유자(`MonoBehaviour`) | 코루틴을 시작한 컴포넌트 | 게임 오브젝트의 활성·파괴 상태에 코루틴 수명이 묶인다 |

## 3. 동작 원리

### 3-1. 코루틴 = 보관된 `IEnumerator` + 정해진 시점의 `MoveNext()`

[Day 07](day07-iterator-yield.md)에서 `yield return` 메서드는 상태 기계 객체(`IEnumerator`)를 돌려줄 뿐이고, 본문은 `MoveNext()`를 부를 때마다 조금씩 실행된다고 했다. Unity 코루틴은 그 **소비자를 Unity가 맡은 것**이다.

1. `StartCoroutine(Foo())`: `Foo()`가 상태 기계를 만들고, Unity가 그것을 보관한다(`Coroutine` 객체를 돌려준다).
2. **첫 `yield return`까지는 `StartCoroutine` 안에서 동기적으로 실행된다.** 호출한 줄에서 곧바로 코루틴 본문이 돈다.
3. `yield return`으로 나온 값(`Current`)을 보고 Unity가 "언제 다시 `MoveNext()`를 부를지" 정한다.
4. 메인 스레드에서만 돈다. 스레드를 만들지 않는다. 한 프레임 안에서 코루틴 본문이 오래 걸리면 그만큼 프레임이 늦어진다.

### 3-2. `yield return` 값과 재개 시점

| `yield return` 값 | 재개 시점 |
|---|---|
| `null` | 다음 프레임, 모든 `Update`가 끝난 뒤 (`LateUpdate` 전) |
| `WaitForSeconds(t)` | `Time.timeScale`의 영향을 받는 시간(scaled time)이 `t` 지난 뒤 첫 프레임의 `Update` 뒤 |
| `WaitForSecondsRealtime(t)` | `timeScale`을 무시한 실제 시간이 `t` 지난 뒤 |
| `WaitForFixedUpdate` | 다음 `FixedUpdate`(물리 단계)가 끝난 뒤 |
| `WaitForEndOfFrame` | 그 프레임의 렌더링이 끝난 뒤 |
| 다른 `Coroutine` | 그 코루틴이 끝났을 때 (`yield return StartCoroutine(Child())`) |
| `CustomYieldInstruction` | `keepWaiting`이 `false`가 될 때 (프레임마다 `Update` 뒤에 확인) |
| `AsyncOperation` | 작업이 끝났을 때 (`SceneManager.LoadSceneAsync` 등) |

`WaitForSeconds(0.1f)`는 "정확히 0.1초 뒤"가 아니라 "0.1초가 지난 **첫 프레임의** `Update` 뒤"다. 프레임 시간만큼 오차가 난다.

### 3-3. 프레임 루프 안의 위치

```
FixedUpdate  ──▶ (WaitForFixedUpdate 재개) ──▶ 물리 ...
Update       ──▶ (null / WaitForSeconds / WaitForSecondsRealtime / CustomYieldInstruction 재개)
LateUpdate
렌더링       ──▶ (WaitForEndOfFrame 재개)
```

`FixedUpdate`는 프레임당 0번 이상 돈다(고정 시간 간격이라서). 전체 순서는 [Unity 공식 실행 순서 문서](https://docs.unity3d.com/Manual/execution-order.html)의 그림으로 확인한다.

### 3-4. 수명: 누가 코루틴을 소유하나

코루틴은 **시작한 `MonoBehaviour`가 소유**한다.

| 상황 | 코루틴 |
|---|---|
| `enabled = false` (컴포넌트만 끔) | **계속 돈다** (`Update`는 멈춰도) |
| `gameObject.SetActive(false)` | 멈춘다. 다시 켜도 **재시작되지 않는다** |
| `Destroy` (컴포넌트 또는 오브젝트) | 멈춘다 |
| `StopCoroutine(handle)` | 그 코루틴만 멈춘다. `StartCoroutine`이 돌려준 `Coroutine`을 보관해 두어야 한다 |
| `StopAllCoroutines()` | 이 컴포넌트가 시작한 것을 모두 멈춘다 |

### 3-5. 코루틴의 한계

- **반환값이 없다.** 결과를 받으려면 콜백이나 필드를 쓴다. (`IEnumerator`의 `Current`는 "기다릴 대상"을 넘기는 통로다.)
- **`try`에 `catch`가 있으면 그 안에서 `yield return`을 못 쓴다.** `error CS1626`. `try/finally`는 된다.
- **예외가 나면 그 코루틴만 끝난다.** 호출한 쪽으로 전파되지 않고, Unity가 콘솔에 로그를 남긴다. 다른 코루틴과 컴포넌트는 영향이 없다.
- 시작한 오브젝트와 수명이 묶여 있어서 편하지만, 그 밖의 수명(씬 전환 너머, 여러 오브젝트가 공유)에는 쓰기 어렵다.

### 3-6. 할당

- `StartCoroutine` 한 번: 상태 기계 객체 + `Coroutine` 객체. 코루틴이 `yield return`하는 값이 `new WaitForSeconds(...)`처럼 새 객체이면 그만큼 더 쌓인다.
- 같은 대기 시간이면 **한 번 만들어 필드에 캐시**해서 재사용한다. 값이 바뀌지 않는 `WaitForSeconds`는 재사용해도 안전하다.

```csharp
private readonly WaitForSeconds _wait = new WaitForSeconds(0.5f);   // 캐시

IEnumerator Blink()
{
    while (true)
    {
        yield return _wait;       // 매번 new WaitForSeconds(0.5f)를 만들지 않는다
        // ...
    }
}
```

{% hint style="info" %}
NOTE: Unity 6 = C# 9 + Mono/IL2CPP. 코루틴 자체는 C# 버전과 무관하다. 위 필드 초기화처럼 C# 9 문법 안에서 쓴다. 반환값/취소/예외 처리가 필요할 때의 대안(`async`)은 Day 09–11에서 다룬다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 코루틴(coroutine) | `IEnumerator`를 반환하고 `yield return`으로 실행을 나눠 프레임에 걸쳐 진행하는 Unity 메서드 |
| `Coroutine` | `StartCoroutine`이 돌려주는 핸들 객체. `StopCoroutine`에 쓴다 |
| scaled time | `Time.timeScale`의 영향을 받는 시간. `WaitForSeconds`가 쓴다 |
| unscaled(real) time | `timeScale`을 무시한 시간. `WaitForSecondsRealtime`이 쓴다 |
| 플레이어 루프(player loop) | `FixedUpdate`, `Update`, `LateUpdate`, 렌더링 등 프레임 처리 순서 |
| CS1626 | `catch`가 있는 `try` 블록 안에서 `yield return`을 쓸 때 나는 컴파일 오류 |

## 5. 확인 실습

{% hint style="info" %}
NOTE: AI, 자동완성, 검색 없이 한다. 막히면 `3. 동작 원리`로 돌아간다.
{% endhint %}

### 실습 A: 미니 코루틴 스케줄러 만들기 (20분, 콘솔)

Unity 없이 코루틴의 원리를 재현한다. 요구사항:

1. 프레임 루프 `Run(frames)`: 한 번 돌 때마다 `Frame`이 1 증가하고, `Time = Frame * 0.1` (가짜 시계: 프레임당 0.1초).
2. `List<IEnumerator>`로 루틴을 관리한다. `Start(IEnumerator)`는 **첫 `yield`까지 즉시(동기) 실행**한다.
3. `yield return null`은 다음 프레임에 재개. `new WaitFrames(n)`은 `n`프레임 뒤, `new WaitSeconds(t)`는 가짜 시계로 `t`초 이상 지난 첫 프레임에 재개.
4. 루틴이 다른 `IEnumerator`를 `yield return`하면, **그 안쪽 루틴이 끝날 때까지 먼저 실행**한 뒤 바깥 루틴을 이어간다. (`Stack<IEnumerator>`를 쓴다. 이것은 우리 스케줄러의 규칙이다. Unity에서는 `yield return StartCoroutine(Child())`로 쓴다.)

테스트 시나리오 (스케줄러 밖에서 작성한다):

```csharp
sched.Start(Parent());
sched.Start(Ticker());
sched.Run(7);

IEnumerator Parent()
{
    Log("parent start");
    yield return new WaitFrames(2);
    Log("parent after 2 frames");
    yield return Child();
    Log("parent after child");
    yield return new WaitSeconds(0.25);
    Log("parent after 0.25s");
}
IEnumerator Child()  { Log("  child start"); yield return null; Log("  child after 1 frame"); }
IEnumerator Ticker() { for (int i = 0; i < 3; i++) { Log($"ticker {i}"); yield return null; } }
// Log(msg) => Console.WriteLine($"[f{sched.Frame} t={sched.Time:F1}] {msg}")
```

**먼저 종이에 출력을 추적해 본다.** 특히 `f2`와 `f3`에서 한 프레임에 몇 줄이 찍히는지, `parent after 0.25s`가 몇 프레임인지.

<details><summary>예상 출력</summary>

```
[f0 t=0.0] parent start
[f0 t=0.0] ticker 0
[f1 t=0.1] ticker 1
[f2 t=0.2] parent after 2 frames
[f2 t=0.2]   child start
[f2 t=0.2] ticker 2
[f3 t=0.3]   child after 1 frame
[f3 t=0.3] parent after child
[f6 t=0.6] parent after 0.25s
```

- `Start`는 첫 `yield`까지 실행하므로 `parent start`, `ticker 0`은 프레임 0(루프 시작 전)에 찍힌다.
- `f3`: 안쪽 `Child`가 끝나자마자 같은 `MoveNext` 흐름에서 바깥 `Parent`가 이어진다.
- `WaitSeconds(0.25)`는 `f3`(0.3초)에 시작해 0.55초 이상이 되는 첫 프레임인 `f6`(0.6초)에 재개된다.

</details>

<details><summary>정답 코드</summary>

```csharp
// 실행 가능: Program.cs
using System.Collections;

var sched = new Scheduler();
sched.Start(Parent());
sched.Start(Ticker());
sched.Run(7);

void Log(string msg) => Console.WriteLine($"[f{sched.Frame} t={sched.Time:F1}] {msg}");

IEnumerator Parent()
{
    Log("parent start");
    yield return new WaitFrames(2);
    Log("parent after 2 frames");
    yield return Child();
    Log("parent after child");
    yield return new WaitSeconds(0.25);
    Log("parent after 0.25s");
}

IEnumerator Child()
{
    Log("  child start");
    yield return null;
    Log("  child after 1 frame");
}

IEnumerator Ticker()
{
    for (int i = 0; i < 3; i++)
    {
        Log($"ticker {i}");
        yield return null;
    }
}

abstract class Wait
{
    public abstract void Begin(Scheduler s);
    public abstract bool Done(Scheduler s);
}

class WaitFrames : Wait
{
    private readonly int _n;
    private int _target;
    public WaitFrames(int n) => _n = n;
    public override void Begin(Scheduler s) => _target = s.Frame + _n;
    public override bool Done(Scheduler s) => s.Frame >= _target;
}

class WaitSeconds : Wait
{
    private readonly double _t;
    private double _wake;
    public WaitSeconds(double t) => _t = t;
    public override void Begin(Scheduler s) => _wake = s.Time + _t;
    public override bool Done(Scheduler s) => s.Time >= _wake - 1e-9;
}

class Scheduler
{
    private class Routine
    {
        public readonly Stack<IEnumerator> Stack = new();
        public Wait? Wait;
    }

    private readonly List<Routine> _routines = new();
    public int Frame { get; private set; }
    public double Time => Frame * 0.1;

    public void Start(IEnumerator body)
    {
        var r = new Routine();
        r.Stack.Push(body);
        if (Advance(r)) _routines.Add(r);   // 첫 yield까지는 동기 실행
    }

    public void Run(int frames)
    {
        for (int i = 0; i < frames; i++)
        {
            Frame++;
            for (int j = 0; j < _routines.Count; j++)
            {
                var r = _routines[j];
                if (r.Wait == null || r.Wait.Done(this))
                {
                    if (!Advance(r)) { _routines.RemoveAt(j); j--; }
                }
            }
        }
    }

    // 다음 yield까지 실행. 루틴이 끝났으면 false.
    private bool Advance(Routine r)
    {
        while (r.Stack.Count > 0)
        {
            var top = r.Stack.Peek();
            if (!top.MoveNext()) { r.Stack.Pop(); continue; }
            switch (top.Current)
            {
                case IEnumerator inner:
                    r.Stack.Push(inner);          // 중첩: 안쪽을 먼저 끝까지
                    continue;
                case Wait w:
                    w.Begin(this);
                    r.Wait = w;
                    return true;
                default:                          // null = 다음 프레임
                    r.Wait = null;
                    return true;
            }
        }
        return false;
    }
}
```

핵심은 `Advance`다. 스택 맨 위 `IEnumerator`에 `MoveNext()`를 부르고, `Current`가 `IEnumerator`면 푸시, 대기 객체면 저장하고 반환, `null`이면 "다음 프레임"으로 반환한다. 끝나면 팝해서 바깥으로 돌아간다. Unity가 하는 일도 이 모양의 훨씬 정교한 버전이다.

</details>

### 실습 B (선택): Unity에서 재개 시점 확인하기 (10분) 🎮

빈 씬의 오브젝트에 아래 스크립트를 붙이고 Play한 뒤 콘솔에서 `frameCount`와 단계를 읽는다. **실행 전에 `after ...` 4줄이 어느 단계 로그 바로 뒤에 찍힐지 예측한다.**

```csharp
// Unity: YieldOrderProbe.cs
using System.Collections;
using UnityEngine;

public class YieldOrderProbe : MonoBehaviour
{
    private void Start() => StartCoroutine(Probe());

    private IEnumerator Probe()
    {
        Log("start");
        yield return null;
        Log("after null");
        yield return new WaitForSeconds(0.1f);
        Log("after WaitForSeconds");
        yield return new WaitForFixedUpdate();
        Log("after WaitForFixedUpdate");
        yield return new WaitForEndOfFrame();
        Log("after WaitForEndOfFrame");
    }

    private void FixedUpdate() => Log("FixedUpdate");
    private void Update() => Log("Update");
    private void LateUpdate() => Log("LateUpdate");

    private static void Log(string msg) => Debug.Log($"[f{Time.frameCount}] {msg}");
}
```

이어서 수명도 확인한다. 아래 스크립트를 붙이고, Play 중 컴포넌트 `⋮` 메뉴에서 `Disable Component` → 로그 확인 → `Deactivate GameObject` → 로그 확인 순서로 실행한다.

```csharp
// Unity: LifetimeProbe.cs
using System.Collections;
using UnityEngine;

public class LifetimeProbe : MonoBehaviour
{
    private void Start() => StartCoroutine(Tick());

    private IEnumerator Tick()
    {
        while (true)
        {
            Debug.Log($"[f{Time.frameCount}] coroutine tick");
            yield return new WaitForSeconds(0.5f);
        }
    }

    private void Update() { if (Time.frameCount % 60 == 0) Debug.Log("Update"); }

    [ContextMenu("Disable Component")] private void DisableComponent() => enabled = false;
    [ContextMenu("Deactivate GameObject")] private void DeactivateGO() => gameObject.SetActive(false);
}
```

<details><summary>기대 결과</summary>

- 단계 로그와 `after ...`의 위치는 [공식 실행 순서](https://docs.unity3d.com/Manual/execution-order.html)와 같아야 한다: `after null`/`after WaitForSeconds`는 해당 프레임 `Update` 뒤(`LateUpdate` 앞), `after WaitForEndOfFrame`은 `LateUpdate`와 렌더링 뒤. 정확한 프레임 번호와 `FixedUpdate` 횟수는 환경에 따라 다르다.
- `Disable Component` 뒤: `Update` 로그는 멈추지만 `coroutine tick`은 계속 찍힌다.
- `Deactivate GameObject` 뒤: `coroutine tick`이 멈춘다. 인스펙터에서 다시 활성화해도 재개되지 않는다.

</details>

## 6. 확인 문제

소리 내어 30초 안에 답해 보고 펼쳐서 비교한다.

**Q1. Unity 코루틴은 멀티스레드인가요? 내부는 어떻게 동작하나요?**
<details><summary>모범 답안</summary>
아닙니다. 메인 스레드에서만 돌아갑니다. `yield return`이 있는 메서드는 컴파일러가 상태 기계 `IEnumerator`로 바꾸는데, Unity가 그 객체를 보관하다가 프레임 루프의 정해진 시점에 `MoveNext()`를 호출합니다. `yield return`한 값(`null`, `WaitForSeconds` 등)이 다음에 언제 `MoveNext()`를 부를지를 정합니다.

</details>

**Q2. 컴포넌트를 `enabled = false`로 끄면 그 컴포넌트의 코루틴은 어떻게 되나요?**
<details><summary>모범 답안</summary>
계속 실행됩니다. 코루틴은 컴포넌트의 활성 여부가 아니라, 시작한 `MonoBehaviour`가 속한 게임 오브젝트의 활성 상태와 파괴 여부에 묶여 있습니다. `SetActive(false)`나 `Destroy`를 하면 멈추고, 다시 활성화해도 자동으로 재시작되지 않습니다. 컴포넌트만 끄고 코루틴도 멈추려면 `StopCoroutine`이나 `StopAllCoroutines`를 직접 불러야 합니다.

</details>

**Q3. `new WaitForSeconds`를 왜 캐시하나요?**
<details><summary>모범 답안</summary>
`WaitForSeconds`는 참조 타입이라 `yield return new WaitForSeconds(t)`를 반복하면 호출마다 힙 객체가 생겨 GC 압력이 됩니다. 대기 시간이 같다면 필드에 한 번만 만들어 재사용하면 됩니다. 대기 시간이 매번 다르면 캐시 대상이 아니고, 얼마나 영향이 있는지는 Profiler의 GC Alloc으로 측정해 판단합니다.

</details>

**Q4. 코루틴 안에서 예외가 나면 어떻게 되고, `yield return`을 `try/catch` 안에서 쓸 수 있나요?**
<details><summary>모범 답안</summary>
예외가 나면 그 코루틴만 종료되고 Unity가 콘솔에 로그를 남깁니다. 호출한 코드로 전파되지 않아서 호출자가 잡을 수 없습니다. 그리고 `catch`가 있는 `try` 블록 안에서는 `yield return`을 쓸 수 없어서 CS1626 컴파일 오류가 납니다. `try/finally`는 가능합니다.

</details>

## 참조

- [Unity 매뉴얼 — 코루틴](https://docs.unity3d.com/Manual/Coroutines.html)
- [Unity 매뉴얼 — 이벤트 함수의 실행 순서](https://docs.unity3d.com/Manual/execution-order.html)
- [MonoBehaviour.StartCoroutine](https://docs.unity3d.com/ScriptReference/MonoBehaviour.StartCoroutine.html)
- [CustomYieldInstruction](https://docs.unity3d.com/ScriptReference/CustomYieldInstruction.html)
- [yield 문 (C# 참조)](https://learn.microsoft.com/ko-kr/dotnet/csharp/language-reference/statements/yield)

이전: [Day 07 · IEnumerator와 yield의 정체](day07-iterator-yield.md) · 다음: [Day 09 · Task와 async/await](day09-task-async-await.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 오늘의 한 줄: 이 날의 핵심을 내 말로 한 문장
- [ ] `enabled = false`와 `SetActive(false)`가 코루틴에 미치는 영향이 다른 이유를 내 말로 설명하면?
- [ ] 내가 코루틴으로 만든 기능(또는 만들 기능)에서 `WaitForSeconds` 대신 `WaitForSecondsRealtime`이 필요한 경우는 언제인가?
