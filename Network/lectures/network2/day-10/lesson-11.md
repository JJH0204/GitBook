# 11. 오늘의 문제 — 리눅스 퀴즈 + CCNA

> 상위: [10일차 · 서버 기초](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-10-011-INS |
| 유형 | INS (점검) |
| 목적 | 10일차 학습 내용을 리눅스 퀴즈 5문항과 CCNA 형식 3문항으로 점검한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 문항과 해설을 다시 검증하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 점검 방법

오늘은 오전(리눅스 기본)과 오후(서버 기초) 두 덩어리라 문제도 둘로 나눴다.

- Part 1 · 리눅스 퀴즈(Q1~Q5): 리눅스마스터 2급, 네트워크관리사 스타일이다. 명령은 영어 약자라서 약자를 풀면 답이 보인다.
- Part 2 · CCNA(Q6~Q8): 실제 시험은 영어라서 핵심 용어는 영문을 함께 표기했다.

진행 순서는 다음과 같다.

1. 각자 문제를 푼다.
2. VM에서 직접 입력해 확인한다.
3. `정답 및 해설` 상자를 펼친다.

Part 2는 "몇 계층 이야기인가"부터 묻는다. 이것이 IP(3계층) 일인가, 포트(4계층) 일인가를 먼저 구분한다.

## 2. 점검 항목

### Part 1 · 리눅스 퀴즈

#### Q1. 커널 · 쉘 · 배포판

관련 문서: [9일차 복습](../day-09/lesson-9.md)

사용자가 입력한 명령을 해석하여 커널에 전달하는 프로그램은?

- A. 커널 (Kernel)
- B. 쉘 (Shell)
- C. 배포판 (Distribution)
- D. 하이퍼바이저 (Hypervisor)

{% hint style="info" %}
**정답 및 해설**

**정답: B**
- 쉘은 통역사, 운전대다. 대표가 `bash`다(`echo $SHELL`로 확인한다).
- A 커널은 하드웨어를 관리하는 엔진이다. C 배포판은 커널, 쉘, 프로그램을 묶은 완성품(Ubuntu)이다.
- D 하이퍼바이저는 VM을 돌리는 프로그램(VirtualBox)이다. 리눅스 구조와 무관하다.
{% endhint %}

#### Q2. 절대 경로

관련 문서: [1. 파일 시스템과 이동](lesson-1.md)(LEC-N2-10-001-DO)

현재 위치가 `/var/log`이다. 다음 중 결과가 다른 하나는?

- A. `cd ~`
- B. `cd`
- C. `cd /home/student` (사용자 student로 로그인 중)
- D. `cd ..`

{% hint style="info" %}
**정답 및 해설**

**정답: D**
- A, B, C는 모두 내 홈 `/home/student`로 간다.
- D의 `..`는 한 칸 위로 가므로 `/var`가 된다.
- 되짚기: `pwd`로 확인하며 STEP 1에서 해 본 것이다.
{% endhint %}

#### Q3. 권한 해석

관련 문서: [3. 사용자 · 권한 · sudo](lesson-3.md)(LEC-N2-10-003-DO)

`ls -l` 결과가 `-rwxr-x--- 1 student dev 120 run.sh`일 때 옳은 것은?

- A. 누구나 실행할 수 있다
- B. dev 그룹 사용자는 읽고 실행할 수 있지만 수정할 수 없다
- C. 숫자로 표현하면 `760`이다
- D. 디렉터리다

{% hint style="info" %}
**정답 및 해설**

**정답: B**
- `rwx | r-x | ---`이므로 주인(student) 7, 그룹(dev) 5, 나머지 0 = 750이다.
- A: 나머지(others)는 `---`이므로 아무것도 못 한다.
- C: 그룹이 `r-x`이므로 760이 아니라 750이다.
- D: 첫 글자가 `-`이므로 파일이다(디렉터리는 `d`).
{% endhint %}

#### Q4. 명령의 뜻

관련 문서: [2. 파일 다루기와 편집](lesson-2.md)(LEC-N2-10-002-DO)

다음 명령에 대한 설명으로 틀린 것은?

- A. `mv a.txt b.txt` — a.txt의 이름을 b.txt로 바꾼다
- B. `echo hi >> log.txt` — log.txt 끝에 한 줄을 덧붙인다
- C. `rm`으로 지운 파일은 휴지통(`~/.Trash`)에서 복구할 수 있다
- D. `cat /etc/passwd | grep student` — student가 들어간 줄만 보여 준다

{% hint style="info" %}
**정답 및 해설**

**정답: C**
- `rm`에는 휴지통이 없다. 지우면 끝이다. 그래서 설정 파일은 `cp`로 백업을 먼저 한다.
- D의 `| grep`은 시스코 `| include`와 같은 발상이다.
{% endhint %}

#### Q5. 리눅스의 네트워크

관련 문서: [4. 리눅스의 네트워크](lesson-4.md)(LEC-N2-10-004-DO)

다음 `ip route` 출력에서 기본 게이트웨이는?

```
default via 192.168.0.1 dev enp0s3 proto dhcp src 192.168.0.42 metric 100
192.168.0.0/24 dev enp0s3 proto kernel scope link src 192.168.0.42 metric 100
```

- A. 192.168.0.42
- B. 192.168.0.1
- C. 192.168.0.0
- D. 192.168.0.255

{% hint style="info" %}
**정답 및 해설**

**정답: B**
- `default via` 뒤가 "모르는 곳은 전부 여기로"이며 기본 게이트웨이다(시스코 `0.0.0.0/0`).
- A는 내 IP(`src`), C는 네트워크 주소, D는 브로드캐스트 주소다. 2일차 서브넷 복습이다.
- `proto dhcp`이므로 게이트웨이도 DHCP로 받았다(8일차 `default-router`).
{% endhint %}

### Part 2 · CCNA

#### Q6. TCP의 특징

관련 문서: [7. TCP와 UDP](lesson-7.md)(LEC-N2-10-007-DO)

Which **two** characteristics describe **TCP**? (Choose two.)
(TCP에 해당하는 것 두 가지는?)

- A. It uses a three-way handshake to establish a session.
- B. It sends data without checking whether it arrived.
- C. It retransmits lost segments using acknowledgments.
- D. It is preferred for real-time voice and video.
- E. It has an 8-byte header.

{% hint style="info" %}
**정답 및 해설**

**정답: A, C**
- A: SYN → SYN-ACK → ACK다. STEP 7에서 `[S]` `[S.]` `[.]`로 직접 본 것이다.
- C: ACK로 받았는지 확인하고, 안 오면 재전송한다. 등기우편이다.
- B, D, E는 전부 UDP다. 확인 없음, 실시간 음성/영상, 헤더 8바이트다.
{% endhint %}

#### Q7. 포트와 전송 프로토콜

관련 문서: [8. 포트 번호와 소켓](lesson-8.md)(LEC-N2-10-008-DO)

Which pair is **correct**? (포트, 프로토콜, 서비스 조합이 옳은 것은?)

- A. SSH — UDP 22
- B. DNS — UDP 53
- C. DHCP — TCP 67
- D. HTTPS — TCP 8443

{% hint style="info" %}
**정답 및 해설**

**정답: B**
- A: SSH는 TCP 22다. 명령 한 글자도 잃으면 안 된다.
- C: DHCP는 UDP 67/68이다. 아직 IP가 없어서 연결(TCP)을 맺을 수 없다.
- D: HTTPS 기본은 443이다(8443은 흔한 대체 포트일 뿐이다).
- UDP인 것만 외운다: DNS 53, DHCP 67/68, SNMP 161/162(그리고 TFTP 69, NTP 123).
{% endhint %}

#### Q8. PAT (NAT Overload)

관련 문서: [9. NAT와 포트포워딩](lesson-9.md)(LEC-N2-10-009-DO)

A home router allows **20 devices** with private addresses to reach the Internet using **one public IP address**.
How does the router tell the return traffic apart?
(공인 IP 하나로 20대가 인터넷을 쓴다. 돌아오는 응답이 누구 것인지 어떻게 구분하나?)

- A. By the destination MAC address of each device
- B. By a unique source port number for each session in the translation table
- C. By assigning each device a different public IP from a pool
- D. By using the DNS server to look up each device

{% hint style="info" %}
**정답 및 해설**

**정답: B**
- PAT(Overload)는 출발지 포트 번호까지 바꿔 변환표에 적는다. 응답이 `203.0.113.2:1025`로 오면 표를 보고 `192.168.0.101`로 돌려준다.
- A: MAC은 같은 LAN 안에서만 의미가 있다(3일차). 인터넷에서 온 패킷은 모른다.
- C: 이것은 Dynamic NAT다. 공인 IP가 20개 필요하다.
- 되짚기: `curl ifconfig.me`로 강의실 전원이 같은 공인 IP를 본 장면이다.
{% endhint %}

## 진행 메모

- 순서는 오늘 수업 순서 그대로다. Q1(9일차 복습: 쉘), Q2(이동), Q3(권한), Q4(파일), Q5(네트워크), Q6(TCP), Q7(포트), Q8(PAT)이다.
- Q3과 Q8이 오늘의 최중요 문제다.
  - Q3: `rwx | r-x | ---`로 세 칸씩 끊어 읽는다. 푼 뒤 VM에서 `touch run.sh; chmod 750 run.sh; ls -l run.sh`를 입력한다.
  - Q8: "변환표에 포트까지 적는다" 한 줄이 핵심이다. C(Dynamic NAT)를 고르는 학생이 많다.
- Q2는 복수 정답이 아니지만 Q6은 "Choose two"다. CCNA 형식에 익숙해지게 한다.
- Q7은 네트워크관리사 필기에도 그대로 나온다. "UDP인 것만 외우기"를 다시 짚는다.
- 종료 전에 `sudo poweroff`를 입력한다. VM은 다음 주에도 쓴다.
- 다음(11일차) 예고: 오늘 포트를 열었다. 먼저 공유기(유선)로 오늘 배운 것을 한 상자에 모아 보고, "아무나 들어오면?"을 거쳐 ACL, 방화벽으로 간다. → [11일차 · 서버 보안](../day-11/README.md)
