# Day 19 · MonoBehaviour 생명주기 🎮

> 4주차 Unity 코어와 트러블슈팅 · 60분 · 준비물: 🎮 Unity 6 (`practice/UnityLab`)

## 오늘의 목표
- `Awake` → `OnEnable` → `Start` → `FixedUpdate` → `Update` → 코루틴 재개 → `LateUpdate` → `OnDisable` → `OnDestroy`의 정확한 순서와 실행 조건을 설명할 수 있다.
- 왜 "내 초기화는 `Awake`, 남 참조는 `Start`"라는 원칙이 생겼는지, 그리고 `Instantiate`와 `Destroy` 호출 시점에 각 이벤트가 언제 도는지 설명할 수 있다.
- `FixedUpdate`가 한 프레임에 0번~여러 번 돌 수 있는 이유와 `Time.timeScale = 0`일 때의 동작을 설명할 수 있다.

---

## 1. 읽기 (20분)

### 1-1. 전체 생명주기 순서 한눈에 보기

Unity의 `PlayerLoop`는 매 프레임 정해진 순서대로 `MonoBehaviour`의 메시지 함수들을 호출한다.

```
[초기화]  Awake ──▶ OnEnable ──▶ Start (첫 Update 직전 1회)
[물리]    FixedUpdate (프레임당 0..N회) ──▶ 물리 시뮬레이션 ──▶ OnTrigger* / OnCollision*
[프레임]  Update ──▶ yield return null 코루틴 재개 ──▶ LateUpdate ──▶ 렌더링
[해제]    OnDisable ──▶ OnDestroy (프레임 끝)      *앱 종료 시: OnApplicationQuit
```

### 1-2. Awake, OnEnable, Start의 결정적 차이

세 함수 모두 초기화에 쓰이지만 **실행 시점과 횟수, 활성화 조건**이 다르다.

| 함수 | 호출 횟수 | GameObject가 비활성(`activeSelf == false`)일 때 | 컴포넌트만 비활성(`enabled == false`)일 때 | 주 용도 |
|---|---|---|---|---|
| `Awake` | 인스턴스 평생 **딱 1번** | 호출 안 됨 (`SetActive(true)` 되는 순간 호출) | **호출됨!** (GameObject만 활성이면 실행) | 내 내부 참조(`GetComponent`), 내부 컬렉션 초기화 |
| `OnEnable` | 활성/비활성 토글마다 **여러 번** | 호출 안 됨 | 호출 안 됨 (켜지는 순간 호출. 처음엔 `Awake` 직후, `Start` **이전에** 실행) | 이벤트 구독(`EventBus.Subscribe`, Day 18), 풀에서 꺼낼 때 리셋 |
| `Start` | 평생 **딱 1번** | 호출 안 됨 | 호출 안 됨 (`enabled = true`가 된 뒤 첫 `Update` 직전 실행) | 다른 오브젝트·매니저 참조 및 초기 상호작용 |

**왜 "내 초기화는 `Awake`, 다른 오브젝트 참조는 `Start`"인가?**
씬에 있는 여러 오브젝트들의 **`Awake` 실행 순서는 보장되지 않는다.** A의 `Awake`에서 B의 프로퍼티를 읽으면 B의 `Awake`가 아직 안 돌아 `NullReferenceException`이 날 수 있다. 반면 모든 활성 오브젝트의 `Awake`와 `OnEnable`이 다 끝난 뒤에야 `Start` 단계로 넘어가므로, 각자 자기 데이터는 `Awake`에서 준비해 두고 남의 데이터를 읽는 작업은 `Start`에서 하면 안전하다.
그래도 `Awake`끼리 순서가 꼭 필요하다면 `Project Settings > Script Execution Order`나 클래스의 `[DefaultExecutionOrder(-100)]` 어트리뷰트로 명시한다.

### 1-3. Instantiate와 Destroy가 실행되는 정확한 시점

- **`Instantiate(prefab)`를 호출한 순간**:
  `Instantiate` 함수가 리턴하기 **전에(동기적으로 그 줄 안에서)** 새 오브젝트의 **`Awake`와 `OnEnable`이 즉시 실행**된다. 따라서 `var enemy = Instantiate(prefab); enemy.Init(hp);`를 작성할 때 `enemy`의 `Awake`는 `Init()`보다 먼저 끝나 있다. 반면 **`Start`는 즉시 돌지 않고** 그 프레임(또는 다음 프레임)의 `Update` 직전에 실행된다.
- **`Destroy(obj)`를 호출한 순간**:
  그 줄에서 즉시 파괴되지 않는다. 파괴 예약만 걸어 두고 **현재 프레임의 `Update`/`LateUpdate`가 끝난 뒤 렌더링 직전(프레임 말미)**에 `OnDisable` → `OnDestroy`가 실행되고 네이티브 객체가 파괴된다(Day 20). 에디터 툴 코드가 아닌 런타임에 즉시 파괴하는 `DestroyImmediate`를 쓰면 현재 순회 중인 루프가 깨지므로 런타임에는 `Destroy`를 쓴다.

### 1-4. FixedUpdate와 Time.timeScale

`Update`는 렌더링 프레임마다 1번 호출되므로 프레임 속도에 따라 간격(`Time.deltaTime`)이 들쭉날쭉하다. 반면 물리 엔진은 일정한 시간 간격(`Fixed Timestep`, 기본 0.02초 = 50Hz)으로 적분해야 결과가 안정적이다.

- **프레임당 `0..N`회 실행**: Unity는 누적된 실제 시간만큼 `FixedUpdate`를 반복 실행해 물리 시간을 따라잡는다.
  - 렌더링이 아주 빨라 0.005초 만에 한 프레임이 지나가면 그 프레임에는 `FixedUpdate`가 **0번** 돌 수도 있다.
  - 반대로 프레임이 느려져 0.05초가 걸리면 한 프레임 안에 `FixedUpdate`가 **2~3번 연속** 실행된다(무한 루프에 빠지지 않도록 `Maximum Allowed Timestep`까지만 돈다).
- **`Time.timeScale = 0f` (일시정지)**:
  게임 시간 배율을 0으로 만들면 물리 시간이 흐르지 않으므로 **`FixedUpdate`는 아예 호출되지 않는다.** 반면 **`Update`와 `LateUpdate`는 매 프레임 계속 호출**된다(`Time.deltaTime`만 0이 될 뿐이다). 따라서 일시정지 중에도 동작해야 하는 UI 연출은 `Time.unscaledDeltaTime`을 쓰고, `Update` 안에서 일시정지 중 캐릭터 조작이 먹지 않게 주의해야 한다.
- **입력은 `Update`, 물리는 `FixedUpdate`**:
  `Input.GetKeyDown`은 한 렌더링 프레임 동안만 `true`다. 만약 이를 `FixedUpdate`에서 읽으면, 그 프레임에 `FixedUpdate`가 0번 돌면 입력이 씹히고 2번 돌면 점프가 두 번 나간다. 단발성 입력은 `Update`에서 받아 플래그에 저장하고 `FixedUpdate`에서 소비한다.

---

## 2. 손으로 확인 (30분)

> AI, 자동완성, 검색 없이. 막히면 위의 읽기로 돌아간다.

### 실습 1: LifecycleLogger로 6가지 시나리오의 호출 순서 예측·검증 (30분)

`practice/UnityLab`에 아래 두 스크립트를 만들고, 실행하기 전에 각 시나리오에서 콘솔에 찍힐 로그 순서와 프레임 번호(`F#`)를 **먼저 예측해 표에 적은 뒤** 실행해 비교한다.

```csharp
// Unity: LifecycleLogger.cs
using System.Collections;
using UnityEngine;

public class LifecycleLogger : MonoBehaviour
{
    [SerializeField] private string label = "Target";
    private bool loggedUpdate;
    private bool loggedFixed;
    private bool loggedLate;

    private void Log(string method)
    {
        Debug.Log($"[F{Time.frameCount}] {label}.{method}");
    }

    private void Awake()
    {
        Log("Awake");
    }

    private void OnEnable()
    {
        Log("OnEnable");
    }

    private IEnumerator Start()
    {
        Log("Start (before yield)");
        yield return null;
        Log("Start Coroutine (after yield null)");
    }

    private void FixedUpdate()
    {
        if (!loggedFixed)
        {
            loggedFixed = true;
            Log("FixedUpdate (first)");
        }
    }

    private void Update()
    {
        if (!loggedUpdate)
        {
            loggedUpdate = true;
            Log("Update (first)");
        }
    }

    private void LateUpdate()
    {
        if (!loggedLate)
        {
            loggedLate = true;
            Log("LateUpdate (first)");
        }
    }

    private void OnDisable()
    {
        Log("OnDisable");
    }

    private void OnDestroy()
    {
        Log("OnDestroy");
    }
}
```

시나리오를 키보드 입력으로 실행하는 컨트롤러 스크립트도 함께 붙인다.

```csharp
// Unity: LifecycleScenarioRunner.cs
using UnityEngine;

public class LifecycleScenarioRunner : MonoBehaviour
{
    [SerializeField] private GameObject inactiveSceneObject;
    [SerializeField] private GameObject prefabWithLogger;
    [SerializeField] private LifecycleLogger targetComponent;

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1) && inactiveSceneObject != null)
        {
            Debug.Log($"[F{Time.frameCount}] --- SetActive(true) 호출 직전 ---");
            inactiveSceneObject.SetActive(true);
            Debug.Log($"[F{Time.frameCount}] --- SetActive(true) 호출 직후 ---");
        }

        if (Input.GetKeyDown(KeyCode.Alpha2) && prefabWithLogger != null)
        {
            Debug.Log($"[F{Time.frameCount}] --- Instantiate 호출 직전 ---");
            Instantiate(prefabWithLogger);
            Debug.Log($"[F{Time.frameCount}] --- Instantiate 호출 직후 ---");
        }

        if (Input.GetKeyDown(KeyCode.Alpha3) && targetComponent != null)
        {
            Debug.Log($"[F{Time.frameCount}] --- enabled 토글 ---");
            targetComponent.enabled = !targetComponent.enabled;
        }

        if (Input.GetKeyDown(KeyCode.Alpha4) && targetComponent != null)
        {
            Debug.Log($"[F{Time.frameCount}] --- Destroy 호출 직전 ---");
            Destroy(targetComponent.gameObject);
            Debug.Log($"[F{Time.frameCount}] --- Destroy 호출 직후 ---");
        }

        if (Input.GetKeyDown(KeyCode.Alpha5))
        {
            Time.timeScale = Time.timeScale == 0f ? 1f : 0f;
            Debug.Log($"[F{Time.frameCount}] Time.timeScale = {Time.timeScale}");
        }
    }
}
```

아래 표의 **예측 순서** 칸을 먼저 채운 다음 Play 모드에서 1~5번 키를 눌러 **실측 순서**를 적는다.

| 시나리오 | 내 예측 (호출되는 함수들과 직전/직후 로그의 위치) | 실측 결과 |
|---|---|---|
| 1) 씬 시작 시 활성 오브젝트 (첫 2프레임) | | |
| 2) 컴포넌트만 꺼 둔(`enabled = false`) 활성 오브젝트로 씬 시작 | | |
| 3) 비활성 GameObject에 `1`번 키로 `SetActive(true)` 호출 | | |
| 4) `Update` 도중 `2`번 키로 `Instantiate(prefab)` 호출 | | |
| 5) `3`번 키로 `enabled = false` 후 다시 `enabled = true` | | |
| 6) `4`번 키로 `Destroy(gameObject)` 호출 (직후 로그와 `OnDestroy`의 순서) | | |
| 7) `5`번 키로 `timeScale = 0` (확인하려면 `FixedUpdate`와 `Update`가 매번 로그를 찍도록 잠시 고친다) | | |

<details><summary>해설 및 확인 포인트</summary>

- **시나리오 2(`enabled = false`로 시작)**: GameObject가 활성이므로 **`Awake`만 실행**되고 `OnEnable`과 `Start`는 컴포넌트가 켜질 때까지 돌지 않는다.
- **시나리오 3 & 4(`SetActive(true)`, `Instantiate`)**: `호출 직전`과 `호출 직후` 로그 **사이에** `Awake`와 `OnEnable`이 동기적으로 찍힌다. `Start`는 `호출 직후` 로그 뒤에 찍힌다.
- **시나리오 5(`enabled` 토글)**: `OnDisable`과 `OnEnable`만 반복해서 찍히고 `Awake`와 `Start`는 다시 돌지 않는다.
- **시나리오 6(`Destroy`)**: `Destroy 호출 직후` 로그가 먼저 찍히고, 그 프레임의 `Update`/`LateUpdate`가 끝난 뒤에야 `OnDisable`(활성 상태였다면) → `OnDestroy`가 찍힌다.

</details>

---

## 3. 면접 대비 (10분)

소리 내어 30초 안에 답해 보고 펼쳐서 비교한다.

**Q1. `Awake`, `OnEnable`, `Start`의 호출 순서와 차이점을 설명해 주세요.**
<details><summary>모범 답안</summary>
호출 순서는 `Awake` → `OnEnable` → `Start`입니다. `Awake`는 GameObject가 활성화될 때 컴포넌트의 `enabled` 여부와 상관없이 평생 단 한 번 호출되고, `Start`는 컴포넌트까지 활성화된 상태에서 첫 `Update` 직전에 단 한 번 호출됩니다. 반면 `OnEnable`은 오브젝트나 컴포넌트가 꺼졌다 켜질 때마다 매번 다시 호출되므로 이벤트 구독이나 오브젝트 풀 재활성화 초기화에 적합합니다.

</details>

**Q2. 왜 자신의 초기화는 `Awake`에서 하고 다른 오브젝트 참조는 `Start`에서 하라고 권장하나요?**
<details><summary>모범 답안</summary>
씬에 배치된 여러 오브젝트들 사이의 `Awake` 호출 순서는 기본적으로 보장되지 않기 때문입니다. 만약 A의 `Awake`에서 B의 데이터를 참조하면 B의 `Awake`가 아직 실행되기 전이라 초기화되지 않은 값을 읽거나 `NullReferenceException`이 발생할 수 있습니다. 모든 활성 오브젝트의 `Awake`와 `OnEnable`이 끝난 뒤에 `Start`가 호출되므로, 자기 내부 상태는 `Awake`에서 준비하고 외부 오브젝트와의 연결은 `Start`에서 수행하면 순서 문제를 피할 수 있습니다.

</details>

**Q3. 런타임에 `Instantiate`로 프리팹을 생성한 직후 아랫줄에서 초기화 메서드를 호출할 때, `Awake`, `OnEnable`, `Start` 중 이미 실행된 것은 무엇인가요?**
<details><summary>모범 답안</summary>
프리팹이 활성 상태라면 `Instantiate` 호출 내부에서 `Awake`와 `OnEnable`이 즉시 동기적으로 실행됩니다. 따라서 `Instantiate` 바로 다음 줄에서 초기화 메서드를 부르면 `Awake`와 `OnEnable`은 이미 끝난 뒤이고, `Start`는 아직 실행되지 않은 상태입니다. `Start`는 그 이후 해당 오브젝트의 첫 `Update` 직전에 호출됩니다.

</details>

**Q4. `Update`와 `FixedUpdate`의 차이와, 왜 키 입력(`GetKeyDown`)을 `FixedUpdate`에서 처리하면 안 되는지 설명해 주세요.**
<details><summary>모범 답안</summary>
`Update`는 매 렌더링 프레임마다 한 번 호출되고, `FixedUpdate`는 고정된 물리 시간 간격마다 호출되어 프레임 속도에 따라 한 프레임에 0번 호출될 수도 있고 여러 번 호출될 수도 있습니다. `Input.GetKeyDown` 같은 단발성 입력은 한 렌더링 프레임 동안만 유효하므로, 이를 `FixedUpdate`에서 검사하면 빠른 프레임에서는 입력이 누락되고 느린 프레임에서는 한 번 눌렀는데 두 번 이상 실행되는 버그가 생깁니다. 따라서 입력은 `Update`에서 받고 물리 적용만 `FixedUpdate`에서 해야 합니다.

</details>

**Q5. `Time.timeScale = 0`으로 게임을 일시정지시켰을 때 `Update`, `FixedUpdate`, 코루틴은 어떻게 동작하나요?**
<details><summary>모범 답안</summary>
`FixedUpdate`는 게임 시간 기준의 물리 타이머를 따르므로 `timeScale`이 0이면 호출되지 않습니다. 반면 `Update`와 `LateUpdate`는 프레임마다 계속 호출되며, 단지 `Time.deltaTime`이 0이 될 뿐입니다. 코루틴의 경우 `yield return null`은 매 프레임 계속 재개되지만, `WaitForSeconds`는 게임 시간을 쓰므로 멈추고 `WaitForSecondsRealtime`만 계속 진행됩니다.

</details>

---

## 오늘의 한 줄
> (내 말로 한 문장)

## 더 보기
- [이벤트 함수의 실행 순서 (Unity 공식 문서)](https://docs.unity3d.com/Manual/ExecutionOrder.html)
- [MonoBehaviour API 문서](https://docs.unity3d.com/ScriptReference/MonoBehaviour.html)
- [Time과 프레임 속도 관리 (Unity 공식 문서)](https://docs.unity3d.com/Manual/TimeFrameManagement.html)
