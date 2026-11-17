# 0. 10일차 실습 명령어 — 수업 흐름 그대로 (이어치기 대본)

> 상위: [10일차 · 서버 기초](README.md)
> **위에서 아래로 그대로 따라 치면 오늘 실습이 끝난다.** 실습 중 화면에 띄워두거나 인쇄해 나눠줄 것.
> 📌 **오전 = 9일차 이월(리눅스 기본 명령)** · **오후 = 서버 기초**. 무선 · PT 공유기 실습은 11일차로 → [11일차 대본](../day-11/commands.md)

## 📌 읽는 법 — 9일차 약속 + 창 번호

- 블록 하나 = **한 창에서 끊지 않고 이어 치는 한 덩어리**
- `🖱` = 마우스 (VirtualBox) · `🪟` = Windows PowerShell · `🌐` = Windows 브라우저
- **오전**: `🐧 Ubuntu` = SSH 로 들어간 창 **하나**
- **오후**: `🐧①` `🐧②` `🐧③` = 같은 VM 에 **창 3개**
  - **① 서버 창** (서버 프로그램을 띄운다 · 띄우면 그 창은 **점유**된다)
  - **② 클라이언트 창** (요청을 보낸다)
  - **③ 관찰 창** (`ss` · `tcpdump` 로 지켜본다)
- `# 뒤 회색 글씨` = 설명. 안 쳐도 된다 · `$` 는 치지 않는다

## 🗺 오늘의 그림

```
        [ 강의실 공유기 192.168.0.1 ]   ← 브릿지: VM 이 직접 IP 를 받는다
                   │
 🪟 Windows ── 창① ② ③ ssh student@192.168.x.x ──▶ 🐧 Ubuntu VM 192.168.x.x
 🌐 브라우저 ── http://192.168.x.x:8080 ─────────▶ (오후 웹서버)
```

---

# ▶ STEP 0 · 몸풀기 — VM 켜고 SSH (10분)

### 0-1 🖱 VirtualBox — VM 시작 (헤드리스 시작 추천)

### 0-2 🪟 PowerShell — 9일차에 만든 SSH 서버로

```powershell
ip a                                  # 🖱 VM 창에서 먼저 — 오늘의 주소 확인!
ssh student@192.168.x.x               # 🪟 Windows 터미널
```

### 0-3 🐧 Ubuntu — 9일차에 직접 구축한 SSH 서버가 살아 있나

```bash
sudo systemctl status ssh          # active (running) · Server listening on 0.0.0.0 port 22  (q 로 나가기)
```

> 🗣 **"9일차에 `enable --now` 로 켜 둔 덕분에, 재부팅해도 SSH 가 알아서 떠 있습니다."**
> 칠판: **"오늘의 주소 — 내 VM IP · 게이트웨이 · `port 22`"** → 오후에 하나씩 지운다
> ⚠️ **브릿지 + DHCP** 라 주소가 지난주와 다를 수 있다. 각자 칠판에 적게 한다

---

# 🌅 오전 · 리눅스 기본 명령 (9일차 이월)

> 9일차는 **SSH 서버 구축 · 접속**까지 했다. 들어온 서버 안에서 **돌아다니고 · 파일을 만지고 · 권한을 다루는** 법부터.

# ▶ STEP 1 · 여기가 어디지 — 이동 (20분) — [1_파일시스템과_이동](lesson-1.md)

### 1-1 🐧 Ubuntu — 내 위치 · 내 방

```bash
pwd                         # /home/student
ls                          # 비어 있다
ls -a                       # 숨김 파일 (.bashrc 등) 이 보인다
ls -al                      # 자세히 + 숨김
```

### 1-2 🐧 Ubuntu — 트리 여행 (Tab 을 계속 누를 것!)

```bash
cd /                        # 루트로
ls                          # bin etc home root tmp var ...
cd /etc                     # 설정의 집
ls                          # 설정 파일이 잔뜩
cat hostname                # 상대 경로 — 지금 /etc 에 있으니까
cat /etc/hostname           # 절대 경로 — 어디서든 같은 결과
cd /var/log                 # 일지의 집
ls
cd ..                       # 한 칸 위 → /var
pwd
cd -                        # 직전 위치로 → /var/log
cd                          # 홈으로
pwd
```

### 1-3 🐧 Ubuntu — 생존 키 연습

```bash
ping 127.0.0.1              # 안 멈춘다 → Ctrl + C
```

- **↑** 로 방금 명령 불러오기 · `cd /e` 까지 치고 **Tab** · `clear`

**✅ STEP 1 체크** — `/var/log` 에서 **한 줄로** 홈으로 돌아오는 방법 3가지를 말할 수 있다

---

# ▶ STEP 2 · 파일 다루기 · nano · 파이프 (30분) — [2_파일다루기와_편집](lesson-2.md)

### 2-1 🐧 Ubuntu — 실험실 만들기

```bash
cd ~
mkdir lab                   # 실험실
cd lab
mkdir -p docs/2026/09       # 중간까지 한 번에
touch memo.txt              # 빈 파일
ls -l
```

### 2-2 🐧 Ubuntu — 쓰고 · 읽기 (리다이렉션)

```bash
echo "첫째 줄" > memo.txt          # > 덮어쓰기
echo "둘째 줄" >> memo.txt         # >> 이어쓰기
cat memo.txt                       # 2줄
echo "덮어버림" > memo.txt          # ⚠️ 다시 > 로
cat memo.txt                       # 1줄만 남았다!
```

### 2-3 🐧 Ubuntu — nano 로 편집

```bash
nano memo.txt
```

- 아래 3줄을 입력 → **Ctrl+O · Enter** (저장) → **Ctrl+X** (종료)

```
hostname ubuntu
ip 192.168.x.x
gateway 192.168.0.1
```

```bash
cat memo.txt
```

### 2-4 🐧 Ubuntu — 복사 · 이동 · 이름 바꾸기 · 삭제

```bash
cp memo.txt memo.bak               # 백업 (설정 고치기 전 습관!)
mv memo.bak docs/                  # 이동
mv memo.txt server.txt             # 이름 바꾸기
ls -R                              # 하위까지 목록
cp -r docs docs_copy               # 디렉터리 복사는 -r
rm -r docs_copy                    # ⚠️ 휴지통 없음
ls
```

### 2-5 🐧 Ubuntu — 긴 출력 걸러내기 (파이프 · grep) ⭐

```bash
grep gateway server.txt            # gateway 가 든 줄만
ls /etc | grep net                 # /etc 중 net 이 들어간 이름만
ls -l /etc | less                  # 길면 넘겨 보기 (Space · b · q)
tail -n 5 /etc/passwd              # 마지막 5줄
grep student /etc/passwd           # 내 계정 정보 한 줄
history | tail -n 10               # 방금 친 명령 10개
```

> 🗣 시스코 `show running-config | include hostname` = 리눅스 `cat 파일 | grep hostname`

**✅ STEP 2 체크** — `~/lab/server.txt` (3줄) · `~/lab/docs/memo.bak` 이 있다

---

# ▶ STEP 3 · 권한 · sudo · apt (20분) — [3_사용자_권한_sudo](lesson-3.md)

### 3-1 🐧 Ubuntu — 권한 읽기

```bash
cd ~/lab
ls -l                              # -rw-rw-r-- server.txt · drwxrwxr-x docs
ls -l /etc/shadow                  # -rw-r----- root shadow
cat /etc/shadow                    # ❌ Permission denied
sudo cat /etc/shadow | head -n 3   # ✅ 비밀번호 묻고 → 관리자로
```

### 3-2 🐧 Ubuntu — 실행 파일 만들고 권한 바꾸기

```bash
echo 'echo "안녕, $(whoami)! 지금은 $(date +%H:%M)"' > hello.sh
./hello.sh                         # ❌ Permission denied — x 가 없다
ls -l hello.sh                     # -rw-rw-r--
chmod u+x hello.sh                 # 주인에게 실행 권한
ls -l hello.sh                     # -rwxrw-r--
./hello.sh                         # ✅
chmod 700 hello.sh                 # 주인만 전부
ls -l hello.sh                     # -rwx------
chmod 644 server.txt               # 일반 파일의 표준
ls -l server.txt                   # -rw-r--r--
```

### 3-3 🐧 Ubuntu — 프로그램 설치

```bash
sudo apt update                    # 창고 목록 새로고침 (강의실 전체가 치면 느리다 — 기다리기)
sudo apt install -y tree
tree ~/lab                         # 나무 모양
apt install -y cowsay              # ❌ sudo 없이 → 권한 오류 확인
sudo apt install -y cowsay
/usr/games/cowsay "sudo 는 마스터키"
```

**✅ STEP 3 체크** — `./hello.sh` 가 실행되고 · `tree` 가 설치됐다

---

# ▶ STEP 4 · 리눅스의 네트워크 (15분) — [4_리눅스의_네트워크](lesson-4.md)

### 4-1 🐧 Ubuntu — 3종 세트 찾기 (2일차 회수)

```bash
ip a                               # 전체
ip -br a                           # 한 줄 요약 (show ip int brief 느낌)
ip route                           # default via = 게이트웨이
ip neigh                           # ARP 표 (3일차)
```

- 📝 **메모**: IP ______ / 마스크 ______ / MAC ______ / 게이트웨이 ______ / `dynamic`? ______

### 4-2 🐧 Ubuntu — 가까운 곳부터 차례로 (3일차 회수)

```bash
ping -c 4 192.168.0.1              # ① 게이트웨이(강의실 공유기)
ping -c 4 8.8.8.8                  # ② 인터넷 IP
ping -c 4 google.com               # ③ 이름 → DNS
resolvectl status | grep "DNS Servers"
```

> ❌ ②부터 안 되면 → 강의실 방화벽일 수 있다 → `curl -I https://www.google.com` 으로 확인

**✅ STEP 4 체크** — 메모 5칸이 다 찼다 (`192.168.x.x` · `/24` · `08:00:27:..` · `192.168.0.1` · 예)
> 🔎 **보너스**: 🪟 `ipconfig` 의 게이트웨이와 **같은지** 비교 → 같으면 **브릿지가 제대로 된 것**

---

# ▶ STEP 5 · 🤖 AI 로 묻고 검증하기 (20분) — [5_AI로_명령어_검증](lesson-5.md)

### 5-1 🤖 → 🐧 옵션 뜻 검증

- AI 에게: **"Ubuntu 24.04 에서 `ls -alh` 의 각 옵션 뜻을 알려줘"**

```bash
ls --help | grep -E -- " -a| -l| -h,"     # 문서로 검증 — -h 는 help 가 아니라 human-readable
ls -alh /etc | head -n 5                   # 실제로 보기 — 크기가 4.0K 처럼 나온다
```

### 5-2 📝 → 🤖 출력 해석 (내가 먼저!)

1. STEP 6 메모를 **내가 먼저** 채운다
2. `ip a` 출력을 AI 에게 붙여넣고 **"내 해석이 맞는지, 놓친 게 있는지 알려줘"**
3. 다른 점 → **누가 맞는지** 문서/실험으로 판정

### 5-3 🤖 → 🐧 한 줄 명령 교차 검증

- AI 에게: **"`/etc` 바로 아래에서 `.conf` 로 끝나는 파일 개수를 세는 명령"**

```bash
ls /etc/*.conf | wc -l                               # 방법 1
find /etc -maxdepth 1 -name "*.conf" | wc -l         # 방법 2 — 같은 숫자인가?
```

### 5-4 🕵 틀린 AI 답 찾기 (강사 화면)

- [5_AI로_명령어_검증](lesson-5.md) 의 **과제 4** 를 띄우고 같이 → VM 에서 검증

```bash
chmod 700 hello.sh && ls -l hello.sh       # -rwx------ 확인
```

**✅ STEP 5 체크** — AI 답 중 **최소 하나를 문서 · 실행으로 확인**했다

---

---

# 🌇 오후 · 서버 기초

# ▶ 오후 준비 — 창 3개 · 도구 (10분)

> 📌 **브릿지**라서 포트포워딩 설정이 **필요 없다.** 오후 웹서버도 `192.168.x.x:8080` 으로 바로 열린다.

### 🪟 PowerShell — 탭 2개 더 열어 각각 `ssh student@192.168.x.x` → 창 ① ② ③

### 🐧① — 오후에 쓸 도구 챙기기

```bash
sudo apt update
sudo apt install -y netcat-openbsd tcpdump bind9-dnsutils curl   # 이미 있으면 "already" — 괜찮다
```

# ▶ STEP 6 · 서버 = 문 열고 기다리는 프로그램 (20분) — [6_서버란_무엇인가](lesson-6.md)

### 6-1 🐧③ — 지금 기다리고 있는 프로그램들

```bash
sudo ss -tulnp          # t=TCP u=UDP l=LISTEN n=숫자 p=프로그램
```

- 🔎 `:22` LISTEN (SSH — 9일차에 들어온 문) · `127.0.0.53:53` (DNS 도우미)

### 6-2 🐧① — 1분 웹서버 만들기

```bash
mkdir -p ~/www && cd ~/www
echo "<h1>Hello from Ubuntu - student</h1>" > index.html
python3 -m http.server 8080           # 👉 이 창은 이제 "서버" — 그대로 둔다
```

### 6-3 🐧③ — 문이 하나 생겼다

```bash
ss -tln | grep 8080                   # LISTEN ... 0.0.0.0:8080 ...
```

### 6-4 🐧② — 손님이 되어 요청

```bash
curl localhost:8080                   # <h1>Hello ...
```

- 🔎 🐧① 서버 창에 **`127.0.0.1 - - "GET / HTTP/1.1" 200`** 로그가 찍힌다 (VM 안에서 불렀으니 루프백)

### 6-5 🌐 Windows 브라우저

```
http://192.168.x.x:8080
```

- 🔎 🐧① 로그의 접속자 주소 = **내 Windows IP 그대로** ← 브릿지라 중간에 안 바뀐다 (`ipconfig` 와 대조)

### 6-6 🐧① — 서버를 끄면?

- **Ctrl + C** → 🐧② `curl localhost:8080` → **`Connection refused`** → 🐧③ `ss -tln | grep 8080` → 없다

**✅ STEP 6 체크** — 서버를 켜고 끌 때마다 `ss` 의 LISTEN 이 **생겼다 사라지는 것**을 봤다

---

# ▶ STEP 7 · TCP 3-way handshake 를 눈으로 (25분) — [7_TCP와_UDP](lesson-7.md) ⭐

### 7-1 🐧③ — 관찰 시작 (루프백 · 5000번)

```bash
sudo tcpdump -i lo -n tcp port 5000
```

### 7-2 🐧① — TCP 서버 (5000번에서 기다린다)

```bash
nc -l 5000
```

### 7-3 🐧② — TCP 클라이언트 (접속만, 아직 아무것도 안 친다)

```bash
nc 127.0.0.1 5000
```

- 🔎 🐧③ 에 **정확히 3줄** — 이것이 3-way handshake 다:

```
... 127.0.0.1.41234 > 127.0.0.1.5000: Flags [S],  ...     ① SYN
... 127.0.0.1.5000 > 127.0.0.1.41234: Flags [S.], ...     ② SYN+ACK
... 127.0.0.1.41234 > 127.0.0.1.5000: Flags [.],  ...     ③ ACK
```

### 7-4 🐧② → 🐧① — 채팅

- 🐧② 에 `안녕 서버` Enter → 🐧① 에 나타난다 · 🐧① 에서 답장도 된다
- 🔎 🐧③ 에 `[P.]` (데이터) → `[.]` (받았음 ACK) 가 짝으로 찍힌다 = **등기우편의 서명**

### 7-5 🐧③ — 연결 중 소켓 보기 (tcpdump 를 잠깐 멈추고)

```bash
# Ctrl+C 로 tcpdump 멈춤
ss -tn | grep 5000                    # ESTAB 두 줄 (양쪽 끝의 소켓)
sudo tcpdump -i lo -n tcp port 5000   # 다시 관찰 시작 (↑ 두 번)
```

### 7-6 🐧② — 끊기 · 그리고 "문 없음"

- 🐧② **Ctrl + C** → 🐧③ 에 `[F.]` (FIN — 정중한 종료) · 🐧① 의 `nc` 도 끝난다
- 🐧① 은 이제 아무도 안 기다린다. 🐧② 에서 다시:

```bash
nc 127.0.0.1 5000                     # 즉시 종료 (nc 는 조용히 끝난다)
nc -v 127.0.0.1 5000                  # -v 로 보면: Connection refused
```

- 🔎 🐧③ 에 `[S]` → **`[R.]`** — **RST = "그 문 없어요"** (9일차 `Connection refused` 의 정체)

### 7-7 🐧③ — UDP 는 인사가 없다

- 🐧③ Ctrl+C 후:

```bash
sudo tcpdump -i lo -n udp port 5001
```

- 🐧① `nc -u -l 5001` · 🐧② `nc -u 127.0.0.1 5001` → 🐧② 에 `hello` Enter
- 🔎 🐧③ 에 **handshake 없이 바로** `UDP, length 6` **한 줄**. ACK 도 없다 = **전단지**
- 🐧① · 🐧② · 🐧③ 모두 **Ctrl + C**

**✅ STEP 7 체크** — `[S]` `[S.]` `[.]` 세 줄과, UDP 는 **한 줄**인 것을 봤다

---

# ▶ STEP 8 · 포트 번호 · 소켓 (10분) — [8_포트번호와_소켓](lesson-8.md)

### 8-1 🐧② — 포트표는 파일로 있다

```bash
grep -w -E "ftp|ssh|telnet|domain|http|https|snmp" /etc/services
```

- 🔎 `domain 53/tcp` · `domain 53/udp` — **DNS 는 둘 다** · `ssh 22/tcp`

### 8-2 🐧② — 1023 이하는 root 만

```bash
python3 -m http.server 80             # ❌ PermissionError — Well-known 포트
# Ctrl+C (혹시 떠 있으면)
```

### 8-3 🐧③ — 지금 내 SSH 연결들 (소켓 4개 값)

```bash
ss -tn | grep :22
```

```
ESTAB 0 0  192.168.0.42:22   192.168.0.7:50514     ← 창 ①
ESTAB 0 0  192.168.0.42:22   192.168.0.7:50522     ← 창 ②   (상대 포트가 다르다 → 안 섞인다)
ESTAB 0 0  192.168.0.42:22   192.168.0.7:50530     ← 창 ③
```

- 🔎 상대 주소가 전부 **내 Windows IP** = `ipconfig` 결과와 같다 → **브릿지**

**✅ STEP 8 체크** — 같은 22번에 붙은 3개 연결이 **상대 포트로** 구분되는 걸 봤다

---

# ▶ STEP 9 · NAT 와 포트포워딩 (20분) — [9_NAT와_포트포워딩](lesson-9.md) ⭐

### 9-1 🐧② · 🪟 · 🌐 — 나는 몇 번 변장하나

```bash
ip -br a | grep enp0s3                # 🐧 VM 안:      192.168.x.x/24  (사설)
ip route | grep default               # 🐧 게이트웨이: 192.168.0.1 ← 강의실 공유기
curl -s ifconfig.me ; echo            # 🌐 인터넷이 본 나: 공인 IP
```

```powershell
ipconfig                              # 🪟 Windows: 192.168.x.y — 게이트웨이가 VM 과 같다!
```

- 🗣 **"다 같이 공인 IP 를 불러봅시다"** → 강의실 전원이 **같은 IP** = PAT
- 📝 `192.168.___.___` (사설) ──NAT──▶ `____.____.____.____` (공인)

### 9-2 🐧① · 🌐 — 안에서 밖으로는 되는데, 밖에서 안으로는?

```bash
cd ~/www && python3 -m http.server 8080
```

- 🌐 내 Windows 에서 `http://192.168.x.x:8080` → **된다** (같은 동네 = 브릿지)
- 🙋 옆자리 PC 에서도 → **된다** (같은 동네)
- 🗣 **"그런데 집에서, 휴대폰 데이터로 이 주소를 치면 될까요?"** → **안 된다**
  - 강의실 공유기가 **NAT** 로 안쪽을 숨기고 있다 → 들어오려면 **포트포워딩**이 필요
  - 📌 지금은 **설정하지 않는다.** 11일차 PT 공유기에서 직접 뚫어 본다

**✅ STEP 9 체크** — **"나갈 때는 NAT 가 알아서, 들어올 때는 포트포워딩이 있어야"** 를 내 말로 설명할 수 있다
> ⚠️ 같은 동네라 **누구나 내 서버에 닿는다** — 이게 11일차의 출발점 → [11일차](../day-11/lesson-3.md)

---

# ▶ STEP 10 · DNS · DHCP 리눅스판 (20분) — [10_DNS와_DHCP_다시보기](lesson-10.md)

### 10-1 🐧② — 누구에게 묻나

```bash
cat /etc/resolv.conf | grep nameserver     # 127.0.0.53 — 내 안의 도우미
resolvectl status | grep "DNS Servers"     # 도우미가 실제로 묻는 서버
```

### 10-2 🐧② — dig 로 레코드 조회

```bash
dig www.google.com                    # ANSWER · TTL · SERVER 줄 읽기 (UDP 53 확인!)
dig www.google.com | grep "Query time" # 한 번 더 → 캐시로 빨라진다
dig +short www.naver.com              # CNAME 별명을 거쳐 IP 로
dig +short MX gmail.com               # 메일 서버 (12일차)
dig +short -x 8.8.8.8                 # 역방향: IP → 이름
```

### 10-3 🐧② — `/etc/hosts` 가 DNS 보다 먼저

```bash
sudo cp /etc/hosts /etc/hosts.bak     # 설정 고치기 전엔 백업 (9일차 습관)
sudo nano /etc/hosts
```

- 맨 아래에 한 줄 추가 → Ctrl+O · Enter · Ctrl+X

```
127.0.0.1   myserver.local
```

```bash
ping -c 2 myserver.local              # 127.0.0.1 로 간다
curl myserver.local:8080              # 🐧① 웹서버가 떠 있으면 이름으로 접속!
dig +short myserver.local             # ❓ 답이 없다 — dig 는 hosts 를 안 보고 DNS 에만 묻는다
```

### 10-4 🐧② — DHCP 임대 확인

```bash
ip a show enp0s3 | grep -A1 "inet "   # dynamic · valid_lft = 임대 남은 시간
sudo cat /etc/netplan/*.yaml          # dhcp4: true
```

- 🐧① 웹서버 **Ctrl + C** (이제 VM 실습 끝)

**✅ STEP 10 체크** — `myserver.local` 로 접속됐고 · `valid_lft` 를 찾았다

---

# ▶ 마무리 · 끄기

```bash
sudo poweroff                      # VM 종료 (SSH 연결도 끊긴다 — 정상)
```

> 📌 **VM 은 지우지 않는다.** 11 · 12일차에도 **이 VM 을 계속** 쓴다.

---

# 📚 부록 A · 오늘 새로 나온 명령 사전

### 오전 — 리눅스 기본

| 명령 | 뜻 (약자) | 예 |
|------|-----------|----|
| `pwd` | **p**rint **w**orking **d**irectory | `pwd` |
| `ls` | **l**i**s**t | `ls -al` |
| `cd` | **c**hange **d**irectory | `cd /etc` · `cd ..` · `cd` |
| `mkdir` | **m**a**k**e **dir**ectory | `mkdir -p a/b` |
| `touch` | 빈 파일 만들기 | `touch a.txt` |
| `cp` | **c**o**p**y | `cp -r src dst` |
| `mv` | **m**o**v**e (이름 바꾸기) | `mv a b` |
| `rm` | **r**e**m**ove ⚠️ | `rm -r dir` |
| `cat` | con**cat**enate — 내용 출력 | `cat a.txt` |
| `less` · `head` · `tail` | 넘겨보기 · 앞 · 뒤 | `tail -n 5 a` |
| `nano` | 편집기 | `nano a.txt` |
| `grep` | 줄 찾기 | `grep -i word file` |
| `echo` | 글자 출력 | `echo hi >> a` |
| `chmod` | **ch**ange **mod**e (권한) | `chmod 755 a` |
| `chown` | **ch**ange **own**er | `sudo chown root:root a` |
| `ip` | 네트워크 확인 | `ip a` · `ip route` |
| `man` · `--help` | 도움말 | `man ls` (q 종료) |
| `history` | 친 명령 기록 | `history \| tail` |

### 오후 — 서버 기초

| 명령 | 뜻 | 예 |
|------|----|----|
| `ss -tulnp` | 열린 포트 · 누가 LISTEN | `sudo ss -tulnp` |
| `ss -tn` | 맺어진 TCP 연결 (소켓) | `ss -tn \| grep :22` |
| `python3 -m http.server` | 1분 웹서버 | `python3 -m http.server 8080` |
| `curl` | 웹 요청 (클라이언트) | `curl localhost:8080` · `curl -s ifconfig.me` |
| `nc` (netcat) | TCP/UDP 로 직접 말 걸기 | `nc -l 5000` · `nc -u 127.0.0.1 5001` |
| `tcpdump` | 패킷 엿보기 | `sudo tcpdump -i lo -n tcp port 5000` |
| `dig` | DNS 조회 | `dig +short MX gmail.com` |
| `resolvectl` | DNS 설정 확인 | `resolvectl status` |
| `/etc/services` | 포트 번호표 | `grep -w ssh /etc/services` |
| `/etc/hosts` | 이름 수첩 | `sudo nano /etc/hosts` |
| `/etc/netplan/*.yaml` | 네트워크 설정 | `sudo cat /etc/netplan/*.yaml` |

---

# ⚠️ 부록 B · 안 될 때 30초 점검 (오늘판)

| 증상 | 원인 | 해결 |
|------|------|------|
| `No such file or directory` | **오타 · 대소문자 · 위치** | `pwd` · `ls` 로 위치 확인 · **Tab** |
| `Permission denied` | 권한 없음 | 내 파일이면 `chmod` · 시스템이면 `sudo` |
| `Could not get lock /var/lib/dpkg/lock` | 백그라운드 자동 업데이트 중 | 1~2분 기다렸다 다시 |
| 화면이 멈췄다 (`ping` · `tail -f` · 서버) | 끝나지 않는 명령 | **Ctrl + C** |
| vim 에 갇혔다 | `vi` 로 열었다 | **Esc → `:q!` → Enter** |
| 🌐 `192.168.x.x:8080` 안 열림 | ① 🐧① 서버 꺼짐 ② 주소를 잘못 봄 | ① `ss -tln \| grep 8080` ② `ip a` 재확인 |
| `Address already in use` | 그 포트에 **이미 서버가** 떠 있다 | 다른 창에서 떠 있는 것 Ctrl+C · 또는 다른 포트 |
| `tcpdump` 에 아무것도 안 나온다 | 인터페이스 · 포트 틀림 | 루프백 실습은 **`-i lo`** · 포트 번호 확인 |
| `nc: command not found` · `dig: command not found` | 미설치 | 오후 준비의 `apt install` |
| `sudo nano /etc/hosts` 후 이상해짐 | 오타 | `sudo cp /etc/hosts.bak /etc/hosts` (백업의 힘) |
