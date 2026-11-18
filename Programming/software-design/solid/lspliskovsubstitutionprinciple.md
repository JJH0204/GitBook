# 리스코프 치환 원칙 (LSP)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-SLD-004-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 하위 타입이 상위 타입의 계약을 유지해야 하는 이유와 위반 사례를 설명한다 |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

{% hint style="info" %}
NOTE: 하위 타입은 상위 타입의 계약(contract)을 유지해야 한다. 상위 타입의 객체를 쓰는 코드에 하위 타입의 객체를 넣어도 프로그램이 올바르게 동작해야 한다.
{% endhint %}

하위 클래스는 상위 클래스의 행위를 확장할 수 있지만 상위 클래스가 약속한 동작을 깨뜨려서는 안 된다. 컴파일이 되는 상속이라도 계약을 깨면 LSP 위반이다.

## 2. 구성 요소

계약을 유지하기 위한 일반적인 조건은 다음과 같다.

| 조건 | 의미 |
|---|---|
| 사전 조건을 강화하지 않는다 | 하위 타입이 상위 타입보다 더 까다로운 입력을 요구하지 않는다 |
| 사후 조건을 약화하지 않는다 | 하위 타입이 상위 타입이 보장한 결과를 보장하지 못하는 일이 없다 |
| 불변 조건을 유지한다 | 상위 타입이 항상 참이라고 약속한 성질을 깨지 않는다 |
| 새 예외를 던지지 않는다 | 상위 타입이 약속하지 않은 예외로 호출자를 놀라게 하지 않는다 |

## 3. 동작 원리

1. 호출 코드는 상위 타입의 계약만 믿고 작성된다.
2. 실행 시 상위 타입 자리에 하위 타입 객체가 들어온다.
3. 하위 타입이 계약을 지키면 호출 코드는 수정 없이 동작한다.
4. 계약을 깨면 호출 코드가 하위 타입을 검사하는 분기(`is`, `GetType()`)를 갖게 되고 OCP도 함께 무너진다.

## 4. 예제 코드

위반 예제다. 정사각형(Square)을 직사각형(Rectangle)의 하위 클래스로 만든다. 직사각형의 계약은 "너비와 높이를 서로 독립적으로 바꿀 수 있다"이다. 정사각형은 이 계약을 지킬 수 없다.

```csharp
class Rectangle
{
    public virtual int Width { get; set; }
    public virtual int Height { get; set; }
    public int Area => Width * Height;
}

class Square : Rectangle
{
    public override int Width
    {
        get => base.Width;
        set { base.Width = value; base.Height = value; }   // 높이까지 바뀐다
    }
    public override int Height
    {
        get => base.Height;
        set { base.Width = value; base.Height = value; }   // 너비까지 바뀐다
    }
}

class Client
{
    public static void Resize(Rectangle r)
    {
        r.Width = 5;
        r.Height = 4;
        // Rectangle이면 Area == 20. Square를 넣으면 Area == 16
        System.Console.WriteLine(r.Area);
    }
}
```

준수 예제다. 공통 계약을 "넓이를 구한다"로 좁히고 각 도형은 불변(immutable) 값으로 만든다.

```csharp
interface IShape
{
    int Area { get; }
}

class Rectangle : IShape
{
    public int Width { get; }
    public int Height { get; }
    public Rectangle(int width, int height) { Width = width; Height = height; }
    public int Area => Width * Height;
}

class Square : IShape
{
    public int Side { get; }
    public Square(int side) { Side = side; }
    public int Area => Side * Side;
}
```

## 5. 코드 설명

| 대상 | 설명 |
|---|---|
| `Resize(Rectangle r)` | 너비 5, 높이 4를 따로 설정한 뒤 넓이 20을 기대한다 |
| `Square` 재정의 | 한쪽을 바꾸면 다른 쪽도 바뀌어 사후 조건("높이는 그대로다")을 깬다. `Square`를 넣으면 16이 출력된다 |
| `IShape` 해법 | 두 도형이 실제로 공유하는 계약(넓이)만 상위 타입에 둔다. 값이 불변이라 서로 영향을 주는 setter가 없다 |

현실의 정사각형은 수학적으로 직사각형이다. 그러나 코드에서는 "상태를 바꾸는 동작"까지 계약에 포함되므로 "is-a"가 곧 상속 가능을 뜻하지 않는다.

## 6. 한계·주의

- 하위 클래스가 메서드에서 `NotSupportedException`을 던지면 대개 LSP 위반이다. 상속 대신 합성이나 인터페이스 분리를 검토한다.
- LSP는 문법이 아니라 동작의 약속이다. 컴파일러는 검사하지 못하므로 테스트로 확인한다. 상위 타입의 테스트를 하위 타입에도 돌리면 위반을 찾을 수 있다.
- 상속은 "코드를 재사용하는 수단"이 아니라 "치환 가능한 하위 타입을 만드는 수단"으로 쓴다. 재사용만 필요하면 합성(has-a)을 쓴다.

관련 문서: [SOLID 원칙 개요](solidprinciples.md), [인터페이스 분리 원칙 (ISP)](ispinterfacesegregationprinciple.md), [객체지향 핵심 개념 (OOP)](../oop/objectorientedprogramming.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 내가 상속을 썼다가 하위 클래스가 상위 클래스의 기대와 다르게 동작한 경험이 있는가?
- [ ] "정사각형은 직사각형이다"가 코드에서 문제가 되는 이유를 내 말로 설명하라.
