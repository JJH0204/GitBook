# [생성형 AI] BGP 개요

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-RSW-017-DO |
| 유형 | D&O (개념) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | BGP가 자치 시스템 사이 경로를 교환하는 방식을 개요 수준으로 설명한다 |
| 확인 상태 | 미검증 (일반 네트워크 지식이며 실행·출처 재확인을 하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 기존 쪽이 다루지 않은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 목적

인터넷은 수많은 독립 네트워크(자치 시스템)가 연결된 구조다. BGP(Border Gateway Protocol)는 이 자치 시스템 사이에서 도달 가능한 네트워크 정보를 교환하는 경로 벡터 방식 프로토콜이다. 현재 버전은 BGP-4이다.

## 2. 구성 요소

| 요소 | 설명 |
|---|---|
| AS | Autonomous System. 하나의 관리 주체가 운영하는 네트워크 묶음. AS 번호(ASN)로 식별한다 |
| 피어(neighbor) | BGP 정보를 주고받는 라우터. TCP 179 포트로 연결한다 |
| eBGP | 서로 다른 AS 사이의 BGP |
| iBGP | 같은 AS 안의 BGP |
| AS_PATH | 경로가 지나온 AS 번호 목록 |

| 비교 | OSPF·RIP·EIGRP(IGP) | BGP(EGP) |
|---|---|---|
| 범위 | 한 AS 내부 | AS 사이 |
| 경로 선택 기준 | 비용·거리 등 지표 | 정책과 속성(AS_PATH 길이 등) |
| 규모 | 조직 단위 | 인터넷 전체 경로표 |

## 3. 동작 원리

1. 두 라우터가 TCP 179로 연결하고 OPEN 메시지로 AS 번호 등을 교환한다.
2. UPDATE 메시지로 경로(네트워크 접두사와 속성)를 알리거나 철회한다.
3. KEEPALIVE 메시지로 연결을 유지한다. 오류가 있으면 NOTIFICATION으로 연결을 끊는다.
4. 같은 목적지에 경로가 여럿이면 속성(예: 로컬 선호도, AS_PATH 길이)을 정해진 순서로 비교해 하나를 고른다.
5. 선택한 경로를 정책에 따라 다른 피어에 다시 알린다.

{% hint style="warning" %}
CAUTION: BGP는 잘못 알린 경로를 그대로 퍼뜨릴 수 있다. 접두사 필터를 걸지 않으면 설정 실수가 외부 장애로 번질 수 있다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| IGP / EGP | 자치 시스템 내부 / 사이 라우팅 프로토콜 |
| ASN | AS 번호 |
| 접두사(prefix) | 네트워크 주소와 길이 (예: 192.0.2.0/24) |

## 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [dynamic-routing-protocol.md](dynamic-routing-protocol.md) | NET-RSW-001-DO | 동적 라우팅 프로토콜 개요 |
| [ospf.md](ospf.md) | NET-RSW-005-DO | OSPF 라우팅 프로토콜 |
| [../ip-addressing-and-nat/cidr.md](../ip-addressing-and-nat/cidr.md) | NET-IPN-004-DO | 사이더 표기법 (CIDR) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] OSPF와 BGP가 각각 어디에서 쓰이는지 내 말로 구분해 본다.
- [ ] 경로 선택에 지표 대신 정책을 쓰는 이유를 적어 본다.
