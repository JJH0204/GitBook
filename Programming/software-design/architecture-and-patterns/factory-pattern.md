# [생성형 AI] 팩토리 메서드 패턴 (Factory)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-ARP-008-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 객체 생성 코드를 한 함수로 모아 호출 쪽이 구체 클래스를 모르게 하는 팩토리 패턴을 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(python3로 실행). 아래 Python 코드를 Python 3.14에서 실행해 출력 예와 일치함을 확인했다. 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

팩토리(Factory) 패턴은 객체를 만드는 책임을 별도의 함수나 메서드에 맡겨, 사용하는 쪽이 구체 클래스 이름 대신 공통 인터페이스와 종류 값만 알게 하는 생성 패턴이다. 아래 예제는 인자로 종류를 받아 객체를 돌려주는 단순 팩토리 함수다. GoF의 팩토리 메서드는 이 생성 책임을 하위 클래스가 재정의하는 방식이며, 같은 목적을 가진다.

## 2. 구조

| 역할 | 책임 |
|---|---|
| Product(`Notifier`) | 만들어지는 객체가 지켜야 할 공통 인터페이스 |
| ConcreteProduct | 인터페이스를 구현한 구체 클래스 |
| Factory(`create_notifier`) | 종류에 따라 알맞은 구체 객체를 만들어 돌려준다 |

## 3. 예제 코드 (Python)

{% code title="factory.py" %}
```python
from abc import ABC, abstractmethod


class Notifier(ABC):
    @abstractmethod
    def send(self, msg: str) -> str: ...


class EmailNotifier(Notifier):
    def send(self, msg):
        return f"email: {msg}"


class SmsNotifier(Notifier):
    def send(self, msg):
        return f"sms: {msg}"


def create_notifier(kind: str) -> Notifier:
    table = {"email": EmailNotifier, "sms": SmsNotifier}
    if kind not in table:
        raise ValueError(f"unknown kind: {kind}")
    return table[kind]()


for kind in ("email", "sms"):
    print(create_notifier(kind).send("hello"))
try:
    create_notifier("fax")
except ValueError as e:
    print(e)
```
{% endcode %}

실행 결과:

```
email: hello
sms: hello
unknown kind: fax
```

| 위치 | 설명 |
|---|---|
| `table` 딕셔너리 | `if`/`elif` 분기 대신 종류와 클래스를 짝지어 새 종류를 한 줄로 추가한다 |
| `ValueError` | 알 수 없는 종류는 조용히 넘기지 않고 오류로 알린다 |
| 호출부 | `EmailNotifier`를 직접 쓰지 않으므로 클래스 이름이 바뀌어도 호출부는 그대로다 |

## 4. 한계와 주의

* 종류가 하나뿐이거나 생성 과정이 단순하면 팩토리는 층만 늘린다. 생성 방법이 바뀔 가능성이 있을 때 도입한다.
* 종류 문자열에 오타가 나면 실행 중에야 발견된다. 종류가 고정이면 열거형(`enum`)을 쓴다.
* 생성되는 객체를 교체하며 쓰는 구조는 [전략 패턴](strategy-pattern.md)과 함께 쓰는 경우가 많다.

## 관련 문서

* [싱글턴 패턴 (Singleton)](singleton-pattern.md)
* [전략 패턴 (Strategy)](strategy-pattern.md)
* [추상 클래스 (Abstract Class)](../../languages/c/csharp/abstractclasses.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `if`/`elif` 분기와 딕셔너리 표를 쓰는 팩토리의 차이를 설명한다.
- [ ] 단순 팩토리 함수와 팩토리 메서드(하위 클래스가 생성을 재정의)의 차이를 찾아 적는다.
- [ ] 팩토리가 필요 없는 경우를 예로 든다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
