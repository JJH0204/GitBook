# 실습 2. OSPF — 지도를 보고 계산하게 하기

> 상위: [5일차 · 라우팅 프로토콜](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N1-05-008-MP |
| 목적 | RIPv2 실습과 같은 망에 OSPF(Area 0)를 설정해 이웃이 `FULL`이 되고 경로가 몇 초 만에 생기는 것을 확인한다 |
| 적용 대상 | Cisco Packet Tracer, Cisco IOS 라우터 3대(R1~R3), 스위치 2대, PC 2대 |
| 소요 시간 | 약 35분 |
| 확인 상태 | 미검증 (원본 강의 노트의 명령 대본을 정리한 것이며 Packet Tracer에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

그림과 주소는 [LEC-N1-05-007-MP](lesson-4-lab-ripv2.md)와 완전히 같다. 바뀌는 것은 라우팅 프로토콜 하나뿐이다.

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-3.md](lesson-3.md) | LEC-N1-05-003-DO | 3. OSPF와 EIGRP |
| [lesson-4-lab-ripv2.md](lesson-4-lab-ripv2.md) | LEC-N1-05-007-MP | 실습 1. RIPv2 (구역 A~D가 공통 준비) |
| [commands.md](commands.md) | LEC-N1-05-006-REF | 0. 5일차 실습 명령어 (와일드카드 계산) |
| [lesson-4-troubleshooting.md](lesson-4-troubleshooting.md) | LEC-N1-05-011-TS | 5일차 실습 문제 해결 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Packet Tracer | 실습 1과 같은 버전 | |
| 2 | 새 `.pkt` 파일 | 실습 1 파일을 고쳐 쓰지 않는다 | |
| 3 | 장비 | 라우터 3대, 스위치 2대, PC 2대 | 실습 1과 같은 구성 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: OSPF `network` 뒤에는 서브넷 마스크(`255.255.255.0`)가 아니라 와일드카드 마스크(`0.0.0.255`)를 적는다. 서브넷 마스크를 쓰면 동작하지 않는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `area` 번호는 이웃끼리 같아야 한다. 이 실습에서는 모든 `network`에 `area 0`을 쓴다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 새 파일에서 LEC-N1-05-007-MP의 구역 A~D를 그대로 다시 수행한다 | 세 라우터 모두 `show ip interface brief`에서 `up/up` 2개 |
| 2 | 라우팅 테이블을 확인한다 | `show ip route`에 `C` 2개, `L` 2개뿐이다 |
| 3 | 출발 상태를 확인한다: PC0에서 `ping 192.168.30.1` | 실패한다(아직 경로가 없다) |

## 5. 절차

### A. 세 라우터에 OSPF 켜기

1. (5-A-01) R1의 `CLI` 탭에서 다음 명령을 입력한다.

```
configure terminal
router ospf 1
 network 192.168.10.0 0.0.0.255 area 0
 network 192.168.20.0 0.0.0.255 area 0
end
```

→ 결과: 오류 없이 끝난다. 1은 프로세스 번호이며 이 장비 안에서만 의미가 있다. `0.0.0.255`는 와일드카드 마스크다. 혼자 켜면 이웃이 없다.

2. (5-A-02) R2의 `CLI` 탭에서 다음 명령을 입력한다.

```
configure terminal
router ospf 1
 network 192.168.20.0 0.0.0.255 area 0
 network 192.168.50.0 0.0.0.255 area 0
end
```

→ 결과: 이웃이 맺어졌다는 로그 메시지(`%OSPF-5-ADJCHG` ... `LOADING to FULL`)가 화면에 뜬다.

3. (5-A-03) R3의 `CLI` 탭에서 다음 명령을 입력한다.

```
configure terminal
router ospf 1
 network 192.168.30.0 0.0.0.255 area 0
 network 192.168.50.0 0.0.0.255 area 0
end
show ip ospf neighbor
```

→ 결과: 이웃이 `FULL` 상태다.

### B. 결과 읽기

1. (5-B-01) R1의 `CLI` 탭에서 `show ip route`를 입력한다. → 결과: 몇 초 만에 `O` 경로가 생긴다.
2. (5-B-02) `show ip ospf neighbor`를 입력한다. → 결과: 이웃 1개가 `FULL`이다.
3. (5-B-03) `show ip protocols`를 입력한다. → 결과: ospf가 돌고 있다.
4. (5-B-04) `O 192.168.30.0/24 [110/3] via 192.168.20.2` 줄을 읽는다. → 결과: `O`는 OSPF가 알려 준 경로, `110`은 AD, `3`은 코스트다. 홉 수가 아니다.
5. (5-B-05) PC0에서 `ping 192.168.30.1`과 `tracert 192.168.30.1`을 입력한다. → 결과: ping이 성공하고 tracert가 라우터를 거치는 경로를 보여 준다.
6. (5-B-06) 세 라우터에서 `copy running-config startup-config`를 입력하고 파일을 `Ctrl + S`로 저장한다. → 결과: 저장이 끝난다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 세 라우터에서 `show ip route` | `O` 경로가 보인다 | 각 라우터에 `O` 경로 존재 |
| 2 | `show ip ospf neighbor` | 이웃 상태 `FULL` | 이웃이 모두 `FULL` |
| 3 | R1의 30.0 경로 | `[110/3]` | AD 110, 코스트 3 |
| 4 | PC0에서 `ping 192.168.30.1` | 응답이 온다 | 4개 모두 성공 |

## 7. 복구

1. (7-01) OSPF 설정을 지우려면 세 라우터에서 `configure terminal` → `no router ospf 1` → `end`를 입력한다. → 결과: `show ip route`에서 `O` 경로가 사라진다.
2. (7-02) 파일 전체를 되돌리려면 저장하지 않고 닫는다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 commands.md의 실습 2와 lesson-4.md의 OSPF 절을 별도 MP 문서로 분리하고 AMM 형식으로 정리했다. 이웃 로그 메시지 표기를 IOS 실제 형식(`%OSPF-5-ADJCHG`)으로 정정했다 |
