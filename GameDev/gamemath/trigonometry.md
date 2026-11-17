# 삼각함수 기초 (Trigonometry)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-MTH-002-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 사인, 코사인, 탄젠트의 정의와 Unity `Mathf` 삼각함수의 단위(라디안)를 이해하고 사인 곡선 움직임을 구현한다 |
| 확인 상태 | 미검증 (공식과 코드를 읽고 정리했으며 Unity에서 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

게임에서 좌표계의 물체 움직임을 구현할 때 `Rigidbody` 같은 내장 컴포넌트를 쓰면 구현은 빠르다. 그러나 의도한 움직임을 정확히 내기 어렵다. 삼각함수를 이해하면 원운동, 출렁임, 조준 같은 움직임을 직접 계산할 수 있다.

## 2. 구성 요소

사인(sin), 코사인(cos), 탄젠트(tan)를 삼각함수라 한다. 직각삼각형에서 한 각도(θ)를 기준으로 변의 이름을 붙인다.

| 기호 | 이름 | 위치 |
|---|---|---|
| a | 높이 (맞은편 변) | θ의 맞은편 변 |
| b | 밑변 (인접변) | θ에 붙은 변 |
| c | 빗변 | 직각의 맞은편, 가장 긴 변 |

| 함수 | 정의 | 식 |
|---|---|---|
| sin(θ) | 맞은편 변 / 빗변 | a / c |
| cos(θ) | 인접변 / 빗변 | b / c |
| tan(θ) | 맞은편 변 / 인접변 | a / b |

## 3. 동작 원리

### 3.1 예제: 정삼각형으로 60° 값 구하기

정삼각형은 모든 각이 180° / 3 = 60°로 같다. 모든 변의 길이를 3이라고 한다.

1. 정삼각형을 이등분해 직각삼각형 2개를 만든다. 빗변은 3, 밑변은 1.5(한 변의 절반), 높이는 미지수 h다.
2. 피타고라스 정리로 높이를 구한다. 빗변² = 높이² + 밑변²이므로 3² = h² + 1.5²이다. h = √(9 − 2.25) = √6.75 ≈ 2.598이다.
3. 삼각함수 값을 계산한다.
   * sin(60°) = 2.598 / 3 ≈ 0.866 (= √3 / 2)
   * cos(60°) = 1.5 / 3 = 0.5
   * tan(60°) = 2.598 / 1.5 ≈ 1.732 (= √3)

변의 길이를 3이 아닌 다른 값으로 해도 결과는 같다. 삼각함수 값은 삼각형의 크기와 상관없이 각도만으로 정해진다.

### 3.2 Unity에서 쓰는 사실

| 항목 | 내용 |
|---|---|
| 라디안 | 각도의 다른 단위. π 라디안 = 180°, 1 라디안 ≈ 57.3° |
| Unity 함수의 단위 | `Mathf.Sin`, `Mathf.Cos`, `Mathf.Tan`은 **라디안**을 받는다. 도(°)는 `Mathf.Deg2Rad`를 곱해서 넘긴다 |
| 각도 → 방향 | 각도 θ의 단위 방향 벡터는 (cos θ, sin θ) |
| 방향 → 각도 | `Mathf.Atan2(y, x)`: 방향 벡터의 각도를 라디안으로 돌려준다. 결과에 `Mathf.Rad2Deg`를 곱하면 도 |
| 원운동 | 중심 c, 반지름 r, 각도 θ의 위치 = c + (cos θ · r, sin θ · r) |
| 주기 | sin, cos는 2π(360°)마다 같은 값을 반복한다. 그래서 `Time.time`을 넣으면 계속 출렁인다 |

### 3.3 예제 코드: 위아래로 출렁이는 물체

시작 위치를 저장해 두고, 매 프레임 사인 값만큼 위아래로 띄운다.

* `amplitude`: 출렁임 높이
* `frequency`: 출렁임 속도(라디안/초). 한 번 왕복하는 데 걸리는 시간은 2π / `frequency`초다.
* `Update`는 매 프레임 호출된다. 시간은 `Time.time`을 쓰므로 프레임 속도와 상관없이 같은 속도로 움직인다.

{% code title="예시: 위아래로 출렁이는 물체" %}
```csharp
public float amplitude; // 출렁임 높이
public float frequency; // 출렁임 속도

private Vector2 _startPosition;

private void Start()
{
    _startPosition = transform.position; // 객체의 시작 위치를 저장
}

private void Update()
{
    // 시간에 따라 출렁임 계산
    var x = Time.time * frequency;
    var sin = Mathf.Sin(x);
    var yOffset = sin * amplitude;

    transform.position = _startPosition + Vector2.up * yOffset;
}
```
{% endcode %}

{% hint style="info" %}
NOTE: 이 코드는 `Vector2`를 `transform.position`(`Vector3`)에 대입하므로 z 값이 0이 된다. 3D 오브젝트에는 `Vector3`를 쓴다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 진폭(amplitude) | 사인 곡선의 최대 변위 |
| 주기(period) | 같은 값이 반복되는 간격. sin, cos는 2π |
| 라디안(radian) | 원의 반지름과 같은 길이의 호가 이루는 각 |

## 5. 더 보기

* [툰 셰이더 공부 노트 Day 06 · 빛의 수학](../toon-shader-study/day06-vectors-and-light.md): 내적과 cos의 관계
* [Unity ScriptReference: Mathf.Atan2](https://docs.unity3d.com/ScriptReference/Mathf.Atan2.html)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `Mathf.Sin(30)`이 0.5가 아닌 이유를 쓰고, 0.5가 나오게 고친다.
- [ ] 반지름 2인 원을 2초에 한 바퀴 도는 물체를 직접 구현한다. 각속도를 어떻게 정했는지 쓴다.
- [ ] 마우스 쪽을 바라보는 2D 포탑을 `Atan2`로 구현하고, `Atan(y / x)` 대신 `Atan2`를 쓰는 이유를 쓴다.
