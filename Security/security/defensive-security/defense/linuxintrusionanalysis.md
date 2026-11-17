# Linux 침해 분석 아티팩트

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-DEF-013-REF |
| 유형 | REF (참조) |
| 목적 | 침해가 의심되는 Linux 시스템에서 수집하는 아티팩트와 그 확인 명령을 찾아본다 |
| 확인 상태 | 미검증 (원본 명령 목록을 표로 옮기고 틀린 옵션을 정정했다. 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 아티팩트의 종류는 Windows와 같고 명령만 다르다. Windows 쪽은 [침해사고 이벤트 분석 절차](intrusioneventanalysis.md) (SEC-DEF-014-MP)를 따른다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 침해 의심 시스템에서 `find`, `ls`, `cat`은 파일의 접근 시간(atime)을 바꿔 증거를 훼손할 수 있다. 가능하면 디스크 이미지를 복사해 이미지에서 분석한다. 침입자가 `ps`, `netstat` 같은 명령을 바꿔 놓았을 수 있으므로 결과를 다른 방법과 교차 확인한다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [침해사고 이벤트 분석 절차](intrusioneventanalysis.md) | SEC-DEF-014-MP | Windows 아티팩트 수집 |
| [침해사고 분석 및 대응 절차](securityincidentanalysisresponse.md) | SEC-DEF-015-DO | 분석 환경과 대응 흐름 |
| [시스템 로그 파일 분석 (/var/log)](../../../../Linux/guide/logging-monitoring/log_file.md) | LNX-LOG-001-REF | 로그 파일 위치 |

## 2. 시스템 상태

| 항목 | 명령 | 비고 |
|---|---|---|
| 시간, 날짜 | `date` | 수집 시각을 기록한다 |
| 시스템 정보 | `uname -a` | |
| 마지막 접속 기록 | `last`, `lastb`, `lastlog` | `lastb`는 로그인 실패 기록이다 |
| 현재 접속한 사용자 | `w` | |
| 현재 런레벨 | `runlevel` | systemd 시스템에서는 `systemctl get-default`로 확인한다 |
| 삭제된 파일 확인 | `debugfs <장치>` | ext 계열 파일 시스템 |

| 런레벨 | 뜻 |
|---|---|
| 0 | Halt (시스템 중지. 기본값으로 설정할 수 없다) |
| 1 | Single User Mode (복구 등 관리 목적) |
| 2 | Multiuser Without NFS (네트워크를 쓰지 않는 다중 사용자) |
| 3 | Full Multiuser (기본값) |
| 4 | Unused (사용자 정의) |
| 5 | X11 Mode (GUI) |
| 6 | Reboot (재부팅. 기본값으로 설정할 수 없다) |

원하는 런레벨은 `/etc/inittab`에서 지정한다. systemd를 쓰는 최신 배포판은 `inittab`을 쓰지 않는다(확인 필요).

## 3. 계정과 권한

| 항목 | 명령 | 비고 |
|---|---|---|
| 사용자·그룹 정보 | `cat /etc/passwd`, `cat /etc/shadow`, `cat /etc/group` | 알 수 없는 계정, UID 0 계정을 찾는다 |
| SetUID 파일 | `find / -type f -perm -4000 -ls` | 원본의 `-perm 4000`은 정확히 일치만 찾으므로 `-` 접두사를 붙여 정정했다 |
| SetGID 파일 | `find / -type f -perm -2000 -ls` | 원본의 `-perm 6000`은 SetUID와 SetGID를 모두 가진 파일만 찾는다 |
| root 소유이고 모두에게 쓰기 가능한 파일 | `find / -type f -perm -002 -user 0` | |

`find / -type f -perm 4000 ...`처럼 서식을 바꿔 조건을 조합할 수 있다.

## 4. 시간 기준 파일 검색

| 명령 | 뜻 |
|---|---|
| `find / -atime -N` | N일 이내에 접근한 파일 |
| `find / -ctime -N` | N일 이내에 상태(inode)가 바뀐 파일. 원본은 "만들어진"이라 적었으나 ctime은 생성 시각이 아니다 |
| `find / -mtime -N` | N일 이내에 내용이 수정된 파일 |
| `find / -amin -N`, `-cmin`, `-mmin` | 같은 조건을 분 단위로 |
| `find / -cnewer <기준 파일>` | 기준 파일보다 나중에 상태가 바뀐 파일 |

## 5. 프로세스와 스케줄

| 항목 | 명령 | 비고 |
|---|---|---|
| 프로세스 목록 | `ps -ef`, `ps -efa`, `ps -ejH` | `-ejH`는 계층(트리) 형태 |
| 프로세스 트리 | `pstree` | 부모-자식 관계를 그림으로 본다 |
| 실시간 보기 | `top` | |
| 예약 작업 | `crontab -l` | 사용자별. `/etc/cron*`도 확인한다 |

## 6. 악성 흔적과 무결성

| 항목 | 명령 | 비고 |
|---|---|---|
| 루트킷 점검 도구 | `chkrootkit` | 별도 설치가 필요하다 |
| 패키지 무결성 | `rpm -Va` | RPM 계열. 출력 문자의 의미는 아래 표 |

| 문자 | 뜻 |
|---|---|
| `5` | MD5가 설치 당시와 다르다 |
| `S` | 파일 크기가 다르다 |
| `T` | 수정 시간(mtime)이 다르다 |
| `U` | 소유 사용자가 다르다 |
| `G` | 소유 그룹이 다르다 |
| `M` | 권한(mode)이 다르다 |
| `D` | 장치 번호(major/minor)가 다르다 |
| `L` | 심볼릭 링크가 바뀌었다 |

## 7. 네트워크

| 항목 | 명령 | 비고 |
|---|---|---|
| 연결 목록 | `netstat -an` | 최신 배포판은 `ss -an`을 쓴다 |
| ARP 테이블 | `arp -a` | |
| IP 주소 | `ip addr` | |
| 라우팅 | `route` | `ip route`로 대체할 수 있다 |
| 열린 파일·소켓 | `lsof` | |

## 8. 명령 기록과 로그

| 항목 | 방법 |
|---|---|
| 명령 기록 | `history` |
| 기록에 시각 남기기 | `/etc/profile`에 `HISTIMEFORMAT="[%Y-%m-%d %H:%M:%S] "`를 추가한다 (원본의 `%M`, `%D` 등은 날짜 서식이 아니므로 정정했다) |
| 로그 위치 | `/var/log` |
| 계정 전환(su) 기록 | 원본은 `sulog`라고 적었으나 Linux에서는 `/var/log/secure`(RHEL 계열) 또는 `/var/log/auth.log`(Debian 계열)에 남는다(확인 필요) |

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 명령 나열 원본을 REF 표로 재작성. `find -perm`, `-ctime`, `HISTIMEFORMAT`, `sulog` 서술을 정정하고 증거 훼손 CAUTION을 추가했다 |
