# 9. 오늘의 문제 — 리눅스 서버 퀴즈 + CCNA

> 상위: [12일차 · 리눅스 서버 구축](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-12-009-INS |
| 유형 | INS (점검) |
| 목적 | 12일차 내용(여섯 단계, SSH, FTP, DNS, 문제 해결)과 CCNA 스타일 문항 9개로 이해를 점검한다 |
| 확인 상태 | 미검증 (원본 문제와 정답을 다시 읽고 정리했으며 VM에서 재현해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 점검 방법

- Part 1 리눅스 서버 퀴즈(Q1~Q6)는 리눅스마스터 2급, 네트워크관리사 스타일이다.
- Part 2 CCNA(Q7~Q9)는 실제 시험이 영어라서 핵심 용어에 영문을 함께 표기했다.
- 각자 풀고, VM에서 직접 쳐서 확인한 뒤, `정답 및 해설` 알림을 펼친다.
- 오늘은 "몇 번 단계의 문제인가"(① 설치 ~ ⑥ 검증)를 먼저 묻는다.
- 합격 기준: 9문항 중 7문항 이상 정답이다.

---

# Part 1 · 리눅스 서버 퀴즈

## Q1. systemctl — [1. 서버 구축의 공통 문법](lesson-1.md)

서비스를 지금 켜고, 재부팅 후에도 자동으로 켜지게 하는 명령은?

- A. `sudo systemctl start vsftpd`
- B. `sudo systemctl enable vsftpd`
- C. `sudo systemctl enable --now vsftpd`
- D. `sudo systemctl reload vsftpd`

{% hint style="info" %}
**정답 및 해설**

**정답: C**
- `start`는 지금만, `enable`은 다음 부팅부터, `--now`는 둘 다다(9일차 SSH 구축 때 쓴 그것).
- D `reload`는 설정만 다시 읽는다. 서비스가 꺼져 있으면 의미가 없다.
- 되짚기: `start`만 하고 퇴근하면 재부팅된 월요일 아침에 서비스가 죽어 있다.
{% endhint %}

---

## Q2. 설정 파일 고르기 — [2. SSH 다시 보기](lesson-2.md)

SSH 서버에서 root 로그인을 막으려 한다. 고쳐야 할 파일과, 고친 뒤 할 일로 옳은 것은?

- A. `/etc/ssh/ssh_config`를 고치고 `systemctl restart ssh`
- B. `/etc/ssh/sshd_config`를 고치고 `sshd -t`로 검사 후 `systemctl restart ssh`
- C. `/etc/ssh/sshd_config`를 고치면 즉시 적용된다
- D. `~/.ssh/authorized_keys`에 `PermitRootLogin no`를 추가한다

{% hint style="info" %}
**정답 및 해설**

**정답: B**
- 서버는 데몬이고 `d`다. 그래서 `sshd_config`다. A의 `ssh_config`는 클라이언트(`ssh` 명령) 설정이다.
- C: 설정 파일은 읽히는 순간에만 적용된다. ③ 기동(restart)이 필수다.
- D: `authorized_keys`는 공개키를 넣는 곳이지 설정 파일이 아니다.
- 실무 철칙: 고치고 지금 창을 닫지 말고 새 창으로 접속을 확인한다.
{% endhint %}

---

## Q3. FTP의 두 연결 — [3. FTP 서버](lesson-3.md)

FTP로 로그인은 성공했는데 `ls`를 하면 응답 없이 멈춘다. 가장 가능성 높은 원인은?

- A. 사용자 비밀번호가 틀렸다
- B. 데이터 연결(패시브 포트 범위)이 방화벽에 막혔다
- C. vsftpd가 꺼져 있다
- D. DNS 서버가 응답하지 않는다

{% hint style="info" %}
**정답 및 해설**

**정답: B**
- 제어 연결(21)은 성공했으니 로그인이 됐다. 목록과 파일은 데이터 연결로 흐른다. 그쪽이 막힌 것이다.
- A라면 로그인 단계에서 실패하고, C라면 접속 자체가 `Connection refused`다.
- 해결: `pasv_min_port`~`pasv_max_port`를 정하고 그 범위를 방화벽에 연다.
- 되짚기: 전화(21)는 됐는데 택배(데이터)가 안 온다.
{% endhint %}

---

## Q4. 평문 프로토콜 — [3. FTP 서버](lesson-3.md), [2. SSH 다시 보기](lesson-2.md)

`sudo tcpdump -i lo -n -A 'tcp port 21'` 실행 중 화면에 `PASS <password>` 줄이 보였다. 이것이 뜻하는 바로 옳은 것은?

- A. tcpdump가 비밀번호를 복호화한 것이다
- B. vsftpd 설정이 잘못돼 비밀번호가 노출된 것이다
- C. FTP는 원래 평문 프로토콜이라 그대로 흐른다
- D. 루프백(`lo`)에서만 생기는 현상이다

{% hint style="info" %}
**정답 및 해설**

**정답: C**
- FTP, Telnet, HTTP, POP3는 평문이다. 설정 문제가 아니라 프로토콜의 성질이다.
- A: 복호화한 것이 아니라 애초에 암호화가 없다. D: 실제 네트워크 구간에서도 똑같이 보인다.
- 대안: SFTP(22), FTPS, SSH, HTTPS. 8일차부터 반복한 평문과 암호화의 짝이다.
{% endhint %}

---

## Q5. DNS 존 파일 — [5. DNS 서버](lesson-5.md)

존 파일에 `A` 레코드를 추가하고 `systemctl restart named`까지 했는데, 다른 서버에서 조회하면 예전 결과가 나온다. 가장 먼저 확인할 것은?

- A. `/etc/hosts`
- B. SOA의 Serial 값을 올렸는가
- C. 방화벽 53번 포트
- D. `listen-on` 설정

{% hint style="info" %}
**정답 및 해설**

**정답: B**
- 다른 서버는 Serial 번호로 "바뀌었나"를 판단한다. 그대로면 가져가지 않는다.
- 관례는 날짜와 순번이다. `2026092001`의 같은 날 두 번째는 `2026092002`다.
- C, D라면 조회 자체가 실패(timeout)한다. 예전 값이라도 나온다는 것은 통신은 된다는 뜻이다.
- 추가 원인: 캐시 TTL이 남아 있다.
{% endhint %}

---

## Q6. 문제 해결 순서 — [8. 오늘의 서버 총정리](lesson-8.md)

VM 안에서는 `curl localhost:3128`이 되는데, Windows 브라우저에서는 연결되지 않는다. 원인으로 가능성이 낮은 것은?

- A. VirtualBox 포트포워딩 규칙이 없다
- B. `ufw`가 3128을 막고 있다
- C. squid가 `127.0.0.1`에만 LISTEN 하고 있다
- D. squid 서비스가 죽어 있다

{% hint style="info" %}
**정답 및 해설**

**정답: D**
- `localhost`로 되고 있다. 서비스는 살아 있고 설정도 읽혔다(①②③ 정상).
- 남은 용의자는 바깥으로 가는 길이다. ④ 방화벽, 포트포워딩, LISTEN 주소다.
- 오늘의 한 줄: "`localhost`는 되나요?" 이 질문으로 문제가 절반으로 쪼개진다.
{% endhint %}

---

# Part 2 · CCNA

## Q7. Well-known ports — [8. 오늘의 서버 총정리](lesson-8.md), [10일차](../day-10/lesson-8.md)

Which pair of protocol and port number is incorrect?
(프로토콜과 포트 번호의 짝이 틀린 것은?)

- A. SSH — TCP 22
- B. SMTP — TCP 25
- C. DNS — TCP 25
- D. FTP control — TCP 21

{% hint style="info" %}
**정답 및 해설**

**정답: C**
- DNS는 53이다. UDP가 기본이고, 응답이 크거나 존 전송(zone transfer)일 때 TCP 53을 쓴다.
- 25는 SMTP(mail)다. 오늘 `nc localhost 25`로 직접 대화한 그 포트다.
- 외우는 법: 21 FTP, 22 SSH, 23 Telnet, 25 SMTP, 53 DNS, 80 HTTP, 110 POP3, 143 IMAP, 443 HTTPS.
{% endhint %}

---

## Q8. Secure file transfer

A network administrator must copy a router configuration file to a server securely. Which protocol should be used?
(라우터 설정 파일을 안전하게 서버로 옮기려면?)

- A. TFTP
- B. FTP
- C. Telnet
- D. SCP (SFTP)

{% hint style="info" %}
**정답 및 해설**

**정답: D**
- SCP와 SFTP는 SSH(22) 위에서 동작해 암호화된다. 새 포트를 열 필요도 없다.
- A TFTP(UDP 69)는 인증도 암호화도 없다. 장비 이미지 업로드에 흔히 쓰지만 사내망 한정이다.
- B, C는 평문이다. 오늘 `tcpdump`로 직접 확인한 그 문제다.
- 되짚기: 8일차 FTP/TFTP로 설정 백업, 오늘 `scp`.
{% endhint %}

---

## Q9. DNS record types — [5. DNS 서버](lesson-5.md)

A company moves its email to a cloud provider. Which DNS record must be changed?
(회사 메일을 클라우드 업체로 옮긴다. 바꿔야 할 DNS 레코드는?)

- A. A record
- B. CNAME record
- C. MX record
- D. NS record

{% hint style="info" %}
**정답 및 해설**

**정답: C**
- MX(Mail eXchanger)는 "이 도메인의 메일은 이 서버가 받는다"는 뜻이다. 숫자는 우선순위(낮을수록 먼저)다.
- A는 이름에서 IPv4, CNAME은 이름에서 다른 이름, NS는 이 존 전체를 누가 관리하는지다.
- 함께: 발신자 인증을 위한 SPF는 TXT 레코드다. 메일은 DNS 위에 서 있다. → [6. 메일 서버](lesson-6.md)
{% endhint %}

---

## 강의 메모

- Part 1은 VM에서 직접 재현시키면 좋다. 특히 Q5(Serial)와 Q6(localhost 구분선)이 그렇다.
- Q4는 앞의 `tcpdump` 실습을 본 사람만 확실히 맞힌다. 실습을 건너뛰었다면 화면 캡처라도 보여준다.
- Q7의 포트표는 10일차 표 그대로다. 외웠는지 확인하는 용도다.
- 시간이 없으면 Q1, Q3, Q5, Q7만 한다(단계, FTP 두 연결, Serial, 포트).
