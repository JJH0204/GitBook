# [생성형 AI] 싱글턴 패턴 (Singleton)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-ARP-007-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 클래스의 인스턴스를 하나로 제한하는 싱글턴 패턴의 구조와 주의점을 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(python3로 실행). 아래 Python 코드를 Python 3.14에서 실행해 출력 예와 일치함을 확인했다. 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

싱글턴 패턴(Singleton pattern)은 클래스의 인스턴스가 프로그램 안에서 하나만 존재하도록 보장하고, 그 인스턴스에 접근하는 전역 지점을 제공하는 생성 패턴이다. 설정 저장소, 로거, 연결 풀처럼 둘 이상이면 상태가 어긋나는 객체에 쓴다.

## 2. 구조

| 요소 | 책임 |
|---|---|
| 정적 필드(`_instance`) | 만들어진 유일한 인스턴스를 보관한다 |
| 생성 통제(`__new__`) | 인스턴스가 없을 때만 만들고, 있으면 기존 것을 돌려준다 |
| 잠금(`Lock`) | 여러 스레드가 동시에 처음 생성하는 경쟁을 막는다 |

## 3. 예제 코드 (Python)

{% code title="singleton.py" %}
```python
import threading


class Config:
    _instance = None
    _lock = threading.Lock()

    def __new__(cls):
        if cls._instance is None:
            with cls._lock:                      # 동시에 두 번 만들지 않도록 잠근다
                if cls._instance is None:
                    cls._instance = super().__new__(cls)
                    cls._instance.values = {}
        return cls._instance


a = Config()
b = Config()
a.values["mode"] = "debug"
print(a is b)
print(b.values["mode"])
```
{% endcode %}

실행 결과:

```
True
debug
```

| 위치 | 설명 |
|---|---|
| `_instance is None` 두 번 검사 | 바깥 검사는 이미 만들어진 뒤 잠금 비용을 피한다. 안쪽 검사는 잠금을 기다리던 다른 스레드가 이미 만들었는지 다시 확인한다 |
| `a is b` | 두 번 호출해도 같은 객체이므로 `True`가 나온다 |

## 4. 한계와 주의

* 전역 상태이므로 어디서든 바뀔 수 있어 코드의 의존 관계가 숨고 단위 테스트에서 상태가 남는다. 인스턴스를 인자로 전달하는 방식(의존성 주입)을 먼저 검토한다.
* 단순한 경우 Python에서는 모듈 수준 변수가 이미 하나만 만들어지는 객체이므로 모듈 자체를 싱글턴처럼 쓸 수 있다.
* `__init__`은 `Config()`를 부를 때마다 다시 실행된다. 위 예제는 값을 `__new__`에서 한 번만 초기화해 이를 피했다.
* 다른 언어에서는 언어별 관례가 다르므로(정적 지연 초기화 등) 해당 언어 문서를 따른다.

## 관련 문서

* [전략 패턴 (Strategy)](strategy-pattern.md)
* [옵저버 패턴 (Observer)](observer-pattern.md)
* [클래스와 객체 (Classes)](../../languages/python/python-classes.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 싱글턴 대신 인스턴스를 함수 인자로 넘기면 테스트가 쉬워지는 이유를 설명한다.
- [ ] `__new__`의 잠금과 이중 검사가 없으면 어떤 상황에서 인스턴스가 둘 만들어지는지 적는다.
- [ ] 직접 겪은 '전역 하나만 있어야 하는 객체'의 예를 든다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
