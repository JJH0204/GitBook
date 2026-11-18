# APOSTATE 절차 생성: FloorGen과 시드 재현

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-APO-104-DO |
| 유형 | D&O (해체 분석) |
| 목적 | 시드 하나로 층의 방 구성을 정하는 `FloorGen`의 구조와, 같은 시드가 같은 층을 만드는 방법을 설명한다 |
| 확인 상태 | 미검증 (소스를 읽고 쓴 문서다. 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 소스는 비공개 레포 `JJH0204/apostate`다. 비공개 레포, 접근 권한 필요. 미발표 프로젝트라 적 조합 목록과 밸런스 수치는 적지 않는다.
{% endhint %}

## 이 영역이 하는 일

`FloorGen.Generate(int seed)`는 방 계획의 목록 `List<RoomPlan>`을 돌려준다. 계획에는 방 이름, 크기, 기둥 위치, 적 종류와 위치와 등장 무리, 유품 위치가 들어 있다. 실제 방 오브젝트는 `Game.AddRoom`이 계획을 받아 만든다.

설계 원칙은 둘이다.

- 같은 시드는 언제나 같은 층을 만든다(하드 로그라이크의 시드 공개와 재현).
- 계획을 만드는 코드는 씬 객체를 만들지 않는다. 그래서 테스트가 씬 없이 300개 시드를 검사할 수 있다.

## 구성 요소

| 이름 | 종류 | 역할 |
|---|---|---|
| `RoomPlan` | 클래스 | 방 하나의 계획: `name`, `w`, `h`, `pillars`, `spawns`(적 종류·위치·무리 번호), `relic` |
| `FloorGen.CombatRooms` | 상수 | 전투 방 개수 |
| `Encounters` | 3중 배열 | 깊이 구간별(1번째 방, 2번째 방, 3~4번째 방) 조우 후보. 후보 하나는 "무리의 배열" |
| `Names` | 배열 | 방 이름 후보. 시드로 뽑고 겹치지 않게 지운다 |
| `Layouts` | 배열 | 기둥 배치 틀(-1~1 좌표). 방 크기에 맞춰 늘린다 |
| `Generate(seed)` | 함수 | 계획 목록을 만든다 |
| `Scale`, `Place` | 보조 함수 | 틀을 방 크기로 변환, 적 종류별 위치 배정 |

## 데이터 흐름

```
seed (int)
  |
  v
new System.Random(seed)  ---- 모든 무작위는 이 rng 하나에서만 뽑는다
  |
  +-- 첫 방: 이름과 크기 고정, 적 없음
  |
  +-- 전투 방 i = 1..CombatRooms
  |      이름 뽑기(남은 후보에서) -> 크기 -> 기둥 틀 -> 조우 후보 뽑기(깊이별 목록에서, 뽑으면 목록에서 제거)
  |      -> 무리마다 적마다 Place(rng, ...) 로 위치 -> 유품 방이면 유품 위치
  |
  +-- 마지막 방: 보스 한 명
  v
List<RoomPlan>  --->  Game.AddRoom(plan) 이 방을 오브젝트로 만든다
```

## 핵심 코드 해설

{% code title="Assets/Scripts/FloorGen.cs (Generate 일부)" %}
```csharp
var rng = new System.Random(seed);
...
int relicRoom = 2 + rng.Next(CombatRooms - 1);
for (int i = 1; i <= CombatRooms; i++)
{
    int n = rng.Next(names.Count);
    var p = new RoomPlan { name = names[n], w = 22 + 2 * rng.Next(4), h = 11 + rng.Next(3) };
    names.RemoveAt(n);
    ...
    var pool = pools[Mathf.Min(i, Encounters.Length) - 1];
    int pick = rng.Next(pool.Count);
    ...
    pool.RemoveAt(pick);
```
{% endcode %}

- 첫 줄: `UnityEngine.Random`이 아니라 시드를 받는 `System.Random`이다. 같은 시드에서 같은 순서로 뽑으면 같은 수열이 나온다.
- `names.RemoveAt(n)`, `pool.RemoveAt(pick)`: 뽑은 후보를 지워서 한 층 안에서 방 이름과 조우가 겹치지 않게 한다. 3~4번째 방은 같은 목록(`Encounters`의 세 번째 항목)에서 뽑으므로 이 제거 덕분에 서로 다른 조우가 나온다.
- `pools[Mathf.Min(i, Encounters.Length) - 1]`: 방 번호가 목록 수를 넘으면 마지막 목록을 쓴다.

{% code title="Assets/Scripts/FloorGen.cs (Place 일부)" %}
```csharp
for (int tries = 0; tries < 40; tries++)
{
    float x = Mathf.Lerp(p.w * x0, Mathf.Min(p.w * x1, p.w / 2 - 1.5f), (float)rng.NextDouble());
    ...
    Vector2 q = at = new Vector2(wave % 2 == 1 ? -x : x, y);
    if (System.Array.TrueForAll(p.pillars, c => (c - q).magnitude > 2) && taken.TrueForAll(t => t.wave != wave || (t.pos - q).magnitude > 2)) break;
}
```
{% endcode %}

- 적 종류마다 x 범위와 y 범위가 다르다(수호천사는 앞줄, 심판관은 안쪽 구석 등). 역할이 위치로 드러난다.
- 둘째 무리처럼 번호가 홀수인 무리(`wave % 2 == 1`)는 x 부호를 뒤집어 들어온 문 쪽에 놓는다. 그래서 방마다 "안쪽으로 파고들었다가 등 뒤로 돌아 나오는" 길이 생긴다.
- 기둥과 같은 무리의 다른 적에서 일정 거리 이상 떨어진 점이 나올 때까지 최대 40번 다시 뽑는다.

## 따라 만들기

확인 상태: 미검증.

1. `RoomPlan` 클래스를 만든다. 필드는 이름, 크기, 기둥 배열, 적 배열(종류, 위치, 무리 번호), 유품 위치다. → 결과: 컴파일된다.
2. `FloorGen`을 `public static class`로 만들고 `Generate(int seed)`에서 `new System.Random(seed)`만 무작위 원천으로 쓴다. → 결과: `UnityEngine.Random` 호출이 파일에 없다.
3. 조우 후보를 깊이 구간별 배열로 적는다. 구간마다 후보를 세 개 이상 둔다. → 결과: 같은 구간에서 후보를 뽑아도 겹치지 않게 뽑은 후보를 지운다.
4. 방 이름, 기둥 틀, 크기를 `rng`에서 뽑는다. 뽑은 이름은 목록에서 지운다. → 결과: 한 층에서 이름이 겹치지 않는다.
5. 적 종류별 위치 규칙을 `Place`로 만든다. 기둥과 다른 적에서 떨어지게 하고, 시도 횟수에 상한을 둔다. → 결과: 대부분의 적이 기둥과 겹치지 않는다(상한을 넘으면 마지막 점을 쓰므로 보장은 아니다).
6. `Game.StartRun(int? fixedSeed)`에서 시드를 받아 `FloorGen.Generate`를 호출하고 계획마다 `AddRoom`을 부른다. 시드를 주지 않으면 새 시드를 뽑는다. → 결과: 같은 시드를 주면 같은 층이 나온다.
7. 지난 시드를 기억해 두었다가 다시 시작할 수 있게 한다(`lastSeed`). → 결과: 같은 층 재도전이 된다.
8. 테스트를 만든다([테스트 설계](tests.md)). → 결과: 같은 시드 동일, 다른 시드 상이, 300개 시드에서 규칙이 지켜진다.

## 알려진 한계·주의

- `Place`는 40번 안에 조건을 만족하는 점을 못 찾으면 마지막으로 시도한 점을 그대로 쓴다. 기둥이나 다른 적과 겹칠 수 있다. 테스트(`FloorGenTests`)는 방 경계와 입구 앞 배치를 검사하지만 기둥 겹침은 검사하지 않는다.
- `System.Random`의 같은 시드가 어느 런타임에서나 같은 수열을 낸다고 보장하는 문서는 이 레포에 없다. 같은 시드를 다른 Unity 버전이나 플랫폼에서 공유할 계획이면 확인이 필요하다.
- 시드는 `Game.StartRun`이 `UnityEngine.Random.Range`로 뽑는다. 시드 선택은 `FloorGen` 바깥이다.
- 유품 위치와 방 이름 같은 값은 시드로 정해지지만, 전투 중의 무작위(총알 퍼짐, 이펙트)는 `UnityEngine.Random`이라 같은 시드여도 전투가 똑같이 재생되지는 않는다.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성 (소스 읽기 기반, 미검증) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 같은 시드가 같은 층을 만들어야 하는 이유를 로그라이크 플레이어의 입장에서 적어 보자.
- [ ] 조우를 "완전 무작위"가 아니라 후보 목록에서 뽑는 방식의 장점은 무엇일까?
- [ ] `Place`의 40번 시도 제한이 없다면 어떤 문제가 생길지 추측해 보자.
