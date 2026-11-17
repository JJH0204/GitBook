# 웹 서버 설정 및 명령어 (WebServer)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-WBB-004-MP |
| 목적 | Rocky Linux에 Apache(httpd)를 설치하고 `index.html`을 웹으로 확인한다 |
| 적용 대상(Effectivity) | Rocky Linux 9(RHEL 계열), `dnf`, root 또는 sudo 권한, 테스트 서버 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 문서로 다시 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 방화벽 단계는 `firewall-cmd ~~`로 미완성이었다. 완성된 명령을 지어내지 않고 [firewalld 방화벽 관리](../../../../Linux/guide/security/firewalld.md)(LNX-SEC-001-MP)를 참조하게 했다. 원본에 적힌 FQDN 예시 "IP:포트"는 FQDN(정규화된 도메인 이름)이 아니므로 정정했다. 예시 IP는 `192.168.x.x` 대역으로 바꿨다. 원본의 `mariadb` 패키지는 `mariadb-server`가 서버 패키지이므로 정정했다. 확인 필요.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [firewalld.md](../../../../Linux/guide/security/firewalld.md) | LNX-SEC-001-MP | firewalld 방화벽 관리 |
| [service-management.md](../../../../Linux/guide/services/service-management.md) | LNX-SVC-002-MP | 불필요한 서비스 관리 및 비활성화 |
| [mariadb.md](../../../../DB/operations/mariadb.md) | DB-OPS-001-MP | MariaDB 기본 사용법 |
| [html.md](html.md) | PRG-WBB-006-DO | HTML 기초 |
| [domain_name.md](../../../../Network/protocols/domain_name.md) | NET-PRT-013-DO | 도메인 이름 |

외부 자료: [systemctl 정리](https://www.kernelpanic.kr/20)

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 서버 | Rocky Linux 9, 인터넷 연결 | 테스트용 |
| 2 | 권한 | root 또는 sudo | |
| 3 | 패키지 | `httpd` | 필수 |
| 4 | 패키지 | `mariadb-server`, `php` | 선택(DB·동적 페이지가 필요할 때) |
| 5 | 클라이언트 | 같은 네트워크의 브라우저 | 기능 확인용 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 방화벽 정책을 바꾸면 SSH 접속이 끊겨 서버에 다시 접속하지 못할 수 있다. 80/tcp만 허용하는 단계에서도 기존 서비스(`ssh`) 규칙을 지우지 않는다. 운영 서버에서는 콘솔 접속 수단을 확보한 뒤 수행한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `httpd`를 시작하면 서버가 80/tcp로 외부 요청을 받는다. 테스트가 끝나면 7절 복구를 수행한다. 설정 파일을 고치기 전에 백업한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | root 또는 sudo 권한이 있다 | `id` 결과에 root 또는 `wheel` 그룹이 보인다 |
| 2 | 인터넷에 연결돼 있다 | `dnf repolist`가 오류 없이 끝난다 |
| 3 | 서버 IP를 안다 | `ip addr`로 확인한다(예시: `192.168.1.101`) |

## 5. 절차

### A. 패키지 설치

1. (5-A-01) 웹 서버 패키지를 설치한다: `dnf install httpd -y` → 결과: `Complete!`가 출력된다.
2. (5-A-02) 필요하면 DB와 PHP를 설치한다: `dnf install mariadb-server php -y` → 결과: `Complete!`가 출력된다.

### B. 서비스 시작과 등록

1. (5-B-01) 서비스를 시작한다: `systemctl start httpd`
2. (5-B-02) 부팅 시 자동 시작하게 등록한다: `systemctl enable httpd` → 결과: 심볼릭 링크 생성 메시지가 출력된다.
3. (5-B-03) 상태를 확인한다: `systemctl status httpd` → 결과: `active (running)`이 보인다.

`status`, `stop`, `restart`, `disable`도 같은 형식으로 쓴다.

### C. 방화벽에서 80/tcp 허용

{% hint style="danger" %}
WARNING: 이 단계는 방화벽 정책을 변경한다. [firewalld 방화벽 관리](../../../../Linux/guide/security/firewalld.md)(LNX-SEC-001-MP)의 절차를 따른다. 기존 규칙을 지우지 않는다.
{% endhint %}

1. (5-C-01) 현재 방화벽 정보를 확인한다: `firewall-cmd --list-all` → 결과: 현재 zone과 허용 서비스가 출력된다.
2. (5-C-02) HTTP 서비스를 영구 허용한다: `firewall-cmd --permanent --add-service=http`
3. (5-C-03) 정책을 적용한다: `firewall-cmd --reload` → 결과: `success`가 출력된다.

| 옵션 | 설명 |
|---|---|
| `--list-all` | 방화벽 정보를 출력한다 |
| `--permanent` | 재부팅 후에도 유지되게 영구 적용한다 |
| `--add-service=<서비스 이름>` | 서비스를 허용 목록에 추가한다 |
| `--reload` | 정책 변경 후 적용한다(영구 설정은 반드시 필요하다) |

{% hint style="info" %}
NOTE: 5-C-02, 5-C-03의 서비스 이름 `http`는 원본의 미완성 명령을 보충한 것이며 확인 필요하다.
{% endhint %}

### D. 설정 파일 확인

설정 디렉터리는 `/etc/httpd`이고 주 설정 파일은 `/etc/httpd/conf/httpd.conf`이다.

1. (5-D-01) 설정 파일을 백업한다: `cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak` → 결과: `.bak` 파일이 생긴다.
2. (5-D-02) 설정 파일을 연다: `vi /etc/httpd/conf/httpd.conf`
3. (5-D-03) 다음 항목을 확인한다.

| 항목 | 설명 |
|---|---|
| `<Directory "/var/www/html"> ... </Directory>` | 해당 디렉터리의 접근 권한을 지정하는 블록이다 |
| `LogLevel` | 로그 심각도 수준 |
| `DocumentRoot` | 웹 페이지 소스 저장 경로. 기본은 `/var/www/html`이다 |
| `Listen` | 대기 포트. 기본은 80이다 |

4. (5-D-04) 문법을 검사한다: `apachectl configtest` → 결과: `Syntax OK`가 출력된다.

### E. 페이지 작성

1. (5-E-01) 웹 루트로 이동한다: `cd /var/www/html`
2. (5-E-02) 파일을 만든다: `vi index.html` → 내용은 [HTML 기초](html.md)(PRG-WBB-006-DO)의 예제를 쓴다.
3. (5-E-03) 파일 목록을 확인한다: `ls -al` → 결과: `index.html`이 보인다.

## 6. 기능 확인

웹 서비스 기본 포트는 80이다. 도메인 이름을 쓰면 FQDN(예: `www.example.com`)으로, 쓰지 않으면 IP 주소로 접속한다.

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 서버에서 `curl http://localhost` | `index.html` 내용이 출력된다 | HTTP 200과 본문 |
| 2 | 클라이언트 브라우저에서 `http://192.168.1.101` | `/var/www/html/index.html`이 표시된다 | 페이지가 보인다 |
| 3 | `http://192.168.1.101/<추가 경로>` | `/var/www/html/<추가 경로>`의 내용이 표시된다 | 해당 파일이 보인다 |
| 4 | `systemctl status httpd` | 서비스가 실행 중이다 | `active (running)` |

{% hint style="info" %}
NOTE: 클라이언트에서 접속되지 않으면 5-C 방화벽 단계를 확인한다. `index.html`이 없으면 기본 안내 페이지 또는 403 응답이 나올 수 있다.
{% endhint %}

## 7. 복구

1. (7-01) 서비스를 중지한다: `systemctl stop httpd`
2. (7-02) 자동 시작을 해제한다: `systemctl disable httpd`
3. (7-03) 방화벽 허용을 제거한다: `firewall-cmd --permanent --remove-service=http` 후 `firewall-cmd --reload`
4. (7-04) 설정 파일을 되돌린다: `cp /etc/httpd/conf/httpd.conf.bak /etc/httpd/conf/httpd.conf`

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM 형식(MP)으로 재작성. 미완성 방화벽 단계 보충·FQDN·패키지명 정정 |
