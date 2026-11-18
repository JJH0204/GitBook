# 0. 실습 명령어 모음

> 상위: [9일차 NAT와 서비스 공개](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-09-005-REF |
| 유형 | REF (명령 대본) |
| 목적 | 9일차 실습에서 입력하는 명령과 기대 결과를 수업 흐름 순서대로 모은다 |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이번 재작성에서 다시 실행하지 않았다. 장비 화면은 IOS 15 형식이며 패킷트레이서 버전에 따라 다를 수 있다) |
| 개정 | R1 (2026-11-18) |

실습하는 동안 띄워 둔다. 1~9번은 `_실습/새봄상사.pkt`에서 새봄상사의 주소로 강사와 함께 입력하고(6번 1:1 정적 NAT 시연은 강사만), 10~13번은 개인 실습에서 `configs/network.pkt`를 열어 같은 일을 내 회사의 설계로 한다. 인터넷 쪽 장비(ISP-R1, NET-PC)와 그 주소는 모든 학생이 같은 것을 쓴다. 단계별 결과와 복구는 세 실습 문서에 있다.

{% hint style="danger" %}
WARNING: 허가받지 않은 시스템에 이 절차를 수행하는 것은 불법이다. 격리된 실습망에서만 수행한다. 6번 1:1 정적 NAT와 FTP 로그인 시연은 강사의 패킷트레이서 안(시뮬레이터의 가상 장비)에서만 한다.
{% endhint %}

| 문서 | Task ID | 다루는 번호 |
|---|---|---|
| [2-1. 인터넷 연결과 PAT 설정 실습](lesson-2-lab.md) | LEC-SN-09-006-MP | 1~5번 |
| [3-1. 정적 NAT 시연과 포트 포워딩 실습](lesson-3-lab.md) | LEC-SN-09-007-MP | 6~8번 |
| [4-1. 내 회사 인터넷 연결과 공개 서비스 목록 실습](lesson-4-lab.md) | LEC-SN-09-008-MP | 9~13번 |

## 수업 흐름

| 단계 | 내용 | 언제 | 노트 |
|---|---|---|---|
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

`00_작업계획/09일차.md`를 만들고 1~5번 칸을 채워 커밋한다.

```bash
git add .
git commit -m "9일차: 작업 계획서"
git push
```

## 1. ISP-R1, NET-PC 놓고 잇기

1. 2911 라우터를 하나 놓고 이름을 ISP-R1로 바꾼다. 4일차처럼 Physical 탭에서 전원을 끄고 HWIC-2T를 꽂은 뒤 켠다(저장할 필요가 없는 새 장비다).
2. PC를 하나 놓고 이름을 NET-PC로 바꾼다. ISP-R1의 Gi0/0에 잇는다.
3. Serial DCE 케이블을 고르고 ISP-R1을 먼저 눌러 Se0/0/0에, 이어서 HQ-R1의 Se0/0/1에 잇는다. 먼저 누른 ISP 쪽이 DCE다.

ISP-R1은 ISP의 장비라 새봄상사의 잠금을 걸지 않는다.

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

마지막 줄은 ISP가 새봄상사에 빌려준 서버용 공인 주소 묶음을 HQ-R1로 보내는 경로다(3번 노트 5번 절). NET-PC는 198.51.100.10/24, 게이트웨이 198.51.100.1이다.

HQ-R1에서 입력한다.

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

HQ-R1에서 입력한다.

```
configure terminal
ip route 0.0.0.0 0.0.0.0 203.0.113.1
ip route 192.168.0.0 255.255.0.0 null0
router ospf 1
 default-information originate
 end
```

BR-R1에서 `show ip route ospf`를 입력한다. `O*E2 0.0.0.0/0 [110/1] via 192.168.99.1`이 있으면 된다.

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

inside는 일곱 곳이다. 지사 쪽 두 포트(Gi0/1, Se0/0/0)를 빠뜨리지 않는다. 한결물류 쪽 Gi0/2에는 걸지 않는다.

## 5. 확인

Sales-PC1과 BR-PC1에서 각각 `ping 198.51.100.10`을 입력한 뒤 바로 HQ-R1에서 확인한다.

```
HQ-R1#show ip nat translations
HQ-R1#show ip nat statistics
```

변환 표에 Inside global 203.0.113.2인 줄이 PC마다 생기면 된다. 표가 비어 있으면 ping을 다시 입력하고 곧바로 확인한다.

## 6. 1:1 정적 NAT와 FTP (강사 시연)

강사의 `_실습/새봄상사.pkt`에서만 한다. Server1의 Services 탭에서 HTTP와 FTP가 켜져 있는지 먼저 확인한다.

```
HQ-R1(config)#ip nat inside source static 192.168.10.98 203.0.113.10
```

1. NET-PC의 Web Browser에서 `http://203.0.113.10`을 연다. 쇼핑몰 화면이 나온다.
2. NET-PC의 Command Prompt에서 `ftp 203.0.113.10`을 입력하고, Username에 `cisco`, Password에 서버의 기본 계정 비밀번호(`<password>`)를 넣는다. `230- Logged in`이 나온다.
3. `quit`으로 나온다.

## 7. 포트 포워딩, 공인 주소 null 경로

강사는 6번의 줄을 지우는 것부터 한다. 학생은 6번을 하지 않았으니 둘째 줄부터 입력한다.

```
configure terminal
no ip nat inside source static 192.168.10.98 203.0.113.10
ip nat inside source static tcp 192.168.10.98 80 203.0.113.10 80
ip nat inside source static tcp 192.168.10.98 443 203.0.113.10 443
ip route 203.0.113.8 255.255.255.248 null0
 end
```

## 8. 밖에서 확인

NET-PC에서 셋을 확인한다.

| 시험 | 기대하는 결과 |
|---|---|
| Web Browser `http://203.0.113.10` | 쇼핑몰 화면 |
| `ftp 203.0.113.10` | 연결되지 않음 |
| `ping 203.0.113.10` | Request timed out |

HQ-R1의 `show ip nat translations`에 `tcp 203.0.113.10:80 192.168.10.98:80 --- ---`처럼 정적 줄 두 개가 보이면 된다.

## 9. 밖에서 친 tracert

```
C:\>tracert 203.0.113.10
```

NET-PC에서 입력한다. 1번 줄 198.51.100.1, 2번 줄 203.0.113.2까지 보이고 그 뒤로는 답이 없거나 HQ-R1이 "닿을 수 없음"으로 답한다. 192.168.으로 시작하는 주소가 한 줄도 없으면 된다. Ctrl+C로 멈춘다.

설정을 바꾼 두 장비(HQ-R1, ISP-R1)를 저장한다.

```
copy running-config startup-config
```

## 10. 내 회사 파일에 1~9번 (개인 실습)

`_실습/새봄상사.pkt`를 저장하고 닫은 뒤 `configs/network.pkt`를 연다.

1. 1번의 인터넷 쪽 장비와 주소는 그대로 쓴다. 내 회사의 경계 라우터 Se0/0/1이 203.0.113.2다.
2. NAT-INSIDE에는 내 회사의 본사와 지사 대역을 적는다.
3. 포트 포워딩은 내 계획서의 "밖에서 접속하는 서비스"가 쓰는 포트만 연다. 6번 시연은 하지 않는다.

## 11. 인터넷 연결 기록, 공개 서비스 목록

1. [4번 노트](lesson-4.md) 5번 절의 양식으로 `03_구축/인터넷_연결.md`를 쓴다.
2. 4번 노트 3번 절의 양식으로 `02_설계/공개_서비스.md`를 만들고, "열지 않기로 한 것"까지 적는다.
3. `02_설계/IP_설계표.md`의 "인터넷 ISP 쪽" 줄을 채운다(회선 203.0.113.0/30, 서버용 203.0.113.8/29).

## 12. 설정 텍스트

`configs/`에 HQ-R1, ISP-R1의 설정 텍스트를 저장한다. ISP-R1은 새로 생기는 파일이다.

## 13. 결과 기록과 커밋

`00_작업계획/09일차.md`의 결과 칸을 채우고, README 진행 현황에 한 줄을 더한다.

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
|---|---|---|
| HQ-R1에서 203.0.113.1로 ping이 안 된다 | 시리얼 케이블의 DCE가 HQ 쪽이라 clock rate가 엉뚱한 곳에 있다 | `show controllers serial 0/0/1`로 DCE 쪽 확인 |
| 지사에 O*E2가 없다 | `default-information originate`를 빠뜨렸거나, HQ-R1에 기본 경로가 없다 | HQ-R1 `show ip route static` |
| PC에서 NET-PC로 ping이 안 되고 변환 표가 비어 있다 | inside나 outside를 빠뜨렸거나 거꾸로 걸었다 | `show ip nat statistics`의 Outside interfaces, Inside interfaces |
| 지사 PC만 안 나간다 | 지사 쪽 Gi0/1에 `ip nat inside`가 없다 | 4번 |
| `ip nat inside source list NAT-INSIDE`가 거절된다 | 패킷트레이서 버전이 이름 붙인 ACL을 받지 않는다 | `access-list 10 permit 192.168.10.0 0.0.0.255`와 `... list 10 ...` |
| 밖에서 쇼핑몰이 안 열린다 | ISP-R1에 203.0.113.8/29 경로가 없다 | 1번의 마지막 줄 |
| 포트 포워딩 뒤에도 밖에서 FTP가 된다 | 6번의 1:1 줄이 남아 있다 | `no ip nat inside source static 192.168.10.98 203.0.113.10` |

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 대본을 AMM REF 형식으로 재작성. 평서체 변환. 실습 절차는 세 MP(LEC-SN-09-006-MP, -007-MP, -008-MP)로 분리. 번호(0~13)는 다른 문서의 참조 때문에 유지. 격리 환경 WARNING 추가. FTP 기본 계정 비밀번호를 `<password>`로 교체 |
