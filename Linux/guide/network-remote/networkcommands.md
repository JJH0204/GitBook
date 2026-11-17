# 네트워크 진단 명령어

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-NRM-001-REF |
| 유형 | REF (명령 표) |
| 목적 | 네트워크 연결, 경로, 이름 해석, 호스트명을 확인하는 진단 명령을 참조한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 명령 표

| 명령어 | 설명 | 형식 | 주요 옵션 | 설치 (RHEL 계열) |
|---|---|---|---|---|
| `ping` | 대상과의 네트워크 연결을 확인한다 | `ping [옵션] <대상>` | `-c`: 요청 횟수<br>`-i`: 요청 간격(초)<br>`-s`: 패킷 데이터 크기(바이트) | 기본 포함 |
| `traceroute` | 목적지까지 거치는 경로와 구간별 응답 시간을 표시한다. 경로상 장애 위치를 찾을 때 쓴다 | `traceroute <주소 또는 IP>` | | `dnf install -y traceroute` |
| `nslookup` | 도메인으로 IP를, IP로 도메인을 조회한다 | `nslookup [옵션] <도메인 또는 IP>` | `-type=A`: 호스트 IP 주소<br>`-type=NS`: 도메인 네임서버 정보 | `dnf install bind-utils` |
| `dig` | `nslookup`과 비슷하다. DNS 응답을 상세히 보여 준다 | `dig <도메인>` | | `dnf install bind-utils` |
| `host` | 호스트명과 IP를 서로 변환한다 | `host <도메인 또는 IP>` | | `dnf install bind-utils` |
| `hostname` | 시스템 이름을 확인한다 | `hostname` 또는 `cat /etc/hostname` | | 기본 포함 |

{% hint style="info" %}
NOTE: 원본은 `yum`을 썼다. RHEL 8 이상에서 `dnf`가 기본이며 `yum`은 `dnf`의 별칭이다. 원본의 `cat /ect/hostname`은 `/etc/hostname` 오타여서 정정했다. `-y`는 설치 확인 질문에 모두 yes로 답하는 옵션이다. 미검증이다.
{% endhint %}

## 2. 사용 예

| 목적 | 명령 | 기대 결과 |
|---|---|---|
| 32바이트 패킷으로 5회 연결 확인 | `ping -c 5 -s 32 <IP 주소>` | 5회 응답과 손실률, 왕복 시간 요약이 출력된다 |
| 목적지까지 경로 확인 | `traceroute <IP 주소>` | 구간(hop)별 주소와 응답 시간이 출력된다 |
| 도메인의 IP 조회 | `nslookup <도메인>` | 서버 주소와 조회된 IP가 출력된다 |
| 도메인의 네임서버 조회 | `nslookup -type=NS <도메인>` | 네임서버 목록이 출력된다 |
| DNS 응답 상세 확인 | `dig <도메인>` | 질의, 응답, 서버 정보가 출력된다 |
| IP의 도메인 조회 | `host <IP 주소>` | 역방향 조회 결과가 출력된다. 등록돼 있지 않으면 `not found`가 나온다 |
| 시스템 이름 확인 | `hostname` | 호스트명이 한 줄 출력된다 |

원본의 예제는 공개 DNS 주소 `8.8.8.8`을 썼다. 이 문서는 `<IP 주소>`로 일반화했다.

## 3. 현행 명령 참고

네트워크 설정 확인에는 `ifconfig`(net-tools, 구식) 대신 `ip` 명령을 쓴다.

| 구식 | 현행 | 용도 |
|---|---|---|
| `ifconfig` | `ip addr` | 인터페이스 주소 확인 |
| `route -n` | `ip route` | 라우팅 테이블 확인 |
| `netstat -tln` | `ss -tln` | 열린 TCP 포트 확인 |

## 4. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [네트워크 진단 명령어 (Network 스페이스)](../../../Network/tools-and-operations/networkcommands.md) | | 같은 주제의 네트워크 스페이스 문서 |
| [리눅스 명령어 마인드맵](../commands/linux_command.md) | LNX-CMD-003-REF | 명령어 모음 |

## 5. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 깨진 표를 정리해 REF 형식으로 재작성. `/ect/hostname` 오타 정정, `yum`을 `dnf`로 갱신, 예제 IP를 일반화, 현행 명령 표를 추가했다 |
