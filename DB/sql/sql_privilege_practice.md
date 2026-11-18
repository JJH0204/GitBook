# 사용자 권한 부여·회수 실습

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-SQL-008-MP |
| 목적 | 연습용 사용자에게 테이블 권한을 부여하고 회수하면서 허용·거부 동작을 확인한다 |
| 적용 대상 | MariaDB 10.x 이상. 사용자 생성과 권한 부여 권한이 있는 관리자 계정 필요 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 페이지의 예제를 단계별 절차로 재구성한 것이며 DB에서 실행해 확인하지 않았다. 아래 "→ 결과"는 예상 출력이다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [데이터 제어어 (DCL)](sql_dcl.md) | DB-SQL-004-REF | GRANT, REVOKE 문법 |
| [DB 성능 튜닝 및 사용자 관리](../operations/dbperformanceinfo.md) | | 사용자 관리 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | MariaDB 서버와 클라이언트 | 10.x 이상 | 연습용 서버를 쓴다 |
| 2 | 관리자 계정 | `CREATE USER`, `GRANT OPTION`, `CREATE`, `DROP` 권한 | `<관리자명>`, 비밀번호 `<관리자 비밀번호>` |
| 3 | 연습용 계정 | 이 실습에서 새로 만든다 | `<사용자명>`, 비밀번호 `<비밀번호>`. 기존 계정 이름을 쓰지 않는다 |
| 4 | 터미널 2개 | 관리자 세션, 연습용 사용자 세션 | |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `GRANT ALL PRIVILEGES`와 `*.*` 범위의 권한 부여는 쓰지 않는다. 이 실습은 `amm_priv_practice.Customers` 테이블 하나에 필요한 권한만 부여한다.
{% endhint %}

{% hint style="danger" %}
WARNING: `<사용자명>`은 이 실습에서 새로 만드는 계정이어야 한다. 기존 계정과 이름이 같으면 `CREATE USER`가 실패하거나, 이후 `DROP USER`로 기존 계정을 지우게 된다. 5-A-01에서 먼저 확인한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 관리자 세션에 접속한다: `mariadb -u <관리자명> -p` | 프롬프트가 나타난다 |
| 2 | 비밀번호는 실습용 임시 값을 쓴다 | 실제 서비스 비밀번호와 다르다 |

## 5. 절차

### A. 연습 환경 생성 (관리자 세션)

1. (5-A-01) 같은 이름의 사용자가 없는지 확인한다: `SELECT User, Host FROM mysql.user WHERE User = '<사용자명>';` → 결과: `Empty set`이다. 행이 나오면 다른 이름을 쓴다.
2. (5-A-02) 데이터베이스를 만든다: `CREATE DATABASE amm_priv_practice;` → 결과: `Query OK`.
3. (5-A-03) 테이블을 만든다: `CREATE TABLE amm_priv_practice.Customers (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50) NOT NULL);` → 결과: `Query OK`.
4. (5-A-04) 행을 입력한다: `INSERT INTO amm_priv_practice.Customers (name) VALUES ('홍길동');` → 결과: `1 row affected`.
5. (5-A-05) 연습용 사용자를 만든다: `CREATE USER '<사용자명>'@'localhost' IDENTIFIED BY '<비밀번호>';` → 결과: `Query OK`.

### B. 권한 부여 (GRANT, 관리자 세션)

1. (5-B-01) 권한 없는 상태를 확인한다: `SHOW GRANTS FOR '<사용자명>'@'localhost';` → 결과: `GRANT USAGE ON *.* ...` 한 줄만 보인다.
2. (5-B-02) 조회와 입력 권한을 부여한다: `GRANT SELECT, INSERT ON amm_priv_practice.Customers TO '<사용자명>'@'localhost';` → 결과: `Query OK`.
3. (5-B-03) 확인한다: `SHOW GRANTS FOR '<사용자명>'@'localhost';` → 결과: `GRANT SELECT, INSERT ON amm_priv_practice.Customers ...` 줄이 추가된다.

### C. 권한 동작 확인 (사용자 세션)

1. (5-C-01) 다른 터미널에서 접속한다: `mariadb -u <사용자명> -p` → 결과: 비밀번호 `<비밀번호>`로 접속된다.
2. (5-C-02) 조회한다: `SELECT * FROM amm_priv_practice.Customers;` → 결과: 홍길동 1행이 나온다.
3. (5-C-03) 입력한다: `INSERT INTO amm_priv_practice.Customers (name) VALUES ('김철수');` → 결과: `1 row affected`.
4. (5-C-04) 허용하지 않은 권한을 시도한다: `UPDATE amm_priv_practice.Customers SET name = '이영희' WHERE id = 1;` → 결과: `ERROR 1142 (42000): UPDATE command denied to user ...`.

### D. 권한 회수 (REVOKE, 관리자 세션)

{% hint style="danger" %}
WARNING: `REVOKE`는 사용자의 작업을 즉시 막는다. 실행 전에 5-B-03의 `SHOW GRANTS` 결과를 기록해 두면 같은 권한을 다시 부여할 수 있다.
{% endhint %}

1. (5-D-01) 입력 권한을 회수한다: `REVOKE INSERT ON amm_priv_practice.Customers FROM '<사용자명>'@'localhost';` → 결과: `Query OK`.
2. (5-D-02) 확인한다: `SHOW GRANTS FOR '<사용자명>'@'localhost';` → 결과: `GRANT SELECT ON amm_priv_practice.Customers ...`만 남는다.
3. (5-D-03) 사용자 세션에서 입력을 시도한다: `INSERT INTO amm_priv_practice.Customers (name) VALUES ('박민수');` → 결과: `ERROR 1142 (42000): INSERT command denied to user ...`.
4. (5-D-04) 사용자 세션에서 조회한다: `SELECT * FROM amm_priv_practice.Customers;` → 결과: 2행(홍길동, 김철수)이 나온다.

### E. 정리 (관리자 세션)

{% hint style="danger" %}
WARNING: `DROP USER`와 `DROP DATABASE`는 복구되지 않는다. 5-E-01에서 사용자 이름과 데이터베이스 이름이 이 실습의 것인지 확인한다.
{% endhint %}

1. (5-E-01) 이름을 확인한다: `SELECT User, Host FROM mysql.user WHERE User = '<사용자명>';` → 결과: 이 실습에서 만든 1행이다.
2. (5-E-02) 사용자 세션을 종료한다: `EXIT;` → 결과: 사용자 세션이 닫힌다.
3. (5-E-03) 남은 권한을 모두 회수한다: `REVOKE ALL PRIVILEGES, GRANT OPTION FROM '<사용자명>'@'localhost';` → 결과: `Query OK`.
4. (5-E-04) 사용자를 삭제한다: `DROP USER '<사용자명>'@'localhost';` → 결과: `Query OK`.
5. (5-E-05) 데이터베이스를 삭제한다: `DROP DATABASE amm_priv_practice;` → 결과: `Query OK`.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 5-C-02, 5-C-03 | 조회, 입력 성공 | 부여한 권한이 동작한다 |
| 2 | 5-C-04 | `ERROR 1142` | 부여하지 않은 권한이 거부된다 |
| 3 | 5-D-03 | `ERROR 1142` | 회수한 권한이 거부된다 |
| 4 | `SELECT User FROM mysql.user WHERE User = '<사용자명>';` (구역 E 후) | `Empty set` | 연습용 사용자가 없다 |

## 7. 복구

1. (7-01) 권한을 잘못 회수했다면 기록해 둔 `SHOW GRANTS` 결과대로 `GRANT`를 다시 실행한다.
2. (7-02) 중간에 중단했다면 구역 E를 수행해 연습용 사용자와 데이터베이스를 지운다. 다른 사용자와 데이터베이스는 건드리지 않는다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `sql_dcl.md`의 GRANT, REVOKE 예제를 단계별 실습으로 새로 작성했다. 사용자 표기(`'<사용자명>'@'localhost'`)와 테이블 범위 지정을 보충했고 `GRANT ALL PRIVILEGES` 예시는 제외했다 |
