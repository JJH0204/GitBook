# 테이블 생성·입력·조회·수정·삭제 실습

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-SQL-006-MP |
| 목적 | 연습용 데이터베이스에 테이블을 만들고 행을 입력, 조회, 수정, 삭제한 뒤 정리한다 |
| 적용 대상 | MariaDB 10.x 이상 (MySQL 호환 문법), 스토리지 엔진 InnoDB |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 페이지의 예제를 단계별 절차로 재구성한 것이며 DB에서 실행해 확인하지 않았다. 아래 "→ 결과"는 예상 출력이다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 원본 DDL, DML 페이지의 예제를 하나의 실습 절차로 새로 구성했다. 문법 설명은 DB-SQL-002-REF, DB-SQL-003-REF를 따른다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [데이터 정의어 (DDL)](sql_ddl.md) | DB-SQL-002-REF | DDL 문법 |
| [데이터 조작어 (DML)](sql_dml.md) | DB-SQL-003-REF | DML 문법 |
| [MariaDB 기본 사용법](../operations/mariadb.md) | | 접속 방법 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | MariaDB 서버 | 10.x 이상 | 연습용 서버를 쓴다. 운영 서버를 쓰지 않는다 |
| 2 | MariaDB 클라이언트 | `mariadb` 또는 `mysql` 명령 | |
| 3 | 계정 | `CREATE`, `DROP`, `INSERT`, `UPDATE`, `DELETE`, `SELECT` 권한이 있는 `<사용자명>` | 비밀번호는 `<비밀번호>` |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 이 실습은 `amm_practice`라는 새 데이터베이스만 쓰고 마지막에 삭제한다. 같은 이름의 데이터베이스가 이미 있으면 실습하지 않는다. 구역 A의 1단계로 먼저 확인한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 클라이언트로 서버에 접속한다: `mariadb -u <사용자명> -p` | 비밀번호 `<비밀번호>`를 입력하면 `MariaDB [(none)]>` 프롬프트가 나타난다 |
| 2 | 스토리지 엔진을 확인한다: `SHOW ENGINES;` | `InnoDB`의 `Support`가 `DEFAULT` 또는 `YES`다 |

## 5. 절차

### A. 연습용 데이터베이스 생성

1. (5-A-01) 같은 이름의 데이터베이스가 없는지 확인한다: `SHOW DATABASES LIKE 'amm_practice';` → 결과: `Empty set`이 나온다. 행이 나오면 실습을 중단한다.
2. (5-A-02) 데이터베이스를 만든다: `CREATE DATABASE amm_practice;` → 결과: `Query OK, 1 row affected`.
3. (5-A-03) 데이터베이스를 선택한다: `USE amm_practice;` → 결과: `Database changed`.

### B. 테이블 생성 (CREATE)

1. (5-B-01) 테이블을 만든다.

```sql
CREATE TABLE Customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    age INT,
    city VARCHAR(50)
);
```
→ 결과: `Query OK, 0 rows affected`.

2. (5-B-02) 구조를 확인한다: `DESCRIBE Customers;` → 결과: `id`, `name`, `age`, `city` 4개 컬럼이 보이고 `id`의 Key가 `PRI`, Extra가 `auto_increment`다.

### C. 데이터 입력 (INSERT)

1. (5-C-01) 행 3개를 입력한다.

```sql
INSERT INTO Customers (name, age, city)
VALUES ('홍길동', 25, '서울'), ('김철수', 30, '부산'), ('이영희', 28, '대구');
```
→ 결과: `Query OK, 3 rows affected`, `Records: 3  Duplicates: 0  Warnings: 0`.

2. (5-C-02) 컬럼 일부만 입력한다: `INSERT INTO Customers (name) VALUES ('박민수');` → 결과: `Query OK, 1 row affected`. `age`와 `city`는 `NULL`이 된다.

### D. 데이터 조회 (SELECT)

1. (5-D-01) 전체를 조회한다: `SELECT * FROM Customers;` → 결과: 4행이 나온다. `id`는 1~4다.
2. (5-D-02) 조건으로 조회한다: `SELECT name, age FROM Customers WHERE age >= 28;` → 결과: `김철수 30`, `이영희 28` 2행이 나온다. `age`가 `NULL`인 박민수는 나오지 않는다.

### E. 테이블 구조 변경 (ALTER)

1. (5-E-01) 컬럼을 추가한다: `ALTER TABLE Customers ADD email VARCHAR(100);` → 결과: `Query OK`. 기존 행의 `email`은 `NULL`이다.
2. (5-E-02) 데이터 타입을 바꾼다: `ALTER TABLE Customers MODIFY COLUMN age SMALLINT;` → 결과: `Query OK`.
3. (5-E-03) 변경을 확인한다: `DESCRIBE Customers;` → 결과: `email`이 `varchar(100)`, `age`가 `smallint(6)`으로 보인다. 표시 형식은 버전에 따라 다를 수 있다.

### F. 데이터 수정 (UPDATE)

{% hint style="danger" %}
WARNING: `UPDATE`에 `WHERE`를 빼면 모든 행이 바뀐다. 5-F-01에서 대상 행을 먼저 확인한 뒤 같은 조건으로 실행한다.
{% endhint %}

1. (5-F-01) 수정할 행을 확인한다: `SELECT * FROM Customers WHERE name = '홍길동';` → 결과: 1행이 나오고 `age`가 25다.
2. (5-F-02) 같은 조건으로 수정한다: `UPDATE Customers SET age = 26 WHERE name = '홍길동';` → 결과: `Rows matched: 1  Changed: 1  Warnings: 0`.
3. (5-F-03) 결과를 확인한다: `SELECT name, age FROM Customers WHERE name = '홍길동';` → 결과: `age`가 26이다.

### G. 데이터 삭제 (DELETE)

{% hint style="danger" %}
WARNING: `DELETE`에 `WHERE`를 빼면 모든 행이 삭제된다. 기본 설정(`autocommit=1`)에서는 실행 즉시 확정되어 되돌릴 수 없다. 5-G-01에서 대상 행을 먼저 확인한다. 되돌릴 수 있게 연습하려면 DB-SQL-007-MP의 트랜잭션 절차를 먼저 따른다.
{% endhint %}

1. (5-G-01) 삭제할 행을 확인한다: `SELECT * FROM Customers WHERE name = '박민수';` → 결과: 1행이 나온다.
2. (5-G-02) 같은 조건으로 삭제한다: `DELETE FROM Customers WHERE name = '박민수';` → 결과: `Query OK, 1 row affected`.
3. (5-G-03) 결과를 확인한다: `SELECT COUNT(*) FROM Customers;` → 결과: `3`이다.

### H. 정리 (DROP)

{% hint style="danger" %}
WARNING: `DROP DATABASE`는 데이터베이스 안의 모든 객체를 복구 없이 삭제한다. 5-H-01에서 `amm_practice`를 선택한 상태인지 확인하고, 데이터베이스 이름을 정확히 입력한다.
{% endhint %}

1. (5-H-01) 현재 데이터베이스를 확인한다: `SELECT DATABASE();` → 결과: `amm_practice`다.
2. (5-H-02) 테이블을 삭제한다: `DROP TABLE Customers;` → 결과: `Query OK, 0 rows affected`.
3. (5-H-03) 데이터베이스를 삭제한다: `DROP DATABASE amm_practice;` → 결과: `Query OK, 0 rows affected`.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 5-D-01 직후 `SELECT COUNT(*) FROM Customers;` | 4 | 입력한 행 수와 같다 |
| 2 | 5-F-03 | `age`가 26 | 수정한 값이 보인다 |
| 3 | 5-G-03 | 3 | 삭제한 행 수만큼 줄었다 |
| 4 | `SHOW DATABASES LIKE 'amm_practice';` (구역 H 후) | `Empty set` | 연습용 데이터베이스가 없다 |

## 7. 복구

1. (7-01) 중간에 중단했다면 `SELECT DATABASE();`로 현재 위치를 확인한다.
2. (7-02) 연습용 데이터베이스만 지운다: `DROP DATABASE IF EXISTS amm_practice;` → 결과: `Query OK`. 다른 데이터베이스는 건드리지 않는다.
3. (7-03) 삭제한 행과 변경한 구조는 복구되지 않는다. 구역 A부터 다시 수행한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `sql_ddl.md`, `sql_dml.md`의 예제를 단계별 실습으로 새로 작성했다. `AUTO_INCREMENT`를 추가했고 `WHERE` 없는 `UPDATE`·`DELETE` 예시는 제외했다 |
