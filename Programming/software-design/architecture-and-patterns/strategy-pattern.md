# [생성형 AI] 전략 패턴 (Strategy)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-ARP-006-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 알고리즘을 객체로 분리해 교체 가능하게 만드는 전략 패턴의 구조와 장단점을 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(python3로 실행). 아래 Python 코드를 실행해 출력 예와 일치함을 확인했다. 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

전략 패턴(Strategy pattern)은 같은 목적을 수행하는 여러 알고리즘을 각각 별도의 클래스로 만들고, 사용하는 쪽(컨텍스트)이 공통 인터페이스를 통해 실행 중에도 알고리즘을 바꿀 수 있게 하는 행동 패턴이다. `if`/`else`나 `switch`로 알고리즘을 분기하는 코드를 객체의 교체로 바꾼다.

## 2. 구조

| 역할 | 책임 |
|---|---|
| Strategy(전략 인터페이스) | 알고리즘을 호출하는 공통 메서드를 정의한다 |
| ConcreteStrategy | 각 알고리즘을 구현한다 |
| Context(컨텍스트) | 전략 객체를 보관하고 필요할 때 그 메서드를 호출한다. 구체 전략의 내용은 모른다 |

## 3. 예제 코드 (Python)

장바구니 합계에 할인 정책을 적용한다. 정률, 정액, 무할인이 각각 전략이다.

{% code title="strategy.py" %}
```python
from abc import ABC, abstractmethod


class Discount(ABC):
    @abstractmethod
    def apply(self, price: int) -> int: ...


class NoDiscount(Discount):
    def apply(self, price):
        return price


class PercentDiscount(Discount):
    def __init__(self, percent):
        self.percent = percent

    def apply(self, price):
        return price * (100 - self.percent) // 100


class FixedDiscount(Discount):
    def __init__(self, amount):
        self.amount = amount

    def apply(self, price):
        return max(price - self.amount, 0)


class Cart:
    def __init__(self, strategy: Discount):
        self.strategy = strategy      # 실행 중 교체할 수 있다
        self.items = []

    def add(self, price):
        self.items.append(price)

    def total(self):
        return self.strategy.apply(sum(self.items))


cart = Cart(NoDiscount())
cart.add(10000); cart.add(5000)
print(cart.total())
cart.strategy = PercentDiscount(10)
print(cart.total())
cart.strategy = FixedDiscount(20000)
print(cart.total())
```
{% endcode %}

실행 결과:

```
15000
13500
0
```

| 위치 | 설명 |
|---|---|
| `Discount(ABC)`, `@abstractmethod` | 모든 전략이 `apply`를 구현하도록 강제하는 인터페이스다 |
| `PercentDiscount.apply` | 15000원의 10% 할인은 `15000 * 90 // 100 = 13500`이다(정수 나눗셈) |
| `FixedDiscount.apply` | 20000원 정액 할인은 합계를 넘으므로 `max(..., 0)`으로 0에서 멈춘다 |
| `cart.strategy = ...` | 컨텍스트 코드를 바꾸지 않고 실행 중에 전략만 교체한다 |

## 4. 장단점

| 장점 | 단점 |
|---|---|
| 새 정책을 클래스 추가만으로 넣을 수 있다([개방 폐쇄 원칙](../solid/ocpopenclosedprinciple.md)) | 전략마다 클래스가 늘어난다 |
| 분기문이 사라지고 각 알고리즘을 따로 테스트할 수 있다 | 사용하는 쪽이 어떤 전략을 고를지 알아야 한다 |
| 컨텍스트가 구체 전략이 아니라 인터페이스에 의존한다([의존관계 역전 원칙](../solid/dipdependencyinversionprinciple.md)) | 전략이 단순하면 함수 하나로 충분해 과한 설계가 된다 |

## 5. 한계와 주의

* Python처럼 함수를 값으로 다룰 수 있는 언어에서는 전략을 클래스 대신 함수로 넘겨도 같은 효과를 얻는다. 전략이 상태나 여러 메서드를 가질 때만 클래스로 만든다.
* 전략이 둘 정도로 적고 바뀔 일이 없다면 단순한 조건문이 더 읽기 쉽다.
* 예제의 `apply`는 정수 금액만 다룬다. 실제 금액 계산은 반올림 규칙을 따로 정해야 한다.

## 관련 문서

* [옵저버 패턴 (Observer)](observer-pattern.md)
* [개방 폐쇄 원칙 (OCP)](../solid/ocpopenclosedprinciple.md)
* [의존관계 역전 원칙 (DIP)](../solid/dipdependencyinversionprinciple.md)
* [OOP 핵심 개념](../oop/objectorientedprogramming.md): 다형성

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 전략 패턴이 `if`/`else` 분기에 비해 새 정책 추가에 유리한 이유를 쓴다.
- [ ] 전략 패턴을 함수 전달로 바꿔 쓰는 방법을 적어 본다.
- [ ] 정렬 알고리즘 선택을 전략 패턴으로 설계하면 인터페이스가 어떻게 되는지 그려 본다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
