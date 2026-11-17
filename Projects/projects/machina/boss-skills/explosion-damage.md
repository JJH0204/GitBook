# 폭발 피해 반경과 배리어 비활성화

## 무엇을 하는가

이 문서는 보스 패턴 오브젝트 두 개의 "피해가 맞는 조건" 수정을 다룬다.

* `SoulSphereObject`: 영혼 구체. 수명이 다하면 폭발하고, 폭발 반경 안의 플레이어에게만 피해를 준다. 플레이어가 먼저 부수면 폭발하지 않는다.
* `AmonBarrier`: 아몬의 보호막. 최대 체력의 10%를 흡수하고, 다 소진되면 스스로 파괴되면서 콜백을 호출한다.

두 수정은 서로 다른 커밋(`06bf7474`, `a755bdc2`)이지만 "조건이 빠져 있어서 항상 맞거나 늦게 반응한다"는 같은 종류의 버그다.

{% hint style="info" %}
동작 설명은 코드를 읽고 쓴 것이다. Unity에서 실행해 확인하지 않았다(unverified).
{% endhint %}

## 왜 이렇게 설계했나

### 폭발 반경(`06bf7474`)

수정 전 `ExplosionObject`는 플레이어를 찾아 바로 `ApplyDamage`를 호출했다. 거리 검사가 없어서 구체가 맵 반대편에서 터져도 플레이어가 맞았다. 수정 후에는 구체와 플레이어 사이의 거리를 직접 재서 `explosionRadius` 안일 때만 피해를 준다. 반경은 `[SerializeField]`로 열어서 프리팹마다 조절한다(기본 5).

물리 쿼리(`OverlapSphere`)를 쓰지 않고 플레이어 한 명의 위치만 비교한 것은, 대상이 항상 한 명이기 때문이다. 물리 쿼리는 레이어 설정과 콜라이더 배치에 결과가 좌우된다. 이 선택의 이유가 커밋에 적혀 있지는 않아서 위 문장은 코드 구조에서 읽은 추정이다.

같은 커밋은 쓰이지 않던 옛 영혼 구체 파일 세 개(스킬 스크립트 하나, `MonoBehaviour` 스크립트 하나, 스킬 에셋 하나)를 지웠다. 삭제된 컴포넌트는 `Update` 안에 비어 있는 분기만 있는 미완성 코드였다.

### 배리어 비활성화(`a755bdc2`)

수정 전 `AmonBarrier`에는 세 가지 문제가 있었다.

1. `Update`가 매 프레임 체력을 검사해 파괴했다. 파괴 결정이 피해를 받은 시점이 아니라 다음 프레임이라서, 그 사이에 들어온 피해가 계속 적용될 수 있었다. 수정 후에는 `ApplyDamage` 안에서 즉시 `Deactivate()`를 부른다.
2. `_isActive` 플래그가 있었지만 피해를 막는 곳에는 쓰이지 않았다. 수정 후에는 `ApplyDamage` 맨 앞에서 비활성 상태면 돌려보낸다.
3. 초기 체력이 `maxHealth`(몬스터 최대 체력 전체)로 들어갔다. 바로 윗줄에서 10%로 계산한 `_maxHealth`를 쓰지 않은 오타성 버그였다. 주석의 "최대 체력의 10%"와 맞도록 고쳤다.

## 핵심 코드

{% code title="SoulSphereObject.cs (ExplosionObject)" %}
```csharp
[Tooltip("폭발 시 플레이어에게 데미지를 주는 반경. 이 범위 밖이면 피해를 받지 않는다.")]
[SerializeField] private float explosionRadius = 5.0f;

private void ExplosionObject()
{
    GameObject playerObject = Managers.MonsterManager.Instance.Player;
    if (playerObject != null)
    {
        float sqrDistance = (playerObject.transform.position - transform.position).sqrMagnitude;
        if (sqrDistance <= explosionRadius * explosionRadius
            && playerObject.TryGetComponent(out PlayerController player))
        {
            player.ApplyDamage(_damage, 1 << playerObject.layer);
        }
    }

    Utils.Destroy(Utils.Instantiate(explosionPrefab, transform.position, Quaternion.identity), 1.5f);
    Utils.Destroy(gameObject);
}
```
{% endcode %}

* 9줄: `sqrMagnitude`는 제곱근을 구하지 않는 거리의 제곱이다. 비교 대상도 `explosionRadius * explosionRadius`로 제곱해서 맞춘다.
* 10~11줄: 거리 조건과 컴포넌트 조회를 한 `if`로 묶었다. `TryGetComponent`는 실패해도 예외나 `null` 경고를 내지 않는다.
* 13줄: 피해 마스크를 하드코딩 레이어 이름(`LayerMask.NameToLayer("Player")`) 대신 플레이어 본인의 `layer`로 만든다. 레이어 이름이 바뀌어도 깨지지 않는다.
* 17~18줄: 피해가 없어도 폭발 이펙트와 자기 파괴는 항상 실행한다.
* 거리는 3D로 잰다. 구체가 공중에 떠 있으면 높이 차이도 거리에 포함된다.

{% code title="AmonBarrier.cs (수정 후)" %}
```csharp
public void ApplyDamage(float inDamage, LayerMask targetMask = default,
    float unitOfTime = 1, float defenceIgnoreRate = 0)
{
    if (!_isActive) return;    // 파괴 예약 상태에서는 피해를 받지 않는다

    _currentBarrierHealth -= Mathf.CeilToInt(inDamage);

    if (_currentBarrierHealth <= 0)
        Deactivate();
}

private void Deactivate()
{
    if (!_isActive) return;
    _isActive = false;    // 추가 피격/중복 파괴를 즉시 차단
    Destroy(gameObject);
}

public void Initialize(float maxHealth, Action onDestroy = null)
{
    _maxHealth = maxHealth * 0.1f;
    OnBarrierDestroy = onDestroy;
    _currentBarrierHealth = Mathf.CeilToInt(_maxHealth);
    _isActive = true;
}

private void OnDestroy()
{
    OnBarrierDestroy?.Invoke();
}
```
{% endcode %}

* 4줄: 맨 앞의 가드가 이후 모든 로직을 막는 방어선이다.
* 8~9줄: 체력 검사를 `Update`에서 `ApplyDamage` 안으로 옮겨 "피해를 받은 즉시" 판단한다.
* 14~16줄: 가드를 한 번 더 두는 이유는 `Deactivate`가 다른 경로에서도 불릴 수 있기 때문이다. `_isActive`를 먼저 내리고 `Destroy`를 부르므로 중복 호출이 안전하다.
* 21~23줄: 흡수량을 최대 체력의 10%로 계산해서 `_currentBarrierHealth`에 넣는다(이전에는 100%였다).
* 27줄: 파괴 콜백은 `OnDestroy`에서 한 번 부른다. 콜백으로 "캐스팅 취소" 같은 후속 처리를 연결하는 설계다. 연결하는 쪽 코드는 이 영역의 대상 파일이 아니라서 읽지 않았다.

현재 `main`의 `AmonBarrier`에는 수정 커밋(`a755bdc2`)에 있던 "받는 피해 50% 감소" 줄이 없다. 클래스 상단 주석에는 아직 50% 감소가 적혀 있으니 주석과 코드가 어긋나 있다. 그 줄이 언제 왜 빠졌는지는 확인하지 못했다.

## 따라 만들기

1. 빈 씬에 `Player` 태그를 단 캡슐과 `explosionPrefab`용 파티클(아무 구체여도 된다)을 만든다. 확인 방법: 플레이어를 방향키로 움직일 수 있다.
2. `PlayerController`에 `ApplyDamage(float damage, LayerMask mask)`를 두고, 마스크에 자기 레이어가 있을 때만 `Debug.Log`로 피해를 출력하게 한다. 확인 방법: 마스크 없이 호출하면 로그가 없다.
3. 구체 프리팹에 `SoulSphereObject`를 붙이고 `lifeTime`을 3초로 둔다. 원본은 `Update`에서 시간을 누적한다. 같은 방식으로 쓴다. `Init(damage)` 메서드도 만들어 `_damage`를 넣는다. 확인 방법: 구체가 3초 뒤 터지고 사라진다.
4. 거리 검사 없는 버전(`player.ApplyDamage(_damage, ...)`만 호출)을 먼저 만든다. 확인 방법: 플레이어를 멀리 두어도 피해 로그가 찍힌다. 버그를 직접 재현해 보는 단계다.
5. 거리 검사를 추가한다. 확인 방법: 5 안이면 로그가 찍히고 밖이면 안 찍힌다. `explosionRadius`를 인스펙터에서 바꾸며 경계를 확인한다. 씬 뷰에서 `OnDrawGizmosSelected`에 `Gizmos.DrawWireSphere`를 그려 두면 편하다.
6. 배리어를 만든다. 큐브에 `AmonBarrier`를 붙이고 `Initialize(1000, () => Debug.Log("배리어 파괴"))`를 호출한다. 흡수량은 1000의 10%인 100이다. 확인 방법: `ApplyDamage(30)`을 세 번 호출하면 남은 흡수량이 10이고 콜백은 아직 없다. 네 번째 호출에서 "배리어 파괴"가 한 번 찍힌다.
7. 중복 호출을 확인한다. 파괴 직후 같은 프레임에 `ApplyDamage`를 한 번 더 호출한다. 확인 방법: 콜백이 두 번 불리지 않는다. 수정 전 초기값(`maxHealth` 그대로, 1000)으로 바꿔 보면 흡수량이 10배가 되어 파괴까지 훨씬 오래 걸리는 것을 볼 수 있다.
8. 옛 방식을 비교한다. `ApplyDamage`에서 즉시 파괴하는 대신 `Update`에서 검사하는 버전을 만들고, 한 프레임에 피해를 두 번 넣어 본다. 확인 방법: 콜백 호출 횟수와 피해 로그 횟수가 달라진다.

## 막히기 쉬운 곳과 한계

* 구체가 풀링(Pooling)되면 `Start`에서 한 번만 하는 이벤트 구독, 누적된 `_currentTime` 등이 재사용 시 남는다. 코드에도 "추후 Pooling할 경우 수정 필요"라는 주석이 있다.
* 폭발 반경 검사는 플레이어 한 명 기준이고 구체 중심과 플레이어 피벗(발 위치일 가능성이 크다) 사이의 거리다. 큰 캐릭터의 가장자리는 반영하지 않는다.
* `ExplosionObject`는 `Update`에서 `lifeTime`이 지난 모든 프레임에서 호출될 수 있는 구조다. 호출 직후 `Destroy`로 오브젝트가 사라지므로 보통은 한 번이지만, `Utils.Destroy`가 즉시 파괴가 아니라 풀 반납 등 다른 동작이라면 중복될 수 있다. `Utils.Destroy`의 구현은 읽지 않았다.
* 배리어 흡수량은 정수(`int`)다. `CeilToInt`로 올림하므로 작은 소수 피해도 최소 1이 깎인다.
* 콜백 `OnBarrierDestroy`는 `Destroy`가 아니라 `OnDestroy`에서 불리므로, 씬 전환 등 다른 이유로 오브젝트가 사라질 때도 호출된다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 거리 검사가 빠진 폭발 버그를 내가 만들었다면 플레이 중 어떤 증상으로 발견했을 것 같은가?
- [ ] `Update`로 상태를 폴링하는 방식과 `ApplyDamage` 안에서 즉시 처리하는 방식의 차이를 한 문장으로 말해 보라.
- [ ] 비활성 플래그(`_isActive`)를 두는 이유는 무엇이고, 나는 어떤 오브젝트에서 비슷한 플래그를 써 봤는가?
