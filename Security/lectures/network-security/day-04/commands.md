# 0. 실습 명령어 모음

> 상위: [4일차 정적 라우팅과 지사 연결](README.md)

수업 흐름 순서대로 적은 대본입니다. 1~7번은 `_실습/새봄상사.pkt` 에서 새봄상사의 주소로 강사와 함께 치고, 8~11번은 개인 실습에서 `configs/network.pkt` 를 열어 같은 일을 내 회사의 설계로 합니다. 장비 화면의 출력 예시는 IOS 15 형식을 따라 적었고, 패킷트레이서 버전에 따라 조금 다를 수 있습니다.

| 단계 | 내용 | 언제 | 노트 |
|------|------|------|------|
| 0 | 작업 계획서 | 14:00 (20분) | README |
| 1 | 지사 장비 놓기와 잠금 | 함께 (10분) | 2 |
| 2 | 주소 주기 | 함께 (7분) | 2 |
| 3 | 정적 경로와 기본 경로 | 함께 (13분) | 2 |
| 4 | 확인 | 함께 (5분) | 2 |
| 5 | 시리얼 모듈과 예비 회선 | 함께 (15분) | 3 |
| 6 | 플로팅 정적 경로 | 함께 (8분) | 3 |
| 7 | 장애 시험 | 함께 (13분) | 3 |
| 8 | 내 회사 지사 주소 | 17:00 개인 (5분) | 2 |
| 9 | 내 회사 파일에 1~7번 | 개인 (25분) | 2, 3 |
| 10 | 장애 시험 기록과 설정 텍스트 | 개인 (20분) | 4 |
| 11 | 결과 기록과 커밋 | 개인 (10분) | |

## 0. 작업 계획서 (14:00~14:20)

```bash
cd ~/my-netsec-project
git pull
mkdir 03_구축
```

VS Code에서 `00_작업계획/04일차.md` 를 만들고 [README](README.md)의 새봄상사 예시를 보며 1~5번 칸을 채웁니다.

```bash
git add .
git commit -m "4일차: 작업 계획서"
git push
```

## 1. 지사 장비 놓기와 잠금

먼저 Options, Preferences에서 Always Show Port Labels를 켭니다. 오늘부터 포트가 많아집니다.

1. 2911 라우터(BR-R1), 2960 스위치(BR-SW1), PC 두 대(BR-PC1, BR-PC2)를 화면 오른쪽에 놓습니다.
2. HQ-R1의 Gi0/1과 BR-R1의 Gi0/1을 잇습니다(번개 모양 케이블).
3. BR-R1의 Gi0/0과 BR-SW1의 Gi0/1을 잇고, BR-PC1을 Fa0/1에, BR-PC2를 Fa0/2에 잇습니다.

BR-R1에 2일차의 잠금을 겁니다. `hostname` 만 BR-R1로 바꿉니다.

```
enable
configure terminal
hostname BR-R1
no ip domain-lookup
enable secret <실습용 비밀번호>
line console 0
 password <실습용 비밀번호>
 login
 exec-timeout 5 0
 exit
line vty 0 4
 password <실습용 비밀번호>
 login
 exec-timeout 5 0
 exit
service password-encryption
banner motd # Authorized access only. All access is logged. #
```

BR-SW1에는 같은 잠금(VTY는 `line vty 0 15`)에 3일차의 스위치 보안을 더합니다.

```
vtp mode transparent
vlan 10
 name SALES
vlan 999
 name UNUSED
interface range fa0/1 - 10 , gi0/1
 switchport mode access
 switchport access vlan 10
interface range fa0/11 - 24 , gi0/2
 switchport mode access
 switchport access vlan 999
 shutdown
 end
```

지사 라우터와 스위치 사이(Gi0/1)는 트렁크가 아니라 VLAN 10의 access 포트입니다. 지사에는 부서가 하나뿐이라 라우터가 태그를 다룰 필요가 없습니다.

## 2. 주소 주기

HQ-R1입니다.

```
configure terminal
interface gi0/1
 description To BR-R1 primary
 ip address 192.168.99.1 255.255.255.252
 no shutdown
 end
```

BR-R1입니다.

```
configure terminal
interface gi0/0
 description BR Sales LAN
 ip address 192.168.20.1 255.255.255.224
 no shutdown
interface gi0/1
 description To HQ-R1 primary
 ip address 192.168.99.2 255.255.255.252
 no shutdown
 end
```

PC입니다.

| PC | IP 주소 | 서브넷 마스크 | 기본 게이트웨이 |
|----|---------|---------------|-----------------|
| BR-PC1 | 192.168.20.2 | 255.255.255.224 | 192.168.20.1 |
| BR-PC2 | 192.168.20.3 | 255.255.255.224 | 192.168.20.1 |

BR-R1에서 `ping 192.168.99.1` 이 되면 두 라우터가 이어진 것입니다.

## 3. 정적 경로와 기본 경로

먼저 본사에만 지사로 가는 길을 넣습니다.

```
HQ-R1(config)#ip route 192.168.20.0 255.255.255.224 192.168.99.2
```

BR-PC1에서 본사 서버로 ping을 칩니다.

```
C:\>ping 192.168.10.98

Reply from 192.168.20.1: Destination host unreachable.
```

답한 쪽이 지사 라우터(192.168.20.1)입니다. 지사 라우터가 본사로 가는 길을 모릅니다. 이제 지사에 기본 경로를 넣습니다.

```
BR-R1(config)#ip route 0.0.0.0 0.0.0.0 192.168.99.1
```

다시 ping을 치면 Reply가 옵니다.

## 4. 확인

```
C:\>tracert 192.168.10.98
```

세 칸(192.168.20.1, 192.168.99.1, 192.168.10.98)이 보이면 됩니다. 두 라우터에서 경로표를 봅니다.

```
show ip route
show ip route static
```

`show ip route static` 은 S 줄만 골라 보여 줍니다. 본사에는 `S 192.168.20.0/27 [1/0] via 192.168.99.2`, 지사에는 `S* 0.0.0.0/0 [1/0] via 192.168.99.1` 이 있어야 합니다.

## 5. 시리얼 모듈과 예비 회선

두 라우터 모두 같은 순서로 합니다.

1. `copy running-config startup-config` 로 저장합니다.
2. 라우터를 누르고 Physical 탭에서 전원 스위치를 끕니다.
3. 왼쪽 목록의 HWIC-2T를 빈 슬롯으로 끌어다 넣습니다.
4. 전원을 켜고 부팅을 기다립니다.

Serial DCE 케이블을 고르고 HQ-R1을 먼저 눌러 Se0/0/0에, 이어서 BR-R1의 Se0/0/0에 잇습니다. 먼저 누른 HQ-R1 쪽이 DCE가 됩니다.

HQ-R1입니다.

```
configure terminal
interface se0/0/0
 description To BR-R1 backup
 ip address 192.168.99.5 255.255.255.252
 clock rate 64000
 no shutdown
 end
```

BR-R1입니다.

```
configure terminal
interface se0/0/0
 description To HQ-R1 backup
 ip address 192.168.99.6 255.255.255.252
 no shutdown
 end
```

`show controllers serial 0/0/0` 에서 DCE로 나오는 쪽에만 `clock rate` 를 넣습니다. 이미 clock rate가 들어 있으면 그대로 둡니다. HQ-R1에서 `ping 192.168.99.6` 이 되면 예비 회선이 이어진 것입니다.

## 6. 플로팅 정적 경로

```
HQ-R1(config)#ip route 192.168.20.0 255.255.255.224 192.168.99.6 250
BR-R1(config)#ip route 0.0.0.0 0.0.0.0 192.168.99.5 250
```

`show ip route static` 을 보면 예비 경로는 아직 보이지 않습니다. 주 경로(관리 거리 1)가 살아 있는 동안에는 표에 오르지 않는 것이 정상입니다. 설정에 들어갔는지는 `show running-config | include ip route` 로 봅니다.

## 7. 장애 시험

BR-PC1에서 멈추지 않는 ping을 겁니다.

```
C:\>ping -t 192.168.10.98
```

HQ-R1에서 주 회선을 끕니다.

```
configure terminal
interface gi0/1
 shutdown
 end
show ip route static
```

`[250/0] via 192.168.99.6` 이 보이고 BR-PC1의 ping이 몇 번 끊겼다가 돌아오면 성공입니다. 빠진 개수를 셉니다. 확인한 뒤 주 회선을 살립니다.

```
configure terminal
interface gi0/1
 no shutdown
 end
```

BR-PC1의 ping은 Ctrl+C로 멈춥니다. 세 장비를 모두 저장합니다.

## 8. 내 회사 지사 주소 (개인 실습)

`02_설계/IP_설계표.md` 에 예비 회선 줄을 더합니다. 본사와 지사 연결 /30 다음의 /30을 씁니다.

```markdown
| 연결 | 본사와 지사 예비 | 192.168.__.4/30 | 없음 | .5 본사, .6 지사 | 시리얼 | 4일차 |
```

## 9. 내 회사 파일에 1~7번

`_실습/새봄상사.pkt` 를 저장하고 닫은 뒤 `configs/network.pkt` 를 엽니다.

1. 1~7번을 내 설계표의 주소로 칩니다. 장비 이름과 포트는 새봄상사와 같아도 됩니다.
2. 경로를 잘못 넣었으면 앞에 `no` 를 붙여 같은 줄을 쳐서 지웁니다.

```
no ip route 192.168.20.0 255.255.255.224 192.168.99.2
```

3. 4번의 확인을 내 주소로 다시 합니다.

## 10. 장애 시험 기록과 설정 텍스트

1. 9번에서 한 장애 시험의 끄기 전과 뒤 `show ip route static` 을 복사해 둡니다.
2. [4번 노트](lesson-4.md) 5번 절의 양식으로 `03_구축/지사_연결.md` 를 씁니다.
3. `configs/` 에 HQ-R1, BR-R1, BR-SW1의 설정 텍스트를 저장합니다.

```bash
git diff configs/HQ-R1.txt
```

Gi0/1, Se0/0/0과 `ip route` 줄이 더해진 것이 보입니다.

## 11. 결과 기록과 커밋

`00_작업계획/04일차.md` 의 결과 칸을 채우고, README 진행 현황에 한 줄을 더합니다.

```markdown
| 4 | 지사 연결, 정적 경로, 예비 회선, 장애 시험 | [작업 계획서](00_작업계획/04일차.md), [지사 연결](03_구축/지사_연결.md), [설정](configs/) |
```

```bash
git add .
git commit -m "4일차: 지사 연결과 정적 경로, 예비 회선 장애 시험"
git push
```

## 자주 막히는 곳

| 보이는 것 | 원인 | 해결 |
|-----------|------|------|
| 두 라우터 사이 ping이 안 된다 | 한쪽 포트를 켜지 않았거나 /30 마스크를 틀렸다 | `show ip interface brief`, 마스크 255.255.255.252 |
| 지사 PC에서 `Destination host unreachable` (192.168.20.1이 답함) | 지사 라우터에 본사로 가는 길이 없다 | 3번의 기본 경로 |
| 지사 PC에서 `Request timed out` | 갔는데 돌아오지 못한다. 본사에 지사로 가는 길이 없다 | 본사의 `ip route 192.168.20.0 ...` |
| `% Invalid next hop address` | 다음 장비 자리에 내 주소를 적었다 | 상대 라우터의 주소를 적는다 |
| 모듈을 꽂았더니 설정이 사라졌다 | 저장하지 않고 전원을 껐다 | 2~4번을 다시 치고, 이번에는 저장 먼저 |
| HWIC-2T가 들어가지 않는다 | 전원이 켜져 있다 | Physical 탭에서 전원을 끈다 |
| 시리얼 회선이 down | DCE 쪽에 clock rate가 없거나 한쪽이 꺼져 있다 | `show controllers serial 0/0/0`, `no shutdown` |
| 예비 경로가 경로표에 없다 | 주 회선이 살아 있어서다 | 정상. `show running-config` 로 들어갔는지 본다 |
| 주 회선을 끊어도 넘어가지 않는다 | 예비 회선이 down이거나 예비 경로의 다음 장비 주소가 틀렸다 | 예비 회선으로 직접 ping |
