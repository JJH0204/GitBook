# smartctl 디스크 상태 점검

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-STB-003-MP |
| 목적 | `smartctl`로 디스크의 SMART 건강 상태를 확인하고 자체 점검을 실행한다 |
| 적용 대상 | RHEL 계열 리눅스(`dnf` 사용), smartmontools 7.x, 물리 디스크 또는 SMART를 지원하는 장치 |
| 소요 시간 | 설치와 건강 확인 약 5분, 짧은 자체 점검은 장치마다 다르며 보통 수 분 |
| 확인 상태 | 미검증 (원본 페이지와 smartmontools 일반 지식을 정리한 것이며 직접 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [스마트몬툴즈 디스크 점검 도구](smarttool.md) | LNX-STB-002-REF | `smartctl` 옵션 표 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 관리자 권한 | root 또는 `sudo` | 장치 파일에 접근한다 |
| 2 | smartmontools | 7.x | 4절에서 설치 |
| 3 | 점검할 디스크 | `/dev/sda` 등 | 가상 디스크는 SMART를 지원하지 않는다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: `-t long` 점검은 수 시간 걸리고 점검 중 디스크 성능이 떨어질 수 있다. 부하가 큰 서비스가 있는 시간대를 피한다.
{% endhint %}

{% hint style="info" %}
NOTE: 이 절차는 읽기와 자체 점검만 한다. 데이터를 바꾸지 않는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | smartmontools를 설치한다: `dnf install -y smartmontools` | 오류 없이 끝난다 |
| 2 | 버전을 확인한다: `smartctl -V` | 버전 7.x가 출력된다 |

## 5. 절차

### A. 장치 확인

1. (5-A-01) 장치를 검색한다: `smartctl --scan` → 결과: `/dev/sda -d scsi # /dev/sda, SCSI device` 형태의 행이 보인다.
2. (5-A-02) 식별 정보를 확인한다: `smartctl -i /dev/sda` → 결과: `Device Model`, `Serial Number`, `User Capacity`가 출력된다.
3. (5-A-03) `SMART support is:` 행을 확인한다. → 결과: `Available`과 `Enabled`면 5-B로 진행한다. `Unavailable`이면 이 디스크는 점검할 수 없다. 작업을 끝낸다.

### B. 건강 상태 확인

1. (5-B-01) 건강 상태를 확인한다: `smartctl -H /dev/sda` → 결과: `SMART overall-health self-assessment test result: PASSED`가 출력된다.
2. (5-B-02) 전체 정보를 확인한다: `smartctl -a /dev/sda` → 결과: 속성 표와 로그가 출력된다.

### C. 자체 점검 실행

1. (5-C-01) 짧은 자체 점검을 시작한다: `smartctl -t short /dev/sda` → 결과: 점검 종료 예상 시각이 출력된다.
2. (5-C-02) 예상 시각까지 기다린다.
3. (5-C-03) 점검 결과를 확인한다: `smartctl -l selftest /dev/sda` → 결과: 최근 점검 행의 상태가 `Completed without error`다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `smartctl -H /dev/sda` | 건강 상태 출력 | `PASSED` |
| 2 | `smartctl -l selftest /dev/sda` | 자체 점검 로그 | `Completed without error` |

`FAILED`가 나오면 디스크가 고장 났을 가능성이 크다. 즉시 데이터를 다른 장치로 백업한다.

## 7. 복구

이 절차는 설정을 바꾸지 않는다. 진행 중인 점검을 멈추려면 `smartctl -X /dev/sda`를 실행한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | `smarttool.md`의 사용 예를 분리해 AMM 형식 절차로 작성 |
