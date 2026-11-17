# 라우팅 프로토콜 재분배

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-OPS-003-MP |
| 목적 | 서로 다른 라우팅 프로토콜(RIP, EIGRP)을 쓰는 두 네트워크가 경로를 공유하도록 재분배(redistribution)를 설정한다 |
| 적용 대상 | 두 네트워크를 잇는 Cisco IOS 계열 라우터(RIP 라우터 1대, EIGRP 라우터 1대), 특권 모드 접속 가능 |
| 소요 시간 | 약 15분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 라우터에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 RIP와 EIGRP 구간만 절차로 다룬다. OSPF와 EIGRP 사이 재분배는 원본에 설정 절차가 없어 구역 C에 요점만 적었다.
{% endhint %}

## 1. 참조

| 참조 | 용도 |
|---|---|
| [재분배 관련 자료](https://simpleisit.tistory.com/20) | 외부 블로그. 재분배 개념 보충 |
| [Redistribution (RIP 문서)](../../../Network/routing-and-switching/rip.md) | RIP 설정 |
| [Redistribution (EIGRP 문서)](../../../Network/routing-and-switching/eigrp.md) | EIGRP 설정 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | RIP 라우터 | 윗 네트워크(RIP) 소속 | 콘솔 또는 원격 접속 |
| 2 | EIGRP 라우터 | 아랫 네트워크(EIGRP) 소속 | 콘솔 또는 원격 접속 |
| 3 | 연결 구간 | 두 네트워크를 잇는 대역, 양쪽 포트에 IP 할당 완료 | |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 서로 다른 라우터가 같은 대역을 중복해서 광고하면 오류나 경로 충돌이 생긴다. 같은 대역은 한쪽 라우터에서만 광고한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 재분배를 설정하면 운영 중인 라우팅 테이블이 바뀌어 통신이 끊길 수 있다. 연결 구간의 IP 설정을 마친 뒤에 수행하고, 점검 시간에 작업한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 두 라우터의 현재 설정을 백업한다: `show running-config` | 출력을 파일로 저장했다 |
| 2 | 연결 구간 포트의 IP 할당을 확인한다: `show ip interface brief` | 양쪽 포트가 `up/up`이다 |
| 3 | EIGRP 자율 시스템 번호를 확인한다: `show ip protocols` | 번호를 기록했다(예: `100`) |

## 5. 절차

윗 네트워크는 RIP, 아랫 네트워크는 EIGRP이다. 아래 `<…>`는 환경마다 다른 값이다.

### A. EIGRP 라우터 설정

1. (5-A-01) EIGRP 라우터에 접속해 전역 설정 모드로 들어간다: `configure terminal` → 결과: `(config)#` 프롬프트가 나온다.
2. (5-A-02) EIGRP 프로세스로 들어간다: `router eigrp <AS 번호>` → 결과: `(config-router)#` 프롬프트가 나온다.
3. (5-A-03) 추가한 연결 네트워크를 등록한다: `network <추가된 네트워크> <와일드카드>` → 결과: 오류 없이 다음 프롬프트가 나온다.
4. (5-A-04) 설정 모드를 빠져나와 등록을 확인한다: `end`, `show ip protocols` → 결과: 등록한 네트워크가 EIGRP 항목에 보인다.

### B. RIP 라우터에서 재분배 설정

1. (5-B-01) RIP 라우터에 접속해 전역 설정 모드로 들어간다: `configure terminal` → 결과: `(config)#` 프롬프트가 나온다.
2. (5-B-02) RIP 프로세스로 들어간다: `router rip` → 결과: `(config-router)#` 프롬프트가 나온다.
3. (5-B-03) EIGRP 경로를 RIP로 재분배한다: `redistribute eigrp <AS 번호> metric <홉 수>` → 결과: 오류 없이 다음 프롬프트가 나온다.
4. (5-B-04) 연결할 네트워크를 등록한다: `network <연결할 네트워크>` → 결과: 오류 없이 다음 프롬프트가 나온다.
5. (5-B-05) 자동 요약을 끈다: `no auto-summary` → 결과: 오류 없이 다음 프롬프트가 나온다.
6. (5-B-06) 설정 모드를 빠져나온다: `end` → 결과: `#` 프롬프트가 나온다.

원본은 `metric 0`을 썼다. RIP의 metric은 홉 수이며 유효 범위는 1~15다. 값은 환경에 맞게 정한다(확인 필요).

### C. OSPF와 EIGRP 사이 재분배 (요점만)

* OSPF의 backbone(area 0)과 반드시 연결할 필요는 없다.
* 설정 절차는 원본에 없다. 추후 보완한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | RIP 라우터에서 `show ip route rip` | EIGRP 네트워크의 경로가 나온다 | 대상 경로가 표시된다 |
| 2 | EIGRP 라우터에서 `show ip route eigrp` | 연결 네트워크가 나온다 | 대상 경로가 표시된다 |
| 3 | 윗 네트워크 호스트에서 아랫 네트워크 호스트로 `ping <대상 IP>` | 응답이 온다 | 손실 0% |

## 7. 복구

1. (7-01) RIP 라우터에서 재분배를 제거한다: `router rip` 입력 후 `no redistribute eigrp <AS 번호>` → 결과: `show running-config`에 해당 줄이 없다.
2. (7-02) EIGRP 라우터에서 추가한 네트워크를 제거한다: `router eigrp <AS 번호>` 입력 후 `no network <추가된 네트워크> <와일드카드>` → 결과: `show ip protocols`에 해당 네트워크가 없다.
3. (7-03) 준비 단계에서 저장한 설정과 `show running-config`를 비교한다 → 결과: 차이가 없다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | AMM 형식으로 재작성. 빈 코드 블록 삭제, 복구 절 추가 |
