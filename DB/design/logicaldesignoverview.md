# 논리적 설계 개요

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-DSN-005-DO |
| 유형 | D&O (개념) |
| 목적 | ERD를 관계형 모델(테이블, 키, 제약 조건)로 변환하는 과정을 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 SQL 예시를 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

논리적 설계는 개념적 설계의 ERD를 관계형 데이터베이스(RDBMS)의 모델로 변환하는 단계다. 정규화로 데이터 중복을 줄이고 무결성을 유지한다.

목표는 다음과 같다.

1. 엔터티, 속성, 관계를 테이블, 컬럼, 키 구조로 변환한다.
2. 정규화로 중복을 줄이고 무결성(Integrity)과 일관성(Consistency)을 유지한다.
3. PK, FK, UNIQUE, NOT NULL 같은 무결성 제약 조건을 정의한다.
4. 최종 스키마를 `CREATE TABLE` 문으로 정리한다.

## 2. 구성 요소

| 번호 | 작업 | 설명 |
|---|---|---|
| 1 | 엔터티 변환 | 엔터티를 테이블(Table)로 변환한다 |
| 2 | 속성 변환 | 속성을 컬럼(Column)과 데이터 타입으로 변환한다 |
| 3 | 키 정의 | 기본 키(PK)와 외래 키(FK)를 정한다 |
| 4 | 관계 정의 | 관계를 FK로 변환한다. N:M 관계는 연결 테이블로 푼다 |
| 5 | 정규화 | 중복과 이상 현상을 줄인다. [DB-DSN-006-DO](databasenormalization.md)를 따른다 |
| 6 | 제약 조건 설정 | NULL 여부, UNIQUE, CHECK, DEFAULT를 정한다 |
| 7 | 스키마 작성 | 최종 SQL 테이블을 정의한다 |

제약 조건은 다음과 같다.

| 제약 조건 | 설명 |
|---|---|
| PRIMARY KEY | 행을 유일하게 식별한다. 중복과 NULL을 허용하지 않는다 |
| FOREIGN KEY | 다른 테이블의 키를 참조한다 |
| UNIQUE | 중복 값을 허용하지 않는다(NULL 허용 여부는 DBMS마다 다르다) |
| NOT NULL | NULL 값을 허용하지 않는다 |
| CHECK | 지정한 조건을 만족해야 한다 |
| DEFAULT | 값을 넣지 않았을 때 쓸 기본값을 정한다 |

## 3. 동작 원리

### 3-1. ERD를 테이블로 변환

ERD 예시는 다음과 같다.

```
[학생(Student)] 1 ─── N [수강(Enrollment)] N ─── 1 [강의(Course)]
```

* 학생 엔터티는 Student 테이블, 강의 엔터티는 Course 테이블로 변환한다.
* 수강 엔터티는 Enrollment 테이블로 변환한다. 학생과 강의의 N:M 관계를 푸는 연결 테이블이다.

변환 결과는 다음과 같다.

| 테이블 | 컬럼 |
|---|---|
| Student | student_id(PK), name, department |
| Course | course_id(PK), course_name, credits |
| Enrollment | student_id(FK), course_id(FK), grade |

### 3-2. 속성을 컬럼으로 변환

| 엔터티 | 속성 | 컬럼 | 데이터 타입 |
|---|---|---|---|
| Student | 학번 | student_id (PK) | INT |
| Student | 이름 | name | VARCHAR(50) |
| Student | 학과 | department | VARCHAR(50) |
| Course | 강의번호 | course_id (PK) | INT |
| Course | 강의명 | course_name | VARCHAR(100) |
| Course | 학점 | credits | INT |

### 3-3. 키 정의

| 테이블 | 기본 키(PK) | 외래 키(FK) |
|---|---|---|
| Student | student_id | 없음 |
| Course | course_id | 없음 |
| Enrollment | student_id, course_id (복합 키) | student_id → Student(student_id), course_id → Course(course_id) |

### 3-4. 관계 정의와 최종 스키마

```sql
CREATE TABLE Student (
    student_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    department VARCHAR(50)
);

CREATE TABLE Course (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    credits INT CHECK (credits > 0)
);

CREATE TABLE Enrollment (
    student_id INT,
    course_id INT,
    grade CHAR(2),
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
);
```

* Enrollment의 `student_id`는 Student 테이블을, `course_id`는 Course 테이블을 참조한다.
* Enrollment의 PK는 두 컬럼을 묶은 복합 키다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| RDBMS | 관계형 데이터베이스 관리 시스템 |
| 무결성(Integrity) | 데이터가 정확하고 일관된 상태 |
| 복합 키(Composite Key) | 둘 이상의 컬럼으로 이루어진 키 |
| 연결 테이블 | N:M 관계를 1:N 두 개로 풀기 위한 테이블 |

## 5. 참조

| 참조 문서 | 비고 |
|---|---|
| [개념적 설계](conceptual-design.md) | DB-DSN-004-DO |
| [데이터베이스 정규화](databasenormalization.md) | DB-DSN-006-DO |
| [물리적 설계](physical-design.md) | DB-DSN-007-DO |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 기본 키와 외래 키는 각각 어떤 문제를 막아 주는가?
- [ ] 외래 키 제약이 없으면 어떤 잘못된 데이터가 들어갈 수 있을까?
