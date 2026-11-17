# 몬스터 AI 실험 해체

## 무엇을 하는가

몬스터가 "지금 무엇을 할지"를 State와 Action, 우선순위 큐로 고르는 초기 실험이다. State가 후보 행동을 큐에 제안하고, AI가 가장 우선순위가 높은 행동 하나를 꺼내 코루틴으로 실행한다. 직접 만든 [우선순위 큐](priority-queue.md)가 쓰이는 유일한 곳이다.

{% hint style="warning" %}
동작 판단은 코드를 읽은 결과이며 Unity에서 실행해 확인하지 않았다(unverified).
{% endhint %}

## 왜 이렇게 설계했나

코드와 주석에서 읽히는 의도는 다음과 같다.

- **State는 "후보 제안자", AI는 "실행자"로 나눴다.** `State`는 `OnEnter/OnUpdate/OnExit`만 가지며, `OnUpdate`에서 `AI.AddAction(...)`으로 후보를 낸다. 행동 실행은 `AI`가 맡는다.
- **우선순위로 충돌을 해결하려 했다.** 한 프레임에 여러 후보가 나와도 큐가 하나를 고른다. `Idle` 상태가 우선순위 2, 1, 3인 Idle 행동 세 개를 넣는 코드는 정렬이 되는지 시험하는 용도로 읽힌다(추정).
- **행동 종류를 enum으로 고정했다.** `ActionType`: Spawn, Idle, Attack, Evasion, Patrol, Chase, Hit, Death 8종.
- **이전 방식의 흔적이 `History/`에 있다.** `MonsterBase.cs`는 상태별 `switch`를 쓰던 구현이며 전체가 주석이다. 주석에 "Hit 1순위, Dead 0순위, Spawn 6순위"처럼 상태마다 우선순위가 적혀 있어, 이 우선순위 개념을 큐로 옮기려 한 것으로 보인다(추정).

## 핵심 코드 발췌

{% code title="AI.cs" %}
```csharp
public abstract class AI : MonoBehaviour
{
    private State _currentState;
    private PriorityQueue<Action> _actionQueue = PriorityQueue<Action>.CreateMinPriorityQueue();
    private Action _currentAction;
    private bool _isActing;

    private void Update()
    {
        _actionQueue.Clear();
        _currentState.OnUpdate();

        if (_isActing || _actionQueue.Count <= 0) return;

        _currentAction = _actionQueue.Dequeue();
        ExecuteAction(_currentAction);
    }

    public void ChangeState(State newState)
    {
        _currentState?.OnExit();
        _currentState = newState;
        _currentState.OnEnter();
    }

    public void AddAction(Action action)
    {
        _actionQueue.Enqueue(action, -action.Priority);
    }
}
```
{% endcode %}

줄 단위 설명은 다음과 같다.

- 큐는 최소 힙이다. `AddAction`에서 `-action.Priority`를 넣으므로 `Priority`가 큰 행동이 먼저 나온다. 예를 들어 우선순위 2, 1, 3이 들어오면 3이 나온다.
- `Update`가 **매 프레임 큐를 비운다.** 그 뒤 현재 State가 후보를 새로 채운다. 큐는 프레임을 넘어 남지 않는다.
- `_isActing`이 true이면 이번 프레임에 넣은 후보는 꺼내지 않고 다음 프레임에 비워진다. 즉 행동 중에는 새 후보가 모두 버려진다(선점 없음).
- `ChangeState`는 이전 State의 `OnExit`, 새 State의 `OnEnter` 순서로 호출한다.
- `Action.cs`의 생성자 주석은 "우선순위를 액션이 가지지 않고 관리하는 Heap에서 관리한다"인데, 실제 코드는 `Action.Priority`를 가지고 있고 큐에 넣을 때 그 값을 부정해서 쓴다. 주석과 코드가 어긋난다.

{% code title="Spawn.cs / NormalAI.cs" %}
```csharp
// Spawn.cs
public override void OnUpdate()
{
    Debug.Log("is Spawn");
    AI.AddAction(new Action(ActionType.Spawn, 1, null));
}

// NormalAI.cs
private void Start() { ChangeState(new Spawn(this)); }

protected override IEnumerator SpawnCoroutine()
{
    yield return new WaitForSeconds(2.0f);
    ChangeState(new Idle(this));
    IsActing = false;
}

protected override IEnumerator AttackCoroutine()
{
    yield break;
}
```
{% endcode %}

- 시작하면 `Spawn` 상태로 들어가 매 프레임 Spawn 행동을 제안한다. 첫 프레임에 꺼내 실행하고, 2초 뒤 `Idle` 상태로 바꾸고 `IsActing`을 풀어 다음 행동을 받는다.
- `Idle` 상태는 매 프레임 Idle 행동 3개(우선순위 2, 1, 3)를 넣고, 그중 3이 선택된다. 로그의 `Priority: 3`으로 큐 동작을 눈으로 확인하는 구조다.
- `Attack`을 포함한 나머지 코루틴은 `yield break;`뿐이며 `IsActing = false`를 하지 않는다. 아래 "한계"에서 다룬다.

## 따라 만들기 단계

[우선순위 큐](priority-queue.md)를 먼저 만들어 둔 상태에서 시작한다. 아래 코드는 레포의 전체 코드를 줄여서 옮기는 순서이며, 동작 확인은 직접 실행해서 해야 한다.

1. **`ActionType`과 `Action` 만들기.** enum 8종과, `Type`, `Priority`, `Target`(GameObject)을 읽기 전용으로 가진 클래스를 만든다. 클래스 이름이 `System.Action`과 겹치므로 `using System;`을 같은 파일에 넣지 않는다.
   - 확인 방법: 컴파일 통과.
2. **`State` 추상 클래스.** `AI`를 보관하는 생성자와 추상 메서드 `OnEnter/OnUpdate/OnExit`를 만든다.
   - 확인 방법: 컴파일 통과.
3. **`AI` 뼈대.** `MonoBehaviour`를 상속한 추상 클래스에 `_currentState`, `_actionQueue`, `_isActing`, `ChangeState`, `AddAction`을 만든다. `AddAction`은 `Enqueue(action, -action.Priority)`로 쓴다.
   - 확인 방법: 컴파일 통과.
4. **`Update`와 `ExecuteAction`.** 큐 비우기 → `OnUpdate` → 행동 중이면 반환 → `Dequeue` → `switch`로 코루틴 시작 순으로 쓴다. 코루틴 8개는 추상 메서드로 선언한다.
   - 확인 방법: 컴파일 통과(자식 클래스가 없어 아직 실행 불가).
5. **`NormalAI` 만들기.** 코루틴 8개를 구현하되 `Spawn`, `Idle` 외에는 `yield break;`만 둔다. `Start`에서 `ChangeState(new Spawn(this))`를 호출한다. 단, 이 레포와 달리 빈 코루틴에도 `IsActing = false;`를 넣어 두는 것을 권한다(한계 절 참고).
   - 확인 방법: 컴파일 통과.
6. **`Spawn`과 `Idle` State.** `Spawn`은 Spawn 행동(우선순위 1)을, `Idle`은 Idle 행동 3개(우선순위 2, 1, 3)를 `OnUpdate`에서 제안한다.
   - 확인 방법: 컴파일 통과.
7. **씬에 연결.** 빈 GameObject를 만들고 `NormalAI`를 붙인다.
   - 확인 방법: 플레이하면 콘솔에 `Spawn State Enter`가 한 번 나오고, `is Spawn`이 반복된 뒤 약 2초 후 `Spawn State Exit`, `Idle State Enter`가 나온다.
8. **우선순위 확인.** Idle 단계에서 콘솔을 본다.
   - 확인 방법: `Executing Action: Idle with Priority: 3`이 나오고, 약 2초 뒤 `Is Idle...`이 찍힌 다음 같은 로그가 반복된다. `Priority: 1`이나 `2`가 나오면 부호 처리를 점검한다.

## 막히기 쉬운 곳

- **`NullReferenceException`.** `Update`는 `_currentState`가 null인지 검사하지 않는다. State를 설정하기 전에 `Update`가 돌면 예외가 난다. 레포는 `Start`에서 설정하므로 문제가 없으나, 새 AI 클래스에서 `Start`를 빼먹으면 바로 난다.
- **우선순위 방향.** `AddAction`이 부정해서 넣는다. 큰 값이 먼저라는 점을 헷갈리면 거꾸로 동작한다. `History/MonsterBase.cs` 주석은 반대로 숫자가 작을수록(0순위=Dead) 높은 우선순위로 적혀 있어 두 규칙이 섞이기 쉽다.
- **로그 폭주.** `Spawn.OnUpdate`가 매 프레임 `Debug.Log("is Spawn")`을 찍는다.

## 이 설계의 한계

코드에서 직접 읽히는 것과 추정을 구분해 적는다.

**코드에서 읽히는 것**

1. **큐가 상태를 담지 못한다.** 매 프레임 비우고 다시 채우므로, 큐는 "이번 프레임 후보 중 최댓값 고르기"만 한다. 이 용도라면 최댓값 하나만 기억하는 변수로도 같은 결과가 나온다. 힙의 장점(많은 후보를 쌓아 두고 순서대로 꺼내기)이 쓰이지 않는다. 안정성이 없다는 점([우선순위 큐](priority-queue.md))도 같은 우선순위 후보 사이에서는 결과가 정해지지 않는 문제로 이어진다.
2. **선점이 없다.** `_isActing` 중에는 새 후보를 받지 않는다. 공격 중에 `Hit`이나 `Death`가 와도 끼어들 수 없다. 우선순위가 높아도 이미 시작한 행동은 못 끊는다.
3. **빈 코루틴이 AI를 멈춘다(버그 후보).** `Spawn`, `Idle` 이외 코루틴은 `yield break;`만 하고 `IsActing = false`를 하지 않는다. 이 행동이 한 번이라도 선택되면 `_isActing`이 영원히 true가 되어 이후 아무 행동도 선택되지 않는다. 현재 State가 만드는 행동은 Spawn과 Idle뿐이라 아직 드러나지 않는다.
4. **행동 종료 책임이 코루틴마다 흩어져 있다.** `IsActing`을 풀고 State를 바꾸는 일이 각 코루틴 안에 있다. 행동이 8종으로 늘면 빠뜨리기 쉽다(위 3번이 그 예).
5. **State 전환 조건이 코루틴 안에 있다.** `SpawnCoroutine`이 끝에 `ChangeState(new Idle(this))`를 호출한다. 전환 규칙을 한눈에 볼 곳이 없다.
6. **State마다 클래스가 하나씩 필요하다.** 새 State가 늘 때마다 파일이 생긴다.
7. **구현이 빈약하다.** 8종 중 6종은 빈 코루틴이며 `Target`은 쓰이지 않는다(`null`만 전달). 공격, 추적 같은 판단 로직(거리, 시야)이 이 구조에 아직 들어가지 않았다.

**BT로 넘어간 이유(추정)**

- 위 2번과 4~5번 문제, 즉 "조건에 따라 행동을 끊고 갈아타는 흐름"과 "전환 규칙을 한곳에서 보는 것"을 해결하려고 Behavior Tree를 택했을 가능성이 있다. BT는 매 틱마다 루트부터 조건을 평가해 우선순위가 높은 가지가 낮은 가지를 끊을 수 있기 때문이다.
- 다만 레포에 이를 직접 적은 기록(README, 커밋 메시지)이 없다. 레포에는 실질 커밋이 1개뿐이고 메시지도 `First Commit`이다. 실제 이유는 [MonsterAI 문서](../monster-ai/README.md)와 본인의 기억으로 확인해야 한다.

## 주변 파일의 버그 후보

- `MonsterPatrol.GenIndex()`: 뽑은 값이 현재 `_index`와 같으면 `++_index`를 반환한다. 현재 값이 마지막 인덱스일 때 이 분기가 걸리면 `patrolPoints.Count`가 되어 `Patrol()`의 `patrolPoints[_index]`에서 범위 오류가 난다(래핑 없음). 이 클래스는 어디에서도 호출되지 않는다.
- `MonsterPatrol.cs`의 `using UnityEngine.UIElements;`는 쓰이지 않는다. `Random`이 `UnityEngine.Random`으로 해석되는지는 컴파일해 확인하지 않았다(확인 필요).
- `MonsterBase.cs`는 `using Old_monster;`를 자기 네임스페이스 안에서 다시 선언한다. 전체가 주석이라 동작에는 영향이 없다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 이 구조에서 우선순위 큐를 매 프레임 비우는 이유를 내 말로 설명하고, 그 선택의 장단점을 적어 본다.
- [ ] 직접 몬스터 AI를 만들면서 "행동 중에 더 급한 일이 생기는" 상황을 겪었는가? 어떻게 처리했는가?
- [ ] State 기반 설계에서 Behavior Tree로 옮기면서 무엇이 가장 달라졌다고 느꼈는가?
