# 보스 스킬과 테스트 도구

## 한눈에 보기

팀 프로젝트(Unity TPS 게임)에서 보스 몬스터의 스킬 몇 개와, 그 스킬을 빠르게 확인하기 위한 에디터 테스트 도구를 맡아 구현한 기록이다. 각 문서는 실제 코드와 커밋 진화 과정을 해체해서, 빈 Unity 프로젝트에서 같은 구조를 따라 만들 수 있게 단계로 풀어 쓴다.

| 주제 | 핵심 질문 |
| --- | --- |
| 차징 레이저 | 정확히 겨냥하면서도 피할 수 있는 지속 피해 빔을 어떻게 만드는가 |
| 영혼 감옥 | 공유 ScriptableObject 스킬이 시전 한 번의 시작과 끝, 중단을 어떻게 책임지는가 |
| 안전지대 | 여러 출처의 무적이 서로를 끄지 않게 하려면 |
| 폭발 피해와 배리어 | 피해가 "맞는 조건"이 빠져 있을 때 어떤 버그가 되는가 |
| 씬 테스트 도구 | 보스 방까지 가지 않고 스킬을 바로 시험하려면 |

{% hint style="info" %}
이 영역의 동작 설명은 모두 코드를 읽고 쓴 것이다. Unity에서 실행하거나 빌드해서 확인하지는 않았다(unverified). 그리고 코드 발췌는 지면에 맞게 줄이고 일부 주석을 뺐다.
{% endhint %}

## 스킬 공통 구조

보스 스킬은 모두 `SkillData`(ScriptableObject)를 상속한다. 한 번의 시전은 아래 흐름을 따른다.

```text
        FSM (몬스터 AI)
          │  스킬 선택, 쿨다운 확인
          ▼
   ┌─────────────────┐
   │ Casting()       │  준비 단계(코루틴): 이동, 이펙트, 조준, 스폰
   └───────┬─────────┘
           │ castTime 경과
           ▼
   ┌─────────────────┐
   │ Activate()      │  실행 단계(코루틴): 판정, 피해, 정리
   └───────┬─────────┘
           ▼
      정상 종료 ──────────────► ResetRuntimeState (공유 인스턴스 초기화)

   중간에 피격/파괴로 끊기면
           │  StopCoroutine (finally는 실행되지 않음)
           ▼
   ┌─────────────────┐
   │ OnInterrupt()   │  FSM이 먼저 호출. 이펙트/스폰물/상태를 직접 정리
   └─────────────────┘
```

공통 규칙 세 가지가 문서 전체에 반복해서 나온다.

* 에셋은 공유 인스턴스다. 시전마다 만드는 오브젝트는 필드 대신 지역 변수에 두거나, 시전 시작과 끝에 초기화한다.
* `StopCoroutine`은 `finally`를 실행하지 않는다. 강제 중단의 뒷정리는 `OnInterrupt`가 맡는다.
* 피해는 `IDamagable.ApplyDamage(피해, 레이어 마스크, 시간 단위, 방어 무시율)`로 준다. 마스크에 대상 레이어가 없으면 무시된다.

## 읽는 순서

1. [집행자 차징 레이저](charging-laser.md): 코루틴 스킬 하나를 끝까지 읽는 가장 쉬운 예
2. [아몬 2페이즈 영혼 감옥](amon-lockdown.md): 수명 관리와 중단 처리, 앵커 좌표
3. [안전지대와 무적 참조 카운트](safe-zone.md): 영혼 감옥의 폭발 면제 장치
4. [폭발 피해 반경과 배리어 비활성화](explosion-damage.md): 피해 조건 버그 두 건
5. [씬 테스트 도구](scene-test-tools.md): 위 스킬들을 바로 시험하는 도구

## 파일 목록

대상 파일은 모두 `Assets/_GameAssets/01. Scripts/` 아래에 있다.

| 파일 | 한 줄 역할 | 문서 |
| --- | --- | --- |
| `Monster/Skills/Excutioner/ExeChargingLaser.cs` | 지속 피해 레이저 스킬 | [차징 레이저](charging-laser.md) |
| `Monster/Skills/Amon_Phase2/AmonLockdown.cs` | 안전지대와 잡몹이 나오는 전역 폭발 스킬 | [영혼 감옥](amon-lockdown.md) |
| `Monster/Skills/Amon_Phase2/AmonBarrier.cs` | 최대 체력 10%를 흡수하는 보호막 | [폭발 피해와 배리어](explosion-damage.md) |
| `GameObjects/Patterns/SafeZoneObject.cs` | 진입 시 무적을 주는 트리거 영역 | [안전지대](safe-zone.md) |
| `GameObjects/Patterns/SoulSphereObject.cs` | 반경 검사가 있는 폭발 구체 | [폭발 피해와 배리어](explosion-damage.md) |
| `Editor/SceneTestLauncher.cs` | 씬 테스트 에디터 창 | [씬 테스트 도구](scene-test-tools.md) |
| `Test/TestManager.cs` | 적 피해 배율, 테스트 무적 플래그 | [씬 테스트 도구](scene-test-tools.md) |
| `Test/SceneTestInvincibility.cs` | 플레이어 무적 유지 컴포넌트 | [씬 테스트 도구](scene-test-tools.md) |
| `Test/ISceneTestHook.cs`, `Test/SceneTestFSMActivator.cs` | 테스트 시작 훅과 FSM 활성화 | [씬 테스트 도구](scene-test-tools.md) |
| `Player/PlayerController.cs` (일부) | 무적 참조 카운트 | [안전지대](safe-zone.md) |
| `Monster/Skills/SkillData.cs`, `Monster/AI/FSM/*` (일부) | `OnInterrupt` 훅과 호출부 | [영혼 감옥](amon-lockdown.md) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 보스 스킬을 `Casting`과 `Activate` 두 단계로 나누면 무엇이 편해지는가?
- [ ] 이 영역에서 내가 가장 어렵게 느낀 문제는 무엇이었고, 어떻게 풀었는가?
- [ ] 같은 스킬을 처음부터 다시 만든다면 가장 먼저 바꾸고 싶은 부분은 어디인가?
