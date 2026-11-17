# 동적 라우팅 프로토콜 개요

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-RSW-001-DO |
| 유형 | D&O (개념) |
| 목적 | 동적 라우팅의 개념과 RIP, OSPF, EIGRP, BGP의 차이를 한 표로 비교한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 출처를 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본에는 RIP, OSPF, EIGRP 링크만 있었다. 비교표와 BGP 행은 원본에 없던 내용이다. 확인 필요.
{% endhint %}

## 1. 목적

동적 라우팅은 라우터가 라우팅 프로토콜로 경로 정보를 서로 교환해 라우팅 테이블을 자동으로 만들고 갱신하는 방식이다. 경로를 관리자가 직접 고정하는 정적 라우팅과 대비된다.

다음 조건 중 하나 이상이면 동적 라우팅을 쓴다.

* 경로가 자주 바뀐다.
* 라우터 수가 많아 경로를 일일이 입력하기 어렵다.
* 장애가 나면 우회 경로로 자동 전환해야 한다.

## 2. 구성 요소

### 2.1 핵심 개념

| 번호 | 용어 | 뜻 |
|---|---|---|
| 1 | 메트릭(Metric) | 같은 목적지로 가는 경로 중 최적 경로를 고르는 기준값이다. 홉 수, 비용, 대역폭, 지연 등이다. 프로토콜마다 계산 방식이 다르다 |
| 2 | 수렴(Convergence) | 네트워크가 바뀐 뒤 모든 라우터의 라우팅 테이블이 다시 안정 상태가 되는 과정, 또는 그 소요 시간이다 |
| 3 | 관리 거리(AD, Administrative Distance) | 서로 다른 출처가 같은 목적지 경로를 알려 줄 때 어느 출처를 믿을지 정하는 값이다. 작을수록 우선한다 |
| 4 | IGP | Interior Gateway Protocol. 한 AS(자율 시스템) 안에서 쓰는 프로토콜이다. RIP, OSPF, EIGRP |
| 5 | EGP | Exterior Gateway Protocol. AS 사이에서 쓰는 프로토콜이다. BGP |

### 2.2 프로토콜 비교

| 번호 | 프로토콜 | 방식 | 메트릭 | AD(Cisco 기본값) | 특징 | 상세 문서 |
|---|---|---|---|---|---|---|
| 1 | RIP | 거리 벡터 | 홉 수 (최대 15, 16은 도달 불가) | 120 | 설정이 간단하다. 소규모용이다 | [rip.md](rip.md) |
| 2 | OSPF | 링크 상태 | 비용(Cost). 기준 대역폭 100 Mbps를 인터페이스 대역폭으로 나눈다 | 110 | 표준(공개) 프로토콜이다. Area로 나눠 대규모를 처리한다. 수렴이 빠르다 | [ospf.md](ospf.md) |
| 3 | EIGRP | 고급 거리 벡터(하이브리드라고도 부른다) | 대역폭과 지연 기반 복합 메트릭 | 내부 90, 외부 170 | Cisco에서 개발했다. DUAL 알고리즘을 쓴다 | [eigrp.md](eigrp.md) |
| 4 | BGP | 경로 벡터 | AS 경로, 속성 | eBGP 20, iBGP 200 | AS 사이 경로 교환용이다. 인터넷 백본과 ISP에서 쓴다 | 이 스페이스에 상세 문서 없음 |

참고용 비교 기준으로 직접 연결(Connected)의 AD는 0, 정적 경로(Static)는 1이다.

### 2.3 상세 문서와 설정 절차

| 번호 | 프로토콜 | 개념 문서 | 설정 절차 |
|---|---|---|---|
| 1 | RIP | [rip.md](rip.md) (NET-RSW-006-DO) | [rip-config.md](rip-config.md) (NET-RSW-010-MP) |
| 2 | OSPF | [ospf.md](ospf.md) (NET-RSW-005-DO) | [ospf-config.md](ospf-config.md) (NET-RSW-011-MP) |
| 3 | EIGRP | [eigrp.md](eigrp.md) (NET-RSW-004-DO) | [eigrp-config.md](eigrp-config.md) (NET-RSW-012-MP) |

## 3. 동작 원리

1. 라우터가 자신에게 직접 연결된 네트워크를 라우팅 테이블에 올린다.
2. 라우팅 프로토콜이 이웃 라우터와 경로 정보를 주고받는다.
3. 라우터가 같은 목적지로 가는 경로가 여럿이면 선택 규칙을 적용한다. 가장 긴 접두사(longest prefix)가 일치하는 경로를 먼저 고르고, 그다음 AD가 낮은 출처, 그다음 메트릭이 낮은 경로를 고른다.
4. 선택된 경로만 라우팅 테이블에 남는다.
5. 링크가 끊기면 이웃이 변화를 알리고 라우터가 새 경로를 계산한다(수렴).

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| AS | Autonomous System. 하나의 관리 주체가 운영하는 라우팅 영역 |
| IGP / EGP | AS 내부용 / AS 사이용 라우팅 프로토콜 |
| AD | Administrative Distance. 경로 출처의 신뢰도 값 |
| RIP | Routing Information Protocol |
| OSPF | Open Shortest Path First |
| EIGRP | Enhanced Interior Gateway Routing Protocol |
| BGP | Border Gateway Protocol |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 정적 라우팅 대신 동적 라우팅을 쓰는 상황은 언제이고, 그 대가는 무엇인가?
- [ ] 같은 목적지를 RIP와 OSPF가 모두 알려 주면 라우터는 어느 경로를 고르는가? 이유는 무엇인가?
- [ ] 거리 벡터 방식과 링크 상태 방식의 차이를 내 말로 설명한다.
