# [생성형 AI] 쿼터니언과 회전

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-MTH-003-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | Unity에서 회전을 표현하는 `Quaternion`의 구조와 자주 쓰는 API를 구분한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (Unity에서 실행하지 않았다. 수식 값은 Python으로 계산해 확인했다) |
| 개정 | R1 (2026-11-19) |

## 1. 정의

쿼터니언(Quaternion)은 3D 회전을 네 개의 수 (x, y, z, w)로 나타내는 방식이다. 축 `a`(단위 벡터)를 중심으로 각도 θ만큼 회전하는 쿼터니언은 다음과 같다.

```
(x, y, z) = a * sin(θ/2)
w         = cos(θ/2)
```

`Transform.rotation`과 `Transform.localRotation`의 타입이 `Quaternion`이다. Inspector의 Rotation 값은 오일러 각(Euler angles)으로 보여 주는 표시일 뿐이다.

{% hint style="danger" %}
WARNING: `x`, `y`, `z`, `w`를 직접 읽거나 쓰지 않는다. 각 값은 각도가 아니다. 회전은 아래 2절의 함수로 만든다.
{% endhint %}

## 2. 구성 요소

| 목적 | Unity API | 비고 |
|---|---|---|
| 회전 없음 | `Quaternion.identity` | |
| 오일러 각에서 만들기 | `Quaternion.Euler(x, y, z)` | 단위는 도(degree). 적용 순서는 Z, X, Y다 |
| 축과 각도로 만들기 | `Quaternion.AngleAxis(angle, axis)` | 각도는 도 |
| 바라보는 방향으로 만들기 | `Quaternion.LookRotation(forward, up)` | `up` 생략 시 `Vector3.up` |
| 벡터 회전 | `q * v` | 쿼터니언을 왼쪽에 쓴다 |
| 회전 합성 | `q1 * q2` | `(q1 * q2) * v`는 `q1 * (q2 * v)`와 같다. 순서를 바꾸면 결과가 다르다 |
| 역회전 | `Quaternion.Inverse(q)` | |
| 두 회전 사이 보간 | `Quaternion.Slerp(a, b, t)` | `t`는 0~1로 제한된다. 제한 없는 버전은 `SlerpUnclamped` |
| 일정 속도로 접근 | `Quaternion.RotateTowards(from, to, maxDegreesDelta)` | 프레임당 최대 각도를 준다 |
| 두 회전의 각도 차 | `Quaternion.Angle(a, b)` | 도 단위 |
| 오일러 각 읽기 | `q.eulerAngles` | 같은 회전도 다른 값으로 나올 수 있다 |

## 3. 동작 원리

### 3.1 벡터 회전 예

Y축(`Vector3.up`) 기준 90° 회전은 +Z 방향을 +X 방향으로 보낸다(Unity는 왼손 좌표계다).

```csharp
Quaternion q = Quaternion.Euler(0f, 90f, 0f);
Vector3 v = q * Vector3.forward;   // 기대값: (1, 0, 0)에 가깝다
```

### 3.2 합성 순서

`q1 * q2`는 "먼저 q2로 돌리고 그다음 q1로 돌린다"는 뜻이다. 회전은 교환 법칙이 성립하지 않는다. 90° X 회전 후 90° Y 회전과 그 반대 순서는 서로 다른 결과를 만든다.

### 3.3 오일러 각 대신 쓰는 이유

| 비교 | 오일러 각 | 쿼터니언 |
|---|---|---|
| 값 수 | 3개 | 4개 |
| 짐벌 락 | 있다. 가운데 축이 ±90°이면 두 축이 겹쳐 자유도가 하나 줄어든다 | 없다 |
| 보간 | 각 축을 따로 보간하면 경로가 이상해진다 | `Slerp`가 최단 경로로 보간한다 |
| 사람이 읽기 | 쉽다 | 어렵다 |

그래서 Unity는 내부에서 쿼터니언을 쓰고, 사람이 입력하는 값에만 오일러 각을 쓴다.

### 3.4 q와 -q

(x, y, z, w) 전체의 부호를 뒤집어도 같은 회전이다. 두 쿼터니언을 비교할 때 `==` 대신 `Quaternion.Angle(a, b)`가 0에 가까운지 본다.

### 3.5 자주 하는 사용

```csharp
// 목표를 바라보게 한다
Vector3 dir = target.position - transform.position;
if (dir.sqrMagnitude > 0.0001f)   // 0 벡터는 LookRotation 경고를 만든다
{
    Quaternion look = Quaternion.LookRotation(dir);
    // 초당 180도 속도로 회전한다
    transform.rotation = Quaternion.RotateTowards(transform.rotation, look, 180f * Time.deltaTime);
}
```

{% hint style="info" %}
NOTE: 2D 게임에서 한 축만 돌리면 `Quaternion.Euler(0, 0, angle)`로 충분하다. 단, 오일러 각을 읽어 값을 더하는 방식(`eulerAngles.y += 1`)은 360° 경계에서 값이 튈 수 있다. 각도는 별도 변수에 저장해서 쓴다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 오일러 각 | X, Y, Z 축 회전량 세 개로 회전을 표현하는 방식 |
| 짐벌 락(Gimbal lock) | 오일러 각에서 두 회전 축이 겹쳐 한 방향으로 회전할 수 없게 되는 현상 |
| Slerp | 구면 선형 보간. 두 회전 사이를 일정한 각속도로 잇는다 |
| 단위 쿼터니언 | 크기 √(x²+y²+z²+w²)가 1인 쿼터니언. 회전에는 이것만 쓴다 |

## 5. 더 보기

* [벡터 기초와 연산 (Vector)](vector.md)
* [삼각함수 기초 (Trigonometry)](trigonometry.md): 각도와 라디안
* [Unity ScriptReference: Quaternion](https://docs.unity3d.com/ScriptReference/Quaternion.html)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 짐벌 락이 어떤 상황에서 생기는지 한 번 겪었거나 상상해서 설명한다.
- [ ] 캐릭터가 목표를 부드럽게 돌아보게 할 때 `Slerp`와 `RotateTowards` 중 무엇을 쓸지, 이유와 함께 쓴다.
