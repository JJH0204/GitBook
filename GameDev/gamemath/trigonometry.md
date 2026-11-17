# 삼각함수 기초 (Trigonometry)

게임을 구현하면서 좌표계에서 물체의 움직임을 구현해야 하는 상황이 필수로 등장하는데\
이때 이미 구현되어 있는 상용 툴(rigidbody 등)을 이용하면 물론 구현은 빠르지만 의도한 움직임을 구현하기 쉽지 않다.\
그렇기에 이번 기회에 제대로 삼각함수에 대해서 이해하고 직접 예제 코드로 움직임을 구현할 수 있도록 연습하자.

## 삼각함수 기초

* 사인(Sin), 코사인(Cos), 탄젠트(Tan) 라고 불리는 세 함수를 "삼각함수"라 한다.
* 각 함수가 무엇을 의미하는지, 서로 어떤 관계를 갖는지 이해하자.

직각삼각형에서 한 각도(θ)를 기준으로 변의 이름을 붙인다.

* a = 높이 (θ의 맞은편 변)
* b = 밑변 (θ에 붙은 인접변)
* c = 빗변 (직각의 맞은편, 가장 긴 변)

각 함수의 계산 식은 아래와 같다.

* cos(θ) = 인접변 / 빗변 = b / c
* sin(θ) = 맞은편 변 / 빗변 = a / c
* tan(θ) = 맞은편 변 / 인접변 = a / b

***

### 예제 1: 정삼각형으로 60° 값 구하기

정삼각형은 모든 각이 180° / 3 = 60°로 같다. 모든 변의 길이를 3이라고 하자.

{% stepper %}
{% step %}
### 정삼각형을 반으로 나누기

정삼각형을 이등분하면 직각삼각형 2개가 생긴다.

* 빗변 = 3
* 밑변 = 1.5 (정삼각형의 한 변을 반으로 나눔)
* 높이 = ??
{% endstep %}

{% step %}
### 높이를 피타고라스로 구하기

높이는 "피타고라스의 정리"를 통해 구할 수 있다.

* 빗변^2 = 높이^2 + 밑변^2
* 3^2 = h^2 + 1.5^2
* h = √(9 - 2.25) = √6.75 = 2.59807621
{% endstep %}

{% step %}
### 삼각함수 값 계산

* sin(60°) = 2.59807621 / 3 ≈ 0.866 (= √3 / 2)
* cos(60°) = 1.5 / 3 = 0.5
* tan(60°) = 2.59807621 / 1.5 ≈ 1.732 (= √3)
{% endstep %}
{% endstepper %}

변의 길이를 3이 아닌 다른 값으로 해도 결과는 같다. 삼각함수 값은 삼각형의 크기와 상관없이 각도만으로 정해진다.

***

## 게임에서 삼각함수 활용

2차원 공간에서 물체의 곡선 움직임을 어떻게 구현할까? 시작 위치를 저장해 두고, 매 프레임 사인 값만큼 위아래로 띄운다.

* `amplitude`: 출렁임 높이
* `frequency`: 출렁임 속도
* `Update`는 매 프레임마다 반복 호출된다.

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

## 알아 둘 사실

| 항목 | 내용 |
|---|---|
| 라디안 | 각도의 다른 단위. π 라디안 = 180°, 1 라디안 ≈ 57.3° |
| Unity 함수의 단위 | `Mathf.Sin`, `Mathf.Cos`, `Mathf.Tan`은 **라디안**을 받는다. 도(°)는 `Mathf.Deg2Rad`를 곱해서 넘긴다 |
| 각도 → 방향 | 각도 θ의 단위 방향 벡터는 (cos θ, sin θ) |
| 방향 → 각도 | `Mathf.Atan2(y, x)`: 방향 벡터의 각도를 라디안으로 돌려준다. 결과에 `Mathf.Rad2Deg`를 곱하면 도 |
| 원운동 | 중심 c, 반지름 r, 각도 θ의 위치 = c + (cos θ · r, sin θ · r) |
| 주기 | sin, cos는 2π(360°)마다 같은 값을 반복한다. 그래서 `Time.time`을 넣으면 계속 출렁인다 |

## 더 보기

* [툰 셰이더 공부 노트 Day 06 · 빛의 수학](../toon-shader-study/day06-vectors-and-light.md) — 내적과 cos의 관계
* [Unity ScriptReference — Mathf.Atan2](https://docs.unity3d.com/ScriptReference/Mathf.Atan2.html)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `Mathf.Sin(30)`이 0.5가 아닌 이유를 쓰고, 0.5가 나오게 고친다.
- [ ] 반지름 2인 원을 2초에 한 바퀴 도는 물체를 직접 구현한다. 각속도를 어떻게 정했는지 쓴다.
- [ ] 마우스 쪽을 바라보는 2D 포탑을 `Atan2`로 구현하고, `Atan(y / x)` 대신 `Atan2`를 쓰는 이유를 쓴다.
