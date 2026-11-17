# EIGRP 라우팅 프로토콜

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-RSW-004-DO |
| 유형 | D&O (개념) |
| 목적 | EIGRP의 특징, 3가지 테이블, 경로 선택 방식, AS 번호의 의미를 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 출처를 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 개념만 다룬다. 설정 절차는 [eigrp-config.md](eigrp-config.md)(NET-RSW-012-MP)로 옮겼다. 원본의 일부 서술은 정정했다. 정정한 곳은 "비고"에 표시했다.
{% endhint %}

## 1. 목적

EIGRP(Enhanced Interior Gateway Routing Protocol)는 Cisco가 IGRP를 개선해 만든 라우팅 프로토콜이다. 네트워크 구성이 바뀐 뒤 라우팅이 불안정해지는 시간을 줄이도록 설계됐다. 경로 비용을 대역폭과 지연 같은 값으로 계산해 RIP보다 유연하다. 원본은 홉 수 제한이 커서 대학, 병원 같은 큰 네트워크에 쓴다고 적었다.

## 2. 구성 요소

### 2.1 특징

| 번호 | 항목 | 내용 | 비고 |
|---|---|---|---|
| 1 | 개발 | Cisco가 IGRP를 바탕으로 개발했다 | 원본은 "개방형"으로 적었다. 2016년 RFC 7868(Informational)로 공개됐으나 원래는 Cisco 독자 프로토콜이다. 확인 필요 |
| 2 | 분류 | IGP. 고급 거리 벡터 방식이다 | |
| 3 | 메트릭 | 기본값은 대역폭(Bandwidth)과 지연(Delay)을 쓴다. MTU와 부하·신뢰도는 기본 계산에 쓰지 않는다 | 원본은 `show interface`에서 MTU, BW, DLY를 확인한다고 적었다. MTU는 값만 전달된다 |
| 4 | 최대 홉 수 | 기본 100, 최대 255로 설정할 수 있다 | RIP의 15보다 훨씬 크다. 확인 필요 |
| 5 | AD | 내부 경로 90, 외부(재분배된) 경로 170 | |
| 6 | 알고리즘 | DUAL(Diffusing Update Algorithm) | |
| 7 | 통신 | 멀티캐스트 `224.0.0.10`, IP 프로토콜 번호 88 | |

### 2.2 EIGRP가 유지하는 테이블

| 번호 | 테이블 | 내용 | 확인 명령 |
|---|---|---|---|
| 1 | 이웃 테이블 | 직접 연결된 EIGRP 이웃 라우터 목록 | `show ip eigrp neighbors` |
| 2 | 토폴로지 테이블 | 이웃이 알려 준 모든 경로와 거리 값 | `show ip eigrp topology` |
| 3 | 라우팅 테이블 | 토폴로지 테이블에서 고른 최적 경로 | `show ip route` |

### 2.3 경로 선택 용어

| 번호 | 용어 | 뜻 |
|---|---|---|
| 1 | FD (Feasible Distance) | 이 라우터에서 목적지까지의 전체 메트릭이다. 값이 가장 작은 경로가 최적 경로(Successor)가 된다 |
| 2 | RD/AD (Reported Distance) | 이웃 라우터가 알려 준, 이웃에서 목적지까지의 메트릭이다 |
| 3 | Successor | 라우팅 테이블에 올라가는 최적 경로의 다음 홉이다 |
| 4 | Feasible Successor | 백업 경로다. 그 RD가 현재 Successor의 FD보다 작아야 한다 |

### 2.4 AS 번호(ASN)

| 번호 | 항목 | 내용 |
|---|---|---|
| 1 | 역할 | EIGRP 프로세스를 구분하는 번호다. 이웃끼리 ASN이 같아야 경로를 교환한다 |
| 2 | ASN이 다른 경우 | 같은 라우터가 두 프로세스를 돌려도 재분배(Redistribution)를 설정해야 서로의 경로를 받는다 |
| 3 | 재분배 방식 | Multi: 양쪽 프로세스에 모두 재분배한다. Single: 한쪽 프로세스에만 재분배한다 |

### 2.5 라우팅 테이블의 EIGRP 코드

| 번호 | 코드 | 뜻 |
|---|---|---|
| 1 | `D` | EIGRP로 학습한 내부 경로 |
| 2 | `D EX` | 다른 AS에서 재분배돼 온 외부 경로 |

## 3. 동작 원리

1. 라우터가 EIGRP를 켠 인터페이스로 Hello 패킷을 보낸다.
2. ASN이 같은 이웃이 응답하면 이웃 테이블에 올린다.
3. 이웃끼리 경로 정보를 교환해 토폴로지 테이블을 만든다.
4. 라우터가 DUAL로 FD가 가장 작은 경로를 Successor로 고른다.
5. Successor가 라우팅 테이블(`D`)에 올라간다.
6. Successor 경로가 끊기면 Feasible Successor로 즉시 바꾼다. 없으면 이웃에 경로를 다시 묻는다.

{% hint style="info" %}
NOTE: 원본은 "이웃 정보가 없으면 네트워크 광고 데이터를 받지 못해 라우팅 테이블을 갱신할 수 없다"고 적었다. 이웃이 맺어지지 않는 대표 원인은 ASN 불일치, `network` 명령 누락, 인터페이스 `shutdown`이다.
{% endhint %}

{% hint style="info" %}
NOTE: 원본은 "같은 프로토콜이면 네트워크를 중복 광고해도 문제없고, 다르면 한쪽에서만 해야 하며 중복 광고 시 오류가 난다"고 적었다. 정확한 조건과 오류 내용을 알 수 없어 확인 필요로 둔다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| EIGRP | Enhanced Interior Gateway Routing Protocol |
| IGRP | Interior Gateway Routing Protocol. EIGRP의 전신 |
| ASN | Autonomous System Number. EIGRP 프로세스 번호 |
| DUAL | Diffusing Update Algorithm. 루프 없는 경로를 계산하는 알고리즘 |
| FD | Feasible Distance |
| 와일드카드 마스크 | 서브넷 마스크의 비트를 뒤집은 값. `255.255.255.0`의 와일드카드는 `0.0.0.255` |
| Redistribution | 서로 다른 라우팅 프로세스·프로토콜 사이에서 경로를 넘겨 주는 기능 |

## 5. 참조

| 참조 | 설명 |
|---|---|
| [EIGRP 설정 (NET-RSW-012-MP)](eigrp-config.md) | 설정 절차 |
| [Redistribution](../../Linux/guide/operations/redistribution.md) | 재분배 문서 |
| [원본 참고 글(네이버 블로그)](https://m.blog.naver.com/luexr/222441096481) | 원본이 가리킨 관련 정보 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] EIGRP가 RIP보다 유연하다고 하는 이유를 메트릭 관점에서 설명한다.
- [ ] 이웃 테이블이 비어 있다면 어디부터 확인할지 순서대로 쓴다.
- [ ] ASN이 서로 다른 두 라우터가 경로를 교환하려면 무엇이 필요한지, 직접 겪은 경험이나 상상으로 적는다.
