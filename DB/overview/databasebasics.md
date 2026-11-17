# 데이터베이스 기초 (Database Basics)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-OVW-001-DO |
| 유형 | D&O (개념) |
| 목적 | SQL 언어의 네 분류, CRUD, 집계·그룹화, 인덱스 종류, 조인의 개념을 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 MariaDB 문서 지식을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 실습 단계는 [학생 실습 데이터베이스 생성](databasebasics-practice.md)(DB-OVW-003-MP)으로, 질의 예시는 [기본 조회 질의 예시](databasebasics-queries.md)(DB-OVW-004-REF)로 나눴다. 이 문서는 개념만 다룬다.
{% endhint %}

## 1. 목적

데이터베이스는 데이터를 구조화해 저장하고, SQL(Structured Query Language)로 생성·조회·변경·삭제하는 체계다. 이 문서는 SQL 문장을 기능별로 분류하고, 조회에 쓰는 핵심 개념을 정리한다.

## 2. 구성 요소

### 2.1 SQL 언어 분류

| 분류 | 이름 | 역할 | 주요 문장 |
|---|---|---|---|
| DDL | Data Definition Language, 데이터 정의어 | 객체(데이터베이스, 테이블)의 구조를 만들고 바꾼다 | `create`, `alter`, `drop`, `truncate`, `rename` |
| DML | Data Manipulation Language, 데이터 조작어 | 데이터를 조회·입력·수정·삭제한다 | `select`, `insert`, `update`, `delete` |
| DCL | Data Control Language, 데이터 제어어 | 권한을 부여하고 회수한다 | `grant`, `revoke` |
| TCL | Transaction Control Language, 트랜잭션 제어어 | 변경을 확정하거나 취소한다 | `commit`, `rollback`, `savepoint` |

{% hint style="info" %}
NOTE: `select`를 DML에서 분리해 DQL(Data Query Language)로 부르는 교재도 있다. 이 문서는 원본대로 DML에 포함한다.
{% endhint %}

### 2.2 CRUD

| 약자 | 뜻 | SQL 문장 |
|---|---|---|
| C | Create, 데이터 생성 | `insert` |
| R | Read, 데이터 읽기 | `select` |
| U | Update, 데이터 갱신 | `update` |
| D | Delete, 데이터 삭제 | `delete` |

### 2.3 그룹화와 정렬

| 항목 | 설명 |
|---|---|
| `group by <칼럼>` | `group by` 뒤에 적은 칼럼의 값이 같은 행끼리 묶는다. 묶은 그룹마다 결과 행이 하나 나온다 |
| `order by <칼럼> [asc\|desc]` | 결과를 정렬한다. `asc`는 오름차순(기본값), `desc`는 내림차순이다 |
| `having <조건>` | 그룹화한 결과에 조건을 건다. 집계 함수를 조건에 쓸 수 있다. `where`는 그룹화 전의 행에 조건을 건다 |

{% hint style="info" %}
NOTE: 원본은 "첫 번째 칼럼을 기준으로 그룹화 진행"이라고 적었다. 그룹화 기준은 선택 목록의 첫 칼럼이 아니라 `group by` 절에 적은 칼럼이다. 정정했다.
{% endhint %}

### 2.4 집계 함수

| 함수 | 결과 |
|---|---|
| `sum(<칼럼>)` | 합계 |
| `avg(<칼럼>)` | 평균 |
| `max(<칼럼>)`, `min(<칼럼>)` | 최댓값, 최솟값 |
| `count(<칼럼>)` | 행 개수 (`count(*)`는 NULL 포함 전체 행) |
| `std(<칼럼>)`, `stddev(<칼럼>)` | 표준편차 |

{% hint style="info" %}
NOTE: 원본은 표준편차를 `stdev`로 적었다. `stdev`는 SQL Server의 함수 이름이다. MariaDB는 `std`, `stddev`를 쓴다. 정정했다. 확인 필요.
{% endhint %}

### 2.5 인덱스 종류

| 종류 | 중복 | 설명 |
|---|---|---|
| primary | 불가 | 기본 키. 행을 유일하게 식별한다. NULL도 불가능하다 |
| unique | 불가 | 칼럼 값의 중복을 금지한다 |
| normal | 허용 | 중복을 허용하는 일반 인덱스다. 조회 속도를 높이는 용도다 |
| full text | 허용 | 자연어(문장) 검색용 인덱스다 |
| foreign | 해당 없음 | 테이블 간 관계를 부여하는 외래 키 제약이다 |

{% hint style="info" %}
NOTE: 외래 키(foreign key)는 인덱스 종류가 아니라 제약 조건이다. InnoDB는 외래 키 칼럼에 인덱스를 자동으로 만든다. 원본의 분류를 유지하되 성격을 구분해 적었다. 확인 필요.
{% endhint %}

### 2.6 조인 종류

| 종류 | 결과 |
|---|---|
| `inner join` | 양쪽 테이블에서 조건이 일치하는 행만 나온다 |
| `left join` (left outer join) | 왼쪽 테이블의 모든 행이 나온다. 오른쪽에 일치하는 행이 없으면 오른쪽 칼럼은 NULL이다 |
| `right join` (right outer join) | 오른쪽 테이블의 모든 행이 나온다. 왼쪽에 일치하는 행이 없으면 왼쪽 칼럼은 NULL이다 |

{% hint style="info" %}
NOTE: 원본은 OUTER JOIN, LEFT JOIN, RIGHT JOIN 제목만 있고 내용이 없었다. 위 표의 설명은 원본에 없던 내용을 추가한 것이다.
{% endhint %}

## 3. 동작 원리

한 문장의 `select`는 아래 순서로 처리된다고 이해하면 질의를 읽기 쉽다.

1. `from`, `join`이 대상 테이블과 결합 행을 정한다.
2. `where`가 행을 걸러낸다.
3. `group by`가 행을 그룹으로 묶는다. 집계 함수는 이 그룹 단위로 계산된다.
4. `having`이 그룹을 걸러낸다.
5. `select`가 출력할 칼럼을 정한다.
6. `order by`가 결과를 정렬한다.

질의 예시는 DB-OVW-004-REF를 본다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| SQL | Structured Query Language. 관계형 데이터베이스 질의 언어 |
| DBMS | Database Management System. 데이터베이스 관리 시스템 |
| RDBMS | 관계형 DBMS. MariaDB, MySQL, PostgreSQL 등 |
| 스키마(schema) | 테이블과 칼럼 구조의 정의 |
| 인덱스(index) | 조회 속도를 높이려고 따로 유지하는 검색 구조 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `where`와 `having`의 차이를 내 말로 설명해 보자.
- [ ] `inner join`과 `left join`의 결과가 달라지는 경우를 내가 만든 예로 적어 보자.
- [ ] 인덱스를 많이 만들면 조회와 입력 속도가 각각 어떻게 달라질지 내 생각을 적어 보자.
