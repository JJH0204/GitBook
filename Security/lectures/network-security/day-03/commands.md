# 0. 실습 명령어 모음

> 상위: [3일차 스위칭과 VLAN](README.md)

수업 흐름 순서대로 적은 대본입니다. 1~8번은 `_실습/새봄상사.pkt` 에서 새봄상사의 주소로 강사와 함께 치고, 9~12번은 개인 실습에서 `configs/network.pkt` 를 열어 같은 일을 내 회사의 설계로 합니다. 장비 화면의 출력 예시는 IOS 15 형식을 따라 적었고, 패킷트레이서 버전에 따라 조금 다를 수 있습니다.

| 단계 | 내용 | 언제 | 노트 |
|------|------|------|------|
| 0 | 작업 계획서 | 14:00 (20분) | README |
| 1 | 토폴로지 넓히기, HQ-SW2 기본 설정 | 함께 (8분) | 1 |
| 2 | VLAN 만들기 | 함께 (6분) | 1 |
| 3 | 포트 넣기, 쓰지 않는 포트 닫기 | 함께 (8분) | 1 |
| 4 | 트렁크 | 함께 (10분) | 2 |
| 5 | 라우터 서브인터페이스 | 함께 (13분) | 3 |
| 6 | 스위치 관리 주소 | 함께 (8분) | 3 |
| 7 | PC 주소와 확인 | 함께 (10분) | 3 |
| 8 | VTP transparent | 함께 (9분) | 4 |
| 9 | 내 회사 VLAN 설계 | 17:00 개인 (8분) | 1 |
| 10 | 내 회사 파일에 1~8번 | 개인 (25분) | 1~4 |
| 11 | 구성도와 설정 텍스트 | 개인 (12분) | |
| 12 | 결과 기록과 커밋 | 개인 (8분) | |

## 0. 작업 계획서 (14:00~14:20)

```bash
cd ~/my-netsec-project
git pull
```

VS Code에서 `00_작업계획/03일차.md` 를 만들고 [README](README.md)의 새봄상사 예시를 보며 1~5번 칸을 채웁니다.

```bash
git add .
git commit -m "3일차: 작업 계획서"
git push
```

## 1. 토폴로지 넓히기

`_실습/새봄상사.pkt` 를 엽니다. 2일차 함께 하는 실습이 끝난 상태입니다.

1. 2960 스위치 한 대를 더 놓고 이름을 HQ-SW2로 바꿉니다. 2층 스위치입니다.
2. HQ-SW1의 Gi0/2와 HQ-SW2의 Gi0/1을 잇습니다. 케이블은 번개 모양(자동)을 고르면 알맞은 종류로 이어 줍니다.
3. PC와 서버를 더합니다.

| 장비 | 이어 줄 곳 | 부서 |
|------|------------|------|
| HR-PC1 | HQ-SW1 Fa0/11 | 인사팀 |
| Server1 (Server-PT) | HQ-SW1 Fa0/21 | 서버 |
| Admin-PC | HQ-SW1 Fa0/24 | 장비 관리 |
| Dev-PC1 | HQ-SW2 Fa0/1 | 개발팀 |
| Sales-PC3 | HQ-SW2 Fa0/11 | 영업팀 (2층 자리) |

Sales-PC1(Fa0/1)과 Sales-PC2(Fa0/2)는 2일차 그대로 둡니다.

HQ-SW2에 2일차의 HQ-SW1과 같은 기본 잠금을 겁니다.

```
enable
configure terminal
hostname HQ-SW2
no ip domain-lookup
enable secret <실습용 비밀번호>
line console 0
 password <실습용 비밀번호>
 login
 exec-timeout 5 0
 exit
line vty 0 15
 password <실습용 비밀번호>
 login
 exec-timeout 5 0
 exit
service password-encryption
banner motd # Authorized access only. All access is logged. #
```

## 2. VLAN 만들기 (HQ-SW1, HQ-SW2 모두)

두 스위치에 똑같이 칩니다. 설정 모드에서 이어서 칩니다.

```
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
```

VLAN 30은 HQ-SW1에 포트가 없지만 만들어 둡니다. 트렁크로 지나가는 VLAN은 지나가는 스위치에도 있어야 합니다.

## 3. 포트 넣기, 쓰지 않는 포트 닫기

HQ-SW1입니다.

```
interface range fa0/1 - 10
 switchport mode access
 switchport access vlan 10
interface range fa0/11 - 15
 switchport mode access
 switchport access vlan 20
interface range fa0/21 - 22
 switchport mode access
 switchport access vlan 40
interface fa0/24
 switchport mode access
 switchport access vlan 99
interface range fa0/16 - 20 , fa0/23
 switchport mode access
 switchport access vlan 999
 shutdown
 exit
```

HQ-SW2입니다.

```
interface range fa0/1 - 10
 switchport mode access
 switchport access vlan 30
interface range fa0/11 - 12
 switchport mode access
 switchport access vlan 10
interface range fa0/13 - 24 , gi0/2
 switchport mode access
 switchport access vlan 999
 shutdown
 exit
```

확인합니다.

```
do show vlan brief
```

출력 읽는 법은 [1번 노트](lesson-1.md) 4번 절에 있습니다. 닫은 포트의 불빛이 빨강으로 바뀌면 됩니다.

## 4. 트렁크

HQ-SW1의 라우터 쪽(Gi0/1)입니다. native VLAN은 바꾸지 않습니다.

```
interface gi0/1
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30,40,99
 switchport nonegotiate
```

HQ-SW1의 2층 쪽(Gi0/2)입니다.

```
interface gi0/2
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30,40,99
 switchport trunk native vlan 900
 switchport nonegotiate
 end
```

여기까지 치고 잠시 기다리면 `%CDP-4-NATIVE_VLAN_MISMATCH` 알림이 뜹니다. HQ-SW2 쪽은 아직 native VLAN이 1이기 때문입니다. HQ-SW2의 Gi0/1에 같은 설정을 하면 알림이 멈춥니다.

```
interface gi0/1
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30,40,99
 switchport trunk native vlan 900
 switchport nonegotiate
 end
```

확인합니다.

```
show interfaces trunk
```

## 5. 라우터 서브인터페이스 (HQ-R1)

먼저 2일차에 Gi0/0에 준 주소를 지웁니다. 지우지 않고 서브인터페이스부터 치면 `overlaps with GigabitEthernet0/0` 오류가 납니다.

```
enable
configure terminal
interface gi0/0
 no ip address
 no shutdown
interface gi0/0.10
 description SALES
 encapsulation dot1Q 10
 ip address 192.168.10.1 255.255.255.224
interface gi0/0.20
 description HR
 encapsulation dot1Q 20
 ip address 192.168.10.33 255.255.255.224
interface gi0/0.30
 description DEV
 encapsulation dot1Q 30
 ip address 192.168.10.65 255.255.255.224
interface gi0/0.40
 description SERVER
 encapsulation dot1Q 40
 ip address 192.168.10.97 255.255.255.224
interface gi0/0.99
 description MGMT
 encapsulation dot1Q 99
 ip address 192.168.10.129 255.255.255.224
 end
show ip interface brief
```

```
Interface              IP-Address      OK? Method Status                Protocol
GigabitEthernet0/0     unassigned      YES manual up                    up
GigabitEthernet0/0.10  192.168.10.1    YES manual up                    up
GigabitEthernet0/0.20  192.168.10.33   YES manual up                    up
GigabitEthernet0/0.30  192.168.10.65   YES manual up                    up
GigabitEthernet0/0.40  192.168.10.97   YES manual up                    up
GigabitEthernet0/0.99  192.168.10.129  YES manual up                    up
```

## 6. 스위치 관리 주소

HQ-SW1입니다.

```
configure terminal
interface vlan 99
 ip address 192.168.10.130 255.255.255.224
 no shutdown
 exit
ip default-gateway 192.168.10.129
end
```

HQ-SW2는 주소만 192.168.10.131로 바꿔 똑같이 칩니다.

## 7. PC 주소와 확인

| 장비 | VLAN | IP 주소 | 서브넷 마스크 | 기본 게이트웨이 |
|------|------|---------|---------------|-----------------|
| Sales-PC1 | 10 | 192.168.10.2 | 255.255.255.224 | 192.168.10.1 |
| Sales-PC2 | 10 | 192.168.10.3 | 255.255.255.224 | 192.168.10.1 |
| Sales-PC3 | 10 | 192.168.10.4 | 255.255.255.224 | 192.168.10.1 |
| HR-PC1 | 20 | 192.168.10.34 | 255.255.255.224 | 192.168.10.33 |
| Dev-PC1 | 30 | 192.168.10.66 | 255.255.255.224 | 192.168.10.65 |
| Server1 | 40 | 192.168.10.98 | 255.255.255.224 | 192.168.10.97 |
| Admin-PC | 99 | 192.168.10.150 | 255.255.255.224 | 192.168.10.129 |

확인할 통신입니다.

| 어디서 | 어디로 | 명령 | 지나는 곳 |
|--------|--------|------|-----------|
| Sales-PC1 | Sales-PC3 | `ping 192.168.10.4` | 트렁크(같은 VLAN, 다른 스위치) |
| Sales-PC1 | HR-PC1 | `tracert 192.168.10.34` | 라우터(다른 VLAN). 첫 줄이 192.168.10.1 |
| Dev-PC1 | Server1 | `ping 192.168.10.98` | 트렁크 두 번과 라우터 |
| Admin-PC | HQ-SW1 | `telnet 192.168.10.130` | 같은 VLAN 99 |
| Admin-PC | HQ-SW2 | `telnet 192.168.10.131` | 트렁크 |
| Sales-PC1 | HQ-SW1 | `telnet 192.168.10.130` | 라우터. 지금은 되지만 10일차에 막는다 |

마지막으로 1번 노트 6번 절의 실험을 합니다. HR-PC1의 주소만 192.168.10.5로 바꾸고 `ping 192.168.10.2` 를 칩니다. 통하지 않으면 됩니다. 확인한 뒤 되돌립니다.

## 8. VTP transparent (HQ-SW1, HQ-SW2 모두)

바꾸기 전에 지금 상태를 봅니다.

```
show vtp status
show running-config | include vlan
```

`show vtp status` 의 VTP Operating Mode가 Server이고, running-config에는 `vlan 10` 같은 줄이 없습니다.

```
configure terminal
vtp mode transparent
end
show running-config | include vlan
copy running-config startup-config
```

이제 `vlan 10`, `vlan 20` 줄이 보입니다. 두 스위치와 라우터 모두 저장합니다.

## 9. 내 회사 VLAN 설계 (개인 실습)

`02_설계/IP_설계표.md` 의 설계표에 VLAN 칸을 더합니다. 부서 이름은 영어 대문자로 정합니다.

```markdown
| 위치 | 네트워크 | VLAN | VLAN 이름 | 대역 | 게이트웨이 | 스위치와 포트 | 인원과 장비 | 쓰는 날 |
```

`99` 장비 관리, `900` native, `999` 쓰지 않는 포트는 새봄상사와 같은 번호를 써도 됩니다.

## 10. 내 회사 파일에 1~8번

`_실습/새봄상사.pkt` 를 저장하고 닫은 뒤 `configs/network.pkt` 를 엽니다.

1. 1~8번을 내 설계표의 VLAN 이름과 주소로 칩니다. VLAN 번호(10, 20, 30, 40, 99, 900, 999)는 새봄상사와 같아도 됩니다.
2. 부서 이름은 내 회사 부서로 짓습니다(`name ACCOUNTING`).
3. 7번의 확인 표를 내 주소로 다시 해 봅니다.

## 11. 구성도와 설정 텍스트

1. 패킷트레이서 화면을 캡처합니다(Win+Shift+S).
2. VS Code에서 `02_설계/구성도.md` 를 만들고 캡처를 붙여 넣습니다(Ctrl+V). 같은 폴더에 그림 파일이 생기고 마크다운에 링크가 들어갑니다.
3. 그림 아래에 장비와 포트, VLAN을 표로 적습니다.
4. 장비 세 대에서 `terminal length 0` 과 `show running-config` 로 설정을 뽑아 `configs/HQ-R1.txt`, `configs/HQ-SW1.txt`, `configs/HQ-SW2.txt` 에 저장합니다.

```bash
git diff configs/HQ-R1.txt
```

Gi0/0의 주소가 빠지고 서브인터페이스가 생긴 줄이 보입니다.

## 12. 결과 기록과 커밋

`00_작업계획/03일차.md` 의 결과 칸을 채우고, README 진행 현황에 한 줄을 더합니다.

```markdown
| 3 | 부서별 VLAN, 트렁크, VLAN 사이 라우팅, 스위치 보안 | [작업 계획서](00_작업계획/03일차.md), [구성도](02_설계/구성도.md), [설정](configs/) |
```

```bash
git add .
git commit -m "3일차: 부서별 VLAN과 트렁크, 스위치 보안 설정"
git push
```

## 자주 막히는 곳

| 보이는 것 | 원인 | 해결 |
|-----------|------|------|
| `interface range fa0/1-10` 이 거절된다 | 하이픈 앞뒤 띄어쓰기 | `fa0/1 - 10` |
| `% Access VLAN does not exist. Creating vlan 10` | VLAN을 만들기 전에 포트에 넣었다 | 오류가 아니다. VLAN이 이름 없이 만들어진다. 2번으로 이름을 붙인다 |
| 같은 VLAN인데 다른 스위치와 안 통한다 | 트렁크가 한쪽만 설정됐거나, `allowed vlan` 에 빠졌거나, 반대 스위치에 VLAN이 없다 | `show interfaces trunk`, 양쪽 `show vlan brief` |
| `%CDP-4-NATIVE_VLAN_MISMATCH` 가 계속 뜬다 | native VLAN을 한쪽만 바꿨다 | 반대쪽 트렁크에도 `switchport trunk native vlan 900` |
| `overlaps with GigabitEthernet0/0` | Gi0/0에 2일차 주소가 남아 있다 | `interface gi0/0`, `no ip address` |
| 서브인터페이스에 주소가 안 들어간다 | `encapsulation` 보다 `ip address` 를 먼저 쳤다 | `encapsulation dot1Q` 부터 |
| 다른 VLAN과 안 통한다 | PC의 게이트웨이가 2일차 그대로(.1)다 | VLAN마다 게이트웨이가 다르다. 7번 표 |
| `interface vlan 99` 가 down | VLAN 99가 없거나 트렁크의 `allowed vlan` 에 99가 없다 | `show vlan brief`, `show interfaces trunk` |
| 관리자 PC에서 HQ-SW2 텔넷이 안 된다 | HQ-SW2에 VTY 비밀번호를 걸지 않았다 | 1번의 기본 잠금 |
| 다른 VLAN에서 스위치로 텔넷이 안 된다 | 스위치에 `ip default-gateway` 가 없다 | 6번 |
