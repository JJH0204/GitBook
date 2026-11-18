# 6. 서버 설정 실습 — 회사망에 서비스를 올린다

> 상위: [8일차 · 네트워크 장비에서의 서버 설정](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N1-08-007-MP |
| 목적 | 7일차 회사망에 서버 한 대를 추가하고 스위치 원격 접속(SSH), DHCP(라우터, 서버 릴레이), DNS, FTP·SNMP, 포트 보안을 순서대로 구성해 확인한다 |
| 적용 대상 | Cisco Packet Tracer, 7일차 파일 `7일차_스위칭.pkt`(R1 1대, SW1·SW2, PC 4대, SW1–SW2 EtherChannel `Po1`) + Server 1대 |
| 소요 시간 | 필수 구역(A, B, D, F) 약 90분, 선택 구역(C, E)과 무선·IPv6 추가 |
| 확인 상태 | 미검증 (원본 강의 노트를 옮긴 것이며 Packet Tracer에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 "왜 그렇게 하는지, 무엇을 봐야 하는지"를 설명하는 절차 문서다. 실습 중에는 입력 명령 전체가 있는 [8일차 실습 명령어 대본](commands.md)을 화면에 띄운다. 무선·IPv6(대본 STEP 7)는 [무선랜과 IPv6 맛보기 실습](lesson-5-lab.md)에서 다룬다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1.md](lesson-1.md) | LEC-N1-08-001-DO | 1. 원격 접속 |
| [lesson-2.md](lesson-2.md) | LEC-N1-08-002-DO | 2. DHCP와 DNS |
| [lesson-3.md](lesson-3.md) | LEC-N1-08-003-DO | 3. SNMP, Proxy, FTP |
| [lesson-4.md](lesson-4.md) | LEC-N1-08-004-DO | 4. 포트 보안 |
| [lesson-5-lab.md](lesson-5-lab.md) | LEC-N1-08-006-MP | 무선랜과 IPv6 맛보기 실습 |
| [lesson-6-troubleshooting.md](lesson-6-troubleshooting.md) | LEC-N1-08-008-TS | 8일차 실습 문제 해결 |
| [commands.md](commands.md) | LEC-N1-08-010-REF | 0. 8일차 실습 명령어 |
| [4_스위칭_실습](../day-07/lesson-4.md) | | 7일차 회사망 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Packet Tracer | 7일차와 같은 버전 | 서버 DHCP 다중 풀, MIB Browser 화면은 버전마다 다르다. 수업 전에 리허설한다 |
| 2 | `7일차_스위칭.pkt` | 7일차 회사망 | 없으면 [대본 부록 A](commands.md)의 복붙 블록으로 5분 복구한다 |
| 3 | Server | 1대 | 오늘 새로 놓는 장비 |
| 4 | Laptop | 1대 | 구역 F(포트 보안)의 침입자 역 |

토폴로지는 다음과 같다.

```
                        [R1]  .10.254 / .20.254
                         │    DHCP 풀 → (구역 C) helper-address
                         │ trunk
  PC0 ──Fa0/1──┐         │         ┌──Fa0/1── PC2
  PC1 ──Fa0/2──┤       [SW1]═Po1═[SW2]       ├──Fa0/2── PC3
  Server0 ─Fa0/3┘   관리 IP .10.253          └──Fa0/3── (AP)
  192.168.10.10 — DNS · 웹 · FTP · (구역 C) DHCP
```

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 7일차 파일 `7일차_스위칭.pkt`를 덮어쓰지 않는다. 시작 전에 `8일차_서버.pkt`로 다른 이름 저장한다.
{% endhint %}

{% hint style="info" %}
NOTE: 실습 계정 비밀번호는 모두 `<password>`로 표기한다. 실제 값은 강사의 안내를 따른다. 문서에 실제 비밀번호를 적지 않는다.
{% endhint %}

## 4. 준비

실습 흐름은 다음과 같다.

| 구역 | 무엇 | 먼저 볼 실패 | 필수 | 시간 |
|---|---|---|:---:|---|
| 준비 | 7일차 파일 + Server0 | 없음 | 필수 | 10분 |
| A | 원격 접속: SVI, Telnet, SSH | 스위치에 IP가 없다, 비밀번호 없는 VTY | 필수 | 25분 |
| B | 라우터 DHCP | `169.254` | 필수 | 20분 |
| C | 서버 DHCP + 릴레이 | VLAN 20만 못 받는다 | 고급 | 20분 |
| D | DNS, 웹 | 이름으로는 모른다 | 필수 | 15분 |
| E | FTP, SNMP | 없음 | 선택 | 10분 |
| F | 포트 보안 | 침입자가 그냥 붙는다 | 필수 | 20분 |

시간이 부족하면 필수(A, B, D, F)만 진행한다. 필수만 90분이다. C(릴레이)는 시간이 없으면 개념 설명만 한다. 그 경우 DHCP는 R1에 그대로 두어야 구역 D의 DNS 주소가 자동으로 전달된다.

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | `7일차_스위칭.pkt`를 열고 `8일차_서버.pkt`로 다른 이름 저장한다 | 제목이 바뀐다 |
| 2 | Server를 배치하고 SW1 Fa0/3에 다이렉트 케이블로 연결한다 | 링크 점이 초록색이다 |
| 3 | Server0의 `Desktop > IP Configuration`에서 Static `192.168.10.10`, `255.255.255.0`, 게이트웨이 `192.168.10.254`, DNS `192.168.10.10`을 입력한다 | 값이 저장된다 |
| 4 | SW1에서 `interface fa0/3`을 `switchport mode access`, `switchport access vlan 10`, `spanning-tree portfast`로 설정한다 | `show vlan brief`에서 Fa0/3이 VLAN 10이다 |
| 5 | PC1에서 `ping 192.168.10.10`, `ping 192.168.10.2`를 입력한다 | 두 ping 모두 성공한다 |
| 6 | 양 스위치에서 `show etherchannel summary`를 입력한다 | `Po1(SU)`가 보인다 |

## 5. 절차

### A. 원격 접속 — "스위치의 주소는?"

흐름은 IP 없음, SVI로 IP 부여, VTY 잠김, Telnet 열기, SSH로 갈아타기 순서다.

1. (5-A-01) PC0의 `Command Prompt`에서 `telnet 192.168.10.253`을 입력한다. → 결과: 응답이 없다. L2 스위치는 원래 IP가 없다.
2. (5-A-02) SW1 CLI에서 `configure terminal`, `interface vlan 10`, `ip address 192.168.10.253 255.255.255.0`, `no shutdown`, `exit`를 차례로 입력한다. → 결과: SVI가 생성된다.
3. (5-A-03) `ip default-gateway 192.168.10.254`를 입력하고 `end`를 입력한다. → 결과: 오류 없이 끝난다.
4. (5-A-04) PC0에서 `ping 192.168.10.253`을 입력한다. → 결과: 응답이 온다.
5. (5-A-05) PC0에서 `telnet 192.168.10.253`을 입력한다. → 결과: `Password required, but none set`이 나오고 끊긴다. VTY는 비밀번호가 없으면 잠긴다.
6. (5-A-06) SW1 CLI에서 `enable secret <password>`, `line vty 0 4`, `password <password>`, `login`, `end`를 입력한다. → 결과: Telnet용 비밀번호가 설정된다. (`enable secret`과 VTY 비밀번호는 별개의 값이다.)
7. (5-A-07) PC0에서 `telnet 192.168.10.253`을 입력하고 VTY 비밀번호를 입력한다. → 결과: `SW1>`가 나온다.
8. (5-A-08) `enable`을 입력하고 enable 비밀번호를 입력한다. → 결과: `SW1#`가 나온다. 스위치 앞에 가지 않고 설정을 볼 수 있다.
9. (5-A-09) `show vlan brief`를 입력한 뒤 `exit`를 입력한다.

{% hint style="danger" %}
WARNING: 5-A-07의 비밀번호는 평문으로 흘러갔다. 엽서처럼 누구나 읽을 수 있다. 이어서 SSH로 갈아탄다.
{% endhint %}

10. (5-A-10) SW1 CLI에서 `configure terminal`을 입력한 뒤 `crypto key generate rsa general-keys modulus 1024`를 일부러 먼저 입력한다. → 결과: `% Please define a domain-name first.`가 나온다. 키 이름표(이름 + 도메인)가 없기 때문이다.
11. (5-A-11) `ip domain-name student.local`을 입력한다. (`hostname SW1`은 7일차에 이미 설정되어 있다.)
12. (5-A-12) `crypto key generate rsa general-keys modulus 1024`를 다시 입력한다. → 결과: 키가 생성된다.
13. (5-A-13) `ip ssh version 2`를 입력한다.
14. (5-A-14) `username admin secret <password>`를 입력한다.
15. (5-A-15) `line vty 0 4`에서 `login local`과 `transport input ssh`를 입력하고 `end`를 입력한다.
16. (5-A-16) `copy running-config startup-config`를 입력한다. → 결과: 저장된다.
17. (5-A-17) PC1(VLAN 20)에서 `telnet 192.168.10.253`을 입력한다. → 결과: 거절된다.
18. (5-A-18) PC1에서 `ssh -l admin 192.168.10.253`(소문자 L)을 입력하고 비밀번호를 입력한다. → 결과: `SW1>`가 나온다. 다른 VLAN인데 접속된 것은 스위치의 `ip default-gateway` 덕분이다.
19. (5-A-19) `enable`, enable 비밀번호, `show interfaces trunk`, `exit`를 차례로 입력한다.
20. (선택) (5-A-20) SW1에서 `no ip default-gateway`를 입력하고 PC0, PC1에서 SSH를 시도한다. → 결과: PC0(VLAN 10)은 되고 PC1(VLAN 20)은 안 된다. 확인 후 `ip default-gateway 192.168.10.254`를 다시 입력한다.

오늘의 확인 질문: "PC1은 다른 VLAN인데 어떻게 스위치에 들어갔을까?" → 스위치도 PC처럼 게이트웨이가 필요하다.

### B. 라우터 DHCP — "169.254는 고장 신호"

1. (5-B-01) PC2의 `Desktop > IP Configuration`에서 `DHCP`를 선택한다. → 결과: `DHCP failed. APIPA is being used.` 문구가 나오고 IP가 `169.254.x.x`로 잡힌다(문구는 버전에 따라 조금 다르다). 2일차에서 배운 고장 신호다.
2. (5-B-02) R1 CLI에서 `configure terminal`을 입력한다.
3. (5-B-03) 제외 주소 4줄을 풀보다 먼저 입력한다: `ip dhcp excluded-address 192.168.10.1 192.168.10.10`, `ip dhcp excluded-address 192.168.10.250 192.168.10.254`, `ip dhcp excluded-address 192.168.20.1 192.168.20.10`, `ip dhcp excluded-address 192.168.20.250 192.168.20.254`. → 결과: 서버(.10), 게이트웨이(.254), 스위치(.253)가 보호된다.
4. (5-B-04) `ip dhcp pool VLAN10`에서 `network 192.168.10.0 255.255.255.0`, `default-router 192.168.10.254`, `dns-server 192.168.10.10`, `exit`를 입력한다.
5. (5-B-05) `ip dhcp pool VLAN20`에서 `network 192.168.20.0 255.255.255.0`, `default-router 192.168.20.254`, `dns-server 192.168.10.10`, `end`를 입력한다. → 결과: VLAN마다 풀이 하나씩 생긴다. `default-router`는 VLAN마다 다르다.
6. (5-B-06) PC0부터 PC3까지 `IP Configuration`에서 Static을 눌렀다가 다시 `DHCP`를 선택한다. → 결과: PC0, PC2는 `192.168.10.11`부터, PC1, PC3은 `192.168.20.11`부터 받고, DNS는 모두 `192.168.10.10`이다.
7. (5-B-07) R1에서 `show ip dhcp binding`을 입력한다. → 결과: IP와 MAC 목록 4줄이 보인다.

오늘의 핵심 질문: "DHCP 요청은 브로드캐스트인데, VLAN 20 PC는 어떻게 R1에게 받았을까?" → R1의 `g0/0.20`이 VLAN 20 동네 안에 있어서 외침이 들린다. 서버가 다른 동네에 있으면 구역 C가 필요하다.

### C. DHCP 릴레이 (고급) — "원칙과 예외"

라우터의 풀을 지우고 Server0(VLAN 10)이 배급을 맡는다. 풀은 VLAN마다 하나이고 시작 주소는 `.101`이다.

1. (5-C-01) R1에서 `configure terminal`, `no ip dhcp pool VLAN10`, `no ip dhcp pool VLAN20`, `end`를 입력한다. → 결과: 라우터 DHCP가 꺼진다.
2. (5-C-02) Server0의 `Services > DHCP`에서 Service를 `On`으로 한다.
3. (5-C-03) `serverPool`을 VLAN 10용으로 고치고 `Save`한다: 게이트웨이 `192.168.10.254`, DNS `192.168.10.10`, Start IP `192.168.10.101`, 마스크 `255.255.255.0`, 최대 사용자 `50`.
4. (5-C-04) Pool Name `VLAN20`으로 새 풀을 `Add`한다: 게이트웨이 `192.168.20.254`, DNS `192.168.10.10`, Start IP `192.168.20.101`, 마스크 `255.255.255.0`, 최대 사용자 `50`. 시작 주소를 `.101`로 둔 이유는 라우터가 준 `.11`과 구분되어 서버에서 받은 것이 한눈에 보이기 때문이다.
5. (5-C-05) PC2(VLAN 10)와 PC3(VLAN 20)에서 DHCP를 재요청한다. → 결과: PC2는 `192.168.10.101`을 받고, PC3은 `169.254.x.x`를 받는다. 외침이 R1에서 멈추기 때문이다.
6. (5-C-06) R1에서 `configure terminal`, `interface g0/0.20`, `ip helper-address 192.168.10.10`, `end`를 입력한다. → 결과: 오류 없이 끝난다.

{% hint style="warning" %}
CAUTION: `ip helper-address`는 클라이언트 쪽(`g0/0.20`)에 입력한다. 서버 쪽(`g0/0.10`)에 입력하면 효과가 없다.
{% endhint %}

7. (5-C-07) PC3, PC1, PC0에서 DHCP를 재요청한다. → 결과: PC3, PC1은 `192.168.20.101`부터, PC0은 `192.168.10.10x`를 받는다.
8. (5-C-08) R1에서 `show ip dhcp binding`을 입력한다. → 결과: 목록이 비어 있다. 서버가 준 것이므로 라우터에는 기록이 없다. R1은 배급소에서 우체국이 되었다.

### D. DNS — "IP는 되는데 이름은 안 된다"

1. (5-D-01) PC0에서 `ping 192.168.10.10`을 입력한다. → 결과: 성공한다.
2. (5-D-02) PC0에서 `ping www.student.local`을 입력한다. → 결과: `Ping request could not find host ...`가 나온다. 3일차의 "IP는 되는데 이름은 안 된다 → DNS 문제"다.
3. (5-D-03) Server0의 `Services > DNS`에서 DNS Service를 `On`으로 한다.
4. (5-D-04) Name `www.student.local`, Type `A Record`, Address `192.168.10.10`을 `Add`한다.
5. (5-D-05) Name `sw1.student.local`, Type `A Record`, Address `192.168.10.253`을 `Add`한다.
6. (5-D-06) PC0, PC3에서 `ping www.student.local`, `ping sw1.student.local`을 입력한다. → 결과: 이름이 IP로 바뀌어 응답이 온다. PC의 DNS 서버 주소는 DHCP가 이미 주었다.
7. (5-D-07) `Desktop > Web Browser`에서 `http://www.student.local`을 연다. → 결과: 서버의 웹 페이지가 열린다(PT 서버는 HTTP가 기본으로 켜져 있다).

4일차부터 입력한 `no ip domain-lookup`의 의미는 [대본 부록 B](commands.md)의 실험으로 확인할 수 있다.

### E. FTP와 SNMP (선택)

1. (5-E-01) PC0에서 `ftp 192.168.10.10`을 입력하고 Username `cisco`, Password `<password>`를 입력한다(PT 서버 기본 계정). → 결과: `ftp>` 프롬프트가 나온다.
2. (5-E-02) `dir`, `quit`을 차례로 입력한다. → 결과: 서버의 파일 목록이 나온다. 로그인이 평문이므로 Telnet과 같은 운명이다. 실무는 SFTP를 쓴다.
3. (5-E-03) R1에서 `configure terminal`, `snmp-server community public ro`, `end`를 입력한다. → 결과: SNMP 에이전트가 켜진다(읽기 전용).
4. (5-E-04) PC0의 `Desktop > MIB Browser`에서 `Advanced`를 열고 Address `192.168.10.254`, Read Community `public`, Version `v2`를 입력한다.
5. (5-E-05) MIB 트리에서 `system > sysName`을 선택하고 Operation `Get`, `GO`를 누른다. → 결과: `R1`이 나온다. 로그인 없이 장비 정보를 읽었다. 커뮤니티 문자열이 곧 비밀번호다.

### F. 포트 보안 — "사원증 출입문"

4컷으로 진행한다: 주인 등록, 침입, 범인 찾기, 복구.

1. (5-F-01) SW1 CLI에서 `configure terminal`, `interface fa0/1`을 입력한다.
2. (5-F-02) `switchport port-security`, `switchport port-security maximum 1`, `switchport port-security mac-address sticky`, `switchport port-security violation shutdown`을 차례로 입력하고 `end`를 입력한다. → 결과: 오류 없이 끝난다. (`Command rejected`가 나오면 포트가 액세스 모드가 아니다. `switchport mode access`를 먼저 입력한다.)
3. (5-F-03) PC0에서 `ping 192.168.10.254`를 입력한다. → 결과: 응답이 온다. 한 번 통신해야 sticky가 MAC을 배운다.
4. (5-F-04) SW1에서 `show port-security interface fa0/1`을 입력한다. → 결과: `Sticky MAC Addresses : 1`이다.
5. (5-F-05) `show running-config`를 입력한다. → 결과: `fa0/1` 아래에 sticky 줄과 PC0의 MAC이 적혀 있다.
6. (5-F-06) Laptop 1대를 배치하고 IP를 `DHCP`로 둔다.
7. (5-F-07) PC0의 선을 삭제하고 Laptop을 SW1 Fa0/1에 연결한다. → 결과: Laptop이 DHCP를 요청하는 순간 링크가 빨간색으로 바뀐다.
8. (5-F-08) SW1에서 `show port-security interface fa0/1`을 입력한다. → 결과: `Port Status`가 `Secure-shutdown`, `Last Source Address:Vlan`이 Laptop의 MAC, `Security Violation Count`가 1이다.
9. (5-F-09) `show interfaces fa0/1`을 입력한다. → 결과: `down (err-disabled)`가 보인다.
10. (5-F-10) Laptop의 `Config > FastEthernet0`에 표시된 MAC을 5-F-08의 `Last Source Address`와 비교한다. → 결과: 일치한다.

{% hint style="danger" %}
WARNING: 복구는 침입 기기를 먼저 치운 뒤에 한다. Laptop을 꽂은 채 `no shutdown`을 하면 즉시 다시 꺼진다.
{% endhint %}

11. (5-F-11) Laptop의 선을 삭제하고 PC0를 SW1 Fa0/1에 다시 연결한다.
12. (5-F-12) SW1에서 `configure terminal`, `interface fa0/1`, `shutdown`, `no shutdown`, `end`를 차례로 입력한다. → 결과: 링크가 초록색으로 돌아온다.
13. (5-F-13) PC0에서 `ping 192.168.10.254`를 입력한다. → 결과: 응답이 온다.
14. (5-F-14) 모든 장비에서 `copy running-config startup-config`를 입력하고 파일을 `Ctrl + S`로 저장한다.

오늘의 확인 질문: 오늘 만든 DHCP가 침입자에게도 IP를 줄 뻔했다. 편리함과 보안은 한 쌍이다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | PC0, PC1에서 `ssh -l admin 192.168.10.253` | 접속된다. `telnet`은 거절된다 | 다른 VLAN(PC1)에서도 SSH 성공 |
| 2 | PC 4대의 `IP Configuration` | 풀대로 IP, 게이트웨이, DNS를 받았다 | 모두 `.11` 대(구역 C 후에는 `.101` 대) 주소 |
| 3 | 구역 C 후 R1의 `show ip dhcp binding` | 비어 있다 | 서버가 준 주소로 VLAN 10, 20 PC가 모두 받았다 |
| 4 | 두 VLAN의 PC에서 `ping www.student.local` | 응답 | 이름이 풀리고 웹 페이지가 열린다 |
| 5 | 침입 시 SW1 `show port-security interface fa0/1` | `Secure-shutdown` | 범인 MAC이 확인된다 |
| 6 | 복구 후 PC0 `ping 192.168.10.254` | 응답 | 정상 통신 |

## 7. 복구

1. (7-01) 변경을 남기지 않으려면 `8일차_서버.pkt`를 저장하지 않고 닫는다. 원본 `7일차_스위칭.pkt`는 그대로 남는다.
2. (7-02) 포트 보안을 해제하려면 SW1 `interface fa0/1`에서 `no switchport port-security`를 입력한다.
3. (7-03) 스위치 관리 IP를 지우려면 `no interface vlan 10`과 `no ip default-gateway`를 입력한다.
4. (7-04) 실습 중 막히면 [8일차 실습 문제 해결](lesson-6-troubleshooting.md)을 본다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 6. 서버 설정 실습과 대본 STEP 1~6을 MP로 재작성. 무선·IPv6는 lesson-5-lab.md로, 막힘 해결은 lesson-6-troubleshooting.md로 분리 |
