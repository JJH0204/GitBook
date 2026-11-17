# 와이어샤크 패킷 분석 (Wireshark)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-DEF-011-REF |
| 유형 | REF (참조) |
| 목적 | Wireshark로 패킷을 분석할 때 쓰는 표시 필터와 통계 메뉴를 찾아본다 |
| 확인 상태 | 미검증 (원본은 제목만 있는 메모였다. 필터 예시와 메뉴 경로는 일반 지식으로 보충했으며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본에는 제목 줄(프로토콜 필터, 포트 필터, IP 데이터그램, 프로토콜 7계층 통계, I/O 그래프, IP Statistics)만 있고 내용은 화면 이미지였다. 이 문서의 표는 그 제목에 해당하는 일반적인 사용법이다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 패킷 캡처에는 계정, 쿠키, 개인정보가 들어 있을 수 있다. 자신이 관리하는 네트워크에서만 캡처하고, 캡처 파일을 외부에 공유하지 않는다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [침입 탐지 시스템 (IDS)](ids.md) | SEC-DEF-001-DO | 패킷 기반 탐지 |
| Wireshark 샘플 캡처 | - | https://wiki.wireshark.org/SampleCaptures |

## 2. 분석 방식

일반적으로 패킷을 캡처해 파일(`.pcap`, `.pcapng`)로 저장한 뒤 분석한다. 분석 실력을 높이려면 샘플 캡처를 자주 분석한다.

## 3. 표시 필터

| 목적 | 필터 예 |
|---|---|
| 특정 프로토콜만 보기 | `http`, `dns`, `icmp`, `tcp`, `udp` |
| 특정 포트만 보기 | `tcp.port == 80`, `udp.port == 53` |
| 특정 IP의 패킷 | `ip.addr == <IP 주소>` |
| 출발지, 목적지 구분 | `ip.src == <IP 주소>`, `ip.dst == <IP 주소>` |
| 조건 조합 | `ip.addr == <IP 주소> && tcp.port == 22` |
| 제외 | `!(arp)` |

필터에 이름(주석)을 붙여 저장하거나 필터 표현식 버튼으로 추가할 수 있다. 메뉴 위치는 `Analyze > Display Filters`와 `Filter Expression Buttons`다(확인 필요).

## 4. 통계 메뉴

| 원본 항목 | 메뉴 경로 | 용도 |
|---|---|---|
| 프로토콜 7계층 통계 | `Statistics > Protocol Hierarchy` | 캡처 안의 프로토콜별 비율을 본다 |
| I/O 그래프 | `Statistics > I/O Graphs` | 시간에 따른 트래픽 양을 그래프로 본다. 보고서 작성에 쓴다 |
| IP Statistics (IP 통신 통계) | `Statistics > Conversations`, `Statistics > Endpoints` | IP 주소 쌍과 단말별 통신량을 본다 |

## 5. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 제목만 있던 메모를 REF 표로 재작성하고 필터와 메뉴 경로를 보충했다(미검증). 구글 검색 링크와 이미지 안내 문구는 삭제했다 |
