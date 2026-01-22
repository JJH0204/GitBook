# 물리적 설계 (Physical Design)

## 물리적 설계란?

* 논리적 설계를 실제 데이터베이스에서 최적의 성능을 발휘하도록 구현하는 과정
* 데이터를 저장하는 구조, 접근 속도, 성능 최적화, 인덱스 설계 등을 결정하는 단계
* [**저장 구조 설계**](physical-design.md#storage-structure-design) **→** [**파일 조직 방식**](physical-design.md#file-organization) **→** [**인덱스 설계**](physical-design.md#index-design) **→** [**파티셔닝 설계**](physical-design.md#partitioning) **→** [**뷰(view) 설계**](physical-design.md#view) **→** [**트랜잭션 제어**](physical-design.md#undefined-3) **→** [**백업 및 복구**](physical-design.md#undefined-4) 순으로 작업이 진행된다.

***

## 물리적 설계의 목표

1. **데이터 저장 효율성 극대화** → 스토리지(디스크) 공간 활용 최적화
2. **데이터 검색 및 처리 속도 향상** → 빠른 조회 및 삽입/수정/삭제 최적화
3. **시스템 부하 감소** → 인덱스, 파티셔닝, 클러스터링 등으로 성능 개선
4. **데이터 무결성 및 보안 유지** → 백업 및 복구, 보안 정책 적용

***

## 물리적 설계의 주요 단계

| 단계                                                      | 설명                                                |
| ------------------------------------------------------- | ------------------------------------------------- |
| [저장 구조 설계](physical-design.md#storage-structure-design) | 테이블 및 데이터 저장소의 구조를 정의                             |
| [파일 조직 방식 선택](physical-design.md#file-organization)     | <p>테이터를 저장하는 방식<br>(Heap, Clustered, Indexed)</p> |
| [인덱스 설계](physical-design.md#index-design)               | 검색 기능을 높이기 위한 인덱스 생성                              |
| [파티셔닝 설계](physical-design.md#partitioning)              | 데이터를 분할하여 저장하여 성능 향상                              |
| [뷰(view) 설계](physical-design.md#view)                   | 보안 및 성능 최적화를 위해 논리적 뷰 제공                          |
| [트랜잭션 및 동시성 제어](physical-design.md#undefined-3)         | ACID 원칙 적용 및 동시 접근 관리                             |
| [백업 및 복구 전략](physical-design.md#undefined-4)            | 데이터 손실 방지를 위한 백업 및 복구 방안 설정                       |

***

### 저장 구조 설계(Storage Structure Design)

🎯 테이블 설계 (Table Design)

* **컬럼의 데이터 타입(Data Type) 최적화**
  * INTEGER 대신 TINYINT, SMALLINT 사용 → **메모리 절약**
  * VARCHAR 대신 CHAR 사용 → **고정 길이 데이터 성능 향상**
* **컬럼 크기 최소화**
  * VARCHAR(1000) 대신 VARCHAR(255) → **불필요한 공간 낭비 방지**

```sql
CREATE TABLE Users (
    user_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

* INT UNSIGNED → 음수 값 필요 없음 (저장 공간 절약)
* VARCHAR(50) → 가변 길이 사용 (저장 공간 절약)
* TIMESTAMP DEFAULT CURRENT\_TIMESTAMP → 자동으로 생성 시간 저장

***

### 파일 조직 방식 (File Organization)

🎯 파일 조직이란?

* 데이터 베이스에 데이터를 어떤 방식으로 저장하고 관리할 것인지 결정하는 과정

| 파일 조직 방식                    | 설명                     | 특징                               |
| --------------------------- | ---------------------- | -------------------------------- |
| Heap 파일 구조                  | 테이블에 데이터를 순서 없이 저장     | <p>삽입 속도가 빠름,<br>검색 속도가 느림</p>   |
| <p>클러스터링<br>(Clustered)</p> | 같은 범주의 데이터를 인접한 위치에 저장 | 범위 검색 성능 향상                      |
| 인덱스 파일 구조                   | 인덱스를 사용하여 데이터를 정렬      | <p>검색 속도 향상,<br>인덱스 유지 비용 발생</p> |

***

### 인덱스 설계 (Index Design)

🎯 인덱스란?

* 데이터 검색 속도를 향상시키기 위해 테이블의 특정 칼럼을 기준으로 정렬하는 자료구조

🎯 인덱스 종류

| 유형                      | 설명                            |
| ----------------------- | ----------------------------- |
| Primary Index(클러스터형)    | 기본 키(Primary Key)를 기준으로 자동 생성 |
| Secondary Index(보조 인덱스) | 기본 키 외의 컬럼에 대해 인덱스 생성         |
| Unique Index            | 중복을 허용하지 않는 인덱스               |
| Full-Text Index         | 텍스트 검색을 최적화하는 인덱스             |
| Bitmap Index            | 값의 종류가 적은 컬럼에 최적화됨            |

```sql
CREATE INDEX idx_username ON Users(username);
```

* username 컬럼에 대한 **검색 속도 향상**

```sql
CREATE INDEX idx_user_email ON Users(username, email);
```

* **두 개 이상의 컬럼을 조합하여 검색 성능 향상**

***

### 파티셔닝 설계 (Partitioning)

🎯 파티셔닝이란?

* 여러 개의 물리적 파티션으로 분할하여 저장하는 방식

🎯 파티셔닝 유형

| 방식                     | 설명                      |
| ---------------------- | ----------------------- |
| Range Partitioning     | 특정 범위(예: 날짜)별로 데이터 분할   |
| List Partitioning      | 특정 값(예: 국가, 지역 코드)으로 분할 |
| Hash Partitioning      | 해시(Hash) 값을 기준으로 데이터 분산 |
| Composite Partitioning | 여러 개의 파티션 방식을 결합        |

```sql
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    total_price DECIMAL(10,2)
)
PARTITION BY RANGE (YEAR(order_date)) (
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024)
);
```

* 2022년 데이터 → p2022 파티션, 2023년 데이터 → p2023 파티션
* 검색 성능 향상

***

### 뷰(View) 설계

🎯 뷰 란?

* 가상 테이블로서 복잡한 쿼리를 단순화하고, 보안성을 강화하기 위해 사용된다.

```sql
CREATE VIEW UserView AS
SELECT user_id, username, email FROM Users;
```

* 뷰를 통해 특정 컬럼만 조회 가능 → 보안 강화

***

### 트랜잭션 및 동시성 제어

🎯 트랜잭션 이란?

* 데이터의 일관성을 유지하기 위한 작업 단계
* ACID 원칙(Atomicity, Consistency, Isolation, Durability)을 적용.

```sql
START TRANSACTION;
UPDATE Accounts SET balance = balance - 500 WHERE user_id = 1;
UPDATE Accounts SET balance = balance + 500 WHERE user_id = 2;
COMMIT;
```

* **모든 연산이 성공해야 반영(Commit), 실패 시 롤백(Rollback)**

***

### 백업 및 복구 전략

🎯 백업 방법

| 방식                  | 설명                     |
| ------------------- | ---------------------- |
| Full Backup         | 전체 데이터베이스 백업           |
| Incremental Backup  | 변경된 데이터만 백업            |
| Differential Backup | 마지막 풀 백업 이후 변경된 데이터 백업 |

```bash
mysqldump -u root -p mydb > backup.sql
```
