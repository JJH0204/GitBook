# APOSTATE 세계 시계: 악마의 시간과 금단 시계

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-APO-103-DO |
| 유형 | D&O (해체 분석) |
| 목적 | 세계 시계 `Game.dt`로 악마의 시간과 금단을 만드는 구조와 담배 상태 기계를 설명한다 |
| 확인 상태 | 미검증 (소스를 읽고 쓴 문서다. 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 소스는 비공개 레포 `JJH0204/apostate`다. 비공개 레포, 접근 권한 필요. 미발표 프로젝트라 밸런스 수치는 적지 않고 상수 이름으로만 가리킨다.
{% endhint %}

## 이 영역이 하는 일

세계 시계는 "시간이 두 갈래로 흐르는" 장치다.

- **실제 시간** `Time.deltaTime`: 주인공의 입력, 이동, 담배 연소, 금단·숙취 시계에 쓴다.
- **세계 시간** `Game.dt`: 적, 탄환, 이펙트, 콤보 제한 시간에 쓴다.

세계 시간은 실제 시간에 `worldScale`을 곱한 값이다. `worldScale`을 낮추면 적과 탄환만 느려지고 주인공은 그대로 움직인다. 이것이 악마의 시간이다. 반대로 `worldScale`이 1보다 크면 금단이다.

## 구성 요소

| 위치 | 이름 | 역할 |
|---|---|---|
| `Rules.cs` | `WorldScale(demonTime, acting, withdrawalStage)` | 상태에서 목표 배율을 계산한다 |
| `Game.cs` | `worldScale`, `dt`, `hitstop`, `slow` | 배율을 서서히 바꾸고 `dt`를 만든다 |
| `Player.cs` | `burn`, `withdrawal`, `hangover`, `acting`, `combo`, `comboTimer` | 담배와 반발의 남은 시간, 행동 여부 |
| `Player.cs` | `Cigarette()`, `Light()`, `BurnOut()`, `PutOut()`, `Endured()` | 상태 전이를 일으키는 함수 |
| `Enemy.cs`, `Bullet.cs`, `Mote.cs` | `Game.I.dt` 사용 | 세계 시간으로 움직이는 쪽 |

## 데이터 흐름

```
Player.Update (실제 시간)                Game.Update (프레임 맨 앞)
  acting = 이동 || 사격 직후 || 재장전     target = Rules.WorldScale(
  burn, withdrawal 갱신        ------>         player.burn > 0,
                                               player.acting,
                                               withdrawal > 0 ? 타락도 단계 : -1)
                                             * (slow > 0 ? 느린 배율 : 1)
                                         worldScale -> target (느려질 땐 빠르게, 빨라질 땐 천천히)
                                         dt = hitstop > 0 ? 0 : 실제dt * worldScale
                                              |
                       Enemy / Bullet / Mote  <-- g.dt 로만 이동
                       Player.comboTimer      <-- g.dt 로 감소
```

`Game`은 `[DefaultExecutionOrder(-100)]`이라 같은 프레임의 `Player.Update`보다 먼저 돈다. 따라서 `Game`이 읽는 `player.acting`은 직전 프레임에 `Player`가 정한 값이다. 한 프레임 늦는 대신 실행 순서가 고정된다.

## 상태 기계

담배 상태는 `burn`(불 켜짐 여부)과 `withdrawal`(금단 남은 시간) 두 변수로 정해진다.

```
                       Q (담배 있음, Light)
        +--------------------------------------------+
        |                                            v
   [맨정신] --- (조건 없음) --- [금단] ---Q (Light)---> [악마의 시간]
        ^                          |  ^                  | |  ^
        |                          |  |                  | |  |
        |  금단 시계 0 (전투 중)    |  +-- 불이 꺼짐 ------+ |  |
        +--- Endured: 타락도 -------+     (PutOut)         | |  |
             감소                                          | |  |
                                  <-- 꽁초 투척 (PutOut) ---+ |  |
                                                            |  |
                       다 탐 + 콤보 >= 기준: 줄담배 (Light) -+--+
                       다 탐 + 콤보 <  기준: 꺼짐 (PutOut) -> [금단]
```

| 전이 | 조건 | 코드 | 결과 |
|---|---|---|---|
| 맨정신 -> 악마의 시간 | `Q`, 담배 있음 | `Cigarette()` -> `Light()` | `burn` 충전, 탄창 충전, 타락도 증가 |
| 금단 -> 악마의 시간 | `Q`, 담배 있음 | `Light()`가 `withdrawal = 0` | 금단이 그 자리에서 멎는다 |
| 악마의 시간 -> 악마의 시간 | 다 탐, `ChainRelights(combo)` 참 | `BurnOut()` -> `Light()` | 담뱃갑에서 꺼내지 않고 이어진다. 금단을 건너뛴다 |
| 악마의 시간 -> 금단 | 다 탐, 콤보 부족 | `BurnOut()` -> `PutOut()` | `withdrawal` 시작 |
| 악마의 시간 -> 금단 | 불 켜진 중 `Q` | `Cigarette()` -> `ThrowButt()` + `PutOut()` | 꽁초 폭발 후 금단 |
| 금단 -> 맨정신 | 전투 중 `withdrawal`이 0 | `Endured()` | 타락도가 내려간다 |

술과 숙취(`drunk`, `soberT`, `hangover`)는 같은 방식의 병렬 시계다. 취기가 한 단계 가실 때마다 숙취가 시작되고, 술을 한 모금 더 마시면 숙취가 멎는다. 숙취는 세계 속도가 아니라 걸음 속도와 화면 번짐을 바꾼다.

## 핵심 코드 해설

{% code title="Assets/Scripts/Game.cs (Update 일부)" %}
```csharp
float target = Rules.WorldScale(player.burn > 0, player.acting, player.withdrawal > 0 ? Rules.Stage(player.corruption) : -1) * (slow > 0 ? 0.25f : 1);
worldScale = Mathf.MoveTowards(worldScale, target, rdt * (target > worldScale ? 2.5f : 8));
dt = hitstop > 0 ? 0 : rdt * worldScale;
```
{% endcode %}

- 1행: 상태 세 개를 인자로 넘겨 목표 배율을 얻는다. `slow`는 사망 연출용 감속이다.
- 2행: `MoveTowards`로 배율을 서서히 바꾼다. 소스 주석에 따르면 느려질 때는 곧바로, 빨라질 때는 조금 천천히 바뀐다. 불이 꺼지는 순간 숨 돌릴 틈을 주기 위해서다.
- 3행: 히트스톱 중이면 `dt = 0`이라 세계가 완전히 멈춘다. 실제 시간으로 도는 주인공은 멈추지 않는다.

{% code title="Assets/Scripts/Player.cs (Update 일부)" %}
```csharp
if (comboTimer > 0 && (comboTimer -= g.dt) <= 0) combo = 0; // 세계 시간
...
if (burn > 0 && (burn -= dt * (wasActing ? 1 : Rules.IdleBurnRate)) <= 0) BurnOut();
bool fighting = g.state == Game.State.Run && !g.room.cleared;
if (fighting && withdrawal > 0 && (withdrawal -= dt) <= 0) Endured(ref withdrawal, "금단을");
```
{% endcode %}

- 콤보 제한 시간은 세계 시간으로 줄어든다. 악마의 시간에 멈춰 서 있으면 세계가 거의 멈추므로 콤보도 거의 줄지 않는다. 생각할 시간을 주는 장치다.
- 담배 연소는 실제 시간이지만 직전 프레임에 행동하지 않았으면 느리게 탄다(`IdleBurnRate`).
- 금단과 숙취는 `fighting`일 때만 줄어든다. 빈 방에서 기다려 넘길 수 없다.

{% code title="Assets/Scripts/Player.cs" %}
```csharp
void BurnOut()
{
    if (!Rules.ChainRelights(combo)) { PutOut(); return; }
    chained++;
    Light();
    ...
}

void PutOut()
{
    burn = 0;
    withdrawal = Rules.WithdrawalTime(Rules.Stage(corruption));
    ...
}
```
{% endcode %}

- 불이 꺼지는 모든 경로(`BurnOut`의 실패, 꽁초 투척)가 `PutOut()` 하나를 지난다. 금단이 "예외 없이" 오는 이유를 코드 구조가 보장한다.

## 따라 만들기

확인 상태: 미검증.

1. `Game`에 `worldScale`과 `dt` 필드를 만들고, 다른 객체는 `Time.deltaTime` 대신 `Game.I.dt`만 쓰기로 정한다. → 결과: 이후 만드는 모든 움직임이 한 곳의 `dt`를 따른다.
2. `Rules.WorldScale`을 만든다([규칙 해체](rules.md)). → 결과: 불 켜짐·행동 여부에 따라 배율이 갈린다.
3. `Game.Update`에서 목표 배율로 `worldScale`을 `MoveTowards`하고 `dt`를 계산한다. 이 컴포넌트에 실행 순서 속성을 준다. → 결과: 적 하나를 `dt`로 움직이면 불을 켠 동안 느려진다.
4. `Player`에 `acting`을 만들고 이동·사격·재장전 중에 참으로 둔다. → 결과: 가만히 서면 세계가 거의 멈추고 움직이면 느리게 흐른다.
5. `burn`, `withdrawal`과 `Light`, `BurnOut`, `PutOut`을 만든다. 불이 꺼지는 경로를 `PutOut` 하나로 모은다. → 결과: 꺼지는 방법이 늘어도 금단이 빠지지 않는다.
6. `comboTimer`를 `g.dt`로 줄이고, 금단 시계는 전투 중에만 실제 시간으로 줄인다. → 결과: 멈춘 세계에서 콤보가 유지되고, 빈 방에서는 금단이 넘어가지 않는다.
7. 히트스톱을 `dt = 0`으로 구현한다. → 결과: 맞히는 순간 적만 멈추고 주인공은 움직인다.

## 알려진 한계·주의

{% hint style="warning" %}
CAUTION: 아래는 코드 읽기에서 나온 관찰이며 실행으로 확인하지 않았다.
{% endhint %}

- `Player.Damage`의 자동 악마의 시간(타락도 높은 단계에서 방어구가 깨질 때)은 `burn`만 직접 설정하고 `withdrawal`을 0으로 만들지 않는다. 금단 중에 발동하면 금단 시계가 계속 줄어드는 것으로 읽힌다. `WorldScale`은 악마의 시간을 우선하므로 화면은 악마의 시간처럼 보인다. 의도인지 확인이 필요하다.
- `Game`이 읽는 `player.acting`은 한 프레임 늦은 값이다. 프레임이 아주 낮아지면 배율 전환이 늦게 느껴질 수 있다.
- 주인공은 히트스톱 중에도 움직인다. `Player.Update`에는 `hitstop` 검사가 없다.
- 세계 시계에 의존하는 코드가 많아서, 새 객체가 `Time.deltaTime`을 쓰면 악마의 시간에 혼자 정상 속도로 움직인다. `Mote.real` 플래그는 일부러 실제 시간을 쓰는 이펙트용이다.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성 (소스 읽기 기반, 미검증) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `Time.timeScale`을 쓰지 않고 `Game.dt`를 따로 둔 이유를 내 말로 추측해 보자. 주인공만 정상 속도로 움직여야 한다는 조건과 연결해 적는다.
- [ ] 불이 꺼지는 경로를 `PutOut()` 하나로 모은 설계의 장점을 적어 보자.
- [ ] 내가 만든 게임에서 "시간을 느리게 하는" 기능을 넣는다면 어떤 값을 분리해야 할까?
