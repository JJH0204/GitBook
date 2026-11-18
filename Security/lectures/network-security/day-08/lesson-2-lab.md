# 2-1. 지사 DHCP 릴레이 실습

> 상위: [8일차 DHCP와 게이트웨이 이중화](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-08-007-MP |
| 목적 | 지사 라우터 BR-R1에 `ip helper-address`를 넣어, 지사 PC가 본사 HQ-R1의 BR-SALES 풀에서 주소를 받게 한다 |
| 적용 대상 | Cisco Packet Tracer의 `_실습/새봄상사.pkt` (2911 라우터 BR-R1, HQ-R1). 1-1 실습을 마친 상태. 격리된 가상 실습망이며 실제 장비와 연결하지 않는다 |
| 소요 시간 | 약 8분 |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이 환경에서 패킷트레이서를 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-2.md](lesson-2.md) | LEC-SN-08-002-DO | DHCP 릴레이: 지사에도 주소를 |
| [lesson-1-lab.md](lesson-1-lab.md) | LEC-SN-08-006-MP | DHCP 풀 만들기 (BR-SALES 풀의 출처) |
| [commands.md](commands.md) | LEC-SN-08-005-REF | 실습 명령어 모음 (3번) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Cisco Packet Tracer | `_실습/새봄상사.pkt` 파일 | 1-1 실습의 결과가 들어 있다 |
| 2 | 라우터 | BR-R1 | Gi0/0에 릴레이를 건다 |
| 3 | 라우터 | HQ-R1 | 루프백 0(192.168.255.1)과 BR-SALES 풀이 있다 |
| 4 | PC | BR-PC1, BR-PC2 | DHCP로 바꾼다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: `ip helper-address`는 지사 PC가 붙은 BR-R1의 Gi0/0에 넣는다. 본사 라우터에 넣으면 지사의 외침이 전해지지 않는다.
{% endhint %}

{% hint style="info" %}
NOTE: 패킷트레이서에서 루프백(192.168.255.1)으로 보내는 릴레이가 안 되면 `192.168.99.1`로 바꾼다. 이 경우 주 회선이 끊기면 릴레이도 멈춘다는 점을 기록에 적는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | HQ-R1에 BR-SALES 풀이 있다 | `show running-config`의 `ip dhcp pool` 부분에 BR-SALES가 보인다 |
| 2 | HQ-R1에 루프백 0이 있다 | `show ip interface brief`에 192.168.255.1이 보인다 |
| 3 | 지사 PC에서 본사로 ping이 된다 | BR-PC1에서 `ping 192.168.10.98`에 Reply가 온다 |

## 5. 절차

### A. 릴레이가 없을 때의 실패 확인

1. (5-A-01) BR-PC1의 IP Configuration을 `DHCP`로 바꾼다. → 결과: 실패하고 169.254로 시작하는 주소가 붙는다. 지사의 외침이 BR-R1에서 멈춘 것이다.

### B. 릴레이 설정

1. (5-B-01) BR-R1 CLI에서 지사 PC 쪽 인터페이스에 한 줄을 넣는다. → 결과: 프롬프트가 `BR-R1#`로 돌아온다.

```
configure terminal
interface gi0/0
 ip helper-address 192.168.255.1
 end
```

### C. 주소 받기와 확인

1. (5-C-01) BR-PC1과 BR-PC2를 다시 `DHCP`로 받는다. → 결과: 192.168.20.10, 192.168.20.11이 붙는다.
2. (5-C-02) HQ-R1에서 `show ip dhcp binding`을 입력한다. → 결과: 1-1 실습의 다섯 줄에 지사 주소 두 줄이 더해진다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | BR-PC1의 IP Configuration | 192.168.20.10, 게이트웨이 192.168.20.1 | 주소와 게이트웨이 일치 |
| 2 | BR-PC2의 IP Configuration | 192.168.20.11 | 주소 일치 |
| 3 | HQ-R1에서 `show ip dhcp binding` | 지사 주소 두 줄 | 192.168.20.10, .11이 있다 |
| 4 | BR-R1에서 `show running-config`의 Gi0/0 부분 | `ip helper-address 192.168.255.1` | 해당 줄 존재 |

## 7. 복구

1. (7-01) 릴레이를 되돌리려면 BR-R1의 Gi0/0에서 `no ip helper-address 192.168.255.1`을 입력한다.
2. (7-02) 지사 PC를 고정 주소로 되돌리려면 IP Configuration에서 `Static`을 고르고 4일차 주소표(192.168.20.2, .3)를 넣는다.
3. (7-03) 다음 실습(LEC-SN-08-008-MP)으로 넘어가기 전에 `copy running-config startup-config`로 BR-R1을 저장한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 3번을 AMM 형식 MP로 분리. 번호(3)는 다른 문서의 참조 때문에 `commands.md`에 유지 |
