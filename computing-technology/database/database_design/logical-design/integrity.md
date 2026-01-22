# 무결성 정책

## 무결성 규정이란?

* 데이터베이스에서 데이터의 **정확성**, **일관성**, **유효성**을 보장하는 규칙을 의미한다.
* 잘못된 데이터 입력이나 변경을 방지하여 데이터베이스의 신뢰성을 유지하는 개념이다.
* 대표되는 무결성 정책들

| 무결성 규정                                                                            | 설명                                         |
| --------------------------------------------------------------------------------- | ------------------------------------------ |
| [**개체** 무결성(Entity Integrity)](<integrity.md#개체 무결성(Entity Integrity)>)           | Primary Key는 NULL이거나 중복될 수 없다.             |
| [**참조** 무결성(Referential Integrity)](<integrity.md#참조 무결성(Referential Integrity)>) | Foreign Key는 부모 테이블의 Primary Key와 일치해야 한다. |
| [**도메인** 무결성(Domain Integrity)](<integrity.md#도메인 무결성(Domain Integrity)>)         | 컬럼의 데이터 타입과 허용된 값의 범위를 지켜야 한다.             |
| [**고유** 무결성(Unique Integrity)](<integrity.md#고유 무결성(Unique Integrity)>)           | 특정 컬럼 값은 중복될 수 없다.                         |
| [**NULL** 무결성(NULL Integrity)](<integrity.md#NULL 무결성(NULL Integrity)>)           | 특정 컬럼은 NULL 값을 가질 수 없다.                    |
| [**키** 무결성(Key Integrity)](<integrity.md#키 무결성(Key Integrity)>)                   | Primary Key는 변경될 수 없다.                     |

***

## 무결성의 중요성

* **데이터 오류 방지**: 잘못딘 데이터 삽입을 차단하여 데이터 품질 유지
* **일관성 유지**: 테이블 간의 관계를 보호하고 논리적인 모순을 방지
* **데이터 보호**: 중요 정보가 의도치 않게 변경되는 것을 방지

***

### 개체 무결성(Entity Integrity)

* **각 행(Row)** 은 고유한 값을 가져야 하며, **Primary Key(PK)는 NULL 값을 가질 수 없다.**
* **기본 키(Primary Key)는 중복될 수 없다.**
* 목적: **각 레코드(행)를 고유하게 식별하기 위함**

```sql
CREATE TABLE Users (
	user_id INT PRIMARY KEY, -- Primary Key (NULL 불가능, 중복 불가능)
	name VARCHAR(50) NOT NULL
);
```

* 위반 사례

```sql
INSERT INTO Users (user_id, name) VALUES (NULL, 'KRJaeho'); -- ERROR: NULL 값을 가질 수 없다.
INSERT INTO Users (user_id, name) VALUES (1, 'USJaeho');
INSERT INTO Users (user_id, name) VALUES (1, 'CHJaeho'); -- ERROR: 중복된 Primary Key
```

***

### 참조 무결성(Referential Integrity)

* **외래 키(Foreign Key)는 반드시 참조하는 기본 키(Primary Key)와 일치해야 한다.**
* **부모 테이블(참조되는 테이블)의 데이터가 먼저 존재해야 하며, 삭제 시에도 주의해야 한다**.
* 목적: **데이터 관계를 유지하고 논리적 오류를 방지하기 위함**

```sql
CREATE TABLE Departments (
	dept_id INT PRIMARY KEY,
	dept_name VARCHAR(50)
);
CREATE TABLE Employees (
	emp_id INT PRIMARY KEY,
	emp_name VARCHAR(50) NOT NULL,
	dept_id INT,
	FOREIGN KEY (dept_id) REFERENCES Departments(dept_id) -- 참조 무결성 적용
);
```

* 위반 사례

```sql
INSERT INTO Employees (emp_id, emp_name, dept_id) VALUES (1, 'Alice', 100);  
-- ❌ ERROR: 100번 부서(dept_id=100)가 Departments 테이블에 존재하지 않음.
```

* 부모 데이터 삭제 시 문제 해결(ON DELETE CASCADE)

```sql
CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50) NOT NULL,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id) ON DELETE CASCADE
    -- 부모 테이블에서 데이터가 삭제되면, 자식 테이블의 관련 데이터도 자동 삭제된다.
);
```

***

### 도메인 무결성(Domain Integrity)

* **각 속성(칼럼)은 허용된 데이터 타입과 제약 조건을 따라야 한다.**
* **데이터 타입, 길이, 값의 범위 등을 제한하여 부적절한 값 입력을 방지한다.**
* 목적: **잘못된 데이터 입력을 방지하고 유효한 데이터만 저장하기 위함**

```sql
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) CHECK (price > 0),  -- 가격은 0보다 커야 함
    stock INT CHECK (stock >= 0)  -- 재고는 음수가 될 수 없음
);
```

* 위반 사례

```sql
INSERT INTO Products (product_id, product_name, price, stock) 
VALUES (1, 'Laptop', -500, 10);  -- ❌ ERROR: price가 음수일 수 없음.
```

***

### 고유 무결성(Unique Integrity)

* **특정 컬럼의 값은 중복될 수 없다.**
* 목적: **고유한 값 유지** (예: 사용자 이메일, 학번, 주민등록번호 등)

```sql
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    email VARCHAR(100) UNIQUE  -- 이메일 값은 중복 불가능
);
```

* 위반 사례

```sql
INSERT INTO Users (user_id, email) VALUES (1, 'alice@example.com');
INSERT INTO Users (user_id, email) VALUES (2, 'alice@example.com');  -- ❌ ERROR: 중복된 이메일
```

***

### NULL 무결성(NULL Integrity)

* **특정 컬럼은 반드시 값을 가져야 하며, NULL 값을 허용하지 않는다.**
* 목적: **중요한 정보가 누락되지 않도록 보장하기 위함**

```sql
INSERT INTO Users (user_id, email) VALUES (1, 'alice@example.com');
INSERT INTO Users (user_id, email) VALUES (2, 'alice@example.com');  -- ❌ ERROR: 중복된 이메일
```

* 위반 사례

```sql
INSERT INTO Employees (emp_id, emp_name, salary) VALUES (1, NULL, 5000);  
-- ❌ ERROR: emp_name은 NULL일 수 없음.
```

***

### 키 무결성(Key Integrity)

* **기본 키(Primary Key)는 중복될 수 없으며, 변경할 수 없다.**
* 목적: **각 레코드(행)을 고유하게 식별하고 안정성 유지하기 위함**

```sql
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,  -- Primary Key
    customer_id INT NOT NULL
);
```

* 위반 사례

```sql
UPDATE Orders SET order_id = NULL WHERE order_id = 1;  
-- ❌ ERROR: Primary Key는 NULL이 될 수 없음.
```
