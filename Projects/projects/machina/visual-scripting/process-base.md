# ProcessBase와 연결 규칙

## 무엇을 하는가

`ProcessBase`는 비주얼 스크립팅의 모든 노드가 상속하는 추상 클래스다. 노드는 "켜져 있는가(`IsOn`)"와 "실행한다(`Execute()`)" 두 가지만 노출한다. `ProcessData`는 다른 노드를 가리키면서 결과를 반전(Not)할지 정하는 구조체다. `Logic`과 `Conditional`은 이 둘을 이용해 노드를 이어 붙인다.

## 왜 이렇게 설계했나

- 입력, 처리, 출력이 모두 같은 부모를 가지므로 인스펙터에서 `ProcessBase` 타입 필드 하나로 어떤 노드든 참조할 수 있다.
- 연결 정보가 씬에 직렬화되어 있어 기획자가 코드 없이 노드를 배치하고 연결한다.
- 상태(`IsOn`)와 동작(`Execute`)을 분리했다. 입력 노드는 상태를 바꾸고, 출력 노드는 한 번 실행되면 상태로 기록한다.

## 핵심 코드

{% code title="ProcessBase.cs (주석 일부 생략)" %}
```csharp
public abstract class ProcessBase : MonoBehaviour
{
    [SerializeField] private bool isOn;
    private Coroutine _runningCoroutine;

    public bool IsOn
    {
        get => isOn;
        protected set => isOn = value;
    }

    public abstract void Execute();

    protected virtual bool CheckInputProcessStatus(ProcessData processData)
    {
        return (processData.isNot) ? !processData.process.IsOn : processData.process.IsOn;
    }

    private void OnEnable()
    {
        if (isOn) isOn = false;
        if (_runningCoroutine != null) StopCoroutine(_runningCoroutine);
    }
}
```
{% endcode %}

- `isOn`은 `[SerializeField]`라서 인스펙터에서 상태를 볼 수 있다. 디버깅할 때 어떤 노드가 켜졌는지 눈으로 확인하기 좋다.
- `IsOn`의 setter가 `protected`이므로 외부 노드가 마음대로 바꾸지 못하고, 자기 자신 또는 자식 클래스만 켠다.
- `Execute()`는 추상 메서드다. 입력 노드에서는 "이벤트를 받았을 때 호출되는 콜백", 출력 노드에서는 "연출을 실제로 수행하는 함수"로 쓰인다.
- `CheckInputProcessStatus`는 `ProcessData`를 받아 Not 적용 후의 상태를 돌려준다.
- `OnEnable`에서 `isOn`을 `false`로 되돌리고 실행 중 코루틴을 멈춘다. 오브젝트가 다시 활성화되면 노드가 초기 상태로 돌아간다. (코루틴 참조 필드를 가진 노드가 이를 실제로 쓰는지는 확인하지 못했다.)

{% code title="ProcessData.cs" %}
```csharp
[Serializable]
public struct ProcessData
{
    public ProcessBase process;
    public bool isNot;
}
```
{% endcode %}

### 노드를 이어 붙이는 Logic과 Conditional

{% code title="Conditional.cs" %}
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
        else _isRunning = false;
    }

    public override void Execute()
    {
        foreach (var output in outputData)
            output.process.Execute();
    }
}
```
{% endcode %}

- `Update`가 매 프레임 입력 노드의 상태를 읽는다(폴링).
- `_isRunning`은 상승 에지 검출이다. 입력이 `true`가 된 첫 프레임에만 `Execute()`가 호출되고, `false`로 돌아가면 다시 대기한다.
- `Execute()`는 `outputData` 목록의 노드를 순서대로 실행한다. 출력이 여러 개여도 한 `Conditional`에 모두 담는다.

`Logic`은 같은 방식으로 `processes1`과 `processes2`를 `And`/`Or`로 합쳐 자신의 `IsOn`에 쓴다. 각 입력에 `isNot`을 줄 수 있어 NAND, NOR도 만들 수 있다. `Logic` 자신도 `ProcessBase`이므로 다른 `Logic`이나 `Conditional`의 입력이 된다.

## 따라 만들기

1. 새 Unity 프로젝트에 `VisualScripting` 폴더를 만들고 `ProcessBase.cs`, `ProcessData.cs`를 위 코드대로 작성한다. 네임스페이스는 `_Project.Scripts.VisualScripting`을 쓰거나 원하는 이름으로 통일한다.
   - 확인 방법: 컴파일 오류가 없다. `ProcessBase`는 추상 클래스라 컴포넌트로 추가할 수 없는 것이 정상이다.
2. 테스트용 입력 노드 `ManualInput`(`Execute()`에서 `IsOn = true`)과 출력 노드 `LogOutput`(`Execute()`에서 `Debug.Log`)을 만든다.
   - 확인 방법: 빈 오브젝트 두 개에 각각 붙이면 인스펙터에 `Is On` 체크박스가 보인다.
3. `Conditional`을 작성해 빈 오브젝트에 붙이고 `inputData.process`에 `ManualInput`, `outputData`에 `LogOutput`을 넣는다.
   - 확인 방법: 플레이 중 `ManualInput`의 `Is On`을 직접 체크하면 `LogOutput`의 로그가 정확히 한 번 찍힌다. 체크를 끄고 다시 켜면 또 한 번 찍힌다.
4. `Logic`을 작성해 `ManualInput` 두 개를 AND로 묶고 `Conditional`의 입력을 `Logic`으로 바꾼다.
   - 확인 방법: 두 입력이 모두 켜져야 로그가 찍힌다. `isNot`을 체크하면 반대로 동작한다.
5. (선택) 에디터 메뉴를 만든다. 원본은 `[MenuItem("GameObject/VisualScripting/...")]`로 하이어라키 우클릭 메뉴에서 노드가 붙은 오브젝트를 생성하고 `Undo.RegisterCreatedObjectUndo`를 호출한다. 에디터 전용 코드는 `Editor` 폴더에 둔다.
   - 확인 방법: 하이어라키 우클릭 메뉴에 `VisualScripting` 항목이 나타난다.

## 막히기 쉬운 곳과 한계

- 폴링 구조다. 노드 수가 늘면 `Update`를 가진 `Logic`, `Conditional`이 비례해서 늘어난다. 규모가 커지면 이벤트 기반으로 바꾸는 편이 낫다. (코드 구조에서 읽은 판단이다.)
- `IsOn`이 "입력 조건 충족"과 "출력이 이미 실행됨"이라는 두 의미를 함께 가진다. 출력 노드를 다시 실행하려면 오브젝트를 껐다 켜서 `OnEnable`이 `isOn`을 초기화하게 해야 한다.
- `Execute()`가 순환 참조되면 무한 호출이 된다. 노드 연결에 순환 검사가 없다.
- 입력 참조가 비어 있으면 `NullReferenceException`이 난다. 코드에 검사가 없다.
- 노드 간 연결은 씬 단위 참조라서, 프리팹 바깥의 노드를 프리팹 안에서 참조할 수 없다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `Conditional`이 "참이 된 순간 한 번만" 실행되도록 `_isRunning`을 둔 이유를, 이 변수가 없을 때 벌어질 일로 설명해 보자.
- [ ] 입력, 처리, 출력 노드를 모두 같은 부모 클래스로 묶었을 때의 장점과 단점을 각각 하나씩 적어 보자.
- [ ] 내가 만든 프로젝트에서 "조건이 맞으면 연출을 실행한다"를 코드 없이 구성하게 하고 싶은 장면이 있었는가? 있었다면 어떤 장면이었는지 적어 보자.
