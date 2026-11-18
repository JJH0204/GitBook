# 4일차 실습 문제 해결

> 상위: [4일차 · 스위치와 라우터](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N1-04-007-TS |
| 유형 | TS (문제 해결) |
| 목적 | 4일차 실습(Lab 10~12)에서 막힐 때 증상별 원인과 조치를 찾는다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 장비에서 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 케이블, 링크 점 색깔, `Port Status` 같은 패킷트레이서 조작 문제는 3일차 표를 본다. → [3일차 · 자주 나는 오류](../day-03/lesson-4.md)
{% endhint %}

## 1. 증상과 가능 원인

| 증상 | 가능 원인 | 확인 | 시정 조치 |
|---|---|---|---|
| 인터페이스에 IP를 줬는데 `C`가 안 생긴다 | `no shutdown`을 하지 않았다 | `show ip interface brief`가 `up/up`인가 | 인터페이스 설정 모드에서 `no shutdown` |
| 게이트웨이까지는 되는데 그 너머가 안 된다 | 라우터에 정적 경로가 없다 | `show ip route`에 `S`가 있는가 | `ip route <목적지> <마스크> <다음 홉>` |
| 한 방향만 되는 것 같다 | 반대쪽 라우터에 경로가 없다 | 양쪽에서 `show ip route` | 반대쪽 라우터에도 경로 입력 |
| `Destination host unreachable` | 경로가 없다 | `show ip route` | 목적지로 가는 경로 추가 |
| `Request timed out` | 갈 길은 있는데 돌아오는 경로가 없다 | 반대쪽 라우터의 경로 | 돌아오는 경로 추가 |
| 명령을 쳤는데 멈춰 있다 | 오타로 DNS 조회 중이다 | 화면에 `Translating`이 보인다 | `Ctrl+Shift+6`으로 중단, `no ip domain-lookup` |
| `% Invalid input detected at '^' marker.` | `^`가 가리키는 자리가 틀렸거나 모드가 틀렸다 | 프롬프트의 모드(`>`, `#`, `(config)#`) | 틀린 자리를 고치거나 모드를 바꿔 다시 입력 |
| 껐다 켜니 설정이 사라졌다 | `copy running-config startup-config`를 하지 않았다 | `show startup-config` | 설정 후 `copy running-config startup-config` |
| PC 창에서 `show ip route`가 안 된다 | 입력하는 창이 틀렸다 | PC는 `C:\>`, 장비는 `Switch>`/`Router>` | PC에는 `ipconfig` 등, 장비에는 `CLI` 탭에서 입력 |

## 2. 격리 절차

1. 라우터에서 `show ip interface brief`를 본다. 인터페이스가 `up/up`이 아니면 `no shutdown`과 케이블을 확인한다.
2. `show ip route`에 `C`가 인터페이스 수만큼 있는지 본다. 없으면 주소 입력 오류를 확인한다.
3. 목적지 네트워크로 가는 `S` 경로가 있는지 본다. 없으면 추가한다.
4. 반대쪽 라우터에서도 1~3을 반복한다. 돌아오는 경로가 없으면 `Request timed out`이 난다.
5. 설정을 바꿨으면 `copy running-config startup-config`로 저장한다.

## 3. 관련 문서

| 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-3-lab-12.md](lesson-3-lab-12.md) | LEC-N1-04-006-MP | Lab 12. 정적 라우팅 |
| [lesson-3.md](lesson-3.md) | LEC-N1-04-003-DO | 3. Cisco CLI 기초와 실습 |
| [commands.md](commands.md) | LEC-N1-04-009-REF | 0. 4일차 실습 명령어 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `Destination host unreachable`과 `Request timed out`이 가리키는 원인의 차이를 내 말로 적어 본다.
- [ ] 실습에서 가장 오래 막혔던 지점이 있다면 무엇이었고 어떻게 풀었는지 적어 본다.
