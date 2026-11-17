# VLAN, 트렁크, VTP 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-RSW-013-MP |
| 목적 | 스위치 2대에 VLAN 10, 20을 만들고 포트를 배정한 뒤 802.1Q 트렁크로 연결하고, 필요하면 VTP로 VLAN 정보를 동기화한다 |
| 적용 대상 | Cisco Packet Tracer 실습 환경. Cisco IOS 스위치 2대(Catalyst 2960 계열, SW1과 SW2). 실제 Catalyst 스위치에도 적용되나 인터페이스 이름과 일부 명령이 모델마다 다르다 |
| 소요 시간 | 약 30분 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 바탕으로 구성한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본 VLAN·VTP 페이지는 개념과 명령 이름만 있었고 설정 절차가 없었다. 이 문서의 구성 값, 명령 순서, 트렁크 설정은 새로 쓴 것이며 원본에 없던 내용이다. 확인 필요.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [가상 랜 (VLAN)](vlan.md) | NET-RSW-008-DO | VLAN, 트렁크 개념 |
| [VLAN 트렁킹 프로토콜 (VTP)](vtp.md) | NET-RSW-009-DO | VTP 개념 |
| [스패닝 트리 프로토콜 (STP)](stp.md) | NET-RSW-007-DO | 루프 방지 |
| [라우팅·스위칭 확인 명령 요약](routing-show-commands.md) | NET-RSW-014-REF | `show` 명령 |
| [LAN 환경 구축 실습](../fundamentals/basics/lanenvsetup.md) | NET-BAS-003-MP | 단일 스위치 LAN |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 스위치 | Cisco IOS L2 스위치 2대 | SW1, SW2 |
| 2 | PC | 4대 | PC1, PC3은 VLAN 10, PC2, PC4는 VLAN 20 |
| 3 | 랜 케이블 | 6개 | PC 4개, 스위치 간 1개(트렁크), 여분 |
| 4 | 콘솔 접근 | 콘솔 케이블 또는 시뮬레이터 터미널 | 원격 접속이 끊겨도 쓸 수 있어야 한다 |
| 5 | 텍스트 파일 | | `show running-config` 백업 저장용 |

### 구성 값

| 번호 | 장치 | 포트 | 역할 | VLAN |
|---|---|---|---|---|
| 1 | SW1 | `FastEthernet0/1` | Access (PC1, `192.168.10.1/24`) | 10 |
| 2 | SW1 | `FastEthernet0/2` | Access (PC2, `192.168.20.1/24`) | 20 |
| 3 | SW1 | `GigabitEthernet0/1` | Trunk (SW2 연결) | 10, 20 |
| 4 | SW2 | `FastEthernet0/1` | Access (PC3, `192.168.10.2/24`) | 10 |
| 5 | SW2 | `FastEthernet0/2` | Access (PC4, `192.168.20.2/24`) | 20 |
| 6 | SW2 | `GigabitEthernet0/1` | Trunk (SW1 연결) | 10, 20 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 원격(SSH, Telnet)으로 접속한 상태에서 접속에 쓰는 포트의 VLAN, 트렁크, `allowed vlan`을 바꾸면 접속이 끊긴다. 콘솔 접근 수단을 확보한 뒤 설정한다.
{% endhint %}

{% hint style="danger" %}
WARNING: VTP 도메인이 같은 스위치에 Revision이 높은 스위치를 연결하면 그 스위치의 VLAN 목록이 기존 스위치 전체를 덮어써 VLAN이 삭제될 수 있다. 연결 전에 구역 D의 Revision 초기화를 한다.
{% endhint %}

{% hint style="danger" %}
WARNING: `erase startup-config`는 저장된 설정을 지우고, `reload`는 저장하지 않은 설정을 잃게 한다. VLAN 정보가 `vlan.dat` 파일에 따로 저장되는 모델에서는 `erase startup-config`만으로 VLAN이 지워지지 않는다. 설정 절차에서는 쓰지 않는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 설정은 `running-config`에만 적용된다. 확인 단계가 끝난 뒤에만 저장한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 스위치와 PC를 구성 값 표대로 연결한다 | 링크 표시등이 켜진다 |
| 2 | 각 스위치의 현재 설정을 백업한다: `show running-config` | 출력 전체를 텍스트 파일로 저장한다 |
| 3 | 현재 VLAN을 확인한다: `show vlan brief` | 기본 VLAN 1과 1002~1005만 있다 |
| 4 | 각 PC에 구성 값 표의 IP와 `255.255.255.0`을 입력한다 | 같은 VLAN의 PC끼리만 통신할 예정이다 |

## 5. 절차

### A. VLAN 생성 (SW1)

1. (5-A-01) SW1에서 특권 모드로 들어간다: `enable` → 결과: 프롬프트가 `SW1#`이다.
2. (5-A-02) 전역 구성 모드로 들어간다: `configure terminal` → 결과: 프롬프트가 `SW1(config)#`이다.
3. (5-A-03) VLAN 10을 만든다: `vlan 10` → 결과: 프롬프트가 `SW1(config-vlan)#`이다.
4. (5-A-04) 이름을 붙인다: `name SALES`
5. (5-A-05) 구성 모드로 돌아간다: `exit`
6. (5-A-06) VLAN 20을 만들고 이름을 붙인다: `vlan 20`, `name ENG`, `exit`
7. (5-A-07) SW2에서 5-A-01~06을 같은 값으로 반복한다. (VTP로 동기화하려면 구역 D를 먼저 수행하고 이 구역은 Server 스위치에서만 한다.)

### B. Access 포트 배정 (SW1)

1. (5-B-01) 포트를 연다: `interface FastEthernet0/1` → 결과: 프롬프트가 `SW1(config-if)#`이다.
2. (5-B-02) Access 모드로 지정한다: `switchport mode access`
3. (5-B-03) VLAN 10에 배정한다: `switchport access vlan 10` → 결과: 오류 없이 적용된다.
4. (5-B-04) 다음 포트를 연다: `interface FastEthernet0/2`
5. (5-B-05) `switchport mode access`와 `switchport access vlan 20`을 입력한다.
6. (5-B-06) `end`를 입력한다.
7. (5-B-07) SW2에서 5-B-01~06을 같은 값으로 반복한다.

{% hint style="info" %}
NOTE: 존재하지 않는 VLAN 번호를 `switchport access vlan`에 쓰면 일부 장비는 VLAN을 자동으로 만든다. 구역 A를 먼저 수행해 번호를 직접 만든다.
{% endhint %}

### C. 트렁크 설정

{% hint style="danger" %}
WARNING: 스위치 사이 링크가 원격 접속 경로라면 5-C 단계에서 접속이 끊길 수 있다. 콘솔로 작업한다.
{% endhint %}

1. (5-C-01) SW1에서 `configure terminal`을 입력하고 `interface GigabitEthernet0/1`을 연다.
2. (5-C-02) 802.1Q를 지정한다: `switchport trunk encapsulation dot1q` → 결과: 오류 없이 적용된다. (`Invalid input`이 나오면 그 모델은 802.1Q만 지원하므로 이 단계를 건너뛴다. Catalyst 2960 계열이 이에 해당한다.)
3. (5-C-03) 트렁크 모드로 지정한다: `switchport mode trunk` → 결과: `%LINEPROTO-5-UPDOWN ... changed state to up`이 나올 수 있다.
4. (5-C-04) 허용 VLAN을 지정한다: `switchport trunk allowed vlan 10,20` → 결과: 오류 없이 적용된다.
5. (5-C-05) `end`를 입력한다.
6. (5-C-06) SW2에서 5-C-01~05를 반복한다. (SW2의 `GigabitEthernet0/1`)

{% hint style="warning" %}
CAUTION: `switchport trunk allowed vlan 10,20`은 기존 허용 목록을 통째로 바꾼다. 이미 쓰는 VLAN이 있으면 지워진다. 기존 목록에 추가하려면 `switchport trunk allowed vlan add <VLAN 번호>`를 쓴다.
{% endhint %}

{% hint style="info" %}
NOTE: 트렁크 양쪽 끝의 Native VLAN(기본 VLAN 1)이 같아야 한다. 다르면 `%CDP-4-NATIVE_VLAN_MISMATCH` 메시지가 나오고 STP 문제가 생긴다.
{% endhint %}

### D. VTP 설정 (선택)

VLAN 정보를 자동으로 동기화하려는 경우에만 수행한다. VTP를 쓰지 않으면 구역 A를 양쪽 스위치에서 각각 한다.

1. (5-D-01) SW1을 Server로 설정한다: `configure terminal`, `vtp mode server` → 결과: `Setting device to VTP SERVER mode.`
2. (5-D-02) 도메인 이름을 지정한다: `vtp domain LAB` → 결과: `Changing VTP domain name to LAB`
3. (5-D-03) 비밀번호를 지정한다: `vtp password <VTP 비밀번호>` → 결과: `Setting device VLAN database password`
4. (5-D-04) SW2를 Client로 설정한다: SW2에서 `configure terminal`, `vtp mode client`
5. (5-D-05) SW2에도 같은 도메인과 비밀번호를 지정한다: `vtp domain LAB`, `vtp password <VTP 비밀번호>`
6. (5-D-06) 새로 들여온 스위치의 Revision을 0으로 만든다: 그 스위치에서 `vtp mode transparent` 후 `vtp mode server`(또는 `client`) → 결과: `show vtp status`의 `Configuration Revision`이 0이다.
7. (5-D-07) SW1에서 구역 A로 VLAN을 만든다. → 결과: SW1의 Revision이 올라가고, SW2의 `show vlan brief`에 VLAN 10, 20이 나타난다.

{% hint style="info" %}
NOTE: 구역 D 후 SW2는 Client이므로 VLAN을 만들거나 지울 수 없다. VTP 버전 1, 2는 확장 범위 VLAN(1006~4094)을 광고하지 않는다. 확인 필요.
{% endhint %}

### E. 저장

1. (5-E-01) 6절이 합격이면 SW1에서 `copy running-config startup-config`를 입력한다. → 결과: `[OK]`
2. (5-E-02) SW2에서 같은 명령을 입력한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 양 스위치에서 `show vlan brief` | VLAN과 포트 배정이 보인다 | VLAN 10 `SALES`에 `Fa0/1`, VLAN 20 `ENG`에 `Fa0/2` |
| 2 | 양 스위치에서 `show interfaces trunk` | 트렁크가 보인다 | `Gi0/1`의 `Mode`가 `on`, `Status`가 `trunking`, 허용 VLAN `10,20` |
| 3 | PC1에서 `ping 192.168.10.2` (PC3) | 응답이 온다 | 손실 0% |
| 4 | PC1에서 `ping 192.168.20.1` (PC2) | 응답이 오지 않는다 | 100% 손실. VLAN이 다르고 라우터가 없으므로 정상이다 |
| 5 | (VTP 사용 시) SW2에서 `show vtp status` | 모드, 도메인이 맞다 | `VTP Operating Mode: Client`, `VTP Domain Name: LAB` |

## 7. 복구

1. (7-01) 포트 배정만 되돌린다: 해당 포트에서 `no switchport access vlan` → 결과: 포트가 VLAN 1로 돌아간다.
2. (7-02) 트렁크를 되돌린다: 해당 포트에서 `no switchport trunk allowed vlan`, `switchport mode access` → 결과: 포트가 트렁크가 아니다.
3. (7-03) VLAN을 지운다: 전역 구성 모드에서 `no vlan 10`, `no vlan 20`

{% hint style="warning" %}
CAUTION: VLAN을 지워도 그 VLAN에 배정된 포트의 `switchport access vlan` 설정은 남고 포트가 비활성(inactive) 상태가 된다. 7-01을 먼저 수행한다.
{% endhint %}

4. (7-04) VTP를 되돌린다: `vtp mode transparent` → 결과: 동기화가 멈춘다. 도메인과 비밀번호를 지우려면 `no vtp password`를 쓰고, 도메인은 새 이름으로 바꿔 쓴다.
5. (7-05) 저장 전이라면 저장하지 않고 재시작한다: `reload` → 결과: 변경이 사라진다. `Save?`에는 `no`로 답한다.
6. (7-06) 저장했다면 4절의 백업과 비교해 되돌린 뒤 다시 저장한다.

{% hint style="danger" %}
WARNING: `erase startup-config`와 `delete flash:vlan.dat`는 실습 환경 초기화 목적으로만 쓴다. 운영 장비에서는 VLAN과 설정을 모두 잃는다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `vlan.md`, `vtp.md`에 없던 설정 절차를 새 MP로 작성했다. 안전 사항, 기능 확인, 복구를 포함한다 |
