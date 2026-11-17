# PMM 에이전트 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-ENV-006-MP |
| 목적 | DB 서버에 PMM 클라이언트를 설치하고 PMM 서버에 등록한 뒤 MySQL(MariaDB)을 모니터링 대상으로 추가한다 |
| 적용 대상 | 허가받은 격리 실습 환경. `dnf`를 쓰는 RHEL 계열 Linux VM, MariaDB, 관리자 권한 |
| 소요 시간 | 약 30분 |
| 확인 상태 | 미검증 (원본 명령을 정리한 것이며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [pmmserver.md](pmmserver.md) | SEC-ENV-005-MP | PMM 모니터링 서버 구축 |
| Percona PMM 공식 문서 | - | 클라이언트 설치·등록 (공식 사이트에서 확인) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 실행 중인 PMM 서버 | SEC-ENV-005-MP 완료 | `<서버 IP>`를 안다 |
| 2 | DB 서버 | MariaDB 설치 | 5-C에서 설치 |
| 3 | 계정 정보 | PMM 서버 관리자 계정, DB 모니터링 계정 | 비밀번호는 `<비밀번호>`로 직접 정하고 문서에 적지 않는다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `--server-url`에 비밀번호를 넣으면 셸 기록과 프로세스 목록에 남는다. 원본은 URL에 관리자 비밀번호를 포함했다. 이 문서는 `<비밀번호>`로 대체했고, 실습 후 해당 비밀번호는 변경한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `--server-insecure-tls`는 인증서 검증을 끈다. 격리된 실습망에서만 쓴다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | PMM 서버가 응답한다 | `https://<서버 IP>/`가 열린다 |
| 2 | DB 서버에서 서버 IP로 443 포트가 열려 있다 | 연결이 된다 |

## 5. 절차

**A. 클라이언트 설치**

1. (SUBTASK 5-A-01) 저장소 패키지와 클라이언트를 설치한다. → 결과: 설치가 끝난다.

```sh
dnf install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm
dnf install -y pmm2-client
```

2. (SUBTASK 5-A-02) 버전을 확인한다: `pmm-admin --version` → 결과: 버전이 출력된다.

**B. 서버 등록**

1. (SUBTASK 5-B-01) 노드를 등록한다: `pmm-admin config --server-insecure-tls --server-url=https://<관리자 계정>:<비밀번호>@<서버 IP>:443` → 결과: 등록 성공 메시지가 출력된다.

**C. DB 서버 준비**

1. (SUBTASK 5-C-01) MariaDB를 설치하고 시작한다: `dnf install -y mariadb`, `systemctl start mariadb` → 결과: 서비스가 `active`이다.
2. (SUBTASK 5-C-02) DB에 접속한다: `mysql -u root -p` → 결과: SQL 프롬프트가 나타난다.
3. (SUBTASK 5-C-03) 모니터링 계정을 만든다. → 결과: 오류 없이 끝난다.

```sql
CREATE USER 'pmm'@'127.0.0.1' IDENTIFIED BY '<비밀번호>' WITH MAX_USER_CONNECTIONS 10;
```

4. (SUBTASK 5-C-04) 권한을 부여한다. → 결과: 오류 없이 끝난다.

```sql
GRANT SELECT, PROCESS, SUPER, REPLICATION CLIENT, RELOAD, SHOW VIEW ON *.* TO 'pmm'@'127.0.0.1';
GRANT SELECT, UPDATE, DROP, DELETE ON performance_schema.* TO 'pmm'@'127.0.0.1';
FLUSH PRIVILEGES;
SHOW GRANTS FOR 'pmm'@'127.0.0.1';
```

**D. MySQL 수집 설정 (예시)**

1. (SUBTASK 5-D-01) DB 서버 설정에 슬로우 쿼리 로그와 성능 스키마를 켠다. 원본은 `pmm-agent.yaml`에 적으라고 했으나 이 항목들은 MariaDB 설정(`my.cnf` 계열)의 옵션이다. 확인 필요. → 결과: 설정 파일에 아래 값이 있다.

```ini
slow_query_log = ON
slow_query_log_file = /log/slow_query.log
long_query_time = 1
log_output = FILE
performance_schema = ON
```

2. (SUBTASK 5-D-02) MariaDB를 재시작한다: `systemctl restart mariadb` → 결과: 서비스가 `active`이다.

**E. 모니터링 대상 추가**

1. (SUBTASK 5-E-01) MySQL을 PMM에 추가한다: `pmm-admin add mysql --query-source=perfschema --username=pmm --password=<비밀번호>` → 결과: 서비스가 추가됐다는 메시지가 출력된다.

**F. 원격 호스트·Docker 예시**

1. (SUBTASK 5-F-01) 원격 호스트를 등록한다: `pmm-admin add mysql --query-source=perfschema --username=pmm --password=<비밀번호> --host=<DB 호스트> --port=3306`
2. (SUBTASK 5-F-02) 컨테이너 실습망을 만든다: `docker network create mynetwork`
3. (SUBTASK 5-F-03) DB 컨테이너를 실행한다: `docker run -d --name mariadb --network=mynetwork -e MYSQL_ROOT_PASSWORD=<비밀번호> mariadb`
4. (SUBTASK 5-F-04) 클라이언트 컨테이너를 실행한다: `docker run -d --name pmm-client --network=mynetwork percona/pmm-client:latest`

{% hint style="info" %}
NOTE: 원본은 마지막에 `docker start wordpress-db-1`도 적었다. 이 컨테이너는 이 문서 범위 밖의 개인 환경이라 뺐다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `pmm-admin list` | 추가한 MySQL 서비스가 보인다 | 상태가 정상 |
| 2 | PMM 웹 화면의 MySQL 대시보드를 연다 | 지표가 표시된다 | 수 분 안에 데이터가 보인다 |

## 7. 복구

1. (SUBTASK 7-01) 모니터링 대상을 제거한다: `pmm-admin remove mysql <서비스 이름>`
2. (SUBTASK 7-02) 모니터링 계정을 삭제한다: `DROP USER 'pmm'@'127.0.0.1';`
3. (SUBTASK 7-03) 클라이언트를 제거한다: `dnf remove -y pmm2-client`

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | `pmmserver.md`의 "Agent 설정"을 분리해 새 문서로 작성. 하드코딩된 비밀번호·서버 IP를 `<비밀번호>`, `<서버 IP>`로 대체. 수집 설정 위치 정정 필요 사항을 기록 |
