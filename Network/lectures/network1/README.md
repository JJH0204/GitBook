# 네트워크 1 — 1단계 · 네트워크 기초와 구성

> 상위: [강의 (Lectures)](../README.md) · 다음 단계: [네트워크 2](../network2/README.md)

패킷트레이서와 리눅스를 활용한 네트워크 기초이론과 실습 과정이다. 도구는 Cisco 패킷트레이서이고 1~8일차를 다룬다. 설치와 계정은 [실습 환경 구축](../setup/README.md)에서 먼저 준비한다.

## 문서 목록과 읽는 순서

일차 순서대로 읽는다. 각 일차 README에 그날의 문서 목록과 Task ID가 있다.

| 순서 | 문서 | 주제 | 핵심 내용 |
|---|---|---|---|
| 1 | [1일차 · 네트워크 기본](day-01/README.md) | 네트워크 기본 | 자격증 소개, Bit/Byte, LAN/WAN, OSI 7계층, 캐스트 |
| 2 | [2일차 · IP와 서브넷](day-02/README.md) | IP와 서브넷 | IPv4/IPv6, IP 클래스, 서브넷 마스크, 서브넷팅 |
| 3 | [3일차 · 네트워크 장비와 네트워크 토폴로지](day-03/README.md) | 네트워크 장비와 토폴로지 | 허브/스위치/라우터, MAC/ARP/ICMP, 패킷트레이서 실습 |
| 4 | [4일차 · 스위치와 라우터](day-04/README.md) | 스위치와 라우터 | 스위치와 라우터의 기본 동작 원리 |
| 5 | [5일차 · 라우팅 프로토콜](day-05/README.md) | 라우팅 프로토콜 | 정적 라우팅의 한계, 메트릭과 AD, RIP, OSPF, EIGRP |
| 6 | [6일차 · 라우팅 프로토콜 심화 — 재분배](day-06/README.md) | 라우팅 프로토콜 심화 | 재분배(Redistribution), seed metric |
| 7 | [7일차 · 스위칭 심화 — VLAN · 트렁크 · EtherChannel](day-07/README.md) | 스위칭 심화 | VLAN, 트렁크, Router-on-a-stick, STP, EtherChannel |
| 8 | [8일차 · 네트워크 장비에서의 서버 설정](day-08/README.md) | 네트워크 장비 서버 설정 | SSH, DHCP(릴레이), DNS, SNMP, Proxy, FTP, 포트 보안, 무선랜과 IPv6 맛보기 |

## 사전 준비

| 준비물 | 문서 | 필요한 시점 |
|---|---|---|
| 파이썬과 VS Code | [LEC-NS-00-001-MP](../setup/lesson-1.md) | 1일차 문자 코드 실습 전 |
| 패킷트레이서와 netacad 계정 | [LEC-NS-00-002-MP](../setup/lesson-2.md) | 3일차 전. 2일차 수업 끝에 미리 안내한다 |
