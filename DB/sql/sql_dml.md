# 데이터 조작어 (DML)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-SQL-003-REF |
| 유형 | REF (문법 표) |
| 목적 | DML 명령(SELECT, INSERT, UPDATE, DELETE)의 문법과 주의점을 참조한다 |
| 확인 상태 | 미검증 (원본 페이지와 MariaDB/MySQL 문서 지식을 정리한 것이며 DB에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. DML이란

DML(Data Manipulation Language, 데이터 조작어)은 테이블 안의 데이터를 조회, 추가, 수정, 삭제하는 SQL 명령이다. 테이블 구조는 바꾸지 않는다. 일부 문헌은 `SELECT`를 DQL(Data Query Language)로 따로 분류한다.

## 2. 명령 표

| 명령 | 용도 | 문법 | 비고 |
|---|---|---|---|
| `SELECT` | 데이터를 조회한다 | `SELECT <컬럼명> FROM <테이블명> WHERE <조건>;` | 데이터를 바꾸지 않는다. `GROUP BY`, `ORDER BY`, `JOIN`과 함께 쓴다 |
| `INSERT` | 행을 추가한다 | `INSERT INTO <테이블명> (<컬럼1>, <컬럼2>) VALUES (<값1>, <값2>);` | 생략한 컬럼은 `AUTO_INCREMENT`나 `DEFAULT` 값이 들어간다 |
| `UPDATE` | 행을 수정한다 | `UPDATE <테이블명> SET <컬럼1> = <값1> WHERE <조건>;` | `WHERE`를 생략하면 모든 행이 바뀐다 |
| `DELETE` | 행을 삭제한다 | `DELETE FROM <테이블명> WHERE <조건>;` | `WHERE`를 생략하면 모든 행이 삭제된다 |

{% hint style="warning" %}
CAUTION: `INSERT`에서 컬럼 목록을 생략하면 모든 컬럼의 값을 순서대로 넣어야 한다. 값을 넣지 않은 컬럼에 `NOT NULL`이고 기본값이 없으면 오류가 난다(엄격 모드).
{% endhint %}

{% hint style="info" %}
NOTE: 원본의 `INSERT INTO Customers (name, age) VALUES ('김철수', 30);`은 `id`가 `AUTO_INCREMENT`가 아니면 `id` 값이 없어 오류가 난다. 원본 예시의 `Customers` 테이블에 `AUTO_INCREMENT`가 없어 이 예는 DB-SQL-006-MP에서 `AUTO_INCREMENT`를 넣어 바로잡았다. 미검증이다.
{% endhint %}

## 3. 사용 예

| 목적 | 명령 |
|---|---|
| 모든 고객 조회 | `SELECT * FROM Customers;` |
| 30세 초과 고객의 이름과 나이 조회 | `SELECT name, age FROM Customers WHERE age > 30;` |
| 모든 컬럼에 값 입력 | `INSERT INTO Customers (id, name, age, city) VALUES (1, '홍길동', 25, '서울');` |
| 특정 고객의 나이 수정 | `UPDATE Customers SET age = 28 WHERE name = '홍길동';` |
| 특정 고객 삭제 | `DELETE FROM Customers WHERE name = '홍길동';` |

{% hint style="danger" %}
WARNING: `WHERE` 없는 `UPDATE`와 `DELETE`는 테이블의 모든 행을 바꾸거나 지운다. 실행 전에 같은 `WHERE` 조건으로 `SELECT`를 먼저 실행해 대상 행을 확인한다. 원본에 있던 `UPDATE Customers SET city = '부산';` 예시(모든 행 변경)는 실행하지 않는다.
{% endhint %}

## 4. DML과 트랜잭션

| 항목 | 내용 |
|---|---|
| 기본 동작 | MariaDB/MySQL은 기본값 `autocommit=1`이다. `START TRANSACTION` 없이 실행한 DML은 문장마다 즉시 확정된다 |
| 트랜잭션 사용 | `START TRANSACTION;` 뒤에 실행한 DML은 `COMMIT`하기 전까지 확정되지 않고, `ROLLBACK`으로 취소할 수 있다 |
| 엔진 조건 | 트랜잭션을 지원하는 스토리지 엔진(InnoDB)이어야 한다. MyISAM은 롤백되지 않는다 |
| 전체 삭제 | 테이블의 모든 행을 지우려면 `TRUNCATE TABLE`(DDL, 롤백 불가)을 쓸 수 있다. DB-SQL-002-REF를 참조한다 |

{% hint style="info" %}
NOTE: 원본은 "COMMIT하지 않으면 반영되지 않는다", "마지막 COMMIT 이전의 변경 사항을 취소한다"로 적었다. 자동 커밋 설정에 따라 다르고, 정확히는 "현재 트랜잭션이 시작된 뒤의 변경 사항"을 취소한다. 정정했다. 미검증이다.
{% endhint %}

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [데이터 정의어 (DDL)](sql_ddl.md) | DB-SQL-002-REF | 테이블 생성과 삭제 |
| [트랜잭션 제어 언어 (TCL)](sql_tcl.md) | DB-SQL-005-REF | 커밋과 롤백 |
| [테이블 생성·입력·조회·수정·삭제 실습](sql_table_practice.md) | DB-SQL-006-MP | 실습 절차 |

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | REF 형식으로 재작성. 자동 커밋과 롤백 범위 설명을 정정하고, 실습은 DB-SQL-006-MP로 분리했다 |
