# 1. 원격 접속 — 스위치에 IP 주기, Telnet 에서 SSH 로

> 상위: [8일차 · 네트워크 장비에서의 서버 설정](README.md)

## 🎯 학습 목표

- 원격 접속이 왜 필요한지, **VTY 라인**이 무엇인지 안다
- **L2 스위치에도 관리용 IP(SVI)** 와 **기본 게이트웨이**가 필요한 이유를 설명한다
- Telnet 과 SSH 의 차이(**평문 vs 암호화**)를 안다
- 장비에 **SSH 를 설정하는 순서**와 각 줄의 이유를 이해한다
- 원격 접속 후 `enable` 이 막히는 이유(**enable secret**)를 안다

## 🌉 다리 놓기: "장비 앞에 매번 갈 순 없잖아"

지금까지는 **콘솔 케이블**로 장비 앞에 붙어서 CLI 를 썼다. → [3_CLI기초와_실습](../day-04/lesson-3.md)
7일차에 만든 회사망에는 스위치가 **2층·3층**에 한 대씩 있다. 실제 회사라면 **건물 수십 개 · 스위치 수백 대**다.
장비 앞으로 매번 걸어갈 수는 없다 → **네트워크를 통해 원격으로** 들어간다.
→ [7일차 · 스위칭 심화](../day-07/README.md)

## 📖 원격 접속의 문 — VTY 라인

| 들어가는 길 | 이름 | 비유 |
|-------------|------|------|
| 콘솔 케이블 | `line console 0` | 집 안에서 여는 **안방 문** |
| 네트워크 (Telnet · SSH) | `line vty 0 4` | 밖에서 들어오는 **현관문 5개** |

- **VTY** = Virtual TeleTYpe — 원격 접속용 **가상 터미널**
- `0 4` = 0번~4번, **동시에 5명**까지 원격 접속 가능
- 공장 출하 상태의 VTY 는 **비밀번호가 없어서 잠겨 있다** → 설정해야 열린다

## 📖 먼저 — 스위치에도 IP 가 필요하다

라우터는 인터페이스마다 IP 가 있으니 원격으로 찾아갈 수 있다. 그런데 **L2 스위치 포트에는 IP 가 없다** (2계층 장비니까).
원격으로 들어가려면 **찾아갈 주소**가 있어야 한다.

> 🗣 **"7일차 스위치에 ping 을 쳐보세요. 주소가 뭐죠?"** → 없다. 스위치는 **지나가는 프레임만 전달**했지, 자기 주소가 없었다.

### SVI — 스위치의 "관리용 명함"

7일차 L3 스위치에서 봤던 **`interface vlan 10`(SVI)** 을 L2 스위치에도 만든다. 이번엔 **라우팅용이 아니라 관리용**이다.

```bash
interface vlan 10                            # VLAN 10 안에 스위치 자신의 IP
 ip address 192.168.10.253 255.255.255.0
 no shutdown
 exit
ip default-gateway 192.168.10.254            # ★ 다른 VLAN 에서 들어오면 답장은 어디로?
```

| 줄 | 왜 |
|----|-----|
| `interface vlan 10` | 스위치가 **VLAN 10 동네 주민**으로 IP 를 하나 받는다 |
| `ip default-gateway` | 스위치는 라우팅을 못 한다 → **다른 동네(VLAN 20)** 에서 온 사람에게 답장하려면 대문(R1)을 알아야 한다 |

> 💡 **PC 와 똑같다.** PC 도 IP 와 **게이트웨이**가 있어야 다른 네트워크와 통신한다 (3일차).
> 스위치의 관리용 IP 는 **스위치 안에 PC 한 대가 사는 것**이라고 생각하면 된다.

> ⚠️ **`ip default-gateway` 를 빼먹으면** 같은 VLAN 10 의 PC 에서는 접속이 되는데, **VLAN 20 PC 에서는 안 된다.** 실습 단골 장애.

> 📌 실무에서는 관리용으로 **따로 VLAN(예: 99 "MGMT")** 을 만들어 쓴다. 오늘은 간단히 VLAN 10 에 붙인다.

## 📖 Telnet vs SSH

|      | Telnet             | SSH          |
| ---- | ------------------ | ------------ |
| 포트   | TCP **23**         | TCP **22**   |
| 암호화  | ❌ 없음(**평문**)       | ✅ 암호화        |
| 위험   | 비밀번호가 **그대로 흘러간다** | 엿봐도 알아볼 수 없다 |
| 쓰는 곳 | 실습 · 레거시           | **실무 표준**    |

> 💡 **비유: 엽서 vs 봉인된 편지.** Telnet 은 **엽서** — 배달하는 사람 누구나 내용(비밀번호)을 읽는다.
> SSH 는 **자물쇠 달린 상자** — 중간에서 가로채도 열 수 없다. 1일차 **편지 부치기** 비유의 보안판.

> ⚠️ 카페 Wi-Fi 에서 Telnet 을 쓰면? 같은 Wi-Fi 의 누군가가 **스위치 비밀번호를 그대로 볼 수 있다.**

## 📖 Telnet 설정 — 먼저 열어보기 (비교용)

```bash
enable secret class                  # ★ 원격에서 enable 할 때 쓸 비밀번호
line vty 0 4
 password cisco                      # 현관문 비밀번호
 login                               # 들어올 때 비밀번호를 물어라
```

**⚠️ 원격 접속의 함정 두 가지**

| 증상 (PC 에서) | 원인 |
|----------------|------|
| `Password required, but none set` → 바로 끊김 | VTY 에 **비밀번호가 없다** (공장 상태) |
| 접속은 됐는데 `enable` 에서 `% No password set` | **`enable secret` 이 없다** → 원격 사용자는 관리자 모드로 못 올라간다 |

> 🗣 콘솔에서는 `enable` 이 그냥 됐는데 원격에서는 왜 막힐까? → **안방(콘솔)은 이미 집 안에 있는 사람**, 현관(VTY)은 **밖에서 온 사람**이라서 더 엄격하다.

## 📖 SSH 설정 — 순서가 있다

```bash
hostname SW1                               # ① 이름 (기본 이름 Switch 로는 키를 못 만든다)
ip domain-name student.local               # ② 도메인 — ①+② 가 열쇠의 이름표가 된다
crypto key generate rsa general-keys modulus 1024   # ③ 자물쇠(암호 키) 만들기
ip ssh version 2                           # ④ 더 안전한 버전 2 (키가 768비트 이상이어야)
username admin secret cisco123             # ⑤ 계정 (SSH 는 "아이디 + 비밀번호")
line vty 0 4
 login local                               # ⑥ 방금 만든 계정으로 확인해라
 transport input ssh                       # ⑦ 현관은 SSH 만 — Telnet 차단
```

| 순서 | 빼먹으면 |
|------|----------|
| ① `hostname` · ② `ip domain-name` | ③에서 `% Please define hostname other than Switch.` / `% Please define a domain-name first.` |
| ③ 키 생성 | SSH 자체가 켜지지 않는다 |
| ⑤ `username` + ⑥ `login local` | 로그인할 **계정이 없다** |
| ⑦ `transport input ssh` | SSH 와 **Telnet 이 둘 다 열린 채** 남는다 |

> 💡 `crypto key generate rsa` 만 치면 **비트 수를 물어본다** (`How many bits in the modulus [512]:`) → `1024` 입력.
> 한 줄로 끝내려면 위처럼 `general-keys modulus 1024` 를 붙인다.

**PC 에서 접속**

```bash
ssh -l admin 192.168.10.253        # -l = login(계정 이름). 소문자 L
```

- `Password:` 에 `cisco123` → `SW1>` → `enable` → `class` → `SW1#`
- 이제 `telnet 192.168.10.253` 은 **거절**된다 (`⑦` 효과)

## 🧪 질문 / 실습

- 실습 STEP 1 → [0_실습_명령어_모음](commands.md) · 해설 [6_서버설정_실습](lesson-6.md)
- "스위치에 ping 이 안 된다" → **SVI 가 없거나 `no shutdown` 을 안 했다**
- "같은 VLAN 에서는 SSH 가 되는데 다른 VLAN 에서는 안 된다" → **`ip default-gateway`**
- "SSH 로 들어갔는데 `enable` 이 안 된다" → **`enable secret`**
- "Telnet 과 SSH, 카페 Wi-Fi 에서 쓴다면?" → **SSH** (평문 도청 위험)

## 📝 강의 메모

- **"스위치의 IP 는 어디 있죠?"** 로 연다 — 7일차 내내 스위치에 IP 없이 잘 썼다는 사실이 오히려 질문이 된다
- SVI 는 7일차 L3 스위치에서 **이름만** 봤다 → "그때는 라우팅용, 오늘은 관리용" 으로 연결
- **엽서 vs 봉인된 편지** 비유 하나로 Telnet/SSH, 뒤에 나올 FTP/SFTP · SNMPv2c/v3 까지 다 설명된다
- SSH 설정은 **① 이름 → ② 도메인 → ③ 키 → ⑤ 계정 → ⑦ SSH 만** 다섯 박자로
- 실습에서 **Telnet 을 먼저 열고 → SSH 로 갈아타는** 순서를 지킨다 (비교가 있어야 SSH 가 왜 필요한지 남는다)
- 리눅스에서의 SSH 서버 구축은 2단계 → 12_리눅스서버구축
