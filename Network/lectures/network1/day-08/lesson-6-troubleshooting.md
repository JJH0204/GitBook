# 8일차 실습 문제 해결

> 상위: [8일차 · 네트워크 장비에서의 서버 설정](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N1-08-008-TS |
| 유형 | TS (문제 해결) |
| 목적 | 8일차 실습(원격 접속, DHCP, DNS, 포트 보안)에서 막힐 때 증상별 원인과 조치를 찾는다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 장비에서 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 케이블, 링크 점 색깔 같은 패킷트레이서 조작 문제는 3일차 표를 본다. → [3일차 · 자주 나는 오류](../day-03/lesson-4.md) 트렁크, VLAN, EtherChannel 증상은 [7일차 부록 D](../day-07/commands.md)를 본다.
{% endhint %}

## 1. 증상과 가능 원인

오늘판 5대 원인은 다음과 같다.

| 증상 | 원인 |
|---|---|
| 같은 VLAN에서만 스위치 원격 접속이 된다 | `ip default-gateway` 누락 (1위) |
| SSH로 들어가서 `enable`이 안 된다 | `enable secret` 누락 |
| VLAN 20만 `169.254` | `ip helper-address` 누락, 서버에 VLAN20 풀 없음 |
| IP는 되는데 이름은 안 된다 | 서버 DNS Off, 레코드 오타 |
| 포트가 또 꺼진다 | 침입 기기를 먼저 치우지 않았다 |

전체 증상 표는 다음과 같다.

| 증상 | 가능 원인 | 확인 | 시정 조치 |
|---|---|---|---|
| 스위치에 ping이 안 된다 | SVI가 없거나 `no shutdown`을 하지 않았다, SVI의 VLAN이 틀렸다 | `show ip interface brief`에서 `Vlan10`이 `up/up`인가 | `interface vlan 10`에서 IP 입력 후 `no shutdown` |
| 같은 VLAN에서만 원격 접속이 된다 | 스위치 `ip default-gateway` 누락 | `show running-config`의 `ip default-gateway` | `ip default-gateway 192.168.10.254` |
| `Password required, but none set` | VTY에 비밀번호와 `login`(또는 `login local`)이 없다 | `show running-config`의 `line vty` | `password <password>`와 `login` 입력 |
| 원격 접속 후 `enable`에서 `% No password set` | `enable secret` 없음 | `show running-config` | `enable secret <password>` |
| `% Please define a domain-name first.` | `ip domain-name`을 먼저 입력하지 않았다 | `show running-config` | `ip domain-name <도메인>` 후 키 생성 |
| `% Please define hostname other than Switch.` | 기본 호스트명 `Switch` | 프롬프트 | `hostname SW1` 후 키 생성 |
| SSH가 거절된다 | 키 미생성, `username` 없음, `login local` 대신 `login`, `ssh -l` 계정 오타 | `show ip ssh`, `show running-config` | 키 생성, 계정 입력, `login local`, 계정 이름 확인 |
| PC가 `169.254.x.x`를 받는다 | DHCP 서버를 못 찾았다 | 풀, 릴레이, 서버 DHCP On, 선 | 풀 생성, `ip helper-address` 입력, 서버 DHCP `On` |
| 서버 DHCP에서 VLAN 10만 받고 VLAN 20은 못 받는다 | `ip helper-address` 누락 | R1 `show running-config`의 `g0/0.20` | `g0/0.20`에 `ip helper-address 192.168.10.10` |
| helper를 넣었는데도 못 받는다 | 서버에 VLAN 20용 풀이 없다 | Server0 `Services > DHCP` | 게이트웨이 `.20.254` 풀 추가 |
| helper를 서버 쪽에 입력했다 | 외침이 들어오는 문(클라이언트 쪽)에 입력하지 않았다 | `g0/0.10`에 helper가 있는가 | `g0/0.20`에 입력, `g0/0.10`은 삭제 |
| 받은 IP가 게이트웨이와 충돌한다 | `excluded-address` 누락 | `show running-config`의 `ip dhcp excluded-address` | 제외 주소 입력(풀보다 먼저) |
| IP로는 되는데 이름으로 안 된다 | 서버 DNS Off, A 레코드 오타, PC의 DNS 서버 주소 | Server0 `Services > DNS`, PC의 `ipconfig /all` | DNS `On`, 레코드 수정, DNS 주소 확인 |
| 포트 보안 명령에서 `Command rejected` | 포트가 액세스 모드가 아니다 | `show interfaces fa0/1 switchport` | `switchport mode access` 후 다시 입력 |
| 포트가 빨간색 (err-disabled) | 포트 보안 위반 | `show port-security interface fa0/1`의 `Last Source Address` | 침입 기기를 뽑고 `shutdown`, `no shutdown` |
| 침입 기기를 꽂은 채 `no shutdown`했더니 또 꺼진다 | 범인을 치우지 않았다 | 포트 상태 | 선을 먼저 뽑은 뒤 복구 |
| 정상 PC로 바꿨는데 포트가 꺼진다 | sticky가 옛 MAC을 기억한다 | `show port-security address` | `clear port-security sticky interface fa0/1` 후 재학습 |
| 무선 노트북이 안 붙는다 | SSID, 비밀번호, WPA2-PSK/AES 불일치, WPC300N 미장착 | AP와 노트북의 `Config` | AP와 같은 값으로 수정, 모듈 교체 |
| IPv6가 라우터를 못 넘는다 | `ipv6 unicast-routing` 누락, PC의 IPv6 게이트웨이 | `show ipv6 interface brief` | `ipv6 unicast-routing` 입력, 게이트웨이 입력 |
| 껐다 켜니 설정이 사라졌다 | `copy running-config startup-config`를 하지 않았다 | `show startup-config` | 저장 |

## 2. 격리 절차

1. 스위치 원격 접속이 안 되면 `show ip interface brief`로 `Vlan10`이 `up/up`인지 본다. 아니면 `no shutdown`을 확인한다.
2. 같은 VLAN에서만 되면 `ip default-gateway`를 확인한다.
3. 접속은 되는데 로그인이 안 되면 VTY(`password`/`login local`), `username`, `enable secret`, 키 생성 순으로 확인한다.
4. PC가 `169.254`이면 DHCP 풀(또는 서버 DHCP On), 같은 VLAN 여부, 릴레이 순으로 확인한다.
5. 이름이 안 풀리면 IP ping부터 확인하고, 서버 DNS 상태, A 레코드, PC의 DNS 주소 순으로 확인한다.
6. 포트가 꺼지면 `show port-security interface`로 범인 MAC을 찾고, 범인을 치운 뒤 `shutdown`, `no shutdown`을 입력한다.
7. 설정을 바꿨으면 `copy running-config startup-config`로 저장한다.

## 3. 약어·용어

| 용어 | 뜻 |
|---|---|
| SVI | Switch Virtual Interface. 스위치의 관리용 가상 IP 인터페이스 |
| APIPA | DHCP 실패 시 PC가 붙이는 `169.254.x.x` |
| err-disabled | 포트 보안 위반으로 포트가 꺼진 상태 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 실습 중 가장 오래 막혔던 증상과 원인을 내 말로 적어 본다.
- [ ] "VLAN 20만 `169.254`를 받는다"를 만났을 때 어디부터 확인할지 순서를 적어 본다.
- [ ] 포트가 err-disabled됐을 때 범인부터 치워야 하는 이유를 적어 본다.
