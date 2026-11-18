# cron 작업 등록과 확인

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-SCR-007-MP |
| 목적 | 5분마다 시각을 파일에 기록하는 작업을 사용자 crontab과 `/etc/cron.d/`에 등록하고, 실행 로그로 동작을 확인한 뒤 제거한다 |
| 적용 대상 | RHEL 계열 9(`crond`) 기준. Debian 계열은 차이를 각 단계에 적었다. 구역 D는 `sudo` 권한이 필요하다 |
| 소요 시간 | 약 20분 (실행 확인 대기 10분 포함) |
| 확인 상태 | 미검증 (원본 페이지와 cronie 문서 지식을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [cron.md](cron.md) | LNX-SCR-006-DO | 작업 예약 스케줄러 (cron) |
| [cron-syntax.md](cron-syntax.md) | LNX-SCR-008-REF | cron 시간 문법 참조 |
| [shell-script-practice.md](shell-script-practice.md) | LNX-SCR-003-MP | 쉘 스크립트 작성과 실행 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 터미널 | bash | |
| 2 | cron 서비스 | `crond`(RHEL 계열) 또는 `cron`(Debian 계열) | 5-A에서 확인한다 |
| 3 | `sudo` 권한 | | 구역 A의 상태 확인, 구역 C의 로그 확인, 구역 D에서 사용 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: cron에 등록한 작업은 사용자가 제거할 때까지 계속 반복 실행된다. 이 문서의 작업은 로그 파일에 한 줄씩 덧붙이므로 방치하면 파일이 커진다. 확인이 끝나면 7절로 반드시 제거한다.
{% endhint %}

{% hint style="info" %}
NOTE: 실제 업무에서 삭제나 덮어쓰기를 하는 스크립트를 cron에 등록하기 전에는 같은 명령을 수동으로 실행해 대상을 확인한다. 삭제 명령은 반복 실행되어 복구할 수 없다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 현재 사용자 이름을 확인한다 | `whoami`가 사용자 이름을 출력한다. 이 문서에서 `<사용자>`로 쓴다 |
| 2 | 현재 시각과 시간대를 확인한다 | `date`가 현재 시각을 출력한다. cron은 시스템 시간대를 따른다 |
| 3 | 기존 crontab 내용을 확인한다 | `crontab -l`을 실행한다. 이미 등록된 줄이 있으면 메모해 둔다 |

## 5. 절차

### A. cron 서비스 확인

1. (5-A-01) 서비스 상태를 확인한다: `systemctl status crond` (Debian 계열: `systemctl status cron`) → 결과: `Active: active (running)`이 보인다.
2. (5-A-02) 실행 중이 아니면 시작한다: `sudo systemctl enable --now crond` (Debian 계열: `cron`) → 결과: 5-A-01을 다시 실행하면 `active (running)`이다.

### B. 실행할 스크립트 작성

1. (5-B-01) 디렉터리를 만든다: `mkdir -p ~/shell-lab` → 결과: 오류 없이 끝난다.
2. (5-B-02) 스크립트를 작성한다.

```bash
cat > ~/shell-lab/heartbeat.sh <<'EOF2'
#!/bin/bash
echo "$(/usr/bin/date '+%F %T') alive" >> "$HOME/shell-lab/heartbeat.log"
EOF2
```

→ 결과: `~/shell-lab/heartbeat.sh`가 생긴다.

3. (5-B-03) 실행 권한을 준다: `chmod +x ~/shell-lab/heartbeat.sh` → 결과: `ls -l ~/shell-lab/heartbeat.sh`의 권한 열에 `x`가 보인다.
4. (5-B-04) 수동으로 실행한다: `~/shell-lab/heartbeat.sh; cat ~/shell-lab/heartbeat.log` → 결과: `<날짜> <시각> alive` 한 줄이 출력된다.

### C. 사용자 crontab에 등록

1. (5-C-01) crontab 편집기를 연다: `crontab -e` → 결과: 편집기가 열린다. 처음이면 편집기 선택을 묻는다.
2. (5-C-02) 맨 아래에 두 줄을 추가한다. `<사용자>`는 홈 디렉터리 경로의 사용자 이름이다.

```
PATH=/usr/local/bin:/usr/bin:/bin
*/5 * * * * /home/<사용자>/shell-lab/heartbeat.sh
```

→ 결과: 편집기에 두 줄이 보인다. 사용자 이름 필드는 쓰지 않는다.

3. (5-C-03) 저장하고 종료한다 → 결과: `crontab: installing new crontab`(환경에 따라 생략)이 출력된다.
4. (5-C-04) 등록 내용을 확인한다: `crontab -l` → 결과: 5-C-02의 두 줄이 출력된다.

{% hint style="info" %}
NOTE: 홈 디렉터리 경로는 `echo $HOME`으로 확인한다. crontab에서는 `~`와 `$HOME`이 환경에 따라 기대와 다르게 풀릴 수 있어 절대 경로를 쓴다. 명령 안의 `%`는 줄바꿈으로 해석되므로 `\%`로 쓴다.
{% endhint %}

### D. 시스템 작업으로 등록 (`/etc/cron.d`, 선택)

구역 C의 사용자 crontab 등록과 같은 일을 하는 다른 방법이다. 두 방법을 모두 하면 작업이 이중으로 실행된다. 구역 D를 하려면 먼저 7-01로 구역 C의 등록을 제거한다.

1. (5-D-01) 파일을 만든다.

```bash
sudo tee /etc/cron.d/heartbeat <<'EOF2'
PATH=/usr/local/bin:/usr/bin:/bin
*/5 * * * * <사용자> /home/<사용자>/shell-lab/heartbeat.sh
EOF2
```

→ 결과: 입력한 두 줄이 화면에 출력된다. 이번에는 시간 필드 뒤에 사용자 이름 필드를 쓴다.

2. (5-D-02) 소유자와 권한을 확인한다: `ls -l /etc/cron.d/heartbeat` → 결과: 소유자가 `root`이고 다른 사용자가 쓸 수 없다(`-rw-r--r--`).

{% hint style="info" %}
NOTE: `/etc/cron.d/`의 파일 이름에 점(`.`)을 쓰지 않는다. Debian 계열의 cron은 점이 있는 이름을 무시한다. 파일은 root 소유여야 하고 일반 사용자가 쓸 수 있으면 무시될 수 있다.
{% endhint %}

### E. 실행 로그 확인

1. (5-E-01) 다음 5분 배수 시각(예: 10:05, 10:10)까지 기다린다 → 결과: 현재 분이 0, 5, 10 … 중 하나를 지난다.
2. (5-E-02) 작업 결과 파일을 확인한다: `cat ~/shell-lab/heartbeat.log` → 결과: 5분 간격의 시각 줄이 추가돼 있다.
3. (5-E-03) cron 실행 기록을 확인한다. RHEL 계열: `sudo grep heartbeat /var/log/cron`. Debian 계열: `sudo grep CRON /var/log/syslog` 또는 `journalctl -u cron` → 결과: `CMD (/home/<사용자>/shell-lab/heartbeat.sh)` 줄이 있다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `systemctl is-active crond` (Debian 계열: `cron`) | `active` | 출력이 `active`다 |
| 2 | `crontab -l` (구역 C 사용 시) | 5-C-02의 두 줄 | 줄이 일치한다 |
| 3 | `wc -l < ~/shell-lab/heartbeat.log` | 줄 수 | 10분 대기 후 3줄 이상(수동 실행 1줄 + cron 2회 이상)이다 |
| 4 | cron 로그 | `CMD (...heartbeat.sh)` | 5분 간격으로 기록이 있다 |

{% hint style="info" %}
NOTE: 로그에 기록이 없으면 다음을 확인한다. 스크립트에 실행 권한이 있는가, crontab의 경로가 절대 경로인가, 파일 마지막 줄 끝에 줄바꿈이 있는가, 시간 필드 순서가 분 시 일 월 요일인가. 출력은 `>> 파일 2>&1`로 리디렉션하지 않으면 메일로 가거나 사라진다.
{% endhint %}

## 7. 복구

1. (7-01) 구역 C에서 등록했으면 제거한다: `crontab -e`로 열어 5-C-02의 두 줄을 삭제하고 저장한다 → 결과: `crontab -l`에 두 줄이 없다.

{% hint style="danger" %}
WARNING: `crontab -r`은 확인 없이 그 사용자의 crontab 전체를 삭제한다. 다른 예약이 있으면 함께 사라지므로 이 문서에서는 쓰지 않는다. 4절에서 메모한 기존 줄이 있다면 7-01 뒤에 남아 있는지 확인한다.
{% endhint %}

2. (7-02) 구역 D에서 등록했으면 제거한다: `sudo rm /etc/cron.d/heartbeat` → 결과: `ls /etc/cron.d/heartbeat`가 `No such file or directory`를 출력한다.
3. (7-03) 시험 파일을 지운다: `rm ~/shell-lab/heartbeat.sh ~/shell-lab/heartbeat.log` → 결과: 두 파일이 없다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `cron.md`의 예제와 서비스 제어를 등록·확인 절차로 재작성. 사용자 crontab과 시스템 crontab의 줄 형식 차이, 로그 확인, 제거 절차를 추가했다 |
