# 2. SSH 다시 보기 — Telnet 과의 차이 · 키 인증 · 파일 전송

> 상위: [12일차 · 리눅스 서버 구축](README.md)

## 🎯 학습 목표

- **Telnet(23)** 과 **SSH(22)** 의 차이를 **평문 vs 암호화**로 설명한다
- 9일차에 세운 SSH 서버의 **설정 파일 `/etc/ssh/sshd_config`** 를 읽고 고친다
- **비밀번호 인증**과 **공개키 인증**의 차이를 알고, 키로 로그인한다
- **`scp` · `sftp`** 로 Windows ↔ 리눅스 사이에 파일을 옮긴다

## 🌉 다리 놓기: "이미 세운 서버부터, 이번엔 제대로"

9일차에 우리는 SSH 서버를 세웠다. 다만 **설치하고 켜기**까지였다. 설정 파일은 열어보지도 않았다.
[1_서버구축의_공통문법](lesson-1.md) 의 여섯 단계로 보면 우리는 **① ③ ④ ⑥** 만 했고 **② 설정**을 건너뛴 셈이다.

오늘 첫 타자로 SSH 를 고르는 이유는 두 가지다.
1. **이미 아는 서버**라서 "설정 파일을 고친다"는 감각에만 집중할 수 있다
2. 오늘 세울 다른 서버들의 **파일을 옮길 통로**가 바로 SSH 다 (`scp` · `sftp`)

---

## 📖 ① Telnet 과 SSH — 8일차의 그 짝

8일차에 라우터를 원격 관리하면서 **Telnet 대신 SSH** 를 썼다 → [8일차 평문 vs 암호화 표](../../network1/day-08/lesson-3.md).

| | **Telnet** | **SSH** |
|---|---|---|
| 포트 | TCP **23** | TCP **22** |
| 내용 | **평문** — 비밀번호가 그대로 흐른다 | **암호화** |
| 요즘 | 실무에서 **금지**. 장비 초기 설정 정도 | **표준** |
| 데몬 | `telnetd` | **`sshd`** |

> 💡 **비유: 엽서와 밀봉 편지.** 엽서(Telnet)는 배달하는 사람이 **읽으면서** 간다. SSH 는 봉해서 보낸다.
> 커리큘럼에 Telnet 서버가 있지만 **일부러 세우지 않는다.** 대신 **"왜 세우면 안 되는지"** 를 [3_FTP서버_vsftpd](lesson-3.md) 에서 **비밀번호가 실제로 보이는 장면**으로 증명한다.

---

## 📖 ② 설정 파일을 연다 — `/etc/ssh/sshd_config`

> ⚠️ **파일이 두 개다. 헷갈리면 오늘 하루가 꼬인다.**

| 파일 | 누구의 설정 |
|------|-------------|
| **`/etc/ssh/sshd_config`** | **서버(sshd)** 설정 — **`d` 가 붙는다** ⭐ 오늘 고칠 것 |
| `/etc/ssh/ssh_config` | 클라이언트(`ssh` 명령) 설정 |

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak     # ② 백업 먼저
grep -v '^#' /etc/ssh/sshd_config | grep -v '^$'          # 주석 뺀 실제 설정만 보기
```

| 항목 | 뜻 | 오늘 권장 |
|------|----|-----------|
| `Port 22` | 듣는 포트 | 수업에선 **그대로 둔다** (아래 ⚠️) |
| `PermitRootLogin` | root 로 직접 로그인 허용 | **`no`** ⭐ |
| `PasswordAuthentication` | 비밀번호 로그인 허용 | 키를 만든 뒤 `no` (실무) · 수업은 `yes` 유지 |
| `PubkeyAuthentication` | 공개키 로그인 허용 | `yes` (기본값) |
| `AllowUsers student` | 이 사용자만 접속 | 선택 |

```bash
sudo nano /etc/ssh/sshd_config      # PermitRootLogin no 로
sudo sshd -t                        # ⭐ 문법 검사 — 조용하면 정상
sudo systemctl restart ssh          # ③ 적용
```

> ⚠️ **SSH 설정을 고칠 때의 철칙: 지금 접속한 창을 절대 닫지 말 것.**
> **새 창**으로 접속이 되는 걸 확인한 뒤에 원래 창을 닫는다. 잘못 고치고 창을 닫으면 → VirtualBox 화면으로 직접 들어가 복구해야 한다.

### 📌 포트를 바꾸고 싶다면 (우분투 24.04 의 함정)

우분투 22.10 부터 SSH 는 **소켓 활성화(ssh.socket)** 라서, `sshd_config` 의 `Port` 만 고치면 **안 바뀐다.**

```bash
sudo systemctl status ssh.socket                     # 포트를 쥐고 있는 진짜 주인
sudo systemctl disable --now ssh.socket              # 소켓 방식 끄고
sudo systemctl enable --now ssh.service              # 서비스가 직접 듣게
```

> 🗣 **"설정 파일이 맞는데 안 먹는다? 그 포트를 쥔 놈이 따로 있는 겁니다."** — 10일차 `ss -tulnp` 의 **Process 칸**이 답을 알려준다.
> 📌 수업에서는 **바꾸지 않는다.** 포트를 바꾸면 **방화벽 규칙도 같이** 고쳐야 한다 — `sudo ufw allow <새 포트>/tcp` 를 **먼저** 하지 않으면 다시 못 들어온다 → [11일차 ufw](../day-11/lesson-6.md)

---

## 📖 ③ 공개키 인증 — 비밀번호 없이, 더 안전하게 ⭐

비밀번호는 **짧고 · 재사용되고 · 무차별 대입(brute force)** 당한다. 키는 **길고 · 유일하고 · 옮겨지지 않는다.**

```
 🪟 Windows (클라이언트)                        🐧 Ubuntu (서버)
 개인키  id_ed25519      ← 절대 남 주지 않는다
 공개키  id_ed25519.pub  ──── 복사 ────▶  ~/.ssh/authorized_keys
                                          "이 공개키를 가진 사람은 통과"
```

> 💡 **비유: 자물쇠와 열쇠.** **공개키 = 자물쇠**다. 서버 문에 **내가 만든 자물쇠를 달아 두는** 것이다.
> 자물쇠는 아무나 봐도 되지만(그래서 '공개'키), 여는 **열쇠(개인키)는 내 PC 에만** 있다.

```powershell
ssh-keygen -t ed25519              # 🪟 Windows 에서 키 한 쌍 만들기 (Enter 3번)
type $env:USERPROFILE\.ssh\id_ed25519.pub    # 공개키 내용 보기
```

- 리눅스에는 `ssh-copy-id` 가 있지만 **Windows 에는 없다** → 대본의 한 줄짜리 복사 명령을 쓴다
- `~/.ssh` 는 **권한이 까다롭다**: `.ssh` 는 `700`, `authorized_keys` 는 `600` 이어야 한다. 아니면 sshd 가 **조용히 무시**한다
  - 10일차 [권한 rwx](../day-10/lesson-3.md) 가 여기서 실제로 쓰인다

```bash
ls -ld ~/.ssh ; ls -l ~/.ssh/authorized_keys     # drwx------ · -rw-------
sudo journalctl -u ssh -n 20 --no-pager          # 키가 무시된 이유가 여기 찍힌다
```

---

## 📖 ④ 파일을 옮긴다 — `scp` · `sftp`

오늘 만든 설정 파일을 백업하거나, 홈페이지 파일을 서버에 올릴 때 쓴다. **둘 다 SSH(22) 위에서 돈다** — 새 포트를 열 필요가 없다.

| 명령 | 성격 | 예 |
|------|------|-----|
| **`scp`** | **복사 한 방** (`cp` 의 네트워크판) | `scp a.txt student@192.168.x.x:~/` |
| **`sftp`** | **대화형** (`ftp` 와 같은 느낌 · `put` · `get`) | `sftp student@192.168.x.x` |

> ⚠️ **포트를 지정해야 할 때는 대소문자가 다르다.** `ssh` 는 소문자 **`-p`**, `scp` · `sftp` 는 대문자 **`-P`**.
> 우리는 기본 포트(22)를 쓰므로 오늘은 **생략**하지만, 포트를 바꾼 서버에서는 오타 1위다.

```powershell
scp C:\Users\사용자\Desktop\hello.txt student@192.168.x.x:~/      # 올리기
scp student@192.168.x.x:~/lab/memo.txt .                          # 내려받기
```

- 서버끼리도 된다: `scp file student@192.168.x.x:/srv/share/`
- 폴더째 옮길 땐 `-r` (10일차 `cp -r` 과 같은 약속)

> 🗣 **"오늘 배울 FTP 와 하는 일이 똑같습니다. 그런데 FTP 는 포트를 새로 열어야 하고, 평문이고, 방화벽이 싫어합니다. 그럼 왜 아직도 FTP 를 배울까요?"** → [3_FTP서버_vsftpd](lesson-3.md)

---

## 🧪 실습 / 질문

- 실습: 대본 **STEP 2** — `sshd_config` 수정 · 키 인증 · `scp` → [0_실습_명령어_모음](commands.md)
- `sshd_config` 를 고쳤는데 그대로다. 무엇을 빠뜨렸나?
- 공개키와 개인키 중 **서버에 올리는 것**은? 왜 그것을 올려도 안전한가?
- `scp` 로 파일을 올렸는데 `Permission denied` — 어디에 올리려 했을까? (`/etc` 같은 곳 → 내 홈으로)

## 📝 강의 메모

- ⚠️ **모두가 SSH 로 들어와 있는 상태에서 SSH 설정을 고친다** → 시작 전에 **"창 하나 더 열어 두세요"** 를 강제한다
- `sshd_config` 의 `d` 를 칠판에 크게: **서버 = 데몬 = `d`**
- 키 인증은 **13일차 GitHub** 에서 그대로 재등장한다 (SSH 키로 push) → [13일차](../day-13/README.md) 예고 한 줄
- 시간이 모자라면: 키 인증은 **시연만** 하고 `scp` 만 각자 해보게 한다 (`scp` 는 16일차 배포에서 계속 쓴다)
- 되짚기: 8일차 **Telnet/SSH · FTP/SFTP · HTTP/HTTPS** 평문·암호화 짝 표
