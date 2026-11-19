# [생성형 AI] 난수와 확률

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-MTH-007-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | Unity의 난수 API 사용법과 가중치 추첨, 기댓값 계산의 기초를 이해한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (Unity에서 실행하지 않았다. 기댓값 수치는 Python 시뮬레이션 20만 회로 확인했다) |
| 개정 | R1 (2026-11-19) |

## 1. 정의

게임의 난수는 드롭, 치명타, 생성 위치, 연출에 쓴다. 컴퓨터의 난수는 시작값(seed)에서 규칙으로 만들어 내는 의사 난수다. 같은 seed는 같은 수열을 만든다.

## 2. 구성 요소

| 목적 | API | 주의 |
|---|---|---|
| 정수 범위 | `Random.Range(int min, int max)` | max는 포함하지 않는다 (`Range(0, 3)`은 0, 1, 2) |
| 실수 범위 | `Random.Range(float min, float max)` | min과 max를 모두 포함한다 |
| 0~1 실수 | `Random.value` | 0과 1을 포함한다 |
| 단위 원 안의 점 | `Random.insideUnitCircle` | 2D 위치, 산개 |
| 단위 구 안의 점 | `Random.insideUnitSphere` | |
| 단위 구 표면의 점 | `Random.onUnitSphere` | 방향 선택 |
| seed 지정 | `Random.InitState(int seed)` | 재현 가능한 수열. 재현 테스트와 절차 생성에 쓴다 |

{% hint style="warning" %}
CAUTION: `using System;`과 `using UnityEngine;`을 함께 쓰면 `Random`이 `System.Random`과 `UnityEngine.Random` 사이에서 모호해져 컴파일 오류가 난다. `UnityEngine.Random.Range(...)`처럼 이름을 완전히 쓰거나 한쪽 `using`을 뺀다.
{% endhint %}

## 3. 동작 원리

### 3.1 확률 판정

```csharp
bool Roll(float chance) => Random.value < chance;   // chance 0.25 = 25%
```

`Random.value`는 1도 포함하므로 `<`를 쓴다. `chance`가 1이면 1.0이 나오는 극히 드문 경우에는 실패한다. 반드시 성공해야 하는 경우는 `chance >= 1f`를 먼저 검사한다.

### 3.2 가중치 추첨

가중치(70, 25, 5)로 세 개 중 하나를 고른다. 합이 100이므로 확률이 70%, 25%, 5%다. 합이 100이 아니어도 합으로 나누어 쓰므로 가중치만 정하면 된다.

```csharp
int PickWeighted(int[] weights)
{
    int total = 0;
    foreach (int w in weights) total += w;

    int roll = Random.Range(0, total);   // 0 이상 total 미만
    for (int i = 0; i < weights.Length; i++)
    {
        if (roll < weights[i]) return i;
        roll -= weights[i];
    }
    return weights.Length - 1;           // 가중치가 비정상일 때의 방어
}
```

### 3.3 기댓값

성공 확률이 p인 시도를 성공할 때까지 반복하면 평균 시도 횟수는 1/p다. p = 0.05이면 평균 20회다. 시뮬레이션 20만 회의 평균은 약 20.04였다.

20회 안에 한 번도 성공하지 못할 확률은 (1 − p)²⁰ = 0.95²⁰ ≈ 0.358이다. 즉 약 36%의 사용자가 "평균 횟수"를 채우고도 얻지 못한다. 평균이 20회라는 말이 20회 안에 얻는다는 뜻이 아니다.

### 3.4 기획 관점

| 기법 | 설명 |
|---|---|
| 확정 보상(천장, pity) | 일정 횟수 실패하면 성공을 보장한다. 불운 구간을 잘라낸다 |
| 확률 가변 | 실패할 때마다 확률을 올리고 성공하면 초기화한다 |
| 가방 추첨(shuffle bag) | 목록을 섞어 하나씩 꺼낸다. 같은 결과가 연속으로 나오는 일이 줄어든다 |

각 기법의 수치 설계는 [밸런스 시트 실습](../game-design/01-system-design/balance-drills.md)을 본다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| seed | 난수 수열의 시작값 |
| 의사 난수(PRNG) | 규칙으로 만든 난수 |
| 기댓값 | 확률 × 값의 합. 반복했을 때의 평균 |

## 5. 더 보기

* [Unity ScriptReference: Random](https://docs.unity3d.com/ScriptReference/Random.html)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 플레이한 게임 중 드롭 확률이 낮은데 불공평하다고 느낀 사례와 그 이유를 쓴다.
- [ ] 자신이 만드는 게임에서 확정 보상 장치가 필요한 보상이 있는지, 있다면 몇 회로 할지 쓴다.
