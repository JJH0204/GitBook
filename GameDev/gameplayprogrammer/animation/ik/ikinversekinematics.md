# 역운동학 원리와 활용 (IK)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-GPP-002-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 순운동학(FK)과 역운동학(IK)의 차이를 이해하고 Unity에서 IK를 구현하는 방법을 구분한다 |
| 확인 상태 | 미검증 (문서와 API를 읽고 정리했으며 Unity에서 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

IK(Inverse Kinematics, 역운동학)는 말단(end effector)의 목표 위치를 지정하면 루트 쪽 관절의 회전을 계산해 그 위치에 말단이 닿게 하는 기술이다. 예를 들어 "손을 이 위치에 두고 싶다"고 지정하면 어깨, 팔꿈치, 손목의 회전이 계산된다.

| 구분 | 입력 | 계산 | 용도 |
|---|---|---|---|
| FK (Forward Kinematics, 순운동학) | 각 관절의 회전 | 루트부터 차례로 회전을 적용해 말단 위치를 얻는다 | 저작된 애니메이션 재생, 손으로 포즈 구성 |
| IK (Inverse Kinematics, 역운동학) | 말단(손, 발)의 목표 위치 | 목표에 맞는 관절 회전을 거꾸로 구한다 | 지형·물체에 맞춰 손발 위치 보정 |

사용 예는 다음과 같다.

* 계단을 오를 때 발이 바닥 높이를 따라간다.
* 벽을 짚는 손 동작에서 손이 벽면에 닿는다.
* VR에서 손 컨트롤러 위치에 맞춰 캐릭터 팔이 따라간다.
* 경사면에서 발이 지면에 닿고 몸이 기울어진다.

{% hint style="info" %}
NOTE: IK는 물리 시뮬레이션이 아니라 수학 계산이다. 관절이 둘인 팔·다리는 코사인 법칙으로 바로 풀 수 있다. 긴 체인은 CCD나 FABRIK 같은 반복 알고리즘을 쓴다.
{% endhint %}

## 2. 구성 요소: Unity에서 IK를 쓰는 방법

| 방법 | 대상 리그 | 특징 |
|---|---|---|
| Animator IK (Mecanim) | Humanoid만 | 엔진 내장. 스크립트의 `OnAnimatorIK`에서 목표 위치를 지정한다 |
| Animation Rigging 패키지 (`com.unity.animation.rigging`) | Humanoid, Generic | 무료 공식 패키지. 컴포넌트(Constraint)를 붙여 에디터에서 조립한다 |
| Final IK (RootMotion) | Humanoid, Generic | 유료 에셋. 전신 IK, 발 접지(Grounder) 등 완성된 기능이 많다 |
| 직접 구현 | 무엇이든 | 두 뼈는 코사인 법칙, 긴 체인은 CCD나 FABRIK 같은 반복 알고리즘 |

## 3. 동작 원리

### 3.1 Animator IK (Mecanim)

1. Animator Controller의 레이어 설정에서 **IK Pass**를 켠다. 꺼져 있으면 `OnAnimatorIK`가 호출되지 않는다.
2. Animator와 같은 게임 오브젝트의 스크립트에 `OnAnimatorIK(int layerIndex)`를 만든다.
3. 그 안에서 목표마다 가중치(0~1)와 위치·회전을 지정한다. 가중치 기본값은 0이라 지정하지 않으면 효과가 없다.

| API | 하는 일 |
|---|---|
| `SetIKPositionWeight(goal, w)`, `SetIKPosition(goal, pos)` | 손·발(`AvatarIKGoal.LeftFoot` 등)의 목표 위치 |
| `SetIKRotationWeight(goal, w)`, `SetIKRotation(goal, rot)` | 손·발의 목표 회전 |
| `SetIKHintPosition(hint, pos)` | 팔꿈치·무릎이 굽는 방향 (`AvatarIKHint`) |
| `SetLookAtWeight(w)`, `SetLookAtPosition(pos)` | 머리·시선이 바라볼 지점 |
| `GetIKPosition(goal)` | IK 목표의 현재 위치 (애니메이션 기준값인지 설정값인지는 문서로 확인 필요) |

```csharp
public Transform target;   // 발이 닿을 목표
private Animator animator;

void Awake() => animator = GetComponent<Animator>();

void OnAnimatorIK(int layerIndex)
{
    animator.SetIKPositionWeight(AvatarIKGoal.LeftFoot, 1f);
    animator.SetIKPosition(AvatarIKGoal.LeftFoot, target.position);
}
```

### 3.2 Animation Rigging

* Animator가 있는 오브젝트에 **Rig Builder**, 그 자식에 **Rig**를 두고, Rig 아래에 Constraint를 붙인다.
* 자주 쓰는 Constraint: **Two Bone IK**(팔·다리), **Chain IK**(꼬리·촉수), **Multi-Aim**(머리가 목표를 바라보기), **Damped Transform**(흔들림 지연)

{% hint style="info" %}
NOTE: Animator IK는 `OnAnimatorIK`에서 코드로 목표를 주고 Humanoid에서만 동작한다. Animation Rigging은 컴포넌트로 에디터에서 조립하며 Generic 리그에서도 동작한다. Unity 버전과 패키지 버전에 따라 메뉴와 컴포넌트 이름이 다를 수 있으므로 사용하는 버전의 문서를 확인한다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| End effector | 체인의 말단. 손, 발 등 목표 위치에 닿게 할 부위 |
| Humanoid / Generic | Unity 리그 유형. Humanoid는 사람형 표준 뼈대 매핑을 쓴다 |
| Hint | 팔꿈치·무릎이 굽는 방향을 정하는 보조 위치 |
| Weight | IK 적용 비율(0~1). 0이면 애니메이션 그대로, 1이면 IK 목표를 따른다 |

## 5. 더 보기

* [Unity 매뉴얼 — Inverse Kinematics](https://docs.unity3d.com/Manual/InverseKinematics.html)
* [Animation Rigging 패키지 문서](https://docs.unity3d.com/Packages/com.unity.animation.rigging@latest)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] FK와 IK를 각각 언제 쓰는지, 게임 장면 예시 하나씩으로 설명한다.
- [ ] 경사면에서 발이 땅에 붙는 발 IK를 직접 구현한다. 레이캐스트를 어디서 어느 방향으로 쏘고, 맞은 점과 법선을 어떻게 쓰는지 순서대로 적는다.
- [ ] 발 IK를 넣었더니 골반 높이가 그대로라 한쪽 다리가 공중에 뜬다. 왜 그런지, 어떻게 고칠지 쓴다.
