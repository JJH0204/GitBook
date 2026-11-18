# Bada 데이터 표: 목업에서 JSON 추출, C# 표

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-BDA-103-REF |
| 유형 | REF (데이터 표와 추출 도구) |
| 목적 | 목업의 데이터를 JSON으로 뽑는 도구와, 사본의 C# 데이터 표가 그 JSON과 어떻게 대응하는지 정리한다 |
| 대상 | `Docs/Porting/data/*.json`, `Docs/Porting/tools/*.js`, `Assets/Scripts/Core/FishingCore.cs`의 `FishingData` |
| 확인 상태 | 미검증 (소스를 읽고 썼으며 Node 도구와 Unity를 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 비공개 레포, 접근 권한 필요: [JJH0204/Bada](https://github.com/JJH0204/Bada)
{% endhint %}

{% hint style="warning" %}
CAUTION: 제목과 달리 사본에서 "JSON에서 C#을 자동 생성"하는 코드는 확인하지 못했다. 사본의 `FishingData`는 JSON 값을 손으로 옮긴 정적 배열이다. 개요 페이지가 말한 자동 생성은 사본에 없는 Godot 이식판의 이야기로 보이며 확인 필요.
{% endhint %}

## 1. 이 영역이 하는 일

목업(`Docs/mockup.html`) 안에 흩어진 표를 한 번 JSON으로 꺼내 놓고, 이식판은 그 JSON을 기준으로 삼는다. 수치를 다시 타이핑하지 않게 하는 것이 목적이다(`PORTING.md` §0: "Import these; do not retype numbers").

## 2. 구성 요소

| 파일 | 역할 |
|---|---|
| `Docs/Porting/tools/extract_data.js` | 목업의 데이터 블록을 Node로 평가해 JSON 20개를 쓴다 |
| `Docs/Porting/tools/golden.js` | 목업의 순수 바다·달력 모델을 Node로 돌려 기준 출력(`golden_model.json`)을 쓴다 |
| `Docs/Porting/data/species.json` | 어종 17종: 수온 범위, 구역, 서식지, 시간대, 무게, 싸움 세기, 가격, 가식 비율, 미끼 배수 |
| `Docs/Porting/data/zones.json` | 바다 구역 3개: 연료, 이동 시간, 반경, 수심 범위, 섬, 암초, 수심 잡음 계수 |
| `Docs/Porting/data/baits.json`, `fish_families.json` | 미끼 4종, 어류 계열과 칼질 횟수 |
| `Docs/Porting/data/calendar.json`, `weather.json` | 절기 24개, 계절, 물때 이름, 날씨 종류 |
| `Docs/Porting/data/economy.json`, `pantry.json`, `mart_goods.json` 외 | 연료·초기 상태, 식료, 요리·민박·버프 표 |
| `Docs/Porting/data/boat_layout.json`, `village_layout.json` | 배와 마을의 치수와 상호작용 지점 |
| `Docs/Porting/data/sky_palette.json` | 시각별 하늘 색 키프레임, 구역별 바다 색 |
| `Docs/Porting/data/golden_model.json` | 해시, 달력, 수온, 적합도, 풍부도 등 기준 출력(허용 오차 1e-5) |
| `Assets/Scripts/Core/FishingCore.cs` (`FishingData`) | 슬라이스가 쓰는 표: 미끼, 구역, 세계, 어종 |

JSON은 20개 파일, 합계 약 100KB다.

## 3. 데이터 흐름

```
 Docs/mockup.html ──node extract_data.js <html> <출력 폴더>──▶ data/*.json (20개)
                  ──node golden.js <html> <출력 파일>────────▶ data/golden_model.json
                                                                 │
        (슬라이스) 손으로 옮김 ─────────────────────────────────▶ FishingData (C#)
        (설계안)   WS0: 타입 레코드 + 로더로 JSON을 읽음 ───────▶ 단위 테스트가 golden 값과 비교
```

## 4. 핵심 코드 해설

{% code title="Docs/Porting/tools/extract_data.js (발췌)" %}
```javascript
const html = fs.readFileSync(src, 'utf8');
const js = html.slice(html.indexOf('<script>\n(() =>') + 8, html.lastIndexOf('</script>'));
const cut = (a, b) => { const i = js.indexOf(a), j = js.indexOf(b, i); ... return js.slice(i, j); };
const data = cut("/* ---------- 데이터", "/* ---------- 달력과 바다 모델");
const f = new Function('$', helpers + data + ... + `return { ${names.join(', ')} };`);
const D = f(() => null);
```
{% endcode %}

* HTML 안의 스크립트에서 "데이터" 절만 문자열로 잘라 `new Function`으로 평가한다. 파서를 따로 만들지 않고 목업이 가진 객체를 그대로 얻는다.
* 절 경계를 주석 문자열(`/* ---------- 데이터`)로 찾으므로, 목업의 그 주석을 바꾸면 도구가 `marker missing` 오류를 낸다.
* 도구는 평가한 객체를 파일별로 `w('species.json', {...})` 형태로 쓴다. 각 파일은 `_note`에 필드 이름 뜻을 적는다.

{% code title="Assets/Scripts/Core/FishingCore.cs (FishingData.S, 발췌)" %}
```csharp
S("볼락","white","round","#7a4a30","#e0b78d",8,16,1,.4f,0,"reef","dusk",1,.15f,.5f,.3f,18000,.40f,1,1.4f,.5f,.05f),
...
private static Species S(string n, string f, string sh, string c0, string c1, float t0, float t1,
    float z0, float z1, float z2, string h, string ti, float ab, float w0, float w1, float s,
    float p, float ed, float b0, float b1, float b2, float b3, bool stripe = false, bool legend = false)
```
{% endcode %}

* 위치 인자가 22개다. `species.json`의 필드 순서(`n, fam, shape, c, t, z, hab, time, ab, w, s, price, ed, b`)를 펼친 것이다. 볼락의 값은 JSON과 일치한다(수온 8~16, 구역 1/.4/0, 무게 .15~.5, 가격 18000).
* `stripe`와 `legend`는 기본값이 `false`다. 고등어는 `stripe: true`, 돗돔은 `legend: true`로 적었다.
* 이 방식은 열 순서를 바꾸면 컴파일은 되지만 값이 어긋난다. 숫자 22개라서 눈으로 검증하기 어렵다.
* `FishingData.Worlds`는 `zones.json`의 `world`(반경 `R`, 수심 `depth`, 섬, 암초, 수심 잡음 `dk`)를 옮긴 것이다. 슬라이스는 구역 3개 모두를 표에 담고 실제 플레이는 구역 0만 쓴다(`BadaGame`의 `const int Zone = 0`).

## 5. 따라 만들기

확인 상태: 미검증. 사본의 설계안(`WORKSTREAMS.md` WS0)을 따른 순서다.

1. 목업 안의 데이터 블록 시작과 끝에 주석 표식을 둔다. → 결과: 도구가 두 표식을 찾는다.
2. 데이터 블록을 `new Function`으로 평가하는 Node 스크립트를 만든다. → 결과: 객체 이름 목록이 반환된다.
3. 영역별로 JSON 파일을 쓰고 `_note`에 필드 뜻을 적는다. → 결과: `data/` 아래에 파일이 생긴다.
4. 같은 방식으로 순수 모델 함수(해시, 수온, 적합도 등)의 출력을 `golden_model.json`에 기록한다. → 결과: 기준 값 표가 생긴다.
5. C# 쪽에 JSON 필드 이름 그대로의 레코드 타입과 로더를 만든다(설계안). 사본은 이 단계를 건너뛰고 정적 배열을 쓴다. → 결과: JSON 전체가 타입 객체로 읽힌다.
6. EditMode 테스트가 `golden_model.json` 값을 1e-5 오차로 비교한다(설계안, 사본의 테스트는 아직 이 비교가 없다). → 결과: 목업과 C# 모델이 같은 값을 낸다.

## 6. 알려진 한계와 주의

* 사본의 `FishingCoreTests`는 `golden_model.json`을 읽지 않는다. 어종 17개 표가 JSON과 일치하는지는 볼락과 돗돔만 대조했다. 나머지는 확인 필요.
* `FishingData.Zones`의 `Zone` 클래스(`Out`, `Travel`)는 슬라이스에서 쓰이지 않는다. 사본의 `CLAUDE.md`도 미사용 표를 정리 대상으로 적는다.
* `Species.EdibleYield`, `Stripe`, `Reef.Mark`도 현재 쓰이지 않는다(`CLAUDE.md`의 후속 과제).
* 목업의 가격 단위는 kg당 원이고 수치 전부가 가상 값이다(`species.json`의 `_note`, `PORTING.md`).
* 도구는 이 환경에서 실행하지 않았다. 목업이 바뀌면 `PORTING.md`의 명령으로 다시 생성한다.

## 7. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성 (소스 사본 읽기 기준) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 표를 손으로 옮기는 방식과 JSON에서 생성하는 방식 중, 이 프로젝트에서 실제로 어느 쪽을 썼고 이유는 무엇이었는가?
- [ ] 기준 값(골든 값)을 두면 어떤 종류의 실수를 잡을 수 있는지 한 가지 예를 들면?
