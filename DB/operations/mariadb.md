# MariaDB 기본 사용법

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-OPS-001-MP |
| 목적 | 설치된 MariaDB 서버의 실행 상태를 확인하고, 보안 설정(`mysql_secure_installation`)을 마친 뒤 root로 접속한다 |
| 적용 대상(Effectivity) | Rocky Linux 등 RHEL 계열, MariaDB 10.5 이상(서비스 이름 `mariadb`), root 또는 sudo 권한 |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 페이지와 MariaDB 문서 지식을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: MariaDB는 MySQL에서 갈라져 나온 RDBMS이며 대부분의 명령이 MySQL과 같다. 이 문서는 설치 후의 보안 설정과 접속만 다룬다. 설치 단계는 원본에 없었다. 명령어 표는 [MariaDB 명령어 참조](mariadb-commands.md)(DB-OPS-002-REF)로 나눴다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [mariadb-commands.md](mariadb-commands.md) | DB-OPS-002-REF | MariaDB 명령어 참조 |
| [dbusermanagement.md](dbusermanagement.md) | DB-OPS-004-MP | DB 사용자 계정 생성과 권한 관리 |
| [mariadb-remote-access.md](mariadb-remote-access.md) | DB-OPS-005-MP | MariaDB 원격 접속 허용 설정 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | MariaDB 서버 패키지 | 10.5 이상 | 설치돼 있어야 한다 |
| 2 | 터미널 | root 또는 `sudo` 사용 가능 | |
| 3 | root 비밀번호 | `<비밀번호>` | 이 문서에서 새로 정한다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 5-B-03 단계에서 정하는 root 비밀번호는 12자 이상의 무작위 문자열로 정한다. 간단한 비밀번호는 원격 접속을 열었을 때 곧바로 침해로 이어진다. 비밀번호를 문서, 스크립트, 셸 이력에 적지 않는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `mysql_secure_installation`은 익명 사용자와 `test` 데이터베이스를 삭제한다. 이미 운영 중인 서버라면 두 항목에 의존하는 응용이 없는지 먼저 확인한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | MariaDB가 설치돼 있다 | `mariadb --version` → 버전 번호가 출력된다 (`mysql --version`도 같다) |
| 2 | root 또는 `sudo` 권한이 있다 | `id` → `uid=0(root)` 이거나 `sudo -v`가 성공한다 |

## 5. 절차

### A. 서비스 상태 확인

1. (5-A-01) 서비스 상태를 확인한다: `systemctl status mariadb` → 결과: `Active: active (running)`이 보인다.
2. (5-A-02) 실행 중이 아니면 시작하고 부팅 시 자동 시작으로 설정한다: `sudo systemctl enable --now mariadb` → 결과: 오류 없이 끝난다. 5-A-01을 다시 실행해 `active (running)`을 확인한다.

### B. 보안 설정

1. (5-B-01) 보안 설정 도구를 실행한다: `sudo mysql_secure_installation` → 결과: 현재 root 비밀번호를 묻는 프롬프트가 나타난다.
2. (5-B-02) 설치 직후 root 비밀번호가 없으면 Enter를 누른다. → 결과: 다음 질문으로 넘어간다.
3. (5-B-03) root 비밀번호 설정 질문에 `Y`를 입력하고 `<비밀번호>`를 두 번 입력한다. → 결과: `Password updated successfully!`가 출력된다.
4. (5-B-04) 익명 사용자 삭제 질문에 `Y`를 입력한다. → 결과: `Success.`가 출력된다.
5. (5-B-05) root 원격 로그인 금지 질문에 `Y`를 입력한다. → 결과: `Success.`가 출력된다.
6. (5-B-06) `test` 데이터베이스 삭제 질문에 `Y`를 입력한다. → 결과: `Success.`가 출력된다.
7. (5-B-07) 권한 테이블 다시 읽기 질문에 `Y`를 입력한다. → 결과: `Success.`가 출력되고 `Thanks for using MariaDB!`로 끝난다.

{% hint style="info" %}
NOTE: 질문의 종류와 순서는 MariaDB 버전에 따라 다르다. 10.4 이상은 `unix_socket` 인증 전환 질문이 추가돼 있다. 이 문서는 질문 내용을 요약했으며 미검증이다. 화면의 실제 질문을 읽고 판단한다. 확인 필요.
{% endhint %}

{% hint style="info" %}
NOTE: 원본은 도구 이름을 `mysql-secure-installation`(하이픈)으로 적었다. 일반적인 이름은 `mysql_secure_installation`(밑줄)이며 MariaDB 10.4 이후 `mariadb-secure-installation`도 제공된다. 정정했다. 확인 필요.
{% endhint %}

### C. root로 접속

1. (5-C-01) DB에 접속한다: `mysql -u root -p` → 결과: `Enter password:` 프롬프트가 나타난다.
2. (5-C-02) `<비밀번호>`를 입력한다. → 결과: `MariaDB [(none)]>` 프롬프트가 나타난다. `(none)`은 선택된 데이터베이스가 없다는 뜻이다.
3. (5-C-03) 데이터베이스 목록을 확인한다: `show databases;` → 결과: `information_schema`, `mysql`, `performance_schema`가 보인다. `test`는 없다.
4. (5-C-04) DB에서 나온다: `exit` → 결과: 셸 프롬프트로 돌아온다.

{% hint style="info" %}
NOTE: 원본은 "-p가 없어도 접속이 가능하던데?"라고 의문을 적었다. MariaDB 10.4 이상은 root가 기본으로 `unix_socket` 인증을 쓴다. OS root(또는 `sudo`)로 실행한 `mysql -u root`는 비밀번호 없이 접속된다. `-p`는 비밀번호 인증 계정일 때 필요하다. 확인 필요.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `systemctl is-active mariadb` | 서비스 상태 | `active` |
| 2 | `mysql -u root -p` 후 `<비밀번호>` 입력 | 프롬프트 | `MariaDB [(none)]>` 표시 |
| 3 | `show databases;` | 데이터베이스 목록 | `test`가 없다 |
| 4 | `select user, host from mysql.user;` | 계정 목록 | 사용자 이름이 비어 있는 행이 없다 |

## 7. 복구

1. (7-01) root 비밀번호를 잊었거나 바꿔야 하면 `mysql_secure_installation`을 다시 실행한다. 5-B-03에서 새 비밀번호를 입력한다. 현재 비밀번호를 모르면 이 방법으로 되돌릴 수 없다. MariaDB 문서의 복구 절차를 따른다.
2. (7-02) 서비스를 중지하려면 `sudo systemctl stop mariadb`를 실행한다. → 결과: `systemctl is-active mariadb`가 `inactive`를 출력한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지의 보안 설정과 접속을 AMM 형식으로 재작성. 명령어 표는 DB-OPS-002-REF로 분리 |
