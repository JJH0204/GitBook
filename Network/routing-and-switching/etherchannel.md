# [생성형 AI] EtherChannel — 링크 묶기

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-RSW-015-DO |
| 유형 | D&O (개념) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | 물리 링크 여러 개를 논리 링크 하나로 묶는 EtherChannel의 목적과 협상 방식을 설명한다 |
| 확인 상태 | 미검증 (일반 지식이며 Cisco IOS 명령은 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 기존 쪽이 다루지 않은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 목적

스위치 사이에 링크를 여러 개 연결하면 [STP](stp.md)가 하나만 남기고 나머지를 차단한다. EtherChannel은 이 링크들을 하나의 논리 링크(Port-channel)로 묶어, 대역폭을 합치고 한 링크가 끊겨도 통신을 유지한다. 이때 STP는 묶음을 링크 하나로 본다.

## 2. 구성 요소

| 협상 방식 | 표준 | 모드 | 설명 |
|---|---|---|---|
| LACP | IEEE 802.3ad (현 802.1AX) | active, passive | 표준 프로토콜. 서로 다른 제조사 장비와 쓴다 |
| PAgP | Cisco 전용 | desirable, auto | Cisco 장비끼리 쓴다 |
| 고정(on) | - | on | 협상 없이 묶는다. 양쪽을 모두 on으로 맞춰야 한다 |

| 조합 | 묶음 형성 |
|---|---|
| active - active, active - passive | 형성 |
| passive - passive | 형성되지 않음 |
| desirable - desirable, desirable - auto | 형성 |
| auto - auto | 형성되지 않음 |
| on - on | 형성 |
| on - 협상 모드 | 형성되지 않음 |

## 3. 동작 원리

1. 묶을 포트의 속도, 듀플렉스, VLAN, 트렁크 설정이 서로 같아야 한다.
2. 양쪽 스위치가 LACP 또는 PAgP로 협상해 Port-channel 인터페이스를 만든다.
3. 스위치가 프레임의 MAC 주소나 IP 주소 등을 해시해 묶음 안의 어느 링크로 보낼지 정한다.
4. 같은 흐름은 항상 같은 링크로 간다. 그래서 단일 흐름의 속도는 링크 하나의 속도를 넘지 못한다.
5. 링크 하나가 끊기면 남은 링크로 흐름이 다시 분배된다.

### 3.1 설정 형태 예시 (개념 설명용)

```
interface range GigabitEthernet0/1 - 2
 channel-group 1 mode active
```

{% hint style="warning" %}
CAUTION: 양쪽 설정이 맞지 않은 채 링크를 연결하면 스위칭 루프나 포트 차단이 생길 수 있다. 포트를 먼저 설정한 뒤 케이블을 연결한다.
{% endhint %}

## 4. 확인 명령 (Cisco IOS)

| 명령 | 용도 |
|---|---|
| `show etherchannel summary` | 묶음과 포트 상태 요약 |
| `show spanning-tree` | STP가 Port-channel을 링크 하나로 보는지 확인 |

## 5. 약어·용어

| 용어 | 뜻 |
|---|---|
| LACP | Link Aggregation Control Protocol |
| PAgP | Port Aggregation Protocol |
| Port-channel | 묶음이 만드는 논리 인터페이스 |

## 6. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [stp.md](stp.md) | NET-RSW-007-DO | 스패닝 트리 프로토콜 (STP) |
| [vlan.md](vlan.md) | NET-RSW-008-DO | 가상 랜 (VLAN) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 링크 두 개를 묶어도 파일 하나를 전송하는 속도가 두 배가 되지 않는 이유를 내 말로 설명해 본다.
- [ ] EtherChannel 없이 링크 두 개를 연결하면 어떤 일이 생기는지 적어 본다.
