# 아몬 2페이즈 영혼 감옥(Lockdown): 시전 한 번의 전체 수명

## 무엇을 하는가

아몬(Amon) 2페이즈 보스의 스킬이다. 에셋 설명(`5737a138` 시점)을 풀어 쓰면 다음과 같다.

1. 보스가 공중으로 떠올라 기를 모은다(`Casting`, 에셋 기준 7초).
2. 그동안 필드에 안전지대 하나와 잡몹이 계속 생긴다.
3. 시전이 끝나면 전역 폭발이 일어난다. 안전지대 안에 있던 플레이어만 피해를 받지 않는다(`Activate`).
4. 폭발 뒤 잡몹은 모두 죽고 보스는 원래 자리로 돌아간다.

`SkillData`를 상속한 ScriptableObject이고, `Casting`과 `Activate`는 코루틴이다. 안전지대 쪽 로직은 [안전지대](safe-zone.md) 문서에서 따로 다룬다.

{% hint style="info" %}
동작 설명은 코드를 읽고 쓴 것이다. Unity에서 실행해 확인하지 않았다(unverified).
{% endhint %}

## 왜 이렇게 설계했나

커밋 `d80d9ae9`, `7b289ce5`, `900df9f4`, `5737a138`을 순서대로 읽으면 "공유 ScriptableObject가 시전 하나의 수명을 책임지려면 무엇이 필요한가"가 보인다.

* **공유 인스턴스 문제.** `SkillData`는 같은 에셋을 여러 곳에서 쓰는 공유 인스턴스다. `_safeZone`, `_targets` 같은 필드에 이전 시전의 참조가 남으면 다음 시전이 오염된다. 그래서 `Casting` 시작과 `Activate` 끝에서 `ResetRuntimeState()`로 비운다(`d80d9ae9`).
* **중단 처리.** 몬스터가 피격으로 경직되면 FSM이 `StopCoroutine`으로 스킬을 끊는다. 코루틴이 중단되면 `finally`도 실행되지 않아서 이펙트, 안전지대, 잡몹, 공중에 뜬 보스가 그대로 남는다. 이를 위해 `SkillData`에 빈 가상 메서드 `OnInterrupt`를 추가했고, `MonsterFSM.ActHit`이 중단 전에 호출한다(`d80d9ae9`). 보스가 파괴될 때를 위해 `AmonPaseTwoFSM.OnDisable`에서도 같은 호출을 한다(`5737a138`).
* **아레나 앵커.** 워프 좌표와 스폰 좌표를 월드 절대값으로 두면 씬 안에서 아레나를 옮길 때마다 에셋을 고쳐야 한다. `Blackboard.ArenaAnchor`를 기준으로 한 로컬 좌표로 바꿔 데이터를 재사용할 수 있게 했다(`d80d9ae9`).
* **스폰 영역과 높이.** X/Z 범위 두 개와 Y를 따로 두던 필드를 `spawnAreaCenter`(중심)와 `spawnAreaSize`(크기)로 합쳤고, 보스가 뜨는 높이는 `warpHeight`로 분리했다. 에셋 주석에 따르면 너무 높으면 카메라에 잡히지 않기 때문이다(`7b289ce5`).
* **피해 하드코딩 제거.** 처음에는 플레이어 피해가 코드에 500으로 박혀 있어 에셋의 `damage`(400)와 어긋났다. 에셋 값을 쓰도록 고쳤다(`d80d9ae9`).
* **면제 판정 방식.** 처음에는 "안전지대가 준 무적 플래그"로 피해를 막았고, 폭발 뒤 플래그를 끄는 순서에 의존했다. 이후 안전지대에 "지금 안에 있는가"를 직접 묻는 방식(`IsProtecting`)으로 바꿨다(`5737a138`). 자세한 이유는 안전지대 문서에 있다.
* **잡몹 정리 마스크.** 정리 피해의 레이어 마스크를 에셋 필드 `targetMask`에서 `~0`(모든 레이어)로 바꿨다(`7b289ce5`). 코드 주석에는 "레이어와 무관하게 항상 적중하도록"이라고만 적혀 있어서, 무엇이 어긋났는지는 확인하지 못했다.

## 핵심 코드

{% code title="AmonLockdown.cs (Activate, 발췌)" %}
```csharp
Utils.Destroy(Utils.Instantiate(explosionEffectPrefab,
    data.Agent.transform.position + effectSpawnOffset,
    Quaternion.identity), ExplosionEffectLifetime);

GameObject playerObject = Managers.MonsterManager.Instance.Player;
if (playerObject != null && playerObject.TryGetComponent(out IDamagable target))
{
    bool sheltered = _safeZone != null
        && _safeZone.TryGetComponent(out SafeZoneObject zone)
        && playerObject.TryGetComponent(out PlayerController pc)
        && zone.IsProtecting(pc);

    if (!sheltered)
        target.ApplyDamage(damage, 1 << playerObject.layer);
}

// 안전지대는 피해 판정이 끝난 뒤 파괴한다.
Utils.Destroy(_safeZone, 1.0f);

foreach (IDamagable t in _targets)
    t?.ApplyDamage(MonsterCleanupDamage, AllLayers);

data.NavMeshAgent.Warp(AnchorToWorld(data.ArenaAnchor, defaultPosition));
ResetRuntimeState();
```
{% endcode %}

* 1~3줄: 폭발 이펙트를 만들고 2초 뒤 지운다.
* 5~6줄: 플레이어가 없거나 `IDamagable`이 아니면 피해 처리 전체를 건너뛴다.
* 8~11줄: `&&` 단락 평가로, 안전지대가 이미 없거나 컴포넌트가 없으면 `sheltered`는 `false`다. 안전지대 점유 여부를 직접 질의하는 부분이다.
* 13~14줄: 마스크를 플레이어 본인 레이어(`1 << playerObject.layer`)로 만든다. 마스크에 대상 레이어가 없으면 `ApplyDamage`가 무시하기 때문이다(이전 커밋의 코드 주석에 같은 설명이 있다).
* 17~18줄: 안전지대 파괴는 피해 판정 뒤로 미루고 1초 지연을 준다.
* 20~21줄: `_targets`에는 이미 파괴되어 `null`이 된 참조가 있을 수 있어 `t?.`로 건너뛴다. 모든 레이어를 대상으로 큰 피해(`10000`)를 준다.
* 23~24줄: 보스를 복귀시키고 런타임 상태를 비운다.

{% code title="AmonLockdown.cs (좌표와 상태 초기화, 발췌)" %}
```csharp
private static Vector3 AnchorToWorld(Transform anchor, Vector3 localPoint)
{
    return anchor != null ? anchor.TransformPoint(localPoint) : localPoint;
}

private Vector3 GetRandomSpawnPosition(Transform anchor)
{
    float halfWidth = spawnAreaSize.x * 0.5f;
    float halfDepth = spawnAreaSize.y * 0.5f;
    float x = spawnAreaCenter.x + Random.Range(-halfWidth, halfWidth);
    float z = spawnAreaCenter.z + Random.Range(-halfDepth, halfDepth);
    return AnchorToWorld(anchor, new Vector3(x, spawnAreaCenter.y, z));
}

private void ResetRuntimeState()
{
    _targets.Clear();
    _chargeEffect = null;
    _safeZone = null;
}
```
{% endcode %}

* `AnchorToWorld`는 앵커가 있으면 `TransformPoint`로 로컬을 월드로 바꾸고, 없으면 입력을 월드 좌표로 취급한다. 앵커가 회전돼 있어도 스폰 영역이 함께 돈다.
* `GetRandomSpawnPosition`은 중심 기준 사각형 안에서 X/Z를 무작위로 뽑고 높이는 고정한다.
* `ResetRuntimeState`는 참조만 비운다. 오브젝트 파괴는 호출하는 쪽의 책임이다.

## 따라 만들기

원본의 `Blackboard`, `NavMeshAgent`, 애니메이터 호출은 줄이고, 시전 수명 관리만 재현한다. 이 구조에서는 스킬을 MonoBehaviour로 시작해도 같은 흐름을 볼 수 있다.

1. 평평한 `Plane`(아레나)을 만들고 빈 오브젝트 `ArenaAnchor`를 그 중앙에 둔다. 확인 방법: 앵커를 이동/회전해도 하이어라키에서 위치가 바뀐다.
2. 플레이어(큐브 + `CharacterController` 또는 `Rigidbody`)에 태그 `Player`를 붙인다. 확인 방법: 태그가 인스펙터에 표시된다.
3. 보스 큐브에 `LockdownSkill`을 만들고 필드를 둔다: `warpHeight`, `spawnAreaCenter`, `spawnAreaSize`, `castTime`, `damage`, `monsterPrefabs`, `safeZonePrefab`, `monsterSpawnInterval`, `anchor`.
4. 위의 `AnchorToWorld`, `GetRandomSpawnPosition`, `ResetRuntimeState`를 옮긴다. 확인 방법: 스킬을 임시로 5번 호출해 스폰 위치를 `Debug.DrawLine`이나 구체로 표시하면 모두 영역 안에 들어간다. 앵커를 45도 돌려도 영역이 같이 돈다.
5. `Casting` 코루틴을 쓴다. `ResetRuntimeState` 호출 후 보스를 `anchor`의 `warpHeight` 높이로 옮기고, 안전지대를 만들고, `castTime` 동안 `monsterSpawnInterval`마다 몬스터 프리팹을 하나씩 만들어 리스트에 넣는다. 확인 방법: 7초 동안 1초마다 잡몹이 생긴다. 프리팹 리스트가 비어 있어도 예외가 나지 않는다.
6. `Activate` 코루틴에 위 발췌를 옮긴다. 확인 방법: 안전지대 밖에 서 있으면 콘솔에 피해 로그가 찍히고, 안에 서 있으면 찍히지 않는다.
7. `OnInterrupt`를 추가해 이펙트, 안전지대, 잡몹을 지우고 보스를 원위치로 돌린다. 시전 중에 `StopCoroutine`을 호출하는 테스트 버튼을 만들고 눌러 본다. 확인 방법: 버튼을 누르면 남는 오브젝트가 없고 보스가 공중에 멈춰 있지 않다. `OnInterrupt`를 일부러 빼고 같은 테스트를 해서 무엇이 남는지도 확인한다.
8. 연속 두 번 시전한다. 확인 방법: 두 번째 시전에서 첫 번째 시전의 잡몹 참조가 리스트에 남아 있지 않다(`_targets.Count`를 로그로 찍는다).

## 막히기 쉬운 곳과 한계

* `Activate`가 폭발 직후 `Utils.Destroy(_safeZone, 1.0f)`로 안전지대를 1초 늦게 지운다. 이 1초의 의도는 커밋 메시지나 주석에 없어서 확인하지 못했다.
* `OnInterrupt`는 `MonsterFSM.ActHit`과 `AmonPaseTwoFSM.OnDisable`에서만 호출된다. 다른 FSM이 이 스킬을 쓰면 호출을 직접 연결해야 한다.
* `AmonPaseTwoFSM.OnDisable`은 `try/catch`로 예외를 삼킨다. 정리 중 예외가 나도 알 수 없다.
* `Casting`에서 `NavMeshAgent.Warp`로 이동하므로 NavMesh 위가 아닌 좌표로는 보낼 수 없다. 공중 높이는 `warpHeight`로 올리는데, 이 높이가 NavMesh에서 얼마나 벗어나도 되는지는 확인하지 못했다.
* 파일 맨 위의 `#` 주석 블록은 `Activate` 설명이 옛 순서(안전지대 제거 후 피해 적용)로 남아 있어 현재 코드와 다르다.
* 같은 영역의 `AmonBarrier`(보호막)는 [폭발 피해와 배리어](explosion-damage.md) 문서에서 다룬다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] ScriptableObject에 런타임 상태(필드)를 두면 어떤 문제가 생기는가? 이 스킬은 그 문제를 어떻게 막았는가?
- [ ] `StopCoroutine`으로 끊긴 코루틴의 뒷정리를 어디서 책임지게 했는가? 다른 설계도 있다면 무엇인가?
- [ ] 월드 좌표 대신 앵커 로컬 좌표로 데이터를 저장하면 어떤 상황에서 이득을 보는가?
