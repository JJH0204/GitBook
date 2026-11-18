# DB 사용자 계정 생성과 권한 관리

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-OPS-004-MP |
| 목적 | MariaDB 계정을 만들고, 권한을 부여·확인·회수하고, 계정을 삭제한다. 운영 체제의 DB 관리자 그룹 생성도 포함한다 |
| 적용 대상(Effectivity) | MariaDB 10.5, Rocky Linux 등 RHEL 계열, DB root 접속 가능 |
| 소요 시간 | 약 15분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리·정정한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [mariadb.md](mariadb.md) | DB-OPS-001-MP | MariaDB 기본 사용법 |
| [mariadb-remote-access.md](mariadb-remote-access.md) | DB-OPS-005-MP | MariaDB 원격 접속 허용 설정 |
| [dbperformanceinfo.md](dbperformanceinfo.md) | DB-OPS-003-REF | DB 서버 자원 확인과 성능 튜닝 |
| [databasebasics-practice.md](../overview/databasebasics-practice.md) | DB-OVW-003-MP | 학생 실습 데이터베이스 생성 (`school` 데이터베이스) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | DB root 계정 | | `mysql -u root -p`로 접속한다 |
| 2 | 실습 데이터베이스 | `school` (`student` 테이블 포함) | DB-OVW-003-MP로 만든다 |
| 3 | OS root 또는 sudo 권한 | | 구역 A에서 사용 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `grant all privileges`는 대상 범위의 모든 권한을 준다. 응용 계정에는 필요한 권한(`select`, `insert` 등)만 준다. `*.*`에 `all privileges`를 주면 그 계정이 서버 전체를 바꿀 수 있다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 비밀번호는 `<비밀번호>`로 표기했다. 실제 값은 12자 이상의 무작위 문자열로 정하고 문서나 스크립트에 적지 않는다. 호스트를 `'%'`로 두면 모든 네트워크에서 접속할 수 있는 계정이 된다. 필요한 호스트만 지정한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | MariaDB 서비스가 실행 중이다 | `systemctl is-active mariadb` → `active` |
| 2 | root로 접속한다 | `mysql -u root -p` → `MariaDB [(none)]>` 프롬프트 |
| 3 | `school` 데이터베이스가 있다 | `show databases;` → `school`이 보인다 |

## 5. 절차

### A. OS의 DB 관리자 그룹과 사용자 생성 (셸에서, 선택)

{% hint style="info" %}
NOTE: 원본은 이 단계를 "DB 사용자 및 그룹 추가"로 적었다. `groupadd`와 `useradd`가 만드는 것은 운영 체제 계정이며 MariaDB 계정이 아니다. 구역 B 이후가 MariaDB 계정이다. 원본의 ID 505는 예시값이다.
{% endhint %}

1. (5-A-01) DB 관리자 그룹을 만든다: `sudo groupadd -g 505 dba` → 결과: 오류 없이 끝난다.
2. (5-A-02) 사용자를 만들고 그룹에 추가한다: `sudo useradd -u 505 -G dba <OS 사용자명>` → 결과: 오류 없이 끝난다.
3. (5-A-03) 그룹 소속을 확인한다: `id <OS 사용자명>` → 결과: `groups=` 목록에 `dba`가 보인다.

### B. 로컬 계정 생성과 권한 부여

1. (5-B-01) DB에 접속한다: `mysql -u root -p` → 결과: `MariaDB [(none)]>` 프롬프트가 나타난다.
2. (5-B-02) 로컬 접속 전용 계정을 만든다: `create user '<DB 사용자명>'@'localhost' identified by '<비밀번호>';` → 결과: `Query OK, 0 rows affected`가 출력된다.
3. (5-B-03) 권한을 부여한다: `grant all privileges on school.* to '<DB 사용자명>'@'localhost';` → 결과: `Query OK`가 출력된다.
4. (5-B-04) 권한을 확인한다: `show grants for '<DB 사용자명>'@'localhost';` → 결과: `GRANT ALL PRIVILEGES ON school.*` 행이 보인다.

{% hint style="info" %}
NOTE: 원본은 계정 생성과 권한 부여를 한 문장으로 하는 `grant all privileges on school.* to '<사용자>'@'localhost' identified by '<비밀번호>';`도 적었다. MariaDB 10.5에서는 동작하지만 MySQL 8.0은 이 문법을 지원하지 않는다. 이 문서는 두 문장으로 나눴다. 확인 필요.
{% endhint %}

### C. 모든 호스트에서 접속하는 계정 (원격 접속용)

{% hint style="danger" %}
WARNING: 호스트 `'%'` 계정은 어느 네트워크에서든 접속을 시도할 수 있다. 서버가 원격 접속을 허용하면(DB-OPS-005-MP) 비밀번호 추측 공격에 노출된다. 가능하면 구역 D처럼 호스트를 지정한다.
{% endhint %}

1. (5-C-01) 계정을 만든다: `create user '<DB 사용자명>'@'%' identified by '<비밀번호>';` → 결과: `Query OK`가 출력된다.
2. (5-C-02) 권한을 부여한다: `grant all privileges on school.* to '<DB 사용자명>'@'%';` → 결과: `Query OK`가 출력된다.
3. (5-C-03) 권한을 확인한다: `show grants for '<DB 사용자명>'@'%';` → 결과: `school.*` 권한 행이 보인다.

### D. 특정 호스트만 허용하는 계정

1. (5-D-01) 계정을 만든다: `create user '<DB 사용자명>'@'<IP 주소>' identified by '<비밀번호>';` → 결과: `Query OK`가 출력된다.
2. (5-D-02) 최소 권한을 부여한다: `grant select, insert on school.student to '<DB 사용자명>'@'<IP 주소>';` → 결과: `Query OK`가 출력된다. 이 계정은 `<IP 주소>` 호스트에서만 접속하며 `student` 테이블의 조회와 입력만 할 수 있다.
3. (5-D-03) 권한을 확인한다: `show grants for '<DB 사용자명>'@'<IP 주소>';` → 결과: `GRANT SELECT, INSERT ON school.student` 행이 보인다.

{% hint style="info" %}
NOTE: 원본은 구역 D에서 `flush privileges;`를 실행했다. `create user`, `grant`, `revoke`, `drop user`는 권한 정보를 즉시 반영하므로 이 명령이 필요하지 않다. `mysql.user` 테이블을 직접 수정했을 때만 필요하다. 원본 단계를 삭제했다. 확인 필요.
{% endhint %}

### E. 계정과 권한 조회

1. (5-E-01) 계정 목록을 조회한다: `select user, host from mysql.user;` → 결과: 계정과 호스트 목록이 출력된다.
2. (5-E-02) 현재 접속한 계정의 권한을 본다: `show grants;` → 결과: 현재 계정의 권한 행이 출력된다.
3. (5-E-03) 특정 계정의 권한을 본다: `show grants for '<DB 사용자명>'@'localhost';` → 결과: 해당 계정의 권한 행이 출력된다.

{% hint style="info" %}
NOTE: 원본은 `select User, Password from mysql.user;`를 적었다. MariaDB 10.4 이상에서 `mysql.user`는 뷰이며 비밀번호 해시를 보이는 것은 권하지 않아 `Password` 칼럼을 뺐다. 확인 필요.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `select user, host from mysql.user;` | 만든 계정 | 5-B-02에서 만든 계정이 목록에 있다 |
| 2 | 셸에서 `mysql -u <DB 사용자명> -p school` 후 `<비밀번호>` 입력 | 접속 | `MariaDB [school]>` 프롬프트 |
| 3 | 구역 D 계정으로 `select * from student;` 실행 | 조회 성공 | 행이 출력된다 |
| 4 | 구역 D 계정으로 `delete from student;` 실행 | 권한 오류 | `DELETE command denied` 메시지 |

## 7. 복구

### F. 권한 회수

1. (7-F-01) 권한을 회수한다: `revoke all on school.* from '<DB 사용자명>'@'localhost';` → 결과: `Query OK`가 출력된다.
2. (7-F-02) 회수를 확인한다: `show grants for '<DB 사용자명>'@'localhost';` → 결과: `GRANT USAGE ON *.*`만 남는다.

### G. 계정 삭제

1. (7-G-01) 계정을 삭제한다: `drop user '<DB 사용자명>'@'localhost';` → 결과: `Query OK`가 출력된다.
2. (7-G-02) 호스트를 지정한 계정도 삭제한다: `drop user '<DB 사용자명>'@'%';` 또는 `drop user '<DB 사용자명>'@'<IP 주소>';` → 결과: `Query OK`가 출력된다.
3. (7-G-03) 삭제를 확인한다: `select user, host from mysql.user;` → 결과: 삭제한 계정이 없다.

{% hint style="info" %}
NOTE: 호스트를 생략한 `drop user <DB 사용자명>;`은 `'<DB 사용자명>'@'%'`를 삭제한다. 원본의 `drop user test1;`과 `drop user 'test1'@'%';`은 같은 동작이다. 확인 필요.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지 `dbperformanceinfo.md`의 사용자·권한 관리를 AMM 형식으로 분리·재작성. 비밀번호·계정명·IP는 일반화 |
