# 오브젝트 상태 보관과 풀링

## 무엇을 하는가

세 클래스가 "스테이지가 내려가고 올라와도 남아야 하는 것"과 "자주 만들고 없애는 것"을 맡는다.

- `DungeonStateManager`: 오브젝트 id를 키로 `bool` 상태를 보관하는 작은 저장소. 스테이지 씬이 내려가 오브젝트가 사라져도 값은 Persistent 쪽 매니저에 남는다.
- `PoolManager`: 프리팹별로 Unity `ObjectPool<GameObject>`를 만들어 몬스터와 투사체를 재사용한다.
- `MonsterManager`: 살아 있는 몬스터의 목록을 들고 있다가 한 번에 풀로 회수한다.

## 왜 이렇게 설계했나

- 커밋 `39ce46d4`(DungeonStateManager 추가)에서 `DungeonStateManager.cs`와 프리팹이 함께 추가되고 `InitPersistent`의 매니저 목록에 올랐다. 스테이지를 스트리밍하면 씬 안의 오브젝트 상태(예: 이미 열린 문)가 씬 언로드와 함께 사라지므로, 씬 밖에 상태를 두려는 목적으로 읽힌다. 이 해석은 클래스 구조에서 추론한 것이며 커밋 메시지에는 "던전 내 오브젝트 상태 관리"로만 적혀 있다.
- 풀링 구조(`PoolManager`, `PoolableObject`)의 원형은 팀 동료가 만든 것이고, 내가 한 변경은 커밋 `8fec0375`, `cc1d0011` 등의 정리 수준이다. `PoolableObject`를 `sealed`로 만들고 `IsInPool`의 `set`을 `private`으로 닫아 풀 바깥에서 상태를 바꾸지 못하게 했다. 오브젝트를 만들 때 풀 부모 아래에 바로 생성하게 했다(하이어라키 정리).
- `MonsterManager.ReleaseAllMonsters`(커밋 `cc1d0011`)는 하드 모드 부활에서 "스테이지를 다시 로드하기 전에 살아 있는 몬스터를 정리"하기 위해 추가되었다.

## 핵심 코드

{% code title="DungeonStateManager.cs" %}
```csharp
public class DungeonStateManager : Singleton<DungeonStateManager>
{
    private Dictionary<int, bool> _objStates = new ();

    public void SetState(int objId, bool state)
    {
        if (_objStates.ContainsKey(objId))
            _objStates[objId] = state;
        else
            _objStates.Add(objId, state);
    }

    public bool GetState(int objId)
    {
        return _objStates.TryGetValue(objId, out bool state) && state;
    }

    public void ClearStates()
    {
        _objStates.Clear();
    }
}
```
{% endcode %}

- `SetState`: 키가 있으면 덮어쓰고 없으면 추가한다. `_objStates[objId] = state`로도 같은 결과이므로 분기는 단순화할 수 있다.
- `GetState`: 키가 없으면 `false`를 돌려준다. "한 번도 기록하지 않은 오브젝트는 기본 상태"라는 규칙이 한 줄에 들어 있다.
- `ClearStates`: 게임을 새로 시작할 때 비우는 용도로 보이나, 코드 안에서 호출하는 곳은 찾지 못했다.

{% code title="PoolManager.cs (풀 생성·반납 발췌)" %}
```csharp
ObjectPool<GameObject> pool = new(
    createFunc: () =>
    {
        GameObject obj = InstantiateObject(poolData.prefab);
        AddPoolableComponent(obj);
        return obj;
    },
    actionOnGet: obj =>
    {
        obj.GetComponent<PoolableObject>()?.OnGetFromPool();
        obj.SetActive(true);
    },
    actionOnRelease: obj =>
    {
        OnRelease(obj);                         // 풀 부모로 이동 + SetActive(false)
        obj.name = poolData.prefab.name;        // "(Clone)" 이름 복원
        obj.GetComponent<PoolableObject>()?.OnReturnToPool();
    },
    actionOnDestroy: Destroy,
    collectionCheck: false,
    defaultCapacity: poolData.defaultSize,
    maxSize: poolData.maxSize
);

public void ReleaseObject(GameObject obj, float delay = 0.0f)
{
    var poolable = obj.GetComponent<PoolableObject>();
    if (poolable == null) { Destroy(obj, delay); return; }   // 풀 밖 오브젝트는 파괴
    if (poolable.IsInPool) return;                           // 중복 반납 방지
    ...
}
```
{% endcode %}

- 풀 키는 프리팹 이름이다(`poolData.prefab.name`). 그래서 반납 시 이름의 `(Clone)`을 지우고(`GetOriginalKey`) 풀을 찾는다.
- `PoolableObject.IsInPool`: 같은 오브젝트가 두 번 반납되는 것을 막는 깃발이다. Unity 풀의 `collectionCheck`는 꺼 두었기 때문에(성능) 이 깃발이 대신 검사한다.
- `defaultSize`만큼 미리 만들어 `pool.Release`로 넣는다. 첫 `Get`에서 생성 비용이 튀지 않게 한다. 실제 파일에는 이 사전 생성 루프와 `GetObject` 오버로드들(위치·회전·부모를 받는 형태)이 길게 이어진다. 발췌에서는 생략했다.

{% code title="MonsterManager.cs (발췌)" %}
```csharp
public void AddMonster(GameObject monster)
{
    if (monster is not null && !monsters.Contains(monster))
        monsters.Add(monster);
}

public void ReleaseAllMonsters()
{
    foreach (GameObject monster in monsters.Where(monster => monster is not null))
        PoolManager.Instance.ReleaseObject(monster);

    monsters.Clear();
}
```
{% endcode %}

- `Where(... is not null)`: 이미 파괴된 몬스터(Unity의 파괴된 참조)를 거른다. 다만 `is not null`은 Unity가 파괴한 오브젝트를 걸러내지 못하는 점은 알아 둘 만하다(Unity 오브젝트의 `null` 비교 규칙. 이 코드에서 실제로 문제가 되는지는 확인하지 못했다).
- 목록을 순회하며 `ReleaseObject`를 호출하고, 끝에 한 번에 `Clear`한다. 순회 중 목록을 수정하지 않으므로 안전하다.

## 따라 만들기 단계

1. `DungeonStateManager`를 만들어 Persistent 매니저 프리팹에 등록한다.
   - 확인 방법: `SetState(1, true)` 후 `GetState(1)`이 `true`, 기록 없는 `GetState(2)`가 `false`.
2. 스테이지 씬의 문(예: 한 번 열면 열린 상태)이 `Awake`에서 `DungeonStateManager.Instance.GetState(id)`로 상태를 읽어 초기 모양을 정하도록 만든다. 열릴 때 `SetState(id, true)`를 호출한다. id는 씬 안에서 겹치지 않는 값으로 정한다.
   - 확인 방법: 문을 열고 스테이지를 언로드했다 다시 로드해도 열린 상태로 시작한다.
3. `PoolableObject`(`IsInPool`, `OnGetFromPool`, `OnReturnToPool`)를 만든다.
4. `PoolManager`에 `PoolData`(`prefab`, `defaultSize`, `maxSize`) 배열을 Inspector 필드로 두고 `Init()`에서 프리팹별 `ObjectPool`을 만든다. 풀 부모 오브젝트를 만들어 하이어라키를 정리한다.
   - 확인 방법: 플레이하면 `<프리팹이름> Pool` 오브젝트가 생기고 그 아래에 비활성 오브젝트가 `defaultSize`개 있다.
5. `GetObject(prefab)`과 `ReleaseObject(obj)`를 만든다. 몬스터 스폰 코드가 `Instantiate` 대신 `GetObject`를 쓰도록 바꾼다.
   - 확인 방법: 몬스터를 반복해서 소환·처치해도 하이어라키의 오브젝트 수가 늘지 않는다.
6. `MonsterManager`에 `AddMonster`, `RemoveMonster`, `ReleaseAllMonsters`를 만들고 소환할 때 `AddMonster`를 호출한다.
   - 확인 방법: `ReleaseAllMonsters`를 호출하면 활성 몬스터가 모두 풀로 돌아간다.

## 막히기 쉬운 곳과 한계

- **이름 기반 키**: 풀 키가 프리팹 이름이라 서로 다른 프리팹의 이름이 같으면 충돌한다(두 번째는 `continue`로 건너뛴다). 반납 시 이름을 바꿔 버리면 풀을 못 찾는다.
- **풀 오브젝트와 씬 수명**: 풀 오브젝트는 `PoolManager` 아래에 있으므로 스테이지 씬이 내려가도 파괴되지 않는다. 대신 스테이지 안에서 풀 오브젝트를 상태에 맞게 되돌리는 책임은 호출하는 쪽에 있다.
- **풀 초기화**: `ClearPools`와 재`Init`은 주석 처리된 채 남아 있다. "풀을 리셋하면 오류가 난다"는 주석이 `GameManager.ExitGame`에 있다. 원인은 확인하지 못했다.
- **`DungeonStateManager`의 범위**: 값은 `bool`뿐이고 저장 파일로 내보내지 않는다. 게임을 껐다 켜면 사라진다. C# 코드에서 `SetState/GetState`를 호출하는 곳은 코드 검색으로 찾지 못했다(Unity 이벤트나 비주얼 스크립팅 쪽에서 호출할 가능성이 있으나 확인하지 못했다).
- **`MonsterManager`의 미완성 부분**: `PauseMonsters/UnpauseMonsters`는 할 일 주석만 있는 빈 함수다.
- **`MapManager`**: 프리팹만 있고 이 저장소에서 같은 이름의 스크립트를 찾지 못했다. 역할은 확인하지 못했다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 오브젝트 풀링을 쓰지 않고 `Instantiate`/`Destroy`만 쓰면 어떤 문제가 생기는지 내가 아는 대로 적어 본다.
- [ ] 스테이지 씬이 언로드되어도 문이 열린 상태를 유지하려면 어디에 상태를 두어야 하는지, 내 말로 설명해 본다.
- [ ] 풀에서 꺼낸 오브젝트를 되돌릴 때 초기화할 것들을 직접 만들어 본 경험이 있다면 적어 본다.
