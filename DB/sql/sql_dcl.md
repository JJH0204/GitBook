# 데이터 제어어 (DCL)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-SQL-004-REF |
| 유형 | REF (문법 표) |
| 목적 | DCL 명령(GRANT, REVOKE)의 문법과 권한 종류를 참조한다 |
| 확인 상태 | 미검증 (원본 페이지와 MariaDB/MySQL 문서 지식을 정리한 것이며 DB에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. DCL이란

DCL(Data Control Language, 데이터 제어어)은 사용자에게 데이터베이스 객체에 대한 권한을 부여하거나 회수하는 SQL 명령이다. 사용자가 할 수 있는 작업을 제한해 데이터를 보호한다.

## 2. 명령 표

| 명령 | 용도 | 문법 | 비고 |
|---|---|---|---|
| `GRANT` | 권한을 부여한다 | `GRANT <권한> ON <객체> TO '<사용자명>'@'<호스트>' [WITH GRANT OPTION];` | `WITH GRANT OPTION`을 붙이면 받은 사용자가 다른 사용자에게 같은 권한을 줄 수 있다 |
| `REVOKE` | 권한을 회수한다 | `REVOKE <권한> ON <객체> FROM '<사용자명>'@'<호스트>';` | 부여한 범위와 같은 범위로 회수한다 |
| `SHOW GRANTS` | 부여된 권한을 확인한다 | `SHOW GRANTS FOR '<사용자명>'@'<호스트>';` | MariaDB/MySQL 명령이다 |

`<객체>`는 범위에 따라 다음과 같이 쓴다.

| 범위 | 표기 |
|---|---|
| 모든 데이터베이스 | `*.*` |
| 데이터베이스 하나 | `<데이터베이스명>.*` |
| 테이블 하나 | `<데이터베이스명>.<테이블명>` |

{% hint style="info" %}
NOTE: 원본은 `GRANT SELECT, INSERT ON Customers TO user1;`처럼 사용자를 이름만 적었다. MariaDB/MySQL에서는 `'<사용자명>'@'<호스트>'` 형식이며, 사용자는 `CREATE USER`로 먼저 만들어 두는 것이 안전하다. 정정했다. 다른 DBMS는 문법이 다르다. 미검증이다.
{% endhint %}

## 3. 권한 종류

| 권한 | 설명 |
|---|---|
| `SELECT` | 데이터를 조회한다 |
| `INSERT` | 데이터를 추가한다 |
| `UPDATE` | 데이터를 수정한다 |
| `DELETE` | 데이터를 삭제한다 |
| `EXECUTE` | 저장 프로시저나 함수를 실행한다 (`ON PROCEDURE <이름>` 형식) |
| `ALL PRIVILEGES` | 지정한 범위의 모든 권한 (`GRANT OPTION` 제외) |

## 4. 사용 예

| 목적 | 명령 |
|---|---|
| 조회와 추가 권한 부여 | `GRANT SELECT, INSERT ON <데이터베이스명>.Customers TO '<사용자명>'@'localhost';` |
| 다른 사용자에게 권한을 줄 수 있게 부여 | `GRANT UPDATE ON <데이터베이스명>.Products TO '<사용자명>'@'localhost' WITH GRANT OPTION;` |
| 읽기 전용 권한 부여 | `GRANT SELECT ON <데이터베이스명>.Employees TO '<사용자명>'@'localhost';` |
| 일부 권한 회수 | `REVOKE INSERT, UPDATE, DELETE ON <데이터베이스명>.Employees FROM '<사용자명>'@'localhost';` |
| 부여된 권한 확인 | `SHOW GRANTS FOR '<사용자명>'@'localhost';` |

{% hint style="danger" %}
WARNING: `GRANT ALL PRIVILEGES`는 지정한 범위의 모든 권한을 준다. 특히 `*.*` 범위는 서버 전체 관리 권한이다. 일반 사용자에게 쓰지 않는다. 원본의 `GRANT ALL PRIVILEGES ON Orders TO user2;` 예시는 필요한 권한만 나열하는 방식으로 바꿔 쓴다.
{% endhint %}

{% hint style="danger" %}
WARNING: `REVOKE ALL PRIVILEGES`는 사용자의 해당 범위 권한을 모두 없앤다. 실행 전에 `SHOW GRANTS`로 현재 권한을 기록한다. 서비스 계정에 쓰면 애플리케이션 접속이 끊길 수 있다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 사용자에게는 필요한 최소 권한만 부여한다(최소 권한 원칙). 데이터베이스 관리자(DBA)만 전체 권한을 가진다. 실습 절차는 DB-SQL-008-MP를 따른다.
{% endhint %}

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [사용자 권한 부여·회수 실습](sql_privilege_practice.md) | DB-SQL-008-MP | 실습 절차 |
| [DB 성능 튜닝 및 사용자 관리](../operations/dbperformanceinfo.md) | | 사용자 관리 |
| [MariaDB 기본 사용법](../operations/mariadb.md) | | MariaDB 접속과 기본 명령 |

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | REF 형식으로 재작성. MariaDB/MySQL의 사용자 표기와 객체 범위를 보충하고, 실습은 DB-SQL-008-MP로 분리했다 |
