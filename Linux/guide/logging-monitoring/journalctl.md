# [생성형 AI] journalctl로 systemd 로그 조회

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-LOG-006-MP |
| 유형 | MP (절차) |
| 목적 | `journalctl`로 서비스, 부팅 회차, 시간대, 우선순위별 로그를 조회한다 |
| 적용 대상 | systemd를 쓰는 배포판(RHEL 계열 9, Ubuntu 26.04 등). 시스템 전체 로그는 root, sudo 또는 `systemd-journal` 그룹 권한이 필요하다 |
| 소요 시간 | 약 10분 |
| 확인 상태 | 일부 확인 (Ubuntu 26.04, systemd 259에서 `-u`, `-n`, `-p err -b`, `--disk-usage`를 실행했다. 나머지 옵션은 미검증, RHEL 계열도 미검증) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 개정 | R1 (2026-11-19) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [log_file.md](log_file.md) | LNX-LOG-001-REF | 시스템 로그 파일 분석 (/var/log) |
| [logrotate.md](logrotate.md) | LNX-LOG-002-DO | 로그 회전 관리 (Logrotate) |
| [systemctl-service.md](../operations/linux_admin/services/systemctl-service.md) | LNX-LAS-004-MP | systemd 서비스 관리 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 대상 서버 | systemd 기반 리눅스 | |
| 2 | 권한 | root, sudo 또는 `systemd-journal` 그룹 | 권한이 없으면 자기 사용자 로그만 보인다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: `--vacuum-size`, `--vacuum-time`은 저널 파일을 지운다. 지운 로그는 복구할 수 없다. 장애 분석이 끝나기 전에는 실행하지 않는다.
{% endhint %}

{% hint style="info" %}
NOTE: 출력은 `less`로 열린다. `q`로 닫는다. 파이프로 넘기거나 화면 폭을 넘는 줄을 잘리지 않게 보려면 `--no-pager`를 붙인다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 저널 용량을 확인한다: `journalctl --disk-usage` | `Archived and active journals take up ...`가 출력된다 |
| 2 | 이전 부팅 로그를 볼 수 있는지 확인한다: `journalctl --list-boots` | 부팅 회차가 둘 이상 출력되면 저널이 재부팅 후에도 남는다 |

## 5. 절차

### A. 서비스와 개수로 좁히기

1. (5-A-01) 서비스 하나의 로그를 본다: `journalctl -u <서비스>` → 결과: 그 서비스 로그가 오래된 것부터 출력된다.
2. (5-A-02) 최근 N줄만 본다: `journalctl -u <서비스> -n 20` → 결과: 마지막 20줄이 출력된다.
3. (5-A-03) 새 로그를 계속 본다: `journalctl -u <서비스> -f` → 결과: 로그가 추가될 때마다 출력된다. `Ctrl+C`로 끝낸다.
4. (5-A-04) 최신 로그를 먼저 본다: `journalctl -r` → 결과: 최신 항목이 맨 위에 출력된다.

### B. 시간과 부팅 회차로 좁히기

1. (5-B-01) 이번 부팅의 로그만 본다: `journalctl -b` → 결과: 현재 부팅 이후 로그가 출력된다.
2. (5-B-02) 직전 부팅의 로그를 본다: `journalctl -b -1` → 결과: 이전 부팅 로그가 출력된다. 저널이 재부팅 후에도 남을 때만 가능하다.
3. (5-B-03) 시각 범위를 지정한다: `journalctl --since "<YYYY-MM-DD HH:MM:SS>" --until "<YYYY-MM-DD HH:MM:SS>"` → 결과: 그 범위의 로그가 출력된다. `--since today`, `--since "1 hour ago"` 같은 표기도 쓸 수 있다.

### C. 우선순위와 종류로 좁히기

1. (5-C-01) 오류 이상만 본다: `journalctl -p err -b` → 결과: 우선순위 `err`(3) 이상인 이번 부팅 로그가 출력된다. 우선순위는 `emerg`(0), `alert`, `crit`, `err`, `warning`, `notice`, `info`, `debug`(7) 순이다.
2. (5-C-02) 커널 메시지만 본다: `journalctl -k` → 결과: `dmesg`에 해당하는 커널 로그가 출력된다.
3. (5-C-03) 줄 단위로 걸러낸다: `journalctl -u <서비스> --no-pager | grep -i <검색어>` → 결과: 검색어가 있는 줄만 출력된다.

### D. 저널 보관 설정 확인

1. (5-D-01) 보관 방식을 확인한다: `grep -E '^#?Storage' /etc/systemd/journald.conf` → 결과: `Storage=` 줄이 출력된다.
2. (5-D-02) `Storage=auto`(기본)는 `/var/log/journal` 디렉터리가 있으면 디스크에, 없으면 `/run/log/journal`(메모리, 재부팅 시 삭제)에 저장한다. 재부팅 후에도 남기려면 `Storage=persistent`로 바꾸고 `systemctl restart systemd-journald`를 입력한다. 이 절은 미검증이다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `journalctl -u <서비스> -n 5 --no-pager` | 5줄 이내의 로그가 출력된다 | 서비스 이름이 로그 줄에 나온다 |
| 2 | `journalctl -p err -b --no-pager` | 오류 로그가 출력된다 | 출력의 우선순위가 `err` 이상이다 |

## 7. 복구

이 절차는 로그를 읽기만 하므로 되돌릴 작업이 없다. 5-D-02에서 `journald.conf`를 바꿨다면 `Storage=`를 원래 값으로 돌리고 `systemctl restart systemd-journald`를 입력한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성 |
