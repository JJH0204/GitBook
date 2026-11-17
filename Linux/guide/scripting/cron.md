# 작업 예약 스케줄러 (cron)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-SCR-006-DO |
| 유형 | D&O (개념·원리) |
| 목적 | cron이 예약 작업을 읽고 실행하는 구조, 시간 필드, 실행 환경의 특징을 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 cronie, run-parts 문서 지식을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

cron은 지정한 시각이나 주기마다 명령을 자동으로 실행하는 기능이다. 데몬(서비스) 이름은 RHEL 계열에서 `crond`, Debian 계열에서 `cron`이다. 한 번만 실행할 작업은 `at` 명령을 쓴다.

등록 절차는 [cron 작업 등록과 확인](cron-register.md)(LNX-SCR-007-MP), 문법 표는 [cron 시간 문법 참조](cron-syntax.md)(LNX-SCR-008-REF)를 따른다.

## 2. 구성 요소

| 구성 요소 | 위치 | 역할 |
|---|---|---|
| `crond` / `cron` | 서비스 | 매분 예약 목록을 확인하고 시각이 맞는 작업을 실행한다 |
| 사용자 crontab | RHEL 계열 `/var/spool/cron/<사용자명>`, Debian 계열 `/var/spool/cron/crontabs/<사용자명>` | 사용자별 예약 목록. `crontab -e`로 편집하며 파일을 직접 고치지 않는다 |
| 시스템 crontab | `/etc/crontab` | 관리자가 편집하는 시스템 예약 목록 |
| 시스템 작업 디렉터리 | `/etc/cron.d/` | 패키지나 관리자가 파일 단위로 두는 예약 목록 |
| 주기별 디렉터리 | `/etc/cron.hourly`, `cron.daily`, `cron.weekly`, `cron.monthly` | 실행 가능한 스크립트를 두면 주기마다 실행한다 |
| `run-parts` | `/usr/bin/run-parts` | 디렉터리 안의 실행 가능한 파일을 순서대로 실행하는 명령 |
| `anacron` | `/etc/anacrontab` | 꺼져 있던 동안 놓친 daily/weekly/monthly 작업을 켜진 뒤 실행한다 |
| `/etc/cron.allow`, `/etc/cron.deny` | `/etc` | `crontab`을 쓸 수 있는 사용자를 제한한다 |

{% hint style="info" %}
NOTE: `run-parts`는 지정한 디렉터리의 실행 가능한 파일을 순차로 실행한다. 주기별 디렉터리에 둘 스크립트는 실행 권한이 있어야 한다. Debian 계열의 `run-parts`는 파일 이름에 영문자, 숫자, `_`, `-`만 허용하므로 `backup.sh`처럼 점이 있는 이름은 건너뛴다. 이 설명은 미검증이다.
{% endhint %}

## 3. 동작 원리

### 시간 필드

한 줄이 예약 하나다. 시간 필드는 5개이며 순서는 분, 시, 일, 월, 요일이다.

```
분 시 일 월 요일 <명령>              (사용자 crontab)
분 시 일 월 요일 <사용자> <명령>     (/etc/crontab, /etc/cron.d/*)
```

| 순서 | 필드 | 범위 |
|:---:|---|---|
| 1 | 분 | 0~59 |
| 2 | 시 | 0~23 |
| 3 | 일 | 1~31 |
| 4 | 월 | 1~12 |
| 5 | 요일 | 0~7 (0과 7은 일요일, 1=월 … 6=토) |
| 6 | 사용자 | 시스템 crontab에만 있다. 사용자 crontab에는 없다 |
| 7 | 명령 | 실행할 명령 |

원본은 사용자 필드를 모든 crontab 형식에 넣었다. 사용자 필드는 `/etc/crontab`과 `/etc/cron.d/`에만 있다. `crontab -e`로 편집하는 파일에 쓰면 사용자 이름이 명령의 일부로 해석되어 오류가 난다.

### 실행 흐름

1. `crond`가 시작될 때와 매분마다 예약 목록(사용자 crontab, `/etc/crontab`, `/etc/cron.d/`)을 읽는다.
2. 현재 시각이 시간 필드 5개와 모두 맞는 줄을 찾는다.
3. 맞는 줄의 명령을 지정한 사용자 권한의 자식 프로세스로 실행한다.
4. 명령의 출력(표준 출력, 표준 오류)이 있으면 `MAILTO` 대상에게 메일로 보낸다.
5. 실행 기록을 로그에 남긴다.

### 실행 환경

cron이 실행하는 명령은 로그인 쉘과 환경이 다르다.

| 항목 | cron 작업 | 로그인 쉘 |
|---|---|---|
| `PATH` | 최소값(보통 `/usr/bin:/bin`) | `/usr/local/bin`, `/usr/sbin` 등 포함 |
| 쉘 | `SHELL` 값, 기본 `/bin/sh` | 로그인 쉘(`bash` 등) |
| 작업 디렉터리 | 사용자의 홈 디렉터리 | 현재 위치 |
| 프로필·별칭 | `~/.bashrc`, `~/.bash_profile`, alias를 읽지 않는다 | 읽는다 |
| 출력 | 화면이 없어 메일 또는 버려진다 | 화면에 나온다 |

그래서 터미널에서는 되는데 cron에서는 `command not found`가 나는 일이 생긴다. 명령은 절대 경로로 쓰거나 crontab 맨 위에 `PATH=...`를 지정한다. 출력은 `>> <로그 파일> 2>&1`로 파일에 남긴다.

### 주기별 디렉터리의 실행 방식

RHEL 계열은 `/etc/cron.d/0hourly`가 매시 1분에 `run-parts /etc/cron.hourly`를 실행한다. `cron.daily`, `cron.weekly`, `cron.monthly`는 `anacron`이 `/etc/anacrontab`에 따라 실행한다. 이 구성은 배포판과 버전에 따라 다르다. 이 설명은 미검증이다.

### 설정 변경의 적용

`crontab -e`로 저장하거나 `/etc/cron.d/`의 파일을 바꾸면 `crond`가 변경을 감지해 다시 읽는다. 일반적으로 재시작은 필요하지 않다. 확실히 하려면 아래 명령을 쓴다. 이 설명은 미검증이다.

| 목적 | RHEL 계열 | Debian 계열 |
|---|---|---|
| 재시작 | `sudo systemctl restart crond` | `sudo systemctl restart cron` |
| 상태 확인 | `systemctl status crond` | `systemctl status cron` |

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| cron | 반복 작업 예약 서비스. 이름은 그리스어 chronos(시간)에서 왔다 |
| crontab | cron table. 예약 목록 파일 또는 그 편집 명령 |
| 데몬(daemon) | 백그라운드에서 계속 실행되는 서비스 프로세스 |
| `run-parts` | 디렉터리 안의 실행 파일을 순서대로 실행하는 명령 |
| `anacron` | 꺼져 있던 시간의 예약을 따라잡는 도구 |
| `at` | 한 번만 실행할 작업을 예약하는 명령(`atd` 데몬 필요) |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [cron-register.md](cron-register.md) | LNX-SCR-007-MP | cron 작업 등록과 확인 |
| [cron-syntax.md](cron-syntax.md) | LNX-SCR-008-REF | cron 시간 문법 참조 |
| [log_file.md](../logging-monitoring/log_file.md) | LNX-LOG-001-REF | 시스템 로그 파일 분석 (/var/log) |
| [cron 설명(외부 블로그)](https://zerostarting.tistory.com/23) | | 원본 페이지의 참고 자료 |

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `cron.md`를 D&O(본 문서), MP(LNX-SCR-007), REF(LNX-SCR-008)로 나눠 재작성. 사용자 필드가 시스템 crontab에만 있음을 정정하고 실행 환경 설명을 추가했다 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 터미널에서는 실행되는 스크립트가 cron에서는 실패하는 이유로 어떤 것이 있는가?
- [ ] 사용자 crontab과 `/etc/cron.d/`의 파일은 줄 형식이 어떻게 다르며, 왜 그렇게 다른가?
- [ ] 반복 작업을 cron으로 예약해 본 경험이 있다면 무엇이었는가?
