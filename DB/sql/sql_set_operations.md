# [생성형 AI] 집합 연산 (UNION, INTERSECT, EXCEPT)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-SQL-014-REF |
| 유형 | REF (표) |
| 목적 | 두 `SELECT` 결과를 집합으로 합치거나 비교하는 연산자의 동작과 규칙을 찾는다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 부분 검증 (SQLite 3.46.1, Python sqlite3, 2026-11-19에서 아래 결과를 실행해 확인했다. MariaDB는 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 1. 연산자 표

예제 테이블: `a(x)`는 1, 2, 2, 3 / `b(x)`는 2, 3, 4를 가진다.

| 연산자 | 의미 | 중복 | 예제 결과 (`SELECT x FROM a <연산자> SELECT x FROM b`) |
|---|---|---|---|
| `UNION` | 합집합 | 제거 | 1, 2, 3, 4 |
| `UNION ALL` | 합집합 | 유지 | 1, 2, 2, 2, 3, 3, 4 (7행) |
| `INTERSECT` | 교집합 | 제거 | 2, 3 |
| `EXCEPT` | 차집합 (왼쪽에서 오른쪽을 뺌) | 제거 | 1 |

## 2. 규칙

| 규칙 | 내용 |
|---|---|
| 열 개수 | 두 `SELECT`의 열 개수가 같아야 한다 |
| 열 타입 | 같은 위치의 열은 서로 호환되는 타입이어야 한다 |
| 열 이름 | 결과의 열 이름은 첫 번째 `SELECT`를 따른다 |
| 정렬 | `ORDER BY`는 전체 문장 맨 끝에 한 번만 쓴다 |
| 성능 | `UNION`은 중복을 제거하느라 정렬 또는 해시 작업이 든다. 중복이 없다고 알면 `UNION ALL`을 쓴다 |

{% hint style="warning" %}
CAUTION: MariaDB는 `INTERSECT`와 `EXCEPT`를 10.3부터 지원하는 것으로 알려져 있다(미확인). 사용할 DBMS의 버전을 문서로 확인한다.
{% endhint %}

## 3. 같은 결과를 내는 다른 표현

| 집합 연산 | 대체 표현 |
|---|---|
| `INTERSECT` | `WHERE x IN (SELECT ...)` 또는 `EXISTS` (DB-SQL-010-DO) |
| `EXCEPT` | `WHERE NOT EXISTS (...)` 또는 `LEFT JOIN ... WHERE 오른쪽 키 IS NULL` (DB-SQL-009-DO) |

## 4. 참조

| 문서 | Task ID |
|---|---|
| [조인 종류와 결과 비교](sql_join_types.md) | DB-SQL-009-DO |
| [서브쿼리](sql_subquery.md) | DB-SQL-010-DO |
| [NULL 처리 규칙](sql_null.md) | DB-SQL-012-REF |
