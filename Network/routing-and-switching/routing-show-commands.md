# 라우팅·스위칭 확인 명령 요약

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-RSW-014-REF |
| 유형 | REF (명령 요약) |
| 목적 | 라우팅과 스위칭 상태를 확인하는 Cisco IOS `show` 명령과 STP 설정 명령을 한 표로 모은다 |
| 적용 대상 | Cisco IOS 라우터·스위치(Cisco Packet Tracer 포함). 모델과 IOS 버전에 따라 출력이 다를 수 있다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본 페이지에서 흩어져 있던 명령(`sh ip route`, `sh ip protocols`, `sh ip eigrp neighbors`, `show vtp status` 등)을 모은 새 문서다. 원본에 없던 명령이 포함돼 있다. 확인 필요.
{% endhint %}

## 1. 공통 명령

| 번호 | 명령 | 용도 | 예상 출력 |
|---|---|---|---|
| 1 | `show running-config` | 현재 적용 중인 설정을 본다. 변경 전 백업에 쓴다 | 설정 전체 |
| 2 | `show startup-config` | 저장된 설정을 본다 | 설정 전체 |
| 3 | `show ip interface brief` | 인터페이스 IP와 상태를 한 줄씩 본다 | `Status`, `Protocol`이 `up` |
| 4 | `copy running-config startup-config` | 현재 설정을 저장한다 | `[OK]` |
| 5 | `copy startup-config running-config` | 저장된 설정을 현재 설정에 합쳐 적용한다 | 추가된 줄은 지워지지 않는다 |

## 2. 라우팅 확인 명령

| 번호 | 명령 | 용도 | 예상 출력 |
|---|---|---|---|
| 1 | `show ip route` | 라우팅 테이블 전체를 본다 | 경로 코드와 `[AD/메트릭]` |
| 2 | `show ip route static` | 정적 경로만 본다 | `S` 행 |
| 3 | `show ip route rip` | RIP 경로만 본다 | `R` 행 |
| 4 | `show ip route ospf` | OSPF 경로만 본다 | `O` 행 |
| 5 | `show ip route eigrp` | EIGRP 경로만 본다 | `D`, `D EX` 행 |
| 6 | `show ip protocols` | 동작 중인 라우팅 프로토콜, 광고 네트워크, 버전을 본다 | 프로토콜별 요약 |

### 경로 코드와 AD

| 번호 | 코드 | 출처 | AD 기본값 |
|---|---|---|---|
| 1 | `C` | 직접 연결(Connected) | 0 |
| 2 | `L` | 인터페이스 자신의 주소(Local) | 0 |
| 3 | `S` | 정적 경로 | 1 |
| 4 | `D` | EIGRP 내부 | 90 |
| 5 | `O` | OSPF | 110 |
| 6 | `R` | RIP | 120 |
| 7 | `D EX` | EIGRP 외부(재분배) | 170 |

## 3. 프로토콜별 이웃·상세 명령

| 번호 | 명령 | 용도 | 예상 출력 |
|---|---|---|---|
| 1 | `show ip eigrp neighbors` | EIGRP 이웃을 본다 | 이웃 주소, 인터페이스 |
| 2 | `show ip eigrp topology` | EIGRP 토폴로지 테이블과 FD를 본다 | Successor 표시 |
| 3 | `show ip ospf` | OSPF 프로세스 정보를 본다 | 라우터 ID, Area |
| 4 | `show ip ospf neighbor` | OSPF 이웃과 상태를 본다 | `FULL` 등 |
| 5 | `show ip ospf interface` | 인터페이스별 OSPF 정보를 본다 | Area, 비용 |
| 6 | `show interfaces <인터페이스 이름>` | `BW`, `DLY`, `MTU`를 본다(경로 비용 계산용) | 인터페이스 속성 |

## 4. 스위칭 확인 명령

| 번호 | 명령 | 용도 | 예상 출력 |
|---|---|---|---|
| 1 | `show vlan brief` | VLAN 목록과 포트 배정을 본다 | VLAN 번호, 이름, 포트 |
| 2 | `show interfaces trunk` | 트렁크 포트와 허용 VLAN을 본다 | `Status: trunking` |
| 3 | `show interfaces <인터페이스 이름> switchport` | 포트의 모드와 VLAN을 본다 | Access/Trunk 모드 |
| 4 | `show vtp status` | VTP 모드, 도메인, Revision을 본다 | `Configuration Revision` |
| 5 | `show spanning-tree` | STP 상태를 본다 | Root 정보, 포트 역할·상태 |
| 6 | `show spanning-tree vlan <VLAN 번호>` | 특정 VLAN의 STP를 본다 | Root ID, Bridge ID, 포트별 `Role`, `Sts` |

### 포트 역할·상태 약어

| 번호 | 약어 | 뜻 |
|---|---|---|
| 1 | `Root` | Root Port |
| 2 | `Desg` | Designated Port |
| 3 | `Altn` | 대체(차단) 포트 |
| 4 | `FWD` | Forwarding |
| 5 | `BLK` | Blocking |
| 6 | `LRN` | Learning |
| 7 | `LIS` | Listening |

## 5. STP 설정 명령

{% hint style="warning" %}
CAUTION: Priority와 Root 지정을 바꾸면 Root Switch가 바뀌어 트래픽 경로가 바뀐다. 변경 전 `show spanning-tree`를 저장한다. 운영 중에는 일시적으로 포트가 전달을 멈출 수 있다(최대 약 50초).
{% endhint %}

| 번호 | 명령 | 용도 | 비고 |
|---|---|---|---|
| 1 | `spanning-tree vlan <VLAN 번호> priority <값>` | VLAN별 Priority를 지정한다 | 값은 0 또는 4096의 배수. 기본 32768 |
| 2 | `spanning-tree vlan <VLAN 번호> root primary` | 이 스위치를 Root가 되게 Priority를 낮춘다 | |
| 3 | `spanning-tree vlan <VLAN 번호> root secondary` | 이 스위치를 백업 Root가 되게 한다 | |

## 6. 되돌리기 명령

| 번호 | 명령 | 효과 | 비고 |
|---|---|---|---|
| 1 | `no router rip` / `no router ospf <번호>` / `no router eigrp <AS 번호>` | 해당 프로세스 설정을 지운다 | 전역 구성 모드 |
| 2 | `no ip route <네트워크> <마스크> <next hop>` | 정적 경로를 지운다 | |
| 3 | `no switchport access vlan` | 포트를 VLAN 1로 돌린다 | |
| 4 | `reload` | 장비를 재시작한다. 저장하지 않은 설정이 사라진다 | `Save?`에 `no` |

{% hint style="danger" %}
WARNING: `erase startup-config`는 저장된 설정을 지운다. `reload`와 함께 쓰면 장비가 초기 상태가 된다. 원격 접속 중이면 접속이 끊긴다.
{% endhint %}

## 7. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 라우팅·스위칭 페이지의 `show` 명령을 모아 REF로 새로 작성했다 |
