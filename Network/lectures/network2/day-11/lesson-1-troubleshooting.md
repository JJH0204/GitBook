# 공유기 실습 문제 해결

> 상위: [11일차 · 서버 보안](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-11-004-TS |
| 유형 | TS (문제 해결) |
| 목적 | 공유기 실습(유선)에서 막힐 때 증상별 원인과 조치를 찾는다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 장비에서 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 증상과 가능 원인

| 증상 | 가능 원인 | 확인 | 시정 조치 |
|---|---|---|---|
| PC가 `169.254.x.x`다 | 공유기 DHCP가 꺼져 있다. 케이블이 `Internet`(WAN) 포트에 꽂혀 있다 | GUI의 DHCP 상태, 케이블 위치 | DHCP `Enabled`로 두고 `Save Settings`. 케이블을 `Ethernet 1~4`(LAN)에 연결한다 |
| IP는 받았는데 `ping 198.51.100.8`이 실패한다 | 공유기 `Internet Setup`(Static, GW `203.0.113.1`)이 틀렸다. `Save Settings`를 누르지 않았다. ISP 인터페이스가 `shutdown`이다 | GUI 값, ISP에서 `show ip interface brief` | GUI 값을 다시 입력하고 저장한다. ISP에서 `no shutdown` |
| IP로는 되는데 이름으로 안 된다 | DHCP의 `Static DNS 1`이 비어 있다. Internet 서버의 DNS가 `Off`다 | GUI의 Static DNS 1, 서버 `Services` > `DNS` | `Static DNS 1`에 `198.51.100.8`을 입력하고 서버 DNS를 `On`으로 둔다. 클라이언트가 DHCP를 다시 받게 한다 |
| 포트포워딩이 먹지 않는다 | 대상 서버가 DHCP 주소다. `Enabled`를 체크하지 않았다 | HomeServer의 IP 설정, 규칙의 `Enabled` | HomeServer를 고정 IP로 바꾸고 `Enabled` 체크 후 `Save` |

## 2. 격리 절차

1. PC에서 `ipconfig`를 입력한다. `169.254.x.x`면 DHCP 문제다.
2. PC에서 게이트웨이 `192.168.0.1`로 `ping`한다. 실패하면 케이블 위치와 공유기 LAN 설정을 본다.
3. `ping 198.51.100.8`을 입력한다. 실패하면 공유기 WAN 설정과 ISP를 본다.
4. `ping www.student.test`를 입력한다. IP로는 되는데 이름만 실패하면 DNS 설정을 본다.

진단 순서는 연결, 주소(DHCP), 이름(DNS)이다. 가까운 곳부터 점검한다.

## 3. 시정 조치 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1-lab-router.md](lesson-1-lab-router.md) | LEC-N2-11-002-MP | 공유기 실습 |
| [lesson-1.md](lesson-1.md) | LEC-N2-11-001-DO | 1. 공유기 실습 (개념) |

{% hint style="info" %}
NOTE: WRT300N의 GUI 메뉴 이름은 Packet Tracer 버전마다 다르다. 메뉴를 찾지 못하면 수업 전 리허설 기록을 본다.
{% endhint %}

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 실습 중 내가 막혔던 증상과 어떻게 풀었는지 적어 본다.
- [ ] PC가 `169.254.x.x`를 받았을 때 왜 웹 서버나 DNS가 원인이 아닌지 적어 본다.
