# 오브젝트 풀링·모바일 최적화 해체

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-MCH-101-DO |
| 유형 | D&O (설정 에셋 해체) |
| 목적 | 풀링 코드(`PoolManager`)와 소스에서 확인되는 모바일 최적화 설정(Addressables 그룹, URP 품질 에셋)을 해체한다 |
| 확인 상태 | 미검증 (코드와 에셋 파일을 읽었을 뿐 Unity에서 열거나 빌드·측정하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="warning" %}
WARNING: 비공개 레포, 접근 권한 필요. 코드는 소스 레포의 git 오브젝트에서 읽기 전용으로 읽었고(작업 트리에는 `.cs`가 없었다), 컴파일·실행하지 않았다. 조사 기록은 [오브젝트 풀링 조사](../rnd/objectpoolingresearch.md), 던전 쪽 풀링은 [오브젝트 상태 보관과 풀링](../dungeon-stage/object-state-pooling.md)을 본다.
{% endhint %}

## 1. 이 영역이 하는 일

- 자주 만들고 없애는 객체를 재사용해 `Instantiate`/`Destroy` 비용을 줄인다(기존 R&D 기록).
- 에셋을 Addressables 그룹으로 나눠 메모리 중복을 줄이고, 모바일용 URP 품질 설정을 따로 둔다.

## 2. 소스에서 확인한 구성 요소

| 구분 | 파일(레포 기준 상대) | 확인한 내용 |
|---|---|---|
| 풀 관리자 | `Branch/Assets/_GameAssets/01. Scripts/Managers/PoolManager.cs` | `PoolManager`(싱글톤)가 프리팹 이름을 키로 `ObjectPool<GameObject>`를 `Dictionary<string, ...>`에 보관한다 |
| 풀 표식 | 같은 파일 | `PoolableObject`: `IsInPool` 플래그와 `OnGetFromPool`/`OnReturnToPool`. 풀 생성 시 자동 부착한다 |
| 몬스터 등록 | `.../Managers/MonsterManager.cs` | 씬의 몬스터 목록. `ReleaseAllMonsters`가 전부 `PoolManager.ReleaseObject`로 반납한다 |
| 상태 초기화 | `.../Monster/AI/Blackboard/Blackboard.cs` | `RealeseObjectToPool()`이 래그돌·사망 이펙트를 끄고 `Init()` 후 반납한다 |
| 생성 호출 | `.../VisualScripting/Output/Instance.cs`, `.../Monster/MonsterAttack.cs` | 출력 노드와 몬스터 공격이 `GetObject`로 풀에서 꺼낸다 |
| Addressables 그룹 | `Branch/Assets/AddressableAssetsData/AssetGroups/` | 그룹 5개: Built In Data, Default Local Group, Shared Asstes, Duplicate Asset Isolation, GameScene. 항목 수는 각각 3, 8, 221, 17, 10개(`m_GUID` 개수 기준) |
| 번들 스키마 | `.../AssetGroups/Schemas/*_BundledAssetGroupSchema.asset` | 네 그룹 모두 `m_Compression: 1`(LZ4로 읽음), `m_BundleMode: 0`(Pack Together로 읽음), 로컬 빌드 |
| 카탈로그 | `.../AddressableAssetSettings.asset` | `m_BuildRemoteCatalog: 0`. 원격 배포는 쓰지 않는 설정이다 |
| URP 품질 에셋 | `Branch/Assets/Settings/URP-*.asset` | Performant, Balanced, HighFidelity, HighFidelityMobile 4종. 모두 SRP Batcher 켬, 동적 배칭 끔 |
| 모바일 URP 에셋 | `Settings/URP-HighFidelityMobile.asset` | HDR 끔, 렌더 스케일 0.9, 메인 라이트 그림자 해상도 512, 그림자 거리 15, 추가 라이트 모드 1(Per Vertex로 읽음) |

{% hint style="info" %}
NOTE: 어느 URP 에셋이 실제 빌드에 쓰이는지는 `ProjectSettings`(Quality·Graphics)에 있으며 로컬 소스에 없었다. 소스에서 확인 못함. 아래 비교는 에셋 값 차이일 뿐 적용 여부가 아니다. 열거값(압축, 번들 모드, 추가 라이트 모드)의 뜻은 Unity 문서 기준으로 해석했으며 버전 확인 필요.
{% endhint %}

### URP 에셋 값 비교

| 항목 | Performant | Balanced | HighFidelityMobile |
|---|---|---|---|
| HDR | 끔 | 켬 | 끔 |
| 렌더 스케일 | 1 | 1 | 0.9 |
| 메인 라이트 그림자 해상도 | 1024 | 256 | 512 |
| 그림자 거리 | 50 | 50 | 15 |
| 소프트 섀도 | 끔 | 끔 | 켬 |
| 추가 라이트 모드 | 0 | 0 | 1 |

## 3. 데이터 흐름

```
에셋 --(그룹 배치)--> Addressables 그룹 --(빌드)--> 로컬 번들
                         |
   Analyze(중복 종속성 검사) --> "Duplicate Asset Isolation" 그룹 (중복 에셋 격리)
                         |
   Shared Asstes 그룹 (공용 에셋 221개를 한곳에 모음)

URP 품질 에셋(4종) --(Quality 설정에서 선택)--> 렌더링 비용 조절
```

- "Duplicate Asset Isolation" 그룹은 Addressables Analyze의 중복 종속성 수정 기능이 만드는 이름과 같다. 실제로 Analyze로 만들었는지는 소스에서 확인 못함.
- 그룹 이름 `Shared Asstes`는 오타로 보이나 에셋 이름이므로 바꾸지 않았다.

## 4. 코드 해설

### 4.1 풀 생성: `PoolManager.Init()`

{% code title="Managers/PoolManager.cs (Init 일부)" %}
```csharp
string key = poolData.prefab.name;
ObjectPool<GameObject> pool = new(
    createFunc: () => { GameObject obj = InstantiateObject(poolData.prefab);
                        AddPoolableComponent(obj); return obj; },
    actionOnGet: obj => { obj.GetComponent<PoolableObject>()?.OnGetFromPool();
                          obj.SetActive(true); },
    actionOnRelease: obj => { OnRelease(obj);
                              obj.GetComponent<PoolableObject>()?.OnReturnToPool(); },
    actionOnDestroy: Destroy,
    collectionCheck: false,
    defaultCapacity: poolData.defaultSize,
    maxSize: poolData.maxSize);
...
for (int i = 0; i < poolData.defaultSize; i++)
{
    GameObject obj = InstantiateObject(poolData.prefab);
    AddPoolableComponent(obj);
    pool.Release(obj);   // 미리 만들어 풀에 넣는다
}
```
{% endcode %}

- **키는 프리팹 이름(`string`)이다.** 기존 조사 기록의 "키 선택" 미결 항목에 대한 답이다. `InstantiateObject`가 생성한 객체 이름을 `(Clone)` 없이 프리팹 이름으로 고정하므로 반납 때 `obj.name`으로 풀을 다시 찾는다.
- **기본 크기 문제의 해법.** 기존 기록은 `defaultSize`만 넘기면 씬에 1개뿐이었다고 적었다. 소스는 `defaultCapacity`를 넘기는 것에 더해 반복문으로 `defaultSize`개를 만들어 `Release`한다. 이 워밍업이 미리 생성을 맡는다.
- `Release`된 객체는 `OnRelease`에서 풀 전용 부모(`"<키> Pool"` 오브젝트) 아래로 옮겨지고 비활성화된다. 하이어라키 정리용이라고 주석에 적혀 있다.
- `collectionCheck: false`라 같은 객체의 중복 `Release`를 Unity가 검사하지 않는다. 대신 `PoolableObject.IsInPool`로 직접 막는다.

### 4.2 반납: `ReleaseObject`

{% code title="Managers/PoolManager.cs (ReleaseObject 요지)" %}
```csharp
var poolable = obj.GetComponent<PoolableObject>();
if (poolable == null) { Destroy(obj, delay); return; }   // 풀 밖 객체는 파괴
if (poolable.IsInPool) { Debug.LogWarning(...); return; } // 중복 반납 무시
if (_pools.ContainsKey(obj.name))
{
    if (delay <= 0f) _pools[obj.name].Release(obj);
    else StartCoroutine(CoReleaseObject(obj, obj.name, delay)); // 지연 반납
}
else Destroy(obj, delay);
```
{% endcode %}

- 풀에 없는 객체는 `Destroy`로 처리하므로 호출하는 쪽은 풀 여부를 구분하지 않아도 된다.
- 지연 반납 코루틴은 대기 후 `IsInPool`을 다시 검사한다.
- `GetObject`는 프리팹 또는 키, 부모, 위치·회전 조합의 오버로드 6개가 있다. 풀이 없으면 경고 후 `null`을 반환하므로 호출 쪽(`Instance.cs`)이 `null`을 검사한다.

### 4.3 몬스터 재사용: 상태 되돌리기

기존 기록의 "Death에서 Idle로 되돌리기" 문제는 `Blackboard.Init()`이 맡는다. `NavMeshAgent`의 정지와 경로를 풀고, 체력을 최대치로 되돌리고, 상태를 `Spawn`으로 설정하고, 디졸브 효과를 초기화하고, 타겟을 플레이어로 다시 잡는다. `RealeseObjectToPool()`이 래그돌·사망 이펙트를 끈 뒤 이 `Init()`을 호출하고 풀에 반납한다. `Instance` 노드는 꺼낸 객체가 `Enemy` 태그이면 `MonsterManager.AddMonster`로 등록하고 `NavMeshAgent.Warp`로 위치를 옮긴다.

{% hint style="warning" %}
CAUTION: 소스의 주석이 미해결 문제를 직접 적고 있다(코드 읽기, 실행 안 함). `AIController.cs`: "풀에 릴리즈한 뒤 다시 활성화될 때 몬스터가 동작하지 않는 문제"(TODO, `OnDisable`에서 `_isInit = false`). `GameManager.cs`: `PoolManager.ClearPools()` 호출을 주석 처리하고 "왜 풀 리셋하면 오류가 나지?"라고 적었다. `ClearPools`는 `_pools`만 비우고 `_poolParents`는 비우지 않는다.
{% endhint %}

{% hint style="info" %}
NOTE: `Init()`에서 `_poolParents.ContainsKey(parent.name)`은 `"<키> Pool"` 이름을 검사하는데 저장 키는 `key`라 검사가 항상 거짓이다. 키 중복은 앞의 `_pools.ContainsKey(key)`가 이미 걸러 동작에는 문제가 없어 보인다. `MonsterManager`는 `is not null`로 Unity 객체를 비교한다(파괴된 객체를 걸러내지 못할 수 있음). 모두 읽기만 했고 실행하지 않았다.
{% endhint %}

### 4.4 초기화 시점

`GameManager.EnterPrologue()`가 프롤로그를 재생하는 동안 `DungeonManager.Init()`, `PoolManager.Init()`, 플레이어 씬 로드를 순서대로 `await`한다. `Init`은 `IsInitialized`로 재호출을 막는다. 즉 풀 워밍업을 로딩·프롤로그 시간에 감춘다.

## 5. 따라 만들기 (풀링과 Addressables 그룹)

확인 상태: 미검증.

1. Addressables 패키지를 설치하고 Groups 창에서 기본 그룹을 만든다. 기대 결과: `Default Local Group`이 생긴다.
2. 씬 에셋은 `GameScene` 그룹, 여러 곳에서 쓰는 에셋은 `Shared` 그룹처럼 용도별 그룹으로 나눈다. 기대 결과: 그룹별 번들이 분리된다.
3. 번들 스키마에서 압축을 LZ4로, 빌드·로드 경로를 로컬로 맞춘다. 기대 결과: 로컬 번들만 만들어진다.
4. `Analyze`의 중복 종속성 검사를 실행하고 수정을 적용한다. 기대 결과: 중복 에셋이 별도 그룹으로 격리된다.
5. 풀링은 4.1~4.4를 따른다: 키를 프리팹 이름으로 한 `ObjectPool` 딕셔너리, `PoolableObject` 표식, 워밍업 반복문, `IsInPool` 중복 반납 방지, 반납 직전 `Init()`으로 상태 복구. 기대 결과: 같은 프리팹을 `Get`/`Release`해도 객체 수가 늘지 않는다.
6. 모바일용 URP 에셋을 따로 만들어 HDR 끔, 그림자 해상도·거리를 줄인다. 기대 결과: 프로젝트 Quality에서 모바일 레벨에 지정할 수 있다.
7. 실제 기기에서 프레임·메모리를 측정한다. 기대 결과: 값은 소스에 없어 직접 측정해야 한다.

## 6. 알려진 한계·주의

- 재활성화 후 몬스터 AI가 동작하지 않는 문제와 `ClearPools` 오류는 소스 주석에만 있고 원인·해결을 소스에서 확인 못함.
- 몬스터 재사용 시 `Init()`이 되돌리지 않는 값이 있는지는 소스에서 확인 못함.
- 성능 측정값은 소스에 없다.

## 7. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 최초 작성 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 풀 키를 프리팹 이름으로 정한 이유와, 재활성화 문제를 어떻게 풀었는지 적는다.
- [ ] 에셋을 그룹으로 나눈 기준은 무엇이고, 중복 에셋 문제를 어떻게 발견했는가?
- [ ] 모바일용 URP 에셋에서 어떤 값을 줄였고 실제 기기에서 효과를 확인했는가?
