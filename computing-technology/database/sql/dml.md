# DML (Data Manipulation Language, 데이터 조작어)

## DML 이란?

- 데이터베이스에서 데이터를 조회, 추가, 수정, 삭제하는 SQL 명령어
- 데이터를 조작(Manipulation)하는 역할을 수행하는 SQL의 하위 집합

✔️ **데이터 조회(SELECT)**, **삽입(INSERT)**, **수정(UPDATE)**, **삭제(DELETE)**

✔️ 데이터를 조작하기 위한 명령어, 테이블 구조를 변경하지 않음

✔️ 트랜잭션(Transaction)과 연계되어 실행되며, COMMIT과 ROLLBACK이 가능하다.

---

## SELECT (데이터 조회)

- 데이터베이스에서 데이터를 조회(검색)하는 명령어
- 데이터를 수정하지 않고 가져오기만 한다. (READ-ONLY)
- WHERE 조건을 사용하여 특정 데이터만 조회 가능
- GROUP BY, ORDER BY, JOIN 등의 다양한 연산과 함께 사용 가능

~~~sql
SELECT 컬럼명 FROM 테이블명 WHERE 조건;
~~~

~~~sql
-- 모든 고객 정보 조회
SELECT * FROM Customers;

-- 특정 고객 조회
SELECT name, age FROM Customers WHERE age > 30;
~~~

✔️ SELECT는 데이터를 검색하는 역할을 하며, DML에서 가장 많이 사용되는 명령어

---

## INSERT (데이터 삽입)

- 새로운 데이터를 테이블에 삽입하는 명령어
- 모든 칼럼에 값을 삽입하거나, 일부 컬럼만 선택적으로 삽입 가능
- 자동 증가(AUTO_INCREMENT) 컬럼이 있다면 해당 컬럼은 생략 가능

~~~sql
INSERT INTO 테이블명 (컬럼1, 컬럼2, ...) VALUES (값1, 값2, ...);
~~~

~~~sql
-- 모든 컬럼에 값 삽입
INSERT INTO Customers (id, name, age, city) VALUES (1, '홍길동', 25, '서울');

-- 특정 컬럼만 값 삽입
INSERT INTO Customers (name, age) VALUES ('김철수', 30);
~~~

✔️ INSERT는 새로운 데이터를 추가할 때 사용하는 명령어

✔️ 컬럼 목록을 지정하지 않으면 모든 컬럼에 대해 값을 넣어야 한다.

---

## UPDATE (데이터 수정)

- 기존 데이터를 수정(업데이트)하는 명령어
- WHERE 절을 사용하지 않으면 모든 행이 변경된다. (주의)
- 특정 조건을 만족하는 데이터만 수정 가능

~~~sql
UPDATE 테이블명 SET 컬럼1 = 값1, 컬럼2 = 값2 WHERE 조건;
~~~

~~~sql
-- 특정 고객의 나이 수정
UPDATE Customers SET age = 28 WHERE name = '홍길동';

-- 모든 고객의 도시 정보 변경
UPDATE Customers SET city = '부산';
~~~

✔️ UPDATE 사용 시 반드시 WHERE 절을 사용하여 특정 행만 수정하는 것이 안전하다.

✔️ WHERE 조건을 생략하면 모든 행이 수정되므로 주의

---

## DELETE (데이터 삭제)

- 특정 데이터를 삭제하는 명령어
- WHERE 조건을 사용하여 특정 행만 삭제 가능
- WHERE 절이 없으면 테이블의 모든 데이터가 삭제된다. (주의)

~~~sql
DELETE FROM 테이블명 WHERE 조건;
~~~

~~~sql
-- 특정 고객 삭제
DELETE FROM Customers WHERE name = '홍길동';

-- 30세 이상 고객 삭제
DELETE FROM Customers WHERE age >= 30;
~~~

✔️ DELETE 사용 시 WHERE 조건을 반드시 추가해야 불필요한 데이터 삭제를 방지할 수 있다.

✔️ 테이블의 전체 데이터를 삭제하려면 TRUNCATE 사용(DDL 명령어, 롤백 불가능)

---

## DML과 트랜잭션(TCL)

- DML 명령어는 데이터 조작이므로 트랜잭션 제어 명령어와 함께 사용된다.
- INSERT, UPDATE, DELETE는 트랜잭션이 완료되기 전까지 COMMIT되지 않으면 변경 사항이 반영되지 않는다.
- ROLLBACK을 사용하면 마지막 COMMIT 이전의 변경 사항을 취소할 수 있다.

~~~sql
-- 고객 데이터 추가
INSERT INTO Customers (id, name, age) VALUES (2, '이영희', 29);

-- 변경 사항을 저장하지 않고 롤백
ROLLBACK;

-- 데이터 확인 (ROLLBACK으로 인해 추가되지 않음)
SELECT * FROM Customers;
~~~