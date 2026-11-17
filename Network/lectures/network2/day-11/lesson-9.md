# 9. 오늘의 CCNA 🎯

> 상위: [11일차 · 서버 보안](README.md)
> 📌 **Q1 · Q2** 는 10일차에서 이월된 무선 · 공유기(NAT), **Q3~Q7** 이 오늘의 서버 보안(ACL · ufw)이다.

> 💡 **진행 방법**: 문제를 먼저 각자 풀어보게 한 뒤 → `정답 및 해설` 콜아웃을 펼쳐 함께 확인한다.

---

## Q1. NAT 용어 — [1_공유기_실습](lesson-1.md) · 대본 부록 A

In the output of `show ip nat translations`, the address **192.168.0.100** is the private address of a PC inside the network.
What is this address called?
(`show ip nat translations` 에서 안쪽 PC 의 사설 주소 192.168.0.100 을 부르는 이름은?)

- A. Inside global
- B. **Inside local**
- C. Outside local
- D. Outside global

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- **Inside local** = 안쪽 기기의 **진짜(사설)** 주소 — 안쪽(local)에서 쓰는 이름
- **Inside global** = 그 기기가 **밖에 보이는(공인)** 주소 → `203.0.113.2`
- 외우는 법: **inside/outside = 누구의 주소인가** (우리 집 기기 / 바깥 서버) · **local/global = 어디서 보이는 모습인가** (안에서 / 밖에서)
{% endhint %}

---

## Q2. 주소를 못 받았다 — [1_공유기_실습](lesson-1.md) · [10일차 DNS·DHCP](../day-10/lesson-10.md)

A PC is cabled to a LAN port on the home router, but it cannot reach any website.
`ipconfig` shows the address **169.254.23.7**. What is the most likely cause?
(공유기 LAN 포트에 유선으로 꽂았는데 웹이 안 된다. IP 가 169.254.23.7 이다. 가장 가능성 높은 원인은?)

- A. The web server is down
- B. The DNS server is down
- C. **The laptop did not receive an address from a DHCP server**
- D. The router's NAT translation table is full

{% hint style="success" %}
**정답 및 해설**

**정답: C**
- `169.254.x.x` = **APIPA** — DHCP 응답을 못 받으면 스스로 붙이는 주소 = **"고장 신호"** (2일차 · 8일차)
- A · B 가 원인이라면 IP 는 **정상(`192.168.0.x`)** 이었을 것이다. `169.254` 는 **주소를 못 받았다**는 신호다
- 흔한 원인: 공유기 **DHCP Disabled** · 케이블이 **WAN 포트**에 꽂힘 · 공유기 전원
- 진단 순서: **연결 → 주소(DHCP) → 이름(DNS)** — 가까운 곳부터
{% endhint %}

---

---

## Q3. 암묵적 deny — [4_ACL_표준](lesson-4.md) ⭐

A router is configured with only this one line, applied outbound on `g0/0`:
`access-list 10 deny host 192.168.20.10`
What happens to traffic from **192.168.20.11** leaving `g0/0`?
(이 한 줄만 적용했다. 192.168.20.11 의 트래픽은 어떻게 되나?)

- A. It is permitted, because the ACL only denies .20.10
- B. **It is denied by the implicit deny any at the end of the ACL**
- C. It is permitted, but logged
- D. The ACL is invalid and is ignored

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- 모든 ACL 끝에는 **보이지 않는 `deny any`** 가 있다 → 명시적으로 `permit` 하지 않은 것은 **전부 거부**
- 고치려면 `access-list 10 permit any` 를 **뒤에** 추가한다
- 실습에서 **개발팀 PC 까지 끊겼던** 그 장면이 바로 이것 (대본 STEP 4-4)
- 외우는 법: **"ACL 은 화이트리스트다. 허용을 안 적으면 아무도 못 지나간다."**
{% endhint %}

---

## Q4. ACL 배치 — [4_ACL_표준](lesson-4.md) · [5_ACL_확장](lesson-5.md)

Where should a **standard** ACL be placed, and why?
(표준 ACL 은 어디에 두어야 하며, 그 이유는?)

- A. Closest to the source, because it is processed faster
- B. **Closest to the destination, because it only matches the source address**
- C. Anywhere — placement does not matter for standard ACLs
- D. On every interface of every router in the path

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- **표준 = 출발지만 본다** → 출발지 가까이 두면 그 PC 의 **모든 통신**이 막힌다(과잉 차단)
- **확장 = 목적지·포트까지 본다** → 출발지 가까이 두어 **일찍 버리는 것**이 효율적
- 한 줄 암기: **"표준은 목적지 가까이, 확장은 출발지 가까이"**
{% endhint %}

---

## Q5. 확장 ACL 문장 — [5_ACL_확장](lesson-5.md) · [10일차 포트](../day-10/lesson-8.md)

You must allow **only** host `192.168.20.11` to reach the web service on server `192.168.10.100`.
Which line is correct?
(개발 PC 한 대만 서버의 웹에 접근하게 하려면?)

- A. `access-list 110 permit tcp host 192.168.20.11 host 192.168.10.100 eq 22`
- B. `access-list 10 permit host 192.168.20.11`
- C. **`access-list 110 permit tcp host 192.168.20.11 host 192.168.10.100 eq 80`**
- D. `access-list 110 permit tcp host 192.168.10.100 host 192.168.20.11 eq 80`

{% hint style="success" %}
**정답 및 해설**

**정답: C**
- 웹 = **80번**(A 의 22 는 SSH) → 10일차 포트표 회수
- B 는 **표준(10번)** 이라 목적지·포트를 쓸 수 없다
- D 는 **출발지와 목적지가 뒤바뀌었다** — 서버가 PC 에 접속하는 규칙이 되어 버린다
- 순서: `permit tcp <출발지> <목적지> eq <포트>` — **포트는 목적지 쪽에** 붙는다
{% endhint %}

---

## Q6. ufw 함정 — [6_리눅스_방화벽_ufw](lesson-6.md) ⭐⭐

You are connected to a remote Ubuntu server over SSH. You run `sudo ufw enable` **without any other rule**.
What is the result?
(SSH 로 원격 접속 중인데 규칙 없이 `ufw enable` 을 실행했다. 결과는?)

- A. Nothing changes until the server reboots
- B. **The SSH session is dropped and you cannot reconnect**
- C. ufw automatically allows port 22 to protect you
- D. Only outbound traffic is blocked

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- ufw 기본 정책은 **`deny (incoming)`** — SSH 도 "들어오는 것"이다
- 반드시 **`sudo ufw allow 22/tcp` 를 먼저**, 그 다음 `sudo ufw enable`
- 복구: **콘솔(VirtualBox 창)로 직접 로그인** → `sudo ufw disable`. 클라우드 서버라면 **복구가 매우 어렵다**
- C 는 오답이지만 위험한 오해다 — **ufw 는 알아서 지켜 주지 않는다**
{% endhint %}

---

## Q7. 진단 — [8_정리와_안될때_점검](lesson-8.md) ⭐

On a server, `curl localhost:8000` succeeds, but a PC on the same LAN gets a **timeout**.
What should you check **first**?
(서버 안에서는 되는데 같은 랜의 PC 에서는 타임아웃이다. 가장 먼저 볼 것은?)

- A. The web service configuration file
- B. The DNS server
- C. **The host firewall (ufw) rules**
- D. Reinstall the web server

{% hint style="success" %}
**정답 및 해설**

**정답: C**
- **①(LISTEN) ②(로컬 접속) 는 통과 → 서비스는 정상**이다. 밖에서만 안 되면 **③ 방화벽**이 가장 유력
- **타임아웃 = 조용히 버려짐(`deny`)** 의 전형적인 증상. 반대로 `Connection refused` 면 서비스 쪽을 본다
- 네 단계 좁히기: **① `ss -tuln` → ② `curl localhost` → ③ `ufw status numbered` → ④ `ip a` · `ping`**
{% endhint %}

---

## 📝 강의 메모

- Q1 의 inside/outside · local/global 은 **CCNA 단골 함정** — 칠판에 2×2 표를 그려서
- Q2 는 **순서(연결 → DHCP → DNS)로 진단**하는 연습 — 1단계 "가까운 곳부터" 점검법과 같다 (무선은 다루지 않으므로 유선 기준으로 출제)
- ⭐ **Q3(암묵적 deny)** 와 **Q6(ufw 함정)** 은 오늘 실습에서 **직접 당해 본 것**이다. 문제 풀기 전에 "아까 그거"라고 상기시킬 것
- Q5 는 10일차 **포트표**를 ACL 문장에 옮기는 연습 — 틀리면 포트표부터 다시
- Q7 의 **네 단계 좁히기**는 12일차 내내 쓴다 → [12일차 8번](../day-12/lesson-8.md)
