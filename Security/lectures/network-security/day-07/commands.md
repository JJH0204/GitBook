# 0. 실습 명령어 모음

> 상위: [7일차 EIGRP와 재분배](README.md)

수업 흐름 순서대로 적은 대본입니다. 1~9번은 `_실습/새봄상사.pkt` 에서 새봄상사의 주소로 강사와 함께 치고(7번의 /28 시연은 강사만), 10~13번은 개인 실습에서 `configs/network.pkt` 를 열어 같은 일을 내 회사의 설계로 합니다. 인수한 회사(한결물류)의 주소와 설정은 모든 학생이 같은 것을 씁니다. 장비 화면의 출력 예시는 IOS 15 형식을 따라 적었고, 패킷트레이서 버전에 따라 조금 다를 수 있습니다.

| 단계 | 내용 | 언제 | 노트 |
|------|------|------|------|
| 0 | 작업 계획서 | 14:00 (20분) | README |
| 1 | 한결물류 장비와 받은 설정 | 14:50 함께 (10분) | 2 |
| 2 | 본사 Gi0/2 잇기 | 함께 (5분) | 2 |
| 3 | 본사에 EIGRP 20 | 함께 (5분) | 2 |
| 4 | 세 라우터 경로표 비교 | 함께 (10분) | 2 |
| 5 | 양방향 재분배 | 15:35 함께 (10분) | 3 |
| 6 | 확인, 무엇이 넘어갔나 | 함께 (15분) | 3 |
| 7 | 받을 것 고르기 | 16:10 함께 (13분) | 4 |
| 8 | 알릴 것 고르기 | 함께 (10분) | 4 |
| 9 | EIGRP 인증 | 함께 (7분) | 4 |
| 10 | 내 회사 파일에 1~9번 | 17:00 개인 (25분) | 2~4 |
| 11 | 인수회사 연결 기록 | 개인 (15분) | 4 |
| 12 | 설정 텍스트 | 개인 (8분) | |
| 13 | 결과 기록과 커밋 | 개인 (10분) | |

## 0. 작업 계획서 (14:00~14:20)

```bash
cd ~/my-netsec-project
git pull
```

`00_작업계획/07일차.md` 를 만들고 1~5번 칸을 채워 커밋합니다.

```bash
git add .
git commit -m "7일차: 작업 계획서"
git push
```

## 1. 한결물류 장비와 받은 설정

2911 라우터(LC-R1), 2960 스위치(LC-SW1), PC 한 대(LC-PC1)를 화면 아래쪽에 놓습니다. LC-R1의 Gi0/0과 LC-SW1의 Gi0/1, LC-PC1과 LC-SW1의 Fa0/1을 잇습니다.

LC-R1에 "인수할 때 받은 설정"을 그대로 붙여 넣습니다.

```
enable
configure terminal
hostname LC-R1
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
interface gi0/0
 description Hangyeol LAN
 ip address 172.16.10.1 255.255.255.0
 no shutdown
interface gi0/1
 description To Saebom HQ
 ip address 192.168.99.10 255.255.255.252
 no shutdown
router eigrp 20
 network 172.16.10.0 0.0.0.255
 network 192.168.99.8 0.0.0.3
 no auto-summary
 end
```

LC-SW1은 받은 그대로(아무 설정 없음) 둡니다. 아직 새봄상사가 관리하지 않는 망이라는 뜻입니다. LC-PC1은 172.16.10.10/24, 게이트웨이 172.16.10.1입니다.

## 2. 본사 Gi0/2 잇기

HQ-R1의 Gi0/2와 LC-R1의 Gi0/1을 잇습니다.

```
configure terminal
interface gi0/2
 description To Hangyeol LC-R1
 ip address 192.168.99.9 255.255.255.252
 no shutdown
 end
ping 192.168.99.10
```

## 3. 본사에 EIGRP 20

```
configure terminal
router eigrp 20
 network 192.168.99.8 0.0.0.3
 no auto-summary
 end
```

`%DUAL-5-NBRCHANGE: EIGRP-IPv4 20: Neighbor 192.168.99.10 (GigabitEthernet0/2) is up` 알림이 뜨면 이웃이 된 것입니다.

## 4. 세 라우터 경로표 비교

```
HQ-R1#show ip eigrp neighbors
HQ-R1#show ip route eigrp
BR-R1#show ip route
LC-R1#show ip route
```

| 라우터 | 찾을 것 |
|--------|---------|
| HQ-R1 | `D 172.16.10.0/24 [90/...] via 192.168.99.10` |
| BR-R1 | 172.16.10.0/24가 없다 |
| LC-R1 | 192.168.10.x가 없다 |

LC-PC1에서 `ping 192.168.10.98` 을 치면 172.16.10.1이 `Destination host unreachable` 로 답합니다.

## 5. 양방향 재분배 (거르지 않고)

HQ-R1입니다.

```
configure terminal
router eigrp 20
 redistribute ospf 1 metric 100000 100 255 1 1500
router ospf 1
 redistribute eigrp 20 subnets
 end
```

## 6. 확인, 무엇이 넘어갔나

```
BR-R1#show ip route ospf
LC-R1#show ip route eigrp
```

BR-R1에 `O E2 172.16.10.0/24`, LC-R1에 `D EX` 줄이 여러 개 생깁니다. LC-PC1에서 서버(192.168.10.98)와 인사팀 PC(192.168.10.34)로 ping을 칩니다. 둘 다 됩니다. LC-R1의 D EX 줄을 [3번 노트](lesson-3.md) 4번 절의 표와 맞춰 봅니다.

## 7. 받을 것 고르기

강사 시연부터 합니다. 강사의 LC-R1에 서버 대역의 /28을 알리게 합니다.

```
LC-R1(config)#interface loopback 5
LC-R1(config-if)#ip address 192.168.10.97 255.255.255.240
LC-R1(config-if)#router eigrp 20
LC-R1(config-router)#network 192.168.10.96 0.0.0.15
```

HQ-R1의 `show ip route eigrp` 에 `D 192.168.10.96/28 via 192.168.99.10` 이 생깁니다. 이제 HQ-R1에 받을 것 목록을 겁니다(학생도 여기부터 함께 칩니다).

```
configure terminal
ip prefix-list LC-IN seq 10 permit 172.16.10.0/24
router eigrp 20
 distribute-list prefix LC-IN in gi0/2
 end
clear ip route *
show ip route eigrp
```

`D 172.16.10.0/24` 만 남고 /28이 사라지면 됩니다. 강사는 시연이 끝나면 LC-R1의 loopback 5와 그 network 줄을 지웁니다.

## 8. 알릴 것 고르기

```
configure terminal
ip prefix-list TO-LC seq 10 permit 192.168.10.96/27
route-map TO-LC permit 10
 match ip address prefix-list TO-LC
 exit
router eigrp 20
 redistribute ospf 1 metric 100000 100 255 1 1500 route-map TO-LC
 end
```

LC-R1에서 `show ip route eigrp` 를 보면 `D EX 192.168.10.96/27` 한 줄만 남습니다. 몇 초 걸리면 LC-R1에서 `clear ip route *` 를 칩니다. LC-PC1에서 서버로는 ping이 되고, 인사팀으로는 `Destination host unreachable` 이 나옵니다.

## 9. EIGRP 인증

HQ-R1과 LC-R1 모두에 같은 열쇠고리를 만들고, HQ-R1은 Gi0/2, LC-R1은 Gi0/1에 겁니다.

```
configure terminal
key chain EIGRPKEY
 key 1
  key-string <실습용 키>
  exit
 exit
interface gi0/2
 ip authentication mode eigrp 20 md5
 ip authentication key-chain eigrp 20 EIGRPKEY
 end
```

LC-R1에서는 `interface gi0/1` 로 바꿔 칩니다. 한쪽만 걸었을 때 이웃이 끊겼다가, 양쪽에 걸면 `Neighbor ... is up` 이 다시 뜹니다. 네 장비를 모두 저장합니다.

## 10. 내 회사 파일에 1~9번 (개인 실습)

`_실습/새봄상사.pkt` 를 저장하고 닫은 뒤 `configs/network.pkt` 를 엽니다.

1. 1번의 한결물류 장비와 설정은 그대로 씁니다.
2. 2~9번을 내 본사 라우터와 내 연결 대역으로 칩니다. 7번의 /28 시연은 하지 않습니다.
3. TO-LC에는 내 회사에서 한결물류가 써야 할 서버 VLAN을 적습니다.

## 11. 인수회사 연결 기록

1. [4번 노트](lesson-4.md) 7번 절의 양식으로 `03_구축/인수회사_연결.md` 를 씁니다.
2. `02_설계/IP_설계표.md` 에 한결물류 연결 구간(/30)과 한결물류 대역(172.16.10.0/24, 우리가 관리하지 않음)을 더합니다.

## 12. 설정 텍스트

`configs/` 에 HQ-R1, BR-R1, LC-R1의 설정 텍스트를 저장합니다. LC-R1은 새로 생기는 파일입니다.

## 13. 결과 기록과 커밋

`00_작업계획/07일차.md` 의 결과 칸을 채우고, README 진행 현황에 한 줄을 더합니다.

```markdown
| 7 | 인수한 회사(EIGRP)와 재분배, 경계 필터와 인증 | [작업 계획서](00_작업계획/07일차.md), [인수회사 연결](03_구축/인수회사_연결.md), [설정](configs/) |
```

```bash
git add .
git commit -m "7일차: 인수한 회사와 재분배, 경계 필터"
git push
```

## 자주 막히는 곳

| 보이는 것 | 원인 | 해결 |
|-----------|------|------|
| EIGRP 이웃이 안 생긴다 | AS 번호가 다르거나(20) 연결 구간이 `network` 에 없다 | `show ip protocols` |
| 지사에 한결물류 경로가 없다 | OSPF로 재분배하지 않았거나 `subnets` 를 빠뜨렸다 | `router ospf 1` 의 `redistribute eigrp 20 subnets` |
| 한결물류에 아무 경로도 안 간다 | EIGRP로 재분배할 때 `metric` 을 빠뜨렸다 | 5번의 metric 다섯 값 |
| `ip prefix-list` 나 `distribute-list prefix` 가 거절된다 | 패킷트레이서 버전이 지원하지 않는다 | 표준 ACL로 대신: `access-list 10 permit 172.16.10.0 0.0.0.255`, `distribute-list 10 in gi0/2` |
| route-map을 걸었더니 한결물류 경로표가 비었다 | prefix-list TO-LC의 대역이 틀렸다 | `show ip prefix-list` 로 확인 |
| 필터를 걸었는데 경로표가 그대로다 | 이미 받은 경로가 남아 있다 | `clear ip route *` |
| 인증 뒤 이웃이 안 돌아온다 | 키 값이나 AS 번호(eigrp 20)가 다르다 | 양쪽 명령의 `eigrp 20` 과 key-string |
