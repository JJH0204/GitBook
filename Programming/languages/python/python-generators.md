# [생성형 AI] Python 이터레이터와 제너레이터 (Generators)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-PYT-008-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 이터레이터 프로토콜과 yield 제너레이터, 지연 평가를 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(python3로 실행). 아래 Python 코드를 Python 3.14에서 실행해 출력 예와 일치함을 확인했다. 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

이터레이터(iterator)는 `next()`를 부를 때마다 다음 값을 돌려주고 끝나면 `StopIteration`을 일으키는 객체다. `for` 루프는 이 프로토콜을 쓴다. 제너레이터(generator)는 `yield`를 가진 함수로, 호출하면 이터레이터를 돌려준다. 값을 한 번에 다 만들지 않고 필요할 때 하나씩 만든다(지연 평가).

## 2. 비교

| 구분 | 리스트 `[x for ...]` | 제너레이터 식 `(x for ...)` |
|---|---|---|
| 메모리 | 모든 요소를 저장한다 | 현재 상태만 저장한다 |
| 다시 순회 | 몇 번이든 가능 | 한 번만 가능(소진됨) |
| 인덱싱, `len` | 가능 | 불가 |

## 3. 예제 코드

{% code title="generators.py" %}
```python
import sys


def count_up(limit):
    n = 1
    while n <= limit:
        yield n                    # 값을 내보내고 여기서 멈춘다
        n += 1


g = count_up(3)
print(next(g), next(g), next(g))
try:
    next(g)
except StopIteration:
    print("exhausted")

squares_list = [x * x for x in range(100000)]
squares_gen = (x * x for x in range(100000))
print(sys.getsizeof(squares_list) > sys.getsizeof(squares_gen))
print(sum(squares_gen))
print(list(count_up(3)))
```
{% endcode %}

실행 결과:

```
1 2 3
exhausted
True
333328333350000
[1, 2, 3]
```

| 위치 | 설명 |
|---|---|
| `yield n` | 값을 내보내고 함수 상태(지역 변수, 실행 위치)를 보존한 채 멈춘다. 다음 `next`에서 이어서 실행한다 |
| `StopIteration` | 함수가 끝나면 발생한다. `for` 문이 이를 받아 루프를 끝낸다 |
| `sys.getsizeof` 비교 | 리스트는 10만 개 요소를 담는 공간을 쓰고 제너레이터 객체는 크기가 작고 일정하다 |
| `sum(squares_gen)` | 제너레이터를 소비해 합을 구한다. 소비 후에는 비어 있다 |

## 4. 한계와 주의

* 제너레이터는 한 번 소진되면 다시 쓸 수 없다. 두 번 순회해야 하면 리스트로 만들거나 제너레이터를 다시 만든다.
* 파일 줄 읽기, 큰 데이터 변환처럼 전체를 메모리에 올리기 부담스러운 입력에 적합하다.
* 값 수가 적고 여러 번 접근하면 리스트가 단순하다.

## 관련 문서

* [Python 컬렉션 (list, tuple, dict, set)](python-collections.md)
* [함수 (Functions)](python-functions.md)
* [파일 입출력 (File I/O)](python-files.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 리스트 컴프리헨션과 제너레이터 식의 메모리 차이를 설명한다.
- [ ] 제너레이터를 두 번 순회하면 두 번째에 어떻게 되는지 실행해 적는다.
- [ ] `yield`가 함수 상태를 어떻게 보존하는지 자기 말로 적는다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
