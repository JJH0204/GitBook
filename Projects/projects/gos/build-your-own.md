# 새 노드 추가하기: 따라 만들기

## 무엇을 하는가

GOS에 없는 기능을 노드로 추가하는 방법을 익힌다. 예로 "연결되면 소리를 재생하는 출력 노드(`PlaySound`)"를 만든다. 이 절차는 어떤 출력 노드에도 같은 방식으로 쓸 수 있다.

## 왜 이렇게 설계했나

노드를 추가하는 비용을 낮추는 것이 GOS 구조의 목적이다. 새 노드가 지킬 일은 세 가지뿐이다.

1. `ProcessBase`를 상속한다.
2. 인스펙터에 노출할 대상·옵션을 `[SerializeField]`로 둔다.
3. `Execute()`에 할 일을 쓰고, 끝났음을 `IsOn`으로 표시한다.

이 세 가지만 지키면 기존 `Conditional`이 바로 호출할 수 있다. `Conditional`이 호출하는 대상은 `ProcessBase`라는 타입 하나뿐이기 때문이다.

## 핵심 코드 발췌

{% code title="VisualScripting/Output/PlaySound.cs" %}
```csharp
using UnityEngine;

namespace _Project.Scripts.VisualScripting
{
    public class PlaySound : ProcessBase
    {
        [Tooltip("재생할 소리가 들어 있는 AudioSource")]
        [SerializeField] private AudioSource source;

        [Tooltip("true면 한 번만 재생한다")]
        [SerializeField] private bool playOnce = true;

        public override void Execute()
        {
            if (playOnce && IsOn) return;     // 한 번만 실행하는 노드의 약속
            if (source == null)               // 유니티 오브젝트는 == null로 검사
            {
                Debug.LogError("PlaySound: AudioSource is not assigned.");
                return;
            }

            source.Play();
            IsOn = true;
        }
    }
}
```
{% endcode %}

{% code title="VisualScripting/Editor/VisualScriptingEditor.cs (추가분)" %}
```csharp
[MenuItem("GameObject/VisualScripting/Output/PlaySound", false, 10)]
private static void CreatePlaySoundAsset(MenuCommand menuCommand)
{
    GameObject go = new GameObject("NewPlaySound");
    go.AddComponent<PlaySound>();
    GameObjectUtility.SetParentAndAlign(go, menuCommand.context as GameObject);
    Undo.RegisterCreatedObjectUndo(go, "Create " + go.name);
    Selection.activeObject = go;
}
```
{% endcode %}

- `Execute` 첫 줄의 `IsOn` 검사: 반복 호출을 막는다. `playOnce`를 꺼서 여러 번 재생할 수도 있다.
- `source == null`: 빈 칸을 안전하게 검사한다. 기존 노드의 `is null` 방식 대신 이 방식을 쓰기를 권한다.
- `IsOn = true`: 실행했음을 알려, 다른 `Conditional`이 "소리가 재생되었다"를 입력으로 쓸 수 있게 한다.
- 메뉴 코드는 기존 항목과 같은 틀이다. 노드 타입과 이름만 바뀐다.

## 따라 만들기

1. [process-base.md](process-base.md), [input-nodes.md](input-nodes.md), [logic-nodes.md](logic-nodes.md)를 마쳐 `ProcessBase`, `OnEvent`(또는 `TriggerEnter`), `Conditional`이 있는 상태로 시작한다.
   - 확인 방법: 콘솔에 오류가 없다.
2. `Output/PlaySound.cs`를 위 코드로 만든다.
   - 확인 방법: 컴파일 오류가 없고, 빈 오브젝트에 Add Component로 붙일 수 있다.
3. `VisualScriptingEditor.cs`에 메뉴 항목을 추가한다.
   - 확인 방법: Hierarchy 우클릭 > VisualScripting > Output > PlaySound가 보인다.
4. 씬에 AudioSource를 가진 오브젝트(Play On Awake 끔, 임의의 AudioClip 지정)를 만든다. `PlaySound`의 Source 칸에 넣는다.
   - 확인 방법: 칸이 채워진다. AudioClip이 없다면 재생은 안 되지만 오류 없이 지나가는지 본다.
5. `OnEvent → Conditional(출력: PlaySound)`로 연결하고 Play 중 `OnEvent`의 Is On을 켠다.
   - 확인 방법: 소리가 한 번 재생되고, `PlaySound`의 Is On이 켜진다. 다시 켜도 `playOnce`라면 재생되지 않는다.
6. `playOnce`를 끄고 `OnEvent`의 Is On을 껐다 켜기를 반복한다.
   - 확인 방법: 켤 때마다 소리가 다시 재생된다.

## 막히기 쉬운 곳·한계

- 파일 이름과 클래스 이름이 다르면 Add Component에서 보이지 않는다.
- 새 노드를 `Editor` 폴더 안에 넣으면 컴포넌트로 붙일 수 없다. 노드는 `Editor` 폴더 밖, 메뉴 코드는 안에 둔다.
- 입력 노드를 새로 만들 때는 `IsOn`을 켜고 끄는 시점만 정하면 된다. 단, 입력을 시작시키는 쪽(`Execute`)과 상태 쪽(`IsOn`)을 헷갈리지 않는다.
- 이 문서의 코드는 실행해 확인하지 않았다(unverified).
- 확장 아이디어: 입력 노드(키 입력 등), 출력 노드(UI 텍스트 변경, 씬 전환), `Loop` 완성. 입력 처리는 프로젝트의 Input 설정(구 Input Manager 또는 새 Input System)에 따라 구현이 달라진다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 새 노드가 지켜야 하는 세 가지 약속을 내 말로 적어 보자.
- [ ] 내가 만들고 싶은 노드를 하나 정하고, 입력과 출력 중 무엇이며 인스펙터에 어떤 칸이 필요한지 적어 보자.
- [ ] 따라 만들면서 막혔던 부분과 해결 과정을 적어 보자.
