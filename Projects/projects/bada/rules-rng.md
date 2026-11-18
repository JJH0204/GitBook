# Bada 규칙과 난수 주입

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-BDA-102-DO |
| 유형 | D&O (규칙 구조와 난수 주입) |
| 목적 | 낚시 규칙(`FishingRod`)이 난수와 확률을 밖에서 받아 테스트로 고정되는 구조를 설명한다 |
| 대상 | `Assets/Scripts/Core/FishingCore.cs`, `Assets/Tests/EditMode/FishingCoreTests.cs` |
| 확인 상태 | 미검증 (소스를 읽고 썼으며 테스트를 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 비공개 레포, 접근 권한 필요: [JJH0204/Bada](https://github.com/JJH0204/Bada). 구조는 [구조 지도](structure.md)를 먼저 본다.
{% endhint %}

## 1. 목적

낚싯대 규칙이 엔진 없이 돌고, 난수를 한 곳으로 모아 테스트에서 값을 고정하는 방법을 정리한다. 개요 페이지의 결정("난수를 한 곳으로 모으면 테스트에서 값을 고정할 수 있다")이 코드에서 어떻게 구현됐는지가 핵심이다.

## 2. 구성 요소

| 요소 | 위치 | 역할 |
|---|---|---|
| `RodState` | `FishingCore.cs` | 상태 6개: `Stowed, Wait, Bite, Hooked, Empty, Fight` |
| `FishingRod` | 같은 파일 | 상태 기계. 생성자에서 `System.Random`을 필수로 받는다 |
| `AbundanceProvider` | `Func<int, float[]>` | 미끼 번호를 받아 어종별 확률 가중치를 돌려주는 주입점 |
| `Say`, `Landed`, `Lost` | `Action` 필드 | 내레이션, 잡힘, 놓침을 화면 쪽에 알리는 콜백 |
| `SeaModel` | 같은 파일 | 수온, 물때, 서식지로 어종별 가중치를 계산하는 정적 함수 |
| `FishingCoreTests` | `Assets/Tests/EditMode/` | 시드를 고정한 규칙 테스트 |

## 3. 동작 원리

상태 전이는 다음과 같다(코드의 메서드 기준).

```
Stowed --Cast(미끼 있음, 피로<100)--> Wait
Wait   --대기 시간 끝(StartBite)--> Bite        (어종 추첨, 미끼 소모. 에기는 유지)
Wait   --입질 중 Strike--> Stowed(35%: 미끼 손실) 또는 Wait(+20~45초)
Bite   --Hook--> Fight
Bite   --4초 경과--> Hooked(35%, 45초) | Empty | Wait(에기)
Hooked --Hook--> Fight  /  --45초--> Empty (에기면 Wait)
Empty  --ReelIn--> Stowed
Fight  --남은 줄 D<=0--> Stowed + Landed
Fight  --장력 100 이상 0.65초 초과 / 장력 3 이하 3.5초 초과--> Stowed + Lost
```

난수는 세 군데에서 쓰인다. 모두 같은 `random` 필드 하나에서 나온다.

1. 대기 시간과 입질 횟수(`RollWait`).
2. 어종 추첨과 무게(`StartBite`): 가중치 합에 `NextDouble()`을 곱해 앞에서부터 빼며 고른다. 무게는 `min + (max-min)·r^1.8`이고 `r^1.8 < .04`면 어린 고기다(갑각류 제외, 전설 어종 제외).
3. 싸움의 요동 간격과 세기(`TickFight`)와 문장 고르기(`Pick`).

확률 가중치는 `SeaModel.Abund`가 계산한다. 곱셈 항은 어종 기본 풍부도, 수온 적합도(`Fit`), 구역 가중치, 시간대(`TimeF`), 물때(`TideFactor`), 서식지(`0.3 + 2.5·HabF`), 미끼 배수다.

## 4. 핵심 코드 해설

{% code title="Assets/Scripts/Core/FishingCore.cs (FishingRod 생성자)" %}
```csharp
public FishingRod(System.Random random)
{
    this.random = random ?? throw new ArgumentNullException(nameof(random));
}
```
{% endcode %}

* 난수 생성기를 안에서 만들지 않고 밖에서 받는다. 테스트는 `new Random(7)`처럼 시드를 줘서 같은 결과를 얻고, 게임은 `new System.Random()`을 준다(`BadaGame.Start`).
* `UnityEngine.Random`을 쓰지 않으므로 규칙이 엔진 상태에 묶이지 않는다.

{% code title="Assets/Tests/EditMode/FishingCoreTests.cs (SeededWait_ReachesBite)" %}
```csharp
var rod = new FishingRod(new Random(7)) { AbundanceProvider = FullAbundance };
rod.SetBait(0);
rod.Cast();
for (int i = 0; i < 4000 && rod.State == RodState.Wait; i++) rod.Tick(.1f, false);
Assert.That(rod.State, Is.EqualTo(RodState.Bite));
```
{% endcode %}

* `FullAbundance`는 첫 어종 가중치만 100인 배열을 돌려주는 테스트용 함수다. 확률도 주입 가능해서 바다 모델 없이 규칙만 시험한다.
* 시간은 `Tick(dt, ...)`로 밖에서 넣는다. 실제 시간이 흐르기를 기다리지 않고 0.1초씩 4000번 돌린다.
* 같은 파일의 다른 테스트는 `PrematureNibbleStrike_UsesBaitStealTransition`(시드 0~99를 돌며 미끼 손실 전이를 찾는다), `HoldingAtMaximumTensionForOverPoint65Seconds_Snaps`(줄 끊김), `LightFish_LandsWithAlternatingTensionControl`(감았다 풀기로 낚아 올림) 등이다.

## 5. 따라 만들기

확인 상태: 미검증.

1. 상태 열거형과 클래스를 만들고 생성자에서 난수 생성기를 받는다. → 결과: `new FishingRod(new Random(1))`이 컴파일된다.
2. 확률 가중치를 돌려주는 `Func<int, float[]>` 속성을 둔다. → 결과: 테스트가 배열을 직접 넣는다.
3. 시간은 `Tick(dt, holdingReel)` 한 메서드로만 넣는다. → 결과: 반복문으로 시간을 감는다.
4. 대기 시간은 `mean = clamp(200 / (0.6 + 2.2·합), 40, 180)`초에 `(0.6 + 0.4·(r1+r2))`를 곱해 정한다(`RollWait`). 합이 0.04 미만이면 입질 없이 40초를 더 기다린다. → 결과: 가중치가 클수록 대기가 짧아진다.
5. 싸움은 장력 `T`(0~100), 남은 줄 `D`, 고기 기력 `energy`로 계산한다. 감는 동안 `T`가 오르고 `D`가 준다. → 결과: `T`를 35~80에 두면 기력이 줄어든다.
6. 결과는 콜백으로만 내보낸다. → 결과: 규칙 코드가 UI를 모른다.
7. 시드 여러 개를 돌려 전이마다 테스트를 하나씩 쓴다. → 결과: 시드 고정 테스트가 같은 결과를 반복한다.

## 6. 알려진 한계와 주의

* 코드의 수치는 목업을 옮긴 것이고 "가상 수치"다(`PORTING.md`). 조정은 별도 작업이다.
* `TideFactor`는 물때 9 고정(`Flow(9)`, `HighT(9)`), `SeaTemperature`는 0일차 고정이다. 슬라이스는 달력이 없어서 한 날만 표현한다(코드 읽기).
* 이식 설계가 말하는 재고·셀 고갈, 비 보정(`×1.1`)은 `SeaModel.Abund`에 없다.
* `Say`, `Landed`, `Lost`는 속성이 아닌 공개 필드다. 테스트는 `+=`로 구독하고 게임은 `=`로 덮어쓴다. 둘을 섞으면 앞선 구독이 사라진다.
* 이식 설계(`WORKSTREAMS.md`)는 `IRandom` 인터페이스와 `dotnet test`용 비엔진 테스트 프로젝트를 제안한다. 사본에는 둘 다 없다(`System.Random` 직접 사용, EditMode 테스트만).
* 개요 페이지가 말한 "하루 전체를 키와 마우스로 플레이하는 자동 테스트"는 사본에 없다. 사본의 PlayMode 테스트는 낚시 한 바퀴만 다룬다. 확인 필요.

## 7. 약어·용어

| 용어 | 뜻 |
|---|---|
| 입질(nibble) | 본 입질 전에 찌가 흔들리는 신호. 이때 챔질하면 너무 이르다 |
| 장력 T | 줄이 받는 힘. 초록 구간 35~80, 100 이상이면 끊긴다 |
| 에기 | 인조 미끼. 소모되지 않고 줄이 터질 때만 잃는다 |
| 시드 | 난수 생성기의 시작값. 같으면 같은 수열이 나온다 |

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성 (소스 사본 읽기 기준) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 난수를 밖에서 주입하면 테스트가 어떻게 쉬워지는지 내 말로 설명하면?
- [ ] 시드를 고정한 테스트가 통과해도 확인하지 못하는 것은 무엇인가?
- [ ] 입질과 싸움의 수치를 조정하면서 가장 먼저 만져 본 값은 무엇이었는가?
