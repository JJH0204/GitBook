# 처리 노드: Conditional, Logic, Loop

## 무엇을 하는가

처리 노드는 입력과 출력 사이에서 "언제 실행할지"를 정한다.

| 노드 | 하는 일 | 상태 |
|---|---|---|
| `Conditional` | 입력 노드 하나가 켜지는 순간 출력 노드 목록의 `Execute()`를 한 번 부른다 | 동작 |
| `Logic` | 두 노드의 상태를 And/Or로 합쳐 자신의 `IsOn`으로 제공한다 | 동작 |
| `ForLoop` | 호출되면 출력 목록을 `loopCount`번 실행한다 | 미완 |
| `WhileLoop` | 입력이 켜져 있는 동안 출력 목록을 실행한다 | 미완 |

## 왜 이렇게 설계했나

- 입력 노드와 출력 노드를 직접 연결하지 않고 `Conditional`을 사이에 둔다. 한 입력에 출력 여러 개를 달기 쉽고, 출력 노드는 조건을 몰라도 된다.
- `Conditional` 자신도 `IsOn`을 가진다(입력 상태를 따라간다). 그래서 `Conditional`의 결과를 다시 다른 `Conditional`이나 `Logic`의 입력으로 연결할 수 있다.
- `Logic`은 칸 두 개(`processes1`, `processes2`)와 연산 종류만 가진 단순한 구조다. And/Or만 있으므로 복잡한 식은 `Logic`을 이어 붙여 만든다.

## 핵심 코드 발췌

{% code title="VisualScripting/Logic/Conditional.cs" %}
```csharp
public class Conditional : ProcessBase
{
    [SerializeField] private ProcessData inputData;
    [SerializeField] private List<ProcessData> outputData;

    private bool _isRunning;

    private void Update()
    {
        IsOn = CheckInputProcessStatus(inputData);

        if (IsOn)
        {
            if (_isRunning) return;

            Execute();
            _isRunning = true;
        }
        else
        {
            _isRunning = false;
        }
    }

    public override void Execute()
    {
        foreach (var output in outputData)
            output.process.Execute();
    }
}
```
{% endcode %}

- `inputData`: 감시할 노드와 NOT 체크 한 칸. `outputData`: 실행할 노드 목록.
- `Update`: 매 프레임 입력 상태를 읽어 자기 `IsOn`에 복사한다.
- `_isRunning`: 켜진 채로 유지되는 동안 중복 실행을 막는 플래그다. 입력이 꺼졌다 다시 켜질 때만 새로 실행된다. 즉 "켜지는 순간(rising edge)"을 만든다.
- `Execute`: 출력 목록을 차례로 호출한다. 출력 목록 칸이 비어 있으면 아무 일도 없고, 칸이 `None`이면 null 참조 오류다.

{% code title="VisualScripting/Logic/Logic.cs" %}
```csharp
public enum LogicType { And, Or }

public class Logic : ProcessBase
{
    [SerializeField] private ProcessData processes1;
    [SerializeField] private LogicType logicType;
    [SerializeField] private ProcessData processes2;

    private void Update()
    {
        Execute();
    }

    public override void Execute()
    {
        var process1IsOn = CheckInputProcessStatus(processes1);
        var process2IsOn = CheckInputProcessStatus(processes2);

        switch (logicType)
        {
            case LogicType.And:
                IsOn = process1IsOn && process2IsOn;
                break;
            case LogicType.Or:
                IsOn = process1IsOn || process2IsOn;
                break;
        }
    }
}
```
{% endcode %}

- `Update`가 매 프레임 `Execute()`를 부르므로 `Logic`은 "계산 결과를 계속 갱신하는 노드"다. 출력 노드를 실행하지는 않는다.
- 결과는 `IsOn`으로만 나오므로 `Conditional`의 `inputData`에 `Logic`을 꽂아 사용한다.

## 따라 만들기

1. `Conditional.cs`를 만들고 `OnEvent`, `Activate`(없으면 [output-nodes.md](output-nodes.md)에서 먼저 만든다)를 준비한다.
   - 확인 방법: 컴파일 오류가 없다.
2. 씬에 `OnEvent` 오브젝트와 `Conditional` 오브젝트, 켤 큐브(비활성 상태)에 대응하는 `Activate` 오브젝트를 만든다.
3. `Conditional`의 Input Data > Process에 `OnEvent`를, Output Data에 요소 1개를 추가하고 `Activate`를 꽂는다. `Activate`의 Obj 칸에는 비활성 큐브를 넣는다.
   - 확인 방법: Inspector 칸이 모두 채워진다.
4. Play 상태에서 `OnEvent`의 Is On 체크박스를 직접 켠다.
   - 확인 방법: 큐브가 나타난다. 체크를 끄고 다시 켜면 `Conditional`이 다시 실행된다(이미 켜진 큐브라 변화는 없다).
5. `Logic.cs`를 만들고 `OnEvent` 두 개를 입력에 꽂아 And/Or을 바꿔 본다. `Conditional`의 입력을 `Logic`으로 바꾼다.
   - 확인 방법: And는 두 `OnEvent`의 Is On이 모두 켜졌을 때만 `Logic`의 Is On이 켜지고, Or는 하나만 켜져도 켜진다.
6. 선택: `Is Not` 체크를 켜고 반대로 동작하는지 확인한다.

## 막히기 쉬운 곳·한계

- 입력 칸을 비워 두면 `Update`에서 매 프레임 null 참조 오류가 난다.
- `Conditional`은 "켜지는 순간 한 번"만 실행한다. 이미 켜져 있는 상태로 Play를 시작한 입력도 첫 `Update`에서 켜진 것으로 감지해 실행한다.
- `Conditional`의 입력 상태가 계속 유지되면 출력이 다시 실행되지 않는다. 반복 실행하려면 입력이 꺼졌다 켜져야 한다.
- 코드 주석에 "TODO: inputData가 true일 때 한 번만 실행한다"와 같은 설명이 있다. 구현은 되어 있으나 같은 문장이 TODO로 남아 있다.
- `Logic`은 입력이 두 개로 고정이다. 3개 이상은 `Logic`을 연결해 만든다.
- `ForLoop`(미완): `Execute()`가 호출되면 출력 목록을 `loopCount`번 같은 프레임에 실행한다. 시간 간격(`delay`)은 주석 처리되어 있고, 입력 연결도 주석 처리되어 있다. 같은 프레임에 같은 출력을 여러 번 부르는 것이라, `IsOn`을 한 번 켜면 끝나는 출력 노드에는 효과가 없다.
- `WhileLoop`(미완): 입력이 켜져 있는 동안 매 프레임 `Execute()`를 부르고, `Execute()`는 출력을 실행한 뒤 `delay`만큼 기다리는 코루틴이다. 기다림이 출력 실행 뒤에 있으므로 간격을 조절하는 효과가 없고, 매 프레임 새 코루틴이 만들어진다.
- 두 Loop 노드는 에디터 메뉴가 없어 Add Component로 붙여야 한다. 수업에서는 사용하지 않는 것을 권한다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `Conditional`이 "켜지는 순간 한 번"만 실행하는 이유를 내 말로 설명해 보자. 그렇지 않았다면 어떤 문제가 생길까?
- [ ] And와 Or를 각각 사용해야 하는 기믹 예를 하나씩 떠올려 적어 보자.
- [ ] Loop를 제대로 완성한다면 어떤 입력과 어떤 옵션이 필요할지 내 생각을 적어 보자.
