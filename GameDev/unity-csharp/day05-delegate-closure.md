# Day 05 · 델리게이트, 람다, 클로저

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UCS-006-DO |
| 유형 | D&O (개념) + 확인 실습 |
| 목적 | 델리게이트·람다·클로저의 할당 조건을 설명하고, 이벤트 구독 해제 누락으로 생기는 누수와 `MissingReferenceException`을 막는다. |
| 적용 대상 | .NET 8 이상 콘솔(`dotnet new console -o practice/day05`), Unity 6(C# 9)와 다른 점은 본문에 표시 |
| 소요 시간 | 60분 (1주차 C# 메모리, 읽기 20분 + 확인 실습 30분 + 확인 문제 10분) |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 학습 목표
- 델리게이트 변환과 람다 식이 언제 힙 할당을 일으키고 언제 캐시되는지 설명할 수 있다.
- 클로저(`closure`)가 값이 아니라 변수를 캡처한다는 뜻과 컴파일러가 만드는 표시 클래스(`display class`)를 설명할 수 있다.
- `event` 구독 해제를 잊었을 때 왜 메모리 누수와 Unity `MissingReferenceException`이 발생하는지 설명하고 고칠 수 있다.

## 2. 구성 요소

| 요소 | 위치 | 역할 |
|---|---|---|
| 델리게이트(`Action`, `Func<T>`) | 힙 (참조 타입, 64비트 .NET 인스턴스 64 B) | 대상 객체(`Target`)와 메서드 포인터를 담는다 |
| 메서드 그룹 변환 | 메서드를 델리게이트 자리에 넘기는 지점 | 인스턴스 메서드는 넘길 때마다 새 델리게이트를 할당한다 |
| 비캡처 람다 | 람다 식 | 컴파일러가 숨은 `static` 필드에 1회 만들어 재사용한다 |
| 캡처 람다(클로저) | 람다 식 | 표시 클래스 인스턴스와 델리게이트를 매번 할당한다 (회당 88 B) |
| `event` | 발행자 클래스 | `+=`/`-=`만 노출한다. 구독자 참조를 델리게이트가 붙잡는다 |
| `OnEnable` / `OnDisable` | `MonoBehaviour` | 구독과 해제를 짝지어 두는 자리 |

## 3. 동작 원리

### 3-1. 델리게이트는 참조 타입이다

`Action`, `Func<T>` 같은 **델리게이트(`delegate`)**는 내부에 대상 객체 참조(`Target`)와 메서드 포인터(`Method`)를 담는 **클래스(참조 타입)**다. 64비트 .NET에서 델리게이트 인스턴스 하나는 **64바이트**다.

```csharp
void Execute(Action job) => job();

Execute(MyMethod); // 메서드 그룹 변환: 호출할 때마다 new Action(this, MyMethod) 할당!
```

- **인스턴스 메서드 그룹(`this.MyMethod`)**: C# 버전에 상관없이 넘길 때마다 새 델리게이트(64B)를 힙에 할당한다. 반복 호출한다면 필드에 `Action _cached;`로 저장해 재사용해야 한다.
- **`static` 메서드 그룹(`StaticMethod`)**: **C# 11(.NET 7+)부터는 컴파일러가 자동 캐시**하지만, **Unity 6(C# 9)은 캐시하지 않아 호출마다 델리게이트를 새로 할당**한다(Mono/IL2CPP의 델리게이트 크기는 .NET과 다르다).

{% hint style="info" %}
NOTE: 메서드 그룹 캐시는 C# 11 컴파일러 기능이다. 사용하는 Unity 버전의 C# 버전에 따라 다르므로 버전 확인 필요.
{% endhint %}

### 3-2. 람다와 클로저(`closure`)

람다 식은 외부 변수를 **캡처(`capture`)하는지**에 따라 컴파일 결과가 완전히 달라진다.

| 종류 | 코드 예 | 컴파일러가 하는 일 | 10,000회 루프 호출 시 할당 |
|---|---|---|---|
| 비캡처 람다 | `x => x + 1` | 숨은 `static` 필드에 델리게이트를 **딱 1번** 만들어 재사용 | 최초 1회(수십 바이트), 이후 **0 B** |
| 캡처 람다(클로저) | `x => x + local` | 캡처한 변수를 필드로 가진 숨은 클래스(**표시 클래스, `display class`**)를 만들고, 그 인스턴스(24B+)와 델리게이트(64B)를 매번 생성 | 회당 88B × 10,000 = **880,000 B** |

C# 9부터는 람다 앞에 `static` 키워드(`static x => x + 1`)를 붙여 실수로 지역 변수나 `this`를 캡처하는 것을 컴파일 타임에 막을 수 있다. Unity 6에서도 쓸 수 있다.

### 3-3. 클로저는 "값"이 아니라 "변수"를 캡처한다

```csharp
var actions = new List<Action>();
for (int i = 0; i < 3; i++)
    actions.Add(() => Console.Write(i)); // 세 람다가 모두 같은 i 변수를 바라봄!

foreach (var a in actions) a(); // 출력: 333
```

`for`문의 `i`는 루프 전체에서 변수 하나다. 컴파일러는 `i`를 표시 클래스의 필드 하나로 끌어올리고(`hoisting`), 세 람다가 그 객체 하나를 공유한다. 루프가 끝날 때 `i`가 3이 되었으므로 모두 3을 찍는다.
반면 **`foreach`의 반복 변수는 C# 5부터 매 반복마다 새 변수로 취급**되어 각 클로저가 서로 다른 값을 갖는다. `for`문에서는 루프 안에 `int copy = i;` 지역 변수를 만들어 캡처하면 해결된다.

### 3-4. `event`와 메모리 누수

`event`는 델리게이트 필드 주위에 `add`(`+=`)와 `remove`(`-=`) 접근자만 노출한 래퍼다. 외부 클래스에서 직접 호출(`Invoke`)하거나 `= null`로 덮어쓸 수 없다. 델리게이트는 **불변(`immutable`)**이라서 `+=`나 `-=`를 할 때마다 내부 호출 목록 배열을 복사한 **새 델리게이트 객체**가 만들어진다.

**메모리 누수 구조**:
`발행자(Publisher) ──(event 델리게이트의 Target)──▶ 구독자(Subscriber)`

발행자가 살아 있는 한, 구독자가 `-=`로 구독을 해제하지 않으면 발행자의 델리게이트가 구독자 참조를 붙잡고 있어 **구독자가 GC에 수거되지 않는다.**

```csharp
// Unity 권장 패턴 (C# 9)
void OnEnable()  { GameManager.Instance.OnScoreChanged += RefreshUI; }
void OnDisable() { GameManager.Instance.OnScoreChanged -= RefreshUI; }
```

Unity에서 구독 해제를 안 한 채 구독자 `GameObject`가 `Destroy`되면 두 가지 문제가 동시에 터진다.
1. C# 래퍼 객체(`MonoBehaviour`)가 메모리에 계속 남는다(누수).
2. 이벤트가 발생할 때 이미 파괴된 네이티브 객체의 `transform`이나 `gameObject`에 접근해 **`MissingReferenceException`**이 발생한다(Day 20).

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 클로저(closure) | 람다가 바깥 지역 변수·`this`를 캡처해 수명을 연장하는 기능 |
| 표시 클래스(display class) | 캡처된 변수를 필드로 갖도록 컴파일러가 만드는 숨은 클래스 |
| 호이스팅(hoisting) | 캡처된 지역 변수를 표시 클래스의 필드로 끌어올리는 일 |
| 메서드 그룹(method group) | 괄호 없이 쓴 메서드 이름. 델리게이트로 변환된다 |
| `MissingReferenceException` | 파괴된 Unity 오브젝트에 접근할 때 발생하는 예외 |

## 5. 확인 실습

{% hint style="info" %}
NOTE: AI, 자동완성, 검색 없이 한다. 막히면 3절 동작 원리로 돌아간다.
{% endhint %}

### 실습 1: `for` 루프 캡처 버그 예측과 수정 (10분)

아래 코드의 첫 줄 출력을 예측해 적고 실행한 뒤, `0 1 2`가 찍히도록 고친다.

```csharp
// 실행 가능: Program.cs
var bugActions = new List<Action>();
for (int i = 0; i < 3; i++)
    bugActions.Add(() => Console.Write($"{i} "));

Console.Write("버그: ");
foreach (var a in bugActions) a();
Console.WriteLine();

var fixedActions = new List<Action>();
for (int i = 0; i < 3; i++)
{
    int copy = i;
    fixedActions.Add(() => Console.Write($"{copy} "));
}

Console.Write("수정: ");
foreach (var a in fixedActions) a();
Console.WriteLine();
```

<details><summary>예상 출력과 해설</summary>

```
버그: 3 3 3 
수정: 0 1 2 
```

`int copy = i;`는 반복마다 새 지역 변수이므로 매 반복마다 별도의 표시 클래스 인스턴스가 생성되어 그때의 값을 간직한다.

</details>

### 실습 2: 5가지 전달 방식의 10,000회 할당 바이트 측정 (10분)

10,000회 루프에서 (1) `static` 메서드 그룹, (2) 인스턴스 메서드 그룹, (3) 미리 캐시한 델리게이트, (4) 비캡처 `static` 람다, (5) 지역 변수 캡처 람다를 넘길 때의 할당 바이트를 예측하고 측정한다.

<details><summary>정답 코드와 예상 출력</summary>

```csharp
// 실행 가능: Program.cs
using System.Runtime.CompilerServices;

const int N = 10_000;
var worker = new Worker { Step = 1 };
Func<int, int> cached = worker.InstanceAdd;
int factor = 5;

// 워밍업
Run(StaticAdd);
Run(worker.InstanceAdd);
Run(cached);

long b0 = GC.GetAllocatedBytesForCurrentThread();
for (int i = 0; i < N; i++) Run(StaticAdd);
long staticGroupBytes = GC.GetAllocatedBytesForCurrentThread() - b0;

b0 = GC.GetAllocatedBytesForCurrentThread();
for (int i = 0; i < N; i++) Run(worker.InstanceAdd);
long instanceGroupBytes = GC.GetAllocatedBytesForCurrentThread() - b0;

b0 = GC.GetAllocatedBytesForCurrentThread();
for (int i = 0; i < N; i++) Run(cached);
long cachedBytes = GC.GetAllocatedBytesForCurrentThread() - b0;

b0 = GC.GetAllocatedBytesForCurrentThread();
for (int i = 0; i < N; i++) Run(static x => x + 1);
long nonCaptureBytes = GC.GetAllocatedBytesForCurrentThread() - b0;

b0 = GC.GetAllocatedBytesForCurrentThread();
for (int i = 0; i < N; i++)
{
    int local = factor + i;
    Run(x => x + local);
}
long captureBytes = GC.GetAllocatedBytesForCurrentThread() - b0;

Console.WriteLine($"1) static 메서드 그룹 (C# 11+): {staticGroupBytes} B");
Console.WriteLine($"2) 인스턴스 메서드 그룹       : {instanceGroupBytes} B");
Console.WriteLine($"3) 캐시한 델리게이트          : {cachedBytes} B");
Console.WriteLine($"4) 비캡처 람다 (static)       : {nonCaptureBytes} B");
Console.WriteLine($"5) 지역 변수 캡처 람다        : {captureBytes} B");

[MethodImpl(MethodImplOptions.NoInlining)]
static int Run(Func<int, int> fn) => fn(10);

static int StaticAdd(int x) => x + 1;

class Worker
{
    public int Step;
    public int InstanceAdd(int x) => x + Step;
}
```

출력:
```
1) static 메서드 그룹 (C# 11+): 0 B
2) 인스턴스 메서드 그룹       : 640000 B
3) 캐시한 델리게이트          : 0 B
4) 비캡처 람다 (static)       : 88 B
5) 지역 변수 캡처 람다        : 880000 B
```

- 1번은 C# 11+에서는 워밍업 때 캐시되어 0B지만, **Unity 6(C# 9)에서는 2번처럼 매번 델리게이트가 할당**된다.
- 2번은 매번 64B 델리게이트를 새로 만들고, 3번처럼 필드에 캐시하면 0B가 된다.
- 4번은 루프 첫 실행에 정적 캐시를 초기화하며 단 1번만 할당하고 나머지 9,999회는 0B다. 88B는 델리게이트(64B)와 컴파일러가 만든 숨은 클래스의 싱글턴 인스턴스(24B)다(.NET 9, 10 기준).
- 5번은 매회 클로저 객체(24B) + 델리게이트(64B) = 88B씩 할당한다.

</details>

### 실습 3: `WeakReference`로 이벤트 메모리 누수 확인하기 (10분)

메서드 안에서 만든 `Subscriber`를 `EventPublisher`의 이벤트에 등록만 하고 나온 경우와, 등록 후 해제(`-=`)하고 나온 경우에 대해 `GC.Collect()` 후 객체가 살아 있는지(`WeakReference.IsAlive`) 확인한다.

<details><summary>정답 코드와 예상 출력</summary>

```csharp
// 실행 가능: Program.cs
using System.Runtime.CompilerServices;

var publisher = new EventPublisher();
WeakReference leakedRef = RegisterWithoutUnsubscribe(publisher);
WeakReference cleanedRef = RegisterWithUnsubscribe(publisher);

GC.Collect();
GC.WaitForPendingFinalizers();
GC.Collect();

Console.WriteLine($"해제 안 한 구독자 생존: {leakedRef.IsAlive}");
Console.WriteLine($"해제한 구독자 생존    : {cleanedRef.IsAlive}");
publisher.Raise();
GC.KeepAlive(publisher);

[MethodImpl(MethodImplOptions.NoInlining)]
static WeakReference RegisterWithoutUnsubscribe(EventPublisher pub)
{
    var sub = new Subscriber();
    pub.OnTick += sub.Handle;
    return new WeakReference(sub);
}

[MethodImpl(MethodImplOptions.NoInlining)]
static WeakReference RegisterWithUnsubscribe(EventPublisher pub)
{
    var sub = new Subscriber();
    pub.OnTick += sub.Handle;
    pub.OnTick -= sub.Handle;
    return new WeakReference(sub);
}

class EventPublisher
{
    public event Action? OnTick;
    public void Raise() => OnTick?.Invoke();
}

class Subscriber { public void Handle() { } }
```

출력:
```
해제 안 한 구독자 생존: True
해제한 구독자 생존    : False
```

</details>

## 6. 확인 문제

소리 내어 30초 안에 답해 보고 펼쳐서 비교한다.

**Q1. 클로저(Closure)가 무엇이고 내부적으로 어떻게 동작하나요?**
<details><summary>모범 답안</summary>
클로저는 람다 식이나 익명 메서드가 자신이 정의된 바깥 범위의 지역 변수나 `this`를 캡처해 생명주기를 연장하는 기능입니다. 컴파일러는 캡처된 변수를 필드로 갖는 숨은 클래스(Display Class)를 생성하고, 원래 스택에 있어야 할 지역 변수를 그 힙 객체의 필드로 옮겨 람다와 원래 메서드가 함께 참조하게 만듭니다.

</details>

**Q2. 람다 식을 쓰면 무조건 가비지(힙 할당)가 발생하나요?**
<details><summary>모범 답안</summary>
아닙니다. 외부 변수나 `this`를 전혀 캡처하지 않는 람다는 컴파일러가 숨은 `static` 필드에 델리게이트를 최초 한 번만 생성해 캐시하므로 이후 호출에서는 할당이 없습니다. 반면 지역 변수나 인스턴스 멤버를 캡처하면 호출될 때마다 클로저 객체와 델리게이트 인스턴스가 새로 할당됩니다. C# 9의 `static` 람다를 쓰면 실수로 캡처하는 것을 컴파일 타임에 방지할 수 있습니다.

</details>

**Q3. C#에서 `event`로 인한 메모리 누수는 왜 발생하고 Unity에서는 어떻게 예방하나요?**
<details><summary>모범 답안</summary>
이벤트 발행자가 내부 델리게이트의 `Target`으로 구독자 객체의 참조를 들고 있기 때문에, 발행자의 수명이 구독자보다 길면 구독자가 더 이상 쓰이지 않아도 GC가 수거하지 못합니다. Unity에서는 싱글톤 매니저의 이벤트를 구독한 `MonoBehaviour`가 파괴될 때 해제하지 않으면 메모리 누수뿐 아니라 이미 파괴된 객체에 접근하는 `MissingReferenceException`이 발생할 수 있어, `OnEnable`에서 구독(`+=`)하고 `OnDisable`이나 `OnDestroy`에서 반드시 해제(`-=`)해야 합니다.

</details>

**Q4. `for (int i = 0; i < 5; i++)` 안에서 `() => Print(i)` 람다를 등록하면 왜 모두 5를 출력하나요?**
<details><summary>모범 답안</summary>
람다는 캡처 시점의 값이 아니라 변수 `i` 자체(정확히는 표시 클래스의 필드 하나)를 공유하기 때문입니다. `for` 루프 전체에서 `i`는 하나뿐이므로 루프가 끝난 뒤 람다들을 실행하면 모두 최종값인 5를 읽게 됩니다. 루프 본문 안에 `int copy = i;`처럼 반복마다 새로 만들어지는 지역 변수를 선언해 캡처하면 해결됩니다.

</details>

## 참조

- [람다 식 및 익명 함수 — 외부 변수 캡처 (C# 참조)](https://learn.microsoft.com/ko-kr/dotnet/csharp/language-reference/operators/lambda-expressions#capture-of-outer-variables-and-variable-scope-in-lambda-expressions)
- [대리자 사용 (C# 프로그래밍 가이드)](https://learn.microsoft.com/ko-kr/dotnet/csharp/programming-guide/delegates/using-delegates)
- [event (C# 참조)](https://learn.microsoft.com/ko-kr/dotnet/csharp/language-reference/keywords/event)
- [이벤트를 구독 및 구독 취소하는 방법](https://learn.microsoft.com/ko-kr/dotnet/csharp/programming-guide/events/how-to-subscribe-to-and-unsubscribe-from-events)

이전: [Day 04 · struct 제대로 쓰기](day04-struct-in-practice.md) · 다음: [Day 06 · \[실습\] 상태 패턴](day06-lab-state-pattern.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 오늘의 한 줄: Day 05의 핵심을 내 말로 한 문장으로 쓴다.
- [ ] 클로저가 "값이 아니라 변수를 캡처한다"는 말을 `for` 루프 예로 내 말로 설명하면?
- [ ] 내가 이벤트를 구독하고 해제를 잊어 문제가 된 경험이 있는가? 어떻게 찾았는가?
