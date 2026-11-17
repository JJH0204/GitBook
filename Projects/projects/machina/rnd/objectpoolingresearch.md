# 오브젝트 풀링 조사 (Object Pooling)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-MRD-008-DO |
| 유형 | D&O (조사 기록) |
| 목적 | 몬스터에 Unity 풀 API를 적용한 구조, 키 선택 고민, 적용 중 나온 문제를 기록한다 |
| 확인 상태 | 미검증 (코드를 읽고 정리했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적과 방식

- 오브젝트 풀링은 자주 생성하고 삭제하는 객체를 미리 만들어 두고, 다른 시스템이 필요할 때 꺼내 쓰게 하는 최적화 기법이다.
- `Instantiate`와 `Destroy`를 반복하면 메모리 할당과 GC 비용이 생기므로 재사용으로 줄인다.
- Unity의 풀 API(`UnityEngine.Pool.ObjectPool<T>`, 2021.1 이후)로 비교적 쉽게 구현할 수 있다.

## 2. 구성 요소

| 번호 | 구성 요소 | 역할 |
|---|---|---|
| 1 | `MonsterType` 열거형 | 몬스터 종류(Normal, Ranged, Rapid) |
| 2 | `MonsterPoolData` 구조체 | 종류, 프리팹, 기본 크기, 최대 크기. 에디터에서 설정한다 |
| 3 | `MonsterManager` | 종류별 `ObjectPool<GameObject>`를 `Dictionary`로 보관하는 풀 관리자 |

```csharp
public enum MonsterType
{
    Normal,
    Ranged,
    Rapid,
}
```

```csharp
[System.Serializable]   // 정정: Inspector에 나타나려면 필요하다
public struct MonsterPoolData
{
    public MonsterType type;
    public GameObject prefab;
    public int defaultSize;
    public int maxSize;
}
```

```csharp
public class MonsterManager : MonoBehaviour
{
    [SerializeField] private MonsterPoolData[] monsterPoolsData;

    // 몬스터를 종류별로 풀을 만들어 저장할 딕셔너리
    private Dictionary<MonsterType, ObjectPool<GameObject>> monsterPools;

    private void Awake()
    {
        monsterPools = new Dictionary<MonsterType, ObjectPool<GameObject>>();
        
        // pool 객체를 초기화하는 코드
    }
}
```

{% hint style="info" %}
NOTE: 원본 코드에는 `[Serializable]`이 없었다. 직렬화 가능 표시가 없으면 구조체 배열이 Inspector에 나타나지 않는다. 풀 초기화 코드는 원본에 없다. `ObjectPool<T>` 사용에는 `using UnityEngine.Pool;`이 필요하다.
{% endhint %}

## 3. 키 선택

열거형 대신 동적으로 풀을 관리할 키 후보를 비교했다.

| 번호 | 키 | 장점 | 단점 |
|---|---|---|---|
| 1 | 캐릭터 ID (`int`) | 직관적이지 않지만 데이터베이스에서 관리되는 기준 값이라 간결하다 | 값만 보고 몬스터를 알기 어렵다 |
| 2 | 캐릭터 이름 (`string`) | 어떤 몬스터인지 알기 쉽다 | 오탈자 때문에 안정성이 떨어진다 |
| 3 | 프리팹 이름 (`string`) | 사용이 간결하고 오탈자 문제에서 일부 자유롭다 | 성능 문제가 있을 수 있다 |

선택한 키는 원본에 없다. 확인 필요.

## 4. 적용 중 문제 (2025-09-03 이슈)

| 번호 | 증상 | 원인 또는 처리 |
|---|---|---|
| 1 | 풀링 매니저 구현은 끝났으나 몬스터에 적용할 때 문제가 난다 | 몬스터는 Behavior Tree를 쓰고 상태 처리를 Sense, Think, Act 세 시스템이 나눠 맡는다. 풀링하려면 Death에서 Idle로 상태를 되돌려야 하는데 원활하지 않아 재활용에 문제가 났다 |
| 2 | 위 문제 | 풀로 돌려주기 전에 사용한 컴포넌트를 초기 상태로 돌리는 `Init` 메서드를 구현하고 풀에서 다시 꺼낸 뒤 `Init`을 호출해 해결했다 |
| 3 | 기본 크기(`defaultSize`)가 의도한 결과가 아니다. 객체 생성은 된 것 같은데 씬에는 풀링 오브젝트가 1개만 있다 | 점검이 필요하다고 기록했다. 아래 NOTE 참조 |
| 4 | 최대 크기(`maxSize`) 동작 여부 | 인스턴스를 극단적으로 늘려 확인하겠다고 기록했다. 결과는 원본에 없다 |

{% hint style="info" %}
NOTE: `ObjectPool<T>`의 생성자 인자 `defaultCapacity`는 내부 컬렉션의 초기 용량일 뿐 객체를 미리 만들지 않는다. 객체는 `Get()`을 호출할 때 `createFunc`로 만들어진다. 미리 만들려면 `Get`으로 꺼냈다가 `Release`하는 워밍업 코드가 필요하다. `maxSize`는 풀이 보관하는 최대 개수이며, 이를 넘어 `Release`한 객체는 `actionOnDestroy`로 파괴된다. 동시 생성 수를 제한하지 않는다. 3번 증상이 이 동작 때문인지는 확인하지 못했다. 버전 확인 필요.
{% endhint %}

## 5. 약어·용어

| 용어 | 뜻 |
|---|---|
| 풀링 | 객체를 파괴하지 않고 재사용하는 방식 |
| Behavior Tree | 몬스터 행동을 트리로 구성하는 AI 방식 |

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM D&O 형식으로 재작성, `[Serializable]` 정정, 오타("Sence/Tink") 정정 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 오브젝트 풀링이 줄여 주는 비용은 무엇이고, 몬스터에 적용할 때 새로 생기는 비용은 무엇인가?
- [ ] 풀 키로 최종 무엇을 골랐고 이유는 무엇인가?
- [ ] 풀에서 꺼낸 몬스터의 상태를 초기화하는 `Init`은 어떤 값을 되돌려야 하는가?
