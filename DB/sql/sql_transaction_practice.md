# 트랜잭션 COMMIT·ROLLBACK·SAVEPOINT 실습

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-SQL-007-MP |
| 목적 | 트랜잭션 안에서 변경을 확정(COMMIT)하거나 취소(ROLLBACK, SAVEPOINT)하고, DDL의 암묵적 커밋을 확인한다 |
| 적용 대상 | MariaDB 10.x 이상, 스토리지 엔진 InnoDB |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 페이지의 예제를 단계별 절차로 재구성한 것이며 DB에서 실행해 확인하지 않았다. 아래 "→ 결과"는 예상 출력이다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [트랜잭션 제어 언어 (TCL)](sql_tcl.md) | DB-SQL-005-REF | TCL 문법 |
| [데이터 정의어 (DDL)](sql_ddl.md) | DB-SQL-002-REF | 암묵적 커밋 |
| [테이블 생성·입력·조회·수정·삭제 실습](sql_table_practice.md) | DB-SQL-006-MP | 선행 실습 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | MariaDB 서버와 클라이언트 | 10.x 이상 | 연습용 서버를 쓴다 |
| 2 | 계정 | `CREATE`, `DROP`, `INSERT`, `SELECT` 권한이 있는 `<사용자명>` | 비밀번호는 `<비밀번호>` |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 이 실습은 `amm_tx_practice` 데이터베이스만 쓰고 마지막에 삭제한다. 같은 이름의 데이터베이스가 이미 있으면 실습하지 않는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `autocommit=1`(기본값)에서 `START TRANSACTION` 없이 실행한 문장은 즉시 확정된다. 이 실습의 모든 DML은 `START TRANSACTION;` 뒤에 실행한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 서버에 접속한다: `mariadb -u <사용자명> -p` | `MariaDB [(none)]>` 프롬프트가 나타난다 |
| 2 | 같은 이름의 데이터베이스가 없는지 확인한다: `SHOW DATABASES LIKE 'amm_tx_practice';` | `Empty set`이다 |

## 5. 절차

### A. 연습 환경 생성

1. (5-A-01) 데이터베이스를 만들고 선택한다: `CREATE DATABASE amm_tx_practice;` 후 `USE amm_tx_practice;` → 결과: `Database changed`.
2. (5-A-02) 테이블을 만든다: `CREATE TABLE Customers (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50) NOT NULL, age INT) ENGINE=InnoDB;` → 결과: `Query OK`.
3. (5-A-03) 자동 커밋 상태를 확인한다: `SELECT @@autocommit;` → 결과: `1`이다.

### B. ROLLBACK으로 취소

1. (5-B-01) 트랜잭션을 시작한다: `START TRANSACTION;` → 결과: `Query OK`.
2. (5-B-02) 행을 입력한다: `INSERT INTO Customers (name, age) VALUES ('김철수', 30);` → 결과: `1 row affected`.
3. (5-B-03) 같은 세션에서 조회한다: `SELECT * FROM Customers;` → 결과: 김철수 1행이 보인다.

{% hint style="danger" %}
WARNING: `ROLLBACK`은 트랜잭션 시작 이후의 미확정 변경을 모두 버린다. 5-B-03에서 취소할 내용이 맞는지 확인한 뒤 실행한다.
{% endhint %}

4. (5-B-04) 취소한다: `ROLLBACK;` → 결과: `Query OK`.
5. (5-B-05) 조회한다: `SELECT * FROM Customers;` → 결과: `Empty set`. 입력이 취소됐다.

### C. COMMIT으로 확정

1. (5-C-01) 트랜잭션을 시작하고 입력한다: `START TRANSACTION;` 후 `INSERT INTO Customers (name, age) VALUES ('홍길동', 25);` → 결과: `1 row affected`.

{% hint style="danger" %}
WARNING: `COMMIT` 뒤에는 `ROLLBACK`으로 되돌릴 수 없다. 5-C-02에서 확정할 내용을 확인한다.
{% endhint %}

2. (5-C-02) 확정 전 상태를 확인한다: `SELECT * FROM Customers;` → 결과: 홍길동 1행이 보인다.
3. (5-C-03) 확정한다: `COMMIT;` → 결과: `Query OK`.
4. (5-C-04) 취소를 시도한다: `ROLLBACK;` 후 `SELECT * FROM Customers;` → 결과: 홍길동 1행이 그대로 남아 있다.

### D. SAVEPOINT로 일부만 취소

1. (5-D-01) 트랜잭션을 시작하고 입력한다: `START TRANSACTION;` 후 `INSERT INTO Customers (name, age) VALUES ('이영희', 28);` → 결과: `1 row affected`.
2. (5-D-02) 저장점을 만든다: `SAVEPOINT sp1;` → 결과: `Query OK`.
3. (5-D-03) 행을 하나 더 입력한다: `INSERT INTO Customers (name, age) VALUES ('박민수', 35);` → 결과: `1 row affected`.
4. (5-D-04) 저장점까지 취소한다: `ROLLBACK TO sp1;` → 결과: `Query OK`.
5. (5-D-05) 조회한다: `SELECT name FROM Customers;` → 결과: `홍길동`, `이영희` 2행이다. 박민수는 취소됐다.
6. (5-D-06) 확정한다: `COMMIT;` → 결과: `Query OK`. `ROLLBACK TO`는 트랜잭션을 끝내지 않으므로 확정이 필요하다.

### E. DDL의 암묵적 커밋 확인

{% hint style="warning" %}
CAUTION: 이 구역의 5-E-02는 DDL을 트랜잭션 안에서 실행한다. DDL이 앞선 변경을 자동으로 확정하는 것을 확인하는 단계이며, 실제 작업에서는 이렇게 쓰지 않는다.
{% endhint %}

1. (5-E-01) 트랜잭션을 시작하고 입력한다: `START TRANSACTION;` 후 `INSERT INTO Customers (name, age) VALUES ('최지우', 40);` → 결과: `1 row affected`.
2. (5-E-02) DDL을 실행한다: `CREATE TABLE tmp_check (id INT);` → 결과: `Query OK`. 암묵적 커밋이 일어난다.
3. (5-E-03) 취소를 시도한다: `ROLLBACK;` → 결과: `Query OK`.
4. (5-E-04) 조회한다: `SELECT name FROM Customers;` → 결과: `최지우`가 남아 있다. DDL 때문에 이미 확정됐다.

### F. 정리

{% hint style="danger" %}
WARNING: `DROP DATABASE`는 안의 모든 객체를 복구 없이 삭제한다. `SELECT DATABASE();`가 `amm_tx_practice`인지 확인한 뒤 실행한다.
{% endhint %}

1. (5-F-01) 현재 데이터베이스를 확인한다: `SELECT DATABASE();` → 결과: `amm_tx_practice`다.
2. (5-F-02) 삭제한다: `DROP DATABASE amm_tx_practice;` → 결과: `Query OK`.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 5-B-05 | `Empty set` | `ROLLBACK`이 입력을 취소했다 |
| 2 | 5-C-04 | 홍길동 1행 유지 | `COMMIT` 뒤 `ROLLBACK`이 효과가 없다 |
| 3 | 5-D-05 | 홍길동, 이영희 2행 | 저장점 이후 입력만 취소됐다 |
| 4 | 5-E-04 | 최지우 행 유지 | DDL 뒤 `ROLLBACK`이 효과가 없다 |

## 7. 복구

1. (7-01) 트랜잭션이 열려 있는 채로 중단했다면 `ROLLBACK;`을 실행한다.
2. (7-02) 연습용 데이터베이스만 지운다: `DROP DATABASE IF EXISTS amm_tx_practice;` → 결과: `Query OK`.
3. (7-03) 확정된 변경은 되돌릴 수 없다. 구역 A부터 다시 수행한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `sql_tcl.md`, `sql_dml.md`의 COMMIT, ROLLBACK, SAVEPOINT 예제를 단계별 실습으로 새로 작성했다. `START TRANSACTION`과 DDL 암묵적 커밋 확인 단계를 추가했다 |
