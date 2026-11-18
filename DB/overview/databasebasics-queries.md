# 기본 조회 질의 예시

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-OVW-004-REF |
| 유형 | REF (질의 표) |
| 목적 | `school` 데이터베이스에서 그룹화, 정렬, 조건 조회, 조인 질의를 찾아 쓴다 |
| 확인 상태 | 미검증 (원본 페이지의 질의를 정리·정정한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서의 질의는 [학생 실습 데이터베이스 생성](databasebasics-practice.md)(DB-OVW-003-MP)을 마친 `school` 데이터베이스를 전제로 한다. 질의 앞에 `use school;`을 실행해 둔다. 개념은 DB-OVW-001-DO를 본다.
{% endhint %}

{% hint style="info" %}
NOTE: 원본의 일부 질의는 `student` 테이블에 없는 `distance` 칼럼을 썼다. `distance`는 `location` 테이블에 있으므로 조인을 추가해 정정했다.
{% endhint %}

## 1. 기본 조회

| 목적 | 질의 | 기대 결과 |
|---|---|---|
| 테이블 구조 보기 | `desc student;` | 칼럼 목록이 출력된다 |
| 전체 조회 | `select * from student;` | 7행 |
| 기본 키로 조회 | `select * from student where id=3;` | 1행 |
| 날짜로 조회 | `select * from student where birthday='1982-11-16 00:00:00';` | 1행 |
| 값으로 조회 | `select * from student where sex='남자';` | 남자 학생 행 |
| 지역 전체 조회 | `select * from location;` | 8행 |

## 2. 그룹화

| 목적 | 질의 | 기대 결과 |
|---|---|---|
| 성별 종류 보기 | `select sex from student group by sex;` | `남자`, `여자` 두 행 |
| 성별별 학생 수 | `select sex, count(*) from student group by sex;` | 성별마다 한 행 |
| 성별별 거리 합계·평균 | `select s.sex, sum(l.distance), avg(l.distance) from student s inner join location l on s.location_id=l.id group by s.sex;` | 성별마다 한 행 |

## 3. 정렬

| 목적 | 질의 | 기대 결과 |
|---|---|---|
| 이름 내림차순 | `select * from student order by name desc;` | 이름 역순 |
| 거리 내림차순 | `select s.name, l.distance from student s inner join location l on s.location_id=l.id order by l.distance desc;` | 거리가 큰 학생부터 |
| 거리 오름차순 | `select s.name, l.distance from student s inner join location l on s.location_id=l.id order by l.distance asc;` | 거리가 작은 학생부터 |
| 성별별 거리 합계 내림차순 | `select s.sex, sum(l.distance) from student s inner join location l on s.location_id=l.id group by s.sex order by sum(l.distance) desc;` | 합계가 큰 성별부터 |

## 4. 조인

| 목적 | 질의 | 기대 결과 |
|---|---|---|
| inner join | `select * from student inner join location on student.location_id=location.id;` | 두 테이블의 칼럼이 한 행에 합쳐진다 |
| 칼럼 선택 | `select student.name, student.sex, student.birthday, location.name, location.distance from student inner join location on student.location_id=location.id;` | 선택한 5개 칼럼 |
| left join | `select * from location left join student on student.location_id=location.id;` | 학생이 없는 지역도 출력된다. 학생 칼럼은 NULL이다 |
| right join | `select * from student right join location on student.location_id=location.id;` | 위 left join과 같은 결과다 |

{% hint style="info" %}
NOTE: left join과 right join 행은 원본에 질의가 없었다. 원본에 없던 예시를 추가한 것이다.
{% endhint %}

## 5. 사용 예

| 목적 | 명령 | 기대 결과 |
|---|---|---|
| 데이터베이스 선택 | `use school;` | `Database changed` |
| 인덱스 확인 | `show index from student;` | `PRIMARY` 인덱스 한 줄 |

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지 `databasebasics.md`의 조회 질의를 AMM 형식으로 분리·재작성 |
