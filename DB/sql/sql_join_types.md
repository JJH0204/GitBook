# [생성형 AI] 조인 종류와 결과 비교

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-SQL-009-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | INNER, LEFT, CROSS, 자기 조인의 결과 차이와 MariaDB에서 FULL OUTER JOIN을 대신하는 방법을 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (SQLite 3.46.1, Python sqlite3, 2026-11-19에서 이 문서의 질의를 실행해 결과를 확인했다. MariaDB에서는 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 1. 목적

조인(join)은 여러 테이블의 행을 조건으로 이어 붙인다. 종류마다 일치하는 행이 없을 때의 처리가 다르다. 개념 소개는 DB-OVW-001-DO, 학생 실습 질의는 DB-OVW-004-REF를 따른다. 이 문서는 같은 데이터로 결과를 나란히 비교한다.

## 2. 구성 요소

### 2.1 예제 데이터

```sql
CREATE TABLE dept (id INTEGER PRIMARY KEY, name TEXT);
CREATE TABLE emp  (id INTEGER PRIMARY KEY, name TEXT,
                   dept_id INTEGER REFERENCES dept(id), mgr_id INTEGER);
INSERT INTO dept VALUES (1,'개발'),(2,'영업'),(3,'인사');
INSERT INTO emp  VALUES (1,'A',1,NULL),(2,'B',1,1),(3,'C',2,1),(4,'D',NULL,3);
```

`D`는 부서가 없고(`dept_id`가 NULL), 부서 `인사`에는 사원이 없다.

### 2.2 조인 종류와 결과

| 종류 | 질의 | 결과 | 규칙 |
|---|---|---|---|
| INNER JOIN | `SELECT e.name, d.name FROM emp e INNER JOIN dept d ON e.dept_id = d.id;` | (A,개발) (B,개발) (C,영업) | 양쪽에 일치하는 행만 나온다. D와 인사는 빠진다 |
| LEFT JOIN | `SELECT e.name, d.name FROM emp e LEFT JOIN dept d ON e.dept_id = d.id;` | 위 3행 + (D, NULL) | 왼쪽 행은 모두 나온다. 일치가 없으면 오른쪽은 NULL이다 |
| LEFT JOIN (반대 방향) | `SELECT d.name, e.name FROM dept d LEFT JOIN emp e ON e.dept_id = d.id;` | (개발,A) (개발,B) (영업,C) (인사,NULL) | 사원이 없는 부서도 나온다 |
| CROSS JOIN | `SELECT COUNT(*) FROM emp CROSS JOIN dept;` | 12 | 모든 조합이다. 4행 × 3행 = 12행 |
| 자기 조인 | `SELECT e.name, m.name FROM emp e LEFT JOIN emp m ON e.mgr_id = m.id;` | (A,NULL) (B,A) (C,A) (D,C) | 같은 테이블을 별칭 둘로 이어 사원과 상사를 한 행에 놓는다 |

`RIGHT JOIN`은 `LEFT JOIN`에서 두 테이블의 순서를 바꾼 것과 같은 결과다. 어느 한쪽으로 통일해 쓰면 읽기 쉽다.

### 2.3 일치하지 않는 행만 찾기

```sql
SELECT d.name FROM dept d LEFT JOIN emp e ON e.dept_id = d.id WHERE e.id IS NULL;
```

결과는 `인사` 한 행이다. `LEFT JOIN` 뒤에 오른쪽 테이블의 기본 키가 NULL인 행만 남기면 짝이 없는 행이 된다.

### 2.4 FULL OUTER JOIN 대용

MariaDB는 `FULL OUTER JOIN` 문법을 지원하지 않는다. 양방향 `LEFT JOIN`을 `UNION`으로 합쳐 대신한다.

```sql
SELECT e.name, d.name FROM emp e LEFT JOIN dept d ON e.dept_id = d.id
UNION
SELECT e.name, d.name FROM dept d LEFT JOIN emp e ON e.dept_id = d.id;
```

결과는 (A,개발) (B,개발) (C,영업) (D,NULL) (NULL,인사) 다섯 행이다. `UNION`은 중복 행을 제거하고, `UNION ALL`은 제거하지 않는다.

{% hint style="warning" %}
CAUTION: `LEFT JOIN`에서 오른쪽 테이블의 열을 `WHERE`에 조건으로 쓰면 NULL 행이 걸러져 `INNER JOIN`과 같아진다. 오른쪽 테이블의 조건은 `ON`에 둔다.
{% endhint %}

## 3. 동작 원리

| 순서 | 처리 |
|---|---|
| 1 | `FROM`의 두 테이블에서 `ON` 조건을 만족하는 행 쌍을 만든다 |
| 2 | `LEFT JOIN`이면 짝이 없는 왼쪽 행을 오른쪽 열을 NULL로 채워 더한다 |
| 3 | `WHERE`가 결과 행을 거른다 |
| 4 | `GROUP BY`, `HAVING`, `ORDER BY`가 이어서 처리된다 |

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 별칭(alias) | 테이블이나 열에 붙이는 짧은 이름. `emp e`의 `e` |
| 카테시안 곱 | 두 테이블의 모든 행 조합. `CROSS JOIN`의 결과 |
| 자기 조인 | 한 테이블을 자기 자신과 조인하는 것 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `INNER JOIN`과 `LEFT JOIN`의 결과가 달라지는 경우를 내가 만든 데이터로 적어 보자.
- [ ] 조인 조건을 빼먹으면 어떤 결과가 나오는지 행 수로 설명해 보자.
- [ ] 자기 조인이 필요한 데이터 구조의 예를 하나 적어 보자.
