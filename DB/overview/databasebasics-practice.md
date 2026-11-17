# 학생 실습 데이터베이스 생성

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-OVW-003-MP |
| 목적 | 실습용 `school` 데이터베이스를 만들고 `student`, `location` 테이블과 샘플 데이터를 적재한다 |
| 적용 대상(Effectivity) | MariaDB 10.5 이상이 설치된 Linux, root로 DB에 접속할 수 있는 환경 |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리·정정한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [databasebasics.md](databasebasics.md) | DB-OVW-001-DO | 데이터베이스 기초 (Database Basics) |
| [databasebasics-queries.md](databasebasics-queries.md) | DB-OVW-004-REF | 기본 조회 질의 예시 |
| [mariadb.md](../operations/mariadb.md) | DB-OPS-001-MP | MariaDB 기본 사용법 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | MariaDB 서버 | 10.5 이상, 서비스 실행 중 | 설치와 보안 설정은 DB-OPS-001-MP를 따른다 |
| 2 | DB root 계정 | | 비밀번호는 `<비밀번호>`로 표기한다 |
| 3 | 텍스트 편집기 | `vi` 등 | |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 5-B 단계의 `student.sql`은 `DROP TABLE IF EXISTS`로 같은 이름의 테이블을 먼저 삭제한다. `school` 데이터베이스에 `student` 또는 `location` 테이블이 이미 있고 데이터가 필요하면 적재 전에 백업한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 비밀번호를 명령줄에 직접 적지 않는다. `-p` 뒤에 값을 붙이면 셸 이력(history)과 프로세스 목록에 남는다. 이 문서는 `-p`만 쓰고 프롬프트에서 입력한다.
{% endhint %}

{% hint style="info" %}
NOTE: 원본의 샘플 이름은 실제 이름처럼 보여 `학생A` 같은 가상 이름으로 바꿨다. 행 수와 구조는 같다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | MariaDB 서비스가 실행 중이다 | `systemctl is-active mariadb` → `active` |
| 2 | root로 접속할 수 있다 | `mysql -u root -p` 입력 후 `MariaDB [(none)]>` 프롬프트가 나타난다. `exit`로 나온다 |

## 5. 절차

### A. 데이터베이스 생성

1. (5-A-01) DB에 접속한다: `mysql -u root -p` → 결과: 비밀번호 프롬프트가 나타난다. `<비밀번호>`를 입력하면 `MariaDB [(none)]>` 프롬프트가 나타난다.
2. (5-A-02) 데이터베이스를 만든다: `create database school;` → 결과: `Query OK, 1 row affected`가 출력된다.
3. (5-A-03) DB에서 나온다: `exit` → 결과: 셸 프롬프트로 돌아온다.

### B. SQL 파일 작성

1. (5-B-01) 파일을 연다: `vi student.sql`
2. (5-B-02) 아래 내용을 입력하고 저장한다.

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
  `id` tinyint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `distance` tinyint UNSIGNED NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `location` VALUES (1, '서울', 10);
INSERT INTO `location` VALUES (2, '청주', 200);
INSERT INTO `location` VALUES (3, '경주', 255);
INSERT INTO `location` VALUES (4, '제천', 190);
INSERT INTO `location` VALUES (5, '대전', 200);
INSERT INTO `location` VALUES (6, '제주', 255);
INSERT INTO `location` VALUES (7, '영동', 255);
INSERT INTO `location` VALUES (8, '광주', 255);
INSERT INTO `student` VALUES (1, '학생A', '여자', 1, '1982-11-16 00:00:00');
INSERT INTO `student` VALUES (2, '학생B', '남자', 2, '1985-10-26 00:00:00');
INSERT INTO `student` VALUES (3, '학생C', '남자', 3, '1989-02-10 00:00:00');
INSERT INTO `student` VALUES (4, '학생D', '남자', 4, '1979-11-04 00:00:00');
INSERT INTO `student` VALUES (6, '학생E', '여자', 5, '1985-01-01 00:00:00');
INSERT INTO `student` VALUES (7, '학생F', '남자', 6, '1981-02-03 00:00:00');
INSERT INTO `student` VALUES (8, '학생G', '남자', 5, '1990-10-01 00:00:00');
```

→ 결과: 현재 디렉터리에 `student.sql`이 만들어진다.

### C. 파일 적용 (대화형)

1. (5-C-01) DB에 접속한다: `mysql -u root -p` → 결과: `MariaDB [(none)]>` 프롬프트가 나타난다.
2. (5-C-02) 데이터베이스를 선택한다: `use school;` → 결과: `Database changed`가 출력된다.
3. (5-C-03) 파일을 실행한다: `source <student.sql 경로>;` → 결과: `Query OK`가 여러 줄 출력되고 오류가 없다.

### D. 구조와 데이터 확인

1. (5-D-01) 테이블 구조를 확인한다: `desc student;` → 결과: `id`, `name`, `sex`, `location_id`, `birthday` 다섯 칼럼이 보인다.
2. (5-D-02) 전체 행을 조회한다: `select * from student;` → 결과: 7행이 출력된다.

### E. 파일 적용 (비대화식, 선택)

1. (5-E-01) 셸에서 데이터베이스 이름을 지정해 파일을 적용한다: `mysql -u root -p school < <student.sql 경로>` → 결과: 비밀번호를 입력하면 오류 없이 끝난다.

{% hint style="info" %}
NOTE: 원본은 `mysql -u root -p toor --host=localhost < student.sql`을 적었다. 공백을 두고 쓴 `toor`는 비밀번호가 아니라 데이터베이스 이름으로 해석된다. 또 `student.sql`에는 `use` 문이 없어 데이터베이스 이름이 없으면 `No database selected` 오류가 난다. 두 문제를 정정했다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `select count(*) from student;` | 학생 수가 출력된다 | `7` |
| 2 | `select count(*) from location;` | 지역 수가 출력된다 | `8` |
| 3 | `show tables;` | 테이블 목록이 출력된다 | `location`, `student` 두 개 |

## 7. 복구

1. (7-01) 실습 데이터베이스를 삭제한다: `drop database school;` → 결과: `Query OK`가 출력된다. 데이터베이스와 안의 모든 테이블이 삭제되며 되돌릴 수 없다.
2. (7-02) 다시 만들려면 5-A부터 반복한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지 `databasebasics.md`의 "실습" 절을 AMM 형식으로 분리·재작성 |
