# 데이터베이스 구현 및 운영

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-DSN-008-DO |
| 유형 | D&O (개념) |
| 목적 | 구현 및 운영 단계의 구축, 마이그레이션, 연동, 튜닝, 보안, 유지보수를 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 코드·SQL 예시를 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

구현 및 운영은 설계한 데이터베이스를 실제 환경에 구축하고 운영하며 유지보수하는 단계다. 목표는 다음과 같다.

1. 논리적·물리적 설계를 바탕으로 데이터베이스를 생성한다.
2. 애플리케이션과 연결해 동작하게 한다.
3. 데이터 처리 속도를 높인다.
4. 보안과 무결성을 유지하고 백업·복구 전략을 세운다.
5. 장애 복구와 성능 개선을 이어 간다.

## 2. 구성 요소

| 번호 | 항목 | 설명 |
|---|---|---|
| 1 | 데이터베이스 구축 | 설계한 스키마로 테이블을 생성한다 |
| 2 | 데이터 적재·마이그레이션 | 기존 시스템의 데이터를 옮긴다 |
| 3 | 애플리케이션 연동 | 애플리케이션에서 CRUD를 구현한다 |
| 4 | 성능 튜닝 | 쿼리와 인덱스를 최적화한다 |
| 5 | 보안·접근 제어 | 권한, 암호화, SQL Injection 방어를 적용한다 |
| 6 | 백업·복구 | 정기 백업과 복구 절차를 마련한다. [DB-DSN-007-DO](physical-design.md)의 백업·복구 전략을 따른다 |
| 7 | 운영·유지보수 | 로그 모니터링, 최적화, 패치를 수행한다 |

## 3. 동작 원리

### 3-1. 데이터베이스 구축

설계된 모델을 실제 데이터베이스로 변환한다.

```sql
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

* `user_id`는 기본 키이며 `AUTO_INCREMENT`로 자동 증가한다.
* `email`은 유니크 키다.
* 비밀번호는 원문이 아니라 해시값(`password_hash`)으로 저장한다.

### 3-2. 데이터 적재와 마이그레이션

기존 시스템의 데이터를 새 데이터베이스로 옮기는 과정이다.

| 방법 | 설명 |
|---|---|
| ETL (Extract, Transform, Load) | 추출, 변환, 적재 순서로 옮긴다 |
| Dump & Restore | 기존 데이터베이스의 백업을 새 DBMS에 복원한다 |
| 실시간 동기화(Replication) | 운영 중인 데이터베이스를 새 시스템과 동기화한다 |

```sql
INSERT INTO Users (username, email, password_hash)
VALUES ('<사용자명>', '<이메일>', '<해시값>');
```

### 3-3. 애플리케이션 연동

애플리케이션과 데이터베이스를 연결해 CRUD(Create, Read, Update, Delete)를 구현한다. 이 과정에서 서버(백엔드) 개발자가 API를 만든다.

| 방식 | 설명 |
|---|---|
| JDBC | Java 애플리케이션이 데이터베이스에 접속하는 표준 API |
| ODBC | 언어·플랫폼에 독립적인 데이터베이스 접속 표준 API |
| ORM | Django ORM처럼 객체로 데이터베이스를 다루는 방식 |

```python
import mysql.connector

conn = mysql.connector.connect(
    host="<호스트>",
    user="<사용자명>",
    password="<비밀번호>",
    database="<데이터베이스명>"
)

cursor = conn.cursor()
cursor.execute("SELECT * FROM Users")
for row in cursor.fetchall():
    print(row)

conn.close()
```

* 위 코드는 `Users` 테이블의 모든 행을 출력한다.

{% hint style="danger" %}
WARNING: 접속 정보(비밀번호)를 소스 코드에 직접 적지 않는다. 환경 변수나 비밀 관리 도구에 보관한다.
{% endhint %}

### 3-4. 성능 튜닝(Performance Tuning)

| 기법 | 설명 |
|---|---|
| 인덱스(Index) | 검색 속도를 높이기 위해 인덱스를 만든다 |
| JOIN 최적화 | 필요한 컬럼과 행만 가져오도록 쿼리를 고친다 |
| 캐싱(Cache) | 자주 쓰는 데이터를 메모리에 둔다 |

```sql
CREATE INDEX idx_username ON Users(username);
```

* 사용자 이름 기준 검색이 빨라진다.

### 3-5. 보안과 접근 제어

| 기법 | 설명 |
|---|---|
| 사용자 권한 설정 | `GRANT`, `REVOKE`로 권한을 제어한다 |
| 데이터 암호화 | 비밀번호와 민감 데이터를 암호화(비밀번호는 해시)해 저장한다 |
| SQL Injection 방지 | 파라미터 바인딩을 쓴다 |

```sql
CREATE USER 'app_user'@'localhost' IDENTIFIED BY '<비밀번호>';
GRANT SELECT, INSERT, UPDATE ON mydb.Users TO 'app_user'@'localhost';
```

* 애플리케이션 계정에는 필요한 권한만 부여한다.

### 3-6. 운영 및 유지보수

| 작업 | 설명 |
|---|---|
| 로그 모니터링 | 슬로 쿼리 로그와 에러 로그를 확인한다 |
| 데이터베이스 최적화 | 쿼리 성능을 점검하고 파티셔닝을 적용한다 |
| 보안 패치·업그레이드 | 최신 보안 패치를 적용한다 |

```sql
SHOW GLOBAL STATUS LIKE 'Slow_queries';
```

* 느린 쿼리 수를 확인해 튜닝 대상을 찾는다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| ETL | 추출·변환·적재 |
| CRUD | 생성·조회·수정·삭제 |
| ORM | 객체-관계 매핑 |
| 파라미터 바인딩 | SQL 문과 값을 분리해 전달하는 방식 |

## 5. 참조

| 참조 문서 | 비고 |
|---|---|
| [물리적 설계](physical-design.md) | DB-DSN-007-DO |
| [데이터베이스 설계 개요](databasedesignoverview.md) | DB-DSN-001-DO |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] SQL Injection은 무엇이며 파라미터 바인딩이 왜 막아 줄까?
- [ ] 운영 중인 데이터베이스가 느려졌다면 가장 먼저 무엇을 확인하겠는가?
