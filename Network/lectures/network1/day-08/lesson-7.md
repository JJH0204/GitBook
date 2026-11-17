# 7. 오늘의 CCNA 🎯

> 상위: [8일차 · 네트워크 장비에서의 서버 설정](README.md)

수업 마무리로 **오늘 배운 내용에 맞춘 CCNA 실전형 문제**를 같이 풀어본다.
CCNA 실제 시험은 영어라서 **핵심 용어는 영문을 함께** 표기했다.

> 💡 **진행 방법**: 문제를 먼저 각자 풀어보게 한 뒤 → `정답 및 해설` 콜아웃을 펼쳐 함께 확인한다.
> 8일차는 **"어디에 설정하나"** 가 핵심이다 → 답을 고르기 전에 **"이건 스위치 일일까, 라우터 일일까, 서버 일일까?"** 부터 묻자.

---

## Q1. 다른 VLAN 에서만 접속이 안 된다 — [1_원격접속_Telnet과SSH](lesson-1.md)

A Layer 2 switch has `interface vlan 10` configured with IP 192.168.10.253.
Hosts in **VLAN 10** can SSH to the switch, but hosts in **VLAN 20** cannot.
Inter-VLAN routing works for PCs. What is missing on the switch?
(VLAN 10 에서는 스위치에 SSH 가 되는데 VLAN 20 에서는 안 된다. PC 끼리는 VLAN 간 통신이 된다.)

- A. `ip routing`
- B. **`ip default-gateway 192.168.10.254`**
- C. `transport input telnet`
- D. `interface vlan 20` 에도 IP

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- L2 스위치는 **라우팅을 못 한다** → 다른 네트워크에 답장하려면 **PC 처럼 게이트웨이**가 필요하다
- VLAN 10 은 **같은 동네**라 게이트웨이 없이도 된다 → 그래서 "VLAN 10 만 된다"
- A 가 오답인 이유: `ip routing` 은 **L3 스위치**의 라우팅 기능. L2 스위치는 게이트웨이만 알면 된다
- D 가 오답인 이유: 관리용 IP 는 **하나면 충분**하다. 필요한 건 돌아갈 길(게이트웨이)
- 되짚기: 실습 STEP 1 에서 **PC1(VLAN 20)** 으로 SSH 한 장면
{% endhint %}

---

## Q2. SSH 설정 순서 — [1_원격접속_Telnet과SSH](lesson-1.md)

Which **two** commands must be configured **before** `crypto key generate rsa` can succeed?
(RSA 키 생성에 앞서 반드시 필요한 두 가지는? — 2개 고르기)

- A. `username admin secret <password>`
- B. **`hostname SW1`** (기본 이름이 아닌 것)
- C. **`ip domain-name student.local`**
- D. `transport input ssh`
- E. `ip ssh version 2`

{% hint style="success" %}
**정답 및 해설**

**정답: B, C**
- RSA 키의 이름표 = **호스트명 + 도메인명** (예: `SW1.student.local`)
- 도메인이 없으면 `% Please define a domain-name first.` · 이름이 기본값이면 `% Please define hostname other than Switch.`
- A · D 는 키 생성 **뒤에** 해도 된다 (로그인 · 접속 방식 설정)
- E 는 키가 **있어야** 켤 수 있다 (768비트 이상)
- 외우는 순서: **이름 → 도메인 → 키 → 계정 → SSH 만**
{% endhint %}

---

## Q3. VLAN 20 만 주소를 못 받는다 ⭐ — [2_DHCP와_DNS](lesson-2.md)

The DHCP server (192.168.10.10) is in **VLAN 10**. It has pools for VLAN 10 and VLAN 20.
PCs in VLAN 10 receive addresses. PCs in **VLAN 20** get **169.254.x.x**.
Router R1 uses subinterfaces g0/0.10 and g0/0.20. What should be configured?
(DHCP 서버는 VLAN 10 에 있고 풀은 둘 다 있다. VLAN 20 PC 만 169.254 를 받는다.)

- A. R1 g0/0.10 에 `ip helper-address 192.168.10.10`
- B. **R1 g0/0.20 에 `ip helper-address 192.168.10.10`**
- C. 서버에 `ip helper-address 192.168.20.254`
- D. 스위치의 트렁크에서 VLAN 20 을 허용

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- DHCP Discover 는 **브로드캐스트** → **라우터에서 멈춘다** (4일차 원칙)
- 릴레이는 **요청이 들어오는 쪽**(클라이언트 쪽) 인터페이스에 → VLAN 20 의 게이트웨이 = **g0/0.20**
- A 가 오답인 이유: VLAN 10 은 서버와 **같은 동네**라 원래 된다. 거기에 쳐도 VLAN 20 은 그대로
- C 가 오답인 이유: helper 는 **라우터(게이트웨이)** 명령이다
- D 가 오답인 이유: VLAN 20 PC 끼리는 **통신이 된다**는 전제 → 트렁크 문제가 아니다
- `169.254` = **DHCP 서버를 못 찾았다**는 신호 (2일차)
- 되짚기: 실습 STEP 3 에서 **PC2 는 되고 PC3 만 실패**한 그 표
{% endhint %}

---

## Q4. 포트 보안 위반 — [4_포트보안](lesson-4.md)

Port security is configured on Fa0/1 with `maximum 1`, `mac-address sticky`, and the **default** violation mode.
An unknown laptop is plugged into Fa0/1. What happens?
(sticky · maximum 1 · 위반 모드는 기본값. 모르는 노트북을 꽂으면?)

- A. 노트북 프레임만 버리고 포트는 계속 동작, 로그 없음
- B. 노트북 프레임만 버리고 포트는 계속 동작, 로그 · 카운터 증가
- C. **포트가 err-disabled 상태로 꺼지고, 관리자가 수동으로 복구해야 한다**
- D. sticky 이므로 노트북 MAC 을 새로 학습해 허용한다

{% hint style="success" %}
**정답 및 해설**

**정답: C**
- 기본 위반 모드 = **shutdown** → 포트 통째로 **err-disabled**
- 복구: **범인 제거 후** `shutdown` → `no shutdown`

| 모드 | 포트 | 기록 |
|---|---|---|
| **shutdown** (기본) | 꺼짐 | ✅ |
| restrict | 유지 | ✅ (B) |
| protect | 유지 | ❌ (A) |

- D 가 오답인 이유: sticky 는 **`maximum` 까지만** 배운다. 이미 PC0 의 MAC 하나로 **꽉 찼다**
- 되짚기: 실습 STEP 6 의 **빨간 불** · `Last Source Address` 로 범인 MAC 을 찾은 장면
{% endhint %}

---

## Q5. 포트 번호 — [3_SNMP_Proxy_FTP](lesson-3.md)

Match the protocols to the correct **default ports**. Which is correct?
(프로토콜과 기본 포트의 짝이 모두 옳은 것은?)

- A. SSH 23 · Telnet 22 · DNS 53
- B. FTP 21 · SNMP 161 · DHCP 53
- C. **SSH 22 · DNS 53 · DHCP 67/68**
- D. HTTP 8080 · FTP 20/21 · SNMP 162

{% hint style="success" %}
**정답 및 해설**

**정답: C**
- A: SSH 와 Telnet 이 **뒤바뀜** (SSH **22**, Telnet **23**)
- B: DHCP 는 **67/68** (53 은 DNS)
- D: HTTP 기본은 **80** (8080 은 흔한 대체 포트일 뿐)

| 20/21 | 22 | 23 | 53 | 67/68 | 80 | 161/162 |
|---|---|---|---|---|---|---|
| FTP | SSH | Telnet | DNS | DHCP | HTTP | SNMP |

- 외우는 법: **20~23 은 연속**(FTP · SSH · Telnet), **53 DNS**, **67/68 DHCP**, **80 웹**, **161 SNMP**
{% endhint %}

---

## 📝 강의 메모

- Q1(스위치 원격) → Q2(SSH 순서) → Q3(릴레이) → Q4(포트 보안) → Q5(포트 번호) — **오늘 실습 순서 그대로**
- **Q3 이 오늘의 최중요 문제.** "원칙(브로드캐스트는 못 넘는다) + 예외(helper)" 를 한 쌍으로 확인
  — A(서버 쪽에 친다)를 고르는 학생이 많다 → **"외침이 들어오는 문에 우체국을"**
- Q2 는 복수 정답 — CCNA 는 **"Choose two"** 형식이 자주 나온다고 알려줄 것
- Q5 포트표는 **네트워크관리사 필기**에도 그대로 나온다 → 칠판 번호순 표를 다시 짚기
- **1단계(1~8일차) 마무리** — 오늘 만든 서비스를 2단계에서 **리눅스로 직접** 만든다
  → [네트워크 2](../../network2/README.md) · 다음(9일차): [9일차 · 리눅스 설명](../../network2/day-09/README.md)
