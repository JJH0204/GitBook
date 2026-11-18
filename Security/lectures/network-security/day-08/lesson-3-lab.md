# 3-1. L3 스위치 설치와 HSRP 장애 시험 실습

> 상위: [8일차 DHCP와 게이트웨이 이중화](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-08-008-MP |
| 목적 | 패킷트레이서에서 L3 스위치 HQ-DSW1을 트렁크로 붙이고 SVI와 `ip routing`을 넣은 뒤, HQ-R1과 HSRP로 게이트웨이를 이중화하고 장애 시험으로 확인한다 |
| 적용 대상 | Cisco Packet Tracer의 `_실습/새봄상사.pkt` (3560-24PS 스위치 HQ-DSW1, 2960 스위치 HQ-SW1, 2911 라우터 HQ-R1). 2-1 실습을 마친 상태. 격리된 가상 실습망이며 실제 장비와 연결하지 않는다 |
| 소요 시간 | 약 44분 (HQ-DSW1 놓기 9분, SVI 8분, HSRP 15분, 확인과 장애 시험 12분) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이 환경에서 패킷트레이서를 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-3.md](lesson-3.md) | LEC-SN-08-003-DO | 게이트웨이 이중화: L3 스위치와 HSRP |
| [commands.md](commands.md) | LEC-SN-08-005-REF | 실습 명령어 모음 (4~7번, 자주 막히는 곳 포함) |
| [lesson-4-lab.md](lesson-4-lab.md) | LEC-SN-08-009-MP | 다음 실습. 스누핑과 HSRP 인증 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Cisco Packet Tracer | `_실습/새봄상사.pkt` 파일 | 2-1 실습까지의 구성이 들어 있다 |
| 2 | L3 스위치 | 3560-24PS (HQ-DSW1) | 새로 놓는다 |
| 3 | 스위치 | 2960 (HQ-SW1) | Fa0/23이 3일차에 닫혀 있다 |
| 4 | 라우터 | 2911 (HQ-R1) | 서브인터페이스 Gi0/0.10, .20, .30, .40 |
| 5 | PC | Sales-PC1 | `ping -t` 시험용 |
| 6 | 서버 | Server1 (192.168.10.98) | 시험 대상 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 구역 C에서 HQ-R1의 주소를 바꾸는 순간부터 HQ-R1에 `standby` 줄이 들어갈 때까지 해당 VLAN의 게이트웨이가 없어 통신이 몇 초 끊긴다. 실제 회사에서는 직원이 적은 시간에 한다. 실습에서는 영업팀 PC에 `ping -t`를 걸어 두고 끊김을 함께 본다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 구역 D의 장애 시험 뒤에는 반드시 HQ-DSW1의 Gi0/1을 `no shutdown`으로 살린다.
{% endhint %}

{% hint style="warning" %}
CAUTION: HQ-DSW1의 기본 경로는 HQ-R1의 실제 주소(192.168.10.29)로 넣는다. 가상 주소(192.168.10.1)를 가리키면 Active인 자기 자신을 가리켜 패킷이 돌기만 한다.
{% endhint %}

{% hint style="info" %}
NOTE: 비밀번호는 `<password>` 자리에 실습용 값을 직접 정해 넣는다. 문서에 실제로 쓰는 비밀번호를 적지 않는다.
{% endhint %}

{% hint style="info" %}
NOTE: 3560의 트렁크는 `switchport trunk encapsulation dot1q`를 먼저 입력해야 `switchport mode trunk`가 받아들여진다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 2-1 실습을 저장했다 | BR-PC1이 DHCP로 192.168.20.10을 받았다 |
| 2 | HQ-SW1의 Fa0/23이 닫혀 있다 | `show interfaces status`에서 Fa0/23이 disabled다 |
| 3 | HQ-R1의 서브인터페이스 주소가 .1, .33, .65, .97이다 | `show ip interface brief` |
| 4 | 본사 PC가 DHCP로 주소를 받았다 | 1-1 실습의 기능 확인 합격 |

## 5. 절차

### A. HQ-DSW1 놓기, VLAN, 트렁크

1. (5-A-01) 3560-24PS 스위치를 HQ-SW1 옆에 놓는다.
2. (5-A-02) HQ-DSW1의 Gi0/1과 HQ-SW1의 Fa0/23을 잇는다. → 결과: 양쪽 포트에 링크 표시가 생긴다.
3. (5-A-03) HQ-DSW1에 2일차의 기본 잠금을 건다. `hostname`만 HQ-DSW1로 바꾸고 VTY는 `line vty 0 15`로 한다. 비밀번호 자리는 `<password>`다. → 결과: 프롬프트가 `HQ-DSW1(config)#`로 바뀐다.
4. (5-A-04) VLAN과 트렁크를 입력한다. → 결과: 프롬프트가 `HQ-DSW1#`로 돌아온다.

```
configure terminal
vtp mode transparent
vlan 10
 name SALES
vlan 20
 name HR
vlan 30
 name DEV
vlan 40
 name SERVER
vlan 99
 name MGMT
vlan 900
 name NATIVE
vlan 999
 name UNUSED
 exit
interface gi0/1
 description To HQ-SW1
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk native vlan 900
 switchport trunk allowed vlan 10,20,30,40,99
 switchport nonegotiate
 exit
interface range fa0/1 - 24 , gi0/2
 switchport mode access
 switchport access vlan 999
 shutdown
 end
```

5. (5-A-05) HQ-SW1의 닫아 둔 Fa0/23을 트렁크로 바꾸고 연다. → 결과: 프롬프트가 `HQ-SW1#`로 돌아오고 `show interfaces trunk`가 출력된다.

```
configure terminal
interface fa0/23
 description To HQ-DSW1
 switchport mode trunk
 switchport trunk native vlan 900
 switchport trunk allowed vlan 10,20,30,40,99
 switchport nonegotiate
 no shutdown
 end
show interfaces trunk
```

6. (5-A-06) `show interfaces trunk` 출력에서 Fa0/23을 확인한다. → 결과: trunking, native 900으로 보인다.
7. (5-A-07) HQ-DSW1에서 같은 명령으로 Gi0/1을 확인한다. → 결과: trunking, native 900으로 보인다.

### B. SVI와 ip routing

1. (5-B-01) HQ-DSW1에서 SVI와 `ip routing`을 입력한다. → 결과: 오류 없이 프롬프트가 돌아온다.

```
configure terminal
interface vlan 10
 ip address 192.168.10.30 255.255.255.224
 no shutdown
interface vlan 20
 ip address 192.168.10.62 255.255.255.224
 no shutdown
interface vlan 30
 ip address 192.168.10.94 255.255.255.224
 no shutdown
interface vlan 40
 ip address 192.168.10.126 255.255.255.224
 no shutdown
interface vlan 99
 ip address 192.168.10.132 255.255.255.224
 no shutdown
 exit
ip routing
 end
show ip route connected
```

2. (5-B-02) `show ip route connected` 출력을 읽는다. → 결과: C 줄 다섯 개(192.168.10.0, .32, .64, .96, .128, 모두 /27)가 보인다.
3. (5-B-03) HQ-DSW1에서 `ping 192.168.10.98`을 입력한다. → 결과: 서버에서 Reply가 온다.

### C. HSRP

1. (5-C-01) 강사가 영업팀 PC에 `ping -t 192.168.10.98`을 걸어 둔다. HQ-R1의 주소를 바꾸는 동안 잠깐 끊긴다.
2. (5-C-02) HQ-R1에서 주소를 블록의 마지막에서 두 번째로 옮기고, 원래 주소를 가상 주소로 건다. → 결과: `%HSRP-5-STATECHANGE: ... state Standby -> Active` 알림이 그룹마다 뜬다. 지금은 HQ-R1 혼자라 Active다.

```
configure terminal
interface gi0/0.10
 ip address 192.168.10.29 255.255.255.224
 standby 10 ip 192.168.10.1
interface gi0/0.20
 ip address 192.168.10.61 255.255.255.224
 standby 20 ip 192.168.10.33
interface gi0/0.30
 ip address 192.168.10.93 255.255.255.224
 standby 30 ip 192.168.10.65
interface gi0/0.40
 ip address 192.168.10.125 255.255.255.224
 standby 40 ip 192.168.10.97
 end
```

3. (5-C-03) HQ-DSW1에서 우선순위 110과 preempt를 더하고, 밖으로 가는 기본 경로를 HQ-R1의 실제 주소로 넣는다. → 결과: 잠시 뒤 HQ-DSW1에 `state Standby -> Active`, HQ-R1에 `state Active -> Speak`가 뜬다. HQ-DSW1이 preempt로 Active를 가져간 것이다.

```
configure terminal
interface vlan 10
 standby 10 ip 192.168.10.1
 standby 10 priority 110
 standby 10 preempt
interface vlan 20
 standby 20 ip 192.168.10.33
 standby 20 priority 110
 standby 20 preempt
interface vlan 30
 standby 30 ip 192.168.10.65
 standby 30 priority 110
 standby 30 preempt
interface vlan 40
 standby 40 ip 192.168.10.97
 standby 40 priority 110
 standby 40 preempt
 exit
ip route 0.0.0.0 0.0.0.0 192.168.10.29
 end
```

### D. 확인과 장애 시험

1. (5-D-01) 두 장비에서 `show standby brief`를 입력한다: HQ-DSW1과 HQ-R1. → 결과: 아래 표와 같이 보인다.

| 장비 | 찾을 것 |
|---|---|
| HQ-DSW1 | 네 그룹 모두 State Active, Standby 칸에 HQ-R1의 실제 주소 |
| HQ-R1 | 네 그룹 모두 State Standby, Active 칸에 HQ-DSW1의 실제 주소 |

2. (5-D-02) Sales-PC1에서 `arp -a`를 입력한다. → 결과: 192.168.10.1의 MAC이 0000.0c07.ac0a다.
3. (5-D-03) Sales-PC1에서 `tracert 192.168.20.1`을 입력한다. → 결과: 192.168.10.30, 192.168.10.29, 192.168.20.1 세 줄이 보인다. 첫 줄이 L3 스위치다.
4. (5-D-04) Sales-PC1에서 `tracert 192.168.10.98`을 입력한다. → 결과: 192.168.10.30, 192.168.10.98 두 줄이 보인다. VLAN 사이는 L3 스위치만 지난다.
5. (5-D-05) Sales-PC1에서 `ping -t 192.168.10.98`을 건다. → 결과: Reply가 이어진다.
6. (5-D-06) HQ-DSW1에서 Gi0/1을 끈다. → 결과: `Request timed out`이 몇 번 나온 뒤 Reply가 돌아온다.

```
HQ-DSW1(config)#interface gi0/1
HQ-DSW1(config-if)#shutdown
```

7. (5-D-07) HQ-R1에서 `show standby brief`를 입력한다. → 결과: 네 그룹이 Active다. 끊긴 횟수를 세어 둔다.
8. (5-D-08) HQ-DSW1에서 Gi0/1을 다시 켠다. → 결과: 30초쯤 지나 HQ-DSW1이 Active를 되찾는다. 돌아올 때 끊긴 횟수도 세어 둔다.

```
HQ-DSW1(config-if)#no shutdown
```

9. (5-D-09) `Ctrl+C`로 ping을 멈춘다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | HQ-SW1, HQ-DSW1에서 `show interfaces trunk` | Fa0/23, Gi0/1이 trunking | native 900 |
| 2 | HQ-DSW1에서 `show ip route connected` | C 줄 다섯 개 | 다섯 대역 모두 존재 |
| 3 | HQ-DSW1에서 `show standby brief` | 네 그룹 Active | Standby 칸에 HQ-R1 실제 주소 |
| 4 | HQ-R1에서 `show standby brief` | 네 그룹 Standby | Active 칸에 HQ-DSW1 실제 주소 |
| 5 | Sales-PC1에서 `arp -a` | 가상 MAC | 0000.0c07.ac0a |
| 6 | 장애 시험 중 `ping -t` | 몇 번 끊긴 뒤 Reply | 끊긴 횟수를 기록했다 |
| 7 | 장애 시험 중 HQ-R1의 `show standby brief` | 네 그룹 Active | HQ-R1이 이어받았다 |
| 8 | `no shutdown` 약 30초 뒤 | HQ-DSW1이 Active를 되찾는다 | preempt 동작 |

## 7. 복구

1. (7-01) 이중화가 꼬이면 HQ-R1 서브인터페이스의 `standby` 줄을 `no standby <그룹 번호> ip`로 지우고 주소를 원래 게이트웨이(.1, .33, .65, .97)로 되돌린다. 이어서 HQ-DSW1의 Gi0/1을 `shutdown`한다. → 결과: 3일차 모습으로 돌아간다.
2. (7-02) 장애 시험 뒤 HQ-DSW1의 Gi0/1이 꺼져 있으면 `no shutdown`을 입력한다.
3. (7-03) 실습을 처음 상태로 돌리려면 `_실습/새봄상사.pkt`를 저장하지 않고 닫고 다시 연다.
4. (7-04) 다음 실습(LEC-SN-08-009-MP)으로 넘어가기 전에 `copy running-config startup-config`로 HQ-R1, HQ-DSW1, HQ-SW1을 저장한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 4~7번을 AMM 형식 MP로 분리. 비밀번호 자리 `<password>`로 표기. 번호(4~7)는 다른 문서의 참조 때문에 `commands.md`에 유지 |
