# Day 20 · UnityEngine.Object와 null 🎮

> 4주차 Unity 코어와 트러블슈팅 · 60분 · 준비물: .NET SDK (`dotnet new console -o practice/day20`), 🎮 Unity 6 (`practice/UnityLab`)

## 오늘의 목표
- `UnityEngine.Object`가 C# 관리 래퍼(`managed wrapper`)와 C++ 네이티브 객체 두 조각으로 이루어진 구조와 `가짜 null(fake null)`의 정체를 설명할 수 있다.
- 파괴된 Unity 오브젝트에 `?.`, `??`, `??=`, `is null`을 쓰면 왜 오버로드된 `==`를 우회해 `MissingReferenceException`이나 버그를 내는지 설명할 수 있다.
- 파괴된 C# 래퍼나 언로드되지 않은 에셋이 메모리에 남는 누수 경로를 찾고 막을 수 있다.

---

## 1. 읽기 (20분)

### 1-1. 반쪽짜리 객체: C# 래퍼와 C++ 네이티브 객체

`GameObject`, `Component`(`MonoBehaviour`, `Transform` 등), `ScriptableObject`, `Texture2D`, `Mesh`는 모두 `UnityEngine.Object`를 상속한다. 이들은 일반 C# 객체와 달리 **두 개의 메모리 공간에 걸쳐** 산다.

```
[C# 관리 힙 (GC 관리)]               [C++ 네이티브 메모리 (엔진 수동 관리)]
┌─────────────────────────┐          ┌──────────────────────────────────┐
│ GameObject (C# Wrapper) │ ───────▶ │ Native GameObject (위치, 이름 등) │
│  - m_CachedPtr (포인터) │          └──────────────────────────────────┘
│  - m_InstanceID         │
└─────────────────────────┘
```

- **진짜 무거운 데이터**(메시 정점, 텍스처 픽셀, 트랜스폼 계층)는 C++ 네이티브 쪽에 있다.
- **C# 객체는 얇은 껍데기(래퍼, `wrapper`)**다. 내부에 네이티브 객체를 가리키는 포인터(`m_CachedPtr`)만 들고 있다.

### 1-2. Destroy와 "가짜 null (Fake Null)"

`Destroy(gameObject)`를 호출하면 **그 프레임 끝에 C++ 네이티브 객체가 해제**되고 C# 래퍼의 내부 포인터는 `0`(`IntPtr.Zero`)이 된다. 하지만 C# 관리 힙에 있는 래퍼 객체 자체는 누군가 참조 변수를 들고 있는 한 GC가 마음대로 지울 수 없다.

즉 **C# 참조 자체는 살아 있는데(진짜 `null`이 아님), 가리키는 C++ 실체는 죽은 상태**가 된다. 이를 흔히 **`가짜 null(fake null)`**이라고 부른다.

Unity는 개발자가 파괴 여부를 쉽게 확인하도록 `UnityEngine.Object`의 **`==`와 `!=` 연산자, 그리고 암시적 `bool` 변환(`if (obj)`)을 오버로드**해 두었다.

| 비교식 | 검사하는 것 | 파괴된(`Destroy`) 직후 다음 프레임 결과 |
|---|---|---|
| `obj == null` / `if (!obj)` | **오버로드된 `==` 호출**: C# 참조가 `null`이거나 **네이티브 포인터가 파괴됐으면** `true` | **`true`** (파괴된 것으로 판정) |
| `obj is null` | 순수 C# 참조 주소가 `0`인지 비교 (연산자 오버로드 무시) | **`false`** (C# 껍데기는 아직 살아 있음!) |
| `ReferenceEquals(obj, null)` | 순수 C# 참조 동일성 비교 | **`false`** |

### 1-3. 왜 Unity 오브젝트에 `?.`, `??`, `??=`를 쓰면 위험한가

C#의 null 조건부 연산자(`?.`)와 null 병합 연산자(`??`, `??=`)는 타입이 오버로드한 `==`를 부르지 않고 **순수 C# 참조가 진짜 `null`인지만** 본다.

```csharp
// target이 Destroy된 상태라고 가정 (C# 래퍼는 살아 있고 C++ 객체만 파괴됨)
string name = target?.name; 
// 1) target?. 은 순수 참조만 보므로 "null이 아니다!"라고 통과시킴
// 2) 그 직후 .name 프로퍼티가 파괴된 C++ 포인터에 접근해 MissingReferenceException 발생!

Transform fallback = target ?? defaultTarget;
// target이 파괴됐는데도 ?? 는 target이 살아 있다고 판단해 파괴된 target을 그대로 반환!
```

Rider나 Visual Studio가 Unity 컴포넌트에 `?.`나 `??`를 쓰면 *"Lifetime check of Unity object is bypassed"* 경고를 띄우는 이유가 바로 이것이다. Unity 오브젝트가 살아 있는지 확인할 때는 명시적으로 `if (target != null)` 또는 `if (target)`을 쓴다.

### 1-4. 에디터 전용 가짜 객체와 핫 패스에서의 `== null` 비용

- **에디터 전용 주의점**: 에디터에서는 인스펙터에 할당하지 않은 `[SerializeField]` 필드나 실패한 `GetComponent`가 진짜 `null` 대신 **"어느 필드가 비었는지 친절한 에러(`UnassignedReferenceException` 등)를 띄우기 위한 가짜 C# 래퍼 객체"**를 들어 있을 때가 있다. 이는 에디터 전용 동작이며 빌드에서는 진짜 `null`이다.
- **`== null`의 비용**: 일반 C# 객체의 `null` 체크는 레지스터 비교 1클럭이지만, `UnityEngine.Object`의 `== null`(및 `if (obj)`)은 오버로드된 메서드를 타며 상황에 따라 네이티브 브리지 확인이 들어간다. 매 프레임 수천 번 도는 루프 안에서는 `== null`을 반복 호출하지 말고 `bool hasTarget = target != null;`이나 `ReferenceEquals`(파괴될 일이 없는 참조일 때)로 캐싱한다.

### 1-5. 래퍼 누수와 에셋 메모리 누수

1. **파괴된 C# 래퍼 누수**: `Destroy(enemy.gameObject)`를 호출했어도 정적 리스트(`static List<Enemy>`)나 해제하지 않은 이벤트(`EventBus`, Day 05, 18)가 `enemy` 컴포넌트를 계속 잡고 있으면, C++ 객체는 사라졌지만 **C# 래퍼와 그 컴포넌트가 필드로 잡고 있는 모든 일반 C# 배열·문자열은 영원히 GC되지 않는다.**
2. **에셋(`Texture`, `Mesh`, `AudioClip`) 누수**: 씬의 `GameObject`는 씬이 닫히면 파괴되지만, 로드된 에셋은 참조가 끊겨도 즉시 내려가지 않을 수 있다. `Addressables.Release`를 짝지어 호출하거나 `Resources.UnloadUnusedAssets()`로 정리해야 네이티브 메모리가 반환된다.

---

## 2. 손으로 확인 (30분)

> AI, 자동완성, 검색 없이. 막히면 위의 읽기로 돌아간다.

### 실습 1 (콘솔): FakeUnityObject를 직접 만들어 가짜 null 재현하기 (15분)

`practice/day20/Program.cs`에 `UnityEngine.Object`처럼 내부 포인터(`nativePtr`)와 오버로드된 `==`/`!=`를 가진 클래스를 직접 작성한다. 실행하기 전에 1)~5)의 출력을 예측해 적는다.

```csharp
// 실행 가능: Program.cs
var obj = new FakeUnityObject("Player");
Console.WriteLine($"[생존 상태] == null: {obj == null}, is null: {obj is null}, name: {obj.Name}");

obj.Destroy(); // C++ 네이티브 객체 파괴 시뮬레이션

Console.WriteLine($"1) obj == null              : {obj == null}");
Console.WriteLine($"2) obj is null              : {obj is null}");
Console.WriteLine($"3) ReferenceEquals(null)    : {ReferenceEquals(obj, null)}");

var fallback = obj ?? new FakeUnityObject("Fallback");
Console.WriteLine($"4) (obj ?? fallback) == null: {fallback == null}");

try
{
    string? n = obj?.Name;
    Console.WriteLine($"5) obj?.Name                : {n}");
}
catch (InvalidOperationException ex)
{
    Console.WriteLine($"5) obj?.Name 예외 발생      : {ex.Message}");
}

class FakeUnityObject
{
    private IntPtr nativePtr = new IntPtr(0x1234);
    private readonly string name;

    public FakeUnityObject(string name) => this.name = name;

    public bool IsDestroyed => nativePtr == IntPtr.Zero;

    public string Name => IsDestroyed
        ? throw new InvalidOperationException("MissingReferenceException: 객체가 이미 파괴되었습니다.")
        : name;

    public void Destroy() => nativePtr = IntPtr.Zero;

    public static bool operator ==(FakeUnityObject? a, FakeUnityObject? b)
    {
        bool aNull = ReferenceEquals(a, null) || a.IsDestroyed;
        bool bNull = ReferenceEquals(b, null) || b.IsDestroyed;
        if (aNull && bNull) return true;
        if (aNull || bNull) return false;
        return ReferenceEquals(a, b);
    }

    public static bool operator !=(FakeUnityObject? a, FakeUnityObject? b) => !(a == b);

    public override bool Equals(object? obj) => this == (obj as FakeUnityObject);
    public override int GetHashCode() => base.GetHashCode();
}
```

<details><summary>예상 출력과 해설</summary>

```
[생존 상태] == null: False, is null: False, name: Player
1) obj == null              : True
2) obj is null              : False
3) ReferenceEquals(null)    : False
4) (obj ?? fallback) == null: True
5) obj?.Name 예외 발생      : MissingReferenceException: 객체가 이미 파괴되었습니다.
```

- 4번: `obj ?? new FakeUnityObject("Fallback")`에서 `??`는 `obj`의 C# 참조가 살아 있으므로 `Fallback`을 쓰지 않고 이미 파괴된 `obj`를 그대로 돌려준다. 그래서 `fallback == null`이 `True`가 된다.
- 5번: `obj?.Name`도 `obj`가 진짜 `null`이 아니므로 통과시켜 `.Name`을 호출하고, 그 안에서 파괴된 네이티브 포인터 접근 예외가 터진다.

</details>

### 실습 2 (Unity): Destroy 같은 프레임 vs 다음 프레임 비교 (15분)

`practice/UnityLab`에서 `Destroy(target)`를 호출한 **직후(같은 프레임)**와 **`yield return null` 직후(다음 프레임)**에 각 연산자가 무엇을 반환하는지 예측하고 실행해 표를 채운다.

```csharp
// Unity: UnityNullCheckLab.cs
using System.Collections;
using UnityEngine;

public class UnityNullCheckLab : MonoBehaviour
{
    private IEnumerator Start()
    {
        GameObject go = new GameObject("TempTarget");
        Destroy(go);

        Debug.Log("=== 1) Destroy 직후 (같은 프레임) ===");
        PrintChecks(go);

        yield return null;

        Debug.Log("=== 2) 다음 프레임 (프레임 끝 파괴 완료 후) ===");
        PrintChecks(go);
    }

    private void PrintChecks(GameObject go)
    {
        Debug.Log($"go == null              : {go == null}");
        Debug.Log($"go is null              : {go is null}");
        Debug.Log($"ReferenceEquals(go,null): {ReferenceEquals(go, null)}");
        try
        {
            Debug.Log($"go?.name                : {go?.name}");
        }
        catch (MissingReferenceException ex)
        {
            Debug.Log($"go?.name 예외           : {ex.GetType().Name}");
        }
    }
}
```

| 검사 식 | 예측: Destroy 같은 프레임 | 예측: 다음 프레임 | 실측: Destroy 같은 프레임 | 실측: 다음 프레임 |
|---|---|---|---|---|
| `go == null` | | | | |
| `go is null` | | | | |
| `ReferenceEquals(go, null)` | | | | |
| `go?.name` | | | | |

<details><summary>예상 결과</summary>

| 검사 식 | Destroy 같은 프레임 | 다음 프레임 |
|---|---|---|
| `go == null` | `False` (아직 파괴 전) | `True` |
| `go is null` | `False` | `False` |
| `ReferenceEquals(go, null)` | `False` | `False` |
| `go?.name` | `TempTarget` | `MissingReferenceException` |

같은 프레임에서는 `Destroy`가 예약만 된 상태라 모든 검사가 "살아 있음"이다. 다음 프레임에는 `==`만 파괴를 알아채고, 순수 참조 검사와 `?.`는 여전히 껍데기를 본다.

</details>

---

## 3. 면접 대비 (10분)

소리 내어 30초 안에 답해 보고 펼쳐서 비교한다.

**Q1. Unity에서 말하는 "가짜 null (Fake Null)"이란 무엇인가요?**
<details><summary>모범 답안</summary>
`UnityEngine.Object` 파생 객체는 C# 관리 힙의 래퍼 객체와 C++ 네이티브 객체 두 부분으로 이루어져 있습니다. `Destroy`를 호출해 프레임이 끝나면 C++ 네이티브 객체는 메모리에서 파괴되지만, C# 변수에 참조가 남아 있는 한 C# 래퍼 객체는 GC되기 전까지 살아 있습니다. 이때 C# 참조 자체는 진짜 `null`이 아니지만, `UnityEngine.Object`가 오버로드한 `== null` 연산자는 내부 네이티브 포인터가 파괴된 것을 확인하고 `true`를 반환하는데, 이 상태를 가짜 null이라고 부릅니다.

</details>

**Q2. Unity 컴포넌트나 GameObject에 C#의 `?.`나 `??` 연산자를 쓰면 왜 위험한가요?**
<details><summary>모범 답안</summary>
`?.`와 `??` 연산자는 `UnityEngine.Object`가 오버로드한 `==` 연산자를 호출하지 않고 순수 C# 참조가 진짜 `null`인지만 검사하기 때문입니다. 따라서 이미 `Destroy`되어 네이티브 객체가 사라진 오브젝트라도 C# 래퍼가 남아 있으면 `?.` 검사를 통과해 버리고, 이어서 프로퍼티나 메서드를 호출하는 순간 `MissingReferenceException`이 발생합니다.

</details>

**Q3. `Destroy(gameObject)`를 호출했는데도 메모리 누수가 발생할 수 있나요?**
<details><summary>모범 답안</summary>
네, 발생할 수 있습니다. `Destroy`는 C++ 네이티브 객체만 해제할 뿐이므로, 정적 컬렉션이나 해제하지 않은 이벤트 구독(`Action`, `event`)이 해당 `MonoBehaviour`의 C# 래퍼를 계속 참조하고 있으면 C# 래퍼와 그 안의 일반 C# 필드(큰 배열, 리스트, 문자열 등)는 GC되지 않고 힙에 계속 남습니다. 따라서 `OnDestroy`나 `OnDisable`에서 정적 참조와 이벤트 구독을 반드시 끊어야 합니다.

</details>

**Q4. `Update` 안의 큰 루프에서 `if (target != null)`을 수천 번 호출할 때 주의할 점은 무엇인가요?**
<details><summary>모범 답안</summary>
일반 C# 참조 비교와 달리 `UnityEngine.Object`의 `!= null`은 오버로드된 연산자 함수를 실행해 네이티브 포인터의 유효성을 확인하므로 반복 호출 시 무시할 수 없는 CPU 비용이 쌓입니다. 따라서 루프 도중 파괴될 일이 없다면 루프 진입 전에 `bool isValid = target != null;`로 결과를 지역 변수에 한 번만 캐싱하거나, 순수 참조 비교만 필요할 때는 `ReferenceEquals`를 사용하는 것이 좋습니다.

</details>

---

## 오늘의 한 줄
> (내 말로 한 문장)

## 더 보기
- [UnityEngine.Object API 문서 및 null 비교 설명](https://docs.unity3d.com/ScriptReference/Object.html)
- [Object.Destroy API 문서](https://docs.unity3d.com/ScriptReference/Object.Destroy.html)
- [연산자 오버로딩 (C# 참조)](https://learn.microsoft.com/ko-kr/dotnet/csharp/language-reference/operators/operator-overloading)
