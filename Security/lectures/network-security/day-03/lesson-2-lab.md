# 2-1. 트렁크 설정 실습

> 상위: [3일차 스위칭과 VLAN](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-03-007-MP |
| 목적 | HQ-SW1과 HQ-R1 사이, HQ-SW1과 HQ-SW2 사이에 트렁크를 만들고 필요한 VLAN만 허락한다 |
| 적용 대상 | Cisco Packet Tracer의 `_실습/새봄상사.pkt`, Catalyst 2960 스위치 |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이번 재작성에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-2.md](lesson-2.md) | LEC-SN-03-002-DO | 트렁크: 선 하나에 여러 VLAN |
| [lesson-1-lab.md](lesson-1-lab.md) | LEC-SN-03-006-MP | 앞 실습. VLAN 만들기와 포트 배정 |
| [commands.md](commands.md) | LEC-SN-03-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 패킷트레이서 파일 | `_실습/새봄상사.pkt` | 1-1 실습을 마친 상태 |
| 2 | 스위치 | HQ-SW1, HQ-SW2 | 두 대 모두 VLAN 10, 20, 30, 40, 99, 900, 999가 있어야 한다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 트렁크의 `allowed vlan`에 빠진 VLAN은 그 선을 건너지 못한다. 99가 빠지면 관리 접속이 끊긴다.
{% endhint %}

{% hint style="info" %}
NOTE: 이 실습의 이중 태그 같은 공격은 재현하지 않는다. 트렁크가 저절로 생기지 않게 하는 설정만 입력한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 두 스위치의 VLAN을 확인한다 | `show vlan brief`에 VLAN 10, 20, 30, 40, 99, 999가 나온다 |
| 2 | HQ-SW1 Gi0/2와 HQ-SW2 Gi0/1이 이어져 있다 | 연결 불빛이 켜져 있다 |

## 5. 절차

### A. HQ-SW1 라우터 쪽 트렁크 (Gi0/1)

native VLAN은 바꾸지 않는다.

1. (5-A-01) HQ-SW1에서 아래를 입력한다. → 결과: 오류 없이 끝난다.

```
interface gi0/1
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30,40,99
 switchport nonegotiate
```

### B. HQ-SW1 2층 쪽 트렁크 (Gi0/2)

1. (5-B-01) HQ-SW1에서 아래를 입력한다. → 결과: 오류 없이 끝난다.

```
interface gi0/2
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30,40,99
 switchport trunk native vlan 900
 switchport nonegotiate
 end
```

2. (5-B-02) 몇 초 기다린다. → 결과: `%CDP-4-NATIVE_VLAN_MISMATCH` 알림이 뜬다. HQ-SW2 쪽 native VLAN이 아직 1이기 때문이다.

### C. HQ-SW2 트렁크 (Gi0/1)

1. (5-C-01) HQ-SW2에서 아래를 입력한다. → 결과: `%CDP-4-NATIVE_VLAN_MISMATCH` 알림이 멈춘다.

```
interface gi0/1
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30,40,99
 switchport trunk native vlan 900
 switchport nonegotiate
 end
```

### D. 확인

1. (5-D-01) HQ-SW1에서 `show interfaces trunk`를 입력한다. → 결과: Gi0/1(native 1)과 Gi0/2(native 900)가 `trunking`이고, 허락한 VLAN이 10,20,30,40,99로 나온다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | HQ-SW1에서 `show interfaces trunk` | Gi0/1, Gi0/2가 `trunking`, Mode `on` | 둘 다 해당 |
| 2 | 같은 명령의 Native vlan 칸 | Gi0/1은 1, Gi0/2는 900 | 해당 |
| 3 | 알림 확인 | `NATIVE_VLAN_MISMATCH`가 더 뜨지 않는다 | 멈춤 |
| 4 | Sales-PC3(HQ-SW2 Fa0/11)에서 Sales-PC1로 ping | 주소와 게이트웨이를 설정한 뒤 [3-1 실습](lesson-3-lab.md)의 7번 단계에서 확인한다 | 응답 |

## 7. 복구

1. (7-01) 트렁크 설정을 되돌리려면 해당 포트에서 `no switchport mode trunk`, `no switchport trunk allowed vlan`, `no switchport trunk native vlan`, `no switchport nonegotiate`를 차례로 입력한다. → 결과: 포트가 기본 설정으로 돌아간다.
2. (7-02) 저장하지 않았다면 `reload`를 입력하고 저장 여부 질문에 `no`를 입력한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 4번을 AMM 형식 MP로 분리 |
