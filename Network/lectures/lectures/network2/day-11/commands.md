# 0. 11일차 실습 명령어 — 수업 흐름 그대로 (이어치기 대본)

> 상위: [11일차 · 서버 보안](README.md) · PT 실습 해설은 [1_공유기_실습](lesson-1.md)
> 📌 **STEP 1 · 2** 는 10일차에서 이월된 **공유기 실습**(📦 PT · 유선), **STEP 3~7 + 마무리**가 서버 보안(📦 PT ACL · 🐧 ufw)이다.
> 📌 **무선랜은 다루지 않는다.**
> **위에서 아래로 그대로 따라 치면 된다.** 실습 중 화면에 띄워두거나 인쇄해 나눠줄 것.

## 📌 읽는 법

- `🖱` = 마우스 (패킷트레이서 GUI) · `🔁` = 라우터 CLI · `🖥` = PC 의 Command Prompt
- `# 뒤 회색 글씨` = 설명. 안 쳐도 된다

---

# ▶ STEP 1 · 📦 PT — 우리 집 공유기 (30분 · 유선) — [1_공유기_실습](lesson-1.md) ⭐

> 🎒 새 파일 `11일차_공유기.pkt`

### 1-1 🖱 장비 놓기

| 장비 | PT 에서 | 이름 |
|------|---------|------|
| 공유기 | Wireless Devices → **WRT300N** | `HomeRouter` |
| ISP 라우터 | Routers → **2911** | `ISP` |
| 인터넷 서버 | End Devices → **Server** | `Internet` |
| 유선 PC | PC | `PC0` |
| 유선 PC | PC | `PC1` |

> 📌 WRT300N 을 쓰지만 **무선은 쓰지 않는다.** LAN 포트에 유선으로만 붙인다.

### 1-2 🖱 선 연결 (전부 **Copper Straight-Through**)

- `HomeRouter` **Internet** 포트 ↔ `ISP` **G0/0**
- `ISP` **G0/1** ↔ `Internet` Fa0
- `PC0` Fa0 ↔ `HomeRouter` **Ethernet 1**
- `PC1` Fa0 ↔ `HomeRouter` **Ethernet 2**

### 1-3 🔁 ISP CLI — 인터넷 역할

```bash
enable
configure terminal
no ip domain-lookup
hostname ISP
interface g0/0
 ip address 203.0.113.1 255.255.255.252     # 우리 집 쪽 (공인)
 no shutdown
interface g0/1
 ip address 8.8.8.1 255.255.255.0           # 인터넷 서버 쪽
 no shutdown
end
```

> 📌 ISP 에는 **`192.168.0.0` 으로 가는 경로가 없다.** 일부러다 — 인터넷은 사설 IP 를 모른다.

### 1-4 🖱 Internet 서버

1. `Desktop → IP Configuration`: `8.8.8.8` · `255.255.255.0` · GW `8.8.8.1` · DNS `8.8.8.8`
2. `Services → DNS`: **On** · Name `www.student.test` · Type **A** · Address `8.8.8.8` → **Add**
3. `Services → HTTP`: On (기본값) — `index.html` 첫 줄을 `인터넷 웹서버입니다` 로 고쳐 두면 확인이 쉽다

### 1-5 🖱 HomeRouter — `GUI` 탭 (공유기 관리자 페이지)

**Setup → Basic Setup**

| 칸 | 값 |
|----|-----|
| Internet Setup | **Static IP** |
| Internet IP Address | `203.0.113.2` |
| Subnet Mask | `255.255.255.252` |
| Default Gateway | `203.0.113.1` |
| DNS 1 | `8.8.8.8` |
| Router IP (Network Setup) | `192.168.0.1` / `255.255.255.0` (기본값) |
| DHCP Server | **Enabled** · Start `192.168.0.100` · Max `50` (기본값) |
| Static DNS 1 (DHCP 설정 칸) | `8.8.8.8` |

→ 맨 아래 **Save Settings**

> 📌 **Wireless 탭은 건드리지 않는다.** 오늘은 유선만 쓴다.

### 1-6 🖱 PC0 · PC1 — DHCP

- 각 PC `Desktop → IP Configuration` → **DHCP**
- 🔎 `192.168.0.100` · `192.168.0.101` · GW `192.168.0.1` · DNS `8.8.8.8`

### 1-7 🖥 PC0 · PC1 — 인터넷 되나

```bash
ipconfig                               # 사설 192.168.0.x
ping 8.8.8.8                           # ✅ — ISP 는 192.168.0.0 경로가 없는데 된다! → NAT
ping www.student.test                  # ✅ DNS
```

- `Web Browser` → `http://www.student.test` → 인터넷 웹서버 페이지

**✅ STEP 1 체크** — PC 두 대가 **모두** `192.168.0.x` 를 받고 `www.student.test` 가 열린다

---

# ▶ STEP 2 · 📦 PT — NAT 를 눈으로, 그리고 포트포워딩 (15분 · 2-3 은 선택)

### 2-1 🖱 Simulation 모드 — 주소가 바뀌는 순간 ⭐

1. 오른쪽 아래 **Simulation** · Edit Filters → **ICMP** 만
2. PC0 에서 `ping 8.8.8.8` (Command Prompt) 또는 **Add Simple PDU**(PC0 → Internet)
3. **Capture/Forward** 로 한 칸씩 → 봉투 클릭
   - **PC0 → HomeRouter** 구간: Src IP **`192.168.0.100`**
   - **HomeRouter → ISP** 구간: Src IP **`203.0.113.2`** ← 🎯 **바뀌었다 = NAT**
   - 돌아오는 응답: Dst `203.0.113.2` → 공유기 통과 후 Dst `192.168.0.100` ← **되돌리기**
4. ⭐ (선택) **PC0 · PC1 에서 동시에** 보내 보기 — 공인 IP 는 하나인데 **포트로 구분**된다 = **PAT**

### 2-2 🖥 Internet 서버 — 밖에서 먼저는?

```bash
ping 192.168.0.100                     # ❌ — 인터넷은 사설 주소를 모른다
ping 203.0.113.2                       # 공유기 자신은 응답할 수 있지만, 안쪽 PC 에게 먼저 말 걸 방법은 없다
```

### 2-3 🖱 (선택) 집 안 서버를 밖에 공개 — 포트포워딩

1. **Server** 하나 더 → `HomeServer` · HomeRouter **Ethernet 2** · IP **고정** `192.168.0.10` / GW `192.168.0.1`
2. HomeRouter `GUI → Applications & Gaming → Single Port Forwarding` (버전에 따라 **Port Range Forwarding**)
   - External Port `80` · Internal Port `80` · Protocol **TCP** · To IP `192.168.0.10` · **Enabled** → Save
3. Internet 서버 `Web Browser` → `http://203.0.113.2` → **HomeServer 의 페이지** ✅

> 🗣 **"10일차 VirtualBox 에서 8080→8080 으로 한 것과 똑같습니다."**

**✅ STEP 2 체크** — Simulation 에서 **출발지 IP 가 바뀌는 구간**을 찾았다

---

---

# ▶ STEP 3 · 🐧 지금 내 서버는 열려 있다 (10분) — [3_왜_막아야_하나](lesson-3.md) ⭐

> 짝을 정하고 **서로의 서버 IP 를 칠판에 적는다.**
> ⚠️ **교실 랩 안에서만.** 허가 없는 외부 장비 점검은 불법이다.

### 3-1 🐧 내 서버 주소와 공격 표면

```bash
ip a                      # 192.168.x.x 를 찾아 칠판에 적는다
ss -tuln                  # LISTEN 몇 줄? = 공격 표면
sudo ufw status           # Status: inactive  ← 아무것도 안 막혀 있다
```

### 3-2 🪟 옆자리 Windows 에서 — 내 서버 두드리기

```
ping 192.168.x.x                 ✅ 응답이 온다
ssh student@192.168.x.x          ✅ 로그인 창이 뜬다
```

> 🚨 **로그인 프롬프트까지만.** 실제로 들어가지 않는다.
> 🗣 **"비밀번호 하나가 이 서버의 전부입니까?"** → STEP 6 에서 닫는다

---

# ▶ STEP 4 · 📦 PT — 표준 ACL (20분) — [4_ACL_표준](lesson-4.md)

### 4-1 🖱 새 파일 · 장비 놓기

| 장비 | 모델 | 주소 |
|------|------|------|
| R1 | 라우터 (2911 등) | `g0/0` **192.168.10.254** · `g0/1` **192.168.20.254** |
| SW1 · SW2 | 스위치 2960 | — |
| Server0 | 서버 | **192.168.10.100** / GW `192.168.10.254` |
| PC_인사 | PC | **192.168.20.10** / GW `192.168.20.254` |
| PC_개발 | PC | **192.168.20.11** / GW `192.168.20.254` |

```
[PC_인사 .20.10]──┐                            ┌── Server0 192.168.10.100
                  ├──[SW2]──[R1]──[SW1]────────┤
[PC_개발 .20.11]──┘         g0/1    g0/0
```

### 4-2 🔁 R1 — 인터페이스

```
enable
configure terminal
hostname R1
interface g0/0
 ip address 192.168.10.254 255.255.255.0
 no shutdown
exit
interface g0/1
 ip address 192.168.20.254 255.255.255.0
 no shutdown
exit
end
```

### 4-3 🖥 먼저 **되는 것**을 확인 ⭐

```
PC_인사 > ping 192.168.10.100        ✅
PC_개발 > ping 192.168.10.100        ✅
```

### 4-4 🔁 일부러 틀리기 — permit 없이 deny 만

```
configure terminal
access-list 10 deny host 192.168.20.10
interface g0/0
 ip access-group 10 out
end
```

```
PC_인사 > ping 192.168.10.100        ❌
PC_개발 > ping 192.168.10.100        ❌  ← 왜 개발팀도 막혔지?!
```

> ⭐ **암묵적 deny any** 를 눈으로 보는 순간. 여기서 멈추고 설명한다.

### 4-5 🔁 고치기 — permit any 추가

```
configure terminal
access-list 10 permit any
end
show access-lists
```

```
PC_인사 > ping 192.168.10.100        ❌  (의도대로)
PC_개발 > ping 192.168.10.100        ✅
```

```
show access-lists                    # match 숫자가 올라간다 ⭐
show ip interface g0/0               # 어느 ACL 이 붙어 있나
```

---

# ▶ STEP 5 · 📦 PT — 확장 ACL (20분) — [5_ACL_확장](lesson-5.md) ⭐

> STEP 4 구성을 **그대로** 쓴다.

### 5-1 🖱 Server0 — 서비스 켜기

- `Services` 탭 → **HTTP** `On` · (가능하면) **SSH** 또는 **Telnet** `On`
- SSH 사용 시 계정 하나 만들어 둔다

### 5-2 🔁 앞 절 ACL 떼기

```
configure terminal
interface g0/0
 no ip access-group 10 out
exit
```

### 5-3 🔁 확장 ACL — 웹은 모두, SSH 는 개발팀만

```
access-list 110 permit tcp host 192.168.20.11 host 192.168.10.100 eq 22
access-list 110 deny   tcp any                host 192.168.10.100 eq 22
access-list 110 permit ip  any any
interface g0/1
 ip access-group 110 in
end
```

### 5-4 🖥 검증 — 같은 PC, 포트에 따라 갈린다 ⭐

| 어디서 | 무엇을 | 기대 |
|--------|--------|------|
| PC_개발 | 웹 브라우저 `http://192.168.10.100` | ✅ |
| PC_개발 | `ssh -l <계정> 192.168.10.100` | ✅ |
| PC_인사 | 웹 브라우저 | ✅ **(막히지 않는다!)** |
| PC_인사 | `ssh -l <계정> 192.168.10.100` | ❌ ⭐ |

```
show access-lists                    # 어느 줄의 match 가 올라갔나
```

> ⚠️ PT 버전에 따라 PC 의 `ssh` 클라이언트가 없을 수 있다 → **Telnet(23)** 으로 바꿔 같은 실습을 한다
> (`eq 22` → `eq 23`). **리허설 때 반드시 확인.**

---

# ▶ STEP 6 · 🐧 ufw — 내 서버의 현관문 (25분) — [6_리눅스_방화벽_ufw](lesson-6.md) ⭐⭐

> 🚨 **순서 엄수.** 바꿔 치면 SSH 창이 끊긴다.
> 🆘 복구: **VirtualBox 창 → 로그인 → `sudo ufw disable`**

### 6-1 🐧 켜기 — 22번을 먼저!

```bash
sudo ufw status                       # inactive
sudo ufw allow 22/tcp                 # ⭐⭐ 반드시 먼저
sudo ufw enable                       # Proceed? → y   (창은 안 끊긴다)
sudo ufw status verbose                # Default: deny (incoming) 확인
```

### 6-2 🐧 웹서버를 올리고 — 막히는 것을 본다

```bash
python3 -m http.server 8000           # 이 창은 서버가 점유한다
```

```
🪟 옆자리 → http://192.168.x.x:8000    ❌ 한참 기다리다 타임아웃  ← ufw 가 막았다
```

### 6-3 🐧 8000 열기 (새 SSH 창에서)

```bash
sudo ufw allow 8000/tcp
sudo ufw status numbered
```

```
🪟 옆자리 → http://192.168.x.x:8000    ✅ 열린다
```

### 6-4 🐧 특정 PC 에게만 — 확장 ACL 과 같은 일 ⭐

```bash
sudo ufw status numbered                                  # 8000 규칙 번호 확인
sudo ufw delete <번호>                                     # 전체 개방 삭제
sudo ufw allow from <내 Windows IP> to any port 8000      # 나에게만
sudo ufw status numbered
```

| 어디서 | 기대 |
|--------|------|
| 내 Windows → `:8000` | ✅ |
| 옆자리 → `:8000` | ❌ ⭐ |

### 6-5 🐧 (시간 남으면) 로그로 증거 보기

```bash
sudo ufw logging on
sudo tail -f /var/log/ufw.log          # [UFW BLOCK] 줄에 출발지·포트가 찍힌다
```

---

# ▶ STEP 7 · 🐧 최소 개방 설계 (10분) — [7_최소개방_설계](lesson-7.md)

### 7-1 🐧 지금 상태 세기

```bash
ss -tuln                               # 공격 표면
sudo ufw status numbered               # 지금 규칙
```

### 7-2 ✍️ 종이에 표 먼저 (짝과 3분)

| 누구에게 | 무엇을 | 왜 |
|----------|--------|-----|
| | | |

> **"왜" 칸을 못 채우는 줄은 열지 않는다.**

### 7-3 🐧 안 쓰는 서비스는 아예 끈다

```bash
sudo systemctl disable --now vsftpd     # 10일차에 세운 FTP, 오늘은 안 쓴다
ss -tuln                                # 21번이 사라졌나
```

> 📌 12일차 FTP 절에서 **다시 켠다**(① 설치는 건너뛰고 ③ 기동부터).

---

# ▶ 마무리 · 12일차로 넘길 상태 만들기 (5분) — [8_정리와_안될때_점검](lesson-8.md) 🚨

```bash
sudo ufw status numbered         # 1. 지금 규칙 확인
sudo ufw allow 22/tcp            # 2. SSH 는 반드시 열려 있어야 한다 ⭐⭐
sudo ufw status verbose          # 3. Status: active 인가
ip a                             # 4. 내 서버 IP 를 적어 둔다
sudo poweroff                    # 5. 얌전히 종료
```

> 🚨 **2번을 빼먹으면 다음 주에 아무도 서버에 못 들어온다.** 전원 확인하고 넘어갈 것.
> 📌 **방화벽은 켜 둔 채로 간다** — 12일차 6단계의 **⑤ 개방(`ufw allow`)** 이 그래야 실감 난다.

### 🧭 안 될 때 — 네 단계로 좁히기 (12일차 내내 쓴다) ⭐⭐

```
① 서비스가 떠 있나?   ss -tuln | grep <포트>      → LISTEN 없으면 서비스 문제
② 안에서는 되나?      curl localhost:<포트>        → 여기서 실패면 서비스 설정
③ 방화벽이 막나?      sudo ufw status numbered     → 규칙 없으면 ufw allow
④ 길이 맞나?          ip a · ping <상대>           → 주소·경로·클라이언트
```

> ⭐ **①②는 되는데 밖에서만 안 된다 = 거의 확실히 방화벽.**

# 📚 부록 A · 공유기 속을 시스코 CLI 로 열어보면 (NAT Overload)

> WRT300N 이 GUI 로 해준 일을 **시스코 라우터로 직접** — CCNA 범위. 시간 남을 때.
> HomeRouter 대신 **2911 라우터 `GW`** + **스위치** 를 놓고, PC 들을 스위치에 연결.

```bash
enable
configure terminal
no ip domain-lookup
hostname GW
interface g0/0
 ip address 192.168.0.1 255.255.255.0
 ip nat inside                                  # 안쪽 (사설)
 no shutdown
interface g0/1
 ip address 203.0.113.2 255.255.255.252
 ip nat outside                                 # 바깥쪽 (공인)
 no shutdown
exit
ip route 0.0.0.0 0.0.0.0 203.0.113.1            # 기본 경로 → ISP (5일차)
ip dhcp excluded-address 192.168.0.1 192.168.0.99
ip dhcp pool HOME                               # 8일차 DHCP 그대로
 network 192.168.0.0 255.255.255.0
 default-router 192.168.0.1
 dns-server 8.8.8.8
exit
access-list 1 permit 192.168.0.0 0.0.0.255      # 변환 대상 = 집 안 전체
ip nat inside source list 1 interface g0/1 overload   # ⭐ PAT — 공인 IP 하나 + 포트
end
```

```bash
show ip nat translations                        # 변환표! ping 후에 보면 줄이 생긴다
```

```
Pro  Inside global       Inside local         Outside local   Outside global
icmp 203.0.113.2:1       192.168.0.100:1      8.8.8.8:1       8.8.8.8:1
tcp  203.0.113.2:1025    192.168.0.101:1025   8.8.8.8:80      8.8.8.8:80
```

| 용어 | 뜻 |
|------|----|
| **Inside local** | 안쪽 기기의 **진짜(사설)** 주소 |
| **Inside global** | 그 기기가 **밖에 보이는(공인)** 주소 |
| `overload` | = **PAT** (공인 하나를 포트로 나눠 씀) |

- (포트포워딩 = Static NAT) `ip nat inside source static tcp 192.168.0.10 80 interface g0/1 80`

---

---

# ⚠️ 부록 B · 안 될 때 30초 점검 (공유기 실습 · 유선)

| 증상 | 원인 | 해결 |
|------|------|------|
| PT PC 가 `169.254.x.x` | 공유기 DHCP 꺼짐 · 케이블이 **Internet(WAN) 포트**에 꽂힘 | GUI DHCP **Enabled** · **Ethernet 1~4** 에 연결 |
| PT `ping 8.8.8.8` 실패 | 공유기 **Internet Setup** (Static · GW `203.0.113.1`) | GUI 값 확인 후 **Save Settings** 눌렀나 |
| PT 이름으로만 안 됨 | DHCP 의 **Static DNS** 비어 있음 · 서버 DNS Off | GUI Static DNS 1 `8.8.8.8` · Internet 서버 DNS **On** |
