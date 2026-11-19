# [생성형 AI] 데코레이터 패턴 (Decorator)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-ARP-009-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 객체를 같은 인터페이스의 래퍼로 감싸 기능을 겹쳐 쌓는 데코레이터 패턴을 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(python3로 실행). 아래 Python 코드를 Python 3.14에서 실행해 출력 예와 일치함을 확인했다. 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

데코레이터 패턴(Decorator pattern)은 원래 객체와 같은 인터페이스를 가진 래퍼(wrapper)로 객체를 감싸, 상속 없이 기능을 덧붙이는 구조 패턴이다. 래퍼도 같은 인터페이스를 가지므로 여러 겹으로 감쌀 수 있고, 감싸는 순서와 조합은 실행 중에 정한다.

{% hint style="info" %}
NOTE: Python의 `@decorator` 문법은 함수를 감싸는 언어 기능이며 이 패턴과 이름이 같지만 별개다. 이 문서는 객체 구조 패턴을 다룬다.
{% endhint %}

## 2. 구조

| 역할 | 책임 |
|---|---|
| Component(`Coffee`) | 공통 인터페이스 |
| ConcreteComponent(`Americano`) | 기본 동작을 가진 원본 객체 |
| Decorator(`Topping`) | 같은 인터페이스를 구현하면서 감싼 객체(`inner`)를 보관한다 |
| ConcreteDecorator(`Milk`, `Syrup`) | 감싼 객체의 결과에 기능을 더한다 |

## 3. 예제 코드 (Python)

{% code title="decorator_pattern.py" %}
```python
from abc import ABC, abstractmethod


class Coffee(ABC):
    @abstractmethod
    def cost(self) -> int: ...

    @abstractmethod
    def desc(self) -> str: ...


class Americano(Coffee):
    def cost(self):
        return 3000

    def desc(self):
        return "americano"


class Topping(Coffee):
    def __init__(self, inner: Coffee):
        self.inner = inner              # 감싸는 대상


class Milk(Topping):
    def cost(self):
        return self.inner.cost() + 500

    def desc(self):
        return self.inner.desc() + " + milk"


class Syrup(Topping):
    def cost(self):
        return self.inner.cost() + 300

    def desc(self):
        return self.inner.desc() + " + syrup"


c = Syrup(Milk(Americano()))
print(c.desc())
print(c.cost())
```
{% endcode %}

실행 결과:

```
americano + milk + syrup
3800
```

| 위치 | 설명 |
|---|---|
| `Syrup(Milk(Americano()))` | 안쪽부터 `Americano`, `Milk`, `Syrup` 순서로 감싼다 |
| `self.inner.cost() + 500` | 감싼 객체에 위임한 뒤 자기 몫을 더한다. 3000 + 500 + 300 = 3800 |

## 4. 한계와 주의

* 조합마다 하위 클래스를 만들면 클래스 수가 곱으로 늘어난다. 데코레이터는 이를 감싸는 겹의 수로 바꾼다.
* 겹이 많아지면 실행 중 어떤 래퍼가 어떻게 쌓였는지 추적하기 어렵고, 겹 순서에 따라 결과가 달라질 수 있다.
* 래퍼는 원본과 객체 동일성(`is`)이 다르다. 타입 검사로 원본을 판별하는 코드가 있으면 깨질 수 있다.

## 관련 문서

* [전략 패턴 (Strategy)](strategy-pattern.md)
* [옵저버 패턴 (Observer)](observer-pattern.md)
* [함수 (Functions)](../../languages/python/python-functions.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 상속으로 조합마다 클래스를 만드는 방식과 데코레이터의 클래스 수를 비교한다.
- [ ] 감싸는 순서를 바꾸면 결과가 달라지는 예를 하나 만든다.
- [ ] Python의 `@decorator` 문법과 이 패턴의 공통점과 차이를 적는다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
