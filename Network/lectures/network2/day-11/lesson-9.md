# 9. 오늘의 CCNA

> 상위: [11일차 · 서버 보안](README.md)
> Q1, Q2는 10일차에서 이월된 공유기(NAT) 문제이고, Q3~Q7이 11일차의 서버 보안(ACL, ufw) 문제다.

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-11-017-INS |
| 유형 | INS (점검) |
| 목적 | 11일차 학습 내용을 CCNA 실전형 문제 7문항으로 점검한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 문항과 해설을 다시 검증하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 그림 목록

원본에 그림 프레임 표는 없다.

## 1. 점검 방법

1. 문제를 먼저 각자 풀어 본다.
2. `정답 및 해설` 상자를 보고 함께 확인한다.
3. 해설의 링크로 그날 배운 문서를 되짚는다.

CCNA 실제 시험은 영어이므로 문제는 영문과 한국어를 함께 적었다.

## 2. 점검 항목

### Q1. NAT 용어

관련 문서: [1. 공유기 실습](lesson-1.md)(LEC-N2-11-001-DO), [부록 A](lesson-1-lab-nat-cli.md)(LEC-N2-11-003-MP)

In the output of `show ip nat translations`, the address 192.168.0.100 is the private address of a PC inside the network.
What is this address called?
(`show ip nat translations`에서 안쪽 PC의 사설 주소 192.168.0.100을 부르는 이름은?)

- A. Inside global
- B. Inside local
- C. Outside local
- D. Outside global

{% hint style="info" %}
**정답 및 해설**

**정답: B**
- Inside local은 안쪽 기기의 진짜(사설) 주소다. 안쪽(local)에서 쓰는 이름이다.
- Inside global은 그 기기가 밖에 보이는(공인) 주소다. → `203.0.113.2`
- 외우는 법: inside/outside는 누구의 주소인가(우리 집 기기 / 바깥 서버), local/global은 어디서 보이는 모습인가(안에서 / 밖에서)다.
{% endhint %}

### Q2. 주소를 못 받았다

관련 문서: [1. 공유기 실습](lesson-1.md), [10일차 DNS와 DHCP](../day-10/lesson-10.md)

A PC is cabled to a LAN port on the home router, but it cannot reach any website.
`ipconfig` shows the address 169.254.23.7. What is the most likely cause?
(공유기 LAN 포트에 유선으로 꽂았는데 웹이 안 된다. IP가 169.254.23.7이다. 가장 가능성 높은 원인은?)

- A. The web server is down
- B. The DNS server is down
- C. The laptop did not receive an address from a DHCP server
- D. The router's NAT translation table is full

{% hint style="info" %}
**정답 및 해설**

**정답: C**
- `169.254.x.x`는 APIPA다. DHCP 응답을 못 받으면 스스로 붙이는 주소이며 "고장 신호"다(2일차, 8일차).
- A 또는 B가 원인이라면 IP는 정상(`192.168.0.x`)이었을 것이다. `169.254`는 주소를 못 받았다는 신호다.
- 흔한 원인: 공유기 DHCP Disabled, 케이블이 WAN 포트에 꽂힘, 공유기 전원.
- 진단 순서: 연결 → 주소(DHCP) → 이름(DNS). 가까운 곳부터 본다.
{% endhint %}

### Q3. 암묵적 deny

관련 문서: [4. ACL 표준](lesson-4.md)(LEC-N2-11-007-DO)

A router is configured with only this one line, applied outbound on `g0/0`:
`access-list 10 deny host 192.168.20.10`
What happens to traffic from 192.168.20.11 leaving `g0/0`?
(이 한 줄만 적용했다. 192.168.20.11의 트래픽은 어떻게 되나?)

- A. It is permitted, because the ACL only denies .20.10
- B. It is denied by the implicit deny any at the end of the ACL
- C. It is permitted, but logged
- D. The ACL is invalid and is ignored

{% hint style="info" %}
**정답 및 해설**

**정답: B**
- 모든 ACL 끝에는 보이지 않는 `deny any`가 있다. 명시적으로 `permit`하지 않은 것은 전부 거부된다.
- 고치려면 `access-list 10 permit any`를 뒤에 추가한다.
- 실습에서 개발팀 PC까지 끊겼던 장면이 바로 이것이다. → [실습. 표준 ACL](lesson-4-lab-standard-acl.md)(LEC-N2-11-008-MP) 5-C
- 외우는 법: ACL은 화이트리스트다. 허용을 적지 않으면 아무도 지나가지 못한다.
{% endhint %}

### Q4. ACL 배치

관련 문서: [4. ACL 표준](lesson-4.md), [5. ACL 확장](lesson-5.md)(LEC-N2-11-009-DO)

Where should a standard ACL be placed, and why?
(표준 ACL은 어디에 두어야 하며, 그 이유는?)

- A. Closest to the source, because it is processed faster
- B. Closest to the destination, because it only matches the source address
- C. Anywhere — placement does not matter for standard ACLs
- D. On every interface of every router in the path

{% hint style="info" %}
**정답 및 해설**

**정답: B**
- 표준은 출발지만 본다. 출발지 가까이 두면 그 PC의 모든 통신이 막힌다(과잉 차단).
- 확장은 목적지와 포트까지 본다. 출발지 가까이 두어 일찍 버리는 것이 효율적이다.
- 한 줄 암기: 표준은 목적지 가까이, 확장은 출발지 가까이.
{% endhint %}

### Q5. 확장 ACL 문장

관련 문서: [5. ACL 확장](lesson-5.md), [10일차 포트](../day-10/lesson-8.md)

You must allow only host 192.168.20.11 to reach the web service on server 192.168.10.100.
Which line is correct?
(개발 PC 한 대만 서버의 웹에 접근하게 하려면?)

- A. `access-list 110 permit tcp host 192.168.20.11 host 192.168.10.100 eq 22`
- B. `access-list 10 permit host 192.168.20.11`
- C. `access-list 110 permit tcp host 192.168.20.11 host 192.168.10.100 eq 80`
- D. `access-list 110 permit tcp host 192.168.10.100 host 192.168.20.11 eq 80`

{% hint style="info" %}
**정답 및 해설**

**정답: C**
- 웹은 80번이다(A의 22는 SSH). 10일차 포트표를 회수한다.
- B는 표준(10번)이라 목적지와 포트를 쓸 수 없다.
- D는 출발지와 목적지가 뒤바뀌었다. 서버가 PC에 접속하는 규칙이 되어 버린다.
- 순서: `permit tcp <출발지> <목적지> eq <포트>`. 포트는 목적지 쪽에 붙는다.
{% endhint %}

### Q6. ufw 함정

관련 문서: [6. 리눅스 방화벽 ufw](lesson-6.md)(LEC-N2-11-011-DO)

You are connected to a remote Ubuntu server over SSH. You run `sudo ufw enable` without any other rule.
What is the result?
(SSH로 원격 접속 중인데 규칙 없이 `ufw enable`을 실행했다. 결과는?)

- A. Nothing changes until the server reboots
- B. The SSH session is dropped and you cannot reconnect
- C. ufw automatically allows port 22 to protect you
- D. Only outbound traffic is blocked

{% hint style="info" %}
**정답 및 해설**

**정답: B** (원본 정답을 유지한다. 아래 NOTE를 함께 읽는다.)
- ufw 기본 정책은 `deny (incoming)`이며 SSH도 "들어오는 것"이다.
- 반드시 `sudo ufw allow 22/tcp`를 먼저, 그다음 `sudo ufw enable`을 입력한다.
- 복구: 콘솔(VirtualBox 창)로 직접 로그인한 뒤 `sudo ufw disable`. 클라우드 서버라면 복구가 매우 어렵다.
- C는 오답이지만 위험한 오해다. ufw는 알아서 지켜 주지 않는다.

NOTE: 이미 맺어진 SSH 연결은 연결 추적 때문에 유지되는 경우가 있다. 그러나 새 SSH 접속은 막혀 재접속할 수 없다. 이 문항의 B는 "재접속할 수 없게 된다"는 뜻으로 읽는다.
{% endhint %}

### Q7. 진단

관련 문서: [8. 오늘 정리 · 안 될 때 점검](lesson-8.md)(LEC-N2-11-015-TS)

On a server, `curl localhost:8000` succeeds, but a PC on the same LAN gets a timeout.
What should you check first?
(서버 안에서는 되는데 같은 랜의 PC에서는 타임아웃이다. 가장 먼저 볼 것은?)

- A. The web service configuration file
- B. The DNS server
- C. The host firewall (ufw) rules
- D. Reinstall the web server

{% hint style="info" %}
**정답 및 해설**

**정답: C**
- ①(LISTEN)과 ②(로컬 접속)를 통과했으므로 서비스는 정상이다. 밖에서만 안 되면 ③ 방화벽이 가장 유력하다.
- 타임아웃은 조용히 버려짐(`deny`)의 전형적인 증상이다. 반대로 `Connection refused`면 서비스 쪽을 본다.
- 네 단계 좁히기: ① `ss -tuln` → ② `curl localhost` → ③ `ufw status numbered` → ④ `ip a`, `ping`
{% endhint %}

## 3. 합격 기준

| 항목 | 기준 |
|---|---|
| 정답 수 | 7문항 중 6문항 이상이면 합격이다. 5문항 이하면 해당 문항의 관련 문서를 다시 읽는다 |
