# ServerCheckScript

### 출력 사항

* 시스템 정보: 서버 운영체제, DB 버전, 현재 시간
* 시스템 리소스: CPU, RAM, ROM 사용량
* 파일 시스템 사용량
* 디스크 컨디션: [smart tool](file:///2435498/dev_tools/smart%20tool.md)을 통한 디스크 상태 확인
* 부팅 정보: 시스템 부팅 시간, 운영 시간
* 현재 로그인한 사용자 목록
* 현재 실행 중인 프로세스: 웹, DB, 애플리케이션 등 실행 여부

***

### 시스템 정보

* 운영체제: \~ -relese

***

### 시스템 리소스

명령 예시:

* free : 메모리 사용량
* free -h : 메모리 사용량 단위 포함
* [sysstat](file:///2435498/linux_admin/sysstat.md)
* [cron](file:///2435498/linux_admin/cron.md): `crontab -e * 5 * * 0 root /usr/lib/sa/sal`

***

### 파일 시스템

명령 예시:

* df -h
* du

***

### 디스크 컨디션

* [smart tool](file:///2435498/dev_tools/smart%20tool.md)

***

### 부팅 정보

* who -b

***

### 현재 로그인한 사용자

* who -u

***

### 프로세스 정보

명령 예시:

* ps -ef
* pgrep
* [netstat](/broken/pages/64ec2824dea3af55128da0d6f6a95deca09d48e6)

***

### 작성 예제

스크립트 예제:

{% code title="server.sh" %}
```bash
#!/usr/bin/bash

#Functions
get_cpu_stat() {
        sar 1 3 | grep Average | awk '{for(i=3;i<=NF;i++) printf $i" "}'
}

get_ram_stat() {
        free -h | grep Mem | awk '{for(i=2;i<=NF;i++) printf $i" "}'
}

get_swap_stat() {
        free -h | grep Swap | awk '{for(i=2;i<=NF;i++) printf $i" "}'
}


# system
os_ver=`grep . /etc/*rocky-release | perl -ane print` # os check
# DB check
cur_time=`date` # date check
cpu_stat=$(get_cpu_stat)
ram_stat=$(get_ram_stat)
swap_stat=$(get_swap_stat)


echo
echo "[Server Monitor]"
echo "--------------------------------------------------------"
echo "OS Version: $os_ver"
echo "DB Version: MariaDB ~~"
echo "Current Time: $cur_time"
echo

# resource Monitor
echo "[Resource]"
echo "--------------------------------------------------------"
echo "CPU: $cpu_stat"
echo "RAM: $ram_stat"
echo "SWAP: $swap_stat"
echo

# File
echo "[File]"
echo "--------------------------------------------------------"
df -h
echo

# Disk
echo "[Disk]"
echo "--------------------------------------------------------"
smartctl --all /dev/sda
echo

# Boot
echo "[Boot]"
echo "--------------------------------------------------------"
who -b
echo

# User
echo "[Users]"
echo "--------------------------------------------------------"
who -u
echo

# Process
echo "[Process]"
echo "--------------------------------------------------------"
netstat -p
echo
```
{% endcode %}

실행 예시 출력:

{% code title="실행 결과 예시" %}
```bash
./server.sh

[Server Monitor]
--------------------------------------------------------
OS Version: Rocky Linux release 9.4 (Blue Onyx)
DB Version: MariaDB ~~
Current Time: Tue Sep 24 11:24:40 AM KST 2024

[Resource]
--------------------------------------------------------
CPU: all 0.00 0.00 0.67 0.00 0.00 99.33
RAM: 1.7Gi 321Mi 1.2Gi 4.0Mi 397Mi 1.4Gi
SWAP: 2.0Gi 0B 2.0Gi

[File]
--------------------------------------------------------
Filesystem           Size  Used Avail Use% Mounted on
devtmpfs             4.0M     0  4.0M   0% /dev
tmpfs                888M     0  888M   0% /dev/shm
tmpfs                356M  5.0M  351M   2% /run
/dev/mapper/rl-root   17G  2.1G   15G  13% /
/dev/sda1            960M  404M  557M  43% /boot
tmpfs                178M     0  178M   0% /run/user/0

[Disk]
--------------------------------------------------------
smartctl 7.2 2020-12-30 r5155 [x86_64-linux-5.14.0-427.33.1.el9_4.x86_64] (local build)
Copyright (C) 2002-20, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Device Model:     VBOX HARDDISK
Serial Number:    VB911d6255-dc004aed
Firmware Version: 1.0
User Capacity:    21,474,836,480 bytes [21.4 GB]
Sector Size:      512 bytes logical/physical
Device is:        Not in smartctl database [for details use: -P showall]
ATA Version is:   ATA/ATAPI-6 published, ANSI INCITS 361-2002
Local Time is:    Tue Sep 24 11:24:43 2024 KST
SMART support is: Unavailable - device lacks SMART capability.

A mandatory SMART command failed: exiting. To continue, add one or more '-T permissive' options.

[Boot]
--------------------------------------------------------
         system boot  2024-09-24 08:47

[Users]
--------------------------------------------------------
root     pts/0        2024-09-24 08:50   .          1382 (192.168.1.8)
root     pts/1        2024-09-24 11:15 00:09        2296 (192.168.1.8)
```
{% endcode %}

***

### 팀 과제

* 리눅스 시스템 보안 점검 스크립트 작성 (하나의 파일)

현재 포함된(원본) 스크립트 조각:

{% code title="팀 과제 - 원본 스크립트 조각" %}
```bash
telnetstat=telnet.socket
if [ $telnetstat = 'active' ]; then
	echo "취약 - telnet 서비스 동작 중 -> 서비스 제거 여부 점검"
else

sshstat=cat /etc/ssh/sshd_config | grep PermitRootLogin
if [ $sshstat = 'no']; then
	echo "취약 = root 원격 접속 가능"
```
{% endcode %}

요구사항:

* 현재 버전에 맞게 수정해서
* 포맷 통일
* 금요일까지

(위 요구사항은 원문 그대로 유지되었습니다.)

***
