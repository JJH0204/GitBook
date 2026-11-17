# OSPF 라우팅 프로토콜

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-RSW-005-DO |
| 유형 | D&O (개념) |
| 목적 | OSPF의 특징, Area 구조, 비용 계산, 이웃 맺기 흐름을 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 출처를 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본은 설정·확인 명령 블록이 모두 비어 있었다. 이 문서는 개념만 다루고, 명령은 [ospf-config.md](ospf-config.md)(NET-RSW-011-MP)에 새로 썼다. 원본에 없던 내용이다. 확인 필요.
{% endhint %}

## 1. 목적

OSPF(Open Shortest Path First)는 링크 상태(Link State) 방식의 IGP다. 라우터가 같은 Area 안의 모든 링크 정보를 모아 SPF(Shortest Path First, 다익스트라) 알고리즘으로 목적지까지의 최단 경로를 계산한다.

## 2. 구성 요소

### 2.1 특징

| 번호 | 항목 | 내용 |
|---|---|---|
| 1 | 표준 | 공개 표준 프로토콜이다. 제조사가 달라도 쓴다 |
| 2 | Area 구조 | 네트워크를 Area 단위로 나눠 대규모 네트워크를 안정적으로 운영한다 |
| 3 | 수렴 시간 | 다른 라우팅 프로토콜에 비해 빠르다 |
| 4 | Stub | Stub Area 같은 강력한 경로 축약 기능을 지원한다 |
| 5 | 경계 광고 | 네트워크를 광고할 때 Area 번호를 함께 쓴다 |
| 6 | 자동 요약 | 자동 요약 기능이 없어 `no auto-summary`가 필요 없다 |
| 7 | AD | 110 |
| 8 | 통신 | IP 프로토콜 번호 89. 멀티캐스트 `224.0.0.5`(모든 OSPF 라우터), `224.0.0.6`(DR/BDR) |

### 2.2 비용(Cost) 계산

| 번호 | 항목 | 내용 |
|---|---|---|
| 1 | 공식 | 비용 = 기준 대역폭 ÷ 인터페이스 대역폭 |
| 2 | 기준 대역폭 | 기본 100 Mbps. 계산 결과의 소수점은 버리고 최소값은 1이다 |
| 3 | 예 | Ethernet 10 Mbps는 10. FastEthernet 100 Mbps는 1. GigabitEthernet 1,000 Mbps도 1 |
| 4 | 경로 비용 | 경로상 나가는 인터페이스의 비용을 모두 더한다 |

{% hint style="warning" %}
CAUTION: 기본 기준 대역폭에서는 FastEthernet과 GigabitEthernet의 비용이 같아 구분되지 않는다. 기가비트 이상이 섞인 네트워크는 모든 라우터에서 `auto-cost reference-bandwidth`를 같은 값으로 맞춘다. 확인 필요.
{% endhint %}

### 2.3 Area

| 번호 | 항목 | 내용 |
|---|---|---|
| 1 | Area 0 | 백본(backbone) Area다. 다른 모든 Area는 Area 0에 연결돼야 한다 |
| 2 | Area 1 이상 | 일반 Area다. Area 0을 거쳐 서로 경로를 주고받는다 |
| 3 | ABR | Area Border Router. 두 개 이상의 Area에 걸쳐 있는 라우터 |
| 4 | Virtual Link | 물리적으로 Area 0에 연결할 수 없을 때 우회하는 기능이다. 물리 환경상 어쩔 수 없을 때만 쓴다 |

{% hint style="warning" %}
CAUTION: Area 0 없이 Area 번호를 1 이상으로만 설정하면 Area 사이 통신이 되지 않는다.
{% endhint %}

### 2.4 이웃 상태(주요)

| 번호 | 상태 | 뜻 |
|---|---|---|
| 1 | Down | 이웃에게서 Hello를 받지 못했다 |
| 2 | Init | Hello를 받았으나 상대가 나를 아직 모른다 |
| 3 | 2-Way | 서로 Hello에서 상대를 확인했다 |
| 4 | Full | 링크 상태 데이터베이스(LSDB) 동기화가 끝났다 |

멀티 액세스 구간(이더넷)에서는 DR/BDR이 선출되며, DR/BDR이 아닌 라우터끼리는 2-Way로 남는 것이 정상이다.

## 3. 동작 원리

1. OSPF를 켠 인터페이스에서 Hello 패킷을 보내 이웃을 찾는다.
2. 이웃과 Area 번호, Hello/Dead 간격 등이 일치하면 이웃 관계를 맺는다.
3. 이웃끼리 링크 상태 정보(LSA)를 교환해 같은 Area의 라우터가 같은 LSDB를 갖는다.
4. 각 라우터가 LSDB로 SPF 계산을 해 최단 경로 트리를 만든다.
5. 계산된 경로를 라우팅 테이블에 올린다(코드 `O`).
6. 링크가 바뀌면 변화분만 LSA로 퍼뜨려 다시 계산한다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| OSPF | Open Shortest Path First |
| SPF | Shortest Path First. 최단 경로 계산 알고리즘 |
| LSA / LSDB | Link State Advertisement / Link State Database |
| DR / BDR | Designated Router / Backup Designated Router |
| ABR | Area Border Router |
| Stub | 외부 경로 정보를 받지 않고 기본 경로로 대신하는 Area |

## 5. 참조

| 참조 | 설명 |
|---|---|
| [OSPF 설정 (NET-RSW-011-MP)](ospf-config.md) | 설정 절차 |
| [Redistribution](../../Linux/guide/operations/redistribution.md) | 재분배 문서 |
| [원본 참고 글(티스토리)](https://nirsa.tistory.com/32) | 원본이 가리킨 관련 자료 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] OSPF가 네트워크를 Area로 나누는 이유를 내 말로 설명한다.
- [ ] Area 0이 없으면 어떤 문제가 생기는지, 어떻게 확인할지 쓴다.
- [ ] 링크 상태 방식이 RIP보다 수렴이 빠른 이유를 한 문단으로 쓴다.
