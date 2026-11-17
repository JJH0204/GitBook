# 데이터 무결성 규정 (Integrity)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-REL-001-DO |
| 유형 | D&O (개념) |
| 목적 | 무결성 규정의 종류와 각 규정을 SQL 제약 조건으로 지키는 방법을 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 MariaDB·SQL 지식을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 일부 서술은 사실과 달라 정정했다. 정정한 곳은 "비고"와 NOTE로 표시했다. 확인이 더 필요한 항목은 응답의 확인 필요 목록에도 적었다.
{% endhint %}

## 1. 목적

데이터 무결성(integrity)은 데이터의 정확성, 일관성, 유효성을 지키는 규칙이다. 잘못된 입력과 변경을 막아 데이터베이스의 신뢰성을 유지한다. 효과는 아래와 같다.

| 번호 | 효과 | 내용 |
|---|---|---|
| 1 | 데이터 오류 방지 | 잘못된 데이터 입력을 차단해 품질을 유지한다 |
| 2 | 일관성 유지 | 테이블 간 관계를 보호하고 논리적 모순을 막는다 |
| 3 | 데이터 보호 | 중요한 정보가 의도치 않게 바뀌는 것을 막는다 |

## 2. 구성 요소

### 2.1 무결성 규정 표

| 무결성 규정 | 설명 | 구현 수단 | 비고 |
|---|---|---|---|
| 개체(Entity) 무결성 | 기본 키(PK)는 NULL일 수 없고 중복될 수 없다 | `PRIMARY KEY` | 원본은 "NULL이거나 중복될 수 없다"로 적어 모호했다. 정정했다 |
| 참조(Referential) 무결성 | 외래 키(FK) 값은 부모 테이블의 기본 키 값과 일치하거나 NULL이어야 한다 | `FOREIGN KEY ... REFERENCES` | 원본은 NULL 허용을 적지 않았다. 보충했다 |
| 도메인(Domain) 무결성 | 칼럼의 데이터 타입과 허용 값의 범위를 지켜야 한다 | 데이터 타입, `CHECK`, `NOT NULL`, `DEFAULT` | |
| 고유(Unique) 무결성 | 특정 칼럼 값은 중복될 수 없다 | `UNIQUE` | 교재에 따라 별도 규정으로 다루지 않는다 |
| NULL 무결성 | 특정 칼럼은 NULL을 가질 수 없다 | `NOT NULL` | 교재에 따라 별도 규정으로 다루지 않는다 |
| 키(Key) 무결성 | 기본 키 값은 바뀌지 않는 값으로 운영한다 | 설계 원칙 | 아래 2.6 참조 |

{% hint style="info" %}
NOTE: 개체, 참조, 도메인 무결성은 일반적인 분류다. 고유, NULL, 키 무결성은 제약 조건 유형을 무결성 이름으로 부른 것이며 교재마다 분류가 다르다. 확인 필요.
{% endhint %}

### 2.2 개체 무결성

각 행(row)은 기본 키로 유일하게 식별된다. 기본 키 칼럼에는 NULL도 중복 값도 들어갈 수 없다.

```sql
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);
```

위반 예시는 다음과 같다. 두 번째 문장은 성공하고 나머지는 오류가 난다.

```sql
INSERT INTO Users (user_id, name) VALUES (NULL, 'Alice');  -- 오류: PK는 NULL 불가
INSERT INTO Users (user_id, name) VALUES (1, 'Alice');     -- 성공
INSERT INTO Users (user_id, name) VALUES (1, 'Bob');       -- 오류: PK 중복
```

### 2.3 참조 무결성

자식 테이블의 외래 키 값은 부모 테이블에 존재하는 기본 키 값이어야 한다. 외래 키 칼럼이 NULL을 허용하면 NULL은 허용된다. 부모 행이 먼저 있어야 자식 행을 넣을 수 있다.

```sql
CREATE TABLE Departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50)
);
CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50) NOT NULL,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
);
```

위반 예시는 다음과 같다.

```sql
INSERT INTO Employees (emp_id, emp_name, dept_id) VALUES (1, 'Alice', 100);
-- 오류: Departments에 dept_id=100이 없다
```

부모 행을 삭제하거나 부모 키를 바꿀 때 자식 행을 어떻게 처리할지는 `ON DELETE`, `ON UPDATE` 옵션으로 정한다.

| 옵션 | 동작 |
|---|---|
| `RESTRICT` | 자식 행이 있으면 부모 행의 삭제·변경을 거부한다 |
| `NO ACTION` | InnoDB에서는 `RESTRICT`와 같다 |
| `CASCADE` | 부모 행의 삭제·변경을 자식 행에 그대로 적용한다. 삭제하면 자식 행도 삭제된다 |
| `SET NULL` | 자식 행의 외래 키를 NULL로 바꾼다. 외래 키 칼럼이 NULL을 허용해야 한다 |
| `SET DEFAULT` | 자식 행의 외래 키를 기본값으로 바꾼다. InnoDB에서는 쓰지 않는다 |

옵션을 쓰지 않으면 InnoDB는 부모 행의 삭제·변경을 거부한다. 원본의 `ON DELETE CASCADE` 예시는 다음과 같다. `Employees`를 다시 만들 때는 기존 테이블을 `DROP TABLE Employees;`로 먼저 삭제한다.

```sql
CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50) NOT NULL,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id) ON DELETE CASCADE
);
```

→ 결과: `Departments`에서 행을 삭제하면 같은 `dept_id`를 가진 `Employees` 행도 자동 삭제된다.

{% hint style="info" %}
NOTE: 옵션 표는 원본에 없던 내용이다. 원본은 `ON DELETE CASCADE`만 다뤘다. `NO ACTION`과 `SET DEFAULT`의 InnoDB 동작은 확인 필요.
{% endhint %}

### 2.4 도메인 무결성

칼럼은 허용된 데이터 타입, 길이, 값의 범위를 따라야 한다.

```sql
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) CHECK (price > 0),
    stock INT CHECK (stock >= 0)
);
```

위반 예시는 다음과 같다.

```sql
INSERT INTO Products (product_id, product_name, price, stock)
VALUES (1, 'Laptop', -500, 10);  -- 오류: price는 0보다 커야 한다
```

{% hint style="info" %}
NOTE: MariaDB는 10.2.1부터 `CHECK` 제약을 검사한다. 이전 버전과 MySQL 8.0.16 미만은 문법만 받고 검사하지 않는다. 확인 필요.
{% endhint %}

### 2.5 고유 무결성과 NULL 무결성

고유 무결성은 `UNIQUE`로, NULL 무결성은 `NOT NULL`로 지킨다.

```sql
CREATE TABLE Members (
    member_id INT PRIMARY KEY,
    email VARCHAR(100) UNIQUE,
    member_name VARCHAR(50) NOT NULL
);
```

위반 예시는 다음과 같다.

```sql
INSERT INTO Members (member_id, email, member_name) VALUES (1, 'alice@example.com', 'Alice');  -- 성공
INSERT INTO Members (member_id, email, member_name) VALUES (2, 'alice@example.com', 'Bob');    -- 오류: email 중복
INSERT INTO Members (member_id, email, member_name) VALUES (3, 'carol@example.com', NULL);     -- 오류: member_name은 NULL 불가
```

{% hint style="info" %}
NOTE: `UNIQUE` 칼럼은 NULL을 여러 개 넣을 수 있다. NULL은 서로 같은 값으로 취급하지 않는다. 확인 필요.
{% endhint %}

### 2.6 키 무결성

기본 키는 행을 식별하는 값이므로 한번 정하면 바꾸지 않는 값으로 설계한다. 자식 테이블이 이 값을 참조하기 때문이다.

{% hint style="info" %}
NOTE: 원본은 "기본 키는 변경할 수 없다"로 적고 `UPDATE Orders SET order_id = NULL`을 키 무결성 위반 예시로 들었다. SQL 자체는 기본 키 값을 NULL이 아닌 유일한 값으로 바꾸는 `UPDATE`를 막지 않는다. 위 예시가 오류가 나는 이유는 기본 키가 NULL일 수 없다는 개체 무결성 때문이다. "변경 불가"는 DBMS 규칙이 아니라 설계 원칙으로 정정했다. 확인 필요.
{% endhint %}

## 3. 동작 원리

DBMS는 `INSERT`, `UPDATE`, `DELETE`가 실행될 때마다 제약 조건을 검사한다.

1. 응용이 데이터를 변경하는 문장을 보낸다.
2. DBMS가 변경 후 상태가 제약 조건(`PRIMARY KEY`, `FOREIGN KEY`, `CHECK`, `UNIQUE`, `NOT NULL`)을 만족하는지 검사한다.
3. 모두 만족하면 변경을 반영한다.
4. 하나라도 위반하면 문장을 거부하고 오류를 반환한다. 외래 키는 `ON DELETE`, `ON UPDATE` 옵션에 따라 자식 행을 함께 처리한다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| PK | Primary Key. 기본 키 |
| FK | Foreign Key. 외래 키 |
| 부모 테이블 | 외래 키가 가리키는 테이블 |
| 자식 테이블 | 외래 키를 가진 테이블 |
| 제약 조건(constraint) | 데이터가 지켜야 할 규칙을 DBMS에 선언한 것 |
| 도메인(domain) | 한 칼럼이 가질 수 있는 값의 집합 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 개체 무결성과 참조 무결성의 차이를 내 말로 설명해 보자.
- [ ] `ON DELETE CASCADE`를 쓰면 위험한 상황을 내가 만든 예로 적어 보자.
- [ ] 응용 코드에서 검사하지 않고 DB 제약 조건으로 무결성을 지킬 때의 장점을 적어 보자.
