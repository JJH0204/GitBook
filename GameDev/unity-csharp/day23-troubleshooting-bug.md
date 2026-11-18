# Day 23 · 트러블슈팅 노트 ②: 투사체가 바닥에 먹히는 버그

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UCS-024-TS |
| 유형 | TS (문제 해결) + 재현 실습 + 노트 작성 실습 |
| 목적 | 시작부터 겹친 콜라이더를 `SphereCastNonAlloc`이 어떻게 보고하는지 이해하고, 투사체가 바닥에 사라지는 버그를 "재현 → 계측 → 원인 → 최소 수정 → 회귀 확인" 노트로 쓴다 |
| 적용 대상 | Unity 6000.3, 3D 물리(PhysX) |
| 소요 시간 | 60분 (4주차 Unity 코어와 트러블슈팅) |
| 확인 상태 | 미검증 (코드와 원본 노트를 읽고 정리했으며 이 환경에서 실행하지 않았다. 원본의 예상 출력은 원작성자가 Unity 6000.3에서 확인한 값이다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 수정 커밋은 팀 저장소 `1eafcc37`이다. 준비물은 Unity 6 프로젝트(`practice/UnityLab`)와 [트러블슈팅 노트 템플릿](troubleshooting/template.md)이다.
{% endhint %}

## 1. 학습 목표

- 스윕 쿼리(`SphereCast` 계열)가 시작부터 겹친 콜라이더를 어떻게 보고하는지 설명할 수 있다.
- 버그 노트를 "재현 → 계측 → 원인 → 최소 수정 → 회귀 확인" 흐름으로 쓸 수 있다.
- 한 줄짜리 수정이 왜 맞는지, 어디까지 못 막는지 말할 수 있다.

## 2. 증상

- "몬스터가 플레이어를 안 때린다"는 체감이 있었다.
- 원거리 몬스터 Bboo의 투사체가 최대 사거리 근처에서 플레이어에게 닿기 전에 사라졌다.
- 정상이라면 가만히 있는 플레이어가 Bboo 3마리가 있는 방에서 약 20초 안에 죽는다.

## 3. 가능 원인

시작부터 겹쳐 있으면 스윕 쿼리의 답이 API마다 다르다. 스윕 쿼리는 도형을 출발점에서 방향으로 밀면서 처음 닿는 곳을 찾는다.

| API | 시작부터 겹친 콜라이더 |
|---|---|
| `Physics.Raycast`, `Physics.SphereCast` (단일 결과) | **무시한다.** 히트로 보고하지 않는다 |
| `Physics.SphereCastAll`, `Physics.SphereCastNonAlloc` | 히트로 보고한다. `distance = 0`, `normal = -(스윕 방향)`, `point = (0, 0, 0)` |

둘 다 Unity 문서의 Notes에 적혀 있다. 단일 버전은 "감지하지 않는다", All/NonAlloc 버전은 "normal을 스윕 반대 방향으로, distance를 0으로 둔다"고 되어 있다.
즉 NonAlloc 결과에서 `distance == 0`인 히트는 **표면에 닿은 게 아니라 원래 안에 있었다**는 뜻이고, 그 `normal`은 표면 방향과 아무 관계가 없다.

| 번호 | 가설 | 확인 방법 | 판정 |
|---|---|---|---|
| 1 | 투사체가 플레이어를 빗나간다 | 발사 수 대비 명중 수 로그 | 명중 0/10이라 단순 빗나감으로 보기 어렵다 |
| 2 | 투사체가 바닥을 "벽"으로 오판해 소멸한다 | 히트의 `distance`, `normal` 기록 | 채택 |

{% hint style="info" %}
NOTE: `Physics.SphereCastNonAlloc`의 존재와 동작은 Unity 버전에 따라 다를 수 있다. 사용 중인 Unity 버전의 문서 Notes로 버전 확인 필요.
{% endhint %}

## 4. 격리 절차

1. 에디터의 던전 미리보기에서 플레이어를 Bboo 3마리가 배치된 방으로 순간이동시킨다. → 결과: 매번 같은 조건이 된다.
2. 런타임에 이벤트 버스의 공격 이벤트(`EnemyAreaAttackEvent`)와 피격 이벤트(`PlayerDamagedEvent`)를 구독해 로그를 남긴다.
3. 로그를 세서 **발사 수 대비 명중 수**를 낸다. → 결과: 문제 조건에서 명중이 **0/10**이다.
4. 투사체 코드를 읽는다. 투사체는 매 프레임 이전 위치에서 현재 위치까지 `Physics.SphereCastNonAlloc`(반지름 0.28)으로 스윕했다.
5. 원인을 확인한다.
   - 포물선 끝에서 내려올 때는 이전 위치가 이미 바닥 안에 들어가 있다. 그러면 바닥 히트가 `distance 0`, `normal = -(스윕 방향)`으로 들어온다.
   - 코드는 `normal.y < 0.7`이고 장애물이면 "벽에 막혔다"고 처리했다. 완만하게 내려오는 투사체는 스윕 방향의 y가 작아서 반대 방향 normal의 y도 0.7보다 작다.
   - 그래서 **바닥을 벽으로 오판**해 투사체를 없앴다.

### 격리 실습 🎮: 겹친 채 출발하는 스윕 직접 보기 (10분)

{% hint style="info" %}
NOTE: AI, 자동완성, 검색 없이 한다. 막히면 위의 3절로 돌아간다.
{% endhint %}

`practice/UnityLab`의 빈 씬에 빈 GameObject를 만들고 아래 스크립트를 붙인다. **실행 전에 4줄의 출력을 예측해 적는다.** 특히 B의 두 줄이 어떻게 다를지 적는다. 되돌리기: 씬을 저장하지 않고 닫거나 Ctrl+Z로 되돌린다.

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

## 5. 시정 조치

벽 판정 조건에 `h.distance > 0f`를 추가한다(1줄).

```csharp
// 벽 판정 조건에 h.distance > 0f 추가
else if (h.distance > 0f && h.normal.y < .7f && CombatObstruction.IsBlocker(h.collider, caster.transform))
```

- 근거: 진짜 벽은 바깥에서 날아와 표면에 먼저 닿으므로 `distance > 0`이다. `distance 0`은 "출발할 때 이미 안에 있었다"는 뜻이다.
- 버린 대안 예: 단일 `SphereCast`로 바꾸기, 바닥 레이어를 쿼리에서 빼기(이유는 아래 확인 문제 Q2).

## 6. 결과

| 조건 | 수정 전 | 수정 후 |
|---|---|---|
| 문제 조건(Bboo 3마리 방) 명중 수 | 0/10 | 6/6 |
| 다른 조건 1 | - | 3/3 (회귀 없음) |
| 다른 조건 2 | - | 4/4 (회귀 없음) |

측정 조건: 에디터 던전 미리보기, 이벤트 로그 집계, 표본이 작다.

## 7. 노트 작성 과제 (30분)

1. `troubleshooting/template.md`를 `troubleshooting/02-projectile-floor.md`로 복사한다. → 결과: 새 파일이 생긴다.
2. `문제 상황`에 플레이어가 느낀 증상과 재현 조건을 쓴다.
3. `원인 분석`에 **어떻게 재현을 자동화했는지**(이벤트 구독 로그로 명중 수 세기)와 결정적 증거(distance 0, normal = 스윕 반대 방향)를 쓴다. 격리 실습의 출력을 근거로 붙여도 좋다.
4. `해결 과정`에 고른 수정(1줄)과 버린 대안을 쓴다. 각각 왜 버렸는지 한 줄씩 쓴다.
5. `결과` 표에 조건별 명중 수를 넣고, 측정 조건 칸에 표본 수를 쓴다.
6. `남은 한계`를 쓴다. 표본이 작다는 점과 자동 테스트가 없다는 점이 있다. 그 밖의 한계는 Q1을 보고 쓴다.
7. 시간이 남으면 아래 선택 재료로 `03-quit-crash.md`의 문제 상황과 원인 분석만 먼저 써 둔다.

**자기 점검**

- [ ] `distance 0`이 무슨 뜻인지 노트만 읽고도 이해된다
- [ ] 수정이 왜 한 줄로 충분한지 근거가 있다
- [ ] 수정이 못 막는 경우를 적었다
- [ ] 내가 하지 않은 일(예: 자동 테스트 추가)을 한 것처럼 쓰지 않았다

### 선택 재료: 종료할 때 크래시 (후보 03)

- 증상: 게임을 끌 때 `D3D12Core.dll`에서 접근 위반(0xC0000005)이 났다. 타이틀만 보고 끄면 드물었고(1/30), 플레이 후 끄면 잦았다(2/3).
- 분석: cdb가 없어서 Python 디버거를 붙이고 UnityPlayer PDB로 콜스택을 봤다. 엔진 종료 중 D3D12 PSO 라이브러리 캐시를 저장(`SaveCache` → `Serialize` → `memcpy`)하면서 크기를 이미 해제된 메모리(`0xFEEEFEEE`, Windows 디버그 힙이 해제한 메모리에 채우는 값)에서 읽고 있었다. 엔진의 use-after-free이고 우리 코드가 아니었다.
- 해결: 실행 인자 `-force-d3d12-single-pso-disk-cache`로 다른 캐시 경로를 쓰게 했다(`boot.config`에 넣으면 효과가 없어서 Steam 실행 옵션에 넣었다). 세이브는 크래시 지점보다 먼저 끝나서 데이터는 안전했다. 이후 D3D11로 전환하면서 이 경로 자체가 사라졌다.

## 8. 확인 문제 (꼬리 질문 대비, 10분)

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
지금은 수동 측정만 했고 표본도 작습니다. "바닥 안에서 출발한 스윕이 벽으로 판정되지 않는다"를 PlayMode 테스트로 남기는 게 다음 단계입니다. 격리 실습처럼 바닥 하나와 스윕 한 번이면 되니 테스트 비용도 작습니다.

</details>

**Q5. (선택 재료) 종료 크래시가 우리 코드 탓이 아니라고 어떻게 판단했나요?**
<details><summary>답의 방향</summary>
디버거와 PDB로 본 콜스택이 처음부터 끝까지 엔진 종료 경로(그래픽스 디바이스 소멸자 → PSO 캐시 저장 → memcpy)였고, 복사할 크기를 디버그 힙이 해제한 메모리 패턴인 0xFEEEFEEE에서 읽고 있었습니다. 같은 시그니처가 Steam 설치본과 여러 개발 빌드에서 반복됐고, 실행 인자로 그 저장 경로를 바꾸자 사라졌습니다.

</details>

## 참조

- [Physics.SphereCast (Notes: 겹친 콜라이더는 감지하지 않음)](https://docs.unity3d.com/ScriptReference/Physics.SphereCast.html)
- [Physics.SphereCastNonAlloc (Notes: 시작부터 겹치면 distance 0)](https://docs.unity3d.com/ScriptReference/Physics.SphereCastNonAlloc.html)
- [RaycastHit](https://docs.unity3d.com/ScriptReference/RaycastHit.html)
- [Physics.SyncTransforms](https://docs.unity3d.com/ScriptReference/Physics.SyncTransforms.html)
- [트러블슈팅 노트 템플릿](troubleshooting/template.md) · [트러블슈팅 노트 후보 목록](troubleshooting/README.md)

이전: [Day 22 · 트러블슈팅 노트 ①: 프레임 스파이크](day22-troubleshooting-performance.md) · 다음: [Day 24 · [실습] 종합 미니 게임](day24-lab-mini-game.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 오늘의 한 줄: 시작부터 겹친 스윕 히트의 `distance 0`이 뜻하는 바를 내 말로 한 문장으로 쓰면?
- [ ] 내가 겪은 버그 중 "한 줄 수정"으로 끝났지만 원인을 찾는 데 오래 걸린 것은 무엇이었나?
