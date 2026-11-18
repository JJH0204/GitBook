# [생성형 AI] 서브쿼리

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-SQL-010-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | 서브쿼리의 위치별 쓰임과 IN, EXISTS, 상관 서브쿼리의 차이를 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (SQLite 3.46.1, Python sqlite3, 2026-11-19에서 이 문서의 질의를 실행해 결과를 확인했다. MariaDB에서는 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 1. 목적

서브쿼리(subquery)는 다른 SQL 문 안에 들어 있는 `SELECT`다. 한 번의 질의로 풀기 어려운 조건을 단계로 나눠 쓴다. 예제는 DB-SQL-009-DO의 `dept`, `emp` 데이터(`emp`에 `salary` 열 추가: A 500, B 400, C 300, D 200)를 쓴다.

## 2. 구성 요소

| 위치 | 반환 형태 | 예 | 결과 |
|---|---|---|---|
| `WHERE`의 비교 | 값 하나(스칼라) | `SELECT name FROM emp WHERE salary > (SELECT AVG(salary) FROM emp);` | 평균 350보다 높은 A, B |
| `WHERE ... IN` | 값 목록 | `SELECT name FROM dept WHERE id IN (SELECT dept_id FROM emp);` | 개발, 영업 |
| `WHERE ... EXISTS` | 행 존재 여부 | `SELECT name FROM dept d WHERE NOT EXISTS (SELECT 1 FROM emp e WHERE e.dept_id = d.id);` | 인사 |
| 상관 서브쿼리 | 바깥 행마다 다시 계산 | `SELECT name FROM emp e WHERE salary > (SELECT AVG(salary) FROM emp x WHERE x.dept_id = e.dept_id);` | 자기 부서 평균보다 높은 A |
| `FROM`(파생 테이블) | 표 | `SELECT * FROM (SELECT dept_id, SUM(salary) s FROM emp GROUP BY dept_id) t WHERE s >= 300;` | (1,900) (2,300) |

{% hint style="info" %}
NOTE: 파생 테이블에는 별칭(`t`)이 필요하다. MariaDB는 별칭이 없으면 오류를 낸다.
{% endhint %}

### 2.1 NOT IN과 NULL

`NOT IN` 목록에 NULL이 하나라도 있으면 결과가 비어 버린다.

| 질의 | 결과 |
|---|---|
| `SELECT name FROM dept WHERE id NOT IN (SELECT dept_id FROM emp);` | 0행 (`emp.dept_id`에 NULL이 있다) |
| `SELECT name FROM dept WHERE id NOT IN (SELECT dept_id FROM emp WHERE dept_id IS NOT NULL);` | 인사 |
| `SELECT name FROM dept d WHERE NOT EXISTS (SELECT 1 FROM emp e WHERE e.dept_id = d.id);` | 인사 |

{% hint style="danger" %}
WARNING: 서브쿼리 대상 열이 NULL을 허용하면 `NOT IN`을 쓰지 않는다. 결과가 비어도 오류가 나지 않아 잘못을 알아채기 어렵다. `NOT EXISTS`를 쓴다. 원리는 DB-SQL-011-REF를 따른다.
{% endhint %}

## 3. 동작 원리

| 종류 | 실행 방식 |
|---|---|
| 비상관 서브쿼리 | 안쪽 질의가 바깥 질의와 무관하다. 개념상 한 번 계산한 결과를 바깥이 쓴다 |
| 상관 서브쿼리 | 안쪽 질의가 바깥 행의 값(`e.dept_id`)을 참조한다. 개념상 바깥 행마다 안쪽을 다시 계산한다 |

옵티마이저는 서브쿼리를 조인으로 바꿔 실행하기도 한다. 같은 결과를 내는 조인 질의가 있으면 두 방식의 실행 계획을 비교한다(DB-STO-002-DO).

| 판단 | 권장 |
|---|---|
| 존재 여부만 필요하다 | `EXISTS` |
| 다른 테이블의 열 값도 필요하다 | `JOIN` |
| 집계값과 비교한다 | 스칼라 서브쿼리 |

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 스칼라 서브쿼리 | 행 하나, 열 하나를 반환하는 서브쿼리 |
| 파생 테이블(derived table) | `FROM` 절에 쓴 서브쿼리가 만든 임시 표 |
| 상관(correlated) | 안쪽 질의가 바깥 질의의 열을 참조하는 관계 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 서브쿼리로 푼 질의를 조인으로 바꿔 쓰고 두 결과가 같은지 확인해 보자.
- [ ] `NOT IN`이 빈 결과를 내는 이유를 NULL과 연결해 설명해 보자.
- [ ] 상관 서브쿼리가 행이 많은 테이블에서 느려지는 이유를 추측해 적어 보자.
