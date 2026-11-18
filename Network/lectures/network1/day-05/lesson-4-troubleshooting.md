# 5일차 실습 문제 해결

> 상위: [5일차 · 라우팅 프로토콜](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N1-05-011-TS |
| 유형 | TS (문제 해결) |
| 목적 | 5일차 실습(RIPv2, OSPF, AD 대결)에서 막힐 때 증상별 원인과 조치를 찾는다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 장비에서 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 케이블, 링크 점 색깔 같은 패킷트레이서 조작 문제는 3일차 표를 본다. → [3일차 · 자주 나는 오류](../day-03/lesson-4.md)
{% endhint %}

## 1. 증상과 가능 원인

| 증상 | 가능 원인 | 확인 | 시정 조치 |
|---|---|---|---|
| 경로가 생기지 않는다 | 30초를 기다리지 않았다(1순위) | 마지막 입력 후 경과 시간 | 30초 뒤 `show ip route`를 한 번 더 입력한다 |
| 30초 뒤에도 생기지 않는다 | 상대 라우터에 RIP을 켜지 않았다. `network`를 양쪽에 적지 않았다 | 양쪽에서 `show ip protocols` | 양쪽 모두 설정한다 |
| `network`를 입력했는데 무시된다 | 목적지를 적었다 | `show ip protocols`의 광고 네트워크 | 내게 직접 연결된 네트워크를 적는다 |
| 경로가 이상하게 뭉쳐 보인다. 마스크가 이상하다 | `version 2` 또는 `no auto-summary`를 빠뜨렸다 | `show ip protocols` | 두 명령을 입력한다 |
| `C` 경로가 없다 | `no shutdown`을 하지 않았다 | `show ip interface brief`가 `up/up`인가 | 인터페이스에서 `no shutdown` |
| OSPF 이웃이 맺어지지 않는다 | `area` 번호가 서로 다르다. 와일드카드가 틀렸다 | `show ip ospf neighbor` | area 번호를 맞추고 와일드카드를 고친다 |
| OSPF `network`가 적용되지 않는다 | 서브넷 마스크(`255.255.255.0`)를 적었다 | `show running-config`의 `router ospf` 블록 | `0.0.0.255`로 고친다 |
| `R` 경로가 사라지고 `O`만 남았다 | 정상이다. AD 110 < 120이다 | `show ip protocols`에 두 프로토콜이 있다 | 조치 불필요. → [LEC-N1-05-001-DO](lesson-1.md) |
| 화면이 계속 흐른다 | `debug`를 켜 두었다 | 화면에 디버그 출력 | `undebug all` |
| 껐다 켜니 설정이 사라졌다 | `copy running-config startup-config`를 하지 않았다 | `show startup-config` | 설정 후 `copy running-config startup-config` |

## 2. 격리 절차

1. 라우터에서 `show ip interface brief`를 본다. `up/up`이 아니면 `no shutdown`과 케이블을 확인한다.
2. `show ip route`에 `C`가 인터페이스 수만큼 있는지 본다. 없으면 주소 입력 오류를 확인한다.
3. `show ip protocols`로 프로토콜이 켜져 있는지, 광고한 네트워크가 내게 직접 연결된 것인지 확인한다.
4. RIP이면 `version 2`와 `no auto-summary`가 있는지 확인한다. 설정 후 30초를 기다린다.
5. OSPF이면 `show ip ospf neighbor`로 이웃이 `FULL`인지 확인한다. 아니면 area 번호와 와일드카드를 확인한다.
6. 양쪽 라우터에서 1~5를 반복한다.
7. 설정을 바꿨으면 `copy running-config startup-config`로 저장한다.

## 3. 관련 문서

| 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-4-lab-ripv2.md](lesson-4-lab-ripv2.md) | LEC-N1-05-007-MP | 실습 1. RIPv2 |
| [lesson-4-lab-ospf.md](lesson-4-lab-ospf.md) | LEC-N1-05-008-MP | 실습 2. OSPF |
| [lesson-4-lab-debug.md](lesson-4-lab-debug.md) | LEC-N1-05-010-MP | 부록 B. debug ip rip |
| [commands.md](commands.md) | LEC-N1-05-006-REF | 0. 5일차 실습 명령어 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 경로가 생기지 않을 때 설정을 지우기 전에 확인해야 할 것을 내 말로 적어 본다.
- [ ] OSPF 이웃이 맺어지지 않을 때 내가 확인한 순서를 적어 본다.
