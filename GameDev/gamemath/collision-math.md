# [생성형 AI] 충돌 판정 수학: AABB, 구, 레이

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-MTH-006-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | 물리 엔진 없이 겹침과 교차를 판정하는 기본 수식(AABB, 구, 레이-평면, 레이-구)을 이해한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (Unity에서 실행하지 않았다. 수식의 예제 값은 Python으로 계산해 확인했다) |
| 개정 | R1 (2026-11-19) |

## 1. 정의

충돌 판정은 두 도형이 겹치는지, 광선(레이)이 도형에 닿는지 계산하는 일이다. 복잡한 메시를 직접 비교하면 느리므로 게임은 단순한 도형(구, 박스)으로 근사한다. Unity의 `Collider`도 같은 원리다.

## 2. 구성 요소

| 판정 | 조건 | Unity API |
|---|---|---|
| 점 ∈ AABB | 세 축 모두 min ≤ p ≤ max | `Bounds.Contains(p)` |
| AABB ∩ AABB | 세 축 모두 구간이 겹친다 | `Bounds.Intersects(other)` |
| 구 ∩ 구 | 중심 거리² ≤ (r1 + r2)² | 직접 계산 |
| 점에서 AABB까지 거리² | 박스 밖이면 가장 가까운 점까지 | `Bounds.SqrDistance(p)` |
| 레이 ∩ 평면 | t = n·(P0 − O) / (n·d) | `Plane.Raycast(ray, out enter)` |
| 레이 ∩ 구 | 이차방정식 | `Physics.Raycast`로 `SphereCollider`에 쏘거나 직접 계산 |

AABB(Axis-Aligned Bounding Box)는 축에 정렬된 박스다. 회전한 오브젝트의 `Renderer.bounds`와 `Collider.bounds`는 월드 축에 정렬된 박스를 돌려준다.

## 3. 동작 원리

### 3.1 AABB 겹침

두 박스가 겹치려면 X, Y, Z 세 축 모두에서 구간이 겹쳐야 한다. 한 축이라도 떨어져 있으면 겹치지 않는다.

```csharp
static bool Overlap1D(float minA, float maxA, float minB, float maxB)
    => minA <= maxB && minB <= maxA;
```

### 3.2 구와 구

거리 비교에 제곱근을 쓰지 않고 제곱 값을 비교한다(`sqrMagnitude`).

```csharp
static bool SphereOverlap(Vector3 c1, float r1, Vector3 c2, float r2)
{
    float rr = r1 + r2;
    return (c1 - c2).sqrMagnitude <= rr * rr;
}
```

예: 반지름 1인 두 구의 중심이 (0,0,0)과 (1.5,0,0)이면 거리² = 2.25 ≤ 4이므로 겹친다. (2.5,0,0)이면 6.25 > 4이므로 겹치지 않는다.

### 3.3 레이와 평면

레이는 시작점 O와 방향 d로 정의되고, 점은 `O + t*d`(t ≥ 0)이다. 평면은 법선 n과 평면 위의 한 점 P0로 정의된다.

```
t = dot(n, P0 - O) / dot(n, d)
```

* `dot(n, d) == 0`이면 레이가 평면과 평행이다. 나눗셈을 하지 않는다.
* t < 0이면 평면이 레이 뒤쪽에 있다. 맞지 않은 것으로 처리한다.

예: 평면 y = 0(n = (0,1,0)), O = (0,5,0), d = (1,−1,0)이면 t = 5이고 교점은 (5, 0, 0)이다. 이 값은 `d`가 단위 벡터가 아니어도 `O + t*d`로 구하는 한 맞다.

```csharp
var plane = new Plane(Vector3.up, Vector3.zero);   // 법선, 평면 위의 점
var ray = new Ray(origin, direction);
if (plane.Raycast(ray, out float enter))           // enter: 레이 위의 거리 t
{
    Vector3 hit = ray.GetPoint(enter);
}
```

{% hint style="info" %}
NOTE: `Plane.Raycast`는 평행이거나 평면이 뒤에 있으면 false를 반환한다. 마우스 클릭 지점을 바닥에 투영하는 용도에 쓴다.
{% endhint %}

### 3.4 레이와 구

중심 C, 반지름 r인 구에 대해 `oc = O − C`, 단위 방향 d로 놓으면 다음과 같다.

```
b = dot(oc, d)
c = dot(oc, oc) − r²
disc = b² − c
disc < 0 이면 맞지 않는다.
t = −b − √disc   (가까운 교점)
```

예: O = (0,0,−5), d = (0,0,1), C = 원점, r = 1이면 t = 4이고 교점은 (0,0,−1)이다. `t < 0`이면 구가 레이 뒤쪽 또는 레이 시작점이 구 안쪽이다. 이때의 처리는 용도에 따라 정한다.

{% hint style="warning" %}
CAUTION: 레이-구 식은 `d`가 단위 벡터일 때 위의 식이다. `d`를 정규화하지 않으면 계산이 틀린다.
{% endhint %}

### 3.5 언제 직접 계산하지 않는가

Unity 물리 엔진으로 되는 일(`Physics.Raycast`, `OverlapSphere`)은 엔진을 쓴다. 직접 계산은 콜라이더를 만들 수 없는 경우, 많은 수의 단순 도형을 코드로만 다루는 경우, 또는 원리를 배우는 경우에 쓴다. 엔진 기능은 [물리 질의와 충돌 이벤트](../unity/physics-queries.md)를 본다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| AABB | Axis-Aligned Bounding Box. 축에 정렬된 박스 |
| 레이(Ray) | 시작점과 방향을 가진 반직선 |
| 법선(Normal) | 면에 수직인 단위 벡터 |
| 광범위/세부 단계 | 큰 후보를 먼저 거르고(광범위) 정밀하게 검사하는(세부) 2단계 방식 |

## 5. 더 보기

* [벡터 기초와 연산 (Vector)](vector.md): 내적, 정규화, `sqrMagnitude`
* [Unity ScriptReference: Bounds](https://docs.unity3d.com/ScriptReference/Bounds.html)
* [Unity ScriptReference: Plane](https://docs.unity3d.com/ScriptReference/Plane.html)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 충돌 판정에 구나 박스 같은 단순 도형을 쓰는 이유를 자신의 말로 쓴다.
- [ ] 마우스 위치를 바닥에 투영해야 하는 기능을 만든다면 어떤 방법을 쓸지 쓴다.
