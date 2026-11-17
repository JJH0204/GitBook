# Day 06 · [실습] 상태 패턴

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UCS-007-MP |
| 목적 | 같은 전이 규칙을 `enum + switch`와 상태 패턴 두 방식으로 구현하고, 상태 패턴이 전이 중 힙 할당 0 B임을 확인한다 |
| 적용 대상 | .NET SDK 8 이상 콘솔 앱 (1주차 C# 메모리). 확장 과제 3은 Unity 6 |
| 소요 시간 | 60분 (설계 읽기 10분, 구현 45분, 회고 5분) |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 구현은 AI, 코드 자동완성, 검색 없이 한다. 막히면 설계 개요와 `참조`의 문서만 본다. 참고 구현(부록 A)은 구현을 끝낸 뒤 펼친다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [day03-gc-allocation.md](day03-gc-allocation.md) | GMD-UCS-004-DO | Day 03 · GC와 할당 |
| [day05-delegate-closure.md](day05-delegate-closure.md) | GMD-UCS-006-DO | Day 05 · 델리게이트, 람다, 클로저 |
| [day07-iterator-yield.md](day07-iterator-yield.md) | GMD-UCS-008-DO | Day 07 · IEnumerator와 yield의 정체 (다음 날) |

외부 자료:
- [Game Programming Patterns — State 장 (Robert Nystrom)](https://gameprogrammingpatterns.com/state.html)
- [패턴 일치 — switch 식 (C# 참조)](https://learn.microsoft.com/ko-kr/dotnet/csharp/language-reference/operators/switch-expression)
- [Unity 매뉴얼 — 애니메이터 컨트롤러와 상태 머신](https://docs.unity3d.com/Manual/StateMachineBasics.html)

이전: [Day 05 · 델리게이트, 람다, 클로저](day05-delegate-closure.md) · 다음: [Day 07 · IEnumerator와 yield의 정체](day07-iterator-yield.md)

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | .NET SDK | 8 이상 | `dotnet --version`으로 확인한다 |
| 2 | 터미널 | 임의 | |
| 3 | 코드 편집기 | VS Code 또는 Rider | AI 기능(Copilot, AI Assistant)을 끈다 |
| 4 | Unity 6 (선택) | 구역 D의 확장 과제 3에서만 사용 | |

## 3. 안전 사항

{% hint style="info" %}
NOTE: 작업 폴더 `practice/day06/` 밖의 파일을 건드리지 않는다. 이 작업은 데이터 손실 위험이 없다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 작업 폴더를 만든다: `dotnet new console -o practice/day06` | `practice/day06/Program.cs`가 생긴다 |
| 2 | 작업 폴더로 이동한다: `cd practice/day06` | `dotnet run`이 `Hello, World!`를 출력한다 |
| 3 | 아래 `설계 개요`를 읽는다 (10분) | `enum + switch`와 상태 패턴의 차이를 한 문장으로 말할 수 있다 |

## 설계 개요

### 설계 1. `enum + switch` vs 상태 패턴(`State pattern`)

캐릭터가 `Idle`, `Run`, `Jump`, `Attack`, `Hit` 5개 상태를 가질 때 가장 먼저 떠올리는 코드는 `enum`과 `switch`다.

| 항목 | `enum + switch` | 상태 패턴 (`ICharacterState`) |
|---|---|---|
| 구조 | 상태 값 하나 + 메서드(`Update`, `Transition`)마다 큰 `switch`문 | 상태별 클래스가 `Enter` / `Update` / `Exit`를 한곳에 캡슐화 |
| 상태 추가 시 | 모든 `switch`문을 찾아 케이스를 추가해야 함 | 새 상태 클래스 하나 추가 |
| 진입·퇴장 처리 | 전이하는 곳마다 이전 상태 정리·다음 상태 초기화를 챙겨야 해 흩어지기 쉬움 | `ChangeState`가 항상 `old.Exit()` → `new.Enter()`를 보장 |
| 메모리 주의점 | 값(`enum`)만 바꾸므로 할당 없음 | 전이할 때마다 **`new JumpState()`를 호출하면 프레임마다 가비지 발생** → **초기화 때 1번만 생성해 캐시·재사용**해야 함 |

### 설계 2. 전이(`Transition`)는 누가 결정하는가

상태 패턴에서 전이 조건을 두는 위치는 두 가지 방식이 있다.
1. **각 상태 객체가 결정**: `IdleState`가 입력을 보고 `ctx.ChangeState(ctx.Run)`을 호출한다. 상태별 규칙이 그 클래스 안에 응집된다.
2. **컨텍스트(또는 전이 테이블)가 결정**: 피격(`Hit`)처럼 **모든 상태에서 공통으로 끼어드는 최우선 전이**는 컨텍스트(`ChangeState` 호출부)에서 먼저 처리하고, 일반 전이는 각 상태에 위임하면 중복이 줄어든다.

## 요구사항

1. **입력 형식**: 문자열 하나가 시뮬레이션 전체 입력이다. 각 글자 1개가 1프레임(0번 프레임부터 시작)의 입력을 뜻한다.
   - `.`: 입력 없음 / `r`: 달리기 유지 / `j`: 점프 / `a`: 공격 / `h`: 피격
2. **상태와 전이 규칙** (초기 상태는 `Idle`, 초기 상태 진입 로그는 찍지 않음):

| 현재 상태 | 지속 프레임 | 프레임 시작 시 전이 규칙 (우선순위 순) |
|---|---|---|
| 공통 최우선 | - | 입력이 `'h'`이면 현재 상태와 무관하게 즉시 `Hit`로 전이 |
| `Idle` | 무기한 | `'r'` → `Run`, `'j'` → `Jump`, `'a'` → `Attack`, `'.'` → 유지 |
| `Run` | `'r'` 누른 동안 | `'j'` → `Jump`, `'a'` → `Attack`, `'.'` → `Idle`, `'r'` → 유지 |
| `Jump` | **3프레임** | 점프 중에는 `'a'`, `'r'`, `'j'` 무시(`Jump` 중 공격 불가). 3프레임이 끝난 다음 프레임 시작 시 `Idle`로 전이 |
| `Attack` | **2프레임** | 공격 중에는 `'r'`, `'j'`, `'a'` 무시. 2프레임이 끝난 다음 프레임 시작 시 `Idle`로 전이 |
| `Hit` | **2프레임** | 경직 중에는 일반 입력 무시. 2프레임이 끝난 다음 프레임 시작 시 `Idle`로 전이 |

3. **프레임 처리 순서와 로그 형식**:
   - 매 프레임 `f`에서 (1) 전이 판정 및 상태 변경(` 현재 != 다음`일 때만 `Exit <이전>` 줄과 `Enter <다음>` 줄 기록) → (2) `frame {f}: {현재상태}` 줄 기록 → (3) 지속 시간 있는 상태(`Jump`, `Attack`, `Hit`)면 남은 프레임 타이머 1 감소 순서로 실행한다.
4. **3단계 구현**:
   - **Step 1**: `enum StateId`와 `switch`문만 사용하는 `EnumCharacterFsm`을 작성한다.
   - **Step 2**: `ICharacterState` 인터페이스를 구현한 상태 클래스를 사용하는 `StatePatternCharacterFsm`을 작성한다. **상태 인스턴스는 생성자에서 한 번만 만들어 필드에 캐시하고 전이 시 재사용한다(`new` 금지).**
   - **Step 3**: 두 FSM에 동일한 입력 `".rrj.a.ah.."`을 넣고 결과 문자열이 완전히 같은지 `Debug.Assert`로 검증한 뒤 같으면 `"MATCH"`를 출력한다.

## 5. 절차

### A. Step 1: `enum + switch` FSM 구현

1. (5-A-01) `Program.cs`에 `enum StateId { Idle, Run, Jump, Attack, Hit }`를 작성한다. → 결과: 5개 상태가 정의된다.
2. (5-A-02) `EnumCharacterFsm` 클래스를 작성한다. `RunSimulation(string input)`은 프레임마다 전이 판정, 로그 기록, 타이머 감소 순서로 실행한다. → 결과: 입력 문자열 하나를 받아 로그 문자열을 반환한다.
3. (5-A-03) 전이 로직은 `switch (_state)` 하나에 모은다. `'h'` 입력은 `switch` 앞에서 먼저 처리한다. → 결과: 요구사항의 우선순위 표와 같은 순서로 판정된다.
4. (5-A-04) `dotnet run`으로 `".rrj.a.ah.."`를 넣고 로그를 출력한다. → 결과: `기능 확인` 1번의 예상 출력과 같은 줄이 나온다.

### B. Step 2: 상태 패턴 FSM 구현

{% hint style="warning" %}
CAUTION: 상태 인스턴스는 생성자(필드 초기화)에서 한 번만 만든다. 전이 메서드 안에서 `new`를 호출하면 전이마다 GC 할당이 생겨 Step 3의 0 B 확인이 실패한다.
{% endhint %}

1. (5-B-01) `ICharacterState` 인터페이스를 작성한다. 멤버는 `Name`, `Enter`, `HandleInput`, `Update`, `Exit`다. → 결과: 상태별 동작이 인터페이스 하나로 정의된다.
2. (5-B-02) `StatePatternCharacterFsm`에 상태 5개를 `readonly` 필드로 만든다. → 결과: 상태 인스턴스가 객체당 5개로 고정된다.
3. (5-B-03) `ChangeState(next)`를 작성한다. 같은 상태면 반환하고, 아니면 `Exit` 호출 → 상태 교체 → `Enter` 호출 순서로 실행하고 로그를 남긴다. → 결과: 전이 때마다 `Exit`/`Enter`가 항상 한 쌍으로 호출된다.
4. (5-B-04) `'h'` 입력을 `StepCore`에서 먼저 처리해 `Hit`로 전이한다. 나머지 입력은 현재 상태의 `HandleInput`에 위임한다. → 결과: 피격이 모든 상태에서 최우선으로 처리된다.
5. (5-B-05) `RunSimulation`과 로그 없이 전이만 하는 `StepSilent`를 작성한다. → 결과: 할당 측정용 경로와 로그 출력 경로가 분리된다.

### C. Step 3: 두 구현 비교와 할당 측정

1. (5-C-01) 두 FSM에 같은 입력 `".rrj.a.ah.."`를 넣는다. → 결과: 로그 문자열 두 개가 나온다.
2. (5-C-02) `Debug.Assert(enumLog == stateLog)`로 비교하고, 같으면 `MATCH`를 출력한다. → 결과: `MATCH`가 출력된다.
3. (5-C-03) `GC.GetAllocatedBytesForCurrentThread()`를 `StepSilent` 반복 전후에 읽어 차이를 출력한다. → 결과: `State 패턴 전이 중 힙 할당: 0 B`가 출력된다.

{% hint style="info" %}
NOTE: `Debug.Assert`는 Release 빌드에서 컴파일 단계에서 제거된다. `dotnet run`은 기본이 Debug 구성이라 동작한다. 그래도 `MATCH` 출력 줄로 결과를 직접 확인한다.
{% endhint %}

### D. 확장(선택)

1. (5-D-01) 계층형 상태(Hierarchical FSM): `Idle`과 `Run`의 공통 전이(`'j'` → `Jump`, `'a'` → `Attack`)를 상위 상태 `GroundedState`로 묶어 중복을 제거한다. → 결과: 두 상태의 `HandleInput`에서 공통 분기가 사라지고 출력은 그대로다.
2. (5-D-02) 전이 이력 링버퍼: 최근 8번의 상태 전이를 `(frame, from, to)` struct 배열(`new` 없이 고정 크기 순환 버퍼)에 기록해 시뮬레이션 끝에 출력한다. → 결과: 마지막 8개 전이가 출력되고 전이 중 할당은 0 B다.
3. (5-D-03) Unity 이식 🎮: `Update()`에서 키보드 입력(`Input.GetKey`)을 문자(`'r'`, `'j'`, `'a'`, `'h'`, `'.'`)로 변환해 `StatePatternCharacterFsm`을 구동한다. → 결과: 키 입력에 따라 `Exit`/`Enter` 로그가 콘솔에 찍힌다.

{% hint style="info" %}
NOTE: `Input.GetKey`는 구 `Input` 클래스 API다. Unity 6에서 새 Input System만 활성화하면 예외가 난다. `Project Settings > Player > Active Input Handling`을 `Both`로 바꾸거나 Input System API로 바꾼다. 버전 확인 필요.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 입력 `".rrj.a.ah.."`로 두 FSM의 로그를 출력한다 | 아래 예상 출력과 같다 (11프레임, `frame 0`~`frame 10`) | 줄 단위로 일치 |
| 2 | 두 로그를 문자열 비교한다 | `MATCH` 출력 | `MISMATCH`가 아니다 |
| 3 | 상태 패턴의 `StepSilent` 11회 전후 할당량 차이를 읽는다 | `0 B` | 정확히 0 |
| 4 | 점프 중(`frame 3`~`5`)의 `'a'` 입력(`frame 5`)이 무시되는지 본다 | `frame 5: Jump`가 출력된다 | `Attack` 전이 줄이 없다 |
| 5 | `frame 8`의 `'h'`가 `Attack`을 끊는지 본다 | `Exit Attack`, `Enter Hit` | 두 줄이 순서대로 있다 |

입력 문자열 `".rrj.a.ah.."`는 총 11프레임이다. 5번 프레임의 `'a'`는 점프 중이라 무시되고, 7번 프레임의 `Attack`은 8번 프레임의 `'h'`에 끊긴다. 예상 출력:

```
frame 0: Idle
Exit Idle
Enter Run
frame 1: Run
frame 2: Run
Exit Run
Enter Jump
frame 3: Jump
frame 4: Jump
frame 5: Jump
Exit Jump
Enter Idle
frame 6: Idle
Exit Idle
Enter Attack
frame 7: Attack
Exit Attack
Enter Hit
frame 8: Hit
frame 9: Hit
Exit Hit
Enter Idle
frame 10: Idle
MATCH
State 패턴 전이 중 힙 할당: 0 B
```

## 7. 복구

1. (7-01) 작업 폴더를 삭제한다: `rm -rf practice/day06` (PowerShell: `Remove-Item -Recurse practice/day06`). → 결과: 폴더가 사라진다.
2. (7-02) Unity 확장 과제를 했다면 변경한 `Active Input Handling` 값을 원래대로 돌린다. 씬은 저장 전이면 `Ctrl+Z`로 되돌린다. → 결과: 프로젝트 설정이 작업 전과 같다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM 형식(Task 템플릿)으로 재작성. 요구사항·참고 구현·회고는 원문 보존, 구역별 절차와 기능 확인 표 추가 |

## 부록 A. 참고 구현

<details><summary>참고 구현</summary>

```csharp
// 실행 가능: Program.cs
using System.Diagnostics;
using System.Text;

const string Input = ".rrj.a.ah..";

var enumFsm = new EnumCharacterFsm();
string enumLog = enumFsm.RunSimulation(Input);

var stateFsm = new StatePatternCharacterFsm();
long b0 = GC.GetAllocatedBytesForCurrentThread();
for (int i = 0; i < Input.Length; i++) stateFsm.StepSilent(Input[i]);
long stepAlloc = GC.GetAllocatedBytesForCurrentThread() - b0;

stateFsm.Reset();
string stateLog = stateFsm.RunSimulation(Input);

Console.WriteLine(enumLog);
Debug.Assert(enumLog == stateLog, "두 FSM의 출력이 다릅니다!");
Console.WriteLine(enumLog == stateLog ? "MATCH" : "MISMATCH");
Console.WriteLine($"State 패턴 전이 중 힙 할당: {stepAlloc} B");

enum StateId { Idle, Run, Jump, Attack, Hit }

class EnumCharacterFsm
{
    private StateId _state = StateId.Idle;
    private int _timer;
    private readonly StringBuilder _log = new();

    public string RunSimulation(string input)
    {
        _state = StateId.Idle;
        _timer = 0;
        _log.Clear();
        for (int f = 0; f < input.Length; f++)
            Step(f, input[f]);
        return _log.ToString().TrimEnd();
    }

    private void Step(int frame, char ch)
    {
        if (ch == 'h')
        {
            TransitionTo(StateId.Hit);
        }
        else
        {
            switch (_state)
            {
                case StateId.Idle:
                    if (ch == 'r') TransitionTo(StateId.Run);
                    else if (ch == 'j') TransitionTo(StateId.Jump);
                    else if (ch == 'a') TransitionTo(StateId.Attack);
                    break;
                case StateId.Run:
                    if (ch == 'j') TransitionTo(StateId.Jump);
                    else if (ch == 'a') TransitionTo(StateId.Attack);
                    else if (ch == '.') TransitionTo(StateId.Idle);
                    break;
                case StateId.Jump:
                case StateId.Attack:
                case StateId.Hit:
                    if (_timer == 0) TransitionTo(StateId.Idle);
                    break;
            }
        }

        _log.AppendLine($"frame {frame}: {_state}");
        if (_state is StateId.Jump or StateId.Attack or StateId.Hit)
            _timer--;
    }

    private void TransitionTo(StateId next)
    {
        if (_state == next) return;
        _log.AppendLine($"Exit {_state}");
        _state = next;
        _timer = next switch
        {
            StateId.Jump => 3,
            StateId.Attack => 2,
            StateId.Hit => 2,
            _ => 0
        };
        _log.AppendLine($"Enter {_state}");
    }
}

interface ICharacterState
{
    string Name { get; }
    void Enter(StatePatternCharacterFsm ctx);
    void HandleInput(StatePatternCharacterFsm ctx, char ch);
    void Update(StatePatternCharacterFsm ctx);
    void Exit(StatePatternCharacterFsm ctx);
}

class StatePatternCharacterFsm
{
    public readonly ICharacterState Idle = new IdleState();
    public readonly ICharacterState Run = new RunState();
    public readonly ICharacterState Jump = new JumpState();
    public readonly ICharacterState Attack = new AttackState();
    public readonly ICharacterState Hit = new HitState();

    public int Timer;
    private ICharacterState _current;
    private readonly StringBuilder _log = new();
    private bool _logging = true;

    public StatePatternCharacterFsm() => _current = Idle;

    public void Reset()
    {
        _current = Idle;
        Timer = 0;
        _log.Clear();
    }

    public string RunSimulation(string input)
    {
        Reset();
        _logging = true;
        for (int f = 0; f < input.Length; f++)
        {
            StepCore(input[f]);
            _log.AppendLine($"frame {f}: {_current.Name}");
            _current.Update(this);
        }
        return _log.ToString().TrimEnd();
    }

    public void StepSilent(char ch)
    {
        _logging = false;
        StepCore(ch);
        _current.Update(this);
    }

    private void StepCore(char ch)
    {
        if (ch == 'h') ChangeState(Hit);
        else _current.HandleInput(this, ch);
    }

    public void ChangeState(ICharacterState next)
    {
        if (ReferenceEquals(_current, next)) return;
        _current.Exit(this);
        if (_logging) _log.AppendLine($"Exit {_current.Name}");
        _current = next;
        _current.Enter(this);
        if (_logging) _log.AppendLine($"Enter {_current.Name}");
    }

    private sealed class IdleState : ICharacterState
    {
        public string Name => "Idle";
        public void Enter(StatePatternCharacterFsm ctx) => ctx.Timer = 0;
        public void HandleInput(StatePatternCharacterFsm ctx, char ch)
        {
            if (ch == 'r') ctx.ChangeState(ctx.Run);
            else if (ch == 'j') ctx.ChangeState(ctx.Jump);
            else if (ch == 'a') ctx.ChangeState(ctx.Attack);
        }
        public void Update(StatePatternCharacterFsm ctx) { }
        public void Exit(StatePatternCharacterFsm ctx) { }
    }

    private sealed class RunState : ICharacterState
    {
        public string Name => "Run";
        public void Enter(StatePatternCharacterFsm ctx) => ctx.Timer = 0;
        public void HandleInput(StatePatternCharacterFsm ctx, char ch)
        {
            if (ch == 'j') ctx.ChangeState(ctx.Jump);
            else if (ch == 'a') ctx.ChangeState(ctx.Attack);
            else if (ch == '.') ctx.ChangeState(ctx.Idle);
        }
        public void Update(StatePatternCharacterFsm ctx) { }
        public void Exit(StatePatternCharacterFsm ctx) { }
    }

    private sealed class JumpState : ICharacterState
    {
        public string Name => "Jump";
        public void Enter(StatePatternCharacterFsm ctx) => ctx.Timer = 3;
        public void HandleInput(StatePatternCharacterFsm ctx, char ch)
        {
            if (ctx.Timer == 0) ctx.ChangeState(ctx.Idle);
        }
        public void Update(StatePatternCharacterFsm ctx) => ctx.Timer--;
        public void Exit(StatePatternCharacterFsm ctx) { }
    }

    private sealed class AttackState : ICharacterState
    {
        public string Name => "Attack";
        public void Enter(StatePatternCharacterFsm ctx) => ctx.Timer = 2;
        public void HandleInput(StatePatternCharacterFsm ctx, char ch)
        {
            if (ctx.Timer == 0) ctx.ChangeState(ctx.Idle);
        }
        public void Update(StatePatternCharacterFsm ctx) => ctx.Timer--;
        public void Exit(StatePatternCharacterFsm ctx) { }
    }

    private sealed class HitState : ICharacterState
    {
        public string Name => "Hit";
        public void Enter(StatePatternCharacterFsm ctx) => ctx.Timer = 2;
        public void HandleInput(StatePatternCharacterFsm ctx, char ch)
        {
            if (ctx.Timer == 0) ctx.ChangeState(ctx.Idle);
        }
        public void Update(StatePatternCharacterFsm ctx) => ctx.Timer--;
        public void Exit(StatePatternCharacterFsm ctx) { }
    }
}
```

</details>

## 부록 B. 회고

질문에 스스로 답해 본 뒤 펼친다.

**Q1. 상태 패턴보다 `enum + switch`가 오히려 나은 경우는 언제인가?**
<details><summary>모범 답안</summary>
상태 개수가 3~4개 이하로 적고 앞으로도 늘어날 가능성이 낮으며, 상태별 고유 필드나 복잡한 `Enter`/`Exit` 동작이 없을 때는 `enum + switch`가 파일 하나에서 한눈에 읽히고 인터페이스 호출이나 객체 생성이 없어 더 단순하고 유리합니다.

</details>

**Q2. 오늘 직접 만든 코드 기반 FSM은 Unity의 `Animator` 상태 기계와 역할이 어떻게 다른가?**
<details><summary>모범 답안</summary>
Unity `Animator`는 애니메이션 클립의 블렌딩과 재생 타이밍을 제어하는 비주얼 상태 기계입니다. 게임플레이 판정(무적 시간, 공격 가능 여부, 이동 속도 제어)까지 `Animator` 파라미터와 `StateMachineBehaviour`에 의존하면 애니메이션 전환 지연(Transition Duration) 때문에 조작감과 판정이 어긋나기 쉬우므로, 게임 논리 상태는 코드 FSM이 소유하고 `Animator`는 그 상태를 시각적으로 표현만 하게 분리하는 것이 좋습니다.

</details>

**Q3. 오늘 작성한 상태 패턴에서 힙 할당이 일어난 지점은 어디이고 어떻게 막았는가?**
<details><summary>모범 답안</summary>
`StatePatternCharacterFsm` 생성 시 5개의 상태 객체와 로그용 `StringBuilder`를 힙에 한 번 할당했습니다. 전이(`ChangeState`)할 때마다 `new JumpState()`를 만들지 않고 미리 생성해 둔 상태 인스턴스 참조를 재사용했기 때문에, 프레임 루프 중 상태 전이로 인한 힙 할당은 0바이트입니다.

</details>
