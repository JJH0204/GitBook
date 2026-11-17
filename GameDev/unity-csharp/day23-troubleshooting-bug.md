# Day 23 · 트러블슈팅 노트 ②: 투사체가 바닥에 먹히는 버그

> 4주차 Unity 코어와 트러블슈팅 · 60분 · 준비물: 🎮 Unity 6, [TEMPLATE.md](troubleshooting/template.md). 수정 커밋은 팀 저장소 `1eafcc37`

## 오늘의 목표
- 스윕 쿼리(`SphereCast` 계열)가 시작부터 겹친 콜라이더를 어떻게 보고하는지 설명할 수 있다.
- 버그 노트를 "재현 → 계측 → 원인 → 최소 수정 → 회귀 확인" 흐름으로 쓸 수 있다.
- 한 줄짜리 수정이 왜 맞는지, 어디까지 못 막는지 말할 수 있다.

---

## 1. 읽기 (10분)

### 1-1. 시작부터 겹쳐 있으면 스윕 쿼리는 어떻게 답하나

스윕 쿼리는 도형을 출발점에서 방향으로 밀면서 처음 닿는 곳을 찾는다. 그런데 **출발 순간에 이미 콜라이더 안에 있으면** API마다 답이 다르다.

| API | 시작부터 겹친 콜라이더 |
|---|---|
| `Physics.Raycast`, `Physics.SphereCast` (단일 결과) | **무시한다.** 히트로 보고하지 않는다 |
| `Physics.SphereCastAll`, `Physics.SphereCastNonAlloc` | 히트로 보고한다. `distance = 0`, `normal = -(스윕 방향)`, `point = (0, 0, 0)` |

둘 다 Unity 문서의 Notes에 적혀 있다. 단일 버전은 "감지하지 않는다", All/NonAlloc 버전은 "normal을 스윕 반대 방향으로, distance를 0으로 둔다"고 되어 있다.
즉 NonAlloc 결과에서 `distance == 0`인 히트는 **표면에 닿은 게 아니라 원래 안에 있었다**는 뜻이고, 그 `normal`은 표면 방향과 아무 관계가 없다.

### 1-2. 재료: 사실만 모았다

**문제 상황**
- "몬스터가 플레이어를 안 때린다"는 체감이 있었다. 원거리 몬스터 Bboo의 투사체가 최대 사거리 근처에서 플레이어에게 닿기 전에 사라졌다.

**재현과 계측**
- 에디터의 던전 미리보기에서 플레이어를 Bboo 3마리가 배치된 방으로 순간이동시켰다. 정상이라면 가만히 있는 플레이어가 약 20초 안에 죽는다.
- 런타임에 이벤트 버스의 공격 이벤트(`EnemyAreaAttackEvent`)와 피격 이벤트(`PlayerDamagedEvent`)를 구독해 로그를 남기고, 로그를 세서 **발사 수 대비 명중 수**를 냈다.
- 문제 조건에서 명중이 **0/10**이었다.

**원인**
- 투사체는 매 프레임 이전 위치에서 현재 위치까지 `Physics.SphereCastNonAlloc`(반지름 0.28)으로 스윕했다.
- 포물선 끝에서 내려올 때는 이전 위치가 이미 바닥 안에 들어가 있었다. 그러면 바닥 히트가 `distance 0`, `normal = -(스윕 방향)`으로 들어온다.
- 코드는 `normal.y < 0.7`이고 장애물이면 "벽에 막혔다"고 처리했다. 완만하게 내려오는 투사체는 스윕 방향의 y가 작아서 반대 방향 normal의 y도 0.7보다 작다. 그래서 **바닥을 벽으로 오판**해 투사체를 없앴다.

**수정 (1줄)**
```csharp
// 벽 판정 조건에 h.distance > 0f 추가
else if (h.distance > 0f && h.normal.y < .7f && CombatObstruction.IsBlocker(h.collider, caster.transform))
```
- 근거: 진짜 벽은 바깥에서 날아와 표면에 먼저 닿으므로 `distance > 0`이다. `distance 0`은 "출발할 때 이미 안에 있었다"는 뜻이다.

**결과**
- 문제 조건 명중 0/10 → 6/6. 다른 두 조건도 수정 후 3/3, 4/4로 회귀가 없었다.

### 1-3. 선택 재료: 종료할 때 크래시 (후보 03)

시간이 남거나 다른 날 노트를 하나 더 쓸 때 쓴다.
- 증상: 게임을 끌 때 `D3D12Core.dll`에서 접근 위반(0xC0000005)이 났다. 타이틀만 보고 끄면 드물었고(1/30), 플레이 후 끄면 잦았다(2/3).
- 분석: 이 PC에 cdb가 없어서 Python 디버거를 붙이고 UnityPlayer PDB로 콜스택을 봤다. 엔진 종료 중 D3D12 PSO 라이브러리 캐시를 저장(`SaveCache` → `Serialize` → `memcpy`)하면서 크기를 이미 해제된 메모리(`0xFEEEFEEE`, Windows 디버그 힙이 해제한 메모리에 채우는 값)에서 읽고 있었다. 엔진의 use-after-free이고 우리 코드가 아니었다.
- 해결: 실행 인자 `-force-d3d12-single-pso-disk-cache`로 다른 캐시 경로를 쓰게 했다(`boot.config`에 넣으면 효과가 없어서 Steam 실행 옵션에 넣었다). 세이브는 크래시 지점보다 먼저 끝나서 데이터는 안전했다. 이후 D3D11로 전환하면서 이 경로 자체가 사라졌다.

---

## 2. 손으로 확인 (40분)

> AI, 자동완성, 검색 없이. 막히면 위의 읽기로 돌아간다.

### 실습 1 🎮: 겹친 채 출발하는 스윕 직접 보기 (10분)

`practice/UnityLab`의 빈 씬에 빈 GameObject를 만들고 아래 스크립트를 붙인다. **실행 전에 4줄의 출력을 예측해 적는다.** 특히 B의 두 줄이 어떻게 다를지 적는다.

```csharp
// Unity: OverlapSweepTest.cs
using UnityEngine;

public class OverlapSweepTest : MonoBehaviour
{
    readonly RaycastHit[] _hits = new RaycastHit[8];

    void Start()
    {
        var floor = GameObject.CreatePrimitive(PrimitiveType.Cube);
        floor.name = "Floor";
        floor.transform.localScale = new Vector3(10f, 1f, 10f);  // 윗면 y = 0.5
        Physics.SyncTransforms();                                 // 방금 바꾼 Transform을 물리에 반영

        Vector3 dir = new Vector3(1f, -0.5f, 0f).normalized;      // 완만하게 내려가는 투사체
        Sweep("A", new Vector3(0f, 2f, 0f), dir);                // 바닥 위에서 출발
        Sweep("B", new Vector3(0f, 0.4f, 0f), dir);              // 바닥에 파묻힌 채 출발
    }

    void Sweep(string label, Vector3 origin, Vector3 dir)
    {
        const float radius = 0.28f, distance = 4f;
        bool single = Physics.SphereCast(origin, radius, dir, out RaycastHit hit, distance);
        Debug.Log($"{label} SphereCast: {single}" + (single ? $" dist={hit.distance:F2} normal={hit.normal}" : ""));

        int n = Physics.SphereCastNonAlloc(origin, radius, dir, _hits, distance);
        for (int i = 0; i < n; i++)
            Debug.Log($"{label} NonAlloc[{i}] {_hits[i].collider.name} dist={_hits[i].distance:F2} normal={_hits[i].normal} point={_hits[i].point}");
    }
}
```

<details><summary>예상 출력과 해설 (Unity 6000.3에서 확인)</summary>

```
A SphereCast: True dist=2.73 normal=(0.00, 1.00, 0.00)
A NonAlloc[0] Floor dist=2.73 normal=(0.00, 1.00, 0.00) point=(2.44, 0.50, 0.00)
B SphereCast: False
B NonAlloc[0] Floor dist=0.00 normal=(-0.89, 0.45, 0.00) point=(0.00, 0.00, 0.00)
```

- A: 바닥 윗면(y = 0.5)에 정상적으로 닿는다. normal은 위쪽 (0, 1, 0)이다.
- B, 단일 `SphereCast`: 시작부터 겹친 바닥을 무시해서 False다.
- B, `NonAlloc`: 같은 바닥을 distance 0으로 보고한다. normal (-0.89, 0.45, 0)은 스윕 방향 (0.89, -0.45, 0)을 뒤집은 값일 뿐이다. y가 0.45라서 버그 코드의 `normal.y < 0.7` 조건을 통과한다. 바닥이 "벽"이 되는 순간이다.

</details>

추가 과제: `bool IsWall(RaycastHit h)`를 버그 버전과 수정 버전으로 두 개 써서 B의 히트에 각각 적용하고 결과를 출력한다.

### 실습 2: 노트 쓰기 (30분)

1. `troubleshooting/TEMPLATE.md`를 `troubleshooting/02-projectile-floor.md`로 복사한다.
2. `문제 상황`에는 플레이어가 느낀 증상과 재현 조건을 쓴다.
3. `원인 분석`에는 **어떻게 재현을 자동화했는지**(이벤트 구독 로그로 명중 수 세기)와 결정적 증거(distance 0, normal = 스윕 반대 방향)를 쓴다. 실습 1의 출력을 근거로 붙여도 좋다.
4. `해결 과정`에는 고른 수정(1줄)과 버린 대안을 쓴다. 대안 예: 단일 `SphereCast`로 바꾸기, 바닥 레이어를 쿼리에서 빼기. 각각 왜 버렸는지 한 줄씩 쓴다.
5. `결과` 표에 조건별 명중 수를 넣고, 측정 조건 칸에 표본 수를 쓴다.
6. `남은 한계`를 쓴다. 표본이 작다는 점과 자동 테스트가 없다는 점이 있다. 그 밖의 한계는 꼬리 질문 Q1을 보고 쓴다.
7. 시간이 남으면 1-3의 재료로 `03-quit-crash.md`의 문제 상황과 원인 분석만 먼저 써 둔다.

**자기 점검**
- [ ] `distance 0`이 무슨 뜻인지 노트만 읽고도 이해된다
- [ ] 수정이 왜 한 줄로 충분한지 근거가 있다
- [ ] 수정이 못 막는 경우를 적었다
- [ ] 내가 하지 않은 일(예: 자동 테스트 추가)을 한 것처럼 쓰지 않았다

---

## 3. 꼬리 질문 대비 (10분)

노트를 덮고 소리 내어 답한다. 펼쳐서 방향만 비교한다.

**Q1. `distance > 0` 조건이 놓치는 경우는 없나요?**
<details><summary>답의 방향</summary>
있습니다. 시전자가 벽에 붙어 있어서 투사체가 처음부터 벽 안에서 출발하면 그 벽도 distance 0이라 벽으로 처리되지 않고 통과할 수 있습니다. 날아가는 도중에는 직전 프레임 스윕이 벽 표면에 먼저 닿기 때문에 이 경우가 생기지 않습니다. 보완하려면 발사 순간에 `OverlapSphere`로 한 번 더 검사하면 됩니다. 이 보완은 당시 적용하지 않았고 한계로 남겼습니다.

</details>

**Q2. 그냥 단일 `SphereCast`로 바꾸면 겹친 바닥을 무시하니까 해결되지 않나요?**
<details><summary>답의 방향</summary>
바닥은 무시되지만, 같은 규칙으로 시작부터 겹친 다른 콜라이더도 전부 무시됩니다. 이미 플레이어와 겹친 위치에서 출발하는 근거리 명중을 놓칠 수 있습니다. 또 이 투사체는 여러 히트 중 가장 가까운 피격 대상과 장애물을 비교해야 해서 히트 목록이 필요했습니다. 그래서 NonAlloc은 유지하고 distance 0의 의미만 바르게 해석했습니다.

</details>

**Q3. 재현은 어떻게 했나요? 손으로 플레이했나요?**
<details><summary>답의 방향</summary>
에디터에서 플레이어를 몬스터가 있는 방의 고정 위치로 옮기고, 이벤트 버스의 공격 이벤트와 피격 이벤트를 구독해 로그를 남긴 뒤 로그를 세서 명중률을 냈습니다. 매번 같은 조건에서 수치로 비교할 수 있어서 수정 전후를 0/10과 6/6처럼 말할 수 있었습니다.

</details>

**Q4. 같은 버그가 다시 생기지 않게 하려면요?**
<details><summary>답의 방향</summary>
지금은 수동 측정만 했고 표본도 작습니다. "바닥 안에서 출발한 스윕이 벽으로 판정되지 않는다"를 PlayMode 테스트로 남기는 게 다음 단계입니다. 실습 1처럼 바닥 하나와 스윕 한 번이면 되니 테스트 비용도 작습니다.

</details>

**Q5. (선택 재료) 종료 크래시가 우리 코드 탓이 아니라고 어떻게 판단했나요?**
<details><summary>답의 방향</summary>
디버거와 PDB로 본 콜스택이 처음부터 끝까지 엔진 종료 경로(그래픽스 디바이스 소멸자 → PSO 캐시 저장 → memcpy)였고, 복사할 크기를 디버그 힙이 해제한 메모리 패턴인 0xFEEEFEEE에서 읽고 있었습니다. 같은 시그니처가 Steam 설치본과 여러 개발 빌드에서 반복됐고, 실행 인자로 그 저장 경로를 바꾸자 사라졌습니다.

</details>

---

## 오늘의 한 줄
> (내 말로 한 문장)

## 더 보기
- [Physics.SphereCast (Notes: 겹친 콜라이더는 감지하지 않음)](https://docs.unity3d.com/ScriptReference/Physics.SphereCast.html)
- [Physics.SphereCastNonAlloc (Notes: 시작부터 겹치면 distance 0)](https://docs.unity3d.com/ScriptReference/Physics.SphereCastNonAlloc.html)
- [RaycastHit](https://docs.unity3d.com/ScriptReference/RaycastHit.html)
- [Physics.SyncTransforms](https://docs.unity3d.com/ScriptReference/Physics.SyncTransforms.html)
