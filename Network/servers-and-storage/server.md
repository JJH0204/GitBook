# 서버 분류 및 유형

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-NSV-001-DO |
| 유형 | D&O (개념) |
| 목적 | 서버를 운영체제와 용도에 따라 분류하고 용도별 대표 프로토콜과 포트를 설명한다 |
| 확인 상태 | 미검증 (원본 목록과 일반 지식을 정리한 것이며 출처를 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본은 이름만 나열한 목록이었다. 역할, 프로토콜, 포트 열은 원본에 없던 내용을 보충했다. 원본의 "등등"은 삭제했다.
{% endhint %}

## 1. 목적

서버는 클라이언트의 요청을 받아 서비스를 제공하는 컴퓨터 또는 프로그램이다. 서버는 운영체제와 용도로 분류한다.

## 2. 구성 요소

### 2.1 운영체제에 따른 분류

| 분류 | 설명 | 문서 |
|---|---|---|
| Linux 서버 | Linux 운영체제로 운영하는 서버 | |
| Windows 서버 | Windows Server 운영체제로 운영하는 서버 | [WindowServer](../../Programming/cs_basics/os_memory/windows-internals/windowserver.md) |

### 2.2 용도에 따른 분류

| 서버 | 역할 | 대표 프로토콜·포트 | 문서 |
|---|---|---|---|
| 웹 서버 | 웹 페이지를 제공한다 | HTTP 80/tcp, HTTPS 443/tcp | [WebServer](../../Programming/cs_basics/web_technologies/web-basics/webserver.md) |
| DNS 서버 | 도메인 이름을 IP 주소로 바꾼다 | 53/udp, 53/tcp | [DNS](../protocols/dns.md) |
| Samba 서버 | Windows(SMB) 방식 파일·프린터 공유를 Linux에서 제공한다 | SMB 445/tcp | |
| FTP 서버 | 파일을 전송한다 | 제어 21/tcp | |
| 로그 서버 | 여러 장비의 로그를 모아 보관한다 | syslog 514/udp | |
| NFS 서버 | 네트워크로 파일 시스템을 공유한다(주로 Unix·Linux) | 2049/tcp | |
| 메일 서버 | 이메일을 보내고 받는다 | SMTP 25/tcp, IMAP 143/tcp, POP3 110/tcp | |
| 클라우드 서버 | 인터넷으로 컴퓨팅 자원을 빌려 쓴다 | 서비스별로 다르다 | |

## 3. 동작 원리

1. 서버 프로그램이 정해진 포트에서 요청을 기다린다.
2. 클라이언트가 서버의 IP 주소와 포트로 요청을 보낸다.
3. 서버가 요청을 처리하고 결과를 클라이언트에 돌려준다.

한 대의 물리 서버가 여러 용도를 겸할 수 있다. 용도는 서버 소프트웨어와 포트로 구분한다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| SMB | Server Message Block. Windows 파일 공유 프로토콜 |
| NFS | Network File System |
| FTP | File Transfer Protocol |
| SMTP / IMAP / POP3 | 메일 전송 / 메일 조회 / 메일 수신 프로토콜 |
| syslog | 로그 전송 표준 프로토콜 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [dns.md](../protocols/dns.md) | | DNS |
| [raid.md](raid.md) | NET-NSV-002-DO | 복수 배열 독립 디스크 (RAID) |
| [storage-types.md](storage-types.md) | NET-NSV-004-DO | 스토리지 연결 방식 (DAS, NAS, SAN) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 내가 접해 본 서버(웹, 게임, 파일 등)를 하나 골라 어떤 요청을 받고 무엇을 돌려주는지 적는다.
- [ ] 서버와 일반 PC의 차이를 내 말로 설명해 본다.
- [ ] 서버 용도별로 열어 둔 포트를 왜 최소로 유지해야 하는지 적는다.
