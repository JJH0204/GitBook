# 0. 실습 명령어 모음

> 상위: [8일차 DHCP와 게이트웨이 이중화](README.md)

수업 흐름 순서대로 적은 대본입니다. 1~10번은 `_실습/새봄상사.pkt` 에서 새봄상사의 주소로 강사와 함께 치고(8번 가짜 DHCP 서버는 강사만), 11~14번은 개인 실습에서 `configs/network.pkt` 를 열어 같은 일을 내 회사의 설계로 합니다. 장비 화면의 출력 예시는 IOS 15 형식을 따라 적었고, 패킷트레이서 버전에 따라 조금 다를 수 있습니다.

| 단계 | 내용 | 언제 | 노트 |
|------|------|------|------|
| 0 | 작업 계획서 | 14:00 (20분) | README |
| 1 | 제외 주소와 풀 | 14:32 함께 (6분) | 1 |
| 2 | PC를 DHCP로, 빌려준 현황 | 함께 (4분) | 1 |
| 3 | 지사 릴레이 | 14:52 함께 (8분) | 2 |
| 4 | HQ-DSW1 놓기, VLAN, 트렁크 | 15:08 함께 (9분) | 3 |
| 5 | SVI와 `ip routing` | 함께 (8분) | 3 |
| 6 | HSRP | 15:45 함께 (15분) | 3 |
| 7 | 확인과 장애 시험 | 함께 (12분) | 3 |
| 8 | 가짜 DHCP 서버 | 16:20 강사 시연 (7분) | 4 |
| 9 | DHCP 스누핑 | 함께 (12분) | 4 |
| 10 | HSRP 인증 | 함께 (6분) | 4 |
| 11 | 내 회사 파일에 1~10번 | 17:00 개인 (27분) | 1~4 |
| 12 | 주소 할당과 이중화 기록 | 개인 (15분) | 4 |
| 13 | 설정 텍스트 | 개인 (8분) | |
| 14 | 결과 기록과 커밋 | 개인 (10분) | |

## 0. 작업 계획서 (14:00~14:20)

```bash
cd ~/my-netsec-project
git pull
```

`00_작업계획/08일차.md` 를 만들고 1~5번 칸을 채워 커밋합니다.

```bash
git add .
git commit -m "8일차: 작업 계획서"
git push
```

## 1. 제외 주소와 풀

HQ-R1입니다. 제외 주소를 먼저 넣고 풀을 만듭니다.

```
configure terminal
ip dhcp excluded-address 192.168.10.1 192.168.10.9
ip dhcp excluded-address 192.168.10.21 192.168.10.30
ip dhcp excluded-address 192.168.10.33 192.168.10.41
ip dhcp excluded-address 192.168.10.53 192.168.10.62
ip dhcp excluded-address 192.168.10.65 192.168.10.73
ip dhcp excluded-address 192.168.10.85 192.168.10.94
ip dhcp excluded-address 192.168.20.1 192.168.20.9
ip dhcp excluded-address 192.168.20.21 192.168.20.30
ip dhcp pool SALES
 network 192.168.10.0 255.255.255.224
 default-router 192.168.10.1
ip dhcp pool HR
 network 192.168.10.32 255.255.255.224
 default-router 192.168.10.33
ip dhcp pool DEV
 network 192.168.10.64 255.255.255.224
 default-router 192.168.10.65
ip dhcp pool BR-SALES
 network 192.168.20.0 255.255.255.224
 default-router 192.168.20.1
 end
```

서버 VLAN(40)과 장비 관리 VLAN(99)에는 풀을 만들지 않습니다. 두 VLAN의 장비는 고정 주소입니다.

## 2. PC를 DHCP로, 빌려준 현황

Sales-PC1, Sales-PC2, Sales-PC3, HR-PC1, Dev-PC1의 Desktop, IP Configuration에서 DHCP를 고릅니다. "DHCP request successful" 이 뜨고 칸이 채워지면 됩니다. Server1과 Admin-PC는 고정 주소 그대로 둡니다.

| PC | 받는 주소 | 게이트웨이 |
|----|-----------|------------|
| Sales-PC1~3 | 192.168.10.10부터 받는 순서대로 | 192.168.10.1 |
| HR-PC1 | 192.168.10.42 | 192.168.10.33 |
| Dev-PC1 | 192.168.10.74 | 192.168.10.65 |

HQ-R1에서 빌려준 현황을 봅니다.

```
HQ-R1#show ip dhcp binding
```

주소 다섯 개와 각 PC의 MAC 주소가 보이면 됩니다. Sales-PC1에서 `ping 192.168.10.98` 로 서버까지 확인합니다.

## 3. 지사 릴레이

먼저 BR-PC1을 DHCP로 바꿉니다. 169.254로 시작하는 주소가 붙고 실패합니다. BR-R1에 한 줄을 넣습니다.

```
configure terminal
interface gi0/0
 ip helper-address 192.168.255.1
 end
```

BR-PC1과 BR-PC2를 다시 DHCP로 받습니다. 192.168.20.10, .11이 붙으면 됩니다. HQ-R1의 `show ip dhcp binding` 에 지사 주소 두 줄이 더해집니다.

## 4. HQ-DSW1 놓기, VLAN, 트렁크

3560-24PS 스위치를 HQ-SW1 옆에 놓고, HQ-DSW1의 Gi0/1과 HQ-SW1의 Fa0/23을 잇습니다.

HQ-DSW1에 2일차의 기본 잠금을 겁니다. `hostname` 만 HQ-DSW1로 바꾸고 VTY는 `line vty 0 15` 입니다. 이어서 VLAN과 트렁크입니다.

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

HQ-SW1의 Fa0/23은 3일차에 닫아 둔 포트입니다. 트렁크로 바꾸고 엽니다.

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

`show interfaces trunk` 에 Fa0/23이 trunking, native 900으로 보이면 됩니다. HQ-DSW1에서도 같은 명령으로 Gi0/1을 확인합니다.

## 5. SVI와 ip routing

HQ-DSW1입니다.

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

C 줄 다섯 개(192.168.10.0, .32, .64, .96, .128, 모두 /27)가 보이면 됩니다. HQ-DSW1에서 `ping 192.168.10.98` 로 서버에 닿는지 봅니다.

## 6. HSRP

강사가 영업팀 PC에 `ping -t 192.168.10.98` 을 걸어 두고 시작합니다. HQ-R1의 주소를 바꾸는 동안 잠깐 끊깁니다.

HQ-R1입니다. 주소를 블록의 마지막에서 두 번째로 옮기고, 원래 주소를 가상 주소로 겁니다.

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

`%HSRP-5-STATECHANGE: ... state Standby -> Active` 알림이 그룹마다 뜹니다. 지금은 HQ-R1 혼자라 Active입니다.

HQ-DSW1입니다. 우선순위 110과 preempt를 더하고, 밖으로 가는 기본 경로는 HQ-R1의 실제 주소로 넣습니다.

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

잠시 뒤 HQ-DSW1에 `state Standby -> Active`, HQ-R1에 `state Active -> Speak` 가 뜹니다. HQ-DSW1이 preempt로 Active를 가져간 것입니다.

## 7. 확인과 장애 시험

```
HQ-DSW1#show standby brief
HQ-R1#show standby brief
```

| 장비 | 찾을 것 |
|------|---------|
| HQ-DSW1 | 네 그룹 모두 State Active, Standby 칸에 HQ-R1의 실제 주소 |
| HQ-R1 | 네 그룹 모두 State Standby, Active 칸에 HQ-DSW1의 실제 주소 |

Sales-PC1에서 확인합니다.

| 명령 | 보이는 것 |
|------|-----------|
| `arp -a` | 192.168.10.1의 MAC이 0000.0c07.ac0a |
| `tracert 192.168.20.1` | 192.168.10.30, 192.168.10.29, 192.168.20.1 세 줄. 첫 줄이 L3 스위치다 |
| `tracert 192.168.10.98` | 192.168.10.30, 192.168.10.98 두 줄. VLAN 사이는 L3 스위치만 지난다 |

장애 시험입니다. Sales-PC1에서 `ping -t 192.168.10.98` 을 걸어 둡니다.

```
HQ-DSW1(config)#interface gi0/1
HQ-DSW1(config-if)#shutdown
```

`Request timed out` 이 몇 번 나온 뒤 Reply가 돌아옵니다. HQ-R1의 `show standby brief` 에서 네 그룹이 Active입니다. 끊긴 횟수를 세어 둡니다.

```
HQ-DSW1(config-if)#no shutdown
```

30초쯤 지나 HQ-DSW1이 Active를 되찾습니다. 돌아올 때 끊긴 횟수도 세어 둡니다. Ctrl+C로 ping을 멈춥니다.

## 8. 가짜 DHCP 서버 (강사 시연)

강사의 `_실습/새봄상사.pkt` 에서만 합니다.

1. Server-PT를 놓고 이름을 FAKE-DHCP로 바꿉니다. HQ-SW1의 Fa0/3(영업팀 VLAN)에 잇습니다.
2. Desktop, IP Configuration에서 고정 주소 192.168.10.25, 마스크 255.255.255.224, 게이트웨이 192.168.10.25를 넣습니다.
3. Services, DHCP에서 Service를 On, Default Gateway 192.168.10.25, Start IP Address 192.168.10.21, Subnet Mask 255.255.255.224로 두고 Save를 누릅니다.
4. Sales-PC1의 IP Configuration을 Static으로 바꿨다가 DHCP로 바꿉니다. 게이트웨이가 192.168.10.25가 될 때까지 몇 번 반복합니다.
5. Sales-PC1에서 `tracert 192.168.20.1` 을 칩니다. 첫 줄부터 답이 없습니다. 패킷이 가짜 서버로 가서 멈춥니다.

## 9. DHCP 스누핑

HQ-SW1입니다.

```
configure terminal
ip dhcp snooping
ip dhcp snooping vlan 10,20,30,40
no ip dhcp snooping information option
interface gi0/1
 ip dhcp snooping trust
 end
show ip dhcp snooping
```

HQ-SW2는 같은 설정에 믿는 포트만 Gi0/1(HQ-SW1 쪽)입니다. BR-SW1은 VLAN이 10 하나입니다.

```
configure terminal
ip dhcp snooping
ip dhcp snooping vlan 10
no ip dhcp snooping information option
interface gi0/1
 ip dhcp snooping trust
 end
```

강사는 Sales-PC1을 다시 DHCP로 받습니다. 몇 번을 받아도 게이트웨이가 192.168.10.1입니다. 확인한 뒤 FAKE-DHCP의 DHCP 서비스를 끄고 서버를 지웁니다.

학생은 모든 PC가 다시 DHCP로 주소를 받는지 확인합니다. 지사 PC도 받아야 합니다.

## 10. HSRP 인증

HQ-DSW1과 HQ-R1에 같은 줄을 넣습니다. HQ-R1은 `interface gi0/0.10` 처럼 서브인터페이스입니다.

```
configure terminal
interface vlan 10
 standby 10 authentication md5 key-string <실습용 키>
interface vlan 20
 standby 20 authentication md5 key-string <실습용 키>
interface vlan 30
 standby 30 authentication md5 key-string <실습용 키>
interface vlan 40
 standby 40 authentication md5 key-string <실습용 키>
 end
```

HQ-DSW1에만 건 상태에서 HQ-R1의 `show standby brief` 를 봅니다. 두 장비가 모두 Active가 됩니다. HQ-R1에도 걸고 다시 봅니다. Active와 Standby가 하나씩이면 됩니다.

여섯 장비(HQ-R1, BR-R1, HQ-DSW1, HQ-SW1, HQ-SW2, BR-SW1)를 모두 저장합니다.

```
copy running-config startup-config
```

## 11. 내 회사 파일에 1~10번 (개인 실습)

`_실습/새봄상사.pkt` 를 저장하고 닫은 뒤 `configs/network.pkt` 를 엽니다.

1. 1~7번과 9, 10번을 내 회사의 설계로 칩니다. 8번 시연은 하지 않습니다.
2. 풀과 제외 주소는 내 VLAN 대역마다 계산합니다. 블록의 마지막 두 주소를 라우터와 L3 스위치에 남깁니다.
3. 지점이 없는 학생은 3번을 건너뛰고, 기록에 "지점이 생기면 릴레이"라고 적습니다.

## 12. 주소 할당과 이중화 기록

1. [4번 노트](lesson-4.md) 7번 절의 양식으로 `03_구축/주소할당과_이중화.md` 를 씁니다. 장애 시험의 끊긴 횟수를 꼭 적습니다.
2. `02_설계/IP_설계표.md` 에 VLAN마다 가상 주소, 라우터와 L3 스위치의 실제 주소, DHCP 범위를 더합니다.
3. `02_설계/구성도.md` 의 캡처를 HQ-DSW1이 보이게 다시 붙입니다.
4. `02_설계/스위치_보안_점검표.md` 가 있으면 4번 노트 6번 절의 세 줄을 더합니다.

## 13. 설정 텍스트

`configs/` 에 여섯 장비의 설정 텍스트를 저장합니다. HQ-DSW1은 새로 생기는 파일입니다.

## 14. 결과 기록과 커밋

`00_작업계획/08일차.md` 의 결과 칸을 채우고, README 진행 현황에 한 줄을 더합니다.

```markdown
| 8 | DHCP와 릴레이, L3 스위치와 HSRP, 스누핑과 HSRP 인증 | [작업 계획서](00_작업계획/08일차.md), [주소 할당과 이중화](03_구축/주소할당과_이중화.md), [설정](configs/) |
```

```bash
git add .
git commit -m "8일차: DHCP, 게이트웨이 이중화, 스누핑"
git push
```

## 자주 막히는 곳

| 보이는 것 | 원인 | 해결 |
|-----------|------|------|
| PC가 169.254 주소를 받는다 | 풀의 `network` 가 그 VLAN 대역과 다르다 | `show running-config` 의 `ip dhcp pool` 부분 |
| PC가 받은 게이트웨이가 틀리다 | `default-router` 를 다른 풀의 값으로 적었다 | 풀마다 그 VLAN의 게이트웨이 |
| 지사 PC만 못 받는다 | helper-address를 HQ-R1에 넣었거나, HQ-R1에 BR-SALES 풀이 없다 | BR-R1 Gi0/0, HQ-R1 풀 |
| 3560에서 `switchport mode trunk` 가 거절된다 | 캡슐화를 정하지 않았다 | `switchport trunk encapsulation dot1q` 먼저 |
| SVI가 down이다 | 그 VLAN이 HQ-DSW1에 없거나 트렁크에서 허락하지 않았다 | `show vlan brief`, `show interfaces trunk` |
| HSRP가 두 장비 모두 Active다 | 트렁크가 끊겼거나 인증 키가 다르다 | `show interfaces trunk`, key-string 비교 |
| HQ-DSW1이 Active를 되찾지 않는다 | `standby 10 preempt` 를 빠뜨렸다 | 그룹마다 preempt |
| 이중화 뒤 지사로만 안 간다 | HQ-DSW1의 기본 경로가 없거나 가상 주소(.1)를 가리킨다 | `ip route 0.0.0.0 0.0.0.0 192.168.10.29` |
| 스누핑을 켜자 모든 PC가 주소를 못 받는다 | 옵션 82 줄을 빠뜨렸거나 믿는 포트를 잘못 골랐다 | `no ip dhcp snooping information option`, 서버 쪽 포트에 trust |
| HQ-SW2의 PC만 못 받는다 | HQ-SW2의 Gi0/1을 믿는 포트로 두지 않았다 | HQ-SW2 Gi0/1에 `ip dhcp snooping trust` |
| `standby ... authentication md5` 가 거절된다 | 패킷트레이서 버전이 지원하지 않는다 | `standby 10 authentication <실습용 키>` (평문 인증) |
