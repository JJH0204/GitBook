# 강의 (Lectures)

주말반 네트워크 1·2 과정을 준비하며 쓴 강의 노트다. 패킷트레이서와 리눅스로 네트워크 기초 이론과 실습을 16일에 걸쳐 다룬다.

{% hint style="info" %}
이 스페이스의 페이지는 강의 노트를 GitBook 형식으로 옮긴 것이다. 실습에 나오는 IP 주소는 모두 가상의 실습망 주소이거나 문서용 예시 주소이고, 계정과 비밀번호는 예시 값이다.
{% endhint %}

## 문서 목록과 읽는 순서

실습 환경을 먼저 준비하고, 네트워크 1에서 네트워크 2 순서로 읽는다.

| 순서 | 문서 | 범위 | 내용 |
|---|---|---|---|
| 1 | [실습 환경 구축](setup/README.md) | 설치 2건 | 파이썬과 VS Code, 패킷트레이서 설치와 계정 |
| 2 | [네트워크 1 — 1단계 · 네트워크 기초와 구성](network1/README.md) | 1~8일차 | 네트워크 기초와 구성(IP, 서브넷, 스위칭, 라우팅) |
| 3 | [네트워크 2 — 2단계 · 서버 구축 및 활용](network2/README.md) | 9~16일차 | 리눅스 서버 구축과 활용(리눅스, 서버, Git, 도커, 쿠버네티스) |

## 기존 노트와 함께 보기

강의 페이지와 겹치는 주제는 기존 페이지에 정리해 두었다.

* OSI 7계층: [OSI 7계층 모델](../fundamentals/osi7layer.md), [TCP/IP 4계층 모델](../fundamentals/tcpip4layer.md)
* IP와 서브넷: [IPv4 주소 체계](../ip-addressing-and-nat/ipv4.md), [서브넷팅 계산](../ip-addressing-and-nat/subnetting.md), [NAT 동작 원리](../ip-addressing-and-nat/network_address_translation.md)
* 보안 쪽 강의는 Security 스페이스의 [정보보안 강의](https://krjaeh0.gitbook.io/j-log/security/lectures)에 있다.
