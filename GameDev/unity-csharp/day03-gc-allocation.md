# Day 03 · GC와 할당

> 1주차 C# 메모리 · 60분 · 준비물: .NET SDK (`dotnet new console -o practice/day03`)

## 오늘의 목표
- .NET의 세대별·압축(`compacting`) GC와 Unity의 Boehm GC가 어떻게 다른지 설명할 수 있다.
- Unity의 점진적 GC(`Incremental GC`)가 해결하는 것과 해결하지 못하는 것을 구분할 수 있다.
- 매 프레임 `Update`에서 흔히 일어나는 할당 원인을 찾고 0바이트 할당으로 고칠 수 있다.

---

## 1. 읽기 (20분)

### 1-1. 가비지 컬렉터(`GC`)가 하는 일

GC는 **루트(`root`)**에서 시작해 참조 사슬을 따라가며 살아 있는 객체를 표시(`mark`)하고, 도달할 수 없는 객체의 메모리를 회수(`sweep`)한다. 루트에는 현재 실행 중인 스택 프레임의 지역 변수·매개변수, CPU 레지스터, `static` 필드가 포함된다.

### 1-2. .NET GC vs Unity(Mono / IL2CPP) GC

| 항목 | .NET (CoreCLR) | Unity 6 (Mono / IL2CPP: Boehm–Demers–Weiser GC) |
|---|---|---|
| 세대 구분 | **세대별(`Generational`)**: Gen 0 / Gen 1 / Gen 2 + 대형 객체 힙(`LOH`, 85,000B 이상) | **비세대(`Non-generational`)**: 수거할 때 힙 전체를 스캔한다 |
| 포인터 판별 | 정확(`Precise`) | **보수적(`Conservative`)**: 비트 패턴이 힙 주소처럼 보이면 참조로 간주할 수 있다 |
| 메모리 압축 | **압축(`Compacting`)**: 살아남은 객체를 모아 빈 공간을 붙인다 | **비이동(`Non-moving`)**: 객체를 옮기지 않아 **단편화(`fragmentation`)**가 생긴다 |
| 힙 크기 | 필요 없으면 OS에 반환하기도 함 | 한 번 늘어난 관리 힙은 거의 줄어들지 않는다 |

- **.NET**: 방금 만든 짧은 수명 객체는 작은 Gen 0만 빠르게 훑어 수거하고, 큰 배열(85,000바이트 이상)은 압축 비용을 피하려고 `LOH`에 따로 둔다.
- **Unity**: Boehm GC는 세대가 없어서 GC가 한 번 돌 때 힙 전체의 객체 수와 비례해 시간이 걸린다. 또 객체를 옮기지 않으므로 작은 객체가 빠진 자리에 큰 배열이 못 들어가 힙 자체가 더 커진다.
- **점진적 GC(`Incremental GC`)**: Unity에서 기본 켜져 있는 기능으로, **표시(`mark`) 단계를 여러 프레임에 쪼개서** 한 프레임이 길게 멈추는 스파이크를 완화한다. 하지만 **할당량이나 총 GC 작업량을 줄여 주지는 않으며**, 참조가 너무 빨리 바뀌거나 메모리가 부족하면 여전히 전체 수거로 멈춘다.

결론은 단순하다. 게임에서는 **프레임마다 할당하지 않는 것**이 유일한 근본 해법이다.

### 1-3. 프레임마다 터지는 단골 할당 10가지와 해법

| 흔한 할당 코드 | 왜 할당되는가 | 무할당(`Zero-alloc`) 해법 |
|---|---|---|
| `"HP: " + hp`, `$"HP: {hp}"` (Unity C# 9) | 매번 새 `string` 할당 + C# 9 보간은 값 타입 박싱 | 값이 바뀔 때만 갱신, 재사용 `StringBuilder`, `TMP_Text.SetText` |
| `hp.ToString()`, `str.Split(',')` | 새 `string` 및 `string[]` 할당 | 값 변경 시에만 호출, `ReadOnlySpan<char>` 파싱(Day 04) |
| `enemies.Where(...).ToList()` | LINQ 이터레이터 객체 + 람다/클로저 + 결과 `List` | `for`문 + 필드에 캐시해 둔 `List<T>`를 `Clear()` 후 재사용 |
| 캡처하는 람다 `x => x > minHp` | 표시 클래스(`closure`) + `Func<>` 델리게이트 할당(Day 05) | 일반 반복문 또는 상태 인자를 직접 전달 |
| `params` 호출 `Log(a, b, c)` | 호출할 때마다 배열(`T[]`) 할당 | 고정 인자 오버로드(1~3개짜리) 따로 정의 |
| `GetComponents<T>()`, `FindObjectsByType<T>()` | 호출마다 새 배열 반환 | `Awake`/`OnEnable`에서 캐시하거나 `GetComponents(List<T>)` 오버로드 사용 |
| `Physics.RaycastAll(...)`, `OverlapSphere(...)` | 결과 배열 매번 생성 | 미리 만든 배열과 `RaycastNonAlloc` / `OverlapSphereNonAlloc` 사용 |
| 코루틴에서 `yield return new WaitForSeconds(1f)` | 매번 래퍼 객체 할당(Day 08) | `static readonly WaitForSeconds` 필드에 캐시 |
| `IEnumerable<T>` 변수에 대한 `foreach` | struct 열거자(`Enumerator`)가 인터페이스로 박싱됨 | 구체 타입(`List<T>`, `T[]`) 그대로 `foreach` 또는 `for` |
| 잦은 `Instantiate` / `Destroy` | 관리 객체 + 네이티브 객체 생성·파괴 | 오브젝트 풀링(Day 12), 로딩 화면에서만 `GC.Collect()` 호출 |

### 1-4. 측정하는 법

- **Unity**: `Profiler` 창 → `CPU Usage` 모듈 → 계층 목록의 **`GC Alloc` 컬럼**을 정렬해 프레임당 0B가 아닌 함수를 찾는다. 힙 전체 구조와 단편화는 **Memory Profiler 패키지**로 본다.
- **.NET 콘솔**: `GC.GetAllocatedBytesForCurrentThread()`로 스레드 누적 할당 바이트를, `GC.CollectionCount(0)`으로 Gen 0 수집 횟수를 잰다.

---

## 2. 손으로 확인 (30분)

> AI, 자동완성, 검색 없이. 막히면 위의 읽기로 돌아간다.

### 실습 1: 10,000프레임 가상 게임 루프 — 할당 버전 vs 무할당 버전 (20분)

적 300명의 체력 배열 `enemies`(1~300)에서 체력이 100 초과인 적의 수와 체력 합계를 구해 `uiText` 문자열을 갱신하는 `Update`를 10,000프레임 돌린다.
1. `UpdateBad`: 매 프레임 `Where(...).ToList()`, `Sum()`, `"Alive: " + ...` 문자열 연결을 쓴다.
2. `UpdateGood`: 미리 만든 `List<int>`(`Clear()` 후 재사용), `for`문, 체력 합계가 바뀌었을 때만 재사용 `StringBuilder`로 문자열을 갱신한다.

실행 전에 `UpdateGood`의 할당 바이트를 예측하고, 두 버전의 총 할당 바이트와 `GC.CollectionCount(0)` 차이를 출력한다.

<details><summary>정답 코드와 예상 출력</summary>

```csharp
// 실행 가능: Program.cs
using System.Text;

const int Frames = 10_000;
int[] enemies = Enumerable.Range(1, 300).ToArray();
string uiText = "";

// 워밍업
UpdateBad();
var reusableList = new List<int>(enemies.Length);
var sb = new StringBuilder(32);
int lastTotal = -1;
UpdateGood();

int gcBefore = GC.CollectionCount(0);
long b0 = GC.GetAllocatedBytesForCurrentThread();
for (int f = 0; f < Frames; f++) UpdateBad();
long badBytes = GC.GetAllocatedBytesForCurrentThread() - b0;
int badGc = GC.CollectionCount(0) - gcBefore;

gcBefore = GC.CollectionCount(0);
b0 = GC.GetAllocatedBytesForCurrentThread();
for (int f = 0; f < Frames; f++) UpdateGood();
long goodBytes = GC.GetAllocatedBytesForCurrentThread() - b0;
int goodGc = GC.CollectionCount(0) - gcBefore;

Console.WriteLine($"UpdateBad : {badBytes:N0} B, Gen0 GC = {badGc}회 (ui={uiText})");
Console.WriteLine($"UpdateGood: {goodBytes:N0} B, Gen0 GC = {goodGc}회 (ui={uiText})");

void UpdateBad()
{
    var alive = enemies.Where(hp => hp > 100).ToList();
    int total = alive.Sum();
    uiText = "Alive: " + alive.Count + " / HP: " + total;
}

void UpdateGood()
{
    reusableList.Clear();
    int total = 0;
    for (int i = 0; i < enemies.Length; i++)
    {
        if (enemies[i] > 100)
        {
            reusableList.Add(enemies[i]);
            total += enemies[i];
        }
    }
    if (total != lastTotal)
    {
        lastTotal = total;
        sb.Clear();
        sb.Append("Alive: ").Append(reusableList.Count).Append(" / HP: ").Append(total);
        uiText = sb.ToString();
    }
}
```

예상 출력(.NET 9, 10 기준. .NET 8에서는 LINQ 내부 구현이 달라 `UpdateBad`가 약 23,840,000 B로 더 크다. `Gen0 GC` 횟수는 머신 메모리에 따라 다르다):
```
UpdateBad : 10,080,000 B, Gen0 GC = 0회 (ui=Alive: 200 / HP: 40100)
UpdateGood: 0 B, Gen0 GC = 0회 (ui=Alive: 200 / HP: 40100)
```

`UpdateBad`는 10,000프레임(60fps 기준 약 2분 46초) 만에 약 10MB의 쓰레기를 만든다. 데스크톱 .NET은 Gen 0 예산이 커서 GC가 0회로 나올 수 있지만, 힙이 작은 Unity의 Boehm GC에서는 이 쓰레기가 그대로 주기적인 수거로 이어진다. `UpdateGood`은 워밍업 이후 10,000프레임 동안 **0바이트**를 할당한다.

</details>

### 실습 2: `List<int>` vs `IEnumerable<int>` 변수의 `foreach` 할당 차이 (10분)

같은 `List<int>` 객체를 (1) `List<int>` 타입 변수로, (2) `IEnumerable<int>` 타입 변수로 각각 10,000번 `foreach` 순회할 때 할당 바이트를 예측하고 측정한다.

<details><summary>정답 코드와 예상 출력</summary>

```csharp
// 실행 가능: Program.cs
const int N = 10_000;
var list = new List<int> { 1, 2, 3, 4 };
IEnumerable<int> asInterface = list;

long b0 = GC.GetAllocatedBytesForCurrentThread();
int s1 = 0;
for (int i = 0; i < N; i++)
    foreach (int x in list) s1 += x;
long listBytes = GC.GetAllocatedBytesForCurrentThread() - b0;

b0 = GC.GetAllocatedBytesForCurrentThread();
int s2 = 0;
for (int i = 0; i < N; i++)
    foreach (int x in asInterface) s2 += x;
long ifaceBytes = GC.GetAllocatedBytesForCurrentThread() - b0;

Console.WriteLine($"List<int> foreach       : {listBytes} B (sum={s1})");
Console.WriteLine($"IEnumerable<int> foreach: {ifaceBytes} B (sum={s2})");
```

출력:
```
List<int> foreach       : 0 B (sum=100000)
IEnumerable<int> foreach: 400000 B (sum=100000)
```

`List<int>.GetEnumerator()`는 `List<int>.Enumerator`라는 **struct**를 직접 반환하므로 `foreach`가 박싱 없이 순회한다(Day 07). 하지만 변수를 `IEnumerable<int>`로 선언하면 인터페이스 메서드 `IEnumerable<int>.GetEnumerator()`가 호출되어 struct 열거자가 `IEnumerator<int>`로 **박싱**(회당 40바이트)된다.

</details>

---

## 3. 면접 대비 (10분)

소리 내어 30초 안에 답해 보고 펼쳐서 비교한다.

**Q1. Unity의 GC는 일반 .NET GC와 어떻게 다르고, 그래서 무엇을 조심해야 하나요?**
<details><summary>모범 답안</summary>
.NET은 세대별(Gen 0/1/2) 압축(Compacting) GC를 쓰지만, Unity(Mono/IL2CPP)는 세대 구분이 없고 객체를 이동시키지 않는 Boehm GC를 씁니다. 세대가 없으므로 수거할 때 힙 전체를 검사해 객체 수가 많을수록 멈춤 시간이 길어지고, 압축을 하지 않아 메모리 단편화가 생기며 한 번 늘어난 관리 힙이 잘 줄어들지 않습니다. 따라서 프레임마다 작은 객체라도 할당하지 않도록 버퍼 재사용과 풀링을 철저히 해야 합니다.

</details>

**Q2. Unity의 Incremental GC(점진적 GC)를 켜면 GC 문제를 신경 쓰지 않아도 되나요?**
<details><summary>모범 답안</summary>
아닙니다. Incremental GC는 표시(mark) 작업을 여러 프레임에 나누어 수행해 한 프레임에 몰리는 스파이크를 완화할 뿐, 총 할당량이나 GC가 해야 할 전체 작업량을 줄여 주지 않습니다. 또한 프레임마다 할당이 많거나 참조가 빠르게 바뀌면 분할 작업을 따라잡지 못해 결국 전체 수거가 발생하고, 비이동 GC의 단편화 문제도 그대로 남습니다.

</details>

**Q3. 게임 플레이 중 주기적으로 프레임 스파이크가 발생할 때 GC가 원인인지 어떻게 찾고 해결하나요?**
<details><summary>모범 답안</summary>
먼저 Unity Profiler의 CPU Usage에서 스파이크 프레임에 `GC.Collect` 마커가 잡히는지 확인합니다. 확인되면 평상시 프레임들의 Hierarchy 뷰에서 `GC Alloc` 컬럼을 내림차순으로 정렬해 프레임마다 할당하는 메서드를 찾습니다. 문자열 조합, LINQ, `RaycastAll` 같은 배열 반환 API, 박싱 등을 찾아 캐싱, `Clear()` 후 컬렉션 재사용, NonAlloc API, 오브젝트 풀로 교체합니다.

</details>

**Q4. `List<T>`를 `foreach`로 돌면 가비지가 생기나요?**
<details><summary>모범 답안</summary>
`List<T>` 타입 변수 그대로 `foreach`를 쓰면 `List<T>.GetEnumerator()`가 struct 열거자를 반환하므로 힙 할당이 0바이트입니다. 다만 같은 리스트라도 `IEnumerable<T>`나 `IReadOnlyList<T>` 같은 인터페이스 타입 변수에 담아 `foreach`를 돌리면 열거자 struct가 `IEnumerator<T>`로 박싱되어 순회할 때마다 가비지가 생깁니다.

</details>

---

## 오늘의 한 줄
> (내 말로 한 문장)

## 더 보기
- [가비지 수집 기본 사항 (.NET)](https://learn.microsoft.com/ko-kr/dotnet/standard/garbage-collection/fundamentals)
- [Unity 매뉴얼 — 관리되는 메모리(Managed memory) 개요](https://docs.unity3d.com/Manual/performance-managed-memory.html)
- [Unity 매뉴얼 — 점진적 가비지 컬렉션(Incremental GC)](https://docs.unity3d.com/Manual/performance-incremental-garbage-collection.html)
- [Unity 매뉴얼 — 가비지 컬렉터 개요](https://docs.unity3d.com/Manual/performance-garbage-collector.html)
