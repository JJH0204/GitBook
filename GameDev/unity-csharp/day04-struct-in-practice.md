# Day 04 · struct 제대로 쓰기

> 1주차 C# 메모리 · 60분 · 준비물: .NET SDK (`dotnet new console -o practice/day04`)

## 오늘의 목표
- Unity 내장 struct들의 크기를 알고 언제 struct를 만들고 언제 피해야 하는지 기준을 말할 수 있다.
- 방어적 복사(`defensive copy`)가 왜 일어나고 `readonly struct`와 `in` 매개변수가 어떻게 맞물리는지 설명할 수 있다.
- `Span<T>`와 `ReadOnlySpan<T>`로 부분 문자열 할당 없이 데이터를 다룰 수 있다.

---

## 1. 읽기 (20분)

### 1-1. 언제 struct를 쓰는가 — Unity 내장 타입 크기

.NET 설계 지침은 아래 네 조건을 모두 만족할 때 struct를 권장한다.
1. 크기가 작다(대략 **16바이트 이하**).
2. 논리적으로 하나의 값이며 **불변(`immutable`)**이다.
3. 수명이 짧고 다른 객체에 자주 공유되지 않는다.
4. `object`나 인터페이스로 박싱될 일이 드물다.

| Unity struct | 구성 필드 | 크기 | 비고 |
|---|---|---|---|
| `Vector3` | `float` × 3 | 12 B | 값 전달이 참조(8B)와 큰 차이 없음 |
| `Quaternion`, `Color`, `Vector4` | `float` × 4 | 16 B | 지침의 상한선 |
| `Bounds` | `Vector3` × 2 | 24 B | 중심 + 크기 |
| `RaycastHit` | 좌표, 법선, 거리, 콜라이더 ID 등 | 약 44 B (버전·아키텍처에 따라 다름) | `out RaycastHit hit`으로 참조 전달 |
| `Matrix4x4` | `float` × 16 | 64 B | 값으로 넘기면 매번 64B 복사 |

### 1-2. 방어적 복사(`defensive copy`)와 `readonly struct`

`readonly` 필드나 `in` 매개변수에 들어 있는 struct는 **원본이 바뀌면 안 된다.** 그런데 컴파일러 입장에서 일반 struct의 메서드가 내부 필드를 바꿀지 안 바꿀지 알 수 없으면, 메서드를 부르기 전에 **임시 복사본을 만들어 복사본에 대해 메서드를 호출**한다. 이것이 **방어적 복사(`defensive copy`)**다.

```csharp
struct Counter
{
    public int Value;
    public void Increment() => Value++;          // 필드를 수정함
    public int Double() => Value * 2;            // 수정 안 하지만 readonly 표시가 없음
}

class Holder
{
    public readonly Counter C = new Counter();
}

var h = new Holder();
h.C.Increment(); // 방어적 복사본의 Value만 1이 되고 버려짐! h.C.Value는 여전히 0
```

이 함정에는 두 가지 문제가 있다.
1. **조용한 버그**: `h.C.Increment()`는 컴파일 에러도 경고도 없이(일부 IDE 분석기 제외) 수정이 증발한다.
2. **숨은 복사 비용**: `Double()`처럼 값을 읽기만 하는 메서드도 `readonly` 표시가 없으면 `in` 매개변수나 `readonly` 필드에서 호출할 때마다 struct 전체를 복사한다.

해법은 `readonly struct`(C# 7.2, 타입 전체 불변)와 `readonly` 멤버 표시(C# 8)다.

```csharp
readonly struct SafeVec3
{
    public readonly float X, Y, Z;
    public SafeVec3(float x, float y, float z) => (X, Y, Z) = (x, y, z);
    public float SqrMagnitude => X * X + Y * Y + Z * Z; // 자동으로 readonly
}
```

### 1-3. `in` / `ref` / `out`과 `ref return`

| 키워드 | 의미 | 주요 용도 |
|---|---|---|
| `ref` | 읽고 쓸 수 있는 참조 전달(호출 전 초기화 필수) | 큰 struct를 원본 자리에서 수정 |
| `out` | 결과를 채워 넣는 참조 전달(메서드 안에서 대입 필수) | `Physics.Raycast(..., out RaycastHit hit)` |
| `in` | 읽기 전용 참조 전달(8바이트 주소만 전달) | 16바이트보다 큰 **`readonly struct`** 전달 |
| `ref return` / `ref local` | 값이 아니라 저장 위치(참조)를 반환·보관 | 배열 안의 큰 struct를 복사 없이 직접 수정 |

```csharp
var arr = new Counter[10];
ref Counter slot = ref arr[0]; // 복사본이 아니라 arr[0] 자리 자체
slot.Increment();              // arr[0].Value가 1이 됨
```

**주의**: `readonly`가 아닌 큰 struct를 `in`으로 넘기면 메서드 안에서 멤버를 호출할 때마다 방어적 복사가 일어나 값 전달보다 오히려 느려질 수 있다. **`in`은 항상 `readonly struct`와 짝지어 쓴다.**

### 1-4. 가변(`mutable`) struct가 위험한 세 곳

1. **프로퍼티/인덱서 반환값**: `list[0].Value = 1;`은 복사본 수정이라 CS1612 에러가 난다([Day 01](day01-value-vs-reference.md) 참고).
2. **`foreach` 반복 변수**: 반복 변수는 읽기 전용이다. `item.Value = 1;`은 CS1654 컴파일 에러가 나지만, `item.Increment();`는 컴파일이 **되고** 방어적 복사본만 고쳐서 아무 효과가 없다. 에러가 안 나는 쪽이 더 위험하다.
3. **`readonly` 필드**: 위에서 본 방어적 복사로 수정이 조용히 버려진다.

### 1-5. `Span<T>`와 `stackalloc` 맛보기

`Span<T>`와 `ReadOnlySpan<T>`는 배열, 문자열, 스택 메모리의 **연속된 구간을 힙 할당 없이 가리키는 `ref struct`**다. `ref struct`는 무조건 스택에만 살아야 해서 클래스의 필드가 될 수 없고, 박싱되거나 `async`/`yield` 메서드에서 경계를 넘어 쓰일 수 없다.

```csharp
Span<int> scratch = stackalloc int[64]; // 스택에 256B 즉시 확보 (GC 무관)
ReadOnlySpan<char> slice = "12,34,56".AsSpan(0, 2); // 부분 문자열 할당 없음 ("12")
```

Unity 6(.NET Standard 2.1)에서도 `Span<T>`, `ReadOnlySpan<T>`, `stackalloc`, `int.Parse(ReadOnlySpan<char>)`를 그대로 쓸 수 있다. 단 `CollectionsMarshal.AsSpan(list)` 같은 API는 최신 .NET 전용이라 Unity에는 없다.

---

## 2. 손으로 확인 (30분)

> AI, 자동완성, 검색 없이. 막히면 위의 읽기로 돌아간다.

### 실습 1: 방어적 복사 버그 재현과 두 가지 수정 (10분)

`readonly Counter C` 필드에 대해 `Increment()`를 두 번 호출했을 때 출력값을 예측해 적고 실행한다. 그다음 (1) 가변이 필요한 경우(필드에서 `readonly` 제거), (2) 불변 `readonly struct`로 새 값을 반환하는 경우 두 가지로 고친다.

```csharp
// 실행 가능: Program.cs
var bugHolder = new BugHolder();
bugHolder.C.Increment();
bugHolder.C.Increment();
Console.WriteLine($"[버그] readonly 필드에서 Increment 2회 후: {bugHolder.C.Value}");

var fix1 = new MutableHolder();
fix1.C.Increment();
fix1.C.Increment();
Console.WriteLine($"[해법 1] 일반 필드에서 Increment 2회 후  : {fix1.C.Value}");

var c = new ReadonlyCounter(0).Add(1).Add(1);
Console.WriteLine($"[해법 2] readonly struct 새 값 반환 2회 후: {c.Value}");

struct Counter
{
    public int Value;
    public void Increment() => Value++;
}

class BugHolder { public readonly Counter C = new Counter(); }
class MutableHolder { public Counter C = new Counter(); }

readonly struct ReadonlyCounter
{
    public readonly int Value;
    public ReadonlyCounter(int value) => Value = value;
    public ReadonlyCounter Add(int delta) => new ReadonlyCounter(Value + delta);
}
```

<details><summary>예상 출력과 해설</summary>

```
[버그] readonly 필드에서 Increment 2회 후: 0
[해법 1] 일반 필드에서 Increment 2회 후  : 2
[해법 2] readonly struct 새 값 반환 2회 후: 2
```

`bugHolder.C`는 `readonly` 필드이므로 컴파일러가 `Increment()` 호출마다 임시 복사본을 만들어 그 복사본의 `Value`만 올리고 버린다.

</details>

### 실습 2: 64바이트 `readonly struct` — 값 전달 vs `in` 전달 (10분)

`long` 8개(64바이트)를 가진 `readonly struct BigData64`를 1,000만 번 넘길 때 값 전달과 `in` 전달의 시간을 `Stopwatch`로 비교한다. 워밍업 후 `dotnet run -c Release`로 측정한다. (마이크로벤치마크 수치는 환경에 따라 다르며 경향만 확인한다.)

<details><summary>정답 코드와 예상 출력</summary>

```csharp
// 실행 가능: Program.cs
using System.Diagnostics;
using System.Runtime.CompilerServices;

const int N = 10_000_000;
var big = new BigData64(1);
long acc = SumByValue(big) + SumByIn(in big); // 워밍업

var sw = Stopwatch.StartNew();
for (int i = 0; i < N; i++) acc += SumByValue(big);
sw.Stop();
double valMs = sw.Elapsed.TotalMilliseconds;

sw.Restart();
for (int i = 0; i < N; i++) acc += SumByIn(in big);
sw.Stop();
double inMs = sw.Elapsed.TotalMilliseconds;

Console.WriteLine($"값 전달(64B): {valMs:F2} ms / in 전달(8B): {inMs:F2} ms (acc={acc})");

[MethodImpl(MethodImplOptions.NoInlining)]
static long SumByValue(BigData64 d) => d.A + d.B + d.C + d.D + d.E + d.F + d.G + d.H;

[MethodImpl(MethodImplOptions.NoInlining)]
static long SumByIn(in BigData64 d) => d.A + d.B + d.C + d.D + d.E + d.F + d.G + d.H;

readonly struct BigData64
{
    public readonly long A, B, C, D, E, F, G, H;
    public BigData64(long v) => A = B = C = D = E = F = G = H = v;
}
```

예상 출력(`ms`는 머신마다 다르다):
```
값 전달(64B): 54.77 ms / in 전달(8B): 47.56 ms (acc=160000016)
```

</details>

### 실습 3: `"12,34,56"`을 부분 문자열 할당 없이 파싱하기 (10분)

`"12,34,56"`에서 세 정수의 합(102)을 구하는 함수를 (1) `string.Split(',')`으로, (2) `ReadOnlySpan<char>`와 `IndexOf(',')`, `Slice`, `int.Parse(ReadOnlySpan<char>)`로 작성해 10,000회 호출 시 할당 바이트를 비교한다. 실행 전에 두 바이트 수를 예측한다.

<details><summary>정답 코드와 예상 출력</summary>

```csharp
// 실행 가능: Program.cs
string csv = "12,34,56";
_ = ParseWithSplit(csv);
_ = ParseWithSpan(csv);

long b0 = GC.GetAllocatedBytesForCurrentThread();
int s1 = 0;
for (int i = 0; i < 10_000; i++) s1 += ParseWithSplit(csv);
long splitBytes = GC.GetAllocatedBytesForCurrentThread() - b0;

b0 = GC.GetAllocatedBytesForCurrentThread();
int s2 = 0;
for (int i = 0; i < 10_000; i++) s2 += ParseWithSpan(csv);
long spanBytes = GC.GetAllocatedBytesForCurrentThread() - b0;

Console.WriteLine($"Split 파싱: {splitBytes} B (sum={s1})");
Console.WriteLine($"Span  파싱: {spanBytes} B (sum={s2})");

static int ParseWithSplit(string s)
{
    int sum = 0;
    foreach (string part in s.Split(','))
        sum += int.Parse(part);
    return sum;
}

static int ParseWithSpan(string s)
{
    ReadOnlySpan<char> span = s.AsSpan();
    int sum = 0;
    while (true)
    {
        int comma = span.IndexOf(',');
        if (comma < 0)
        {
            sum += int.Parse(span);
            break;
        }
        sum += int.Parse(span.Slice(0, comma));
        span = span.Slice(comma + 1);
    }
    return sum;
}
```

출력:
```
Split 파싱: 1440000 B (sum=1020000)
Span  파싱: 0 B (sum=1020000)
```

`Split`은 호출마다 `string[]` 배열 1개와 부분 문자열 3개를 힙에 할당한다. `ReadOnlySpan<char>`는 원본 문자열의 시작 위치와 길이만 바꿔 가리키므로 힙 할당이 **0바이트**다.

</details>

---

## 3. 면접 대비 (10분)

소리 내어 30초 안에 답해 보고 펼쳐서 비교한다.

**Q1. 어떤 경우에 class 대신 struct를 선택하나요?**
<details><summary>모범 답안</summary>
크기가 대략 16바이트 이하로 작고, 논리적으로 하나의 불변 값을 나타내며, 수명이 짧고 인터페이스로 박싱될 일이 드문 경우에 struct를 선택합니다. Unity의 `Vector3`(12B)나 `Color`(16B)가 대표적인 예입니다. 반대로 크기가 크거나 가변 상태를 여러 곳에서 공유해야 하면 복사 비용과 상태 불일치 문제 때문에 class를 씁니다.

</details>

**Q2. `readonly struct`를 쓰면 어떤 이점이 있나요?**
<details><summary>모범 답안</summary>
첫째, 모든 필드가 불변임이 컴파일 타임에 강제되어 복사본을 수정하는 실수를 원천 차단합니다. 둘째, `readonly` 필드나 `in` 매개변수에 담긴 struct의 메서드나 프로퍼티를 호출할 때 컴파일러가 원본 불변성을 확신할 수 있어 불필요한 방어적 복사(defensive copy)를 생략합니다.

</details>

**Q3. 큰 struct를 최적화하려고 `in` 매개변수를 썼는데 오히려 느려질 수 있는 이유는 무엇인가요?**
<details><summary>모범 답안</summary>
전달하는 struct가 `readonly struct`가 아니고 호출하는 메서드에도 `readonly` 표시가 없으면, 컴파일러는 원본이 바뀔 가능성을 막기 위해 메서드를 호출할 때마다 struct 전체를 스택에 방어적으로 복사합니다. 메서드 안에서 프로퍼티나 메서드를 여러 번 부르면 값 전달(1회 복사)보다 더 많은 복사가 일어날 수 있어, `in`은 반드시 `readonly struct`와 함께 써야 합니다.

</details>

**Q4. `Span<T>`가 배열이나 `Substring`보다 빠른 이유는 무엇이고 어떤 제약이 있나요?**
<details><summary>모범 답안</summary>
`Span<T>`는 기존 배열, 문자열, 혹은 `stackalloc` 메모리의 포인터와 길이만 담는 `ref struct`라서, 구간을 잘라도(Slice) 새로운 힙 객체를 전혀 할당하지 않습니다. 대신 스택에만 존재해야 하는 `ref struct`이므로 클래스의 필드로 저장하거나 박싱할 수 없고, `async`나 `yield` 메서드의 대기 지점 너머로 유지할 수 없습니다.

</details>

---

## 오늘의 한 줄
> (내 말로 한 문장)

## 더 보기
- [구조체 형식 (C# 참조) — readonly struct 및 방어적 복사](https://learn.microsoft.com/ko-kr/dotnet/csharp/language-reference/builtin-types/struct)
- [in 매개 변수 한정자 (C# 참조)](https://learn.microsoft.com/ko-kr/dotnet/csharp/language-reference/keywords/method-parameters#in-parameter-modifier)
- [변경 가능한 구조체가 위험한 이유 — 성능 함정 해결](https://learn.microsoft.com/ko-kr/dotnet/csharp/write-safe-efficient-code)
- [Memory<T> 및 Span<T> 사용 지침](https://learn.microsoft.com/ko-kr/dotnet/standard/memory-and-spans/memory-t-usage-guidelines)
