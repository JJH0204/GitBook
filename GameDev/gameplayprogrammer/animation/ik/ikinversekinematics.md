# 역운동학 원리와 활용 (IK)

IK (Inverse Kinematics, 역운동학)

* 말단(end effector)의 위치를 지정하면, 루트 쪽 관절이 자동으로 움직여 연결을 맞춰주는 기술
* "손을 이 위치에 두고 싶다" > 어깨, 팔꿈치, 손목이 자동으로 그 자세가 되게 계산

FK (Forward Kinematics) : 관절을 루트부터 차례로 수동으로 회전시키며 포즈 구성\
IK (Inverse Kinematics) : 손이나 발 위치를 고정하고, 그 위치에 맞게 관절 자동 계산

<예제>

* 캐릭터가 계단을 오를 때 발이 자연스럽게 바닥을 따라간다.
* 벽을 짚고 있는 손 모션
* VR에서 손 컨트롤러 위치에 맞춰 캐릭터 팔이 자동으로 따라간다.
* 발이 경사면이나 바닥을 따라 정확히 닿는 기술
  * ㄴ 경사면에 따라 짝다리를 한다던가

## Unity에서 IK를 쓰는 방법

| 방법 | 대상 리그 | 특징 |
|---|---|---|
| Animator IK (Mecanim) | Humanoid만 | 엔진 내장. 스크립트의 `OnAnimatorIK`에서 목표 위치를 지정한다 |
| Animation Rigging 패키지 (`com.unity.animation.rigging`) | Humanoid, Generic | 무료 공식 패키지. 컴포넌트(Constraint)를 붙여 에디터에서 조립한다 |
| Final IK (RootMotion) | Humanoid, Generic | 유료 에셋. 전신 IK, 발 접지(Grounder) 등 완성된 기능이 많다 |
| 직접 구현 | 무엇이든 | 물리가 아니라 수학 계산이다. 두 뼈는 코사인 법칙으로 바로 풀고, 긴 체인은 CCD나 FABRIK 같은 반복 알고리즘을 쓴다 |

### Animator IK

1. Animator Controller의 레이어 설정에서 **IK Pass**를 켠다. 꺼져 있으면 `OnAnimatorIK`가 호출되지 않는다.
2. Animator와 같은 게임 오브젝트의 스크립트에 `OnAnimatorIK(int layerIndex)`를 만든다.
3. 그 안에서 목표마다 가중치(0~1)와 위치·회전을 지정한다. 가중치 기본값은 0이라 지정하지 않으면 효과가 없다.

| API | 하는 일 |
|---|---|
| `SetIKPositionWeight(goal, w)`, `SetIKPosition(goal, pos)` | 손·발(`AvatarIKGoal.LeftFoot` 등)의 목표 위치 |
| `SetIKRotationWeight(goal, w)`, `SetIKRotation(goal, rot)` | 손·발의 목표 회전 |
| `SetIKHintPosition(hint, pos)` | 팔꿈치·무릎이 굽는 방향 (`AvatarIKHint`) |
| `SetLookAtWeight(w)`, `SetLookAtPosition(pos)` | 머리·시선이 바라볼 지점 |
| `GetIKPosition(goal)` | 현재 애니메이션 기준 손·발 위치 |

```csharp
void OnAnimatorIK(int layerIndex)
{
    animator.SetIKPositionWeight(AvatarIKGoal.LeftFoot, 1f);
    animator.SetIKPosition(AvatarIKGoal.LeftFoot, targetPosition);
}
```

### Animation Rigging

* Animator가 있는 오브젝트에 **Rig Builder**, 그 자식에 **Rig**를 두고, Rig 아래에 Constraint를 붙인다.
* 자주 쓰는 Constraint: **Two Bone IK**(팔·다리), **Chain IK**(꼬리·촉수), **Multi-Aim**(머리가 목표를 바라보기), **Damped Transform**(흔들림 지연)

## 더 보기

* [Unity 매뉴얼 — Inverse Kinematics](https://docs.unity3d.com/Manual/InverseKinematics.html)
* [Animation Rigging 패키지 문서](https://docs.unity3d.com/Packages/com.unity.animation.rigging@latest)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] FK와 IK를 각각 언제 쓰는지, 게임 장면 예시 하나씩으로 설명한다.
- [ ] 경사면에서 발이 땅에 붙는 발 IK를 직접 구현한다. 레이캐스트를 어디서 어느 방향으로 쏘고, 맞은 점과 법선을 어떻게 쓰는지 순서대로 적는다.
- [ ] 발 IK를 넣었더니 골반 높이가 그대로라 한쪽 다리가 공중에 뜬다. 왜 그런지, 어떻게 고칠지 쓴다.
