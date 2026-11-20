# [생성형 AI] Python 함수 (Functions)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-PYT-005-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 함수 정의, 인자 종류, 기본값 함정, 클로저를 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(python3로 실행). 아래 Python 코드를 Python 3.14에서 실행해 출력 예와 일치함을 확인했다. 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

Python의 함수는 `def`로 정의하는 객체이며 변수에 담거나 인자로 넘길 수 있다. 값을 돌려주지 않으면 `None`을 반환한다.

## 2. 인자의 종류

| 형태 | 의미 |
|---|---|
| `def f(a, b)` | 위치 인자. 순서대로 대응한다 |
| `def f(a, b=1)` | 기본값이 있는 인자. 생략하면 기본값을 쓴다 |
| `def f(*args)` | 남는 위치 인자를 튜플로 받는다 |
| `def f(**kw)` | 남는 키워드 인자를 딕셔너리로 받는다 |
| `def f(a, *, key)` | `*` 뒤의 인자는 반드시 `key=값` 형태로 넘긴다(키워드 전용) |

## 3. 예제 코드

{% code title="functions.py" %}
```python
def greet(name, greeting="Hello", *, punct="!"):
    return f"{greeting}, {name}{punct}"


def total(*nums, **opts):
    s = sum(nums)
    return s * opts.get("scale", 1)


def append_bad(x, bucket=[]):          # 기본값 리스트는 호출 사이에 공유된다
    bucket.append(x)
    return bucket


def append_good(x, bucket=None):
    if bucket is None:
        bucket = []
    bucket.append(x)
    return bucket


def make_counter():
    count = 0

    def inc():
        nonlocal count
        count += 1
        return count
    return inc


print(greet("Kim"))
print(greet("Kim", "Hi", punct="?"))
print(total(1, 2, 3, scale=10))
print(append_bad(1), append_bad(2))
print(append_good(1), append_good(2))
c = make_counter()
print(c(), c(), c())
square = lambda x: x * x
print(list(map(square, [1, 2, 3])))
print(sorted(["bb", "a", "ccc"], key=len, reverse=True))
```
{% endcode %}

실행 결과:

```
Hello, Kim!
Hi, Kim?
60
[1, 2] [1, 2]
[1] [2]
1 2 3
[1, 4, 9]
['ccc', 'bb', 'a']
```

| 위치 | 설명 |
|---|---|
| `append_bad` | 기본값 `[]`는 함수를 정의할 때 한 번만 만들어진다. 호출마다 같은 리스트를 쓰므로 두 번째 호출 결과가 `[1, 2]`가 된다. 출력의 `[1, 2] [1, 2]`는 두 결과가 같은 객체여서 이미 두 값이 모두 들어간 뒤 출력되기 때문이다 |
| `append_good` | 기본값을 `None`으로 두고 함수 안에서 새 리스트를 만든다 |
| `make_counter` | 안쪽 함수 `inc`가 바깥 변수 `count`를 기억한다(클로저). 바깥 변수를 바꾸려면 `nonlocal`을 선언한다 |
| `lambda`, `key=len` | 이름 없는 한 줄 함수. 정렬 기준 등 짧은 함수 인자에 쓴다 |

## 4. 한계와 주의

* 변경 가능한 객체(리스트, 딕셔너리, 집합)를 기본값으로 쓰지 않는다.
* 인자로 넘긴 리스트를 함수 안에서 바꾸면 호출한 쪽의 리스트도 바뀐다. 객체의 참조가 전달되기 때문이다(C의 [참조에 의한 전달](../c-and-c++/pointers-and-memory/function-arguments-by-reference.md)과 다른 모델이다).
* `lambda`는 식 하나만 쓸 수 있다. 복잡하면 `def`로 쓴다.

## 관련 문서

* [Python 컬렉션 (list, tuple, dict, set)](python-collections.md)
* [클래스와 객체 (Classes)](python-classes.md)
* [Python 개요 (Overview)](pythonoverview.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 기본값 `[]`가 호출 사이에 공유되는 이유를 함수 정의 시점과 호출 시점으로 설명한다.
- [ ] `*args`와 `**kw`가 각각 무엇을 받는지 예를 든다.
- [ ] `nonlocal`을 빼면 `make_counter`가 어떻게 되는지 직접 실행해 적는다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
