# 네트워크 진단 명령어

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-TOP-001-REF |
| 유형 | REF (명령 표) |
| 목적 | 연결, 경로, 이름 해석, 호스트명을 확인하는 진단 명령을 참조한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 명령 요약이다. Linux 기준 상세 표와 현행 명령 대응표는 [LNX-NRM-001-REF](../../Linux/guide/network-remote/networkcommands.md)를 따른다.
{% endhint %}

## 1. 명령 표

| 명령어 | 설명 | 형식 | 주요 옵션 | 설치 (RHEL 계열) |
|---|---|---|---|---|
| `ping` | 대상과의 연결을 확인한다 | `ping [옵션] <대상>` | `-c`: 요청 횟수 (Linux)<br>`-n`: 요청 횟수 (Windows)<br>`-i`: 요청 간격(초, Linux)<br>`-s`: 패킷 데이터 크기(바이트, Linux) | 기본 포함 |
| `traceroute` | 목적지까지 거치는 경로와 구간별 응답 시간을 표시한다. 경로상 장애 위치를 찾을 때 쓴다 | `traceroute <주소 또는 IP>` | | `dnf install -y traceroute` |
| `tracert` | Windows의 `traceroute` 대응 명령이다 | `tracert <주소 또는 IP>` | | 기본 포함 |
| `nslookup` | 도메인으로 IP를, IP로 도메인을 조회한다 | `nslookup [옵션] <도메인 또는 IP>` | `-type=A`: 호스트 IP 주소<br>`-type=NS`: 네임서버 정보 | `dnf install bind-utils` |
| `dig` | `nslookup`과 비슷하다. DNS 응답을 상세히 보여 준다 | `dig <도메인 또는 IP>` | `-x <IP>`: IP로 도메인 조회 | `dnf install bind-utils` |
| `host` | 호스트명과 IP를 서로 변환한다 | `host <도메인 또는 IP>` | | `dnf install bind-utils` |
| `hostname` | 시스템 이름을 확인한다 | `hostname` 또는 `cat /etc/hostname` | | 기본 포함 |

## 2. 사용 예

| 목적 | 명령 | 기대 결과 |
|---|---|---|
| 32바이트 패킷으로 5회 연결 확인 (Linux) | `ping -c 5 -s 32 <IP 주소>` | 5회 응답과 손실률, 왕복 시간 요약이 출력된다 |
| 5회 연결 확인 (Windows) | `ping -n 5 <IP 주소>` | 5회 응답과 통계가 출력된다 |
| 목적지까지 경로 확인 (Linux) | `traceroute <IP 주소>` | 구간(hop)별 주소와 응답 시간이 출력된다 |
| 목적지까지 경로 확인 (Windows) | `tracert <IP 주소>` | 구간별 주소와 응답 시간이 출력된다 |
| 도메인의 IP 조회 | `nslookup <도메인>` | 서버 주소와 조회된 IP가 출력된다 |
| 도메인의 네임서버 조회 | `nslookup -type=NS <도메인>` | 네임서버 목록이 출력된다 |
| DNS 응답 상세 확인 | `dig <도메인>` | 질의, 응답, 서버 정보가 출력된다 |
| IP의 도메인 조회 | `host <IP 주소>` | 역방향 조회 결과가 출력된다. 등록이 없으면 `not found`가 나온다 |

{% hint style="info" %}
NOTE: Windows의 `ping`은 옵션 없이 4회만 보내고 끝난다. Linux의 `ping`은 `-c`를 주지 않으면 중단(`Ctrl+C`)할 때까지 계속 보낸다. 원본의 `/ect/hostname`은 `/etc/hostname` 오타여서 정정했다. 원본은 `yum`을 썼으나 RHEL 8 이상은 `dnf`가 기본이다(`yum`은 `dnf` 별칭). 원본 예제의 `8.8.8.8`은 `<IP 주소>`로 일반화했다.
{% endhint %}

## 3. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [network-remote/networkcommands.md](../../Linux/guide/network-remote/networkcommands.md) | LNX-NRM-001-REF | 네트워크 진단 명령어 (Linux 스페이스) |
| [netstat.md](netstat.md) | NET-TOP-002-REF | 네트워크 상태 모니터링 (netstat) |

## 4. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 깨진 표를 정리해 REF 형식으로 재작성. Windows 대응 명령(`-n`, `tracert`) 추가, 오타와 패키지 관리자 정정, 예제 IP 일반화 |
