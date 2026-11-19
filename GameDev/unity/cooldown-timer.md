# [생성형 AI] 쿨타임과 타이머 패턴

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UNI-013-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | 스킬 쿨타임, 지연 실행, 지속 시간 같은 타이머를 `Time` 비교와 카운트다운으로 구현하는 패턴을 이해한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (Unity에서 실행하지 않았다. 수식과 수치는 Python으로 계산해 확인했다) |
| 개정 | R1 (2026-11-19) |

## 1. 정의

쿨타임은 한 번 쓴 뒤 일정 시간 다시 쓰지 못하게 하는 규칙이다. 구현은 마지막 사용 시각과 현재 시각을 비교하거나, 남은 시간을 `deltaTime`으로 줄이는 두 방식이 있다.

## 2. 구성 요소

| 방식 | 코드 | 장점 | 단점 |
|---|---|---|---|
| 시각 비교 | `Time.time - lastUse >= cooldown` | 변수 하나, `Update` 불필요 | 남은 시간은 계산해야 한다 |
| 카운트다운 | `remaining -= Time.deltaTime` | 남은 시간을 바로 UI에 쓴다 | 매 프레임 갱신이 필요하다 |
| 코루틴 | `yield return new WaitForSeconds(t)` | 순차 연출에 편하다 | 오브젝트가 비활성화되면 멈춘다 |

## 3. 동작 원리

### 3.1 시각 비교

```csharp
public class Skill : MonoBehaviour
{
    [SerializeField] float cooldown = 0.5f;
    float lastUse = float.NegativeInfinity;   // 첫 사용은 항상 가능하게

    public bool TryUse()
    {
        if (Time.time - lastUse < cooldown) return false;
        lastUse = Time.time;
        Fire();
        return true;
    }

    public float Remaining01 => Mathf.Clamp01(1f - (Time.time - lastUse) / cooldown);

    void Fire() { /* 발사 */ }
}
```

0.1초 간격으로 시간을 올리며 쿨타임 0.5초 로직을 시뮬레이션한 결과(Python으로 확인), 사용 가능 시각은 0.0, 0.5, 1.0, 1.5, 2.0초였다. 부동소수점 비교가 경계에서 흔들릴 수 있어, 확인에는 작은 허용 오차(예: `1e-9`)를 두었다.

### 3.2 UI에 표시

`Remaining01`을 `Image.fillAmount`(Image Type이 `Filled`일 때)에 넣으면 시계 방향으로 차오르는 쿨타임 표시가 된다.

```csharp
cooldownImage.fillAmount = skill.Remaining01;   // 1이면 가득, 0이면 비어 있음
```

### 3.3 어떤 시간을 쓸 것인가

| 시간 | `timeScale` 0일 때 | 쓰임새 |
|---|---|---|
| `Time.time` | 멈춘다 | 일반 전투 쿨타임. 일시정지 중 흐르면 안 된다 |
| `Time.unscaledTime` | 흐른다 | UI 연출, 실시간 쿨타임 |

### 3.4 자주 겪는 문제

| 증상 | 원인과 대응 |
|---|---|
| 첫 사용이 막힘 | `lastUse` 초기값이 0이면 시작 직후 `Time.time`이 쿨타임보다 작아 막힌다. `float.NegativeInfinity`로 둔다 |
| 씬 전환 뒤 이상한 값 | `Time.time`은 앱 시작 기준이라 저장·복원에 적합하지 않다. 저장은 남은 시간을 쓴다 |
| 쿨타임 감소 아이템 | 시각 비교는 `cooldown` 값만 바꾸면 되지만 진행 중인 쿨타임의 처리 방식을 기획에서 정한다 |

{% hint style="info" %}
NOTE: 서버가 판정하는 게임은 클라이언트 `Time.time`을 믿지 않는다. 서버 시각으로 쿨타임을 검증한다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 쿨타임 | 재사용 대기 시간 |
| `Time.time` | 게임 시작 후 `timeScale`이 반영된 경과 시간 |
| `fillAmount` | `Image`가 채워지는 비율(0~1) |

## 5. 더 보기

* [시간: deltaTime, fixedDeltaTime, timeScale](time-deltatime.md)
* [스킬 쿨타임 대비 DPS](../game-design/01-system-design/balance-b3-skill-dps.md)
* [Unity 코루틴의 내부](../unity-csharp/day08-unity-coroutine.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 쿨타임을 시각 비교와 카운트다운으로 만들 때 각각 어떤 상황에 맞는지 자신의 말로 쓴다.
- [ ] 자신이 좋아하는 게임의 쿨타임 규칙(감소, 초기화 등)을 하나 적고 구현 방식을 추측한다.
