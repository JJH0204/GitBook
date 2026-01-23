# SQL\_DDL

## DDL (Data Definition Language, 데이터 정의어)란?

* 데이터베이스의 테이블, 인덱스, 뷰 등의 구조를 관리하는 SQL 명령어
* 데이터를 저장하는 형식과 구조를 설정하는 역할을 수행하는 SQL의 하위 집합

***

## CREATE (객체 생성)

* 데이터베이스의 객체(테이블, 인덱스, 뷰, 스키마 등)를 생성하는 명령어
* 데이터를 저장할 테이블의 구조를 정의할 때 사용된다.
* 테이블의 각 컬럼의 데이터 타입과 제약 조건을 설정할 수 있다.

{% code title="CREATE TABLE 문법" %}
```sql
CREATE TABLE 테이블명 (
    컬럼1 데이터타입 [제약조건],
    컬럼2 데이터타입 [제약조건],
    ...
);
```
{% endcode %}

{% code title="예시: Customers 테이블 생성" %}
```sql
CREATE TABLE Customers (
    id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    age INT,
    city VARCHAR(50)
);
```
{% endcode %}

{% hint style="info" %}
테이블뿐만 아니라 INDEX, VIEW, SCHEMA 등을 생성할 수도 있다.
{% endhint %}

***

## ALTER (객체 수정)

* 기존 테이블이나 데이터베이스 객체의 구조를 변경하는 명령어
* 컬럼 추가, 삭제, 데이터 타입 변경, 제약 조건 변경 등이 가능

{% code title="ALTER 기본 문법" %}
```sql
ALTER TABLE 테이블명 ADD 컬럼명 데이터타입;
ALTER TABLE 테이블명 DROP COLUMN 컬럼명;
ALTER TABLE 테이블명 MODIFY COLUMN 컬럼명 새로운_데이터타입;
```
{% endcode %}

{% code title="예시" %}
```sql
-- 컬럼 추가
ALTER TABLE Customers ADD email VARCHAR(100);

-- 컬럼 삭제
ALTER TABLE Customers DROP COLUMN city;

-- 데이터 타입 변경
ALTER TABLE Customers MODIFY COLUMN age SMALLINT;
```
{% endcode %}

{% hint style="success" %}
기존 데이터를 유지하면서 테이블 구조를 변경할 수 있다.
{% endhint %}

***

## DROP (객체 삭제)

* 테이블, 인덱스, 뷰 등 데이터베이스 객체를 완전히 삭제하는 명령어
* 삭제된 데이터는 복구할 수 없음(ROLLBACK 불가능)
* 테이블을 삭제하면 관련된 모든 데이터와 인덱스도 삭제된다.

{% code title="DROP 예시" %}
```sql
DROP TABLE 테이블명;
DROP DATABASE 데이터베이스명;
DROP INDEX 인덱스명;
DROP VIEW 뷰명;
```
{% endcode %}

{% code title="예시: Customers 테이블 및 데이터베이스 삭제" %}
```sql
-- Customers 테이블 삭제
DROP TABLE Customers;

-- 특정 데이터베이스 삭제
DROP DATABASE ShopDB;
```
{% endcode %}

{% hint style="danger" %}
데이터와 테이블 구조가 완전히 제거됩니다. 복구할 수 없으므로 주의해서 사용하세요.
{% endhint %}

{% hint style="info" %}
DROP과 달리 TRUNCATE는 테이블 구조를 유지하면서 데이터만 삭제합니다.
{% endhint %}

***

## TRUNCATE

* 테이블의 모든 데이터를 삭제하지만, 테이블 구조는 유지한다.
* DROP과 달리 테이블은 삭제되지 않고, 데이터만 초기화 된다.
* DELETE와 달리 트랜잭션을 지원하지 않으며, 실행 후 ROLLBACK 불가능하다.
* DELETE 보다 성능이 뛰어나 대량 데이터 삭제 시 유리하다.

{% code title="TRUNCATE 예시" %}
```sql
TRUNCATE TABLE 테이블명;
```
{% endcode %}

{% code title="예시: Customers 모든 데이터 삭제" %}
```sql
TRUNCATE TABLE Customers;
```
{% endcode %}

{% hint style="warning" %}
TRUNCATE는 DELETE보다 빠르지만 복구가 불가능하므로 주의해서 사용해야 합니다.
{% endhint %}

{% hint style="info" %}
테이블을 초기화해야 할 경우 성능 면에서 DELETE 대신 TRUNCATE를 고려할 수 있습니다.
{% endhint %}

***

## DDL과 트랜잭션

{% hint style="warning" %}
DDL 명령어는 일반적으로 트랜잭션을 지원하지 않습니다. 실행 시 ROLLBACK을 사용할 수 없으며, 즉시 COMMIT 되어 작업이 반영되는 경우가 많습니다. (데이터베이스 종류에 따라 동작이 다를 수 있으니 사용하는 DBMS의 문서를 참고하세요.)
{% endhint %}

***

## DDL 명령어 비교

| 명령어      | 설명                           |
| -------- | ---------------------------- |
| CREATE   | 테이블, 뷰, 인덱스 등의 데이터베이스 객체를 생성 |
| ALTER    | 기존 테이블 또는 데이터베이스 객체의 구조를 변경  |
| DROP     | 테이블, 인덱스, 뷰 등을 삭제            |
| TRUNCATE | 테이블의 모든 데이터를 삭제 (테이블 유지)     |

***

## DDL과 DML의 차이

| 구분      | DDL                           | DML                            |
| ------- | ----------------------------- | ------------------------------ |
| 설명      | 테이블 및 데이터 구조 정의               | 데이터를 삽입, 조회, 수정, 삭제            |
| 주요 명령어  | CREATE, ALTER, DROP, TRUNCATE | SELECT, INSERT, UPDATE, DELETE |
| 트랜잭션 여부 | 지원하지 않음, 자동 COMMIT            | 지원, COMMIT, ROLLBACK 가능        |
| 영향 범위   | 데이터 구조                        | 테이블 내 데이터                      |
