# Day 02 · 박싱과 언박싱

> 1주차 C# 메모리 · 60분 · 준비물: .NET SDK (`dotnet new console -o practice/day02`)

## 오늘의 목표
- 박싱(`boxing`)과 언박싱(`unboxing`)이 메모리에서 수행하는 작업을 단계별로 설명할 수 있다.
- 코드에 `object`라는 단어가 없어도 박싱이 일어나는 숨은 지점 6가지를 찾을 수 있다.
- 제네릭 제약(`where T : IFoo`)과 `IEquatable<T>`로 struct의 박싱을 제거할 수 있다.

---

## 1. 읽기 (20분)

### 1-1. 박싱과 언박싱이 하는 일

값 타입을 `object`나 인터페이스 타입 변수에 담으면 **박싱(`boxing`)**이 일어난다.

1. 관리 힙에 새 객체를 할당한다(64비트 기준 객체 헤더 8B + 타입 포인터 8B + 값 크기, 최소 24바이트).
2. 스택(또는 원래 위치)에 있던 값을 힙 객체 안으로 복사한다.
3. 그 힙 객체의 참조를 돌려준다.

반대로 박싱된 참조에서 값을 꺼내는 것이 **언박싱(`unboxing`)**이다.

1. 참조가 `null`이 아닌지, 박싱할 때의 **정확한 원래 타입**이 맞는지 검사한다.
2. 맞으면 힙 객체 안의 값을 대상 위치로 복사한다.

```csharp
int x = 5;
object boxed = x;          // 박싱: 힙에 24바이트 할당 + 값 5 복사
int y = (int)boxed;        // 언박싱: 타입 검사 + 값 복사

long z = (long)boxed;      // InvalidCastException! (int를 바로 long으로 언박싱 불가)
long ok = (long)(int)boxed; // 언박싱(int) 후 형변환(long)은 가능
```

박싱이 비싼 이유는 세 가지다. **힙 할당**이 일어나고, **값 복사**가 일어나며, 나중에 **GC가 수거할 쓰레기**가 남는다.

### 1-2. 눈에 잘 안 보이는 박싱 지점 6가지

코드에 `(object)` 캐스트가 없어도 아래 자리에서는 값 타입이 박싱된다.

| 지점 | 예시 | 왜 박싱되는가 |
|---|---|---|
| `object` 매개변수 | `string.Format("{0}", 10)`, `Console.WriteLine((object)x)` | 매개변수 타입이 `object`다 (`WriteLine(int)`처럼 오버로드가 있으면 안 됨) |
| `params object[]` | `void Log(params object[] args)`에 `int` 전달 | `object[]` 배열 할당 + 각 값 타입 원소 박싱 |
| 비제네릭 컬렉션 | `ArrayList.Add(1)`, `Hashtable[1] = 2` | 요소를 `object`로 저장한다 |
| 인터페이스 변수/매개변수 | `IFoo f = myStruct;`, `void M(IFoo f)` | 인터페이스 변수는 참조 타입처럼 동작해 힙 객체를 가리킨다 |
| 재정의 안 한 `ToString()` 등 | `myStruct.ToString()` (오버라이드 안 했을 때) | `ValueType`의 가상 메서드를 호출할 때 인스턴스를 박싱해 넘긴다 |
| `IEquatable<T>` 없는 struct 키 | `Dictionary<MyStruct, int>` | 기본 비교자가 `object.Equals(object)`와 `ValueType.Equals`를 거치며 박싱한다(리플렉션까지 쓸 수 있음) |

### 1-3. 문자열 보간(`$"..."`)과 Unity(C# 9)의 차이

```csharp
int hp = 100;
string s = $"HP: {hp}";
```

- **.NET 6+ / C# 10+**: 컴파일러가 `DefaultInterpolatedStringHandler`로 변환한다. `AppendFormatted<int>(int)` 제네릭 오버로드가 호출되어 **`hp`가 박싱되지 않는다**(결과 문자열 1개만 할당).
- **Unity 6 (C# 9)**: 보간 핸들러가 없어 컴파일러가 `string.Format("HP: {0}", (object)hp)`로 낮춘다. 즉 **값 타입 인자마다 박싱**이 추가된다.

### 1-4. 인터페이스로 인한 박싱을 제네릭 제약으로 막기

struct가 인터페이스를 구현하는 것 자체는 박싱이 아니다. **인터페이스 타입으로 다룰 때** 박싱된다.

```csharp
interface IPoint { int X { get; } }
struct PointS : IPoint { public int X { get; set; } }

static int SumBoxed(IPoint p) => p.X;                  // 호출할 때마다 PointS 박싱 (24B)
static int SumGeneric<T>(T p) where T : IPoint => p.X; // 박싱 없음 (0B)
```

`where T : IPoint` 제약을 걸면 컴파일러는 IL에 `constrained.` 접두사를 붙이고, JIT(또는 IL2CPP)가 `PointS` 전용 코드를 만들어 박싱 없이 메서드를 직접 호출한다.

### 1-5. Dictionary 키로 쓰는 struct에는 `IEquatable<T>`

`Dictionary<K, V>`는 키를 비교할 때 `EqualityComparer<K>.Default`를 쓴다. `K`가 `IEquatable<K>`를 구현하지 않은 struct이면 `ObjectEqualityComparer<K>`가 선택되어 비교할 때마다 `Equals(object)` 호출로 박싱이 일어난다.

```csharp
struct GridCoord : IEquatable<GridCoord>
{
    public int X, Y;
    public bool Equals(GridCoord other) => X == other.X && Y == other.Y;
    public override bool Equals(object? obj) => obj is GridCoord other && Equals(other);
    public override int GetHashCode() => HashCode.Combine(X, Y);
}
```

`IEquatable<T>.Equals(T)`와 `override int GetHashCode()`를 함께 구현해야 `Dictionary`와 `HashSet`에서 박싱이 0바이트가 된다.

---

## 2. 손으로 확인 (30분)

> AI, 자동완성, 검색 없이. 막히면 위의 읽기로 돌아간다.

### 실습 1: 6가지 케이스의 할당 바이트 예측·측정 (10분)

각 루프가 10,000번 돌 때 몇 바이트를 할당할지 실행 전에 주석으로 먼저 적고, `dotnet run -c Release`로 확인한다. (힌트: 64비트에서 `int`나 작은 struct 하나가 박싱되면 24바이트다.)

```csharp
// 실행 가능: Program.cs
using System.Collections;

const int N = 10_000;
object? sink = null;

// 워밍업
sink = string.Format("HP: {0}", 1000);
sink = $"HP: {1000}";

// 1) int -> object 대입
long b0 = GC.GetAllocatedBytesForCurrentThread();
for (int i = 0; i < N; i++) sink = i;
long case1 = GC.GetAllocatedBytesForCurrentThread() - b0;

// 2) ArrayList.Add(int) (용량 미리 확보)
var arrayList = new ArrayList(N);
b0 = GC.GetAllocatedBytesForCurrentThread();
for (int i = 0; i < N; i++) arrayList.Add(i);
long case2 = GC.GetAllocatedBytesForCurrentThread() - b0;

// 3) List<int>.Add(int) (용량 미리 확보)
var genericList = new List<int>(N);
b0 = GC.GetAllocatedBytesForCurrentThread();
for (int i = 0; i < N; i++) genericList.Add(i);
long case3 = GC.GetAllocatedBytesForCurrentThread() - b0;

// 4) struct를 인터페이스 변수에 대입
var p = new PointS { X = 1 };
IPoint? ip = null;
b0 = GC.GetAllocatedBytesForCurrentThread();
for (int i = 0; i < N; i++) ip = p;
long case4 = GC.GetAllocatedBytesForCurrentThread() - b0;

// 5) string.Format("HP: {0}", int) — Unity(C# 9)의 $"HP: {v}"와 동일
b0 = GC.GetAllocatedBytesForCurrentThread();
for (int i = 0; i < N; i++) sink = string.Format("HP: {0}", 1000 + i);
long case5 = GC.GetAllocatedBytesForCurrentThread() - b0;

// 6) C# 10+ 문자열 보간 $"HP: {v}" (.NET 6+)
b0 = GC.GetAllocatedBytesForCurrentThread();
for (int i = 0; i < N; i++) sink = $"HP: {1000 + i}";
long case6 = GC.GetAllocatedBytesForCurrentThread() - b0;

Console.WriteLine($"1) object 대입: {case1} B");
Console.WriteLine($"2) ArrayList.Add: {case2} B");
Console.WriteLine($"3) List<int>.Add: {case3} B");
Console.WriteLine($"4) 인터페이스 대입: {case4} B");
Console.WriteLine($"5) string.Format: {case5} B");
Console.WriteLine($"6) $\"HP: {{v}}\" 보간: {case6} B");
Console.WriteLine($"5와 6의 차이(박싱분): {case5 - case6} B");
GC.KeepAlive(sink);
GC.KeepAlive(ip);

interface IPoint { int X { get; } }
struct PointS : IPoint { public int X { get; set; } }
```

<details><summary>예상 출력과 해설</summary>

```
1) object 대입: 240000 B
2) ArrayList.Add: 240000 B
3) List<int>.Add: 0 B
4) 인터페이스 대입: 240000 B
5) string.Format: 640000 B
6) $"HP: {v}" 보간: 400000 B
5와 6의 차이(박싱분): 240000 B
```

- 1, 2, 4: 회당 24바이트 × 10,000회 = 240,000바이트.
- 3: `List<int>`는 내부가 `int[]`라서 박싱이 전혀 없다(0바이트).
- 5, 6: 둘 다 길이 8인 문자열(`"HP: 1000"`, 40바이트)을 만들지만, `string.Format`은 인자를 `object`로 받아 회당 24바이트씩 더 할당한다. Unity(C# 9)에서는 6번처럼 써도 5번으로 컴파일된다.

</details>

### 실습 2: struct Dictionary 키 — `IEquatable<T>` 유무 비교 (10분)

좌표 struct `BadKey`(아무것도 구현 안 함)와 `GoodKey`(`IEquatable<GoodKey>` + `GetHashCode` 구현)를 만들어 각각 `Dictionary`에서 `ContainsKey`를 10,000번 호출할 때의 할당 바이트와 소요 시간을 비교한다. 실행 전에 두 바이트 수를 예측한다.

<details><summary>정답 코드와 예상 출력</summary>

```csharp
// 실행 가능: Program.cs
using System.Diagnostics;

const int N = 10_000;
var badDict = new Dictionary<BadKey, int> { [new BadKey { X = 1, Y = 2 }] = 42 };
var goodDict = new Dictionary<GoodKey, int> { [new GoodKey { X = 1, Y = 2 }] = 42 };
var badKey = new BadKey { X = 1, Y = 2 };
var goodKey = new GoodKey { X = 1, Y = 2 };

// 워밍업
_ = badDict.ContainsKey(badKey);
_ = goodDict.ContainsKey(goodKey);

var sw = Stopwatch.StartNew();
long b0 = GC.GetAllocatedBytesForCurrentThread();
for (int i = 0; i < N; i++) _ = badDict.ContainsKey(badKey);
long badBytes = GC.GetAllocatedBytesForCurrentThread() - b0;
sw.Stop();
double badMs = sw.Elapsed.TotalMilliseconds;

sw.Restart();
b0 = GC.GetAllocatedBytesForCurrentThread();
for (int i = 0; i < N; i++) _ = goodDict.ContainsKey(goodKey);
long goodBytes = GC.GetAllocatedBytesForCurrentThread() - b0;
sw.Stop();
double goodMs = sw.Elapsed.TotalMilliseconds;

Console.WriteLine($"BadKey : {badBytes} B, {badMs:F3} ms");
Console.WriteLine($"GoodKey: {goodBytes} B, {goodMs:F3} ms");

struct BadKey { public int X, Y; }

struct GoodKey : IEquatable<GoodKey>
{
    public int X, Y;
    public bool Equals(GoodKey other) => X == other.X && Y == other.Y;
    public override bool Equals(object? obj) => obj is GoodKey other && Equals(other);
    public override int GetHashCode() => HashCode.Combine(X, Y);
}
```

예상 출력(`ms`는 환경에 따라 다르며 경향만 참고한다):
```
BadKey : 720000 B, 3.546 ms
GoodKey: 0 B, 0.551 ms
```

`BadKey`는 `GetHashCode()`와 `Equals(object)` 호출 과정에서 한 번 조회할 때마다 여러 번 박싱(회당 72B)이 발생한다. `GoodKey`는 0바이트다.

</details>

### 실습 3: 인터페이스 매개변수 vs 제네릭 제약 (10분)

`IPoint`를 받는 `CallInterface(IPoint p)`와 `CallGeneric<T>(T p) where T : IPoint`를 작성하고, 각각 `[MethodImpl(MethodImplOptions.NoInlining)]`을 붙인 뒤 `PointS`를 10,000번 넘겨 할당 바이트를 비교한다.

<details><summary>정답 코드와 예상 출력</summary>

```csharp
// 실행 가능: Program.cs
using System.Runtime.CompilerServices;

const int N = 10_000;
var pt = new PointS { X = 3 };

// 워밍업
CallInterface(pt);
CallGeneric(pt);

long b0 = GC.GetAllocatedBytesForCurrentThread();
int sum1 = 0;
for (int i = 0; i < N; i++) sum1 += CallInterface(pt);
long ifaceBytes = GC.GetAllocatedBytesForCurrentThread() - b0;

b0 = GC.GetAllocatedBytesForCurrentThread();
int sum2 = 0;
for (int i = 0; i < N; i++) sum2 += CallGeneric(pt);
long genericBytes = GC.GetAllocatedBytesForCurrentThread() - b0;

Console.WriteLine($"CallInterface: {ifaceBytes} B (sum={sum1})");
Console.WriteLine($"CallGeneric  : {genericBytes} B (sum={sum2})");

[MethodImpl(MethodImplOptions.NoInlining)]
static int CallInterface(IPoint p) => p.X;

[MethodImpl(MethodImplOptions.NoInlining)]
static int CallGeneric<T>(T p) where T : IPoint => p.X;

interface IPoint { int X { get; } }
struct PointS : IPoint { public int X { get; set; } }
```

출력:
```
CallInterface: 240000 B (sum=30000)
CallGeneric  : 0 B (sum=30000)
```

</details>

---

## 3. 면접 대비 (10분)

소리 내어 30초 안에 답해 보고 펼쳐서 비교한다.

**Q1. 박싱과 언박싱이 무엇이고 왜 비용이 큰가요?**
<details><summary>모범 답안</summary>
박싱은 값 타입을 `object`나 인터페이스 타입으로 변환할 때 관리 힙에 새 객체를 할당하고 값을 복사하는 작업입니다. 언박싱은 그 객체의 타입을 검사한 뒤 값을 다시 복사해 꺼내는 작업입니다. 단순 대입과 달리 힙 할당과 메모리 복사가 일어나고, 사용 후 남은 객체가 GC 수거 대상이 되기 때문에 반복 호출되는 루프에서 성능 문제를 일으킵니다.

</details>

**Q2. 코드에서 의도하지 않은 박싱이 자주 일어나는 곳은 어디인가요?**
<details><summary>모범 답안</summary>
대표적으로 `string.Format`이나 `params object[]`처럼 `object` 매개변수를 받는 메서드에 값 타입을 넘길 때, 그리고 struct를 인터페이스 타입 변수나 매개변수로 다룰 때 일어납니다. 또한 `IEquatable<T>`과 `GetHashCode`를 구현하지 않은 struct를 `Dictionary`나 `HashSet`의 키로 쓸 때도 비교 과정에서 박싱이 발생합니다. Unity는 C# 9를 사용하므로 `$"..."` 문자열 보간도 `string.Format`으로 변환되어 값 타입 인자가 박싱됩니다.

</details>

**Q3. 내 코드에서 박싱이 일어나는지 어떻게 찾나요?**
<details><summary>모범 답안</summary>
런타임에서는 Unity Profiler의 CPU Usage 모듈에서 `GC Alloc` 컬럼을 보거나 콘솔에서 `GC.GetAllocatedBytesForCurrentThread()`로 할당량을 측정합니다. 정적으로는 컴파일된 IL 코드에서 `box` 명령어를 검색하거나 SharpLab(sharplab.io), IDE의 Heap Allocations Viewer 플러그인으로 확인할 수 있습니다.

</details>

**Q4. 인터페이스를 구현한 struct를 박싱 없이 전달하려면 어떻게 해야 하나요?**
<details><summary>모범 답안</summary>
매개변수를 인터페이스 타입 `IFoo`로 직접 받지 않고, `void Process<T>(T item) where T : IFoo`처럼 제네릭 타입 매개변수와 인터페이스 제약을 사용합니다. 그러면 IL의 `constrained` 호출을 통해 값 타입 전용 코드가 생성되어 힙 할당 없이 메서드를 호출할 수 있습니다.

</details>

---

## 오늘의 한 줄
> (내 말로 한 문장)

## 더 보기
- [박싱 및 언박싱 (C# 프로그래밍 가이드)](https://learn.microsoft.com/ko-kr/dotnet/csharp/programming-guide/types/boxing-and-unboxing)
- [형식 매개 변수에 대한 제약 조건](https://learn.microsoft.com/ko-kr/dotnet/csharp/programming-guide/generics/constraints-on-type-parameters)
- [System.IEquatable<T> 인터페이스](https://learn.microsoft.com/ko-kr/dotnet/api/system.iequatable-1)
- [SharpLab — C# to IL 디컴파일러](https://sharplab.io/)
