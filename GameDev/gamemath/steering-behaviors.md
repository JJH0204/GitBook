# [생성형 AI] 스티어링 기초: Seek, Flee, Arrive

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-MTH-012-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | 목표를 향하거나 피하거나 멈추는 이동을 속도 차이(조향)로 구현하는 방법을 이해한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (Unity에서 실행하지 않았다. 수식과 수치는 Python으로 계산해 확인했다) |
| 개정 | R1 (2026-11-19) |

## 1. 정의

스티어링(steering)은 위치를 직접 옮기는 대신 속도를 서서히 원하는 속도로 바꾸는 이동 방식이다. 급격한 방향 전환 없이 자연스러운 곡선 이동이 나온다. 길 찾기 알고리즘이 정한 경로를 따라갈 때 개별 이동 단계로도 쓴다.

## 2. 구성 요소

| 행동 | 원하는 속도(desired) |
|---|---|
| Seek | `normalize(target - pos) * maxSpeed` |
| Flee | Seek의 반대 방향 |
| Arrive | 목표 가까이에서 속도를 거리에 비례해 줄인다 |

조향량은 `steering = desired - velocity`이고, 이것을 최대 힘(`maxForce`)으로 제한해 속도에 더한다.

## 3. 동작 원리

### 3.1 Seek와 Arrive

Seek는 목표를 지나친 뒤 되돌아오며 진동한다. Arrive는 정지 반경 `radius` 안에서 원하는 속도를 `maxSpeed * distance / radius`로 줄여 목표에서 멈춘다.

```csharp
public class SteeringAgent : MonoBehaviour
{
    [SerializeField] Transform target;
    [SerializeField] float maxSpeed = 4f;
    [SerializeField] float maxForce = 10f;
    [SerializeField] float slowRadius = 3f;
    Vector3 velocity;

    void Update()
    {
        Vector3 toTarget = target.position - transform.position;
        float dist = toTarget.magnitude;
        if (dist < 0.01f) { velocity = Vector3.zero; return; }

        float speed = dist > slowRadius ? maxSpeed : maxSpeed * dist / slowRadius;
        Vector3 desired = toTarget / dist * speed;

        Vector3 steering = Vector3.ClampMagnitude(desired - velocity, maxForce * Time.deltaTime);
        velocity = Vector3.ClampMagnitude(velocity + steering, maxSpeed);
        transform.position += velocity * Time.deltaTime;
    }
}
```

### 3.2 1차원 수치 검증

Python으로 1차원에서 목표 10까지 Arrive를 2000단계(`dt = 0.02`) 시뮬레이션했다. 정지 반경 3, 최대 속도 4, 속도 보정 계수 5(`vel += (desired - vel) * min(1, 5·dt)`)로 마지막 위치 10.0, 속도 0에 수렴했다. 위 C# 코드는 조향 제한 방식이 달라 이 시뮬레이션과 같은 수치가 나오는지 확인하지 않았다.

### 3.3 선택 기준

| 상황 | 선택 |
|---|---|
| 목표에 닿아 멈춰야 함 | Arrive |
| 계속 쫓아야 함 | Seek |
| 위험에서 벗어남 | Flee |
| 장애물이 있음 | `NavMeshAgent`나 경로 탐색으로 경로를 먼저 구하고 각 지점을 Arrive로 따라간다 |

{% hint style="info" %}
NOTE: 3D 지형 위 캐릭터는 높이 처리가 필요하다. `y` 성분을 0으로 둘지 `CharacterController`와 함께 쓸지를 정한다. 이 문서는 이동 방향 계산만 다룬다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 조향 | 현재 속도와 원하는 속도의 차이로 방향을 바꾸는 일 |
| 정지 반경 | 감속을 시작하는 거리 |

## 5. 더 보기

* [내비메시 에이전트 클릭 이동](../unity/navmeshagent.md)
* [격자 경로 탐색: A*](pathfinding-astar.md)
* [시간: deltaTime, fixedDeltaTime, timeScale](../unity/time-deltatime.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] Seek와 Arrive의 움직임이 어떻게 다른지 자신의 말로 설명한다.
- [ ] 적 AI가 플레이어에게 다가올 때 어떤 움직임이 자연스러울지 쓴다.
