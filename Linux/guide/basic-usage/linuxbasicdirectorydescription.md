# LinuxBasicDirectoryDescription

| dir               | desc                                                                                                           |
| ----------------- | -------------------------------------------------------------------------------------------------------------- |
| /                 | <p>파일 시스템이 있는 최상위 디렉토리.<br>모든 디렉토리의 출발점<br>다른 시스템과의 연결점</p>                                                    |
| /bin              | <p>기본적인 명령어 저장.<br>root 사용자와 일반 사용자 모두 사용 가능</p>                                                               |
| /boot             | <p>부트 디렉토리.<br>커널 이미지, 부팅 정보 파일 저장</p>                                                                         |
| **/dev**          | **시스템 디바이스 디렉터리.**                                                                                             |
| **/etc**          | <p><strong>시스템 환경 설정 파일, 부팅 스크립트 파일 저장</strong><br><strong>사용자 정보 및 암호 정보 파일, 보안 파일 등 저장</strong></p>          |
| /etc/rc.d         | 부팅 레벨별 부팅 스크립트 파일                                                                                              |
| /etc/rc.d/init.d  | 시스템 초기화 파일                                                                                                     |
| /etc/mail         | send메일 설정 파일                                                                                                   |
| /etc/winitd.d     | 슈퍼 데몬에 의해 서비스 되는 서비스 설정 파일                                                                                     |
| /etc/ssh          | sshd 데몬에서 실행되는 각종 설정 파일                                                                                        |
| /etc/samba        | 삼바 관련 설정 파일                                                                                                    |
| /etc/group        | 그룹 정보                                                                                                          |
| /etc/passwd       | 계정 정보                                                                                                          |
| /etc/shadow       | <p>/ect/passwd 의 두 번째 필드인 패스워드 부분을 암호화 관리.<br>패스워드 만기일, 계정 만기일 등 저장</p>                                        |
| /home             | <p>사용자 계정 디렉토리.<br>계정들의 홈 디렉토리가 위치</p>                                                                         |
| **/lib**          | <p><strong>공유 라이브러리 디렉토리.</strong><br><strong>커널 모듈 파일, 프로그램 실행을 지원해주는 라이브러리 저장</strong></p>                   |
| **/lost+found**   | <p><strong>결함이 있는 파일에 대한 정보.</strong><br><strong>fsck에 의해서 사용되는 디렉토리</strong></p>                              |
| /mnt              | 파일 시스템을 일시적으로 마운트 할 때 사용                                                                                       |
| /proc             | <p>가상 파일 시스템 정보 디렉토리.<br>현재 실행중인 프로세스, 실제 사용하는 하드웨어 정보 저장</p>                                                  |
| /root             | 시스템 관리자용 홈 디렉토리                                                                                                |
| /sbin             | 시스템 명령어 저장                                                                                                     |
| /tmp              | 임시로 생성되는 파일 저장                                                                                                 |
| /usr              | <p>사용자 데이터나 어플리케이션 저장.<br>사용자 디렉토리</p>                                                                         |
| /usr/bin          |                                                                                                                |
| /usr/X11R6        |                                                                                                                |
| /usr/lib          | /lib에 들어가지 않은 라이브러리                                                                                            |
| /usr/local        | MySQL. Apache, PHP 등과 같은 어플리케이션들을 소스로 컴파일을 설치할 때 사용되는 디렉토리                                                     |
| /usr/share/man    | 메뉴얼 페이지 디렉토리                                                                                                   |
| **/var**          | <p><strong>가변 자료(로그 파일, 스폴링(spooling), 캐싱(caching)) 저장 디렉토리.</strong><br><strong>로그 파일, 메일 데이터 저장</strong></p> |
| /var/tmp          | <p>리눅스 시스템의 공용 디렉토리는 /tmp, /var/tmp.<br>(퍼미션: 1777) sticky bit 설정.</p>                                         |
| /var/log          | 시스템 로그 파일                                                                                                      |
| /var/named        | DNS에서 사용하는 zone 파일                                                                                             |
| /var/spool/lpd    | 프린트 임시 디렉터리 (Spooling 디렉터리)                                                                                    |
| /var/spool/mqueue | 발송을 위한 메일 임시 저장                                                                                                |
| /var/spool/cron   | 각 사용자들의 cron 설정 파일                                                                                             |
| /var/spool/at     | atd (예약작업) 관련 파일                                                                                               |
