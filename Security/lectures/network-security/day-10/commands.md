# 0. 실습 명령어 모음

> 상위: [10일차 ACL과 첫 침해사고](README.md)

수업 흐름 순서대로 적은 대본입니다. 1~12번은 `_실습/새봄상사.pkt` 에서 새봄상사의 주소로 강사와 함께 치고, 13~16번은 개인 실습에서 `configs/network.pkt` 를 열어 같은 일을 내 회사의 설계로 합니다. 6번의 한결물류 관리자 역할(정적 경로)은 강사가 수업 전에 미리 해 두고, 학생은 자기 파일에서 직접 합니다. 장비 화면의 출력 예시는 IOS 15 형식을 따라 적었고, 패킷트레이서 버전에 따라 조금 다를 수 있습니다.

| 단계 | 내용 | 언제 | 노트 |
|------|------|------|------|
| 0 | 작업 계획서 | 14:00 (20분) | README |
| 1 | NAT-INSIDE에 줄 끼워 넣기 | 14:40 함께 (5분) | 1 |
| 2 | SALES-IN 만들기 | 14:53 함께 (8분) | 2 |
| 3 | 두 곳에 걸기 | 15:01 함께 (6분) | 2 |
| 4 | 확인과 장애 시험 | 15:07 함께 (8분) | 2 |
| 5 | access-class | 15:15 함께 (10분) | 2 |
| 6 | 한결물류의 정적 경로, 감시용 ACL | 15:40 함께 (7분) | 3 |
| 7 | 탐지 | 15:47 함께 (8분) | 3 |
| 8 | 증거 저장 | 15:55 함께 (5분) | 3 |
| 9 | LC-IN으로 바꾸기 | 16:00 함께 (7분) | 3 |
| 10 | EIGRP 복구와 확인 | 16:07 함께 (5분) | 3 |
| 11 | LC-OUT의 reflect | 16:30 함께 (6분) | 4 |
| 12 | evaluate와 확인 | 16:36 함께 (6분) | 4 |
| 13 | 내 회사 파일에 1~10번 | 17:00 개인 (25분) | 1~3 |
| 14 | 사고 01 보고서 | 개인 (20분) | 3 |
| 15 | 정책표와 설정 텍스트 | 개인 (5분) | 2 |
| 16 | 결과 기록과 커밋 | 개인 (10분) | |

## 0. 작업 계획서 (14:00~14:20)

```bash
cd ~/my-netsec-project
git pull
```

`00_작업계획/10일차.md` 를 만들고 1~5번 칸을 채워 커밋합니다. 되돌리는 방법 칸에 "ACL을 걸 포트에서 `no ip access-group` 으로 떼면 바로 원래대로"를 꼭 적습니다.

```bash
git add .
git commit -m "10일차: 작업 계획서"
git push
```

## 1. NAT-INSIDE에 줄 끼워 넣기

HQ-R1입니다.

```
configure terminal
ip access-list standard NAT-INSIDE
 5 deny 192.168.10.128 0.0.0.31
 end
show access-lists NAT-INSIDE
```

5번 줄이 10번 줄 위에 보이면 됩니다.

## 2. SALES-IN 만들기

HQ-DSW1과 HQ-R1 두 장비에 똑같이 칩니다.

```
configure terminal
ip access-list extended SALES-IN
 10 permit ip 192.168.10.0 0.0.0.31 192.168.10.96 0.0.0.31
 20 deny ip 192.168.10.0 0.0.0.31 192.168.10.32 0.0.0.31 log
 30 deny ip 192.168.10.0 0.0.0.31 192.168.10.64 0.0.0.31 log
 40 deny ip 192.168.10.0 0.0.0.31 192.168.10.128 0.0.0.31 log
 50 permit ip any any
 end
```

## 3. 두 곳에 걸기

HQ-DSW1입니다.

```
configure terminal
interface vlan 10
 ip access-group SALES-IN in
 end
```

HQ-R1입니다.

```
configure terminal
interface gi0/0.10
 ip access-group SALES-IN in
 end
```

## 4. 확인과 장애 시험

Sales-PC1에서 칩니다. HR-PC1의 주소는 HR-PC1의 `ipconfig` 로 먼저 확인합니다(8일차 DHCP로 192.168.10.42).

| 시험 | 기대하는 결과 |
|------|---------------|
| `ping 192.168.10.98` (서버) | Reply |
| `ping 192.168.10.42` (인사팀) | 닿을 수 없음 (`Destination ... unreachable` 또는 `Request timed out`) |
| `ping 198.51.100.10` (인터넷) | Reply |

HQ-DSW1에서 `show access-lists SALES-IN` 을 보고 20번 줄의 적중 횟수를 기억합니다. 이어서 8일차 장애 시험을 합니다.

```
HQ-DSW1(config)#interface gi0/1
HQ-DSW1(config-if)#shutdown
```

HQ-R1이 Active가 된 뒤 Sales-PC1에서 인사팀으로 다시 ping을 칩니다. 여전히 막히고, 이번에는 HQ-R1의 `show access-lists SALES-IN` 20번 줄 횟수가 늘어나면 됩니다. 확인한 뒤 `no shutdown` 으로 되돌립니다.

## 5. access-class

여섯 장비(HQ-R1, BR-R1, HQ-DSW1, HQ-SW1, HQ-SW2, BR-SW1)에 겁니다. 라우터는 `line vty 0 4`, 스위치는 `line vty 0 15` 입니다. CLI 탭(콘솔)에서 칩니다.

```
configure terminal
ip access-list standard MGMT-ONLY
 permit host 192.168.10.150
 exit
line vty 0 4
 access-class MGMT-ONLY in
 end
```

| 어디서 | 명령 | 기대하는 결과 |
|--------|------|---------------|
| Admin-PC | `telnet 192.168.10.130` | 비밀번호 창 |
| Sales-PC1 | `telnet 192.168.10.29` | 연결 거부 |
| NET-PC | `telnet 203.0.113.2` | 연결 거부 |

## 6. 한결물류의 정적 경로, 감시용 ACL

학생은 먼저 한결물류 관리자 역할로 LC-R1에 칩니다. 강사는 수업 전에 해 두었습니다.

```
LC-R1(config)#ip route 192.168.10.0 255.255.255.0 192.168.99.9
```

이제 새봄상사 담당자로 돌아와 HQ-R1에 칩니다.

```
configure terminal
ip access-list extended LC-WATCH
 10 permit eigrp host 192.168.99.10 any
 20 permit ip 172.16.10.0 0.0.0.255 192.168.10.96 0.0.0.31
 30 permit ip any any log
 exit
interface gi0/2
 ip access-group LC-WATCH in
 end
```

## 7. 탐지

한결물류 직원 역할로 LC-PC1에서 `ping 192.168.10.42` 를 칩니다. HQ-R1의 화면에 `%SEC-6-IPACCESSLOGDP: list LC-WATCH permitted icmp 172.16.10.10 -> 192.168.10.42 ...` 줄이 뜹니다.

```
HQ-R1#show access-lists LC-WATCH
```

30번 줄의 적중 횟수가 0이 아니면 업무 밖의 통신이 있다는 뜻입니다. 로그가 뜨지 않는 버전이면 적중 횟수만으로 판단합니다.

## 8. 증거 저장

고치기 전에 화면을 텍스트로 옮겨 둡니다. VS Code에서 `05_진단과_대응/증거/` 폴더를 만들고 세 파일에 붙여 넣습니다.

| 파일 | 붙여 넣을 것 |
|------|--------------|
| `01_acl_log.txt` | 7번의 로그 줄과 그때의 시각 |
| `01_acl_count.txt` | `show access-lists LC-WATCH` |
| `01_lc-r1_route.txt` | LC-R1의 `show ip route static` |

## 9. LC-IN으로 바꾸기

```
configure terminal
ip access-list extended LC-IN
 10 permit ip 172.16.10.0 0.0.0.255 192.168.10.96 0.0.0.31
 20 deny ip any any log
 exit
interface gi0/2
 no ip access-group LC-WATCH in
 ip access-group LC-IN in
 end
```

15초쯤 기다리면 `%DUAL-5-NBRCHANGE: EIGRP-IPv4 20: Neighbor 192.168.99.10 (GigabitEthernet0/2) is down: holding time expired` 가 뜹니다. 이 줄과 시각도 `증거/01_eigrp_down.txt` 에 붙여 넣습니다.

## 10. EIGRP 복구와 확인

```
configure terminal
ip access-list extended LC-IN
 5 permit eigrp host 192.168.99.10 any
 end
```

`Neighbor 192.168.99.10 ... is up` 이 뜨면 확인합니다.

| 어디서 | 명령 | 기대하는 결과 |
|--------|------|---------------|
| LC-PC1 | `ping 192.168.10.42` | 닿을 수 없음 |
| LC-PC1 | `ping 192.168.10.98` | Reply |
| HQ-R1 | `show ip eigrp neighbors` | 192.168.99.10 |
| HQ-R1 | `show access-lists LC-IN` | 20번 줄에 적중 |

결과를 `증거/01_after.txt` 에 붙여 넣습니다.

## 11. LC-OUT의 reflect

먼저 BR-PC1에서 `ping 172.16.10.10` 을 쳐 답이 오지 않는 것을 봅니다. HQ-R1입니다.

```
configure terminal
ip access-list extended LC-OUT
 permit tcp any any reflect LC-RETURN
 permit udp any any reflect LC-RETURN
 permit icmp any any reflect LC-RETURN
 exit
interface gi0/2
 ip access-group LC-OUT out
 end
```

## 12. evaluate와 확인

```
configure terminal
ip access-list extended LC-IN
 15 evaluate LC-RETURN
 end
```

| 어디서 | 명령 | 기대하는 결과 |
|--------|------|---------------|
| BR-PC1 | `ping 172.16.10.10` | Reply |
| HQ-R1 | `show access-lists` | Reflexive IP access list LC-RETURN에 임시 줄과 time left |
| LC-PC1 | `ping 192.168.10.42` | 여전히 닿을 수 없음 |

설정을 바꾼 장비(HQ-R1, HQ-DSW1, BR-R1, 스위치 세 대, LC-R1)를 모두 저장합니다.

```
copy running-config startup-config
```

## 13. 내 회사 파일에 1~10번 (개인 실습)

`_실습/새봄상사.pkt` 를 저장하고 닫은 뒤 `configs/network.pkt` 를 엽니다.

1. 1번과 5번은 내 회사 주소로 그대로 합니다.
2. 2~4번은 내 회사 부서 하나의 ACL을 정책표로 먼저 정한 뒤, 게이트웨이 두 장비에 겁니다.
3. 6~10번은 한결물류 관리자 역할부터 합니다. 증거 파일을 꼭 남깁니다.
4. 11, 12번(Reflexive)은 시간이 남으면 합니다.

## 14. 사고 01 보고서

[양식](../incident-report.md)을 복사해 `05_진단과_대응/사고_01_인수회사_우회접근.md` 를 만듭니다. 오늘은 요약, 탐지, 타임라인, 분석까지 채웁니다. 원인, 재발 방지, 교훈은 11일차 작업 계획서 시간에 다듬습니다. `01_요구사항/인수회사_연결_규정.md` 도 세 줄로 씁니다.

## 15. 정책표와 설정 텍스트

`04_보안정책/ACL_정책표.md` 를 만들고 [2번 노트](lesson-2.md) 1번 절의 표를 내 회사로 씁니다. `configs/` 에 설정을 바꾼 장비의 텍스트를 저장합니다.

## 16. 결과 기록과 커밋

`00_작업계획/10일차.md` 의 결과 칸을 채우고, README 진행 현황에 한 줄을 더합니다.

```markdown
| 10 | ACL 정책표, 부서 ACL, access-class, 사고 01 (인수회사 우회 접근) | [작업 계획서](00_작업계획/10일차.md), [정책표](04_보안정책/ACL_정책표.md), [사고 01](05_진단과_대응/사고_01_인수회사_우회접근.md) |
```

```bash
git add .
git commit -m "10일차: ACL 정책과 사고 01"
git push
```

사고 보고서의 대응 칸에 적을 커밋 해시는 `git log --oneline` 으로 확인합니다. 대응을 한 설정 커밋의 해시를 적고, 보고서를 고친 뒤 한 번 더 커밋합니다.

## 자주 막히는 곳

| 보이는 것 | 원인 | 해결 |
|-----------|------|------|
| ACL을 걸자 영업팀이 인터넷까지 못 나간다 | 50번 `permit ip any any` 를 빠뜨렸다 | `show access-lists SALES-IN` |
| 장애 시험 뒤에 인사팀으로 통한다 | HQ-R1의 Gi0/0.10에 SALES-IN을 걸지 않았다 | 3번 |
| 관리자 PC도 텔넷이 거부된다 | MGMT-ONLY의 주소가 틀렸다 | 콘솔에서 `show access-lists MGMT-ONLY` |
| `ip access-group` 이 3560 SVI에서 거절된다 | 패킷트레이서 버전이 지원하지 않는다 | HQ-R1에만 걸고 장애 뒤의 동작만 본다 |
| LC-WATCH에 아무것도 안 잡힌다 | LC-R1에 정적 경로가 없거나, LC-PC1이 틀린 주소로 ping했다 | 6번, HR-PC1의 `ipconfig` |
| LC-IN 뒤에 한결물류가 서버에도 못 간다 | EIGRP 이웃이 끊겼다 | 10번의 5번 줄 |
| Reflexive를 걸었는데 답이 안 온다 | `evaluate` 가 20번 거부 줄 아래에 있다 | 15번 자리에 끼워 넣는다 |
| `reflect` 가 거절된다 | 패킷트레이서 버전이 지원하지 않는다 | `permit tcp any any established` 로 TCP만 확인 |
