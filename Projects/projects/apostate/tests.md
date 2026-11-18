# APOSTATE 테스트 설계: EditMode와 PlayMode

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-APO-106-DO |
| 유형 | D&O (해체 분석) |
| 목적 | 순수 규칙은 EditMode 테스트로, 입력 경로와 게임 루프는 PlayMode 테스트로 나눠 고정하는 방식을 설명한다 |
| 확인 상태 | 미검증 (소스를 읽고 쓴 문서다. 테스트를 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 소스는 비공개 레포 `JJH0204/apostate`다. 비공개 레포, 접근 권한 필요. 테스트가 확인하는 개수와 시간은 레포 README의 설명을 따른 것이며 이 문서에서 실행해 확인하지 않았다.
{% endhint %}

## 이 영역이 하는 일

테스트를 두 층으로 나눈다.

| 층 | 위치 | 확인 대상 | 씬 필요 |
|---|---|---|---|
| EditMode | `Assets/Tests/EditMode` | `Rules`, `FloorGen`의 순수 함수 | 없음 |
| PlayMode | `Assets/Tests/PlayMode` | 실제 입력 경로와 게임 루프 | `Game` 씬을 로드한다 |

레포 README는 EditMode 30개, PlayMode 13개라고 적는다. PlayMode 전체는 1분 30초쯤 걸린다고 한다(레포 README 기준, 미확인).

## 구성 요소

| 파일 | 역할 |
|---|---|
| `Apostate.Tests.EditMode.asmdef` | Editor 전용 어셈블리. `Apostate`와 TestRunner 참조, NUnit 사용 |
| `Apostate.Tests.PlayMode.asmdef` | 런타임 테스트 어셈블리. `Apostate`, Input System 및 Input System 테스트 프레임워크 참조 |
| `RulesTests.cs` | 규칙 함수의 경계값과 부등식 |
| `FloorGenTests.cs` | 시드 재현성과 생성 규칙 |
| `GameplayTests.cs` | 가상 키보드·마우스로 진행하는 통합 테스트. `InputTestFixture`를 상속 |

두 테스트 어셈블리 모두 `defineConstraints: UNITY_INCLUDE_TESTS`를 쓰고 `Apostate`(스크립트 어셈블리)를 참조한다.

## 데이터 흐름

```
EditMode:  [Test] -> Rules.함수(입력) / FloorGen.Generate(seed) -> Assert
                      (Unity 씬 없음)

PlayMode:  [UnityTest] -> SceneManager.LoadSceneAsync("Game")
              -> Game.I, Game.I.player 참조 -> g.StartRun()
              -> Press/Release (가상 키보드, 마우스) -> yield return (프레임 진행)
              -> 상태(p.burn, p.combo, e.hp, g.state 등)를 Assert
```

## 핵심 코드 해설

{% code title="Assets/Tests/EditMode/RulesTests.cs" %}
```csharp
[Test]
public void ChainRelight_NeedsTheThresholdCombo()
{
    Assert.IsFalse(Rules.ChainRelights(Rules.ChainCombo - 1));
    Assert.IsTrue(Rules.ChainRelights(Rules.ChainCombo));
}
```
{% endcode %}

- 값을 직접 쓰지 않고 상수(`Rules.ChainCombo`)를 기준으로 경계 바로 아래와 위를 확인한다. 수치를 고쳐도 테스트가 따라간다. 설계 의도(기준 이상이면 이어진다)만 고정한다.
- 일부 테스트(예: 세계 속도, 연소 회복)는 값 자체를 단언한다. 수치를 바꾸면 이 테스트도 고쳐야 한다.

{% code title="Assets/Tests/EditMode/RulesTests.cs (Withdrawal 테스트 일부)" %}
```csharp
for (int stage = 0; stage <= 4; stage++)
{
    Assert.Greater(Rules.WithdrawalWorld(stage), 1);
    ...
    if (stage == 0) continue;
    Assert.Greater(Rules.WithdrawalTime(stage), Rules.WithdrawalTime(stage - 1));
```
{% endcode %}

- 값이 아니라 "맨정신보다 나쁘고, 단계가 오를수록 커진다"는 부등식을 고정한다. 밸런스 값을 자주 고치는 프로토타입에 맞는 방식이다.

{% code title="Assets/Tests/EditMode/FloorGenTests.cs" %}
```csharp
[Test]
public void SameSeed_BuildsTheSameFloor() => Assert.AreEqual(Describe(482913), Describe(482913));
```
{% endcode %}

- `Describe(seed)`는 층 전체를 문자열로 만든다. 같은 시드의 두 결과가 같은지, 다른 시드의 결과가 다른지 비교한다. 이 밖에 300개 시드를 돌며 "첫 방은 비어 있다", "마지막 방은 보스뿐", "유품은 층에 하나", "방마다 세 무리" 같은 불변 조건을 확인한다.

{% code title="Assets/Tests/PlayMode/GameplayTests.cs" %}
```csharp
IEnumerator StartRun()
{
    yield return SceneManager.LoadSceneAsync("Game");
    yield return null;
    g = Game.I; p = g.player;
    Assert.AreEqual(Game.State.Hub, g.state, "게임은 그날 밤 거점에서 시작한다");
    g.StartRun();
    yield return null;
}
```
{% endcode %}

- 모든 PlayMode 테스트가 실제 씬을 로드하고 같은 방식으로 시작한다. 입력은 `Press(button, queueEventOnly: true)`로 가상 장치에 넣어, 실제 입력 경로를 통과시킨다.

## PlayMode가 확인하는 흐름

레포 README의 설명과 테스트 이름을 정리하면 다음과 같다.

| 묶음 | 확인 내용 |
|---|---|
| 기본 입력 | 이동과 사격 |
| 세계 시계 | 악마의 시간의 세계 속도, 멈춘 동안 콤보가 줄지 않음 |
| 생존 | 맨몸 즉사, 방어구가 한 대를 막음 |
| 전투 규칙 | 근접 처형과 탄 회수, 방패와 밀치기, 보스 처형 불가와 근접 배수 |
| 담배·반발 | 줄담배(기준 이상은 이어지고 미만은 금단), 금단과 숙취의 시계, 참아내기 |
| 진행 | 방 등급과 담배 지급, 모든 방과 보스를 거친 승리·사망·거점 복귀·같은 시드 재시작 |
| 각본 플레이 | 단순한 주인공이 한 방을 정리하는 시나리오 4가지를 돌려 줄담배 사용 여부와 피격 빈도를 비교 |

## 따라 만들기

확인 상태: 미검증.

1. 스크립트 폴더에 `Apostate.asmdef`를 만든다. → 결과: 스크립트가 별도 어셈블리가 된다.
2. `Assets/Tests/EditMode`에 Editor 전용 테스트 어셈블리를 만들고 `Apostate`와 TestRunner, NUnit을 참조한다. → 결과: Test Runner의 EditMode 탭에 테스트가 보인다.
3. `Rules`의 판정 함수마다 경계값 테스트를 하나씩 쓴다. 상수에서 경계를 계산한다. → 결과: 수치를 바꿔도 테스트가 깨지지 않는다.
4. 단계 곡선 함수는 단계 0~4를 돌며 부등식을 확인한다. → 결과: 곡선이 단조롭게 유지된다.
5. `FloorGen`은 같은 시드 동일, 다른 시드 상이, 시드 수백 개의 불변 조건을 쓴다. → 결과: 생성 규칙이 깨지면 실패한다.
6. `Assets/Tests/PlayMode`에 테스트 어셈블리를 만들고 Input System 테스트 프레임워크를 참조한다. `InputTestFixture`를 상속한 클래스에서 가상 키보드와 마우스를 추가한다. → 결과: 실제 키 입력 없이 입력 경로를 시험한다.
7. 씬을 로드하고 `Game.I`를 잡아 한 시나리오씩 `[UnityTest]`로 쓴다. 프레임 진행은 `yield return null`로 한다. → 결과: 시나리오 하나가 한 규칙을 확인한다.
8. 오래 걸리는 시나리오는 `Time.timeScale`을 올리고, 끝나면 `TearDown`에서 1로 되돌린다. → 결과: 다음 테스트에 영향이 없다.
9. 실행은 Editor의 `Window > General > Test Runner` 또는 Unity CLI로 한다(PlayMode는 비동기 실행 후 상태 확인). → 결과: 두 탭의 테스트가 통과한다.

## 알려진 한계·주의

- PlayMode 테스트는 시간 의존이 있다. `Wait(seconds)`로 프레임을 기다리고 `Time.timeScale`을 올리므로 느린 기기에서 불안정할 수 있다. 실행해 확인하지 않았다.
- 각본 플레이 테스트는 난이도를 증명하지 않는다. 레포 README도 사람이 직접 플레이한 평가가 아니라고 밝힌다. 이 테스트는 "시스템이 돌아간다"를 확인한다.
- 테스트가 `Game.I`와 `Game`의 공개 필드(`p.burn`, `p.combo` 등)를 직접 읽으므로, 이 필드의 이름을 바꾸면 테스트도 고쳐야 한다.
- 입력 시뮬레이션은 `Press(... queueEventOnly: true)`에 의존한다. Input System 패키지 버전이 바뀌면 동작을 다시 확인해야 한다.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성 (소스 읽기 기반, 미검증) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 규칙 테스트를 "값 고정"이 아니라 "부등식과 경계 고정"으로 쓰는 것이 프로토타입에 맞는 이유를 적어 보자.
- [ ] EditMode로 충분한 것과 PlayMode가 필요한 것을 내 프로젝트에서 하나씩 골라 보자.
- [ ] 각본 플레이 테스트가 "재미"를 보장하지 못하는 이유를 내 말로 설명해 보자.
