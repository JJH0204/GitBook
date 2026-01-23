# DatabaseBasics

## 언어 구조

* DDL(Definition) - 데이터 정의어
  * create, alter, drop, truncate, rename, ...
* DML(Manipulation) - 데이터 조작어
  * select, insert, update, delete, ...
* DCL(Control) - 데이터 제어어
  * grant, revoke, ...
* TCL(Transaction) - 트랜잭션 제어어
  * commit, rollback, savepoint, ...

## CRUD

C-Create: 데이터 생성(insert)\
R-Read: 데이터 읽기(select)\
U-Update: 데이터 갱신(update)\
D-Delete: 데이터 삭제(delete)

## 실습

{% stepper %}
{% step %}
### MySQL 접속 및 데이터베이스 생성

```bash
mysql -u root
create database school;
```
{% endstep %}

{% step %}
### student.sql 파일 생성 및 내용

파일: vi student.sql

```sql
DROP TABLE IF EXISTS `student`;
CREATE TABLE `student` (
  `id` tinyint(4) NOT NULL,
  `name` char(4) NOT NULL,
  `sex` enum('남자','여자') NOT NULL,
  `location_id` tinyint(4) NOT NULL,
  `birthday` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
 
DROP TABLE IF EXISTS `location`;
CREATE TABLE `location` (
  `id`  tinyint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`  varchar(20) NOT NULL,
  `distance`  tinyint UNSIGNED NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;;

INSERT INTO `location` VALUES (1, '서울', 10);
INSERT INTO `location` VALUES (2, '청주', 200);
INSERT INTO `location` VALUES (3, '경주', 255);
INSERT INTO `location` VALUES (4, '제천', 190);
INSERT INTO `location` VALUES (5, '대전', 200);
INSERT INTO `location` VALUES (6, '제주', 255);
INSERT INTO `location` VALUES (7, '영동', 255);
INSERT INTO `location` VALUES (8, '광주', 255);
INSERT INTO `student` VALUES (1, '이숙경', '여자', 1, '1982-11-16 00:00:00');
INSERT INTO `student` VALUES (2, '박재숙', '남자', 2, '1985-10-26 00:00:00');
INSERT INTO `student` VALUES (3, '백태호', '남자', 3, '1989-2-10 00:00:00');
INSERT INTO `student` VALUES (4, '김경훈', '남자', 4, '1979-11-4 00:00:00');
INSERT INTO `student` VALUES (6, '김경진', '여자', 5, '1985-1-1 00:00:00');
INSERT INTO `student` VALUES (7, '박경호', '남자', 6, '1981-2-3 00:00:00');
INSERT INTO `student` VALUES (8, '김정인', '남자', 5, '1990-10-1 00:00:00');
```

다음 명령으로 실행:

```bash
mysql -u root
use school;
source /root/student.sql;
```
{% endstep %}

{% step %}
### 테이블 구조 확인 및 조회

테이블 구조 확인:

```sql
desc student;
```

전체 조회:

```sql
select * from student;
```
{% endstep %}

{% step %}
### 스크립트로 데이터 적용 (옵션)

한 줄로 파일 적용:

```bash
mysql -u root -p toor --host=localhost < /root/student.sql
```

쉘 스크립트 예:

파일: vi sql.sh

```bash
#!/bin/bash
mysql -u root -p toor --host=localhost < /root/student.sql
```

실행:

```bash
./sql.sh
```

또는 파이프 방식:

```bash
cat /root/student.sql | mysql -u root -p toor
```
{% endstep %}
{% endstepper %}

### Group by

```sql
select * from student;
select sex from student group by sex;
select sex, sum(distance), avg(distance) from student group by sex;
```

* 첫 번째 칼럼을 기준으로 그룹화 진행

### Order by

#### 내림차순

```sql
select * from student order by distance desc;
```

#### 오름차순

```sql
select * from student order by distance asc;
```

```sql
select sex, distance from student group by sex order by sum(distance) desc;
```

```sql
select * from student order by name desc;
```

### 연산자

#### 집계 함수

* sum, avg, max, min, count, stdev(표준편차), ...

#### 조건 함수

* having (조건)

### 인덱싱

* primary: 중복 x
* normal: 중복 허용
* unique: 중복 금지
* foreign: 테이블 관계성 부여
* full text: 자연어 검색

테이블 확인:

```sql
desc student;
```

예시 조회:

```sql
select * from student where id=3;
```

```sql
select * from student where birthday='1982-11-16 00:00:00';
```

```sql
select * from student where sex='남자';
```

* 중복이 허용되는 인덱싱은 normal 인덱싱

```sql
desc location;
```

```sql
select * from location;
```

### SQL Join

#### INNER JOIN

```sql
select * from student inner join location on student.location_id=location.id;
```

* 칼럼을 선택적으로 출력:

```sql
select student.name, student.sex, student.birthday, location.name, location.distance
from student
inner join location on student.location_id=location.id;
```

#### OUTER JOIN

#### LEFT JOIN

#### RIGHT JOIN
