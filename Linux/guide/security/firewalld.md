# firewalld 방화벽 관리

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-SEC-001-MP |
| 목적 | firewalld의 상태, zone, 서비스 정책을 확인하고 zone, 서비스, 소스, rich rule을 설정한다 |
| 적용 대상 | RHEL 계열 9, firewalld 사용 중인 서버, root 또는 sudo 권한 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 구역 A는 조회만 하므로 위험이 없다. 구역 B~D는 방화벽 정책을 바꾼다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [iptables.md](iptables.md) | LNX-SEC-002-MP | iptables 방화벽 규칙 (firewalld와 동시에 쓰지 않는다) |
| [remote-access-management.md](../network-remote/remote-access-management.md) | LNX-NRM-002-MP | 원격 접속 관리 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 대상 서버 | RHEL 계열 9, firewalld 실행 중 | |
| 2 | 콘솔 접근 | 가상 머신 화면 또는 물리 콘솔 | SSH 단절에 대비한다 |
| 3 | 다른 PC | SSH 접속 확인용 | 기능 확인에서 사용 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: zone이나 규칙을 잘못 바꾸면 SSH(22/tcp) 접속이 끊긴다. 변경 전에 콘솔 접근을 확보하고, 접속에 쓰는 zone에 `ssh` 서비스가 남아 있는지 확인한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `--permanent` 옵션 없이 입력한 규칙은 `firewall-cmd --reload` 또는 재부팅 시 사라진다. `--permanent`로 입력한 규칙은 `firewall-cmd --reload`를 실행해야 실행 중인 설정에 적용된다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | firewalld가 실행 중이다 | `firewall-cmd --state`가 `running`을 출력한다 |
| 2 | 현재 설정을 보관한다 | `firewall-cmd --list-all-zones > <백업 파일 경로>`가 파일을 만든다 |
| 3 | 콘솔에 로그인할 수 있다 | 로그인 프롬프트가 보인다 |

## 5. 절차

### A. 상태와 정책 확인

1. (5-A-01) 실행 상태를 확인한다: `firewall-cmd --state` → 결과: `running`이 출력된다.
2. (5-A-02) 서비스 상태를 확인한다: `systemctl status firewalld` → 결과: `active (running)`이 보인다.
3. (5-A-03) 현재 정책을 확인한다: `firewall-cmd --list-all` → 결과: 기본 zone의 서비스, 포트, 규칙이 출력된다.
4. (5-A-04) 기본 zone을 확인한다: `firewall-cmd --get-default-zone` → 결과: 보통 `public`이 출력된다.
5. (5-A-05) 활성 zone을 확인한다: `firewall-cmd --get-active-zone` → 결과: zone과 연결된 인터페이스가 출력된다.
6. (5-A-06) 모든 zone 이름을 확인한다: `firewall-cmd --get-zones`
7. (5-A-07) 특정 zone의 정책을 확인한다: `firewall-cmd --zone=<zone 이름> --list-all` → 결과: 해당 zone의 정책이 출력된다.
8. (5-A-08) 서비스 또는 포트만 확인한다: `firewall-cmd --zone=public --list-services` 또는 `firewall-cmd --zone=public --list-ports`
9. (5-A-09) 영구 설정만 확인한다: `firewall-cmd --zone=public --list-services --permanent`
10. (5-A-10) 사용 가능한 서비스 이름을 확인한다: `firewall-cmd --get-services`

### B. zone 할당과 기본 zone 변경

{% hint style="danger" %}
WARNING: 접속에 쓰는 인터페이스를 `ssh` 서비스가 없는 zone으로 옮기거나 그런 zone을 기본 zone으로 지정하면 SSH 접속이 끊긴다. 대상 zone의 서비스 목록(5-A-07)에 `ssh`가 있는지 먼저 확인한다.
{% endhint %}

1. (5-B-01) 인터페이스에 zone을 할당한다: `firewall-cmd --zone=<zone 이름> --change-interface=<인터페이스 이름>` → 결과: `success`가 출력된다. zone을 할당하면 자동으로 활성 상태가 된다. 이 설정은 실행 중인 설정에만 적용된다.
2. (5-B-02) 기본 zone을 변경한다: `firewall-cmd --set-default-zone=<zone 이름>` → 결과: `success`가 출력된다.

### C. zone 생성과 서비스, 소스 설정

1. (5-C-01) zone을 만든다: `firewall-cmd --permanent --new-zone=<zone 이름>` → 결과: `success`가 출력된다.
2. (5-C-02) 새 zone을 인식시킨다: `firewall-cmd --reload` → 결과: `success`가 출력된다. 새 zone은 reload 후에 사용할 수 있다.
3. (5-C-03) zone에 서비스를 허용한다: `firewall-cmd --permanent --zone=<zone 이름> --add-service=<서비스 이름>` → 결과: `success`가 출력된다. 서비스 이름은 5-A-10에서 확인한 값을 쓴다(웹 서버는 `http`).
4. (5-C-04) 소스 IP 또는 네트워크 대역을 zone에 연결한다: `firewall-cmd --permanent --zone=<zone 이름> --add-source=<IP 주소 또는 네트워크 대역>` → 결과: `success`가 출력된다. 예: `192.168.0.0/16` 형식의 대역도 가능하다.
5. (5-C-05) 설정을 적용한다: `firewall-cmd --reload`
6. (5-C-06) 연결한 소스를 제거할 때는 다음을 입력한다: `firewall-cmd --permanent --zone=<zone 이름> --remove-source=<IP 주소 또는 네트워크 대역>` 이어서 `firewall-cmd --reload`

### D. rich rule 설정

rich rule은 소스, 서비스, 동작을 조합한 세부 정책이다.

{% hint style="danger" %}
WARNING: `drop` 또는 `reject` 규칙의 소스에 관리자 접속 IP가 포함되면 SSH 접속이 끊긴다. 소스 주소를 다시 확인한 뒤 적용한다.
{% endhint %}

1. (5-D-01) 규칙을 추가한다: `firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="<IP 주소>" service name="ssh" accept'` → 결과: `success`가 출력된다. 이 규칙은 `<IP 주소>`에서 22/tcp(ssh)로 오는 IPv4 패킷을 허용한다.
2. (5-D-02) 설정을 적용한다: `firewall-cmd --reload` → 결과: `success`가 출력된다.

| 요소 | 뜻 |
|---|---|
| `source address` | 출발지. 네트워크 대역도 가능하다 |
| `accept` | 허용 |
| `drop` | 응답 없이 차단 |
| `reject` | 차단하고 접속 시도자에게 거부 메시지를 보낸다 |

도움말은 `firewall-cmd --help`로 본다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `firewall-cmd --zone=<zone 이름> --list-all --permanent` | 설정한 서비스, 소스, rich rule이 보인다 | 5절에서 입력한 항목이 모두 있다 |
| 2 | 다른 PC에서 `ssh <사용자명>@<IP 주소>` | 접속된다 | 로그인 프롬프트가 나온다 |
| 3 | `firewall-cmd --get-active-zone` | zone과 인터페이스가 의도한 대로다 | 접속 인터페이스가 `ssh`를 허용하는 zone에 있다 |

## 7. 복구

1. (7-01) 추가한 규칙을 제거한다: 추가 명령의 `--add-...`를 `--remove-...`로 바꿔 같은 인수로 입력한다(`--permanent` 포함).
2. (7-02) 설정을 다시 읽는다: `firewall-cmd --reload` → 결과: `success`가 출력된다.
3. (7-03) 기본 zone을 원래대로 돌린다: `firewall-cmd --set-default-zone=<원래 zone 이름>`
4. (7-04) SSH 접속이 끊겼다면 콘솔에서 7-01~7-03을 수행한다.

## 8. 참조: firewalld 설정 파일

| 경로 | 내용 |
|---|---|
| `/usr/lib/firewalld/services/` | 서비스 정의 파일. 예: `ssh.xml`은 `tcp` 22번 포트를 정의한다 |
| `/usr/lib/firewalld/zones/` | 기본 zone 정의 파일. `block`, `dmz`, `drop`, `external`, `home`, `internal`, `public`, `trusted`, `work` 등 |
| `/etc/firewalld/` | 사용자가 만든 zone과 서비스 설정 위치 |

`public.xml`의 기본 허용 서비스는 `ssh`, `dhcpv6-client`, `cockpit`이다.

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 명령 모음이던 원본을 MP 형식으로 재작성. 접속 단절 WARNING, `--permanent`와 reload 주의, 복구 절차를 추가했다. 서비스 예 `httpd`를 `http`로 정정했다 |
