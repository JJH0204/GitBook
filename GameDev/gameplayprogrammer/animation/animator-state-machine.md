# [생성형 AI] Animator 컨트롤러 기초

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-GPP-003-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | Animator 컨트롤러(상태 머신), 파라미터, 전이, 블렌드 트리의 역할과 스크립트 연동 방법을 이해한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (Unity에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 1. 정의

`Animator` 컴포넌트는 `Animator Controller` 에셋을 읽어 어떤 애니메이션 클립을 어떻게 재생할지 결정한다. 컨트롤러는 상태 머신이다. 상태(State)마다 클립이나 블렌드 트리를 하나 연결하고, 전이(Transition)의 조건을 파라미터(Parameter)로 정한다. 스크립트는 클립을 직접 고르지 않고 파라미터 값만 바꾼다.

## 2. 구성 요소

| 구성 | 설명 |
|---|---|
| Animator Controller | `.controller` 에셋. `Animator` 창에서 편집한다 |
| State | 재생 단위(Idle, Run, Jump). 클립 하나 또는 블렌드 트리 |
| Transition | 상태 사이의 화살표. 조건, 지속 시간, 종료 시간 설정을 가진다 |
| Parameter | 스크립트와 주고받는 값: `Float`, `Int`, `Bool`, `Trigger` |
| Layer | 상체와 하체처럼 겹쳐 재생한다. `Avatar Mask`로 적용 부위를 제한한다 |
| Blend Tree | 파라미터 값에 따라 여러 클립을 섞는다(걷기와 달리기 등) |
| Avatar | 리그의 뼈대 매핑. `Humanoid`는 다른 모델의 애니메이션 공유(리타게팅)가 가능하다 |

| 파라미터 타입 | 특징 | 용도 |
|---|---|---|
| `Float` | 연속 값 | 속도(블렌드 트리 입력) |
| `Int` | 정수 | 무기 종류, 콤보 번호 |
| `Bool` | 켜짐/꺼짐 유지 | `IsGrounded` |
| `Trigger` | 한 번 켜지고 소비되면 꺼진다 | `Attack`, `Jump` |

## 3. 동작 원리

### 3.1 스크립트 연동

```csharp
using UnityEngine;

public class CharacterAnim : MonoBehaviour
{
    static readonly int SpeedHash = Animator.StringToHash("Speed");
    static readonly int GroundedHash = Animator.StringToHash("IsGrounded");
    static readonly int AttackHash = Animator.StringToHash("Attack");

    [SerializeField] Animator animator;

    public void SetMove(float speed, bool grounded)
    {
        animator.SetFloat(SpeedHash, speed);
        animator.SetBool(GroundedHash, grounded);
    }

    public void Attack() => animator.SetTrigger(AttackHash);
}
```

파라미터 이름 문자열 대신 `Animator.StringToHash`로 만든 정수를 쓰면 매 호출마다 문자열을 해시하는 일을 피한다. 이름의 철자 오류는 컴파일 오류가 되지 않으므로 컨트롤러의 파라미터 이름과 정확히 같게 쓴다. 이름이 틀리면 경고가 콘솔에 나올 수 있다.

### 3.2 전이 설정

| 설정 | 의미 |
|---|---|
| Conditions | 전이에 필요한 파라미터 조건. 조건이 없고 `Has Exit Time`이 켜져 있으면 클립이 끝난 뒤 전이한다 |
| Has Exit Time | 켜져 있으면 지정한 재생 비율(`Exit Time`)이 지나야 전이한다. 즉시 반응해야 하는 전이(공격 취소 등)에서는 끈다 |
| Transition Duration | 두 상태를 섞는 시간 |
| Interruption Source | 전이 중에 다른 전이가 끼어들 수 있는 조건 |

{% hint style="warning" %}
CAUTION: 조작감이 둔하면 `Has Exit Time`이 켜져 있는지부터 확인한다. 이동 상태 간 전이에서 가장 흔한 원인이다.
{% endhint %}

### 3.3 블렌드 트리

`Speed`가 0이면 Idle, 2이면 Walk, 6이면 Run을 재생하도록 임계값을 정하면 값이 사이에 있을 때 인접한 두 클립이 섞인다. `Animator.SetFloat(hash, value, dampTime, Time.deltaTime)` 오버로드는 값을 부드럽게 따라가게 한다.

### 3.4 루트 모션과 애니메이션 이벤트

| 기능 | 설명 |
|---|---|
| Apply Root Motion | 켜면 클립에 기록된 이동이 오브젝트의 `Transform`에 적용된다. 끄면 이동은 스크립트가 맡는다 |
| 애니메이션 이벤트 | 클립의 특정 시점에서 스크립트의 메서드를 호출한다. 메서드는 `Animator`가 있는 `GameObject`의 스크립트에 있어야 한다 |

공격 판정은 이벤트로 타격 프레임에 맞추는 방식이 흔하다.

### 3.5 상태 확인

```csharp
AnimatorStateInfo info = animator.GetCurrentAnimatorStateInfo(0);   // 레이어 0
if (info.IsName("Attack") && info.normalizedTime >= 1f) { /* 끝났다 */ }
```

전이 중에는 현재 상태가 아직 이전 상태일 수 있다. 상태 이름 비교는 `Animator` 창의 상태 이름과 같아야 한다.

{% hint style="info" %}
NOTE: 에셋 스토어나 외부 사이트에서 받은 애니메이션 클립은 배포 조건을 확인한다. 저장소 공개 여부에 따라 쓸 수 없는 경우가 있다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| FSM | Finite State Machine. 유한 상태 기계 |
| 리타게팅 | 한 모델용 애니메이션을 다른 모델에 적용하는 일 |
| Avatar Mask | 어느 뼈에 애니메이션을 적용할지 정하는 에셋 |
| `normalizedTime` | 상태의 재생 비율(0은 시작, 1은 한 번 재생 완료) |

## 5. 더 보기

* [역운동학 원리와 활용 (IK)](ik/ikinversekinematics.md): `OnAnimatorIK`
* [Day 06 · \[실습\] 상태 패턴](../../unity-csharp/day06-lab-state-pattern.md): 코드로 만드는 상태 머신
* [Unity 매뉴얼: Animator Controller](https://docs.unity3d.com/Manual/class-AnimatorController.html)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 자신의 캐릭터에 필요한 상태와 전이 조건을 표로 적는다.
- [ ] 애니메이션이 끊기거나 반응이 늦었던 경험이 있으면 원인을 적는다.
