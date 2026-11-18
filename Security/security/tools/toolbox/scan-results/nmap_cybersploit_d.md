# Nmap 네트워크 스캔 로그

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-SCN-004-REF |
| 유형 | REF (출력 읽는 법) |
| 목적 | 서브넷 전체를 대상으로 한 Nmap 스캔(호스트 발견, 서비스·버전 탐지) 출력을 읽는다 |
| 적용 대상 | 허가받은 격리 실습 환경(자신이 소유·관리하는 VM 또는 의도적 취약 앱) |
| 확인 상태 | 미검증 (원본 출력과 일반 지식을 정리한 것이며 스캔을 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="danger" %}
WARNING: 허가받지 않은 네트워크를 스캔하는 것은 불법이다. 격리된 실습망(VirtualBox 호스트 전용 네트워크)의 소유·관리 대상에서만 수행한다.
{% endhint %}

## 1. 도구 개요

원본에 명령줄은 없다. 출력에서 다음 스캔 단계가 보인다(Nmap 7.94SVN).

| 출력의 단계 | 뜻 | 대응하는 옵션(추정) |
|---|---|---|
| `ARP Ping Scan` (255 hosts) | `/24` 서브넷의 호스트 발견. 같은 L2 망이므로 ARP를 쓴다 | 대상 `192.168.56.0/24` |
| `SYN Stealth Scan` (65535 ports/host) | 모든 TCP 포트에 SYN만 보내 열림 여부를 본다 | `-sS -p-` |
| `Service scan` | 열린 포트에 프로브를 보내 서비스·버전을 알아낸다 | `-sV` |
| `NSE` (46 scripts) | 기본 스크립트를 실행한다 | `-sC` 또는 `-A` |

위 옵션 대응은 출력에서 추정한 것이며 확인하지 않았다.

## 2. 출력 구조

| 줄·열 | 뜻 |
|---|---|
| `Nmap scan report for <호스트>` | 호스트별 결과의 시작 |
| `[host down]` | 응답이 없는 호스트. 이 출력에서 대부분의 줄이 이 형식이어서 요약에서 제외했다 |
| `Not shown: N closed/filtered tcp ports (reset / no-response / admin-prohibited)` | 표에 나오지 않은 포트의 상태와 그 근거 |
| `PORT` `STATE` `SERVICE` `VERSION` | 포트/프로토콜, 상태, 서비스 이름, 탐지한 제품·버전 |
| `SERVICE` 끝의 `?` | 이름이 추정이다 |
| `SF-Port...` 블록 | 서비스를 식별하지 못했을 때 출력되는 지문(fingerprint). 제출용 데이터이며 읽을 정보가 거의 없어 제거했다 |
| `Service Info: OS: ...; CPE: ...` | 서비스에서 추정한 운영체제와 표준 식별자 |
| 마지막 `Nmap done` | 스캔한 주소 수, 응답한 호스트 수, 소요 시간과 패킷량 |

`Not shown`의 근거는 상태를 구분한다. `reset`은 RST 응답을 받은 닫힘이고, `no-response`는 응답이 없어 방화벽이 버렸다는 뜻이며, `admin-prohibited`는 방화벽이 ICMP 관리자 금지 응답을 보냈다는 뜻이다.

## 3. 이 출력에서 읽을 수 있는 정보

전체 요약은 256개 주소 중 5개 호스트가 응답했고 354.45초가 걸렸다는 것이다. 보낸 패킷은 약 39만 개(17.3MB)다.

| 호스트(`<대상 IP>` 구분) | 상태 | 열린 포트와 서비스 | 해석 |
|---|---|---|---|
| 호스트 A (.100) | 65535개 모두 filtered | 없음 | 모든 포트가 필터링되어 서비스를 알 수 없다 |
| 호스트 B (.101) | 닫힌 포트 65,516개 | 135·139·445 (Windows RPC, NetBIOS, SMB), 443 (HTTPS), 902·912 (VMware 인증 데몬), 3306 (MySQL), 33060 (MySQL X), 10050 (zabbix agent 포트로 알려짐, 응답은 tcpwrapped), 5040·7680, 49664~49672 (동적 RPC) | Windows 호스트다. 파일 공유·데이터베이스·원격 관리 포트가 다수 열려 있다 |
| 호스트 C (.103) | filtered 65,532개 | 22 (OpenSSH 8.6), 80·443 (Apache 2.4.51, Fedora, mod_wsgi, Python 3.9) | 방화벽 뒤의 Linux 웹 서버다. 호스트 이름이 `earth.local`로 해석되었다 |
| 호스트 D (.105) | 닫힌 포트 65,533개 | 22 (OpenSSH 5.9p1 Debian 5ubuntu1.10), 80 (Apache 2.2.22 Ubuntu) | Cybersploit 1 대상이다. 오래된 Ubuntu 계열 버전이다 |
| 호스트 E (.102) | 65535개 모두 closed | 없음 | 스캔을 실행한 자기 호스트(지연 0.000003s)로 보인다 |

`VERSION` 열의 제품 문자열이 곧 [SEC-SCN-006-REF](searchsploit_cybersploit_result.md)의 검색어가 된다. 호스트 B의 3306 열(`MySQL (unauthorized)`)은 접속이 거부되었다는 뜻이다.

## 4. 탐지·방어

| 항목 | 내용 |
|---|---|
| 서버 로그의 흔적 | 호스트 발견 단계에서 ARP 요청이 서브넷 전체에 나간다. SYN 스캔은 한 출발지에서 65,535개 포트로 SYN을 보내 방화벽·conntrack에 불완전 연결이 대량으로 남고, 서비스 스캔은 열린 포트에 비정상 요청을 보내 `501`·`400` 같은 오류가 웹 서버 로그에 기록된다(원본 지문 블록의 `501 Not Implemented`, `400 Bad Request`가 그 예다). Windows 호스트는 방화벽 로그에 차단된 연결 시도가 기록된다 |
| 탐지 | 한 출발지가 짧은 시간에 수천 개 이상의 포트에 접속하는 규칙(Snort·Suricata, SIEM 상관 규칙), ARP 스캔 탐지(arpwatch 등)로 탐지한다 |
| 노출 축소 | 호스트 C처럼 방화벽 기본 정책을 DROP으로 두면 `filtered`로 보여 서비스 정보를 줄 수 있다. 사용하지 않는 서비스(139·445·3306·33060 등)는 끄거나 관리망에서만 허용한다. 서비스 배너의 버전 문자열을 줄이고(OpenSSH의 `DebianBanner no`, Apache `ServerTokens Prod`) 지원 종료 버전을 올린다 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [nmap_cybersploit.md](nmap_cybersploit.md) | SEC-SCN-003-REF | Nmap 스캔: Cybersploit 1 |
| [searchsploit_cybersploit_result.md](searchsploit_cybersploit_result.md) | SEC-SCN-006-REF | Searchsploit 검색 로그 |

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | AMM 형식 REF로 재구성. 약 420줄의 원문(host down 목록, 지문 블록)을 요약 표로 대체하고 IP·MAC을 가림 |
