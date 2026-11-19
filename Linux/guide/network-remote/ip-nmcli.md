# [생성형 AI] 네트워크 설정 명령어 (ip, ss, nmcli)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-NRM-008-REF |
| 유형 | REF (명령 표) |
| 목적 | 인터페이스, 주소, 경로, 소켓을 조회하는 `ip`, `ss`와 NetworkManager의 `nmcli` 명령을 참조한다 |
| 확인 상태 | 일부 확인 (Ubuntu 26.04에서 `ip -br addr`, `ip route`, `ip -s link show`, `ss -tuln`을 실행했다. `nmcli`는 이 환경에 없어 미검증, 설정 변경 명령은 실행하지 않았다) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 진단 명령 `ping`, `traceroute` 등은 [네트워크 진단 명령어](networkcommands.md)(LNX-NRM-001-REF)에 있다. 이 문서는 조회와 설정 명령을 다룬다.
{% endhint %}

## 1. 조회 (ip, ss)

| 명령어 | 설명 | 형식 | 주요 옵션 | 예 |
|---|---|---|---|---|
| `ip addr` | 인터페이스와 IP 주소를 출력한다 | `ip [-br] addr [show <장치>]` | `-br`: 한 줄 요약 출력(이름, 상태, 주소) | `ip -br addr` |
| `ip link` | 링크 계층 정보와 통계를 출력한다 | `ip [-s] link show [<장치>]` | `-s`: 송수신 바이트, 오류, 폐기 통계 | `ip -s link show <장치>` |
| `ip route` | 라우팅 테이블을 출력한다. `default via`가 기본 게이트웨이다 | `ip route` | | `ip route` |
| `ip neigh` | 이웃(ARP) 테이블을 출력한다 | `ip neigh` | | `ip neigh` |
| `ss` | 소켓 상태를 출력한다 | `ss [옵션]` | `-t`: TCP, `-u`: UDP<br>`-l`: 대기(LISTEN) 소켓만<br>`-n`: 이름 대신 숫자<br>`-p`: 프로세스 표시(다른 사용자의 것은 root 권한 필요) | `ss -tuln` |

`ip addr`의 `UP`은 관리상 켜짐, `LOWER_UP`은 링크 신호 있음을 뜻한다. `ss -tuln`의 `Local Address:Port` 열로 어느 포트가 열려 있는지 확인한다. 열려 있는 포트가 의도한 서비스인지 점검할 때 쓴다.

## 2. 설정 (nmcli, RHEL 계열의 NetworkManager)

| 명령어 | 설명 | 형식 | 예 |
|---|---|---|---|
| `nmcli device status` | 장치와 연결 상태를 출력한다 | `nmcli device status` | `nmcli device status` |
| `nmcli connection show` | 연결(프로파일) 목록을 출력한다 | `nmcli connection show [<연결 이름>]` | `nmcli connection show` |
| `nmcli connection modify` | 연결 설정을 바꾼다 | `nmcli connection modify <연결 이름> <속성> <값>` | `nmcli connection modify <연결 이름> ipv4.method manual ipv4.addresses <주소/접두사> ipv4.gateway <게이트웨이>` |
| `nmcli connection up` | 연결을 활성화해 변경을 적용한다 | `nmcli connection up <연결 이름>` | `nmcli connection up <연결 이름>` |

{% hint style="danger" %}
WARNING: 원격 접속 중인 인터페이스의 주소나 게이트웨이를 바꾸면 접속이 끊긴다. 콘솔을 확보한 뒤 바꾼다. 잘못된 주소를 적용하면 서버에 네트워크로 닿지 못한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `ip addr add` 같은 `ip` 명령으로 바꾼 설정은 재부팅하면 사라진다. 영구 설정은 NetworkManager(`nmcli`) 같은 네트워크 관리 도구로 한다. 같은 인터페이스를 두 방법으로 동시에 관리하지 않는다.
{% endhint %}

## 3. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성 |
