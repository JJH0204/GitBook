# 시스템 보안 과제 (Linux 보안)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-LAB-008-MP |
| 유형 | MP (Linux 보안 설정) |
| 목적 | Linux 서버의 원격 접속, 계정, 권한, 방화벽 설정을 점검·강화하고 Snort로 의심 패킷을 탐지한다 |
| 적용 대상 | 허가받은 격리 실습 환경(자신이 소유·관리하는 VM), firewalld와 systemd를 쓰는 RHEL 계열 Linux, root 권한 |
| 소요 시간 | 약 90분 (추정) |
| 확인 상태 | 미검증 (원본 메모를 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본이 학교 과제의 답안으로 보인다. 문제문과 채점 항목은 옮기지 않고 설정 절차로 재구성했다. 사용자 판단이 필요하다. 원본의 일부 문장은 "~했다" 형태의 풀이 기록이어서 절차로 바꿨다.
{% endhint %}

## 1. 참조

| 참조 문서 | 제목 |
|---|---|
| [Remote Access Management](https://krjaeh0.gitbook.io/j-log/linux/guide/network-remote/remote-access-management) | 원격 접속 관리 |
| [Account Management](https://krjaeh0.gitbook.io/j-log/linux/guide/accounts-permissions/account-management) | 계정 관리 |
| [firewalld](https://krjaeh0.gitbook.io/j-log/linux/guide/security/firewalld) | 방화벽 |
| [snort](../security/defensive-security/defense/snort.md) | Snort 설치 |
| [CTF_TechSupport](../ctf-and-wargame/ctf-writeups/ctf_techsupport.md) | 원본이 연결한 CTF 풀이 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 대상 Linux VM | firewalld, cron 사용 | root 권한 |
| 2 | 공격 측 VM | 같은 호스트 전용 네트워크 | 시험 접속용 |
| 3 | 네트워크 인터페이스 | 원본 기준 `enp0s8`, 대역 `192.168.56.0/24` | 환경에 맞게 바꾼다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: SSH 설정과 방화벽 규칙을 잘못 바꾸면 원격 접속이 끊긴다. 콘솔 접근이 가능한 상태에서 작업하고, 설정을 바꾸기 전에 파일을 백업한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 콘솔 접근 가능 | VM 콘솔 로그인 |
| 2 | 설정 파일 백업 | `cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak` |

## 5. 절차

**A. root 원격 접속 제한**

1. (SUBTASK 5-A-01) `/etc/ssh/sshd_config`의 `PermitRootLogin` 값이 `no`인지 확인한다. → 결과: 값이 출력된다.
2. (SUBTASK 5-A-02) `/etc/ssh/sshd_config.d/` 아래 설정 파일에 `PermitRootLogin` 값이 있는지 확인한다. → 결과: 값이 있으면 `no`로 바꾸거나 그 파일을 삭제한다. 원본에서는 이 디렉터리의 파일이 root 로그인을 허용해 제한이 적용되지 않았다.
3. (SUBTASK 5-A-03) sshd를 재시작한다. → 결과: 오류 없이 재시작된다.
4. (SUBTASK 5-A-04) 다른 VM에서 root로 SSH 접속을 시도한다. → 결과: 접속이 거부된다.
5. (SUBTASK 5-A-05) 사용하지 않는 telnet, rsh 서비스를 삭제한다. → 결과: 해당 패키지가 목록에 없다.

**B. 비밀번호 생성 규칙**

1. (SUBTASK 5-B-01) `libpwquality` 설치 여부를 확인한다. → 결과: 패키지 정보가 출력된다.
2. (SUBTASK 5-B-02) `/etc/security/pwquality.conf`에 규칙을 설정한다. 원본의 요구는 대문자·소문자·숫자·특수문자 각 1개 이상, 8자 이상이다. → 결과: 설정이 저장된다.
3. (SUBTASK 5-B-03) 일반 사용자로 규칙에 어긋나는 비밀번호를 설정해 본다. → 결과: 거부된다.

{% hint style="info" %}
NOTE: 원본에서 root가 신규 계정을 만들 때는 규칙 검사가 적용되지 않는 것으로 관찰되었다. 규칙은 사용자가 자기 비밀번호를 바꿀 때 적용된다.
{% endhint %}

**C. 비밀번호 만료일**

1. (SUBTASK 5-C-01) 서버의 사용자 목록을 확인한다. → 결과: 계정 이름이 출력된다.
2. (SUBTASK 5-C-02) 각 계정의 만료 정보를 `chage -l <계정>`으로 확인한다. → 결과: 만료일 설정 여부가 보인다.
3. (SUBTASK 5-C-03) 만료일이 없는 계정에 `chage -M <일수> <계정>`을 실행한다. → 결과: 다시 확인하면 최대 사용 일수가 반영된다.

**D. 디스크 용량 점검 자동화**

1. (SUBTASK 5-D-01) 아래 스크립트를 `/root/disk_check.sh`로 저장한다. → 결과: 파일이 생긴다.

```bash
#!/bin/bash
# 사용법: disk_check.sh <기준 퍼센트>
LOG_DIR="/root/log"
mkdir -p "$LOG_DIR"
exec > "$LOG_DIR/diskcheck_$(date +%Y%m%d_%H%M%S).log" 2>&1

DVAL=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
df
printf "Disk usage: %s%%\n" "$DVAL"
if [ "$DVAL" -gt "$1" ]; then
    echo "[Warning]"
fi
```

2. (SUBTASK 5-D-02) 실행 권한을 준다. `chmod +x /root/disk_check.sh` → 결과: 오류가 없다.
3. (SUBTASK 5-D-03) `systemctl status crond`로 cron 서비스가 active인지 확인한다. → 결과: active (running).
4. (SUBTASK 5-D-04) `crontab -e`에 매주 금요일 5시 실행 줄을 추가한다. → 결과: 저장된다.

```
0 5 * * 5 /root/disk_check.sh 80
```

{% hint style="info" %}
NOTE: 원본의 `* 5 * * 5`는 분 필드가 `*`이어서 금요일 5시 동안 매분 실행된다. 분 필드를 `0`으로 정정했다.
{% endhint %}

**E. 방화벽으로 접속 차단**

1. (SUBTASK 5-E-01) `firewall-cmd --list-all-zones`로 현재 영역(zone) 설정을 확인한다. → 결과: 인터페이스별 영역이 보인다.
2. (SUBTASK 5-E-02) 공격 측 대역(`192.168.56.0/24`)이 연결된 인터페이스에 별도 영역을 지정한다. → 결과: 해당 인터페이스가 새 영역에 속한다.
3. (SUBTASK 5-E-03) 그 영역에서 HTTP, SSH 접속을 차단하는 규칙을 적용한다. 차단 방식은 공격자 IP 하나 또는 대역 전체 중 선택한다. → 결과: 규칙이 목록에 보인다.
4. (SUBTASK 5-E-04) 공격 측 VM에서 HTTP, SSH 접속을 시도한다. → 결과: 접속이 차단된다.

**F. SetUID와 Sticky Bit 점검**

1. (SUBTASK 5-F-01) SetUID가 설정된 파일을 찾는다. `find / -perm -4000 -type f 2>/dev/null` → 결과: 목록이 출력된다.
2. (SUBTASK 5-F-02) 목록에서 기본 시스템 파일이 아닌 항목이 있는지 검토한다. → 결과: 의심 항목이 있으면 SetUID를 제거한다 (`chmod u-s <파일>`).
3. (SUBTASK 5-F-03) 공유 디렉터리에 Sticky Bit를 설정한다. `chmod +t <디렉터리>` → 결과: `ls -ld`에서 권한 끝이 `t`이다.
4. (SUBTASK 5-F-04) 다른 일반 사용자로 그 디렉터리의 남의 파일 삭제를 시도한다. → 결과: 거부된다. 소유자와 root는 삭제할 수 있다.

{% hint style="info" %}
NOTE: 원본에는 root 권한 셸을 여는 SetUID 프로그램을 직접 만들어 권한 상승을 시연한 절차가 있었다. 이 문서에는 옮기지 않았다. 내부자가 이런 파일을 심을 수 있으므로 5-F-01 점검을 정기적으로 수행한다.
{% endhint %}

**G. Snort 탐지 설정**

{% hint style="danger" %}
WARNING: 패킷 탐지는 허가받은 자신의 네트워크에서만 수행한다.
{% endhint %}

1. (SUBTASK 5-G-01) [snort](../security/defensive-security/defense/snort.md) 문서에 따라 Snort를 설치한다. → 결과: `snort -V`가 버전을 출력한다.
2. (SUBTASK 5-G-02) 탐지 인터페이스를 promiscuous 모드로 한다. `ip link set dev <인터페이스> promisc on` → 결과: 링크 정보에 PROMISC가 보인다.
3. (SUBTASK 5-G-03) 커뮤니티 룰을 설치한다. → 결과: 룰 파일이 생긴다.
4. (SUBTASK 5-G-04) `snort.lua`의 `HOME_NET`을 `192.168.56.0/24`로, `EXTERNAL_NET`을 `!$HOME_NET`으로 설정한다. → 결과: 저장된다.
5. (SUBTASK 5-G-05) `local.rules`에 아래 규칙을 추가한다. 원본의 설명은 "공격 대역이 IP를 위조할 수 있어 대역으로 지정했다"이다. → 결과: 규칙이 저장된다.

```
alert icmp 192.168.56.0/24 any -> $HOME_NET any (msg:"icmp packet"; sid:1000001; rev:1;)
alert tcp 192.168.56.0/24 any -> $HOME_NET 80 (msg:"Suspicious access to /etc/passwd"; content:"/etc/passwd"; sid:1000002; rev:1;)
alert tcp $HOME_NET any -> <공격 측 IP> 22 (msg:"Outgoing SSH connection to attacker"; sid:1000003; rev:1;)
```

6. (SUBTASK 5-G-06) Snort를 실행한다. → 결과: 경고 모드로 동작한다.

```
snort -c /usr/local/etc/snort/snort.lua -R /usr/local/etc/snort/rules/local.rules -i <인터페이스> -A alert_fast -s 65535 -k none
```

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | root로 SSH 접속 | 거부 | 거부된다 |
| 2 | 약한 비밀번호 설정 | 거부 | 거부된다 |
| 3 | 공격 측에서 HTTP, SSH 접속 | 차단 | 연결되지 않는다 |
| 4 | 공격 측에서 ping | Snort 경고 | 경고가 1건 이상 출력된다 |

## 탐지·방어

| 항목 | 내용 |
|---|---|
| 로그 | SSH 인증 로그, firewalld 차단 로그, Snort 경고, 디스크 점검 로그 |
| 완화 | 설정 파일은 하위 디렉터리(`.d`)까지 확인한다. SetUID 파일 목록을 기준선과 비교한다 |

## 7. 복구

1. (SUBTASK 7-01) 백업한 `sshd_config`를 복원하고 sshd를 재시작한다. → 결과: 변경 전 설정으로 동작한다.
2. (SUBTASK 7-02) 추가한 방화벽 영역과 규칙을 제거한다. → 결과: 목록에 없다.
3. (SUBTASK 7-03) cron 항목을 삭제한다. → 결과: `crontab -l`에 없다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | AMM 방식으로 재작성. 권한 상승 시연 코드 삭제, cron 분 필드 정정, 사용자 계정 이름 삭제 |
