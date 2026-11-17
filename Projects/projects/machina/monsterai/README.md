# 몬스터 AI (Monster AI)

마키나 프로젝트(Unity 팀 프로젝트)에서 맡은 몬스터 AI 작업의 기록이다. 행동 트리(Behavior Tree, BT) 구조, 유한 상태 머신(Finite State Machine, FSM), 공격 패턴 기획, 보스·특수 몬스터 연구 개발(R&D), 래그돌 피격 처리를 다룬다. 문서 번호(Task ID)는 `PRJ-MAI-<번호>-<유형>` 형식이며 이 그룹의 문서는 모두 D&O(개념·기록)다.

{% hint style="info" %}
NOTE: 이 그룹의 문서는 원본 메모를 정리한 것이며 실행해 확인하지 않았다(확인 상태: 미검증). 코드 사실은 팀 레포(`shion0202/2025_Project_ProjectRecombination`)의 소스를 읽어 확인했다. 팀원 이름은 적지 않았다.
{% endhint %}

## 내 역할

몬스터 AI 구조(BT, FSM, Blackboard, 명령 큐), 몬스터 공격 패턴 기획, 보스 몬스터 R&D, 몬스터 피격 연출(래그돌, 피격 반응)을 맡았다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| PRJ-MAI-001-DO | 개념 | [FSM 몬스터 AI](fsmmonsterai.md) | 상태, 전이, 진입 훅의 구성과 동작을 확인한다 |
| PRJ-MAI-002-DO | 개념 | [보스 몬스터 연구 개발 일지](bossmonsterrndlog.md) | 다중 개체 보스의 BT 설계 메모를 확인한다 |
| PRJ-MAI-003-DO | 개념 | [몬스터 공격 패턴 기획](monsterattackpattern.md) | 몬스터 유형별 행동과 기획 근거를 확인한다 |
| PRJ-MAI-004-DO | 개념 | [특수 몬스터 연구 개발 일지](monstermaniacrnd.md) | 특수 몬스터의 공격 구상을 확인한다 |
| PRJ-MAI-005-DO | 개념 | [몬스터 신규 투사체 추가](monsternewbulletaddition.md) | 중력 투사체 구현과 코드 주의점을 확인한다 |
| PRJ-MAI-006-DO | 개념 | [몬스터 시스템 기획 예시](monstersystemplanningexample.md) | 몬스터 용어 정의 메모를 확인한다 |
| PRJ-MAI-007-DO | 개념 | [몬스터 시스템 아키텍처 (BT)](monstersystemstructure.md) | BT 기반 AI 구조와 FSM 도입 배경을 확인한다 |
| PRJ-MAI-008-DO | 개념 | [래그돌 피격 및 사망 처리](ragdollmonsterhitik.md) | 래그돌 전환과 피격 반응 블렌딩을 확인한다 |

## 소스 위치

팀 레포의 몬스터 코드는 `Assets/_GameAssets/01. Scripts/Monster` 아래에 있다.

| 폴더 | 내용 |
|---|---|
| `AI` | `AIController`, 행동 트리, Blackboard, 명령(Command), FSM |
| `Animator` | `RagdollController`, `HitReactionController`, 상태 동작(StateMachineBehaviour) |
| `State` | 비트 마스크 기반 상태 |
| `Skills` | 몬스터 스킬 |

{% hint style="info" %}
NOTE: 소스는 팀 레포에 있다. 레포 접근 권한은 팀 설정에 따르므로 링크가 열리지 않으면 권한을 확인한다.
{% endhint %}
