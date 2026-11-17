# RIP 라우팅 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-RSW-010-MP |
| 목적 | R1과 R2에 RIPv2를 설정해 서로의 LAN 경로를 자동으로 학습하게 한다 |
| 적용 대상 | Cisco Packet Tracer 실습 환경. Cisco IOS 라우터 2대(R1, R2). 실제 Cisco IOS 라우터에도 적용되나 인터페이스 이름이 다를 수 있다 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 바탕으로 구성한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 RIP 페이지는 명령 블록이 일부 깨져 있었다. 이 문서의 구성 값(IP)은 원본에 없던 값이며 사설 주소를 새로 정했다. 원본은 Loopback으로 간소화한 토폴로지를 썼다. 확인 필요.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [RIP 라우팅 프로토콜](rip.md) | NET-RSW-006-DO | RIP 개념 |
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

### A. 모드 진입과 RIP 설정 (R1)

1. (5-A-01) R1에서 특권 모드로 들어간다: `enable` → 결과: 프롬프트가 `R1#`이다.
2. (5-A-02) 전역 구성 모드로 들어간다: `configure terminal` → 결과: 프롬프트가 `R1(config)#`이다.
3. (5-A-03) RIP 프로세스를 만든다: `router rip` → 결과: 프롬프트가 `R1(config-router)#`이다.
4. (5-A-04) 버전 2를 지정한다: `version 2`
5. (5-A-05) 자동 요약을 끈다: `no auto-summary`
6. (5-A-06) 연결된 네트워크를 입력한다: `network 192.168.10.0` → 결과: 오류 없이 적용된다.
7. (5-A-07) 두 번째 네트워크를 입력한다: `network 172.16.0.0` → 결과: 오류 없이 적용된다.
8. (5-A-08) 구성 모드를 나온다: `end`

{% hint style="info" %}
NOTE: RIP의 `network` 명령은 마스크 없이 클래스 단위(클래스풀) 주소를 쓴다. `172.16.10.0/30`은 `172.16.0.0`(클래스 B)으로 입력한다. 이 주소의 인터페이스가 모두 RIP에 포함된다.
{% endhint %}

### B. RIP 설정 (R2)

1. (5-B-01) R2에서 `enable`과 `configure terminal`을 입력한다.
2. (5-B-02) `router rip`, `version 2`, `no auto-summary`를 차례로 입력한다.
3. (5-B-03) `network 192.168.20.0`과 `network 172.16.0.0`을 입력한다.
4. (5-B-04) `end`를 입력한다. → 결과: 프롬프트가 `R2#`이다.

### C. 광고 확인

1. (5-C-01) R1에서 프로토콜 정보를 확인한다: `show ip protocols` → 결과: `Routing Protocol is "rip"`, 버전 2, 광고 중인 네트워크가 보인다.
2. (5-C-02) R1의 라우팅 테이블을 확인한다: `show ip route` → 결과: `R 192.168.20.0/24 [120/1] via 172.16.10.2`가 보인다. (`R`은 RIP, `120`은 AD, `1`은 홉 수다.)

### D. 저장

1. (5-D-01) 6절이 합격이면 R1에서 저장한다: `copy running-config startup-config` → 결과: `[OK]`
2. (5-D-02) R2에서 같은 명령을 실행한다.

### E. 버전 전환(선택)

원본의 "RIPv1에서 v2 전환" 절차다. v1만 쓰던 장비에서 v2로 바꿀 때만 수행한다.

{% hint style="danger" %}
WARNING: 이웃 라우터가 v1만 쓰는 상태에서 `version 2`를 지정하면 그 이웃과 경로 교환이 끊긴다. 모든 라우터를 같은 버전으로 맞춘 뒤 전환한다.
{% endhint %}

1. (5-E-01) `configure terminal`, `router rip`을 입력한다.
2. (5-E-02) `version 2`를 입력한다. → 결과: 기존 설정을 유지한 채 v2로 바뀐다.
3. (5-E-03) 기존 RIP 설정을 모두 지우려면 `no router rip`을 입력한다. → 결과: RIP 설정이 사라진다. 다시 5-A부터 설정한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | R1에서 `show ip route` | RIP 경로가 보인다 | `R 192.168.20.0/24` 행이 있다 |
| 2 | R2에서 `show ip route` | RIP 경로가 보인다 | `R 192.168.10.0/24` 행이 있다 |
| 3 | R1에서 `ping 192.168.20.1` | 응답이 온다 | 손실 0% (첫 패킷은 ARP로 실패할 수 있다) |
| 4 | R1에서 `show ip protocols` | 버전 2, 자동 요약 꺼짐 | `automatic network summarization is not in effect` |

## 7. 복구

1. (7-01) 설정만 되돌린다: 전역 구성 모드에서 `no router rip` → 결과: `show ip protocols`에 RIP가 없다.
2. (7-02) 저장 전이라면 저장하지 않고 재시작한다: `reload` → 결과: 변경이 사라진다. `Save?`에는 `no`로 답한다.
3. (7-03) 이미 저장했다면 `no router rip` 후 다시 저장한다. 4절의 백업과 비교해 다른 부분이 없는지 확인한다.

{% hint style="danger" %}
WARNING: `erase startup-config` 후 `reload`는 저장된 모든 설정을 지운다. 실습 환경 초기화가 목적일 때만 쓴다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `rip.md`의 연결 과정을 MP 형식으로 분리했다. 구성 값, 안전 사항, 기능 확인, 복구를 추가했다 |
