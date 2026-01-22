# LinuxIntrusionAnalysis

아티팩트는 윈도우와 같지만 명령어가 다르다

## 시간/날짜

`date`

## 시스템 정보 보기

`uname -a`

## 마지막 접속 기록

`last`\
`lastb`\
`lastlog`

## 현재 접속한 사용자

`w`

## 현재 run level

`runlevel`

{% hint style="info" %}
Run Level

* 0: Halt (시스템 중지 - 디폴트로 설정할 수 없다)
* 1: Single User Mode (시스템 복구 등 관리 목적)
* 2: Multiuser Without NFS (네트워크를 사용하지 않는 다중 사용자 모드)
* 3: Full Multiuser (기본값)
* 4: Unused (사용자가 지정/정의해서 사용 가능)
* 5: X11 Mode (GUI/X Window)
* 6: Reboot (시스템 재부팅 - 디폴트로 설정할 수 없다.)
{% endhint %}

`vi /etc/inittab` <- 원하는 런레벨이 있다면 설정하면 됨

## 삭제된 파일 또는 디렉터리 확인/복구

`debugfs device`

## 사용자/그룹 정보 확인

`cat /etc/passwd`\
`cat /etc/shadow`\
`cat /etc/group`

## set UID/GID

`find / -type f -perm 6000 -ls`\
`find / -type f -perm 4000 -ls`

## 특정 사용자 권한이 있는 파일/디렉터리 검사

`find / -type f -perm -002 -user 0`

find / -type f -style {서식을 지정}

## 시간과 관련된 파일 찾기

`find -atime N` : N일 내에 액세스 된 파일 찾기\
`find -ctime N` : N일 내에 만들어진 파일 찾기\
`find -mtime N` : N일 내에 수정되어진 파일 찾기

* time -> min : 시간 기준

`find -cnewer FILE` : FILE 생성 이후에 생성된 파일을 찾아줌

## 프로세스 점검

`ps -ef`\
`ps -efa`\
`pstree` : 도식화\
`top` : 실시간으로 출력\
`ps -ejH`

## 스케줄링 점검

`crontab -l`

## 리눅스용 악성프로그램 점검 툴

chkrootkit

## 패키지 무결성 검사

`rpm -Va` : 무결성 점검

다음 의미:

* 5 -> MD5: 설치 당시 MD5와 현재의 MD5 값이 다르다.
* S -> Size(파일크기): 설치 당시 파일 사이즈와 현재 사이즈가 다르다.
* T -> Time(파일변경시간): 파일의 mtime이 변경되었다.
* U -> User: 설치 당시 사용자와 다르다.
* G -> Group: 설치 당시 그룹과 다르다.
* M -> Mode(Permission): 설치 당시 권한과 다르다.
* D -> Device: Device ID 값이 다르다. (Major N/Miner N)
* L -> Link: 심볼릭 링크의 수정이 생겼다.

## 네트워크

`netstat -an`\
`arp -a`\
`ip addr`\
`route`\
`lsof`

## 명령어 입력 기록

`history`\
`vi /etc/profile`

```sh
HISTIMEFORMAT="[%Y-%M-%D %h:%m:%s]"
```

## 로그

/var/log

sulog -> 계정 변경(관리자 권한) 사용 기록
