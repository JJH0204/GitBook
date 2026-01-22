# 구현 및 운영 (Implementation & Maintenance)

## 구현 및 운영 이란?

* 설계된 데이터베이스를 실제 환경에 구축하고 운영하면서 유지보수하는 과정
* 데이터베이스를 실제 시스템에 적용하고 최적화하는 단계

***

## 구현 및 운영 단계의 목표

1. **데이터베이스 구축** → 논리적, 물리적 설계를 바탕으로 실제 데이터베이스를 생성
2. **애플리케이션과 연동** → 데이터베이스를 애플리케이션과 연결하여 동작하도록 설정
3. **성능 최적화** → 데이터 처리 속도를 높이고 효율적인 데이터 관리를 수행
4. **보안 및 무결성 유지** → 데이터 보호 및 백업/복구 전략 수립
5. **장기적인 유지보수** → 장애 복구 및 성능 개선

***

## 구현 및 운영의 주요 단계

<table><thead><tr><th width="241">단계</th><th>설명</th></tr></thead><tbody><tr><td><a href="implementation-and-maintenance.md#db-implementation">데이터베이스 구축</a></td><td>논리적, 물리적 설계를 기반으로 실제 DBMS에 테이블 생성</td></tr><tr><td><a href="implementation-and-maintenance.md#undefined-3">데이터 적재 및 마이그레이션</a></td><td>기존 데이터 이전 및 초기 데이터 삽입</td></tr><tr><td><a href="implementation-and-maintenance.md#undefined-4">애플리케이션과 연동</a></td><td>데이터베이스와 애플리케이션을 연결하여 CRUD 구현</td></tr><tr><td><a href="implementation-and-maintenance.md#performance-tuning">성능 튜닝</a></td><td>인덱스 최적화, 쿼리 최적화, 캐싱 설정 등 성능 개선</td></tr><tr><td><a href="implementation-and-maintenance.md#security-and-access-control">보안 및 접근 제어</a></td><td>사용자 권한 설정, 암호화, 데이터 무결성 유지</td></tr><tr><td><a href="implementation-and-maintenance.md#backup-and-recovery">백업 및 복구 전략 수립</a></td><td>장애 발생 시 데이터를 복원할 수 있도록 백업 정책 마련</td></tr><tr><td><a href="implementation-and-maintenance.md#database-maintenance">운영 및 유지보수</a></td><td>장애 대응, 보안 패치, 성능 최적화 등 지속적인 유지관리</td></tr></tbody></table>

***

### 데이터베이스 구축(DB Implementation)

🎯 테이블 생성 및 스키마 적용

* 설계된 논리적, 물리적 모델을 실제 데이터베이스로 변환하는 과정

```sql
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

* Primary Key 설정 → user\_id
* Unique Key 설정 → email
* 자동 생성 값(AUTO\_INCREMENT) 적용

### 데이터 적재 및 마이그레이션

* 기존 시스템에서 새로운 데이터베이스로 데이터를 이전(데이터 마이그레이션, Data Migration)하는 과정

🎯 마이그레이션 전략

| 방법                                       | 설명                                               |
| ---------------------------------------- | ------------------------------------------------ |
| <p>ETL<br>(Extract, Transform, Load)</p> | 데이터를 추출(Extract) → 변환(Transform) → 적재(Load)하는 방식 |
| Dump & Restore                           | 기존 데이터베이스에서 백업을 생성한 후, 새로운 DBMS에 복원              |
| <p>실시간 동기화<br>(Replication)</p>          | 운영 중인 데이터베이스를 새로운 시스템과 동기화                       |

```sql
INSERT INTO Users (username, email, password_hash) 
VALUES ('Alice', 'alice@example.com', 'hashed_password');
```

### 애플리케이션과 연동

* 데이터베이스를 실제 애플리케이션과 연결하여 CRUD(Create, Read, Update, Delete) 연산을 구현하는 단계
* 이 과정에서 서버(Back-end) 개발자에 의해 API를 구현하게 된다.

🎯 애플리케이션과 데이터베이스 연결 방식

| 방식   | 설명                           |
| ---- | ---------------------------- |
| JDBC | Java 애플리케이션에서 데이터베이스와 연결     |
| ODBC | 운영체제에서 데이터베이스 연결을 지원         |
| ORM  | Django ORM 등 객체 기반 데이터베이스 관리 |

```python
import mysql.connector

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="password",
    database="mydb"
)

cursor = conn.cursor()
cursor.execute("SELECT * FROM Users")
for row in cursor.fetchall():
    print(row)

conn.close()
```

* 애플리케이션에서 데이터 조회 가능

### 성능 튜닝(Performance Tuning)

* 데이터베이스 속도를 높이기 위해 다양한 최적화 기법을 적용한다.

🎯 쿼리 최적화 (Query Optimization)

| 최적화 기법     | 설명                        |
| ---------- | ------------------------- |
| 인덱스(Index) | 검색 속도를 높이기 위해 인덱스 생성      |
| JOIN 최적화   | 필요한 데이터만 불러올 수 있도록 쿼리 최적화 |
| 캐싱(Cache)  | 자주 사용하는 데이터를 메모리에 저장      |

```sql
CREATE INDEX idx_username ON Users(username);
```

* 인덱스 생성을 통해 사용자 이름을 기준으로 빠르게 검색 가능

### 보안 및 접근 제어 (Security & Access Control)

* 데이터 유출 방지 및 보안성을 높이기 위해 보안 정책을 적용해야 한다.

🎯 보안 정책

| 보안 기법            | 설명                       |
| ---------------- | ------------------------ |
| 사용자 권한 설정        | GRANT, REVOKE 명령어로 권한 제어 |
| 데이터 암호화          | 비밀번호, 민감 데이터 암호화 저장      |
| SQL Injection 방지 | 파라미터 바인팅 사용하여 공격 방어      |

```sql
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'securepassword';
GRANT SELECT, INSERT, UPDATE ON mydb.Users TO 'app_user'@'localhost';
```

* 사용자 계정 및 권한 설정을 통해 **애플리케이션 계정에 필요한 권한만 부여**

### 백업 및 복구 전략 (Backup & Recovery)

* 데이터 손실을 방지하기 위해 정기적인 백업 및 복구 전략을 수립해야 한다.
* [백업 및 복구 전략에 대하여](physical-design.md#undefined-4)

### 운영 및 유지보수 (Database Maintenance)

* 데이터베이스를 안정적으로 운영하고 장애가 발생했을 때 대응하는 과정

🎯 운영 및 유지보수 작업

| 유지보수 작업       | 설명                         |
| ------------- | -------------------------- |
| 로그 모니터링       | slow query 로그 분석, 에러 로그 확인 |
| 데이터베이스 최적화    | 쿼리 성능 점검, 파티셔닝 적용          |
| 보안 패치 및 업그레이드 | 최신 보안 패치 적용                |

```sql
SHOW GLOBAL STATUS LIKE 'Slow_queries';
```

* **느린 쿼리 조회**를 통해 튜닝 가능
