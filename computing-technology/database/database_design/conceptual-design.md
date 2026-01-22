# 개념적 설계 (Conceptual Design)

## 개념적 설계란?

* 데이터베이스 설계 과정 중 **사용자의 요구사항을 분석하고, ERD(Entity-Relationship Diagram)를 작성하여 데이터 구조를 시각적으로 표현하는 단계**이다.
* 이 단계에서 **논리적, 물리적 구조에 대한 고려 없이, 데이터 간의 관계를 개념적으로 정의하는 것이 핵심**이다.

***

## 개념적 설계의 주 목표

1. **데이터 모델링**
2. **사용자의 요구사항을 데이터 모델로 변환**
3. **ERD(Entity-Relationship Diagram) 작성**

***

## 개념적 설계의 주요 요소

* ER 모델(Entity-Relationship Model)을 사용하여 데이터 구조를 표현하는데, 이를 구성하는 주요 요소는 아래와 같다.

| 요소               | 설명                              | 예시                      |
| ---------------- | ------------------------------- | ----------------------- |
| 엔터티(Entity, 개체)  | 독립적으로 존재하는 데이터 개체 (테이블로 변환된다.)  | 학생(Student), 강의(Course) |
| 속성(Attribute)    | 엔터티가 가지는 속성 (필드로 변환된다.)         | 학생(학번, 이름, 학과)          |
| 관계(Relationship) | 엔터티 간의 연관성 (Foreign Key로 변환된다.) | 학생 - 수강 - 강의            |
| 키(Key)           | 엔터티를 고유하게 식별하는 속성 (Primary Key) | 학생 ID (Primary Key)     |

***

## 개념적 설계의 단계별 수행 절차

### 1. [요구사항 분석](requirement-analysis/)

* 사용자 인터뷰, 문서 분석, 설문 조사 등을 통해 저장해야 할 데이터와 기능을 정의.
* 비지니스 규칙을 파악하여 데이터 관계를 정의

### 2. 엔터티(Entity) 정의

* 시스템에서 관리할 **핵심 개체(엔터티)를 식별**
* 엔터티는 **데이터베이스의 테이블로 변환될 개념적인 요소**

| 엔터티            | 설명             |
| -------------- | -------------- |
| 학생(Student)    | 학생 정보 관리       |
| 강의(Course)     | 개설된 강의 정보      |
| 교수(Professor)  | 강의를 담당하는 교수 정보 |
| 수강(Enrollment) | 학생이 강의를 등록한 정보 |

***

### 3. 속성(Attribute) 정의

* 각 엔터티가 가지는 **특성(속성)을 정의**
* 속성은 테이블의 필드(컬럼)로 변환된다.
* 각 엔터티는 **Primary Key(PK)** 가 포함되어야 한다.

| 엔터티            | 속성 (Attribute)              |
| -------------- | --------------------------- |
| 학생(Student)    | 학생ID(PK), 이름, 학과, 입학년도      |
| 강의(Course)     | 강의ID(PK), 강의명, 학점, 교수ID(FK) |
| 교수(Professor)  | 교수ID(PK), 이름, 전공            |
| 수강(Enrollment) | 학생ID(FK), 강의 ID (FK), 성적    |

***

### 4. 관계(Relationship) 정의

* 엔터티 간의 연관성을 정의한다.
* 관계는 1:1, 1:N, N:N 관계로 나뉜다.

| 관계                                        | 설명                        |
| ----------------------------------------- | ------------------------- |
| 학생(Student) - 수강(Enrollment) - 강의(Course) | 학생은 여러 강의를 수강할 수 있음 (N:N) |
| 교수(Professor) - 강의(Course)                | 교수는 여러 강의를 담당할 수 있음 (1:N) |

***

### 5. ER 다이어그램(Entity-Relationship Diagram) 작성

* 데이터 관계를 시각적으로 표현.

```
[학생] 1 - N [수강] N - 1 [강의]
[교수] 1 - N [강의]
```

(위 관계를 SQL 테이블로 변환하면 아래와 같다.)

```sql
CREATE TABLE Student (
    student_id INT PRIMARY KEY,
    name VARCHAR(50),
    department VARCHAR(50),
    enrollment_year INT
);

CREATE TABLE Professor (
    professor_id INT PRIMARY KEY,
    name VARCHAR(50),
    major VARCHAR(50)
);

CREATE TABLE Course (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    credits INT,
    professor_id INT,
    FOREIGN KEY (professor_id) REFERENCES Professor(professor_id)
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

***

## 개념적 설계의 장점

1. 데이터 관계를 명확히 정의할 수 있다.
2. 시각적 모델링이 가능하여 직관적 이해가 쉽다.
3. 데이터 중복을 방지하고 정규화 과정이 용이해진다.
4. 비지니스 규칙과 데이터 모델을 일치시킬 수 있다.

***
