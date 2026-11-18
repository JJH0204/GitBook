# APOSTATE 전투: 사격·밀치기·처형·탄환

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-APO-105-DO |
| 유형 | D&O (해체 분석) |
| 목적 | 사격, 밀치기, 처형, 탄환 충돌, 적의 방어(방패, 성가대 무적)가 코드에서 어떻게 맞물리는지 설명한다 |
| 확인 상태 | 미검증 (소스를 읽고 쓴 문서다. 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 소스는 비공개 레포 `JJH0204/apostate`다. 비공개 레포, 접근 권한 필요. 미발표 프로젝트라 밸런스 수치는 적지 않고 상수 이름으로만 가리킨다.
{% endhint %}

## 이 영역이 하는 일

전투의 핵심 동사는 세 가지다. 멀리서 쏘기(여러 발 필요), 붙어서 쏘기(한 발에 처형), 밀치기(밀어내고 멈추게 하고 방패를 연다). 이 셋이 `Player.Shoot`, `Player.Melee`, `Enemy.Hit`, `Enemy.Shove`에 나뉘어 있고, 판정 규칙은 `Rules`의 함수가 맡는다.

## 구성 요소

| 위치 | 이름 | 역할 |
|---|---|---|
| `Player.cs` | `Shoot()` | 탄을 소모하고 `Bullet.Fire`로 탄환을 만든다. 탄이 없으면 재장전 |
| `Player.cs` | `Melee()` | 부채꼴 안의 적에게 `Enemy.Shove`를 호출 |
| `Player.cs` | `OnKill(executed)` | 콤보 증가, 탄 회수, 담배 연소 회복 |
| `Player.cs` | `Damage(from, cause)` | 방어구가 있으면 한 칸 소모, 없으면 `Game.Die` |
| `Bullet.cs` | `Fire`, `Update`, `Sweeps` | 탄환 이동과 구간 충돌 검사 |
| `Enemy.cs` | `Hit(dmg, from, melee, close)` | 피격 처리 순서: 무적, 방패, 피해, 처형 |
| `Enemy.cs` | `Shielded`, `Blocks(from)`, `Shove(...)` | 성가대 무적, 방패 방향 검사, 밀치기 |
| `Rules.cs` | `IsClose`, `ShotDamage`, `MeleeMul` | 처형 거리 판정, 피해 계산 |

## 데이터 흐름

```
좌클릭 -> Player.Update (입력 버퍼) -> Shoot()
             rounds-- , Bullet.Fire(위치, 방향*속도, hostile=false)
                 |  origin = 쏜 순간 주인공 위치
                 v
          Bullet.Update (g.dt)
             적마다 Sweeps(이동 구간, 적 위치, 반지름) 검사
             close = Rules.IsClose(적까지 거리 - 반지름)   <-- origin 기준
             e.Hit(Rules.ShotDamage(close, 보스 여부), origin, close)
                 |
                 v
          Enemy.Hit
             1) 성가대 노래 안(Shielded)  -> 무시
             2) 방패가 정면(Blocks)       -> 막힘
             3) execute = close && 보스 아님
             4) hp -= dmg
             5) execute 이거나 hp <= 0    -> Die(execute) -> player.OnKill(execute)

우클릭 -> Player.Melee() -> 부채꼴 안 적마다 Enemy.Shove -> 밀기, 멈춤(stun), Hit(melee: true)
적 탄환/공격 -> Player.Damage -> 방어구 있음: 한 칸 소모, 콤보 끊김 / 없음: Game.Die
```

## 핵심 코드 해설

{% code title="Assets/Scripts/Bullet.cs" %}
```csharp
static bool Sweeps(Vector2 p, Vector2 step, Vector2 target, float r) =>
    (target - (p + step * Mathf.Clamp01(Vector2.Dot(target - p, step) / Mathf.Max(step.sqrMagnitude, 1e-6f)))).magnitude <= r;
...
bool close = Rules.IsClose((e.Pos - origin).magnitude - e.radius);
e.Hit(Rules.ShotDamage(close, e.kind == Kind.God), origin, close: close);
```
{% endcode %}

- `Sweeps`: 이번 프레임에 탄환이 이동하는 선분과 표적 중심 사이의 최단 거리를 구한다. 빠른 탄환이 표적을 한 프레임에 뚫고 지나가는 문제(터널링)를 막는다.
- 처형 거리는 "맞은 순간"이 아니라 "쏜 순간의 주인공 위치(`origin`)"에서 적 표면까지의 거리다. 쏜 뒤에 물러나도 처형 여부가 바뀌지 않는다.

{% code title="Assets/Scripts/Enemy.cs (Hit 일부)" %}
```csharp
if (!Targetable) return;
if (Shielded) { ...; return; }
if (!melee && Blocks(from)) { ...; return; }
bool execute = close && kind != Kind.God;
...
hp -= dmg; flash = 1;
if (execute || hp <= 0) Die(execute);
```
{% endcode %}

- 판정 순서가 규칙이다. 성가대 무적이 방패보다 먼저, 방패가 피해보다 먼저다.
- 방패는 원거리 사격만 막는다(`!melee`). 밀치기는 방패를 무시하고, 밀린 적은 `stun` 동안 방패가 열린다(`Blocks`가 `stun <= 0`을 요구한다).
- 처형은 피해 계산이 아니라 `execute` 플래그다. 보스만 처형되지 않고 대신 근접 피해가 배가 된다(`ShotDamage`).

{% code title="Assets/Scripts/Player.cs" %}
```csharp
public void OnKill(bool executed)
{
    combo = comboTimer > 0 ? combo + 1 : 1;
    comboTimer = Rules.ComboWindow; kills++;
    ...
    rounds = Mathf.Min(Rules.Rounds, rounds + (executed ? Rules.ExecuteRefund : Rules.KillRefund));
    ...
    AddBurn(Rules.BurnBack(combo, executed));
}
```
{% endcode %}

- 처치할 때마다 세 가지가 함께 일어난다: 콤보 증가, 탄 회수(처형이 더 많이), 담배 연소 회복. 이 보상이 "붙어서 처형하며 불을 잇는" 플레이를 만든다. 담배와 세계 시계의 연결은 [세계 시계](world-clock.md)를 본다.

{% code title="Assets/Scripts/Player.cs (Damage 일부)" %}
```csharp
if (!Rules.Survives(armor)) { g.Die(cause); return true; }
armor--; combo = 0; comboTimer = 0; invuln = Rules.ArmorInvuln;
```
{% endcode %}

- 체력이 없고 방어구 칸만 있다. 방어구가 한 대를 막으면 콤보가 끊기고 짧은 무적이 생긴다. 사망 원인 문자열 `cause`는 요약 화면에 쓰인다.

## 적의 방어 구조

| 방어 | 코드 | 깨는 법 |
|---|---|---|
| 방패(수호천사) | `Blocks(from)`: 정면 각도 안의 원거리 사격만 막는다 | 옆이나 뒤로 돌아간다, 밀쳐서 `stun`을 건다 |
| 성가대 무적 | `Shielded`: 성가대가 살아 있고 일정 반경 안이면 무적 | 성가대를 먼저 처치한다 |
| 보스 | 처형 불가, 근접 사격 피해 배수 | 근접 사격을 누적한다 |

적 행동은 `Enemy.Update`의 `switch (kind)` 하나에 모여 있다. 종류마다 "예고 -> 공격 -> 회복" 단계(`step`)와 타이머(`t`)를 쓴다. 예고(`Art.Warn`, 조준선)가 있어서 공격은 피할 수 있다.

## 따라 만들기

확인 상태: 미검증.

1. `Bullet`을 만든다. 위치와 속도를 가지고 `Update`에서 `Game.I.dt`만큼 이동한다. → 결과: 세계 속도에 따라 느려지는 탄환이 날아간다.
2. 이동을 구간 검사(`Sweeps`)로 구현한다. → 결과: 빠른 탄환이 얇은 적을 지나치지 않는다.
3. 탄환이 생성될 때 쏜 위치(`origin`)를 저장하고, 충돌 시 그 위치로 처형 거리를 판정한다. → 결과: 가까이서 쏜 탄만 처형한다.
4. `Enemy.Hit`을 무적, 방패, 피해, 처형 순서로 쓴다. → 결과: 판정 순서가 코드 한 곳에 보인다.
5. `Enemy.Shove`와 `stun`을 만든다. `Blocks`가 `stun`을 보게 한다. → 결과: 밀친 뒤 방패가 열린다.
6. `Player.OnKill`에서 콤보, 탄 회수, 연소 회복을 처리한다. → 결과: 처치 보상이 한 함수에 모인다.
7. `Player.Damage`에서 방어구 소모와 사망을 처리한다. → 결과: 방어구가 없으면 한 대에 죽는다.
8. 적 종류마다 단계 변수(`step`, `t`)로 예고와 회복을 만든다. → 결과: 공격 전에 예고가 보인다.

## 알려진 한계·주의

- 모든 적 행동이 `Enemy.Update`의 하나의 `switch`에 있어 종류를 늘리면 파일이 길어진다(현재 322줄).
- 탄환마다 `GameObject`를 만들고 `Destroy`한다. 오브젝트 풀을 쓰지 않는다. 보스전의 탄막 밀도에서 부담이 되는지는 확인하지 않았다.
- 적 탄환은 방 영역 밖으로 나가면 사라진다(`InRoom` 검사). 기둥도 탄환을 막는다.
- 탄환이 적을 맞히는 순서는 `Game.enemies` 리스트 순서다. 겹친 적이 있으면 먼저 검사된 적이 맞는다.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성 (소스 읽기 기반, 미검증) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 처형 거리를 "맞은 순간"이 아니라 "쏜 순간" 기준으로 판정할 때 플레이어가 느끼는 차이를 적어 보자.
- [ ] 무적, 방패, 피해 순서를 바꾸면 어떤 상황에서 규칙이 달라지는지 하나만 예를 들어 보자.
- [ ] 내가 만든 게임에서 "보상이 한 번에 여러 개 따라오는" 처치 규칙이 있다면 어떻게 한 곳에 모을까?
