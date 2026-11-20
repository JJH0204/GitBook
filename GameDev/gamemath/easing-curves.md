# [생성형 AI] 이징 함수와 커브

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-MTH-008-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | 진행도 t(0~1)를 변형해 시작과 끝을 부드럽게 만드는 이징 함수의 형태와 `Mathf.SmoothStep`, `AnimationCurve` 사용을 이해한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (Unity에서 실행하지 않았다. 수식과 수치는 Python으로 계산해 확인했다) |
| 개정 | R1 (2026-11-19) |

## 1. 정의

이징(easing)은 진행도 `t`(0에서 1)를 다른 0~1 값으로 바꿔서, 같은 시간에도 움직임의 속도 변화를 다르게 만드는 함수다. 이징 값 `e = f(t)`를 `Lerp(a, b, e)`에 넣어 쓴다. `f(0) = 0`, `f(1) = 1`을 지키는 함수만 시작점과 끝점이 변하지 않는다.

```csharp
float t = Mathf.Clamp01(elapsed / duration);   // 0~1 진행도
float e = t * t * (3f - 2f * t);               // smoothstep
transform.position = Vector3.Lerp(start, end, e);
```

## 2. 구성 요소

t = 0, 0.25, 0.5, 0.75, 1에서 계산한 값이다(Python으로 확인).

| 이름 | 식 | 0 | 0.25 | 0.5 | 0.75 | 1 | 느낌 |
|---|---|---|---|---|---|---|---|
| 선형 | `t` | 0 | 0.25 | 0.5 | 0.75 | 1 | 일정한 속도 |
| Ease In (quad) | `t²` | 0 | 0.0625 | 0.25 | 0.5625 | 1 | 느리게 시작해 빨라진다 |
| Ease Out (quad) | `1 - (1 - t)²` | 0 | 0.4375 | 0.75 | 0.9375 | 1 | 빠르게 시작해 느려진다 |
| Ease In Out (quad) | `t < 0.5 ? 2t² : 1 - (-2t + 2)² / 2` | 0 | 0.125 | 0.5 | 0.875 | 1 | 양끝이 느리다 |
| smoothstep | `t²(3 - 2t)` | 0 | 0.1562 | 0.5 | 0.8438 | 1 | 양끝 기울기 0 |
| smootherstep | `t³(6t² - 15t + 10)` | 0 | 0.1035 | 0.5 | 0.8965 | 1 | 양끝 기울기와 곡률 0 |

## 3. 동작 원리

### 3.1 기울기가 속도다

이징 함수의 기울기(미분)가 곧 그 시점의 상대 속도다. Ease In은 `t = 0`에서 기울기가 0이므로 정지 상태에서 출발한다. smoothstep은 `t = 0`과 `t = 1`에서 모두 기울기가 0이라 시작과 끝이 부드럽다.

### 3.2 Unity API

| API | 동작 |
|---|---|
| `Mathf.SmoothStep(from, to, t)` | `t`를 0~1로 제한하고 smoothstep 방식으로 `from`에서 `to`로 보간한다 |
| `Mathf.InverseLerp(a, b, v)` | `v`가 `a`~`b` 구간의 어디인지 0~1로 돌려준다. 구간을 진행도로 바꿀 때 쓴다 |
| `AnimationCurve.Evaluate(t)` | 인스펙터에서 그린 곡선의 `t` 위치 값을 돌려준다 |
| `AnimationCurve.EaseInOut(t0, v0, t1, v1)` | 양끝이 부드러운 곡선을 만든다 |

```csharp
public class MoveWithCurve : MonoBehaviour
{
    [SerializeField] AnimationCurve curve = AnimationCurve.EaseInOut(0, 0, 1, 1);
    [SerializeField] Vector3 end;
    [SerializeField] float duration = 1f;
    Vector3 start;
    float elapsed;

    void Start() => start = transform.position;

    void Update()
    {
        elapsed += Time.deltaTime;
        float t = Mathf.Clamp01(elapsed / duration);
        transform.position = Vector3.LerpUnclamped(start, end, curve.Evaluate(t));
    }
}
```

`curve`의 값이 0~1을 벗어나는 곡선(되튕김 효과)을 쓰려면 범위를 제한하지 않는 `LerpUnclamped`가 필요하다. `Lerp`는 `t`를 0~1로 제한한다.

### 3.3 선택 기준

| 연출 | 권장 |
|---|---|
| UI 패널이 나타남 | Ease Out |
| 화면 밖으로 사라짐 | Ease In |
| 두 지점 사이 이동 | Ease In Out 또는 smoothstep |
| 기획자가 직접 튜닝 | `AnimationCurve` 노출 |

{% hint style="info" %}
NOTE: 외부 트윈 라이브러리(DOTween 등)는 이징 이름이 다르고 라이선스가 따로 있다. 이 문서는 사용하지 않는다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 이징 | 진행도를 변형하는 함수 |
| smoothstep | 양끝 기울기가 0인 3차 곡선 `3t² - 2t³` |
| 기울기 | 함수의 변화율. 이징에서는 속도에 해당 |

## 5. 더 보기

* [보간: Lerp, MoveTowards, SmoothDamp](lerp-interpolation.md)
* [베지어 곡선](bezier-curves.md)
* [Unity ScriptReference: AnimationCurve](https://docs.unity3d.com/ScriptReference/AnimationCurve.html)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 같은 이동을 선형과 Ease Out으로 보았을 때 느낌이 어떻게 다른지 자신의 말로 쓴다.
- [ ] 자신이 만든 UI나 연출에서 이징을 적용하면 좋아질 부분이 있으면 적는다.
