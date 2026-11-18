# 스위칭 실습 문제 해결

> 상위: [7일차 · 스위칭 심화](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N1-07-005-TS |
| 유형 | TS (문제 해결) |
| 목적 | 7일차 실습(VLAN · 트렁크 · Router-on-a-stick · EtherChannel)에서 막힐 때 증상별 원인과 조치를 찾는다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 장비에서 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: `no shutdown`, 게이트웨이, 케이블 같은 공통 증상은 4일차 표를 본다. → [4일차 실습 문제 해결](../day-04/lesson-3-troubleshooting.md)
{% endhint %}

## 1. 증상과 가능 원인

| 증상 | 가능 원인 | 확인 | 시정 조치 |
|---|---|---|---|
| 같은 VLAN인데 층을 못 넘는다 (1위) | 스위치 사이가 트렁크가 아니다 | `show interfaces trunk` | 양쪽 `switchport mode trunk` |
| 같은 스위치의 다른 VLAN끼리 안 된다 | 정상이다. 라우터가 없다 | STEP 3 전인가 | Router-on-a-stick(STEP 3) 구성 |
| 라우터를 거쳐도 다른 VLAN이 안 된다 | SW1 Gi0/1이 액세스 그대로다 | SW1 `show interfaces trunk`에 Gi0/1이 있는가 | SW1 `interface g0/1` → `switchport mode trunk` |
| 라우터를 거쳐도 다른 VLAN이 안 된다 | R1 `g0/0`이 shutdown이다 | `show ip interface brief` | `interface g0/0` → `no shutdown` |
| 라우터를 거쳐도 다른 VLAN이 안 된다 | PC 게이트웨이 오타 | PC `ipconfig` | 게이트웨이를 `192.168.10.254` / `192.168.20.254`로 수정 |
| 서브인터페이스에 IP가 거부된다 | `encapsulation dot1Q`를 먼저 하지 않았다 | 오류 메시지 `% Configuring IP routing on a LAN subinterface ...` | `encapsulation dot1Q <VLAN 번호>` 입력 후 IP 입력 (태그 먼저, 주소 나중) |
| `encapsulation dot1Q 10`인데 VLAN 20 PC가 응답한다 | 서브인터페이스 번호와 태그가 뒤바뀌었다 | `show running-config`로 대조 | 서브인터페이스 번호와 태그를 맞춘다 |
| `show vlan brief`에서 포트가 사라졌다 | 트렁크가 된 것이다. 정상이다 | `show interfaces trunk` | 조치 없음 |
| PC 포트가 엉뚱한 VLAN에 있다 | `switchport access vlan` 오타 | `show vlan brief` | 올바른 VLAN 번호로 다시 입력 |
| `NATIVE_VLAN_MISMATCH` 경고 | 양쪽 네이티브 VLAN이 다르다 | 양쪽 `show interfaces trunk`의 Native vlan | 양쪽을 같은 번호로 맞춘다 |
| 두 번째 선이 계속 주황이다 | STP가 막은 것이다. 정상이다 | `show spanning-tree vlan 10`에서 `Altn BLK` | 조치 없음. 묶으려면 EtherChannel 구성 |
| `Po1(SD)`, 포트가 `(I)` / `(s)` | 한쪽만 설정했거나, active와 PAgP를 섞었거나, 두 선의 설정이 다르다 | 양쪽 `show etherchannel summary`, `show running-config interface fa0/23` | 양쪽에 같은 모드(`active`)와 같은 포트 설정을 넣는다 |
| `switchport trunk encapsulation`이 에러다 | 2960은 이 명령이 필요 없다(3560에서만 사용) | 장비 모델 | 명령을 생략한다 |
| PC를 꽂았는데 30초 동안 먹통이다 | STP 확인 중이다 | 링크 점이 주황인가 | PC 포트에 `spanning-tree portfast` |
| 껐다 켜니 설정이 사라졌다 | `copy running-config startup-config`를 하지 않았다 | `show startup-config` | 설정 후 `copy running-config startup-config` |

## 2. 격리 절차

1. 스위치 두 대에서 `show vlan brief`를 본다. PC 포트가 맞는 VLAN에 있는지 확인한다.
2. 양쪽 스위치에서 `show interfaces trunk`를 본다. 스위치 사이 포트가 `trunking`이고 Native vlan이 같은지 확인한다.
3. 다른 VLAN 통신이 안 되면 SW1 Gi0/1이 트렁크인지, R1 `g0/0`이 켜져 있는지 확인한다.
4. R1에서 `show ip interface brief`와 `show ip route`를 본다. `C`가 서브인터페이스마다 있는지 확인한다.
5. PC의 IP·마스크·게이트웨이를 `ipconfig`로 확인한다.
6. EtherChannel이 안 묶이면 양쪽에서 `show etherchannel summary`를 본다. 모드 조합과 두 포트의 설정을 맞춘다.
7. 설정을 바꿨으면 `copy running-config startup-config`로 저장한다.

## 3. 관련 문서

| 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-4.md](lesson-4.md) | LEC-N1-07-004-MP | 4. 스위칭 실습 |
| [lesson-2.md](lesson-2.md) | LEC-N1-07-002-DO | 2. 트렁크와 VLAN 간 라우팅 |
| [lesson-3.md](lesson-3.md) | LEC-N1-07-003-DO | 3. 선 두 줄을 하나로 — STP 다시 보기와 EtherChannel |
| [commands.md](commands.md) | LEC-N1-07-007-REF | 0. 7일차 실습 명령어 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 같은 VLAN인데 통신이 안 될 때 가장 먼저 확인하는 것은 무엇이고, 그 이유는 무엇일까?
- [ ] 라우터를 연결했는데도 VLAN 간 통신이 안 될 때 라우터 쪽과 스위치 쪽에서 각각 무엇을 보는지 적어 본다.
- [ ] 실습에서 직접 막혔던 지점이 있다면, 어떻게 원인을 찾았는지 적어 본다.
