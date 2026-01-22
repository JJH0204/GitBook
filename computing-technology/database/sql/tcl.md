# TCL

## TCL(Transaction Control Language, 트랜잭션 제어 언어)란?

- 데이터베이스에서 트랜잭션의 실행을 제어하는 SQL 명령어
- DML과 함께 사용되어 트랜잭션의 실행을 확정(COMMIT)하거나 취소(ROLLBACK)하는 역할을 수행

✔️ 데이터의 일관성과 무결성을 보장하기 위해 사용된다.

✔️ 트랜잭션 단위로 데이터를 처리하여 원자성을 유지

✔️ TCL 명령어: COMMIT, ROLLBACK, SAVEPOINT

---

## 트랜잭션(Transaction)이란?

- 데이터베이스에서 하나의 논리적인 작업 단위를 의미한다.
- 여러 개의 SQL 연산이 하나의 트랜잭션으로 묶여서 실행되며, 트랜잭션이 완료되면 COMMIT, 오류 발생 시 ROLLBACK을 수행

✔️ 트랜잭션은 원자성, 일관성, 독립성, 지속성을 보장해야 한다. (ACID 원칙)

✔️ TCL은 트랜잭션을 제어하여 데이터의 무결성을 유지하는 역할을 수행한다.

---

## COMMIT (트랜잭션 확정)

- 현재까지 실행된 트랜잭션의 변경 내용을 데이터베이스에 반영(확정)
- DML 작업 후 COMMIT을 수행해야 변경 사항이 저장된다.
- COMMIT이 실행되면 이후 ROLLBACK을 할 수 없다.

~~~sql
COMMIT;
~~~

~~~sql
-- 고객 정보 추가
INSERT INTO Customers (id, name, age) VALUES (1, '홍길동', 25);

-- 변경 사항 확정 (데이터베이스에 반영)
COMMIT;
~~~

✔️ **변경사항 영구 저장, ROLLBACK 불가능**

---

## ROLLBACK (트랜잭션 취소)

- 현재 트랜잭션의 변경 내용을 취소하고, 이전 상태로 되돌린다.
- COMMIT 되지 않은 DML 작업을 모두 취소
- ROLLBACK을 수행하면 트랜잭션이 시작되기 전 상태로 되돌린다.

~~~sql
ROLLBACK;
~~~

~~~sql
-- 고객 정보 추가
INSERT INTO Customers (id, name, age) VALUES (2, '김철수', 30);

-- 실수로 데이터를 삽입했으므로 롤백
ROLLBACK;

-- 변경 사항이 취소되었으므로 데이터는 저장되지 않음
SELECT * FROM Customers;
~~~

✔️ **DML 실행 결과를 COMMIT 하지 않은 경우 복구 할 수 있다.**

---

## SAVEPOINT (트랜잭션 저장점 설정)

- 트랜잭션 내에서 특정 지점을 저장, 부분적으로 롤백 기능 제공
- ROLLBACK TO SAVEPOINT를 사용하면 특정 저장점 이후의 변경 사항만 취소 가능
- 복잡한 트랜잭션에서 부분적인 오류 처리를 수행할 때 유용하다.

~~~sql
SAVEPOINT 저장점_이름;
~~~

~~~sql
ROLLBACK TO 저장점_이름;
~~~

~~~sql
-- 고객 정보 추가
INSERT INTO Customers (id, name, age) VALUES (3, '이영희', 28);
SAVEPOINT sp1;  -- 저장점 설정

-- 고객 정보 추가
INSERT INTO Customers (id, name, age) VALUES (4, '박민수', 35);
SAVEPOINT sp2;  -- 저장점 설정

-- 일부 데이터 롤백
ROLLBACK TO sp1;

-- '이영희'는 남아있고, '박민수' 데이터는 롤백됨
SELECT * FROM Customers;
~~~

✔️ **SAVEPOINT를 사용하면 트랜잭션 내에서 특정 지점을 설정하여 부분적 ROLLBACK 가능**

---

## ACID

- 데이터베이스 트랜잭션의 ACID (Atomicity, Consistency, Isolation, Durability)특성을 보장하기 위해 사용된다.

| ACID 속성          | 설명                         | TCL 명령어와의 관계 |
| :--------------- | -------------------------- | ------------ |
| 원자성(Atomicity)   | 트랜잭션 내 모든 작업이 성공해야 한다.     | ROLLBACK     |
| 일관성(Consistency) | 트랜잭션이 실행되면 데이터의 무결성이 유지된다. | COMMIT       |
| 격리성(Isolatiion)  | 여러 트랜잭션이 독립적으로 실행되어야 한다.   | SAVEPOINT    |
| 지속성(Durability)  | 트랜잭션이 완료되면 영구적으로 저장되어야 한다. | COMMIT       |
