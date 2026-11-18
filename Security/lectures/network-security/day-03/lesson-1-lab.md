# 1-1. VLAN 만들기와 포트 배정 실습

> 상위: [3일차 스위칭과 VLAN](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-03-006-MP |
| 목적 | 새봄상사 토폴로지에 HQ-SW2를 더하고, 두 스위치에 VLAN을 만들어 포트를 넣고, 쓰지 않는 포트를 닫는다 |
| 적용 대상 | Cisco Packet Tracer의 `_실습/새봄상사.pkt` (2일차 함께 하는 실습이 끝난 상태), Catalyst 2960 스위치 |
| 소요 시간 | 약 22분 (토폴로지 8분, VLAN 6분, 포트 8분) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이번 재작성에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1.md](lesson-1.md) | LEC-SN-03-001-DO | VLAN: 스위치가 지키는 경계 |
| [commands.md](commands.md) | LEC-SN-03-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |
| [lesson-2-lab.md](lesson-2-lab.md) | LEC-SN-03-007-MP | 다음 실습. 트렁크 설정 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 패킷트레이서 파일 | `_실습/새봄상사.pkt` | 2일차 함께 하는 실습이 끝난 상태 |
| 2 | 스위치 | Catalyst 2960 두 대 (HQ-SW1, HQ-SW2) | HQ-SW2를 이번에 더한다 |
| 3 | PC와 서버 | PC 5대, Server-PT 1대 | 아래 표 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 포트의 VLAN을 바꾸면 그 포트에 꽂힌 장비의 통신이 끊긴다. 실습 파일의 가상 장비에서만 한다.
{% endhint %}

{% hint style="info" %}
NOTE: 비밀번호 `<password>`는 실습용 값으로 바꿔 입력한다. 실제 운영 장비의 비밀번호를 쓰지 않는다. 장비 화면의 출력은 IOS 15 형식이며 패킷트레이서 버전에 따라 조금 다를 수 있다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | `_실습/새봄상사.pkt`를 연다 | HQ-R1, HQ-SW1, Sales-PC1, Sales-PC2가 보인다 |
| 2 | HQ-SW1의 2일차 설정을 확인한다 | 호스트 이름 HQ-SW1, 콘솔과 VTY 비밀번호가 있다 |

## 5. 절차

### A. 토폴로지 넓히기

1. (5-A-01) 2960 스위치 한 대를 더 놓고 이름을 HQ-SW2로 바꾼다. 2층 스위치다.
2. (5-A-02) HQ-SW1의 Gi0/2와 HQ-SW2의 Gi0/1을 잇는다. 케이블은 번개 모양(자동)을 고르면 알맞은 종류로 이어 준다. → 결과: 두 포트의 연결 불빛이 켜진다.
3. (5-A-03) 아래 표대로 PC와 서버를 더하고 이어 준다. Sales-PC1(Fa0/1)과 Sales-PC2(Fa0/2)는 2일차 그대로 둔다.

| 장비 | 이어 줄 곳 | 부서 |
|---|---|---|
| HR-PC1 | HQ-SW1 Fa0/11 | 인사팀 |
| Server1 (Server-PT) | HQ-SW1 Fa0/21 | 서버 |
| Admin-PC | HQ-SW1 Fa0/24 | 장비 관리 |
| Dev-PC1 | HQ-SW2 Fa0/1 | 개발팀 |
| Sales-PC3 | HQ-SW2 Fa0/11 | 영업팀 (2층 자리) |

### B. HQ-SW2 기본 잠금

HQ-SW2에 2일차의 HQ-SW1과 같은 기본 잠금을 건다.

1. (5-B-01) HQ-SW2의 CLI를 열고 아래를 입력한다. → 결과: 오류 없이 프롬프트가 `HQ-SW2(config)#`로 바뀐다.

```
enable
configure terminal
hostname HQ-SW2
no ip domain-lookup
enable secret <password>
line console 0
 password <password>
 login
 exec-timeout 5 0
 exit
line vty 0 15
 password <password>
 login
 exec-timeout 5 0
 exit
service password-encryption
banner motd # Authorized access only. All access is logged. #
```

### C. VLAN 만들기 (HQ-SW1, HQ-SW2 모두)

두 스위치에 똑같이 입력한다. 설정 모드에서 이어서 입력한다.

1. (5-C-01) 아래를 입력한다. → 결과: 오류 없이 VLAN 7개가 만들어진다.

```
vlan 10
 name SALES
vlan 20
 name HR
vlan 30
 name DEV
vlan 40
 name SERVER
vlan 99
 name MGMT
vlan 900
 name NATIVE
vlan 999
 name UNUSED
 exit
```

{% hint style="info" %}
NOTE: VLAN 30은 HQ-SW1에 포트가 없지만 만들어 둔다. 트렁크로 지나가는 VLAN은 지나가는 스위치에도 있어야 한다.
{% endhint %}

### D. 포트 넣기, 쓰지 않는 포트 닫기

1. (5-D-01) HQ-SW1에서 아래를 입력한다. → 결과: 오류 없이 끝난다.

```
interface range fa0/1 - 10
 switchport mode access
 switchport access vlan 10
interface range fa0/11 - 15
 switchport mode access
 switchport access vlan 20
interface range fa0/21 - 22
 switchport mode access
 switchport access vlan 40
interface fa0/24
 switchport mode access
 switchport access vlan 99
interface range fa0/16 - 20 , fa0/23
 switchport mode access
 switchport access vlan 999
 shutdown
 exit
```

2. (5-D-02) HQ-SW2에서 아래를 입력한다. → 결과: 오류 없이 끝난다.

```
interface range fa0/1 - 10
 switchport mode access
 switchport access vlan 30
interface range fa0/11 - 12
 switchport mode access
 switchport access vlan 10
interface range fa0/13 - 24 , gi0/2
 switchport mode access
 switchport access vlan 999
 shutdown
 exit
```

3. (5-D-03) 각 스위치에서 `do show vlan brief`를 입력한다. → 결과: 부서별 포트 목록이 [1번 노트](lesson-1.md) 4절의 예와 같게 나온다.
4. (5-D-04) 닫은 포트의 불빛을 본다. → 결과: 빨강으로 바뀐다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | HQ-SW1에서 `show vlan brief` | VLAN 10 Fa0/1~10, 20 Fa0/11~15, 40 Fa0/21~22, 99 Fa0/24, 999 나머지 | 설계표와 같다 |
| 2 | HQ-SW2에서 `show vlan brief` | VLAN 30 Fa0/1~10, 10 Fa0/11~12, 999 나머지 | 설계표와 같다 |
| 3 | 닫은 포트의 불빛 | 빨강 | 쓰지 않는 포트 전부 |

트렁크는 아직 설정하지 않았으므로 스위치 사이 통신은 [2-1 트렁크 실습](lesson-2-lab.md) 뒤에 확인한다.

## 7. 복구

1. (7-01) 저장하지 않았다면 각 스위치에서 `reload`를 입력하고 저장 여부 질문에 `no`를 입력한다. → 결과: 마지막으로 저장한 설정으로 돌아간다.
2. (7-02) 패킷트레이서 파일은 `git restore _실습/새봄상사.pkt`로 마지막 커밋 상태로 되돌린다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 1~3번을 AMM 형식 MP로 분리. 비밀번호 자리를 `<password>`로 바꿈 |
