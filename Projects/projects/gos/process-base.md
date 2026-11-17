# ProcessBase: 모든 노드의 공통 약속

## 무엇을 하는가

`ProcessBase`는 GOS의 모든 노드가 상속하는 추상 클래스다. 노드가 지켜야 하는 약속을 둘만 정한다.

- `IsOn`: 이 노드가 켜져 있는지 나타내는 bool 값.
- `Execute()`: 이 노드가 맡은 일을 실행하라는 호출. 노드마다 다르게 구현한다.

여기에 노드끼리 연결하는 데이터 묶음 `ProcessData`(노드 참조 + NOT 체크)와, 연결 대상의 상태를 읽는 `CheckInputProcessStatus()`가 더해진다.

## 왜 이렇게 설계했나

- 노드를 MonoBehaviour로 만들어 두면 기획자가 일반 컴포넌트처럼 오브젝트에 붙이고, 인스펙터에서 다른 노드를 끌어다 놓는 것으로 "선을 잇는" 효과를 낼 수 있다. 별도의 그래프 에디터를 만들 필요가 없다.
- 모든 노드가 같은 부모 타입이므로 인스펙터 칸 하나(`ProcessBase`, `ProcessData`)에 입력·처리·출력 어떤 노드든 꽂을 수 있다.
- `isOn`이 `[SerializeField]`라서 실행 중에 인스펙터에서 켜짐 여부가 체크박스로 보인다. 디버깅과 수업 시연에 유용하다.
- `ProcessData.isNot`으로 반대 조건("트리거 밖에 있을 때")을 별도 노드 없이 표현한다.

## 핵심 코드 발췌

{% code title="VisualScripting/ProcessBase.cs" %}
```csharp
using UnityEngine;

namespace _Project.Scripts.VisualScripting
{
    public abstract class ProcessBase : MonoBehaviour
    {
        [SerializeField] private bool isOn;

        public bool IsOn
        {
            get => isOn;
            protected set => isOn = value;
        }

        // 노드가 맡은 일을 하는 함수
        public abstract void Execute();

        // 입력 노드의 상태를 읽는다. isNot이면 반대로 돌려준다
        protected virtual bool CheckInputProcessStatus(ProcessData processData)
        {
            return (processData.isNot) ? !processData.process.IsOn : processData.process.IsOn;
        }
    }
}
```
{% endcode %}

{% code title="VisualScripting/ProcessData.cs" %}
```csharp
using System;

namespace _Project.Scripts.VisualScripting
{
    [Serializable]
    public struct ProcessData
    {
        public ProcessBase process;
        public bool isNot;
    }
}
```
{% endcode %}

줄 단위 설명은 다음과 같다.

- `abstract class ProcessBase : MonoBehaviour`: 직접 오브젝트에 붙일 수 없고(추상), 상속한 노드만 붙일 수 있다.
- `[SerializeField] private bool isOn`: 저장 필드. private이지만 인스펙터에 "Is On"으로 보인다.
- `IsOn { get; protected set; }`: 밖에서는 읽기만 되고, 값을 바꾸는 것은 노드 자신(상속 클래스)만 할 수 있다.
- `public abstract void Execute()`: 모든 노드가 반드시 구현해야 하는 "일하기" 함수.
- `CheckInputProcessStatus`: `processData.process`가 비어 있으면 `NullReferenceException`이 난다. 연결을 빼먹으면 콘솔에 오류가 뜨는 이유다.
- `[Serializable] struct ProcessData`: 인스펙터에서 "노드 칸 + Is Not 체크박스" 한 쌍으로 보인다. `List<ProcessData>`로 쓰면 여러 개를 연결한다.

## 따라 만들기

1. 빈 3D 프로젝트(Unity 2022.3 LTS 권장)를 만들고 `Assets/Scripts/VisualScripting` 폴더를 만든다.
   - 확인 방법: Project 창에 폴더가 보인다.
2. 위 `ProcessBase.cs`를 같은 이름의 파일로 만든다. 클래스 이름과 파일 이름이 같아야 한다.
   - 확인 방법: 컴파일 오류가 없고, 콘솔이 비어 있다.
3. 위 `ProcessData.cs`를 만든다.
   - 확인 방법: 컴파일 오류가 없다.
4. 아직 쓸 수 있는 노드가 없으므로 [input-nodes.md](input-nodes.md)의 `OnEvent`를 먼저 만든다. 빈 오브젝트에 붙이면 인스펙터에 "Is On" 체크박스가 보이는지 확인한다.
   - 확인 방법: `OnEvent`가 붙은 오브젝트의 인스펙터에서 Is On 체크박스가 나타난다. Play 모드에서 체크 상태가 코드 동작에 따라 바뀌는 것은 이후 페이지에서 확인한다.

## 막히기 쉬운 곳·한계

- 연결 칸을 비워 두면 `Conditional`이나 `Logic`이 매 프레임 `NullReferenceException`을 낸다. 코드에 null 검사가 없다.
- `IsOn`은 "지금 상태"이고 "이번 프레임에 일어난 사건"이 아니다. 사건(진입 순간)은 `Conditional`이 켜짐 상태가 되는 순간을 감지해 만든다. 자세한 내용은 [logic-nodes.md](logic-nodes.md)를 본다.
- 읽기 방식(폴링)이라 한 프레임 정도의 지연이 생길 수 있다. 업데이트 순서는 정해져 있지 않다.
- 노드를 다른 노드로 호출하는 방향(`Execute`)과 읽는 방향(`IsOn`)이 섞여 있어, 처음에는 "무엇이 무엇을 부르는지" 헷갈리기 쉽다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 노드를 MonoBehaviour로 만들면 기획자에게 어떤 점이 편한지 내 말로 설명해 보자.
- [ ] `IsOn`을 `protected set`으로 둔 이유를 추측해 보고, 만약 `public set`이었다면 어떤 문제가 생길지 적어 보자.
- [ ] `ProcessData`에 `isNot`을 넣은 설계를 직접 노드로 만들었다면 어떤 노드를 몇 개 더 만들어야 했을지 적어 보자.
