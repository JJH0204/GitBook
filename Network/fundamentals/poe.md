# [생성형 AI] PoE — 이더넷으로 전원 공급

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-FND-013-DO |
| 유형 | D&O (개념) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | PoE의 구성과 표준별 전력 한도를 설명한다 |
| 확인 상태 | 미검증 (일반 네트워크 지식이며 실행·출처 재확인을 하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 기존 쪽이 다루지 않은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 목적

PoE(Power over Ethernet)는 데이터 케이블(UTP)로 전원을 함께 보내는 기술이다. IP 카메라, 무선 AP, IP 전화처럼 전원 콘센트가 없는 곳에 설치할 때 쓴다.

## 2. 구성 요소

| 요소 | 설명 |
|---|---|
| PSE | Power Sourcing Equipment. 전원을 공급하는 쪽. PoE 스위치, PoE 인젝터 |
| PD | Powered Device. 전원을 받는 쪽. AP, 카메라, 전화기 |
| 케이블 | UTP. 거리 한도는 일반 이더넷과 같은 100 m |

## 3. 동작 원리

1. PSE가 포트에 처음에는 낮은 전압을 걸어 상대가 PD인지 검출한다.
2. PD이면 전력 등급(class)을 확인한다.
3. 확인되면 정식 전압을 공급한다. PD가 아니면 전원을 보내지 않으므로 일반 PC를 연결해도 안전하다.

### 3.1 표준

| 표준 | 별칭 | PSE 포트 최대 전력 |
|---|---|---|
| IEEE 802.3af | PoE | 15.4 W (PD 수신 약 12.95 W) |
| IEEE 802.3at | PoE+ | 30 W (PD 수신 약 25.5 W) |
| IEEE 802.3bt | PoE++ | 60 W(Type 3), 90~100 W(Type 4) |

### 3.2 설계 시 확인할 것

- 스위치 전체 PoE 전력 예산(budget)이 연결 장치 소비 전력의 합 이상이어야 한다.
- 케이블은 UTP 등급이 맞아야 하며 품질이 나쁜 케이블은 전압 강하가 크다.

{% hint style="warning" %}
CAUTION: 표준을 따르지 않는 비표준 패시브 PoE 장비를 표준 PoE 포트에 연결하면 장비가 손상될 수 있다. 장비 사양서의 전압·방식을 확인한다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| PSE / PD | 전원 공급 장치 / 전원 수신 장치 |
| 인젝터 | PoE 미지원 스위치 옆에 두고 전원을 얹어 주는 장치 |
| 전력 예산 | 스위치가 PoE로 낼 수 있는 총 전력 |

## 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [utp_cabling.md](utp_cabling.md) | NET-FND-007-DO | UTP 케이블 배선 (UTP Cabling) |
| [wireless-lan.md](wireless-lan.md) | NET-FND-012-DO | 무선 LAN (Wi-Fi) 기초 |
| [network-devices.md](network-devices.md) | NET-FND-011-DO | 네트워크 장비 — 허브·스위치·라우터 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 천장에 AP를 설치할 때 PoE가 편한 이유를 적어 본다.
- [ ] PoE 스위치를 고를 때 어떤 수치를 비교할지 적어 본다.
