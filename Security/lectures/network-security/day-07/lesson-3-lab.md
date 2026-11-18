# 3-1. 양방향 재분배 실습

> 상위: [7일차 EIGRP와 재분배](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-07-007-MP |
| 목적 | HQ-R1에서 OSPF와 EIGRP 사이에 거르지 않은 양방향 재분배를 걸고, 어떤 경로가 넘어갔는지 확인한다 |
| 적용 대상 | Cisco Packet Tracer의 `_실습/새봄상사.pkt` (HQ-R1, BR-R1, LC-R1, LC-PC1). 2-1 실습을 마친 상태. 격리된 가상 실습망이다 |
| 소요 시간 | 약 25분 (재분배 10, 확인 15) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이 환경에서 패킷트레이서를 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-3.md](lesson-3.md) | LEC-SN-07-003-DO | 재분배 |
| [lesson-2-lab.md](lesson-2-lab.md) | LEC-SN-07-006-MP | 선행 실습. 인수한 회사 장비 설치와 EIGRP 연결 |
| [commands.md](commands.md) | LEC-SN-07-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |
| [lesson-4-lab.md](lesson-4-lab.md) | LEC-SN-07-008-MP | 다음 실습. 경계 필터와 EIGRP 인증 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 라우터 | 2911 (HQ-R1, BR-R1, LC-R1) | 2-1 실습에서 구성을 마친 장비 |
| 2 | PC | LC-PC1 | 서버와 인사팀 PC로 ping을 보낸다 |
| 3 | 본사 PC | 인사팀 PC (192.168.10.34), 서버 (192.168.10.98) | 3일차까지 구성한 장비 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 이 실습은 일부러 거르지 않고 재분배한다. 인사팀과 장비 관리 대역까지 한결물류에 알려지는 것이 의도한 관찰 대상이다. 실제 운영망에서는 이렇게 하지 않고, 다음 실습(LEC-SN-07-008-MP)의 필터를 바로 건다.
{% endhint %}

{% hint style="info" %}
NOTE: 출력 예시는 IOS 15 형식이다. 패킷트레이서 버전에 따라 줄 구성이 조금 다를 수 있다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 2-1 실습을 마쳤다 | HQ-R1에서 `show ip eigrp neighbors`에 192.168.99.10이 있다 |
| 2 | 장비 설정을 저장했다 | `copy running-config startup-config`가 오류 없이 끝난다 |

## 5. 절차

### A. 양방향 재분배 (거르지 않고)

1. (5-A-01) HQ-R1에서 두 방향의 재분배를 입력한다.

```
configure terminal
router eigrp 20
 redistribute ospf 1 metric 100000 100 255 1 1500
router ospf 1
 redistribute eigrp 20 subnets
 end
```

→ 결과: 오류 없이 프롬프트가 `HQ-R1#`로 돌아온다. EIGRP 쪽의 `metric`과 OSPF 쪽의 `subnets`를 빠뜨리지 않는다.

### B. 확인, 무엇이 넘어갔나

1. (5-B-01) 지사와 한결물류 라우터의 경로표를 확인한다.

```
BR-R1#show ip route ospf
LC-R1#show ip route eigrp
```

→ 결과: BR-R1에 `O E2 172.16.10.0/24`, LC-R1에 `D EX` 줄이 여러 개 생긴다. 반영에 몇 초 걸리면 해당 라우터에서 `clear ip route *`를 입력한 뒤 다시 확인한다.

2. (5-B-02) LC-PC1에서 서버로 ping을 입력한다: `ping 192.168.10.98` → 결과: Reply가 온다.
3. (5-B-03) LC-PC1에서 인사팀 PC로 ping을 입력한다: `ping 192.168.10.34` → 결과: Reply가 온다. 한결물류가 인사팀에 닿는 것이 이 실습의 문제 장면이다.
4. (5-B-04) LC-R1의 D EX 줄을 [3번 노트](lesson-3.md) 4번 절의 표와 맞춰 본다. → 결과: 영업팀, 인사팀, 장비 관리, 지사, 연결 구간, 루프백 경로가 모두 보인다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | BR-R1에서 `show ip route ospf` | `O E2 172.16.10.0/24` | 해당 줄 존재 |
| 2 | LC-R1에서 `show ip route eigrp` | `D EX 192.168.10.x` 여러 줄 | 서버 VLAN 외의 줄도 보인다 |
| 3 | LC-PC1에서 `ping 192.168.10.98` | Reply | 응답 수신 |
| 4 | LC-PC1에서 `ping 192.168.10.34` | Reply | 응답 수신 (필터 전 상태의 증거) |

## 7. 복구

1. (7-01) 재분배가 꼬이면 해당 줄만 지운다.

```
router eigrp 20
 no redistribute ospf 1 metric 100000 100 255 1 1500
router ospf 1
 no redistribute eigrp 20 subnets
```

2. (7-02) 다음 실습(LEC-SN-07-008-MP)으로 넘어가기 전에 `copy running-config startup-config`로 장비를 저장한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 5~6번을 AMM 형식 MP로 분리. 거르지 않은 재분배를 의도한 시험으로 밝히는 CAUTION 추가. 번호(5~6)는 다른 문서의 참조 때문에 `commands.md`에 유지 |
