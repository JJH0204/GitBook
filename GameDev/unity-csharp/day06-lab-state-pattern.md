# Day 06 · [실습] 상태 패턴

> 1주차 C# 메모리 · 60분 · 준비물: .NET SDK (`dotnet new console -o practice/day06`)

## 오늘의 목표
- `enum + switch` 유한 상태 기계(`FSM, Finite State Machine`)의 한계와 상태 패턴(`State pattern`)의 차이를 설명할 수 있다.
- 상태 객체를 전이마다 `new`로 만들지 않고 미리 만들어 재사용해 무할당(`0 B`) FSM을 구현할 수 있다.
- 동일한 전이 규칙을 `enum + switch`와 상태 패턴 두 방식으로 구현하고 출력이 100% 일치함을 검증할 수 있다.

---

## 1. 설계 읽기 (10분)

### 1-1. `enum + switch` vs 상태 패턴(`State pattern`)

캐릭터가 `Idle`, `Run`, `Jump`, `Attack`, `Hit` 5개 상태를 가질 때 가장 먼저 떠올리는 코드는 `enum`과 `switch`다.

| 항목 | `enum + switch` | 상태 패턴 (`ICharacterState`) |
|---|---|---|
| 구조 | 상태 값 하나 + 메서드(`Update`, `Transition`)마다 큰 `switch`문 | 상태별 클래스가 `Enter` / `Update` / `Exit`를 한곳에 캡슐화 |
| 상태 추가 시 | 모든 `switch`문을 찾아 케이스를 추가해야 함 | 새 상태 클래스 하나 추가 |
| 진입·퇴장 처리 | 전이하는 곳마다 이전 상태 정리·다음 상태 초기화를 챙겨야 해 흩어지기 쉬움 | `ChangeState`가 항상 `old.Exit()` → `new.Enter()`를 보장 |
| 메모리 주의점 | 값(`enum`)만 바꾸므로 할당 없음 | 전이할 때마다 **`new JumpState()`를 호출하면 프레임마다 가비지 발생** → **초기화 때 1번만 생성해 캐시·재사용**해야 함 |

### 1-2. 전이(`Transition`)는 누가 결정하는가

상태 패턴에서 전이 조건을 두는 위치는 두 가지 방식이 있다.
1. **각 상태 객체가 결정**: `IdleState`가 입력을 보고 `ctx.ChangeState(ctx.Run)`을 호출한다. 상태별 규칙이 그 클래스 안에 응집된다.
2. **컨텍스트(또는 전이 테이블)가 결정**: 피격(`Hit`)처럼 **모든 상태에서 공통으로 끼어드는 최우선 전이**는 컨텍스트(`ChangeState` 호출부)에서 먼저 처리하고, 일반 전이는 각 상태에 위임하면 중복이 줄어든다.

---

## 2. 구현 (45분)

> AI, 자동완성, 검색 없이. 아래 명세만 보고 직접 작성한다.

### 요구사항

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

### 테스트 시나리오와 예상 출력

입력 문자열 `".rrj.a.ah.."` (총 11프레임: 5번 프레임의 `'a'`는 점프 중이라 무시되고, 7번 프레임의 `Attack`은 8번 프레임의 `'h'`에 끊긴다):

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

### 확장 과제 (시간이 남을 때)

1. **계층형 상태(`Hierarchical FSM`)**: `Idle`과 `Run`의 공통 전이(`'j'` → `Jump`, `'a'` → `Attack`)를 상위 상태 `GroundedState`로 묶어 중복을 제거한다.
2. **전이 이력 링버퍼**: 최근 8번의 상태 전이를 `(frame, from, to)` struct 배열(`new` 없이 고정 크기 순환 버퍼)에 기록해 시뮬레이션 끝에 출력한다.
3. **Unity 이식 🎮**: `Update()`에서 키보드 입력(`Input.GetKey`)을 위 문자(`'r'`, `'j'`, `'a'`, `'h'`, `'.'`)로 변환해 `StatePatternCharacterFsm`을 구동한다.

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

---

## 3. 회고 (5분)

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

---

## 오늘의 한 줄
> (내 말로 한 문장)

## 더 보기
- [Game Programming Patterns — State 장 (Robert Nystrom)](https://gameprogrammingpatterns.com/state.html)
- [패턴 일치 — switch 식 (C# 참조)](https://learn.microsoft.com/ko-kr/dotnet/csharp/language-reference/operators/switch-expression)
- [Unity 매뉴얼 — 애니메이터 컨트롤러와 상태 머신](https://docs.unity3d.com/Manual/StateMachineBasics.html)
