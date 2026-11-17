# 스패닝 트리 프로토콜 (STP)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-RSW-007-DO |
| 유형 | D&O (개념) |
| 목적 | STP가 스위치 루프를 막는 방식, 포트 역할 선출 규칙, 포트 상태, 수렴 시간을 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 출처를 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 수렴 시간(55초)은 계산이 맞지 않아 정정했다. 포트 상태와 Root Port 동점 규칙은 원본에 없던 내용이다. 확인 필요.
{% endhint %}

## 1. 목적

STP(Spanning Tree Protocol, IEEE 802.1D)는 스위치 사이에 이중 연결이 있을 때 루프(순환 경로)를 막는 프로토콜이다. 활성 경로 하나만 남기고 나머지 포트를 차단(Blocking)해 브로드캐스트 폭풍과 MAC 테이블 불안정을 막는다. 차단한 포트는 활성 경로가 끊기면 다시 살아나 백업 구실을 한다.

Cisco 스위치의 기본 동작은 VLAN마다 별도의 스패닝 트리를 만드는 PVST+이다. 그래서 VLAN마다 사용할 경로를 다르게 정할 수 있다.

## 2. 구성 요소

### 2.1 선출 대상과 규칙

| 번호 | 선출 대상 | 개수 | 기준(앞 기준이 같으면 다음 기준) |
|---|---|---|---|
| 1 | Root Switch(Root Bridge) | 네트워크(VLAN)당 1대 | 1) 가장 낮은 Priority 2) Priority가 같으면 가장 낮은 MAC 주소 |
| 2 | Root Port | Non-Root Switch마다 1개 | 1) Root Switch까지 비용(Cost)이 가장 낮은 포트 2) 같으면 이웃 스위치의 BID가 낮은 쪽 3) 같으면 Port ID가 낮은 포트 |
| 3 | Designated Port(DP) | 세그먼트(링크)마다 1개 | 1) Root Switch까지 비용이 가장 낮은 쪽 2) 같으면 BID가 낮은 쪽 3) 같으면 Port ID가 낮은 쪽 |
| 4 | Non-designated Port | 나머지 포트 | 차단(BLK) 상태가 되어 데이터를 주고받지 못한다 |

* BID(Bridge ID)는 Priority와 MAC 주소를 합친 값이다. 값이 낮을수록 우선한다.
* Root Switch의 모든 포트는 DP이며 Forward(전송) 상태다.

### 2.2 Priority 값

| 번호 | 항목 | 내용 |
|---|---|---|
| 1 | 기본값 | 32768 |
| 2 | 설정 단위 | 0을 포함해 4096의 배수만 설정할 수 있다 |
| 3 | 적용 범위 | VLAN마다 따로 설정할 수 있다 |

### 2.3 포트 상태 (802.1D)

| 번호 | 상태 | 데이터 전달 | MAC 학습 | 머무는 시간 |
|---|---|---|---|---|
| 1 | Blocking | 안 함 | 안 함 | 최대 20초(Max Age) |
| 2 | Listening | 안 함 | 안 함 | 15초(Forward Delay) |
| 3 | Learning | 안 함 | 함 | 15초(Forward Delay) |
| 4 | Forwarding | 함 | 함 | 계속 |
| 5 | Disabled | 안 함 | 안 함 | 관리자가 포트를 끈 상태 |

### 2.4 타이머

| 번호 | 타이머 | 기본값 | 뜻 |
|---|---|---|---|
| 1 | Hello | 2초 | Root Switch가 BPDU를 보내는 간격 |
| 2 | Max Age | 20초 | BPDU를 못 받았을 때 기다리는 시간 |
| 3 | Forward Delay | 15초 | Listening, Learning 각 단계의 시간 |

## 3. 동작 원리

1. 스위치가 BPDU(Bridge Protocol Data Unit)를 주고받는다.
2. Priority가 가장 낮은(같으면 MAC이 가장 낮은) 스위치가 Root Switch가 된다.
3. Non-Root Switch마다 Root Switch로 가는 비용이 가장 낮은 포트가 Root Port가 된다.
4. 링크마다 DP를 하나 고른다.
5. Root Port도 DP도 아닌 포트는 Blocking이 된다.
6. 활성 링크가 끊겨 BPDU가 오지 않으면 Max Age 20초 후 Blocking 포트가 Listening 15초, Learning 15초를 거쳐 Forwarding이 된다.

{% hint style="info" %}
NOTE: 원본은 "연결이 동기화되는 데 총 55초(20 + 15 + 20)"라고 적었다. 802.1D의 최대 수렴 시간은 20(Max Age) + 15(Listening) + 15(Learning) = 50초다. 타이머는 스위치 종류와 설정에 따라 다를 수 있다. 원본의 "2초에 한 번"은 Hello 타이머(2초)로 정정해 배치했다. 확인 필요.
{% endhint %}

{% hint style="info" %}
NOTE: 원본은 STP를 "연결을 비활성화하는 기능"이라 적었다. 포트를 끄는 것이 아니라 Blocking 상태로 두어 BPDU만 받고 데이터는 막는다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| STP | Spanning Tree Protocol (IEEE 802.1D) |
| BPDU | Bridge Protocol Data Unit. 스위치가 주고받는 STP 제어 프레임 |
| BID | Bridge ID. Priority와 MAC 주소로 구성 |
| Root Port / DP | 루트로 가는 포트 / 링크의 대표 포트 |
| BLK | Blocking. 차단 상태 |
| PVST+ | Per-VLAN Spanning Tree Plus. VLAN마다 트리를 만드는 Cisco 방식 |

## 5. 참조

| 참조 | 설명 |
|---|---|
| [라우팅·스위칭 확인 명령 요약 (NET-RSW-014-REF)](routing-show-commands.md) | `show spanning-tree`, Priority 설정 명령 |
| [가상 랜 (VLAN)](vlan.md) | VLAN별 STP |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 스위치 두 대를 케이블 두 가닥으로 이으면 STP 없이 어떤 문제가 생기는지 설명한다.
- [ ] 내가 Root Switch를 직접 정해야 한다면 어느 스위치를 고르고, 이유는 무엇인가?
- [ ] 포트가 Blocking에서 Forwarding으로 바뀌는 동안 사용자가 겪는 일을 쓴다.
