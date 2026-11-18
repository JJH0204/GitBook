# [생성형 AI] 옵저버 패턴 (Observer)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-ARP-005-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 한 객체의 상태 변화를 여러 객체에 알리는 옵저버 패턴의 구조와 장단점을 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(python3로 실행). 아래 Python 코드를 실행해 출력 예와 일치함을 확인했다. 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

옵저버 패턴(Observer pattern)은 한 객체(주체, subject)의 상태가 바뀌면 그 객체에 등록된 다른 객체들(관찰자, observer)에게 자동으로 알리는 행동 패턴이다. 주체는 관찰자의 구체적인 종류를 모르고, "알림을 받을 수 있는 대상"으로만 안다. 일대다(one-to-many) 의존 관계를 느슨하게 만든다.

## 2. 구조

| 역할 | 책임 |
|---|---|
| Subject(주체) | 관찰자 목록을 관리한다. 등록(attach), 해제(detach), 알림(notify)을 제공한다 |
| Observer(관찰자) | 알림을 받았을 때 호출되는 메서드(또는 함수)를 가진다 |
| ConcreteSubject | 실제 상태를 갖고 상태가 바뀔 때 `notify`를 호출한다 |

흐름: 관찰자가 attach로 등록한다 → 주체의 상태가 바뀐다 → 주체가 `notify`로 등록된 관찰자를 차례로 호출한다 → 관찰자가 각자 반응한다.

## 3. 예제 코드 (Python)

온도계(주체)의 값이 바뀌면 화면 표시와 경보 두 관찰자가 반응한다. 관찰자는 호출 가능한 함수로 단순화했다.

{% code title="observer.py" %}
```python
class Subject:
    def __init__(self):
        self._observers = []

    def attach(self, fn):
        self._observers.append(fn)

    def detach(self, fn):
        self._observers.remove(fn)

    def notify(self, event):
        for fn in list(self._observers):   # 순회 중 detach 되어도 안전하도록 복사
            fn(event)


class Thermometer(Subject):
    def set_temp(self, t):
        self.temp = t
        self.notify(t)


def display(t):
    print("display:", t)

def alarm(t):
    if t > 30:
        print("alarm: too hot", t)


th = Thermometer()
th.attach(display)
th.attach(alarm)
th.set_temp(25)
th.set_temp(35)
th.detach(alarm)
th.set_temp(40)
```
{% endcode %}

실행 결과:

```
display: 25
display: 35
alarm: too hot 35
display: 40
```

| 위치 | 설명 |
|---|---|
| `attach`, `detach` | 관찰자 목록에 추가·제거한다. 주체 코드는 관찰자의 구체 내용을 알지 못한다 |
| `list(self._observers)` | 알림 도중 관찰자가 자신을 `detach`해도 순회가 깨지지 않도록 복사본을 순회한다 |
| `th.detach(alarm)` 이후 | 경보 관찰자는 더 이상 알림을 받지 않는다(마지막 `40`에서 `alarm` 출력이 없다) |

## 4. 장단점

| 장점 | 단점 |
|---|---|
| 주체와 관찰자의 결합도가 낮다([결합도](../oop/coupling.md) 참고) | 알림 순서가 보장되지 않거나 구현에 의존한다 |
| 주체 코드를 바꾸지 않고 관찰자를 추가·제거할 수 있다([개방 폐쇄 원칙](../solid/ocpopenclosedprinciple.md)과 맞는다) | 관찰자가 해제되지 않으면 주체가 계속 참조해 메모리 누수가 된다 |
| 이벤트 처리, GUI, 메시지 구독 구조의 기본 모델이다 | 알림이 연쇄적으로 또 다른 알림을 일으키면 흐름을 추적하기 어렵다 |

## 5. 한계와 주의

* 예제는 한 스레드에서만 쓴다. 여러 스레드가 동시에 등록·알림을 하면 동기화가 필요하다.
* 관찰자가 예외를 던지면 뒤 관찰자가 호출되지 않는다. 예제는 이를 처리하지 않는다.
* 상태 전체를 넘기는 방식(push)과 관찰자가 필요할 때 주체에서 읽어 가는 방식(pull) 중 어느 쪽인지 설계 시 정한다. 예제는 값을 직접 넘기는 push 방식이다.

## 관련 문서

* [전략 패턴 (Strategy)](strategy-pattern.md)
* [결합도 (Coupling)](../oop/coupling.md)
* [개방 폐쇄 원칙 (OCP)](../solid/ocpopenclosedprinciple.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 옵저버 패턴이 결합도를 낮추는 이유를 주체가 관찰자에 대해 아는 것의 범위로 설명한다.
- [ ] 관찰자가 해제되지 않을 때 어떤 문제가 생기는지 적는다.
- [ ] 알림을 받아야 하는 실제 상황(예: 버튼 클릭, 데이터 변경)을 하나 골라 주체와 관찰자를 나눠 본다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
