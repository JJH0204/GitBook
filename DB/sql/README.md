---
description: 관계 언어 개요와 SQL의 DDL, DML, DCL, TCL 문법 참조 및 실습
---

# SQL

SQL을 관계 언어 개요, 명령 분류별 문법 표, 실습 절차로 나눠 정리한다. 문서 번호(Task ID)는 `DB-SQL-<번호>-<유형>` 형식이다. 실습 문서는 MariaDB(MySQL 호환 문법)를 기준으로 하며 모두 미검증이다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| DB-SQL-001-DO | 개념 | [관계 언어 개요](relationallanguageoverview.md) | 관계 대수, 관계 해석, SQL의 관계를 이해한다 |
| DB-SQL-002-REF | 표 | [데이터 정의어 (DDL)](sql_ddl.md) | CREATE, ALTER, DROP, TRUNCATE 문법을 찾는다 |
| DB-SQL-003-REF | 표 | [데이터 조작어 (DML)](sql_dml.md) | SELECT, INSERT, UPDATE, DELETE 문법을 찾는다 |
| DB-SQL-004-REF | 표 | [데이터 제어어 (DCL)](sql_dcl.md) | GRANT, REVOKE 문법과 권한 종류를 찾는다 |
| DB-SQL-005-REF | 표 | [트랜잭션 제어 언어 (TCL)](sql_tcl.md) | COMMIT, ROLLBACK, SAVEPOINT 문법을 찾는다 |
| DB-SQL-006-MP | 절차 | [테이블 생성·입력·조회·수정·삭제 실습](sql_table_practice.md) | 테이블 한 개로 DDL과 DML 전 과정을 실습한다 |
| DB-SQL-007-MP | 절차 | [트랜잭션 COMMIT·ROLLBACK·SAVEPOINT 실습](sql_transaction_practice.md) | 변경을 확정하거나 취소하는 동작을 실습한다 |
| DB-SQL-008-MP | 절차 | [사용자 권한 부여·회수 실습](sql_privilege_practice.md) | GRANT와 REVOKE의 효과를 실습한다 |

## 읽는 순서

1. DB-SQL-001-DO로 SQL의 이론적 배경을 본다.
2. DB-SQL-002-REF ~ DB-SQL-005-REF로 명령 분류와 문법을 본다.
3. DB-SQL-006-MP, DB-SQL-007-MP, DB-SQL-008-MP 순서로 실습한다.
