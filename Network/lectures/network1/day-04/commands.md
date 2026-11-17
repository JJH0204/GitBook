# 0. 4일차 실습 명령어 — 수업 흐름 그대로 (이어치기 대본)

> 상위: [4일차 · 스위치와 라우터](README.md) · 이론 설명은 [3_CLI기초와_실습](lesson-3.md)
> **위에서 아래로 그대로 따라 치면 오늘 실습이 끝난다.** 실습 중 화면에 띄워두거나 인쇄해 나눠줄 것.

## 📌 읽는 법 — 이 노트의 약속

- 블록 하나 = **한 장비에서 끊지 않고 이어 치는 한 덩어리**. 중간에 다른 창으로 가지 않는다
- 블록 머리의 `🖥 PC0` / `🔀 SW` / `🔁 R1` = **어느 장비의 어느 창**인지
- 블록 끝의 `👉` = **다음에 어디로 가는지**
- `# 뒤 회색 글씨` = 설명. 안 쳐도 된다

| 어디에 치나 | 여는 법 | 프롬프트 |
|------|---------|----------|
| **PC** | PC 클릭 → `Desktop` 탭 → `Command Prompt` | `C:\>` |
| **스위치 · 라우터** | 장비 클릭 → **`CLI` 탭** | `Switch>` `Router>` |

> ⚠️ PC 창에서 `show ip route`, 장비 창에서 `ipconfig` 는 **안 된다.** 막히면 **창부터** 확인.

## ⌨️ 시작 전 30초 — 이것만 알면 타이핑이 반으로 준다

| 기능 | 키 | 예 |
|------|-----|-----|
| 자동완성 | `Tab` | `conf`+`Tab` → `configure` |
| 도움말 | `?` | `show ?` · `sh ip ro?` |
| 축약 | 헷갈리지 않을 만큼만 | `sh ip int br` = `show ip interface brief` |
| 이전 명령 | `↑` `↓` | 다시 치지 말 것 |

- 취소는 앞에 **`no`** — `shutdown` ↔ `no shutdown`
- `--More--` 에서 멈추면 → `Space`(다음 쪽) · `q`(중단)
- **명령이 멈춰서 안 돌아오면 → `Ctrl + Shift + 6`**

---

# ▶ STEP 1 · Lab 10 — 스위치 MAC 테이블 (`03_스위치.pkt`)

> 3일차 파일을 **연다**. 새로 만들지 않는다. 구성: `PC0(192.168.10.1) — SW — PC1(192.168.10.2)`

### 1-1 🔀 스위치 CLI — 준비 + "비었다" 확인

```bash
enable
configure terminal
no ip domain-lookup
hostname SW1
end
show mac address-table
```

> 여기까지 **한 번에** 친다. 마지막 화면이 **비어 있는 것**이 오늘의 출발점.
> 👉 다음: PC0 창으로

### 1-2 🖥 PC0 (Desktop → Command Prompt) — 채우러 간다

```bash
ping 192.168.10.2
```

> 👉 다음: 다시 스위치 CLI 로 (창만 바꾸고, 명령은 이어진다)

### 1-3 🔀 스위치 CLI — "찼다 → 비웠다 → 다시 찼다"

```bash
show mac address-table          # ② 찼다 — 두 PC 의 MAC 이 포트별로
clear mac address-table dynamic
show mac address-table          # ③ 비웠다
```

> 👉 PC0 에서 `ping 192.168.10.2` 한 번 더 → 다시 스위치에서 `show mac address-table` (④ 다시 찼다)

**✅ 체크** — `Type` 이 `DYNAMIC` 인가 · 포트 번호가 실제 연결과 맞는가 → [1_스위치_동작원리](lesson-1.md)

---

# ▶ STEP 2 · Lab 11 — 라우터 라우팅 테이블 (`03_라우터.pkt`)

> 파일을 바꿔 연다. 3일차에 **GUI 로** 설정해둔 라우터가 있는 파일.

### 2-1 🔁 라우터 CLI — 준비 + 두 테이블 확인

```bash
enable
configure terminal
no ip domain-lookup
hostname R1
end
show ip interface brief         # 두 인터페이스가 up/up 인가
show ip route                   # C 2개 · L 2개가 보이는가
copy running-config startup-config
```

> 3일차에 GUI 로 준 IP 때문에 **자동으로 생긴 경로**가 `C` 다. → [2_라우터_동작원리](lesson-2.md)
> 👉 다음: 이 파일 그대로 **다른 이름으로 저장** → `04_정적라우팅.pkt` (STEP 3 로)

---

# ▶ STEP 3 · Lab 12 — 정적 라우팅 ⭐ 오늘의 핵심 (`04_정적라우팅.pkt`)

```
[PC0]──[SW1]──[R1]────────[R2]──[SW2]──[PC2]
 192.168.10.0/24   .20.0/24   192.168.30.0/24
```

### 3-1 🖱 먼저 마우스로 (명령 아님)

1. R1 ↔ SW2 케이블을 **지우고**, 사이에 **라우터 R2** 를 넣는다
2. R1 ↔ R2 = **크로스오버** · R2 ↔ SW2 = **다이렉트**
3. `PC2` → `IP Configuration` → IP `192.168.30.1` / 마스크 `255.255.255.0` / **게이트웨이 `192.168.30.254`**

> 👉 배선과 PC 주소가 끝났으면, 이제부터 **끝까지 CLI 다.**

### 3-2 🔁 R1 CLI — G0/1 주소를 `.254` → `.1` 로

```bash
enable
configure terminal
interface g0/1
 ip address 192.168.20.1 255.255.255.0
 no shutdown
end
show ip interface brief         # g0/1 이 up/up · 주소가 20.1 로 바뀌었나
```

> 👉 다음: R2 로 (R1 은 잠시 그대로 둔다 — 경로는 3-4 에서 한 번에 넣는다)

### 3-3 🔁 R2 CLI — 새 라우터, 처음부터 끝까지 한 덩어리

```bash
enable
configure terminal
no ip domain-lookup
hostname R2
interface g0/1
 ip address 192.168.20.2 255.255.255.0
 no shutdown
 exit
interface g0/0
 ip address 192.168.30.254 255.255.255.0
 no shutdown
end
show ip interface brief         # 둘 다 up/up ?
show ip route                   # C 2개뿐 — R2 는 아직 10.0 을 모른다
```

> ⚠️ `no shutdown` 을 빠뜨리면 `C` 가 안 생긴다. 3일차 `Port Status = On` 과 같은 뜻.
> 👉 다음: PC0 로 가서 **일부러 실패를 본다**

### 3-4 🖥 PC0 — 실패부터 확인한다

```bash
ping 192.168.10.254             # ① 내 게이트웨이까지 — 성공해야 정상
ping 192.168.30.1               # ② 그 너머 PC2 — 실패한다. 메시지를 읽을 것
```

> 🗣 "왜 실패했나?" → 경로가 없다 ([3_ICMP와_ping](../day-03/lesson-3.md))
> 👉 다음: 두 라우터에 길을 알려준다

### 3-5 🔁 R1 CLI — 30.0 으로 가는 길

```bash
configure terminal
ip route 192.168.30.0 255.255.255.0 192.168.20.2
end
show ip route                   # S 항목이 생겼는가
copy running-config startup-config
```

### 3-6 🔁 R2 CLI — 10.0 으로 돌아오는 길 (**한쪽만 넣으면 안 된다**)

```bash
configure terminal
ip route 192.168.10.0 255.255.255.0 192.168.20.1
end
show ip route
copy running-config startup-config
```

> 형식: `ip route <목적지 네트워크> <서브넷 마스크> <다음 홉 주소>`
> 👉 다음: PC0 로 가서 성공 확인

### 3-7 🖥 PC0 — 이번엔 성공

```bash
ping 192.168.30.1
tracert 192.168.30.1            # 어디를 거쳐 갔는지
arp -a                          # 여전히 게이트웨이의 MAC 뿐이다
```

**💾 저장** — 라우터는 **양쪽 다** `copy running-config startup-config` (3-5·3-6 에서 이미 함) ·
패킷트레이서 파일은 따로 **`Ctrl + S`** (`04_정적라우팅.pkt`)

### 3-8 🔁 R2 CLI — 일부러 한쪽을 지워 다시 실패시키기

```bash
configure terminal
no ip route 192.168.10.0 255.255.255.0 192.168.20.1
end
show ip route                   # S 가 사라졌다
```

> 👉 PC0 에서 `ping 192.168.30.1` → **다시 실패**. "라우팅은 왕복"을 몸으로 확인.
> 확인이 끝나면 **3-6 을 다시 쳐서 되돌린다** (`↑` 키로 불러오면 빠르다)

**✅ 최종 체크**

- [ ] R1·R2 각각 `show ip route` 에 `C` 2개 + `S` 1개
- [ ] PC0 → PC2 ping 성공
- [ ] 양쪽 라우터 `copy run start` · PT 파일 `Ctrl + S`

---

# 📚 부록 A · 장비를 처음 만났을 때 기본 설정 (여유 있으면)

```bash
enable
configure terminal
 hostname R1
 no ip domain-lookup            # 오타 쳐도 30초 멈추지 않게
 enable secret cisco123         # 특권 모드 비밀번호 (암호화 저장)
 banner motd #Authorized access only#
 line console 0
  logging synchronous           # 장비 메시지가 타이핑을 방해하지 않게
  password cisco
  login
 end
copy running-config startup-config
```

# 📚 부록 B · 명령 사전 (급할 때만 여기)

| 무엇 | 명령 | 어느 모드 |
|------|------|-----------|
| 특권 모드로 | `enable` | `>` |
| 설정 모드로 | `configure terminal` | `#` |
| 포트 설정으로 | `interface g0/0` | `(config)#` |
| 한 단계 나가기 / 전부 나가기 | `exit` / `end`(`Ctrl+Z`) | 어디서나 |
| 인터페이스 상태 요약 | `show ip interface brief` | `#` |
| MAC 테이블 (2계층) | `show mac address-table` | `#` |
| 라우팅 테이블 (3계층) | `show ip route` | `#` |
| 지금 설정 / 저장된 설정 | `show running-config` / `show startup-config` | `#` |
| **저장** | `copy running-config startup-config` (= `write memory`) | `#` |
| IP 주기 | `ip address <주소> <마스크>` + `no shutdown` | `(config-if)#` |
| 정적 경로 | `ip route <목적지> <마스크> <다음 홉>` | `(config)#` |
| MAC 테이블 비우기 | `clear mac address-table dynamic` | `#` |
| **PC 쪽** | `ipconfig` · `ping` · `arp -a` · `tracert` | `C:\>` |

# ⚠️ 부록 C · 안 될 때 30초 점검

| 증상 | 원인 · 조치 |
|------|-------------|
| `% Invalid input detected at '^' marker.` | `^` 가 가리키는 자리가 틀렸다 · 또는 **모드가 틀렸다**(`show` 는 `#` 에서) |
| 명령을 쳤는데 멈춰 있다 | 오타 → DNS 조회 중 · `Ctrl+Shift+6` · `no ip domain-lookup` |
| IP 를 줬는데 `C` 가 안 생김 | **`no shutdown`** 안 했다 → `show ip interface brief` |
| 게이트웨이 너머가 안 됨 | 정적 경로 · **반대쪽 라우터**에도 넣었나 |
| `Destination host unreachable` | 경로가 없다 → `show ip route` |
| `Request timed out` | 갈 길은 있는데 **돌아오는 경로**가 없다 |
| 껐다 켜니 설정이 사라짐 | `copy running-config startup-config` 안 했다 |

> 자세한 설명은 [3_CLI기초와_실습](lesson-3.md) · 케이블·링크 점 같은 **PT 조작 문제**는
> → [3일차 · 자주 나는 오류](../day-03/lesson-4.md)
