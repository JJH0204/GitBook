# 4-1. Reflexive ACL 실습

> 상위: [10일차 ACL과 첫 침해사고](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-10-009-MP |
| 목적 | 경계(Gi0/2)에 LC-OUT의 `reflect`와 LC-IN의 `evaluate`를 걸어, 새봄상사에서 먼저 건 통신의 답이 들어오고 한결물류의 먼저 거는 접근은 계속 막히는 것을 확인한다 |
| 적용 대상 | 허가받은 격리 실습 환경. Cisco Packet Tracer의 `_실습/새봄상사.pkt` 안의 가상 장비(HQ-R1, BR-PC1, LC-PC1) |
| 소요 시간 | 약 12분 (대본 11번 6분, 12번 6분) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이번 재작성에서 다시 실행하지 않았다. 패킷트레이서가 `reflect`와 `evaluate`를 받는지 수업 전에 확인해야 한다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-4.md](lesson-4.md) | LEC-SN-10-004-DO | 돌아오는 길: established와 Reflexive ACL |
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-SN-10-008-MP | 선행 실습. LC-IN이 걸려 있어야 한다 |
| [commands.md](commands.md) | LEC-SN-10-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Packet Tracer 파일 | `_실습/새봄상사.pkt` (3-1 실습을 마친 상태) | |
| 2 | HQ-R1 | Gi0/2에 LC-IN(in)이 걸려 있다 | |
| 3 | BR-PC1, LC-PC1 | 지사 PC, 한결물류 PC(172.16.10.10) | |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: `evaluate`는 LC-IN의 20번 거부 줄보다 위(15번)에 끼워 넣는다. 아래에 두면 답이 20번 줄에서 먼저 버려진다.
{% endhint %}

{% hint style="info" %}
NOTE: 패킷트레이서가 `reflect`와 `evaluate`를 받지 않으면 `permit tcp any any established`로 TCP만 확인한다(웹이나 텔넷으로).
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | LC-IN이 Gi0/2에 걸려 있다 | HQ-R1 `show ip interface gi0/2`에 `Inbound access list is LC-IN`이 보인다 |
| 2 | 새봄상사에서 한결물류로 먼저 건 통신이 막혀 있다 | BR-PC1에서 `ping 172.16.10.10`을 입력하면 답이 오지 않는다 |

## 5. 절차

### A. LC-OUT의 reflect

1. (5-A-01) BR-PC1에서 `ping 172.16.10.10`을 입력한다. → 결과: 답이 오지 않는다.
2. (5-A-02) HQ-R1에서 `configure terminal`, `ip access-list extended LC-OUT`을 입력한다.
3. (5-A-03) 아래 세 줄을 차례로 입력하고 `exit`를 입력한다.

```
 permit tcp any any reflect LC-RETURN
 permit udp any any reflect LC-RETURN
 permit icmp any any reflect LC-RETURN
```

4. (5-A-04) `interface gi0/2`, `ip access-group LC-OUT out`, `end`를 차례로 입력한다.

### B. evaluate와 확인

1. (5-B-01) HQ-R1에서 `configure terminal`, `ip access-list extended LC-IN`을 입력한다.
2. (5-B-02) `15 evaluate LC-RETURN`, `end`를 입력한다.
3. (5-B-03) BR-PC1에서 `ping 172.16.10.10`을 입력한다. → 결과: Reply.
4. (5-B-04) HQ-R1에서 `show access-lists`를 입력한다. → 결과: Reflexive IP access list LC-RETURN에 임시 줄과 `time left`가 보인다.
5. (5-B-05) LC-PC1에서 `ping 192.168.10.42`를 입력한다. → 결과: 여전히 닿을 수 없다.
6. (5-B-06) 설정을 바꾼 장비(HQ-R1, HQ-DSW1, BR-R1, 스위치 세 대, LC-R1)에서 `copy running-config startup-config`를 입력해 저장한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | BR-PC1에서 한결물류 PC로 ping | Reply | 답이 들어온다 |
| 2 | HQ-R1 `show access-lists` | Reflexive IP access list LC-RETURN에 임시 줄 | `time left`가 보인다 |
| 3 | LC-PC1에서 인사팀 PC로 ping | 닿을 수 없음 | 한결물류의 먼저 거는 접근이 막혀 있다 |

## 7. 탐지·방어

확인 상태: 미검증 (일반 지식으로 짧게 정리했다).

| 항목 | 내용 |
|---|---|
| 원인 | Reflexive ACL의 임시 줄은 시간이 다할 때까지 해당 주소 쌍의 답을 모두 들인다. `established`는 플래그만 보므로 ACK를 켠 가짜 패킷도 맞는다 |
| 완화 | 상태 추적 방화벽(13, 14일차)으로 옮긴다. 경계의 기본값을 "필요한 것만 연다"로 유지한다 |
| 로그에서 보이는 흔적 | LC-IN 20번 줄 적중 횟수 증가, Reflexive 임시 줄의 생성과 소멸 |

## 8. 복구

1. (8-01) 답이 들어오지 않으면 `evaluate`가 20번 줄 아래에 있는지 `show access-lists LC-IN`으로 확인하고 15번 자리에 다시 끼워 넣는다.
2. (8-02) 되돌리려면 HQ-R1에서 `interface gi0/2`, `no ip access-group LC-OUT out`을 입력하고, `ip access-list extended LC-IN`에서 `no 15`를 입력한다. → 결과: 3-1 실습을 마친 상태로 돌아간다.

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 11~12번과 `lesson-4.md`의 설정 안내를 AMM 형식 MP로 분리. 탐지·방어 절과 복구 절 추가 |
