# [생성형 AI] 보간: Lerp, MoveTowards, SmoothDamp

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-MTH-004-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | 값을 부드럽게 바꾸는 보간 함수의 차이와 프레임 속도 의존 문제를 이해한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (Unity에서 실행하지 않았다. 30, 60, 144 FPS 비교 수치는 Python으로 계산했다) |
| 개정 | R1 (2026-11-19) |

## 1. 정의

보간(Interpolation)은 시작값 a와 끝값 b 사이의 값을 비율 t(0~1)로 구하는 계산이다.

```
Lerp(a, b, t) = a + (b - a) * t
```

t = 0이면 a, t = 1이면 b, t = 0.5이면 중간값이다. 위치, 색, 소리 크기, 카메라 줌에 모두 쓴다.

## 2. 구성 요소

| 함수 | 동작 | 쓰임 |
|---|---|---|
| `Mathf.Lerp(a, b, t)`, `Vector3.Lerp` | t를 0~1로 제한한 선형 보간 | 비율로 섞기 |
| `Mathf.LerpUnclamped` | t를 제한하지 않는다 | 범위를 넘는 연출 |
| `Mathf.InverseLerp(a, b, v)` | 값 v가 a~b에서 몇 비율인지 구한다(Lerp의 역) | 값을 0~1로 정규화 |
| `Mathf.MoveTowards(cur, target, maxDelta)` | 프레임당 최대 maxDelta만큼 목표로 이동한다 | 일정 속도 이동 |
| `Vector3.MoveTowards` | 위와 같다. 벡터 버전 | 목표 지점으로 일정 속도 이동 |
| `Mathf.SmoothDamp(cur, target, ref vel, smoothTime)` | 스프링처럼 감속하며 목표에 접근한다. 속도 `vel`을 호출 사이에 보관해야 한다 | 카메라 추적, UI 수치 |
| `Mathf.SmoothStep(a, b, t)` | 시작과 끝에서 느려지는 곡선 | 부드러운 시작/끝 |
| `Quaternion.Slerp` | 회전 보간 | [쿼터니언과 회전](quaternion.md) 참조 |

## 3. 동작 원리

### 3.1 일정 시간에 걸친 이동

시작 위치를 저장하고 경과 시간 비율을 t로 쓴다.

```csharp
float elapsed;
const float duration = 2f;

void Update()
{
    elapsed += Time.deltaTime;
    float t = Mathf.Clamp01(elapsed / duration);
    transform.position = Vector3.Lerp(startPos, endPos, t);
}
```

t가 시간에 비례하므로 속도가 일정하다.

### 3.2 흔한 오용: 현재값에 고정 비율 Lerp

```csharp
x = Mathf.Lerp(x, target, 0.1f);   // 프레임마다 거리의 10%를 줄인다
```

이 코드는 짧고 부드러워 보이지만 프레임 속도에 따라 속도가 달라진다. 1초 동안 거리가 얼마나 줄었는지 계산한 값은 다음과 같다(시작 0, 목표 1).

| FPS | 1초 뒤 값 |
|---|---|
| 30 | 약 0.958 |
| 60 | 약 0.998 |
| 144 | 약 1.000 |

프레임이 많을수록 더 빨리 도착한다. 해결은 두 가지다.

| 방법 | 설명 |
|---|---|
| 지수 감쇠 식 | `t = 1 - Mathf.Exp(-k * Time.deltaTime)`를 t로 쓴다. `k`가 클수록 빠르다. FPS와 무관하게 같은 시간에 같은 값에 도달한다(k = 5이면 1초 뒤 약 0.993, 30·60·144 FPS 모두 같다) |
| `SmoothDamp` | 내장 함수. `smoothTime`이 목표 도달 시간의 대략적 기준이다. `Time.deltaTime`을 내부에서 쓴다 |

```csharp
// 지수 감쇠
x = Mathf.Lerp(x, target, 1f - Mathf.Exp(-5f * Time.deltaTime));

// SmoothDamp
float vel;   // 필드로 두고 호출 사이에 유지한다
x = Mathf.SmoothDamp(x, target, ref vel, 0.3f);
```

### 3.3 선택 기준

| 원하는 느낌 | 쓸 것 |
|---|---|
| 일정 속도 | `MoveTowards`, 또는 경과 비율 t로 `Lerp` |
| 가까워질수록 느려지는 추적 | `SmoothDamp`, 지수 감쇠 |
| 정해진 시간에 시작과 끝이 부드러움 | 경과 비율 t에 `Mathf.SmoothStep` 또는 이징 곡선 |

{% hint style="info" %}
NOTE: `Mathf.Lerp`는 t를 0~1로 제한한다. 의도적으로 목표를 넘기려면 `LerpUnclamped`를 쓴다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| Lerp | Linear interpolation. 선형 보간 |
| 이징(Easing) | t를 곡선으로 바꿔 가속·감속을 주는 처리 |
| 감쇠(Damping) | 목표에 가까워질수록 변화량이 줄어드는 성질 |

## 5. 더 보기

* [시간: deltaTime, fixedDeltaTime, timeScale](../unity/time-deltatime.md)
* [Unity ScriptReference: Mathf.SmoothDamp](https://docs.unity3d.com/ScriptReference/Mathf.SmoothDamp.html)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 카메라가 플레이어를 따라올 때 어떤 느낌을 원하는지 쓰고, 그에 맞는 함수를 고른 이유를 쓴다.
- [ ] `Lerp(x, target, 0.1f)`가 프레임 속도마다 다르게 보였던 경험이 있으면 적는다.
