# 집행자 차징 레이저: 지속 피해와 독립 조준점

## 무엇을 하는가

집행자(Executioner) 보스가 캐스팅 시간 동안 플레이어를 향해 천천히 돌아선 뒤, 발사 시간 동안 레이저 빔을 쏘는 스킬이다. 빔은 플레이어의 가슴 높이 조준점을 따라가되 회전 속도에 상한이 있어서, 플레이어가 충분히 빠르게 움직이면 피할 수 있다. 피해는 한 번에 들어가지 않고, 0.1초 간격으로 "초당 피해량 x 경과 시간"만큼 계속 들어간다.

구현은 `ExeChargingLaser`(`SkillData`를 상속한 ScriptableObject)이고, 코루틴 두 개로 이루어진다.

* `Casting`: 몸체를 타깃 쪽으로 부드럽게 돌린다(`Slerp`).
* `Activate`: 빔 생성, 조준 회전, 피해 판정, 정리.

{% hint style="info" %}
이 문서의 동작 설명은 코드를 읽고 쓴 것이다. Unity에서 실행해 확인하지는 않았다(unverified).
{% endhint %}

## 왜 이렇게 설계했나

이 스킬은 커밋 세 개를 거쳐 지금 모양이 되었다. 각 단계에서 무엇이 문제였는지가 코드 주석에 남아 있다.

| 단계 | 커밋 | 바뀐 점 | 이유 |
| --- | --- | --- | --- |
| 1 | `aa820f3d` | 빔 방향으로 `Raycast`, 틱마다 지속 피해 | 빔이 눈에 보이기만 하고 피해가 없었다. 장애물에 먼저 맞으면 막히게 하려고 대상과 장애물 레이어를 한 번에 쏜다. |
| 2 | `cdef3868` | `SphereCast`(빔 두께), 몸체 회전 각속도 제한, 필드를 지역 변수로 이동, `try/finally` | 이전 코드는 조준이 즉시 정확해서 피할 수 없었다(기존 주석의 To-do에도 그렇게 적혀 있었다). 또 `SkillData`는 공유 ScriptableObject라서 필드에 런타임 오브젝트를 두면 몬스터 여러 마리가 상태를 덮어쓴다. |
| 3 | `e9a55ec5` | 빔 회전을 몸체와 분리하고, 플레이어 자식 `TargetPos`를 조준점으로 사용 | 2단계는 몸체의 수평 방향만 따라가서 빔이 가슴이 아니라 발 높이로 날아가기 쉬웠다. 조준점을 3D로 따라가게 하되 각속도 제한은 유지했다. |

핵심 아이디어는 "정확히 겨냥하되 느리게 돈다"이다. 정확도와 회피 가능성을 서로 다른 변수(조준점 위치, `fireRotateSpeed`)로 분리해서 난이도를 숫자 하나로 조절한다.

## 핵심 코드

{% code title="ExeChargingLaser.cs (Activate 루프, 발췌)" %}
```csharp
Transform aimPoint = ResolveAimPoint(data.Target);
Quaternion beamRotation = laser.transform.rotation; // 시작 시 몸체 정면

float elapsed = 0f;
float damageTimer = 0f;
while (elapsed < attackDuration)
{
    if (data.Target == null) break;

    if (aimPoint == null || !aimPoint.IsChildOf(data.Target.transform))
        aimPoint = ResolveAimPoint(data.Target);

    // 몸체: 수평(yaw)만 제한 회전
    Vector3 bodyDir = aimPoint.position - data.Agent.transform.position;
    bodyDir.y = 0;
    if (bodyDir.sqrMagnitude > 0.001f)
        data.Agent.transform.rotation = Quaternion.RotateTowards(
            data.Agent.transform.rotation,
            Quaternion.LookRotation(bodyDir), fireRotateSpeed * Time.deltaTime);

    // 빔: 조준점을 3D로 추적, 각속도 제한, 월드 회전을 직접 대입
    Vector3 beamDir = aimPoint.position - shootPoint.position;
    if (beamDir.sqrMagnitude > 0.001f)
    {
        beamRotation = Quaternion.RotateTowards(beamRotation,
            Quaternion.LookRotation(beamDir), fireRotateSpeed * Time.deltaTime);
        laser.transform.rotation = beamRotation;
    }

    damageTimer += Time.deltaTime;
    if (damageTimer >= damageInterval)
    {
        ApplyBeamDamage(laser.transform, damageTimer);
        damageTimer = 0f;
    }
    elapsed += Time.deltaTime;
    yield return null;
}
```
{% endcode %}

* 1~2줄: 조준점은 플레이어 자식 `TargetPos`이고, 빔 회전값은 몸체 회전과 별도 변수(`beamRotation`)로 들고 있다. 빔 오브젝트는 몸체의 자식이라 몸체가 돌면 같이 돌아가는데, 별도 변수를 두면 매 프레임 마지막에 월드 회전을 덮어써서 그 영향을 지울 수 있다.
* 8~11줄: 타깃이 사라지면 루프를 끝낸다. 리스폰으로 타깃 오브젝트가 바뀌면 조준점을 다시 찾는다.
* 13~19줄: 몸체는 `y`를 0으로 만든 방향으로만 돌려 몸이 기울지 않게 한다. 연출용이고 판정과는 무관하다.
* 21~28줄: `Quaternion.RotateTowards`의 세 번째 인자가 최대 회전 각도라서, `도/초 x deltaTime`을 넣으면 각속도 상한이 된다. `Slerp`는 거리가 멀수록 빨리 돌아 상한이 없다.
* 30~35줄: 틱 누적 시간 `damageTimer`를 피해 계산에 그대로 넘긴다.

{% code title="ExeChargingLaser.cs (ApplyBeamDamage, 발췌)" %}
```csharp
int hitMask = targetMask | obstacleMask;
if (!Physics.SphereCast(beam.position, beamRadius, beam.forward,
        out RaycastHit hit, maxLength, hitMask))
    return;

// 먼저 맞은 것이 대상 레이어가 아니면(=장애물) 빔이 막힌 것
if ((targetMask.value & (1 << hit.collider.gameObject.layer)) == 0)
    return;

IDamagable target = hit.collider.GetComponent<IDamagable>()
                    ?? hit.collider.GetComponentInParent<IDamagable>();
if (target is not Component targetComponent)
    return;

// damage = 초당 대미지. tickTime을 곱해 이번 틱 몫만 적용
target.ApplyDamage(damage * tickTime,
    1 << targetComponent.gameObject.layer, tickTime, 0.0f);
```
{% endcode %}

* 1~4줄: 대상과 장애물 레이어를 한 번에 쏘면 `SphereCast`는 가장 가까운 것 하나를 돌려준다. 그것이 장애물이면 벽 뒤의 플레이어는 맞지 않는다.
* 6~8줄: 맞은 것의 레이어가 대상 마스크에 없으면 막힌 것으로 보고 종료한다.
* 10~13줄: 콜라이더가 자식에 붙어 있을 수 있어서 부모까지 `IDamagable`을 찾는다.
* 15~17줄: 마스크를 `targetMask`가 아니라 맞은 `IDamagable` 본체의 레이어로 만든다. 코드 주석에 따르면 `ApplyDamage` 안에서도 레이어를 다시 검사하는데, 콜라이더 레이어와 본체 레이어가 다르면 피해가 사라지는 문제가 있었다고 한다. `ApplyDamage` 내부 구현은 이 영역의 대상 파일이 아니라서 읽지 않았다.

## 따라 만들기

아래 단계는 빈 프로젝트에서 같은 구조를 재현하기 위한 축소판이다. 원본의 `Blackboard`, `Utils.Instantiate`, 애니메이션/오디오 호출은 뺀다.

1. 빈 3D 프로젝트에 레이어 `Player`와 `Obstacle`을 만든다. 확인 방법: `Edit > Project Settings > Tags and Layers`에 두 레이어가 보인다.
2. 인터페이스 `IDamagable { void ApplyDamage(float damage, LayerMask mask, float unitOfTime, float defenceIgnoreRate); }`를 만든다. 플레이어용 `Health` 컴포넌트가 이를 구현하고, 받은 피해를 `Debug.Log`로 출력하게 한다. 확인 방법: 플레이어 큐브에 붙이고 컴포넌트가 에러 없이 컴파일된다.
3. 플레이어 큐브 아래에 빈 자식 `TargetPos`를 만들고 가슴 높이(예: y=1)에 둔다. 확인 방법: 하이어라키에서 이름이 정확히 `TargetPos`다(코드가 이름으로 찾는다).
4. 보스 큐브를 만들고 `LaserBoss` MonoBehaviour를 붙인다. 원본은 ScriptableObject지만, 먼저 MonoBehaviour로 같은 코루틴을 돌려 보는 편이 디버깅이 쉽다. 필드는 `fireRotateSpeed`, `beamRadius`, `maxLength`, `damageInterval`, `targetMask`, `obstacleMask`, `damagePerSecond`다. 확인 방법: 인스펙터에 필드가 보인다.
5. 보스 자식으로 `ShootPoint`를 만들고, 그 아래에 길쭉한 큐브(빔 모양)를 `+Z` 방향으로 늘려 둔다. 확인 방법: 빔이 보스 정면으로 뻗어 있다.
6. 위 "Activate 루프" 발췌를 코루틴에 옮긴다. `laser`는 빔 큐브의 Transform으로 대신한다. 확인 방법: 플레이어를 천천히 걸어 다니게 하면 빔이 따라오고, 빠르게 달리면 빔이 뒤처진다.
7. `ApplyBeamDamage`를 추가한다. 확인 방법: 플레이어가 빔 안에 있을 때 콘솔에 0.1초 간격으로 피해 로그가 찍히고, 사이에 벽(`Obstacle` 레이어 큐브)을 세우면 로그가 멈춘다.
8. `fireRotateSpeed`를 30, 60, 120으로 바꿔 본다. 확인 방법: 값이 클수록 피하기 어려워진다. 난이도 조절이 이 값 하나로 되는지 체감한다.
9. (선택) 원본처럼 `SkillData`를 ScriptableObject로 옮길 때는 `GameObject` 같은 런타임 참조를 필드에 두지 않고 코루틴의 지역 변수로 둔다. 확인 방법: 보스 두 마리가 동시에 쏴도 서로의 빔이 사라지지 않는다.

## 막히기 쉬운 곳과 한계

* `TargetPos`가 없으면 코드는 타깃 루트(보통 발 위치)로 대체한다. 이때 빔이 바닥을 향해 가슴 높이 판정과 어긋난다.
* `SphereCast`는 시작 지점에 이미 겹쳐 있는 콜라이더를 잡지 못한다. 플레이어가 보스에 바짝 붙으면 맞지 않을 수 있다(Unity 물리 일반 동작이고, 이 게임에서 재현해 보지는 않았다).
* `fireRotateSpeed`를 몸체 회전과 빔 회전에 같이 쓴다. 몸체와 빔을 따로 조절하려면 필드를 나눠야 한다.
* 파일 맨 위 주석은 다른 스킬(돌진)의 설명이 복사된 채 남아 있다. 이 스킬의 동작과 맞지 않으므로 믿지 않는다.
* `try/finally`는 정상 종료나 예외에서는 정리를 보장하지만, 외부에서 `StopCoroutine`을 하면 `finally`가 실행되지 않는다. 이 스킬에는 `OnInterrupt` 재정의가 없다(이 영역의 코드 기준). 자세한 배경은 [영혼 감옥 스킬](amon-lockdown.md)에 적었다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `Quaternion.Slerp`와 `Quaternion.RotateTowards`는 회전 속도 면에서 어떻게 다르고, 이 스킬에서 왜 후자를 골랐는가?
- [ ] 보스 공격을 "피할 수 있게" 만들려고 해 본 경험이 있다면, 정확도와 회피 가능성 중 무엇을 조절했는가?
- [ ] 지속 피해를 "초당 피해량 x 경과 시간"으로 계산하면 틱 간격이 바뀌어도 총 피해가 같은 이유는 무엇인가?
