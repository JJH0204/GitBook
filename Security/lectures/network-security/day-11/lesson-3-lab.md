# 3-1. IPSec 암호화와 암호화 전후 비교 실습

> 상위: [11일차 VPN과 IPv6](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-11-007-MP |
| 목적 | 시뮬레이션 모드로 GRE 상자를 열어 캡처하고, GRE 위에 IPSec을 얹은 뒤, 같은 상자를 다시 열어 ESP로 바뀐 것을 캡처해 비교한다 |
| 적용 대상 | Cisco Packet Tracer의 `_실습/새봄상사.pkt` (HQ-R1, BR-R1, ISP-R1, BR-PC1). 2-1 실습을 마친 상태. 격리된 가상 실습망이며 실제 장비와 연결하지 않는다 |
| 소요 시간 | 약 32분 (GRE 상자 열기 8, IPSec 설정 14, 확인 6, 다시 연 상자와 캡처 4) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이 환경에서 패킷트레이서를 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-3.md](lesson-3.md) | LEC-SN-11-003-DO | IPSec으로 암호화 |
| [lesson-2-lab.md](lesson-2-lab.md) | LEC-SN-11-006-MP | 선행 실습. GRE 터널과 장애 시험 |
| [commands.md](commands.md) | LEC-SN-11-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |
| [lesson-4-lab.md](lesson-4-lab.md) | LEC-SN-11-008-MP | 다음 실습. IPv6 듀얼 스택과 IPv6 ACL |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 라우터 | 2911 (HQ-R1, BR-R1, ISP-R1) | HQ-R1과 BR-R1에 securityk9 라이선스가 켜져 있다 |
| 2 | PC | BR-PC1, 서버 (192.168.10.98) | ping을 보낸다 |
| 3 | Packet Tracer | Simulation 모드 | 화면 오른쪽 아래에서 바꾼다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 사전 공유 키는 `<key>` 자리에 실습용 값을 직접 정해 넣는다. 설정 텍스트를 저장소에 올릴 때는 키를 `<key>`로 바꾼 뒤 올린다.
{% endhint %}

{% hint style="warning" %}
CAUTION: IPSec 때문에 터널이 끊기면 Se0/0/1에서 `no crypto map VPNMAP`으로 떼어 GRE만으로 다시 통하게 한다. 7번 절을 따른다.
{% endhint %}

{% hint style="info" %}
NOTE: 패킷트레이서가 `aes 256`이나 `group 5`를 받지 않으면 `aes`와 `group 2`로 바꾼다. 양쪽 라우터가 같은 값이어야 한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 2-1 실습을 마쳤다 | HQ-R1에서 `ping 192.168.99.14`가 Reply |
| 2 | 보안 라이선스가 켜져 있다 | `show version`에 securityk9가 있다 |
| 3 | 장비 설정을 저장했다 | `copy running-config startup-config`가 오류 없이 끝난다 |

## 5. 절차

### A. 시뮬레이션 모드로 GRE 상자 열기

1. (5-A-01) 화면 오른쪽 아래에서 Simulation 모드로 바꾼다. → 결과: 시뮬레이션 패널이 열린다.
2. (5-A-02) Edit Filters에서 ICMP와 GRE만 보이게 한다. → 결과: 목록에 두 프로토콜만 남는다.
3. (5-A-03) BR-PC1에서 `ping 192.168.10.98`을 입력하고 Capture/Forward를 눌러 패킷을 ISP-R1까지 보낸다. → 결과: ISP-R1에 봉투가 머문다.
4. (5-A-04) ISP-R1에 머문 봉투를 눌러 PDU 정보를 연다. → 결과: 겉 IP, GRE, 안의 IP, ICMP가 모두 보인다.
5. (5-A-05) 이 화면을 캡처해 둔다(암호화 전). → 결과: 캡처 파일이 생긴다.

### B. IPSec 설정

1. (5-B-01) HQ-R1에 입력한다.

```
configure terminal
crypto isakmp policy 10
 encryption aes 256
 hash sha
 authentication pre-share
 group 5
 exit
crypto isakmp key <key> address 203.0.113.6
crypto ipsec transform-set HQBR esp-aes 256 esp-sha-hmac
ip access-list extended VPN-HQBR
 permit gre host 203.0.113.2 host 203.0.113.6
 exit
crypto map VPNMAP 10 ipsec-isakmp
 set peer 203.0.113.6
 set transform-set HQBR
 match address VPN-HQBR
 exit
interface se0/0/1
 crypto map VPNMAP
 end
```

→ 결과: 오류 없이 입력되고, 인터페이스에 crypto map을 걸 때 ISAKMP가 켜졌다는 알림이 뜰 수 있다.

2. (5-B-02) BR-R1에는 세 군데만 바꿔 입력한다. → 결과: HQ-R1과 같은 구성이 상대 주소만 반대로 들어간다.

| 바꿀 곳 | BR-R1의 값 |
|---|---|
| `crypto isakmp key` | `crypto isakmp key <key> address 203.0.113.2` |
| 대상 ACL | `permit gre host 203.0.113.6 host 203.0.113.2` |
| `set peer` | `set peer 203.0.113.2` |

### C. crypto 확인

1. (5-C-01) BR-PC1에서 `ping 192.168.10.98`을 몇 번 입력한다. → 결과: 첫 ping 한두 개는 빠질 수 있고, 이후 Reply가 온다.
2. (5-C-02) HQ-R1에서 확인한다.

```
show crypto isakmp sa
show crypto ipsec sa
```

→ 결과: `QM_IDLE`과 `ACTIVE`가 보이고, `#pkts encrypt`와 `#pkts decrypt`가 0보다 크다.

### D. 다시 연 상자와 캡처

1. (5-D-01) A 절을 다시 한다. → 결과: ISP-R1에서 연 패킷에 겉 IP 다음으로 ESP만 보인다. 안의 IP와 ICMP는 보이지 않는다.
2. (5-D-02) 이 화면을 캡처해 둔다(암호화 뒤). → 결과: 두 번째 캡처 파일이 생긴다.
3. (5-D-03) Realtime 모드로 돌아온다. → 결과: 시뮬레이션 패널이 닫힌다.
4. (5-D-04) 설정을 바꾼 HQ-R1, BR-R1, ISP-R1을 저장한다: `copy running-config startup-config` → 결과: 세 장비 모두 `[OK]`가 나온다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | HQ-R1에서 `show crypto isakmp sa` | `QM_IDLE`, `ACTIVE` | 두 값 모두 보인다 |
| 2 | HQ-R1에서 `show crypto ipsec sa` | `#pkts encrypt`, `#pkts decrypt` 증가 | 두 값이 0보다 크고 ping마다 는다 |
| 3 | 시뮬레이션 모드에서 ISP-R1의 패킷 | 겉 IP 다음 ESP | GRE, 안의 IP, ICMP가 보이지 않는다 |
| 4 | 캡처 두 장 | 암호화 전과 뒤 | 비교 표를 채울 수 있다 |
| 5 | BR-PC1에서 `ping 192.168.10.98` | Reply | 응답 수신 |

## 7. 복구

1. (7-01) IPSec 때문에 터널이 끊기면 BR-R1과 HQ-R1의 Se0/0/1에서 crypto map을 뗀다.

```
configure terminal
interface se0/0/1
 no crypto map VPNMAP
 end
```

→ 결과: GRE만으로 다시 통한다.

2. (7-02) 다시 걸 때는 양쪽의 키 값, `address`, ACL의 두 공인 주소가 서로 반대로 들어갔는지 먼저 확인한다.
3. (7-03) 다음 실습(LEC-SN-11-008-MP)으로 넘어가기 전에 `copy running-config startup-config`로 장비를 저장한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 6~9번을 AMM 형식 MP로 분리. 사전 공유 키 `<key>` 표기와 WARNING 추가. 번호(6~9)는 다른 문서의 참조 때문에 `commands.md`에 유지 |
