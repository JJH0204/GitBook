# 로그 회전 관리 (Logrotate)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-LOG-002-DO |
| 유형 | D&O (개념·원리) |
| 목적 | logrotate의 구성 요소, 실행 방식, 주요 지시자를 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 man 문서 지식을 정리한 것이며 직접 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

로그 파일은 계속 커져 디스크를 채운다. logrotate는 로그를 주기적으로 이름을 바꿔 보관하고, 새 파일을 만들고, 오래된 파일을 지운다. 이 과정을 회전(rotate)이라 한다.

{% hint style="warning" %}
CAUTION: `rotate` 개수를 넘은 옛 로그는 자동으로 삭제된다. 보존 기간을 줄이거나 설정을 잘못 바꾸면 감사 증적이 사라진다. 보존 기간은 조직의 로그 보존 정책을 확인한 뒤 정한다.
{% endhint %}

## 2. 구성 요소

| 구성 요소 | 위치 | 역할 |
|---|---|---|
| `logrotate` | `/usr/sbin/logrotate` | 회전을 실행하는 프로그램 |
| `logrotate.timer` | `/usr/lib/systemd/system/logrotate.timer` | 매일 `logrotate.service`를 깨우는 타이머 |
| `logrotate.service` | `/usr/lib/systemd/system/logrotate.service` | `logrotate /etc/logrotate.conf`를 한 번 실행한다 |
| 전역 설정 | `/etc/logrotate.conf` | 모든 로그의 기본값. `include /etc/logrotate.d`로 개별 설정을 읽는다 |
| 개별 설정 | `/etc/logrotate.d/<이름>` | 로그 파일별 규칙. 패키지가 설치할 때 함께 놓는다 |

`logrotate.service`는 한 번 실행하고 종료한다. 평소 상태가 `inactive (dead)`인 것이 정상이다. 동작 여부는 `logrotate.timer`의 `active (waiting)`으로 판단한다.

## 3. 동작 원리

### 실행 흐름

1. `logrotate.timer`가 `OnCalendar=daily`(매일 00:00)에 맞춰 `logrotate.service`를 시작한다.
2. 서비스가 `logrotate /etc/logrotate.conf`를 실행한다.
3. `logrotate.conf`가 전역 기본값을 적용하고 `/etc/logrotate.d/`의 파일을 읽는다.
4. 각 로그에 대해 주기와 조건을 검사하고, 해당되면 회전한다.

타이머 유닛의 핵심 항목은 아래와 같다.

| 항목 | 값 | 뜻 |
|---|---|---|
| `OnCalendar` | `daily` | 매일 00:00에 실행한다 |
| `AccuracySec` | `1h` | 실행 시각이 최대 1시간 어긋날 수 있다 |
| `Persistent` | `true` | 시스템이 꺼져 있어 놓친 실행을 켜진 뒤에 한 번 수행한다 |

타이머가 매일 깨워도 각 로그의 회전 여부는 설정의 주기(`weekly` 등)가 정한다.

### 전역 설정 `/etc/logrotate.conf` 예

```
weekly
rotate 4
create
dateext
#compress
include /etc/logrotate.d
```

### 주요 지시자

| 지시자 | 뜻 |
|---|---|
| `daily` / `weekly` / `monthly` / `yearly` | 회전 주기 |
| `rotate <N>` | 보관할 회전 파일 수. 개수를 넘은 가장 오래된 파일은 삭제한다 |
| `create [<모드> <사용자> <그룹>]` | 회전 후 새 빈 로그 파일을 만든다 |
| `dateext` | 회전 파일 이름에 날짜를 붙인다 (`messages-20240920`) |
| `dateyesterday` | `dateext`의 날짜를 어제 날짜로 쓴다 |
| `compress` | 회전 파일을 압축한다 |
| `missingok` | 로그 파일이 없어도 오류로 처리하지 않는다 |
| `notifempty` | 로그가 비어 있으면 회전하지 않는다 |
| `copytruncate` | 로그 파일을 복사한 뒤 원본을 비운다. 파일을 닫았다 다시 열 수 없는 프로그램에 쓴다. 복사와 비우기 사이에 쓰인 로그는 유실될 수 있다 |
| `su <사용자> <그룹>` | 지정한 사용자와 그룹 권한으로 회전한다 |
| `sharedscripts` | 패턴에 여러 파일이 걸려도 스크립트를 한 번만 실행한다 |
| `postrotate` ~ `endscript` | 회전 뒤에 실행할 명령 |

### 개별 설정 `/etc/logrotate.d/` 예

`/etc/logrotate.d/`에는 `btmp`, `chrony`, `dnf`, `firewalld`, `rsyslog`, `samba`, `sssd`, `wtmp` 등의 파일이 있다. 아래는 일반적인 형태를 보이는 예시다.

```
/var/log/<서비스>.log
{
    missingok
    daily
    rotate 7
    notifempty
    copytruncate
    su <사용자> <그룹>
    sharedscripts
    postrotate
        /bin/systemctl reload <서비스>.service > /dev/null 2>&1 || true
    endscript
}
```

설정 문법과 동작은 시험 실행으로 확인한다. `-d`는 실제로 회전하지 않고 계획만 출력한다.

```bash
logrotate -d /etc/logrotate.conf
```

{% hint style="warning" %}
CAUTION: `logrotate -f`(강제 회전)는 주기와 무관하게 즉시 회전하고 `rotate` 개수를 넘은 파일을 삭제한다. 보존이 필요한 로그가 있는 서버에서 실행하지 않는다.
{% endhint %}

### 상태 확인

```bash
systemctl status logrotate.timer
systemctl list-timers logrotate.timer
```

`Active: active (waiting)`이고 `Trigger:`에 다음 실행 시각이 나오면 정상이다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| rotate | 로그 파일 이름을 바꿔 보관하고 새 파일로 교체하는 일 |
| timer unit | 정해진 시각에 서비스를 시작하는 systemd 유닛 |
| `copytruncate` | 복사 후 원본을 비우는 회전 방식 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [시스템 로그 파일 분석 (/var/log)](log_file.md) | LNX-LOG-001-REF | 회전 대상 로그 파일 |
| [서비스 관리](../services/service-management.md) | | `systemctl` 사용법 |

## 6. 원본 정정 내역

| 원본 | 정정 |
|---|---|
| `monthry` | `monthly` |
| `dayeyesterday` | `dateyesterday` |
| `su 사용자 그룹` | `su <사용자> <그룹>` |
| `copytruncate` 2회 | 1회로 정리하고 "복사 후 원본을 비운다"로 정정(원본의 "복사 후 순환"은 부정확) |
| 예시의 `httpd` reload | `<서비스>`로 일반화(`boot.log` 설정과 무관한 예였다) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 로그를 회전하지 않으면 서버에 어떤 문제가 생길까?
- [ ] `weekly`와 `rotate 4`를 함께 쓰면 로그가 얼마나 오래 남는지 설명해 보자.
- [ ] 서비스가 로그 파일을 계속 열어 두고 있을 때 `copytruncate`를 쓰는 이유는 무엇일까?
