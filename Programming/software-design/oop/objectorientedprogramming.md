# 객체지향 핵심 개념 (OOP)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-OOP-001-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 객체지향의 기본 용어와 네 가지 핵심 개념(캡슐화, 상속, 다형성, 추상화)을 설명한다 |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

객체지향 프로그래밍(OOP, Object-Oriented Programming)은 상태(데이터)와 그 상태를 다루는 동작(메서드)을 객체 하나로 묶어 프로그램을 구성하는 방식이다. 객체는 필요한 기능별로 만들어 여러 곳에서 재사용할 수 있고, 상속과 합성으로 기존 객체를 바탕으로 새 객체를 만들 수 있다.

{% hint style="info" %}
NOTE: OOP가 절차 지향보다 항상 유지보수가 쉬운 것은 아니다. 문제의 규모와 성격에 따라 득실이 다르다. 비교는 [OOP 대 POP 비교 (OOP vs POP)](oopvspopcomparison.md)를 본다.
{% endhint %}

## 2. 구성 요소

| 용어 | 뜻 | 예 |
|---|---|---|
| 클래스(class) | 객체의 설계도. 상태와 동작을 정의한다 | `Lamp` |
| 객체(object, 인스턴스) | 클래스로 만든 실체 | `new Lamp()` |
| 필드·속성(field, property) | 객체가 가진 상태 값. 예: 전원의 켜짐 여부 | `isOn` |
| 메서드(method) | 객체가 수행하는 동작. 상태를 바꾸거나 값을 계산한다. C 계열에서는 함수(function)라고도 부른다 | `TurnOn()` |
| 열거형(enum), 구조체(struct) | 값을 묶는 타입. 언어에 따라 값 타입이며 클래스와 다른 규칙을 가진다 | |

{% hint style="info" %}
NOTE: "Property"는 C#에서 `get`/`set`을 가진 별도 문법을 가리키기도 한다. 이 문서에서는 상태 값 일반을 뜻하며, 언어별 의미는 해당 언어 문서를 따른다.
{% endhint %}

## 3. 동작 원리

### 3.1 네 가지 핵심 개념

| 개념 | 정의 | 효과 |
|---|---|---|
| 캡슐화(encapsulation) | 상태와 동작을 한 단위로 묶고 내부를 외부에서 직접 접근하지 못하게 숨긴다 | 내부 구현을 바꿔도 사용하는 쪽이 영향받지 않는다 |
| 상속(inheritance) | 하위 클래스가 상위 클래스의 멤버를 물려받는다 | 공통 코드를 재사용하고 계층을 만든다 |
| 다형성(polymorphism) | 같은 메시지(메서드 호출)에 객체의 실제 타입에 따라 다른 동작을 한다 | 호출하는 쪽이 구체 타입을 몰라도 된다 |
| 추상화(abstraction) | 불필요한 세부를 숨기고 핵심 인터페이스만 드러낸다 | 복잡도를 낮춘다 |

### 3.2 접근 제한자

캡슐화는 접근 제한자로 구현한다. 아래는 C#과 Java의 차이를 포함한 일반적인 의미다.

| 제한자 | 접근 범위 |
|---|---|
| `public` | 어디서나 접근한다 |
| `protected` | 같은 클래스와 하위 클래스에서 접근한다. Java는 같은 패키지에서도 접근한다 |
| `private` | 같은 클래스 안에서만 접근한다 |
| `internal`(C#) | 같은 어셈블리 안에서 접근한다 |
| 기본(package-private, Java) | 같은 패키지 안에서 접근한다 |

기본 접근 수준은 언어마다 다르다. C#의 클래스 멤버는 기본이 `private`이다.

### 3.3 상속 대 합성

| 항목 | 상속(is-a) | 합성(has-a) |
|---|---|---|
| 관계 | 하위 타입이 상위 타입이다 | 객체가 다른 객체를 부품으로 가진다 |
| 결합도 | 높다. 하위 클래스가 상위 클래스의 내부 변경에 영향받는다 | 낮다. 부품은 인터페이스로 교체할 수 있다 |
| 유연성 | 컴파일 시점에 관계가 고정된다 | 실행 시점에 부품을 바꿀 수 있다 |
| 적합한 경우 | 진짜 하위 타입 관계이고 [LSP](../solid/lspliskovsubstitutionprinciple.md)를 지킬 수 있다 | 기능을 재사용하거나 조립한다 |

상속은 코드 재사용만을 위해 쓰지 않는다. 재사용이 목적이면 합성을 먼저 검토한다.

## 4. 예제 코드

```csharp
using System;

class Lamp
{
    private bool _isOn;                       // 캡슐화: 외부에서 직접 접근 불가

    public bool IsOn => _isOn;                // 읽기만 허용

    public void TurnOn()  { _isOn = true; }
    public void TurnOff() { _isOn = false; }
}

abstract class Shape                          // 추상화
{
    public abstract double Area();
}

class Circle : Shape                          // 상속
{
    private readonly double _r;
    public Circle(double r) { _r = r; }
    public override double Area() => Math.PI * _r * _r;
}

class Rect : Shape
{
    private readonly double _w, _h;
    public Rect(double w, double h) { _w = w; _h = h; }
    public override double Area() => _w * _h;
}

class Program
{
    static void Main()
    {
        Shape[] shapes = { new Circle(1), new Rect(2, 3) };
        foreach (Shape s in shapes)
            Console.WriteLine(s.Area());      // 다형성: 실제 타입의 Area 실행
    }
}
```

## 5. 코드 설명

| 대상 | 개념 | 설명 |
|---|---|---|
| `_isOn` | 캡슐화 | `private`이므로 `TurnOn`, `TurnOff`로만 바꾼다 |
| `Shape` | 추상화 | 도형이 "넓이를 구한다"는 약속만 정의한다 |
| `Circle`, `Rect` | 상속 | `Shape`를 상속해 `Area`를 구현한다 |
| `s.Area()` | 다형성 | 변수 타입은 `Shape`이지만 객체의 실제 타입 구현이 실행된다 |

## 6. 한계·주의

- 상속 계층이 깊어지면 하위 클래스가 상위 클래스의 구현에 묶여 변경이 어려워진다.
- 필드를 `public`으로 열면 캡슐화의 이점이 사라진다.
- 모든 문제를 객체로 모델링할 필요는 없다. 상태 없는 계산은 함수로 두는 편이 단순하다.

관련 문서: [SOLID 원칙 (SOLID)](../solid/README.md), [응집도 (Cohesion)](cohesion.md), [결합도 (Coupling)](coupling.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 캡슐화가 없었다면 내 코드에서 어떤 문제가 생겼겠는가?
- [ ] 상속 대신 합성을 선택한 경험이 있는가? 이유는 무엇이었는가?
- [ ] 다형성이 코드를 단순하게 만든 사례를 하나 적어 보라.
