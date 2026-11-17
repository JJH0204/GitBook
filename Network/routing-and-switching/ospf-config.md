# OSPF 라우팅 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-RSW-011-MP |
| 목적 | R1과 R2를 Area 0의 OSPF 이웃으로 만들어 서로의 LAN 경로를 자동으로 학습하게 한다 |
| 적용 대상 | Cisco Packet Tracer 실습 환경. Cisco IOS 라우터 2대(R1, R2). 실제 Cisco IOS 라우터에도 적용되나 인터페이스 이름이 다를 수 있다 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 바탕으로 구성한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 OSPF 페이지는 설정·확인 명령 블록이 모두 비어 있었다. 이 문서의 명령과 구성 값은 원본 설명(네트워크와 Area 설정, 이웃·경로·인터페이스 정보 출력)을 바탕으로 새로 쓴 것이며 원본에 없던 내용이다. 확인 필요.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [OSPF 라우팅 프로토콜](ospf.md) | NET-RSW-005-DO | OSPF 개념 |
| [동적 라우팅 프로토콜 개요](dynamic-routing-protocol.md) | NET-RSW-001-DO | 프로토콜 비교 |
| [라우팅 실습 (Packet Tracer)](routing-1.md) | NET-RSW-003-MP | 인터페이스 IP 설정 |
| [라우팅·스위칭 확인 명령 요약](routing-show-commands.md) | NET-RSW-014-REF | `show` 명령 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 라우터 | Cisco IOS, 인터페이스 2개 이상 | R1, R2. 아래 구성 값 표 참조 |
| 2 | 콘솔 접근 | 콘솔 케이블 또는 시뮬레이터 터미널 | 원격 접속이 끊겨도 쓸 수 있어야 한다 |
| 3 | 텍스트 파일 | | `show running-config` 백업 저장용 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 원격(SSH, Telnet)으로 접속한 상태에서 접속에 쓰는 인터페이스의 IP를 바꾸거나 `shutdown`하거나, 그 경로를 바꾸는 라우팅 설정을 하면 접속이 끊긴다. 콘솔 접근 수단을 확보한 뒤 설정한다.
{% endhint %}

{% hint style="danger" %}
WARNING: `erase startup-config`는 저장된 설정을 지우고, `reload`는 저장하지 않은 설정을 잃게 한다. 이 문서의 설정 절차에서는 쓰지 않는다. 복구 절에서만 쓴다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 설정은 `running-config`에만 적용된다. 저장(`copy running-config startup-config`) 전에 장비를 재시작하면 설정이 사라진다. 확인 단계가 끝난 뒤에만 저장한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 인터페이스 IP가 구성 값 표대로 설정돼 있고 켜져 있다 | `show ip interface brief`에서 `Status`와 `Protocol`이 모두 `up`이다 |
| 2 | 현재 설정을 백업한다: `show running-config` | 출력 전체를 텍스트 파일로 저장한다 |
| 3 | 현재 라우팅 테이블을 확인한다: `show ip route` | `C`와 `L` 경로만 보인다 |

## 5. 절차

### 구성 값

| 번호 | 장치 | 인터페이스 | IP / 마스크 |
|---|---|---|---|
| 1 | R1 | `GigabitEthernet0/0` | `192.168.10.1` / `255.255.255.0` |
| 2 | R1 | `GigabitEthernet0/1` | `172.16.10.1` / `255.255.255.252` |
| 3 | R2 | `GigabitEthernet0/1` | `172.16.10.2` / `255.255.255.252` |
| 4 | R2 | `GigabitEthernet0/0` | `192.168.20.1` / `255.255.255.0` |

### A. OSPF 설정 (R1)

1. (5-A-01) R1에서 `enable`, `configure terminal`을 입력한다. → 결과: 프롬프트가 `R1(config)#`이다.
2. (5-A-02) OSPF 프로세스를 만든다: `router ospf 1` → 결과: 프롬프트가 `R1(config-router)#`이다. (프로세스 번호 `1`은 이 라우터 안에서만 쓰며 이웃과 같지 않아도 된다.)
3. (5-A-03) 라우터 ID를 지정한다: `router-id 1.1.1.1` → 결과: 오류 없이 적용된다. (실제 주소가 아닌 식별자 값이다.)
4. (5-A-04) LAN 네트워크를 Area 0에 넣는다: `network 192.168.10.0 0.0.0.255 area 0`
5. (5-A-05) 라우터 사이 링크를 Area 0에 넣는다: `network 172.16.10.0 0.0.0.3 area 0` → 결과: 오류 없이 적용된다.
6. (5-A-06) 단말만 있는 LAN 인터페이스는 OSPF 광고를 막는다: `passive-interface GigabitEthernet0/0`
7. (5-A-07) `end`를 입력한다.

{% hint style="info" %}
NOTE: `network` 명령의 두 번째 값은 서브넷 마스크가 아니라 와일드카드 마스크다. `/24`는 `0.0.0.255`, `/30`은 `0.0.0.3`이다. Area 번호는 `area 0`처럼 명령에 함께 쓴다. OSPF는 `no auto-summary`가 필요 없다.
{% endhint %}

### B. OSPF 설정 (R2)

1. (5-B-01) R2에서 `enable`, `configure terminal`, `router ospf 1`을 입력한다.
2. (5-B-02) `router-id 2.2.2.2`를 입력한다.
3. (5-B-03) `network 192.168.20.0 0.0.0.255 area 0`을 입력한다.
4. (5-B-04) `network 172.16.10.0 0.0.0.3 area 0`을 입력한다.
5. (5-B-05) `passive-interface GigabitEthernet0/0`을 입력한다.
6. (5-B-06) `end`를 입력한다. → 결과: 잠시 뒤 `%OSPF-5-ADJCHG: ... Neighbor ... from LOADING to FULL`이 나온다.

{% hint style="danger" %}
WARNING: Area 0(백본) 없이 Area 번호를 1 이상으로만 설정하면 Area 사이 통신이 되지 않는다. Virtual Link로 우회할 수 있으나 물리 환경상 어쩔 수 없을 때만 쓴다.
{% endhint %}

### C. 이웃과 경로 확인

1. (5-C-01) OSPF 전체 정보를 확인한다: `show ip ospf` → 결과: 라우터 ID와 Area 0이 보인다.
2. (5-C-02) 이웃 정보를 출력한다: `show ip ospf neighbor` → 결과: 이웃의 상태가 `FULL`이다. (점대점 링크가 아니면 `FULL/DR`, `FULL/BDR`, `2WAY/DROTHER`로 보일 수 있다.)
3. (5-C-03) 라우팅 경로 정보를 출력한다: `show ip route ospf` → 결과: `O 192.168.20.0/24 [110/2] via 172.16.10.2`가 보인다. (`110`은 AD, `2`는 비용 합이다. 각 구간 비용이 1이면 합이 2다.)
4. (5-C-04) 인터페이스별 OSPF 정보를 출력한다: `show ip ospf interface` → 결과: Area, 비용, 이웃 수가 보인다.

### D. 저장

1. (5-D-01) 6절이 합격이면 R1에서 `copy running-config startup-config`를 입력한다. → 결과: `[OK]`
2. (5-D-02) R2에서 같은 명령을 입력한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | R1에서 `show ip ospf neighbor` | 이웃이 보인다 | 상태가 `FULL` |
| 2 | R1에서 `show ip route ospf` | OSPF 경로가 보인다 | `O 192.168.20.0/24` 행이 있다 |
| 3 | R2에서 `show ip route ospf` | OSPF 경로가 보인다 | `O 192.168.10.0/24` 행이 있다 |
| 4 | R1에서 `ping 192.168.20.1` | 응답이 온다 | 손실 0% (첫 패킷은 ARP로 실패할 수 있다) |

## 7. 복구

1. (7-01) 설정만 되돌린다: 전역 구성 모드에서 `no router ospf 1` → 결과: `show ip route`에서 `O` 행이 사라진다.
2. (7-02) 저장 전이라면 저장하지 않고 재시작한다: `reload` → 결과: 변경이 사라진다. `Save?`에는 `no`로 답한다.
3. (7-03) 이미 저장했다면 `no router ospf 1` 후 다시 저장한다. 4절의 백업과 비교한다.
4. (7-04) 이웃이 `FULL`이 되지 않으면 양쪽의 Area 번호, 와일드카드 마스크, 인터페이스 `shutdown` 여부를 먼저 비교한다.

{% hint style="danger" %}
WARNING: `erase startup-config` 후 `reload`는 저장된 모든 설정을 지운다. 실습 환경 초기화가 목적일 때만 쓴다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `ospf.md`의 설정 안내를 MP 형식으로 분리했다. 비어 있던 명령 블록을 채우고 안전 사항, 기능 확인, 복구를 추가했다 |
