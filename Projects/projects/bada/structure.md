# Bada 구조 지도: 목업·Core·Game 씬 해체

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-BDA-101-REF |
| 유형 | REF (소스 구조 지도) |
| 목적 | 소스 사본에 실제로 있는 폴더, 어셈블리, 실행 흐름을 한 장으로 정리한다 |
| 대상 | `JJH0204/Bada` 소스 사본 (Unity 6000.3.12f1, URP 17.3, Input System) |
| 확인 상태 | 미검증 (소스를 읽고 쓴 것이며 Unity에서 열거나 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 비공개 레포, 접근 권한 필요: [JJH0204/Bada](https://github.com/JJH0204/Bada)
{% endhint %}

{% hint style="warning" %}
CAUTION: [개요 페이지](README.md)는 Godot 4 .NET 이식판과 중계 서버를 적는다. 이 문서가 읽은 소스 사본에는 Godot 씬(`.tscn`, `.gd`, `project.godot`)과 중계 서버 코드가 없다. 사본은 Unity 낚시 슬라이스와 이식 설계 패키지(`Docs/Porting/`)만 담고 있다. 이 문서는 사본에 있는 것만 다루며, Godot·중계 서버 쪽은 쓰지 않았다.
{% endhint %}

## 1. 이 영역이 하는 일

개요 페이지가 말한 "규칙과 엔진을 분리한다"는 결정이 폴더 구조에 어떻게 나타나는지 보여 준다. 규칙은 엔진 의존이 없는 `Bada.Core`에 있고, 화면과 입력은 MonoBehaviour 하나(`BadaGame`)가 잇는다.

## 2. 구성 요소

경로는 레포 기준이다. 줄 수는 사본의 값이다.

| 경로 | 줄 | 역할 |
|---|---|---|
| `CLAUDE.md` | - | 프로젝트 사실(레이아웃, 검증 방법, 슬라이스 범위) |
| `Assets/Scripts/Core/FishingCore.cs` | 479 | 데이터 표, `SeaModel`, `FishingRod` 상태 기계. 네임스페이스 `Bada.Core` |
| `Assets/Scripts/Game/BadaGame.cs` | 276 | 유일한 MonoBehaviour. 입력, 배, 카메라, 찌와 줄, IMGUI HUD |
| `Assets/Scenes/SampleScene.unity` | - | `BadaGame` 하나를 배선한 씬 |
| `Assets/Models/*.fbx` | - | Boat, Bobber, Island, 물고기 5종(Fish_round, flat, torpedo, long, squid) |
| `Assets/Tests/EditMode/FishingCoreTests.cs` | 142 | 규칙 단위 테스트 |
| `Assets/Tests/PlayMode/PlaySliceTests.cs` | 75 | 키보드만으로 낚시 한 바퀴를 도는 종단 테스트 |
| `Tools/blender/make_assets.py` | 256 | Blender 스크립트로 FBX 에셋 생성 |
| `Docs/mockup.html` | - | three.js 웹 목업. 규칙과 수치의 기준 |
| `Docs/fishing-spec.md` | 707 | 목업에서 뽑은 낚시 규칙 명세 |
| `Docs/Porting/` | - | 이식 설계 패키지: `PORTING.md`, `WORKSTREAMS.md`, `ACCEPTANCE.md`, `data/*.json` 20개, `tools/*.js` 2개 |

어셈블리 정의는 `Assets/Scripts/Core/Bada.Core.asmdef`, `Assets/Tests/EditMode/Bada.Core.Tests.asmdef`, `Assets/Tests/PlayMode/Bada.PlayMode.Tests.asmdef` 세 개다. `Game` 폴더에는 asmdef가 없다.

## 3. 데이터 흐름

```
 Docs/mockup.html (기준)
      │  extract_data.js / golden.js  (Node로 실행, 이 환경에서는 미실행)
      ▼
 Docs/Porting/data/*.json ──(손으로 옮김)──▶ FishingData (C# 표)
                                                    │
 키보드 ─▶ BadaGame.Update ─▶ FishingRod.Tick(dt, 릴 잡는 중?)
              │                    ▲   │ Say / Landed / Lost 콜백
              │   AbundanceProvider│   ▼
              └──▶ SeaModel.Abund(미끼, 구역, x, z, 시각)   내레이션·어창
                                   │
                    Draw(): 카메라·찌·줄·손에 든 고기, OnGUI(): HUD
```

한 프레임의 순서(`BadaGame.Update`)는 다음과 같다.

1. 시각을 올린다(`hour += dt / 45`, 게임 한 시간이 실제 45초).
2. `E`, `R` 키를 처리한다(조타실 출입, 닻).
3. 조타실 밖이면 낚시 입력을 처리한다(`Fishing`).
4. 닻 진행도와 배 이동을 갱신한다(`Sail`).
5. `rod.Tick(dt, 릴을 감는 중인가)`로 규칙을 한 걸음 진행한다.
6. 카메라, 찌, 줄, 손에 든 고기를 그린다(`Draw`).

## 4. 핵심 코드 해설

{% code title="Assets/Scripts/Game/BadaGame.cs (Start 일부)" %}
```csharp
rod = new FishingRod(new System.Random()) {
    AbundanceProvider = b => SeaModel.Abund(b, Zone, boat.position.x, boat.position.z, hour),
    CurrentZone = Zone };
rod.Say = s => narr = s;
rod.Landed = ShowCatch;
```
{% endcode %}

* 규칙 객체(`FishingRod`)는 난수 생성기와 "지금 위치의 어종별 확률"을 함수로 받는다. 엔진 객체를 직접 잡지 않는다.
* 결과는 콜백(`Say`, `Landed`)으로 나온다. 화면 쪽은 콜백에서 문자열과 손에 든 고기만 갱신한다.
* 난수 주입의 자세한 내용은 [규칙과 난수 주입](rules-rng.md)에 적었다.

{% code title="Assets/Scripts/Game/BadaGame.cs (Sail 일부)" %}
```csharp
if (atHelm && anchorP <= 0) {
    float thr = (k.wKey.isPressed ? 1 : 0) - (k.sKey.isPressed ? .5f : 0), ...;
    speed = Mathf.Lerp(speed, thr * 9.5f, 1 - Mathf.Exp(-dt * 1.3f));
    ...
}
```
{% endcode %}

* 배는 조타실에서 닻이 완전히 올라온 상태(`anchorP <= 0`)일 때만 움직인다. 목업의 `tickBoat` 규칙이다(코드 주석).
* 이동 보간은 `1 - e^(-dt·k)` 꼴이어서 프레임 속도와 무관하다.

## 5. 따라 만들기

슬라이스 하나를 같은 구조로 만드는 순서다.

1. Unity 6 URP 프로젝트에 Input System 패키지를 넣는다. → 결과: 프로젝트가 컴파일된다.
2. `Assets/Scripts/Core/`에 어셈블리 정의를 만들고 `UnityEngine`을 쓰지 않는 규칙 코드를 둔다(예외: 사본의 `FishingCore.cs`는 `Mathf`와 `Vector2` 때문에 `UnityEngine`을 쓴다). → 결과: Core가 단독으로 컴파일된다.
3. 데이터 표와 `SeaModel`을 먼저 옮긴다([데이터 표](data-tables.md)). → 결과: 어종별 확률을 함수로 얻는다.
4. `FishingRod` 상태 기계를 옮기고 EditMode 테스트로 고정한다([규칙과 난수 주입](rules-rng.md)). → 결과: 시드를 고정한 테스트가 통과한다.
5. Blender 스크립트로 로우폴리 FBX를 만들어 `Assets/Models/`에 둔다([렌더링](render-postfx.md)). → 결과: 프리팹으로 쓸 메시가 생긴다.
6. `BadaGame` MonoBehaviour를 만들어 입력, 배, 카메라, 찌, HUD를 잇는다. 씬에는 오브젝트 하나만 둔다. → 결과: 키보드로 던지기부터 어창 넣기까지 한 바퀴가 돈다.
7. PlayMode 테스트로 키 입력을 흉내 내어 한 바퀴를 자동으로 돈다. → 결과: 어창에 고기가 1마리 들어간다.

확인 상태: 미검증. 위 단계는 소스를 읽고 정리한 것이며 실행하지 않았다.

## 6. 알려진 한계와 주의

* 슬라이스 범위는 연안(구역 0), 1년차 첫날, 앉아서 낚기까지다. 연료, 구역 이동, 마을·마트·시장, 요리, 달력과 날씨, 소리, 재고 고갈은 아직 옮기지 않았다(`CLAUDE.md`).
* `Keyboard.current`가 null이면 `BadaGame.Update`의 `k.eKey`에서 예외가 난다(코드 읽기). 키보드 없는 장치는 고려하지 않은 프로토타입이다.
* 사본에는 이식 설계(`PORTING.md`)가 그리는 `Assets/_Bada/{Core,Data,Game,Rendering,UI,World}` 구조가 아직 없다. 지금 구조는 `Assets/Scripts/{Core,Game}` 두 폴더다.
* 사본의 `CLAUDE.md` 상태 절은 "로컬 main이 푸시되지 않았다"고 적는다. 사본이 그 이후 상태인지는 확인 필요.

## 7. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성 (소스 사본 읽기 기준) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 규칙 코드와 MonoBehaviour를 나눈 설계가 테스트에 어떤 도움이 되었는지 내 경험으로 적으면?
- [ ] 목업을 "기준"으로 두고 Unity와 Godot으로 옮긴 과정에서, 사본에 남지 않은 부분은 무엇이었는가?
