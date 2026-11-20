# [생성형 AI] 시간 설정과 동기화 (timedatectl, chrony)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-OPS-005-REF |
| 유형 | REF (명령 표) |
| 목적 | 시스템 시각과 시간대를 조회·설정하고 NTP로 동기화하는 명령을 참조한다 |
| 확인 상태 | 일부 확인 (Ubuntu 26.04에서 `timedatectl`, `chronyc tracking`, `systemctl is-active`를 읽기 전용으로 실행했다. 시각·시간대를 바꾸는 명령은 실행하지 않아 미검증) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 시각이 어긋나면 로그의 시각 대조, 인증서 검증, Kerberos 같은 시각 의존 인증, cron 실행 시각이 틀어진다. 서버는 NTP 동기화를 켜 둔다.
{% endhint %}

## 1. timedatectl

| 목적 | 명령 | 설명 |
|---|---|---|
| 현재 상태 조회 | `timedatectl` | 현지 시각, UTC, RTC 시각, 시간대, 동기화 여부를 출력한다 |
| 시간대 목록 | `timedatectl list-timezones` | 사용 가능한 시간대 이름을 출력한다 |
| 시간대 설정 | `timedatectl set-timezone <시간대>` | 예: `Asia/Seoul`. root 권한이 필요하다 |
| NTP 동기화 켜기·끄기 | `timedatectl set-ntp <true\|false>` | 시간 동기화 서비스를 켜거나 끈다. root 권한이 필요하다 |
| 시각 직접 설정 | `timedatectl set-time "<YYYY-MM-DD HH:MM:SS>"` | NTP 동기화가 켜져 있으면 거부된다 |

`timedatectl` 출력의 주요 줄(실행 확인한 항목): `Local time`, `Universal time`, `RTC time`, `Time zone`. 동기화 상태 줄은 환경에 따라 `System clock synchronized: yes|no`, `NTP service: active|inactive`로 나타난다.

{% hint style="warning" %}
CAUTION: 시각을 직접 바꾸면 로그 순서, 인증서 유효성, 예약 작업에 영향을 준다. 운영 서버에서는 직접 설정 대신 NTP 동기화를 쓴다.
{% endhint %}

## 2. chrony

`chrony`는 NTP 클라이언트이자 서버 데몬이다. 서비스 이름은 배포판마다 다르다(Debian 계열 `chrony`, RHEL 계열 `chronyd`). 이 환경에서는 `chrony` 서비스가 `active`임을 확인했다.

| 목적 | 명령 | 설명 |
|---|---|---|
| 동기화 상태 | `chronyc tracking` | 기준 서버(Reference ID), 계층(Stratum), 기준 시각, 현재 오차를 출력한다 |
| 시간 서버 목록 | `chronyc sources -v` | 사용 중인 서버와 도달 여부를 출력한다 |
| 서비스 상태 | `systemctl status <chrony 또는 chronyd>` | 데몬 실행 여부를 본다 |
| 설정 파일 | `/etc/chrony.conf`(RHEL 계열), `/etc/chrony/chrony.conf`(Debian 계열) | `server` 또는 `pool` 줄이 시간 서버를 지정한다 |

`Stratum`은 기준 시계로부터의 거리다. 값이 작을수록 기준 시계에 가깝다(실행 확인 예: `Stratum : 3`).

{% hint style="info" %}
NOTE: `systemd-timesyncd`는 더 가벼운 SNTP 클라이언트다. 한 호스트에서 `chrony`와 `systemd-timesyncd`를 동시에 쓰지 않는다. 이 환경에서는 `systemd-timesyncd`가 비활성(`inactive`)이었고 `chrony`가 동기화를 담당했다.
{% endhint %}

## 3. 점검 순서

1. `timedatectl`로 시간대와 현재 시각을 확인한다. → 결과: 기대한 시간대와 시각이 출력된다.
2. 동기화 서비스가 실행 중인지 `systemctl is-active <서비스>`로 확인한다. → 결과: `active`.
3. `chronyc tracking`으로 기준 서버와 오차를 확인한다. → 결과: `Reference ID`가 표시되고 오차(`System time`)가 작다.
4. 어긋나 있으면 `chronyc sources -v`로 서버에 닿는지 확인하고, 방화벽이 NTP(UDP 123)를 막는지 점검한다.

## 4. 관련 문서

| Task ID | 문서 | 용도 |
|---|---|---|
| LNX-LAS-004-MP | [systemd 서비스 관리 (systemctl)](linux_admin/services/systemctl-service.md) | 서비스를 시작·상태 확인한다 |
| LNX-SCR-007-MP | [cron 작업 등록과 확인](../scripting/cron-register.md) | 시각에 의존하는 예약 작업을 확인한다 |
| LNX-LOG-006-MP | [journalctl로 systemd 로그 조회](../logging-monitoring/journalctl.md) | 동기화 로그를 조회한다 |

## 5. 약어

| 용어 | 뜻 |
|---|---|
| NTP | Network Time Protocol |
| RTC | Real-Time Clock, 메인보드의 하드웨어 시계 |
| Stratum | NTP 계층 |

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성 |
