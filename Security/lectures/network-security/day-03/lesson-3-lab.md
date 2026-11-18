# 3-1. 서브인터페이스와 관리 주소 실습

> 상위: [3일차 스위칭과 VLAN](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-03-008-MP |
| 목적 | HQ-R1에 서브인터페이스를 만들어 VLAN 사이를 잇고, 두 스위치에 관리 주소를 주고, PC 주소를 설정해 통신을 확인한다 |
| 적용 대상 | Cisco Packet Tracer의 `_실습/새봄상사.pkt`, Cisco 라우터(HQ-R1), Catalyst 2960 스위치 |
| 소요 시간 | 약 31분 (서브인터페이스 13분, 관리 주소 8분, PC 설정과 확인 10분) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이번 재작성에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-3.md](lesson-3.md) | LEC-SN-03-003-DO | VLAN 사이의 통신과 관리 VLAN |
| [lesson-2-lab.md](lesson-2-lab.md) | LEC-SN-03-007-MP | 앞 실습. 트렁크 설정 |
| [commands.md](commands.md) | LEC-SN-03-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 패킷트레이서 파일 | `_실습/새봄상사.pkt` | 2-1 실습을 마친 상태 |
| 2 | 라우터 | HQ-R1 | Gi0/0에 2일차 주소가 있다 |
| 3 | 스위치 | HQ-SW1, HQ-SW2 | 트렁크가 선 상태 |
| 4 | PC와 서버 | Sales-PC1~3, HR-PC1, Dev-PC1, Server1, Admin-PC | |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: HQ-R1 Gi0/0의 주소를 지우는 순간 2일차 설정의 통신이 끊긴다. 서브인터페이스를 입력한 뒤에야 다시 통한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 텔넷은 비밀번호를 평문으로 보낸다. 이 실습에서는 가상 장비에서만 쓴다. 12일차에 SSH로 바꾼다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 트렁크 두 곳이 섰다 | HQ-SW1에서 `show interfaces trunk`에 Gi0/1, Gi0/2가 `trunking`이다 |
| 2 | HQ-R1 Gi0/0의 주소를 확인한다 | `show ip interface brief`에 192.168.10.1이 보인다 |

## 5. 절차

### A. 라우터 서브인터페이스 (HQ-R1)

먼저 2일차에 Gi0/0에 준 주소를 지운다. 지우지 않고 서브인터페이스부터 입력하면 `overlaps with GigabitEthernet0/0` 오류가 난다.

1. (5-A-01) HQ-R1에서 아래를 입력한다. `encapsulation`을 `ip address`보다 먼저 입력한다. → 결과: 오류 없이 끝나고 `show ip interface brief`가 출력된다.

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

2. (5-A-02) 출력을 읽는다. → 결과: 아래와 같이 Gi0/0은 `unassigned`, 서브인터페이스 다섯 개는 `up up`이다.

```
Interface              IP-Address      OK? Method Status                Protocol
GigabitEthernet0/0     unassigned      YES manual up                    up
GigabitEthernet0/0.10  192.168.10.1    YES manual up                    up
GigabitEthernet0/0.20  192.168.10.33   YES manual up                    up
GigabitEthernet0/0.30  192.168.10.65   YES manual up                    up
GigabitEthernet0/0.40  192.168.10.97   YES manual up                    up
GigabitEthernet0/0.99  192.168.10.129  YES manual up                    up
```

### B. 스위치 관리 주소

1. (5-B-01) HQ-SW1에서 아래를 입력한다. → 결과: 오류 없이 끝나고 `interface vlan 99`가 up이 된다.

```
configure terminal
interface vlan 99
 ip address 192.168.10.130 255.255.255.224
 no shutdown
 exit
ip default-gateway 192.168.10.129
end
```

2. (5-B-02) HQ-SW2에서 주소만 192.168.10.131로 바꿔 똑같이 입력한다. → 결과: 오류 없이 끝난다.

### C. PC 주소 설정

1. (5-C-01) 아래 표대로 각 PC와 서버의 주소, 서브넷 마스크, 기본 게이트웨이를 입력한다. 게이트웨이는 VLAN마다 다르다. → 결과: 각 장비의 설정 창에 값이 들어간다.

| 장비 | VLAN | IP 주소 | 서브넷 마스크 | 기본 게이트웨이 |
|---|---|---|---|---|
| Sales-PC1 | 10 | 192.168.10.2 | 255.255.255.224 | 192.168.10.1 |
| Sales-PC2 | 10 | 192.168.10.3 | 255.255.255.224 | 192.168.10.1 |
| Sales-PC3 | 10 | 192.168.10.4 | 255.255.255.224 | 192.168.10.1 |
| HR-PC1 | 20 | 192.168.10.34 | 255.255.255.224 | 192.168.10.33 |
| Dev-PC1 | 30 | 192.168.10.66 | 255.255.255.224 | 192.168.10.65 |
| Server1 | 40 | 192.168.10.98 | 255.255.255.224 | 192.168.10.97 |
| Admin-PC | 99 | 192.168.10.150 | 255.255.255.224 | 192.168.10.129 |

### D. 통신 확인

1. (5-D-01) 아래 표의 통신을 차례로 확인한다. → 결과: 각 줄의 "지나는 곳"대로 동작한다.

| 어디서 | 어디로 | 명령 | 지나는 곳 |
|---|---|---|---|
| Sales-PC1 | Sales-PC3 | `ping 192.168.10.4` | 트렁크(같은 VLAN, 다른 스위치) |
| Sales-PC1 | HR-PC1 | `tracert 192.168.10.34` | 라우터(다른 VLAN). 첫 줄이 192.168.10.1 |
| Dev-PC1 | Server1 | `ping 192.168.10.98` | 트렁크 두 번과 라우터 |
| Admin-PC | HQ-SW1 | `telnet 192.168.10.130` | 같은 VLAN 99 |
| Admin-PC | HQ-SW2 | `telnet 192.168.10.131` | 트렁크 |
| Sales-PC1 | HQ-SW1 | `telnet 192.168.10.130` | 라우터. 지금은 되지만 10일차에 막는다 |

2. (5-D-02) [1번 노트](lesson-1.md) 6절의 실험을 한다. HR-PC1의 주소만 192.168.10.5로 바꾸고 `ping 192.168.10.2`를 입력한다. → 결과: `Request timed out.`이 나온다. 통하지 않으면 정상이다.
3. (5-D-03) HR-PC1의 주소를 192.168.10.34로 되돌린다. → 결과: HR-PC1에서 `ping 192.168.10.33`이 응답한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | HQ-R1에서 `show ip interface brief` | 서브인터페이스 다섯 개 `up up` | 해당 |
| 2 | Sales-PC1에서 Sales-PC3으로 `ping` | Reply | 응답 |
| 3 | Sales-PC1에서 HR-PC1로 `tracert` | 첫 줄 192.168.10.1 | 해당 |
| 4 | HR-PC1 주소를 영업팀 대역으로 바꾸고 `ping` | `Request timed out.` | 통하지 않음 |
| 5 | Admin-PC에서 두 스위치로 `telnet` | 비밀번호 창 | 둘 다 해당 |
| 6 | HQ-R1에서 `show ip route` | VLAN마다 C와 L 두 줄 | 서브인터페이스 다섯 개 |

## 7. 복구

1. (7-01) 저장하지 않았다면 각 장비에서 `reload`를 입력하고 저장 여부 질문에 `no`를 입력한다. → 결과: 마지막으로 저장한 설정으로 돌아간다.
2. (7-02) 라우터 설정이 꼬이면 `configs/HQ-R1.txt`의 2일차 설정을 붙여 넣는다.
3. (7-03) 패킷트레이서 파일은 `git restore _실습/새봄상사.pkt`로 마지막 커밋 상태로 되돌린다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 5~7번을 AMM 형식 MP로 분리. 텔넷 평문 전송 CAUTION 추가 |
