# [생성형 AI] MariaDB 논리 백업과 복원

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-OPS-006-MP |
| 유형 | MP (절차) |
| 목적 | `mysqldump`로 데이터베이스 하나를 SQL 파일로 백업하고 다른 데이터베이스에 복원해 확인한다 |
| 적용 대상(Effectivity) | MariaDB 10.5 이상이 설치된 Linux, 백업 대상에 `SELECT` 권한이 있는 계정 |
| 소요 시간 | 약 10분 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (MariaDB 문서 지식을 정리한 것이며 이 환경에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [MariaDB 기본 사용법](mariadb.md) | DB-OPS-001-MP | 접속 |
| [DB 사용자 계정 생성과 권한 관리](dbusermanagement.md) | DB-OPS-004-MP | 백업용 계정 |
| [학생 실습 데이터베이스 생성](../overview/databasebasics-practice.md) | DB-OVW-003-MP | 예제 `school` 데이터베이스 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | MariaDB 서버 | 10.5 이상 | 10.5부터 `mariadb-dump`가 정식 이름이고 `mysqldump`는 호환 이름이다 |
| 2 | 백업 대상 데이터베이스 | `school` | DB-OVW-003-MP로 만든 것 |
| 3 | 백업 파일 저장 위치 | 디스크 여유가 데이터 크기 이상 | `<백업 폴더>`로 표기한다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 백업 파일에는 모든 행의 데이터가 평문으로 들어 있다. 파일 권한을 소유자만 읽도록 제한하고, 공유 저장소나 공개 저장소에 올리지 않는다.
{% endhint %}

{% hint style="danger" %}
WARNING: 복원은 같은 이름의 테이블을 덮어쓴다(덤프에 `DROP TABLE IF EXISTS`가 들어 있다). 운영 데이터베이스가 아닌 새 데이터베이스에 먼저 복원해 확인한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 비밀번호를 명령줄에 직접 적지 않는다. `-p`만 쓰고 프롬프트에서 입력한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 서비스가 실행 중이다 | `systemctl is-active mariadb` → `active` |
| 2 | 대상 데이터베이스가 있다 | `mysql -u <사용자> -p -e "SHOW DATABASES;"` → 목록에 `school`이 있다 |
| 3 | 저장 폴더가 있다 | `ls -ld <백업 폴더>` → 폴더 정보가 나온다 |

## 5. 절차

### A. 백업

1. (5-A-01) 덤프를 만든다: `mysqldump -u <사용자> -p --single-transaction --routines --triggers school > <백업 폴더>/school.sql` → 결과: 비밀번호 프롬프트가 나타난다. 입력하면 오류 없이 프롬프트로 돌아온다.
2. (5-A-02) 파일 권한을 제한한다: `chmod 600 <백업 폴더>/school.sql` → 결과: 오류 없이 끝난다.
3. (5-A-03) 파일 내용을 확인한다: `head -n 30 <백업 폴더>/school.sql` → 결과: `CREATE TABLE` 문과 `INSERT INTO` 문이 보인다.

`--single-transaction`은 InnoDB 테이블을 잠그지 않고 일관된 시점의 스냅숏을 읽는다. MyISAM 테이블에는 효과가 없다.

### B. 새 데이터베이스에 복원

1. (5-B-01) 빈 데이터베이스를 만든다: `mysql -u <사용자> -p -e "CREATE DATABASE school_restore;"` → 결과: 오류 없이 끝난다.
2. (5-B-02) 덤프를 적재한다: `mysql -u <사용자> -p school_restore < <백업 폴더>/school.sql` → 결과: 오류 없이 끝난다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `mysql -u <사용자> -p -e "SHOW TABLES;" school_restore` | 원본과 같은 테이블 이름 목록 | 테이블 수 일치 |
| 2 | `mysql -u <사용자> -p -e "SELECT COUNT(*) FROM student;" school_restore` | 원본 `school.student`의 행 수와 같은 값 | 행 수 일치 |

## 7. 복구 (Close-up / Restore)

1. (7-01) 확인용 데이터베이스를 지운다: `mysql -u <사용자> -p -e "DROP DATABASE school_restore;"` → 결과: 오류 없이 끝난다. 이 명령은 `school_restore`만 지운다.
2. (7-02) 백업 파일은 보관 정책에 따라 안전한 위치로 옮긴다.

{% hint style="info" %}
NOTE: 논리 백업은 SQL 문을 저장하는 방식이라 큰 데이터베이스에서는 복원이 오래 걸린다. 백업 계획에는 보관 기간, 저장 위치, 정기 복원 시험을 함께 정한다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성 |
