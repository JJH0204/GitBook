# Day 17 · 프로파일러 읽는 법 🎮

> 3주차 렌더링과 측정 · 60분 · 준비물: 🎮 Unity 6 (`practice/UnityLab`, URP)

## 오늘의 목표
- 왜 에디터 프로파일링만 믿으면 안 되는지 설명하고 `Development Build`에서 측정하는 원칙을 지킬 수 있다.
- CPU Usage 모듈의 `Hierarchy`(`Total` vs `Self`, `GC Alloc`)와 `Timeline`(메인·렌더·워커 스레드)을 읽고 진짜 병목 지점을 찾을 수 있다.
- `Deep Profile`의 한계를 이해하고 `ProfilerMarker`로 의심 구간만 정밀하게 계측할 수 있다.

---

## 1. 읽기 (20분)

### 1-1. 측정의 4가지 원칙

1. **추측하지 말고 측정한다**: 코드를 눈으로 보고 "여기가 느릴 것이다"라고 고치면 엉뚱한 곳만 복잡해진다.
2. **에디터 ≠ 빌드**: Unity 에디터에서 Play 모드로 찍은 프로파일러에는 Scene 뷰 렌더링, 인스펙터 갱신, 에디터 전용 검증, `OnGUI` 디버그 창, C# 디버그 체크 오버헤드가 섞여 있다. 최종 판단은 반드시 **`Development Build` + `Autoconnect Profiler`**에서 내린다.
3. **같은 조건에서 전후(A/B) 비교한다**: 같은 카메라 위치, 같은 시드/연출, 같은 워밍업 상태에서 수정 전과 수정 후 수치를 비교한다.
4. **평균 프레임만 보지 말고 최악 프레임(스파이크, 1% Low)을 본다**: 평균 60 FPS여도 1초에 한 번 80 ms짜리 스파이크가 튀면 플레이어는 "게임이 끊긴다"고 느낀다.

**팀 프로젝트 교훈**:
같은 전투 구간인데도 에디터에서는 스파이크 초과분의 81%가 메인 스레드의 VFX 초기화로 보였고, `Development Build`에서는 74%가 렌더 스레드 쪽에서 나타났다. 빌드의 던전 진입 최악 프레임(2,776ms)은 절반이 디버그 하네스의 `IMGUI` 텍스트 측정이었는데, 출시 빌드에는 없어야 할 개발용 코드다. 에디터에서는 방향만 잡고, 수치는 빌드에서 확정하며, 개발 빌드에만 있는 비용은 따로 표시해 둔다.

### 1-2. CPU Usage 모듈: Hierarchy vs Timeline

CPU Usage 창 왼쪽 상단 드롭다운으로 두 가지 뷰를 오가며 본다.

| 뷰 | 언제 쓰는가 | 핵심 열 / 보는 법 |
|---|---|---|
| **Hierarchy** | 어떤 함수가 시간을 많이 썼고 `GC Alloc`을 얼마나 일으켰는지 정렬해 찾을 때 | - **`Total` vs `Self`**: `Total`은 하위 호출까지 합친 시간, **`Self`는 그 함수 자체에서 쓴 시간**이다. 진짜 범인은 `Self ms`가 높은 쪽에 있다.<br>- **`Calls`**: 프레임당 호출 횟수<br>- **`GC Alloc`**: 힙 할당 바이트. `GC Alloc` 열 헤더를 클릭해 내림차순 정렬하면 프레임당 할당 범인이 바로 나온다 |
| **Timeline** | 호출 순서, 스레드 간 대기(메인 ↔ 렌더 ↔ Job 워커), 긴 프레임의 병목 위치를 시간축으로 볼 때 | - **Main Thread**와 **Render Thread**가 나란히 보인다. 어느 쪽이 다른 쪽을 기다리는지(`WaitForPresent...`) 한눈에 보인다 |

### 1-3. 자주 만나는 프로파일러 마커 사전

| 마커 이름 | 의미와 대처 |
|---|---|
| `PlayerLoop` | 한 프레임의 최상위 루프 |
| `Update.ScriptRunBehaviourUpdate` | 모든 `MonoBehaviour.Update()` 실행 시간의 합 |
| `Gfx.WaitForPresentOnGfxThread` | 메인 스레드가 렌더 스레드/GPU 완료를 기다리는 시간 (Day 13, **GPU 바운드** 신호) |
| `WaitForTargetFPS` | VSync 또는 `Application.targetFrameRate`를 맞추려고 **남은 시간을 쉬는 구간**(병목 아님!) |
| `GC.Collect` | Boehm GC가 힙을 스캔해 메모리를 회수하는 시간. 평소 `GC Alloc`을 0에 가깝게 줄여 예방해야 함 (Day 03) |
| `Shader.CreateGPUProgram` / PSO 생성 마커 | 런타임 첫 셰이더/PSO 준비 스톨 (Day 16) |
| `Loading.UpdatePreloading` / `AwakeFromLoad` | 에셋·씬 로딩 및 직렬화 복원 비용 |

### 1-4. Deep Profile의 함정과 ProfilerMarker

`Deep Profile` 버튼을 켜면 모든 C# 메서드 진입·퇴장에 계측 코드가 삽입된다.
- **장점**: 어떤 하위 메서드가 범인인지 코드 수정 없이 바로 보인다.
- **단점**: **계측 오버헤드 자체가 엄청나게 크다.** 작은 함수를 수만 번 호출하는 코드는 Deep Profile을 켜는 순간 원래보다 수십 배 느려져서 병목 순위가 왜곡되고 메모리도 많이 먹는다.

따라서 실무에서는 일반 프로파일링으로 큰 줄기를 먼저 찾고, 의심되는 구간에만 **`ProfilerMarker`**를 심어 오버헤드 없이 정확히 잰다.

```csharp
using Unity.Profiling;
using UnityEngine;

public class MarkerExample : MonoBehaviour
{
    // static readonly로 한 번만 선언해 재사용 (할당 0)
    private static readonly ProfilerMarker SearchMarker = new ProfilerMarker("MyGame.SearchTargets");

    private void Update()
    {
        using (SearchMarker.Auto())
        {
            // 측정할 코드
        }
    }
}
```

### 1-5. 함께 쓰는 분석 도구 3가지

- **Frame Debugger**: 한 프레임의 드로우 콜 순서와 배칭이 깨진 이유를 1드로우 단위로 확인 (Day 13, 14).
- **Memory Profiler 패키지**: 두 시점의 메모리 스냅샷을 찍어 비교(`Diff`)함으로써 씬 전환 후에도 남아서 새는 에셋·래퍼 객체(Day 20)를 추적.
- **Profile Analyzer 패키지**: 300프레임 같은 구간의 프로파일 데이터를 두 벌 불러와 중앙값(`Median`), 상위 1%, 마커별 시간 차이를 통계로 비교.

---

## 2. 손으로 확인 (30분)

> AI, 자동완성, 검색 없이. 막히면 위의 읽기로 돌아간다.

### 실습 1: 심어 둔 3가지 문제(GC, 스파이크, CPU 과부하)를 프로파일러로 잡고 고치기 (30분)

아래 `ProblemMaker.cs`를 직접 타이핑해 `practice/UnityLab`의 빈 오브젝트에 붙인다. `Start`에서 더미 오브젝트 200개를 만든다. `RunFixed`는 처음에 비워 두고, 프로파일러로 원인을 찾은 다음 직접 고쳐 쓴 뒤 아래 코드와 비교한다.

```csharp
// Unity: ProblemMaker.cs
using System.Text;
using System.Threading;
using Unity.Profiling;
using UnityEngine;

public class ProblemMaker : MonoBehaviour
{
    private static readonly ProfilerMarker ConcatMarker = new ProfilerMarker("Lab.StringBuild");
    private static readonly ProfilerMarker SpikeMarker  = new ProfilerMarker("Lab.PeriodicWork");
    private static readonly ProfilerMarker FindMarker   = new ProfilerMarker("Lab.FindTargets");

    [SerializeField] private bool useFixedVersion = false;

    private readonly StringBuilder sb = new StringBuilder(1024);
    private Transform[] cachedTargets;
    private string lastStatus;

    private void Start()
    {
        for (int i = 0; i < 200; i++)
        {
            GameObject go = new GameObject("DummyTarget_" + i);
            go.transform.SetParent(transform);
        }
        cachedTargets = GetComponentsInChildren<Transform>();
    }

    private void Update()
    {
        if (!useFixedVersion)
        {
            RunBroken();
        }
        else
        {
            RunFixed();
        }
    }

    private void RunBroken()
    {
        // 문제 1: 매 프레임 문자열 연결로 GC Alloc 발생
        using (ConcatMarker.Auto())
        {
            string s = "";
            for (int i = 0; i < 100; i++)
            {
                s += i.ToString() + ",";
            }
            lastStatus = s;
        }

        // 문제 2: 100프레임마다 50ms 블로킹 스파이크
        using (SpikeMarker.Auto())
        {
            if (Time.frameCount % 100 == 0)
            {
                Thread.Sleep(50);
            }
        }

        // 문제 3: 매 프레임 씬 전체에서 컴포넌트 검색
        using (FindMarker.Auto())
        {
            for (int i = 0; i < 20; i++)
            {
                Transform[] all = FindObjectsByType<Transform>(FindObjectsSortMode.None);
                if (all.Length > 0) lastStatus = all[0].name;
            }
        }
    }

    private void RunFixed()
    {
        using (ConcatMarker.Auto())
        {
            sb.Clear();
            for (int i = 0; i < 100; i++)
            {
                sb.Append(i).Append(',');
            }
        }

        using (SpikeMarker.Auto())
        {
            // 블로킹 대기 제거
        }

        using (FindMarker.Auto())
        {
            // Start에서 캐싱해 둔 배열 재사용
            if (cachedTargets.Length > 0)
            {
                lastStatus = cachedTargets[0].name;
            }
        }
    }
}
```

1. Play 모드를 켜고 Profiler(`Window > Analysis > Profiler` → `CPU Usage` → `Hierarchy`)에서 200프레임가량 기록한 뒤 일시정지한다.
2. 그래프에서 **평소 프레임**과 **위로 솟구친 스파이크 프레임**을 각각 클릭해 `Lab.StringBuild`, `Lab.PeriodicWork`, `Lab.FindTargets` 세 마커의 `Total ms`, `Self ms`, `GC Alloc`을 찾아 표에 적는다.
3. 인스펙터에서 `useFixedVersion`을 체크한 뒤 다시 기록하여 수치가 어떻게 바뀌었는지 채운다.

| 마커 이름 | 수정 전 Time (ms) | 수정 전 GC Alloc (B / KB) | 수정 후 Time (ms) | 수정 후 GC Alloc | 원인 요약 |
|---|---|---|---|---|---|
| `Lab.StringBuild` (평소 프레임) | | | | | |
| `Lab.PeriodicWork` (스파이크 프레임) | | | | | |
| `Lab.FindTargets` (평소 프레임) | | | | | |

---

## 3. 면접 대비 (10분)

소리 내어 30초 안에 답해 보고 펼쳐서 비교한다.

**Q1. 게임 중 간헐적으로 프레임이 뚝 끊기는(프레임 드랍) 현상이 제보되었습니다. 어떤 순서로 원인을 찾으시겠습니까?**
<details><summary>모범 답안</summary>
먼저 에디터가 아닌 `Development Build`에 프로파일러를 연결해 문제 구간을 재현하고, 평균 프레임이 아니라 그래프에서 치솟은 스파이크 프레임을 클릭합니다. Timeline 뷰에서 메인 스레드와 렌더 스레드를 비교해 CPU 바운드인지 GPU 대기(`WaitForPresent`)인지 먼저 가릅니다. CPU 쪽이라면 Hierarchy 뷰에서 `Self ms`와 `GC Alloc`을 기준으로 정렬해 스크립트 연산, `GC.Collect`, 에셋 로딩, 셰이더 첫 컴파일 중 무엇이 범인인지 좁힌 뒤, 의심 함수에 `ProfilerMarker`를 심어 수정 전후 수치를 비교합니다.

</details>

**Q2. 프로파일러 Hierarchy 뷰의 `Total` 시간과 `Self` 시간은 무엇이 다른가요?**
<details><summary>모범 답안</summary>
`Total` 시간은 해당 함수가 시작해서 끝날 때까지 하위에서 호출한 다른 함수들의 실행 시간까지 모두 합친 값이고, `Self` 시간은 하위 호출 시간을 빼고 순수하게 그 함수 본문 자체에서 소비한 시간입니다. 예를 들어 `Update` 매니저 함수는 하위 시스템을 다 호출하므로 `Total`은 높고 `Self`는 낮습니다. 따라서 호출 트리를 따라 내려가며 실제로 연산을 소모하는 진짜 병목을 찾을 때는 `Self` 시간이 높은 함수를 찾아야 합니다.

</details>

**Q3. 왜 에디터에서 프로파일링한 수치만 믿고 최적화를 끝내면 안 되나요?**
<details><summary>모범 답안</summary>
에디터에는 Scene 뷰와 인스펙터 렌더링, 에디터 전용 안전성 검사, 디버그용 IMGUI, 에셋 데이터베이스 감시 같은 오버헤드가 함께 잡히기 때문입니다. 또한 셰이더 컴파일이나 스크립트 최적화 수준도 실제 빌드된 실행 파일(특히 IL2CPP 빌드)과 다릅니다. 따라서 에디터 프로파일러는 대략적인 경향을 파악하는 용도로만 쓰고, 실제 병목 비중과 개선 수치는 반드시 `Development Build`에서 확인해야 합니다.

</details>

**Q4. `Deep Profile` 기능의 장단점과 대안은 무엇인가요?**
<details><summary>모범 답안</summary>
`Deep Profile`은 모든 C# 메서드 호출을 자동으로 기록해 주므로 어디서 시간이 쓰이는지 한눈에 볼 수 있다는 장점이 있습니다. 하지만 모든 함수 호출마다 계측 오버헤드가 붙기 때문에 작은 함수를 많이 부르는 코드의 시간이 실제보다 크게 부풀려지고 메모리 소모도 심합니다. 따라서 전체 흐름은 일반 모드로 보고, 정밀 측정이 필요한 구간에만 `ProfilerMarker`를 코드에 추가해 오버헤드 없이 측정하는 것이 정확합니다.

</details>

---

## 오늘의 한 줄
> (내 말로 한 문장)

## 더 보기
- [프로파일러 창 개요 (Unity 공식 문서)](https://docs.unity3d.com/Manual/ProfilerWindow.html)
- [CPU Usage 프로파일러 모듈 (Unity 공식 문서)](https://docs.unity3d.com/Manual/ProfilerCPU.html)
- [ProfilerMarker API 문서](https://docs.unity3d.com/ScriptReference/Unity.Profiling.ProfilerMarker.html)
- [Memory Profiler 패키지 문서](https://docs.unity3d.com/Packages/com.unity.memoryprofiler@latest)
