# 시스템 성능 모니터링 (sysstat)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-LOG-004-MP |
| 목적 | `sysstat`을 설치하고 `sar`로 성능 통계가 수집되는지 확인한다 |
| 적용 대상 | RHEL 계열 Linux 9 (`dnf` 사용, sysstat 12.5 계열), root 권한 필요 |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 페이지와 sysstat 문서 지식을 정리한 것이며 이 문서로 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 설치와 수집 확인만 다룬다. `sar`, `iostat` 등 명령의 옵션은 LNX-LOG-005-REF를 따른다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [sar·iostat 명령 참조 (sysstat)](sysstatcommands.md) | LNX-LOG-005-REF | 명령과 옵션 표 |
| [시스템 로그 파일 분석 (/var/log)](log_file.md) | LNX-LOG-001-REF | 로그 파일 위치 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Linux 터미널 | RHEL 계열 9 | |
| 2 | root 권한 | root 로그인 또는 `sudo` | |
| 3 | 편집기 | `vi` | |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: `HISTORY` 값을 줄이거나 `SA_DIR`의 파일을 지우면 그 기간의 성능 이력이 사라져 장애 원인을 거슬러 분석할 수 없다. `HISTORY`는 28보다 크게 설정할 때 `SADC_OPTIONS`에 `-D`가 필요하다. 설정 파일에 같은 설명이 주석으로 있다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | root 권한을 확인한다: `id -u` | 출력이 `0`이다 |
| 2 | 설정 파일을 설치 후 백업한다(구역 A 뒤에 실행): `cp /etc/sysconfig/sysstat /etc/sysconfig/sysstat.bak` | `ls /etc/sysconfig/sysstat.bak`가 파일을 보여 준다 |

## 5. 절차

### A. 설치와 시작

1. (5-A-01) 설치한다: `dnf install -y sysstat` → 결과: 설치가 완료된다.
2. (5-A-02) 서비스를 시작한다: `systemctl start sysstat` → 결과: 오류 없이 끝난다.
3. (5-A-03) 부팅 때 자동 시작하게 한다: `systemctl enable sysstat` → 결과: `Created symlink`로 시작하는 줄이 출력된다.
4. (5-A-04) 상태를 확인한다: `systemctl status sysstat` → 결과: `Active: active (exited)`가 보인다.

### B. 설정 확인

설정 파일은 `/etc/sysconfig/sysstat`이다. 주요 키는 아래와 같다.

| 키 | 기본값(예) | 뜻 |
|---|---|---|
| `HISTORY` | `28` | 통계 파일을 보관하는 일수 |
| `COMPRESSAFTER` | `31` | 이 일수가 지난 파일을 압축한다 |
| `SADC_OPTIONS` | `-S DISK` | 수집기 `sadc`의 옵션. `-S DISK`는 디스크 통계도 수집한다 |
| `SA_DIR` | `/var/log/sa` | 통계 파일 저장 디렉터리. 미리 있어야 한다 |
| `ZIP` | `xz` | 압축 프로그램 |
| `DELAY_RANGE` | `0` | 요약 작성 전 무작위 지연(초) 상한 |
| `UMASK` | `0022` | 통계 파일의 생성 권한. 엄격히 하려면 `0027`을 쓴다 |

1. (5-B-01) 설정 파일을 연다: `vi /etc/sysconfig/sysstat`
2. (5-B-02) 값을 확인한다. 바꿀 필요가 없으면 수정하지 않고 종료한다: `:q`
3. (5-B-03) 저장 디렉터리를 확인한다: `ls /var/log/sa` → 결과: 디렉터리가 있다. 수집이 시작되기 전에는 비어 있을 수 있다.

{% hint style="info" %}
NOTE: 수집 주기는 `sysstat-collect.timer`가 정한다(기본 10분 간격, 미검증). 파일 `saDD`(DD는 일)는 첫 수집 뒤에 생긴다. 확인 전에 수 분에서 10분 정도 기다린다.
{% endhint %}

### C. 수집 확인

1. (5-C-01) 1초 간격으로 3회 측정한다: `sar 1 3` → 결과: CPU 사용률 3줄과 `Average:` 줄이 출력된다.
2. (5-C-02) 평균 줄만 추출한다: `sar 1 3 | grep Average` → 결과: `Average:` 한 줄만 출력된다.
3. (5-C-03) 필드를 추출한다: `sar 1 3 | awk '/Average/ {print $8}'` → 결과: `%idle` 값 한 개가 출력된다.

`sar 1 3`의 출력 형태는 아래와 같다.

```
Linux <커널 버전> (<호스트명>)     <날짜>      _x86_64_        (1 CPU)

<시각>     CPU     %user     %nice   %system   %iowait    %steal     %idle
<시각>     all      0.00      0.00      0.00      0.00      0.00    100.00
<시각>     all      0.00      0.00      1.00      0.00      0.00     99.00
<시각>     all      0.00      0.00      1.00      0.00      0.00     99.00
Average:   all      0.00      0.00      0.67      0.00      0.00     99.33
```

4. (5-C-04) 저장된 통계 파일을 확인한다: `ls /var/log/sa` → 결과: `sa<일>` 파일이 보인다(첫 수집 이후).

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `systemctl is-enabled sysstat` | 자동 시작이 켜져 있다 | `enabled` |
| 2 | `sar 1 3` | CPU 사용률이 출력된다 | `Average:` 줄이 나온다 |
| 3 | `ls /var/log/sa` | 통계 파일이 있다 | `sa<일>` 파일이 1개 이상 |

## 7. 복구

1. (7-01) 설정을 되돌린다: `cp /etc/sysconfig/sysstat.bak /etc/sysconfig/sysstat` → 결과: 파일이 작업 전 상태다.
2. (7-02) 수집을 끈다: `systemctl disable --now sysstat` → 결과: 서비스가 멈추고 자동 시작이 꺼진다.
3. (7-03) 제거가 필요하면 `dnf remove -y sysstat`를 실행한다. `/var/log/sa`의 기존 통계는 남는다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM 형식으로 재작성. 설정 파일 전문을 키 표로 줄이고, 호스트명·커널 정보를 일반화했다. 상태 확인과 복구를 추가했다. 명령 설명은 LNX-LOG-005-REF로 분리했다 |
