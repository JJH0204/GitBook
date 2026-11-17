# Day 07 · IEnumerator와 yield의 정체

> 2주차 비동기 · 60분 · 준비물: .NET SDK (`dotnet new console -o practice/day07`)

## 오늘의 목표
- `foreach`가 인터페이스가 없어도 덕 타이핑(`duck typing`)으로 동작하는 원리와 `Dispose()` 호출 규칙을 설명할 수 있다.
- `yield return` 메서드가 컴파일러에 의해 어떤 상태 기계(`state machine`) 클래스로 변환되는지 손으로 재현할 수 있다.
- 지연 실행(`deferred execution`)의 함정과 이터레이터 호출 시 발생하는 힙 할당을 설명할 수 있다.

---

## 1. 읽기 (20분)

### 1-1. `foreach`의 진짜 모습 — 덕 타이핑(`duck typing`)

`foreach (var x in collection)`은 반드시 `IEnumerable<T>`를 구현해야만 동작하는 것이 아니다. 컴파일러는 **이름과 시그니처만 맞으면**(덕 타이핑) 아래 코드로 풀어 쓴다.

1. `collection`에 `GetEnumerator()` 메서드가 있는지 찾는다.
2. 반환된 열거자(`enumerator`)에 `bool MoveNext()` 메서드와 `Current` 프로퍼티가 있으면 통과한다.
3. 열거자가 `IDisposable`을 구현하면 `try / finally`로 감싸 루프가 끝날 때(중간에 `break`나 예외로 나가더라도) `Dispose()`를 호출한다.

```csharp
// foreach (int x in list) { ... } 가 풀린 모습
var e = list.GetEnumerator(); // List<int>.Enumerator (struct) 반환 → 박싱 0B
try
{
    while (e.MoveNext())
    {
        int x = e.Current;
        // 본문
    }
}
finally
{
    e.Dispose();
}
```

[Day 03](day03-gc-allocation.md)에서 `List<int>`를 바로 `foreach`하면 0바이트였던 이유가 바로 이것이다.

### 1-2. `yield return`은 스레드도 마법도 아닌 "상태 기계 클래스"다

메서드 안에 `yield return`이나 `yield break`가 하나라도 있으면, 컴파일러는 그 메서드의 본문을 실행하는 대신 **`IEnumerator<T>`(또는 `IEnumerable<T>`)를 구현한 숨은 클래스를 생성**한다.

| 원래 이터레이터 코드의 요소 | 컴파일러가 만든 클래스 안에서의 모습 |
|---|---|
| 현재 어디까지 실행했는가 | `private int _state;` 필드 (`0`, `1`, `2`, ..., 종료 시 `-1`) |
| 마지막으로 내보낸 값 | `public T Current { get; private set; }` 필드 |
| 메서드의 매개변수와 지역 변수 | `MoveNext()` 호출 사이에도 값이 유지되어야 하므로 **모두 클래스의 필드로 승격(`hoisting`)** |
| `yield return expr;` | `Current = expr; _state = 다음번호; return true;` |
| `yield break;` 또는 메서드 끝 | `_state = -1; return false;` |
| `try { ... } finally { ... }` | `Dispose()`가 호출될 때(조기 `break` 포함) `finally` 블록을 실행하는 상태 정리 메서드 호출 |

따라서 **`yield` 메서드를 호출하는 순간에는 본문 코드가 한 줄도 실행되지 않는다.** 단지 이 숨은 상태 기계 객체를 **`new`로 힙에 1번 할당**해 돌려줄 뿐이다. 실제 본문 코드는 소비자가 첫 `MoveNext()`를 부를 때 비로소 첫 `yield return`까지 달린다.

### 1-3. 지연 실행(`deferred execution`)의 함정

```csharp
// 나쁜 예: count에 -1을 넘겨도 호출 시점에는 예외가 안 나고, 나중에 foreach를 돌릴 때 터진다!
static IEnumerable<int> BadRange(int count)
{
    if (count < 0) throw new ArgumentOutOfRangeException(nameof(count));
    for (int i = 0; i < count; i++) yield return i;
}

// 좋은 예: 검증은 일반 메서드에서 즉시 수행하고, 실제 순회는 로컬 이터레이터 함수에 맡긴다
static IEnumerable<int> SafeRange(int count)
{
    if (count < 0) throw new ArgumentOutOfRangeException(nameof(count));
    return Impl();

    IEnumerable<int> Impl()
    {
        for (int i = 0; i < count; i++) yield return i;
    }
}
```

또 다른 함정은 `IEnumerable<T>`를 반환받아 **두 번 `foreach`를 돌리면 상태 기계가 두 번 생성되어 처음부터 다시 계산한다**는 점이다.

---

## 2. 손으로 확인 (30분)

> AI, 자동완성, 검색 없이. 막히면 위의 읽기로 돌아간다.

### 실습 1: `yield`와 `foreach` 교차 실행 순서 예측하기 (10분)

아래 코드를 실행하기 전에 출력될 줄의 정확한 순서를 종이에 먼저 적는다. 특히 `B`가 언제 찍히는지, `n == 2`에서 `break`했을 때 `finally`가 실행되는지 확인한다.

```csharp
// 실행 가능: Program.cs
Console.WriteLine("A: 메서드 호출 전");
IEnumerable<int> seq = NumbersWithFinally();
Console.WriteLine("B: 메서드 호출 직후 (아직 MoveNext 전)");

foreach (int n in seq)
{
    Console.WriteLine($"  foreach 본문: {n}");
    if (n == 2)
    {
        Console.WriteLine("  foreach에서 break!");
        break;
    }
}
Console.WriteLine("C: foreach 종료 후");

static IEnumerable<int> NumbersWithFinally()
{
    try
    {
        Console.WriteLine("  [iter] 1 반환 전");
        yield return 1;
        Console.WriteLine("  [iter] 2 반환 전");
        yield return 2;
        Console.WriteLine("  [iter] 3 반환 전");
        yield return 3;
    }
    finally
    {
        Console.WriteLine("  [iter] finally 실행 (Dispose)");
    }
}
```

<details><summary>예상 출력과 해설</summary>

```
A: 메서드 호출 전
B: 메서드 호출 직후 (아직 MoveNext 전)
  [iter] 1 반환 전
  foreach 본문: 1
  [iter] 2 반환 전
  foreach 본문: 2
  foreach에서 break!
  [iter] finally 실행 (Dispose)
C: foreach 종료 후
```

- `NumbersWithFinally()`를 부른 시점에는 객체만 생성되어 `B`가 먼저 찍힌다.
- `n == 2`에서 `break`로 루프를 빠져나가도 `foreach`가 생성한 `finally { enumerator.Dispose(); }`가 호출되어 이터레이터 안의 `finally`가 실행된다. `3 반환 전`은 절대 실행되지 않는다.

</details>

### 실습 2: 컴파일러가 만드는 상태 기계 손으로 짜 보기 (10분)

`yield`를 전혀 쓰지 않고, `_state` 필드와 `switch (_state)`만으로 `10`, `20`, `30`을 차례대로 내보내는 `IEnumerator<int>` 클래스를 직접 작성해 `foreach`로 출력한다. (시간이 남으면 [sharplab.io](https://sharplab.io/)에 `yield` 메서드를 붙여 넣고 컴파일러 결과와 비교해 본다.)

<details><summary>정답 코드와 예상 출력</summary>

```csharp
// 실행 가능: Program.cs
using System.Collections;

foreach (int n in new ManualNumbersEnumerable())
    Console.Write($"{n} ");
Console.WriteLine();

class ManualNumbersEnumerable : IEnumerable<int>
{
    public IEnumerator<int> GetEnumerator() => new ManualEnumerator();
    IEnumerator IEnumerable.GetEnumerator() => GetEnumerator();

    private sealed class ManualEnumerator : IEnumerator<int>
    {
        private int _state;
        private int _i; // 원래 지역 변수였던 것이 필드로 승격됨
        public int Current { get; private set; }
        object IEnumerator.Current => Current;

        public bool MoveNext()
        {
            switch (_state)
            {
                case 0:
                    _i = 10;
                    Current = _i;
                    _state = 1;
                    return true;
                case 1:
                    _i += 10;
                    Current = _i;
                    _state = 2;
                    return true;
                case 2:
                    _i += 10;
                    Current = _i;
                    _state = -1;
                    return true;
                default:
                    return false;
            }
        }

        public void Reset() => throw new NotSupportedException();
        public void Dispose() { }
    }
}
```

출력:
```
10 20 30 
```

</details>

### 실습 3: 무한 피보나치 수열 + 직접 만든 `MyTake(n)` 확장 메서드 (10분)

`while (true)`와 `yield return`으로 무한히 피보나치 수(`1, 1, 2, 3, 5, 8, ...`)를 내보내는 `Fibonacci()`와, 앞에서부터 `count`개만 꺼내고 `yield break`하는 `MyTake<T>` 확장 메서드를 작성해 첫 6개의 합을 출력한다.

<details><summary>정답 코드와 예상 출력</summary>

```csharp
// 실행 가능: Program.cs
int sum = 0;
foreach (int f in Fibonacci().MyTake(6))
{
    Console.Write($"{f} ");
    sum += f;
}
Console.WriteLine($"(합={sum})");

static IEnumerable<int> Fibonacci()
{
    int a = 1, b = 1;
    while (true)
    {
        yield return a;
        (a, b) = (b, a + b);
    }
}

static class EnumerableExt
{
    public static IEnumerable<T> MyTake<T>(this IEnumerable<T> source, int count)
    {
        if (count <= 0) yield break;
        int taken = 0;
        foreach (T item in source)
        {
            yield return item;
            if (++taken >= count) yield break;
        }
    }
}
```

출력:
```
1 1 2 3 5 8 (합=20)
```

`Fibonacci()` 안에 `while (true)`가 있어도 `MyTake(6)`이 `MoveNext()`를 딱 6번만 부르고 `yield break`하므로 무한 루프에 빠지지 않는다.

</details>

---

## 3. 면접 대비 (10분)

소리 내어 30초 안에 답해 보고 펼쳐서 비교한다.

**Q1. C#의 `yield return`은 내부적으로 어떻게 동작하나요?**
<details><summary>모범 답안</summary>
컴파일러가 `yield return`이 있는 메서드를 `IEnumerator<T>`를 구현한 숨은 상태 기계(State Machine) 클래스로 변환합니다. 메서드의 지역 변수들은 호출 간에 값을 유지해야 하므로 그 클래스의 필드로 승격되고, `MoveNext()`가 호출될 때마다 `switch (_state)`를 통해 이전 `yield return` 다음 줄부터 다음 `yield return`까지 실행한 뒤 `true`를 반환합니다.

</details>

**Q2. 지연 실행(Deferred Execution)이란 무엇이고 어떤 함정을 조심해야 하나요?**
<details><summary>모범 답안</summary>
이터레이터 메서드를 호출한 시점에는 상태 기계 객체만 생성되고, 실제로 첫 `MoveNext()`가 호출될 때까지 본문 코드가 실행되지 않는 특성입니다. 이로 인해 매개변수 유효성 검사 예외가 메서드 호출 시점이 아니라 나중에 순회할 때 뒤늦게 터지거나, 같은 `IEnumerable<T>`를 여러 번 순회할 때 매번 연산과 할당이 반복되는 함정이 있습니다.

</details>

**Q3. `yield return`으로 만든 이터레이터 안에서 `try / finally`를 쓰면, 소비자가 `foreach` 도중에 `break`로 나가도 `finally`가 실행되나요?**
<details><summary>모범 답안</summary>
네, 실행됩니다. `foreach`문은 컴파일될 때 열거자 순회를 `try / finally`로 감싸고 `finally`에서 `enumerator.Dispose()`를 호출합니다. 컴파일러가 생성한 상태 기계의 `Dispose()` 안에 이터레이터의 `finally` 블록을 실행하는 코드가 들어 있어서, 루프를 중간에 `break`나 예외로 빠져나가도 자원 정리가 보장됩니다.

</details>

**Q4. `yield return` 메서드를 호출해 `foreach`로 돌면 힙 할당이 얼마나 발생하나요?**
<details><summary>모범 답안</summary>
컴파일러가 생성한 상태 기계(이터레이터) 클래스 인스턴스가 힙에 1번 할당됩니다(`yield return` 횟수만큼 할당되는 것이 아니라 호출당 1개입니다). 단, 반환 타입이 비제네릭 `IEnumerable`이고 값 타입을 `yield return`하면 매 요소마다 박싱이 추가로 일어납니다.

</details>

---

## 오늘의 한 줄
> (내 말로 한 문장)

## 더 보기
- [반복기 (C# 프로그래밍 가이드)](https://learn.microsoft.com/ko-kr/dotnet/csharp/iterators)
- [yield 문 (C# 참조)](https://learn.microsoft.com/ko-kr/dotnet/csharp/language-reference/statements/yield)
- [foreach, in (C# 참조)](https://learn.microsoft.com/ko-kr/dotnet/csharp/language-reference/statements/iteration-statements#the-foreach-statement)
- [SharpLab — yield 상태 기계 디컴파일 확인](https://sharplab.io/)
