# 네트워크 프로토콜 (Network Protocol)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-PRT-001-DO |
| 유형 | D&O (개념) |
| 목적 | 네트워크 프로토콜이 무엇인지 설명하고, 이 그룹의 프로토콜 문서로 안내한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 네트워크 지식을 정리한 것이며 출처를 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

네트워크 프로토콜(network protocol)은 컴퓨터나 장치가 데이터를 교환할 때 따르는 통신 규약이다. 데이터 형식, 주소 지정 방법, 오류 검출과 정정 방법 등을 정의해 데이터가 네트워크를 통해 전송되게 한다. 대표적인 프로토콜은 HTTP, FTP, TCP, IP다.

## 2. 구성 요소

### 2.1 프로토콜 목록

| 프로토콜 | 계층 (TCP/IP 4계층) | 한 줄 설명 | 상세 문서 |
|---|---|---|---|
| HTTP | 응용 | 웹 요청과 응답을 주고받는다 | [http.md](http.md) (NET-PRT-007-DO) |
| HTTPS | 응용 | TLS로 암호화한 HTTP다 | [https.md](https.md) (NET-PRT-008-DO) |
| DNS | 응용 | 도메인 이름을 IP 주소로 바꾼다 | [dns.md](dns.md) (NET-PRT-009-DO) |
| DHCP | 응용 | IP 주소 등 네트워크 설정을 자동으로 할당한다 | [dhcp.md](../ip-addressing-and-nat/dhcp.md) |
| SSH | 응용 | 원격 접속을 암호화한다 | [ssh.md](../security/ssh.md) |
| TLS | 전송 계층 위 | 통신 내용을 암호화한다 | [ssl.md](../security/ssl.md) |
| TCP | 전송 | 연결형 전송 프로토콜이다 | [tcp.md](tcp.md) (NET-PRT-004-DO) |
| UDP | 전송 | 비연결형 전송 프로토콜이다 | [udp.md](udp.md) (NET-PRT-005-DO) |
| IP | 인터넷 | 주소를 지정하고 패킷을 라우팅한다 | [ip.md](../ip-addressing-and-nat/ip.md) (NET-IPN-001-DO) |
| ICMP | 인터넷 | 오류와 제어 메시지를 전달한다(`ping`은 echo 요청 8, echo 응답 0을 쓴다) | 상세 문서 없음 |
| ARP | 인터넷(2계층과 3계층 사이) | IP 주소를 MAC 주소로 바꾼다 | 상세 문서 없음 |
| HDLC | 데이터 링크 | WAN 점대점 연결에서 프레임을 전송한다 | [hdlc.md](hdlc.md) (NET-PRT-006-DO) |

{% hint style="info" %}
NOTE: 원본의 ARP 항목은 보안 스캔 결과 문서(외부 링크)를 가리키고 있어 링크를 뺐다. IP와 ICMP 항목은 링크가 없었다. TLS의 계층은 문헌마다 다르게 분류하므로 "전송 계층 위"로 적었다. 확인 필요.
{% endhint %}

### 2.2 관련 문서

| 문서 | Task ID | 제목 |
|---|---|---|
| [relationshipbetweennetworkandprotocol.md](../fundamentals/relationshipbetweennetworkandprotocol.md) | NET-FND-004-DO | 네트워크와 프로토콜의 관계 |
| [transport-layer.md](transport-layer.md) | NET-PRT-003-DO | 전송 계층 개요 |
| [datagram.md](datagram.md) | NET-PRT-002-DO | 데이터그램 |

## 3. 동작 원리

프로토콜은 송신 측과 수신 측이 같은 규칙으로 메시지를 만들고 해석하게 한다.

1. 송신 측은 데이터에 프로토콜이 정한 헤더를 붙인다.
2. 네트워크가 메시지를 전달한다.
3. 수신 측은 같은 프로토콜의 규칙으로 헤더를 읽고 데이터를 꺼낸다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| HTTP | Hypertext Transfer Protocol |
| FTP | File Transfer Protocol |
| TCP | Transmission Control Protocol |
| UDP | User Datagram Protocol |
| IP | Internet Protocol |
| ICMP | Internet Control Message Protocol |
| ARP | Address Resolution Protocol |
| TLS | Transport Layer Security |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 프로토콜이 없다면 두 컴퓨터의 통신에 어떤 문제가 생길까? 내 말로 적어 본다.
- [ ] 위 표에서 내가 직접 써 본 프로토콜을 하나 골라, 언제 썼는지 적어 본다.
