# [생성형 AI] SSH 키 인증 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-NRM-007-MP |
| 유형 | MP (절차) |
| 목적 | SSH 키 쌍을 만들고 공개 키를 서버에 등록해 비밀번호 없이 키로 로그인한다 |
| 적용 대상 | OpenSSH 클라이언트와 서버(RHEL 계열 9, Ubuntu 26.04 등), 서버에 비밀번호로 로그인할 수 있는 계정 |
| 소요 시간 | 약 15분 |
| 확인 상태 | 일부 확인 (Ubuntu 26.04, OpenSSH 10.2에서 5-A 키 생성과 지문 확인을 임시 디렉터리에 실행했다. 서버 등록과 `sshd_config` 변경은 실행하지 않아 미검증) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 개정 | R1 (2026-11-19) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [remote-access-management.md](remote-access-management.md) | LNX-NRM-002-MP | 원격 접속 보안 관리 (sshd) |
| [remote-ssh.md](remote-ssh.md) | LNX-NRM-003-MP | VS Code 원격 SSH 연결 |
| [permissionchange.md](../accounts-permissions/permissionchange.md) | LNX-ACC-010-MP | 파일 권한 변경 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 클라이언트 PC | OpenSSH 클라이언트(`ssh`, `ssh-keygen`) | |
| 2 | 서버 | `sshd` 실행 중 | 서버 주소는 `<서버 주소>`, 계정은 `<사용자>` |
| 3 | 콘솔 접근 | 가상 머신 화면 또는 물리 콘솔 | 5-C 단계에서 접속이 끊길 때 복구용 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 개인 키 파일(`id_ed25519`, `.pub`이 없는 쪽)은 비밀번호와 같다. 다른 사람에게 보내거나 저장소에 올리지 않는다. 공유하는 것은 `.pub` 공개 키뿐이다.
{% endhint %}

{% hint style="danger" %}
WARNING: 키 로그인이 되는 것을 확인하기 전에 `PasswordAuthentication no`를 적용하면 서버에 접속할 수 없게 된다. 5-C는 5-B의 키 로그인 확인 뒤에, 접속 중인 세션을 닫지 않은 채 수행한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 클라이언트에 `ssh-keygen`이 있다 | `ssh -V`가 버전을 출력한다 |
| 2 | 서버에 비밀번호로 접속할 수 있다 | `ssh <사용자>@<서버 주소>`가 로그인된다 |

## 5. 절차

### A. 키 쌍 만들기 (클라이언트)

1. (5-A-01) 키를 만든다: `ssh-keygen -t ed25519 -C "<설명>"` → 결과: 저장 위치(기본 `~/.ssh/id_ed25519`)와 암호문(passphrase)을 묻는다.
2. (5-A-02) 암호문을 입력한다. 개인 키가 유출될 때를 대비해 비워 두지 않는 것을 권장한다 → 결과: `id_ed25519`(개인 키)와 `id_ed25519.pub`(공개 키)가 만들어진다.
3. (5-A-03) 지문을 확인한다: `ssh-keygen -lf ~/.ssh/id_ed25519.pub` → 결과: `256 SHA256:... (ED25519)` 형식이 출력된다. 개인 키 권한은 `-rw-------`(600)이다.

### B. 공개 키 등록

1. (5-B-01) 공개 키를 서버에 복사한다: `ssh-copy-id -i ~/.ssh/id_ed25519.pub <사용자>@<서버 주소>` → 결과: 서버 비밀번호를 묻고 `Number of key(s) added: 1`이 출력된다.
2. (5-B-02) 새 터미널에서 키로 접속한다: `ssh <사용자>@<서버 주소>` → 결과: 서버 비밀번호 대신 키 암호문을 묻거나 바로 로그인된다.
3. (5-B-03) 서버에서 권한을 확인한다: `stat -c '%a %n' ~/.ssh ~/.ssh/authorized_keys` → 결과: `700 .../.ssh`와 `600 .../authorized_keys`(또는 그보다 엄격한 값)가 출력된다. 권한이 느슨하면 `sshd`가 키를 무시할 수 있다.

### C. 비밀번호 로그인 끄기 (선택)

1. (5-C-01) 서버에서 설정 파일을 백업한다: `cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak`
2. (5-C-02) `/etc/ssh/sshd_config`에서 `PasswordAuthentication no`로 바꾼다 → 결과: 해당 줄이 `PasswordAuthentication no`다. 배포판이 `/etc/ssh/sshd_config.d/`의 파일로 이 값을 덮어쓸 수 있으므로 그 디렉터리의 파일도 확인한다.
3. (5-C-03) 문법을 검사한다: `sshd -t` → 결과: 아무 출력 없이 끝난다.
4. (5-C-04) 서비스에 반영한다: `systemctl reload sshd` (Ubuntu는 `ssh`) → 결과: 오류 없이 끝난다.
5. (5-C-05) 기존 세션을 닫지 않은 채 새 터미널에서 키로 접속한다 → 결과: 로그인된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 새 터미널에서 `ssh <사용자>@<서버 주소>` | 키로 로그인된다 | 서버 계정 비밀번호를 묻지 않는다 |
| 2 | 5-C 후 `ssh -o PubkeyAuthentication=no <사용자>@<서버 주소>` | 비밀번호 로그인이 거부된다 | `Permission denied (publickey...)`가 출력된다 |

## 7. 복구

1. (7-01) 서버 콘솔에서 `cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config`를 입력한다.
2. (7-02) `systemctl reload sshd`(Ubuntu는 `ssh`)를 입력한다 → 결과: 비밀번호 로그인이 다시 된다.
3. (7-03) 키를 폐기하려면 서버의 `~/.ssh/authorized_keys`에서 해당 공개 키 줄을 지운다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성 |
