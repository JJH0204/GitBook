# [생성형 AI] systemd 서비스 관리 (systemctl)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-LAS-004-MP |
| 유형 | MP (절차) |
| 목적 | `systemctl`로 서비스의 상태를 확인하고 시작, 중지, 재시작하고 부팅 시 자동 시작을 설정한다 |
| 적용 대상 | systemd를 쓰는 배포판(RHEL 계열 9, Ubuntu 26.04 등), root 또는 sudo 권한 |
| 소요 시간 | 약 15분 |
| 확인 상태 | 일부 확인 (Ubuntu 26.04, systemd 259에서 읽기 전용 명령 `status`, `is-active`, `cat`, `list-unit-files`를 실행했다. 상태를 바꾸는 명령은 실행하지 않았다. RHEL 계열은 미검증) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 개정 | R1 (2026-11-19) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [service-management.md](../../../services/service-management.md) | LNX-SVC-002-MP | 불필요한 서비스 관리 및 비활성화 |
| [runlevel.md](../../../storage-boot/runlevel.md) | LNX-STB-005-DO | 런레벨 정의표 (Runlevel) |
| [log_file.md](../../../logging-monitoring/log_file.md) | LNX-LOG-001-REF | 시스템 로그 파일 분석 (/var/log) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 대상 서버 | systemd 기반 리눅스 | `systemctl --version`으로 확인 |
| 2 | 대상 서비스 이름 | 예: `cron`, `sshd` | 서비스 이름은 배포판마다 다르다. SSH 서버는 RHEL 계열에서 `sshd`, Ubuntu에서 `ssh`다 |
| 3 | 콘솔 접근 | 가상 머신 화면 또는 물리 콘솔 | 원격 접속 서비스를 다룰 때 필요 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: SSH 서비스를 `stop`하거나 `disable`하면 원격 접속이 끊기거나 재부팅 후 접속할 수 없다. 원격 접속 서비스는 콘솔을 확보한 뒤에만 다룬다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `restart`는 서비스를 잠시 멈춘다. 접속 중인 사용자의 연결이 끊길 수 있다. 설정만 다시 읽으면 되는 서비스는 `reload`를 쓴다. `reload`는 서비스가 지원할 때만 동작한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | systemd가 PID 1이다 | `ps -p 1 -o comm=`가 `systemd`를 출력한다 |
| 2 | 대상 서비스 이름을 안다 | `systemctl list-unit-files --type=service`에 이름이 있다 |

## 5. 절차

### A. 상태 확인

1. (5-A-01) 서비스 상태를 확인한다: `systemctl status <서비스>` → 결과: `Loaded`(unit 파일 경로, `enabled`/`disabled`)와 `Active`(`active (running)` 등) 줄이 출력된다.
2. (5-A-02) 실행 여부만 확인한다: `systemctl is-active <서비스>` → 결과: `active`, `inactive`, `failed` 중 하나가 출력된다. 종료 코드는 `active`일 때 0이다.
3. (5-A-03) 자동 시작 여부를 확인한다: `systemctl is-enabled <서비스>` → 결과: `enabled` 또는 `disabled` 등이 출력된다.
4. (5-A-04) 실패한 서비스를 모두 본다: `systemctl --failed` → 결과: `failed` 상태 unit 목록이 출력된다.

### B. 시작, 중지, 재시작

1. (5-B-01) 서비스를 시작한다: `systemctl start <서비스>` → 결과: 오류 없이 끝난다.
2. (5-B-02) 서비스를 중지한다: `systemctl stop <서비스>` → 결과: 오류 없이 끝난다.
3. (5-B-03) 서비스를 재시작한다: `systemctl restart <서비스>` → 결과: 오류 없이 끝난다.
4. (5-B-04) 설정만 다시 읽게 한다: `systemctl reload <서비스>` → 결과: 서비스를 멈추지 않고 설정을 다시 읽는다.
5. (5-B-05) 5-A-01을 다시 수행한다 → 결과: `Active` 줄이 바꾼 상태를 보여 준다.

### C. 부팅 시 자동 시작

1. (5-C-01) 자동 시작을 켠다: `systemctl enable <서비스>` → 결과: `/etc/systemd/system/` 아래에 심볼릭 링크가 만들어진다는 메시지가 출력된다.
2. (5-C-02) 자동 시작을 끈다: `systemctl disable <서비스>` → 결과: 링크가 제거된다는 메시지가 출력된다.
3. (5-C-03) 켜고 동시에 시작한다: `systemctl enable --now <서비스>` → 결과: 자동 시작이 켜지고 서비스가 바로 시작된다.
4. (5-C-04) 다른 서비스가 실수로 시작하는 것까지 막는다: `systemctl mask <서비스>` → 결과: unit이 `/dev/null`로 연결된다. 되돌릴 때는 `systemctl unmask <서비스>`를 쓴다.

{% hint style="info" %}
NOTE: `enable`과 `disable`은 부팅 때의 동작만 바꾼다. 지금 실행 중인 서비스 상태는 `start`와 `stop`이 바꾼다. 두 가지를 따로 설정한다.
{% endhint %}

### D. unit 파일 확인

1. (5-D-01) unit 파일 내용을 본다: `systemctl cat <서비스>` → 결과: 파일 경로와 `[Unit]`, `[Service]`, `[Install]` 절이 출력된다. `ExecStart=`가 실제 실행 명령이다.
2. (5-D-02) 배포판이 설치한 unit 파일은 `/usr/lib/systemd/system/`에 있다. 직접 만든 파일과 수정본은 `/etc/systemd/system/`에 둔다.
3. (5-D-03) unit 파일을 고친 뒤에는 systemd가 다시 읽게 한다: `systemctl daemon-reload` → 결과: 오류 없이 끝난다. 이 명령 후 서비스를 `restart`해야 새 설정이 적용된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `systemctl is-active <서비스>` | 의도한 상태다 | 출력이 `active` 또는 의도한 상태와 같다 |
| 2 | `systemctl is-enabled <서비스>` | 자동 시작 설정이 의도와 같다 | 출력이 `enabled` 또는 `disabled`로 의도와 같다 |
| 3 | 재부팅 후 `systemctl is-active <서비스>` | 자동 시작이 동작한다 | `enable`한 서비스가 `active`다 |

## 7. 복구

1. (7-01) 중지한 서비스를 시작한다: `systemctl start <서비스>`
2. (7-02) 끈 자동 시작을 켠다: `systemctl enable <서비스>`
3. (7-03) mask한 서비스는 `systemctl unmask <서비스>`를 입력한다.
4. (7-04) 서비스가 시작되지 않으면 로그를 확인한다: `journalctl -u <서비스> -n 50` (LNX-LOG-006-MP)

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성 |
