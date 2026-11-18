# 4-1. VTP transparent 설정 실습

> 상위: [3일차 스위칭과 VLAN](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-03-009-MP |
| 목적 | 두 스위치의 VTP 모드를 transparent로 바꾸고, VLAN 설정이 설정 텍스트에 남는 것을 확인한다 |
| 적용 대상 | Cisco Packet Tracer의 `_실습/새봄상사.pkt`, Catalyst 2960 스위치 (HQ-SW1, HQ-SW2) |
| 소요 시간 | 약 9분 |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이번 재작성에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-4.md](lesson-4.md) | LEC-SN-03-004-DO | VTP와 스위치 보안 점검 |
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-SN-03-008-MP | 앞 실습. 서브인터페이스와 관리 주소 |
| [commands.md](commands.md) | LEC-SN-03-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 패킷트레이서 파일 | `_실습/새봄상사.pkt` | 3-1 실습을 마친 상태 |
| 2 | 스위치 | HQ-SW1, HQ-SW2 | 각각 따로 입력한다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 리비전 번호 사고는 이 실습에서 재현하지 않는다. VTP 도메인 설정이 다른 스위치와 겹치는 실습망에서는 VLAN 목록이 덮어쓰일 수 있다. 실습 파일의 가상 장비에서만 한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 두 스위치에 VLAN이 만들어져 있다 | `show vlan brief`에 VLAN 10, 20, 30, 40, 99, 900, 999가 나온다 |

## 5. 절차

### A. 바꾸기 전 상태 보기 (HQ-SW1, HQ-SW2 모두)

1. (5-A-01) 아래를 입력한다. → 결과: `show vtp status`의 VTP Operating Mode가 `Server`이고, `show running-config | include vlan`에 `vlan 10` 같은 줄이 없다.

```
show vtp status
show running-config | include vlan
```

### B. transparent로 바꾸고 저장 (HQ-SW1, HQ-SW2 모두)

1. (5-B-01) 아래를 입력한다. → 결과: 이제 `vlan 10`, `vlan 20` 줄이 보인다.

```
configure terminal
vtp mode transparent
end
show running-config | include vlan
copy running-config startup-config
```

2. (5-B-02) 두 스위치와 라우터 모두 저장한다. → 결과: 저장 확인 메시지가 나온다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `show vtp status` | VTP Operating Mode가 `Transparent` | 두 스위치 모두 |
| 2 | `show running-config \| include vlan` | `vlan 10`부터 `vlan 999`까지 일곱 줄이 보인다 (`switchport access vlan` 줄도 함께 보인다) | 해당 |
| 3 | Sales-PC1에서 Sales-PC3으로 `ping` | Reply | VLAN 통신이 그대로 유지됨 |

## 7. 복구

1. (7-01) server 모드로 되돌리려면 `configure terminal`, `vtp mode server`를 입력한다. → 결과: VTP Operating Mode가 `Server`로 바뀐다. VLAN 설정이 설정 텍스트에서 다시 사라진다.
2. (7-02) 저장하지 않았다면 `reload`를 입력하고 저장 여부 질문에 `no`를 입력한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 8번을 AMM 형식 MP로 분리 |
