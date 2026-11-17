# 가상 사설망 (VPN)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-NSC-002-DO |
| 유형 | D&O (개념) |
| 목적 | VPN의 목적, 연결 방식(Site-to-Site, Remote Access), 터널링 프로토콜의 특징을 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 네트워크 교재 지식을 정리한 것이며 출처를 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 탭 구조(site-to-site, Remote Access VPN)는 절로 풀어 썼다. 프로토콜 설명(IPSec, SSL VPN, 터널링 프로토콜)은 원본에 없던 내용을 보충한 것이다.
{% endhint %}

## 1. 목적

VPN(Virtual Private Network)은 신뢰할 수 없는 공용망(인터넷) 위에 암호화된 가상의 전용 통신로(터널)를 만드는 기술이다. 비인가 네트워크를 지나는 통신은 도청(스니핑)과 변조의 대상이 될 수 있다. 기업과 개인은 이를 막기 위해 VPN을 쓴다.

VPN은 연결 방식에 따라 Site-to-Site VPN과 Remote Access VPN으로 나눈다.

## 2. 구성 요소

### 2.1 연결 방식 비교

| 구분 | Site-to-Site VPN | Remote Access VPN |
|---|---|---|
| 연결 대상 | 네트워크와 네트워크(본사와 지사) | 개별 사용자와 네트워크 |
| 터널 종단 | 양쪽 지점의 VPN 장비(라우터, 방화벽) | 사용자 단말의 클라이언트와 VPN 서버 |
| 사용자 인식 | 사용자는 VPN을 의식하지 않는다 | 사용자가 접속 프로그램으로 연결한다 |
| 주요 프로토콜 | IPSec, GRE(IPSec과 조합) | IPSec, SSL/TLS 기반 VPN, OpenVPN, WireGuard |
| 관련 문서 | 아래 2.2절 GRE | [Open VPN](../../Linux/guide/network-remote/open-vpn.md) (LNX-NRM-005-MP) |

### 2.2 터널링 프로토콜

| 프로토콜 | 계층 | 암호화 | 특징 | 비고 |
|---|---|---|---|---|
| IPSec | 3 | 있음 | 인증과 암호화를 제공하는 프로토콜 모음. Site-to-Site에 널리 쓴다 | 상세는 2.3절 |
| GRE | 3 | 없음 | 다른 패킷을 IP 패킷 안에 감싸는 터널링 프로토콜. 멀티캐스트·라우팅 프로토콜 전달이 가능하다 | 암호화가 없어 보통 IPSec과 함께 쓴다 |
| L2TP | 2 | 없음 | PPP 프레임을 터널링한다 | 보통 L2TP/IPSec으로 조합해 암호화한다 |
| PPTP | 2 | 약함 | 오래된 Remote Access VPN 방식 | 구식이며 취약점이 알려져 있어 쓰지 않는다 |
| SSL/TLS VPN | 4~7 | 있음 | TLS로 터널을 만든다. 브라우저 또는 전용 클라이언트를 쓴다 | 방화벽 통과가 쉽다(443/tcp) |

{% hint style="warning" %}
CAUTION: PPTP는 인증 방식(MS-CHAPv2)과 암호화에 알려진 취약점이 있다. 새로 구축하는 VPN에는 쓰지 않는다.
{% endhint %}

### 2.3 IPSec 구성 요소

| 구성 요소 | 역할 |
|---|---|
| IKE (Internet Key Exchange) | 보안 연결(SA)을 협상하고 키를 교환한다. UDP 500을 쓰고, NAT 통과 시 UDP 4500을 쓴다 |
| IKE Phase 1 | 두 장비가 서로를 인증하고 IKE SA(관리용 보안 연결)를 만든다. 인증은 사전 공유 키 또는 인증서로 한다 |
| IKE Phase 2 | 실제 데이터를 보호할 IPSec SA를 협상한다 |
| ESP (Encapsulating Security Payload) | 데이터를 암호화하고 무결성을 확인한다. IP 프로토콜 번호 50이다 |
| AH (Authentication Header) | 무결성과 출처 인증만 제공하고 암호화는 하지 않는다. IP 프로토콜 번호 51이다. NAT를 통과하지 못해 ESP를 주로 쓴다 |
| 전송 모드 | 원본 IP 헤더를 유지하고 페이로드만 보호한다. 종단 간 통신에 쓴다 |
| 터널 모드 | 원본 IP 패킷 전체를 보호하고 새 IP 헤더를 붙인다. Site-to-Site에 쓴다 |

{% hint style="info" %}
NOTE: IKE 버전은 IKEv1(Phase 1, Phase 2 구조)과 IKEv2(IKE_SA_INIT, IKE_AUTH 교환 구조)가 있다. Phase 1/2 용어는 IKEv1 기준이다.
{% endhint %}

## 3. 동작 원리

### 3.1 Site-to-Site VPN

1. 본사 장비와 지사 장비가 IKE Phase 1에서 서로를 인증한다(사전 공유 키 `<사전 공유 키>` 또는 인증서).
2. 두 장비가 IKE Phase 2에서 보호할 트래픽 범위(`<본사 대역>`과 `<지사 대역>`)와 암호 방식을 협상한다.
3. 지사 PC가 본사 대역으로 보낸 패킷을 지사 장비가 ESP로 암호화해 터널 모드로 감싼다.
4. 인터넷은 암호화된 패킷만 전달한다.
5. 본사 장비가 패킷을 복호화해 본사 내부망으로 전달한다.

### 3.2 Remote Access VPN

1. 사용자 단말의 VPN 클라이언트가 VPN 서버(`<VPN 서버 IP 주소>`)에 접속한다.
2. 서버가 사용자를 인증한다(계정, 인증서, 다중 인증).
3. 서버가 단말에 가상 IP 주소를 할당하고 터널을 연다.
4. 단말이 보내는 내부망 대상 트래픽이 터널을 통해 암호화되어 전달된다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| VPN | Virtual Private Network. 가상 사설망 |
| SA | Security Association. 보안 연결 |
| IKE | Internet Key Exchange. 키 교환 프로토콜 |
| ESP | Encapsulating Security Payload |
| AH | Authentication Header |
| GRE | Generic Routing Encapsulation. 일반 라우팅 캡슐화 |
| L2TP | Layer 2 Tunneling Protocol |
| PPTP | Point-to-Point Tunneling Protocol |
| 스니핑 | 네트워크 패킷을 가로채 내용을 읽는 행위 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [open-vpn.md](../../Linux/guide/network-remote/open-vpn.md) | LNX-NRM-005-MP | OpenVPN 설정 |
| [ssl.md](ssl.md) | NET-NSC-003-DO | SSL 및 TLS 프로토콜 |
| [firewall.md](firewall.md) | NET-NSC-005-DO | 방화벽 장치 유형 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 카페 공용 Wi-Fi에서 VPN을 쓰면 무엇이 보호되고 무엇은 보호되지 않는지 내 말로 적는다.
- [ ] 본사와 지사를 연결할 때와 재택 직원을 연결할 때 어떤 VPN을 고를지, 이유와 함께 적는다.
- [ ] VPN을 직접 써 본 경험이 있다면 어떤 상황이었는지 적는다.
