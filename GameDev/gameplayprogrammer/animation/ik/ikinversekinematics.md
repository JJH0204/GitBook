# 역운동학 원리와 활용 (IK)

{% hint style="warning" %}
{% endhint %}

IK (Inverse Kinematics, 역운동학)

* 말단(end effector)의 위치를 지정하면, 루트 쪽 관절이 자동으로 움직여 연결을 맞춰주는 기술
* "손을 이 위치에 두고 싶다" > 어깨, 팔꿈치, 손목이 자동으로 그 자세가 되게 계산

^GfATgCii

FK (Forward Kinematics) : 관절을 루트부터 차례로 수동으로 회전시키며 포즈 구성\
IK (Inverse Kinematics) : 손이나 발 위치를 고정하고, 그 위치에 맞게 관절 자동 계산

<예제>

* 캐릭터가 계단을 오를 때 발이 자연스럽게 바닥을 따라간다.
* 벽을 짚고 있는 손 모션
* VR에서 손 컨트롤러 위치에 맞춰 캐릭터 팔이 자동으로 따라간다.
* 발이 경사면이나 바닥을 따라 정확히 닿는 기술
  * ㄴ 경사면에 따라 짝다리를 한다던가

\<Unity IK 방식>

* Animator 기반 IK: Mecanim 애니메이터 컨트롤러에서 제공
* Final IK 플러그인: 고급 IK 솔루션 (Asset Store)
* Unity Physics 기반 Custom IK: 직접 본 회전 계산
