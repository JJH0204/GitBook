# 데이터베이스 실습 과제

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-ASG-001-DO |
| 유형 | D&O (개념) |
| 목적 | 조회 SQL의 정렬, 집합, 조인, 집계, 중복 제거와 웹 애플리케이션의 SQL 인젝션 점검 개념을 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 개념 정리다. 예시는 설명용으로 새로 만든 `employee`, `dept` 테이블을 쓴다. 명령 문법의 세부는 참조 절의 문서를 따른다.
{% endhint %}

## 1. 목적

관계형 데이터베이스에서 데이터를 조회하는 방법과, 같은 데이터베이스가 웹 애플리케이션을 통해 공격받는 원리를 정리한다. 다룬 주제는 다음과 같다.

1. 정렬, 조건 필터, 집합 연산(`UNION`).
2. 두 테이블을 잇는 조인(`INNER`, `LEFT`, `RIGHT`).
3. 합계와 평균 같은 집계.
4. 윈도 함수로 중복 행 제거.
5. 취약한 웹 애플리케이션에서 SQL 인젝션을 찾는 흐름.
6. 사용자별 접근 범위 제한(권한).

## 2. 구성 요소

### 2.1 예시 테이블

| 테이블 | 열 | 설명 |
|---|---|---|
| `dept` | `dept_id`(기본 키), `dept_name` | 부서 |
| `employee` | `emp_id`(기본 키), `emp_name`, `dept_id`, `age`, `salary` | 직원. `dept_id`는 `dept`를 참조한다 |

### 2.2 조회 SQL 요소

| 번호 | 요소 | 역할 |
|---|---|---|
| 1 | `ORDER BY <열> [ASC\|DESC]` | 결과를 정렬한다. 생략하면 `ASC`(오름차순)다 |
| 2 | `WHERE <조건>` | 조건에 맞는 행만 남긴다. 정렬과 같이 쓰면 `WHERE`가 먼저 적용된다 |
| 3 | `UNION`, `UNION ALL` | 두 `SELECT` 결과를 위아래로 합친다 |
| 4 | `INNER JOIN` | 양쪽에 모두 일치하는 행만 남긴다 |
| 5 | `LEFT JOIN`, `RIGHT JOIN` | 왼쪽 또는 오른쪽 테이블의 행을 모두 남기고, 짝이 없는 쪽은 `NULL`로 채운다 |
| 6 | `SUM`, `AVG`, `COUNT` | 열 전체를 하나의 값으로 집계한다. `GROUP BY`와 같이 쓰면 그룹별로 집계한다 |
| 7 | `ROW_NUMBER() OVER (PARTITION BY ...)` | 그룹 안에서 행에 순번을 붙이는 윈도 함수다 |

### 2.3 웹 점검 도구

| 번호 | 도구 | 역할 |
|---|---|---|
| 1 | `nmap` | 열린 포트와 서비스를 찾는 포트 스캐너다 |
| 2 | `dirb` | 단어 목록으로 웹 서버의 숨은 경로를 찾는다 |
| 3 | `nikto` | 웹 서버의 알려진 설정 결함과 노출 파일을 점검한다 |
| 4 | `sqlmap` | SQL 인젝션 취약점을 자동으로 탐지하고 분석한다 |
| 5 | ZAP(OWASP Zed Attack Proxy) | 브라우저와 서버 사이에서 요청을 가로채 점검하는 프록시다 |
| 6 | DVWA(Damn Vulnerable Web Application) | 일부러 취약하게 만든 학습용 웹 애플리케이션이다 |

## 3. 동작 원리

### 3.1 정렬과 집합

* `ORDER BY age ASC`는 나이가 적은 행이 먼저, `ORDER BY salary DESC`는 급여가 많은 행이 먼저 나온다.
* `WHERE salary >= 3000 ORDER BY salary`는 급여 3000 이상인 행만 골라 오름차순으로 정렬한다.
* `UNION`은 두 결과의 열 개수가 같고 대응하는 열의 자료형이 호환될 때만 쓸 수 있다. 중복 행은 제거한다. 중복을 남기려면 `UNION ALL`을 쓴다.

```sql
SELECT emp_name FROM employee
UNION
SELECT dept_name FROM dept;
```

### 3.2 조인

세 조인은 짝이 없는 행의 처리가 다르다.

| 조인 | 짝 없는 왼쪽 행 | 짝 없는 오른쪽 행 |
|---|---|---|
| `INNER JOIN` | 제외 | 제외 |
| `LEFT JOIN` | 포함(오른쪽 열 `NULL`) | 제외 |
| `RIGHT JOIN` | 제외 | 포함(왼쪽 열 `NULL`) |

```sql
SELECT e.emp_id, e.emp_name, d.dept_name
FROM employee e
LEFT JOIN dept d ON e.dept_id = d.dept_id;
```

* 조인 조건(`ON`)을 빠뜨리면 두 테이블의 모든 행 조합(카티전 곱)이 나온다.
* MariaDB와 MySQL은 `FULL OUTER JOIN`을 지원하지 않는다. `LEFT JOIN`과 `RIGHT JOIN` 결과를 `UNION`으로 합쳐 대신한다.

### 3.3 집계

* 전체 합계: `SELECT SUM(salary) FROM employee;`
* 전체 평균: `SELECT AVG(salary) FROM employee;`
* 한 행의 열끼리 더하는 것은 집계 함수가 아니라 산술식이다. 열 세 개의 평균은 `(a + b + c) / 3.0`으로 구한다. `3`으로 나누면 정수 나눗셈이 되는 DBMS가 있어 `3.0`을 쓴다.
* `NULL`이 있는 열은 `SUM`과 `AVG`가 `NULL` 행을 무시한다. 산술식에서는 `NULL`이 하나라도 있으면 결과가 `NULL`이다.

### 3.4 중복 행 제거

열 값이 같은 행 중 하나만 남기려면 윈도 함수로 순번을 붙이고 1번만 고른다.

```sql
WITH ranked AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY emp_id) AS rn
  FROM employee
)
SELECT * FROM ranked WHERE rn = 1;
```

* 윈도 함수와 `WITH`(공통 테이블 식)는 MariaDB 10.2 이상, MySQL 8.0 이상에서 지원한다.
* 단순히 값의 종류만 보려면 `SELECT DISTINCT <열>`이 더 짧다.
* `PARTITION BY` 안에서 어느 행을 남길지는 `ORDER BY`가 정한다.

### 3.5 SQL 인젝션 점검 흐름

SQL 인젝션은 사용자 입력이 SQL 문장의 일부로 해석될 때 생긴다. 학습용 환경(DVWA)에서 점검하는 흐름은 다음과 같다.

| 순서 | 단계 | 내용 |
|---|---|---|
| 1 | 정보 수집 | `nmap`으로 포트와 서비스, `dirb`로 숨은 경로, `nikto`로 노출 파일과 설정 결함을 찾는다 |
| 2 | 취약점 확인 | 입력란에 작은따옴표(`'`)를 넣고 SQL 문법 오류가 화면에 나오는지 본다. 오류가 나오면 입력이 SQL에 그대로 들어간다는 뜻이다 |
| 3 | 자동 분석 | `sqlmap`으로 취약한 매개변수와 DBMS 종류를 확인한다 |
| 4 | 결과 정리 | 확인된 취약점과 노출된 정보를 기록한다 |

* 오류 메시지가 화면에 노출되는 것 자체가 정보 노출 결함이다.
* `UNION`을 이용한 방식은 원래 쿼리와 열 개수를 맞춘 `UNION SELECT`를 덧붙여 다른 테이블의 값을 응답에 섞는다. 3.1절의 `UNION` 조건이 그대로 적용된다.
* 서버에 보관된 문서나 설정 파일에 기본 계정 정보가 노출되는 경우가 있다. 기본 계정은 설치 직후 바꾼다.

{% hint style="danger" %}
WARNING: `nmap`, `dirb`, `nikto`, `sqlmap`, ZAP은 허가받지 않은 시스템에 사용하면 불법이다. 본인이 소유하거나 서면으로 허가받은 실습 환경에서만 사용한다.
{% endhint %}

방어 방법은 다음과 같다.

| 방어 | 내용 |
|---|---|
| 매개변수화된 쿼리(prepared statement) | 입력을 값으로만 처리해 SQL 구조를 바꾸지 못하게 한다 |
| 최소 권한 | 웹 애플리케이션의 DB 계정에 필요한 테이블의 필요한 권한만 준다 |
| 오류 메시지 숨김 | 운영 환경에서는 SQL 오류를 화면에 출력하지 않는다 |
| 입력 검증 | 길이와 형식을 서버에서 검증한다 |

### 3.6 사용자별 접근 범위 제한

권한은 부여 범위를 좁게 잡는 것이 원칙이다. 범위는 `*.*`(전체), `<DB명>.*`(한 DB), `<DB명>.<테이블>`(한 테이블) 순으로 좁아진다.

| 요구 | 부여할 권한과 범위 |
|---|---|
| 자기 이름과 같은 DB에서만 모든 작업 | `<DB명>.*`에 `ALL PRIVILEGES` |
| 다른 DB는 조회만 | 해당 DB에 `SELECT` |
| 특정 테이블의 구조 변경만 | 해당 테이블에 `CREATE`, `DROP` 등 필요한 권한만 |
| 일시적 사용 계정 | 사용 후 `DROP USER`로 삭제 |

* 다른 사용자가 어떤 DB에도 접속하지 못하게 하려면 그 DB에 대한 권한을 주지 않는다. 권한이 없는 사용자는 해당 DB를 볼 수 없다.
* `SELECT` 권한이 있으면 보통 `DESC <테이블>`로 열 구조를 볼 수 있다.
* `GRANT`, `REVOKE`, `DROP USER`의 단계별 절차와 경고는 [데이터 제어어 (DCL)](../sql/sql_dcl.md)와 [DB 성능 튜닝 및 사용자 관리](../operations/dbperformanceinfo.md)를 따른다.

## 4. 약어와 용어

| 용어 | 뜻 |
|---|---|
| 기본 키(Primary Key) | 행을 유일하게 식별하는 열이다 |
| 외래 키(Foreign Key) | 다른 테이블의 기본 키를 참조하는 열이다 |
| 카티전 곱(Cartesian product) | 두 테이블의 모든 행 조합이다 |
| CTE(Common Table Expression) | `WITH`로 이름 붙인 임시 결과 집합이다 |
| 윈도 함수 | 행을 합치지 않고 그룹 안에서 계산하는 함수다 |
| SQL 인젝션 | 입력값으로 SQL 문장의 구조를 바꾸는 공격이다 |
| DVWA | 학습용 취약 웹 애플리케이션이다 |
| 최소 권한 원칙 | 작업에 필요한 최소한의 권한만 부여하는 원칙이다 |

## 5. 참조

| 참조 문서 | 제목 |
|---|---|
| [sql_dml.md](../sql/sql_dml.md) | 데이터 조작어 (DML) |
| [sql_dcl.md](../sql/sql_dcl.md) | 데이터 제어어 (DCL) |
| [mariadb.md](../operations/mariadb.md) | MariaDB 기본 사용법 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `LEFT JOIN`과 `INNER JOIN`의 결과가 달라지는 경우를 내가 겪은 예로 설명한다.
- [ ] 입력값이 SQL에 그대로 들어가면 왜 위험한지 내 말로 설명한다.
- [ ] 계정에 `*.*` 대신 `<DB명>.*` 범위로 권한을 주는 이유를 설명한다.
