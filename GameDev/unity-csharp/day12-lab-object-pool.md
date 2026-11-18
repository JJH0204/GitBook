# Day 12 · [실습] 오브젝트 풀

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UCS-013-MP |
| 유형 | MP (실습 절차) |
| 목적 | 제네릭 `Pool<T>`를 직접 구현하고, 풀 없음과 풀 사용의 할당 바이트·GC 횟수를 비교해 확인한다 |
| 적용 대상 | .NET 8 이상 콘솔(필수), Unity 6 / URP(확장 과제, 선택) |
| 소요 시간 | 60분 (2주차 비동기). 설계 읽기 10분, 구현 45분, 회고 5분 |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- 오브젝트 풀링이 줄여 주는 비용과 새로 만드는 비용을 구분하고, "측정 먼저"의 이유를 사례로 설명할 수 있다.
- 생성 함수, `Get`/`Release`, 콜백, `maxSize`, 이중 반환 감지, 통계를 갖춘 제네릭 `Pool<T>`를 구현할 수 있다.
- 재사용 함정(초기화 누락) 체크리스트로 풀링 코드를 점검할 수 있다.

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [day03-gc-allocation.md](day03-gc-allocation.md) | GMD-UCS-004-DO | Day 03 · GC와 할당 |
| [day08-unity-coroutine.md](day08-unity-coroutine.md) | GMD-UCS-009-DO | Day 08 · Unity 코루틴의 내부 🎮 |
| [day11-cancellation-exceptions.md](day11-cancellation-exceptions.md) | GMD-UCS-012-DO | Day 11 · 취소, 예외, 수명 |
| [day16-shader-variants-warmup.md](day16-shader-variants-warmup.md) | GMD-UCS-017-DO | Day 16 · 셰이더 variant와 첫 사용 스톨 🎮 |

외부 참조:

- [ObjectPool\<T\> (UnityEngine.Pool)](https://docs.unity3d.com/ScriptReference/Pool.ObjectPool_1.html)
- [Game Programming Patterns — Object Pool (Robert Nystrom)](https://gameprogrammingpatterns.com/object-pool.html)
- [ReferenceEqualityComparer 클래스](https://learn.microsoft.com/ko-kr/dotnet/api/system.collections.generic.referenceequalitycomparer)

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | .NET SDK | 8 이상 | `dotnet --version`으로 확인 |
| 2 | 터미널과 텍스트 에디터 | AI 기능·자동완성 끔 | |
| 3 | Unity | Unity 6, URP 프로젝트 `practice/UnityLab` | 확장 과제(선택)에서만 사용 |

## 3. 안전 사항

{% hint style="info" %}
NOTE: AI 채팅, 코드 자동완성, 검색을 쓰지 않고 아래 명세만 보고 직접 작성한다. 막히면 설계 개요로 돌아간다.
{% endhint %}

{% hint style="info" %}
NOTE: 작업 폴더 `practice/day12/` 밖의 파일을 건드리지 않는다. Unity 확장 과제는 씬을 저장하기 전에 복사본을 만든다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 작업 폴더를 만든다: `dotnet new console -o practice/day12` | `practice/day12/Program.cs`가 생긴다 |
| 2 | 풀 코드를 쓰기 전에 `created`, `reused`, `dropped`를 예측해 종이나 주석에 적는다 | 값 3개가 적혀 있다 |
| 3 | 설계 개요를 읽는다 | 풀이 아끼는 것과 비용을 한 문장씩 말할 수 있다 |

## 설계 개요

### 설계 1-1. 풀링이 아끼는 것과 비싸게 만드는 것

| | 내용 |
|---|---|
| 아끼는 것 | 객체 할당과 GC 부담 ([Day 03](day03-gc-allocation.md)). Unity에서는 `Instantiate`/`Destroy`의 비용(컴포넌트 생성, 초기화, 파괴) |
| 비용 | 상주 메모리(안 쓰는 객체도 계속 들고 있다), **상태 초기화 누락 버그**, 풀 관리 코드의 복잡도 |
| 원칙 | **측정 먼저.** 프로파일러에서 원인임이 확인된 곳에만 적용한다 |

{% hint style="info" %}
NOTE: Unity 6 = Boehm GC(세대 없음, 압축 없음, 새 프로젝트는 incremental 기본). 세대가 없어서 수집은 힙 전체를 대상으로 하므로, 힙이 크고 객체가 많을수록 수집 비용이 커진다(incremental 모드는 그 작업을 여러 프레임에 나눈다). 풀링은 "수집할 거리를 만들지 않는" 방법이다. GC 모드와 기본값은 Unity 버전에 따라 다르므로 버전 확인 필요.
{% endhint %}

### 설계 1-2. 팀 프로젝트 측정 사례

프레임 스파이크가 의심되어 Editor와 개발 빌드(development build)에서 프로파일러로 확인했다.

- `Instantiate`는 스파이크의 원인이 아니었다. 빌드에서 `Instantiate`의 최대 시간은 **12 ms**였다.
- 스파이크 초과분의 **74–81%** 는 **첫 사용 시점의 VFX Graph 초기화**(셰이더 변형 컴파일)였다. 풀링으로는 줄어들지 않는 비용이다. (셰이더 변형과 웜업은 Day 16에서 다룬다.)
- 교훈: **풀링부터 짜지 말고 프로파일부터 한다.** 원인이 `Instantiate`가 아니면 풀은 복잡도만 늘린다.

### 설계 1-3. 재사용 함정 체크리스트

팀 프로젝트의 풀링 계획에서 정리한 항목이다. `onGet`(꺼낼 때)에서 초기화하거나, 코드를 고쳐서 없앤다.

- [ ] **스케일/속도를 스폰할 때마다 곱한다**: 재사용되는 객체의 스케일이 계속 커진다. 곱하지 말고 **대입**한다.
- [ ] 이전에 시작한 **코루틴**이 계속 돌고 있다 (Day 08: `SetActive(false)`는 멈추지만, `enabled = false`는 못 멈춘다).
- [ ] 이전에 구독한 **이벤트**가 남아 있다 → 중복 호출. 꺼낼 때 구독하고 반환할 때 해제한다.
- [ ] **파티클**이 이전 재생 상태로 남아 있다 → `Clear()` 후 `Play()`.
- [ ] `Rigidbody`의 **velocity/angularVelocity**가 남아 있다.
- [ ] 오브젝트를 **`"(Clone)"` 이름으로 찾는** 코드가 있다 (풀 오브젝트는 이름이 바뀌지 않거나 다르다).

### 설계 1-4. 풀 설계 결정

| 결정 | 선택 |
|---|---|
| 보관 구조 | `Stack<T>`: 최근에 반환한 것을 먼저 쓴다 (캐시에 따뜻한 객체) |
| 비었을 때 | 새로 만든다 (`create`) |
| 가득 찼을 때 | `maxSize`를 넘는 반환은 **버린다**(`dropped`). Unity에서는 파괴한다 |
| 이중 반환 | 같은 객체를 두 번 반환하면 나중에 두 곳이 같은 객체를 쓰게 되므로 **개발 중에 예외로 잡는다** |

## 5. 절차

### A. `Pool<T>` 구현

명세:

1. `Pool<T> where T : class`: 생성자 `(Func<T> create, int maxSize, Action<T>? onGet = null, Action<T>? onRelease = null, bool detectDoubleRelease = false)`.
2. `T Get()`: 보관 중이면 꺼내고(`Reused++`), 없으면 `create()`로 만든다(`Created++`). 어느 쪽이든 `onGet`을 호출한다.
3. `void Release(T item)`: `onRelease`를 호출하고, 보관 개수가 `maxSize` 이상이면 버리고(`Dropped++`) 아니면 보관한다.
4. `detectDoubleRelease`가 `true`면 이미 풀에 있는 객체를 `Release`할 때 `InvalidOperationException`을 던진다 (`HashSet<T>`와 `ReferenceEqualityComparer.Instance` 사용).
5. 통계 프로퍼티 `Created`, `Reused`, `Dropped`, `Idle`(현재 보관 개수).

1. (5-A-01) `Pool<T>`를 위 명세 1~5를 모두 만족하게 `Program.cs`에 작성한다. → 결과: 빌드 오류 없이 `dotnet build`가 끝난다.
2. (5-A-02) `Bullet` 클래스를 작성한다. `float[1024]` 배열(4KB)을 필드로 둔다. → 결과: 객체 하나가 약 4KB를 차지한다.

### B. 시뮬레이션 작성

시나리오 조건: `Bullet`(필드 몇 개 + `float[1024]` 부속 데이터 4KB)를 쓴다. 시나리오: **1000프레임 동안 프레임마다 10발 발사 → 총 10,000발**, 각 탄은 5프레임 뒤 반환한다(매 프레임 먼저 5프레임 지난 10발을 반환하고 나서 10발을 새로 꺼낸다). 시뮬레이션 끝에 남은 50발을 한꺼번에 반환한다. `maxSize = 32`.

풀 없음(`new Bullet()`)과 풀 사용 두 경우에 **할당 바이트**(`GC.GetAllocatedBytesForCurrentThread()`)와 **`GC.CollectionCount(0)`** 증가량을 출력한다. 시작 전에 `GC.Collect()`를 한 번 한다.

**실행 전에 예측한다:** `created`, `reused`, `dropped`는 각각 몇인가? (힌트: 동시에 살아 있는 탄은 최대 50발.)

1. (5-B-01) 풀 없음 경로와 풀 사용 경로를 같은 `Simulate` 함수로 돌린다. 생성과 반환은 함수 인자로 받는다. → 결과: 두 경로의 코드가 한 곳에 있다.
2. (5-B-02) 시작 전에 `GC.Collect()`를 한 번 호출하고, `GC.GetAllocatedBytesForCurrentThread()`와 `GC.CollectionCount(0)`의 증가량을 기록한다. → 결과: 경로마다 두 값이 출력된다.
3. (5-B-03) `detectDoubleRelease: true`인 풀에서 같은 객체를 두 번 반환하는 코드를 추가한다. → 결과: `InvalidOperationException`을 잡아 메시지를 출력한다.

### C. 실행과 예측 비교

1. (5-C-01) Release 구성으로 실행한다: `dotnet run -c Release` → 결과: 아래와 비슷한 출력이 나온다.

```
[풀 없음] 할당 39.7 MB, GC(0) 2회
[풀 사용] 할당 0.20 MB, GC(0) 0회
풀 통계: created=50 reused=9950 dropped=18 idle=32
이중 반환 감지: 이미 풀에 있는 객체를 다시 반환했다.
```

2. (5-C-02) 4절 2번에서 적은 예측과 `created`, `reused`, `dropped`를 비교한다. → 결과: 세 값이 일치한다.
3. (5-C-03) 일치하지 않으면 해당 값이 나오는 코드를 다시 읽는다. 참고 구현은 부록 A에서 마지막에 본다.

해설:

- `created = 50`: 처음 5프레임은 반환이 없어서 10×5발을 만든다. 그 뒤로는 반환한 만큼 재사용한다. `reused = 10000 − 50`.
- `dropped = 18`: 종료 때 50발을 반환하는데 `maxSize` 32까지만 보관한다.
- 할당 바이트는 64비트 기준이다. 탄 하나 ≈ 4 KB 배열 + 객체이므로 10,000발이면 약 40 MB, 풀은 50발분만 만든다.
- 이중 반환 줄은 `detectDoubleRelease: true`인 풀에서 같은 객체를 두 번 반환하는 별도 코드의 결과다. 예외 메시지 문자열은 본인이 정한 것을 쓰면 된다.

### D. 확장 (선택)

1. **Unity 이식 🎮**: 탄 `MonoBehaviour`를 `SetActive` 토글로 풀링하고(직접 만든 `Pool<T>` 또는 `Stack<Bullet>`), 꺼낼 때 상태를 초기화한다. 그다음 `UnityEngine.Pool.ObjectPool<T>`로 바꿔서 Profiler의 GC Alloc과 `Instantiate` 시간을 풀 없는 버전과 비교한다. (비교용 코드는 부록 A에 있다.)
2. **활성 개수 한도**: 동시에 꺼내 간 개수(`Active`)를 세고, `maxActive`를 넘는 `Get`은 예외를 던지게 해 본다.
3. **통계 출력**: 프레임별 `Idle` 최솟값을 추적해서, 풀이 실제로 필요로 한 `maxSize`를 추천하도록 해 본다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 풀 통계 줄 출력 | `created=50 reused=9950 dropped=18 idle=32` | 네 값이 모두 같다 |
| 2 | 풀 없음과 풀 사용의 할당 바이트 비교 | 풀 사용 쪽이 약 1/100 이하 | 풀 사용 할당이 풀 없음 할당보다 작다 (정확한 값은 머신마다 다르다) |
| 3 | `GC.CollectionCount(0)` 증가량 비교 | 풀 사용 쪽이 같거나 작다 | 풀 사용 쪽이 풀 없음보다 크지 않다 |
| 4 | 이중 반환 | 예외 메시지가 출력된다 | `InvalidOperationException`을 잡는다 |

## 7. 복구

1. (7-01) 작업 폴더를 지운다: `rm -r practice/day12` → 결과: 폴더가 없다.
2. (7-02) Unity 확장 과제를 했다면 저장 전 복사본으로 씬을 되돌린다. 저장 전이면 Ctrl+Z로 되돌린다. → 결과: 씬에 풀링용 오브젝트가 없다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM 형식(MP)으로 재작성. 설계 읽기를 설계 개요로, 구현을 절차로, 회고를 부록 B로 재배치 |

## 부록 A. 참고 구현과 Unity 비교 코드

<details><summary>Unity 비교용 코드 (Bullet.cs, BulletSpawner.cs)</summary>

```csharp
// Unity: Bullet.cs
using System;
using UnityEngine;

public class Bullet : MonoBehaviour
{
    public float Speed = 10f;
    public float Lifetime = 2f;
    public Action<Bullet> OnExpire;
    private float _age;

    public void ResetState()
    {
        _age = 0f;
        transform.localScale = Vector3.one;   // 곱하지 않고 대입: 재사용돼도 커지지 않는다
    }

    private void Update()
    {
        transform.position += transform.forward * (Speed * Time.deltaTime);
        _age += Time.deltaTime;
        if (_age >= Lifetime) OnExpire?.Invoke(this);
    }
}
```

```csharp
// Unity: BulletSpawner.cs
using UnityEngine;
using UnityEngine.Pool;

public class BulletSpawner : MonoBehaviour
{
    [SerializeField] private Bullet _prefab;
    [SerializeField] private int _perFrame = 10;
    [SerializeField] private bool _usePool = true;
    private ObjectPool<Bullet> _pool;

    private void Awake()
    {
        _pool = new ObjectPool<Bullet>(
            createFunc: () =>
            {
                var b = Instantiate(_prefab);
                b.OnExpire = _pool.Release;
                return b;
            },
            actionOnGet: b =>
            {
                b.transform.SetPositionAndRotation(transform.position, transform.rotation);
                b.ResetState();
                b.gameObject.SetActive(true);
            },
            actionOnRelease: b => b.gameObject.SetActive(false),
            actionOnDestroy: b => Destroy(b.gameObject),
            collectionCheck: true,
            defaultCapacity: 64,
            maxSize: 256);
    }

    private void Update()
    {
        for (int i = 0; i < _perFrame; i++)
        {
            if (_usePool)
            {
                _pool.Get();
            }
            else
            {
                var b = Instantiate(_prefab, transform.position, transform.rotation);
                b.OnExpire = x => Destroy(x.gameObject);
            }
        }
    }
}
```

`_usePool`을 껐다 켜며 Profiler의 GC Alloc과 CPU 시간을 비교한다. `collectionCheck`(이중 반환 검사)는 Unity 문서 기준으로 에디터에서만 동작한다. 빌드에서는 검사하지 않는다. 프리팹이 얼마나 가벼운지에 따라 차이가 거의 없을 수도 있다 — 그것이 Day 12의 요점이다.

</details>

<details><summary>참고 구현</summary>

```csharp
// 실행 가능: Program.cs
const int Frames = 1000, PerFrame = 10, Lifetime = 5, MaxSize = 32;

// 1) 풀 없음
var (bytes0, gc0) = Simulate(() => new Bullet(), _ => { });

// 2) 풀 사용
var pool = new Pool<Bullet>(() => new Bullet(), MaxSize, onGet: b => b.Reset());
var (bytes1, gc1) = Simulate(pool.Get, pool.Release, endRelease: true);

Console.WriteLine($"[풀 없음] 할당 {bytes0 / 1024.0 / 1024.0:F1} MB, GC(0) {gc0}회");
Console.WriteLine($"[풀 사용] 할당 {bytes1 / 1024.0 / 1024.0:F2} MB, GC(0) {gc1}회");
Console.WriteLine($"풀 통계: created={pool.Created} reused={pool.Reused} dropped={pool.Dropped} idle={pool.Idle}");

// 이중 반환 감지
var checkedPool = new Pool<Bullet>(() => new Bullet(), 4, detectDoubleRelease: true);
var one = checkedPool.Get();
checkedPool.Release(one);
try { checkedPool.Release(one); }
catch (InvalidOperationException ex) { Console.WriteLine($"이중 반환 감지: {ex.Message}"); }

// 프레임마다 10발 발사, 5프레임 뒤 반환. 시작 전에 GC를 한 번 비워 둔다.
(long bytes, int gc) Simulate(Func<Bullet> get, Action<Bullet> release, bool endRelease = false)
{
    var active = new Queue<Bullet>(64);
    GC.Collect();
    long b0 = GC.GetAllocatedBytesForCurrentThread();
    int g0 = GC.CollectionCount(0);

    for (int f = 0; f < Frames; f++)
    {
        if (f >= Lifetime)                          // 5프레임 전에 쏜 10발 반환
            for (int i = 0; i < PerFrame; i++) release(active.Dequeue());
        for (int i = 0; i < PerFrame; i++)
        {
            var bullet = get();
            bullet.X = f;
            active.Enqueue(bullet);
        }
    }
    if (endRelease)                                 // 게임 종료: 남은 50발을 한꺼번에 반환
        while (active.Count > 0) release(active.Dequeue());

    return (GC.GetAllocatedBytesForCurrentThread() - b0, GC.CollectionCount(0) - g0);
}

class Bullet
{
    public float X, Y, VX, VY;
    public int Age;
    public float[] Trail = new float[1024];         // 4KB짜리 부속 데이터
    public void Reset() { X = Y = VX = VY = 0; Age = 0; }
}

class Pool<T> where T : class
{
    private readonly Stack<T> _items = new();
    private readonly HashSet<T>? _inPool;
    private readonly Func<T> _create;
    private readonly Action<T>? _onGet, _onRelease;
    private readonly int _maxSize;

    public int Created { get; private set; }
    public int Reused { get; private set; }
    public int Dropped { get; private set; }
    public int Idle => _items.Count;

    public Pool(Func<T> create, int maxSize, Action<T>? onGet = null, Action<T>? onRelease = null,
                bool detectDoubleRelease = false)
    {
        _create = create; _maxSize = maxSize; _onGet = onGet; _onRelease = onRelease;
        if (detectDoubleRelease) _inPool = new HashSet<T>(ReferenceEqualityComparer.Instance);
    }

    public T Get()
    {
        T item;
        if (_items.Count > 0) { item = _items.Pop(); _inPool?.Remove(item); Reused++; }
        else { item = _create(); Created++; }
        _onGet?.Invoke(item);
        return item;
    }

    public void Release(T item)
    {
        if (_inPool != null && !_inPool.Add(item))
            throw new InvalidOperationException("이미 풀에 있는 객체를 다시 반환했다.");
        _onRelease?.Invoke(item);
        if (_items.Count >= _maxSize) { Dropped++; _inPool?.Remove(item); return; }   // 넘치면 버린다
        _items.Push(item);
    }
}
```

- `Simulate`는 풀과 무관한 함수 두 개(`get`, `release`)를 받아서 두 경우를 같은 코드로 돌린다.
- `Release`에서 버려진 객체는 `_inPool`에서도 지운다. 안 지우면 GC가 수거할 수 있는 객체를 해시 집합이 붙잡는다.
- `onGet`은 **꺼낼 때** 상태를 초기화한다. 반환할 때 초기화(`onRelease`)와 둘 중 하나로 통일하면 빠뜨리기 어렵다.
- 마이크로 벤치마크라서 숫자는 참고용이다. `dotnet run -c Release`로 실행한다.

</details>

## 부록 B. 회고

질문에 스스로 답해 본 뒤 펼친다.

**Q1. 풀링이 오히려 상황을 나쁘게 만드는 경우는 언제인가?**
<details><summary>모범 답안</summary>
객체가 가볍고 자주 만들어지지 않을 때는 풀 관리 코드와 상주 메모리, 초기화 누락 버그 위험이 이득보다 큽니다. 병목이 `Instantiate`가 아니라 다른 곳(예: 첫 사용 시 셰이더 컴파일)일 때도 풀은 효과가 없습니다. 크기를 너무 크게 잡으면 안 쓰는 객체가 메모리를 계속 차지하고, 초기화가 불완전하면 이전 상태가 새어 나오는 버그가 생깁니다.

</details>

**Q2. `maxSize`를 어떻게 정해야 하는가?**
<details><summary>모범 답안</summary>
동시에 살아 있는 최대 개수와 그 사이 변동 폭을 측정해서 정합니다. 너무 작으면 반환이 버려지고 다시 만드는 일이 반복되어 풀의 의미가 줄고, 너무 크면 상주 메모리가 낭비됩니다. 오늘 시나리오의 통계(`created`, `dropped`, `Idle`)가 그 판단의 재료입니다.

</details>

**Q3. 팀 프로젝트 사례를 면접에서 30초로 설명한다면?**
<details><summary>모범 답안</summary>
프레임 스파이크가 의심돼서 풀링을 하기 전에 에디터와 개발 빌드에서 프로파일링을 했습니다. `Instantiate`는 원인이 아니었고(빌드에서 최대 12 ms), 스파이크 초과분의 74–81%는 첫 사용 시 VFX Graph 초기화, 즉 셰이더 변형 컴파일이었습니다. 풀링이 해결할 문제가 아니라는 것을 측정으로 확인한 셈이고, 최적화는 원인을 확인한 뒤에 한다는 교훈을 얻었습니다.

</details>

이전: [Day 11 · 취소, 예외, 수명](day11-cancellation-exceptions.md) · 다음: [Day 13 · 렌더링 파이프라인 한 바퀴 🎮](day13-rendering-pipeline.md)
