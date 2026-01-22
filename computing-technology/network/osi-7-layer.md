# OSI 7 Layer

## OSI 7 계층 모델(OSI 7 Layer Model)이란?

* 네트워크 통신을 계층화하여 표준화한 모델
* 국제 표준화 기구(ISO)에서 정의한 네트워크 프로토콜 구조
* 각 계층별 역할을 분리하여 네트워크 통신을 설명하는 개념이다.

✔ **네트워크 통신 과정을 7개의 계층으로 분할하여 정리**

✔ **각 계층이 독립적으로 동작하며, 계층 간 상호작용을 통해 데이터가 전달됨**

✔ **TCP/IP 모델과 비교할 때 기본 개념으로 많이 사용됨**

***

<figure><img src="../../.gitbook/assets/Pasted image 20240819202412.png" alt=""><figcaption><p>OSI 7 Layer 와 TCP/IP</p></figcaption></figure>

## OSI 7 계층 구조

### 요약

<table><thead><tr><th width="100">계층</th><th>명칭</th><th>역할</th><th>주요 프로토콜 및 장비</th></tr></thead><tbody><tr><td>7</td><td>응용 계층<br>Application Layer</td><td>사용자와 네트워크 간 상호작용</td><td>HTTP, FTP, SMTP, DNS</td></tr><tr><td>6</td><td>표현 계층<br>Presentation Layer</td><td>데이터 형식 변환, 암호화/복호화</td><td>JPEG, MP3, ASCII, TLS, SSL</td></tr><tr><td>5</td><td>세션 계층<br>Session Layer</td><td>통신 세션 관리, 연결 설정 및 종료</td><td>NetBIOS, RPC, PPTP</td></tr><tr><td>4</td><td>전송 계층<br>Transport Layer</td><td>신뢰성 있는 데이터 전송, 흐름/오류 제어</td><td>TCP, UDP</td></tr><tr><td>3</td><td>네트워크 계층<br>Network Layer</td><td>데이터 패킷 라우팅, IP 주소 관리</td><td>IP, ICMP, ARP<br>라우터</td></tr><tr><td>2</td><td>테이터 링크 계층<br>Data Link Layer</td><td>물리적 주소(MAC)관리, 오류 감지</td><td>이더넷, 스위치, MAC 주소</td></tr><tr><td>1</td><td>물리 계층<br>Physical Layer</td><td>전기적 신호, 데이터 전송 매체</td><td>케이블, 허브, 리피터</td></tr></tbody></table>

***

### 물리 계층 (Physical Layer)

* 데이터를 전기적 신호(이진수)로 변환하여 전송
* 네트워크 장비 간 물리적 연결(케이블, 전파, 광신호 등)
* 데이터 속도, 전송 방식(직렬/병렬), 전송 매체 결정

> 장비: 리피터, 허브, 광케이블, 동축 케이블 프로토콜: RS-232, IEEE 802.11(Wi-Fi)

***

### 데이터 링크 계층 (Data Link Layer)

* MAC 주소 기반 통신 & 오류 감지 (Frame 단위)
* 물리 계층에서 받은 데이터를 프레임(Frame)으로 변환
* 네트워크 장치 간 직접적인 데이터 전송 및 흐름 제어
* 오류 감지(Parity Check, CRC) 기능 제공

> 장비: 스위치, 브리지 프로토콜: Ethernet, Wi-Fi, MAC

***

### 네트워크 계층 (Network Layer)

* IP 주소를 기반으로 최적의 경로를 찾아 패킷을 라우팅
* 데이터 패킷(Packet) 단위 전송
* IP 주소 지정 및 관리 (논리적 주소)
* 패킷을 목적지까지 전달하기 위해 라우팅(Routing) 수행

> 장비: 라우터 프로토콜: IPv4, IPv6, ICMP, ARP

***

### 전송 계층 (Transport Layer)

* 포트 번호를 기반으로 프로세스 간 데이터 전송 (세그먼트 단위)
* 데이터 흐름 제어(Flow Control) & 오류 제어(Error Control)
* 신뢰성 있는 데이터 전송 보장 (TCP) 또는 빠른 전송 (UDP)

> 프로토콜: TCP(신뢰성 있는 연결, 패킷 손실 복구), UDP(속도가 중요한 경우, 비신뢰성 전송)

* 포트 번호 예시

| 서비스   | 프로토콜 | 포트 번호 |
| ----- | ---- | ----- |
| HTTP  | TCP  | 80    |
| HTTPS | TCP  | 443   |
| FTP   | TCP  | 21    |
| DNS   | UDP  | 53    |

***

### 세션 계층 (Session Layer)

* 통신 세션 관리 (연결 설정, 유지, 종료)
* 클라이언트와 서버 간 세션 생성 및 동기화
* 중복 데이터 전송 방지 및 데이터 복구 지원

> 프로토콜: NetBIOS, RPC, PPTP

***

### 표현 계층 (Presentation Layer)

* 데이터 변환, 암호화/복호화, 압축 기능 수행
* 서로 다른 시스템 간 데이터 표현 방식 통일
* 인코딩/디코딩, 파일 압축 처리

> 파일 형식: ASCII, JPEG, PNG, MP3, MP4 암호화: SSL/TLS

***

### 응용 계층 (Application Layer)

* 사용자와 직접 상호작용하는 애플리케이션 계층
* 이메일, 웹 브라우저, 파일 전송 기능 제공

> 프로토콜(서비스): HTTP, HTTPS, FTP, SMTP, DNS

***

## OSI 7 계층의 데이터 흐름

송신 측에서 7계층 → 1 계층으로 내려가고, 수신 측에서 1계층 → 7계층으로 올라간다.

***

## OSI 7 계층, TCP/IP 4계층 비교

* OSI 7 계층은 개념적 모델, TCP/IP는 실제 인터넷에서 사용되는 모델
* TCP/IP 모델과 비교하며 개념을 이해하면 실무에서 도움이 될 것 같다.
