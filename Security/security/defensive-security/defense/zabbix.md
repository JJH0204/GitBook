# Zabbix 모니터링 시스템 구축

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-DEF-012-MP |
| 목적 | Zabbix 7.0 서버(웹, DB 포함)를 설치하고 에이전트를 설치해 호스트를 모니터링 대상으로 등록한다 |
| 적용 대상 | 서버: RHEL 계열 9(Alma, Rocky 등), httpd + MariaDB + PHP-FPM, root 권한. 에이전트: Windows, RHEL 계열, Ubuntu/Debian. 실습망 기준 |
| 소요 시간 | 서버 약 40분, 에이전트 호스트당 약 10분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 환경에서 설치·실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 탭 구조(Windows, CentOS/RHEL, Ubuntu)는 구역 H-1, H-2, H-3으로 풀어 썼다. 에이전트는 호스트 운영체제에 맞는 구역 하나만 수행한다. 공식 사이트: https://www.zabbix.com/
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [firewalld 방화벽 관리](../../../../Linux/guide/security/firewalld.md) | LNX-SEC-001-MP | 방화벽 포트 허용 |
| [보안 정보 이벤트 관리 (SIEM)](siem.md) | SEC-DEF-003-DO | 모니터링과 SIEM의 차이 |
| Zabbix 에이전트 다운로드 | - | https://www.zabbix.com/download_agents |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Zabbix 서버 | RHEL 계열 9 가상 머신, root 권한 | |
| 2 | 모니터링 대상 호스트 | Windows, RHEL 계열, Ubuntu 24.04 중 하나 이상 | 서버와 통신 가능 |
| 3 | 브라우저 | 서버에 접속 가능한 PC | 웹 설치와 호스트 등록 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: Zabbix 웹의 기본 관리자 계정은 공개되어 있다. 설치 직후 로그인해 기본 계정의 비밀번호를 바꾼다. DB 사용자 비밀번호와 Zabbix 관리자 비밀번호는 문서, 채팅, 저장소에 쓰지 않는다. 이 문서는 `<DB 비밀번호>`, `<기본 계정>`, `<관리자 비밀번호>`로 표기한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 방화벽 규칙을 잘못 바꾸면 SSH 접속이 끊긴다. 방화벽 명령을 입력하기 전에 콘솔 접근을 확보한다. 모니터링 포트(10050, 10051)는 필요한 상대 IP에만 연다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `systemctl restart httpd php-fpm`은 같은 서버의 웹 서비스를 잠시 중단한다. 다른 웹 서비스가 있는 서버라면 점검 시간에 수행한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | root 권한을 확인한다: `id -u` | 출력이 `0`이다 |
| 2 | 서버 IP를 확인한다: `ip -br addr` | `<서버 IP>`를 메모한다 |
| 3 | 인터넷 연결을 확인한다: `curl -I https://repo.zabbix.com` | `HTTP` 응답이 온다 |

## 5. 절차

### A. 패키지 갱신과 설치

1. (5-A-01) 갱신하고 웹, PHP, DB를 설치한다: `dnf update -y && dnf install -y httpd php php-mysqli mariadb-server` → 결과: 오류 없이 끝난다.
2. (5-A-02) PHP-FPM을 설치한다: `dnf install -y php-fpm` → 결과: 설치가 끝난다.

### B. 저장소 추가와 Zabbix 설치

1. (5-B-01) Zabbix 저장소를 추가한다: `rpm -Uvh https://repo.zabbix.com/zabbix/7.0/alma/9/x86_64/zabbix-release-7.0-2.el9.noarch.rpm && dnf clean all` → 결과: 저장소가 추가된다.
2. (5-B-02) Zabbix 패키지를 설치한다: `dnf install -y zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent` → 결과: 설치가 끝난다.
3. (5-B-03) 웹 서비스용 방화벽을 허용한다: `firewall-cmd --permanent --add-service=http` 이어서 `firewall-cmd --reload` → 결과: `success`가 출력된다.
4. (5-B-04) httpd와 MariaDB를 시작한다: `systemctl start httpd mariadb && systemctl enable httpd mariadb` → 결과: 오류 없이 끝난다.
5. (5-B-05) MariaDB 초기 보안 설정을 실행한다: `mysql_secure_installation` → 결과: 안내에 따라 root 비밀번호를 설정하고 익명 사용자와 테스트 DB를 제거한다.

### C. DB 초기 설정

1. (5-C-01) DB에 접속한다: `mysql -u root -p` → 결과: `MariaDB [(none)]>` 프롬프트가 나온다.
2. (5-C-02) DB를 만든다: `create database zabbix_db character set utf8 collate utf8_bin;` (Zabbix 7.0 공식 문서는 `utf8mb4`와 `utf8mb4_bin`을 권장한다. 확인 필요)
3. (5-C-03) 사용자를 만든다: `create user 'zabbix_user'@'localhost' identified by '<DB 비밀번호>';`
4. (5-C-04) 권한을 부여한다: `grant all privileges on zabbix_db.* to 'zabbix_user'@'localhost';` (원본의 `with grant option`은 불필요한 권한이므로 뺐다)
5. (5-C-05) 스키마 가져오기 동안 함수 생성을 허용한다: `set global log_bin_trust_function_creators = 1;`
6. (5-C-06) 권한을 적용하고 나간다: `flush privileges; quit;` → 결과: 각 문장이 `Query OK`를 출력한다.

### D. 스키마 가져오기

1. (5-D-01) 스크립트 위치로 이동한다: `cd /usr/share/zabbix-sql-scripts/mysql/`
2. (5-D-02) 스키마를 가져온다: `zcat ./server.sql.gz | mysql --default-character-set=utf8mb4 -u<DB 사용자> -p'<DB 비밀번호>' <DB 이름>` → 결과: 오류 없이 끝난다. `<DB 사용자>`는 `zabbix_user`, `<DB 이름>`은 `zabbix_db`다. 비밀번호를 명령줄에 쓰면 셸 기록에 남으므로 `-p`만 쓰고 프롬프트에 입력하는 방법을 권한다.
3. (5-D-03) 가져온 뒤 함수 생성 허용을 끈다: `mysql -u root -p`로 접속해 `set global log_bin_trust_function_creators = 0;` 입력 (Zabbix 공식 문서의 권장 순서이며 원본에는 없던 보충, 확인 필요)
4. (5-D-04) 테이블을 확인한다: `mysql -u root -p` 접속 후 `use zabbix_db; show tables;` → 결과: Zabbix 테이블 목록이 출력된다.

### E. Zabbix 서버와 에이전트 설정

1. (5-E-01) 서버 설정을 백업한다: `cp /etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf.bak`
2. (5-E-02) 서버 설정 파일을 연다: `vi /etc/zabbix/zabbix_server.conf`
3. (5-E-03) 세 항목을 설정한다: `DBName=zabbix_db`, `DBUser=<DB 사용자>`, `DBPassword=<DB 비밀번호>` → 결과: 세 줄이 주석 없이 저장된다. (원본은 107, 123, 131행 부근이다.)
4. (5-E-04) 에이전트 설정 파일을 연다: `vi /etc/zabbix/zabbix_agentd.conf`
5. (5-E-05) 세 항목을 설정한다: `Server=127.0.0.1`, `ServerActive=127.0.0.1`, `Hostname=Zabbix server` → 결과: 세 줄이 저장된다. (원본은 117, 171, 182행 부근이다.)
6. (5-E-06) 서버와 에이전트를 시작한다: `systemctl start zabbix-server zabbix-agent && systemctl enable zabbix-server zabbix-agent` → 결과: 오류 없이 끝난다.

### F. PHP 설정

1. (5-F-01) PHP-FPM 설정을 연다: `vi /etc/php-fpm.d/www.conf`
2. (5-F-02) 아래 항목을 추가한다.

```
php_value[max_execution_time] = 300
php_value[memory_limit] = 128M
php_value[post_max_size] = 16M
php_value[upload_max_filesize] = 2M
php_value[max_input_time] = 300
php_value[max_input_vars] = 10000
php_value[date.timezone] = Asia/Seoul
```

→ 결과: 7줄이 저장된다. 원본의 `data.timezone`은 `date.timezone`의 오타로 보아 정정했고, 현재 PHP에서 제거된 `always_populate_raw_post_data`는 뺐다(확인 필요).
3. (5-F-03) 서비스를 재시작한다: `systemctl restart zabbix-agent httpd php-fpm` → 결과: 오류 없이 끝나고 `systemctl is-active httpd php-fpm`이 모두 `active`다.

### G. 웹 파일 배치와 웹 설치

1. (5-G-01) 웹 파일을 복사한다: `mkdir /var/www/html/zabbix && cp -R /usr/share/zabbix/* /var/www/html/zabbix` → 결과: `/var/www/html/zabbix`에 파일이 있다. `zabbix-apache-conf`가 이미 `/zabbix` 경로를 제공하므로 이 복사가 필요 없을 수 있다(확인 필요).
2. (5-G-02) 브라우저에서 `http://<서버 IP>/zabbix`에 접속한다 → 결과: 웹 설치 마법사가 나온다.
3. (5-G-03) DB 정보를 입력한다: DB 종류 `MySQL`, DB 이름 `zabbix_db`, 사용자 `zabbix_user`, 비밀번호 `<DB 비밀번호>` → 결과: 마법사가 DB 연결을 확인한다. 서버와 DB가 같은 장치에 있으면 포트는 `0`(기본값)을 쓸 수 있다.
4. (5-G-04) 마법사를 끝내고 로그인한다: `<기본 계정>`과 `<기본 비밀번호>`(설치 직후 기본값은 Zabbix 공식 문서를 확인한다) → 결과: 대시보드가 열린다.
5. (5-G-05) 즉시 기본 계정의 비밀번호를 바꾼다: `Users > Users`에서 해당 계정 선택 후 변경 → 결과: 새 비밀번호로 다시 로그인된다.
6. (5-G-06) 설정에 문제가 있으면 `/etc/zabbix/web/zabbix.conf.php`를 수정한다.

### H. 에이전트 설치 (대상 호스트 운영체제별로 하나 선택)

{% hint style="info" %}
NOTE: 원본은 "Zabbix가 SNMP로 에이전트와 통신한다"고 적었으나 Zabbix 에이전트는 SNMP가 아니라 Zabbix 자체 프로토콜을 쓴다. SNMP는 에이전트를 설치할 수 없는 장비용의 별도 수집 방식이다. 서버가 에이전트에 접속하는 방식(패시브)은 에이전트의 10050/tcp를, 에이전트가 서버로 접속하는 방식(액티브)은 서버의 10051/tcp를 쓴다.
{% endhint %}

#### H-1. Windows

1. (5-H1-01) 운영체제에 맞는 에이전트를 https://www.zabbix.com/download_agents 에서 받아 설치한다 → 결과: 설치가 끝난다.
2. (5-H1-02) 에이전트 설정 파일(`zabbix_agentd.conf`)에서 `Server`와 `ServerActive`를 `<서버 IP>`로, `Hostname`을 원하는 이름으로 바꾼다. 필요하면 `ListenPort` 주석을 해제한다 → 결과: 값이 저장된다.
3. (5-H1-03) `zabbix_agentd.exe`를 관리자 권한으로 실행하거나 서비스 관리자에서 Zabbix Agent 서비스를 시작한다 → 결과: 서비스가 `실행 중`이다.
4. (5-H1-04) Windows 방화벽에서 `<서버 IP>`로부터 오는 TCP 10050 인바운드를 허용한다 → 결과: 허용 규칙이 목록에 보인다.
5. (5-H1-05) 서버에서 에이전트 접속 방식에 따라 10051/tcp를 허용한다: `firewall-cmd --permanent --add-port=10051/tcp` 이어서 `firewall-cmd --reload` → 결과: `success`가 출력된다.

#### H-2. RHEL 계열 (Alma, Rocky 등)

1. (5-H2-01) 저장소를 추가한다: `rpm -Uvh https://repo.zabbix.com/zabbix/7.0/alma/9/x86_64/zabbix-release-7.0-2.el9.noarch.rpm && dnf clean all`
2. (5-H2-02) 설치한다: `dnf install -y zabbix-agent` → 결과: 설치가 끝난다.
3. (5-H2-03) 설정 파일을 연다: `vi /etc/zabbix/zabbix_agentd.conf`
4. (5-H2-04) `Server`, `ServerActive`를 `<서버 IP>`로, `Hostname`을 원하는 이름으로 설정한다 → 결과: 세 줄이 저장된다.
5. (5-H2-05) 시작한다: `systemctl start zabbix-agent && systemctl enable zabbix-agent` → 결과: 오류 없이 끝난다.
6. (5-H2-06) 방화벽을 허용한다: `firewall-cmd --permanent --add-port=10050/tcp` 이어서 `firewall-cmd --reload` → 결과: `success`가 출력된다.

#### H-3. Ubuntu / Debian

1. (5-H3-01) 저장소 패키지를 받는다: `wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu24.04_all.deb`
2. (5-H3-02) 설치한다: `dpkg -i ./zabbix-release_7.0-2+ubuntu24.04_all.deb && apt update && apt install -y zabbix-agent` → 결과: 설치가 끝난다.
3. (5-H3-03) 설정 파일을 연다: `vi /etc/zabbix/zabbix_agentd.conf`
4. (5-H3-04) `Server`, `ServerActive`를 `<서버 IP>`로, `Hostname`을 원하는 이름으로 설정한다 → 결과: 세 줄이 저장된다.
5. (5-H3-05) 시작한다: `systemctl start zabbix-agent && systemctl enable zabbix-agent` → 결과: 오류 없이 끝난다.
6. (5-H3-06) 방화벽에서 10050/tcp를 허용한다. 원본은 `firewall-cmd`를 썼으나 Ubuntu 기본 방화벽은 `ufw`다. 예: `ufw allow from <서버 IP> to any port 10050 proto tcp` → 결과: 규칙이 추가된다.

### I. 서버에서 호스트 등록

1. (5-I-01) Zabbix 웹에 로그인한다.
2. (5-I-02) `Data collection > Hosts`를 연다. 원본의 경로는 `Monitoring > Hosts`이며, 7.0에서는 `Data collection > Hosts`다(확인 필요).
3. (5-I-03) `Create host`를 누른다.
4. (5-I-04) 호스트 이름(에이전트 설정의 `Hostname`과 같은 값), 템플릿(예: `Linux by Zabbix agent`, Windows는 `Windows by Zabbix agent`), 호스트 그룹, 인터페이스(`Agent`, 주소 `<에이전트 IP>`, 포트 10050)를 입력한다 → 결과: 호스트가 목록에 추가된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `systemctl is-active zabbix-server zabbix-agent httpd mariadb php-fpm` | 모두 실행 중이다 | 모두 `active` |
| 2 | 브라우저에서 `http://<서버 IP>/zabbix` | 로그인 화면이 나온다 | 새 비밀번호로 로그인된다 |
| 3 | 호스트 목록의 `Availability` | 에이전트가 연결된다 | `ZBX` 표시가 녹색이다. 연결 직후 2~5분이 걸릴 수 있다 |
| 4 | `Monitoring > Latest data`에서 호스트 선택 | 수집값이 보인다 | CPU, 메모리 항목에 값이 있다 |

## 7. 복구

1. (7-01) 서비스를 중지한다: `systemctl disable --now zabbix-server zabbix-agent`
2. (7-02) 서버 설정을 되돌린다: `cp /etc/zabbix/zabbix_server.conf.bak /etc/zabbix/zabbix_server.conf`
3. (7-03) 추가한 방화벽 규칙을 제거한다: `firewall-cmd --permanent --remove-port=10050/tcp`, `firewall-cmd --permanent --remove-port=10051/tcp`, `firewall-cmd --reload`
4. (7-04) DB를 지우려면 `mysql -u root -p`로 접속해 `drop database zabbix_db; drop user 'zabbix_user'@'localhost';`를 입력한다 → 결과: 수집된 데이터가 모두 삭제된다. 되돌릴 수 없으므로 필요하면 먼저 덤프로 백업한다.
5. (7-05) 에이전트를 제거한다: RHEL은 `dnf remove -y zabbix-agent`, Ubuntu는 `apt remove -y zabbix-agent`, Windows는 프로그램 제거에서 삭제한다.

## 8. 참조: 항목 요약

| 항목 | 값 |
|---|---|
| DB 이름 | `zabbix_db` |
| DB 사용자 | `zabbix_user` |
| 웹 기본 계정 | `<기본 계정>` (공식 문서 확인) |
| 에이전트 포트 | 10050/tcp |
| 서버 포트 | 10051/tcp |

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 단계형·탭형 원본을 MP 형식으로 재작성. 원본의 기본 계정/비밀번호(`Admin`/`zabbix`)와 DB 비밀번호 자리를 `<기본 계정>`, `<기본 비밀번호>`, `<DB 비밀번호>`로 바꾸고 변경 WARNING을 추가했다. 탭 블록은 구역 H-1~H-3으로 풀었다. "SNMP로 통신" 서술, `data.timezone` 오타, `with grant option`을 정정했다. CAUTION, 기능 확인, 복구 절을 추가했다 |
