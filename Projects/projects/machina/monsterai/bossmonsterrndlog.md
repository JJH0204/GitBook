# 보스 몬스터 연구 개발 일지 (R&D)

{% hint style="info" %}
{% endhint %}

* 소스 코드가 많이 꼬여있다.\
  무슨 기능을 하는지 모르겠고 없어도 될 객체들이 많다. 걷어내고 하나씩 수정해야 할 것 같다.
* 뭐 부터 손을 봐야 할까\
  보스 몬스터의 행동 패턴을 만들어 줘야 하는데
* 우선 현제 체력을 확인해서 상태 값을 변경해 줘야 하는데\
  (Death)
* 몬스터의 체력을 어떻게 정의하고 있는지 찾아보자
* 드래곤 체력을 리스트로 관리
* 드래곤 체력을 임의의 값으로 초기화 하는 메서드
* AI 컨트롤러에서 BT 초기화 시 드레곤 체력도 함께 초기화
* 드래곤의 전체 체력 == 몬스터의 체력 인가?
* 보스 몬스터는 언제 죽었다고 판단하지?
* 특정 드래곤 타입을 선택해서 해당 드래곤의 죽음 여부를 반환하는 노드
* 죽음 명령을 큐에 등록
* 죽음 명령
* 지정한 드래곤 타입에 해당하는 모델의 머테리얼을 죽음 상태로 전환
* 용 마다 BT를 하나씩 가지고 있어야 할 것 같은데\
  (용 마다 Blackboard도 하나씩 가지고 있어야 할 것 같고 아니면 하나의 Blackboard를 참조해도 될듯)
* 보스를 구성하는 용 5마리를 각각 보스의 하위 몬스터로 포함
  * 검둥이
  * 파랑이
  * 노랑이
  * 빨갱이
  * 초록이
* 몸통
* 각각의 몬스터 객체가 각자의 AI 컨트롤러를 가지고 있다.\
  컨트롤러 --- Global BT + 각 상태별 SubBT
* 몸통
* \[Seq]\
  Death
* \[Seq]\
  Battle
* \[Seq]\
  Move
* \[Seq]\
  Idle
* \[Condi]\
  CurrentHealth <= 0
* \[SetState]\
  State = Death
* \[Condi]\
  Player Is Ground == true
* \[Condi]\
  Near by right foot form dist <= 00
* \[Condi]\
  Is Cooldown Time
* \[SetState]\
  Battle
* \[Condi]\
  Player Is Alive
* \[SetState]\
  State = Move
* 초록이
* 노랑이
* \[Seq]\
  Groggy
* \[Seq]\
  Battle
* \[Seq]\
  Idle
* \[Seq]\
  Groggy
* \[Seq]\
  Battle
* \[Seq]\
  Idle
* \[Condi]\
  CurrentHealth <= 0
* \[SetState]\
  State = Death
* \[Condi]\
  CurrentHealth <= 0
* \[SetState]\
  State = Death
* \[Selec]
* \[Condi]\
  Player is On Ground
* \[Condi]\
  Player is Near by Left foot radius
* \[Selec]\
  Chack Skill Cooldown
* \[Condi]\
  독 안개 스킬 쿨타임 적용 여부 확인
* \[Condi]\
  달려들기 스킬 쿨타임 적용 여부 확인
* \[SetState]\
  Battle
* <필요한 기능>
  * 스킬 캐스팅 시간
* 벽과 부딫히는 상황은 무시하는 것인가?
* 얼마나 빠르게? 투사체가 빠른거야 아니면 발사간 딜레이가 짧은거야?
* 왜 달라지는 거지? 피해량이 달라진다는 것은 거리가 멀수록 피해량이 줄어든다는 뜻인가?\
  / 총알이 자신이 시작지점부터 얼마나 날아왔는지 알고 있어야 겠네\
  / 총알이 피격 대상에게 줄 데미지의 최고, 최저가 있어야 겠네 (아니라면 얼마나 줄어들지 결정을 해야 하니까, 별도의 파라미터가 있어야 겟다.)
* 뭔 말인지 모르겠다.
* 좋은 기믹 같은데\
  빨강이랑 파랑을 왜 나누지?\
  보통 빨강은 나쁜거/ 파랑을 좋은거라고 유저는 인식할 것인데
* 일단은 던전 기믹으로 만들어 놓고 각 구체색 별로 기능은 따로 설정할 수 있도록 만들자
* ??
* 보스의 체력이 1페이즈 2페이즈 체력이 나눠져 있어야 할까?\
  왜 1페이즈 시작 후 자동으로 페이즈가 전환될까? 2페이즈를 자랑 하고 싶어서?
* 텔레포트
* 돌진
* 난사
* 영혼 구체(디버프)
