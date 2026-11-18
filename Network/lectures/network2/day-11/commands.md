# 0. 11일차 실습 명령어 — 수업 흐름 그대로 (이어치기 대본)

> 상위: [11일차 · 서버 보안](README.md) · 개념은 [1. 공유기 실습](lesson-1.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-11-018-REF |
| 유형 | REF (명령·표) |
| 목적 | 11일차 실습의 순서, 공통 주소, 입력 위치 표기, 명령을 한 장에서 찾는다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 장비에서 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본은 실습 절차 전체를 이 페이지에 담고 있었다. 한 파일 한 유형 원칙에 따라 절차는 MP 문서로 분리했다. 이 페이지는 실습 중 화면에 띄워 두는 명령 참조다. 단계별 대본은 아래 "실습별 문서"의 MP를 연다. 무선랜은 다루지 않는다.
{% endhint %}

## 1. 실습별 문서

| 순서 | 실습 | 환경 | Task ID | 문서 | 시간 |
|---|---|---|---|---|---|
| STEP 1, 2 | 공유기, NAT 관찰, 포트포워딩(선택) | PT(유선) | LEC-N2-11-002-MP | [공유기 실습](lesson-1-lab-router.md) | 약 45분 |
| 부록 A | 공유기 속을 시스코 CLI로(NAT Overload) | PT | LEC-N2-11-003-MP | [부록 A](lesson-1-lab-nat-cli.md) | 약 20분 |
| STEP 3 | 지금 내 서버는 열려 있다 | Ubuntu VM | LEC-N2-11-006-MP | [옆자리에서 내 서버 두드리기](lesson-3-lab-exposure.md) | 약 10분 |
| STEP 4 | 표준 ACL | PT | LEC-N2-11-008-MP | [표준 ACL 실습](lesson-4-lab-standard-acl.md) | 약 20분 |
| STEP 5 | 확장 ACL | PT | LEC-N2-11-010-MP | [확장 ACL 실습](lesson-5-lab-extended-acl.md) | 약 20분 |
| STEP 6 | ufw | Ubuntu VM | LEC-N2-11-012-MP | [ufw 실습](lesson-6-lab-ufw.md) | 약 25분 |
| STEP 7 | 최소 개방 설계 | Ubuntu VM | LEC-N2-11-014-MP | [규칙표 실습](lesson-7-lab-rules.md) | 약 10분 |
| 마무리 | 12일차로 넘길 상태 만들기 | Ubuntu VM | LEC-N2-11-016-MP | [마무리](lesson-8-lab-closing.md) | 약 5분 |
| 부록 B | 안 될 때 점검 | - | LEC-N2-11-004-TS, LEC-N2-11-015-TS | [공유기 문제 해결](lesson-1-troubleshooting.md), [8. 정리·안 될 때 점검](lesson-8.md) | - |

## 2. 읽는 법

- 마우스(Packet Tracer GUI), 라우터 CLI, PC의 `Command Prompt`, VM 터미널, 옆자리 Windows를 문서에서 구분해 적는다.
- 코드 블록의 `#` 뒤 글자는 설명이다. 입력하지 않아도 된다.
- 위에서 아래로 그대로 따라 입력한다. 실습 중 화면에 띄워 두거나 인쇄해 나눠 준다.

## 3. 공통 주소

**공유기 실습(STEP 1, 2)**

| 장비 | 주소 | 비고 |
|---|---|---|
| HomeRouter LAN | `192.168.0.1/24` | DHCP `192.168.0.100`부터 50개 |
| HomeRouter WAN | `203.0.113.2/30` | |
| ISP G0/0, G0/1 | `203.0.113.1/30`, `198.51.100.1/24` | |
| Internet 서버 | `198.51.100.8/24` | DNS `www.student.test`, HTTP |
| HomeServer (선택) | `192.168.0.10` 고정 | 포트포워딩 대상 |

**ACL 실습(STEP 4, 5)**

| 장비 | 주소 |
|---|---|
| R1 `g0/0`(서버망) | `192.168.10.254/24` |
| R1 `g0/1`(사용자망) | `192.168.20.254/24` |
| Server0 | `192.168.10.100`, GW `192.168.10.254` |
| PC_인사 | `192.168.20.10`, GW `192.168.20.254` |
| PC_개발 | `192.168.20.11`, GW `192.168.20.254` |

## 4. 명령 사전 (11일차에 새로 나온 것)

**시스코 라우터**

| 무엇 | 명령 | 모드 |
|---|---|---|
| 표준 ACL 만들기 | `access-list 10 deny host 192.168.20.10` | `(config)#` |
| 나머지 허용 | `access-list 10 permit any` | `(config)#` |
| 확장 ACL 만들기 | `access-list 110 permit tcp host <출발지> host <목적지> eq 22` | `(config)#` |
| 나머지 IP 허용 | `access-list 110 permit ip any any` | `(config)#` |
| 인터페이스에 적용 | `ip access-group <번호> in` 또는 `out` | `(config-if)#` |
| 인터페이스에서 떼기 | `no ip access-group <번호> in` 또는 `out` | `(config-if)#` |
| ACL 확인(match 수) | `show access-lists` | `#` |
| 적용 위치 확인 | `show ip interface g0/0` | `#` |
| ACL 삭제(번호 전체) | `no access-list 10` | `(config)#` |
| NAT 안쪽, 바깥쪽 지정 | `ip nat inside`, `ip nat outside` | `(config-if)#` |
| PAT | `ip nat inside source list 1 interface g0/1 overload` | `(config)#` |
| 포트포워딩(Static NAT) | `ip nat inside source static tcp 192.168.0.10 80 interface g0/1 80` | `(config)#` |
| 변환표 확인 | `show ip nat translations` | `#` |

**리눅스 ufw와 확인 명령**

| 무엇 | 명령 |
|---|---|
| 주소 확인 | `ip a` |
| 열린 포트 세기(공격 표면) | `ss -tuln` |
| 방화벽 상태 | `sudo ufw status`, `sudo ufw status verbose`, `sudo ufw status numbered` |
| 22번 열기(먼저) | `sudo ufw allow 22/tcp` |
| 켜기 | `sudo ufw enable` |
| 끄기 | `sudo ufw disable` |
| 포트 열기 | `sudo ufw allow 8000/tcp` |
| 특정 PC에게만 열기 | `sudo ufw allow from <IP> to any port 8000` |
| 규칙 삭제 | `sudo ufw delete <번호>` |
| 포트 범위 | `sudo ufw allow 40000:40010/tcp` |
| 로그 켜기, 보기 | `sudo ufw logging on`, `sudo tail -f /var/log/ufw.log` |
| 서비스 끄기 | `sudo systemctl disable --now vsftpd` |
| 서비스 켜기 | `sudo systemctl enable --now vsftpd` |
| 로컬 접속 확인 | `curl localhost:8000` |
| 연습용 웹서버 | `python3 -m http.server 8000` |

{% hint style="danger" %}
WARNING: `sudo ufw enable` 전에 `sudo ufw allow 22/tcp`를 먼저 입력한다. 이미 막혔다면 VirtualBox 창으로 로그인해 `sudo ufw disable`을 입력한다.
{% endhint %}

## 5. 안 될 때 점검: 네 단계로 좁히기

| 단계 | 확인 | 명령 | 통과 못 하면 |
|---|---|---|---|
| ① | 서비스가 떠 있나 | `ss -tuln \| grep <포트>` | `LISTEN`이 없으면 서비스 문제 |
| ② | 안에서는 되나 | `curl localhost:<포트>` | 실패하면 서비스 설정 |
| ③ | 방화벽이 막나 | `sudo ufw status numbered` | 규칙이 없으면 `ufw allow` |
| ④ | 길이 맞나 | `ip a`, `ping <상대>` | 주소, 경로, 클라이언트 |

①②는 되는데 밖에서만 안 되면 거의 확실히 방화벽이다. 자세한 내용은 [8. 오늘 정리 · 안 될 때 점검](lesson-8.md)(LEC-N2-11-015-TS)을 본다.

## 6. 안 될 때 30초 점검 (공유기 실습, 유선)

| 증상 | 원인 | 해결 |
|---|---|---|
| PT PC가 `169.254.x.x` | 공유기 DHCP 꺼짐, 케이블이 `Internet`(WAN) 포트에 꽂힘 | GUI DHCP `Enabled`, `Ethernet 1~4`에 연결 |
| PT `ping 198.51.100.8` 실패 | 공유기 `Internet Setup`(Static, GW `203.0.113.1`) | GUI 값 확인 후 `Save Settings`를 눌렀는지 확인 |
| PT 이름으로만 안 됨 | DHCP의 `Static DNS`가 비어 있음, 서버 DNS가 `Off` | GUI `Static DNS 1` `198.51.100.8`, Internet 서버 DNS `On` |

## 7. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 절차를 MP로 분리하고 명령 사전과 점검표만 남김. 인터넷 서버 주소를 문서용 `198.51.100.x`로 변경 |
