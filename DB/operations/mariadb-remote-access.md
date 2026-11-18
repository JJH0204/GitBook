# MariaDB 원격 접속 허용 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-OPS-005-MP |
| 목적 | MariaDB 서버가 다른 호스트의 접속을 받도록 `bind-address`와 포트를 설정하고 방화벽 포트를 연다 |
| 적용 대상(Effectivity) | MariaDB 10.5, Rocky Linux 등 RHEL 계열(`firewalld` 사용), root 또는 sudo 권한 |
| 소요 시간 | 약 15분 |
| 확인 상태 | 미검증 (원본 페이지의 설정 예시를 정리·정정한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [mariadb.md](mariadb.md) | DB-OPS-001-MP | MariaDB 기본 사용법 |
| [dbusermanagement.md](dbusermanagement.md) | DB-OPS-004-MP | DB 사용자 계정 생성과 권한 관리 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | MariaDB 서버 | 10.5, 서비스 `mariadb` | |
| 2 | 설정 파일 | `/etc/my.cnf.d/mariadb-server.cnf` | `/etc/my.cnf`가 `/etc/my.cnf.d`를 포함한다 |
| 3 | 방화벽 | `firewalld` | 포트 3306(기본) |
| 4 | 접속 시험용 다른 호스트 | MariaDB 클라이언트 | 기능 확인에 사용 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 원격 접속을 열면 DB 서버가 네트워크에 노출된다. root 비밀번호를 설정한 뒤에만 수행한다(DB-OPS-001-MP). `bind-address=0.0.0.0`과 방화벽 포트 개방은 신뢰할 수 있는 네트워크(내부망)에서만 한다. 인터넷에 직접 노출하지 않는다.
{% endhint %}

{% hint style="danger" %}
WARNING: root 계정의 원격 접속을 허용하지 않는다. 원격용 계정은 일반 계정으로 만들고 필요한 권한과 호스트만 준다(DB-OPS-004-MP).
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 설정 파일을 백업한다 | `sudo cp /etc/my.cnf.d/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf.bak` → 복사본이 생긴다 |
| 2 | 현재 접속 허용 상태를 기록한다 | `ss -tlnp \| grep mariadbd` (또는 `mysqld`) → 수신 주소가 `127.0.0.1:3306`인지 `0.0.0.0:3306`인지 적어 둔다 |
| 3 | 원격 접속용 계정이 있다 | DB-OPS-004-MP 구역 C 또는 D를 완료했다 |

## 5. 절차

### A. 수신 주소 설정

1. (5-A-01) 설정 파일을 연다: `sudo vi /etc/my.cnf.d/mariadb-server.cnf` → 결과: 편집기가 열린다.
2. (5-A-02) `[mysqld]` 절에 `bind-address` 줄을 추가하거나 수정한다. 값은 아래 표에서 고른다. → 결과: 파일에 줄이 저장된다.

| 설정 | 의미 |
|---|---|
| `bind-address=127.0.0.1` | 이 서버 안에서만 접속한다. 원격 접속을 허용하지 않는다 |
| `bind-address=0.0.0.0` | 서버의 모든 IPv4 주소에서 접속을 받는다 |
| `bind-address=<서버 IP 주소>` | 지정한 서버 주소 한 개에서만 접속을 받는다 |

{% hint style="info" %}
NOTE: 원본은 `bind-address=192.168.56.0/24`를 "해당 네트워크 시스템만 접속 허용"이라고 적었다. `bind-address`는 서버가 수신할 자신의 IP 주소 한 개를 정하며 네트워크 대역(CIDR)을 받지 않는다. 특정 대역만 허용하려면 계정의 호스트(`'<DB 사용자명>'@'<IP 주소>'`, DB-OPS-004-MP 구역 D)나 방화벽 규칙으로 제한한다. 정정했다. 확인 필요.
{% endhint %}

### B. 포트 설정 (기본 포트를 바꿀 때만)

1. (5-B-01) `[mysqld]` 절에 포트를 적는다: `port=<포트 번호>` → 결과: 파일에 줄이 저장된다. 기본값은 3306이다. 줄이 없으면 3306을 쓴다.

{% hint style="info" %}
NOTE: 원본은 `Port=5000`을 적었다. 옵션 이름은 소문자 `port`로 적는다. 값 5000은 예시이며 이 문서는 포트를 `<포트 번호>`로 표기한다. 이후 단계의 `3306`은 기본 포트를 뜻한다. 포트를 바꿨다면 `<포트 번호>`로 읽는다.
{% endhint %}

### C. 서비스 재시작

1. (5-C-01) 서비스를 재시작한다: `sudo systemctl restart mariadb` → 결과: 오류 없이 끝난다.
2. (5-C-02) 상태를 확인한다: `systemctl status mariadb` → 결과: `Active: active (running)`이 보인다. 시작에 실패하면 7절 복구를 수행한다.
3. (5-C-03) 수신 주소를 확인한다: `ss -tlnp | grep 3306` → 결과: 5-A-02에서 정한 주소와 포트가 보인다.

### D. 방화벽 포트 개방

{% hint style="danger" %}
WARNING: 이 단계로 포트 3306이 네트워크에 열린다. 5-A-02에서 허용 범위를 정했는지, 원격 계정의 호스트가 제한돼 있는지 확인한 뒤 수행한다. 가능하면 `--add-port` 대신 허용할 IP 주소만 `rich rule`로 여는 방식을 쓴다.
{% endhint %}

1. (5-D-01) 방화벽 실행 상태를 확인한다: `sudo firewall-cmd --state` → 결과: `running`이 출력된다.
2. (5-D-02) 포트를 영구 규칙으로 연다: `sudo firewall-cmd --permanent --add-port=3306/tcp` → 결과: `success`가 출력된다.
3. (5-D-03) 규칙을 다시 읽는다: `sudo firewall-cmd --reload` → 결과: `success`가 출력된다.
4. (5-D-04) 열린 포트를 확인한다: `sudo firewall-cmd --list-ports` → 결과: `3306/tcp`가 보인다.

{% hint style="info" %}
NOTE: 방화벽 단계(구역 D)는 원본에 없던 내용이다. 원격 접속이 되려면 필요해 추가했다. `firewall-cmd` 사용법은 확인 필요. SELinux를 켠 환경에서 기본 포트가 아닌 포트를 쓰면 SELinux 정책도 바꿔야 할 수 있다. 확인 필요.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 서버에서 `ss -tlnp \| grep 3306` | 수신 주소 | 5-A-02에서 정한 주소 |
| 2 | 다른 호스트에서 `mysql -h <서버 IP 주소> -P 3306 -u <DB 사용자명> -p` 후 `<비밀번호>` 입력 | 접속 | `MariaDB [(none)]>` 프롬프트 |
| 3 | 허용하지 않은 호스트에서 같은 명령 실행 | 접속 거부 | `Access denied` 또는 연결 시간 초과 |

## 7. 복구

1. (7-01) 설정 파일을 되돌린다: `sudo cp /etc/my.cnf.d/mariadb-server.cnf.bak /etc/my.cnf.d/mariadb-server.cnf` → 결과: 복사가 끝난다.
2. (7-02) 서비스를 재시작한다: `sudo systemctl restart mariadb` → 결과: `systemctl is-active mariadb`가 `active`를 출력한다.
3. (7-03) 방화벽 규칙을 제거한다: `sudo firewall-cmd --permanent --remove-port=3306/tcp` 후 `sudo firewall-cmd --reload` → 결과: `sudo firewall-cmd --list-ports`에 `3306/tcp`가 없다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지 `dbperformanceinfo.md`의 설정 파일·`bind-address`·포트 부분을 AMM 형식으로 분리·재작성. 방화벽 단계 추가 |
