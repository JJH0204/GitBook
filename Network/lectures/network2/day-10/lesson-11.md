# 11. 오늘의 문제 🎯 — 리눅스 퀴즈 + CCNA

> 상위: [10일차 · 서버 기초](README.md)

오늘은 **오전(리눅스 기본) · 오후(서버 기초)** 두 덩어리라 문제도 둘로 나눴다.

- **Part 1 · 리눅스 퀴즈** (Q1~Q5) — 리눅스마스터 2급 · 네트워크관리사 스타일. 명령은 **영어 약자**라서 약자를 풀면 답이 보인다
- **Part 2 · CCNA** (Q6~Q8) — 실제 시험은 영어라 **핵심 용어는 영문을 함께** 표기했다

> 💡 **진행 방법**: 각자 풀고 → **VM 에서 직접 쳐서 확인**한 뒤 → `정답 및 해설` 콜아웃을 펼친다.
> Part 2 는 **"몇 계층 이야기인가"** 부터 묻자 — **"이건 IP(3계층) 일인가, 포트(4계층) 일인가?"**

---

# Part 1 · 리눅스 퀴즈

## Q1. 커널 · 쉘 · 배포판 — [9일차 복습](../day-09/lesson-1.md)

사용자가 입력한 명령을 해석하여 **커널에 전달**하는 프로그램은?

- A. 커널 (Kernel)
- B. **쉘 (Shell)**
- C. 배포판 (Distribution)
- D. 하이퍼바이저 (Hypervisor)

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- 쉘 = **통역사 · 운전대**. 대표가 `bash` (`echo $SHELL` 로 확인)
- A 커널 = 하드웨어를 관리하는 **엔진**, C 배포판 = 커널 + 쉘 + 프로그램 **완성품**(Ubuntu)
- D 하이퍼바이저 = VM 을 돌리는 프로그램(VirtualBox) — 리눅스 구조와 무관
{% endhint %}

---

## Q2. 절대 경로 — [1_파일시스템과_이동](lesson-1.md)

현재 위치가 `/var/log` 이다. 다음 중 **결과가 다른 하나**는?

- A. `cd ~`
- B. `cd`
- C. `cd /home/student` (사용자 student 로 로그인 중)
- D. **`cd ..`**

{% hint style="success" %}
**정답 및 해설**

**정답: D**
- A · B · C 는 모두 **내 홈** `/home/student` 으로 간다
- D `..` 는 **한 칸 위** → `/var`
- 되짚기: `pwd` 로 확인하며 STEP 1 에서 해본 것
{% endhint %}

---

## Q3. 권한 해석 ⭐ — [3_사용자_권한_sudo](lesson-3.md)

`ls -l` 결과가 `-rwxr-x--- 1 student dev 120 run.sh` 일 때 옳은 것은?

- A. 누구나 실행할 수 있다
- B. **dev 그룹 사용자는 읽고 실행할 수 있지만 수정할 수 없다**
- C. 숫자로 표현하면 `760` 이다
- D. 디렉터리다

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- `rwx | r-x | ---` → 주인(student) **7** · 그룹(dev) **5** · 나머지 **0** = **750**
- A: 나머지(others)는 `---` → 아무것도 못 한다
- C: `760` 이면 그룹이 `rw-` → 그룹은 `r-x` 이므로 **750**
- D: 첫 글자가 `-` → **파일** (`d` 여야 디렉터리)
{% endhint %}

---

## Q4. 명령의 뜻 — [2_파일다루기와_편집](lesson-2.md)

다음 명령에 대한 설명으로 **틀린** 것은?

- A. `mv a.txt b.txt` — a.txt 의 이름을 b.txt 로 바꾼다
- B. `echo hi >> log.txt` — log.txt 끝에 한 줄을 덧붙인다
- C. **`rm` 으로 지운 파일은 휴지통(`~/.Trash`)에서 복구할 수 있다**
- D. `cat /etc/passwd | grep student` — student 가 들어간 줄만 보여준다

{% hint style="success" %}
**정답 및 해설**

**정답: C**
- `rm` 에는 **휴지통이 없다** → 지우면 끝. 그래서 설정 파일은 **`cp` 로 백업 먼저**
- D 의 `| grep` = 시스코 `| include` 와 같은 발상
{% endhint %}

---

## Q5. 리눅스의 네트워크 — [4_리눅스의_네트워크](lesson-4.md)

다음 `ip route` 출력에서 **기본 게이트웨이**는?

```
default via 192.168.0.1 dev enp0s3 proto dhcp src 192.168.0.42 metric 100
192.168.0.0/24 dev enp0s3 proto kernel scope link src 192.168.0.42 metric 100
```

- A. 192.168.0.42
- B. **192.168.0.1**
- C. 192.168.0.0
- D. 192.168.0.255

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- `default via` 뒤 = **모르는 곳은 전부 여기로** = 기본 게이트웨이 (시스코 `0.0.0.0/0`)
- A 는 **내 IP** (`src`), C 는 **네트워크 주소**, D 는 **브로드캐스트 주소** — 2일차 서브넷 복습
- `proto dhcp` → 게이트웨이도 **DHCP 로 받았다** (8일차 `default-router`)
{% endhint %}

---

# Part 2 · CCNA

## Q6. TCP 의 특징 — [7_TCP와_UDP](lesson-7.md)

Which **two** characteristics describe **TCP**? (Choose two.)
(TCP 에 해당하는 것 두 가지는?)

- A. **It uses a three-way handshake to establish a session.**
- B. It sends data without checking whether it arrived.
- C. **It retransmits lost segments using acknowledgments.**
- D. It is preferred for real-time voice and video.
- E. It has an 8-byte header.

{% hint style="success" %}
**정답 및 해설**

**정답: A, C**
- A: **SYN → SYN-ACK → ACK** — STEP 7 에서 `[S]` `[S.]` `[.]` 로 직접 본 것
- C: **ACK** 로 받았는지 확인하고, 안 오면 **재전송** = 등기우편
- B · D · E 는 전부 **UDP** — 확인 없음 · 실시간 음성/영상 · 헤더 8 바이트
{% endhint %}

---

## Q7. 포트와 전송 프로토콜 ⭐ — [8_포트번호와_소켓](lesson-8.md)

Which pair is **correct**? (포트 · 프로토콜 · 서비스 조합이 옳은 것은?)

- A. SSH — UDP 22
- B. **DNS — UDP 53**
- C. DHCP — TCP 67
- D. HTTPS — TCP 8443

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- A: SSH 는 **TCP** 22 — 명령 한 글자도 잃으면 안 된다
- C: DHCP 는 **UDP** 67/68 — 아직 IP 가 없어서 연결(TCP)을 맺을 수 없다
- D: HTTPS 기본은 **443** (8443 은 흔한 대체 포트일 뿐)
- **UDP 인 것만 외우기**: DNS 53 · DHCP 67/68 · SNMP 161/162 (+ TFTP 69 · NTP 123)
{% endhint %}

---

## Q8. PAT (NAT Overload) — [9_NAT와_포트포워딩](lesson-9.md)

A home router allows **20 devices** with private addresses to reach the Internet using **one public IP address**.
How does the router tell the return traffic apart?
(공인 IP 하나로 20대가 인터넷을 쓴다. 돌아오는 응답을 누구 것인지 어떻게 구분하나?)

- A. By the destination MAC address of each device
- B. **By a unique source port number for each session in the translation table**
- C. By assigning each device a different public IP from a pool
- D. By using the DNS server to look up each device

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- **PAT(Overload)** 는 출발지 **포트 번호**까지 바꿔 **변환표**에 적는다 → 응답이 `203.0.113.2:1025` 로 오면 표를 보고 `192.168.0.101` 로
- A: MAC 은 **같은 LAN 안에서만** 의미가 있다 (3일차) — 인터넷에서 온 패킷은 모른다
- C: 이건 **Dynamic NAT** — 공인 IP 가 20개 필요하다
- 되짚기: `curl ifconfig.me` 로 강의실 전원이 **같은 공인 IP** 를 본 장면
{% endhint %}

---

## 📝 강의 메모

- 순서가 **오늘 수업 순서 그대로** — Q1(9일차 복습: 쉘) → Q2(이동) → Q3(권한) → Q4(파일) → Q5(네트워크) → Q6(TCP) → Q7(포트) → Q8(PAT)
- **Q3 · Q8 이 오늘의 최중요 문제.**
  - Q3: `rwx | r-x | ---` 로 **세 칸 끊어 읽기** — 풀고 나서 VM 에서 `touch run.sh; chmod 750 run.sh; ls -l run.sh`
  - Q8: "변환표에 **포트**까지 적는다" 한 줄 — C(Dynamic NAT)를 고르는 학생이 많다
- Q2 는 복수 정답이 아니지만 Q6 은 **"Choose two"** — CCNA 형식에 익숙해지게
- Q7 은 **네트워크관리사 필기**에도 그대로 나온다 → "UDP 인 것만 외우기" 다시
- 🔚 **종료 전**: `sudo poweroff` — **VM 은 다음 주에도 쓴다**
- **다음(11일차) 예고**: 오늘 **포트를 열었다** → 먼저 **공유기(유선)** 로 오늘 배운 걸 한 상자에 모아 보고 → "아무나 들어오면?" → **ACL · 방화벽**
  → [11일차 · 서버 보안](../day-11/README.md)
