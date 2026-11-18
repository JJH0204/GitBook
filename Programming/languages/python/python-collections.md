# [생성형 AI] Python 컬렉션 (list, tuple, dict, set)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-PYT-004-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | Python 기본 컬렉션 네 가지의 특성과 선택 기준을 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(python3로 실행). 아래 Python 코드를 실행해 출력 예와 일치함을 확인했다. 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

Python의 기본 컬렉션은 목록(`list`), 튜플(`tuple`), 딕셔너리(`dict`), 집합(`set`)이다.

| 자료형 | 리터럴 | 순서 | 변경 가능 | 중복 | 내부 구조(CPython) |
|---|---|---|---|---|---|
| list | `[1, 2]` | 있음 | 가능 | 허용 | 동적 배열 |
| tuple | `(1, 2)` | 있음 | 불가 | 허용 | 고정 배열 |
| dict | `{"a": 1}` | 삽입 순서 유지(3.7 이후 언어 사양) | 가능 | 키는 유일 | 해시 테이블 |
| set | `{1, 2}` | 없음 | 가능 | 불허 | 해시 테이블 |

빈 집합은 `{}`가 아니라 `set()`이다. `{}`는 빈 딕셔너리다.

## 2. 연산 복잡도

| 연산 | list | dict / set |
|---|---|---|
| 인덱스·키 접근 | O(1) | 평균 O(1) |
| 값 포함 여부(`x in c`) | O(n) | 평균 O(1) |
| 끝에 추가(`append`) | 분할상환 O(1) | 평균 O(1) |
| 앞·중간 삽입(`insert`) | O(n) | - |

`dict`와 `set`이 빠른 이유는 [해시 테이블](../../cs-fundamentals/data-structures/hash-table.md)이기 때문이다. 포함 여부를 자주 검사한다면 리스트보다 집합이 적합하다.

## 3. 예제 코드

{% code title="collections_demo.py" %}
```python
nums = [3, 1, 2]
nums.append(4)
nums.insert(0, 9)
print(nums, nums[1:3], nums[-1])
nums.sort()
print(nums)

pt = (1, 2)
x, y = pt
print(x, y)
try:
    pt[0] = 5
except TypeError as e:
    print("TypeError:", e)

ages = {"kim": 20, "lee": 25}
ages["park"] = 30
print(ages.get("choi", -1), ages["kim"], list(ages.items()))

a, b = {1, 2, 3}, {3, 4}
print(a & b, a | b, a - b, 2 in a)

squares = [n * n for n in range(5) if n % 2 == 0]
print(squares)

try:
    {[1]: 1}
except TypeError as e:
    print("TypeError:", e)

c = [1, 2]; d = c; e = c.copy()
d.append(3)
print(c, e)
```
{% endcode %}

실행 결과:

```
[9, 3, 1, 2, 4] [3, 1] 4
[1, 2, 3, 4, 9]
1 2
TypeError: 'tuple' object does not support item assignment
-1 20 [('kim', 20), ('lee', 25), ('park', 30)]
{3} {1, 2, 3, 4} {1, 2} True
[0, 4, 16]
TypeError: cannot use 'list' as a dict key (unhashable type: 'list')
[1, 2, 3] [1, 2]
```

(출력 예의 `TypeError` 메시지 문구는 Python 버전에 따라 조금 다를 수 있다. 위는 실행한 환경의 출력이다.)

| 위치 | 설명 |
|---|---|
| `nums[1:3]`, `nums[-1]` | 슬라이싱은 끝 인덱스를 포함하지 않는다. 음수 인덱스는 뒤에서부터 센다 |
| `pt[0] = 5` | 튜플은 요소를 바꿀 수 없어 `TypeError`가 난다 |
| `ages.get("choi", -1)` | 키가 없을 때 `KeyError` 대신 기본값을 반환한다 |
| `a & b`, `a \| b`, `a - b` | 교집합, 합집합, 차집합 |
| 리스트 컴프리헨션 | `[n * n for n in range(5) if n % 2 == 0]`은 짝수의 제곱만 모은다 |
| `{[1]: 1}` | 리스트는 변경 가능해 해시할 수 없으므로 딕셔너리 키나 집합 원소가 될 수 없다. 튜플은 안의 요소가 모두 해시 가능할 때 키가 된다 |
| `d = c`와 `c.copy()` | `d = c`는 같은 객체를 가리키는 별칭이라 `d.append(3)`이 `c`에도 보인다. `c.copy()`는 얕은 복사라 영향이 없다 |

## 4. 한계와 주의

* 얕은 복사는 중첩된 리스트 안쪽 객체를 공유한다. 안쪽까지 복사하려면 `copy.deepcopy`를 쓴다.
* 반복 중인 리스트·딕셔너리의 크기를 바꾸면 오류나 의도하지 않은 결과가 나온다. 복사본을 순회하거나 새 컬렉션을 만든다.
* 순서가 필요한 큐로 `list.pop(0)`을 쓰면 O(n)이다. 양쪽 끝 연산이 잦으면 `collections.deque`를 쓴다.

## 관련 문서

* [Python 개요 (Overview)](pythonoverview.md)
* [해시 테이블 (Hash Table)](../../cs-fundamentals/data-structures/hash-table.md)
* [선형 자료구조 개요 (Linear)](../../cs-fundamentals/overviews/datastructuresalgorithms/lineardatastructureoverview.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 리스트에서 `in` 검사가 O(n)인데 집합에서는 평균 O(1)인 이유를 해시 테이블 원리로 설명한다.
- [ ] 튜플을 딕셔너리 키로 쓸 수 있는 경우와 없는 경우를 예로 든다.
- [ ] `b = a[:]`와 `b = a`의 차이를 `append`로 확인해 적는다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
