# AIController와 데이터: 트리를 돌리고 명령을 실행하는 쪽

## 무엇을 하는가

`AIController`는 몬스터 오브젝트에 붙는 `MonoBehaviour`로, 트리(에셋)와 몬스터(씬 오브젝트)를 이어 준다. 매 프레임 세 단계를 돈다.

| 단계 | 메서드 | 호출 시점 | 하는 일 |
| --- | --- | --- | --- |
| Sense | `Sense()` | `Update` | 블랙보드의 쿨타임 목록 갱신 |
| Think | `Think()` | `Update` | 전역 BT와 현재 상태에 맞는 BT들을 `Tick`. 액션 노드가 명령을 큐에 넣는다 |
| Act | `Act()` | `LateUpdate` | 큐에서 명령 하나를 꺼내 우선순위를 비교하고 실행한다 |

이 단계를 지탱하는 데이터 쪽은 다음과 같다.

* `Blackboard`: 몬스터 한 마리의 현재 상태 저장소(`MonoBehaviour`). 체력, 타겟, `NavMeshAgent`, 애니메이터, 스킬 목록, 쿨타임 목록, 상태 비트를 갖는다.
* `Datas.cs`: `CharData`(체력·속도·감지 범위 등), `SkillData`(범위·피해·쿨타임 등), `Monster2SkillData`(몬스터 ID → 스킬 ID 배열).
* `DataManager`: 위 데이터 목록을 인스펙터에 담고 ID로 찾아 주는 싱글톤.
* `MonsterManager`: 씬의 몬스터 목록과 플레이어 참조를 가진 싱글톤.

## 왜 이렇게 설계했나

* **Sense-Think-Act 분리.** 소스의 주석이 "LateUpdate는 매 프레임 후에 호출되므로 AI 명령어 큐를 처리하는 데 적합"이라고 적는다. 판단(Update)에서 모아 둔 명령을 `LateUpdate`에서 한 번에 처리하므로, 같은 프레임에 여러 노드가 명령을 넣어도 실행은 한 번이다.
* **큐가 `Queue`에서 우선순위 큐로.** 2025-08-14의 `AIController` 첫 버전은 평범한 `Queue<AICommand>`였고 "우선순위 큐를 활용해 우선순위에 따라 처리할 수 있도록 개선할 수 있음"이라는 TODO가 붙어 있었다. 이후 `PriorityQueue<AICommand>`로 바뀌어 현재에 이른다. (`PriorityQueue`는 `CustomCollections/PriorityQueue.cs`에 있고, 이 레포에서는 `AIController`의 명령 큐 한 곳에서만 쓴다. 자료구조 자체는 별도 문서에서 다룬다.)
* **전역 트리 + 상태별 트리.** 2025-09-10 커밋에서 `BTData{stateName, behaviorTree}` 배열이 생겼다. 항상 도는 `globalBehaviorTree`가 상태를 바꾸고(`BTActionChangeState`), 상태 이름에 맞는 트리가 그 상태의 행동을 한다. 이 시기 첫 구현은 일치하는 상태 트리를 하나만 돌리고 `break`했으나, 2026-01-07의 보스 페이즈 커밋에서 `break`가 사라져 상태 비트가 여러 개 켜져 있으면 해당 트리가 모두 돈다.
* **상태를 문자열 + 비트마스크로.** `StateData`(`ScriptableObject`)가 상태 이름과 비트 번호(0~31)를 정의하고, 기본 상태 9개(`None, Idle, Chase, Attack, Hit, Death, Patrol, Wander, Spawn`)를 항상 앞에 고정한다. 사용자 정의 상태는 9번부터 자동 배정된다. 한 몬스터가 여러 상태를 동시에 가질 수 있고(비트 OR), `HasState`로 검사한다. 보스의 페이즈 같은 상태를 에디터에서 이름만 추가해 늘릴 수 있다.

## 핵심 코드 발췌

{% code title="Monster/AI/AIController.cs (NodeContext, Think)" %}
```csharp
public readonly struct NodeContext
{
    public readonly Blackboard.Blackboard Blackboard;
    public readonly Action<AICommand, int> Enqueue;

    public NodeContext(Blackboard.Blackboard blackboard, Action<AICommand, int> enqueue)
    {
        Blackboard = blackboard;
        Enqueue = enqueue;
    }
}

[Serializable]
public struct BTData
{
    public string stateName;
    public BehaviorTree.BehaviorTree behaviorTree;
}

private void Think()
{
    globalBehaviorTree?.Tick(new NodeContext(Blackboard, EnqueueCommand));

    foreach (var btData in data)
    {
        if (!blackboard.State.HasState(btData.stateName)) continue;
        btData.behaviorTree?.Tick(new NodeContext(Blackboard, EnqueueCommand));
    }
}
```
{% endcode %}

* `NodeContext`: 노드가 알아야 할 것을 두 가지로 줄였다. 블랙보드(읽기)와 `Enqueue`(명령 요청). `struct`라서 Tick마다 새로 만들어도 힙 할당이 없다.
* `Enqueue`가 `Action<AICommand, int>`인 덕분에 노드는 `AIController` 타입을 알 필요가 없다.
* `BTData`: 인스펙터에서 "상태 이름 ↔ 트리"를 짝지어 배열로 넣는다.
* `Think`: 전역 트리를 먼저 돌리고, 그다음 현재 켜진 상태에 해당하는 트리를 전부 돌린다. 전역 트리가 이번 프레임에 상태를 바꿨다면, 바뀐 상태의 트리가 같은 프레임에 이어서 돈다.

{% code title="Monster/AI/AIController.cs (Act)" %}
```csharp
private void Act()
{
    if (_queue.Count > 0)
    {
        // 큐에 명령어가 있는 경우, 첫 번째 명령어를 처리
        (AICommand command, int priority) = DequeueCommand();

        // 명령어 실행 후 큐 청소
        _queue.CleanUp();

        if (_currentPriority < priority)
        {
            _currentPriority = priority;
            _currentCommand = command;
            _currentCommand.OnEnter(blackboard, () =>
            {
                _currentPriority = -999;
            });
        }
    }
    else
    {
        _currentCommand = null;
        _currentPriority = -999;
    }

    _currentCommand?.Execute(blackboard, () =>
    {
        _currentCommand = null;
        _currentPriority = -999;
    });
}
```
{% endcode %}

* `DequeueCommand()`: 큐에서 우선순위 값이 가장 앞선 항목 하나를 꺼낸다. 큐는 `CreateMinPriorityQueue()`로 만들었으므로 우선순위 **숫자가 가장 작은** 항목이 나온다.
* `_queue.CleanUp()`: 꺼내고 나서 남은 명령을 모두 버린다. 한 프레임에 하나만 후보가 되고 나머지는 사라진다.
* `_currentPriority < priority`: 지금 실행 중인 명령보다 **숫자가 큰** 명령일 때만 새로 시작한다. 같거나 작으면 새 명령은 버려지고 기존 명령이 계속된다. 이 덕분에 `BTActionPatrol`처럼 매 프레임 같은 명령을 넣어도 명령이 매번 재시작되지 않는다.
* `-999`: "실행 중인 명령이 없음"을 뜻하는 최저 우선순위다.
* 큐가 비어 있으면 `_currentCommand = null`로 지금 명령을 놓아 버린다. 이때 `OnExit`는 호출되지 않는다(코드 읽기).
* `Execute`는 매 프레임 호출된다. 명령은 끝나면 전달받은 콜백으로 `AIController`에 완료를 알린다(`HitCommand`처럼 곧장 `onComplete`를 부르는 명령도 있다).

{% code title="Data/Datas.cs, Managers/DataManager.cs (발췌)" %}
```csharp
[Serializable]
public class CharData
{
    public int id;
    public string name;
    public float health;
    public float maxHealth;
    public float damage;
    public float walkSpeed;
    public float runSpeed;
    public float defence;
    public float maxDetectiveRange;
    public float minDetectiveRange;
}

public class DataManager : Singleton<DataManager>
{
    [SerializeField] private List<CharData> charDataList;
    [SerializeField] private List<SkillData> skillDataList;
    [SerializeField] private List<Monster2SkillData> monster2SkillDataList;

    public CharData GetCharDataByID(int id)
    {
        foreach (CharData charData in charDataList)
            if (charData.id == id) return charData;
        return null;
    }
}
```
{% endcode %}

* `[Serializable]` 클래스 + `List`: 인스펙터에서 바로 수치를 입력하는 가장 단순한 데이터 저장 방식이다(CSV나 에셋 없이).
* `id`로 선형 탐색한다. 몬스터 종류가 수십 개 수준이면 충분하다.
* `Blackboard.InitMonsterStatsByID()`는 `id`가 1000~1999일 때만 동작해 `CharData`를 **복사(새 인스턴스)** 하고 `Monster2SkillData`로 스킬 목록을 채운다. 몬스터마다 체력이 독립되는 이유다. 스킬 데이터는 복사하지 않고 `DataManager`의 객체를 그대로 참조한다.

### 몬스터 매니저와의 연결

* `AIController.Awake`에서 `MonsterManager.Instance.AddMonster(gameObject)`로 자신을 등록하고, `Init()`에서 `blackboard.Target = MonsterManager.Instance.Player`로 타겟을 정한다.
* `Singleton<T>.Instance`는 씬에서 `FindObjectOfType`으로 찾고, 없으면 새 `GameObject`를 만들어 `DontDestroyOnLoad`를 건다. 자동 생성된 `MonsterManager`는 `player`가 비어 있으므로, 씬에 `MonsterManager`를 미리 두고 `player`를 연결해야 한다.
* `MonsterManager.GetBattleMonsters()`는 `BTIsCombatNearby`가 호출한다.
* 피격 경로: `Bullet.TakeDamage` → `AIController.OnHit(damage, command, priority)`가 `blackboard.CurrentHealth`를 깎고 `HitCommand`를 우선순위 100으로 큐에 넣는다.
* 쿨타임 경로: `AttackCommand`가 끝에 `blackboard.ApplyCooldown(skillID, coolTime + Time.time)`을 호출하고(종료 시각을 저장), `Sense()`가 매 프레임 `UpdateCooldownList()`로 끝난 항목을 지운다. `BTIsCooldown`은 목록에 없으면 "사용 가능"으로 본다.

## 따라 만들기: 최소 AIController

[BT 기초](bt-basics.md), [리프 노드](leaf-nodes.md)의 최소 노드가 있다고 가정한다.

1. **데이터 클래스를 만든다.** `Datas.cs`에 `CharData`와 `SkillData`(`id, range, cooldownTime`만 있어도 된다)를 `[Serializable]`로 만든다.

   확인 방법: 다른 `MonoBehaviour`에 `public List<CharData>` 필드를 두면 인스펙터에서 리스트가 편집된다.

2. **`Singleton<T>`와 `DataManager`를 만든다.** 원본 `Singleton`처럼 `FindObjectOfType`으로 찾고 없으면 생성하게 한다. `DataManager`에 `GetCharDataByID`, `GetSkillDataByID`를 둔다.

   확인 방법: 씬에 `DataManager`를 넣고 몬스터 한 종류 데이터를 입력한 뒤 `Debug.Log(DataManager.Instance.GetCharDataByID(1001).name)`이 값을 찍는다.

3. **`Blackboard`를 만든다.** 최소판은 `Agent`, `Target`, `NavMeshAgent`, `CharData`, `Skills`와 `CurrentHealth` 프로퍼티(= `CharData.health`)만 둔다. `InitStats()`에서 `DataManager`의 `CharData`를 복사한다.

   확인 방법: 몬스터 두 마리의 체력을 각각 깎아도 서로 영향이 없다(복사 확인).

4. **`AICommand` 추상 클래스를 만든다.** `Execute(Blackboard, Action onComplete)`를 추상으로, `OnEnter`/`OnExit`를 가상으로 둔다. 한 번에 끝나는 `IdleCommand`와 로그만 찍는 `LogCommand`를 만든다.

   확인 방법: `new IdleCommand().Execute(bb, () => Debug.Log("done"))`가 `done`을 출력한다.

5. **`NodeContext`를 만들고 노드의 `Evaluate` 시그니처를 맞춘다.** 위 발췌의 `NodeContext`를 넣는다.

   확인 방법: 모든 노드가 컴파일된다.

6. **우선순위 큐를 준비한다.** 직접 만든 최소 힙(또는 `List`를 정렬하는 임시 구현)으로 `Enqueue(item, priority)`, `Dequeue()`, `Clear()`를 만든다. 자료구조 구현은 이 문서의 범위가 아니다.

   확인 방법: 우선순위 3, 1, 2로 넣고 꺼내면 1, 2, 3 순서로 나온다(최소 우선).

7. **`AIController`를 만든다.** `Update`에서 `tree.Tick(new NodeContext(bb, EnqueueCommand))`, `LateUpdate`에서 위 `Act`를 구현한다. 처음에는 전역 트리 하나만 쓴다.

   확인 방법: `Selector[ Sequence[IsTargetNear, ActionLog], ActionIdle ]` 트리로 Play하면 타겟이 가까울 때와 멀 때 서로 다른 명령 로그가 찍힌다.

8. **우선순위 선점을 확인한다.** 액션 두 개의 `priority`를 서로 다르게 두고, 한 프레임에 둘 다 큐에 들어가도록 `Parallel`로 묶어 본다.

   확인 방법: 한 프레임에 하나의 명령만 `OnEnter`되고, 나머지는 버려진다. 어떤 숫자가 이기는지 직접 로그로 확인한다(원본은 숫자가 작은 항목이 후보가 되고, 그 항목이 현재 명령보다 클 때만 시작된다).

9. **(선택) 상태 비트마스크를 넣는다.** `StateData`와 `DynamicState`를 만들어 `BTData` 배열로 상태별 트리를 돌린다.

   확인 방법: `BTActionChangeState`가 `Patrol` 상태를 켜면 `Patrol` 트리만 돌기 시작한다.

## 막히기 쉬운 곳, 한계

아래는 소스를 읽고 찾은 문제 후보다. 실행해 확인하지 못했으므로 모두 **unverified**다.

* **상태 숫자 리터럴 불일치 (버그 후보).** `StateData`/`MonsterState`는 상태를 비트마스크(`1 << bitIndex`)로 저장한다. 그런데 `MonsterManager`는 `HasState(2)`, `HasState(3)`, `HasState(4)`를 "Chase/Attack/Hit"로 쓰고(주석 참고), 사망 판정에 `HasState(5)`를 쓴다. 마스크로 읽으면 2 = `Idle`(비트 1), 4 = `Chase`(비트 2), 5 = 비트 0과 비트 2가 동시에 켜진 상태이며, `Death`(비트 5)의 마스크는 32다. 열거형 시절의 숫자가 남은 것으로 보인다. 이 경우 `GetBattleMonsters`와 죽은 몬스터 제거가 의도대로 동작하지 않을 수 있다.
* **죽은 몬스터 제거 루프.** `MonsterManager.Update`가 `for`로 리스트를 순회하면서 `monsters.Remove(monster)`를 호출해 인덱스를 보정하지 않는다. 제거 직후 다음 요소를 건너뛴다.
* **우선순위 방향.** 큐는 최소 힙이라 숫자가 작은 명령이 먼저 나오는데, 실행 판단은 `_currentPriority < priority`라서 숫자가 큰 명령이 현재 명령을 대체한다. 한 프레임에 낮은 숫자와 높은 숫자가 함께 들어오면 낮은 숫자가 후보가 되고 높은 숫자는 `CleanUp`으로 사라진다. 피격(`HitCommand`)을 100으로 넣는 것은 "높은 숫자가 우선"이라는 의도로 보이는데, 같은 프레임에 다른 명령이 함께 있으면 큐에서 지는 구조로 읽힌다. 의도인지 확인이 필요하다.
* **큐가 비면 현재 명령을 놓는다.** 프레임에 아무 명령도 들어오지 않으면 `_currentCommand = null`이 되고 `OnExit`가 불리지 않는다. 길게 실행되는 명령(`PatrolCommand`)은 트리가 매 프레임 계속 넣어 줘야 유지된다.
* **`InitMonsterStatsByID`의 널 처리.** `GetMonster2SkillDataByCharID`가 `null`을 반환하면 바로 `skillData.skillIds`에서 예외가 난다. `id`가 범위(1000~1999) 밖이면 `CharData`가 `null`인 채로 남고, 이를 읽는 조건들은 대부분 `null`을 검사해 거짓을 돌려준다.
* **`Init()`의 중복 호출.** `Awake`와 `OnEnable` 모두 `Init()`을 부르지만 `_isInit` 플래그로 한 번만 실행된다. 오브젝트를 풀링(비활성/활성 반복)하면 두 번째부터는 초기화가 다시 일어나지 않는다. `MonsterManager.CreateMonster`는 비어 있다.
* **씬 의존성.** `MonsterManager`, `DataManager`는 씬에 미리 있어야 값이 채워진다. 자동 생성되면 목록이 비어 있다.
* **`DynamicState` 초기화 시점.** `[RuntimeInitializeOnLoadMethod(AfterSceneLoad)]`로 `Resources/StateData`를 읽는다. 에셋이 `Resources` 폴더에 `StateData`라는 이름으로 있어야 하고, 없으면 에러 로그만 남고 모든 상태 이름이 0 마스크가 된다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] Sense-Think-Act 세 단계를 내가 아는 다른 게임 AI 예시(또는 직접 만든 AI)에 대응시켜 적는다.
- [ ] 몬스터에게 "한 번에 하나의 명령만 실행한다"는 규칙이 필요한 이유와, 그 규칙 때문에 생기는 불편을 내 말로 적는다.
- [ ] 몬스터 데이터를 코드가 아니라 데이터(`CharData`, `SkillData`)로 분리했을 때 내 프로젝트에서 이득을 볼 지점을 적는다.
