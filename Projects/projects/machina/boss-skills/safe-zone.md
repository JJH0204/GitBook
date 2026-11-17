# 안전지대(SafeZone)와 무적 참조 카운트

## 무엇을 하는가

플레이어가 들어가면 무적이 되고 나오면 무적이 풀리는 트리거 영역이다. [영혼 감옥](amon-lockdown.md) 스킬의 "폭발을 피하는 장소"로 쓰인다. 구성 요소는 두 개다.

* `SafeZoneObject`: 트리거 콜라이더에 붙는 컴포넌트. 안에 있는 플레이어를 `HashSet`으로 기억한다.
* `PlayerController.AddInvincibility()` / `RemoveInvincibility()`: 무적을 "출처별 카운트"로 관리한다.

{% hint style="info" %}
동작 설명은 코드를 읽고 쓴 것이다. Unity에서 실행해 확인하지 않았다(unverified).
{% endhint %}

## 왜 이렇게 설계했나

처음 구현은 단순했다. 들어가면 `SetPlayerState(Invincibility, true)`, 나오면 `false`. 이 방식은 두 가지 이유로 단계적으로 고쳐졌다.

1. **다른 무적을 같이 꺼 버린다(`7b289ce5`).** 테스트 도구가 켜 둔 무적(자세한 내용은 [씬 테스트 도구](scene-test-tools.md))이나 대시 무적 프레임도 같은 `Invincibility` 플래그를 쓴다. 안전지대에서 나오는 순간 모두 꺼진다. 임시 해결로 `TestManager.PlayerInvincible`이 켜져 있으면 해제를 건너뛰었다. 이 방식은 게임 로직(안전지대, 스킬)이 테스트 클래스를 직접 참조하게 만든다.
2. **`OnTriggerExit`가 항상 오지 않는다(`5737a138`).** 안전지대 오브젝트가 파괴되거나 비활성화될 때는 `OnTriggerExit`가 보장되지 않는다. 안에 있던 플레이어의 무적이 영원히 남을 수 있다. 그래서 점유자 집합을 들고 있다가 `OnDisable`에서 직접 해제한다.

두 문제를 한꺼번에 푼 것이 **참조 카운트**다. 무적을 주는 쪽이 각자 `Add`/`Remove`를 짝으로 호출하고, 카운트가 0이 되고 테스트 무적도 아닐 때만 플래그를 끈다. 어느 한 출처가 다른 출처의 무적을 끄지 못한다.

또 하나의 변화는 폭발 피해 면제 판정이다. 예전에는 "무적 상태인가"를 피해 함수 안에서 보게 했고, 그래서 안전지대를 지우는 순서가 결과를 바꿨다. 이제는 폭발 쪽이 `IsProtecting(player)`로 "이 순간 안에 있는가"를 직접 묻는다. 무적 플래그와 피해 면제가 분리되어서 순서에 덜 민감하다.

## 핵심 코드

{% code title="SafeZoneObject.cs" %}
```csharp
using System.Collections.Generic;
using UnityEngine;

public class SafeZoneObject : MonoBehaviour
{
    private readonly HashSet<PlayerController> _occupants = new();

    public bool IsProtecting(PlayerController player)
    {
        return player != null && _occupants.Contains(player);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (!other.transform.CompareTag("Player")) return;
        PlayerController player = other.GetComponent<PlayerController>();
        if (player && _occupants.Add(player))
            player.AddInvincibility();
    }

    private void OnTriggerExit(Collider other)
    {
        if (!other.transform.CompareTag("Player")) return;
        PlayerController player = other.GetComponent<PlayerController>();
        if (player && _occupants.Remove(player))
            player.RemoveInvincibility();
    }

    private void OnDisable()
    {
        foreach (PlayerController player in _occupants)
            if (player) player.RemoveInvincibility();
        _occupants.Clear();
    }
}
```
{% endcode %}

* 6줄: 영역 안의 플레이어 집합. `HashSet.Add`/`Remove`는 실제로 바뀐 때만 `true`를 돌려준다.
* 17~18줄, 25~26줄: `Add`가 `true`일 때만 카운트를 올리고, `Remove`가 `true`일 때만 내린다. 콜라이더가 여러 개라서 `OnTriggerEnter`가 중복 호출되어도 카운트가 두 번 오르지 않는다.
* 29~33줄: `OnDisable`은 오브젝트가 파괴되거나 비활성화될 때 모두 불린다. 남아 있는 점유자를 순회하며 카운트를 돌려준다. `if (player)`는 플레이어가 먼저 파괴된 경우를 거른다.
* 8~11줄: 외부에서 무적 플래그를 거치지 않고 점유를 질의하는 통로다.

{% code title="PlayerController.cs (무적 카운트 부분, 발췌)" %}
```csharp
private int _invincibilityRefCount = 0;

public void AddInvincibility()
{
    _invincibilityRefCount++;
    _currentPlayerState |= EPlayerState.Invincibility;
}

public void RemoveInvincibility()
{
    _invincibilityRefCount = Mathf.Max(0, _invincibilityRefCount - 1);
    // 남은 출처가 없고 테스트 무적도 아닐 때만 실제로 해제한다.
    if (_invincibilityRefCount == 0 && !TestManager.PlayerInvincible)
    {
        _currentPlayerState &= ~EPlayerState.Invincibility;
    }
}

private IEnumerator CoStartInvincibility(float duration)
{
    AddInvincibility();
    yield return new WaitForSeconds(duration);
    RemoveInvincibility();
}
```
{% endcode %}

* `_currentPlayerState`는 `[Flags]` 열거형 비트 마스크다. `|=`로 켜고 `&= ~`로 끈다.
* `Mathf.Max(0, ...)`는 `Remove`가 `Add`보다 많이 불려도 카운트가 음수가 되지 않게 한다.
* 마지막 조건에 `TestManager.PlayerInvincible`이 남아 있어서 테스트 무적은 계속 유지된다. 이 결합은 "게임 코드가 테스트 클래스를 안다"는 점에서 완전히 깔끔하지는 않다.
* 스폰 i-frame 코루틴(`CoStartInvincibility`)도 같은 쌍을 쓰도록 바뀌었다. 같은 커밋에서 `Spawn()`과 `Die()`는 카운트를 0으로 초기화한다.

## 따라 만들기

1. 플레이어 큐브에 `Player` 태그, `CharacterController`, 그리고 `PlayerController`를 만든다. `PlayerController`에는 `[Flags] enum EPlayerState { Idle = 0, Invincibility = 1 << 0, Dead = 1 << 1 }`, `_currentPlayerState` 필드, `IsInvincible` 읽기 속성을 둔다. 확인 방법: 인스펙터에서 디버그용으로 `IsInvincible`을 `OnGUI`에 표시한다.
2. `AddInvincibility`/`RemoveInvincibility`를 위 발췌처럼 쓴다. `TestManager.PlayerInvincible`은 일단 `static bool` 하나를 가진 빈 클래스로 만든다. 확인 방법: 테스트 버튼으로 `Add` 두 번, `Remove` 한 번을 호출하면 여전히 무적이고, 한 번 더 `Remove`하면 해제된다.
3. 바닥에 큐브를 놓고 `Is Trigger`를 켠 뒤 `SafeZoneObject`를 붙인다. 플레이어 쪽에는 `Rigidbody` 또는 `CharacterController`가 있어야 트리거 이벤트가 온다(`CharacterController`는 트리거 이벤트를 받을 수 있다). 확인 방법: 영역에 들어가면 화면의 `IsInvincible`이 켜지고 나오면 꺼진다.
4. 무적을 두 출처에서 겹쳐 본다. 영역 안에서 `CoStartInvincibility(1)`을 호출한다. 확인 방법: 1초 뒤에도 영역 안이므로 무적이 유지되고, 영역에서 나가는 순간 꺼진다. 단순 `true/false` 방식으로 바꿔 같은 실험을 하면 1초 뒤 꺼지는 것을 볼 수 있다.
5. 파괴 시 정리를 확인한다. 영역 안에 선 채로 안전지대 오브젝트를 `Destroy`한다. 확인 방법: 무적이 풀린다. `OnDisable`을 주석 처리하고 같은 실험을 하면 무적이 남는 것을 본다.
6. `IsProtecting`을 쓰는 폭발 호출부를 만든다. 확인 방법: 영역 안에서 폭발 함수를 부르면 피해 로그가 없고, 밖에서 부르면 있다.

## 막히기 쉬운 곳과 한계

* `OnTriggerEnter`/`Exit`는 양쪽에 콜라이더와 (둘 중 하나에) 리지드바디가 있어야 온다. 안 오면 가장 먼저 의심한다.
* `AddInvincibility`와 `RemoveInvincibility`는 짝이 맞아야 한다. 호출부가 늘면 짝이 틀어질 수 있다. 이 구조는 "새는 카운트"를 막아 주지 않는다.
* `SetPlayerState(Invincibility, true/false)`로 직접 플래그를 바꾸는 경로는 카운트를 거치지 않는다. 무적 모드 컴포넌트가 이 경로를 쓰고, 이는 [씬 테스트 도구](scene-test-tools.md)에서 설명한다.
* 플레이어가 두 명 이상인 경우를 가정한 `HashSet` 구조이지만, 게임에서 플레이어는 한 명이므로 다인 상황은 확인하지 못했다.
* `OnDisable`은 에디터에서 플레이 종료 시에도 불리므로 로그/상태에 영향이 없는지 확인한다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 불리언 플래그 대신 참조 카운트가 필요한 상황을 내 프로젝트의 사례로 하나 들어 보라.
- [ ] `OnTriggerExit`만 믿으면 어떤 경우에 상태가 남는가? 직접 겪었거나 상상한 사례를 적어 보라.
- [ ] "무적 상태를 확인한다"와 "안전지대 안에 있는지 직접 묻는다"의 차이는 무엇이고, 후자가 낫다고 생각하는가?
