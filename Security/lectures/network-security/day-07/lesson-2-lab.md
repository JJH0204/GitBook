# 2-1. 인수한 회사 장비 설치와 EIGRP 연결 실습

> 상위: [7일차 EIGRP와 재분배](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-07-006-MP |
| 목적 | 패킷트레이서에서 한결물류 장비를 놓고 받은 설정을 넣은 뒤, 본사 Gi0/2로 잇고 EIGRP 20 이웃을 맺어 세 라우터의 경로표를 비교한다 |
| 적용 대상 | Cisco Packet Tracer의 `_실습/새봄상사.pkt` (2911 라우터, 2960 스위치, PC). 격리된 가상 실습망이며 실제 장비와 연결하지 않는다 |
| 소요 시간 | 약 30분 (장비와 설정 10, Gi0/2 연결 5, EIGRP 20 5, 경로표 비교 10) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이 환경에서 패킷트레이서를 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-2.md](lesson-2.md) | LEC-SN-07-002-DO | 인수한 회사 잇기 |
| [lesson-1.md](lesson-1.md) | LEC-SN-07-001-DO | EIGRP |
| [commands.md](commands.md) | LEC-SN-07-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-SN-07-007-MP | 다음 실습. 양방향 재분배 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Cisco Packet Tracer | `_실습/새봄상사.pkt` 파일 | 6일차까지의 본사와 지사 구성이 들어 있다 |
| 2 | 라우터 | 2911 (LC-R1) | 화면 아래쪽에 새로 놓는다 |
| 3 | 스위치 | 2960 (LC-SW1) | 새로 놓는다 |
| 4 | PC | LC-PC1 | 새로 놓는다 |
| 5 | 본사 장비 | HQ-R1 (Gi0/2가 비어 있음), BR-R1 | 6일차까지 구성한 장비 |

## 3. 안전 사항

{% hint style="info" %}
NOTE: 비밀번호는 `<password>` 자리에 실습용 값을 직접 정해 넣는다. 문서에 실제로 쓰는 비밀번호를 적지 않는다.
{% endhint %}

{% hint style="info" %}
NOTE: LC-SW1은 "인수할 때 받은 그대로" 아무 설정을 하지 않고 둔다. 아직 새봄상사가 관리하지 않는 망이라는 뜻이다.
{% endhint %}

{% hint style="info" %}
NOTE: 출력 예시는 IOS 15 형식이다. 패킷트레이서 버전에 따라 줄 구성이 조금 다를 수 있다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 오늘의 작업 계획서 1~5번 칸을 커밋했다 | `git log`에 7일차 작업 계획서 커밋이 있다 |
| 2 | `_실습/새봄상사.pkt`를 연다 | 본사, 지사 장비가 보인다 |
| 3 | HQ-R1의 Gi0/2가 비어 있다 | 케이블이 연결되지 않았다 |

## 5. 절차

### A. 한결물류 장비와 받은 설정

1. (5-A-01) 2911 라우터(LC-R1), 2960 스위치(LC-SW1), PC 한 대(LC-PC1)를 화면 아래쪽에 놓는다.
2. (5-A-02) LC-R1의 Gi0/0과 LC-SW1의 Gi0/1을 잇는다.
3. (5-A-03) LC-PC1과 LC-SW1의 Fa0/1을 잇는다.
4. (5-A-04) LC-R1 CLI에서 "인수할 때 받은 설정"을 그대로 붙여 넣는다.

```
enable
configure terminal
hostname LC-R1
no ip domain-lookup
enable secret <password>
line console 0
 password <password>
 login
 exec-timeout 5 0
 exit
line vty 0 4
 password <password>
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

→ 결과: 프롬프트가 `LC-R1#`로 돌아온다.

5. (5-A-05) LC-SW1은 설정하지 않고 둔다.
6. (5-A-06) LC-PC1의 주소를 172.16.10.10, 서브넷 마스크 255.255.255.0, 기본 게이트웨이 172.16.10.1로 준다.

### B. 본사 Gi0/2 잇기

1. (5-B-01) HQ-R1의 Gi0/2와 LC-R1의 Gi0/1을 잇는다. → 결과: 양쪽 포트에 링크 표시가 생긴다.
2. (5-B-02) HQ-R1에서 Gi0/2에 주소를 준다.

```
configure terminal
interface gi0/2
 description To Hangyeol LC-R1
 ip address 192.168.99.9 255.255.255.252
 no shutdown
 end
```

3. (5-B-03) HQ-R1에서 `ping 192.168.99.10`을 입력한다. → 결과: Reply가 온다.

### C. 본사에 EIGRP 20

1. (5-C-01) HQ-R1에서 EIGRP 20을 켜고 Gi0/2의 연결 구간만 고른다.

```
configure terminal
router eigrp 20
 network 192.168.99.8 0.0.0.3
 no auto-summary
 end
```

→ 결과: `%DUAL-5-NBRCHANGE: EIGRP-IPv4 20: Neighbor 192.168.99.10 (GigabitEthernet0/2) is up` 알림이 뜬다. 이 알림이 뜨면 이웃이 된 것이다.

### D. 세 라우터 경로표 비교

1. (5-D-01) 각 라우터에서 다음 명령을 입력한다.

```
HQ-R1#show ip eigrp neighbors
HQ-R1#show ip route eigrp
BR-R1#show ip route
LC-R1#show ip route
```

2. (5-D-02) 아래 표의 항목을 찾는다. → 결과: 표와 같게 보인다.

| 라우터 | 찾을 것 |
|---|---|
| HQ-R1 | `D 172.16.10.0/24 [90/...] via 192.168.99.10` |
| BR-R1 | 172.16.10.0/24가 없다 |
| LC-R1 | 192.168.10.x가 없다 |

3. (5-D-03) LC-PC1에서 `ping 192.168.10.98`을 입력한다. → 결과: 172.16.10.1이 `Destination host unreachable`로 답한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | HQ-R1에서 `ping 192.168.99.10` | Reply | 5개 모두 성공 |
| 2 | HQ-R1에서 `show ip eigrp neighbors` | 192.168.99.10 | 이웃 목록에 해당 주소 존재 |
| 3 | HQ-R1에서 `show ip route eigrp` | `D 172.16.10.0/24` | 해당 줄 존재 |
| 4 | BR-R1에서 `show ip route` | 172.16.10.0/24 없음 | 해당 줄 없음 |
| 5 | LC-PC1에서 `ping 192.168.10.98` | `Destination host unreachable` (172.16.10.1이 답함) | 서버에 닿지 않음 |

## 7. 복구

1. (7-01) 본사 쪽 EIGRP를 되돌리려면 HQ-R1에서 `no router eigrp 20`을 입력한다.
2. (7-02) Gi0/2를 되돌리려면 HQ-R1의 Gi0/2에서 `shutdown`을 입력한다. 새봄상사 망은 영향을 받지 않는다.
3. (7-03) 실습을 처음 상태로 돌리려면 `_실습/새봄상사.pkt`를 저장하지 않고 닫고 다시 연다.
4. (7-04) 다음 실습(LEC-SN-07-007-MP)으로 넘어가기 전에 `copy running-config startup-config`로 장비를 저장한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 1~4번을 AMM 형식 MP로 분리. 비밀번호 자리 `<password>`로 표기. 번호(1~4)는 다른 문서의 참조 때문에 `commands.md`에 유지 |
