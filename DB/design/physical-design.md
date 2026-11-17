# 물리적 설계 (Physical Design)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-DSN-007-DO |
| 유형 | D&O (개념) |
| 목적 | 물리적 설계의 항목(저장 구조, 파일 조직, 인덱스, 파티셔닝, 뷰, 트랜잭션, 백업)을 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 SQL 예시를 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

물리적 설계는 논리적 설계 결과를 실제 DBMS에서 좋은 성능으로 동작하도록 구현 방식을 정하는 단계다. 저장 구조, 접근 속도, 인덱스 등을 결정한다.

목표는 다음과 같다.

1. 저장 공간(디스크)을 효율적으로 쓴다.
2. 조회, 삽입, 수정, 삭제 속도를 높인다.
3. 인덱스, 파티셔닝 등으로 시스템 부하를 줄인다.
4. 백업·복구와 보안 정책으로 무결성과 안전성을 유지한다.

{% hint style="info" %}
NOTE: 이 문서의 SQL 예시는 MySQL 문법 기준이다. 기능과 문법은 DBMS마다 다르다.
{% endhint %}

## 2. 구성 요소

| 번호 | 설계 항목 | 설명 |
|---|---|---|
| 1 | 저장 구조 설계 | 테이블 구조, 컬럼 데이터 타입과 크기를 정한다 |
| 2 | 파일 조직 방식 | 데이터를 저장하는 방식(Heap, Clustered, Indexed)을 정한다 |
| 3 | 인덱스 설계 | 검색 성능을 위한 인덱스의 종류와 대상 컬럼을 정한다 |
| 4 | 파티셔닝 설계 | 데이터를 여러 파티션으로 나눠 저장한다 |
| 5 | 뷰 설계 | 복잡한 쿼리를 단순화하고 노출 컬럼을 제한한다 |
| 6 | 트랜잭션·동시성 제어 | ACID 원칙과 동시 접근 관리를 정한다 |
| 7 | 백업·복구 전략 | 데이터 손실에 대비한 방법을 정한다 |

## 3. 동작 원리

### 3-1. 저장 구조 설계

* 컬럼 데이터 타입을 값의 범위에 맞춰 고른다. 예: 작은 정수는 `INT` 대신 `TINYINT`, `SMALLINT`를 쓰면 공간을 줄인다.
* 길이가 고정된 값은 `CHAR`, 길이가 변하는 값은 `VARCHAR`를 쓴다.
* 컬럼 크기는 실제 필요한 만큼 정한다.

{% hint style="info" %}
NOTE: `VARCHAR(1000)`을 `VARCHAR(255)`로 줄여도 MySQL은 저장된 값의 실제 길이만큼만 디스크를 쓰므로 디스크 절약 효과는 작다. 길이 제한은 데이터 검증, 인덱스 길이 제한, 임시 테이블 메모리 사용에 영향을 준다.
{% endhint %}

```sql
CREATE TABLE Users (
    user_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

* `INT UNSIGNED`는 음수가 필요 없을 때 쓴다(MySQL 문법).
* `VARCHAR(50)`은 가변 길이라 짧은 값은 짧게 저장한다.
* `TIMESTAMP DEFAULT CURRENT_TIMESTAMP`는 행을 넣은 시각을 자동 저장한다.

### 3-2. 파일 조직 방식(File Organization)

파일 조직은 데이터를 어떤 방식으로 저장하고 관리할지 정하는 일이다.

| 방식 | 설명 | 특징 |
|---|---|---|
| Heap 파일 | 데이터를 순서 없이 저장한다 | 삽입이 빠르고 검색이 느리다 |
| 클러스터링(Clustered) | 키 순서대로 행을 인접하게 저장한다 | 범위 검색에 유리하다 |
| 인덱스 파일 | 데이터와 별도로 정렬된 인덱스를 두고 데이터 위치를 가리킨다 | 검색이 빠르고 인덱스 유지 비용이 든다 |

### 3-3. 인덱스 설계(Index Design)

인덱스는 특정 컬럼 값을 정렬된 별도 자료구조(주로 B-tree)로 저장해 검색 속도를 높이는 구조다.

| 유형 | 설명 |
|---|---|
| Primary Index | 기본 키 기준 인덱스. MySQL InnoDB에서는 기본 키가 클러스터형 인덱스다. 다른 DBMS는 다를 수 있다 |
| Secondary Index | 기본 키 외 컬럼에 만드는 인덱스 |
| Unique Index | 중복 값을 허용하지 않는 인덱스 |
| Full-Text Index | 텍스트 검색용 인덱스 |
| Bitmap Index | 값의 종류가 적은 컬럼에 쓴다. Oracle 등 일부 DBMS에서만 제공하며 MySQL에는 없다 |

```sql
CREATE INDEX idx_username ON Users(username);
CREATE INDEX idx_user_email ON Users(username, email);
```

* 첫 문장은 `username` 검색을 빠르게 한다.
* 둘째 문장은 두 컬럼을 묶은 복합 인덱스다. 조건이 앞 컬럼(`username`)부터 쓰일 때 효과가 있다.

{% hint style="warning" %}
CAUTION: 인덱스는 조회를 빠르게 하지만 삽입·수정·삭제 때 함께 갱신되어 쓰기 속도와 저장 공간을 소모한다. 필요한 컬럼에만 만든다.
{% endhint %}

### 3-4. 파티셔닝 설계(Partitioning)

파티셔닝은 큰 테이블을 여러 물리적 파티션으로 나눠 저장하는 방식이다.

| 방식 | 설명 |
|---|---|
| Range | 날짜 같은 범위별로 나눈다 |
| List | 국가, 지역 코드 같은 특정 값으로 나눈다 |
| Hash | 해시 값을 기준으로 고르게 분산한다 |
| Composite | 여러 방식을 결합한다 |

```sql
CREATE TABLE Orders (
    order_id INT,
    order_date DATE NOT NULL,
    total_price DECIMAL(10,2),
    PRIMARY KEY (order_id, order_date)
)
PARTITION BY RANGE (YEAR(order_date)) (
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION pmax VALUES LESS THAN MAXVALUE
);
```

* 2022년 데이터는 p2022, 2023년 데이터는 p2023, 그 이후는 pmax에 저장한다.
* MySQL은 파티션 키(`order_date`)가 모든 기본 키·유니크 키에 포함되어야 하므로 기본 키를 `(order_id, order_date)`로 정했다.
* `MAXVALUE` 파티션이 없으면 2024년 이후 행은 넣을 수 없다.

### 3-5. 뷰 설계(View)

뷰는 저장된 쿼리를 가상 테이블처럼 쓰는 객체다. 복잡한 쿼리를 단순화하고 보여 줄 컬럼을 제한해 보안을 높인다.

```sql
CREATE VIEW UserView AS
SELECT user_id, username, email FROM Users;
```

* 뷰로 조회하면 지정한 컬럼만 볼 수 있다.

{% hint style="info" %}
NOTE: 일반 뷰는 쿼리를 저장할 뿐 성능을 높이지 않는다. 결과를 저장하는 구체화 뷰(Materialized View)는 DBMS마다 지원 여부가 다르다.
{% endhint %}

### 3-6. 트랜잭션과 동시성 제어

트랜잭션은 하나의 논리적 작업 단위다. ACID 원칙(원자성 Atomicity, 일관성 Consistency, 격리성 Isolation, 지속성 Durability)을 적용한다.

```sql
START TRANSACTION;
UPDATE Accounts SET balance = balance - 500 WHERE user_id = 1;
UPDATE Accounts SET balance = balance + 500 WHERE user_id = 2;
COMMIT;
```

* 모든 연산이 성공하면 `COMMIT`으로 반영한다. 실패하면 `ROLLBACK`으로 되돌린다.

### 3-7. 백업·복구 전략

| 방식 | 설명 |
|---|---|
| Full Backup | 전체 데이터베이스를 백업한다 |
| Incremental Backup | 직전 백업(전체 또는 증분) 이후 변경분만 백업한다 |
| Differential Backup | 마지막 전체 백업 이후 변경분을 모두 백업한다 |

```bash
mysqldump -u <사용자명> -p <데이터베이스명> > backup.sql
```

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 인덱스(Index) | 검색 속도를 높이는 정렬된 보조 자료구조 |
| 파티션(Partition) | 테이블을 나눈 저장 단위 |
| ACID | 트랜잭션의 4가지 성질 |
| 반정규화 | 성능을 위해 의도적으로 중복을 허용하는 설계 |

## 5. 참조

| 참조 문서 | 비고 |
|---|---|
| [논리적 설계 개요](logicaldesignoverview.md) | DB-DSN-005-DO |
| [데이터베이스 구현 및 운영](implementation-and-maintenance.md) | DB-DSN-008-DO |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 인덱스를 모든 컬럼에 만들면 안 되는 이유는 무엇인가?
- [ ] 증분 백업과 차등 백업은 복구할 때 어떻게 다를까?
