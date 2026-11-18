# 8. 오늘의 CCNA

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N1-01-008-INS |
| 유형 | INS (점검) |
| 목적 | 1일차 내용을 CCNA 형식 문제 3개로 점검한다 |
| 확인 상태 | 미검증 (원본 문제와 해설을 정리한 것이며 문제와 정답을 공식 자료로 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 점검 방법

수업 마무리로 오늘 배운 내용에 맞춘 CCNA 실전형 문제 3개를 함께 푼다. CCNA 실제 시험은 영어이므로 핵심 용어는 영문을 함께 적었다.

1. 문제를 먼저 각자 풀어 본다.
2. `정답 및 해설` 상자를 보고 함께 확인한다.
3. 해설의 링크로 그날 배운 문서를 되짚는다.

## 2. 점검 항목

### Q1. OSI 계층과 장비

관련 문서: [6. 프로토콜 · OSI 7계층](lesson-6.md)(LEC-N1-01-006-DO)

Which OSI layer does a **router** primarily operate at, and what is the PDU (data unit) at that layer?
(라우터는 주로 OSI 몇 계층에서 동작하며, 그 계층의 데이터 단위(PDU)는 무엇인가?)

- A. 2계층(Data Link) — Frame
- B. 3계층(Network) — Packet
- C. 4계층(Transport) — Segment
- D. 1계층(Physical) — Bit

{% hint style="info" %}
**정답 및 해설**

**정답: B**
- 라우터는 논리 주소(IP)를 보고 경로를 결정하는 3계층(Network) 장비이며, 이 계층의 PDU는 Packet이다.
- A는 스위치(2계층, Frame), D는 허브·리피터(1계층, Bit)에 해당한다.
- C(Transport)의 PDU가 Segment(TCP/UDP)라는 것도 표에서 함께 짚는다.
- 되짚기: "3계층 = IP = 라우터 = Packet" 세트. → [6. 프로토콜 · OSI 7계층](lesson-6.md)의 계층 표
{% endhint %}

### Q2. 전송 방식(Cast)

관련 문서: [7. 유니 · 브로드 · 멀티캐스트](lesson-7.md)(LEC-N1-01-007-DO)

A host needs to send an **ARP Request** to learn a neighbor's MAC address.
Which transmission type is used, and what is the destination MAC address?
(호스트가 이웃의 MAC 주소를 알아내려고 ARP Request를 보낸다. 어떤 전송 방식이며 목적지 MAC은?)

- A. Unicast — `00:00:00:00:00:00`
- B. Multicast — `01:00:5E:00:00:01`
- C. Broadcast — `FF:FF:FF:FF:FF:FF`
- D. Anycast — 가장 가까운 하나

{% hint style="info" %}
**정답 및 해설**

**정답: C**
- MAC을 모르는 상태이므로 같은 네트워크 전체에 물어야 한다. 전송 방식은 Broadcast, 목적지 MAC은 `FF:FF:FF:FF:FF:FF`다.
- 브로드캐스트는 같은 브로드캐스트 도메인(스위치는 통과, 라우터는 차단) 안에서만 퍼진다.
- 되짚기: 카톡 비유로 1:1은 유니, 단톡은 멀티, 전체 공지는 브로드다. → [7. 유니 · 브로드 · 멀티캐스트](lesson-7.md)
- ARP의 MAC과 동작 상세는 3일차에서 이어진다. → [3일차 · 네트워크 장비와 네트워크 토폴로지](../day-03/README.md)
{% endhint %}

### Q3. 2진수와 IP

관련 문서: [3. Bit · Byte · 문자 코드](lesson-3.md)(LEC-N1-01-003-DO), [4. IP 주소](lesson-4.md)(LEC-N1-01-004-DO)

An IPv4 octet is shown in binary as `11000000`.
What is its decimal value? (2진수 `11000000`은 10진수로 얼마인가?)

- A. 168
- B. 172
- C. 192
- D. 255

{% hint style="info" %}
**정답 및 해설**

**정답: C**
- 자리값은 `128 64 32 16 8 4 2 1`이다. 켜진 자리(1)는 `128 + 64 = 192`다.
- 한 옥텟(octet)은 8bit = 1Byte이며 표현 범위는 0~255(2⁸ = 256가지)다. D(255)는 8자리가 모두 1일 때다.
- `11000000`은 사설망에서 흔한 `192.168.x.x`의 첫 옥텟이다. 개념과 실제 IP를 연결해 준다.
- 되짚기: 자리값 감각은 2일차 서브넷팅의 기초 체력이다. → [2일차 · IP와 서브넷](../day-02/README.md)
{% endhint %}

## 3. 합격 기준

| 번호 | 점검 항목 | 정답 | 합격 기준 |
|---|---|---|---|
| Q1 | 라우터의 계층과 PDU | B | 정답을 고르고 A, C, D가 각각 어떤 장비·계층인지 설명한다 |
| Q2 | ARP Request의 전송 방식과 목적지 MAC | C | 정답을 고르고 브로드캐스트를 쓰는 이유를 설명한다 |
| Q3 | `11000000`의 10진수 값 | C | 자리값 합산으로 192를 계산한다 |

## 4. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-3.md](lesson-3.md) | LEC-N1-01-003-DO | 3. Bit · Byte · 문자 코드 |
| [lesson-4.md](lesson-4.md) | LEC-N1-01-004-DO | 4. IP 주소 |
| [lesson-6.md](lesson-6.md) | LEC-N1-01-006-DO | 6. 프로토콜 · OSI 7계층 |
| [lesson-7.md](lesson-7.md) | LEC-N1-01-007-DO | 7. 유니 · 브로드 · 멀티캐스트 |
| [README.md](README.md) | - | 1일차 · 네트워크 기본 (상위) |

## 강의 메모

- 2~3문제만 부담 없이 푼다. 목적은 시험 감(感) 익히기와 오늘 복습이다.
- 해설을 펼치기 전에 왜 그 답인지 말로 설명하게 유도한다.
- 오답 보기도 각각 어떤 개념이나 장비에 해당하는지 짚으면 복습 효과가 크다.
