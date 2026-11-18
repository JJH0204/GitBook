# [생성형 AI] 시간: deltaTime, fixedDeltaTime, timeScale

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UNI-006-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | `Update`와 `FixedUpdate`의 시간 간격, `deltaTime` 사용법, `timeScale`이 미치는 범위를 구분한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (Unity에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 1. 정의

`Update`는 프레임마다 호출되고, 프레임 시간은 일정하지 않다. 그래서 "프레임당 얼마"가 아니라 "초당 얼마"로 움직임을 정의하고, 프레임 시간(`Time.deltaTime`)을 곱해 한 프레임의 변화량을 구한다.

```csharp
// 초당 5유닛 이동
transform.position += direction * (5f * Time.deltaTime);
```

초당 5유닛은 60 FPS에서 프레임당 약 0.083유닛, 30 FPS에서 약 0.167유닛이다. 곱하지 않으면 FPS가 높은 기기에서 더 빨라진다.

## 2. 구성 요소

| API | 의미 | `timeScale` 영향 |
|---|---|---|
| `Time.deltaTime` | 직전 프레임 이후 경과 시간(초) | 받는다 |
| `Time.unscaledDeltaTime` | 같은 값. `timeScale`을 무시한다 | 받지 않는다 |
| `Time.fixedDeltaTime` | 물리 업데이트 간격. 기본값은 0.02초(50회/초) | 받는다 (실행 빈도가 변한다) |
| `Time.time` | 게임 시작 후 경과 시간 | 받는다 |
| `Time.unscaledTime` | 위와 같고 `timeScale`을 무시한다 | 받지 않는다 |
| `Time.timeScale` | 게임 시간 배율. 1이 보통, 0이 정지, 0.5가 슬로모션 | - |
| `Time.realtimeSinceStartup` | 실제 경과 시간 | 받지 않는다 |
| `Application.targetFrameRate` | 목표 프레임 속도 | - |

## 3. 동작 원리

### 3.1 Update와 FixedUpdate

| 구분 | `Update` | `FixedUpdate` |
|---|---|---|
| 호출 간격 | 프레임마다. 불규칙 | `Time.fixedDeltaTime`마다. 일정 |
| 용도 | 입력, 이동 로직, 애니메이션 | `Rigidbody`와 물리 |
| `Time.deltaTime` 값 | 프레임 시간 | `fixedDeltaTime`과 같은 값을 돌려준다 |

`FixedUpdate`에서 `Time.deltaTime`을 써도 올바른 값이 나오지만, 의도를 분명히 하려고 `Time.fixedDeltaTime`을 쓴다. 한 프레임이 길어지면 `FixedUpdate`가 한 프레임에 여러 번 호출될 수 있고, 프레임이 짧으면 호출되지 않는 프레임도 있다.

### 3.2 timeScale = 0

일시정지 구현에 쓰이지만 적용 범위가 다르다.

| 항목 | `timeScale = 0`일 때 |
|---|---|
| `Update` | 계속 호출된다. `deltaTime`은 0이다 |
| `FixedUpdate` | 호출되지 않는다 |
| `WaitForSeconds` | 시간이 흐르지 않아 대기가 끝나지 않는다 |
| `WaitForSecondsRealtime` | 실제 시간으로 대기한다 |
| 일시정지 메뉴의 애니메이션 | `Animator`의 `Update Mode`를 `Unscaled Time`으로 바꾸면 계속 재생된다 |
| 메뉴 입력 | `Update`가 돌므로 입력은 읽을 수 있다 |

```csharp
void Pause(bool on) => Time.timeScale = on ? 0f : 1f;
```

{% hint style="warning" %}
CAUTION: `Time.timeScale`을 0으로 둔 채 씬을 넘기거나 종료하면 다음 씬도 멈춘 상태로 시작한다. 복귀 경로에서 1로 되돌린다.
{% endhint %}

### 3.3 슬로모션과 물리

`timeScale`을 0.5로 낮추면 `FixedUpdate` 호출 빈도도 절반이 되어 물리가 거칠어질 수 있다. 슬로모션에서 물리가 부드러워야 하면 `Time.fixedDeltaTime`을 `0.02f * Time.timeScale`처럼 함께 줄이는 방법이 있으나, 호출 횟수(CPU 비용)가 늘어난다. 효과는 프로젝트에서 확인한다(미검증).

### 3.4 `deltaTime`을 쓰지 말아야 할 곳

| 상황 | 이유 |
|---|---|
| 마우스 이동량(`Input.GetAxis("Mouse X")`)에 곱하기 | 마우스 델타는 이미 프레임당 값이라 곱하면 FPS에 따라 감도가 달라진다. 이 규칙은 입력 방식에 따라 다르므로 사용하는 입력 API의 설명을 확인한다 |
| 값을 한 번에 바꾸는 점프 속도 설정 | 순간 값이다. 지속적인 가속(`AddForce` 등)이 아니다 |

### 3.5 FPS 제한

모바일이나 에디터에서 프레임 속도를 정하려면 `Application.targetFrameRate`를 쓴다. 수직 동기화(VSync)가 켜져 있으면(`QualitySettings.vSyncCount`가 0이 아니면) 이 값이 무시될 수 있다. 플랫폼별 동작은 확인 필요.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 델타 타임 | 이전 프레임과 현재 프레임 사이의 시간 |
| 고정 타임스텝 | 일정 간격으로 물리를 계산하는 방식 |
| FPS | 초당 프레임 수 |

## 5. 더 보기

* [MonoBehaviour 생명주기](../unity-csharp/day19-monobehaviour-lifecycle.md)
* [Unity 코루틴의 내부](../unity-csharp/day08-unity-coroutine.md): `WaitForSeconds`
* [보간: Lerp, MoveTowards, SmoothDamp](../gamemath/lerp-interpolation.md): 프레임 속도와 보간
* [Unity ScriptReference: Time](https://docs.unity3d.com/ScriptReference/Time.html)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `deltaTime`을 곱하지 않았을 때 어떤 일이 생기는지 자신의 말로 설명한다.
- [ ] 일시정지 메뉴가 열린 동안 계속 움직여야 하는 연출(예: 메뉴 애니메이션)을 어떻게 만들지 쓴다.
