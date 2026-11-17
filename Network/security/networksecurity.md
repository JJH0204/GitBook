# 네트워크 보안 로드맵

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-NSC-001-DO |
| 유형 | D&O (개념, 학습 로드맵) |
| 목적 | 네트워크 보안을 학습하는 순서와 각 단계에서 읽을 문서를 안내한다 |
| 확인 상태 | 미검증 (원본 목차를 정리한 것이며 출처를 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

네트워크 보안은 네트워크 구조를 이해한 뒤 접근 통제, 암호화 통신, 탐지·분석 순서로 학습한다. 이 문서는 그 순서와 대응 문서를 정리한다. 원본의 학습 목표는 두 가지다.

- 네트워크에 대한 이해
- 네트워크 관리사 자격증 취득

## 2. 구성 요소

### 2.1 학습 단계

| 단계 | 주제 | 다룰 내용 | 문서 |
|---|---|---|---|
| 1 | 네트워크 기초 | 네트워크 개념, 용어, 계층 모델 | [네트워크 기초](../fundamentals/network.md) (NET-FND-001-DO), [OSI 7계층 모델](../fundamentals/osi7layer.md) (NET-FND-005-DO) |
| 2 | 네트워크 | 토폴로지, IP 주소 | [네트워크 토폴로지](../fundamentals/topology.md) (NET-FND-007-DO), [IP 주소](../ip-addressing-and-nat/ip.md) (NET-IPN-001-DO) |
| 3 | LAN과 WAN | 근거리망과 광역망의 구분 | [LAN과 WAN](../fundamentals/basics/lanandwan.md) |
| 4 | 서버 | 서버 유형과 용도 | [서버 분류 및 유형](../servers-and-storage/server.md) (NET-NSV-001-DO) |
| 5 | ACL | 접근 제어 목록 | [ACL](../../Linux/guide/operations/linux_admin/security/acl.md) (LNX-LAS-001-DO) |
| 6 | VPN | 암호화 터널 | [가상 사설망 (VPN)](vpn.md) (NET-NSC-002-DO) |
| 7 | 방화벽 | 트래픽 필터링 | [방화벽 장치 유형 (Firewall)](firewall.md) (NET-NSC-005-DO) |
| 8 | DDoS | 서비스 거부 공격과 방어 | [DDoS](../../Security/security/offensive-security/system/ddos.md) |
| 9 | Wireshark | 패킷 분석 | [Wireshark](../../Security/security/defensive-security/defense/wireshark.md) |
| 10 | NMS | 네트워크 관리 시스템 | 원본에 연결된 문서가 없다 |
| 11 | IDS | 침입 탐지 시스템 | [IDS](../../Security/security/defensive-security/defense/ids.md) |
| 12 | Suricata | 오픈소스 IDS/IPS 엔진 | [Suricata](../../Security/security/defensive-security/defense/suricata.md) |

### 2.2 보안 솔루션 분류

원본의 "보안 솔루션" 절은 내용이 비어 있었다. 이 문서에 연결된 솔루션은 다음과 같다.

| 구분 | 솔루션 | 역할 |
|---|---|---|
| 접근 통제 | ACL, 방화벽 | 출발지·목적지·포트 기준으로 트래픽을 허용하거나 차단한다 |
| 암호화 통신 | VPN, TLS, SSH | 구간 또는 세션을 암호화해 도청과 변조를 막는다 |
| 탐지 | IDS, 패킷 분석 | 비정상 트래픽을 찾는다 |

## 3. 동작 원리

보안 계층은 겹쳐서 쓴다(심층 방어). 한 계층이 뚫려도 다음 계층이 막도록 구성한다.

1. 경계에서 방화벽과 ACL이 허용된 트래픽만 통과시킨다.
2. 원격 접속과 지점 간 연결은 VPN, SSH, TLS로 암호화한다.
3. IDS와 패킷 분석이 통과한 트래픽에서 이상 징후를 찾는다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| ACL | Access Control List. 접근 제어 목록 |
| VPN | Virtual Private Network. 가상 사설망 |
| IDS | Intrusion Detection System. 침입 탐지 시스템 |
| DDoS | Distributed Denial of Service. 분산 서비스 거부 공격 |
| NMS | Network Management System. 네트워크 관리 시스템 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [ssl.md](ssl.md) | NET-NSC-003-DO | SSL 및 TLS 프로토콜 |
| [ssh.md](ssh.md) | NET-NSC-004-DO | 시큐어 셸 (SSH) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 방화벽이 있는데도 IDS가 따로 필요한 이유를 내 말로 설명해 본다.
- [ ] 내가 쓰는 네트워크(집, 학교, 회사)에서 보안 장치가 어디에 있는지 그려 본다.
- [ ] 이 로드맵에서 가장 어렵게 느껴지는 단계와 그 이유를 적는다.
