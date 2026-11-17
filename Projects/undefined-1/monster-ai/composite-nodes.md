# 컴포짓 노드: Selector, Sequence, Parallel

## 무엇을 하는가

컴포짓(Composite) 노드는 자식을 여러 개 갖고, 자식들을 어떤 순서와 규칙으로 평가할지 정한다. 이 레포에는 공통 부모 `BTComposite`와 세 구현이 있다.

| 노드 | 규칙 | 반환 |
| --- | --- | --- |
| `BTSelector` | 자식을 왼쪽부터 평가한다. 처음으로 Success 또는 Running이 나오면 거기서 멈춘다 | Success/Running이 나온 자식의 상태를 그대로 반환. 전부 Failure면 Failure |
| `BTSequence` | 자식을 왼쪽부터 평가한다. 처음으로 Failure 또는 Running이 나오면 거기서 멈춘다 | 전부 Success면 Success. Failure/Running이 나오면 그 상태 |
| `BTParallel` | 모든 자식을 한 번씩 평가한다. 결과는 보지 않는다 | 항상 Success |

흔한 읽는 법: Selector는 "OR(대안을 순서대로 시도)", Sequence는 "AND(조건과 행동을 순서대로 이어 붙임)"다.

## 왜 이렇게 설계했나

* **부모 클래스 `BTComposite`.** `children` 리스트와 `OnValidateNode`(자식의 `input`을 자신으로 맞추기)를 한곳에 둔다. 그래프 에디터는 노드가 컴포짓인지 아닌지만 보고 출력 포트를 여러 개 만든다([그래프 에디터 (1)](graph-editor.md)).
* **자식 순서가 곧 우선순위.** 리스트 앞쪽 자식이 먼저 평가되므로, 에디터의 `Out 1, Out 2, ...` 포트 번호가 곧 우선순위다. 예를 들어 `Selector[ 사망 체크, 전투, 순찰, 대기 ]`처럼 위에서 아래로 중요도 순서로 놓는다.
* **상태를 기억하지 않는 구조.** 컴포짓은 "어느 자식이 Running이었는지"를 저장하지 않는다. 매 Tick마다 항상 첫 자식부터 다시 평가한다. 구현이 단순하고, 높은 우선순위 조건(예: 사망)이 매 프레임 낮은 우선순위 행동을 끊고 들어올 수 있다는 장점이 있다. 대가는 아래 "실행 중 노드 재개 방식"에서 설명한다.
* **`Parallel`이 사실상 "모두 실행"인 이유.** 소스의 주석은 "성공 여부는 별도로 지정"이라고 적지만 그 설정은 구현되어 있지 않다. 이 시스템에서 액션은 큐에 명령을 넣는 일이라 "동시에 여러 개 넣기"가 필요했던 것으로 보이나, 이는 코드로 확인되는 의도가 아니라 추측이므로 확신하지 않는다.

## 핵심 코드 발췌

{% code title="Nodes/Composite/BTSelector.cs" %}
```csharp
public class BTSelector : BTComposite
{
    public override NodeState Evaluate(NodeContext context, HashSet<BTNode> visited)
    {
        if (CheckCycle(visited))
            return NodeState.Failure;

        foreach (var child in children)
        {
            var childState = child.Evaluate(context, visited);
            if (childState == NodeState.Success)
            {
                state = NodeState.Success;
                return state;
            }
            if (childState == NodeState.Running)
            {
                state = NodeState.Running;
                return state;
            }
        }
        state = NodeState.Failure;
        return state;
    }
}
```
{% endcode %}

* `CheckCycle(visited)`: 순환이면 Failure로 끊는다.
* `foreach`: `children` 순서대로 평가한다. 자식이 `null`이면 `child.Evaluate`에서 `NullReferenceException`이 난다(에디터가 빈 포트 자리를 `null`로 남기기 때문, [그래프 에디터 (2)](graph-editor-2.md) 참고).
* Success면 즉시 반환: "하나만 성공하면 된다".
* Running이어도 즉시 반환: 진행 중인 자식이 있으면 뒤의 대안은 시도하지 않는다.
* 끝까지 못 찾으면 Failure.

{% code title="Nodes/Composite/BTSequence.cs" %}
```csharp
public class BTSequence : BTComposite
{
    public override NodeState Evaluate(NodeContext context, HashSet<BTNode> visited)
    {
        if (CheckCycle(visited))
            return NodeState.Failure;

        foreach (var child in children)
        {
            var childState = child.Evaluate(context, visited);
            if (childState == NodeState.Failure)
            {
                state = NodeState.Failure;
                return state;
            }
            if (childState == NodeState.Running)
            {
                state = NodeState.Running;
                return state;
            }
        }
        state = NodeState.Success;
        return state;
    }
}
```
{% endcode %}

* Selector와 대칭이다. 종료 조건이 Success 대신 Failure로 바뀌었을 뿐이다.
* 끝까지 아무 일도 없었다면(모든 자식이 Success) Success.
* 자식이 하나도 없으면 반복문이 돌지 않아 Success다. 반대로 Selector는 자식이 없으면 Failure다.

{% code title="Nodes/Composite/BTParallel.cs" %}
```csharp
public class BTParallel : BTComposite
{
    public override NodeState Evaluate(NodeContext context, HashSet<BTNode> visited)
    {
        if (CheckCycle(visited))
            return NodeState.Failure;
        // 모든 자식 노드를 실행만 함
        foreach (var child in children)
        {
            child.Evaluate(context, visited);
        }

        // 실행 즉시 성공 반환
        return state = NodeState.Success;
    }
}
```
{% endcode %}

* 자식의 반환값을 버린다. 자식이 Failure여도, Running이어도 Parallel은 Success다.
* 따라서 일반적인 BT의 Parallel("모두 성공해야 성공" 등의 정책)과는 다르다. 정책을 넣으려면 반환값을 집계해야 한다.

## 실행 중 노드 재개 방식

이 구현에서 "재개(resume)"는 별도 로직이 아니라 "처음부터 다시 평가"다.

```
Tick N  : Selector → [IsDeath → Failure] → [Chase → Success(명령 enqueue)]  → 종료
Tick N+1: Selector → [IsDeath → Failure] → [Chase → Success(명령 enqueue)]  → 종료
```

* Running을 반환한 자식이 있어도 다음 Tick에 컴포짓은 첫 자식부터 다시 돈다. 이전에 Running이던 노드는 그 노드가 여전히 앞선 조건들을 통과할 때에만 다시 평가된다.
* 그래서 `Sequence[조건, 액션]` 구조는 매 프레임 조건을 다시 확인한다. 조건이 거짓이 되면 액션은 자연스럽게 끊긴다(반응형).
* 반대로 `Sequence[액션A, 액션B]`에서 A가 Success를 반환하면 다음 Tick에도 A부터 다시 실행된다. "A를 한 번 하고 B로 넘어가는" 순차 실행 기억은 없다. 이 시스템에서는 Cooldown/Delay 데코레이터와 블랙보드의 쿨타임이 그 역할을 대신한다([데코레이터 노드](decorator-nodes.md)).
* 실제로 Running을 반환하는 리프는 `BTActionPatrol` 하나뿐이다(읽은 범위). 나머지 액션은 명령을 큐에 넣고 즉시 Success를 반환한다.

## 따라 만들기: 컴포짓 세 개

[BT 기초](bt-basics.md)의 최소 BT가 만들어져 있다고 가정한다.

1. **`BTComposite`에 `OnValidateNode`를 넣는다.** 자식 각각의 `input`을 자신으로 설정한다. 이때 `null` 자식을 걸러 내는 `if (child != null)`을 추가한다(원본은 `null` 검사가 없어 빈 슬롯이 있으면 예외가 난다).

   확인 방법: 자식이 비어 있는 컴포짓에서 `OnValidateNode`를 호출해도 예외가 나지 않는다.

2. **테스트용 리프 `BTDebugLeaf`를 만든다.** 인스펙터에서 `NodeState result`와 `string label`을 정하게 하고, `Evaluate`에서 `Debug.Log(label)`을 찍은 뒤 `result`를 반환한다.

   확인 방법: 에셋을 3개 만들어 각각 Success/Failure/Running으로 설정할 수 있다.

3. **`BTSelector`를 구현한다.** 위 발췌를 입력한다.

   확인 방법: 자식 `[Failure, Success, Failure]`로 Tick하면 로그가 앞의 둘만 찍히고 Success가 반환된다.

4. **`BTSequence`를 구현한다.**

   확인 방법: 자식 `[Success, Failure, Success]`로 Tick하면 로그가 앞의 둘만 찍히고 Failure가 반환된다. 자식 `[Success, Running, Success]`는 Running을 반환하고 세 번째 로그가 없다.

5. **`BTParallel`을 구현한다.**

   확인 방법: 자식 `[Failure, Running, Success]`에서 세 로그가 모두 찍히고 Success가 반환된다.

6. **Running 반응성을 확인한다.** `Sequence[조건(BTDebugLeaf), 액션(Running)]`을 만들고 Play 중 조건 에셋의 `result`를 바꿔 본다.

   확인 방법: 조건이 Failure가 되는 순간 액션 로그가 멈춘다. 이것이 "재개가 아니라 재평가"임을 보여 준다.

7. **(선택) Parallel 정책을 추가한다.** 열거형 `Policy { Ignore, RequireAll, RequireOne }`을 두고 자식 반환값을 집계한다. 원본에는 없는 확장이다.

   확인 방법: `RequireAll`에서 한 자식이 Failure면 Failure가 반환된다.

## 막히기 쉬운 곳, 한계

* **`null` 자식.** 에디터는 "자식 노드 추가" 버튼으로 `children`에 `null`을 추가한다(포트 자리를 만들기 위함). 이 상태로 런타임에서 Tick하면 컴포짓이 예외를 낸다. 원본 README의 "null 노드 참조 오류"와 관련 있어 보이나, 실행해 확인하지 못했다.
* **같은 노드를 두 곳에 연결.** `visited`가 Tick 전체에서 공유되므로, 한 노드를 두 부모에 연결하면 두 번째 평가 때 "순환 참조" 에러로 Failure가 반환된다. 의도한 순환 검사가 아닌 부작용이다(코드 읽기, unverified).
* **`BTComposite`가 추상이 아니다.** 직접 인스턴스를 만들면 `Evaluate`가 에러 로그와 Failure를 낸다. 에디터의 노드 생성 팝업 목록에 `BTComposite`가 나타날 수 있다(`!IsAbstract` 필터이므로).
* **Parallel의 이름과 동작 불일치.** 이름은 병렬이지만 스레드도 코루틴도 아니다. 한 프레임 안에서 순서대로 호출하는 것이다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] Selector와 Sequence를 각각 몬스터 행동 예시 하나씩으로 설명한다(내 말로, 비유 없이).
- [ ] "Running을 기억하지 않고 매번 처음부터 평가한다"는 설계가 내 프로젝트에서 장점이 될 장면과 단점이 될 장면을 하나씩 적는다.
- [ ] 직접 만든 테스트 트리에서 예상과 다르게 동작한 것이 있었다면 무엇이었는지 적는다.
