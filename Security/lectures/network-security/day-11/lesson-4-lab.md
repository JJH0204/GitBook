# 4-1. IPv6 듀얼 스택과 IPv6 ACL 실습

> 상위: [11일차 VPN과 IPv6](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-11-008-MP |
| 목적 | HQ-R1의 영업팀과 인사팀 서브인터페이스에 IPv6를 켜고, IPv4 ACL이 IPv6 통신을 막지 못하는 것을 확인한 뒤 IPv6 ACL(SALES-IN6)로 막는다 |
| 적용 대상 | Cisco Packet Tracer의 `_실습/새봄상사.pkt` (HQ-R1, Sales-PC1, HR-PC1). 10일차의 SALES-IN이 걸려 있는 상태. 격리된 가상 실습망이다 |
| 소요 시간 | 약 15분 (듀얼 스택 6, 두 ping 5, IPv6 ACL 4) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이 환경에서 패킷트레이서를 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-4.md](lesson-4.md) | LEC-SN-11-004-DO | IPv6와 듀얼 스택의 뒷문 |
| [commands.md](commands.md) | LEC-SN-11-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-SN-11-007-MP | 선행 실습. IPSec 암호화와 암호화 전후 비교 |
| [lesson-4-personal-lab.md](lesson-4-personal-lab.md) | LEC-SN-11-009-MP | 다음 실습. 내 회사 VPN과 IPv6, 기록, 커밋 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 라우터 | 2911 (HQ-R1) | 서브인터페이스 gi0/0.10(영업팀), gi0/0.20(인사팀)이 있다 |
| 2 | PC | Sales-PC1, HR-PC1 | IP Configuration에서 IPv6를 Automatic으로 바꾼다 |

## 3. 안전 사항

{% hint style="info" %}
NOTE: 이 실습은 격리된 가상 실습망에서만 한다. IPv6 주소는 문서용 2001:db8::/32를 쓴다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `no ipv6 unicast-routing`으로 IPv6 라우팅을 끄면 라우터 광고가 멈춘다. 이미 만들어진 PC의 IPv6 주소는 수명이 끝날 때 사라진다. (미검증)
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 10일차의 SALES-IN이 걸려 있다 | Sales-PC1에서 `ping 192.168.10.42`가 닿을 수 없음 |
| 2 | HQ-R1 설정을 저장했다 | `copy running-config startup-config`가 오류 없이 끝난다 |

## 5. 절차

### A. IPv6 듀얼 스택 시범

1. (5-A-01) HQ-R1에 입력한다.

```
configure terminal
ipv6 unicast-routing
interface gi0/0.10
 ipv6 address 2001:db8:10:10::1/64
interface gi0/0.20
 ipv6 address 2001:db8:10:20::1/64
 end
```

→ 결과: 오류 없이 `HQ-R1#`로 돌아온다. 서브인터페이스에 IPv4와 IPv6 주소가 함께 있다.

2. (5-A-02) Sales-PC1과 HR-PC1의 IP Configuration에서 IPv6를 Automatic으로 바꾼다. → 결과: HR-PC1에 2001:db8:10:20::으로 시작하는 주소가 생긴다.
3. (5-A-03) HR-PC1의 IPv6 주소를 적어 둔다. → 결과: 다음 절차에서 쓸 주소를 얻는다.

### B. IPv4와 IPv6로 친 ping

1. (5-B-01) Sales-PC1에서 두 ping을 입력한다.

| 명령 | 기대하는 결과 |
|---|---|
| `ping 192.168.10.42` | 닿을 수 없음 (SALES-IN) |
| `ping <HR-PC1의 IPv6 주소>` | Reply |

→ 결과: IPv4는 막히고 IPv6는 통한다. IPv4 ACL을 IPv6 패킷이 비켜 가는 장면이다.

### C. SALES-IN6

1. (5-C-01) HQ-R1에 IPv6 ACL을 만들어 건다.

```
configure terminal
ipv6 access-list SALES-IN6
 deny ipv6 2001:db8:10:10::/64 2001:db8:10:20::/64 log
 permit ipv6 any any
 exit
interface gi0/0.10
 ipv6 traffic-filter SALES-IN6 in
 end
```

→ 결과: 오류 없이 입력된다. IPv4의 `ip access-group`이 아니라 `ipv6 traffic-filter`로 건다.

2. (5-C-02) B 절의 IPv6 ping을 다시 입력한다. → 결과: 막힌다.
3. (5-C-03) HQ-R1을 저장한다: `copy running-config startup-config` → 결과: `[OK]`가 나온다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | HR-PC1의 IPv6 주소 | 2001:db8:10:20::으로 시작 | 주소 존재 |
| 2 | ACL 전 Sales-PC1에서 IPv6 ping | Reply | 응답 수신 |
| 3 | ACL 뒤 Sales-PC1에서 IPv6 ping | 닿을 수 없음 | 응답 없음 |
| 4 | Sales-PC1에서 `ping 192.168.10.42` | 닿을 수 없음 | IPv4 정책이 그대로 유지된다 |

## 7. 복구

1. (7-01) IPv6 ACL만 떼려면 서브인터페이스에서 필터를 뺀다.

```
configure terminal
interface gi0/0.10
 no ipv6 traffic-filter SALES-IN6 in
 end
```

2. (7-02) IPv6를 완전히 끄려면 `no ipv6 unicast-routing`을 입력하고 서브인터페이스의 `ipv6 address`를 지운다.
3. (7-03) 다음 실습(LEC-SN-11-009-MP)으로 넘어가기 전에 `copy running-config startup-config`로 장비를 저장한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 10~12번을 AMM 형식 MP로 분리. `no ipv6 unicast-routing` 후 PC 주소가 수명이 끝날 때 사라진다는 CAUTION 추가. 번호(10~12)는 다른 문서의 참조 때문에 `commands.md`에 유지 |
