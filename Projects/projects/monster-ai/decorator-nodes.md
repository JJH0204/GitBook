# 데코레이터 노드: Inverter, Repeater, Until, Cooldown, Delay

## 무엇을 하는가

데코레이터(Decorator)는 자식을 정확히 하나 갖고, 그 자식의 실행 여부나 결과를 바꾼다. 부모는 `BTDecorator`(추상)이고, 구현은 다음과 같다.

| 노드 | 하는 일 | 반환 규칙 (코드 기준) |
| --- | --- | --- |
| `BTInverter` | 자식 결과를 뒤집는다 | Success ↔ Failure, Running은 그대로 Running |
| `BTRepeater` | 자식을 Tick마다 한 번씩, 정해진 횟수까지 반복 평가한다 | 자식이 `chaseState`와 같은 상태를 반환하면 Success, 아니면 Running. 횟수를 넘으면 Failure |
| `BTUntilSuccess` | 자식이 Success일 때까지 반복한다 | 자식이 Success면 Success, 그 외는 Running |
| `BTUntilFailure` | 자식이 Failure일 때까지 반복한다 | 자식이 Failure면 Failure, 그 외는 Running |
| `BTCooldown` | 한 번 실행하면 `cooldownTime`초 동안 자식을 실행하지 않는다 | 쿨타임 중이면 Failure, 아니면 자식 결과 |
| `BTDelay` | `delayTime`초가 지난 뒤에 자식을 실행한다 | 대기 중 Running, 이후 자식 결과 |

## 왜 이렇게 설계했나

* **데코레이터로 "시간"을 노드에 넣었다.** 2025-08-05 커밋에서 `Time/` 폴더의 `BTCooldown`, `BTDelay`가 데코레이터로 처음 등장한다. 행동 코드를 건드리지 않고 에디터에서 "이 공격은 3초에 한 번"을 조립할 수 있다는 점이 노드 기반 설계의 장점이다. 이후 2025-08-14의 구조 개편에서 스킬별 쿨타임은 블랙보드(`ApplyCooldown`, `IsSkillReady`)로도 관리되며, 둘이 공존한다([리프 노드](leaf-nodes.md)의 `BTIsCooldown`).
* **자식이 하나인 이유.** 에디터에서 데코레이터는 출력 포트가 하나다. 데이터 모델도 `BTNode child` 한 칸뿐이라, 연결 로직이 컴포짓보다 단순하다.
* **반복류는 "Running으로 반복을 표현"한다.** Repeater/UntilSuccess/UntilFailure는 내부 루프(`while`)를 돌지 않는다. 한 Tick에 자식을 한 번 평가하고 `Running`을 반환해, 다음 Tick에도 다시 호출되게 한다. 한 프레임에 AI가 무한히 도는 것을 막고, 프레임 단위로 반복이 진행된다.

## 핵심 코드 발췌

{% code title="Nodes/Decorator/BTDecorator.cs, BTInverter.cs" %}
```csharp
public abstract class BTDecorator : BTNode
{
    [SerializeField] public BTNode child;

    public override void OnValidateNode()
    {
        if (child != null)
            child.input = this;
    }
}

public class BTInverter : BTDecorator
{
    public override NodeState Evaluate(NodeContext context, HashSet<BTNode> visited)
    {
        if (CheckCycle(visited))
            return NodeState.Failure;

        var nodeState = child.Evaluate(context, visited);

        if (nodeState == NodeState.Failure)
            state = NodeState.Success;
        else if (nodeState == NodeState.Success)
            state = NodeState.Failure;
        else
            state = NodeState.Running;

        return state;
    }
}
```
{% endcode %}

* `child` 한 칸과 `OnValidateNode`(자식의 `input`을 자신으로)가 데코레이터의 전부다.
* Inverter는 세 갈래 `if`로 상태를 바꾼다. Running을 그대로 통과시키는 것이 핵심이다.
* `child`가 `null`이면 `child.Evaluate`에서 예외가 난다. 같은 폴더의 `BTCooldown`만 `null` 검사를 한다.

{% code title="Nodes/Decorator/BTRepeater.cs" %}
```csharp
public class BTRepeater : BTDecorator
{
    public int currentCount = 0;
    public int repeatCount;
    public NodeState chaseState;

    public override NodeState Evaluate(NodeContext context, HashSet<BTNode> visited)
    {
        if (CheckCycle(visited))
            return NodeState.Failure;

        // 반복 횟수가 지정된 횟수 이상이 된 경우> 실패 반환
        if (currentCount >= repeatCount)
            return state = NodeState.Failure;

        var nodeState = child.Evaluate(context, visited);
        currentCount++;

        // 종료 조건으로 설정한 Node 상태와 같으면 성공 반환
        if (nodeState == chaseState)
            return state = NodeState.Success;

        state = NodeState.Running;
        return state;
    }
}
```
{% endcode %}

* `repeatCount`: 최대 평가 횟수. `currentCount`가 이를 넘으면 더는 자식을 평가하지 않고 Failure.
* `chaseState`: "이 상태가 나오면 성공으로 끝낸다"는 종료 조건. 이름은 `chase`지만 추적과 무관하게 보이며(코드 읽기), 의미상 "종료 상태" 정도로 읽는다.
* `currentCount`는 `public` 필드이고 어디에서도 0으로 되돌리지 않는다. 한 번 횟수를 다 채우면 이후 모든 Tick에서 Failure다(코드 읽기, unverified). 또한 노드가 에셋이므로 몬스터들이 카운터를 공유한다.

{% code title="Nodes/Decorator/Time/BTCooldown.cs" %}
```csharp
public class BTCooldown : BTDecorator
{
    public float cooldownTime;
    private float _lastExecuted;

    public override NodeState Evaluate(NodeContext context, HashSet<BTNode> visited)
    {
        if (CheckCycle(visited))
            return NodeState.Failure;

        // 쿨타임과 시간 경과를 비교해서 쿨타임 중인 경우 자식 실행 x
        if (Time.time - _lastExecuted < cooldownTime)
            return state = NodeState.Failure;

        if (child == null)
        {
            Debug.LogError("Child node is not set for BTCooldown.");
            return NodeState.Failure;
        }

        var nodeState = child.Evaluate(context, visited);

        // 자식 노드의 실행이 끝나면 현재 시간을 저장
        if (nodeState != NodeState.Running)
            _lastExecuted = Time.time;

        return state = nodeState;
    }
}
```
{% endcode %}

* 쿨타임 판정은 `Time.time - _lastExecuted < cooldownTime`. `_lastExecuted`의 초기값이 0이므로 게임 시작 후 `cooldownTime`초 동안은 첫 실행도 막힌다.
* 쿨타임을 기록하는 시점은 "자식이 Running이 아닐 때"다. 즉 자식이 Success든 Failure든 끝나는 순간부터 쿨타임이 시작된다. 자식이 실패했을 때도 쿨타임이 걸리는 것이 의도인지는 코드만으로 알 수 없다.
* `_lastExecuted`는 `private`이라 직렬화되지 않는다. 노드 에셋을 공유하는 몬스터 전부가 같은 값을 본다.

{% code title="Nodes/Decorator/Time/BTDelay.cs" %}
```csharp
public class BTDelay : BTDecorator
{
    public float delayTime;
    private float _startTime;
    private bool _isDelaying;
    private bool _isStarted;

    public override void OnEnter()
    {
        _startTime = Time.time; // 시작 노드를 언제 어떻게 초기화 하지??
        _isDelaying = true;
    }

    public override NodeState Evaluate(NodeContext context, HashSet<BTNode> visited)
    {
        if (CheckCycle(visited))
            return NodeState.Failure;

        if (!_isStarted)
        {
            OnEnter();
            _isStarted = true;
        }

        if (_isDelaying)
        {
            if (Time.time - _startTime >= delayTime)
                _isDelaying = false;
            else
                return state = NodeState.Running;
        }

        if (child is null)
            return NodeState.Success;

        return state = child.Evaluate(context, visited);
    }
}
```
{% endcode %}

* 첫 `Evaluate`에서 `OnEnter()`로 시작 시각을 잡고 `_isStarted`를 켠다.
* `_isDelaying` 동안은 Running. 시간이 차면 한 번 `_isDelaying`을 끄고 이후에는 자식을 그대로 평가한다.
* 코드 안 주석("시작 노드를 언제 어떻게 초기화 하지??")이 저자가 알고 있던 약점을 보여 준다. `_isStarted`/`_isDelaying`을 다시 켜는 코드가 없으므로, 지연은 "에셋이 로드된 뒤 처음 한 번"만 적용되고 이후에는 사라진다(코드 읽기, unverified). 매번 지연을 주려면 자식 종료 시 `_isStarted = false`로 되돌리는 로직이 필요하다.

`BTUntilSuccess`/`BTUntilFailure`는 구조가 같다. 자식을 평가해 목표 상태면 그 상태를 반환하고, 아니면 Running을 반환한다.

## 따라 만들기: 데코레이터

[컴포짓 노드](composite-nodes.md)의 `BTDebugLeaf`(결과를 인스펙터에서 정하는 테스트 노드)가 있다고 가정한다.

1. **`BTDecorator` 추상 클래스를 만든다.** `child`와 `OnValidateNode`를 넣는다.

   확인 방법: 컴파일 에러가 없다.

2. **`BTInverter`를 만든다.** 위 발췌 그대로, 단 `child == null`이면 Failure를 반환하는 검사를 추가한다.

   확인 방법: `Inverter → DebugLeaf(Success)`가 Failure를, `DebugLeaf(Failure)`가 Success를, `DebugLeaf(Running)`이 Running을 반환한다.

3. **`BTUntilSuccess`, `BTUntilFailure`를 만든다.**

   확인 방법: `UntilSuccess → DebugLeaf(Failure)`는 매 Tick Running이다. Play 중 리프를 Success로 바꾸면 다음 Tick부터 Success가 반환된다.

4. **`BTRepeater`를 만든다.** 학습 단계에서는 원본처럼 `repeatCount`, `chaseState`를 둔다. 카운터 초기화가 필요하면 `Success`/`Failure` 반환 시점에 `currentCount = 0`을 넣는다(원본에는 없는 개선).

   확인 방법: `repeatCount = 3`, 자식 Running이면 처음 3번은 Running, 4번째부터 Failure다.

5. **`BTCooldown`을 만든다.** 위 발췌 그대로.

   확인 방법: `cooldownTime = 2`, 자식이 로그를 찍고 Success를 반환하게 하고 Play한다. 로그가 2초에 한 번만 찍힌다. 시작 후 첫 2초는 로그가 없다는 점도 확인한다.

6. **`BTDelay`를 만든다.** 위 발췌 그대로.

   확인 방법: `delayTime = 1.5`로 하고 Play하면 자식 로그가 1.5초 뒤에 시작된다. 그 후에는 지연 없이 매 Tick 평가된다(원본 동작).

7. **조합을 만든다.** `Sequence[IsInRange, Cooldown(3s)[Attack]]`처럼 조건 + 쿨타임 + 행동을 조립한다.

   확인 방법: 범위 안에 있는 동안 공격 로그가 3초 간격으로 찍힌다.

## 막히기 쉬운 곳, 한계

* **노드 에셋 공유로 인한 상태 공유.** `BTCooldown`, `BTDelay`, `BTRepeater`의 내부 상태는 노드 에셋에 저장된다. 여러 몬스터가 같은 트리를 쓰면 서로의 쿨타임을 소비한다. 해결하려면 상태를 `NodeContext`/블랙보드에 두거나, 트리를 몬스터마다 `Instantiate`해야 한다. 원본은 그렇게 하지 않는다.
* **Repeater/Delay의 초기화 부재.** 위에서 짚은 대로 되돌리는 코드가 없다.
* **`BTCooldown`은 Failure를 반환한다.** 쿨타임 중에는 Failure를 반환하므로, 부모가 Selector일 때 다음 대안으로 넘어가는 용도로 자연스럽다. 반대로 부모가 Sequence이면 시퀀스 전체가 실패한다.
* **설정 UI와의 연동.** 설정 패널이 값 필드를 제공하는 데코레이터는 `BTCooldown`(`Cooldown Time`)과 `BTDelay`(`Delay Time`)뿐이다. `BTRepeater.repeatCount`/`chaseState`는 패널에 필드가 없어 기본 인스펙터에서 고쳐야 한다([그래프 에디터 (2)](graph-editor-2.md)).

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] Inverter를 실제로 쓰고 싶은 AI 장면을 하나 정하고, 트리를 글로 적어 본다.
- [ ] 쿨타임을 "데코레이터 노드"로 만드는 방식과 "블랙보드에서 스킬별로 관리"하는 방식의 차이를 내 말로 설명한다.
- [ ] 같은 노드 에셋을 여러 몬스터가 공유할 때 생기는 문제를 직접 재현해 봤다면 어떻게 재현했는지 적는다.
