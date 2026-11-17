# 0. 9일차 실습 명령어 — 수업 흐름 그대로 (이어치기 대본)

> 상위: [9일차 · 리눅스 설명](README.md)
> 📌 실제 수업은 **SSH 서버 구축 · 접속 · 첫 명령**까지 했다. 이후 명령어 실습(이동 · 파일 · 권한 · 네트워크 · AI)은 **10일차 오전**으로 → [10일차 대본](../day-10/commands.md)
> **위에서 아래로 그대로 따라 치면 오늘 실습이 끝난다.** 실습 중 화면에 띄워두거나 인쇄해 나눠줄 것.

## 📌 읽는 법 — 1단계와 같은 약속, 창만 바뀐다

- 블록 하나 = **한 창에서 끊지 않고 이어 치는 한 덩어리**
- 블록 머리의 `🖱` = 마우스로 하는 GUI 작업 · `🪟 PowerShell` = Windows 터미널 · `🐧 Ubuntu` = SSH 로 들어간 리눅스
- `# 뒤 회색 글씨` = 설명. **안 쳐도 된다** (리눅스도 `#` 뒤는 무시한다)
- `$` 는 **치지 않는다** — 프롬프트 표시일 뿐

## 🗺 오늘의 그림

```
 🪟 Windows (호스트)                          🐧 Ubuntu Server VM (게스트)
 PowerShell ── ssh student@192.168.x.x ──▶ [강의실 공유기] ──▶ Ubuntu VM : 22 (sshd)
                                   브릿지 어댑터 — 공유기에서 IP 를 직접 받는다
```

---

# ▶ STEP 0 · 준비물 확인 (수업 전)

- [ ] **VirtualBox 7.x** 설치 — virtualbox.org
- [ ] **Ubuntu Server 24.04 LTS ISO** — ubuntu.com/download/server (약 3GB, `...live-server-amd64.iso`)
- [ ] **BIOS 가상화 ON** 확인: 작업 관리자 → 성능 → CPU → **가상화: 사용**

---

# ▶ STEP 1 · VM 만들고 설치 (20분 + 설치 대기)

### 1-1 🖱 VirtualBox — 새로 만들기

| 칸 | 값 |
|----|-----|
| 이름 | `ubuntu-server` |
| ISO 이미지 | 받은 ISO 선택 |
| **무인 설치 건너뛰기** | ✅ **체크** (Skip Unattended Installation) |
| 메모리 / CPU | **2048 MB** / **2** |
| 디스크 | **25 GB** |

### 1-2 🖱 설정 → 네트워크 → 어댑터 1 → **고급 → 포트 포워딩** ⭐

| 이름 | 프로토콜 | 호스트 IP | 호스트 포트 | 게스트 IP | 게스트 포트 |
|------|----------|-----------|-------------|-----------|-------------|

> ⭐ 어댑터 1 을 **브릿지 어댑터**로 바꾼다 (이름 = 지금 인터넷이 되는 랜카드).

### 1-3 🖱 시작 → 설치 화면 (키보드: ↑↓ · **Space 체크** · Enter)

1. `Try or Install Ubuntu Server` → Enter
2. Language **English** → Keyboard **English (US)**
3. **Ubuntu Server** (기본) → Network **기본값** (🔎 **강의실 망 IP 가 보인다 — 적어 둘 것**) → Proxy · Mirror 기본값
4. Storage **Use an entire disk** → Done → **Continue**
5. Profile: 이름 · server name **`ubuntu`** · username **`student`** · password
6. Ubuntu Pro → **Skip for now**
7. **SSH Setup → 체크하지 않고 Done** — SSH 서버는 설치가 끝난 뒤 **직접 구축**한다 (STEP 2) ⭐
8. Featured snaps → 아무것도 선택 안 함 → Done
9. ⏳ 설치 (10~20분) → **Reboot Now** → `remove the installation medium` → Enter

> ⏳ **설치 도는 동안** → [1_운영체제와_리눅스](lesson-1.md) 이론

**✅ STEP 1 체크** — `ubuntu login:` 이 떴다 → 🖱 VirtualBox **스냅샷 찍기** `설치완료`

---

# ▶ STEP 2 · SSH 서버 직접 구축 → Windows 에서 접속 (30분)

### 2-1 🐧 Ubuntu (VM 창에서 직접) — 첫 로그인

```bash
student                     # login:
(비밀번호)                   # ⚠️ 화면에 아무것도 안 나온다. 그냥 치고 Enter
```

### 2-2 🐧 Ubuntu (VM 창) — 첫 서버 구축: OpenSSH 서버 ⭐

```bash
sudo apt update                          # 패키지 관리자(apt)의 창고 목록 새로고침
sudo apt install openssh-server          # SSH 서버 프로그램 설치 → 물어보면 y
sudo systemctl enable --now ssh          # enable = 부팅할 때마다 자동 시작 · --now = 지금 바로 켜기
sudo systemctl status ssh                # 상태 확인 (q 로 나가기)
```

- 🔎 `status` 에서 읽을 세 줄

```
Loaded: ... ssh.service; enabled; ...        ← enabled = 부팅 때 자동 시작
Active: active (running) since ...           ← 지금 돌고 있다
... sshd[2610]: Server listening on 0.0.0.0 port 22.   ← 22번 문을 열고 기다린다
```

> 🗣 **"방금 여러분은 리눅스에 서버를 하나 구축했습니다."** 명령의 모양은 전부 `명령어 [옵션] [대상]` 이다.
> `Server listening on ... port 22` — 이 한 줄의 정체(포트 · LISTEN)는 **10일차 오후**에 밝힌다

### 2-3 🪟 PowerShell — 원격 접속 ⭐

```powershell
ip a                                   # 🐧 VM 창에서 먼저 — 192.168.x.x 확인
ssh student@192.168.x.x                # 🪟 Windows 터미널에서
# Are you sure you want to continue connecting (yes/no)?  → yes
# password: → (비밀번호)
```

> 🗣 8일차: `ssh -l admin 192.168.10.253` (스위치) → 오늘: `ssh student@192.168.x.x` (리눅스 서버)
> 👉 **이제부터 VM 창은 최소화.** 모든 실습은 PowerShell 창에서.

### 2-4 🐧 Ubuntu — 첫 명령 몇 개: 나는 누구, 여긴 어디

```bash
whoami                      # 나는 누구?  → student
hostname                    # 이 서버 이름 → ubuntu
cat /etc/os-release         # 무슨 리눅스? → Ubuntu 24.04 LTS
uname -r                    # 커널 버전 (리눅스 = 커널 이름!)
date                        # 서버 시각
```

**✅ STEP 2 체크** — `status` 에 `active (running)` · PowerShell 에서 `student@ubuntu:~$` 프롬프트가 보인다

> ❌ `Connection refused` → ① `sudo systemctl status ssh` 가 running 인가 ② `ip a` 로 **주소를 다시** 확인 (`10.0.2.15` 면 어댑터가 아직 NAT)

---

# ▶ 마무리 · 끄기

```bash
sudo poweroff                      # VM 종료 (SSH 연결도 끊긴다 — 정상)
```

> 📌 **VM 은 지우지 않는다.** 10 · 11 · 12일차에 **이 VM 을 계속** 쓴다.

---
