# Day 18 · [실습] 이벤트 버스

> 3주차 렌더링과 측정 · 60분 · 준비물: .NET SDK (`dotnet new console -o practice/day18`)

## 오늘의 목표
- 제네릭 정적 클래스 `EventBus<T> where T : struct`가 어떻게 `Dictionary` 조회나 박싱 없이 타입별 독립 저장소를 갖는지 설명할 수 있다.
- `Publish` 도중 구독·해제가 일어나거나 한 핸들러가 예외를 던져도 안전하게 동작하는 무할당(0 B) 이벤트 버스를 구현할 수 있다.
- 구독 해제를 잊었을 때 왜 정적 참조 때문에 객체가 GC되지 않는지 `WeakReference`로 증명하고, Unity의 생명주기(`OnEnable`/`OnDisable`)와 도메인 리로드 비활성화 대응법을 설명할 수 있다.

---

## 1. 설계 읽기 (10분)

### 1-1. 왜 이벤트 버스를 쓰는가: 결합도 vs 추적 난이도

플레이어가 적을 처치했을 때 점수 UI, 효과음, 업적, 퀘스트 시스템이 모두 반응해야 한다고 하자. `Player` 클래스가 `UIManager`, `SoundManager`, `AchievementSystem`을 전부 필드로 참조해 직접 호출하면 결합도가 치솟는다. 이벤트 버스(`Event Bus`, 발행-구독 패턴)를 두면 발행자(`Publisher`)는 `EventBus<EnemyKilled>.Publish(...)`만 호출하고 누가 듣는지 몰라도 된다.

| 장점 | 단점(남용 시 문제) |
|---|---|
| 발행자와 구독자가 서로를 몰라도 됨(낮은 결합도) | 코드에서 `Publish`만 보고는 **누가 어떤 순서로 실행되는지** 따라가기 어려움 |
| UI, 사운드, 업적 같은 부가 시스템을 쉽게 붙였다 뗄 수 있음 | 구독자 실행 순서에 의존하는 로직이 섞이면 버그가 됨 |
| | **`Unsubscribe`를 빼먹으면 정적 리스트가 구독자 인스턴스를 붙잡아 메모리 누수 발생** (Day 05) |

### 1-2. 왜 `static class EventBus<T> where T : struct`인가

비제네릭 `EventBus`에 `Dictionary<Type, List<Delegate>>`를 두면 `Publish`할 때마다 `typeof(T)` 해시 조회가 일어나고, 이벤트를 `object`나 인터페이스로 넘기면 **박싱(`boxing`, Day 02)**까지 발생한다.

반면 CLR에서 **제네릭 타입의 `static` 필드는 닫힌 타입(`closed generic type`)마다 별도로 생성**된다. 즉 `EventBus<PlayerDamaged>.Handlers`와 `EventBus<EnemyKilled>.Handlers`는 애초에 서로 다른 정적 변수다.
- `Dictionary` 해시 조회가 필요 없다.
- `where T : struct` 제약과 `Publish(in T evt)`를 쓰면 이벤트 데이터 자체가 힙에 할당되지 않는다.

### 1-3. Publish 도중 Subscribe/Unsubscribe가 일어날 때의 3가지 해법

핸들러 안에서 "1회성 방어막 발동 후 자기 자신 구독 해제(`Unsubscribe`)"를 호출할 때 `foreach (var h in Handlers)`로 돌고 있었다면 `InvalidOperationException(Collection was modified)`이 터진다. 이를 막는 방법은 세 가지다.

| 방식 | 원리 | 트레이드오프 |
|---|---|---|
| **1) 사전 할당 스냅샷 버퍼 복사** | `Publish` 시작 시 정적 `Snapshot` 리스트를 비우고(`Clear`) 현재 `Handlers`를 복사한 뒤 `Snapshot`을 정방향 순회 | 등록 순서(FIFO) 유지. 워밍업 이후 내부 배열이 재사용되어 **할당 0 바이트**(단, 같은 이벤트 `T`를 재귀 발행하면 별도 대처 필요) |
| **2) 지연 반영 리스트(Deferred)** | `isPublishing` 동안 들어온 추가·삭제를 `Pending` 큐에 모았다가 루프 끝에 반영 | 등록 순서 유지. 중첩 `Publish` 깊이 카운팅 필요 |
| **3) 역방향 `for` 루프** | `for (int i = Handlers.Count - 1; i >= 0; i--)`로 뒤에서부터 순회 | 복사 비용 0. 단, 호출 순서가 **등록 역순(LIFO)**이 되고 현재 인덱스 앞쪽 항목이 지워지면 인덱스가 밀림 |

이번 실습에서는 등록 순서가 그대로 유지되고 워밍업 후 할당이 0 바이트인 **1번(사전 할당 스냅샷 리스트)**으로 구현한다.

### 1-4. Unity에서의 주의점 2가지

1. **`OnEnable`에서 구독, `OnDisable`에서 해제**: `MonoBehaviour`가 비활성화되거나 `Destroy`될 때 정적 `EventBus<T>`에 델리게이트가 남아 있으면 파괴된 래퍼(Day 20)를 계속 호출해 `MissingReferenceException`과 메모리 누수를 일으킨다.
2. **Enter Play Mode Options(Domain Reload 비활성화) 대응**: Unity에서 빠른 플레이 진입을 위해 `Reload Domain`을 끄면, 플레이 모드를 껐다 켜도 C# `static` 필드가 초기화되지 않고 이전 플레이의 구독자가 남는다. 제네릭이 아닌 정적 초기화 레지스트리나 `[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]`으로 플레이 시작 시 `Clear()`를 호출해 주어야 한다.

---

## 2. 구현 (45분)

> AI, 자동완성, 검색 없이. 막히면 위의 읽기로 돌아간다.

### 요구사항

`practice/day18/Program.cs`에 아래 조건을 만족하는 이벤트 버스와 검증 시나리오를 직접 작성한다.

1. `static class EventBus<T> where T : struct`를 구현한다.
   - `Subscribe(Action<T> handler)`: 중복 등록을 막고 리스트에 추가한다.
   - `Unsubscribe(Action<T> handler)`: 리스트에서 제거한다.
   - `Clear()`: 등록된 핸들러와 스냅샷 버퍼를 비운다.
   - `Publish(in T evt)`: 사전 할당된 `Snapshot` 리스트를 사용해 순회 도중 `Unsubscribe`가 호출되어도 안전하게 정방향 실행한다.
2. **예외 격리**: 핸들러 하나가 예외를 던져도 `try-catch`로 `[EventBus 오류] <메시지>`를 출력하고 나머지 핸들러를 끝까지 실행한다.
3. **무할당 증명**: 워밍업 1회 후 `Publish(in dmg1)`를 **10,000번** 호출하는 루프 전후의 `GC.GetAllocatedBytesForCurrentThread()` 차이가 **정확히 `0 B`**인지 출력한다.
4. **누수 증명(`WeakReference`)**: 별도 메서드(`[MethodImpl(MethodImplOptions.NoInlining)]`)에서 구독자 객체를 만들어 `Subscribe`만 하고 반환한 뒤, `GC.Collect()` 후에도 `WeakReference.IsAlive`가 `True`(누수)임을 확인하고, `Clear()` 후 다시 `GC.Collect()`하면 `False`(수거됨)가 되는 것을 출력한다.

### 테스트 시나리오와 예상 출력

아래 시나리오 순서대로 실행했을 때 출력이 정확히 일치해야 한다.
- `PlayerDamaged(Damage, RemainingHp)` 발행:
  - 1차 피격(데미지 15, 남은 HP 85): 일회성 방어막 핸들러(출력 후 자기 자신 `Unsubscribe`) → UI 핸들러 → 예외를 던지는 고장 난 로거 핸들러 → 사운드 핸들러 순서로 등록.
  - 2차 피격(데미지 20, 남은 HP 65): 일회성 방어막은 이미 빠져서 실행되지 않고, UI → 오류 출력 → 사운드 순으로 실행.
- `EnemyKilled(EnemyId, Score)` 발행:
  - UI, 사운드, 업적(2마리 처치 시 달성 출력) 핸들러를 등록하고 `(101, 100)`, `(102, 150)`을 연속 발행.
- 10,000회 발행 할당량 측정 및 `WeakReference` 누수 실험 실행.

**예상 출력**:
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

### 확장 과제 (선택)

- **팀 프로젝트 코드와 비교하기**: 본인의 팀 프로젝트에 있는 `EventBus<T>` 구현을 열어 지금 직접 짠 코드와 **다른 점 3가지**(예: 이벤트 제약 조건, 스냅샷/순회 방식, 도메인 리로드 초기화 유무, 예외 처리 방식 등)를 찾아 노트에 적는다.

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

---

## 3. 회고 (5분)

아래 세 질문에 스스로 답해 본다.

1. `EventBus<T>.Subscribe(e => OnDamaged(e))`처럼 람다로 구독하면 나중에 왜 `Unsubscribe`할 수 없는가? (Day 05 복습)
2. 만약 `PlayerDamaged` 핸들러 안에서 또 `EventBus<PlayerDamaged>.Publish(...)`를 재귀적으로 호출한다면 위 `Snapshot` 리스트 구조에서 어떤 문제가 생기고 어떻게 고칠 수 있는가?
3. 모든 함수 호출을 다 `EventBus`로 바꾸면 왜 유지보수가 힘들어지는가? 직접 참조(또는 C# `event`)를 써야 할 때와 전역 `EventBus`를 써야 할 때의 기준은 무엇인가?

---

## 오늘의 한 줄
> (내 말로 한 문장)

## 더 보기
- [제네릭 클래스와 정적 필드 (C# 프로그래밍 가이드)](https://learn.microsoft.com/ko-kr/dotnet/csharp/programming-guide/generics/generic-classes)
- [이벤트 처리 및 발생 (Microsoft Learn)](https://learn.microsoft.com/ko-kr/dotnet/standard/events/)
- [도메인 리로드 설정과 정적 필드 초기화 (Unity 공식 문서)](https://docs.unity3d.com/Manual/DomainReloading.html)
