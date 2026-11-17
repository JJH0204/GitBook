# 0. 8일차 실습 명령어 — 수업 흐름 그대로 (이어치기 대본)

> 상위: [8일차 · 네트워크 장비에서의 서버 설정](README.md) · 이론 설명은 [6_서버설정_실습](lesson-6.md)
> **위에서 아래로 그대로 따라 치면 오늘 실습이 끝난다.** 실습 중 화면에 띄워두거나 인쇄해 나눠줄 것.

## 📌 읽는 법 — 4~7일차와 같은 약속

- 블록 하나 = **한 장비에서 끊지 않고 이어 치는 한 덩어리**
- 블록 머리의 `🖥 PC0` / `🗄 Server0` / `🔀 SW1` / `🔁 R1` = **어느 장비의 어느 창** · `👉` = **다음 행선지**
- `🖱` = 마우스로 하는 GUI 설정 (명령 아님)
- `# 뒤 회색 글씨` = 설명. 안 쳐도 된다

## 🧰 오늘은 예외 — **7일차 파일을 이어 쓴다**

> 오늘은 새 그림을 그리지 않는다. 7일차에 만든 **회사망 위에 서비스를 올리는 날**이다.
> 🚨 **7일차 파일이 없는 사람**은 → 부록 A 의 복붙 블록으로 먼저 복구

## 🗺 오늘의 그림 — 7일차 회사망 + 서버 한 대

```
                        [R1]  .10.254 / .20.254 (서브인터페이스)
                         │    ← DHCP 풀 · helper-address · SNMP
                         │ trunk
                         │
  PC0 ──Fa0/1──┐         │         ┌──Fa0/1── PC2
  PC1 ──Fa0/2──┤       [SW1]═Po1═[SW2]       ├──Fa0/2── PC3
  Server0 ─Fa0/3┘   관리 IP .10.253          └──Fa0/3── (AP · STEP 7)
  (DNS · 웹 · FTP · DHCP)
```

| 장비 | 주소 | 비고 |
|------|------|------|
| **Server0** | 192.168.10.10 /24 · GW .10.254 · DNS .10.10 | SW1 Fa0/3 · **VLAN 10** · 고정 IP |
| **SW1 관리 IP** | 192.168.10.253 /24 · GW .10.254 | `interface vlan 10` |
| PC0 ~ PC3 | **DHCP 로 받는다** (STEP 2 부터) | |

---

# ▶ 준비 · 7일차 파일 열기 + 서버 붙이기 (10분)

### 0-1 🖱 마우스로

1. `7일차_스위칭.pkt` 열기 → **다른 이름으로 저장** `8일차_서버.pkt`
2. **Server** 1대 배치 → **SW1 Fa0/3** 에 다이렉트 케이블
3. Server0 `Desktop → IP Configuration` → Static: `192.168.10.10` · `255.255.255.0` · GW `192.168.10.254` · DNS `192.168.10.10`

### 0-2 🔀 SW1 CLI — 서버 포트를 VLAN 10 에

```bash
enable
configure terminal
interface fa0/3
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
end
```

### 0-3 🖥 PC1 — 7일차가 살아 있는지

```bash
ping 192.168.10.10             # 서버 (VLAN 20 → 라우터 → VLAN 10)
ping 192.168.10.2              # PC2
```

**✅ 준비 체크** — 서버 ping 성공 · 두 스위치 `show etherchannel summary` 에 `Po1(SU)`

---

# ▶ STEP 1 · 원격으로 스위치에 들어간다 — SVI · Telnet → SSH (25분)

### 1-1 🖥 PC0 — 스위치의 주소는?

```bash
telnet 192.168.10.253          # ❌ 응답 없음 — 스위치엔 아직 IP 가 없다
```

> 🗣 **"7일차 내내 스위치를 썼는데, 스위치의 IP 는 뭐였죠?"** → 없었다

### 1-2 🔀 SW1 CLI — 관리용 IP (SVI) + 게이트웨이

```bash
configure terminal
interface vlan 10                            # 스위치 자신이 VLAN 10 주민이 된다
 ip address 192.168.10.253 255.255.255.0
 no shutdown
 exit
ip default-gateway 192.168.10.254            # 다른 VLAN 에 답장하려면 필요
end
```

> 👉 다음: PC0 으로

### 1-3 🖥 PC0 — 이제 문은 있는데…

```bash
ping 192.168.10.253            # ✅
telnet 192.168.10.253          # Password required, but none set → 바로 끊긴다
```

> 🗣 **"문(VTY)은 있는데 비밀번호가 없어서 잠겨 있다."** 👉 SW1 으로

### 1-4 🔀 SW1 CLI — Telnet 열기 (비교용)

```bash
configure terminal
enable secret class                          # ★ 원격에서 enable 할 때 쓸 비밀번호
line vty 0 4
 password cisco
 login
end
```

### 1-5 🖥 PC0 — 원격으로 들어갔다

```bash
telnet 192.168.10.253
Password: cisco
SW1> enable
Password: class
SW1# show vlan brief           # ★ 스위치 앞에 가지 않고 설정을 봤다
SW1# exit
```

> ⚠️ **이 비밀번호는 평문으로 흘러갔다** — 엽서처럼 누구나 읽을 수 있다 → SSH 로 갈아탄다

### 1-6 🔀 SW1 CLI — SSH 로 갈아타기 (**일부러 순서를 어겨 먼저**)

```bash
configure terminal
crypto key generate rsa general-keys modulus 1024    # ★ 도메인 없이 먼저 쳐본다
```

```
% Please define a domain-name first.
```

> 🗣 **"키에 붙일 이름표(이름 + 도메인)가 없다."** → 순서대로 다시

```bash
ip domain-name student.local                          # ① 도메인 (hostname SW1 은 7일차에 이미)
crypto key generate rsa general-keys modulus 1024    # ② 자물쇠(키) 만들기
ip ssh version 2                                      # ③ 버전 2
username admin secret cisco123                        # ④ 계정
line vty 0 4
 login local                                          # ⑤ 계정으로 확인
 transport input ssh                                  # ⑥ SSH 만 — Telnet 차단
end
copy running-config startup-config
```

> 👉 다음: **PC1 (VLAN 20)** 으로 — 다른 부서에서 들어가 본다

### 1-7 🖥 PC1 — 다른 VLAN 에서 SSH ⭐

```bash
telnet 192.168.10.253          # ❌ 이제 거절된다
ssh -l admin 192.168.10.253    # ✅ (소문자 L)
Password: cisco123
SW1> enable
Password: class
SW1# show interfaces trunk
SW1# exit
```

> 💡 PC1 은 **VLAN 20** 이다. 스위치의 `ip default-gateway` 가 있어서 **답장이 R1 을 거쳐** 돌아온다.

**✅ 체크** — Telnet 거절 · SSH 성공 · **다른 VLAN(PC1)** 에서도 SSH 성공

---

# ▶ STEP 2 · IP 를 자동으로 나눠준다 — 라우터 DHCP (20분)

### 2-1 🖥 PC2 — 먼저 실패부터

🖱 `Desktop → IP Configuration` → **DHCP** 선택

```
DHCP failed. APIPA is being used.      (버전에 따라 문구는 조금 다르다)
→ IP 가 169.254.x.x 로 잡힌다
```

> 🗣 **"169.254 — 2일차에 뭐라고 했죠?"** → **고장 신호.** DHCP 서버를 못 찾았다. 👉 R1 으로

### 2-2 🔁 R1 CLI — VLAN 마다 풀 하나씩

```bash
configure terminal
ip dhcp excluded-address 192.168.10.1 192.168.10.10      # 서버 · 장비용 (먼저!)
ip dhcp excluded-address 192.168.10.250 192.168.10.254   # 게이트웨이 · 스위치 관리 IP
ip dhcp excluded-address 192.168.20.1 192.168.20.10
ip dhcp excluded-address 192.168.20.250 192.168.20.254
ip dhcp pool VLAN10
 network 192.168.10.0 255.255.255.0
 default-router 192.168.10.254
 dns-server 192.168.10.10
 exit
ip dhcp pool VLAN20
 network 192.168.20.0 255.255.255.0
 default-router 192.168.20.254
 dns-server 192.168.10.10
end
```

### 2-3 🖱 PC0 ~ PC3 — 전부 DHCP 로

각 PC `IP Configuration` → **Static 눌렀다가 다시 DHCP** (재요청)

| PC | 받아야 할 IP | 게이트웨이 | DNS |
|----|--------------|------------|-----|
| PC0 · PC2 (VLAN 10) | `192.168.10.11` ~ | 192.168.10.254 | 192.168.10.10 |
| PC1 · PC3 (VLAN 20) | `192.168.20.11` ~ | 192.168.20.254 | 192.168.10.10 |

### 2-4 🔁 R1 CLI — 누가 무엇을 받았나

```bash
show ip dhcp binding           # IP · MAC 목록 — 4줄
```

> 🗣 **"DHCP 요청은 브로드캐스트입니다. 브로드캐스트는 라우터를 못 넘죠. VLAN 20 PC 는 어떻게 받았을까요?"**
> → R1 의 `g0/0.20` 이 **VLAN 20 동네 안에** 있어서. → 그럼 서버가 **다른 동네**에 있으면? → STEP 3

**✅ 체크** — PC 4대 모두 `.11` 대 주소 · 게이트웨이 · DNS 가 풀대로 · PC 끼리 ping ✅

---

# ▶ STEP 3 · DHCP 를 서버로 옮긴다 — 릴레이 (20분, ⭐ 고급)

### 3-1 🔁 R1 CLI — 라우터의 DHCP 는 끈다

```bash
configure terminal
no ip dhcp pool VLAN10
no ip dhcp pool VLAN20
end
```

### 3-2 🖱 Server0 — `Services → DHCP`

1. Service **On**
2. **serverPool** 을 VLAN 10 용으로 고친다 → **Save**

| 칸 | 값 |
|----|-----|
| Default Gateway | 192.168.10.254 |
| DNS Server | 192.168.10.10 |
| Start IP Address | **192.168.10.101** |
| Subnet Mask | 255.255.255.0 |
| Maximum Number of Users | 50 |

3. Pool Name `VLAN20` 으로 **새 풀** → **Add**

| 칸 | 값 |
|----|-----|
| Default Gateway | 192.168.20.254 |
| DNS Server | 192.168.10.10 |
| Start IP Address | **192.168.20.101** |
| Subnet Mask | 255.255.255.0 |
| Maximum Number of Users | 50 |

> 💡 시작 주소를 **`.101`** 로 둔 이유: 라우터가 준 `.11` 과 구분돼서 **"서버에서 받았다"** 가 한눈에 보인다.

### 3-3 🖱 PC2 (VLAN 10) · PC3 (VLAN 20) — 재요청

| PC | 결과 | 이유 |
|----|------|------|
| **PC2** (VLAN 10) | ✅ `192.168.10.101` | 서버와 **같은 동네** — 외침이 들린다 |
| **PC3** (VLAN 20) | ❌ `169.254.x.x` | 외침이 **R1 에서 멈춘다** |

> 🗣 **"서버는 켜져 있는데 왜 VLAN 20 만 못 받죠?"** → **브로드캐스트는 라우터를 못 넘는다** (4일차 원칙)
> 👉 R1 으로 — 원칙의 **예외**를 만들어준다

### 3-4 🔁 R1 CLI — "DHCP 외침은 서버에게 전해줘"

```bash
configure terminal
interface g0/0.20                           # ★ 서버가 없는 쪽(클라이언트 쪽) 게이트웨이에
 ip helper-address 192.168.10.10
end
```

### 3-5 🖱 PC3 · PC1 — 다시 재요청 ⭐

- PC3 · PC1 → **`192.168.20.101`** ~ ✅ (서버의 VLAN20 풀)
- PC0 도 재요청 → `192.168.10.10x`
- 🔁 R1 `show ip dhcp binding` → **비어 있다** = 라우터가 준 게 아니다. **서버가 줬다**

> 💡 R1 은 이제 **배급소가 아니라 우체국**이다 — 외침을 편지로 바꿔 서버에 전달만 한다.

**✅ 체크** — VLAN 10 · 20 PC 모두 `.101` 대 · R1 binding 비어 있음

---

# ▶ STEP 4 · 이름으로 부른다 — DNS · 웹 (15분)

### 4-1 🖥 PC0 — 이름으로는 아직 모른다

```bash
ping 192.168.10.10             # ✅
ping www.student.local         # ❌ Ping request could not find host ...
```

> 🗣 3일차 떡밥 그대로 — **"IP 는 되는데 이름은 안 된다 → DNS 문제!"**

### 4-2 🖱 Server0 — `Services → DNS`

1. DNS Service **On**
2. Name `www.student.local` · Type **A Record** · Address `192.168.10.10` → **Add**
3. Name `sw1.student.local` · Type **A Record** · Address `192.168.10.253` → **Add**

### 4-3 🖥 PC0 · PC3 — 이름으로 ⭐

```bash
ping www.student.local         # ✅ 192.168.10.10 으로 바뀌어 간다
ping sw1.student.local         # ✅ 스위치도 이름으로
```

- 🖱 `Desktop → Web Browser` → `http://www.student.local` → **서버의 웹 페이지** (PT 서버는 HTTP 가 기본으로 켜져 있다)
- PC 의 DNS 서버 주소는 **DHCP 가 줬다** — 손으로 넣은 적 없다

**✅ 체크** — 두 VLAN 모두 이름으로 ping · 웹 페이지 열림

---

# ▶ STEP 5 · FTP · SNMP 맛보기 (10분, 선택)

### 5-1 🖥 PC0 — FTP (PT 서버 기본 계정 cisco / cisco)

```bash
ftp 192.168.10.10
Username: cisco
Password: cisco
ftp> dir                       # 서버의 파일 목록
ftp> quit
```

> ⚠️ 방금 비밀번호도 **평문**이다 — Telnet 과 같은 운명 → 실무는 **SFTP**

### 5-2 🔁 R1 CLI — SNMP 에이전트 켜기

```bash
configure terminal
snmp-server community public ro             # 읽기 전용
end
```

### 5-3 🖱 PC0 — `Desktop → MIB Browser`

1. **Advanced** → Address `192.168.10.254` · Read Community `public` · Version **v2** → OK
2. MIB 트리에서 **system → sysName** 선택 → Operation **Get** → **GO**
3. 결과에 **`R1`** — 🗣 **"로그인도 안 했는데 라우터 이름을 알아냈습니다. 커뮤니티 문자열이 곧 비밀번호예요."**

---

# ▶ STEP 6 · 아무나 꽂지 못하게 — 포트 보안 (20분)

### 6-1 🔀 SW1 CLI — PC0 자리(Fa0/1)를 잠근다

```bash
configure terminal
interface fa0/1
 switchport port-security
 switchport port-security maximum 1
 switchport port-security mac-address sticky
 switchport port-security violation shutdown
end
```

### 6-2 🖥 PC0 → 🔀 SW1 — 주인을 등록시킨다

```bash
ping 192.168.10.254            # (PC0) 한 번 통신해야 sticky 가 배운다
```

```bash
show port-security interface fa0/1          # (SW1) Sticky MAC Addresses : 1
show running-config                         # fa0/1 아래에 sticky + PC0 의 MAC 이 적혔다
```

### 6-3 🖱 침입자 등장

1. **Laptop** 1대 배치 · IP 는 **DHCP**
2. **PC0 의 선을 삭제** → Laptop 을 **SW1 Fa0/1** 에 연결
3. Laptop 이 DHCP 를 요청하는 순간 → 🚨 **링크가 빨간색**

### 6-4 🔀 SW1 CLI — 범인을 찾는다

```bash
show port-security interface fa0/1
show interfaces fa0/1                       # down (err-disabled)
```

```
Port Status                : Secure-shutdown        ← 봉쇄됐다
Last Source Address:Vlan   : 00D0.xxxx.xxxx:10      ← 범인의 MAC
Security Violation Count   : 1
```

- 🖱 Laptop `Config → FastEthernet0` 의 MAC 과 **비교** → 일치!

### 6-5 🖱 + 🔀 SW1 — 복구 (범인부터 치운다)

1. 🖱 Laptop 선 **삭제** → **PC0 다시 연결**
2. SW1:

```bash
configure terminal
interface fa0/1
 shutdown
 no shutdown
end
```

3. PC0 `ping 192.168.10.254` → ✅

> ⚠️ Laptop 을 꽂은 채 `no shutdown` 하면 **즉시 다시 꺼진다.**

**💾 저장** — 모든 장비 `copy running-config startup-config` · 파일은 `Ctrl + S`

**✅ 체크** — 침입 시 빨간 불 · 범인 MAC 확인 · 복구 후 PC0 정상

---

# ▶ STEP 7 · 무선 · IPv6 맛보기 (선택) — [5_무선랜과_IPv6](lesson-5.md)

### 7-1 🔀 SW2 CLI — AP 를 꽂을 포트

```bash
configure terminal
interface fa0/3
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
end
```

### 7-2 🖱 AP · 무선 노트북

1. **AccessPoint-PT** → SW2 Fa0/3 (다이렉트)
2. AP `Config → Port 1`: SSID `KoreaIT` · **WPA2-PSK** · Pass Phrase `example-password` · Encryption **AES**
3. Laptop 2 `Physical`: **전원 끄기** → 유선 모듈 빼기 → **WPC300N** 넣기 → 전원 켜기
4. Laptop 2 `Config → Wireless0`: SSID `KoreaIT` · WPA2-PSK · `example-password` · IP **DHCP**
5. 🔎 `192.168.10.10x` 를 받았나 → `ping www.student.local`

> 🗣 **"무선인데 VLAN 10 주소?"** → AP 가 꽂힌 포트가 VLAN 10. **AP = 전파로 된 액세스 포트**

### 7-3 🖱 PC0 · PC2 — 스위치는 IPv6 를 신경 쓰지 않는다

- PC0 IPv6: `2001:db8:10::1` / `64` · PC2 IPv6: `2001:db8:10::2` / `64`
- PC0 `ping 2001:db8:10::2` → ✅ **스위치 설정은 하나도 안 바꿨다** (2계층이라 상관없다)

### 7-4 🔁 R1 CLI — 라우터를 넘으려면 (여유 있으면)

```bash
configure terminal
ipv6 unicast-routing                         # ★ 빠뜨리면 IPv6 를 넘겨주지 않는다
interface g0/0.10
 ipv6 address 2001:db8:10::254/64
interface g0/0.20
 ipv6 address 2001:db8:20::254/64
end
show ipv6 interface brief
```

- PC1 IPv6 `2001:db8:20::1/64` · IPv6 Gateway `2001:db8:20::254` / PC0 IPv6 Gateway `2001:db8:10::254`
- PC0 `ping 2001:db8:20::1` → ✅ (VLAN 을 넘는 IPv6)

---

# 📚 부록 A · 7일차 파일이 없을 때 — 5분 복구

> 🖱 7일차 그림(라우터 1 · 스위치 2 · PC 4, **SW1–SW2 는 Fa0/23 · Fa0/24 두 줄**)을 먼저 만든 뒤
> 아래 블록을 **장비마다 통째로 복사 → CLI 에 붙여넣기**(주석이 없어서 그대로 붙여도 된다). PC 는 STEP 2 에서 DHCP 로 받으니 IP 를 안 넣어도 된다.

**🔀 SW1 · SW2 공통** — SW2 에 붙일 땐 `hostname SW1` 만 `SW2` 로 고친다

```bash
enable
configure terminal
no ip domain-lookup
hostname SW1
vlan 10
 name SALES
vlan 20
 name DEV
 exit
interface fa0/1
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast
interface fa0/2
 switchport mode access
 switchport access vlan 20
 spanning-tree portfast
interface range fa0/23 - 24
 switchport mode trunk
 channel-group 1 mode active
 exit
interface port-channel 1
 switchport mode trunk
end
```

**🔀 SW1 만 추가** — 라우터 쪽 포트

```bash
configure terminal
interface g0/1
 switchport mode trunk
end
```

**🔁 R1**

```bash
enable
configure terminal
no ip domain-lookup
hostname R1
interface g0/0
 no shutdown
interface g0/0.10
 encapsulation dot1Q 10
 ip address 192.168.10.254 255.255.255.0
interface g0/0.20
 encapsulation dot1Q 20
 ip address 192.168.20.254 255.255.255.0
end
```

> 원리가 궁금하면 → [7일차 대본](../day-07/commands.md)

# 📚 부록 B · `no ip domain-lookup` 을 풀어보면 (재미 실험)

**🔁 R1**

```bash
configure terminal
ip domain-lookup                             # 4일차부터 막아뒀던 걸 푼다
ip name-server 192.168.10.10                 # 이제 물어볼 DNS 서버가 있다
end
ping www.student.local                       # ✅ 라우터도 이름으로
shwo ip route                                # 오타 → Translating "shwo"...domain server (192.168.10.10)
```

> 🗣 DNS 서버가 있으니 **금방 "그런 이름 없다"** 는 답이 온다. 4일차에 30초씩 멈췄던 건 **물어볼 서버도 없이 외치고 있어서**였다.

# 📚 부록 C · 오늘 새로 나온 명령 사전

| 무엇 | 명령 | 어느 모드 |
|------|------|-----------|
| 스위치 관리 IP | `interface vlan 10` → `ip address …` | `(config)#` |
| 스위치 게이트웨이 | `ip default-gateway 192.168.10.254` | `(config)#` |
| enable 비밀번호 | `enable secret class` | `(config)#` |
| 원격 라인 | `line vty 0 4` | `(config)#` |
| Telnet 비밀번호 | `password cisco` → `login` | `(config-line)#` |
| 도메인 이름 | `ip domain-name student.local` | `(config)#` |
| SSH 키 | `crypto key generate rsa general-keys modulus 1024` | `(config)#` |
| SSH 버전 | `ip ssh version 2` | `(config)#` |
| 계정 | `username admin secret cisco123` | `(config)#` |
| 계정으로 인증 · SSH 만 | `login local` · `transport input ssh` | `(config-line)#` |
| DHCP 제외 | `ip dhcp excluded-address 시작 끝` | `(config)#` |
| DHCP 풀 | `ip dhcp pool 이름` → `network` · `default-router` · `dns-server` | `(dhcp-config)#` |
| DHCP 릴레이 | `ip helper-address 서버IP` | `(config-subif)#` |
| DNS 서버 지정 | `ip name-server 192.168.10.10` | `(config)#` |
| SNMP | `snmp-server community public ro` | `(config)#` |
| 포트 보안 | `switchport port-security` (+ `maximum` · `mac-address sticky` · `violation`) | `(config-if)#` |
| IPv6 라우팅 | `ipv6 unicast-routing` | `(config)#` |
| 확인 | `show ip dhcp binding` · `show port-security interface fa0/1` · `show ipv6 interface brief` | `#` |
| PC 원격 접속 | `telnet IP` · `ssh -l 계정 IP` · `ftp IP` | PC 명령 프롬프트 |

# ⚠️ 부록 D · 안 될 때 30초 점검 (오늘판)

| 증상 | 원인 · 조치 |
|------|-------------|
| 스위치에 ping 이 안 된다 | `interface vlan 10` 에 **`no shutdown`** 했나 · SVI 의 VLAN 이 맞나 |
| **같은 VLAN 에서만** 원격 접속이 된다 | 스위치 **`ip default-gateway`** 누락 |
| `Password required, but none set` | VTY 에 `password` + `login` (또는 `login local`) 없음 |
| 원격 접속 후 `enable` → `% No password set` | **`enable secret`** 없음 |
| `% Please define a domain-name first.` | `ip domain-name` 먼저 |
| SSH 가 거절된다 | ① 키 생성 안 됨 ② `username` 없음 ③ `login local` 대신 `login` ④ `ssh -l` 계정 오타 |
| PC 가 `169.254.x.x` | DHCP 서버를 못 찾음 → 풀 · 릴레이 · 서버 DHCP On 확인 |
| VLAN 10 만 받고 VLAN 20 은 못 받음 (서버 DHCP) | **`ip helper-address`** 를 `g0/0.20` 에 |
| helper 를 넣었는데도 못 받음 | 서버에 **VLAN 20 용 풀**이 있나 (게이트웨이 `.20.254`) |
| 받은 IP 가 게이트웨이와 충돌 | `excluded-address` 누락 |
| IP 로는 되는데 이름으로 안 됨 | 서버 DNS **On** · A 레코드 오타 · PC 의 DNS 서버 주소 |
| 포트 보안 명령 `Command rejected` | 포트가 **액세스 모드**가 아니다 |
| 포트가 빨간색 (err-disabled) | 포트 보안 위반 → **범인 제거 후** `shutdown` → `no shutdown` |
| 정상 PC 인데 포트가 꺼짐 | sticky 가 **옛 MAC** 을 기억 → sticky 항목 삭제 후 재학습 |
| 무선 노트북이 안 붙는다 | SSID · 비밀번호 · **WPA2-PSK / AES** 가 AP 와 같은가 · WPC300N 장착 |
| IPv6 가 라우터를 못 넘는다 | **`ipv6 unicast-routing`** · PC 의 IPv6 게이트웨이 |
| 껐다 켜니 설정이 사라짐 | `copy running-config startup-config` 안 했다 |

> 7일차 공통 증상(트렁크 · VLAN · EtherChannel)은 → [7일차 부록 D](../day-07/commands.md)
