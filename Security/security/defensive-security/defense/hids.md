# 호스트 침입 탐지 시스템 (HIDS)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-DEF-002-MP |
| 목적 | OSSEC HIDS 서버를 설치하고 에이전트를 등록해 호스트의 경고를 서버에서 확인한다 |
| 적용 대상 | 서버: Ubuntu Linux, root 권한. 에이전트: Ubuntu 또는 Rocky Linux. 실습망(가상 머신) 기준 |
| 소요 시간 | 약 40분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 환경에서 설치·실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 "RULE을 활용해 패킷을 검출한다"는 서술은 정정했다. OSSEC은 호스트의 로그, 파일 무결성, 루트킷 흔적을 룰로 분석한다. 패킷 분석은 NIDS인 [Snort](snort.md)의 역할이다. 원본의 Windows 에이전트 설치 절은 화면 이미지뿐이어서 절차를 쓰지 못했다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [침입 탐지 시스템 (IDS)](ids.md) | SEC-DEF-001-DO | NIDS와 HIDS의 차이 |
| [Wazuh 보안 관제 시스템 구축](wazuh.md) | SEC-DEF-007-MP | OSSEC에서 갈라져 나온 후속 도구 |
| [firewalld 방화벽 관리](../../../../Linux/guide/security/firewalld.md) | LNX-SEC-001-MP | 방화벽 포트 허용 |
| OSSEC 공식 사이트 | - | https://www.ossec.net/download-ossec/ |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | HIDS 서버 | Ubuntu Linux, 인터넷 연결, root 권한 | 패키지 저장소는 Atomicorp를 쓴다 |
| 2 | 에이전트 호스트 | Ubuntu 또는 Rocky Linux | 서버와 통신 가능한 사설망에 둔다 |
| 3 | 방화벽 관리 도구 | firewalld 또는 ufw | 서버 포트 1514 허용에 쓴다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 에이전트 인증 키는 비밀번호와 같다. 키가 노출되면 다른 호스트가 그 에이전트인 척 서버에 로그를 보낼 수 있다. 문서, 채팅, 저장소에 키를 붙여 넣지 않는다. 이 문서는 키를 `<에이전트 키>`로 표기한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 방화벽 규칙을 잘못 바꾸면 SSH 접속이 끊긴다. 5-E 구역을 수행하기 전에 콘솔 접근을 확보하고, `ssh` 허용 규칙이 남아 있는지 확인한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | root 권한을 확인한다: `id -u` | 출력이 `0`이다 |
| 2 | 서버와 에이전트의 IP를 확인한다: `ip -br addr` | `<서버 IP>`, `<에이전트 IP>`를 메모한다 |
| 3 | 설정 파일을 수정하기 전에 백업할 준비를 한다 | 5-C-02에서 `ossec.conf`를 복사한다 |

## 5. 절차

### A. 서버: 라이브러리와 저장소 준비

1. (5-A-01) 빌드 라이브러리를 설치한다: `apt install -y build-essential make zlib1g-dev libpcre2-dev libevent-dev libssl-dev libz-dev libsqlite3-dev` → 결과: 오류 없이 설치가 끝난다.
2. (5-A-02) Atomicorp 저장소 설치 스크립트를 받아 실행한다: `wget -q -O - https://updates.atomicorp.com/installers/atomic | bash` → 결과: 저장소가 등록된다.
3. (5-A-03) 패키지 목록을 갱신한다: `apt update` → 결과: 갱신이 오류 없이 끝난다.

{% hint style="warning" %}
CAUTION: 5-A-02는 내려받은 스크립트를 root 권한으로 바로 실행한다. 스크립트 출처가 올바른지 확인한 뒤 수행한다.
{% endhint %}

### B. 서버: 설치

1. (5-B-01) 서버 패키지를 설치한다: `apt install -y ossec-hids-server` → 결과: `/var/ossec` 디렉터리가 만들어진다.

### C. 서버: 환경설정

1. (5-C-01) 설정 파일을 백업한다: `cp /var/ossec/etc/ossec.conf /var/ossec/etc/ossec.conf.bak`
2. (5-C-02) 설정 파일을 연다: `vi /var/ossec/etc/ossec.conf`
3. (5-C-03) `<remote>` 블록에 에이전트 허용 대역을 추가한다. 예:

```xml
<remote>
  <connection>secure</connection>
  <allowed-ips><에이전트가 속한 대역, 예: 192.168.0.0/16></allowed-ips>
</remote>
```

→ 결과: `connection`은 `secure`이고 `allowed-ips`에 에이전트 대역이 있다. 대역은 에이전트가 속한 가장 좁은 범위로 쓴다.

### D. 서버: 에이전트 등록과 키 발급

1. (5-D-01) 관리 도구를 실행한다: `cd /var/ossec/bin && ./manage_agents` → 결과: `Choose your action: A,E,L,R or Q:` 메뉴가 나온다.
2. (5-D-02) `A`를 입력한다 → 결과: 새 에이전트 추가 입력창이 나온다.
3. (5-D-03) 에이전트 이름, IP, ID를 입력한다(예: 이름 `<에이전트 이름>`, IP `<에이전트 IP>`, ID `001`) → 결과: `Agent information`이 표시된다.
4. (5-D-04) `y`를 입력해 확정한다 → 결과: `Agent added with ID 001.`이 출력된다.
5. (5-D-05) 메뉴에서 `E`를 입력하고 에이전트 ID `001`을 입력한다 → 결과: `Agent key information for '001' is:` 아래에 키가 출력된다.
6. (5-D-06) 출력된 키를 에이전트 호스트에 안전하게 전달할 수 있는 방법으로 보관한다 → 결과: 5-F-04에서 입력할 `<에이전트 키>`를 확보했다.

### E. 서버: 구동과 방화벽 허용

1. (5-E-01) 서버를 시작한다: `/var/ossec/bin/ossec-control start` → 결과: 각 데몬이 `Started`로 표시된다. 인수 없이 `./ossec-control`만 입력하면 사용 가능한 명령이 나온다.

{% hint style="warning" %}
CAUTION: 아래 방화벽 명령은 firewalld 기준이다. Ubuntu 기본 방화벽은 `ufw`이므로 환경에 맞는 도구를 쓴다. 규칙을 적용한 뒤에도 SSH 접속이 유지되는지 5-E-03에서 확인한다.
{% endhint %}

2. (5-E-02) 에이전트 통신 포트를 허용한다(firewalld 사용 시):

```bash
firewall-cmd --permanent --add-port=1514/tcp
firewall-cmd --permanent --add-port=1514/udp
firewall-cmd --reload
```

→ 결과: 각 명령이 `success`를 출력한다.
3. (5-E-03) 다른 PC에서 SSH 접속이 되는지 확인한다 → 결과: 로그인 프롬프트가 나온다.

### F. 에이전트: 설치와 서버 등록

Ubuntu 에이전트:

1. (5-F-01) 에이전트를 설치한다: `apt install -y ossec-hids-agent` → 결과: 설치가 끝난다.
2. (5-F-02) 설정 파일을 연다: `vi /var/ossec/etc/ossec.conf`
3. (5-F-03) `<client>` 블록의 서버 주소를 `<서버 IP>`로 수정한다 → 결과: `<server-ip>`에 서버 IP가 들어 있다.
4. (5-F-04) 키를 등록한다: `/var/ossec/bin/manage_agents`를 실행해 `I`(키 가져오기)를 입력하고 `<에이전트 키>`를 붙여 넣은 뒤 `y`, `q` 순서로 입력한다 → 결과: 에이전트가 키를 가져왔다는 메시지가 나온다.
5. (5-F-05) 에이전트를 시작한다: `/var/ossec/bin/ossec-control start` → 결과: 데몬이 시작된다.

Rocky Linux 에이전트(5-F-01 대신):

1. (5-F-06) 빌드 라이브러리를 설치한다: `dnf install -y gcc make zlib-devel pcre2-devel libevent-devel openssl-devel sqlite-devel`
2. (5-F-07) 저장소를 등록한다: `wget -q -O - https://updates.atomicorp.com/installers/atomic | sudo bash` 이어서 `dnf update`
3. (5-F-08) 에이전트를 설치한다: `dnf install -y ossec-hids-agent` → 결과: 설치가 끝난다. 이후 5-F-02부터 Ubuntu와 같은 순서로 진행한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 에이전트에서 `/var/ossec/bin/ossec-control status` | 에이전트 데몬이 실행 중이다 | `ossec-agentd`가 `is running`이다 |
| 2 | 서버에서 `/var/ossec/bin/manage_agents`로 `L` 입력 | 등록한 에이전트가 목록에 있다 | 에이전트 이름과 IP가 보인다 |
| 3 | 서버에서 `tree /var/ossec/logs` | 로그 디렉터리 구조가 보인다 | `alerts`, `ossec.log` 등이 있다 |
| 4 | 서버에서 `tail -f /var/ossec/logs/alerts/alerts.log` 실행 후 에이전트에서 `sudo` 인증 실패를 1회 만든다 | 서버에 경고가 나타난다 | 에이전트 이름이 포함된 경고가 출력된다 |

### 룰 관리

탐지 룰은 `/var/ossec/rules` 디렉터리에서 관리한다. 룰을 바꾼 뒤에는 서버를 재시작해야 반영된다: `/var/ossec/bin/ossec-control restart`

## 7. 복구

1. (7-01) 서버와 에이전트를 중지한다: `/var/ossec/bin/ossec-control stop`
2. (7-02) 서버 설정을 되돌린다: `cp /var/ossec/etc/ossec.conf.bak /var/ossec/etc/ossec.conf` → 결과: 5-C에서 바꾼 내용이 사라진다.
3. (7-03) 추가한 방화벽 규칙을 제거한다: `firewall-cmd --permanent --remove-port=1514/tcp`, `firewall-cmd --permanent --remove-port=1514/udp`, `firewall-cmd --reload`
4. (7-04) 에이전트를 등록 해제한다: 서버에서 `manage_agents`를 실행해 `R`을 입력하고 에이전트 ID를 입력한다 → 결과: 목록에서 에이전트가 사라진다.
5. (7-05) 완전히 제거하려면 `apt remove -y ossec-hids-server`(에이전트는 `ossec-hids-agent`)를 입력한다.

## 8. 참조: 용어

| 용어 | 뜻 |
|---|---|
| 루트킷(rootkit) | 침입자가 관리자 권한을 유지하고 자신의 흔적을 숨기려고 쓰는 도구 모음. HIDS가 탐지 대상으로 삼는다 |
| 에이전트 | 호스트의 로그와 파일 변경을 모아 서버로 보내는 프로그램 |

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 단계형 원본을 MP 형식으로 재작성. 에이전트 키를 `<에이전트 키>`로 바꾸고 노출 WARNING, 방화벽 CAUTION, 복구 절차를 추가했다. "패킷 검출" 서술을 정정했다. 원본의 중복된 방화벽 명령 절은 5-E로 합쳤다. 5-F-04의 `I` 입력은 원본의 입력 순서(i, 키, y, q)를 옮긴 것이다 |
