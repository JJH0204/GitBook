# [생성형 AI] Python 예외 처리 (Exceptions)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-PYT-007-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | try/except/else/finally, 예외 발생과 사용자 정의 예외를 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(python3로 실행). 아래 Python 코드를 Python 3.14에서 실행해 출력 예와 일치함을 확인했다. 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

예외(exception)는 실행 중 오류를 나타내는 객체다. 예외가 발생하면 정상 흐름이 중단되고 가장 가까운 `except` 블록으로 이동한다. 처리하는 곳이 없으면 프로그램이 트레이스백과 함께 종료된다.

## 2. 구문

| 절 | 실행 시점 |
|---|---|
| `try` | 예외가 날 수 있는 코드 |
| `except 예외형 as e` | 해당 예외가 발생했을 때 |
| `else` | `try`에서 예외가 없었을 때만 |
| `finally` | 예외 여부와 무관하게 항상(`return` 직전에도) |
| `raise` | 예외를 직접 발생시킨다 |
| `raise A from B` | 원인 예외 B를 `A.__cause__`에 연결한다 |

## 3. 예제 코드

{% code title="exceptions.py" %}
```python
class InsufficientFunds(Exception):
    pass


def withdraw(balance, amount):
    if amount > balance:
        raise InsufficientFunds(f"need {amount - balance} more")
    return balance - amount


def parse(text):
    try:
        n = int(text)
    except ValueError:
        print("not a number:", text)
        return None
    else:                               # 예외가 없을 때만 실행
        print("parsed:", n)
        return n
    finally:                            # 항상 실행
        print("done:", text)


parse("42")
parse("abc")
try:
    withdraw(100, 150)
except InsufficientFunds as e:
    print("failed:", e)

try:
    try:
        {}["k"]
    except KeyError as e:
        raise RuntimeError("lookup failed") from e
except RuntimeError as e:
    print(e, "<-", repr(e.__cause__))
```
{% endcode %}

실행 결과:

```
parsed: 42
done: 42
not a number: abc
done: abc
failed: need 50 more
lookup failed <- KeyError('k')
```

| 위치 | 설명 |
|---|---|
| `except ValueError` | `int("abc")`처럼 변환할 수 없는 값만 잡는다 |
| `else` | 성공 때만 하는 후속 작업을 두어 `try` 범위를 좁힌다 |
| `finally` | `return`이 있어도 실행된다. 출력에서 `done`이 `parsed` 또는 `not a number` 뒤에 나온다 |
| `InsufficientFunds` | `Exception`을 상속한 사용자 정의 예외 |
| `raise ... from e` | 예외 변환 시 원래 원인(`KeyError`)을 남긴다 |

## 4. 한계와 주의

* `except:`처럼 예외형 없이 쓰면 `KeyboardInterrupt` 등 종료 신호까지 잡는다. 필요한 예외형만 적는다.
* 예외를 잡고 아무것도 하지 않으면 오류가 숨는다. 최소한 로그를 남기거나 다시 발생시킨다(`raise`).
* 파일처럼 닫아야 하는 자원은 `finally`보다 `with`가 간결하다([파일 입출력](python-files.md)).
* 흔한 흐름 제어(예: 키가 없을 수 있음)는 `in` 검사나 `dict.get`이 예외보다 읽기 쉬울 때가 많다.

## 관련 문서

* [함수 (Functions)](python-functions.md)
* [파일 입출력 (File I/O)](python-files.md)
* [클래스와 객체 (Classes)](python-classes.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `else`와 `finally`의 차이를 설명한다.
- [ ] `except:` 단독 사용이 위험한 이유를 적는다.
- [ ] 자신이 만든 프로그램에서 사용자 정의 예외가 필요한 곳을 하나 찾아 적는다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
