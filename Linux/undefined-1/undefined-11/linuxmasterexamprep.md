# LinuxMasterExamPrep

<details>

<summary>문제: 다음 명령어에 대한 설명으로 가장 적절한 것은? [root&#x26;ihd root]# cat /etc/passwd | grep -v linuxmaster</summary>

* 선택지\
  가. /etc/passwd 파일에서 linuxmaster라는 문자열이 포함된 행만 출력한다.\
  나. /etc/passwd 파일에서 linuxmaster라는 문자열이 포함되지 않은 행만 출력한다.\
  다. /etc/passwd 파일에서 linuxmaster라는 문자열을 추가한다.\
  라. /etc/passwd 파일에서 linuxmaster라는 문자열이 계정이 존재하는지 확인한다.
* 정답: 나. /etc/passwd 파일에서 linuxmaster라는 문자열이 포함되지 않은 행만 출력한다.
* 해설:\
  grep의 옵션 중 -v는 전달 받은 키 값을 포함하지 않는 문장(행)을 출력하는 옵션이다.

</details>

<details>

<summary>문제: 현재 디렉토리의 하위 디렉토리까지 모두 포함하여 linuxmaster라는 문자열을 포함한 파일을 검색하는 명령으로 가장 알맞은 것은?</summary>

* 선택지\
  가. find .-string linuxmaster -print\
  나. grep -r linuxmaster \*\
  다. ls-al | grep linuxmaster\
  라. cat \* | grep linuxmaster
* 정답: 나. grep -r linuxmaster \*
* 해설:\
  grep의 -r 옵션은 디렉토리와 그 하위 디렉토리의 모든 파일을 재귀적으로 검색한다. 사용 예: grep -r '찾는 키' '디렉토리'

</details>

<details>

<summary>문제: shutdown 명령어의 옵션에 대한 설명으로 틀린 것은?</summary>

* 선택지\
  가. -c: 예약된 shutdown 명령을 취소한다.\
  나. -h: shutdown 명령이 완료되면 시스템을 정지시킨다.\
  다. -f: shutdown 전에 수행중인 모든 프로세스에게 kill 시그널을 보낸다.\
  라. -r: shutdown 명령이 완료되면 시스템을 재부팅 한다.
* 정답: 다. -f: shutdown 전에 수행중인 모든 프로세스에게 kill 시그널을 보낸다.
* 해설:\
  shutdown의 -f 옵션은 다음 부팅 시 파일 시스템 검사를 건너뛰도록 설정하는 옵션이다. 강제 종료(모든 프로세스에 kill 시그널 전송) 옵션이 아니다.

</details>

<details>

<summary>문제: diff 명령어의 옵션에 대한 설명으로 틀린 것은?</summary>

* 선택지\
  가. -i: 대,소문자를 구별한다.\
  나. -b: 하나 이상의 공백문자는 같은 것으로 취급하여 비교한다.\
  다. -e: ed 에디터를 위한 스크립트를 생성한다.\
  라. -w: 공백을 무시하고 비교 작업을 수행한다.
* 정답: 가. -i: 대,소문자를 구별한다.
* 해설:\
  diff의 -i 옵션은 대소문자를 구별하지 않고 비교한다. (즉 "hello"와 "Hello"를 동일하게 취급)

</details>

<details>

<summary>문제: 시스템을 재 시작하지 않고 종료하는 명령으로 틀린 것은?</summary>

* 선택지\
  가. shutdown -h now\
  나. halt\
  다. init 0\
  라. reboot
* 정답: 라. reboot
* 해설:\
  reboot 명령어는 시스템을 재부팅하는 명령어다.

</details>

<details>

<summary>문제: FSF의 설립자로서 GNU를 이끌면서 리눅스의 발전에 핵심적인 역할을 한 사람은?</summary>

* 선택지\
  가. 리처드 스톨만(Richard Stallman)\
  나. 리누스 토발즈(Linus Tovalds)\
  다. 앤드류 타넨바움(Andrew Tanenbaum)\
  라. 빌 게이츠(Bill Gates)
* 정답: 가. 리처드 스톨만(Richard Stallman)
* 해설:\
  리처드 스톨만은 1983년 FSF/GNU 프로젝트를 시작했다.

</details>

<details>

<summary>문제: 시디롬을 열고 닫을 때, 사용하는 명령어는?</summary>

* 선택지\
  가. eject\
  나. mount\
  다. mmd\
  라. close
* 정답: 가. eject
* 해설:\
  'eject'는 CD-ROM 트레이를 열거나 닫는 데 사용한다. 'mount'는 마운트, 'umount'는 언마운트.

</details>

<details>

<summary>문제: 리처드 스톨만(Richard Stallman)에 의해 설립되었으며 컴퓨터 프로그램의 복제와 배포, 개작을 위한 소스 코드의 응용에 대한 제한들을 철폐하는 목적을 가진 단체는?</summary>

* 선택지\
  가. FSF\
  나. ISO\
  다. ANSI\
  라. IETF
* 정답: 가. FSF
* 해설:\
  리처드 스톨만이 설립한 Free Software Foundation(FSF).

</details>

<details>

<summary>문제: LILO에 대한 설명으로 틀린 것은?</summary>

* 선택지\
  가. 반드시 MBR(Master Boot Record)에 설치되어야 하는 것은 아니다.\
  나. Redhat 계열의 배포판에서만 제공된다.\
  다. LILO를 사용하면 다양한 OS를 선택하여 사용할 수 있다.\
  라. LILO외에도 GRUB(Grand Unified Bootloader)등의 부트 로더가 있다.
* 정답: 나. Redhat 계열의 배포판에서만 제공된다.
* 해설:\
  LILO는 특정 배포판에만 국한되지 않는다.
* 관련 링크: [LILO](file:///6408728/linux_admin/LILO.md)

</details>

<details>

<summary>문제: LILO 설정 파일인 /etc/lilo.conf의 각 설정에 대한 설명으로 틀린 것은?</summary>

* 선택지\
  가. boot=/dev/hda : LILO가 설치될 위치\
  나. map=/boot/map : LILO에 의해서 자동으로 생성되는 파일\
  다. install=/boot/boot.b : 부트 섹터 위치 정보를 가진 파일\
  라. timeout=50 : 키보드 입력이 없을 시 자동 부팅시간 50초 설정
* 정답: 가. boot-/dev/hda : LILO가 설치될 위치
* 해설:\
  `boot=`는 부트 로더가 사용할 장치를 지정한다. 일반적으로 `/dev/hda`는 첫 번째 IDE 드라이브를 가리킨다.

</details>

<details>

<summary>문제: 오류 메시지를 파일로 저장하기 위한 방향 재지정 명령으로 옳은 것은?</summary>

* 선택지\
  가. cat nofile 0> error\_log\_file\
  나. cat nofile 1> error\_log\_file\
  다. cat nofile 2> error\_log\_file\
  라. cat nofile > error\_log\_file
* 정답: 다. cat nofile 2> error\_log\_file
* 해설:\
  2>는 표준 에러(STDERR)를 리디렉션한다. 0>는 표준 입력, 1>는 표준 출력, >는 기본적으로 1>와 동일.

</details>

<details>

<summary>문제: LILO와 GRUB에 대한 설명으로 틀린 것은?</summary>

* 선택지\
  가. LILO는 GRUB보다 먼저 개발되었다.\
  나. LILO는 컴퓨터 바이오스(BIOS)의 정보를 참조하지 않는다.\
  다. GRUB은 IDE 하드디스크를 장착한 순서대로 인식한다.\
  라. GRUB에서는 부트 디스크를 통한 부팅을 지원하지 않는다.
* 정답: 나. LILO는 컴퓨터 바이오스(BIOS)의 정보를 참조하지 않는다.
* 해설:\
  LILO는 부트로더로서 BIOS 정보를 참조한다.

</details>

<details>

<summary>문제: 하나의 디스크를 몇 개의 드라이브로 분할하여 사용할지 설정하는 것으로 그 용어와 툴(Tool)의 조합이 맞는 것은?</summary>

* 선택지\
  가. MBR, FDISK\
  나. MBR, LILO\
  다. 파티션, Disk Druid\
  라. 파티션, LILO
* 정답: 다. 파티션, Disk Druid
* 해설:\
  Disk Druid는 GUI 기반의 디스크 파티셔닝 도구이다. 관련: [MBR](file:///6408728/cs_basics/MBR.md), [Disk Druid](file:///6408728/linux_admin/Disk_Druid.md), [FDISK](file:///6408728/linux_admin/FDISK.md)

</details>

<details>

<summary>문제: 다음 중 논리 파티션에 부여될 수 있는 최소 파티션 값으로 알맞은 것은?</summary>

* 선택지
  1. 1
  2. 2
  3. 4
  4. 5
* 정답: 4. 5
* 해설:\
  논리 파티션은 보통 5번부터 시작한다(1\~4는 주 파티션).

</details>

<details>

<summary>문제: 크론 데몬(cron daemon)에 의해 갱신된 데이터베이스를 바탕으로 파일의 빠른 검색을 가능하게 하는 명령어는?</summary>

* 선택지
  1. locate
  2. grep
  3. find
  4. search
* 정답: 1. locate
* 해설:\
  locate는 updatedb로 갱신된 데이터베이스를 사용해 빠르게 파일을 검색한다.

</details>

<details>

<summary>문제: grub.conf 파일의 설정 내용이 지워진 상태에서 GRUB 부트 메뉴에서 관련 설정을 직접 입력하려고 한다. 다음 중 GRUB 부트 메뉴에서 입력하는 키로 알맞은 것은?</summary>

* 선택지
  1. \[a]
  2. \[b]
  3. \[c]
  4. \[e]
* 정답: 4. \[e]
* 해설:\
  GRUB에서 항목을 편집하려면 커서를 해당 항목에 두고 'e'키를 누른다.

</details>

<details>

<summary>문제: 소스 코드를 수정해서 프로그램을 개발한 후에 소스 코드를 공개하지 않고 독점적 소프트웨어로 사용하려고 한다. 다음 설명에 적합한 라이선스로 알맞은 것은?</summary>

* 선택지
  1. GPL
  2. BSD
  3. MPL
  4. LGPL
* 정답: 2. BSD
* 해설:\
  BSD 라이선스는 소스 코드를 공개하지 않고도 수정된 코드를 독점적으로 사용할 수 있게 허용한다.

</details>

<details>

<summary>문제: ls -l a? | wc -l 명령어의 결과값은?</summary>

* 선택지
  1. 2
  2. 3
  3. 4
  4. 5
* 정답: 1. 2
* 해설:\
  a로 시작하고 뒤에 한 글자가 있는 파일들을 상세히 출력한 라인 수를 wc -l로 센 결과.

</details>

<details>

<summary>문제: ls -al /etc/skel 실행 결과 설명으로 가장 적절한 것은?</summary>

* 결과 예시:\
  total 28\
  drwxr-xr-x 3 root root 78 Jan 4 12:15 .\
  drwxr-xr-x 156 root root 12288 Jan 20 11:32 ..\
  -rw-r--r-- 1 root root 18 Apr 1 2020 .bash\_logout\
  -rw-r--r-- 1 root root 193 Apr 1 2020 .bash\_profile\
  -rw-r--r-- 1 root root 231 Apr 1 2020 .bashrc\
  drwxr-xr-x 4 root root 39 Jan 4 12:14 .mozilla
* 선택지
  1. 현재 로그인 된 계정의 bash 설정 파일들을 나열하고 있다.
  2. 새로운 계정을 생성할 때 기본적으로 홈 디렉토리에 생성되어야 할 각종 설정 파일들의 목록을 나열하고 있다.
  3. 현재 로그인된 계정의 홈 디렉토리에 존재하는 파일들을 나열하고 있다.
  4. 시스템의 모든 사용자에게 영향을 주는 bash 설정을 담당하는 파일들을 나열하고 있다.
* 정답: 2. 새로운 계정을 생성할 때 기본적으로 홈 디렉토리에 생성되어야 할 각종 설정 파일들의 목록을 나열하고 있다.
* 해설:\
  /etc/skel은 새 사용자 생성 시 기본으로 복사되는 파일들을 담고 있다.

</details>

<details>

<summary>문제: 다음 (괄호) 안에 들어갈 명령어로 알맞은 것은? $ ( ) kaituser pts/0 2017-01-23 22:27 (203.247.40.xxx) root pts/2 2016-08-29 16:13 (:2.0) root tty1 2016-11-28 15:46 (:0) root pts/16 2016-11-29 09:13 (:0.0)</summary>

* 선택지
  1. who
  2. w
  3. id
  4. users
* 정답: 1. who
* 해설:\
  who는 현재 로그인한 사용자들의 정보를 표시한다.

</details>

<details>

<summary>문제: \# ( ) -s time.bora.net 에 들어갈 명령어로 알맞은 것은?</summary>

* 선택지
  1. set
  2. time
  3. date
  4. rdate
* 정답: 4. rdate
* 해설:\
  rdate는 원격 시간 서버에서 시간을 가져와 시스템 시간을 설정하는 명령어다.

</details>

<details>

<summary>문제: 파티션 분할된 상태를 확인할 수 있는 파일로 알맞은 것은?</summary>

* 선택지
  1. /etc/partition
  2. /etc
  3. /proc/partition
  4. /proc/partitions
* 정답: 4. /proc/partitions
* 해설:\
  /proc/partitions에 현재 인식된 블록 장치와 파티션 정보가 포함되어 있다.

</details>

<details>

<summary>문제: 시스템에 로그인한 전체 사용자에게 메시지를 전달할 때 사용하는 명령으로 알맞은 것은?</summary>

* 선택지
  1. write
  2. mesg
  3. message
  4. wall
* 정답: 4. wall
* 해설:\
  wall은 로그인한 모든 사용자에게 메시지를 보낸다.

</details>

<details>

<summary>문제: 다음 중 아파치 라이선스를 적용하는 소프트웨어로 알맞은 것은?</summary>

* 선택지
  1. CentOS
  2. Hadoop
  3. Firefox
  4. OS XNIS
* 정답: 2. Hadoop
* 해설:\
  Hadoop은 Apache License를 따르는 프로젝트이다.

</details>

<details>

<summary>문제: date ( ) 2017 02 01 에 들어갈 형식 지정자는?</summary>

* 선택지
  1. "%Y %m %d"
  2. -%Y %m %d
  3. +"%Y %m %d"
  4. \--%Y %m %d
* 정답: 3. +"%Y %m %d"
* 해설:\
  date 명령어에서 형식은 +로 시작한다.

</details>

<details>

<summary>문제: 다음 중 상용판 리눅스로 알맞은 것은?</summary>

* 선택지
  1. CentOS
  2. Scientific Linux
  3. RHEL
  4. Fedora
* 정답: 3. RHEL
* 해설:\
  RHEL(Red Hat Enterprise Linux)은 유료 상용 배포판이다.

</details>

<details>

<summary>문제: 리눅스에서 인식되는 장치 파일명의 종류가 나머지 셋과 다른 것은?</summary>

* 선택지
  1. SCSI
  2. E-IDE
  3. SSD
  4. USB 메모리
* 정답: 2. E-IDE
* 해설:\
  E-IDE는 /dev/h&#x64;_&#xB85C; 인식되고, 나머지는 /dev/s&#x64;_&#xB85C; 인식된다.

</details>

<details>

<summary>문제: cat ( ) lin.txt 에 들어갈 옵션으로 알맞은 것은? (파일 내용 표시된 예시 참조)</summary>

* 선택지
  1. -b
  2. -n
  3. -v
  4. -s
* 정답: 2. -n
* 해설:\
  -n은 모든 줄에 번호를 매긴다. -b는 비어 있지 않은 줄에만 번호를 매긴다.

</details>

<details>

<summary>문제: /etc/shadow 파일에 대한 설명 중 틀린 것은?</summary>

* 선택지\
  가. /etc/shadow는 일반 사용자는 읽기 권한만 가지며, 쓰기 및 실행은 할 수 없도록 지정되어있다.\
  나. /etc/shadow 파일에서 패스워드는 x로 표시되어 /etc/shadow 파일의 포인터를 유지하고 있다.\
  다. /etc/shadow 파일의 expire 필드는 암호와 계정이 만료되는 날짜의 정보를 가지고 있다.\
  라. /etc/passwd 파일은 사용자 계정에 대해 uid, gid, 기본 셸 등의 정보를 포함하고 있다.
* 해설:\
  /etc/shadow는 일반 사용자에게 읽기 권한조차 주어지지 않으며, root만 읽기/쓰기 권한을 가진다.

</details>

<details>

<summary>문제: LILO 설정 파일인 /etc/lilo.conf의 각 설정에 대한 설명으로 틀린 것은? (다시)</summary>

* 선택지
  1. BOOT=/dev/gda : LILO가 설치 될 위치
  2. MAP=/boot/map : LILO에 의해서 자동으로 생성되는 파일
  3. INSTALL=/boot/boot.b : 부트 섹터 위치 정보를 가진 파일
  4. TIMEOUT=50 : 키보드 입력이 없을 시 자동 부팅시간 50초 설정
* 해설:\
  /dev/gda는 잘못된 디바이스 이름이다. 일반적으로는 /dev/sda나 /dev/hda 등을 사용한다.

</details>

<details>

<summary>문제: 리눅스 설치 시 사용자 보안 인증에 관한 설정사항이 아닌 것은?</summary>

* 선택지
  1. MD5
  2. Shadow Password
  3. NIS
  4. SSL
* 정답: 4. SSL
* 해설:\
  SSL은 네트워크 통신 암호화 프로토콜로, 리눅스 설치 시의 사용자 보안 인증 설정과 직접 관련이 없다.

</details>

<details>

<summary>문제: bash 기준으로 명령어의 검색 경로를 지정할 수 있는 파일은?</summary>

* 선택지
  1. bash\_scan
  2. bash\_find
  3. bash\_path
  4. bash\_profile
* 정답: 4. bash\_profile
* 해설:\
  bash\_profile에서 PATH 등의 환경변수를 설정해 명령어 검색 경로를 지정할 수 있다.

</details>

<details>

<summary>문제: netstat 명령어에서 라우팅 테이블을 출력하는 옵션은?</summary>

* 선택지
  1. -a
  2. -c
  3. -i
  4. -r
* 정답: 4. -r
* 해설:\
  -r 옵션은 라우팅 테이블을 출력한다. 관련: [netstat](file:///6408728/network/netstat.md)

</details>

<details>

<summary>문제: 다음 명령의 의미는? # source=`ls *.c`</summary>

* 선택지
  1. .c 확장자를 가진 파일을 찾아 화면에 나열한다.
  2. source 셸 변수에 'ls \*.c'라는 문자열을 대입한다.
  3. .c 확장자를 가진 파일을 찾아 source 셸 변수에 대입한다.
  4. source 변수의 내용과 ls \*.c 명령의 수행 결과가 동일한가 비교한다.
* 정답: 3. .c 확장자를 가진 파일을 찾아 source 셸 변수에 대입한다.
* 해설:\
  백틱(\`\`) 안의 명령 실행 결과가 변수에 대입된다.

</details>

<details>

<summary>문제: "unknown host" 오류가 날 때 제일 먼저 점검해 볼 사항은? (2개)</summary>

* 선택지
  1. /etc/host.conf 파일을 점검한다.
  2. hostname 명령을 수행한다.
  3. ifconfig 명령을 수행한다.
  4. /etc/resolv.conf 파일을 점검한다.
* 해설:\
  hostname으로 호스트 이름 설정을 확인하고, /etc/resolv.conf에서 DNS 서버 설정을 확인하는 것이 우선이다.

</details>

<details>

<summary>문제: 다음 중 TCP/IP 서비스 설명 중 옳지 않은 것은?</summary>

* 선택지
  1. TELNET : 원격 시스템으로 접속하여 명령이나 각종 응용 프로그램을 실행 시킬 수 있는 단말기 서비스 프로토콜
  2. FTP : 양쪽 컴퓨터를 연결하여 파일로 송·수신하는 서비스 프로토콜
  3. SMTP: 연결할 호스트의 이름에 대한 IP 주소를 찾아 주는 프로토콜
  4. HTTP : 웹을 통해 다양한 종류의 전자문서들을 서비스하는 프로토콜
* 정답: 3. SMTP 설명이 잘못되었다.
* 해설:\
  SMTP는 메일 전송 프로토콜이며, 호스트 이름을 IP로 변환하는 것은 DNS의 역할이다.

</details>

<details>

<summary>문제: 다음 명령의 실행 결과에 대한 설명으로 가장 적절한 것은? [root@ihdroot]echo $PWD /root</summary>

* 선택지
  1. 현재 작업 디렉토리의 위치를 확인해 보고 있다.
  2. 홈 디렉토리 정보를 간직하고 있는 PWD 환경변수의 내용을 출력하고 있다.
  3. 시스템 관리자의 권한으로만 위 환경변수를 확인해 볼 수 있다.
  4. 일반적으로 디렉토리를 이동하면 PWD 변수를 수동으로 다시 설정해 주어야 한다.
* 정답: 2. 현재 작업 디렉토리의 절대 경로를 저장하는 PWD 환경변수의 내용을 출력하고 있다. (선택지 1과 2의 의미가 유사하므로 맥락상 2번이 적절)
* 해설:\
  PWD는 현재 작업 디렉토리의 절대 경로를 저장하며, 모든 사용자가 접근 가능하고 자동으로 갱신된다.

</details>

<details>

<summary>문제: mbox 파일의 파일 종류를 확인하는 명령은? (mbox: ASCII mail text 출력 예시)</summary>

* 선택지
  1. what
  2. file
  3. type
  4. tail
* 정답: 2. file
* 해설:\
  file 명령은 파일의 타입을 판별한다.

</details>

<details>

<summary>문제: 다음 중 리눅스에서 파티션을 분할하도록 권장하지 않는 영역(틀린 것은?)</summary>

* 선택지
  1. /usr
  2. /tmp
  3. /etc
  4. /var
* 정답: 3. /etc
* 해설:\
  /etc는 설정 파일을 저장하는 정적인 디렉토리로 별도의 파티션으로 분리하는 것은 권장되지 않는다(데이터 지속 저장용으로 부적합).

</details>

<details>

<summary>문제: reboot 명령어의 수행 과정에 대한 설명으로 틀린 것은?</summary>

* 선택지
  1. 파일 시스템을 언마운트한다.
  2. 시스템을 shutdown 한다.
  3. 시스템 실행 수준(run level)을 3으로 변경시킨다.
  4. 다중 사용자(multi-user) 모드에서는 수행하지 않는다.
* 정답: 3, 4 중 틀린 설명(문맥상 3과 4는 부정확; 특히 4번은 틀림)
* 해설:\
  reboot은 파일 시스템을 안전하게 언마운트하고 시스템을 재시작한다. 특정 runlevel로 변경한다고 단정할 수 없으며, 다중 사용자 모드에서도 reboot는 수행될 수 있다.

</details>

<details>

<summary>문제: 리처드 스톨먼에 의해 설립된 단체는?</summary>

* 선택지
  1. FSF
  2. ISO
  3. ANSI
  4. IETF
* 정답: 1. FSF
* 해설:\
  FSF는 자유 소프트웨어를 위한 단체로 GNU 프로젝트 등을 주도했다.

</details>

<details>

<summary>문제: E-IDE 타입의 디스크인 Secondary Slave에 연결될 경우 인식되는 장치 파일명은?</summary>

* 선택지
  1. /dev/hda
  2. /dev/hdb
  3. /dev/hdc
  4. /dev/hdd
* 정답: 4. /dev/hdd
* 해설:\
  /dev/hdd는 두 번째 IDE 인터페이스의 슬레이브이다.

</details>

<details>

<summary>문제: 명령줄 명령해석에서 입력을 전환할 때 사용하는 기호로 알맞은 것은?</summary>

* 선택지
  1. |
  2. >
  3. <
  4. ;
* 정답: 1. |
* 해설:\
  파이프(|)는 앞 명령의 출력을 다음 명령의 입력으로 전달한다.

</details>

<details>

<summary>문제: 우분투(Ubuntu)의 기반이 되는 리눅스 배포판은?</summary>

* 선택지
  1. Fedora
  2. RHEL
  3. Debian
  4. Slackware
* 정답: 3. Debian
* 해설:\
  Ubuntu는 Debian에서 파생된 배포판이다.

</details>

<details>

<summary>문제: 다음 중 슬랙웨어 계열 리눅스에 속하는 배포판은?</summary>

* 선택지
  1. Kali Linux
  2. Scientific Linux
  3. SUSE
  4. Knoppix
* 정답: (주어진 선택지 중 없음)
* 해설:\
  주어진 선택지들은 각각 Debian 계열, RHEL 계열, SUSE 계열 등으로 분류되며, 슬랙웨어 계열은 Slackware, Zenwalk, Salix OS 등이 있다.

</details>
