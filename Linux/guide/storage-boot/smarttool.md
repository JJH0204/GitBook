# 스마트몬툴즈 디스크 점검 도구

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-STB-002-REF |
| 유형 | REF (명령 표) |
| 목적 | `smartctl`의 주요 옵션과 출력 예시를 찾아본다 |
| 확인 상태 | 미검증 (원본 페이지의 `smartctl -h` 출력과 smartmontools 일반 지식을 정리한 것이다) |
| 개정 | R1 (2026-11-18) |

smartmontools는 디스크의 SMART(Self-Monitoring, Analysis and Reporting Technology) 정보를 읽는 도구 모음이다. 명령줄 도구는 `smartctl`이다. 실제 점검 순서는 [smartctl 디스크 상태 점검](smartctl-check.md)(LNX-STB-003-MP)을 따른다.

## 1. 설치

| 배포판 계열 | 명령 |
|---|---|
| RHEL 계열 | `dnf install -y smartmontools` |
| Debian 계열 | `apt install smartmontools` (미검증) |

## 2. 주요 옵션

사용 형식은 `smartctl [옵션] <장치>`다. 예: `smartctl -H /dev/sda`.

| 옵션 | 긴 옵션 | 동작 |
|---|---|---|
| `-i` | `--info` | 장치 식별 정보(모델, 시리얼, 용량)를 표시한다 |
| `-H` | `--health` | SMART 건강 상태(PASSED/FAILED)를 표시한다 |
| `-a` | `--all` | 장치의 모든 SMART 정보를 표시한다 |
| `-x` | `--xall` | 모든 정보를 더 자세히 표시한다 |
| `-A` | `--attributes` | 제조사별 SMART 속성과 값을 표시한다 |
| `-c` | `--capabilities` | SMART 기능 목록을 표시한다 (ATA, NVMe) |
| `-l <종류>` | `--log=<종류>` | 장치 로그를 표시한다. 예: `error`, `selftest` |
| `-t <종류>` | `--test=<종류>` | 자체 점검을 시작한다. 예: `short`, `long`, `offline`, `conveyance` |
| `-X` | `--abort` | 진행 중인 비캡티브 점검을 중단한다 |
| `-s on\|off` | `--smart=on\|off` | 장치의 SMART 기능을 켜거나 끈다 |
| `-d <종류>` | `--device=<종류>` | 장치 유형을 지정한다. 예: `ata`, `scsi`, `nvme`, `sat`, `megaraid,N` |
| | `--scan` | 장치를 검색한다 |
| `-j` | `--json` | 출력을 JSON 형식으로 낸다 |
| `-V` | `--version` | 버전과 라이선스를 표시한다 |
| `-h` | `--help` | 도움말을 표시한다 |

## 3. 사용 예

| 목적 | 명령 |
|---|---|
| 장치 검색 | `smartctl --scan` |
| 식별 정보 | `smartctl -i /dev/sda` |
| 건강 상태 | `smartctl -H /dev/sda` |
| 전체 정보 | `smartctl -a /dev/sda` |
| 짧은 자체 점검 | `smartctl -t short /dev/sda` |
| 긴 자체 점검 | `smartctl -t long /dev/sda` |
| 점검 결과 로그 | `smartctl -l selftest /dev/sda` |
| 속성과 점검 오류만 | `smartctl --attributes --log=selftest --quietmode=errorsonly /dev/sda` |

## 4. 출력 예시

원본 페이지의 가상 머신(VirtualBox) 디스크 출력이다. 일련번호는 `<시리얼>`로 바꿨다.

```
smartctl --scan
/dev/sda -d scsi # /dev/sda, SCSI device
```

```
smartctl -i /dev/sda
=== START OF INFORMATION SECTION ===
Device Model:     VBOX HARDDISK
Serial Number:    <시리얼>
Firmware Version: 1.0
User Capacity:    21,474,836,480 bytes [21.4 GB]
Sector Size:      512 bytes logical/physical
SMART support is: Unavailable - device lacks SMART capability.
```

```
smartctl --all /dev/sda
...
SMART support is: Unavailable - device lacks SMART capability.

A mandatory SMART command failed: exiting. To continue, add one or more '-T permissive' options.
```

{% hint style="info" %}
NOTE: 가상 디스크는 SMART를 지원하지 않아 `-a`가 위처럼 실패한다. 실제 디스크에서는 건강 상태, 속성 표, 로그가 출력된다.
{% endhint %}

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [smartctl 디스크 상태 점검](smartctl-check.md) | LNX-STB-003-MP | 점검 절차 |
