# 트랜잭션 제어 언어 (TCL)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-SQL-005-REF |
| 유형 | REF (문법 표) |
| 목적 | TCL 명령(COMMIT, ROLLBACK, SAVEPOINT)과 트랜잭션 개념을 참조한다 |
| 확인 상태 | 미검증 (원본 페이지와 MariaDB/MySQL 문서 지식을 정리한 것이며 DB에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. TCL이란

TCL(Transaction Control Language, 트랜잭션 제어 언어)은 DML로 바꾼 데이터를 확정하거나 취소하는 SQL 명령이다. 트랜잭션은 하나의 논리적 작업 단위로 묶인 SQL 문의 집합이다. 전부 성공하거나 전부 취소된다.

## 2. 명령 표

| 명령 | 용도 | 문법 | 비고 |
|---|---|---|---|
| `START TRANSACTION` | 트랜잭션을 시작한다 | `START TRANSACTION;` 또는 `BEGIN;` | 이 명령 뒤의 DML은 `COMMIT`하기 전까지 확정되지 않는다 |
| `COMMIT` | 변경을 확정한다 | `COMMIT;` | 확정 뒤에는 `ROLLBACK`으로 취소할 수 없다 |
| `ROLLBACK` | 변경을 취소한다 | `ROLLBACK;` | 트랜잭션 시작 이후의 변경을 모두 취소한다 |
| `SAVEPOINT` | 저장점을 만든다 | `SAVEPOINT <저장점 이름>;` | 트랜잭션 안에서만 쓴다 |
| `ROLLBACK TO` | 저장점까지만 취소한다 | `ROLLBACK TO <저장점 이름>;` | 트랜잭션은 끝나지 않는다. 그 저장점 이후에 만든 저장점은 사라진다 |
| `RELEASE SAVEPOINT` | 저장점을 지운다 | `RELEASE SAVEPOINT <저장점 이름>;` | 변경 내용은 취소되지 않는다 |
| `SET autocommit` | 자동 커밋을 켜고 끈다 | `SET autocommit = 0;` | 기본값은 `1`(켜짐)이다 |

{% hint style="warning" %}
CAUTION: MariaDB/MySQL의 기본값은 `autocommit=1`이다. `START TRANSACTION` 없이 실행한 DML은 문장마다 즉시 확정되어 `ROLLBACK`으로 되돌릴 수 없다. 트랜잭션을 쓰려면 먼저 `START TRANSACTION;`을 실행한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 트랜잭션 안에서 DDL(`CREATE`, `ALTER`, `DROP`, `TRUNCATE`)을 실행하면 암묵적 커밋이 일어나 그때까지의 변경이 확정된다. 이후 `ROLLBACK`으로 되돌릴 수 없다.
{% endhint %}

{% hint style="info" %}
NOTE: 롤백은 InnoDB처럼 트랜잭션을 지원하는 스토리지 엔진에서만 동작한다. MyISAM 테이블은 롤백되지 않는다. 미검증이다.
{% endhint %}

## 3. 사용 예

| 목적 | 명령 순서 |
|---|---|
| 변경을 확정한다 | `START TRANSACTION;` → `INSERT INTO Customers (name, age) VALUES ('홍길동', 25);` → `COMMIT;` |
| 변경을 취소한다 | `START TRANSACTION;` → `INSERT INTO Customers (name, age) VALUES ('김철수', 30);` → `ROLLBACK;` |
| 일부만 취소한다 | `START TRANSACTION;` → `INSERT ...;` → `SAVEPOINT sp1;` → `INSERT ...;` → `ROLLBACK TO sp1;` → `COMMIT;` |

{% hint style="danger" %}
WARNING: `ROLLBACK`은 마지막 `COMMIT`이나 `START TRANSACTION` 이후의 모든 미확정 변경을 버린다. 실행 전에 `SELECT`로 현재 상태를 확인한다. `COMMIT`은 되돌릴 수 없다. 확정하기 전에 `SELECT`로 결과를 확인한다. 안전한 연습 절차는 DB-SQL-007-MP를 따른다.
{% endhint %}

## 4. ACID

트랜잭션이 지켜야 하는 네 가지 성질이다.

| 속성 | 의미 | 관련 기능 |
|---|---|---|
| 원자성 (Atomicity) | 트랜잭션의 작업이 모두 반영되거나 모두 취소된다 | `ROLLBACK` |
| 일관성 (Consistency) | 트랜잭션 전후에 데이터 무결성 규칙이 유지된다 | 제약 조건, 트랜잭션 전체 |
| 격리성 (Isolation) | 동시에 실행되는 트랜잭션이 서로 영향을 주지 않는다 | 격리 수준(`SET TRANSACTION ISOLATION LEVEL`) |
| 지속성 (Durability) | 확정된 변경은 장애가 나도 유지된다 | `COMMIT`, 로그 |

{% hint style="info" %}
NOTE: 원본은 격리성을 `SAVEPOINT`에, 일관성을 `COMMIT`에 대응시켰다. 격리성은 `SAVEPOINT`가 아니라 격리 수준으로 제어하고, 일관성은 `COMMIT` 하나로 보장되지 않는다. 대응 열을 정정했다. 미검증이다.
{% endhint %}

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [데이터 조작어 (DML)](sql_dml.md) | DB-SQL-003-REF | 트랜잭션 대상 명령 |
| [데이터 정의어 (DDL)](sql_ddl.md) | DB-SQL-002-REF | 암묵적 커밋 |
| [트랜잭션 COMMIT·ROLLBACK·SAVEPOINT 실습](sql_transaction_practice.md) | DB-SQL-007-MP | 실습 절차 |

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | REF 형식으로 재작성. 자동 커밋, `ROLLBACK TO` 동작, ACID 대응 표를 정정하고, 실습은 DB-SQL-007-MP로 분리했다 |
