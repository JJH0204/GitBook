# 8. 오늘의 CCNA 🎯

> 상위: [1일차 · 네트워크 기본](README.md)

수업 마무리로 **오늘 배운 내용에 맞춘 CCNA 실전형 문제 2~3개**를 같이 풀어본다.
CCNA 실제 시험은 영어라서 **핵심 용어는 영문을 함께** 표기했다.

> 💡 **진행 방법**: 문제를 먼저 각자 풀어보게 한 뒤 → `정답 및 해설` 콜아웃을 펼쳐 함께 확인한다.
> (해설의 위키링크로 그날 배운 노트로 바로 되짚어줄 수 있다.)

---

## Q1. OSI 계층과 장비 — [6_프로토콜_OSI7계층](lesson-6.md)

Which OSI layer does a **router** primarily operate at, and what is the PDU (data unit) at that layer?
(라우터는 주로 OSI 몇 계층에서 동작하며, 그 계층의 데이터 단위(PDU)는 무엇인가?)

- A. 2계층(Data Link) — Frame
- B. 3계층(Network) — Packet
- C. 4계층(Transport) — Segment
- D. 1계층(Physical) — Bit

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- 라우터는 **논리 주소(IP)** 를 보고 경로를 결정하는 **3계층(Network)** 장비이며, 이 계층의 PDU는 **Packet**이다.
- A는 **스위치**(2계층, Frame), D는 **허브/리피터**(1계층, Bit)에 해당한다.
- C(Transport)의 PDU가 **Segment(TCP/UDP)** 라는 것도 표에서 함께 짚어주기.
- 되짚기: "**3계층 = IP = 라우터 = Packet**" 세트 → [6_프로토콜_OSI7계층](lesson-6.md) 계층 표
{% endhint %}

---

## Q2. 전송 방식(Cast) — [7_캐스트_유니_브로드_멀티](lesson-7.md)

A host needs to send an **ARP Request** to learn a neighbor's MAC address.
Which transmission type is used, and what is the destination MAC address?
(호스트가 이웃의 MAC 주소를 알아내려고 ARP Request를 보낸다. 어떤 전송 방식이며 목적지 MAC은?)

- A. Unicast — `00:00:00:00:00:00`
- B. Multicast — `01:00:5E:00:00:01`
- C. Broadcast — `FF:FF:FF:FF:FF:FF`
- D. Anycast — 가장 가까운 하나

{% hint style="success" %}
**정답 및 해설**

**정답: C**
- MAC을 **모르는** 상태라 "동네(같은 네트워크) 전체"에 물어봐야 하므로 **Broadcast**, 목적지 MAC은 `FF:FF:FF:FF:FF:FF`.
- 브로드캐스트는 같은 **브로드캐스트 도메인**(스위치는 통과, **라우터는 차단**) 안에서만 퍼진다.
- 되짚기: 카톡 비유 — 1:1(유니) / 단톡(멀티) / 전체공지(브로드) → [7_캐스트_유니_브로드_멀티](lesson-7.md)
- ARP의 MAC/동작 상세는 **3일차**에서 이어짐 → [3일차 · 네트워크 장비와 네트워크 토폴로지](../day-03/README.md)
{% endhint %}

---

## Q3. 2진수와 IP — [3_Bit_Byte_문자코드](lesson-3.md) · [4_어디로_보낼까_IP주소](lesson-4.md)

An IPv4 octet is shown in binary as `11000000`.
What is its decimal value? (2진수 `11000000` 은 10진수로 얼마인가?)

- A. 168
- B. 172
- C. 192
- D. 255

{% hint style="success" %}
**정답 및 해설**

**정답: C**
- 자리값: `128 64 32 16 8 4 2 1` → 켜진 자리(1) = `128 + 64 = 192`.
- 한 옥텟(octet) = **8bit = 1Byte** → 표현 범위 **0~255**(2⁸ = 256가지). D(255)는 8자리 전부 1일 때.
- `11000000` 은 사설망에서 흔한 `192.168.x.x`의 첫 옥텟 → 개념과 실제 IP를 연결해주기.
- 되짚기: 자리값 감각은 **2일차 서브넷팅의 기초 체력** → [2일차 · IP와 서브넷](../day-02/README.md)
{% endhint %}

---

## 📝 강의 메모

- 2~3문제만, **부담 없이** — "시험 감(感) 익히기 + 오늘 복습" 이 목적
- 해설 펼치기 전에 **왜 그 답인지 말로 설명**하게 유도 (개념 이해 확인)
- 오답 보기도 각각 어떤 개념/장비에 해당하는지 짚어주면 복습 효과 ↑
