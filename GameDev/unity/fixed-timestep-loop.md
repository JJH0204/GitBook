# [생성형 AI] 고정 타임스텝 누산기와 보간

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UNI-012-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | 게임 로직을 고정 간격으로 돌리는 누산기(accumulator) 구조와 렌더 보간을 이해한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (Unity에서 실행하지 않았다. 수식과 수치는 Python으로 계산해 확인했다) |
| 개정 | R1 (2026-11-19) |

## 1. 정의

프레임 시간이 들쭉날쭉해도 시뮬레이션(물리, 결정적 로직)은 같은 간격으로 계산해야 결과가 재현된다. 누산기 방식은 프레임 시간을 쌓아 두고, 고정 간격 `fdt`만큼 쌓일 때마다 로직을 한 번 실행한다. Unity의 `FixedUpdate`가 같은 구조로 동작한다. 직접 구현은 서버 시뮬레이션이나 프레임 독립 로직이 필요할 때 쓴다.

## 2. 구성 요소

| 요소 | 설명 |
|---|---|
| `fdt` | 고정 간격. 예: 0.02초(50회/초) |
| `acc` | 아직 소비하지 않은 시간 |
| 프레임 시간 상한 | 한 프레임에 쌓을 시간의 최댓값. 상한이 없으면 긴 프레임 뒤에 로직이 연속 호출되어 더 느려진다(죽음의 나선) |
| 보간 계수 `alpha` | `acc / fdt`. 마지막 두 상태 사이 렌더 위치를 정한다 |

## 3. 동작 원리

### 3.1 구조

```csharp
public class FixedLoop : MonoBehaviour
{
    const float Fdt = 0.02f;
    const float MaxFrame = 0.25f;     // 한 프레임에 쌓는 시간의 상한
    float acc;
    Vector3 prev, curr;               // 직전·현재 시뮬레이션 상태

    void Update()
    {
        acc += Mathf.Min(Time.unscaledDeltaTime, MaxFrame);
        while (acc >= Fdt)
        {
            prev = curr;
            curr = Step(curr, Fdt);   // 로직 1회
            acc -= Fdt;
        }
        float alpha = acc / Fdt;
        transform.position = Vector3.Lerp(prev, curr, alpha);   // 렌더용 보간
    }

    Vector3 Step(Vector3 s, float dt) => s + Vector3.right * dt;
}
```

### 3.2 호출 횟수 (Python으로 확인, `fdt = 0.02`, 상한 0.25)

| 입력 프레임 | 로직 호출 수 | 남은 시간 |
|---|---|---|
| 1/60초 프레임 60개(합 1초) | 49회 | 약 0.02초 |
| 1/30초 프레임 30개(합 1초) | 49회 | 약 0.02초 |
| 0.5초 프레임 1개 | 12회 | 0.01초 |

1초에 50회가 아니라 49회가 나온 것은 부동소수점 오차로 마지막 호출이 다음 프레임으로 넘어갔기 때문이다(남은 시간이 0.02에 가깝다). 프레임 속도가 달라도 호출 수가 같다는 점이 핵심이다. 0.5초 프레임은 상한 0.25로 잘려 12회만 실행된다. 대신 그만큼 게임 시간이 늦어진다.

### 3.3 보간이 필요한 이유

로직이 50Hz이고 화면이 144Hz이면 일부 프레임은 로직 갱신 없이 그려진다. 보간을 하지 않으면 같은 위치가 반복되어 끊겨 보인다. 보간하면 화면은 항상 직전 로직 상태와 현재 상태 사이를 그리므로 한 로직 간격만큼 늦지만 부드럽다.

### 3.4 Unity 내장 기능과 관계

| 항목 | 내용 |
|---|---|
| `FixedUpdate` | 같은 누산기 구조. 프레임당 여러 번 호출될 수 있다 |
| 상한 | Time 설정의 Maximum Allowed Timestep이 같은 역할을 한다. 기본값은 버전 확인 필요 |
| 렌더 보간 | `Rigidbody.interpolation = RigidbodyInterpolation.Interpolate`가 같은 목적이다 |

{% hint style="info" %}
NOTE: 대부분의 게임은 `FixedUpdate`와 `Rigidbody` 보간으로 충분하다. 직접 구현은 결정적 재현(리플레이, 롤백 네트코드)이 필요할 때 검토한다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 누산기 | 쓰지 않은 시간을 쌓아 두는 변수 |
| 죽음의 나선 | 계산이 늦어져 다음 프레임에 더 많이 계산하다 더 늦어지는 현상 |
| 결정적 | 같은 입력이 항상 같은 결과를 내는 성질 |

## 5. 더 보기

* [시간: deltaTime, fixedDeltaTime, timeScale](time-deltatime.md)
* [리지드바디 캐릭터 이동 구현](rigidbody.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 고정 간격으로 로직을 돌리는 이유를 자신의 말로 설명한다.
- [ ] 직접 만들어 보고 싶은 결정적 시뮬레이션(리플레이 등)이 있으면 쓴다.
