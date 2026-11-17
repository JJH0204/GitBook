# 로그 분석 및 보고 (Logwatch)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-LOG-003-MP |
| 목적 | `logwatch`를 설치하고 시스템 로그 요약 보고서를 화면에 출력하거나 메일로 보낸다 |
| 적용 대상 | RHEL 계열 Linux 9 (`dnf` 사용), root 권한 필요 |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 페이지와 logwatch 문서 지식을 정리한 것이며 이 문서로 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: logwatch는 지정한 기간(기본 어제 하루)의 로그를 읽어 서비스별 요약 보고서로 만든다. 로그 원본은 LNX-LOG-001-REF를 따른다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [시스템 로그 파일 분석 (/var/log)](log_file.md) | LNX-LOG-001-REF | 로그 파일 위치 |
| [로그 회전 관리 (Logrotate)](logrotate.md) | LNX-LOG-002-DO | 회전된 로그와 보고 범위 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Linux 터미널 | RHEL 계열 9 | |
| 2 | root 권한 | root 로그인 또는 `sudo` | |
| 3 | 편집기 | `vi` | |
| 4 | 메일 전송 환경 | MTA(예: `postfix`) | 구역 C(메일 전송)에서만 필요하다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 보고서에는 사용자 이름, 접속 IP, 인증 실패 내역이 들어간다. 외부 메일 주소로 보내면 이 정보가 서버 밖으로 나간다. `MailTo`에는 조직이 허용한 관리자 주소만 쓴다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | root 권한을 확인한다: `id -u` | 출력이 `0`이다 |
| 2 | 설정 파일이 있으면 백업한다: `cp /etc/logwatch/conf/logwatch.conf /etc/logwatch/conf/logwatch.conf.bak` | 파일이 없다는 오류가 나오면 백업할 내용이 없는 것이다. 다음으로 진행한다 |

## 5. 절차

### A. 설치

1. (5-A-01) 설치한다: `dnf install -y logwatch` → 결과: 설치가 완료된다.
2. (5-A-02) 설치를 확인한다: `logwatch --version` → 결과: 버전이 출력된다.
3. (5-A-03) 설정 디렉터리를 확인한다: `ls /etc/logwatch` → 결과: `conf`, `scripts` 디렉터리가 보인다.

### B. 화면 출력으로 보고서 만들기

1. (5-B-01) 보고서를 출력한다: `logwatch --output stdout` → 결과: `Logwatch`로 시작하는 머리말과 서비스별 구간이 출력된다.

출력 형태는 아래와 같다(`<…>`는 환경마다 다른 값이다).

```
 ################### Logwatch 7.5.5 (01/22/21) ####################
        Processing Initiated: <처리 시각>
        Date Range Processed: yesterday
                              ( <처리 대상 날짜> )
                              Period is day.
        Detail Level of Output: <상세 수준>
        Type of Output/Format: stdout / text
        Logfiles for Host: <호스트명>
 ##################################################################

 --------------------- Disk Space Begin ------------------------

 Filesystem           Size  Used Avail Use% Mounted on
 /dev/mapper/<볼륨>   17G  2.1G   15G  13% /
 /dev/sda1            960M  404M  557M  43% /boot

 ---------------------- Disk Space End -------------------------

 ###################### Logwatch End #########################
```

2. (5-B-02) 옵션을 바꿔 출력한다: `logwatch --detail High --range today --output stdout` → 결과: 오늘 기준의 더 자세한 보고서가 출력된다.

### C. 설정 파일로 메일 전송 지정

기본값은 `/usr/share/logwatch/default.conf/logwatch.conf`에 있다. 이 파일은 수정하지 않는다. 바꿀 값만 로컬 설정 `/etc/logwatch/conf/logwatch.conf`에 쓴다. 로컬 설정이 기본값을 덮어쓴다.

| 키 | 뜻 | 기본값 |
|---|---|---|
| `Output` | 출력 방식(`stdout`, `mail`, `file`) | `stdout` |
| `Format` | 출력 형식(`text`, `html`) | `text` |
| `MailTo` | 보고서를 받을 로컬 계정 또는 메일 주소 | `root` |
| `Detail` | 상세 수준(`Low`=0, `Med`=5, `High`=10 또는 숫자) | `Low` |

1. (5-C-01) 로컬 설정 파일을 연다: `vi /etc/logwatch/conf/logwatch.conf`
2. (5-C-02) 아래 세 줄을 쓴다.

```
Output = mail
MailTo = <관리자 메일 주소>
Detail = Med
```

3. (5-C-03) 저장하고 종료한다 → 결과: 파일이 저장된다.
4. (5-C-04) 메일 전송을 시험한다: `logwatch` → 결과: 화면 출력 없이 끝나고 `<관리자 메일 주소>`로 보고서가 도착한다.

{% hint style="info" %}
NOTE: 메일을 보내려면 서버에 MTA가 설치돼 동작해야 한다. 메일이 오지 않으면 `/var/log/maillog`에서 전송 오류를 확인한다. 일 단위 자동 실행은 `/etc/cron.daily/0logwatch`가 맡는다(미검증).
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `logwatch --output stdout` | 보고서가 출력된다 | `Logwatch`로 시작하고 `Logwatch End`로 끝난다 |
| 2 | `logwatch --detail High --output stdout` | 1번보다 항목이 많다 | `Detail Level of Output: 10` |
| 3 | `logwatch` (구역 C 설정 후) | 메일이 도착한다 | `<관리자 메일 주소>`의 받은 편지함에 보고서가 있다 |

## 7. 복구

1. (7-01) 로컬 설정을 되돌린다: `cp /etc/logwatch/conf/logwatch.conf.bak /etc/logwatch/conf/logwatch.conf` → 결과: 파일이 작업 전 상태다. 백업이 없었으면 구역 C에서 쓴 세 줄을 지운다.
2. (7-02) 제거가 필요하면 `dnf remove -y logwatch`를 실행한다 → 결과: 패키지가 삭제된다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM 형식으로 재작성. 설정 파일 발췌를 키 표로 줄이고, 원본의 개발자 연락처와 호스트명을 제거했다. 옵션 실행 단계와 복구를 추가했다 |
