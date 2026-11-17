# 0. 실습 명령어 모음

> 상위: [11일차 VPN과 IPv6](README.md)

수업 흐름 순서대로 적은 대본입니다. 1~12번은 `_실습/새봄상사.pkt` 에서 새봄상사의 주소로 강사와 함께 치고, 13~16번은 개인 실습에서 `configs/network.pkt` 를 열어 같은 일을 내 회사의 설계로 합니다. 인터넷 쪽 주소(지사 회선 203.0.113.4/30)는 모든 학생이 같은 것을 씁니다. 장비 화면의 출력 예시는 IOS 15 형식을 따라 적었고, 패킷트레이서 버전에 따라 조금 다를 수 있습니다.

| 단계 | 내용 | 언제 | 노트 |
|------|------|------|------|
| 0 | 작업 계획서, 사고 01 보고서 다듬기 | 14:00 (20분) | README |
| 1 | 보안 라이선스와 재시작 | 14:20 함께 (7분, 1번 노트와 겹쳐서) | 2 |
| 2 | 지사의 인터넷 회선, 터널 끝으로 가는 길 | 14:47 함께 (10분) | 2 |
| 3 | 터널 인터페이스 | 14:57 함께 (8분) | 2 |
| 4 | 터널 위로 OSPF | 15:05 함께 (8분) | 2 |
| 5 | 예비 회선 해지와 장애 시험 | 15:13 함께 (12분) | 2 |
| 6 | 시뮬레이션 모드로 GRE 상자 열기 | 15:35 함께 (8분) | 3 |
| 7 | IPSec 설정 | 15:51 함께 (14분) | 3 |
| 8 | crypto 확인 | 16:05 함께 (6분) | 3 |
| 9 | 다시 연 상자와 캡처 | 16:11 함께 (4분) | 3 |
| 10 | IPv6 듀얼 스택 시범 | 16:32 함께 (6분) | 4 |
| 11 | IPv4와 IPv6로 친 ping | 16:38 함께 (5분) | 4 |
| 12 | SALES-IN6 | 16:43 함께 (4분) | 4 |
| 13 | 내 회사 파일에 1~12번 | 17:00 개인 (25분) | 2~4 |
| 14 | 지사 연결 기록, VPN 정책, 설계표와 정책표 | 개인 (15분) | 3, 4 |
| 15 | 설정 텍스트 | 개인 (8분) | |
| 16 | 결과 기록과 커밋 | 개인 (10분) | |

## 0. 작업 계획서, 사고 01 보고서 다듬기 (14:00~14:20)

```bash
cd ~/my-netsec-project
git pull
```

사고 01 보고서의 원인, 재발 방지와 남은 위험, 교훈 칸을 다듬어 커밋합니다. 이어서 `00_작업계획/11일차.md` 의 1~5번 칸을 채워 커밋합니다.

```bash
git add .
git commit -m "11일차: 사고 01 보고서 다듬기, 작업 계획서"
git push
```

## 1. 보안 라이선스와 재시작

HQ-R1과 BR-R1에서 합니다. crypto 명령은 이 라이선스를 켜고 다시 시작해야 받아들여집니다. 먼저 저장합니다.

```
copy running-config startup-config
configure terminal
license boot module c2900 technology-package securityk9
```

약관 질문에 `yes` 를 칩니다.

```
end
copy running-config startup-config
reload
```

다시 켜진 뒤 `show version` 에서 securityk9가 켜져 있으면 됩니다.

## 2. 지사의 인터넷 회선, 터널 끝으로 가는 길

Serial DCE 케이블을 고르고 ISP-R1을 먼저 눌러 Se0/0/1에, 이어서 BR-R1의 Se0/0/1에 잇습니다.

ISP-R1입니다.

```
configure terminal
interface se0/0/1
 ip address 203.0.113.5 255.255.255.252
 clock rate 64000
 no shutdown
 end
```

BR-R1입니다.

```
configure terminal
interface se0/0/1
 description To ISP
 ip address 203.0.113.6 255.255.255.252
 no shutdown
 exit
ip route 203.0.113.2 255.255.255.255 203.0.113.5
 end
```

HQ-R1입니다.

```
configure terminal
ip route 203.0.113.6 255.255.255.255 203.0.113.1
 end
ping 203.0.113.6
```

## 3. 터널 인터페이스

HQ-R1입니다.

```
configure terminal
interface tunnel 0
 description GRE to BR-R1
 ip address 192.168.99.13 255.255.255.252
 tunnel source se0/0/1
 tunnel destination 203.0.113.6
 end
```

BR-R1입니다.

```
configure terminal
interface tunnel 0
 description GRE to HQ-R1
 ip address 192.168.99.14 255.255.255.252
 tunnel source se0/0/1
 tunnel destination 203.0.113.2
 end
ping 192.168.99.13
```

## 4. 터널 위로 OSPF

HQ-R1과 BR-R1 모두입니다.

```
configure terminal
router ospf 1
 network 192.168.99.12 0.0.0.3 area 0
 no passive-interface tunnel0
 exit
interface tunnel 0
 ip ospf authentication message-digest
 ip ospf message-digest-key 1 md5 <실습용 키>
 end
```

HQ-R1에만 하나 더 겁니다.

```
configure terminal
interface tunnel 0
 ip nat inside
 end
```

`show ip ospf neighbor` 에 Tunnel0 쪽 이웃(192.168.255.2)이 FULL로 더해지면 됩니다.

## 5. 예비 회선 해지와 장애 시험

HQ-R1과 BR-R1 모두 Se0/0/0을 끕니다.

```
configure terminal
interface se0/0/0
 description Backup serial (terminated, 11일차)
 shutdown
 end
```

BR-PC1에서 `ping -t 192.168.10.98` 을 걸어 두고 HQ-R1의 Gi0/1을 `shutdown` 합니다. 몇 번 끊긴 뒤 다시 Reply가 오면, 다음을 확인합니다.

| 어디서 | 명령 | 기대하는 결과 |
|--------|------|---------------|
| BR-R1 | `show ip route ospf` | 본사 대역이 `via 192.168.99.13, Tunnel0` |
| BR-PC1 | `tracert 192.168.10.98` | 192.168.20.1, 192.168.99.13, 192.168.10.98 |

끊긴 ping 개수를 세어 둔 뒤 Gi0/1을 `no shutdown` 합니다.

## 6. 시뮬레이션 모드로 GRE 상자 열기

1. 화면 오른쪽 아래에서 Simulation 모드로 바꿉니다.
2. Edit Filters에서 ICMP와 GRE만 보이게 합니다.
3. BR-PC1에서 `ping 192.168.10.98` 을 치고 Capture/Forward를 눌러 패킷을 ISP-R1까지 보냅니다.
4. ISP-R1에 머문 봉투를 눌러 PDU 정보를 엽니다. 겉 IP, GRE, 안의 IP, ICMP가 모두 보입니다.

이 화면을 캡처해 둡니다(암호화 전).

## 7. IPSec 설정

HQ-R1입니다.

```
configure terminal
crypto isakmp policy 10
 encryption aes 256
 hash sha
 authentication pre-share
 group 5
 exit
crypto isakmp key <실습용 키> address 203.0.113.6
crypto ipsec transform-set HQBR esp-aes 256 esp-sha-hmac
ip access-list extended VPN-HQBR
 permit gre host 203.0.113.2 host 203.0.113.6
 exit
crypto map VPNMAP 10 ipsec-isakmp
 set peer 203.0.113.6
 set transform-set HQBR
 match address VPN-HQBR
 exit
interface se0/0/1
 crypto map VPNMAP
 end
```

BR-R1은 세 군데만 바꿉니다. `crypto isakmp key ... address 203.0.113.2`, ACL은 `permit gre host 203.0.113.6 host 203.0.113.2`, `set peer 203.0.113.2` 입니다.

## 8. crypto 확인

BR-PC1에서 `ping 192.168.10.98` 을 몇 번 친 뒤 HQ-R1에서 봅니다.

```
show crypto isakmp sa
show crypto ipsec sa
```

`QM_IDLE` 과 `ACTIVE`, 그리고 `#pkts encrypt` 와 `#pkts decrypt` 가 0보다 크면 됩니다. 첫 ping 한두 개는 빠질 수 있습니다.

## 9. 다시 연 상자와 캡처

6번을 다시 합니다. ISP-R1에서 연 패킷에 겉 IP 다음으로 ESP만 보이면 됩니다. 이 화면을 캡처해 둡니다(암호화 뒤). Realtime 모드로 돌아옵니다.

설정을 바꾼 장비(HQ-R1, BR-R1, ISP-R1)를 저장합니다.

## 10. IPv6 듀얼 스택 시범

HQ-R1입니다.

```
configure terminal
ipv6 unicast-routing
interface gi0/0.10
 ipv6 address 2001:db8:10:10::1/64
interface gi0/0.20
 ipv6 address 2001:db8:10:20::1/64
 end
```

Sales-PC1과 HR-PC1의 IP Configuration에서 IPv6를 Automatic으로 바꿉니다. HR-PC1에 2001:db8:10:20::으로 시작하는 주소가 생기면 적어 둡니다.

## 11. IPv4와 IPv6로 친 ping

Sales-PC1에서 칩니다.

| 명령 | 기대하는 결과 |
|------|---------------|
| `ping 192.168.10.42` | 닿을 수 없음 (SALES-IN) |
| `ping (HR-PC1의 IPv6 주소)` | Reply |

## 12. SALES-IN6

HQ-R1입니다.

```
configure terminal
ipv6 access-list SALES-IN6
 deny ipv6 2001:db8:10:10::/64 2001:db8:10:20::/64 log
 permit ipv6 any any
 exit
interface gi0/0.10
 ipv6 traffic-filter SALES-IN6 in
 end
```

11번의 IPv6 ping을 다시 쳐서 막히면 됩니다. HQ-R1을 저장합니다.

## 13. 내 회사 파일에 1~12번 (개인 실습)

`_실습/새봄상사.pkt` 를 저장하고 닫은 뒤 `configs/network.pkt` 를 엽니다.

1. 1번(라이선스)을 가장 먼저 합니다. 재시작에 시간이 걸립니다.
2. 2~9번은 인터넷 쪽 주소를 그대로 쓰고, 터널 주소는 내 설계표의 다음 /30을 씁니다.
3. 10~12번은 내 회사 부서 두 곳으로 합니다. 시간이 모자라면 IPv6는 더 해 볼 것으로 넘깁니다.

## 14. 지사 연결 기록, VPN 정책, 설계표와 정책표

1. `03_구축/지사_연결.md` 에 "11일차: 예비 시리얼 회선 해지, 인터넷 VPN으로" 절을 더하고, 장애 시험 결과를 4일차, 6일차와 나란히 적습니다.
2. [3번 노트](lesson-3.md) 6번 절의 양식으로 `04_보안정책/VPN_정책.md` 를 만들고, 6번과 9번의 캡처를 붙입니다.
3. `02_설계/IP_설계표.md` 에 지사 인터넷 회선(203.0.113.4/30), 터널(192.168.99.12/30), IPv6 프리픽스를 더합니다.
4. `04_보안정책/ACL_정책표.md` 에 IPv6 줄을 더하거나, IPv6를 쓰지 않기로 했다면 그 결정을 적습니다.

## 15. 설정 텍스트

`configs/` 에 HQ-R1, BR-R1, ISP-R1의 설정 텍스트를 저장합니다. `crypto isakmp key` 줄에 실습용 키가 들어 있음을 확인합니다.

## 16. 결과 기록과 커밋

`00_작업계획/11일차.md` 의 결과 칸을 채우고, README 진행 현황에 한 줄을 더합니다.

```markdown
| 11 | 예비 회선을 GRE over IPSec VPN 으로, 암호화 전후 비교, IPv6 듀얼 스택과 IPv6 ACL | [작업 계획서](00_작업계획/11일차.md), [VPN 정책](04_보안정책/VPN_정책.md), [지사 연결](03_구축/지사_연결.md) |
```

```bash
git add .
git commit -m "11일차: 본사와 지사 VPN, IPv6"
git push
```

## 자주 막히는 곳

| 보이는 것 | 원인 | 해결 |
|-----------|------|------|
| `crypto` 명령이 거절된다 | 라이선스를 켜고 재시작하지 않았다 | 1번, `show version` |
| 재시작했더니 설정이 사라졌다 | 저장하지 않고 재시작했다 | 1번의 첫 줄과 마지막 저장 |
| 터널이 up/down이다 | 상대의 공인 주소로 가는 길이 없다 | 2번의 /32 경로 |
| `%TUN-5-RECURDOWN` 이 뜬다 | 터널 목적지로 가는 길이 터널을 가리킨다 | 2번의 /32 경로가 인터넷 쪽인지 |
| 터널 위에 OSPF 이웃이 안 생긴다 | `no passive-interface tunnel0` 을 빠뜨렸거나 양쪽 키가 다르다 | 4번 |
| 장애 때 지사가 인터넷에 못 나간다 | HQ-R1 Tunnel0에 `ip nat inside` 가 없다 | 4번 |
| `#pkts encrypt` 가 0이다 | VPN-HQBR의 주소가 틀렸거나 crypto map을 Se0/0/1에 안 걸었다 | 7번 |
| ISAKMP SA가 생기지 않는다 | 양쪽 key의 address나 키 값이 다르다 | `show crypto isakmp key` |
| PC에 IPv6 주소가 안 생긴다 | `ipv6 unicast-routing` 을 빠뜨렸다 | 10번 |
| `aes 256` 이나 `group 5` 가 거절된다 | 패킷트레이서 버전이 지원하지 않는다 | `aes`, `group 2` |
