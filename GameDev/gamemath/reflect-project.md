# [생성형 AI] 반사와 투영: Reflect, Project, ProjectOnPlane

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-MTH-010-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | 벡터의 반사와 투영 식을 이해하고 `Vector3.Reflect`, `Project`, `ProjectOnPlane`을 구분해 쓴다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (Unity에서 실행하지 않았다. 수식과 수치는 Python으로 계산해 확인했다) |
| 개정 | R1 (2026-11-19) |

## 1. 정의

* 투영(projection): 벡터를 다른 방향(또는 평면)에 떨어뜨린 그림자 성분이다.
* 반사(reflection): 벡터가 평면에 부딪혀 튕겨 나온 방향이다.

두 연산 모두 내적을 쓴다. 법선(normal) `n`은 길이가 1이어야 아래 식이 맞다.

## 2. 구성 요소

| 연산 | 식 | Unity API |
|---|---|---|
| 방향 `o`로의 투영 | `(v·o / o·o) · o` | `Vector3.Project(v, o)` |
| 평면으로의 투영 | `v - (v·n) n` | `Vector3.ProjectOnPlane(v, n)` |
| 반사 | `v - 2 (v·n) n` | `Vector3.Reflect(v, n)` |

계산 예 (Python으로 확인):

| 입력 | 결과 |
|---|---|
| `Reflect((1,-1,0), n=(0,1,0))` | (1, 1, 0) |
| `Project((3,4,0), (1,0,0))` | (3, 0, 0) |
| `ProjectOnPlane((3,4,0), n=(0,1,0))` | (3, 0, 0) |

## 3. 동작 원리

### 3.1 반사

바닥(법선 `(0,1,0)`)에 `(1,-1,0)` 방향으로 내려오던 공은 `(1,1,0)`으로 튕긴다. 법선 방향 성분(`y`)만 부호가 뒤집히고, 평면에 평행한 성분(`x`)은 그대로다. `Reflect`의 첫 인자는 들어오는 방향이고, 법선은 표면에서 바깥쪽을 향해야 한다.

```csharp
void OnCollisionEnter(Collision c)
{
    Vector3 normal = c.GetContact(0).normal;
    Vector3 bounced = Vector3.Reflect(velocity, normal);
    velocity = bounced * 0.8f;   // 0.8: 탄성 계수(예시 값)
}
```

{% hint style="info" %}
NOTE: `Rigidbody`와 `PhysicMaterial`(Unity 6에서는 `PhysicsMaterial`)의 Bounciness로 튕김을 처리하면 직접 반사할 필요가 없다. 물리 엔진을 쓰지 않는 탄환·레이저에 이 식을 쓴다. 클래스 이름은 버전 확인 필요.
{% endhint %}

### 3.2 평면 투영

`ProjectOnPlane`은 이동 방향을 바닥 평면에 붙이는 데 쓴다. 경사면을 걸을 때 입력 방향에서 법선 성분을 빼면 경사를 따라가는 방향이 된다.

```csharp
Vector3 move = Vector3.ProjectOnPlane(inputDir, groundNormal).normalized;
```

경사에서 벡터를 투영하면 길이가 줄어들 수 있으므로 위처럼 다시 정규화해 속도를 맞춘다.

### 3.3 방향으로의 투영

`Project(v, o)`는 `v`가 `o` 방향으로 얼마나 가는지를 벡터로 돌려준다. 길이만 필요하면 내적 `Vector3.Dot(v, o.normalized)`를 쓴다. 장애물까지의 앞쪽 거리 판정 등에 쓴다.

{% hint style="warning" %}
CAUTION: `Project`의 두 번째 인자가 영벡터이면 결과는 영벡터다. 방향 벡터가 0이 되는 경우를 처리한다. 반사식에 쓰는 법선은 직접 정규화해 전달한다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 법선 | 표면에 수직이고 길이가 1인 벡터 |
| 내적 | 두 벡터의 같은 방향 성분 크기. `Vector3.Dot` |

## 5. 더 보기

* [벡터 기초와 연산](vector.md)
* [충돌 판정 수학](collision-math.md)
* [Unity ScriptReference: Vector3.Reflect](https://docs.unity3d.com/ScriptReference/Vector3.Reflect.html)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 내적이 투영과 반사식에 어떻게 쓰이는지 자신의 말로 설명한다.
- [ ] 경사면 이동에서 `ProjectOnPlane`을 쓰지 않았을 때 생기는 문제를 상상해 쓴다.
