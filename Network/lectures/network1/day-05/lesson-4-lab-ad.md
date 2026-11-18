# 부록 A. AD 대결 — RIP과 OSPF를 함께 켜기

> 상위: [5일차 · 라우팅 프로토콜](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N1-05-009-MP |
| 목적 | OSPF가 켜진 망에 RIP을 함께 켜서 같은 목적지를 두 프로토콜이 알려 줄 때 AD가 낮은 OSPF(110)의 경로만 테이블에 오르는 것을 확인한다 |
| 적용 대상 | Cisco Packet Tracer, 실습 2(OSPF)를 마친 파일 |
| 소요 시간 | 약 15분 |
| 확인 상태 | 미검증 (원본 강의 노트의 명령 대본을 정리한 것이며 Packet Tracer에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1.md](lesson-1.md) | LEC-N1-05-001-DO | 1. 라우팅 프로토콜 개요 (AD 표) |
| [lesson-4-lab-ospf.md](lesson-4-lab-ospf.md) | LEC-N1-05-008-MP | 실습 2. OSPF |
| [4일차 · 오늘의 CCNA](../day-04/lesson-4.md) | - | Q4 AD 비교 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 실습 2 파일 | OSPF가 설정돼 있다 | 실습 2의 파일에서 이어서 진행한다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: OSPF를 지우지 않는다. OSPF를 지우면 AD 대결을 볼 수 없다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | OSPF 경로가 있다 | 세 라우터의 `show ip route`에 `O` 경로가 있다 |

## 5. 절차

### A. RIP 추가

1. (5-A-01) R1에서 다음 명령을 입력한다. R2는 `network 192.168.20.0`, `network 192.168.50.0`을, R3은 `network 192.168.50.0`, `network 192.168.30.0`을 쓴다(각자 자기에게 직접 연결된 네트워크).

```
configure terminal
router rip
 version 2
 no auto-summary
 network 192.168.10.0
 network 192.168.20.0
end
```

→ 결과: 오류 없이 끝난다.

2. (5-A-02) R2, R3에서도 같은 방식으로 입력한다. → 결과: 세 라우터에 RIP이 켜진다.
3. (5-A-03) R1에서 30초 기다린 뒤 `show ip route`를 입력한다. → 결과: `O 192.168.30.0/24 [110/3]`이 그대로다. `R` 경로가 하나도 없다.

```
RIP을 켜기 전:  O    192.168.30.0/24 [110/3] via 192.168.20.2
RIP을 켠 뒤:    O    192.168.30.0/24 [110/3] via 192.168.20.2   ← 그대로다
```

4. (5-A-04) `show ip protocols`를 입력한다. → 결과: rip과 ospf가 둘 다 돌고 있다.
5. (5-A-05) 이유를 확인한다. → 결과: AD가 낮은 쪽만 테이블에 오른다. OSPF 110 < RIP 120이다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `show ip route` | `O` 경로만 있다 | `R` 경로 없음 |
| 2 | `show ip protocols` | rip과 ospf가 모두 표시된다 | 두 프로토콜 모두 존재 |

## 7. 복구

1. (7-01) 세 라우터에서 `configure terminal` → `no router rip` → `end`를 입력한다. → 결과: `show ip protocols`에 ospf만 남는다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 commands.md의 부록 A와 lesson-4.md의 AD 대결 절을 별도 MP 문서로 분리하고 AMM 형식으로 정리했다 |
