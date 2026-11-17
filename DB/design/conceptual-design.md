# 개념적 설계 (Conceptual Design)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-DSN-004-DO |
| 유형 | D&O (개념) |
| 목적 | 개념적 설계의 구성 요소와 ERD 작성 순서를 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 SQL 예시를 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

개념적 설계는 요구사항을 바탕으로 ER 모델(Entity-Relationship Model)을 만들어 데이터 구조를 시각적으로 표현하는 단계다. 논리적·물리적 구조는 고려하지 않고 데이터 간 관계를 개념적으로 정의하는 것이 핵심이다.

목표는 다음과 같다.

1. 데이터를 모델링한다.
2. 사용자의 요구사항을 데이터 모델로 변환한다.
3. ERD를 작성한다.

## 2. 구성 요소

| 번호 | 요소 | 설명 | 예시 | 논리적 설계에서의 변환 |
|---|---|---|---|---|
| 1 | 엔터티(Entity, 개체) | 독립적으로 존재하는 데이터 대상 | 학생(Student), 강의(Course) | 테이블 |
| 2 | 속성(Attribute) | 엔터티가 가지는 특성 | 학생(학번, 이름, 학과) | 컬럼 |
| 3 | 관계(Relationship) | 엔터티 사이의 연관성 | 학생 - 수강 - 강의 | 외래 키(FK) 또는 연결 테이블 |
| 4 | 키(Key) | 엔터티를 고유하게 식별하는 속성 | 학생ID | 기본 키(PK) |

관계의 대응 수(카디널리티)는 1:1, 1:N, N:M으로 나눈다.

{% hint style="info" %}
NOTE: 외래 키(FK)는 관계형 모델의 개념이라 엄밀하게는 논리적 설계에서 정한다. 아래 표의 FK 표기는 이해를 돕기 위해 미리 적은 것이다.
{% endhint %}

## 3. 동작 원리

개념적 설계는 아래 순서로 진행한다.

### 3-1. 요구사항 분석

사용자 인터뷰, 문서 분석, 설문 조사로 저장할 데이터와 기능을 정의하고 업무 규칙을 파악한다. 자세한 내용은 [요구사항 분석 개요](requirementanalysisoverview.md)(DB-DSN-002-DO)를 따른다.

### 3-2. 엔터티 정의

시스템에서 관리할 핵심 개체를 식별한다.

| 엔터티 | 설명 |
|---|---|
| 학생(Student) | 학생 정보 관리 |
| 강의(Course) | 개설된 강의 정보 |
| 교수(Professor) | 강의를 담당하는 교수 정보 |
| 수강(Enrollment) | 학생이 강의를 등록한 정보 |

### 3-3. 속성 정의

각 엔터티의 속성을 정의한다. 모든 엔터티에는 기본 키(PK)가 있어야 한다.

| 엔터티 | 속성 |
|---|---|
| 학생(Student) | 학생ID(PK), 이름, 학과, 입학년도 |
| 강의(Course) | 강의ID(PK), 강의명, 학점, 교수ID(FK) |
| 교수(Professor) | 교수ID(PK), 이름, 전공 |
| 수강(Enrollment) | 학생ID(FK), 강의ID(FK), 성적 |

### 3-4. 관계 정의

| 관계 | 설명 |
|---|---|
| 학생 - 수강 - 강의 | 학생은 여러 강의를 수강하고 강의는 여러 학생이 수강한다(N:M). 수강 엔터티로 풀어 1:N과 N:1로 나눈다 |
| 교수 - 강의 | 교수는 여러 강의를 담당한다(1:N) |

### 3-5. ER 다이어그램 작성

텍스트 표기 예시는 다음과 같다.

```
[학생] 1 - N [수강] N - 1 [강의]
[교수] 1 - N [강의]
```

위 관계를 SQL 테이블로 변환하면 다음과 같다. 이 변환은 논리적 설계([DB-DSN-005-DO](logicaldesignoverview.md))의 작업이며 이해를 돕기 위해 싣는다.

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

### 장점

1. 데이터 관계를 명확히 정의할 수 있다.
2. 시각적 모델링으로 이해하기 쉽다.
3. 데이터 중복을 줄여 정규화 과정이 쉬워진다.
4. 업무 규칙과 데이터 모델을 일치시킬 수 있다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| ER 모델 | 엔터티, 속성, 관계로 데이터를 표현하는 모델 |
| ERD | ER 모델을 그린 다이어그램. 표기법(Chen, 까마귀발 등)이 여러 가지다 |
| PK / FK | 기본 키 / 외래 키 |
| 카디널리티(Cardinality) | 관계에서 양쪽 엔터티의 대응 수(1:1, 1:N, N:M) |

## 5. 참조

| 참조 문서 | 비고 |
|---|---|
| [논리적 설계 개요](logicaldesignoverview.md) | DB-DSN-005-DO |
| [데이터베이스 정규화](databasenormalization.md) | DB-DSN-006-DO |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] N:M 관계는 왜 그대로 테이블로 만들 수 없고 연결 테이블이 필요할까?
- [ ] 내가 아는 서비스의 엔터티 3개와 그 관계를 적어 보자.
