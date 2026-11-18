# 가상 메서드 (virtual)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-CSH-001-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | `virtual` 메서드, `override`, `base`, `new` 숨기기의 동작과 차이를 설명한다 |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

가상 메서드(virtual method)는 기본 구현을 가지면서 자식 클래스가 `override`로 재정의할 수 있는 메서드다. 부모 클래스의 기본 동작을 유지하거나, 자식 클래스에서 필요에 따라 바꿀 수 있다.

{% hint style="info" %}
NOTE: C#의 메서드는 기본이 비가상(non-virtual)이다. `virtual`을 붙인 메서드만 재정의할 수 있다.
{% endhint %}

## 2. 구성 요소

| 키워드 | 위치 | 역할 |
|---|---|---|
| `virtual` | 부모 메서드 | 자식이 재정의할 수 있게 허용한다 |
| `override` | 자식 메서드 | 부모의 `virtual`(또는 `abstract`, `override`) 메서드를 재정의한다. 시그니처가 같아야 한다 |
| `base.메서드()` | 자식 메서드 안 | 부모의 구현을 호출한다 |
| `new` | 자식 메서드 | 재정의가 아니라 부모 멤버를 숨긴다(hiding) |
| `sealed override` | 자식 메서드 | 이 클래스의 하위 클래스가 더 재정의하지 못하게 막는다 |

## 3. 동작 원리

1. 객체를 만들면 객체는 자신의 실제 타입 정보를 가진다.
2. 가상 메서드를 호출하면 변수의 선언 타입이 아니라 객체의 실제 타입을 기준으로 실행할 구현을 고른다. 런타임은 가상 메서드 테이블(vtable)과 비슷한 구조로 이를 찾는다.
3. 비가상 메서드와 `new`로 숨긴 메서드는 변수의 선언 타입을 기준으로 컴파일 시점에 정해진다.

## 4. 예제 코드

```csharp
using System;

class Animal
{
    public virtual void Speak()
    {
        Console.WriteLine("...");
    }
}

class Dog : Animal
{
    public override void Speak()
    {
        base.Speak();                 // 부모 구현 호출
        Console.WriteLine("멍멍");
    }
}

class Cat : Animal
{
    public new void Speak()           // 재정의가 아니라 숨기기
    {
        Console.WriteLine("야옹");
    }
}

class Program
{
    static void Main()
    {
        Animal a = new Dog();
        a.Speak();                    // ... 멍멍 (Dog.Speak 실행)

        Animal b = new Cat();
        b.Speak();                    // ... (Animal.Speak 실행)

        Cat c = new Cat();
        c.Speak();                    // 야옹
    }
}
```

| 호출 | 변수 타입 → 객체 타입 | 실행되는 구현 | 이유 |
|---|---|---|---|
| `a.Speak()` | `Animal` → `Dog` | `Dog.Speak` | `override`는 객체의 실제 타입을 따른다 |
| `b.Speak()` | `Animal` → `Cat` | `Animal.Speak` | `new`는 숨기기이므로 변수 타입을 따른다 |
| `c.Speak()` | `Cat` → `Cat` | `Cat.Speak` | 변수 타입이 `Cat`이다 |

## 5. 한계와 주의

{% hint style="warning" %}
CAUTION: 자식에서 같은 이름의 메서드를 `override`나 `new` 없이 쓰면 컴파일러가 경고(CS0114)를 낸다. 의도에 맞게 둘 중 하나를 명시한다.
{% endhint %}

* `private` 메서드와 `static` 메서드에는 `virtual`을 쓸 수 없다.
* 가상 호출은 비가상 호출보다 약간의 간접 비용이 있다. 재정의할 필요가 없는 메서드는 `virtual`을 붙이지 않는다.
* 생성자에서 가상 메서드를 호출하면 자식의 필드가 초기화되기 전에 자식의 `override`가 실행될 수 있다. 피한다.

{% hint style="info" %}
NOTE: Unity에서 `MonoBehaviour`의 `Awake`, `Start` 같은 이벤트 함수는 부모에 `virtual`로 선언되어 있지 않다. 상속 구조에서 이 함수를 확장하려면 부모에 `protected virtual void Awake()`를 직접 선언하고 자식에서 `protected override void Awake()`로 재정의한 뒤 `base.Awake()`를 호출한다. 사용할 수 있는 C# 문법 버전은 Unity 버전에 따라 다르므로 프로젝트의 C# 언어 버전을 확인한다.
{% endhint %}

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `override`와 `new`로 같은 이름의 메서드를 쓸 때 호출 결과가 다른 이유를 내 말로 설명하면?
- [ ] 내가 만드는 코드에서 자식이 동작을 바꿔야 하는 부모 메서드는 무엇인가?
