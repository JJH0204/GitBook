# 원격 접속 보안 관리 (sshd)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-NRM-002-MP |
| 목적 | 원격 접속 시 root 계정 로그인을 막고, 평문 원격 접속 서비스(`telnet-server`)를 제거한다 |
| 적용 대상 | RHEL 계열 Linux 8 이상, OpenSSH 서버, root 권한 필요 |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 이 문서로 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [스위치 및 라우터 원격 접속 설정](remoteterminalaccess.md) | LNX-NRM-004-MP | `telnet` 사용 시 보안 경고 |
| [사용자 생성 명령어 (useradd)](../accounts-permissions/usercreationcommands.md) | LNX-ACC-002-MP | 일반 사용자 계정 만들기 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 대상 서버 | RHEL 계열 8 이상, `sshd` 동작 중 | |
| 2 | 콘솔 접근 수단 | 가상 머신 콘솔, 하이퍼바이저 콘솔, 물리 콘솔 중 하나 | SSH 접속 단절 시 복구용 |
| 3 | 일반 사용자 계정 | `sudo` 권한 보유 | root 로그인을 막기 전에 준비한다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `sshd_config` 변경은 원격 접속 단절 위험이 있다. 변경 전에 콘솔 접근을 확보하고, 설정 파일을 백업하고, 현재 SSH 세션을 하나 열어 둔 채 유지한다. 새 세션에서 접속이 확인되기 전에 기존 세션을 닫지 않는다.
{% endhint %}

{% hint style="danger" %}
WARNING: root 로그인을 막기 전에 `sudo` 권한이 있는 일반 사용자로 SSH 접속되는지 확인한다. 그렇지 않으면 원격에서 관리자 작업을 할 수 없다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 설정 파일을 백업한다: `cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak` | `ls /etc/ssh/sshd_config.bak`가 파일을 보여 준다 |
| 2 | 일반 사용자로 SSH 접속이 되는지 확인한다 | 로그인 후 `sudo -l`이 허용 목록을 출력한다 |
| 3 | 콘솔 접근을 확인한다 | 콘솔에서 로그인 프롬프트가 보인다 |

## 5. 절차

### A. root 원격 로그인 차단

1. (5-A-01) 설정 파일을 연다: `vi /etc/ssh/sshd_config`
2. (5-A-02) `PermitRootLogin` 줄을 찾는다: `grep -n PermitRootLogin /etc/ssh/sshd_config` → 결과: 줄 번호와 현재 값이 출력된다. 원본에서는 40번째 줄이었다.
3. (5-A-03) 값을 `no`로 바꾼다. 주석(`#`)이면 `#`을 지운다 → 결과: 해당 줄이 `PermitRootLogin no`가 된다.
4. (5-A-04) 문법을 검사한다: `sshd -t` → 결과: 출력 없이 끝난다. 오류가 나오면 5-A-03을 다시 확인한다.
5. (5-A-05) 설정을 적용한다: `systemctl reload sshd` → 결과: 오류 없이 끝난다.

{% hint style="info" %}
NOTE: RHEL 9 계열은 `/etc/ssh/sshd_config.d/` 아래 파일(예: `50-redhat.conf`)이 주 설정 파일을 덮어쓸 수 있다. 값이 적용되지 않으면 `sshd -T | grep -i permitrootlogin`으로 실제 적용값을 확인한다. 미검증이다.
{% endhint %}

### B. telnet 서비스 제거

`telnet`은 계정과 비밀번호를 평문으로 전송하는 프로토콜이다. 서버에서 쓰지 않는다.

1. (5-B-01) 설치 여부를 확인한다: `rpm -q telnet-server` → 결과: 설치돼 있으면 패키지명이, 없으면 `package telnet-server is not installed`가 나온다.
2. (5-B-02) 설치돼 있으면 제거한다: `dnf remove -y telnet-server` → 결과: `Complete!`가 출력된다.

{% hint style="info" %}
NOTE: 원본 제목은 "telnet, rsh 시스템 삭제"였으나 명령은 `telnet-server`만 제거한다. RHEL 8 이상은 `rsh-server`를 제공하지 않는다. 구버전에서 `rsh-server`가 설치돼 있다면 같은 방식으로 제거한다. 미검증이다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 다른 PC에서 `ssh root@<IP 주소>` | 접속이 거부된다 | `Permission denied`가 나온다 |
| 2 | 다른 PC에서 `ssh <사용자명>@<IP 주소>` | 접속된다 | 로그인 프롬프트가 나온다 |
| 3 | `sshd -T \| grep -i permitrootlogin` | `permitrootlogin no` | 값이 `no`다 |
| 4 | `rpm -q telnet-server` | 설치되지 않음 | `is not installed`가 나온다 |

## 7. 복구

1. (7-01) 백업을 되돌린다: `cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config`
2. (7-02) 설정을 적용한다: `systemctl reload sshd`
3. (7-03) SSH 접속이 끊겼다면 콘솔에서 위 두 단계를 수행한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 설정 한 줄과 명령 한 줄뿐이던 원본을 MP 형식으로 재작성. 접속 단절 WARNING, 문법 검사(`sshd -t`), 적용, 복구 절차를 추가했다 |
