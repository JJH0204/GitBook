# [생성형 AI] NULL 처리 규칙

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-SQL-012-REF |
| 유형 | REF (규칙 표) |
| 목적 | NULL이 비교, 논리 연산, 집계, 집합 조건에서 어떻게 동작하는지 찾아 본다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (SQLite 3.46.1, Python sqlite3, 2026-11-19에서 이 문서의 질의를 실행해 결과를 확인했다. MariaDB에서는 실행하지 않았다). 함수 이름 중 COALESCE는 SQL 표준이고 IFNULL은 MariaDB와 SQLite가 지원한다 |
| 개정 | R1 (2026-11-19) |

## 1. NULL이란

NULL은 값이 없거나 모른다는 표시다. 0이나 빈 문자열과 다르다. 비교 결과는 참(TRUE), 거짓(FALSE), 알 수 없음(UNKNOWN) 세 가지다(3값 논리). `WHERE`는 참인 행만 남긴다.

## 2. 비교와 논리 연산

| 식 | 결과 | 설명 |
|---|---|---|
| `NULL = NULL` | NULL(알 수 없음) | 같은지 모른다 |
| `NULL IS NULL` | 참 | NULL 검사는 `IS NULL`로 한다 |
| `1 <> NULL` | NULL | |
| `NULL OR 1` | 참 | 한쪽이 참이면 참이다 |
| `NULL AND 0` | 거짓 | 한쪽이 거짓이면 거짓이다 |
| `NULL AND 1` | NULL | |
| `1 IN (2, NULL)` | NULL | 같은 값이 없고 NULL이 있어 알 수 없다 |

## 3. 질의에서의 영향

예제는 `emp`에 4행이 있고 `D`의 `dept_id`만 NULL인 데이터다(DB-SQL-009-DO).

| 질의 | 결과 | 주의 |
|---|---|---|
| `WHERE dept_id = NULL` | 0행 | 항상 알 수 없음이라 걸리지 않는다 |
| `WHERE dept_id IS NULL` | D | 올바른 검사 |
| `WHERE dept_id <> 1` | C | D는 NULL이라 빠진다. D를 포함하려면 `OR dept_id IS NULL`을 더한다 |
| `COUNT(*)`, `COUNT(dept_id)` | 4, 3 | `COUNT(<열>)`은 NULL을 세지 않는다 |
| `AVG(dept_id)` | 1.333... | NULL 행은 분모에서도 제외된다. 값 1, 1, 2의 평균이다 |
| `COALESCE(dept_id, 0)` | D는 0 | 첫 번째 NULL 아닌 값을 돌려준다 |

## 4. 주의

{% hint style="danger" %}
WARNING: `NOT IN` 목록에 NULL이 들어 있으면 결과가 항상 비어 있다. 서브쿼리에는 `NOT EXISTS`를 쓴다(DB-SQL-010-DO).
{% endhint %}

{% hint style="info" %}
NOTE: `GROUP BY`와 `DISTINCT`는 NULL끼리 같은 그룹으로 묶는다. `=` 비교와 규칙이 다르다. `UNIQUE` 제약에서 NULL 여러 개를 허용하는지는 DBMS에 따라 다르니 문서를 확인한다.
{% endhint %}

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [서브쿼리](sql_subquery.md) | DB-SQL-010-DO | NOT IN과 NULL |
| [데이터 무결성 규정 (Integrity)](../relational-model/integrity.md) | DB-REL-001-DO | `NOT NULL` 제약 |
