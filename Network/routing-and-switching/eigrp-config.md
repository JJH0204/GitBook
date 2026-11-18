# EIGRP 라우팅 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-RSW-012-MP |
| 목적 | R1과 R2를 같은 AS(100)의 EIGRP 이웃으로 만들고, 필요하면 다른 AS 사이 재분배를 설정한다 |
| 적용 대상 | Cisco Packet Tracer 실습 환경. Cisco IOS 라우터 2대(R1, R2). 실제 Cisco IOS 라우터에도 적용되나 인터페이스 이름이 다를 수 있다 |
| 소요 시간 | 약 25분 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 바탕으로 구성한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 설정 절차는 EIGRP 페이지에 개념과 섞여 있었다. 이 문서는 설정만 분리했다. 구성 값(IP)은 원본에 없던 값이며 사설 주소를 새로 정했다. 원본의 `net 192.168.20.192 0.0.0.63` 예시는 그대로 구역 D에 쓴다. 원본의 "중복 광고" 서술은 조건이 불분명해 옮기지 않았다. 확인 필요.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [EIGRP 라우팅 프로토콜](eigrp.md) | NET-RSW-004-DO | EIGRP 개념 |
| [Redistribution](../../Linux/guide/operations/redistribution.md) | | 재분배 문서 |
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

### A. EIGRP 설정 (R1)

1. (5-A-01) R1에서 전역 구성 모드로 들어간다: `enable` 후 `configure terminal` → 결과: 프롬프트가 `R1(config)#`이다.
2. (5-A-02) EIGRP 프로세스를 만들고 AS 번호를 지정한다: `router eigrp 100` → 결과: 프롬프트가 `R1(config-router)#`이다.
3. (5-A-03) LAN 네트워크를 광고한다: `network 192.168.10.0 0.0.0.255`
4. (5-A-04) 라우터 사이 링크를 광고한다: `network 172.16.10.0 0.0.0.3` → 결과: 오류 없이 적용된다.
5. (5-A-05) 모든 네트워크를 입력한 뒤 자동 요약을 끈다: `no auto-summary`
6. (5-A-06) `end`를 입력한다.

{% hint style="info" %}
NOTE: `network` 명령의 두 번째 값은 서브넷 마스크가 아니라 와일드카드 마스크다. `/24`는 `0.0.0.255`, `/26`은 `0.0.0.63`이다. 최신 IOS는 자동 요약이 기본으로 꺼져 있으나 오래된 IOS는 켜져 있어 명시적으로 끈다. 확인 필요.
{% endhint %}

### B. EIGRP 설정 (R2)

1. (5-B-01) R2에서 `enable`, `configure terminal`, `router eigrp 100`을 입력한다. (이웃끼리 AS 번호가 같아야 한다.)
2. (5-B-02) `network 192.168.20.0 0.0.0.255`와 `network 172.16.10.0 0.0.0.3`을 입력한다.
3. (5-B-03) `no auto-summary`를 입력하고 `end`를 입력한다. → 결과: `%DUAL-5-NBRCHANGE: IP-EIGRP 100: Neighbor 172.16.10.1 ... is up: new adjacency`가 나온다.

### C. 이웃과 경로 확인

1. (5-C-01) 이웃을 확인한다: `show ip eigrp neighbors` → 결과: 이웃 `172.16.10.2`(R1에서 볼 때)가 목록에 있다. 비어 있으면 광고 정보를 받지 못해 라우팅 테이블이 갱신되지 않는다.
2. (5-C-02) 라우팅 테이블을 확인한다: `show ip route` → 결과: `D 192.168.20.0/24 [90/...] via 172.16.10.2`가 보인다. (`D`는 EIGRP 내부 경로, `90`은 AD다.)
3. (5-C-03) 경로 비용 계산에 쓰이는 인터페이스 속성을 확인한다: `show interfaces <인터페이스 이름>` → 결과: `MTU`, `BW`, `DLY`가 보인다.
4. (5-C-04) 토폴로지 테이블을 확인한다: `show ip eigrp topology` → 결과: FD(Feasible Distance)가 가장 작은 경로가 최적 경로(Successor)로 표시된다.

### D. 서로 다른 AS 사이 재분배 (선택)

다른 AS 번호(예: 200)의 EIGRP 영역과 경로를 주고받을 때만 수행한다. 재분배는 두 프로세스(`100`, `200`)를 함께 돌리는 경계 라우터에서 한다.

{% hint style="danger" %}
WARNING: 재분배는 한 방향이면 단방향 경로만 생긴다. 두 방향이 모두 필요하면 양쪽에 설정한다(Multi). 잘못 설정하면 라우팅 루프와 경로 오염이 생겨 기존 통신이 끊길 수 있다. 운영 장비에서는 변경 전 백업과 콘솔 접근을 확보한다.
{% endhint %}

1. (5-D-01) 경계 라우터에서 `configure terminal`을 입력한다.
2. (5-D-02) 재분배를 받을 프로세스로 들어간다: `router eigrp 100` → 결과: 프롬프트가 `(config-router)#`이다.
3. (5-D-03) 다른 AS를 재분배한다: `redistribute eigrp 200` → 결과: 오류 없이 적용된다. (원본 방식: Single은 한쪽 프로세스에만, Multi는 양쪽 프로세스에 입력한다.)
4. (5-D-04) 추가 네트워크가 있으면 광고한다: `network 192.168.20.192 0.0.0.63` → 결과: `%DUAL-5-NBRCHANGE ... new adjacency`가 나올 수 있다.
5. (5-D-05) `no auto-summary`를 입력한다.
6. (5-D-06) 라우팅 테이블을 확인한다: `do show ip route` → 결과: 재분배한 라우터에는 다른 AS 경로가 `D`로, 다른 라우터에는 `D EX`(외부 경로)로 보인다.

### E. 저장

1. (5-E-01) 6절이 합격이면 R1에서 `copy running-config startup-config`를 입력한다. → 결과: `[OK]`
2. (5-E-02) R2에서 같은 명령을 입력한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | R1에서 `show ip eigrp neighbors` | 이웃이 보인다 | 이웃 1개 이상 |
| 2 | R1에서 `show ip route` | EIGRP 경로가 보인다 | `D 192.168.20.0/24` 행이 있다 |
| 3 | R2에서 `show ip route` | EIGRP 경로가 보인다 | `D 192.168.10.0/24` 행이 있다 |
| 4 | R1에서 `ping 192.168.20.1` | 응답이 온다 | 손실 0% (첫 패킷은 ARP로 실패할 수 있다) |
| 5 | (재분배한 경우) 다른 라우터에서 `show ip route` | 외부 경로가 보인다 | `D EX` 행이 있다 |

## 7. 복구

1. (7-01) 설정만 되돌린다: 전역 구성 모드에서 `no router eigrp 100` → 결과: `show ip route`에서 `D` 행이 사라진다.
2. (7-02) 재분배만 되돌리려면 해당 프로세스에서 `no redistribute eigrp 200`을 입력한다.
3. (7-03) 저장 전이라면 저장하지 않고 재시작한다: `reload` → 결과: 변경이 사라진다. `Save?`에는 `no`로 답한다.
4. (7-04) 이미 저장했다면 7-01 후 다시 저장하고 4절의 백업과 비교한다.
5. (7-05) 이웃이 보이지 않으면 양쪽 AS 번호, `network` 명령, 인터페이스 `shutdown` 여부를 먼저 비교한다.

{% hint style="danger" %}
WARNING: `erase startup-config` 후 `reload`는 저장된 모든 설정을 지운다. 실습 환경 초기화가 목적일 때만 쓴다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `eigrp.md`의 연결 과정과 재분배 절차를 MP 형식으로 분리했다. 구성 값, 안전 사항, 기능 확인, 복구를 추가했다 |
