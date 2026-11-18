# 네트워크 상태 모니터링 (netstat)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-TOP-002-REF |
| 유형 | REF (옵션 표, 상태 값 표) |
| 목적 | 소켓 연결, 열린 포트, 라우팅 테이블, 인터페이스 통계를 확인하는 `netstat`과 대체 명령 `ss`를 참조한다 |
| 적용 대상 | RHEL 계열 Linux 9 (`netstat`은 net-tools 패키지) |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: `netstat`은 net-tools 패키지의 구식 도구이며 현재 배포판은 `ss`(iproute2)를 권장한다. 새 환경에서는 `ss`를 먼저 쓴다. net-tools는 `dnf install -y net-tools`로 설치한다.
{% endhint %}

## 1. netstat 옵션

| 옵션 | 설명 |
|---|---|
| `-a` | 모든 연결과 청취(LISTEN) 소켓을 보여 준다 |
| `-t` | TCP만 대상으로 한다 |
| `-u` | UDP만 대상으로 한다 |
| `-l` | 청취 상태인 소켓만 보여 준다 |
| `-n` | 주소와 포트를 이름으로 바꾸지 않고 숫자로 보여 준다 |
| `-p` | 소켓을 쓰는 프로세스 ID(PID)와 프로그램 이름을 보여 준다 (다른 사용자의 프로세스는 root 권한이 필요하다) |
| `-s` | 프로토콜별 통계를 보여 준다 |
| `-i` | 네트워크 인터페이스 통계를 보여 준다 |
| `-e` | 확장 정보를 보여 준다 (`-i`와 같이 쓰면 인터페이스 상세 정보) |
| `-r` | 커널 IP 라우팅 테이블을 보여 준다 |

옵션은 묶어 쓴다. 원본 표의 조합은 아래와 같다.

| 조합 | 의미 |
|---|---|
| `-at` / `-au` | TCP 또는 UDP의 모든 소켓 |
| `-lt` / `-lu` | TCP 또는 UDP 청취 소켓 |
| `-st` / `-su` | TCP 또는 UDP 통계 |
| `-ie` | 인터페이스 통계의 상세 정보 |
| `-tulnp` | TCP·UDP 청취 소켓을 숫자 주소와 프로세스 이름으로 표시 (가장 자주 쓰는 조합) |

## 2. netstat과 ss 대응

| 목적 | netstat | ss |
|---|---|---|
| 청취 중인 TCP·UDP 포트와 프로세스 | `netstat -tulnp` | `ss -tulnp` |
| TCP 연결 전체 | `netstat -at` | `ss -t -a` |
| 프로토콜별 통계 | `netstat -s` | `ss -s` (소켓 요약) |
| 라우팅 테이블 | `netstat -r` | `ip route` |
| 인터페이스 통계 | `netstat -i` | `ip -s link` |

{% hint style="info" %}
NOTE: `ss -r`은 라우팅 테이블이 아니라 주소를 이름으로 해석하는 옵션이다. `ss -i`도 인터페이스 통계가 아니라 TCP 내부 정보를 보여 준다. 원본은 `ss -t`를 "모든 TCP 연결"이라 했으나 `ss -t`는 연결된(established) 소켓만 보여 주며, 청취 소켓까지 보려면 `-a`를 붙인다. 정정했다.
{% endhint %}

## 3. 출력 열

| 열 | 뜻 |
|---|---|
| `Proto` | 프로토콜 (`tcp`, `udp`) |
| `Recv-Q` / `Send-Q` | 수신 또는 송신 대기 바이트 수 |
| `Local Address` | 이 시스템의 주소:포트 |
| `Foreign Address` | 상대 주소:포트 |
| `State` | 연결 상태 (4절) |
| `PID/Program name` | `-p`를 줬을 때 소켓을 연 프로세스 |

## 4. TCP 연결 상태 값

| 상태 | 뜻 |
|---|---|
| `LISTEN` | 연결 요청을 기다리는 중이다 |
| `SYN_SENT` | 연결 요청(SYN)을 보내고 응답을 기다린다 |
| `SYN_RECV` | 요청을 받고 응답(SYN+ACK)을 보낸 뒤 확인을 기다린다 |
| `ESTABLISHED` | 연결이 맺어져 데이터를 주고받는다 |
| `FIN_WAIT1` / `FIN_WAIT2` | 이쪽이 먼저 종료를 요청하고 상대의 응답을 기다린다 |
| `CLOSE_WAIT` | 상대가 종료를 요청했으나 이쪽 프로그램이 아직 닫지 않았다. 오래 쌓이면 프로그램이 소켓을 닫지 않는 것을 의심한다 |
| `LAST_ACK` | 이쪽도 종료를 보내고 마지막 확인을 기다린다 |
| `TIME_WAIT` | 연결 종료 후 지연된 패킷을 위해 잠시(보통 60초) 소켓을 유지한다. 정상 상태다 |
| `CLOSING` | 양쪽이 동시에 종료를 보낸 드문 상태다 |
| `CLOSED` | 닫혔다 |

`ss`에서는 `SYN_RECV`가 `SYN-RECV`, `FIN_WAIT1`이 `FIN-WAIT-1`처럼 하이픈으로 표시된다.

## 5. 그 밖의 도구

| 도구 | 용도 | 예 |
|---|---|---|
| `ip` | 주소, 라우팅, 장치 관리 | `ip route` |
| `nmap` | 포트 스캔, 보안 점검 | `nmap localhost` |

{% hint style="danger" %}
WARNING: `nmap`을 소유하거나 허가받지 않은 시스템에 쓰지 않는다. 대상은 이 시스템(`localhost`)이나 허가받은 시스템으로 한정한다.
{% endhint %}

## 6. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [networkcommands.md](networkcommands.md) | NET-TOP-001-REF | 네트워크 진단 명령어 |
| [servercheckscript.md](servercheckscript.md) | NET-TOP-004-MP | 서버 상태 점검 스크립트 |

## 7. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | REF 형식으로 재작성. `-n`, `-tulnp` 설명과 `ss` 대응표, TCP 상태 값 표 추가. `ss -t`의 범위 설명 정정, 대화체 제거, `nmap` 사용 경고 추가 |
