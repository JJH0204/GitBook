# 서버 상태 점검 스크립트

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-TOP-004-MP |
| 목적 | 서버의 OS, 자원, 디스크, 부팅, 로그인 사용자, 소켓 상태를 한 번에 출력하는 점검 스크립트를 작성하고 cron으로 정기 실행한다 |
| 적용 대상 | RHEL 계열 Linux 9 (Rocky Linux 9), bash, root 권한 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 스크립트를 정리해 오류를 정정한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [sysstat.md](../../Linux/guide/logging-monitoring/sysstat.md) | LNX-LOG-004-MP | 시스템 성능 모니터링 (`sar` 설치) |
| [smarttool.md](../../Linux/guide/storage-boot/smarttool.md) | LNX-STB-002-REF | 디스크 상태 점검 도구 (`smartctl`) |
| [shell-script.md](../../Linux/guide/scripting/shell-script.md) | LNX-SCR-001-DO | 쉘 스크립트 프로그래밍 기초 |
| [cron-register.md](../../Linux/guide/scripting/cron-register.md) | LNX-SCR-007-MP | cron 작업 등록과 확인 |
| [netstat.md](netstat.md) | NET-TOP-002-REF | 네트워크 상태 모니터링 (`ss`, `netstat`) |
| [linuxsecuritycheckscript.md](linuxsecuritycheckscript.md) | NET-TOP-005-MP | 리눅스 보안 점검 스크립트 오류 정정 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Linux 서버 | RHEL 계열 9 | |
| 2 | root 권한 | root 로그인 또는 `sudo` | `smartctl`, `ss -p`에 필요하다 |
| 3 | sysstat | `sar` 제공 | `dnf install -y sysstat` |
| 4 | smartmontools | `smartctl` 제공 | `dnf install -y smartmontools` |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 점검 결과(로그인 사용자의 접속 IP, 프로세스, 열린 포트)는 보안 정보다. 결과 파일 `/var/log/server-check.log`는 root만 읽게 둔다(5-C-03).
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | root 권한을 확인한다: `id -u` | 출력이 `0`이다 |
| 2 | 필요한 패키지를 확인한다: `command -v sar smartctl ss` | 세 명령의 경로가 모두 출력된다 |
| 3 | 점검할 디스크 장치 이름을 확인한다: `lsblk -d -o NAME,TYPE` | `TYPE`이 `disk`인 행의 `NAME`을 기록한다 (예: `sda`) |

## 5. 절차

### A. 스크립트 작성

점검 항목과 사용 명령은 아래와 같다.

| 항목 | 명령 |
|---|---|
| 운영체제 | `grep PRETTY_NAME /etc/os-release` |
| DB 버전 | `mariadb --version` |
| 현재 시간 | `date` |
| CPU 사용률 | `sar 1 3` (3회 평균) |
| 메모리, 스왑 | `free -h` |
| 파일 시스템 | `df -h` |
| 디스크 상태 | `smartctl -H /dev/<디스크 장치>` |
| 부팅 시간 | `who -b` |
| 로그인 사용자 | `who -u` |
| 서비스 실행 여부 | `systemctl is-active <서비스명>` |
| 열린 포트와 프로세스 | `ss -tulnp` |

1. (5-A-01) 파일을 연다: `vi /usr/local/sbin/server-check.sh`
2. (5-A-02) 아래 내용을 입력하고 저장한다. `<디스크 장치>`는 4절에서 기록한 값(예: `sda`)으로 바꾼다.

{% code title="/usr/local/sbin/server-check.sh" %}
```bash
#!/usr/bin/bash

get_cpu_stat() {
        sar 1 3 | grep Average | awk '{for(i=3;i<=NF;i++) printf $i" "}'
}

get_ram_stat() {
        free -h | grep Mem | awk '{for(i=2;i<=NF;i++) printf $i" "}'
}

get_swap_stat() {
        free -h | grep Swap | awk '{for(i=2;i<=NF;i++) printf $i" "}'
}

os_ver=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
db_ver=$(mariadb --version 2>/dev/null || echo "not installed")
cur_time=$(date)
cpu_stat=$(get_cpu_stat)
ram_stat=$(get_ram_stat)
swap_stat=$(get_swap_stat)

echo
echo "[Server Monitor]"
echo "--------------------------------------------------------"
echo "OS Version: $os_ver"
echo "DB Version: $db_ver"
echo "Current Time: $cur_time"
echo

echo "[Resource]"
echo "--------------------------------------------------------"
echo "CPU: $cpu_stat"
echo "RAM: $ram_stat"
echo "SWAP: $swap_stat"
echo

echo "[File]"
echo "--------------------------------------------------------"
df -h
echo

echo "[Disk]"
echo "--------------------------------------------------------"
smartctl -H /dev/<디스크 장치>
echo

echo "[Boot]"
echo "--------------------------------------------------------"
who -b
echo

echo "[Users]"
echo "--------------------------------------------------------"
who -u
echo

echo "[Service]"
echo "--------------------------------------------------------"
for svc in sshd httpd mariadb; do
        echo "$svc: $(systemctl is-active $svc)"
done
echo

echo "[Socket]"
echo "--------------------------------------------------------"
ss -tulnp
echo
```
{% endcode %}

→ 결과: 파일이 저장된다. `sar`의 `Average` 행은 `-` 열이 `all`이고 이어서 `%user`, `%nice`, `%system`, `%iowait`, `%steal`, `%idle` 값이 나온다.

{% hint style="info" %}
NOTE: 원본은 OS 확인에 `grep . /etc/*rocky-release | perl -ane print`를 썼다. 배포판에 종속되고 `perl`이 필요해서 `/etc/os-release`를 읽도록 정정했다. 원본은 프로세스 확인에 `netstat -p`(구식 net-tools, 모든 소켓 출력)를 썼으나 `ss -tulnp`로 바꿨다. DB 버전은 원본에 `MariaDB ~~` 자리표시만 있었다. 서비스 이름 `sshd httpd mariadb`는 예시이므로 실제 서버에 맞게 고친다.
{% endhint %}

### B. 실행 권한 부여와 첫 실행

1. (5-B-01) 소유자만 실행하게 한다: `chmod 700 /usr/local/sbin/server-check.sh` → 결과: `ls -l /usr/local/sbin/server-check.sh`가 `-rwx------`를 보여 준다.
2. (5-B-02) 실행한다: `/usr/local/sbin/server-check.sh` → 결과: `[Server Monitor]`부터 `[Socket]`까지 구역이 순서대로 출력된다.
3. (5-B-03) 오류가 출력되면 6절 오류 표에서 원인을 찾는다.

### C. cron 등록

cron 문법과 등록 방법의 상세는 LNX-SCR-007-MP를 따른다.

1. (5-C-01) root의 crontab을 연다: `crontab -e`
2. (5-C-02) 아래 한 줄을 추가하고 저장한다. 매일 06시 정각에 실행해 결과를 파일에 덧붙인다.

```
0 6 * * * /usr/local/sbin/server-check.sh >> /var/log/server-check.log 2>&1
```

3. (5-C-03) 결과 파일 권한을 제한한다: `touch /var/log/server-check.log && chmod 600 /var/log/server-check.log` → 결과: 파일이 `-rw-------`이다.
4. (5-C-04) 등록을 확인한다: `crontab -l` → 결과: 5-C-02의 줄이 출력된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `/usr/local/sbin/server-check.sh` 실행 | 8개 구역 제목이 출력된다 | `[Server Monitor]`, `[Resource]`, `[File]`, `[Disk]`, `[Boot]`, `[Users]`, `[Service]`, `[Socket]`이 모두 나온다 |
| 2 | 다음 06시 이후 `tail -n 20 /var/log/server-check.log` | cron이 실행한 결과가 남는다 | 당일 날짜의 `Current Time` 줄이 있다 |
| 3 | `grep CRON /var/log/cron` | cron 실행 기록이 남는다 | 스크립트 경로가 포함된 줄이 있다 |

스크립트 오류와 정정은 아래와 같다.

| 증상 | 원인 | 정정 |
|---|---|---|
| `sar: command not found` | sysstat 미설치 | `dnf install -y sysstat` |
| `smartctl: command not found` | smartmontools 미설치 | `dnf install -y smartmontools` |
| `SMART support is: Unavailable` | 가상 머신 디스크는 SMART를 지원하지 않는다 | 가상 환경에서는 이 구역을 제외한다 (정상 동작) |
| `ss: command not found` | iproute 미설치 | `dnf install -y iproute` |
| cron에서만 실패한다 | cron은 최소한의 `PATH`로 실행된다 | 스크립트 첫 줄 아래에 `PATH=/usr/sbin:/usr/bin:/sbin:/bin`을 추가한다 |
| 수동 실행은 되는데 cron은 파일이 없다 | 경로 오타 | 5-C-02의 경로를 실제 파일과 대조한다 |

## 7. 복구

1. (7-01) 스크립트를 중지한다: `crontab -e`로 5-C-02의 줄을 삭제한다. → 결과: `crontab -l`에 그 줄이 없다.
2. (7-02) 스크립트와 결과 파일을 삭제한다: `rm /usr/local/sbin/server-check.sh /var/log/server-check.log`

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 점검 항목 목록과 스크립트를 AMM 형식으로 재작성. OS 확인 방식과 `netstat -p`를 정정하고 서비스 확인, 실행 권한, cron 등록, 복구를 추가. 접속 IP와 디스크 일련번호가 든 실행 결과 예시는 삭제. "팀 과제" 부분은 NET-TOP-005-MP로 분리했다 |
