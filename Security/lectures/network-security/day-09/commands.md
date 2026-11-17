# 0. 실습 명령어 모음

> 상위: [9일차 NAT와 서비스 공개](README.md)

수업 흐름 순서대로 적은 대본입니다. 1~9번은 `_실습/새봄상사.pkt` 에서 새봄상사의 주소로 강사와 함께 치고(6번 1:1 정적 NAT 시연은 강사만), 10~13번은 개인 실습에서 `configs/network.pkt` 를 열어 같은 일을 내 회사의 설계로 합니다. 인터넷 쪽 장비(ISP-R1, NET-PC)와 그 주소는 모든 학생이 같은 것을 씁니다. 장비 화면의 출력 예시는 IOS 15 형식을 따라 적었고, 패킷트레이서 버전에 따라 조금 다를 수 있습니다.

| 단계 | 내용 | 언제 | 노트 |
|------|------|------|------|
| 0 | 작업 계획서 | 14:00 (20분) | README |
| 1 | ISP-R1, NET-PC 놓고 잇기 | 14:45 함께 (8분) | 2 |
| 2 | 기본 경로, null 경로, OSPF로 알리기 | 함께 (10분) | 2 |
| 3 | PAT | 15:03 함께 (7분) | 2 |
| 4 | inside와 outside | 함께 (7분) | 2 |
| 5 | 확인 | 15:17 함께 (8분) | 2 |
| 6 | 1:1 정적 NAT와 FTP | 15:42 강사 시연 (10분) | 3 |
| 7 | 포트 포워딩, 공인 주소 null 경로 | 함께 (10분) | 3 |
| 8 | 밖에서 확인 | 16:02 함께 (13분) | 3 |
| 9 | 밖에서 친 tracert | 16:23 함께 (8분) | 4 |
| 10 | 내 회사 파일에 1~9번 | 17:00 개인 (25분) | 1~4 |
| 11 | 인터넷 연결 기록, 공개 서비스 목록 | 개인 (15분) | 4 |
| 12 | 설정 텍스트 | 개인 (8분) | |
| 13 | 결과 기록과 커밋 | 개인 (10분) | |

## 0. 작업 계획서 (14:00~14:20)

```bash
cd ~/my-netsec-project
git pull
```

`00_작업계획/09일차.md` 를 만들고 1~5번 칸을 채워 커밋합니다.

```bash
git add .
git commit -m "9일차: 작업 계획서"
git push
```

## 1. ISP-R1, NET-PC 놓고 잇기

1. 2911 라우터를 하나 놓고 이름을 ISP-R1로 바꿉니다. 4일차처럼 저장하지 않아도 되는 새 장비이니 Physical 탭에서 전원을 끄고 HWIC-2T를 꽂은 뒤 켭니다.
2. PC를 하나 놓고 이름을 NET-PC로 바꿉니다. ISP-R1의 Gi0/0에 잇습니다.
3. Serial DCE 케이블을 고르고 ISP-R1을 먼저 눌러 Se0/0/0에, 이어서 HQ-R1의 Se0/0/1에 잇습니다. 먼저 누른 ISP 쪽이 DCE입니다.

ISP-R1은 ISP의 장비라 새봄상사의 잠금을 걸지 않습니다.

```
enable
configure terminal
hostname ISP-R1
no ip domain-lookup
interface se0/0/0
 ip address 203.0.113.1 255.255.255.252
 clock rate 64000
 no shutdown
interface gi0/0
 ip address 198.51.100.1 255.255.255.0
 no shutdown
 exit
ip route 203.0.113.8 255.255.255.248 203.0.113.2
 end
```

마지막 줄은 ISP가 새봄상사에 빌려준 서버용 공인 주소 묶음을 HQ-R1로 보내는 경로입니다(3번 노트 5번 절). NET-PC는 198.51.100.10/24, 게이트웨이 198.51.100.1입니다.

HQ-R1입니다.

```
configure terminal
interface se0/0/1
 description To ISP
 ip address 203.0.113.2 255.255.255.252
 no shutdown
 end
ping 203.0.113.1
```

## 2. 기본 경로, null 경로, OSPF로 알리기

HQ-R1입니다.

```
configure terminal
ip route 0.0.0.0 0.0.0.0 203.0.113.1
ip route 192.168.0.0 255.255.0.0 null0
router ospf 1
 default-information originate
 end
```

BR-R1에서 `show ip route ospf` 를 봅니다. `O*E2 0.0.0.0/0 [110/1] via 192.168.99.1` 이 있으면 됩니다.

## 3. PAT

```
configure terminal
ip access-list standard NAT-INSIDE
 permit 192.168.10.0 0.0.0.255
 permit 192.168.20.0 0.0.0.255
 exit
ip nat inside source list NAT-INSIDE interface se0/0/1 overload
 end
```

## 4. inside와 outside

```
configure terminal
interface se0/0/1
 ip nat outside
interface gi0/0.10
 ip nat inside
interface gi0/0.20
 ip nat inside
interface gi0/0.30
 ip nat inside
interface gi0/0.40
 ip nat inside
interface gi0/0.99
 ip nat inside
interface gi0/1
 ip nat inside
interface se0/0/0
 ip nat inside
 end
```

inside는 일곱 곳입니다. 지사 쪽 두 포트(Gi0/1, Se0/0/0)를 빠뜨리지 않습니다. 한결물류 쪽 Gi0/2에는 걸지 않습니다.

## 5. 확인

Sales-PC1과 BR-PC1에서 각각 `ping 198.51.100.10` 을 친 뒤 바로 HQ-R1에서 봅니다.

```
HQ-R1#show ip nat translations
HQ-R1#show ip nat statistics
```

변환 표에 Inside global 203.0.113.2인 줄이 PC마다 생기면 됩니다. 표가 비어 있으면 ping을 다시 치고 곧바로 봅니다.

## 6. 1:1 정적 NAT와 FTP (강사 시연)

강사의 `_실습/새봄상사.pkt` 에서만 합니다. Server1의 Services 탭에서 HTTP와 FTP가 켜져 있는지 먼저 봅니다.

```
HQ-R1(config)#ip nat inside source static 192.168.10.98 203.0.113.10
```

1. NET-PC의 Web Browser에서 `http://203.0.113.10` 을 엽니다. 쇼핑몰 화면이 나옵니다.
2. NET-PC의 Command Prompt에서 `ftp 203.0.113.10` 을 치고, Username에 `cisco`, Password에 `cisco` 를 넣습니다. `230- Logged in` 이 나옵니다.
3. `quit` 으로 나옵니다.

## 7. 포트 포워딩, 공인 주소 null 경로

강사는 6번의 줄을 지우는 것부터 합니다. 학생은 6번을 하지 않았으니 둘째 줄부터 칩니다.

```
configure terminal
no ip nat inside source static 192.168.10.98 203.0.113.10
ip nat inside source static tcp 192.168.10.98 80 203.0.113.10 80
ip nat inside source static tcp 192.168.10.98 443 203.0.113.10 443
ip route 203.0.113.8 255.255.255.248 null0
 end
```

## 8. 밖에서 확인

NET-PC에서 셋을 확인합니다.

| 시험 | 기대하는 결과 |
|------|---------------|
| Web Browser `http://203.0.113.10` | 쇼핑몰 화면 |
| `ftp 203.0.113.10` | 연결되지 않음 |
| `ping 203.0.113.10` | Request timed out |

HQ-R1의 `show ip nat translations` 에 `tcp 203.0.113.10:80 192.168.10.98:80 --- ---` 처럼 정적 줄 두 개가 보이면 됩니다.

## 9. 밖에서 친 tracert

```
C:\>tracert 203.0.113.10
```

NET-PC에서 칩니다. 1번 줄 198.51.100.1, 2번 줄 203.0.113.2까지 보이고 그 뒤로는 답이 없거나 HQ-R1이 "닿을 수 없음"으로 답합니다. 192.168.으로 시작하는 주소가 한 줄도 없으면 됩니다. Ctrl+C로 멈춥니다.

설정을 바꾼 두 장비(HQ-R1, ISP-R1)를 저장합니다.

```
copy running-config startup-config
```

## 10. 내 회사 파일에 1~9번 (개인 실습)

`_실습/새봄상사.pkt` 를 저장하고 닫은 뒤 `configs/network.pkt` 를 엽니다.

1. 1번의 인터넷 쪽 장비와 주소는 그대로 씁니다. 내 회사의 경계 라우터 Se0/0/1이 203.0.113.2입니다.
2. NAT-INSIDE에는 내 회사의 본사와 지사 대역을 적습니다.
3. 포트 포워딩은 내 계획서의 "밖에서 접속하는 서비스"가 쓰는 포트만 엽니다. 6번 시연은 하지 않습니다.

## 11. 인터넷 연결 기록, 공개 서비스 목록

1. [4번 노트](lesson-4.md) 5번 절의 양식으로 `03_구축/인터넷_연결.md` 를 씁니다.
2. 4번 노트 3번 절의 양식으로 `02_설계/공개_서비스.md` 를 만들고, "열지 않기로 한 것"까지 적습니다.
3. `02_설계/IP_설계표.md` 의 "인터넷 ISP 쪽" 줄을 채웁니다(회선 203.0.113.0/30, 서버용 203.0.113.8/29).

## 12. 설정 텍스트

`configs/` 에 HQ-R1, ISP-R1의 설정 텍스트를 저장합니다. ISP-R1은 새로 생기는 파일입니다.

## 13. 결과 기록과 커밋

`00_작업계획/09일차.md` 의 결과 칸을 채우고, README 진행 현황에 한 줄을 더합니다.

```markdown
| 9 | 인터넷 연결(PAT), 쇼핑몰 공개(포트 포워딩), 공개 서비스 목록 | [작업 계획서](00_작업계획/09일차.md), [인터넷 연결](03_구축/인터넷_연결.md), [공개 서비스](02_설계/공개_서비스.md) |
```

```bash
git add .
git commit -m "9일차: 인터넷 연결과 쇼핑몰 공개"
git push
```

## 자주 막히는 곳

| 보이는 것 | 원인 | 해결 |
|-----------|------|------|
| HQ-R1에서 203.0.113.1로 ping이 안 된다 | 시리얼 케이블의 DCE가 HQ 쪽이라 clock rate가 엉뚱한 곳에 있다 | `show controllers serial 0/0/1` 로 DCE 쪽 확인 |
| 지사에 O*E2가 없다 | `default-information originate` 를 빠뜨렸거나, HQ-R1에 기본 경로가 없다 | HQ-R1 `show ip route static` |
| PC에서 NET-PC로 ping이 안 되고 변환 표가 비어 있다 | inside나 outside를 빠뜨렸거나 거꾸로 걸었다 | `show ip nat statistics` 의 Outside interfaces, Inside interfaces |
| 지사 PC만 안 나간다 | 지사 쪽 Gi0/1에 `ip nat inside` 가 없다 | 4번 |
| `ip nat inside source list NAT-INSIDE` 가 거절된다 | 패킷트레이서 버전이 이름 붙인 ACL을 받지 않는다 | `access-list 10 permit 192.168.10.0 0.0.0.255` 와 `... list 10 ...` |
| 밖에서 쇼핑몰이 안 열린다 | ISP-R1에 203.0.113.8/29 경로가 없다 | 1번의 마지막 줄 |
| 포트 포워딩 뒤에도 밖에서 FTP가 된다 | 6번의 1:1 줄이 남아 있다 | `no ip nat inside source static 192.168.10.98 203.0.113.10` |
