# DCL

## DCL (Data Control Language, 데이터 제어어)란?

- 데이터베이스 사용자와 객체에 대한 권한을 부여하거나 회수하는 SQL 명령어를 의미한다.
- 데이터베이스 보안을 유지하고, 특정 사용자에게 권한을 설정하는 역할을 수행하는 SQL의 하위 집합

✔️ 사용자에게 데이터베이스 접근 권한을 부여하거나 제거하는 명령어

✔️ 데이터의 보안과 무결성을 유지하는 역할

✔️ DCL 명령어: GRANT, REBOKE

---

## GRANT (권한 부여)

- 특정 사용자에게 데이터베이스 객체(테이블, 뷰, 프로시저 등)에 대한 권한을 부여하는 명령어
- 사용자가 특정 작업(SELECT, INSERT, UPDATE, DELETE, EXECUTE 등)을 수행할 수 있도록 설정
- WITH GRANT OPTION을 사용하면 부여받은 사용자가 다른 사용자에게 권한을 부여할 수 있다.

~~~sql
GRANT 권한명 ON 객체명 TO 사용자명 [WITH GRANT OPTION];
~~~

~~~sql
-- 'user1'에게 Customers 테이블에 대한 SELECT, INSERT 권한 부여
GRANT SELECT, INSERT ON Customers TO user1;

-- 'user2'에게 모든 권한 부여
GRANT ALL PRIVILEGES ON Orders TO user2;

-- 'user3'가 다른 사용자에게도 권한을 부여할 수 있도록 설정
GRANT UPDATE ON Products TO user3 WITH GRANT OPTION;
~~~

---

## REVOKE (권한 회수)

- 특정 사용자에게 부여된 데이터베이스 객체에 대한 권한을 회수하는 명령어
- GRANT로 부여한 권한을 최소하는 역할
- 특정 권한만 회수할 수도 있고, 전체 권한을 제거할 수도 있다.

~~~sql
REVOKE 권한명 ON 객체명 FROM 사용자명;
~~~

~~~sql
-- 'user1'에게 부여된 SELECT, INSERT 권한 회수
REVOKE SELECT, INSERT ON Customers FROM user1;

-- 'user2'의 모든 권한 제거
REVOKE ALL PRIVILEGES ON Orders FROM user2;

-- 'user3'의 특정 권한만 제거
REVOKE UPDATE ON Products FROM user3;
~~~

---

## DCL과 사용자 권한

| 권한 유형          | 설명               |
| :------------- | ---------------- |
| SELECT         | 데이터를 조회할 수 있는 권한 |
| INSERT         | 데이터를 삽입할 수 있는 권한 |
| UPDATE         | 데이터를 수정할 수 있는 권한 |
| DELETE         | 데이터를 삭제할 수 있는 권한 |
| EXECUTE        | 프로시저 또는 함수 실행 권한 |
| ALL PRIVILEGES | 모든 권한 부여         |

✔️ 일반 사용자는 필요 최소한의 권한만 부여받아야 보안이 강화된다.

✔️ DBA(데이터베이스 관리자)는 전체 권한을 가질 수 있다.

---

## DCL과 보안(Security)

- DCL을 사용하면 특정 사용자가 데이터베이스에서 수행할 수 있는 작업을 제한할 수 있다. 
- 데이터베이스 보안을 강화하여 불법적인 데이터 접근 및 조작을 방지할 수 있다.

~~~sql
-- 'user4'에게 READ-ONLY 권한 부여
GRANT SELECT ON Employees TO user4;

-- 'user5'의 권한 회수 (데이터 수정 방지)
REVOKE INSERT, UPDATE, DELETE ON Employees FROM user5;
~~~