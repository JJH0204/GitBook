# MariaDB 명령어 참조

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-OPS-002-REF |
| 유형 | REF (명령 표) |
| 목적 | MariaDB 콘솔의 데이터베이스·테이블·행 명령을 찾아 쓴다 |
| 확인 상태 | 미검증 (원본 페이지와 MariaDB 문서 지식을 정리·정정한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 아래 명령은 MariaDB 콘솔(`MariaDB [(none)]>` 프롬프트)에서 실행한다. 문장은 `;`로 끝낸다. 접속 방법은 [MariaDB 기본 사용법](mariadb.md)(DB-OPS-001-MP)을 본다. `<꺾쇠>`는 사용자 입력값이다. 원본의 `//` 주석은 MariaDB 콘솔에서 쓰는 형식이 아니므로 설명을 표의 열로 옮겼다.
{% endhint %}

## 1. 데이터베이스 명령

| 목적 | 명령 | 비고 |
|---|---|---|
| 접속 | `mysql -u root -p` | 셸에서 실행한다 |
| 데이터베이스 목록 | `show databases;` | |
| 데이터베이스 선택 | `use <데이터베이스 이름>;` | 프롬프트의 `(none)`이 선택한 이름으로 바뀐다 |
| 테이블 목록 | `show tables;` | 데이터베이스를 선택한 뒤 실행한다 |
| 칼럼 목록 | `desc <테이블 이름>;` | |
| 전체 조회 | `select * from <테이블 이름>;` | |
| 칼럼 지정 조회 | `select <칼럼1>, <칼럼2> from <테이블 이름>;` | |
| 데이터베이스 생성 | `create database <데이터베이스 이름>;` | |
| 테이블 생성 | `create table <테이블 이름> (<칼럼> <자료형>(<자릿수>), ...);` | |
| 종료 | `exit` | |

## 2. 테이블 변경 명령

| 목적 | 명령 | 비고 |
|---|---|---|
| 칼럼 추가 | `alter table <테이블> add <칼럼> <자료형>;` | 위치를 생략하면 가장 뒤에 추가된다 |
| 칼럼 추가 (맨 앞) | `alter table <테이블> add <칼럼> <자료형> first;` | |
| 칼럼 추가 (지정 칼럼 뒤) | `alter table <테이블> add <칼럼> <자료형> after <기준 칼럼>;` | |
| 칼럼 여러 개 추가 | `alter table <테이블> add (<칼럼1> <자료형>, <칼럼2> <자료형>);` | |
| 칼럼 정의 수정 | `alter table <테이블> modify <칼럼> <자료형>;` | 자료형이나 위치(`first`, `after`)를 바꾼다 |
| 칼럼 삭제 | `alter table <테이블> drop <칼럼>;` | 칼럼의 데이터도 삭제된다 |
| 칼럼 이름 변경 | `alter table <테이블> rename column <이전 이름> to <새 이름>;` | MariaDB 10.5.2 이상 |
| 칼럼 이름 변경 (구형) | `alter table <테이블> change <이전 이름> <새 이름> <자료형>;` | 자료형을 다시 적어야 한다 |

{% hint style="info" %}
NOTE: 원본은 `before <칼럼>` 위치 지정과 `alter table <테이블> rename <이전> to <새>` 칼럼 이름 변경을 적었다. MariaDB는 `first`, `after`만 지원하며 `rename <A> to <B>`는 테이블 이름 변경 문법이다. 정정했다. 확인 필요.
{% endhint %}

## 3. 행 명령

| 목적 | 명령 | 비고 |
|---|---|---|
| 행 입력 | `insert into <테이블> (<칼럼1>, <칼럼2>) values (<값1>, <값2>);` | |
| 모든 행 수정 | `update <테이블> set <칼럼> = <값>;` | 테이블의 모든 행이 바뀐다 |
| 조건에 맞는 행 수정 | `update <테이블> set <칼럼> = <값> where <기준 칼럼> = <키 값>;` | |
| 조건에 맞는 행 삭제 | `delete from <테이블> where <칼럼> = <값>;` | |
| 모든 행 삭제 | `delete from <테이블>;` | 행만 삭제되고 테이블은 남는다 |

{% hint style="danger" %}
WARNING: `where` 없는 `update`와 `delete`는 테이블의 모든 행에 적용된다. 실행 전에 `select`로 대상 행을 확인한다.
{% endhint %}

{% hint style="info" %}
NOTE: 원본은 `delete from <테이블>;`을 "테이블 삭제"로 적었다. 이 명령은 행만 삭제한다. 테이블 자체는 `drop table`로 삭제한다. 정정했다.
{% endhint %}

## 4. 객체 삭제 명령

| 목적 | 명령 | 비고 |
|---|---|---|
| 테이블 삭제 | `drop table <테이블 이름>;` | 구조와 데이터가 모두 삭제된다 |
| 데이터베이스 삭제 | `drop database <데이터베이스 이름>;` | 안의 모든 테이블이 삭제된다 |

{% hint style="danger" %}
WARNING: `drop`은 되돌릴 수 없다. 백업 없이 운영 데이터에 실행하지 않는다.
{% endhint %}

## 5. 사용 예

| 목적 | 명령 | 기대 결과 |
|---|---|---|
| 데이터베이스 만들고 선택 | `create database school;` 후 `use school;` | `Database changed` |
| 테이블 만들기 | `create table memo (id int, title varchar(50));` | `Query OK, 0 rows affected` |
| 칼럼 추가 | `alter table memo add body text after title;` | `Query OK` |
| 행 입력 | `insert into memo (id, title) values (1, 'first');` | `1 row affected` |
| 조회 | `select * from memo;` | 1행 |

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지 `mariadb.md`의 명령어 목록을 AMM 형식(REF)으로 분리·재작성 |
