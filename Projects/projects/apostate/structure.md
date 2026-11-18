# APOSTATE 구조 지도: Rules·FloorGen·Game·Player·Enemy·Hud

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-APO-101-REF |
| 유형 | REF (소스 구조 목록) + 해체 분석 읽는 순서 |
| 목적 | APOSTATE 프로토타입의 스크립트 구성, 의존 방향, 한 프레임의 흐름을 한 장에 정리한다 |
| 확인 상태 | 미검증 (소스를 읽고 쓴 문서이며 Unity에서 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서의 소스는 비공개 레포 `JJH0204/apostate`다. 비공개 레포, 접근 권한 필요. 레포를 열 수 없는 독자는 이 문서와 [프로젝트 개요](README.md)만으로 구조를 따라갈 수 있게 썼다.
{% endhint %}

{% hint style="info" %}
NOTE: 아직 발표하지 않은 프로젝트라 밸런스 수치(시간, 거리, 개수)와 이야기 내용은 적지 않는다. 상수는 이름으로만 가리킨다. 값은 레포의 `Assets/Scripts/Rules.cs`에서 확인한다.
{% endhint %}

## 이 문서가 하는 일

APOSTATE는 Unity 6(URP 2D)으로 만든 탑다운 건카타 로그라이크 프로토타입이다. 장르와 설계 원칙은 [프로젝트 개요](README.md)에 있다. 이 해체 분석 묶음은 같은 구조를 따라 만들 수 있게 코드를 영역별로 풀어 쓴다.

이 프로젝트의 구조적 특징은 셋이다.

- 씬에는 카메라와 `Game` 컴포넌트 하나만 있다. 방, 주인공, 적, HUD는 모두 실행 중 코드로 만든다.
- 수치와 규칙은 `Rules.cs`, 층 구성은 `FloorGen.cs`에 순수 함수로 모은다. 두 파일은 `UnityEngine.Random`이나 씬 객체를 쓰지 않아 EditMode 테스트로 고정할 수 있다.
- 적, 탄환, 이펙트는 실제 시간이 아니라 "세계 시계" `Game.dt`로 움직인다. 주인공만 실제 시간으로 움직인다. 이것이 악마의 시간을 만드는 장치다.

## 구성 요소

| 파일 (`Assets/Scripts/`) | 역할 | 이 묶음의 페이지 |
|---|---|---|
| `Rules.cs` | 상수와 규칙 함수(`WorldScale`, `Grade`, `Stage`, `BurnBack` 등). 전부 `static` | [규칙 해체](rules.md) |
| `FloorGen.cs` | 시드로 방 이름·크기·기둥·적 배치를 정하는 `Generate(int seed)`와 `RoomPlan` | [절차 생성](floorgen.md) |
| `Game.cs` | 거점과 층 만들기, 세계 시계, 방 잠금과 무리 강림, 방 등급, 사망·승리, 카메라, 충돌(`Walk`) | [세계 시계](world-clock.md) |
| `Player.cs` | 이동, 조준, 사격, 밀치기, 담배·금단, 술·숙취, 타락도, 피격 | [세계 시계](world-clock.md), [전투](combat.md) |
| `Enemy.cs` | 적 5종(`Kind`)의 행동, 피격 판정, 처형, 방패, 성가대 무적 | [전투](combat.md) |
| `Bullet.cs` | 탄환 한 발의 이동과 충돌(구간 검사) | [전투](combat.md) |
| `Mote.cs`, `Art.cs`, `Sfx.cs` | 이펙트 조각, 코드로 만든 도형 스프라이트, 합성 효과음 | 이 문서 |
| `Hud.cs` | IMGUI로 그리는 HUD와 화면들. 상태를 읽기만 한다 | 이 문서 |
| `Apostate.asmdef` | 스크립트 어셈블리. Input System과 URP를 참조한다 | [테스트 설계](tests.md) |

테스트는 `Assets/Tests/EditMode`(`RulesTests.cs`, `FloorGenTests.cs`)와 `Assets/Tests/PlayMode`(`GameplayTests.cs`)에 있다.

## 의존 방향

```
Rules.cs  <-----------------------------+
FloorGen.cs ---- (Kind 타입만) ---> Enemy.cs
   ^                                     |
   |                                     v
Game.cs  <----------- Game.I ------ Player.cs, Enemy.cs, Bullet.cs, Mote.cs, Hud.cs
   |
   +-- 만든다: Player, Hud (Awake에서 AddComponent)
```

- `Rules`는 아무것도 참조하지 않는다(`Mathf`만 쓴다). 모든 파일이 `Rules`를 읽는다.
- `FloorGen`은 `Enemy.cs`의 `enum Kind`만 참조한다.
- `Game`은 `Game.I` 정적 참조로 모든 객체가 접근한다. 의존이 한 방향(모두 -> Game)이라 단순하지만, 객체가 `Game.I`에 묶인다.

## 데이터 흐름: 한 프레임

```
Game.Update()  (DefaultExecutionOrder -100: 가장 먼저 실행)
  1. 세계 속도 목표값 = Rules.WorldScale(불 켜짐, 주인공 행동 중, 금단 단계)
  2. worldScale을 목표값으로 서서히 이동 -> dt = 히트스톱 ? 0 : 실제dt * worldScale
  3. 방 상태 판정: 앞 무리가 거의 쓰러지면 다음 무리 강림 / 마지막 무리면 방 정리
  4. 카메라, 후처리, 연출 값(demon, crave, sick) 갱신
        |
        v
Player.Update()   실제 시간으로 입력 처리, 담배/금단/술/숙취 시계, 사격
Enemy.Update()    g.dt로 행동 (switch로 종류별 분기)
Bullet.Update()   g.dt로 이동, 충돌 -> Player.Damage / Enemy.Hit
Mote.Update()     g.dt(또는 real이면 실제 시간)
Hud.OnGUI()       상태를 읽어 그린다
```

실행 순서 보장은 `Game`의 `[DefaultExecutionOrder(-100)]` 한 곳뿐이다. 나머지 컴포넌트 사이의 순서는 정해져 있지 않다.

## 구현 순서(따라 만들기 권장 순서)

1. 빈 URP 2D 프로젝트를 만든다. 패키지는 Input System과 URP를 쓴다. → 결과: `Apostate.asmdef` 같은 어셈블리 정의를 만들 수 있다.
2. [규칙 해체](rules.md)를 먼저 따라 `Rules.cs`와 EditMode 테스트를 만든다. → 결과: 씬 없이 테스트가 통과한다.
3. [절차 생성](floorgen.md)을 따라 `FloorGen.cs`를 만든다. → 결과: 같은 시드가 같은 층을 만든다.
4. `Game`, `Player`, `Enemy`, `Bullet`을 최소 형태로 만든다. [세계 시계](world-clock.md)와 [전투](combat.md)를 따른다. → 결과: 방 하나에서 이동·사격·처치가 된다.
5. 마지막에 HUD와 이펙트를 붙인다. → 결과: 상태가 화면에 보인다.
6. [테스트 설계](tests.md)의 PlayMode 테스트로 입력 경로를 고정한다.

## 알려진 한계·주의

- `Game.I` 싱글턴과 `static` 규칙 덕분에 코드는 짧지만, `Game` 없이 `Player`나 `Enemy`를 단독 테스트할 수 없다. PlayMode 테스트가 필요한 이유다.
- 그래픽과 효과음은 전부 코드로 만든다. `Art.cs`는 도형 스프라이트를 런타임에 생성하고, `Sfx.cs`는 효과음을 합성한다. 에셋 파이프라인 문서는 이 묶음에 없다.
- `Hud.cs`는 IMGUI(`OnGUI`)를 쓴다. 높이 1080 기준 가상 화면 좌표로 그린다.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성 (소스 읽기 기반, 미검증) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 씬에 컴포넌트를 하나만 두고 나머지를 코드로 만드는 방식의 장점과 불편한 점을 내 경험으로 적어 보자.
- [ ] `Rules`와 `FloorGen`을 순수 함수로 둔 덕분에 가능한 것은 무엇인가?
