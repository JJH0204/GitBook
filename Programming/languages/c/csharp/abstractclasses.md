# 추상 클래스 (Abstract Class)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-CSH-002-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | `abstract` 클래스와 추상 메서드의 규칙, 인터페이스와의 차이를 설명한다 |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

`abstract`는 C#에서 추상 클래스 또는 추상 메서드를 정의할 때 쓰는 키워드다.

* 추상 클래스는 인스턴스화(`new`)할 수 없다. 상속받는 용도로만 쓴다.
* 추상 메서드는 본문이 없고, 일반(비추상) 파생 클래스가 반드시 `override`로 구현해야 한다.
* 자식 클래스가 특정 메서드를 반드시 구현하도록 강제해 코드 구조를 명확히 한다.

## 2. 구성 요소

| 요소 | 규칙 |
|---|---|
| `abstract class` | `new`로 만들 수 없다. 필드, 생성자, 구현이 있는 메서드를 가질 수 있다 |
| `abstract` 메서드 | 추상 클래스 안에서만 선언한다. 본문 없이 `;`로 끝난다. 암묵적으로 `virtual`이다 |
| `override` | 파생 클래스가 추상 메서드를 구현한다. 추상 클래스를 다시 `abstract`로 두면 구현을 미룰 수 있다 |
| `virtual` 메서드 | 추상 클래스 안에서 기본 구현을 제공하고 자식이 선택적으로 재정의한다 |

## 3. 예제 코드

```csharp
using System;

abstract class Shape
{
    public string Name { get; }

    protected Shape(string name)           // 추상 클래스도 생성자를 가진다
    {
        Name = name;
    }

    public abstract double Area();         // 본문 없음: 자식이 구현해야 한다

    public virtual string Describe()       // 기본 구현: 자식이 선택적으로 재정의
    {
        return $"{Name}의 면적: {Area():F2}";
    }
}

class Circle : Shape
{
    private readonly double radius;

    public Circle(double radius) : base("원")
    {
        this.radius = radius;
    }

    public override double Area()
    {
        return Math.PI * radius * radius;
    }
}

class Program
{
    static void Main()
    {
        // Shape s = new Shape("x");       // 컴파일 오류: 추상 클래스는 인스턴스화할 수 없다
        Shape s = new Circle(2);
        Console.WriteLine(s.Describe());   // 원의 면적: 12.57
    }
}
```

## 4. 추상 클래스와 인터페이스

| 항목 | 추상 클래스 | 인터페이스 |
|---|---|---|
| 상속 | 클래스는 하나만 상속한다(단일 상속) | 여러 개를 구현할 수 있다 |
| 상태(필드) | 가질 수 있다 | 인스턴스 필드를 가질 수 없다 |
| 생성자 | 가질 수 있다 | 가질 수 없다 |
| 구현 | 구현이 있는 메서드를 가질 수 있다 | 기본적으로 시그니처만 가진다. C# 8 이상은 기본 구현(default interface method)도 허용한다 |
| 쓰는 곳 | 공통 상태와 구현을 공유하는 "is-a" 계층 | 서로 다른 계층의 클래스에 같은 능력을 부여 |

{% hint style="info" %}
NOTE: 인터페이스의 기본 구현은 C# 8 이상, .NET Core 3.0 이상 런타임에서 쓸 수 있다. Unity는 버전에 따라 지원하는 C# 문법 범위가 다르므로 프로젝트의 C# 언어 버전을 확인한다.
{% endhint %}

## 5. 한계와 주의

* 추상 클래스를 상속한 클래스가 추상 메서드를 모두 구현하지 않으면 그 클래스도 `abstract`여야 한다. 그렇지 않으면 컴파일 오류가 난다.
* `abstract`와 `sealed`, `abstract`와 `static`은 함께 쓸 수 없다.
* 추상 메서드는 `private`으로 선언할 수 없다. 접근 수준은 `public` 또는 `protected` 등으로 둔다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 추상 클래스와 인터페이스 중 무엇을 쓸지 정하는 내 기준은?
- [ ] "추상 클래스는 `new`로 만들 수 없다"는 제약이 설계에 주는 이점을 내 말로 설명하면?
