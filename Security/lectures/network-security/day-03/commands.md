# 0. 실습 명령어 모음

> 상위: [3일차 스위칭과 VLAN](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-03-005-REF |
| 유형 | REF (명령 표) |
| 목적 | 3일차 실습에서 입력하는 명령과 하는 일, 확인 명령, 자주 막히는 곳을 모은다 |
| 확인 상태 | 미검증 (원본 대본을 표로 정리한 것이다. 장비 출력은 IOS 15 형식을 따른 예시이며 이번에 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

실습하는 동안 띄워 둔다. 단계별 입력과 기대 결과는 아래 실습 문서에 있다. 1~8번은 `_실습/새봄상사.pkt`에서 새봄상사의 주소로 강사와 함께 하고, 9~12번은 개인 실습에서 `configs/network.pkt`를 열어 내 회사의 설계로 한다. 패킷트레이서 버전에 따라 출력이 조금 다를 수 있다.

| 문서 | Task ID | 다루는 단계 |
|---|---|---|
| [1-1. VLAN 만들기와 포트 배정 실습](lesson-1-lab.md) | LEC-SN-03-006-MP | 1~3번 |
| [2-1. 트렁크 설정 실습](lesson-2-lab.md) | LEC-SN-03-007-MP | 4번 |
| [3-1. 서브인터페이스와 관리 주소 실습](lesson-3-lab.md) | LEC-SN-03-008-MP | 5~7번 |
| [4-1. VTP transparent 설정 실습](lesson-4-lab.md) | LEC-SN-03-009-MP | 8번 |
| [개인 실습: 내 회사 VLAN 구성](personal-lab.md) | LEC-SN-03-010-MP | 9~12번 |

## 수업 흐름

| 단계 | 내용 | 언제 | 노트 |
|---|---|---|---|
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

## 작업 계획서 (14:00~14:20)

```bash
cd ~/my-netsec-project
git pull
```

VS Code에서 `00_작업계획/03일차.md`를 만들고 [README](README.md)의 새봄상사 예시를 보며 1~5번 칸을 채운다.

```bash
git add .
git commit -m "3일차: 작업 계획서"
git push
```

## 명령 표

### VLAN과 포트 (스위치)

| 명령 | 하는 일 | 쓰는 단계 |
|---|---|---|
| `vlan <번호>`, `name <이름>` | VLAN을 만들고 이름을 붙인다 | 2 |
| `interface range fa0/1 - 10` | 포트 열 개를 한 번에 고른다 (하이픈 앞뒤를 띄운다) | 3 |
| `switchport mode access` | 포트를 access로 고정한다 | 3 |
| `switchport access vlan <번호>` | 포트를 VLAN에 넣는다 | 3 |
| `shutdown` | 쓰지 않는 포트를 끈다 (VLAN 999와 함께) | 3 |
| `show vlan brief` | VLAN과 포트 배정을 본다 | 3 |

### 트렁크 (스위치)

| 명령 | 하는 일 | 쓰는 단계 |
|---|---|---|
| `switchport mode trunk` | 포트를 트렁크로 못 박는다 | 4 |
| `switchport trunk allowed vlan 10,20,30,40,99` | 나를 VLAN을 정한다 | 4 |
| `switchport trunk native vlan 900` | 태그 없이 오가는 VLAN을 900으로 한다 (스위치 사이 트렁크 양쪽) | 4 |
| `switchport nonegotiate` | DTP 협상 신호를 끈다 | 4 |
| `show interfaces trunk` | 트렁크 상태, native VLAN, 허락한 VLAN을 본다 | 4 |

### 라우터와 관리 주소

| 명령 | 하는 일 | 쓰는 단계 |
|---|---|---|
| `interface gi0/0` + `no ip address` | 물리 포트의 2일차 주소를 지운다 | 5 |
| `interface gi0/0.10` | 서브인터페이스를 만든다 | 5 |
| `encapsulation dot1Q 10` | 서브인터페이스가 맡을 VLAN을 정한다 (`ip address`보다 먼저) | 5 |
| `ip address <주소> <마스크>` | VLAN의 게이트웨이 주소 | 5 |
| `show ip interface brief` | 인터페이스와 주소를 본다 | 5 |
| `show ip route` | VLAN마다 C와 L 두 줄을 본다 | 5 |
| `interface vlan 99` + `ip address ...` | 스위치의 관리 주소 (SVI) | 6 |
| `ip default-gateway 192.168.10.129` | 다른 VLAN에서 온 접속에 답할 게이트웨이 | 6 |

### VTP

| 명령 | 하는 일 | 쓰는 단계 |
|---|---|---|
| `show vtp status` | VTP 모드를 본다 (처음은 Server) | 8 |
| `vtp mode transparent` | 다른 스위치의 알림을 따르지 않게 한다 | 8 |
| `show running-config \| include vlan` | VLAN 줄만 골라 본다 | 8 |
| `copy running-config startup-config` | 설정을 저장한다 | 8 |

### 새봄상사 PC 주소 (7번)

| 장비 | VLAN | IP 주소 | 서브넷 마스크 | 기본 게이트웨이 |
|---|---|---|---|---|
| Sales-PC1 | 10 | 192.168.10.2 | 255.255.255.224 | 192.168.10.1 |
| Sales-PC2 | 10 | 192.168.10.3 | 255.255.255.224 | 192.168.10.1 |
| Sales-PC3 | 10 | 192.168.10.4 | 255.255.255.224 | 192.168.10.1 |
| HR-PC1 | 20 | 192.168.10.34 | 255.255.255.224 | 192.168.10.33 |
| Dev-PC1 | 30 | 192.168.10.66 | 255.255.255.224 | 192.168.10.65 |
| Server1 | 40 | 192.168.10.98 | 255.255.255.224 | 192.168.10.97 |
| Admin-PC | 99 | 192.168.10.150 | 255.255.255.224 | 192.168.10.129 |

스위치 관리 주소는 HQ-SW1 192.168.10.130, HQ-SW2 192.168.10.131이다.

### 저장소 명령 (11~12번)

| 명령 | 하는 일 |
|---|---|
| `git diff configs/HQ-R1.txt` | 2일차와 3일차의 라우터 설정 차이를 본다 |
| `git add .`, `git commit -m "<메시지>"`, `git push` | 기록하고 올린다 |

## 자주 막히는 곳

| 보이는 것 | 원인 | 해결 |
|---|---|---|
| `interface range fa0/1-10`이 거절된다 | 하이픈 앞뒤 띄어쓰기 | `fa0/1 - 10` |
| `% Access VLAN does not exist. Creating vlan 10` | VLAN을 만들기 전에 포트에 넣었다 | 오류가 아니다. VLAN이 이름 없이 만들어진다. 2번으로 이름을 붙인다 |
| 같은 VLAN인데 다른 스위치와 안 통한다 | 트렁크가 한쪽만 설정됐거나, `allowed vlan`에 빠졌거나, 반대 스위치에 VLAN이 없다 | `show interfaces trunk`, 양쪽 `show vlan brief` |
| `%CDP-4-NATIVE_VLAN_MISMATCH`가 계속 뜬다 | native VLAN을 한쪽만 바꿨다 | 반대쪽 트렁크에도 `switchport trunk native vlan 900` |
| `overlaps with GigabitEthernet0/0` | Gi0/0에 2일차 주소가 남아 있다 | `interface gi0/0`, `no ip address` |
| 서브인터페이스에 주소가 안 들어간다 | `encapsulation`보다 `ip address`를 먼저 입력했다 | `encapsulation dot1Q`부터 |
| 다른 VLAN과 안 통한다 | PC의 게이트웨이가 2일차 그대로(.1)다 | VLAN마다 게이트웨이가 다르다. 위의 PC 주소 표 |
| `interface vlan 99`가 down | VLAN 99가 없거나 트렁크의 `allowed vlan`에 99가 없다 | `show vlan brief`, `show interfaces trunk` |
| 관리자 PC에서 HQ-SW2 텔넷이 안 된다 | HQ-SW2에 VTY 비밀번호를 걸지 않았다 | 1-1 실습의 기본 잠금 |
| 다른 VLAN에서 스위치로 텔넷이 안 된다 | 스위치에 `ip default-gateway`가 없다 | 6번 |

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 대본을 AMM REF 형식으로 재작성. 단계별 입력은 MP 5개로 분리하고 명령 표, PC 주소 표, 자주 막히는 곳을 유지. 비밀번호 자리를 `<password>`로 바꿈 |
