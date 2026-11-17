# 데이터 정의어 (DDL)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-SQL-002-REF |
| 유형 | REF (문법 표) |
| 목적 | DDL 명령(CREATE, ALTER, DROP, TRUNCATE)의 문법과 동작 차이를 참조한다 |
| 확인 상태 | 미검증 (원본 페이지와 MariaDB/MySQL 문서 지식을 정리한 것이며 DB에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. DDL이란

DDL(Data Definition Language, 데이터 정의어)은 테이블, 인덱스, 뷰, 데이터베이스 같은 객체의 구조를 만들고 바꾸고 지우는 SQL 명령이다. 데이터 자체가 아니라 데이터를 담는 구조를 다룬다.

## 2. 명령 표

| 명령 | 용도 | 문법 | 비고 |
|---|---|---|---|
| `CREATE TABLE` | 테이블을 만든다 | `CREATE TABLE <테이블명> (<컬럼명> <데이터 타입> [제약 조건], ...);` | 이미 있으면 오류. `IF NOT EXISTS`로 오류를 피한다 |
| `CREATE DATABASE` | 데이터베이스를 만든다 | `CREATE DATABASE <데이터베이스명>;` | |
| `CREATE INDEX` | 인덱스를 만든다 | `CREATE INDEX <인덱스명> ON <테이블명> (<컬럼명>);` | |
| `CREATE VIEW` | 뷰를 만든다 | `CREATE VIEW <뷰명> AS SELECT ...;` | |
| `ALTER TABLE ... ADD` | 컬럼을 추가한다 | `ALTER TABLE <테이블명> ADD <컬럼명> <데이터 타입>;` | |
| `ALTER TABLE ... DROP COLUMN` | 컬럼을 삭제한다 | `ALTER TABLE <테이블명> DROP COLUMN <컬럼명>;` | 컬럼의 데이터도 함께 사라진다 |
| `ALTER TABLE ... MODIFY COLUMN` | 컬럼의 데이터 타입을 바꾼다 | `ALTER TABLE <테이블명> MODIFY COLUMN <컬럼명> <새 데이터 타입>;` | MySQL/MariaDB 문법이다. 표준 SQL과 Oracle 등은 문법이 다르다 |
| `DROP TABLE` | 테이블을 삭제한다 | `DROP TABLE <테이블명>;` | 구조와 데이터가 모두 사라진다 |
| `DROP DATABASE` | 데이터베이스를 삭제한다 | `DROP DATABASE <데이터베이스명>;` | 안의 모든 객체가 사라진다 |
| `DROP INDEX` | 인덱스를 삭제한다 | `DROP INDEX <인덱스명> ON <테이블명>;` | MySQL/MariaDB는 `ON <테이블명>`이 필요하다 |
| `DROP VIEW` | 뷰를 삭제한다 | `DROP VIEW <뷰명>;` | |
| `TRUNCATE TABLE` | 테이블의 모든 행을 삭제한다 | `TRUNCATE TABLE <테이블명>;` | 구조는 남는다 |

{% hint style="info" %}
NOTE: 원본은 `DROP INDEX 인덱스명;`으로 적었다. MySQL/MariaDB에서는 `ON <테이블명>`이 필요해 정정했다. `MODIFY COLUMN`은 MySQL/MariaDB 전용 문법이라는 설명도 추가했다. 미검증이다.
{% endhint %}

{% hint style="danger" %}
WARNING: `DROP TABLE`, `DROP DATABASE`, `TRUNCATE TABLE`은 데이터를 복구할 수 없게 지운다. 실행 전에 백업하고, 대상 이름을 한 번 더 확인한다. 안전한 연습 절차는 DB-SQL-006-MP를 따른다.
{% endhint %}

## 3. 사용 예

| 목적 | 명령 |
|---|---|
| Customers 테이블 생성 | `CREATE TABLE Customers (id INT PRIMARY KEY, name VARCHAR(50) NOT NULL, age INT, city VARCHAR(50));` |
| email 컬럼 추가 | `ALTER TABLE Customers ADD email VARCHAR(100);` |
| city 컬럼 삭제 | `ALTER TABLE Customers DROP COLUMN city;` |
| age 컬럼 타입 변경 | `ALTER TABLE Customers MODIFY COLUMN age SMALLINT;` |
| 테이블 삭제 | `DROP TABLE Customers;` |
| 모든 행 삭제 | `TRUNCATE TABLE Customers;` |

## 4. DROP, TRUNCATE, DELETE 비교

| 구분 | `DROP TABLE` | `TRUNCATE TABLE` | `DELETE` (DML) |
|---|---|---|---|
| 분류 | DDL | DDL | DML |
| 테이블 구조 | 삭제한다 | 유지한다 | 유지한다 |
| 행 삭제 범위 | 전부 | 전부 | `WHERE`로 지정한다. 생략하면 전부 |
| 롤백 | 불가 | 불가 | 트랜잭션 안에서 가능 |
| 속도 | | 대량 삭제에 빠르다 | 행마다 처리해 느리다 |

{% hint style="info" %}
NOTE: MariaDB/MySQL에서 `TRUNCATE`는 `AUTO_INCREMENT` 값도 초기화한다. 이 설명은 원본에 없던 내용이며 미검증이다.
{% endhint %}

## 5. DDL과 트랜잭션

{% hint style="warning" %}
CAUTION: MariaDB/MySQL에서 DDL은 암묵적 커밋(implicit commit)을 일으킨다. DDL을 실행하면 그 전까지 열려 있던 트랜잭션이 먼저 확정되고, DDL 자체도 확정된다. 이후 `ROLLBACK`으로 되돌릴 수 없다. Oracle도 DDL이 자동 커밋된다. PostgreSQL 등 일부 DBMS는 DDL을 트랜잭션에 넣을 수 있으므로 사용하는 DBMS의 문서를 확인한다.
{% endhint %}

## 6. DDL과 DML 비교

| 구분 | DDL | DML |
|---|---|---|
| 대상 | 객체의 구조 | 테이블 안의 데이터 |
| 주요 명령 | `CREATE`, `ALTER`, `DROP`, `TRUNCATE` | `SELECT`, `INSERT`, `UPDATE`, `DELETE` |
| 트랜잭션 | 자동 커밋(MariaDB/MySQL). 롤백 불가 | 트랜잭션 안에서 `COMMIT`, `ROLLBACK` 가능 |

{% hint style="info" %}
NOTE: 원본은 DDL의 트랜잭션을 "지원하지 않음"으로 적었다. 정확한 표현은 "자동 커밋되어 롤백할 수 없다"이다. 또 DML도 기본 설정(`autocommit=1`)에서는 문장마다 자동 확정된다. DB-SQL-005-REF를 참조한다. 미검증이다.
{% endhint %}

## 7. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [데이터 조작어 (DML)](sql_dml.md) | DB-SQL-003-REF | 데이터 조작 문법 |
| [트랜잭션 제어 언어 (TCL)](sql_tcl.md) | DB-SQL-005-REF | 커밋과 롤백 |
| [테이블 생성·입력·조회·수정·삭제 실습](sql_table_practice.md) | DB-SQL-006-MP | 실습 절차 |

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | REF 형식으로 재작성. `DROP INDEX` 문법, DDL 암묵적 커밋 설명을 정정했다. 실습은 DB-SQL-006-MP로 분리했다 |
