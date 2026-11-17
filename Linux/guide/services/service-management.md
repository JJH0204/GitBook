# 불필요한 서비스 관리 및 비활성화

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-SVC-002-MP |
| 목적 | 사용하지 않는 서비스, autofs, cron, at를 점검하고 비활성화하거나 접근을 제한해 공격 표면을 줄인다 |
| 적용 대상 | RHEL 계열 9, root 또는 sudo 권한 |
| 소요 시간 | 약 30분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 사용하지 않는 서비스와 프로토콜을 지우거나 끄는 것이 기본이다. 대표 대상은 `nfs-server`, `tftp`, `telnet`이다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [remote-access-management.md](../network-remote/remote-access-management.md) | LNX-NRM-002-MP | 원격 접속 관리 |
| [permissionchange.md](../accounts-permissions/permissionchange.md) | LNX-ACC-010-MP | 파일 권한 변경 |
| [logrotate.md](../logging-monitoring/logrotate.md) | LNX-LOG-002-DO | 로그 회전 관리 (`systemctl` 사용 예) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 대상 서버 | RHEL 계열 9 | |
| 2 | 콘솔 접근 | 가상 머신 화면 또는 물리 콘솔 | |
| 3 | 서비스 사용 현황 목록 | 서버에서 실제 쓰는 서비스 이름 | 비활성화 전 대조용 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 사용 중인 서비스를 중지하거나 제거하면 그 서비스에 의존하는 업무가 중단된다. SSH 서비스(`sshd`)를 중지하면 원격 접속이 끊긴다. 대상 서비스가 사용 중이 아님을 확인한 뒤 수행하고, 콘솔 접근을 확보한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 불필요한 서비스가 켜져 있으면 원격 공격자가 접근할 수 있는 공격 표면이 늘어난다. 사용하지 않는 서비스는 제거하거나 비활성화한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 이 서버에서 쓰는 서비스 목록을 정한다 | 서비스 이름 목록이 있다 |
| 2 | 콘솔에 로그인할 수 있다 | 로그인 프롬프트가 보인다 |
| 3 | 현재 실행 중인 서비스를 저장한다: `systemctl list-units --type=service --state=running > <백업 파일 경로>` | 파일이 만들어진다 |

## 5. 절차

### A. 실행 중인 서비스 점검

1. (5-A-01) 실행 중인 프로세스를 확인한다: `ps -ef` → 결과: 프로세스 목록이 출력된다.
2. (5-A-02) 서비스 단위로 확인한다: `systemctl list-units --type=service --state=running` → 결과: 실행 중인 서비스가 출력된다.
3. (5-A-03) 부팅 시 켜지는 서비스를 확인한다: `systemctl list-unit-files --type=service --state=enabled` → 결과: 자동 시작 서비스가 출력된다.

### B. 불필요한 서비스 비활성화

1. (5-B-01) `nfs-server`의 설정 파일 권한을 확인한다: `ls -l /etc/exports` → 결과: 파일 권한과 소유자가 출력된다. 이 파일은 필요한 계정만 읽고 쓸 수 있어야 한다.
2. (5-B-02) 사용하지 않는 서비스를 중지하고 자동 시작을 해제한다: `systemctl disable --now <서비스 이름>` (예: `nfs-server`) → 결과: `Removed ...` 메시지가 출력된다.
3. (5-B-03) 패키지가 필요 없으면 제거한다: `dnf remove -y <패키지 이름>` (예: `tftp-server`, `telnet-server`) → 결과: `Complete!`가 출력된다.

### C. autofs 점검

autofs(자동 마운트)가 있으면 로컬 공격자가 원하는 장치를 언제든 연결할 수 있어 서버가 취약해진다.

1. (5-C-01) 설치 여부를 확인한다: `rpm -qa | grep autofs` → 결과: 설치돼 있으면 패키지명이 출력되고, 없으면 출력이 없다.
2. (5-C-02) 설치돼 있으면 비활성화한다: `systemctl disable --now autofs` → 결과: 오류 없이 끝난다. 삭제하려면 `dnf remove -y autofs`를 입력한다.

### D. cron 접근 제한

cron 관련 파일을 수정할 수 있는 권한이 있으면 서버가 취약해진다. 일반 사용자도 `crontab`을 쓸 수 있으므로 권한을 확인한다.

1. (5-D-01) `crontab` 명령의 권한을 확인한다: `ls -l /usr/bin/crontab` → 결과: 권한 문자열이 출력된다.
2. (5-D-02) 기타 사용자(other)의 실행 권한을 제거한다: `chmod o-x /usr/bin/crontab` → 결과: `ls -l /usr/bin/crontab`에서 마지막 권한 글자의 `x`가 없다. 실행 권한을 다시 주려면 `o+x`를 쓴다.
3. (5-D-03) 특정 사용자만 막을 때는 `/etc/cron.deny` 파일에 사용자 이름을 한 줄에 하나씩 적는다: `vi /etc/cron.deny` → 결과: 파일에 해당 이름이 있다. 이 파일은 기타 사용자가 `crontab`을 쓸 수 있는 상태에서 특정 사용자의 권한을 제거할 때 쓴다.

### E. at 접근 제한

`at`는 한 번만 실행할 작업을 예약한다. cron처럼 관리자 권한을 조절하거나 내부 권한을 조정해 관리한다.

1. (5-E-01) 차단 사용자 파일을 확인한다: `ls -l /etc/at.deny` → 결과: 차단 사용자를 등록하는 파일이 보인다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `systemctl is-enabled <서비스 이름>` | 비활성화됐다 | `disabled` |
| 2 | `systemctl is-active <서비스 이름>` | 중지됐다 | `inactive` |
| 3 | `rpm -qa \| grep autofs` | 출력이 없거나 서비스가 꺼져 있다 | 설치 안 됨 또는 `inactive` |
| 4 | 일반 사용자로 `crontab -l` | 실행이 거부된다 | `Permission denied` |
| 5 | 서버가 쓰는 서비스 접속 시험 | 정상이다 | 5-A-02의 필요한 서비스가 그대로 실행 중이다 |

## 7. 복구

1. (7-01) 서비스를 다시 켠다: `systemctl enable --now <서비스 이름>`
2. (7-02) 제거한 패키지를 다시 설치한다: `dnf install -y <패키지 이름>`
3. (7-03) `crontab` 권한을 되돌린다: `chmod o+x /usr/bin/crontab`
4. (7-04) `/etc/cron.deny`에서 추가한 사용자 줄을 지운다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 메모 형식이던 원본을 MP 형식으로 재작성. 서비스 중단 WARNING, 확인과 복구 절차를 추가했다. 원본의 `Remote Access Management` 소제목은 이 문서의 주제와 달라 삭제했다. `systemctl` 명령(5-A-02, 5-A-03, 5-B-02)은 원본에 없던 내용이다 |
