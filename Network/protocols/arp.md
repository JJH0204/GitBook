# [생성형 AI] ARP — IP 주소를 MAC 주소로 바꾸기

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-PRT-015-DO |
| 유형 | D&O (개념) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | ARP가 같은 네트워크 안에서 IP 주소로 MAC 주소를 알아내는 과정과 ARP 테이블 확인법을 설명한다 |
| 확인 상태 | 일부 실행. `ip neigh` 출력 형식을 Linux에서 확인했다. 나머지는 일반 지식이며 출처를 다시 확인하지 않았다 |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 기존 쪽이 다루지 않은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 목적

ARP(Address Resolution Protocol)는 IPv4 주소만 알고 있을 때, 같은 LAN 안에서 상대의 MAC 주소를 알아내는 프로토콜이다. 이더넷 프레임은 MAC 주소로 전달되므로, IP 패킷을 보내기 전에 목적지(또는 게이트웨이)의 MAC 주소가 필요하다.

## 2. 구성 요소

| 구성 요소 | 역할 |
|---|---|
| ARP 요청(Request) | "이 IP 주소를 가진 장치의 MAC 주소가 무엇인가"를 묻는 브로드캐스트 프레임 |
| ARP 응답(Reply) | 해당 IP를 가진 장치가 자신의 MAC 주소를 요청자에게 알리는 유니캐스트 프레임 |
| ARP 테이블(캐시) | IP 주소와 MAC 주소 쌍을 일정 시간 저장하는 표 |
| 게이트웨이 | 목적지가 다른 네트워크이면 목적지 대신 게이트웨이의 MAC 주소를 묻는다 |

## 3. 동작 원리

1. 송신 호스트가 목적지 IP가 자기 서브넷 안인지 서브넷 마스크로 판단한다.
2. 같은 서브넷이면 목적지 IP, 다른 서브넷이면 기본 게이트웨이 IP에 대해 ARP 테이블을 찾는다.
3. 항목이 없으면 ARP 요청을 LAN 전체에 브로드캐스트한다(목적지 MAC `ff:ff:ff:ff:ff:ff`).
4. 해당 IP의 장치만 ARP 응답을 유니캐스트로 보낸다.
5. 송신 호스트가 결과를 ARP 테이블에 저장하고 원래 프레임을 보낸다.
6. 저장된 항목은 일정 시간이 지나면 삭제되며, 운영체제마다 시간이 다르다.

ARP는 라우터를 넘지 않는다. ARP 요청은 브로드캐스트이므로 브로드캐스트 도메인 안에서만 전달된다.

## 4. 확인 방법

| 환경 | 명령 | 설명 |
|---|---|---|
| Linux | `ip neigh` | 이웃(ARP) 테이블 출력. 항목 상태는 `REACHABLE`, `STALE`, `DELAY` 등 |
| Windows | `arp -a` | ARP 테이블 출력 |
| Cisco IOS | `show ip arp` | 라우터·L3 스위치의 ARP 테이블 출력 |

## 5. 보안 관점

ARP에는 응답의 진위를 확인하는 장치가 없다. 그래서 거짓 응답으로 ARP 테이블을 오염시키는 ARP 스푸핑이 가능하다. 방어는 스위치의 DAI(Dynamic ARP Inspection), 중요 장치의 정적 ARP 항목, 포트 보안으로 한다. 세부 설정은 이 쪽에서 다루지 않는다.

## 6. 약어·용어

| 용어 | 뜻 |
|---|---|
| MAC 주소 | NIC에 부여된 48비트 하드웨어 주소. [이더넷 프레임과 MAC 주소](../fundamentals/ethernet-mac.md) 참조 |
| 브로드캐스트 | 같은 네트워크의 모든 장치에 보내는 전송. [유니캐스트·브로드캐스트·멀티캐스트](../ip-addressing-and-nat/cast-types.md) 참조 |
| DAI | Dynamic ARP Inspection. ARP 패킷을 검사하는 스위치 기능 |

## 7. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [ethernet-mac.md](../fundamentals/ethernet-mac.md) | NET-FND-010-DO | 이더넷 프레임과 MAC 주소 |
| [gatewaysetup.md](../ip-addressing-and-nat/gatewaysetup.md) | NET-IPN-008-MP | 게이트웨이 설정 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 다른 네트워크의 서버로 보낼 때 ARP가 누구의 MAC 주소를 묻는지 내 말로 설명해 본다.
- [ ] 내 PC에서 ARP 테이블을 열어 보고, 항목 중 하나가 어떤 장치인지 추측해 적어 본다.
