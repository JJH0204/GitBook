# APOSTATE 규칙 해체: 순수 함수로 분리한 이유와 방법

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-APO-102-DO |
| 유형 | D&O (해체 분석) |
| 목적 | 수치와 규칙을 `Rules.cs` 한 파일의 순수 함수로 모은 방식과, 그렇게 한 이유를 설명한다 |
| 확인 상태 | 미검증 (소스를 읽고 쓴 문서다. 따라 만들기는 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 소스는 비공개 레포 `JJH0204/apostate`다. 비공개 레포, 접근 권한 필요. 미발표 프로젝트라 밸런스 수치는 적지 않고 상수 이름으로만 가리킨다.
{% endhint %}

## 이 영역이 하는 일

`Assets/Scripts/Rules.cs`는 `public static class Rules` 하나다. 이 파일에 세 종류가 들어 있다.

1. 상수: 주인공, 적, 사격, 콤보, 담배, 금단, 술, 숙취의 수치.
2. 상수 배열: 적 체력(`EnemyHp`), 방 등급 이름(`GradeNames`)과 담배 지급(`GradeCigs`), 타락도 단계 이름(`StageNames`).
3. 규칙 함수: "입력을 주면 결과를 돌려주는" 함수. 상태를 바꾸지 않는다.

파일 첫머리 주석은 이 파일의 목적을 이렇게 적는다. 튜닝은 이 파일 하나에서 하고, 규칙 함수는 EditMode 테스트로 고정한다.

## 구성 요소

| 구분 | 이름 | 하는 일 |
|---|---|---|
| 판정 | `Survives(armor)`, `IsClose(dist)`, `ChainRelights(combo)` | 한 대 사망 여부, 처형 거리 여부, 줄담배 여부 |
| 계산 | `ShotDamage(close, god)`, `BurnBack(combo, executed)`, `ButtDamage(remaining01)`, `MeleeMul(...)` | 피해와 연소 회복 계산 |
| 등급 | `Grade(bestCombo, angels)`, `Stage(corruption)` | 방 등급(0~3), 타락도 단계(0~4) |
| 세계 시계 | `WorldScale(demonTime, acting, withdrawalStage)` | 세계 속도 배율. [세계 시계](world-clock.md)에서 다룬다 |
| 반발 곡선 | `WithdrawalTime/World/Sway/Reload(stage)`, `HangoverTime/Move/Blur(stage)` | 타락도 단계에 따라 금단과 숙취가 길고 세지는 곡선 |
| 흔들림 | `AimSway(drunk)`, `Spread(drunk)` | 취기 단계별 조준 흔들림과 탄 퍼짐 |

## 데이터 흐름

```
Player / Enemy / Bullet / Game
        |  (현재 상태를 인자로 넘긴다)
        v
   Rules.함수(인자)  --->  결과(숫자 또는 bool)
        ^
        |  (상수를 읽는다)
   Rules.const / static readonly
```

호출하는 쪽이 `Rules`에 상태를 넘기고 결과를 받는다. `Rules`는 호출하는 쪽을 모른다. 그래서 테스트가 씬 없이 호출할 수 있다.

## 핵심 코드 해설

{% code title="Assets/Scripts/Rules.cs" %}
```csharp
public static bool ChainRelights(int combo) => combo >= ChainCombo;

public static int Grade(int bestCombo, int angels) =>
    bestCombo >= angels ? 3 : bestCombo >= GradeACombo ? 2 : bestCombo >= ChainCombo ? 1 : 0;

public static bool IsClose(float dist) => dist <= CloseRange;
public static float ShotDamage(bool close, bool god) => close && god ? GodCloseMul : 1;
public static bool Survives(int armor) => armor > 0;
```
{% endcode %}

- `ChainRelights`: 담배가 다 탈 때 콤보가 기준(`ChainCombo`) 이상이면 불이 이어진다. 한 줄이지만 게임의 핵심 판정이다. 이 판정을 `Player`에 직접 쓰지 않고 함수로 빼 두었기 때문에 기준이 바뀌어도 한 곳만 고친다.
- `Grade`: 방 정리 등급은 그 방의 최고 콤보와 방의 적 수로 정한다. 적 전원을 한 콤보로 처치하면 최고 등급이다.
- `ShotDamage`: 일반 적은 가까이서 쏴도 피해가 늘지 않는다. 처형은 피해가 아니라 `Enemy.Hit`의 `close` 분기가 처리한다. 보스만 근접 사격 피해가 배가 된다.
- 마지막 두 줄: 규칙이 "임계값 비교 한 줄"이라 테스트가 경계값(기준값, 기준값 바로 위)을 확인하기 쉽다.

{% code title="Assets/Scripts/Rules.cs" %}
```csharp
public static float WorldScale(bool demonTime, bool acting, int withdrawalStage = -1) =>
    demonTime ? (acting ? ActingScale : StillScale) : withdrawalStage >= 0 ? WithdrawalWorld(withdrawalStage) : 1;
```
{% endcode %}

- 상태 세 개(악마의 시간, 금단, 맨정신)를 한 식으로 묶었다. 금단 단계를 `-1`로 주면 "금단 아님"이다. 호출하는 쪽의 규칙은 [세계 시계](world-clock.md)에 있다.

## 왜 이렇게 나눴나

- **튜닝 한 곳.** 코드의 주석이 밝힌 대로 값을 고치고 저장하면 Editor가 다시 컴파일한다. 숫자가 `Player`, `Enemy`에 흩어져 있지 않다.
- **테스트가 쉽다.** 함수는 같은 입력에 같은 결과를 준다. `RulesTests`는 씬을 띄우지 않는다([테스트 설계](tests.md)).
- **의도가 이름에 남는다.** `ChainCombo`, `CloseRange`처럼 이름이 있는 상수는 "왜 이 값인가"를 주석으로 적을 자리가 된다.
- **단계 곡선이 한 곳에 있다.** 금단과 숙취의 길이·세기가 `Stage(corruption)`을 인자로 받는 함수 묶음이라, "타락도가 오르면 반발이 길고 세진다"는 설계 원칙이 코드 구조로 보인다.

## 따라 만들기

확인 상태: 미검증.

1. `Assets/Scripts`에 어셈블리 정의(`Apostate.asmdef`)를 만든다. → 결과: 테스트 어셈블리에서 참조할 수 있다.
2. `public static class Rules`를 만들고 수치를 `const` 또는 `static readonly`로 모은다. 값은 가안으로 둔다. → 결과: 컴파일 오류가 없다.
3. 판정 함수(`Survives`, `IsClose`, `ChainRelights`)를 한 줄씩 만든다. → 결과: 함수가 상태를 바꾸지 않는다.
4. 타락도 단계 함수 `Stage(int)`를 만든다. 0~4 범위로 자르고 구간마다 단계를 올린다. → 결과: 경계값에서 단계가 한 칸씩 바뀐다.
5. 단계를 인자로 받는 곡선 함수를 만든다(금단, 숙취). → 결과: 단계가 오를수록 값이 단조롭게 변한다.
6. 세계 시계 함수 `WorldScale`을 만든다. → 결과: 세 상태가 한 식으로 나온다.
7. EditMode 테스트로 경계값과 "맨정신보다 나쁘다" 같은 부등식을 고정한다. → 결과: 값을 고치면 의도가 깨질 때 테스트가 실패한다.

## 알려진 한계·주의

- 모든 수치가 가안이며 사람이 플레이하며 고칠 값이다(소스 주석과 레포 문서의 표현).
- `Rules`가 `UnityEngine`의 `Mathf`를 쓰므로 순수 C# 어셈블리는 아니다. Unity 없이 `dotnet test`로 돌릴 수는 없다.
- 일부 규칙은 `Rules`에 없다. 예를 들어 `Enemy.Spawn`의 "타락도 1단계부터 강림이 빨라진다"는 `Enemy.cs`에 직접 쓰여 있다. 신의 탄막 모양도 `Enemy.cs`에 남아 있다. 파일 첫 주석의 "수치는 이 파일 하나"와 완전히 일치하지는 않는다.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성 (소스 읽기 기반, 미검증) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 규칙을 `Player`나 `Enemy` 안에 직접 쓰지 않고 `Rules`로 뺀 이유를 내 말로 설명해 보자.
- [ ] 내 프로젝트에서 숫자가 여러 파일에 흩어져 고생한 경험이 있는가? 있다면 어떻게 모을 수 있었을지 적어 보자.
- [ ] `Rules`가 `Mathf`를 쓰는 것이 "순수"하다고 할 수 있는지 내 기준으로 판단해 보자.
