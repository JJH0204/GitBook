# 네트워크 주요 용어 정리

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-FND-003-REF |
| 유형 | REF (용어 표) |
| 목적 | 네트워크 입문에서 자주 나오는 용어를 찾아본다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 개념을 정리한 것이며 출처를 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 용어 표

| 용어 | 풀이 | 설명 | 상세 문서 |
|---|---|---|---|
| DHCP | Dynamic Host Configuration Protocol | 기기에 IP 주소 등 네트워크 설정을 자동으로 할당한다 | [dhcp.md](../ip-addressing-and-nat/dhcp.md) |
| MAC 주소 | Media Access Control address | 네트워크 카드(NIC)에 부여된 48비트(6바이트) 하드웨어 주소다. L2 스위치가 같은 네트워크 안의 기기 사이에 데이터를 전달할 때 쓴다 | 2절 |
| ARP | Address Resolution Protocol | IP 주소로 MAC 주소를 알아낸다. `arp -a`로 현재 기기의 ARP 표를 확인한다 | 2절 |
| RARP | Reverse ARP | MAC 주소로 IP 주소를 알아낸다. 현재는 거의 쓰지 않고 BOOTP와 DHCP가 대체했다 | 2절 |
| 게이트웨이 | Gateway | 내 네트워크에서 다른 네트워크로 나가는 출입구다. 가정에서는 보통 공유기의 내부 IP가 기본 게이트웨이다 | [gatewaysetup.md](../ip-addressing-and-nat/gatewaysetup.md) |
| DTE | Data Terminal Equipment | 데이터를 만들고 받는 종단 장비다. 예: PC, 라우터의 시리얼 인터페이스 | |
| DCE | Data Circuit-terminating Equipment | 회선에 연결하고 동기 신호(클록)를 제공하는 장비다. 예: 모뎀, CSU/DSU | |
| 홉(Hop) | Hop | 경로에서 지나는 라우터 하나를 센 단위다. 1 홉은 라우터 1대, 2 홉은 경로에 라우터가 2대 있다는 뜻이다 | [rip.md](../routing-and-switching/rip.md) |

{% hint style="info" %}
NOTE: 원본의 `Gateway`, `DTE / DCE` 절은 제목만 있고 내용이 없었다. 위 풀이는 일반적인 정의로 새로 채운 것이다.
{% endhint %}

## 2. MAC 주소와 ARP

| 번호 | 항목 | 내용 |
|---|---|---|
| 1 | 전달 방식 | L2 스위치는 MAC 주소를 참조해 목적지 기기로 프레임을 전달한다 |
| 2 | 주소를 모를 때 | 스위치에 목적지 MAC 주소 정보가 없으면 플러딩(flooding)한다. 받은 포트를 제외한 모든 포트로 프레임을 보낸다 |
| 3 | 수신 판단 | 프레임을 받은 기기의 NIC는 프레임의 목적지 MAC 주소가 자기 주소인지 확인해 수신 여부를 정한다 |
| 4 | 주소 변환 | ARP가 IP 주소를 MAC 주소로 바꾼다. RARP는 반대 방향이다 |

{% hint style="info" %}
NOTE: 원본은 플러딩된 데이터를 받은 장치가 "IP 확인 후 수신 여부를 결정"한다고 적었다. 같은 네트워크 안에서 1차 판단은 목적지 MAC 주소로 하므로 정정했다. 확인 필요.
{% endhint %}

## 3. 사용 예

| 목적 | 명령 | 기대 결과 |
|---|---|---|
| ARP 표 확인 | `arp -a` | IP 주소와 MAC 주소의 대응 목록이 출력된다 |

## 4. 참조

| 참조 문서 | 비고 |
|---|---|
| [Cisco 명령어 정리 (네이버 블로그)](https://m.blog.naver.com/sung_mk1919/221796249432) | 외부 문서 |
