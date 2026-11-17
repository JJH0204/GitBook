# 시스템 로그 파일 분석 (/var/log)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-LOG-001-REF |
| 유형 | REF (파일·명령 표) |
| 목적 | `/var/log`의 주요 로그 파일 위치와 로그인 기록 조회 명령을 참조한다 |
| 확인 상태 | 미검증 (원본 페이지와 man 문서 지식을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 로그 파일 표

RHEL 계열 9 기준이다. 배포판에 따라 파일 이름이 다르다(예: Debian 계열은 `messages` 대신 `syslog`, `secure` 대신 `auth.log`).

| 경로 | 형식 | 내용 | 조회 방법 |
|---|---|---|---|
| `/var/log/messages` | 텍스트 | 시스템 일반 로그 | `less /var/log/messages` |
| `/var/log/secure` | 텍스트 | 인증·권한 관련 로그(로그인, `sudo`, `ssh`) | `less /var/log/secure` |
| `/var/log/cron` | 텍스트 | 예약 작업(cron) 실행 로그 | `less /var/log/cron` |
| `/var/log/btmp` | 바이너리 | 로그인 실패 기록 | `lastb` |
| `/var/log/wtmp` | 바이너리 | 로그인 성공·로그아웃·재부팅 기록 | `last` |
| `/var/log/lastlog` | 바이너리 | 사용자별 마지막 로그인 기록 | `lastlog` |
| `/run/utmp` | 바이너리 | 현재 접속 중인 사용자 | `who` |

{% hint style="info" %}
NOTE: `utmp`는 `/var/log`가 아니라 `/run/utmp`(`/var/run/utmp`는 이 경로의 링크)에 있다. 재부팅하면 비워진다. 바이너리 파일은 `cat`, `less`로 읽을 수 없다. 표의 명령으로 읽는다.
{% endhint %}

그 밖에 `/var/log`에는 `audit/`(감사 로그), `dnf.log`(패키지 관리), `boot.log`(부팅 서비스 메시지), `maillog`(메일), `firewalld`, `chrony/`, `sssd/`, `samba/` 등이 있다. 회전된 파일은 `messages-20240920`처럼 날짜가 붙는다(LNX-LOG-002-DO).

{% hint style="warning" %}
CAUTION: `btmp`에는 로그인 실패 때 입력한 사용자 이름이 남는다. 비밀번호를 사용자 이름 칸에 잘못 입력하면 비밀번호가 그대로 기록될 수 있다. 조회 결과를 외부에 공유하기 전에 `<사용자명>`, `<IP 주소>`로 바꾼다.
{% endhint %}

## 2. 조회 명령 표

| 명령 | 읽는 파일 | 설명 | 주요 옵션 |
|---|---|---|---|
| `lastb` | `btmp` | 로그인 실패 기록을 출력한다. root 권한이 필요하다 | `-f <파일>`: 지정한 파일을 읽는다 |
| `last` | `wtmp` | 로그인 성공 기록을 출력한다 | `-f <파일>`: 지정한 파일을 읽는다 |
| `who` | `utmp` | 현재 접속한 사용자를 출력한다 | `who am i`: 현재 세션의 사용자만 출력한다 |
| `lastlog` | `lastlog` | 사용자별 마지막 로그인 시각을 출력한다 | `-u <사용자>`: 지정한 사용자만<br>`-t <일>`: 최근 N일 안에 로그인한 사용자만<br>`-b <일>`: N일보다 오래전에 로그인한 사용자만 |

## 3. 사용 예

| 목적 | 명령 | 기대 결과 |
|---|---|---|
| 로그인 실패 기록 보기 | `lastb` | 실패한 사용자, 터미널, 접속 위치, 시각이 한 줄씩 출력된다 |
| 파일을 지정해 실패 기록 보기 | `last -f /var/log/btmp` | `lastb`와 같은 결과가 나온다 |
| 현재 접속자 보기 | `who` | 사용자 이름, 터미널, 접속 시각이 출력된다 |
| 로그인 성공 기록 보기 | `last` | 로그인·재부팅 기록이 최신순으로 출력된다 |
| 전체 사용자의 마지막 로그인 보기 | `lastlog` | 사용자별로 한 줄씩 출력된다. 로그인한 적이 없으면 `**Never logged in**`이다 |
| root의 마지막 로그인 보기 | `lastlog -u root` | root 한 줄이 출력된다 |
| 최근 5일 안의 로그인 보기 | `lastlog -t 5` | 5일 안에 로그인한 사용자만 출력된다 |
| 19일보다 오래전 로그인 보기 | `lastlog -b 19` | 마지막 로그인이 19일보다 오래된 사용자만 출력된다 |

## 4. 로그를 만드는 서비스

| 서비스 | 역할 | 확인 명령 |
|---|---|---|
| `rsyslog` | 텍스트 로그(`messages`, `secure` 등)를 파일에 쓴다. 규칙은 `/etc/rsyslog.conf`와 `/etc/rsyslog.d/`에 `<facility>.<priority>  <대상>` 형식으로 쓴다 | `systemctl status rsyslog` |
| `systemd-journald` | 서비스와 커널 메시지를 저널에 모은다 | `journalctl -u <서비스 이름>`<br>`journalctl -p err -b`: 이번 부팅의 오류 이상 로그 |

{% hint style="info" %}
NOTE: 4절은 원본에 없던 보충이다. 미검증이다. RHEL 계열은 기본 설정에서 저널을 메모리에만 두므로(`Storage=auto`와 `/var/log/journal` 없음) 재부팅 후 저널이 사라질 수 있다.
{% endhint %}

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [로그 회전 관리 (Logrotate)](logrotate.md) | LNX-LOG-002-DO | 로그 파일이 회전되는 방식 |
| [로그 분석 및 보고 (Logwatch)](logwatch.md) | LNX-LOG-003-MP | 로그 요약 보고서 |
| [cron](../scripting/cron.md) | | 예약 작업 |

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 항목별 나열을 REF 형식으로 재작성. `utmp` 위치 정정, 사용 예와 `rsyslog`·`journald` 보충 추가, 사용자 정보 CAUTION 추가 |
