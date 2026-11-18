# 4. 리눅스의 네트워크 — ipconfig 의 리눅스판

> 상위: [10일차 · 서버 기초](README.md)
> 실습: [LEC-N2-10-018-MP](lesson-4-lab.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-10-004-DO |
| 유형 | D&O (개념) |
| 목적 | 리눅스에서 `ip a`, `ip route`, `ping`, `resolvectl`로 IP, 마스크, MAC, 게이트웨이, DNS를 읽는 방법을 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 VM에서 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- `ip a`에서 인터페이스 이름, IP, 마스크(/24), MAC을 찾는다.
- `ip route`에서 기본 게이트웨이를 찾는다.
- `ping`, `resolvectl`로 인터넷과 DNS가 되는지 확인한다.
- 1단계 Windows·시스코 명령과 리눅스 명령을 짝지어 말한다.

## 이전 학습과의 연결

1단계 내내 장비를 만나면 제일 먼저 "IP가 무엇인가, 게이트웨이는 무엇인가, 밖으로 나가는가"를 확인했다. 리눅스 서버도 같다. 서버는 네트워크로 서비스하는 컴퓨터라서 네트워크 확인이 첫 번째 할 일이다.

2일차의 IP, 마스크, 게이트웨이 3종 세트를 리눅스에서 찾아본다. → [3. 공인 IP와 사설 IP](../../network1/day-02/lesson-3.md)

## 1. 같은 질문, 다른 명령

| 알고 싶은 것 | Windows (1단계) | 시스코 (1단계) | 리눅스 (오늘) |
|---|---|---|---|
| 내 IP, MAC | `ipconfig /all` | `show ip interface brief` | `ip a` (`ip -br a` = 짧게) |
| 게이트웨이, 경로 | `route print` | `show ip route` | `ip route` |
| 연결 확인 | `ping` (4번 하고 끝) | `ping` (5번) | `ping` (무한 → Ctrl+C), `ping -c 4` |
| 경로 추적 | `tracert` | `traceroute` | `tracepath` (또는 `traceroute`) |
| DNS 서버 | `ipconfig /all` | `show hosts` | `resolvectl status` |
| ARP 표 | `arp -a` | `show arp` | `ip neigh` |

{% hint style="info" %}
NOTE: 예전 책에는 `ifconfig`가 나온다. 요즘 우분투에는 기본으로 없다. 표준은 `ip` 명령이다.
{% endhint %}

## 2. `ip a` 읽기

```
1: lo: <LOOPBACK,UP,LOWER_UP> ...
    inet 127.0.0.1/8 scope host lo                ← 나 자신 (루프백)
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 ...
    link/ether 08:00:27:ab:cd:ef brd ff:ff:ff:ff:ff:ff       ← MAC 주소 (3일차)
    inet 192.168.0.42/24 metric 100 brd 192.168.0.255 scope global dynamic enp0s3
         ─────┬─── ┬                ─────┬────              ───┬───
              │    └ 마스크 /24 = 255.255.255.0                  └ DHCP로 받았다 (8일차)
              └ 내 IP (사설 — 2일차 192.168.0.0/16 대역)   브로드캐스트 주소 (1일차)
```

| 찾을 것 | 어디 | 1단계 연결 |
|---|---|---|
| 인터페이스 이름 | `enp0s3` | 시스코 `g0/0` 같은 것. 리눅스는 이름이 길다(**e**thernet, **p**ci `0`, **s**lot `3`) |
| IP / 마스크 | `inet 192.168.0.42/24` | 2일차 CIDR 표기, 사설 IP |
| MAC | `link/ether 08:00:27:...` | 3일차 MAC. `08:00:27`은 VirtualBox 가상 랜카드다 |
| dynamic | `scope global dynamic` | DHCP로 받은 주소. 8일차 DORA가 여기서도 일어났다 |
| lo (127.0.0.1) | 첫 줄 | 루프백 = 나 자신. 네트워크 없이도 늘 있다 |

## 3. `ip route` 읽기 — 게이트웨이는?

```
default via 192.168.0.1 dev enp0s3 proto dhcp src 192.168.0.42 metric 100
192.168.0.0/24 dev enp0s3 proto kernel scope link src 192.168.0.42 metric 100
```

| 줄 | 뜻 | 시스코로 치면 |
|---|---|---|
| `default via 192.168.0.1` | 모르는 곳은 전부 192.168.0.1로 보낸다 = 기본 게이트웨이 | `S* 0.0.0.0/0 via ...` (5일차 기본 경로) |
| `192.168.0.0/24 dev enp0s3` | 이 동네는 직접 간다 | `C 192.168.0.0/24 is directly connected` |

{% hint style="info" %}
NOTE: 1단계 그대로다. 목적지가 내 동네(/24)면 직접, 아니면 게이트웨이로 보낸다. 리눅스 서버도 라우팅 테이블을 보고 패킷을 보낸다.
{% endhint %}

- `192.168.0.1`은 강의실 공유기다. VM이 브릿지라서 내 Windows와 같은 공유기를 쓴다.
- 내 Windows에서 `ipconfig`를 입력해 본다. 게이트웨이가 똑같다. 두 대가 같은 동네에 있다는 증거다.
- 이 주소는 누가 줬나? → DHCP([10. DNS와 DHCP 다시 보기](lesson-10.md)). 공유기가 밖으로 내보내는 방법은? → NAT([9. NAT와 포트포워딩](lesson-9.md))

## 4. 밖으로 나가는가 — `ping`과 DNS

```bash
ping -c 4 192.168.0.1         # ① 게이트웨이(공유기)까지
ping -c 4 8.8.8.8             # ② 인터넷(IP)까지
ping -c 4 google.com          # ③ 이름으로 → DNS까지
```

| 결과 | 문제는 |
|---|---|
| ① 실패 | 내 IP, 랜카드, VM 네트워크 설정 |
| ① 성공, ② 실패 | 게이트웨이 너머(공유기, 인터넷) |
| ② 성공, ③ 실패 | DNS. 3일차의 "IP는 되는데 이름은 안 된다"와 같다 → [3. ICMP와 ping](../../network1/day-03/lesson-3.md) |

{% hint style="info" %}
NOTE: 이 "가까운 곳부터 차례로" 점검법은 1단계에서 배운 그대로다. 장비만 리눅스로 바뀌었다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 강의실 망 정책에 따라 `ping`이 막혀 있을 수 있다. 그때는 `curl -I https://google.com`으로 확인한다.
{% endhint %}

```bash
resolvectl status | grep "DNS Servers"      # 내 DNS 서버는?
```

- 리눅스의 DNS 설정, `/etc/hosts`, `dig`는 오후에 자세히 다룬다. → [10. DNS와 DHCP 다시 보기](lesson-10.md)

## 5. 확인 질문

- `ip a`에서 내 IP가 DHCP로 받은 것인지 어떻게 아나? → `dynamic`이라고 쓰여 있다.
- `default via 192.168.0.1`은 1단계의 무엇인가? → 기본 게이트웨이(시스코 `0.0.0.0/0` 경로)
- `127.0.0.1`은? → 루프백 = 나 자신. 랜선이 뽑혀도 있다.
- 리눅스 `ping`이 안 멈춘다. → Ctrl+C. 처음부터 `ping -c 4`를 쓴다.

## 6. 약어·용어

| 용어 | 뜻 |
|---|---|
| 루프백(lo) | 나 자신을 가리키는 가상 인터페이스. `127.0.0.1` |
| 기본 게이트웨이 | 모르는 목적지로 가는 패킷을 보내는 출구 라우터 |
| `dynamic` | DHCP로 받은 주소 표시 |
| `resolvectl` | systemd-resolved의 DNS 상태 확인 명령 |
| `enp0s3` | 첫 번째 가상 이더넷 인터페이스 이름 예시 |

## 진행 메모

- Windows, 시스코, 리눅스 3단 비교표가 오늘의 가장 큰 무기다. 새로 외우는 것이 아니라 아는 것을 번역한다는 느낌을 준다.
- `ip a`는 스크린샷이나 칠판에 밑줄을 긋는다. IP, 마스크, MAC, dynamic 네 곳만 찾게 한다.
- 내 Windows `ipconfig`와 나란히 비교시키는 것이 이 절의 하이라이트다. 게이트웨이가 같으면 브릿지의 의미가 전달된다.
- VM 주소는 브릿지와 DHCP 때문에 매주 바뀔 수 있다. 값은 학생마다 다르므로 칠판에 각자 적게 한다.
- 이 노트가 오전과 오후를 잇는 다리다. 각자의 IP, 게이트웨이, `dynamic`을 남겨 두고 오후에 회수한다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 내 VM의 IP, 마스크, 게이트웨이를 `ip a`와 `ip route` 출력에서 찾아 적어 본다.
- [ ] `ping`으로 게이트웨이, 8.8.8.8, 도메인 이름을 차례로 확인하는 이유를 내 말로 설명해 본다.
- [ ] Windows `ipconfig`와 리눅스 `ip a`를 비교하며 같은 점과 다른 점을 적어 본다.
