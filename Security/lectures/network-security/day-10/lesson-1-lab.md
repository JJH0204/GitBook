# 1-1. NAT-INSIDE에 거부 줄 끼워 넣기 실습

> 상위: [10일차 ACL과 첫 침해사고](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-10-006-MP |
| 목적 | HQ-R1의 NAT-INSIDE 맨 위에 장비 관리 VLAN 거부 줄(5번)을 끼워 넣고 순서를 확인한다 |
| 적용 대상 | 허가받은 격리 실습 환경. Cisco Packet Tracer의 `_실습/새봄상사.pkt`, 2911 라우터 HQ-R1 (IOS 15 형식) |
| 소요 시간 | 약 5분 (대본 1번) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이번 재작성에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1.md](lesson-1.md) | LEC-SN-10-001-DO | ACL의 원리 (5절 줄 번호로 끼워 넣기) |
| [commands.md](commands.md) | LEC-SN-10-005-REF | 실습 명령어 모음 |
| [lesson-2-lab.md](lesson-2-lab.md) | LEC-SN-10-007-MP | 다음 실습. SALES-IN과 access-class |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Packet Tracer 파일 | `_실습/새봄상사.pkt` (9일차 NAT 설정이 들어 있는 것) | |
| 2 | HQ-R1 | 2911, NAT-INSIDE 표준 ACL이 10번, 20번 줄로 있다 | |

## 3. 안전 사항

{% hint style="info" %}
NOTE: 장비 화면은 IOS 15 형식이다. 패킷트레이서 버전에 따라 값과 줄 구성이 다를 수 있다. 패킷트레이서가 이름 붙인 ACL의 줄 번호 끼워 넣기(`5 deny ...`)를 받는지 수업 전에 확인한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | HQ-R1에서 `show access-lists NAT-INSIDE`를 입력한다 | `10 permit 192.168.10.0 0.0.0.255`와 `20 permit 192.168.20.0 0.0.0.255`가 보인다 |

## 5. 절차

### A. 5번 줄 끼워 넣기

1. (5-A-01) HQ-R1에서 `configure terminal`을 입력한다.
2. (5-A-02) `ip access-list standard NAT-INSIDE`를 입력한다. → 결과: 프롬프트가 `(config-std-nacl)#`로 바뀐다.
3. (5-A-03) `5 deny 192.168.10.128 0.0.0.31`을 입력한다.
4. (5-A-04) `end`를 입력한다.
5. (5-A-05) `show access-lists NAT-INSIDE`를 입력한다. → 결과: 5번 줄이 10번 줄 위에 보인다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | HQ-R1 `show access-lists NAT-INSIDE` | 5번 줄이 가장 위에 있다 | `5 deny 192.168.10.128 0.0.0.31`이 10번 줄보다 위에 있다 |

## 7. 복구

1. (7-01) HQ-R1에서 `configure terminal`, `ip access-list standard NAT-INSIDE`를 입력한다.
2. (7-02) `no 5`를 입력해 5번 줄을 지우고 `end`를 입력한다. → 결과: `show access-lists NAT-INSIDE`에 10번, 20번 줄만 남는다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 1번과 `lesson-1.md`의 5절 설정 안내를 AMM 형식 MP로 분리 |
