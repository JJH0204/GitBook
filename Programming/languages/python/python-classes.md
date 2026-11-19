# [생성형 AI] Python 클래스와 객체 (Classes)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-PYT-006-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 클래스 정의, 속성, 상속, 프로퍼티, classmethod와 staticmethod를 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(python3로 실행). 아래 Python 코드를 Python 3.14에서 실행해 출력 예와 일치함을 확인했다. 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

클래스는 데이터(속성)와 동작(메서드)을 묶는 틀이고, 객체(인스턴스)는 그 틀로 만든 값이다. 메서드의 첫 인자 `self`는 호출된 객체 자신이다.

## 2. 구성 요소

| 요소 | 의미 |
|---|---|
| `__init__` | 객체를 만든 직후 속성을 초기화한다 |
| 인스턴스 속성(`self.x`) | 객체마다 따로 가진다 |
| 클래스 속성 | 클래스에 정의해 모든 객체가 공유한다 |
| `@property` | 메서드를 속성처럼 읽게 한다(읽기 전용 값 표현에 쓴다) |
| `@classmethod` | 첫 인자가 클래스(`cls`)다. 다른 생성 방법에 쓴다 |
| `@staticmethod` | `self`, `cls`가 없는 일반 함수를 클래스 안에 둔다 |
| 상속 | `class B(A)`. `super()`로 부모 메서드를 부른다 |
| `__repr__` | 객체를 디버깅용 문자열로 나타낸다 |

## 3. 예제 코드

{% code title="classes.py" %}
```python
class Account:
    bank = "demo"                      # 클래스 속성: 모든 인스턴스가 공유

    def __init__(self, owner, balance=0):
        self.owner = owner             # 인스턴스 속성
        self._balance = balance

    @property
    def balance(self):
        return self._balance

    def deposit(self, amount):
        if amount <= 0:
            raise ValueError("amount must be positive")
        self._balance += amount

    @classmethod
    def empty(cls, owner):
        return cls(owner, 0)

    @staticmethod
    def is_valid(amount):
        return amount > 0

    def __repr__(self):
        return f"Account({self.owner!r}, {self._balance})"


class Savings(Account):
    def __init__(self, owner, balance=0, rate=0.01):
        super().__init__(owner, balance)
        self.rate = rate

    def add_interest(self):
        self.deposit(int(self._balance * self.rate))


a = Account.empty("kim")
a.deposit(1000)
print(a, a.balance, Account.is_valid(-1))
s = Savings("lee", 10000, 0.05)
s.add_interest()
print(s, isinstance(s, Account), Savings.bank)
try:
    a.deposit(0)
except ValueError as e:
    print("error:", e)
```
{% endcode %}

실행 결과:

```
Account('kim', 1000) 1000 False
Account('lee', 10500) True demo
error: amount must be positive
```

| 위치 | 설명 |
|---|---|
| `_balance` | 밑줄 한 개는 외부에서 직접 쓰지 말자는 관례다. 접근을 막지는 않는다 |
| `Account.empty("kim")` | `classmethod`로 다른 생성 경로를 만든다. `cls(owner, 0)`이라 하위 클래스에서 부르면 하위 클래스 객체가 만들어진다 |
| `super().__init__(...)` | 부모의 초기화를 먼저 실행한다 |
| `Savings.bank` | 클래스 속성은 하위 클래스에서도 보인다 |

## 4. 한계와 주의

* 클래스 속성에 리스트 등 변경 가능한 값을 두면 모든 객체가 공유한다. 객체마다 필요하면 `__init__`에서 만든다.
* `__init__`을 오버라이드하면서 `super().__init__()`을 부르지 않으면 부모의 속성이 만들어지지 않는다.
* 접근 제어 키워드(`private`)는 없다. 밑줄 두 개(`__x`)는 이름만 바꿀 뿐 완전한 보호가 아니다.

## 관련 문서

* [함수 (Functions)](python-functions.md)
* [예외 처리 (Exceptions)](python-exceptions.md)
* [추상 클래스 (Abstract Class)](../c/csharp/abstractclasses.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 클래스 속성과 인스턴스 속성의 차이를 리스트를 예로 들어 설명한다.
- [ ] `classmethod`와 `staticmethod`를 각각 어떤 때 쓰는지 적는다.
- [ ] `Savings`에서 `super().__init__`을 빼면 어떤 오류가 나는지 실행해 적는다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
