# 3. 선 두 줄을 하나로 — STP 다시 보기와 EtherChannel

> 상위: [7일차 · 스위칭 심화](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N1-07-003-DO |
| 유형 | D&O (개념) |
| 목적 | STP가 막는 포트를 정하는 원리(루트 브리지), PortFast, EtherChannel(LACP·PAgP·on)의 원리와 조건을 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 장비에서 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- 스위치 사이에 선을 두 줄 이으면 STP가 하나를 막는다는 것을 다시 확인한다.
- 루트 브리지가 어떻게 뽑히고 어느 포트가 막히는지 `show spanning-tree`로 읽는다.
- PortFast로 3일차의 "주황 점 30초"를 없앤다.
- EtherChannel이 여러 선을 논리적으로 한 줄로 묶어 STP 문제를 푸는 원리를 이해한다.
- LACP / PAgP / on 모드 조합과 묶이기 위한 조건을 안다.

## 이전 학습과의 연결

[2_트렁크와_VLAN간_라우팅](lesson-2.md)에서 모든 부서 트래픽이 트렁크 한 줄을 탄다는 것을 봤다.

```
 [SW1] ──────────── 선 한 줄 ──────────── [SW2]
         영업10 + 개발20 + 부서간 통신 전부
```

| 걱정 | 뜻 |
|---|---|
| 병목 | 100Mbps 선 하나를 두 부서가 나눠 쓴다 |
| 단일 장애점 | 이 선이 빠지면 3층 전체가 끊긴다 |

당연한 해결책은 선을 하나 더 꽂는 것이다. 그런데 4일차에 이미 답을 들었다. "스위치 두 대를 선 두 줄로 연결하면?" → 루프 → 브로드캐스트 스톰 → 그래서 STP가 하나를 막는다. → [1_스위치_동작원리](../day-04/lesson-1.md) · [4_오늘의_CCNA](../day-04/lesson-4.md)

질문: 선을 두 줄 꽂았는데 STP가 하나를 막았다. 속도는 두 배가 됐을까? 아니다. 하나는 대기 상태로 놀고 있다. 끊겨야 비로소 일한다. 돈 주고 산 선의 절반이 노는 셈이다.

오늘은 두 가지를 본다. 1) STP가 누구를 막을지 어떻게 정하는지, 2) 막을 이유를 아예 없애는 EtherChannel.

## 1. 구성 요소

### 1-1. STP 다시 보기 — 누가 막을지는 누가 정하나

#### 루트 브리지 — 나무의 뿌리

STP는 스위치들 중 대장 하나(루트 브리지)를 뽑는다. 대장에게 가는 가장 좋은 길만 남기고 나머지를 막는다.

```
         [SW1] 루트 브리지 (대장)
          ║  ║
   Fa0/23 ║  ║ Fa0/24          루트의 포트는 전부 FWD (지정 포트)
          ║  ║
         [SW2]
   Fa0/23  Root(FWD)            대장에게 가는 최선의 길 = 루트 포트
   Fa0/24  Altn(BLK)            남는 길 = 대체 포트 → 막는다
```

대장은 Bridge ID가 가장 작은 스위치다.

```
Bridge ID  =  우선순위(Priority)  +  MAC 주소
              기본 32768 (+VLAN번호)   공장에서 박힌 값
```

1. 우선순위가 작은 쪽이 이긴다(기본은 모두 32768이므로 비긴다).
2. 비기면 MAC이 작은 쪽이 이긴다. 결국 가장 오래된(MAC이 작은) 스위치가 대장이 되기 쉽다.

{% hint style="info" %}
NOTE: 비유는 반장 선거다. 원래는 추천(우선순위)으로 뽑는데 아무도 추천하지 않으면 출석번호(MAC)가 빠른 사람이 반장이 된다. 가장 느린 구형 스위치가 반장이 되는 사고가 여기서 난다. 그래서 실무에서는 반장을 직접 지명한다: `spanning-tree vlan 10,20 root primary`
{% endhint %}

{% hint style="info" %}
NOTE: 막히는 포트는 대장이 아닌 쪽 스위치에 있다. 한쪽만 보고 "BLK가 없다"고 판단하지 말고 두 대 다 확인한다.
{% endhint %}

#### `show spanning-tree` 읽기 (루트가 아닌 SW2)

```
VLAN0010
  Spanning tree enabled protocol ieee
  Root ID    Priority    32778
             Address     0001.4295.1A01          ← 대장(루트)의 MAC
             Cost        19
             Port        23(FastEthernet0/23)    ← 대장에게 가는 내 포트

  Bridge ID  Priority    32778  (priority 32768 sys-id-ext 10)
             Address     000C.85B2.3C02          ← 나(SW2)의 MAC

Interface        Role Sts Cost      Prio.Nbr Type
---------------- ---- --- --------- -------- ----------
Fa0/1            Desg FWD 19        128.1    P2p
Fa0/23           Root FWD 19        128.23   P2p
Fa0/24           Altn BLK 19        128.24   P2p     ← 막힌 선
```

| 읽을 곳 | 뜻 |
|---|---|
| VLAN0010 | STP는 VLAN마다 따로 돈다(PVST+). VLAN0001 · 0020도 있다 |
| Priority 32778 | 32768 + VLAN 번호 10 |
| This bridge is the root | 이 문구가 있으면 내가 대장이다(SW1 쪽에서 보인다) |
| Role | `Root` 대장 가는 길 · `Desg` 내보내는 포트 · `Altn` 대체(대기) |
| Sts | `FWD` 통과 · `BLK` 막힘 · `LIS`/`LRN` 확인 중(주황 점) |

#### PortFast — 3일차의 "주황 점 30초"를 없앤다

- 포트가 켜지면 STP는 루프가 없는지 Listening → Learning 단계를 거친다. 약 30초가 걸린다(4일차).
- PC 한 대만 꽂는 포트에는 루프가 생길 수 없다. 그래서 확인을 건너뛴다. 이것이 PortFast다.

```bash
interface range fa0/1 - 2
 spanning-tree portfast          # PC 포트만! 스위치끼리 잇는 포트엔 절대 금지
```

{% hint style="danger" %}
WARNING: PortFast는 PC 포트에만 켠다. 스위치를 잇는 포트에 켜면 STP의 안전장치를 스스로 끄는 것이어서 루프가 생길 수 있다. 실무에서는 PortFast 포트에 누가 스위치를 꽂으면 포트를 막는 BPDU Guard(`spanning-tree bpduguard enable`)를 같이 켠다(이름만 안다).
{% endhint %}

3일차 → 4일차 → 7일차로 이어진 떡밥의 끝이다. "주황 점은 고장이 아니다(3일차) → STP가 확인하는 중이다(4일차) → PC 포트라면 건너뛸 수 있다(오늘)."

### 1-2. EtherChannel — 두 줄을 한 줄로 신고한다

#### 아이디어

STP가 막는 이유는 길이 두 개이기 때문이다. 두 선을 하나로 묶어 길은 하나라고 신고하면 막을 이유가 없다.

```
  묶기 전                             묶은 뒤
 [SW1] ─── Fa0/23 ─── [SW2]          [SW1] ═══ Po1 ═══ [SW2]
       ─── Fa0/24 ─── (BLK)                (Fa0/23 + Fa0/24)
  STP: "길이 둘이다, 하나 막아!"       STP: "길이 하나네, 통과"
```

- 여러 물리 선을 논리 인터페이스 하나(Port-channel, `Po1`)로 묶는다.
- STP는 `Po1`을 포트 하나로 본다. 막을 이유가 없으므로 두 선이 다 일한다.

{% hint style="info" %}
NOTE: 비유는 왕복 2차선 도로 두 개다. 교통경찰(STP)은 "길이 두 개면 차가 뱅뱅 돈다"며 하나를 폐쇄한다. 두 도로를 4차선 도로 하나로 합쳐 신고하면 폐쇄할 이유가 없다. 차선 하나가 공사 중이어도 도로는 계속 열려 있다.
{% endhint %}

| 얻는 것 | 설명 |
|---|---|
| 대역폭 증가 | 100M × 2 = 200M급 통로 |
| 이중화 | 선 하나가 끊겨도 `Po1`은 up 그대로다. STP 재계산(30초)도 없다 |
| 관리 편의 | 설정은 `Po1` 한 곳에서 한다 |

{% hint style="info" %}
NOTE: "두 배 빨라진다"의 정확한 뜻은 다음과 같다. 대화(흐름) 하나는 선 하나를 탄다. 파일 하나가 두 배 빨라지는 것이 아니라, 여러 대화가 두 선에 나눠 타서 전체가 넓어진다. 차선이 늘어난 도로와 같다.
{% endhint %}

#### 묶는 방식 — 서로 "묶자"고 합의해야 한다

| 방식 | 누가 만들었나 | 모드 |
|---|---|---|
| LACP (권장) | 국제 표준 (IEEE 802.3ad) | `active`(먼저 제안) · `passive`(제안 오면 응함) |
| PAgP | 시스코 전용 | `desirable`(먼저 제안) · `auto`(제안 오면 응함) |
| on | — | 협상 없이 무조건 묶음 |

조합표 — 묶이는가?

| SW1 \ SW2 | active | passive | desirable | auto | on |
|---|:---:|:---:|:---:|:---:|:---:|
| active | O | O | X | X | X |
| passive | O | X | X | X | X |
| desirable | X | X | O | O | X |
| auto | X | X | O | X | X |
| on | X | X | X | X | O |

- 둘 다 기다리기만 하면(passive–passive, auto–auto) 묶이지 않는다. DTP의 auto–auto와 같은 이치다. ([2_트렁크와_VLAN간_라우팅](lesson-2.md))
- 방식이 다르면(LACP–PAgP) 묶이지 않는다. 서로 다른 언어이기 때문이다.
- 오늘의 원칙은 양쪽 다 `active`다(표준이고 확실하다).

{% hint style="danger" %}
WARNING: `on`은 위험하다. 협상이 없어서 한쪽만 `on`이면 묶인 줄 알고 보내는데 상대는 모른다. 루프와 장애가 생긴다.
{% endhint %}

#### 묶이려면 양쪽 선의 설정이 같아야 한다

| 조건 | 예 |
|---|---|
| 속도 · 듀플렉스 | 둘 다 100M / full |
| 포트 모드 | 둘 다 트렁크 (하나만 액세스이면 안 된다) |
| VLAN 설정 | 액세스면 같은 VLAN, 트렁크면 같은 허용 VLAN · 네이티브 VLAN |

그래서 `interface range`로 두 포트를 한꺼번에 설정한다. 설정이 어긋날 틈이 없다.

#### 설정 (양쪽 스위치에 똑같이)

```bash
interface range fa0/23 - 24
 shutdown                              # 1) 묶는 동안 잠깐 끈다 (루프 방지)
 switchport mode trunk                 # 2) 둘 다 트렁크로 똑같이
 channel-group 1 mode active           # 3) 1번 묶음에 넣는다 (LACP)
 no shutdown
 exit
interface port-channel 1               # 4) 만들어진 논리 포트
 switchport mode trunk
end
show etherchannel summary
```

#### `show etherchannel summary` 읽기

```
Flags:  D - down        P - in port-channel
        I - stand-alone s - suspended
        S - Layer2      U - in use
...
Group  Port-channel  Protocol    Ports
------+-------------+-----------+------------------------------
1      Po1(SU)           LACP   Fa0/23(P) Fa0/24(P)
```

| 표시 | 뜻 | 정상 여부 |
|---|---|:---:|
| Po1(SU) | S 2계층 · U 사용 중 | 정상 |
| Fa0/23(P) | P = 묶음에 들어갔다 | 정상 |
| `(SD)` | 묶음이 down. 상대가 받아 주지 않는다 | 비정상 |
| `(I)` / `(s)` | 혼자 놀거나(stand-alone) 정지(suspended). 조건이 불일치한다 | 비정상 |

묶은 뒤 `show spanning-tree`를 보면 Fa0/23 · Fa0/24가 사라지고 `Po1` 한 줄만 `FWD`로 남는다.

## 2. 동작 원리

1. 선이 두 줄이면 STP는 루프 가능성을 보고 루트에서 먼 쪽 한 줄을 `Altn BLK`로 막는다.
2. 막힌 선은 대기 상태다. 쓰던 선이 끊기면 STP가 다시 계산해 막아 둔 선을 연다. 최대 30~50초가 걸린다.
3. EtherChannel은 두 선을 `Po1` 하나로 묶는다. STP는 `Po1`만 보므로 막을 선이 없다.
4. 묶음 안에서는 흐름(출발지·목적지 주소 등의 해시)마다 한 선이 정해진다. 여러 흐름이 두 선에 나뉘어 탄다.
5. 선 하나가 끊겨도 `Po1`은 up을 유지한다. 남은 선으로 계속 통신하므로 재계산이 없다.

## 3. 실습·질문 연결

- 실습 STEP 4(두 번째 선 → STP 확인 → EtherChannel) · STEP 5(PortFast · 루트 지명) → [0_실습_명령어_모음](commands.md) · 실습 절차 [4_스위칭_실습](lesson-4.md)
- 선을 꽂았는데 한쪽 링크만 주황이다. 고장인가? → 아니다. STP가 막은 것이다(`Altn BLK`).
- EtherChannel을 한쪽 스위치만 설정했다. → 묶이지 않는다. 양쪽 다 설정해야 한다.
- SW1은 `active`, SW2는 `desirable`이다. → 묶이지 않는다. LACP와 PAgP는 서로 모른다.
- 묶은 뒤 선 하나를 뽑으면? → `Po1`은 up 그대로이고 통신은 끊기지 않는다.

## 4. 강의 메모

- 4일차 CCNA(STP를 끈 채 두 줄 연결) 문제를 다시 띄우고 시작하면 흐름이 산다.
- "선 두 줄인데 속도는 그대로다"라는 불만이 EtherChannel의 동기다. 학생이 먼저 말하게 한다.
- 루트 브리지는 반장 선거다(추천이 없으면 출석번호). MAC이 작은 구형 스위치가 대장이 되는 사고까지 말해 줘야 `root primary`가 와닿는다.
- STP는 VLAN마다 따로 돈다(PVST+). `show spanning-tree`가 VLAN 수만큼 길게 나오는 이유다.
- PortFast는 3일차 주황 점 떡밥의 최종 회수다. 실습에서 "꽂자마자 초록"을 꼭 보여 준다.
- EtherChannel 조합표는 외우게 하지 않고 3줄로 정리한다. "둘 다 기다리면 안 된다 · 언어가 다르면 안 된다 · `on`은 위험하다."
- 설정 순서 사고가 많다. "끄고, 똑같이, 묶고, 켠다"를 구호로 쓴다.

## 5. 약어·용어

| 용어 | 뜻 |
|---|---|
| STP | Spanning Tree Protocol. 2계층 루프를 막는 프로토콜 |
| PVST+ | Per-VLAN Spanning Tree Plus. VLAN마다 STP를 따로 도는 시스코 방식 |
| BPDU | Bridge Protocol Data Unit. STP 정보를 주고받는 메시지 |
| Bridge ID | 우선순위와 MAC으로 만든 스위치 식별값. 작을수록 루트가 된다 |
| 루트 포트 (Root) | 루트 브리지로 가는 최선의 포트 |
| 지정 포트 (Desg) | 세그먼트에서 프레임을 내보내는 포트 |
| 대체 포트 (Altn) | 막혀 있는 대기 포트 |
| PortFast | 호스트 포트를 STP 대기 없이 바로 Forwarding으로 전환하는 기능 |
| BPDU Guard | PortFast 포트에 BPDU가 들어오면 포트를 차단하는 기능 |
| EtherChannel | 여러 물리 링크를 논리 링크 하나로 묶는 기술 |
| LACP | Link Aggregation Control Protocol. 표준 묶음 협상(IEEE 802.3ad) |
| PAgP | Port Aggregation Protocol. 시스코 전용 묶음 협상 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 선을 두 줄 이었는데 속도가 두 배가 되지 않는 이유를 내 말로 설명해 본다.
- [ ] EtherChannel로 묶으면 STP가 막지 않는 이유는 무엇일까?
- [ ] 실습에서 주황 점이 오래 남았던 경험이 있다면, 어느 포트였고 어떻게 판단했는지 적어 본다.
