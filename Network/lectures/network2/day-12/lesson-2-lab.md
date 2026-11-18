# SSH 설정 강화와 공개키 인증 실습

> 상위: [12일차 · 리눅스 서버 구축](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-12-012-MP |
| 목적 | `sshd_config`에서 root 로그인을 막고, Windows에서 만든 공개키로 비밀번호 없이 로그인하고, `scp`로 파일을 옮긴다 |
| 적용 대상 | 9일차 Ubuntu Server 24.04 LTS VM(openssh-server 설치됨), Windows 10/11 PowerShell(OpenSSH 클라이언트) |
| 소요 시간 | 약 25분 |
| 확인 상태 | 미검증 (원본 강의 노트와 실습 명령 대본을 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1.md](lesson-1.md) | LEC-N2-12-001-DO | 서버 구축의 공통 문법 |
| [lesson-2.md](lesson-2.md) | LEC-N2-12-002-DO | SSH 다시 보기 |
| [lesson-1-lab.md](lesson-1-lab.md) | LEC-N2-12-011-MP | ufw 방화벽 켜기 실습 |
| [commands.md](commands.md) | LEC-N2-12-010-REF | 12일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Ubuntu Server VM | 24.04 LTS, 브릿지 어댑터 | 서버. 창 `①`로 부른다 |
| 2 | Windows PowerShell | OpenSSH 클라이언트 포함 | 창 `PowerShell`로 부른다 |
| 3 | VM의 IP 주소 | `ip a`로 확인(`192.168.x.x`) | 브릿지라 수업마다 바뀔 수 있다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `sshd_config`를 고치는 동안 접속 중인 창을 닫지 않는다. 설정 오류로 새 접속이 막혀도 기존 창으로 복구할 수 있다. 기존 창을 닫은 뒤 복구하려면 VirtualBox 콘솔로 직접 로그인해야 한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 5-A-02(`.bak` 백업)를 건너뛰지 않는다. 백업이 없으면 7절의 복구를 할 수 없다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | VM을 켜고 IP를 확인한다 | `ip a`에서 `192.168.x.x`가 보인다 |
| 2 | PowerShell 창 2개로 각각 VM에 SSH 접속한다 | 두 창 모두 `student@...` 프롬프트가 보인다 |
| 3 | ufw를 켰다면 22번이 열려 있다 | `sudo ufw status`에 `22/tcp ALLOW`가 있다 |

## 5. 절차

### A. 설정 파일 수정과 적용 (서버 창)

1. (5-A-01) 서버 창에서 설정을 확인한다: `grep -v '^#' /etc/ssh/sshd_config | grep -v '^$'` → 결과: 실제로 살아 있는 설정만 보인다.
2. (5-A-02) 설정 파일을 백업한다: `sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak` → 결과: 오류 없이 끝난다.
3. (5-A-03) 편집기를 연다: `sudo nano /etc/ssh/sshd_config`
4. (5-A-04) `Ctrl+W`로 `PermitRootLogin`을 찾는다.
5. (5-A-05) 값을 `PermitRootLogin no`로 고친다. 줄 앞의 `#`이 있으면 지운다.
6. (5-A-06) 저장하고 나간다: `Ctrl+O`, `Enter`, `Ctrl+X`
7. (5-A-07) 문법을 검사한다: `sudo sshd -t` → 결과: 아무 출력이 없다. 오타가 있으면 줄 번호가 나온다.
8. (5-A-08) 서비스를 재시작한다: `sudo systemctl restart ssh` → 결과: 오류 없이 끝난다. 기존 창은 유지된다.

### B. 새 창으로 접속 확인 (Windows)

1. (5-B-01) PowerShell 새 창을 연다. 기존 창은 닫지 않는다.
2. (5-B-02) 접속한다: `ssh student@192.168.x.x` → 결과: 비밀번호를 묻고, 입력하면 접속된다.

### C. 공개키 생성과 등록 (Windows)

1. (5-C-01) 키 한 쌍을 만든다: `ssh-keygen -t ed25519` → 결과: 저장 위치와 암호를 묻는다.
2. (5-C-02) Enter를 3번 누른다(암호는 비워도 된다). → 결과: `id_ed25519`, `id_ed25519.pub` 파일이 만들어진다.
3. (5-C-03) 공개키를 확인한다: `type $env:USERPROFILE\.ssh\id_ed25519.pub` → 결과: `ssh-ed25519 AAAA...`로 시작하는 한 줄이 보인다.
4. (5-C-04) 공개키를 서버에 등록한다(한 줄, 통째로 복사한다):

```powershell
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh student@192.168.x.x "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

→ 결과: 비밀번호를 한 번 묻고, 오류 없이 끝난다.

{% hint style="info" %}
NOTE: 개인키(`id_ed25519`)는 서버에 올리지 않는다. 올리는 것은 `.pub` 파일뿐이다.
{% endhint %}

### D. 키 로그인 확인 (Windows)

1. (5-D-01) 다시 접속한다: `ssh student@192.168.x.x` → 결과: 비밀번호를 묻지 않고 바로 접속된다.

{% hint style="info" %}
NOTE: 여전히 비밀번호를 묻는다면 서버 창에서 `ls -ld ~/.ssh`(`drwx------`)와 `ls -l ~/.ssh/authorized_keys`(`-rw-------`)를 확인한다. 그래도 안 되면 `sudo journalctl -u ssh -n 20 --no-pager`에 이유가 찍혀 있다.
{% endhint %}

### E. 파일 옮기기 (Windows)

1. (5-E-01) 테스트 파일을 만든다: `echo hello > hello.txt`
2. (5-E-02) 서버로 올린다: `scp hello.txt student@192.168.x.x:~/` → 결과: 전송 진행 표시가 나오고 오류가 없다.
3. (5-E-03) 서버에서 내려받는다: `scp student@192.168.x.x:/etc/hostname .` → 결과: 현재 폴더에 `hostname` 파일이 생긴다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 서버에서 `sudo sshd -t` | 출력이 없다 | 빈 출력 |
| 2 | 서버에서 `grep PermitRootLogin /etc/ssh/sshd_config` | `PermitRootLogin no` | `no`로 보인다 |
| 3 | Windows에서 `ssh student@192.168.x.x` | 비밀번호를 묻지 않는다 | 바로 프롬프트가 나온다 |
| 4 | 서버에서 `ls ~/hello.txt` | 파일이 있다 | 파일이 보인다 |

수업 종료 시 점검: `sshd_config`와 `ssh_config`의 차이, `-p`와 `-P`의 차이를 말할 수 있다.

## 7. 복구

1. (7-01) 서버 창에서 원본 설정을 되돌린다: `sudo cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config`
2. (7-02) 검사하고 재시작한다: `sudo sshd -t && sudo systemctl restart ssh`
3. (7-03) 등록한 공개키를 지운다(선택): 서버에서 `nano ~/.ssh/authorized_keys`로 해당 줄을 삭제한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-2.md`의 구축 절과 `commands.md` STEP 2를 AMM 형식 MP로 분리 |
