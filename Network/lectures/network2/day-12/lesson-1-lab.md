# ufw 방화벽 켜기 실습

> 상위: [12일차 · 리눅스 서버 구축](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-12-011-MP |
| 목적 | `systemctl`로 서비스를 다루고 `journalctl`로 로그를 읽은 뒤, SSH 접속이 끊기지 않도록 22번을 먼저 열고 `ufw`를 켠다 |
| 적용 대상 | Ubuntu Server 24.04 LTS VM(9일차 VM, openssh-server 설치됨), SSH 접속 창 |
| 소요 시간 | 약 5분 |
| 확인 상태 | 미검증 (원본 강의 노트와 실습 명령 대본을 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1.md](lesson-1.md) | LEC-N2-12-001-DO | 서버 구축의 공통 문법 |
| [commands.md](commands.md) | LEC-N2-12-010-REF | 12일차 실습 명령어 |
| [11일차 서버 보안](../day-11/README.md) | | ACL과 방화벽(ufw 이월 배경) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Ubuntu Server VM | 24.04 LTS | SSH 서버 구동 중 |
| 2 | SSH 접속 창 | `ssh student@192.168.x.x` | 창 `①` |
| 3 | VirtualBox 창(콘솔) | 해당 VM | 접속이 끊겼을 때 복구용 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 5-C-01(`ufw allow 22/tcp`)보다 5-C-02(`ufw enable`)를 먼저 하지 않는다. `ufw`의 기본 정책은 들어오는 것 전부 거부다. 22번을 열기 전에 켜면 지금 접속한 SSH 창이 그 자리에서 끊기고 다시 들어갈 수 없다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 이미 끊겼다면 VirtualBox 창(콘솔)으로 직접 로그인해 `sudo ufw disable`을 친다. 이 복구 경로를 시작 전에 칠판에 적어 둔다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | SSH 창으로 VM에 접속한다 | `student@...` 프롬프트가 보인다 |
| 2 | VirtualBox 콘솔 로그인이 가능한지 확인한다 | 계정과 비밀번호를 안다(`<password>`) |
| 3 | `ufw` 현재 상태를 본다 | `sudo ufw status`가 `Status: inactive`다 |

## 5. 절차

### A. `systemctl` 연습 (이미 있는 SSH로)

1. (5-A-01) 상태를 본다: `systemctl status ssh --no-pager | head -5` → 결과: `active (running)`.
2. (5-A-02) 자동 시작 여부를 본다: `systemctl is-enabled ssh` → 결과: `enabled`.
3. (5-A-03) 동작 여부를 본다: `systemctl is-active ssh` → 결과: `active`.
4. (5-A-04) 재시작한다: `sudo systemctl restart ssh` → 결과: 오류 없이 끝나고 지금 접속은 유지된다.

### B. 로그 읽기

1. (5-B-01) 최근 로그를 본다: `journalctl -u ssh -n 15 --no-pager` → 결과: SSH 서비스의 최근 15줄이 나온다.

### C. 방화벽 켜기

1. (5-C-01) 먼저 22번을 연다: `sudo ufw allow 22/tcp` → 결과: `Rules updated`(또는 `Skipping adding existing rule`).
2. (5-C-02) 방화벽을 켠다: `sudo ufw enable` → 결과: `Command may disrupt existing ssh connections. Proceed with operation (y|n)?`가 나오면 `y`를 입력한다.
3. (5-C-03) 상태를 본다: `sudo ufw status verbose` → 결과: `Status: active`, `Default: deny (incoming)`, `22/tcp ALLOW IN`이 보인다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 5-C-02 직후 SSH 창에서 아무 명령 입력 | 창이 끊기지 않는다 | 명령이 실행된다 |
| 2 | `sudo ufw status` | 활성 | `Status: active` |
| 3 | `sudo ufw status numbered` | 22번 규칙 | `22/tcp ALLOW IN`이 있다 |

수업 종료 시 점검: `start`와 `enable`의 차이를 말할 수 있고, `ufw status`가 `active`다.

## 7. 복구

1. (7-01) 방화벽을 끈다: `sudo ufw disable` → 결과: `Firewall stopped and disabled on system startup`.
2. (7-02) 규칙만 지운다(선택): `sudo ufw status numbered`로 번호를 확인하고 `sudo ufw delete <번호>`를 실행한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-1.md`의 ufw 절과 `commands.md` STEP 1을 AMM 형식 MP로 분리 |
