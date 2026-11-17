# TCP 래퍼 접근 제어

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-SEC-006-MP |
| 목적 | `hosts.allow`, `hosts.deny` 파일로 특정 호스트의 서비스 접근을 허용하거나 거부한다 |
| 적용 대상 | TCP 래퍼(libwrap)를 지원하는 서비스와 배포판. RHEL 8 이상은 TCP 래퍼를 제공하지 않는다 |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 페이지의 설정을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: TCP 래퍼는 RHEL 8부터 제거됐다. RHEL 9에서는 이 절차가 적용되지 않으므로 방화벽(LNX-SEC-001-MP)을 쓴다. 이 문서는 TCP 래퍼를 지원하는 구버전 환경용이다. 미검증이다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [firewalld.md](firewalld.md) | LNX-SEC-001-MP | firewalld 방화벽 관리 |
| [TCP Wrapper 설정 (tistory)](https://dev-jaguar.tistory.com/entry/Linux-TCP-Wrapper-%EC%84%A4%EC%A0%95-hostsallow-hostsdeny) | | 외부 자료 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 대상 서버 | TCP 래퍼 지원 환경, root 권한 | |
| 2 | 콘솔 접근 | 가상 머신 화면 또는 물리 콘솔 | |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `hosts.deny`에 `ALL:ALL`을 쓰면 `hosts.allow`에 허용 규칙이 없는 모든 접속이 거부되어 SSH 접속이 끊긴다. 먼저 `hosts.allow`에 관리자 접속 IP를 허용한 뒤 `hosts.deny`를 수정한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 두 파일을 백업한다: `cp /etc/hosts.allow /etc/hosts.allow.bak` 과 `cp /etc/hosts.deny /etc/hosts.deny.bak` | 백업 파일이 있다 |
| 2 | 콘솔에 로그인할 수 있다 | 로그인 프롬프트가 보인다 |

## 5. 절차

판단 순서는 `hosts.allow`를 먼저 검사해 일치하면 허용하고, 일치하지 않으면 `hosts.deny`를 검사해 일치하면 거부한다. 둘 다 일치하지 않으면 허용한다. 미검증이다.

### A. 허용 규칙 설정

1. (5-A-01) 허용 파일을 연다: `vi /etc/hosts.allow`
2. (5-A-02) 관리자 접속 IP의 SSH를 허용하는 줄을 추가한다: `sshd:<IP 주소>` → 결과: 파일에 해당 줄이 있다.

### B. 거부 규칙 설정

1. (5-B-01) 거부 파일을 연다: `vi /etc/hosts.deny`
2. (5-B-02) 필요한 줄을 추가한다 → 결과: 파일에 해당 줄이 있다.

| 형식 | 뜻 |
|---|---|
| `ALL:ALL` | 모든 클라이언트의 모든 서비스를 거부한다 |
| `sshd:<IP 주소>` | 해당 IP에서 오는 SSH 접속을 거부한다 |
| `httpd:<네트워크 주소>/<서브넷 마스크>` | 해당 네트워크 대역의 HTTP 접속을 거부한다 |

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 거부한 IP의 PC에서 접속 시도 | 접속이 거부된다 | 연결이 끊긴다 |
| 2 | 허용한 IP의 PC에서 `ssh <사용자명>@<IP 주소>` | 접속된다 | 로그인 프롬프트가 나온다 |

## 7. 복구

1. (7-01) 백업을 되돌린다: `cp /etc/hosts.allow.bak /etc/hosts.allow` 과 `cp /etc/hosts.deny.bak /etc/hosts.deny`
2. (7-02) 접속이 끊겼다면 콘솔에서 7-01을 수행한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본을 MP 형식으로 재작성. 파일명 `host.allow`, `host.deny`를 `hosts.allow`, `hosts.deny`로 정정했다. 접속 단절 WARNING, 백업, 복구, 판단 순서 설명은 원본에 없던 내용이다 |
