# Day 21 · 직렬화와 ScriptableObject 🎮

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UCS-022-DO |
| 유형 | D&O (개념) + 확인 실습 |
| 목적 | Unity 직렬화기가 저장하는 필드와 무시하는 필드, `[SerializeReference]`, `ScriptableObject`의 공유 데이터 특성과 Play 모드 함정을 설명한다 |
| 적용 대상 | Unity 6 (`practice/UnityLab`) |
| 소요 시간 | 60분 (4주차 Unity 코어와 트러블슈팅) |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 학습 목표

- Unity 직렬화기(`Serializer`)가 어떤 필드를 저장하고 어떤 필드를 무시하는지, 그리고 왜 `[Serializable]` 클래스가 `null`이나 다형성을 지원하지 않는지 설명할 수 있다.
- `ScriptableObject`가 왜 메모리를 절약하는지, 그리고 에디터 Play 모드에서 값을 바꿨을 때 왜 빌드와 다르게 동작하는지 설명할 수 있다.
- `[SerializeReference]`와 `ISerializationCallbackReceiver`로 인터페이스 다형성과 `Dictionary`를 인스펙터에 직렬화할 수 있다.

## 2. 구성 요소

| 구성 요소 | 위치 | 역할 |
|---|---|---|
| Unity 직렬화기(`Serializer`) | 엔진(C++) | 인스펙터 노출, 씬(`.unity`)·프리팹(`.prefab`)·에셋 저장과 복원을 맡는다 |
| `[SerializeField]` | 필드 | `private`/`protected` 필드를 직렬화 대상으로 만든다 |
| `[Serializable]` | 일반 C# 클래스·struct | 해당 타입을 인라인 값으로 직렬화할 수 있게 한다 |
| `[SerializeReference]` | 필드 | `null`, 참조 공유, 인터페이스·추상 클래스 다형성을 허용한다 |
| `[FormerlySerializedAs]` | 필드 | 필드 이름을 바꿔도 저장된 값을 이어받는다 |
| `ScriptableObject` | 에셋(`.asset`) | 여러 오브젝트가 참조만 공유하는 데이터 에셋이다 |
| `OnValidate()` | `MonoBehaviour`·`ScriptableObject` | 에디터에서 값이 바뀔 때 범위 제한·검증을 한다 |
| `ISerializationCallbackReceiver` | 직렬화되는 클래스 | 직렬화 직전·복원 직후에 호출되어 `Dictionary` 같은 타입을 우회 저장한다 |

## 3. 동작 원리

### 3-1. Unity 직렬화 규칙: 무엇이 저장되고 무엇이 무시되는가

인스펙터에 노출되고 씬(`.unity`)·프리팹(`.prefab`)에 저장되는 것은 전부 Unity의 C++ 직렬화기가 처리한다. .NET의 일반 직렬화와 규칙이 다르다.

| 직렬화 **됨** | 직렬화 **안 됨** (인스펙터에 안 나옴) |
|---|---|
| `public` 필드 또는 `[SerializeField]`가 붙은 `private`/`protected` 필드 | 프로퍼티(`{ get; set; }`, 단 `[field: SerializeField]`로 백킹 필드에 붙이면 가능), `static`, `const`, `readonly` 필드 |
| 기본 타입(`int`, `float`, `bool`, `string`), `enum`, Unity 내장 struct(`Vector3`, `Color` 등) | `Dictionary<K, V>`, `HashSet<T>`, `Queue<T>`, 다차원 배열(`int[,]`), 중첩 리스트(`List<List<int>>`) |
| `UnityEngine.Object` 파생 참조(`GameObject`, `MonoBehaviour`, `ScriptableObject`, `Texture` 등) | 추상 클래스·인터페이스 타입 필드 (`[SerializeReference]` 없이는 불가) |
| `[System.Serializable]`이 붙은 일반 C# `class` / `struct` | `[Serializable]`이 없는 일반 클래스/구조체 |
| 위 지원 타입의 1차원 배열(`T[]`)과 `List<T>` | |

### 3-2. `[Serializable]` 일반 클래스의 3가지 특성과 `[SerializeReference]`

`UnityEngine.Object`를 상속하지 않은 일반 C# 클래스에 `[Serializable]`을 붙이면 Unity는 이를 참조가 아니라 **값처럼 인라인(`inline`)으로 펼쳐서 저장**한다. 이 때문에 세 가지 놀라운 현상이 생긴다.

1. **`null`이 될 수 없다**: 코드에서 `private MyData data = null;`로 놔둬도 역직렬화 과정을 거치면 Unity가 빈 `new MyData()` 인스턴스를 자동으로 채워 넣는다. 자기 자신을 재귀적으로 가지는 트리 구조도 무한 생성을 막기 위해 **직렬화 깊이 제한(10단계)**에서 끊긴다.
2. **참조 공유가 깨진다**: 두 필드가 같은 `MyData` 인스턴스를 가리키게 해 놓아도 직렬화 후 복원되면 **서로 다른 두 복사본**으로 갈라진다.
3. **다형성(`Polymorphism`)이 안 된다**: `List<SkillEffect>`에 자식 클래스 `HealEffect`를 넣어도 부모인 `SkillEffect` 필드만 저장되고 자식 필드는 잘려 나간다.

이 세 가지를 해결하려면 필드에 **`[SerializeReference]`**를 붙인다. 인라인 값 대신 관리 객체의 참조 ID와 실제 런타임 타입을 함께 저장하므로 **`null`, 참조 공유, 인터페이스/추상 클래스 다형성**이 모두 동작한다.

### 3-3. 필드 초기값 vs 씬/프리팹 저장값, 그리고 변수 이름 변경

```csharp
[SerializeField] private int maxHp = 100; // 나중에 200으로 코드를 고쳐도...
```

생성자나 필드 초기화 식(`= 100`)이 먼저 실행된 **직후**, 씬이나 프리팹 파일에 이미 저장되어 있던 값(`100`)이 그 위를 덮어쓴다. 그래서 코드에서 초기값을 `200`으로 고쳐도 이미 씬에 배치된 오브젝트들은 여전히 `100`이다.
또한 직렬화된 필드 이름을 리팩터링할 때 그냥 바꾸면 씬과 프리팹에 저장된 그 필드의 값이 사라지고 기본값으로 돌아간다. 반드시 **`[FormerlySerializedAs("예전이름")]`**을 붙여 기존 데이터를 이어받아야 한다.

### 3-4. ScriptableObject: 공유 데이터 에셋과 Play 모드의 함정

몬스터 100마리가 각각 `int maxHp`, `float moveSpeed`, `string monsterName`을 `MonoBehaviour` 필드로 들고 있으면 100마리마다 똑같은 데이터가 메모리에 중복 복제된다(플라이웨이트 패턴 위반).
변하지 않는 정적 기획 데이터를 **`ScriptableObject`** 에셋(`.asset`) 하나에 담아 두고 몬스터 100마리가 그 에셋 참조 하나만 공유하면 **메모리에 단 한 벌**만 올라간다.

**가장 많이 밟는 함정 — 에디터 Play 모드 영구 저장 vs 빌드 휘발**:
- **에디터**: Play 모드 도중 스크립트가 `monsterDataSO.maxHp -= 10;`처럼 `ScriptableObject` 에셋의 필드를 수정하면, **Play 모드를 꺼도 디스크의 에셋 파일에 바뀐 값이 그대로 남는다**(Git diff가 더러워지고 다음 실행 결과가 꼬인다).
- **빌드된 게임**: 반대로 빌드에서는 `ScriptableObject`를 런타임에 수정해도 디스크 에셋에 저장되지 않으며, **앱을 껐다 켜면 원래 값으로 초기화**된다.
- **원칙**: `ScriptableObject`는 **읽기 전용 원본 데이터**로만 쓰고, 런타임에 변하는 상태(현재 체력, 세이브 데이터)는 별도 런타임 인스턴스에 복사해 쓰거나 JSON/바이너리로 직접 저장해야 한다.

**팀 프로젝트 연결**:
팀 프로젝트의 데이터 파이프라인은 **`CSV → ScriptableObject → 런타임 GameData`** 3단계로 되어 있다. 왜 CSV에서 바로 쓰거나 `ScriptableObject`를 런타임에 직접 고쳐 쓰지 않고 중간에 `ScriptableObject` 단계와 런타임 `GameData` 분리 단계를 두었는지 5절 실습 2에서 직접 정리해 본다.

### 3-5. OnValidate, ISerializationCallbackReceiver, 도메인 리로드

- **`OnValidate()`**: 에디터에서 인스펙터 값을 바꾸거나 스크립트가 리로드될 때 호출된다. 값 범위 제한(`Mathf.Clamp`)이나 참조 자동 연결 검증에 쓴다.
- **`ISerializationCallbackReceiver`**: Unity가 직렬화하기 직전(`OnBeforeSerialize`)과 직렬화 복원 직후(`OnAfterDeserialize`)에 호출되는 인터페이스다. Unity가 못 읽는 `Dictionary<K, V>`를 직렬화 직전에 `List<K> keys`, `List<V> values` 두 리스트로 풀고, 복원 직후 다시 `Dictionary`로 합치는 정석 패턴에 쓴다.
- **Enter Play Mode Options (Domain Reload 비활성화)**: Day 18에서 본 것처럼 도메인 리로드를 끄면 `static` 필드가 플레이 세션 사이에 초기화되지 않는다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 직렬화(serialization) | 메모리의 객체를 파일(씬, 프리팹, 에셋)에 저장할 수 있는 형태로 바꾸는 것 |
| 역직렬화(deserialization) | 저장된 데이터에서 객체를 복원하는 것 |
| 인라인(inline) 저장 | 참조가 아니라 값처럼 그 자리에 펼쳐서 저장하는 방식 |
| 다형성(polymorphism) | 부모 타입 변수에 자식 타입 객체를 담아 쓰는 성질 |
| 플라이웨이트(flyweight) | 같은 데이터를 여러 객체가 하나만 공유하는 패턴 |
| 도메인 리로드(domain reload) | 스크립트 컴파일이나 Play 모드 진입 때 C# 상태를 초기화하는 에디터 동작 |

## 5. 확인 실습 (30분)

{% hint style="info" %}
NOTE: AI, 자동완성, 검색 없이 한다. 막히면 3절로 돌아간다. 되돌리기: 실습용 GameObject와 스크립트, 에셋은 프로젝트 창과 씬에서 삭제하고 Ctrl+Z로 되돌린다. 씬 저장 전에 백업한다.
{% endhint %}

### 실습 1: 어떤 필드가 인스펙터에 나오는가 + `[SerializeReference]`와 Dictionary 직렬화 (20분)

`practice/UnityLab`에 아래 스크립트를 작성해 빈 GameObject에 붙인다. **인스펙터를 보기 전에** 아래 표에서 1)~10)번 필드가 인스펙터에 보일지(`O`/`X`), 그리고 `Start()`에서 `plainData == null`이 무엇을 찍을지 예측한다.

```csharp
// Unity: SerializationLab.cs
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

[Serializable]
public class PlainSerializableClass
{
    public int level = 1;
}

public interface IRewardEffect
{
    void Apply();
}

[Serializable]
public class GoldReward : IRewardEffect
{
    public int goldAmount = 100;
    public void Apply() => Debug.Log($"골드 +{goldAmount}");
}

[Serializable]
public class HealReward : IRewardEffect
{
    public float healRatio = 0.5f;
    public void Apply() => Debug.Log($"체력 회복 {healRatio * 100f}%");
}

public class SerializationLab : MonoBehaviour, ISerializationCallbackReceiver
{
    // 1~10번 필드 중 인스펙터에 보이는 것은?
    public int f1_PublicInt = 10;                                      // 1)
    private int f2_PrivateInt = 20;                                    // 2)
    [SerializeField] private int f3_SerializedPrivate = 30;            // 3)
    [SerializeField] private readonly int f4_Readonly = 40;            // 4)
    public static int f5_Static = 50;                                  // 5)
    public int F6_Property { get; set; } = 60;                         // 6)
    [field: SerializeField] public int F7_AutoProp { get; set; } = 70; // 7)
    [SerializeField] private PlainSerializableClass f8_PlainNull = null; // 8)
    [SerializeField] private Dictionary<string, int> f9_RawDict = new Dictionary<string, int>(); // 9)
    [SerializeReference] private List<IRewardEffect> f10_PolymorphicRewards = new List<IRewardEffect>(); // 10)

    // ISerializationCallbackReceiver로 Dictionary 우회 직렬화
    [SerializeField] private List<string> dictKeys = new List<string> { "Potion", "Scroll" };
    [SerializeField] private List<int> dictValues = new List<int> { 5, 2 };
    private readonly Dictionary<string, int> itemCounts = new Dictionary<string, int>();

    [ContextMenu("Add Polymorphic Rewards")]
    private void AddSampleRewards()
    {
        f10_PolymorphicRewards.Clear();
        f10_PolymorphicRewards.Add(new GoldReward { goldAmount = 250 });
        f10_PolymorphicRewards.Add(new HealReward { healRatio = 0.3f });
    }

    public void OnBeforeSerialize() { }

    public void OnAfterDeserialize()
    {
        itemCounts.Clear();
        int count = Mathf.Min(dictKeys.Count, dictValues.Count);
        for (int i = 0; i < count; i++)
        {
            if (!string.IsNullOrEmpty(dictKeys[i]))
                itemCounts[dictKeys[i]] = dictValues[i];
        }
    }

    private void Start()
    {
        Debug.Log($"f8_PlainNull == null : {f8_PlainNull == null} (level={f8_PlainNull?.level})");
        Debug.Log($"복원된 Dictionary Potion 개수: {itemCounts["Potion"]}");
        foreach (IRewardEffect reward in f10_PolymorphicRewards)
        {
            reward?.Apply();
        }
    }
}
```

컴포넌트 우클릭 메뉴(`Add Polymorphic Rewards`)를 눌러 `f10_PolymorphicRewards`에 서로 다른 자식 클래스 두 개가 들어가는 것도 확인하고 표를 채운다.

| 필드 번호와 이름 | 예측: 인스펙터 노출 (O/X) | 실측 (O/X) | 이유 (안 나오거나 특이한 동작을 하는 이유) |
|---|---|---|---|
| 1) `f1_PublicInt` | | | |
| 2) `f2_PrivateInt` | | | |
| 3) `f3_SerializedPrivate` | | | |
| 4) `f4_Readonly` | | | |
| 5) `f5_Static` | | | |
| 6) `F6_Property` | | | |
| 7) `F7_AutoProp` (`[field: SerializeField]`) | | | |
| 8) `f8_PlainNull = null` (`Start`에서 `null`인가?) | | | |
| 9) `f9_RawDict` | | | |
| 10) `f10_PolymorphicRewards` (`[SerializeReference]`) | | | |

<details><summary>정답</summary>

- O: 1, 3, 7, 8, 10
- X: 2(private), 4(readonly), 5(static), 6(일반 프로퍼티), 9(Dictionary)
- 7은 컴파일러가 만든 백킹 필드가 직렬화되어 보인다.
- 8은 `null`로 선언했지만 인스펙터가 빈 인스턴스를 만들어 채운다. `Start`는 `False (level=1)`을 찍는다.
- 10은 리스트는 보이지만 처음엔 비어 있다. 컨텍스트 메뉴로 넣은 `GoldReward`와 `HealReward`가 각자의 필드를 가진 채 저장된다.

</details>

### 실습 2: ScriptableObject의 Play 모드 오염 함정과 팀 프로젝트 파이프라인 정리 (10분)

1. 아래 `MonsterConfigSO.cs`를 만들고 프로젝트 창에서 `Create > Study > MonsterConfig`로 에셋(`maxHp = 100`)을 생성한다.

```csharp
// Unity: MonsterConfigSO.cs
using UnityEngine;

[CreateAssetMenu(menuName = "Study/MonsterConfig")]
public class MonsterConfigSO : ScriptableObject
{
    public int maxHp = 100;
}
```

2. 아무 `MonoBehaviour`의 `Start()`에서 `configSO.maxHp = 999;`를 실행한 뒤 **Play 모드를 끈다.**
3. Play 모드를 껐는데도 에셋 인스펙터의 `maxHp`가 몇으로 남아 있는지 확인하고, 팀 프로젝트의 `CSV → ScriptableObject → 런타임 GameData` 구조와 비교해 아래 표를 작성한다.

| 질문 | 내 확인 결과 및 정리 |
|---|---|
| Play 모드 중 `configSO.maxHp = 999` 실행 후 Play 모드를 껐을 때 에셋에 남은 값 | |
| 팀 프로젝트에서 CSV를 바로 런타임에 파싱하지 않고 에디터에서 `ScriptableObject`로 변환하는 이유는? | |
| `ScriptableObject`를 그대로 쓰지 않고 런타임에 `GameData` 객체로 한 번 더 감싸거나 복사하는 이유는? | |

## 6. 확인 문제 (10분)

소리 내어 30초 안에 답해 보고 펼쳐서 비교한다.

**Q1. 인스펙터에 변수를 노출할 때 `public` 대신 `[SerializeField] private`을 쓰는 이유는 무엇인가요?**
<details><summary>모범 답안</summary>
객체지향의 캡슐화를 지키기 위해서입니다. 필드를 `public`으로 열면 인스펙터에 노출될 뿐 아니라 다른 모든 스크립트에서 그 필드를 마음대로 읽고 수정할 수 있어 상태 추적이 어려워집니다. `[SerializeField] private`을 쓰면 다른 클래스로부터의 직접 접근은 막으면서 Unity 직렬화기와 인스펙터에만 안전하게 노출할 수 있습니다.

</details>

**Q2. `ScriptableObject`의 장점과 사용 시 주의할 함정은 무엇인가요?**
<details><summary>모범 답안</summary>
여러 오브젝트가 공유하는 변하지 않는 데이터를 에셋 하나에 담아 참조만 공유하므로, 프리팹 인스턴스마다 데이터가 중복 복사되는 것을 막아 메모리를 절약합니다. 또한 씬과 분리된 에셋이라 씬 간 데이터 공유와 기획 데이터 관리에 유리합니다. 다만 에디터 Play 모드에서 수정한 값은 에셋 파일에 영구히 남고, 반대로 실제 빌드에서는 런타임 수정 사항이 재시작 시 사라지므로, 세이브 데이터나 가변 상태 저장소로 쓰면 안 됩니다.

</details>

**Q3. Unity 인스펙터에서 `Dictionary`나 인터페이스 리스트를 직렬화하려면 어떻게 해야 하나요?**
<details><summary>모범 답안</summary>
Unity 기본 직렬화기는 `Dictionary`와 인터페이스 다형성을 직접 지원하지 않습니다. `Dictionary`는 `ISerializationCallbackReceiver`를 구현해 직렬화 전(`OnBeforeSerialize`)에는 키 리스트와 값 리스트 두 개로 나누어 저장하고, 역직렬화 후(`OnAfterDeserialize`)에 다시 `Dictionary`로 재조립합니다. 인터페이스나 추상 클래스의 다형성 리스트는 필드에 `[SerializeReference]` 어트리뷰트를 붙여 값 인라인이 아닌 관리 참조 방식으로 직렬화하면 됩니다.

</details>

**Q4. 코드에서 `[SerializeField] private int speed = 5;`를 `10`으로 고쳤는데 게임에서는 여전히 `5`로 동작합니다. 왜 그런가요?**
<details><summary>모범 답안</summary>
오브젝트가 생성될 때 C# 필드 초기값인 `10`이 먼저 들어가지만, 그 직후 Unity 역직렬화 단계에서 씬이나 프리팹 파일에 이미 저장되어 있던 직렬화 값 `5`가 그 위를 덮어쓰기 때문입니다. 이미 배치된 프리팹이나 씬 오브젝트는 인스펙터에서 값을 바꾸거나 컴포넌트를 Reset해야 새 초기값이 반영됩니다.

</details>


## 참조

- [스크립트 직렬화 규칙 (Unity 공식 문서)](https://docs.unity3d.com/Manual/script-serialization-rules.html)
- [ScriptableObject 소개 (Unity 공식 문서)](https://docs.unity3d.com/Manual/class-ScriptableObject.html)
- [SerializeReference API 문서](https://docs.unity3d.com/ScriptReference/SerializeReference.html)
- [ISerializationCallbackReceiver API 문서](https://docs.unity3d.com/ScriptReference/ISerializationCallbackReceiver.html)

이전: [Day 20 · UnityEngine.Object와 null](day20-unity-object-null.md) · 다음: [Day 22 · 트러블슈팅 노트 ①: 프레임 스파이크](day22-troubleshooting-performance.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 오늘의 한 줄: 직렬화와 `ScriptableObject`의 핵심을 내 말로 한 문장으로 쓰면?
- [ ] 코드에서 초기값을 바꿨는데 씬의 값이 그대로여서 헤맨 경험이 있는가? 있다면 어떻게 확인했는가?
