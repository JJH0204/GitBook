# 논리적 설계 (Logical Design)

## 논리적 설계란?

* 개념적 설계에서 작성된 ERD를 관계형 데이터베이스 모델(RDBMS)로 변환하는 과정이다.
* 정규화(Normalization)을 수행하여 데이터 중복을 최소화하고 무결성을 유지한다.

***

## 논리적 설계의 목표

1. 개념적 설계를 관계형 모델로 변환
   * ERD에서 정의된 엔터티(Entity), 속성(Attribute), 관계(Relationship)을 테이블(Table), 컬럼(Column), 키(Key) 구조로 변환
2. 데이터 정규화
   * 데이터 중복을 줄이고, 무결성(Integrity)과 일관성(Consistency)을 유지하기 위해 정규화를 적용
3. 데이터 무결성 제약 조건 정의
   * 기본 키(Primary Key, PK), 외래 키(Foreign Key, FK), 고유 제약(Unique Constraint), NOT NULL 조건 등을 설정하여 데이터 품질 유지
4. SQL 테이블 설계
   * 최종적으로 SQL CREATE TABLE 문으로 변환하여 실제 데이터베이스에서 사용할 수 있도록 준비

***

## 논리적 설계의 주요 과정

| 단계                                        | 설명                                              |
| ----------------------------------------- | ----------------------------------------------- |
| [개념적 설계](./#greater-than)                 | 엔터티를 테이블(Table)로 변환                             |
| [속성(Attribute)변환](./#attribute)           | 엔터티의 속성을 테이블의 컬럼(Column)으로 변환                   |
| [키(Key)정의](./#key)                        | 기본 키(Primary Key, PK)와 외래 키(Foreign Key, FK) 설정 |
| [정규화(Normalization) 수행](./#normalization) | 데이터 중복을 최소화하고 무결성을 유지                           |
| 제약 조건(Constraints) 설정                     | NULL 여부, UNIQUE, CHECK, DEFAULT 값 설정            |
| 관계 정의                                     | 엔터티 간 관계를 테이블의 FK로 변환                           |
| 테이블 스키마 설계                                | 최종적으로 SQL 테이블을 정의                               |

***

### 개념적 설계 > 관계형 모델 변환

* 개념적 설계에서 ERD를 만들었다면, 논리적 설계에서는 이를 관계형 데이터베이스(RDB)에서 사용할 수 있도록 변환해야 한다.

1. 개념적 설계(ERD 예시)

```
[학생(Student)] 1 ─── N [수강(Enrollment)] N ─── 1 [강의(Course)]
```

```
- 학생(Student) 엔터티 > Student 테이블
- 강의(Course) 엔터티 > Course 테이블
- 수강(Enrollment) 엔터티 > Enrollment 테이블
  (학생과 강의의 관계를 나타냄, 다대다 해결)
```

2\) 논리적 설계 변환 후 테이블 구조

| 엔터티        | 속성                                     |
| ---------- | -------------------------------------- |
| Student    | student\_id(PK), name, department      |
| Course     | course\_id(PK), course\_name, credits  |
| Enrollment | student\_id(FK), course\_id(FK), grade |

***

### 속성(Attribute) 변환

* 각 엔터티의 속성은 테이블의 컬럼(Column)으로 변환된다.
* 예제

| 엔터티     | 속성   | 컬럼               | 데이터 타입       |
| ------- | ---- | ---------------- | ------------ |
| Student | 학번   | student\_id (PK) | INT          |
| Student | 이름   | name             | VARCHAR(50)  |
| Student | 학과   | department       | VARCHAR(50)  |
| Course  | 강의번호 | course\_id (PK)  | INT          |
| Course  | 강의명  | course\_name     | VARCHAR(100) |
| Course  | 학점   | credits          | INT          |

***

### 키(Key) 정의

* 테이블의 기본 키(Primary Key, PK)와 외래 키(Foreign Key, FK)를 설정한다.
* 예제

| 테이블        | 기본 키(PK)                | 외래 키(FK)                                                                   |
| ---------- | ----------------------- | -------------------------------------------------------------------------- |
| Student    | student\_id             | -                                                                          |
| Course     | course\_id              | -                                                                          |
| Enrollment | student\_id, course\_id | <p>student_id ><br>Student(student_id)course_id ><br>Course(course_id)</p> |

***

### 정규화(Normalization) 수행

* 정규화는 데이터 중복을 최소화하고 무결성을 유지하기 위한 과정이다.
* [정규화에 대해서](normalization.md)

***
### 제약 조건(Constrainsts) 설정
- 제약 조건을 추가하여 데이터 무결성을 보장해야 한다.

| 제약 조건       | 설명                 |
| ----------- | ------------------ |
| PRIMARY KEY | 중복되지 않는 유일한 값 (PK) |
| FOREIGN KEY | 다른 테이블의 값을 참조 (FK) |
| UNIQUE      | 중복된 값 허용 불가        |
| NOT NULL    | NULL 값 입력 불가능      |
| CHECK       | 특정 조건을 만족해야 함      |
| DEFAULT     | 기본값 설정 가능          |
- [무결성 정책에 대해서](integrity.md)
---
### 관계 정의(Foreign Key 설정)
- 외래 키(FK)를 설정하여 테이블 간 관계를 유지해야 한다.
~~~sql
CREATE TABLE Enrollment (
    student_id INT,
    course_id INT,
    grade CHAR(2),
    PRIMARY KEY (student_id, course_id),  -- 복합키
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
);
~~~
- Enrollment 테이블의 student_id는 Student 테이블을 참조한다.
- course_id는 Course 테이블을 참조한다.
---
### 최종 테이블 스키마(SQL)
~~~sql
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
~~~