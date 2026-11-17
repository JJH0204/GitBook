# 개방 폐쇄 원칙 (OCP)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-SLD-003-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 기존 코드를 수정하지 않고 기능을 확장하는 구조를 설명한다 |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

{% hint style="info" %}
NOTE: 소프트웨어 구성 요소는 확장에는 열려 있어야 하고, 수정에는 닫혀 있어야 한다.
{% endhint %}

새 기능을 추가할 때 이미 검증된 코드를 고치지 않고 새 코드를 더하는 방식으로 끝나야 한다. 그러면 기능 추가에 따른 회귀(regression) 위험이 줄어든다.

## 2. 구성 요소

| 구성 요소 | 역할 |
|---|---|
| 추상(인터페이스·추상 클래스) | 변하는 부분의 약속을 정의한다. 예: `IDiscountPolicy` |
| 구현 클래스 | 추상을 구현한다. 새 기능은 새 구현 클래스로 추가한다 |
| 사용 클래스 | 추상에만 의존한다. 새 구현이 추가돼도 수정하지 않는다 |

## 3. 동작 원리

1. 변하는 부분(할인 규칙)을 찾는다.
2. 그 부분을 인터페이스로 뽑아낸다.
3. 사용 클래스는 인터페이스만 호출한다.
4. 새 규칙은 인터페이스를 구현한 새 클래스로 추가한다.

## 4. 예제 코드

위반 예제다. 할인 종류가 늘 때마다 `switch`를 수정한다.

```csharp
class DiscountCalculator
{
    public decimal Apply(string type, decimal price)
    {
        switch (type)
        {
            case "VIP":    return price * 0.8m;
            case "Normal": return price * 0.95m;
            default:       return price;
            // 새 할인이 생기면 이 메서드를 수정해야 한다
        }
    }
}
```

준수 예제다. 새 할인은 새 클래스로 추가한다.

```csharp
interface IDiscountPolicy
{
    decimal Apply(decimal price);
}

class VipDiscount : IDiscountPolicy
{
    public decimal Apply(decimal price) => price * 0.8m;
}

class NormalDiscount : IDiscountPolicy
{
    public decimal Apply(decimal price) => price * 0.95m;
}

class Checkout
{
    private readonly IDiscountPolicy _policy;

    public Checkout(IDiscountPolicy policy)
    {
        _policy = policy;
    }

    public decimal Total(decimal price) => _policy.Apply(price);
}
```

`BlackFridayDiscount : IDiscountPolicy`를 추가해도 `Checkout`은 수정하지 않는다.

## 5. 코드 설명

| 대상 | 설명 |
|---|---|
| `switch` 버전 | 새 할인마다 `Apply`를 수정한다. 기존 분기도 다시 테스트해야 한다 |
| `IDiscountPolicy` | 변하는 부분의 약속이다 |
| `Checkout` | 구체 할인 클래스를 모르고 인터페이스만 호출한다 |

## 6. 한계·주의

- 모든 변경을 미리 예측해 추상화할 수는 없다. 실제로 변경이 반복되는 지점에 적용한다.
- 추상을 만들면 클래스가 늘고 흐름이 간접적이 된다. 분기가 두세 개이고 거의 바뀌지 않으면 `switch`가 더 단순하다.
- 완전한 "수정 불가"는 없다. 어떤 변경에 닫혀 있을지 선택하는 것이다.

관련 문서: [SOLID 원칙 개요](solidprinciples.md), [의존관계 역전 원칙 (DIP)](dipdependencyinversionprinciple.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 내 코드에서 기능을 추가할 때마다 고치는 `if`/`switch`가 있는가? 있다면 어디인가?
- [ ] 추상화하지 않고 `switch`로 두는 것이 나은 경우는 언제인가?
