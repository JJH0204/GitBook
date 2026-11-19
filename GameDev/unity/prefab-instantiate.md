# [생성형 AI] 프리팹과 Instantiate, Destroy

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UNI-008-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | 프리팹의 개념과 런타임 생성·삭제 API의 동작, 비용, 주의점을 이해한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (Unity에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 1. 정의

프리팹(Prefab)은 `GameObject`와 컴포넌트, 값 설정을 에셋으로 저장한 템플릿이다. 프리팹 에셋 하나로 씬에 인스턴스를 여러 개 배치하거나 코드로 생성한다. 프리팹을 고치면 인스턴스에 반영된다. 인스턴스에서 바꾼 값은 오버라이드(Override)로 남는다.

## 2. 구성 요소

| 개념 | 설명 |
|---|---|
| 프리팹 에셋 | `Project` 창의 `.prefab` 파일 |
| 프리팹 인스턴스 | 씬에 놓였거나 코드로 만든 복제본. `Hierarchy`에서 파란 아이콘으로 보인다 |
| 오버라이드 | 인스턴스에서만 바꾼 값. Inspector에서 `Apply`(프리팹에 반영)와 `Revert`(되돌리기)를 고른다 |
| 중첩 프리팹(Nested) | 프리팹 안에 다른 프리팹을 넣는다 |
| 프리팹 변형(Variant) | 기존 프리팹을 기반으로 일부 값만 다르게 만든 프리팹 |
| 프리팹 모드 | 프리팹을 더블클릭해 단독으로 편집하는 화면 |

| API | 의미 |
|---|---|
| `Instantiate(prefab)` | 프리팹을 복제한다 |
| `Instantiate(prefab, position, rotation)` | 위치와 회전을 지정해 복제한다 |
| `Instantiate(prefab, parent)` | 부모 아래에 복제한다 |
| `Destroy(obj)` | 프레임 끝에 오브젝트를 삭제한다 |
| `Destroy(obj, seconds)` | 지정한 시간 뒤에 삭제한다 |
| `GameObject.SetActive(bool)` | 삭제하지 않고 켜고 끈다 |
| `DontDestroyOnLoad(obj)` | 씬을 불러와도 유지한다 |

## 3. 동작 원리

### 3.1 생성 예제

필드의 타입을 `GameObject` 대신 컴포넌트 타입으로 두면 `Instantiate`가 그 컴포넌트를 바로 돌려줘 `GetComponent`를 줄인다.

```csharp
using UnityEngine;

public class Bullet : MonoBehaviour
{
    public float speed = 20f;
    void Update() => transform.Translate(Vector3.forward * (speed * Time.deltaTime));
}

public class Gun : MonoBehaviour
{
    [SerializeField] Bullet bulletPrefab;   // Inspector에 프리팹 에셋을 끌어 놓는다
    [SerializeField] Transform muzzle;

    public void Fire()
    {
        Bullet b = Instantiate(bulletPrefab, muzzle.position, muzzle.rotation);
        Destroy(b.gameObject, 3f);          // 3초 뒤 삭제
    }
}
```

{% hint style="warning" %}
CAUTION: `Destroy(b)`처럼 컴포넌트를 넘기면 오브젝트가 아니라 그 컴포넌트만 삭제된다. 오브젝트를 지우려면 `Destroy(b.gameObject)`를 쓴다.
{% endhint %}

### 3.2 호출 시점

| 항목 | 동작 |
|---|---|
| `Awake`, `OnEnable` | 활성 상태의 프리팹이면 `Instantiate`가 돌아오기 전에 호출된다 |
| `Start` | 첫 `Update` 직전에 호출된다 |
| `Destroy` | 즉시 삭제가 아니다. 현재 프레임이 끝날 때 삭제된다 |
| 삭제된 뒤 | 참조를 `== null`로 비교하면 `true`다. 자세한 이유는 [UnityEngine.Object와 null](../unity-csharp/day20-unity-object-null.md)을 본다 |

### 3.3 비용과 풀링

`Instantiate`와 `Destroy`는 메모리 할당과 초기화 비용이 있고, 자주 호출하면 GC와 프레임 스파이크의 원인이 된다. 총알, 이펙트처럼 자주 생기고 사라지는 오브젝트는 만들어 두고 켜고 끄는 풀링을 쓴다. 구현은 [Day 12 · 오브젝트 풀](../unity-csharp/day12-lab-object-pool.md)을 본다. 풀링 오브젝트는 재사용 시 상태(체력, 속도, 타이머)를 직접 초기화해야 한다. 프리팹 에셋을 `Resources`나 `Addressables`로 불러오는 방식은 이 문서에서 다루지 않는다.

### 3.4 에디터 조작

| 동작 | 방법 | 되돌리기 |
|---|---|---|
| 프리팹 만들기 | `Hierarchy`의 오브젝트를 `Project` 창으로 끌어다 놓는다 | `Ctrl+Z`. 만든 `.prefab`을 삭제하면 인스턴스는 프리팹과 연결이 끊긴다 |
| 인스턴스 값을 프리팹에 반영 | Inspector의 `Overrides > Apply All` | 반영 전에 씬과 프리팹을 백업한다. 반영 후에는 `Ctrl+Z` 또는 버전 관리로 되돌린다 |
| 연결 끊기 | `Hierarchy`에서 우클릭, `Prefab > Unpack` | `Ctrl+Z` |

{% hint style="info" %}
NOTE: 에셋 스토어에서 받은 프리팹은 라이선스와 재배포 조건을 확인한다. 프로젝트 저장소에 올릴 수 있는지는 에셋마다 다르다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 인스턴스 | 프리팹에서 만든 복제본 |
| 오버라이드 | 인스턴스에서만 바꾼 값 |
| 언팩(Unpack) | 프리팹과의 연결을 끊고 일반 오브젝트로 만든다 |
| 풀링 | 오브젝트를 파괴하지 않고 재사용하는 방식 |

## 5. 더 보기

* [전투 시스템 투사체 발사 설계](battlesystemdesign.md)
* [MonoBehaviour 생명주기](../unity-csharp/day19-monobehaviour-lifecycle.md)
* [Unity ScriptReference: Object.Instantiate](https://docs.unity3d.com/ScriptReference/Object.Instantiate.html)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 프리팹을 쓰지 않고 씬에 오브젝트를 복사해서 쓰면 어떤 불편이 생기는지 자신의 경험으로 쓴다.
- [ ] 자신의 게임에서 풀링이 필요한 오브젝트와 필요하지 않은 오브젝트를 하나씩 쓴다.
