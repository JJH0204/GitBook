# 2-1. 인터넷 연결과 PAT 설정 실습

> 상위: [9일차 NAT와 서비스 공개](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-09-006-MP |
| 목적 | ISP-R1과 NET-PC를 놓고 HQ-R1에 잇고, 기본 경로와 null 경로를 넣어 OSPF로 지사에 알린 뒤, PAT로 본사와 지사를 인터넷에 내보내고 변환 표로 확인한다 |
| 적용 대상 | Cisco Packet Tracer의 `_실습/새봄상사.pkt`, 2911 라우터 HQ-R1·BR-R1·ISP-R1 (IOS 15 형식). 강사와 함께 하는 실습이다 |
| 소요 시간 | 약 40분 (대본 1~5번: 8분, 10분, 7분, 7분, 8분) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이번 재작성에서 다시 실행하지 않았다. 패킷트레이서가 이름 붙인 ACL을 NAT에 받는지 수업 전에 확인해야 한다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-2.md](lesson-2.md) | LEC-SN-09-002-DO | PAT로 인터넷에 나가기 |
| [lesson-1.md](lesson-1.md) | LEC-SN-09-001-DO | NAT가 필요한 이유 |
| [commands.md](commands.md) | LEC-SN-09-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-SN-09-007-MP | 다음 실습. 정적 NAT 시연과 포트 포워딩 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Packet Tracer 파일 | `_실습/새봄상사.pkt` (8일차까지 설정이 들어 있는 것) | |
| 2 | HQ-R1, BR-R1 | 2911 라우터. HQ-R1의 Se0/0/1이 비어 있어야 한다 | 4일차에 꽂은 HWIC-2T의 두 번째 포트 |
| 3 | ISP-R1 | 2911 라우터 (새로 놓는다) | Physical 탭에서 HWIC-2T를 꽂는다 |
| 4 | NET-PC | PC (새로 놓는다) | 198.51.100.10/24, 게이트웨이 198.51.100.1 |
| 5 | Serial DCE 케이블 | 1개 | |
| 6 | Sales-PC1, BR-PC1 | 본사와 지사 PC | 확인에 쓴다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: Se0/0/1의 회선 주소(203.0.113.2/30)와 기본 경로는 HQ-R1에서 회사 안 모든 통신의 경로표를 바꾼다. 입력 뒤 `show ip route`로 확인하고, 회사 안 통신이 이상하면 7절 복구를 따른다.
{% endhint %}

{% hint style="info" %}
NOTE: 장비 화면은 IOS 15 형식이다. 패킷트레이서 버전에 따라 값과 줄 구성이 다를 수 있다. 인터넷 쪽 장비와 주소는 모든 학생이 같은 것을 쓴다. 203.0.113.0/24와 198.51.100.0/24는 문서용 대역이다. 막히면 [commands.md](commands.md)의 "자주 막히는 곳"을 본다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | `_실습/새봄상사.pkt`를 연다 | 8일차까지의 토폴로지가 보인다 |
| 2 | HQ-R1에서 `show ip interface brief`를 입력한다 | Se0/0/1이 `unassigned`이고 `administratively down`이다 |
| 3 | HQ-R1에서 `show ip route ospf`를 입력한다 | 지사로 가는 O 줄이 보인다 |

## 5. 절차

### A. ISP-R1, NET-PC 놓고 잇기

1. (5-A-01) 2911 라우터를 하나 놓고 이름을 ISP-R1로 바꾼다. → 결과: 토폴로지에 ISP-R1이 놓인다.
2. (5-A-02) Physical 탭에서 전원을 끄고 HWIC-2T를 꽂은 뒤 전원을 켠다. → 결과: 라우터에 Se0/0/0이 생긴다.
3. (5-A-03) PC를 하나 놓고 이름을 NET-PC로 바꾼다.
4. (5-A-04) 케이블로 NET-PC와 ISP-R1의 Gi0/0을 잇는다.
5. (5-A-05) Serial DCE 케이블을 고른다.
6. (5-A-06) ISP-R1을 먼저 눌러 Se0/0/0을 고르고, 이어서 HQ-R1을 눌러 Se0/0/1을 고른다. → 결과: 먼저 누른 ISP 쪽이 DCE가 된다.
7. (5-A-07) ISP-R1에서 아래 줄을 차례로 입력한다. ISP-R1은 ISP의 장비라 새봄상사의 잠금을 걸지 않는다.

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

마지막 `ip route`는 ISP가 새봄상사에 빌려준 서버용 공인 주소 묶음(203.0.113.8/29)을 HQ-R1로 보내는 경로다. 3-1 실습의 포트 포워딩에서 쓴다.

8. (5-A-08) NET-PC의 IP Configuration에 주소 198.51.100.10, 마스크 255.255.255.0, 게이트웨이 198.51.100.1을 입력한다.
9. (5-A-09) HQ-R1에서 아래 줄을 차례로 입력한다.

```
configure terminal
interface se0/0/1
 description To ISP
 ip address 203.0.113.2 255.255.255.252
 no shutdown
 end
ping 203.0.113.1
```

→ 결과: Reply가 5개 모두 오면 회선이 이어진 것이다.

### B. 기본 경로, null 경로, OSPF로 알리기

1. (5-B-01) HQ-R1에서 아래 줄을 차례로 입력한다.

```
configure terminal
ip route 0.0.0.0 0.0.0.0 203.0.113.1
ip route 192.168.0.0 255.255.0.0 null0
router ospf 1
 default-information originate
 end
```

2. (5-B-02) BR-R1에서 `show ip route ospf`를 입력한다. → 결과: `O*E2 0.0.0.0/0 [110/1] via 192.168.99.1`이 있다.

### C. PAT

1. (5-C-01) HQ-R1에서 바꿔 줄 출발지 목록과 PAT 줄을 입력한다.

```
configure terminal
ip access-list standard NAT-INSIDE
 permit 192.168.10.0 0.0.0.255
 permit 192.168.20.0 0.0.0.255
 exit
ip nat inside source list NAT-INSIDE interface se0/0/1 overload
 end
```

→ 결과: 오류 없이 끝난다. 이름 붙인 ACL이 거절되면 `access-list 10 permit 192.168.10.0 0.0.0.255`, `access-list 10 permit 192.168.20.0 0.0.0.255`, `ip nat inside source list 10 interface se0/0/1 overload`로 바꾼다.

### D. inside와 outside

1. (5-D-01) HQ-R1에서 아래 줄을 차례로 입력한다.

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

2. (5-D-02) `show ip nat statistics`를 입력한다. → 결과: Outside interfaces가 Se0/0/1 하나, Inside interfaces가 일곱 곳이다.

{% hint style="info" %}
NOTE: inside는 일곱 곳이다. 지사 쪽 두 포트(Gi0/1, Se0/0/0)를 빠뜨리지 않는다. 한결물류 쪽 Gi0/2에는 걸지 않는다.
{% endhint %}

### E. 확인

1. (5-E-01) Sales-PC1에서 `ping 198.51.100.10`을 입력한다. → 결과: Reply가 온다.
2. (5-E-02) BR-PC1에서 `ping 198.51.100.10`을 입력한다. → 결과: Reply가 온다.
3. (5-E-03) 바로 HQ-R1에서 `show ip nat translations`를 입력한다. → 결과: Inside global이 203.0.113.2인 줄이 PC마다 생긴다. 표가 비어 있으면 ping을 다시 입력하고 곧바로 확인한다.
4. (5-E-04) HQ-R1에서 `show ip nat statistics`를 입력한다. → 결과: 변환 중인 개수와 포트 목록이 보인다.
5. (5-E-05) 설정을 바꾼 HQ-R1과 ISP-R1에서 `copy running-config startup-config`를 입력해 저장한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | HQ-R1 `ping 203.0.113.1` | Reply | 5개 모두 성공 |
| 2 | BR-R1 `show ip route ospf` | 기본 경로가 보인다 | `O*E2 0.0.0.0/0` |
| 3 | Sales-PC1, BR-PC1 `ping 198.51.100.10` | Reply | 두 PC 모두 성공 |
| 4 | HQ-R1 `show ip nat translations` | 변환 줄이 PC마다 있다 | Inside global이 203.0.113.2 |
| 5 | HQ-R1 `show ip nat statistics` | inside와 outside 포트 | outside 1, inside 7 |

## 7. 복구

1. (7-01) NAT가 꼬이면 아래 순서로 지운다: `no ip nat inside source list NAT-INSIDE interface se0/0/1 overload`, 각 포트의 `no ip nat inside`와 `no ip nat outside`, `no ip access-list standard NAT-INSIDE`.
2. (7-02) 기본 경로 때문에 회사 안 통신이 이상하면 `show ip route`에서 null 경로와 기본 경로를 함께 본다. 필요하면 `no ip route 0.0.0.0 0.0.0.0 203.0.113.1`로 기본 경로를 지운다.
3. (7-03) 인터넷 연결 전체를 끊어야 하면 HQ-R1의 `interface se0/0/1`에서 `shutdown`을 입력한다. 회사 안 통신은 그대로다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 1~5번과 `lesson-2.md`의 설정 안내를 AMM 형식 MP로 분리. 단계마다 기대 결과를 추가하고 복구 절 추가 |
