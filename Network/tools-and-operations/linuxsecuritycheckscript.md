# 리눅스 보안 점검 스크립트 오류 정정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-TOP-005-MP |
| 목적 | 팀 과제로 받은 보안 점검 스크립트 조각의 문법·논리 오류를 정정해 동작하는 한 파일로 만든다 |
| 적용 대상 | RHEL 계열 Linux 9, bash, OpenSSH 서버, root 권한 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 조각을 읽고 정정한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본 요구사항은 "현재 버전에 맞게 수정, 포맷 통일, 금요일까지"였다. 이 문서는 점검 항목 두 개(telnet, root 원격 로그인)만 다룬다. 항목은 같은 형식으로 늘린다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [servercheckscript.md](servercheckscript.md) | NET-TOP-004-MP | 서버 상태 점검 스크립트 |
| [shell-script-syntax.md](../../Linux/guide/scripting/shell-script-syntax.md) | LNX-SCR-002-REF | 쉘 스크립트 문법 참조 |
| [ssh.md](../security/ssh.md) | | SSH |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Linux 서버 | RHEL 계열 9, `sshd` 실행 중 | |
| 2 | root 권한 | | `sshd -T`에 필요하다 |

## 3. 안전 사항

{% hint style="info" %}
NOTE: 이 스크립트는 점검만 하며 설정을 바꾸지 않는다. 점검 결과가 "취약"이어도 서비스를 끄거나 설정을 고치는 것은 별도 작업이다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | root 권한을 확인한다: `id -u` | 출력이 `0`이다 |
| 2 | `sshd`의 실제 설정값을 확인한다: `sshd -T \| grep -i permitrootlogin` | `permitrootlogin no` 같은 한 줄이 출력된다 |

## 5. 절차

### A. 원본 오류 파악

| 번호 | 원본 | 오류 | 정정 |
|---|---|---|---|
| 1 | `telnetstat=telnet.socket` | 서비스 상태가 아니라 문자열 `telnet.socket`을 저장한다. 비교가 항상 거짓이다 | `telnetstat=$(systemctl is-active telnet.socket)` |
| 2 | `else`로 끝나고 `fi`가 없다 | if 문이 닫히지 않아 문법 오류가 난다 | 각 `if`를 `fi`로 닫는다 |
| 3 | `sshstat=cat /etc/ssh/sshd_config \| grep PermitRootLogin` | 명령 치환(`$(...)`)이 없어 `cat` 명령이 환경변수로 실행된다 | `$(...)`로 감싼다 |
| 4 | `[ $sshstat = 'no']` | `'no'`와 `]` 사이에 공백이 없다 | `[ "$sshstat" = "no" ]` |
| 5 | `grep PermitRootLogin` 결과와 `no` 비교 | 결과가 `PermitRootLogin no` 전체 줄이라 `no`와 같지 않다. 주석(`#`) 줄도 걸린다 | `sshd -T`의 실제 적용값에서 두 번째 열만 읽는다 |
| 6 | `echo "취약 = root ..."` | `-`가 `=`로 오타. 양호 분기가 없다 | `양호` 분기를 추가한다 |
| 7 | 변수를 따옴표 없이 비교 | 값이 비면 `[ = 'no' ]`로 문법 오류가 난다 | `"$변수"`로 감싼다 |

### B. 정정한 스크립트 작성

1. (5-B-01) 파일을 연다: `vi /usr/local/sbin/security-check.sh`
2. (5-B-02) 아래 내용을 입력하고 저장한다.

{% code title="/usr/local/sbin/security-check.sh" %}
```bash
#!/usr/bin/bash

# 1. telnet 서비스
telnetstat=$(systemctl is-active telnet.socket 2>/dev/null)
if [ "$telnetstat" = "active" ]; then
        echo "취약 - telnet 서비스 동작 중 -> 서비스 제거 여부 점검"
else
        echo "양호 - telnet 서비스 비활성"
fi

# 2. root 원격 로그인
sshstat=$(sshd -T 2>/dev/null | awk '$1=="permitrootlogin" {print $2}')
if [ "$sshstat" = "no" ]; then
        echo "양호 - root 원격 접속 불가"
else
        echo "취약 - root 원격 접속 가능 (PermitRootLogin=$sshstat)"
fi
```
{% endcode %}

3. (5-B-03) 실행 권한을 준다: `chmod 700 /usr/local/sbin/security-check.sh`
4. (5-B-04) 실행한다: `/usr/local/sbin/security-check.sh` → 결과: 항목마다 `양호` 또는 `취약` 한 줄이 출력된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `bash -n /usr/local/sbin/security-check.sh` | 문법 오류가 없다 | 출력이 없다 |
| 2 | `/etc/ssh/sshd_config`가 `PermitRootLogin no`인 상태에서 실행 | root 항목이 양호다 | `양호 - root 원격 접속 불가` 출력 |
| 3 | `PermitRootLogin yes`로 바꾸고 `systemctl reload sshd` 후 실행 | root 항목이 취약이다 | `취약 - root 원격 접속 가능` 출력 |

{% hint style="info" %}
NOTE: `sshd_config`에 `PermitRootLogin`이 없으면 OpenSSH 기본값은 `prohibit-password`(비밀번호 로그인 금지, 키 로그인 허용)다. 이 스크립트는 `no`가 아니면 모두 취약으로 표시한다. 기본값을 허용 기준으로 삼을지는 점검 정책에 따라 정한다.
{% endhint %}

## 7. 복구

1. (7-01) 6절 3번에서 설정을 바꿨다면 `PermitRootLogin no`로 되돌리고 `systemctl reload sshd`를 실행한다. → 결과: 6절 2번 확인이 다시 양호를 출력한다.
2. (7-02) 스크립트를 지우려면 `rm /usr/local/sbin/security-check.sh`를 실행한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | `servercheckscript.md`의 "팀 과제" 절을 분리해 신규 작성. 원본 스크립트 조각의 오류를 표로 정리하고 정정본을 추가 |
