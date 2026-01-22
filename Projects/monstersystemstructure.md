# MonsterSystemStructure

## Text Elements

Behavior Tree\
(Scriptable Object) ^Bdt2pXgh

Behavior Tree Runner\
(MonoBehavior) ^PsHQKcN8

Blackboard\
(MonoBehavior) ^CnPdScLb

MonsterStats\
(Scriptable Object) ^38CAOXrh

※ 몬스터의 초기 스텟 정보를 관리

* Google Sheets 에서 설정된 인덱스 번호에 해당하는 값 불러옴
* 파라미터를 활용해 Blackboard가 사용할 수 있도록 값을 전달 ^PyFupIU4

※ 몬스터의 현재(게임 씬에서) 상태를 관리 ^cNJJfoij

Tick(); ^tLIdiz1J

Behavior Tree\
(Scriptable Object) ^9NXhXwVJ

Behavior Tree Runner\
(MonoBehavior) ^UYnrq1Uw

Update() => Tree.Tick(); ^xwuoGDVg

Think ^EZv45bHV

Act ^zGc0xG7b

Controller ^KsBnPr9n

Blackboard\
(MonoBehavior) ^Cg5aUDj9

MonsterStats\
(Scriptable Object) ^cATj06lu

Awake() => Blackboard.Init(); ^HYcIVQzN

Update() { /\* 비용 높은 계산 \*/} ^WWJ1kgxc

?? ^ty50KdSy

Queue \_queue ^MzZ4eixy

Enqueue(AICommand c) ^fvYD6VHi

Enqueue(c) ^WYGMC3q2

LateUpdate() ^2whV10gf

\_queue.Count > 0 ^VYXlIIYI

Blackboard blackboard ^xYJRQlAT

MonsterStats BaseStats ^uIt0saJ7

Dequeue() ^xzQD42Zp

Awake() => Init(); ^7aY3nAGL

Update() ^Edu7XCRE

비용 높은 계산 ^tKFi4e64

Behavior Tree\
(Scriptable Object) ^NVIXpzTq

Behavior Tree Runner\
(MonoBehavior) ^7JwznB1t

Update() => Tree.Tick(); ^Yv0BpPZY

Think ^x2SvWF9R

Controller ^HotEvxar

blackboard.TryGet(new BBKey("Health"), out float health) ^NL8m1C5t

※ 우선순위 큐를 활용해서 로직을 더 정교하게 만들 수 있지 않을까? ^FWtww7nW

\[DefaultExecutionOrder(-200)]\
public sealed class AIController : MonoBehaviour { void Update() { /\* Sense & High-cost compute -> BB \*/ } }

\[DefaultExecutionOrder(-100)]\
public sealed class BehaviorTreeRunner : MonoBehaviour { void Update() { /\* Tick -> BB.Intent \*/ } }

\[DefaultExecutionOrder( +50)]\
public sealed class AIController : MonoBehaviour { void LateUpdate() { /\* Consume Intent \*/ } } ^GdYz0ijF

구조적으로 안전하게 Update 함수를 사용하자 ^rLEiMBcw

데이터베이스에서 데이터를 가져오는데 성공했다.

SO Asset 이 고장났는데 왜이러는 걸까 ^SQ3UyL6x

\[CreateAssetMenu()] 키워드가 적용되어야 SO Asset으로 활용할 수 있다. ^mfPryVvC

AI Controller에서 Sence > Tink > Act 를 진행하기 때문에 DefaultExcutionOrder 설정은 필요 없어졌다. ^4NvBqzWF

Queue \_queue ^QtN9sITy

LateUpdate() ^BApjBxpI

\_queue.Count > 0 ^KyQxvKtm

Dequeue() ^Y7d3L51T

Blackboard blackboard ^r5pnEVTq

Update() ^YkCi7MwH

비용 높은 계산 ^DqMwkCuL

Behavior Tree\
(Scriptable Object) ^5AWCxIQJ

Think ^ec07Um3e

Controller ^spD1EoQj

Sence ^PmxBscAF

Act ^7DdGUZDN

Awake(), OnEnable() ^RCP3K2FP

Init() ^t7YyO05X

Enqueue(c) ^QayQUEZg

몬스터가 애니메이션을 캔슬하면서 행동을 처리한다.\
몬스터가 의도한데로 움직이지 않는다면 내가 행동트리를 잘못 짠걸까? ^OxAWuVwO

Root ^m13UgpZj

Death ^5pIimHB8

Death ^UsAM7tgD

Battle ^Pll6hjWE

전투 시퀀스

{% stepper %}
{% step %}
### 전투 시퀀스 — 판단: 전투 상태에 돌입할 것인지

전투 상태에 돌입할 것인지 판단
{% endstep %}

{% step %}
### 전투 시퀀스 — 판단: 어떤 행동을 할 것인지

전투 상태에 돌입한다면 어떤 행동을 할 것인지 판단
{% endstep %}

{% step %}
### 전투 시퀀스 — 실행

(다음 단계에 따라 행동 실행)
{% endstep %}
{% endstepper %}

Check the combat ^0r3JuIqi

감지 범위 안에 타겟이 존재 ^JetliDAR

주변 동료가 전투 상태인지 ^ewthO83f

전투 상태에 돌입할 때 확인할 건 없을까?

{% stepper %}
{% step %}
### 스텝: 스킬 사용 가능 여부 확인

스킬 사용 가능 여부
{% endstep %}

{% step %}
### 스텝: (기타 확인 항목)

... (추가 확인사항)
{% endstep %}
{% endstepper %}

모든 스킬의 사용 가능 여부를 확인하고 사용 가능한 스킬을 액션 ^cXYrpR62

Skill을 사용할 수 있는가 ^WuJzp7ar

Skill 사용 ^7IaBdmou

Use Skill A ^dSBKScUa

Skill을 사용할 수 있는가 ^IDsXBeOj

Skill 사용 ^VDl2eoAt

Use Skill B ^0AiJRvFo

Skill을 사용할 수 있는가 ^HAPOkLqv

Skill 사용 ^ib0cpqxU

Use Skill C ^wsF6Kyu9

Check Skill ^YAA1f2ML

전투 상태에 돌입한다면 어떤 행동을 할 것인지 판단

Parallel (일단 자식 노드를 전부 실행) ^loZhpqti

전투 상태에 돌입할 것인지 판단 ^e0OrsMQw

Check Chase ^JaQJnuZP

패트롤 데이터가 초기화 되었는지 확인 ^yEj7tcAi

Wander ^8m7xLkl0

Chase ^mydCI7or

Idle Action Choice ^vQ1YzgpB

Patrol ^9dOEunHN

Idle ^Pnpy5jGq

피격 당했는지 ^tA0yQgiu

현재 HP가 0 이하면 Sucesse ^PjlFrnlt

CTC ^41om1xDP

타겟이 살아있는지 확인 ^MAfocKMn

일단 parallel 노드로 진입하면 자식 노드의 실행 결과와 상관없이 무조건 성공을 반환할 것이다.\
그러면 사용가능한 스킬이 없어도 공격 명령을 내린다고 판단하고 그 이후 판단을 하지 않을 것인데 사용가능한 스킬이 없다는 것을 ^oFQtQiLQ

Chase를 할 수 있는가? ^ku5gDvRD

Action Chase ^RmnFRZYx

이미 타겟과 전투 가능여부는 판단하고 해당 노드에 들어옴\
추적을 하되 어디까지 할 것인지 판단해야 함\
minDetection 값이 있으니 이 값 이하인지 판단 ? false : true; ^1ohwPwmx

스킬을 사용할 수 있는지 없는지는 어떻게 판단하지?

{% stepper %}
{% step %}
### 조건 1

스킬의 사거리에 타겟이 들어왔는지 ? 공격 가능 : 공격 불가능
{% endstep %}

{% step %}
### 조건 2

스킬이 현재 쿨타임 적용중이 아닌지 ? 공격 가능 : 공격 불가능
{% endstep %}

{% step %}
### 조건 3

내 체력이 n % 미만인가 ? 공격 가능 : 공격 불가능
{% endstep %}

{% step %}
### 조건 4

(...)
{% endstep %}
{% endstepper %}

Is In Skill Range ^iUdra8Jf

Is In Skill Cooldown-Time ^R3wocaJk

Check My Health ^zSv1ZlhZ

... ^0QziLKpW

Can Use Skill ID ^nSs5O8Ig

몬스터가 현재 사용가능한 스킬 리스트에 등록되어 있는 스킬ID 인지 검사하는 노드\
모든 검사 노드에 스크립트로 포함되어 사용할 예정 ^1Xd5bvqG

이미 공격이 가능하다는 것을 확인하고 공격 명령을 내린 상태인데 이후에 Chase 명령을 ^V2xF7K5C

명령어를 처리하는 중에 다른 명령어가 끼어들어 중간에 실행이 취소되는 문제는 해결되었다.\
ㄴ 명령 실행전 우선순위 값을 비교

애니메이션 실행 전 에니메이터 초기화 메서드를 통해 상태를 초기 상태로 되돌리는 방식으로 애니메이션이 중간에 캔슬되는 문제를 해결했다. ^5NMYR8J5

공격 중에 타겟이 거리를 벌리면 > 공격 모션이 끝난 후 추적 상태가 되어 추적해야 한다. (추적이 안되고 있다. 시발)\
추적을 못하고 있는데 공격 모션은 이전 공격 모션을 계속해서 재생하고 있다. (위 문제가 해결되면 같이 해결될 문제라 생각하게 된다.)\
아직 제대로된 공격 기능을 구현하지 않았다.\
ㄴ 시발 29일까지 할 수 있을까. (좆됐다.)\
ㄴ 피격 이벤트 처리 까지라도 만들어 놓자.\
ㄴ 에니메이터의 트리거 기능에 대해서 더 알아볼 필요가 있어보인다. ^8yC2AtX0

자고 일어난 내일의 재호에게

재호야 일어나면 학점은행제 강의 마저 듣고 얼른 몬스터 피격 이벤트 부터 만들어 놓거라.\
그래야 다른 사람이 게임성 테스트라도 해보겠지 않그러니\
피격 이벤트 구현이 얼추 되면 위에 문제를 하나씩 해결해 나가보자\
예비군 잊지말고 다녀오도록 ^P5KVXIOH

<25.09.05>\
몬스터가 피격 이후 멍청해지는 이슈가 있다.

* 느낌 때문인지 아닌지 점검 필요 ^C9g8dJfq

FSM을 적용하여 BT의 단점을 보완한다. > 왜?

1. 구조화를 통한 재사용성 강화
2. 프로그래머의 개입없이 쉽게 수정할 수 있어야 하니까
3. 확장성 때문에 ^zRm507kK

어떻게 하면 확장성을 추가할 수 있을까?\
여러 BT를 원하는 조건(상태)에 실행할 수 있어야 하는데 ^tgMmjSgV

개선안

{% stepper %}
{% step %}
### 서브트리 개념 추가

서브트리를 활용해 재사용성 및 모듈화 향상
{% endstep %}

{% step %}
### Global BT 개념 추가

전역 상태 전환을 담당하는 BT 추가
{% endstep %}

{% step %}
### 상태를 동적으로 추가/수정할 수 있도록 BitMask 사용

동적 상태 확장을 위한 BitMask 도입
{% endstep %}
{% endstepper %}

Global Behavior Tree 란?

* 전역에서 AI의 상태 전환만 처리하는 BT
* AIController에서 동작해 ^Hg6dqvcY
* GlobalBehaviorTree
* BTData ^4D3bFhik
* String key
* BehaviorTree tree ^nLqlBP1W

BTData ^ckWbEttj

AIController ^lPsahXzD

Global BT ^N1BZhaut

Death BT ^0s0IvuYx

Battle BT ^fvKGPRur

Patrol BT ^ozFiSFZU

... ^SnKDRmtX

상태 제어 ^h8KuN5Zx

상태에 해당하는 Sub BT 실행 ^fN6DAYhj

고정된 상태값에 의해 다양한 상태 표현과 행동 설정이 불가능하다.\
-> ^TQHcLPYQ

몬스터 AI + 애니메이션 병합 과정 ^E9YozdFn

플레이어가 최소 추적 범위에 들어 왔다면\
-> 공격\
-> 또는 할 수 있는 행동이 없다면 -> Idle 모션을 취해야 함 ^ntQBxL1n

달리기 애니메이션만 재생되고 있다. ^lDk3lt14

첫 번째\
: 코드를 신뢰하지말 것, 언제나 예상과 다르게 동작한다.

두 번째\
: 구조화가 잘된 코드일 수록 수정사항이 발생했을 때 취약하다.

세 번째\
: 바빠도 체력 관리를 잘 할 것, 양질의 수면은 양질의 코드로 보답한다. ^QShDJ1Px

TODO: 몬스터 사망시 디졸브 효과로 사라지게\
TODO: 장애물을 뛰어 넘도록 > 네비메시 링크 ^x6ao9Y1A

## Embedded Files

* f57a216497bf888661055fcd9b3b7df14f155db9: \[\[topics/assets/images/스크린샷 2025-09-04 오전 10.27.58.png]]
* e3932b9fe2441aeadeb24c9b763f42d79ab15e81: \[\[topics/assets/images/스크린샷 2025-09-24 10.51.36.png]]

## Drawing

```compressed-json
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

[numerous additional compressed-json lines omitted for brevity...]
```

(Embedded compressed drawing data retained as-is.)
