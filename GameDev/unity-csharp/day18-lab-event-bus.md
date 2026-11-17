# Day 18 · [실습] 이벤트 버스

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UCS-019-MP |
| 유형 | MP (절차) + 기능 확인 |
| 목적 | 무할당(0 B)이며 `Publish` 중 구독 해제와 핸들러 예외에 안전한 제네릭 이벤트 버스 `EventBus<T>`를 구현하고 검증한다 |
| 적용 대상 | .NET 8 이상 콘솔 (macOS, `dotnet` CLI). Unity 이식은 설계 개요 D-4 참조 |
| 소요 시간 | 3주차 렌더링과 측정 · 60분 (설계 읽기 10, 구현 45, 회고 5) |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- 제네릭 정적 클래스 `EventBus<T> where T : struct`가 어떻게 `Dictionary` 조회나 박싱 없이 타입별 독립 저장소를 갖는지 설명할 수 있다.
- `Publish` 도중 구독·해제가 일어나거나 한 핸들러가 예외를 던져도 안전하게 동작하는 무할당(0 B) 이벤트 버스를 구현할 수 있다.
- 구독 해제를 잊었을 때 왜 정적 참조 때문에 객체가 GC되지 않는지 `WeakReference`로 증명하고, Unity의 생명주기(`OnEnable`/`OnDisable`)와 도메인 리로드 비활성화 대응법을 설명할 수 있다.

## 설계 개요

### D-1. 왜 이벤트 버스를 쓰는가: 결합도 vs 추적 난이도

플레이어가 적을 처치했을 때 점수 UI, 효과음, 업적, 퀘스트 시스템이 모두 반응해야 한다고 하자. `Player` 클래스가 `UIManager`, `SoundManager`, `AchievementSystem`을 전부 필드로 참조해 직접 호출하면 결합도가 치솟는다. 이벤트 버스(`Event Bus`, 발행-구독 패턴)를 두면 발행자(`Publisher`)는 `EventBus<EnemyKilled>.Publish(...)`만 호출하고 누가 듣는지 몰라도 된다.

| 장점 | 단점(남용 시 문제) |
|---|---|
| 발행자와 구독자가 서로를 몰라도 됨(낮은 결합도) | 코드에서 `Publish`만 보고는 **누가 어떤 순서로 실행되는지** 따라가기 어려움 |
| UI, 사운드, 업적 같은 부가 시스템을 쉽게 붙였다 뗄 수 있음 | 구독자 실행 순서에 의존하는 로직이 섞이면 버그가 됨 |
| | **`Unsubscribe`를 빼먹으면 정적 리스트가 구독자 인스턴스를 붙잡아 메모리 누수 발생** (Day 05) |

### D-2. 왜 `static class EventBus<T> where T : struct`인가

비제네릭 `EventBus`에 `Dictionary<Type, List<Delegate>>`를 두면 `Publish`할 때마다 `typeof(T)` 해시 조회가 일어나고, 이벤트를 `object`나 인터페이스로 넘기면 **박싱(`boxing`, Day 02)**까지 발생한다.

반면 CLR에서 **제네릭 타입의 `static` 필드는 닫힌 타입(`closed generic type`)마다 별도로 생성**된다. 즉 `EventBus<PlayerDamaged>.Handlers`와 `EventBus<EnemyKilled>.Handlers`는 애초에 서로 다른 정적 변수다.
- `Dictionary` 해시 조회가 필요 없다.
- `where T : struct` 제약과 `Publish(in T evt)`를 쓰면 이벤트 데이터 자체가 힙에 할당되지 않는다.

### D-3. Publish 도중 Subscribe/Unsubscribe가 일어날 때의 3가지 해법

핸들러 안에서 "1회성 방어막 발동 후 자기 자신 구독 해제(`Unsubscribe`)"를 호출할 때 `foreach (var h in Handlers)`로 돌고 있었다면 `InvalidOperationException(Collection was modified)`이 터진다. 이를 막는 방법은 세 가지다.

| 방식 | 원리 | 트레이드오프 |
|---|---|---|
| **1) 사전 할당 스냅샷 버퍼 복사** | `Publish` 시작 시 정적 `Snapshot` 리스트를 비우고(`Clear`) 현재 `Handlers`를 복사한 뒤 `Snapshot`을 정방향 순회 | 등록 순서(FIFO) 유지. 워밍업 이후 내부 배열이 재사용되어 **할당 0 바이트**(단, 같은 이벤트 `T`를 재귀 발행하면 별도 대처 필요) |
| **2) 지연 반영 리스트(Deferred)** | `isPublishing` 동안 들어온 추가·삭제를 `Pending` 큐에 모았다가 루프 끝에 반영 | 등록 순서 유지. 중첩 `Publish` 깊이 카운팅 필요 |
| **3) 역방향 `for` 루프** | `for (int i = Handlers.Count - 1; i >= 0; i--)`로 뒤에서부터 순회 | 복사 비용 0. 단, 호출 순서가 **등록 역순(LIFO)**이 되고 현재 인덱스 앞쪽 항목이 지워지면 인덱스가 밀림 |

이번 실습에서는 등록 순서가 그대로 유지되고 워밍업 후 할당이 0 바이트인 **1번(사전 할당 스냅샷 리스트)**으로 구현한다.

### D-4. Unity에서의 주의점 2가지

1. **`OnEnable`에서 구독, `OnDisable`에서 해제**: `MonoBehaviour`가 비활성화되거나 `Destroy`될 때 정적 `EventBus<T>`에 델리게이트가 남아 있으면 파괴된 래퍼(Day 20)를 계속 붙잡아 메모리 누수를 일으키고, 핸들러가 그 오브젝트의 `transform` 같은 멤버에 접근하는 순간 `MissingReferenceException`이 난다.
2. **Enter Play Mode Options(Domain Reload 비활성화) 대응**: Unity에서 빠른 플레이 진입을 위해 `Reload Domain`을 끄면, 플레이 모드를 껐다 켜도 C# `static` 필드가 초기화되지 않고 이전 플레이의 구독자가 남는다. 제네릭 정적 클래스는 닫힌 타입마다 `Clear()`를 따로 호출해야 하므로, 이벤트 타입을 모아 두는 정적 초기화 레지스트리나 `[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]`으로 플레이 시작 시 `Clear()`를 호출해 주어야 한다.

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [day02-boxing.md](day02-boxing.md) | GMD-UCS-003-DO | Day 02 · 박싱과 언박싱 |
| [day05-delegate-closure.md](day05-delegate-closure.md) | GMD-UCS-006-DO | Day 05 · 델리게이트, 람다, 클로저 |
| [day20-unity-object-null.md](day20-unity-object-null.md) | GMD-UCS-021-DO | Day 20 · UnityEngine.Object와 null |
- [제네릭 클래스와 정적 필드 (C# 프로그래밍 가이드)](https://learn.microsoft.com/ko-kr/dotnet/csharp/programming-guide/generics/generic-classes)
- [이벤트 처리 및 발생 (Microsoft Learn)](https://learn.microsoft.com/ko-kr/dotnet/standard/events/)
- [도메인 리로드 설정과 정적 필드 초기화 (Unity 공식 문서)](https://docs.unity3d.com/Manual/DomainReloading.html)

이전: [Day 17 프로파일러 읽는 법](day17-profiler.md) · 다음: [Day 19 MonoBehaviour 생명주기](day19-monobehaviour-lifecycle.md)

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | .NET SDK | 8 이상 | `dotnet --version`으로 확인한다 |
| 2 | 터미널과 편집기 | AI 기능을 끈 편집기 | AI 채팅, 자동완성, 검색을 쓰지 않는다 |
| 3 | 작업 폴더 | `practice/day18/` | 이 폴더 안에서만 작업한다 |

## 3. 안전 사항

{% hint style="info" %}
NOTE: 이 작업은 `practice/day18/` 폴더 밖의 파일을 건드리지 않는다. 데이터 손실 위험은 없다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 이 이벤트 버스는 단일 스레드용이다. 정적 `Snapshot` 리스트를 공유하므로 여러 스레드에서 `Publish`하면 안 된다. 같은 이벤트 `T`를 핸들러 안에서 재귀 발행하는 경우도 처리하지 않는다(회고 질문 2).
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 터미널을 연다 | 프롬프트가 나타난다 |
| 2 | `dotnet --version`을 실행한다 | 8.0 이상이 출력된다 |
| 3 | 설계 개요의 D-1~D-4를 읽는다 | 스냅샷 방식을 고른 이유를 한 문장으로 말할 수 있다 |

## 5. 절차

### 요구사항

1. `static class EventBus<T> where T : struct`를 구현한다.
   - `Subscribe(Action<T> handler)`: 중복 등록을 막고 리스트에 추가한다.
   - `Unsubscribe(Action<T> handler)`: 리스트에서 제거한다.
   - `Clear()`: 등록된 핸들러와 스냅샷 버퍼를 비운다.
   - `Publish(in T evt)`: 사전 할당된 `Snapshot` 리스트를 사용해 순회 도중 `Unsubscribe`가 호출되어도 안전하게 정방향 실행한다.
2. **예외 격리**: 핸들러 하나가 예외를 던져도 `try-catch`로 `[EventBus 오류] <메시지>`를 출력하고 나머지 핸들러를 끝까지 실행한다.
3. **무할당 증명**: 워밍업 1회 후 `Publish(in dmg1)`를 **10,000번** 호출하는 루프 전후의 `GC.GetAllocatedBytesForCurrentThread()` 차이가 **정확히 `0 B`**인지 출력한다.
4. **누수 증명(`WeakReference`)**: 별도 메서드(`[MethodImpl(MethodImplOptions.NoInlining)]`)에서 구독자 객체를 만들어 `Subscribe`만 하고 반환한 뒤, `GC.Collect()` 후에도 `WeakReference.IsAlive`가 `True`(누수)임을 확인하고, `Clear()` 후 다시 `GC.Collect()`하면 `False`(수거됨)가 되는 것을 출력한다.

### A. 프로젝트 만들기

1. (5-A-01) 콘솔 프로젝트를 만든다: `dotnet new console -o practice/day18` → 결과: `practice/day18/Program.cs`가 생긴다.
2. (5-A-02) 폴더로 이동한다: `cd practice/day18` → 결과: 프롬프트의 경로가 `practice/day18`이다.

### B. 이벤트 버스 구현

1. (5-B-01) `Program.cs`에 `readonly struct PlayerDamaged(Damage, RemainingHp)`와 `readonly struct EnemyKilled(EnemyId, Score)`를 작성한다. → 결과: 두 struct가 컴파일된다.
2. (5-B-02) `static class EventBus<T> where T : struct`에 `Handlers`와 `Snapshot` 정적 리스트를 선언한다. → 결과: 두 리스트가 `static readonly`다.
3. (5-B-03) `Subscribe`와 `Unsubscribe`를 작성한다. `Subscribe`는 `Contains`로 중복을 막는다. → 결과: 같은 핸들러를 두 번 등록해도 한 번만 들어간다.
4. (5-B-04) `Clear`를 작성한다. → 결과: `Handlers`와 `Snapshot`이 모두 비워진다.
5. (5-B-05) `Publish(in T evt)`를 작성한다. 먼저 `Handlers`를 `Snapshot`으로 복사하고 `Snapshot`을 정방향으로 순회한다. → 결과: 핸들러 안에서 `Unsubscribe`해도 `InvalidOperationException`이 나지 않는다.
6. (5-B-06) 각 핸들러 호출을 `try-catch`로 감싸 `[EventBus 오류] <메시지>`를 출력한다. → 결과: 예외를 던지는 핸들러 뒤의 핸들러도 실행된다.

### C. 피격·처치 시나리오 작성

1. (5-C-01) 1회성 방어막, UI, 예외를 던지는 로거, 사운드 핸들러를 이 순서로 `PlayerDamaged`에 구독한다. → 결과: 핸들러 4개가 등록된다.
2. (5-C-02) `PlayerDamaged(15, 85)`와 `PlayerDamaged(20, 65)`를 차례로 발행한다. → 결과: 2차 발행에서 방어막 줄이 나오지 않는다.
3. (5-C-03) `EnemyKilled`에 UI, 사운드, 업적(2마리 처치 시 출력) 핸들러를 구독하고 `(101, 100)`, `(102, 150)`을 발행한다. → 결과: 업적 줄이 두 번째 발행 뒤에 나온다.

### D. 무할당 측정

1. (5-D-01) `EventBus<PlayerDamaged>.Clear()` 후 누적 데미지를 더하는 핸들러를 구독하고 워밍업으로 1회 발행한다. → 결과: 오류 없이 끝난다.
2. (5-D-02) `GC.GetAllocatedBytesForCurrentThread()`를 읽은 뒤 `Publish(in dmg1)`를 10,000번 호출하고 다시 읽는다. → 결과: 두 값의 차이가 계산된다.
3. (5-D-03) 차이와 누적 데미지를 출력한다. → 결과: `10,000회 Publish 할당: 0 B (누적 데미지: 150015)`가 출력된다.

### E. 누수 증명

1. (5-E-01) `[MethodImpl(MethodImplOptions.NoInlining)]`를 붙인 `CreateLeakySubscriber()`를 작성한다. 이 메서드는 `DamagePopup`을 만들어 `Subscribe`하고 `WeakReference`를 반환한다. → 결과: 메서드가 컴파일된다.
2. (5-E-02) `Clear()` 후 `CreateLeakySubscriber()`를 호출하고 `GC.Collect()`, `GC.WaitForPendingFinalizers()`, `GC.Collect()`를 실행한다. → 결과: `IsAlive`가 `True`로 출력된다.
3. (5-E-03) `Clear()`를 호출하고 같은 GC 순서를 다시 실행한다. → 결과: `IsAlive`가 `False`로 출력된다.

### F. 실행과 비교

1. (5-F-01) 실행한다: `dotnet run` → 결과: 아래 예상 출력과 한 줄씩 비교한다.
2. (5-F-02) 다르면 5-B~5-E에서 해당 단계를 고치고 다시 실행한다. → 결과: 출력이 일치한다.

**예상 출력**
```
=== 1차 피격 ===
[Shield] 첫 피격 방어 발동! (구독 자동 해제)
[UI] 체력바 갱신: -15 (남은 HP: 85)
[EventBus 오류] 로거 오류
[Sound] 피격 효과음 재생 (데미지 15)
=== 2차 피격 ===
[UI] 체력바 갱신: -20 (남은 HP: 65)
[EventBus 오류] 로거 오류
[Sound] 피격 효과음 재생 (데미지 20)
=== 적 처치 ===
[UI] +100점 (101 처치)
[Sound] 처치 효과음: 101
[UI] +150점 (102 처치)
[Sound] 처치 효과음: 102
[Achievement] 업적 달성: 사냥의 시작 (2마리 처치)
=== 할당 측정 ===
10,000회 Publish 할당: 0 B (누적 데미지: 150015)
=== 누수 확인 ===
Unsubscribe 전 GC 후 생존: True
Clear 후 GC 후 생존: False
```

{% hint style="info" %}
NOTE: `GC.Collect()` 결과는 Debug 빌드에서 지역 변수 수명이 길어져 달라질 수 있다. 누수 확인이 기대와 다르면 `dotnet run -c Release`로 다시 실행한다. 확인 필요.
{% endhint %}

### 구역 G 확장 (선택)

1. (5-G-01) 본인의 팀 프로젝트에 있는 `EventBus<T>` 구현을 연다. → 결과: 파일이 열린다.
2. (5-G-02) 지금 작성한 코드와 다른 점 3가지를 찾아 노트에 적는다. 예: 이벤트 제약 조건, 스냅샷·순회 방식, 도메인 리로드 초기화 유무, 예외 처리 방식. → 결과: 노트에 3줄이 있다.

{% hint style="info" %}
NOTE: Unity 6은 C# 9까지 지원한다. 위 코드를 Unity로 옮길 때는 `Action<T>?` 같은 nullable 참조 표기와 `Console.WriteLine`을 `Debug.Log`로 바꾼다. 프로젝트의 C# 언어 버전과 nullable 설정은 버전 확인 필요.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `dotnet run` | 예상 출력과 같은 줄이 출력된다 | 모든 줄 일치 |
| 2 | 1차·2차 피격 출력 비교 | 방어막 줄이 1차에만 나온다 | `Publish` 중 `Unsubscribe` 안전 |
| 3 | 로거 핸들러 뒤 줄 확인 | `[EventBus 오류] 로거 오류` 뒤에 `[Sound]` 줄이 나온다 | 예외 격리 |
| 4 | 할당 측정 줄 확인 | `10,000회 Publish 할당: 0 B` | 정확히 `0 B` |
| 5 | 누수 확인 줄 확인 | `True` 다음 `False` | 순서 일치 |

## 7. 복구

1. (7-01) 작업 폴더를 지운다: `rm -r practice/day18` → 결과: `practice/day18`이 없어진다. 다른 폴더는 변하지 않는다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM 형식(MP)으로 재작성. 절차를 구역 A~G로 나누고 기능 확인·복구 절을 추가. `MissingReferenceException` 설명과 도메인 리로드 설명 정정 |

## 부록 A. 참고 구현

<details><summary>참고 구현</summary>

```csharp
// 실행 가능: Program.cs
using System.Runtime.CompilerServices;

// 1. 기본 발행 + 일회성 구독(Publish 중 자기 자신 해제) + 예외 격리 테스트
Action<PlayerDamaged>? oneShotShield = null;
oneShotShield = e =>
{
    Console.WriteLine("[Shield] 첫 피격 방어 발동! (구독 자동 해제)");
    EventBus<PlayerDamaged>.Unsubscribe(oneShotShield!);
};

Action<PlayerDamaged> uiHandler = e => Console.WriteLine($"[UI] 체력바 갱신: -{e.Damage} (남은 HP: {e.RemainingHp})");
Action<PlayerDamaged> brokenLogger = _ => throw new InvalidOperationException("로거 오류");
Action<PlayerDamaged> soundHandler = e => Console.WriteLine($"[Sound] 피격 효과음 재생 (데미지 {e.Damage})");

EventBus<PlayerDamaged>.Subscribe(oneShotShield);
EventBus<PlayerDamaged>.Subscribe(uiHandler);
EventBus<PlayerDamaged>.Subscribe(brokenLogger);
EventBus<PlayerDamaged>.Subscribe(soundHandler);

Console.WriteLine("=== 1차 피격 ===");
var dmg1 = new PlayerDamaged(15, 85);
EventBus<PlayerDamaged>.Publish(in dmg1);

Console.WriteLine("=== 2차 피격 ===");
var dmg2 = new PlayerDamaged(20, 65);
EventBus<PlayerDamaged>.Publish(in dmg2);

// 2. EnemyKilled 이벤트 (UI, 사운드, 업적)
int killCount = 0;
EventBus<EnemyKilled>.Subscribe(e => Console.WriteLine($"[UI] +{e.Score}점 ({e.EnemyId} 처치)"));
EventBus<EnemyKilled>.Subscribe(e => Console.WriteLine($"[Sound] 처치 효과음: {e.EnemyId}"));
EventBus<EnemyKilled>.Subscribe(e =>
{
    if (++killCount == 2)
        Console.WriteLine("[Achievement] 업적 달성: 사냥의 시작 (2마리 처치)");
});

Console.WriteLine("=== 적 처치 ===");
var kill1 = new EnemyKilled(101, 100);
var kill2 = new EnemyKilled(102, 150);
EventBus<EnemyKilled>.Publish(in kill1);
EventBus<EnemyKilled>.Publish(in kill2);

// 3. 10,000회 Publish 무할당(0 B) 검증
EventBus<PlayerDamaged>.Clear();
int totalDamage = 0;
EventBus<PlayerDamaged>.Subscribe(e => totalDamage += e.Damage);
EventBus<PlayerDamaged>.Publish(in dmg1); // 워밍업 1회

long before = GC.GetAllocatedBytesForCurrentThread();
for (int i = 0; i < 10_000; i++)
{
    EventBus<PlayerDamaged>.Publish(in dmg1);
}
long allocated = GC.GetAllocatedBytesForCurrentThread() - before;
Console.WriteLine("=== 할당 측정 ===");
Console.WriteLine($"10,000회 Publish 할당: {allocated} B (누적 데미지: {totalDamage})");

// 4. 구독 해제 누락에 의한 메모리 누수 데모 (WeakReference)
EventBus<PlayerDamaged>.Clear();
WeakReference leakRef = CreateLeakySubscriber();
GC.Collect();
GC.WaitForPendingFinalizers();
GC.Collect();
Console.WriteLine("=== 누수 확인 ===");
Console.WriteLine($"Unsubscribe 전 GC 후 생존: {leakRef.IsAlive}");

EventBus<PlayerDamaged>.Clear();
GC.Collect();
GC.WaitForPendingFinalizers();
GC.Collect();
Console.WriteLine($"Clear 후 GC 후 생존: {leakRef.IsAlive}");

[MethodImpl(MethodImplOptions.NoInlining)]
static WeakReference CreateLeakySubscriber()
{
    var popup = new DamagePopup("임시 팝업");
    EventBus<PlayerDamaged>.Subscribe(popup.OnDamaged);
    return new WeakReference(popup);
}

readonly struct PlayerDamaged
{
    public readonly int Damage;
    public readonly int RemainingHp;
    public PlayerDamaged(int damage, int remainingHp) { Damage = damage; RemainingHp = remainingHp; }
}

readonly struct EnemyKilled
{
    public readonly int EnemyId;
    public readonly int Score;
    public EnemyKilled(int enemyId, int score) { EnemyId = enemyId; Score = score; }
}

class DamagePopup
{
    private readonly string name;
    public DamagePopup(string name) => this.name = name;
    public void OnDamaged(PlayerDamaged e) => Console.WriteLine($"{name}: {e.Damage}");
}

static class EventBus<T> where T : struct
{
    private static readonly List<Action<T>> Handlers = new();
    private static readonly List<Action<T>> Snapshot = new();

    public static void Subscribe(Action<T> handler)
    {
        if (!Handlers.Contains(handler))
            Handlers.Add(handler);
    }

    public static void Unsubscribe(Action<T> handler)
    {
        Handlers.Remove(handler);
    }

    public static void Clear()
    {
        Handlers.Clear();
        Snapshot.Clear();
    }

    public static void Publish(in T evt)
    {
        Snapshot.Clear();
        for (int i = 0; i < Handlers.Count; i++)
            Snapshot.Add(Handlers[i]);

        for (int i = 0; i < Snapshot.Count; i++)
        {
            try
            {
                Snapshot[i].Invoke(evt);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[EventBus 오류] {ex.Message}");
            }
        }
    }
}
```

</details>

## 부록 B. 회고

아래 질문에 스스로 답해 본다.

1. `EventBus<T>.Subscribe(e => OnDamaged(e))`처럼 람다로 구독하면 나중에 왜 `Unsubscribe`할 수 없는가? (Day 05 복습)
2. 만약 `PlayerDamaged` 핸들러 안에서 또 `EventBus<PlayerDamaged>.Publish(...)`를 재귀적으로 호출한다면 위 `Snapshot` 리스트 구조에서 어떤 문제가 생기고 어떻게 고칠 수 있는가?
3. 모든 함수 호출을 다 `EventBus`로 바꾸면 왜 유지보수가 힘들어지는가? 직접 참조(또는 C# `event`)를 써야 할 때와 전역 `EventBus`를 써야 할 때의 기준은 무엇인가?
