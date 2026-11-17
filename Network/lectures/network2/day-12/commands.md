# 0. 12일차 실습 명령어 — 수업 흐름 그대로 (이어치기 대본)

> 상위: [12일차 · 리눅스 서버 구축](README.md)
> **위에서 아래로 그대로 따라 치면 오늘 실습이 끝난다.** 실습 중 화면에 띄워두거나 인쇄해 나눠줄 것.
> 📌 9일차에 만든 **같은 VM** 을 계속 쓴다. 오늘은 그 위에 **서버를 여섯 개** 올린다.

## 📌 읽는 법 — 10일차 약속 그대로

- 블록 하나 = **한 창에서 끊지 않고 이어 치는 한 덩어리**
- `🪟` = Windows PowerShell · `🖱` = 마우스(VirtualBox) · `🌐` = Windows 브라우저
- `🐧①` **작업 창** (설치 · 설정 — 오늘의 메인) · `🐧②` **클라이언트 창** (손님이 되어 접속) · `🐧③` **관찰 창** (`tcpdump` · `tail -f`)
- `# 뒤 회색 글씨` = 설명. 안 쳐도 된다 · `$` 는 치지 않는다
- ⚠️ **오늘은 설정 파일을 고친다. 고치기 전 `.bak` 백업은 생략 금지.**

## 🗺 오늘의 그림 — 여섯 단계를 **세 번**

```
 ① apt install  →  ② nano /etc/…  →  ③ systemctl restart  →  ④ ss -tulnp  →  ⑤ ufw allow  →  ⑥ 클라이언트로 검증
     SSH(22) · FTP(21) · NFS(2049) · DNS(53) · Mail(25) · Proxy(3128)
```

---

# ▶ STEP 0 · 몸풀기 — VM 켜고 창 3개 (10분)

### 0-1 🖱 VirtualBox — VM 시작 (헤드리스 시작)

### 0-2 🪟 PowerShell — 창 3개를 열고 각각 접속

```powershell
ip a                                  # 🐧 먼저 오늘의 IP 확인 (브릿지+DHCP 라 바뀐다)
ssh student@192.168.x.x
```

> 창마다 `🐧①` `🐧②` `🐧③` 라고 **제목을 붙여** 두면 헷갈리지 않는다 (10일차와 같은 약속)

### 0-3 🐧① — 어제까지의 서버가 살아 있나

```bash
sudo systemctl status ssh --no-pager    # active (running)
sudo ss -tulnp                          # 지금 열린 포트: 22 · 53(127.0.0.53) 정도
ip -br a                                # 내 IP: 192.168.x.x
```

> 🗣 칠판: **"① 설치 ② 설정 ③ 기동 ④ 확인 ⑤ 개방 ⑥ 검증"** — **오늘 하루 지우지 않는다**

---

# ▶ STEP 1 · 여섯 단계 + 방화벽 켜기 (5분) — [1_서버구축의_공통문법](lesson-1.md) ⭐⭐

### 1-1 🐧① — systemctl 4형제 (이미 있는 SSH 로 연습)

```bash
systemctl status ssh --no-pager | head -5
systemctl is-enabled ssh            # enabled  ← 부팅 때 자동 시작
systemctl is-active ssh             # active
sudo systemctl restart ssh          # 껐다 켜기 (지금 접속은 유지된다)
```

### 1-2 🐧① — 로그 읽는 연습

```bash
journalctl -u ssh -n 15 --no-pager    # 최근 15줄
```

### 1-3 🐧① — 방화벽을 **오늘 처음 켠다** 🚨 (11일차 이월)

> 🚨 **순서 엄수.** 바꿔 치면 SSH 창이 그 자리에서 끊긴다.
> 🆘 복구: **VirtualBox 창 → 로그인 → `sudo ufw disable`** (칠판에 적어 둘 것)

```bash
sudo ufw status                       # Status: inactive   ← 아직 아무것도 안 막혀 있다

sudo ufw allow 22/tcp                 # ⭐⭐ ① 먼저 내 통로부터!
sudo ufw enable                       # ② 그 다음에 켠다   (Proceed? → y)

sudo ufw status verbose               # Default: deny (incoming) 확인
```

- 🔎 **창이 안 끊긴다** — 22번을 먼저 열었으니까. 여기서 "순서"의 의미가 몸에 남는다
- 🗣 **"지난주 ACL 은 라우터에서 막았죠. 오늘부터는 서버가 스스로 막습니다."**

**✅ STEP 1 체크** — `start` 와 `enable` 의 차이를 말할 수 있다 · `ufw status` 가 **active** 다

---

# ▶ STEP 2 · SSH 를 제대로 (25분) — [2_SSH_다시보기와_파일전송](lesson-2.md)

### 2-1 🐧① — ② 설정: 백업하고 열기

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
grep -v '^#' /etc/ssh/sshd_config | grep -v '^$'     # 실제로 살아 있는 설정만
sudo nano /etc/ssh/sshd_config
```

**고칠 줄 — `PermitRootLogin` 을 찾아 (`Ctrl+W` 로 검색)**

```
PermitRootLogin no
```

> 💾 나가기: `Ctrl+O` → `Enter` → `Ctrl+X`

### 2-2 🐧① — 문법 검사 → ③ 기동

```bash
sudo sshd -t                     # ⭐ 조용하면 정상. 오타가 있으면 줄 번호를 알려준다
sudo systemctl restart ssh
```

### 2-3 🪟 **새 창** — ⑥ 검증 (지금 창은 절대 닫지 않는다!)

```powershell
ssh student@192.168.x.x        # 들어가지면 성공
```

### 2-4 🪟 — 공개키 만들기

```powershell
ssh-keygen -t ed25519                # Enter 3번 (암호는 비워도 된다)
type $env:USERPROFILE\.ssh\id_ed25519.pub      # 공개키 확인 (ssh-ed25519 AAAA... 로 시작)
```

### 2-5 🪟 — 공개키를 서버에 심기 (한 줄, 통째로 복사)

```powershell
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh student@192.168.x.x "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

### 2-6 🪟 — ⑥ 검증: 이제 비밀번호를 묻지 않는다

```powershell
ssh student@192.168.x.x        # 바로 들어가진다 ⭐
```

> ❗ 여전히 비밀번호를 묻는다면 → `🐧①` 에서 `ls -ld ~/.ssh` (drwx------) · `ls -l ~/.ssh/authorized_keys` (-rw-------) 확인
> → 그래도 안 되면 `sudo journalctl -u ssh -n 20 --no-pager` 에 이유가 찍혀 있다

### 2-7 🪟 — 파일 옮기기 (`scp` 는 **대문자 -P**)

```powershell
echo hello > hello.txt
scp hello.txt student@192.168.x.x:~/          # 올리기
scp student@192.168.x.x:/etc/hostname .       # 내려받기
```

**✅ STEP 2 체크** — `sshd_config` 와 `ssh_config` 의 차이, `-p` 와 `-P` 의 차이를 말할 수 있다

---

# ▶ STEP 3 · FTP 서버 (25분) — [3_FTP서버_vsftpd](lesson-3.md) ⭐

### 3-1 🐧① — ① 설치

```bash
sudo apt update
sudo apt install vsftpd ftp -y      # 서버 + 검증용 클라이언트
```

### 3-2 🐧① — ② 설정

```bash
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
sudo nano /etc/vsftpd.conf
```

> ✅ **Ubuntu 24.04 기본 `vsftpd.conf` 실측 결과** — 항목마다 할 일이 다르다

| 줄 | 항목 | 기본 상태 | 할 일 |
|----|------|-----------|-------|
| 25 | `anonymous_enable=NO` | **이미 NO** | 그대로 (확인만) |
| 28 | `local_enable=YES` | **이미 YES** | 그대로 (확인만) |
| 31 | `write_enable=YES` | `#` 주석 | **주석 해제** |
| 114 | `chroot_local_user=YES` | `#` 주석 | **주석 해제** |
| — | `allow_writeable_chroot=YES` | **파일에 없다** | **맨 아래에 새로 추가** ⚠️ |
| — | `pasv_min_port=40000` | **파일에 없다** | **맨 아래에 새로 추가** |
| — | `pasv_max_port=40010` | **파일에 없다** | **맨 아래에 새로 추가** |

**→ 결국 맨 아래에 이 세 줄을 붙이고, 위 두 줄(31 · 114)의 `#` 만 지우면 된다**

```
allow_writeable_chroot=YES
pasv_min_port=40000
pasv_max_port=40010
```

> 🚨 **`chroot_local_user=YES` 만 켜고 `allow_writeable_chroot=YES` 를 빠뜨리면**
> `500 OOPS: vsftpd: refusing to run with writable root inside chroot()` 로 **접속이 거부된다.** 오늘 1번 함정.

### 3-3 🐧① — ③ 기동 · ④ 확인

```bash
sudo systemctl restart vsftpd
systemctl status vsftpd --no-pager | head -5
sudo ss -tulnp | grep -E ':21 '           # 0.0.0.0:21 LISTEN
```

> ❗ 실패하면: `sudo journalctl -u vsftpd -n 20 --no-pager` → `refusing to run with writable root inside chroot()` 면 **`allow_writeable_chroot=YES`** 를 빠뜨린 것

### 3-4 🐧① — ⑤ 개방 (ufw 를 쓰는 경우만)

```bash
sudo ufw allow 21/tcp
sudo ufw allow 40000:40010/tcp
```

### 3-5 🐧② — ⑥ 검증: 손님이 되어 본다

```bash
cd ~ ; echo "FTP 로 올릴 파일" > upload.txt
ftp localhost
```

```
Name: student          ← 리눅스 계정
Password:              ← 비밀번호 (화면에 안 보인다)
ftp> ls
ftp> put upload.txt
ftp> ls
ftp> get upload.txt downloaded.txt
ftp> bye
```

### 3-6 🐧③ — ⭐⭐ 평문의 증거: 비밀번호를 눈으로 본다

**먼저 `🐧③` 에서 엿듣기 시작**

```bash
sudo tcpdump -i lo -n -A 'tcp port 21'
```

**그 상태에서 `🐧②` 에서 다시 접속**

```bash
ftp localhost                 # 로그인만 하고 bye
```

> `🐧③` 화면에 **`USER student`** · **`PASS ...`** 가 그대로 뜬다 ⚠️ → `Ctrl + C` 로 멈춤
> 🗣 **"지금 이 비밀번호가 회사 스위치를 지나갔다면?"**

### 3-7 🐧③ + 🐧② — 비교: 암호화된 통로는 어떻게 보이나

```bash
sudo tcpdump -i lo -n -A 'tcp port 22'      # 🐧③ 에서 엿듣기
```

```bash
sftp student@192.168.x.x              # 🐧② 에서 (바로 bye)
```

> 알아볼 수 없는 글자만 흐른다 = **암호화** ⭐

**✅ STEP 3 체크** — FTP 가 연결을 **두 개** 쓰는 이유와, 평문이 왜 문제인지 말할 수 있다

---

# 🅿️ STEP 4 · NFS 파일 공유 — **오늘 안 함 → 13일차** — [4_NFS_파일공유](lesson-4.md)

> 📌 4시간에 맞추려고 뺐다. 아래는 **13일차용 대본**이다.

### 4-1 🐧① — ① 설치 · ② 설정

```bash
sudo apt install nfs-kernel-server -y
sudo mkdir -p /srv/share
echo "NFS 로 공유되는 파일" | sudo tee /srv/share/hello.txt
sudo chown nobody:nogroup /srv/share
sudo nano /etc/exports
```

**맨 아래에 한 줄 추가**

```
/srv/share  127.0.0.1(rw,sync,no_subtree_check)
```

### 4-2 🐧① — ③ 기동 · ④ 확인

```bash
sudo exportfs -ra                  # exports 다시 읽기
sudo exportfs -v                   # 내주는 목록
sudo ss -tulnp | grep 2049
showmount -e 127.0.0.1             # 밖에서 본 공유 목록
```

### 4-3 🐧② — ⑥ 검증: 마운트해서 붙여 본다

```bash
sudo mkdir -p /mnt/share
sudo mount -t nfs 127.0.0.1:/srv/share /mnt/share
df -h | grep share                 # 목록에 나타난다 ⭐
ls -l /mnt/share
cat /mnt/share/hello.txt
```

### 4-4 🐧② — 같은 파일임을 확인

```bash
echo "클라이언트가 추가한 줄" | sudo tee -a /mnt/share/hello.txt
cat /srv/share/hello.txt           # ⭐ 서버 쪽에도 즉시 반영 — 복사한 적이 없다
sudo umount /mnt/share             # 빼기
ls /mnt/share                      # 다시 비었다
```

**✅ STEP 4 체크** — 파일 **전송**과 **공유**의 차이를 한 문장으로 말할 수 있다

---

# ▶ STEP 5 · DNS 서버 (30분) — [5_DNS서버_bind9](lesson-5.md) ⭐

### 5-1 🐧① — ① 설치

```bash
sudo apt install bind9 bind9-utils bind9-dnsutils -y
```

### 5-2 🐧① — ② 설정 (1) 듣는 주소 지정 ⚠️ 가장 중요

```bash
sudo cp /etc/bind/named.conf.options /etc/bind/named.conf.options.bak
sudo nano /etc/bind/named.conf.options
```

**`options {` 바로 아래에 추가**

```
        listen-on port 53 { 127.0.0.1; 192.168.x.x; };   # ⚠️ 내 IP 는 ip a 로 확인 (any 쓰지 말 것!)
        listen-on-v6 { none; };
        forwarders { 8.8.8.8; 1.1.1.1; };
        allow-query { any; };
```

> ⚠️ 이걸 안 하면 `systemd-resolved` 와 53번이 부딪쳐 **`Address already in use`** 로 죽는다

### 5-3 🐧① — ② 설정 (2) 존 선언

```bash
sudo nano /etc/bind/named.conf.local
```

```
zone "student.local" {
    type master;
    file "/etc/bind/db.student.local";
};
```

### 5-4 🐧① — ② 설정 (3) 존 파일 — 템플릿을 복사해서 고친다

```bash
sudo cp /etc/bind/db.local /etc/bind/db.student.local
sudo nano /etc/bind/db.student.local
```

**아래 모양이 되도록 고친다 (끝의 점 `.` 주의!)**

```
$TTL    604800
@   IN  SOA ns1.student.local. admin.student.local. (
            2026092001  ; Serial
            604800      ; Refresh
            86400       ; Retry
            2419200     ; Expire
            604800 )    ; Negative TTL
;
@       IN  NS      ns1.student.local.
ns1     IN  A       192.168.x.x
www     IN  A       192.168.x.x
web     IN  CNAME   www.student.local.
@       IN  MX  10  mail.student.local.
mail    IN  A       192.168.x.x
```

### 5-5 🐧① — 문법 검사 → ③ 기동 → ④ 확인

```bash
sudo named-checkconf                                            # 조용하면 정상
sudo named-checkzone student.local /etc/bind/db.student.local   # OK: loaded serial 2026092001
sudo systemctl restart named
systemctl status named --no-pager | head -5
sudo ss -tulnp | grep ':53 '                                    # 127.0.0.1:53 · 192.168.x.x:53 (tcp · udp)
```

> ❗ 실패하면 **반드시** `sudo journalctl -u named -n 30 --no-pager`

### 5-6 🐧② — ⑥ 검증: 내 DNS 서버에 직접 묻는다

```bash
dig @127.0.0.1 www.student.local +short        # 192.168.x.x
dig @127.0.0.1 web.student.local               # CNAME → A
dig @127.0.0.1 student.local MX +short         # 10 mail.student.local.
dig @127.0.0.1 nosuch.student.local | head -8 # status: NXDOMAIN
dig @127.0.0.1 www.google.com +short           # forwarders 가 대신 찾아온다
dig @127.0.0.1 www.student.local | grep flags  # flags: ... aa  ← 내가 주인이다 ⭐
```

### 5-7 🐧① — ⭐ 각자 해보기: 레코드 추가 + Serial 올리기

```bash
sudo nano /etc/bind/db.student.local
```

```
ftp     IN  A       192.168.x.x        ← 한 줄 추가
2026092002  ; Serial                 ← Serial 을 1 올린다 (필수!)
```

```bash
sudo named-checkzone student.local /etc/bind/db.student.local
sudo systemctl reload named
dig @127.0.0.1 ftp.student.local +short        # 192.168.x.x
```

**✅ STEP 5 체크** — 고치고 → **검사 → 재시작 → dig** 4단계를 혼자 돌릴 수 있다

---

# 🅿️ STEP 6 · 메일 서버 맛보기 — **오늘 안 함 → 13일차** — [6_메일서버_원리](lesson-6.md)

> 📌 4시간에 맞추려고 뺐다. 아래는 **13일차용 대본**이다.

### 6-1 🐧① — ① 설치 (파란 화면 주의)

```bash
sudo apt install postfix mailutils -y
```

> 🖱 설치 중 파란 화면 → **`Local only`** 선택 (Tab 으로 이동, Enter 로 확정) · 메일 이름은 기본값 그대로
> ⚠️ `Internet Site` 를 고르지 말 것

### 6-2 🐧① — ④ 확인

```bash
systemctl status postfix --no-pager | head -5
sudo ss -tulnp | grep ':25 '        # 127.0.0.1:25 — 나 자신에게만 열려 있다
```

### 6-3 🐧② — ⑥ 검증: SMTP 대화를 손으로 친다 ⭐

```bash
nc localhost 25
```

**서버가 `220 ...` 으로 인사하면, 아래를 한 줄씩 (응답 `250` 을 확인하며)**

```
HELO student.local
MAIL FROM:<student@localhost>
RCPT TO:<student@localhost>
DATA
Subject: 12일차 첫 메일

리눅스 서버가 보낸 편지입니다.
.
QUIT
```

> ⚠️ **마침표 한 개만 있는 줄(`.`)** 이 "본문 끝" 신호다

### 6-4 🐧② — 도착했나

```bash
mail                                   # 목록 → 번호 Enter 로 읽기 → q 로 나가기
cat /var/mail/student | tail -20
sudo tail -20 /var/log/mail.log        # 배달 기록 ⭐
```

### 6-5 🐧② — 진짜 도메인의 메일 설정 구경

```bash
dig +short MX gmail.com
dig +short TXT gmail.com | head -3     # v=spf1 ... (발신자 인증)
```

**✅ STEP 6 체크** — `MAIL FROM` 에 아무 주소나 쓸 수 있다는 사실이 무엇을 뜻하는지 말할 수 있다

---

# 🅿️ STEP 7 · 프록시 서버 — **오늘 안 함 → 13일차** — [7_Proxy서버_squid](lesson-7.md)

> 📌 4시간에 맞추려고 뺐다. 아래는 **13일차용 대본**이다.

### 7-1 🐧① — ① 설치 · ④ 확인

```bash
sudo apt install squid -y
systemctl status squid --no-pager | head -5
sudo ss -tulnp | grep 3128
```

### 7-2 🐧③ — 기록을 실시간으로 지켜본다

```bash
sudo tail -f /var/log/squid/access.log
```

### 7-3 🐧② — ⑥ 검증: 프록시를 거쳐 나가 본다

```bash
curl -I http://example.com                                 # 직접
curl -I -x http://127.0.0.1:3128 http://example.com        # 프록시 경유 ⭐
curl -I -x http://127.0.0.1:3128 http://example.com        # 한 번 더 → TCP_HIT 가 보이면 캐시
```

> `🐧③` 에 `TCP_MISS/200` → `TCP_HIT/200` 순서로 찍힌다 (사이트가 캐시를 허용할 때)

### 7-4 🐧① — ② 설정: 사이트 차단 규칙

```bash
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.bak
sudo nano /etc/squid/squid.conf
```

**`http_access deny all` **위쪽**에 두 줄 추가** (순서가 중요하다!)

```
acl blocked_sites dstdomain .example.com
http_access deny blocked_sites
```

```bash
sudo squid -k parse > /dev/null && echo "문법 OK"
sudo systemctl restart squid
```

### 7-5 🐧② — 막혔나 확인

```bash
curl -I -x http://127.0.0.1:3128 http://example.com        # 403 Forbidden ⭐
curl -I -x http://127.0.0.1:3128 http://neverssl.com       # 이건 된다
```

> `🐧③` 로그: `TCP_DENIED/403` — **누가 · 언제 · 어디를 시도했는지**까지 남는다

**✅ STEP 7 체크** — 프록시가 **7계층**에서 본다는 말의 뜻을 NAT 와 비교해 말할 수 있다

---

# ▶ STEP 8 · 정리 — 오늘 연 문을 세어 본다 (10분) — [8_서비스_정리와_문제해결](lesson-8.md)

### 8-1 🐧① — 오늘 연 포트 전부

```bash
sudo ss -tulnp | grep LISTEN
sudo ss -tulnp | grep -E ':(21|22|53) '          # 오늘 세운 세 개
```

> 🗣 **"아침엔 22번 하나였습니다. 지금은 세 개죠. 전부 남이 두드릴 수 있는 문입니다."**

### 8-2 🐧① — 자동 시작 상태 점검

```bash
systemctl is-enabled ssh vsftpd named
```

### 8-3 🐧① — 안 쓰는 서비스는 끈다 (공격 표면 줄이기) ⭐

```bash
sudo systemctl disable --now vsftpd      # 예: FTP 는 평문이라 평소엔 끈다
sudo ss -tulnp | grep :21                # 사라졌다
```

### 8-4 🐧① — 방화벽 상태 남기기

```bash
sudo ufw status numbered
```

**✅ STEP 8 체크** — 서비스가 안 될 때 **`localhost 는 되나요?`** 로 문제를 반 쪼개는 법을 말할 수 있다

---

# 📎 부록 A · Windows 에서 FTP 로 접속하기 (선택)

> ⚠️ **리허설 필수.** 패시브 포트까지 포워딩해야 해서 규칙이 여러 개 필요하다.

1. 🖱 VirtualBox → 설정 → 네트워크 → 고급 → **포트 포워딩**
   - `ftp` : 호스트 `2121` → 게스트 `21`
   - `ftp-pasv` : 40000~40010 을 **한 줄씩** (또는 범위를 좁혀 2~3개만)
2. 🐧① `/etc/vsftpd.conf` 에 추가 후 재시작

```
pasv_address=127.0.0.1
pasv_addr_resolve=NO
```

3. 🪟 FileZilla 등으로 `127.0.0.1` · 포트 `2121` · 계정 `student`

> 🗣 **"규칙을 열 줄 넘게 만들어야 겨우 됩니다. 그래서 요즘은 SFTP 를 씁니다."** — 이것 자체가 좋은 결론이다

---

# 📎 부록 B · 옆자리 VM 과 NFS 공유 (선택)

> ⚠️ VirtualBox **NAT** 어댑터끼리는 서로 통신이 **안 된다**. 하려면 VM 설정에서 **어댑터 2 = 호스트 전용(Host-only)** 또는 **NAT 네트워크**를 추가해야 한다. **리허설 필수**

```bash
ip -br a                                        # 새 어댑터의 IP 확인 (예: 192.168.56.10)
sudo nano /etc/exports                          # 허용 대상을 192.168.56.0/24 로
sudo exportfs -ra
```

```bash
showmount -e 192.168.56.10                      # 상대 서버가 내주는 목록
sudo mount -t nfs 192.168.56.10:/srv/share /mnt/share
```

---

# 📎 부록 C · 오늘의 명령어 한 장

| 명령 | 뜻 | 예 |
|------|----|-----|
| `systemctl status/restart/reload` | 서비스 상태 · 재시작 · 설정만 다시 읽기 | `sudo systemctl restart named` |
| `systemctl enable --now` | 지금 켜고 + 자동 시작 | `sudo systemctl enable --now vsftpd` |
| `systemctl is-enabled/is-active` | 자동 시작하나 / 떠 있나 | `systemctl is-enabled squid` |
| `journalctl -u <서비스>` | **그 서비스의 로그** ⭐ | `journalctl -u named -n 30 --no-pager` |
| `ss -tulnp` | 열린 포트 · 누가 LISTEN | `sudo ss -tulnp \| grep :53` |
| `sshd -t` · `named-checkconf` · `squid -k parse` | **문법 검사** | 기동 전에 꼭 |
| `scp -P` · `sftp -P` | 파일 전송 (SSH 위) | `scp a.txt student@192.168.x.x:~/` |
| `ftp` | FTP 클라이언트 | `ftp localhost` |
| `exportfs -ra` · `showmount -e` | NFS 내보내기 · 목록 | `sudo exportfs -v` |
| `mount -t nfs` · `umount` · `df -h` | 붙이기 · 빼기 · 확인 | `sudo mount -t nfs 127.0.0.1:/srv/share /mnt/share` |
| `dig @서버 이름 [타입]` | DNS 질의 | `dig @127.0.0.1 www.student.local +short` |
| `nc <호스트> <포트>` | 포트에 직접 말 걸기 | `nc localhost 25` |
| `curl -x` | 프록시 경유 요청 | `curl -I -x http://127.0.0.1:3128 http://example.com` |
| `tcpdump -i lo -n -A 'tcp port N'` | 내용까지 엿보기 | `sudo tcpdump -i lo -n -A 'tcp port 21'` |
| `tail -f /var/log/...` | 로그 실시간 | `sudo tail -f /var/log/mail.log` |

---

# ⚠️ 부록 D · 안 될 때 30초 점검 (오늘판)

| 증상 | 원인 | 해결 |
|------|------|------|
| `Job for X.service failed` | **설정 오타** | `journalctl -u X -n 30 --no-pager` ⭐ |
| `Address already in use` (named) | `systemd-resolved` 가 53 을 쥠 | `listen-on` 에 **주소를 지정** (5-2) |
| 설정을 고쳤는데 그대로 | **③ 기동을 안 했다** | `sudo systemctl restart <서비스>` |
| `dig` 결과가 예전 값 | **Serial 을 안 올렸다** · 캐시 TTL | Serial +1 → `reload` |
| vsftpd `500 OOPS: ... writable root` | `chroot` 설정 짝 | `allow_writeable_chroot=YES` |
| FTP 로그인은 되는데 `ls` 가 멈춤 | **데이터 연결** 차단 | 패시브 포트 범위 · 방화벽 |
| SSH 키를 넣었는데 비밀번호를 물음 | `~/.ssh` **권한** | `chmod 700 ~/.ssh` · `chmod 600 authorized_keys` |
| `scp: Permission denied` | 쓸 수 없는 위치 | 홈(`~/`)으로 보낸다 |
| `mount.nfs: access denied` | `/etc/exports` 의 **허용 IP** | `exportfs -v` 로 확인 후 `exportfs -ra` |
| `nc localhost 25` 에서 아무 응답 없음 | postfix 미기동 · 포트 다름 | `ss -tulnp \| grep :25` |
| `curl -x` 가 `403` | 내가 만든 **차단 규칙** | 의도대로 동작한 것! |
| `localhost` 는 되는데 밖에서 안 됨 | LISTEN 주소(`127.0.0.1` 전용?) · **`ufw`** | 8번 노트 ② 5단계 |
| 화면이 멈췄다 (`tcpdump` · `tail -f`) | 끝나지 않는 명령 | **Ctrl + C** |
