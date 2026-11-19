# [생성형 AI] 윈도 함수 (Window Function)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-SQL-015-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | 행을 합치지 않고 그룹 단위 계산과 순위를 붙이는 윈도 함수를 이해한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 부분 검증 (SQLite 3.46.1, Python sqlite3, 2026-11-19에서 예제 결과를 실행해 확인했다. MariaDB 지원 버전(10.2 이상으로 알려짐)은 실행하지 않았고 미확인이다) |
| 개정 | R1 (2026-11-19) |

## 1. 목적

`GROUP BY`는 그룹당 한 행으로 줄이지만, 윈도 함수는 원래 행을 그대로 두고 각 행 옆에 그룹 계산 결과를 붙인다. 순위, 부서별 합계와의 비교, 이전 행과의 차이를 구할 때 쓴다.

## 2. 구성 요소

| 구성 | 문법 | 설명 |
|---|---|---|
| 함수 | `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `LAG()`, `SUM()` 등 | 계산 종류 |
| `OVER` | `OVER (...)` | 윈도 함수임을 나타낸다 |
| `PARTITION BY` | `PARTITION BY <열>` | 그룹을 나눈다. 생략하면 전체가 한 그룹이다 |
| `ORDER BY` | `ORDER BY <열>` | 그룹 안의 정렬 순서 |

### 2.1 순위 함수 비교

예제 테이블 `s(id, dept, name, sal)`은 (1,D,A,500), (2,D,B,400), (3,D,C,400), (4,S,E,300)이다.

```sql
SELECT name, sal,
  ROW_NUMBER() OVER (ORDER BY sal DESC, id) AS rn,
  RANK()       OVER (ORDER BY sal DESC)     AS rk,
  DENSE_RANK() OVER (ORDER BY sal DESC)     AS dr
FROM s ORDER BY id;
```

| name | sal | rn | rk | dr |
|---|---|---|---|---|
| A | 500 | 1 | 1 | 1 |
| B | 400 | 2 | 2 | 2 |
| C | 400 | 3 | 2 | 2 |
| E | 300 | 4 | 4 | 3 |

| 함수 | 동점 처리 |
|---|---|
| `ROW_NUMBER` | 동점이어도 서로 다른 번호를 준다 |
| `RANK` | 동점은 같은 순위, 다음 순위는 건너뛴다 (2, 2, 4) |
| `DENSE_RANK` | 동점은 같은 순위, 다음 순위는 이어진다 (2, 2, 3) |

### 2.2 그룹 합계와 이전 행

```sql
SELECT name, dept, SUM(sal) OVER (PARTITION BY dept) AS dept_sum FROM s;
```

결과: D 부서 세 행은 모두 1300, S 부서 행은 300이다. 행 수는 줄지 않는다.

```sql
SELECT name, sal, sal - LAG(sal) OVER (ORDER BY id) AS diff FROM s ORDER BY id;
```

결과의 `diff`는 `NULL`, -100, 0, -100이다. 첫 행은 이전 행이 없어 `LAG`가 `NULL`을 돌려주고 뺄셈 결과도 `NULL`이 된다(DB-SQL-012-REF).

## 3. 동작 원리

| 순서 | 처리 |
|---|---|
| 1 | `FROM`, `WHERE`, `GROUP BY`, `HAVING`이 먼저 행을 확정한다 |
| 2 | `PARTITION BY`로 행을 그룹으로 나누고 그룹 안에서 `ORDER BY`로 정렬한다 |
| 3 | 각 행에 대해 함수를 계산해 새 열로 붙인다 |
| 4 | 마지막에 `SELECT`의 `ORDER BY`와 `LIMIT`가 적용된다 |

{% hint style="warning" %}
CAUTION: 윈도 함수는 `WHERE` 절에 쓸 수 없다. 순위로 거르려면 윈도 함수를 서브쿼리 안에서 계산하고 바깥 질의의 `WHERE`에서 조건을 건다(DB-SQL-010-DO).
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 윈도(window) | 한 행의 계산이 참조하는 행 집합 |
| 파티션 | `PARTITION BY`로 나눈 그룹 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `GROUP BY` 집계와 윈도 함수 집계가 결과 행 수에서 어떻게 다른지 적어 보자.
- [ ] `RANK`와 `DENSE_RANK`가 필요한 상황을 각각 하나씩 떠올려 보자.
- [ ] 부서별 급여 상위 2명을 구하려면 질의를 어떻게 나눌지 내 말로 설명해 보자.
