# 5. 오늘의 CCNA

> 상위: [7일차 · 스위칭 심화](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N1-07-006-INS |
| 유형 | INS (점검) |
| 목적 | 7일차 학습 내용을 CCNA 실전형 문제 5문항으로 점검한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 문항과 해설을 다시 검증하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 점검 방법

수업 마무리로 오늘 배운 내용에 맞춘 CCNA 실전형 문제를 같이 푼다. CCNA 실제 시험은 영어라서 핵심 용어는 영문을 함께 표기했다.

문제를 먼저 각자 풀게 한 뒤 정답 및 해설을 함께 확인한다. 7일차는 포트 종류가 핵심이다. 답을 고르기 전에 "이 포트는 액세스일까 트렁크일까?"부터 묻는다.

---

## Q1. VLAN이 나누는 것 — [1_VLAN](lesson-1.md)

A switch has **24 ports** in **3 VLANs**. No routers are involved.
How many **broadcast domains** exist on this switch?
(24포트 스위치에 VLAN이 3개 있다. 브로드캐스트 도메인은 몇 개인가?)

- A. 1
- B. 3
- C. 24
- D. 27

{% hint style="info" %}
NOTE: 정답 및 해설

정답: B

- VLAN 하나 = 브로드캐스트 도메인 하나다. VLAN이 3개면 3개다.
- A가 오답인 이유: VLAN이 없을 때의 답이다(스위치 전체가 하나, 4일차).
- C가 오답인 이유: 24는 콜리전 도메인 수다(스위치는 포트마다 콜리전 도메인을 나눈다).
- 되짚기: 3일차 CCNA Q5(24포트 스위치 도메인 세기) 해설 끝의 "(현실적으로는 VLAN)"이 오늘이다. → [5_오늘의_CCNA](../day-03/lesson-5.md)

| 장비 | 콜리전 도메인 | 브로드캐스트 도메인 |
|---|---|---|
| 허브 | 1 | 1 |
| 스위치 (VLAN 없음) | 포트 수 | 1 |
| 스위치 (VLAN 3개) | 포트 수 | 3 |
| 라우터 | 포트 수 | 포트 수 |
{% endhint %}

---

## Q2. 같은 VLAN인데 왜 안 되나 — [2_트렁크와_VLAN간_라우팅](lesson-2.md)

PC-A (VLAN 10, SW1) cannot ping PC-B (**VLAN 10**, SW2).
Both PCs are in the same subnet. The link between SW1 and SW2 is up.
`show interfaces trunk` on SW1 shows **nothing**. What is the problem?
(같은 VLAN · 같은 서브넷인데 스위치를 넘어가지 못한다. SW1의 `show interfaces trunk`가 비어 있다.)

- A. PC의 게이트웨이가 잘못됐다
- B. 스위치 사이 링크가 트렁크가 아니라 액세스 포트(VLAN 1)로 동작하고 있다
- C. 라우터가 없어서 같은 VLAN끼리도 통신할 수 없다
- D. VLAN 10에 이름(name)을 붙이지 않았다

{% hint style="info" %}
NOTE: 정답 및 해설

정답: B

- `show interfaces trunk`가 비어 있다는 것은 트렁크가 하나도 없다는 뜻이다.
- 스위치 사이가 VLAN 1 액세스 포트면 VLAN 10 프레임은 건너갈 수 없다.
- 해결: 양쪽에 `switchport mode trunk`를 입력한다.
- A가 오답인 이유: 같은 서브넷끼리는 게이트웨이를 쓰지 않는다.
- C가 오답인 이유: 라우터는 다른 VLAN으로 갈 때 필요하다. 같은 VLAN은 트렁크면 충분하다.
- 2960 기본값은 `dynamic auto`다. 양쪽 다 기본값이면 트렁크가 맺어지지 않는다(둘 다 기다리기만 한다).
- 되짚기: 실습 STEP 1 끝에서 "나눴더니 오히려 안 된다"를 본 그 장면이다.
{% endhint %}

---

## Q3. Router-on-a-stick 설정 순서 — [2_트렁크와_VLAN간_라우팅](lesson-2.md)

An engineer configures R1 for inter-VLAN routing:
```
interface g0/0.20
 ip address 192.168.20.254 255.255.255.0
```
The router **rejects** the IP address. What must be configured **first**?
(서브인터페이스에 IP를 넣었더니 거부됐다. 무엇을 먼저 해야 하나?)

- A. `no shutdown` on g0/0.20
- B. `encapsulation dot1Q 20` on g0/0.20
- C. `switchport mode trunk` on g0/0
- D. `ip routing` in global configuration

{% hint style="info" %}
NOTE: 정답 및 해설

정답: B

- 서브인터페이스는 어느 VLAN 태그 담당인지 먼저 알아야 주소를 받는다. "태그 먼저, 주소 나중"이다.
- C가 오답인 이유: `switchport`는 스위치 명령이다. 라우터 포트에는 없다. 트렁크 설정은 라우터와 연결된 스위치 포트에서 한다.
- D가 오답인 이유: `ip routing`은 L3 스위치에서 라우팅을 켜는 명령이다. 라우터는 원래 켜져 있다.
- A: 켜야 하는 것은 물리 포트 g0/0이다. 서브인터페이스는 물리 포트를 따라간다.
- 되짚기: 실습에서 일부러 틀리게 먼저 입력해 본 그 거절 메시지다.
{% endhint %}

---

## Q4. 선 두 줄, 하나는 논다 — [3_EtherChannel과_STP](lesson-3.md)

Two switches are connected by **two** FastEthernet links. STP is running (default).
`show spanning-tree` on SW2 shows:
```
Fa0/23   Root FWD 19  128.23  P2p
Fa0/24   Altn BLK 19  128.24  P2p
```
Which statement is true?
(스위치 두 대를 두 줄로 이었다. SW2의 출력이 위와 같다. 옳은 것은?)

- A. Fa0/24 케이블이 불량이다
- B. SW2가 루트 브리지다
- C. STP가 루프를 막으려고 Fa0/24를 차단했고, 대역폭은 한 줄분(100M)만 쓰인다
- D. 두 링크가 로드 밸런싱되어 200M로 동작한다

{% hint style="info" %}
NOTE: 정답 및 해설

정답: C

- `Altn BLK`는 대체(Alternate) 포트, 차단(Blocking) 상태다. 루프 방지를 위해 STP가 일부러 막은 것이다.
- 막힌 선은 대기 상태다. 쓰던 선이 끊겨야 일한다. 대역폭은 한 줄분이다.
- B가 오답인 이유: `Root` 포트가 있다는 것은 루트로 가는 길이 있다는 뜻이고, 나는 루트가 아니라는 뜻이다. 루트 브리지의 포트는 전부 `Desg`다.
- D가 오답인 이유: 그렇게 하려면 EtherChannel로 묶어야 한다.
- 되짚기: 4일차 CCNA "STP를 끄고 두 줄로 이으면?" → 스톰. 켜면? → 하나를 막는다. 둘 다 쓰려면? → 오늘의 EtherChannel.
{% endhint %}

---

## Q5. EtherChannel 모드 조합 — [3_EtherChannel과_STP](lesson-3.md)

Which combination **successfully forms** an EtherChannel?
(EtherChannel이 맺어지는 조합은?)

- A. SW1 `mode passive` — SW2 `mode passive`
- B. SW1 `mode auto` — SW2 `mode auto`
- C. SW1 `mode active` — SW2 `mode desirable`
- D. SW1 `mode active` — SW2 `mode passive`

{% hint style="info" %}
NOTE: 정답 및 해설

정답: D

- LACP: `active`(먼저 제안) — `passive`(제안 오면 응함). 한쪽이 먼저 말하므로 성립한다.
- A·B가 오답인 이유: 둘 다 기다리기만 한다. 아무도 먼저 말하지 않는다(트렁크의 auto–auto와 같은 이치).
- C가 오답인 이유: `active`는 LACP, `desirable`은 PAgP다. 언어가 다르다.

| | LACP (표준 802.3ad) | PAgP (시스코) |
|---|---|---|
| 먼저 제안 | `active` | `desirable` |
| 응답만 | `passive` | `auto` |

- 외우는 법: "둘 다 기다리면 안 된다. 언어가 다르면 안 된다. `on`은 `on`끼리만 된다."
- 실무 원칙: 양쪽 다 `active`(표준이고 확실하다).
{% endhint %}

---

## 강의 메모

- Q1(나누기) → Q2(잇기) → Q3(넘기) → Q4(막힘) → Q5(묶기). 오늘 실습 STEP 순서 그대로다.
- Q1은 3일차 CCNA Q5의 회수다. 3일차 문제를 화면에 다시 띄우고 "그때 괄호로 VLAN이라고 했다"로 시작한다.
- Q2가 오늘의 최중요 문제다. 실무 장애 1위("같은 VLAN인데 안 된다")와 똑같다.
- Q3은 C(`switchport`는 스위치 명령)를 고르는 학생이 꽤 있다. 라우터와 스위치 명령을 구분시키는 기회다.
- Q4는 출력 두 줄을 손가락으로 짚어 가며 푼다. `Root`가 있으면 루트가 아니라는 역설을 즐기게 한다.
- Q5 조합표는 외우게 하지 말고 3줄 구호로 정리한다.
- 다음 예고: "회사망은 깔았다. 이제 이 망을 관리하고, 주소를 자동으로 나눠 주고, 지키자." → [8일차](../day-08/README.md)
