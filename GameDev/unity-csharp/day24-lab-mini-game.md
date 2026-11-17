# Day 24 · [실습] 종합 미니 게임

> 4주차 Unity 코어와 트러블슈팅 · 60분 · 준비물: .NET SDK (`dotnet new console -o practice/day24`)

## 오늘의 목표
- Day 06의 상태 패턴(`State Pattern`), Day 12의 오브젝트 풀(`ObjectPool<T>`), Day 18의 무할당 이벤트 버스(`EventBus<T>`)를 하나의 자동 전투 시뮬레이터로 결합할 수 있다.
- 고정 시드(`Random(42)`)로 1,000프레임 전투 루프를 재현 가능하게 돌리고, 워밍업 이후 프레임 루프 내부의 힙 할당을 **0 바이트**로 유지할 수 있다.
- 4주 과정을 돌아보며 아직 막히는 면접 질문을 체크해 두 번째 바퀴 복습 목록을 완성할 수 있다.

---

## 1. 설계 읽기 (10분)

### 1-1. 세 가지 패턴이 만나는 구조

콘솔에서 1,000프레임 동안 돌아가는 자동 전투 시뮬레이터를 만든다. 각 모듈은 앞서 직접 구현했던 세 가지 패턴을 그대로 담당한다(Day 06, 12, 18에서 본인이 작성한 코드를 복사해 와서 합쳐도 좋다).

```
[Battlefield] ──(Get / Release)──▶ [ObjectPool<Enemy>] (Day 12)
      ▲                                    │
      │ (탐색 / 타격)                       ▼
   [Player] ◀──(Idle/Chase/Attack)──▶ [IPlayerState]   (Day 06)
      │
      └──(사망 시 Publish)──▶ [EventBus<EnemyKilled>]  (Day 18)
                                   ├──▶ ScoreSubscriber
                                   ├──▶ KillLogSubscriber
                                   └──▶ AchievementSubscriber
```

| 타입 | 책임 | 무할당(Zero-Alloc) 포인트 |
|---|---|---|
| `Player` & `IPlayerState` (`Idle`, `Chase`, `Attack`) | 가장 가까운 적 탐색 → 거리 좁히기 → 공격 및 처치 | 상태 객체 3개를 `Player` 생성 시 미리 만들어 재사용 (상태 전환 시 `new` 없음) |
| `ObjectPool<Enemy>` & `Battlefield` | 초기 용량 8개로 `Enemy`를 미리 생성해 두고 스폰 시 꺼내고 사망 시 반납 | 프레임 루프 중 `new Enemy()` 호출 0회 |
| `EventBus<EnemyKilled>` | 적 처치 시 `readonly struct EnemyKilled(Frame, EnemyId, Score)` 발행 | `struct` 이벤트 + 사전 할당 `Snapshot` 리스트로 박싱·할당 0회 |
| `Score` / `KillLog` / `Achievement` 구독자 | 점수 합산, 처치 기록 배열 저장, 10킬·50킬 달성 프레임 기록 | 프레임 루프 안에서는 문자열 보간(`$"..."`)을 하지 않고 `EnemyKilled[]` 정적 버퍼에 구조체로만 기록 후 종료 시 출력 |

---

## 2. 구현 (45분)

> AI, 자동완성, 검색 없이. 막히면 위의 읽기와 Day 06, 12, 18로 돌아간다.

### 요구사항

`practice/day24/Program.cs`에 아래 규칙을 따르는 1,000프레임 자동 전투 시뮬레이터를 작성한다.

1. **시드 고정과 프레임 루프**: `new Random(42)`를 사용하고 `frame = 1`부터 `1_000`까지 순서대로 `battlefield.TickSpawn(frame)`과 `player.Tick(frame)`을 실행한다.
2. **적 스폰 규칙 (`Battlefield`)**:
   - 동시 활성 적 최대 수는 `4`마리, 풀 초기 용량은 `8`개로 한다.
   - `active.Count < 4`이고 `frame % 8 == 1`일 때 풀에서 `Enemy`를 꺼낸다.
   - 스폰 시 `hp = rng.Next(20, 45)`, `dist = rng.Next(2, 6)`, `score = hp * 10`으로 초기화한다.
3. **플레이어 FSM 규칙 (`Player`)**:
   - 한 프레임에 현재 상태의 `Tick`만 1번 실행한다.
   - `IdleState`: 가장 가까운(`Distance`가 가장 작은, 같으면 먼저 스폰된) 적을 찾아 `Target`으로 잡고, `Distance > 1`이면 `Chase`, 아니면 `Attack`으로 전환한다.
   - `ChaseState`: `Target.Distance`를 1 줄이고, `Distance <= 1`이 되면 `Attack`으로 전환한다.
   - `AttackState`: `Target.Hp`를 `12` 깎는다. `Hp <= 0`이 되면 `EventBus<EnemyKilled>.Publish`를 호출하고 적을 풀에 반납한 뒤 `Idle`로 전환한다.
4. **무할당 검증**: 짧은 워밍업 실행 후 본 1,000프레임 루프 전후의 `GC.GetAllocatedBytesForCurrentThread()` 차이가 **`0 B`**인지 출력한다.

### 예상 출력 (Seed: 42)

아래는 참고 구현의 출력이다. 같은 프레임에 다시 탐색하는지, 스폰과 플레이어 중 무엇을 먼저 돌리는지 같은 세부가 다르면 숫자가 조금 달라진다. 숫자가 다르면 참고 구현과 비교해 차이가 어디서 생겼는지 설명할 수 있으면 된다. `프레임 루프 할당 : 0 B`만은 반드시 맞춘다.

```
=== 1,000프레임 자동 전투 결과 (Seed: 42) ===
총 처치 수       : 125
총 점수          : 38920
상태 전환 횟수   : 375
풀 총 생성 객체  : 8 (현재 활성: 0, 대기: 8)
업적 [10킬 달성] : 80프레임
업적 [50킬 달성] : 399프레임
마지막 3건 처치  : [F984] #123(+390), [F991] #124(+440), [F999] #125(+410)
프레임 루프 할당 : 0 B
```

### 확장 과제 (선택)

- **Unity 이식 (`practice/UnityLab`)**: 순수 C# 클래스인 `ObjectPool<T>`, `EventBus<T>`, `IPlayerState`를 그대로 `practice/UnityLab`으로 가져가 `MonoBehaviour` 매니저의 `Update()`에서 구동하고, Profiler의 `GC Alloc` 열이 매 프레임 `0 B`인지 확인한다(Unity 6은 C# 9이므로 주 생성자 문법만 일반 생성자로 풀어 준다).

<details><summary>참고 구현</summary>

```csharp
// 실행 가능: Program.cs
const int Seed = 42, TotalFrames = 1_000;

// 워밍업 실행(JIT 및 내부 버퍼 확보) 후 본 시뮬레이션 측정
RunSimulation(Seed, 10, out _, out _, out _, out _, out _);
long allocatedBytes = RunSimulation(Seed, TotalFrames, out var scoreSub, out var logSub, out var achieveSub, out var pool, out var player);

Console.WriteLine($"=== 1,000프레임 자동 전투 결과 (Seed: {Seed}) ===");
Console.WriteLine($"총 처치 수       : {scoreSub.TotalKills}");
Console.WriteLine($"총 점수          : {scoreSub.TotalScore}");
Console.WriteLine($"상태 전환 횟수   : {player.StateTransitions}");
Console.WriteLine($"풀 총 생성 객체  : {pool.TotalCreated} (현재 활성: {pool.ActiveCount}, 대기: {pool.PooledCount})");
Console.WriteLine($"업적 [10킬 달성] : {(achieveSub.TenKillFrame > 0 ? $"{achieveSub.TenKillFrame}프레임" : "미달성")}");
Console.WriteLine($"업적 [50킬 달성] : {(achieveSub.FiftyKillFrame > 0 ? $"{achieveSub.FiftyKillFrame}프레임" : "미달성")}");
Console.WriteLine($"마지막 3건 처치  : {logSub.FormatLastThree()}");
Console.WriteLine($"프레임 루프 할당 : {allocatedBytes} B");

static long RunSimulation(int seed, int frames, out ScoreSubscriber scoreSub, out KillLogSubscriber logSub,
    out AchievementSubscriber achieveSub, out ObjectPool<Enemy> pool, out Player player)
{
    var rng = new Random(seed);
    pool = new ObjectPool<Enemy>(() => new Enemy(), 8);
    scoreSub = new ScoreSubscriber();
    logSub = new KillLogSubscriber(256);
    achieveSub = new AchievementSubscriber();

    EventBus<EnemyKilled>.Clear();
    EventBus<EnemyKilled>.Subscribe(scoreSub.OnEnemyKilled);
    EventBus<EnemyKilled>.Subscribe(logSub.OnEnemyKilled);
    EventBus<EnemyKilled>.Subscribe(achieveSub.OnEnemyKilled);

    var warmupEvt = new EnemyKilled(0, 0, 0);
    EventBus<EnemyKilled>.Publish(in warmupEvt);
    scoreSub.Reset(); logSub.Reset(); achieveSub.Reset();

    var field = new Battlefield(rng, pool, 4);
    player = new Player(field);

    long before = GC.GetAllocatedBytesForCurrentThread();
    for (int f = 1; f <= frames; f++) { field.TickSpawn(f); player.Tick(f); }
    return GC.GetAllocatedBytesForCurrentThread() - before;
}

readonly struct EnemyKilled(int frame, int enemyId, int score)
{
    public readonly int Frame = frame, EnemyId = enemyId, Score = score;
}

class ScoreSubscriber
{
    public int TotalKills { get; private set; }
    public int TotalScore { get; private set; }
    public void Reset() => TotalKills = TotalScore = 0;
    public void OnEnemyKilled(EnemyKilled e) { TotalKills++; TotalScore += e.Score; }
}

class KillLogSubscriber(int capacity)
{
    private readonly EnemyKilled[] buffer = new EnemyKilled[capacity];
    public int Count { get; private set; }
    public void Reset() => Count = 0;
    public void OnEnemyKilled(EnemyKilled e) { if (Count < buffer.Length) buffer[Count++] = e; }
    public string FormatLastThree()
    {
        var list = new List<string>();
        for (int i = Math.Max(0, Count - 3); i < Count; i++)
            list.Add($"[F{buffer[i].Frame}] #{buffer[i].EnemyId}(+{buffer[i].Score})");
        return string.Join(", ", list);
    }
}

class AchievementSubscriber
{
    private int kills;
    public int TenKillFrame { get; private set; }
    public int FiftyKillFrame { get; private set; }
    public void Reset() => kills = TenKillFrame = FiftyKillFrame = 0;
    public void OnEnemyKilled(EnemyKilled e)
    {
        if (++kills == 10) TenKillFrame = e.Frame;
        if (kills == 50) FiftyKillFrame = e.Frame;
    }
}

static class EventBus<T> where T : struct
{
    private static readonly List<Action<T>> Handlers = new(), Snapshot = new();
    public static void Subscribe(Action<T> h) { if (!Handlers.Contains(h)) Handlers.Add(h); }
    public static void Clear() { Handlers.Clear(); Snapshot.Clear(); }
    public static void Publish(in T evt)
    {
        Snapshot.Clear();
        for (int i = 0; i < Handlers.Count; i++) Snapshot.Add(Handlers[i]);
        for (int i = 0; i < Snapshot.Count; i++) Snapshot[i].Invoke(evt);
    }
}

class ObjectPool<T> where T : class
{
    private readonly Stack<T> stack;
    private readonly Func<T> factory;
    public int TotalCreated { get; private set; }
    public int ActiveCount { get; private set; }
    public int PooledCount => stack.Count;

    public ObjectPool(Func<T> factory, int initialCapacity)
    {
        this.factory = factory;
        stack = new Stack<T>(initialCapacity);
        for (int i = 0; i < initialCapacity; i++) { stack.Push(factory()); TotalCreated++; }
    }
    public T Get() { ActiveCount++; if (stack.Count > 0) return stack.Pop(); TotalCreated++; return factory(); }
    public void Release(T item) { ActiveCount--; stack.Push(item); }
}

class Enemy
{
    public int Id, Hp, Distance, ScoreReward;
    public void Init(int id, int hp, int dist, int score) { Id = id; Hp = hp; Distance = dist; ScoreReward = score; }
}

class Battlefield(Random rng, ObjectPool<Enemy> pool, int maxActive)
{
    private readonly List<Enemy> active = new(maxActive);
    private int nextId = 1;

    public void TickSpawn(int frame)
    {
        if (active.Count < maxActive && frame % 8 == 1)
        {
            var e = pool.Get();
            int hp = rng.Next(20, 45), dist = rng.Next(2, 6);
            e.Init(nextId++, hp, dist, hp * 10);
            active.Add(e);
        }
    }
    public Enemy? FindNearest()
    {
        Enemy? best = null;
        for (int i = 0; i < active.Count; i++)
            if (best == null || active[i].Distance < best.Distance) best = active[i];
        return best;
    }
    public void KillAndReturn(Enemy e, int frame)
    {
        var evt = new EnemyKilled(frame, e.Id, e.ScoreReward);
        EventBus<EnemyKilled>.Publish(in evt);
        active.Remove(e);
        e.Init(0, 0, 0, 0);
        pool.Release(e);
    }
}

interface IPlayerState { void Tick(Player p, int frame); }

class Player
{
    public readonly Battlefield Field;
    public readonly IPlayerState Idle = new IdleState(), Chase = new ChaseState(), Attack = new AttackState();
    public Enemy? Target;
    public int StateTransitions { get; private set; }
    private IPlayerState current;

    public Player(Battlefield field) { Field = field; current = Idle; }
    public void ChangeState(IPlayerState next) { if (!ReferenceEquals(current, next)) { current = next; StateTransitions++; } }
    public void Tick(int frame) => current.Tick(this, frame);
}

class IdleState : IPlayerState
{
    public void Tick(Player p, int frame)
    {
        p.Target = p.Field.FindNearest();
        if (p.Target != null) p.ChangeState(p.Target.Distance > 1 ? p.Chase : p.Attack);
    }
}

class ChaseState : IPlayerState
{
    public void Tick(Player p, int frame)
    {
        if (p.Target == null || p.Target.Hp <= 0) { p.ChangeState(p.Idle); return; }
        if (--p.Target.Distance <= 1) p.ChangeState(p.Attack);
    }
}

class AttackState : IPlayerState
{
    public void Tick(Player p, int frame)
    {
        var t = p.Target;
        if (t == null || t.Hp <= 0) { p.ChangeState(p.Idle); return; }
        t.Hp -= 12;
        if (t.Hp <= 0) { p.Field.KillAndReturn(t, frame); p.Target = null; p.ChangeState(p.Idle); }
    }
}
```

</details>

---

## 3. 회고 (5분)

### 3-1. 이번 실습 회고 질문

1. 프레임 루프 안에서 `Console.WriteLine($"[F{frame}] 적 처치")`를 매번 호출했다면 `allocatedBytes`가 왜 0이 나올 수 없는가?
2. `Enemy`를 풀에 반납(`Release`)했어도 `Player.Target`이 그 `Enemy` 참조를 계속 들고 있으면 어떤 버그가 생기는가? (Day 12 복습)
3. 상태 전환 시마다 `new ChaseState()`를 만들었다면 1,000프레임 동안 상태 객체가 몇 번 힙에 할당되었겠는가?

### 3-2. 4주 총정리 체크리스트 (두 번째 바퀴 준비)

[README.md](README.md)의 안내대로, 지난 4주간의 각 Day 면접 질문 중 **모범 답안을 안 보고 30초 안에 막힘없이 답하기 어려웠던 날**에 체크 표시를 남긴다. 내일부터는 체크된 날만 골라 두 번째 바퀴를 돈다.

- [ ] **1주차 (C# 메모리)**: Day 01 값/참조 · Day 02 박싱 · Day 03 GC와 할당 · Day 04 struct · Day 05 델리게이트/클로저 · Day 06 상태 패턴
- [ ] **2주차 (비동기)**: Day 07 IEnumerator/yield · Day 08 코루틴 · Day 09 Task/async · Day 10 UniTask/Awaitable · Day 11 취소/예외/수명 · Day 12 오브젝트 풀
- [ ] **3주차 (렌더링과 측정)**: Day 13 렌더링 파이프라인 · Day 14 배칭 · Day 15 오버드로우/컬링 · Day 16 셰이더 variant/웜업 · Day 17 프로파일러 · Day 18 이벤트 버스
- [ ] **4주차 (Unity 코어와 트러블슈팅)**: Day 19 생명주기 · Day 20 UnityEngine.Object와 null · Day 21 직렬화/SO · Day 22 성능 트러블슈팅 · Day 23 버그 트러블슈팅

---

## 오늘의 한 줄
> (내 말로 한 문장)

## 더 보기
- [가비지 컬렉션 및 성능 (Microsoft Learn)](https://learn.microsoft.com/ko-kr/dotnet/standard/garbage-collection/performance)
- [Unity 메모리 관리 및 GC 최적화 (Unity 공식 문서)](https://docs.unity3d.com/Manual/performance-garbage-collector.html)
- [Random 클래스 시드와 재현성 (Microsoft Learn)](https://learn.microsoft.com/ko-kr/dotnet/api/system.random)
