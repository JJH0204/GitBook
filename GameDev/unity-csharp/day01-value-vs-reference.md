# Day 01 · 값 타입과 참조 타입

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UCS-002-DO |
| 유형 | D&O (개념) + 확인 실습 |
| 목적 | 값 타입과 참조 타입의 차이를 대입 시 복사되는 대상으로 설명하고, 구조체 프로퍼티 수정 오류(CS1612)를 고친다. |
| 적용 대상 | .NET 8 이상 콘솔(`dotnet new console -o practice/day01`), Unity 6(C# 9)와 다른 점은 본문에 표시 |
| 소요 시간 | 60분 (1주차 C# 메모리, 읽기 20분 + 확인 실습 30분 + 확인 문제 10분) |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 학습 목표
- 값 타입과 참조 타입의 차이를 "대입하면 무엇이 복사되는가"로 설명할 수 있다.
- "값 타입은 스택에 저장된다"는 말이 왜 반만 맞는지 설명할 수 있다.
- `transform.position.x = 5;`가 왜 컴파일되지 않는지 설명하고 고칠 수 있다.

## 2. 구성 요소

| 요소 | 위치 | 역할 |
|---|---|---|
| 값 타입 변수 (`int`, `struct`) | 선언된 곳(지역 변수는 보통 스택, 필드·배열 요소는 그 객체와 함께 힙) | 값 자체를 담는다 |
| 참조 타입 변수 (`class`, `string`, 배열) | 선언된 곳 | 힙 객체를 가리키는 참조(8바이트 주소)를 담는다 |
| 참조 타입 객체 | 관리 힙 | 데이터 본체. GC가 회수한다 |
| 프로퍼티 getter (`transform.position`) | 메서드 호출 | 값 타입의 복사본을 반환한다 |
| `ref` / `out` / `in` | 메서드 매개변수 | 값이 아니라 변수의 저장 위치를 넘긴다 |

## 3. 동작 원리

### 3-1. 두 종류의 타입

| | 값 타입 | 참조 타입 |
|---|---|---|
| 예 | `int`, `float`, `bool`, `enum`, `struct` (Unity의 `Vector3`, `Quaternion`, `Color`) | `class`, `string`, 배열, `delegate`, 인터페이스 변수 (Unity의 `GameObject`, `Transform`) |
| 변수에 들어 있는 것 | **값 자체** | 힙에 있는 객체를 가리키는 **참조** |
| 대입(`b = a`) | 값 전체가 복사된다 | 참조만 복사된다. 두 변수가 같은 객체를 본다 |
| `null` | 될 수 없다 (`int?` 같은 `Nullable<T>` 제외) | 될 수 있다 |

```csharp
struct PointS { public int X; }
class  PointC { public int X; }

var a = new PointS { X = 1 };
var b = a;      // 값 복사: b는 a와 별개의 PointS
b.X = 99;       // a.X는 여전히 1

var c = new PointC { X = 1 };
var d = c;      // 참조 복사: c와 d는 같은 객체
d.X = 99;       // c.X도 99
```

핵심은 **대입은 항상 변수 안의 내용을 복사한다**는 것이다. 값 타입은 그 내용이 값이고, 참조 타입은 그 내용이 참조일 뿐이다.

### 3-2. "값 타입은 스택에 산다"는 반만 맞다

정확히는 **값 타입은 자신이 선언된 곳에 그대로(인라인으로) 저장된다.**

| 선언된 곳 | 값 타입이 저장되는 곳 |
|---|---|
| 메서드의 지역 변수 | 보통 스택 |
| 클래스의 필드 | 그 객체 안, 즉 힙 |
| 배열의 요소 | 배열 객체 안, 즉 힙 |
| 람다가 캡처한 지역 변수, `async`/`yield` 메서드의 지역 변수 | 컴파일러가 만든 숨은 객체의 필드가 되어 힙 (Day 05, 07, 09) |

참조 타입 **객체**는 항상 관리 힙에 생기고 GC가 회수한다. 참조 **변수** 자체(8바이트 주소)는 그 변수가 선언된 곳에 있다.
그래서 "값이냐 참조냐"는 **복사 방식**의 차이이고, "스택이냐 힙이냐"는 **어디에 선언됐는가**의 결과다. 면접에서 이 둘을 구분해서 말하면 된다.

### 3-3. 메서드에 넘길 때

C#의 기본 전달 방식은 **값 전달**이다. 참조 타입도 예외가 아니다. **참조를 값으로** 넘긴다.

```csharp
static void ChangeClass(PointC p)  => p.X = 100;                 // 호출자도 바뀐 걸 본다 (같은 객체)
static void ReplaceClass(PointC p) => p = new PointC { X = -1 }; // 호출자는 모른다 (복사된 참조만 바뀜)
static void ChangeStruct(PointS p) => p.X = 100;                 // 호출자는 모른다 (복사본 수정)
static void ChangeStructByRef(ref PointS p) => p.X = 100;        // 호출자도 바뀐다 (변수 자체를 넘김)
```

`ref`/`out`/`in`은 변수 자체(저장 위치)를 넘긴다. "클래스는 참조로 전달된다"는 말은 틀렸다. 참조**를** 값으로 전달하는 것이다.

### 3-4. Unity에서 매일 만나는 함정: CS1612

```csharp
transform.position.x = 5f;   // error CS1612
```

`Vector3`는 struct이고 `transform.position`은 **프로퍼티**다. 프로퍼티는 메서드(`get_position()`)라서 값의 **복사본**을 돌려준다. 복사본의 `x`를 바꿔 봐야 버려질 값이라 컴파일러가 막는다.

```csharp
var p = transform.position;  // 복사본을 받아서
p.x = 5f;                    // 고치고
transform.position = p;      // 다시 대입 (set_position 호출)
```

`List<T>`의 인덱서도 프로퍼티라서 `list[0].X = 1;`이 같은 에러가 난다. 반면 배열의 `arr[0].X = 1;`은 된다. 배열 요소 접근은 메서드 호출이 아니라 **요소의 저장 위치 자체**를 가리키기 때문이다.

### 3-5. 얕은 복사

struct를 복사하면 필드가 하나씩 복사된다. 그런데 필드가 참조 타입이면 **참조만** 복사된다.

```csharp
struct Holder { public PointC Inner; }
var h1 = new Holder { Inner = new PointC() };
var h2 = h1;          // Holder는 복사되지만
h2.Inner.X = 42;      // Inner는 같은 객체라서 h1.Inner.X도 42
```

### 3-6. 언제 struct를 쓰나 (Day 04에서 자세히)

- 작고(대략 16바이트 이하), 불변이고, 짧게 쓰이고, `object`로 변환(박싱, Day 02)될 일이 드문 값
- 큰 struct는 대입하거나 넘길 때마다 통째로 복사돼서 오히려 느리다. `Matrix4x4`(64바이트)가 그 예다.
- `string`은 참조 타입이지만 불변이고 `==`가 내용 비교로 오버로드되어 있어서 값처럼 보일 뿐이다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 값 타입(value type) | 변수가 값 자체를 담는 타입. `int`, `enum`, `struct` |
| 참조 타입(reference type) | 변수가 힙 객체의 참조를 담는 타입. `class`, `string`, 배열, `delegate` |
| 얕은 복사(shallow copy) | 필드를 하나씩 복사하되 참조 필드는 참조만 복사하는 복사 |
| CS1612 | 값 타입을 반환하는 프로퍼티의 반환값 필드를 수정할 때 나는 컴파일러 오류 |
| 인라인 저장 | 값 타입이 선언된 위치(변수·객체·배열) 안에 그대로 저장되는 것 |

## 5. 확인 실습

{% hint style="info" %}
NOTE: AI, 자동완성, 검색 없이 한다. 막히면 3절 동작 원리로 돌아간다.
{% endhint %}

### 실습 1: 예측하고 실행하기 (10분)

아래 코드를 `practice/day01/Program.cs`에 **직접 타이핑**한다. 실행하기 전에 각 줄 옆에 `// 예측: ` 주석으로 출력값을 먼저 적는다.

```csharp
// 실행 가능: Program.cs
var s1 = new PointS { X = 1 };
var s2 = s1;
s2.X = 99;
Console.WriteLine($"1) s1.X = {s1.X}");

var c1 = new PointC { X = 1 };
var c2 = c1;
c2.X = 99;
Console.WriteLine($"2) c1.X = {c1.X}");

ChangeStruct(s1);
Console.WriteLine($"3) s1.X = {s1.X}");

ChangeClass(c1);
Console.WriteLine($"4) c1.X = {c1.X}");

ReplaceClass(c1);
Console.WriteLine($"5) c1.X = {c1.X}");

ChangeStructByRef(ref s1);
Console.WriteLine($"6) s1.X = {s1.X}");

var arr = new PointS[1];
arr[0].X = 7;
Console.WriteLine($"7) arr[0].X = {arr[0].X}");

var h1 = new Holder { Inner = new PointC { X = 1 } };
var h2 = h1;
h2.Inner.X = 42;
Console.WriteLine($"8) h1.Inner.X = {h1.Inner.X}");

static void ChangeStruct(PointS p) => p.X = 100;
static void ChangeClass(PointC p) => p.X = 100;
static void ReplaceClass(PointC p) => p = new PointC { X = -1 };
static void ChangeStructByRef(ref PointS p) => p.X = 100;

struct PointS { public int X; }
class PointC { public int X; }
struct Holder { public PointC Inner; }
```

<details><summary>예상 출력과 해설</summary>

```
1) s1.X = 1
2) c1.X = 99
3) s1.X = 1
4) c1.X = 100
5) c1.X = 100
6) s1.X = 100
7) arr[0].X = 7
8) h1.Inner.X = 42
```

- 3: `ChangeStruct`는 복사본을 고쳤다.
- 4: `c1`과 `c2`는 같은 객체라서 2번에서 이미 99였고, `ChangeClass`가 100으로 바꿨다.
- 5: `ReplaceClass`는 자기 매개변수(복사된 참조)만 새 객체로 바꿨다.
- 8: `Holder`는 복사됐지만 `Inner`는 같은 객체를 가리킨다(얕은 복사).

</details>

### 실습 2: CS1612를 직접 만들고 고치기 (10분)

Unity 없이 같은 상황을 만든다. 아래를 작성하고 주석을 하나씩 풀어 빌드해 본다. 에러 번호와 메시지를 적어 둔다.

```csharp
var t = new FakeTransform();
// t.Position.X = 5;       // ① 어떤 에러가 나는가?

var list = new List<PointS> { new PointS() };
// list[0].X = 5;          // ② 이것은?

class FakeTransform { public PointS Position { get; set; } }
struct PointS { public int X; }
```

과제: ①과 ②가 **실제로 값을 바꾸도록** 고쳐서 `t.Position.X`와 `list[0].X`가 5로 출력되게 만든다.

<details><summary>정답 코드</summary>

```csharp
// 실행 가능: Program.cs
var t = new FakeTransform();
var p = t.Position;   // 복사본
p.X = 5;
t.Position = p;       // 다시 대입

var list = new List<PointS> { new PointS() };
var e = list[0];
e.X = 5;
list[0] = e;

Console.WriteLine($"{t.Position.X} {list[0].X}");

class FakeTransform { public PointS Position { get; set; } }
struct PointS { public int X; }
```

출력: `5 5`. 둘 다 에러는 `CS1612: 변수가 아니므로 '...'의 반환 값을 수정할 수 없습니다`.
참고로 .NET 5 이상에는 `CollectionsMarshal.AsSpan(list)[0].X = 5;`로 리스트 내부 배열을 직접 고치는 방법도 있다. Unity에서는 쓸 수 없다.

</details>

### 실습 3 (도전): 100만 개를 만들면 메모리가 얼마나 드나 (10분)

`PointS { int X, Y; }` 100만 개를 담은 배열과 `PointC { int X, Y; }` 100만 개를 담은 배열을 만들고, 각각 할당된 바이트를 `GC.GetAllocatedBytesForCurrentThread()`로 재서 MB로 출력한다. **실행 전에 두 숫자를 예측해 적는다.** 힌트: 64비트에서 객체 하나에는 필드 외에 16바이트의 헤더가 붙는다.

<details><summary>정답 코드와 해설</summary>

```csharp
// 실행 가능: Program.cs
const int N = 1_000_000;

long before = GC.GetAllocatedBytesForCurrentThread();
var structs = new PointS[N];
for (int i = 0; i < N; i++) structs[i] = new PointS { X = i, Y = i };
long structBytes = GC.GetAllocatedBytesForCurrentThread() - before;

before = GC.GetAllocatedBytesForCurrentThread();
var classes = new PointC[N];
for (int i = 0; i < N; i++) classes[i] = new PointC { X = i, Y = i };
long classBytes = GC.GetAllocatedBytesForCurrentThread() - before;

Console.WriteLine($"struct 배열: {structBytes / 1024.0 / 1024.0:F1} MB");
Console.WriteLine($"class  배열: {classBytes / 1024.0 / 1024.0:F1} MB");
GC.KeepAlive(structs);
GC.KeepAlive(classes);

struct PointS { public int X, Y; }
class PointC { public int X, Y; }
```

출력(64비트):
```
struct 배열: 7.6 MB
class  배열: 30.5 MB
```

- struct 배열: 8바이트 × 100만 = 800만 바이트가 배열 하나 안에 연속으로 들어간다. 할당은 **1번**이다.
- class 배열: 참조 8바이트 × 100만(배열) + 객체 100만 개 × 24바이트(헤더 8 + 타입 포인터 8 + 필드 8)다. 할당은 **100만 1번**이고, GC가 추적할 객체도 100만 개 늘어난다.
- `new PointS { ... }`는 힙 할당이 아니다. struct의 `new`는 값을 초기화할 뿐이다.

</details>

## 6. 확인 문제

소리 내어 30초 안에 답해 보고 펼쳐서 비교한다.

**Q1. 값 타입과 참조 타입의 차이를 설명해 주세요.**
<details><summary>모범 답안</summary>
값 타입 변수는 값 자체를 담고, 참조 타입 변수는 힙에 있는 객체의 참조를 담습니다. 그래서 대입하거나 메서드에 넘기면 값 타입은 값 전체가 복사되고 참조 타입은 참조만 복사되어 같은 객체를 공유합니다. 참조 타입 객체는 GC가 관리하는 힙에 할당되므로, 많이 만들면 할당과 GC 비용이 생깁니다.

</details>

**Q2. "값 타입은 스택에 저장된다"는 말은 맞나요?**
<details><summary>모범 답안</summary>
반만 맞습니다. 값 타입은 선언된 곳에 인라인으로 저장됩니다. 지역 변수면 보통 스택이지만, 클래스의 필드나 배열 요소면 그 객체와 함께 힙에 있습니다. 람다가 캡처하거나 async/iterator 메서드의 지역 변수는 컴파일러가 만든 객체의 필드가 되어 힙으로 갑니다. 두 타입의 본질적 차이는 저장 위치가 아니라 복사 방식입니다.

</details>

**Q3. `transform.position.x = 10;`이 왜 컴파일되지 않나요?**
<details><summary>모범 답안</summary>
`Vector3`가 struct이고 `position`이 프로퍼티라서, getter가 값의 복사본을 반환합니다. 복사본의 필드를 바꿔도 원본에 반영되지 않으므로 컴파일러가 CS1612로 막습니다. 지역 변수에 받아서 x를 바꾼 뒤 `transform.position`에 다시 대입하면 됩니다.

</details>

**Q4. 클래스 인스턴스를 메서드에 넘기면 참조로 전달(pass by reference)되는 건가요?**
<details><summary>모범 답안</summary>
아닙니다. C#은 기본이 값 전달이고, 참조 타입은 참조를 값으로 전달합니다. 그래서 메서드 안에서 객체의 필드를 바꾸면 호출자도 보지만, 매개변수에 새 객체를 대입하면 호출자의 변수는 그대로입니다. 변수 자체를 넘기려면 `ref`나 `out`을 써야 합니다.

</details>

**Q5. struct와 class 중 무엇을 쓸지 어떻게 정하나요?**
<details><summary>모범 답안</summary>
작고(대략 16바이트 이하) 불변이며 짧게 쓰이고, 박싱될 일이 드문 데이터 묶음은 struct로 합니다. 좌표, 색, 범위 같은 값이 그렇습니다. 정체성이 있거나 공유되거나 상속이 필요하거나 크기가 큰 데이터는 class로 합니다. 큰 struct는 복사 비용이 커서 오히려 느려질 수 있습니다.

</details>

## 참조

- [값 형식 (C# 참조)](https://learn.microsoft.com/ko-kr/dotnet/csharp/language-reference/builtin-types/value-types)
- [참조 형식 (C# 참조)](https://learn.microsoft.com/ko-kr/dotnet/csharp/language-reference/keywords/reference-types)
- [구조체와 클래스 중에서 선택](https://learn.microsoft.com/ko-kr/dotnet/standard/design-guidelines/choosing-between-class-and-struct)
- [컴파일러 오류 CS1612](https://learn.microsoft.com/ko-kr/dotnet/csharp/language-reference/compiler-messages/cs1612)

다음: [Day 02 · 박싱과 언박싱](day02-boxing.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 오늘의 한 줄: Day 01의 핵심을 내 말로 한 문장으로 쓴다.
- [ ] 값 타입과 참조 타입을 "대입하면 무엇이 복사되는가"로 내 말로 설명하면?
- [ ] 내 Unity 코드에서 `transform.position`을 직접 바꾸려다 막힌 적이 있는가? 어떻게 고쳤는가?
