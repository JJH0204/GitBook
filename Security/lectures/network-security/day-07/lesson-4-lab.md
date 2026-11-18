# 4-1. 경계 필터와 EIGRP 인증 실습

> 상위: [7일차 EIGRP와 재분배](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-07-008-MP |
| 목적 | HQ-R1의 신뢰 경계(Gi0/2)에서 받을 경로와 알릴 경로를 prefix-list, distribute-list, route-map으로 고르고, 이웃 사이에 EIGRP 인증을 건다 |
| 적용 대상 | Cisco Packet Tracer의 `_실습/새봄상사.pkt` (HQ-R1, BR-R1, LC-R1, LC-PC1). 3-1 실습을 마친 상태. 격리된 가상 실습망이며 실제 장비와 연결하지 않는다 |
| 소요 시간 | 약 30분 (받을 것 13, 알릴 것 10, 인증 7) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이 환경에서 패킷트레이서를 실행하지 않았다. 패킷트레이서의 prefix-list, route-map, EIGRP 인증 지원 여부는 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-4.md](lesson-4.md) | LEC-SN-07-004-DO | 경계에서 걸러 내기 |
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-SN-07-007-MP | 선행 실습. 양방향 재분배 |
| [commands.md](commands.md) | LEC-SN-07-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |
| [lesson-4-personal-lab.md](lesson-4-personal-lab.md) | LEC-SN-07-009-MP | 다음 실습. 내 회사 인수회사 연결과 커밋 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 라우터 | 2911 (HQ-R1, BR-R1, LC-R1) | 3-1 실습에서 재분배를 마친 장비 |
| 2 | PC | LC-PC1 | 서버와 인사팀 PC로 ping을 보낸다 |
| 3 | 본사 PC | 인사팀 PC (192.168.10.34), 서버 (192.168.10.98) | |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 필터를 잘못 걸어 경로가 모두 사라지면 `no distribute-list`와 `redistribute`의 `route-map`을 빼고 다시 건다. 이 필터는 경로만 거르며 패킷은 막지 못한다. 패킷 필터는 10일차 ACL에서 건다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 구역 C에서 인증을 한쪽에만 걸면 이웃이 끊긴다. 양쪽에 같은 키를 건 뒤에 이웃이 다시 맺어지는지 확인한다.
{% endhint %}

{% hint style="info" %}
NOTE: 7번 절차의 /28 시연은 강사의 한결물류 라우터에서만 한다. 학생은 필터가 걸린 상태를 확인한다. 이 시연은 격리된 가상 실습망 안에서만 한다.
{% endhint %}

{% hint style="info" %}
NOTE: EIGRP 키 `<key>`와 장비 비밀번호는 실습용 값을 직접 정해 넣는다. 문서와 저장소에 실제 값을 적지 않는다.
{% endhint %}

{% hint style="info" %}
NOTE: 패킷트레이서가 `ip prefix-list`나 `distribute-list prefix`를 받지 않으면 구역 B와 C의 대체 명령(표준 ACL)을 쓴다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 3-1 실습을 마쳤다 | LC-R1의 `show ip route eigrp`에 D EX 줄이 여러 개 있다 |
| 2 | 장비 설정을 저장했다 | `copy running-config startup-config`가 오류 없이 끝난다 |

## 5. 절차

### A. 받을 것 고르기

1. (5-A-01) 강사만 한결물류 라우터에 서버 대역의 /28을 알린다.

```
LC-R1(config)#interface loopback 5
LC-R1(config-if)#ip address 192.168.10.97 255.255.255.240
LC-R1(config-if)#router eigrp 20
LC-R1(config-router)#network 192.168.10.96 0.0.0.15
```

→ 결과: HQ-R1의 `show ip route eigrp`에 `D 192.168.10.96/28 via 192.168.99.10`이 생긴다.

2. (5-A-02) HQ-R1에 받을 것 목록을 건다. 학생도 여기부터 함께 입력한다.

```
configure terminal
ip prefix-list LC-IN seq 10 permit 172.16.10.0/24
router eigrp 20
 distribute-list prefix LC-IN in gi0/2
 end
clear ip route *
show ip route eigrp
```

→ 결과: `D 172.16.10.0/24`만 남고 /28이 사라진다.

3. (5-A-03) 강사는 시연이 끝나면 LC-R1의 loopback 5와 그 network 줄을 지운다.

### B. 알릴 것 고르기

1. (5-B-01) HQ-R1에서 알릴 것 목록과 route-map을 만들고 재분배에 붙인다.

```
configure terminal
ip prefix-list TO-LC seq 10 permit 192.168.10.96/27
route-map TO-LC permit 10
 match ip address prefix-list TO-LC
 exit
router eigrp 20
 redistribute ospf 1 metric 100000 100 255 1 1500 route-map TO-LC
 end
```

2. (5-B-02) LC-R1에서 `show ip route eigrp`를 입력한다. → 결과: `D EX 192.168.10.96/27` 한 줄만 남는다. 몇 초 걸리면 LC-R1에서 `clear ip route *`를 입력한다.
3. (5-B-03) LC-PC1에서 서버로 ping을 입력한다: `ping 192.168.10.98` → 결과: Reply가 온다.
4. (5-B-04) LC-PC1에서 인사팀 PC로 ping을 입력한다: `ping 192.168.10.34` → 결과: `Destination host unreachable`이 나온다.

패킷트레이서가 prefix-list를 받지 않으면 표준 ACL로 대신한다.

```
access-list 10 permit 172.16.10.0 0.0.0.255
router eigrp 20
 distribute-list 10 in gi0/2
```

route-map에서는 `match ip address 10`을 쓴다.

### C. EIGRP 인증

1. (5-C-01) HQ-R1과 LC-R1 모두에 같은 열쇠고리를 만든다. HQ-R1은 Gi0/2에, LC-R1은 Gi0/1에 건다. 먼저 HQ-R1이다.

```
configure terminal
key chain EIGRPKEY
 key 1
  key-string <key>
  exit
 exit
interface gi0/2
 ip authentication mode eigrp 20 md5
 ip authentication key-chain eigrp 20 EIGRPKEY
 end
```

→ 결과: 한쪽만 건 상태라 이웃이 끊긴다는 알림이 뜬다.

2. (5-C-02) LC-R1에서 같은 열쇠고리를 만들고 `interface gi0/1`로 바꿔 같은 두 줄을 입력한다. → 결과: `Neighbor ... is up` 알림이 다시 뜬다.
3. (5-C-03) 네 장비를 모두 저장한다: `copy running-config startup-config`

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | HQ-R1에서 `show ip route eigrp` (필터 뒤) | `D 172.16.10.0/24`만 있다 | /28이 없다 |
| 2 | LC-R1에서 `show ip route eigrp` | `D EX 192.168.10.96/27` 한 줄 | 해당 줄만 존재 |
| 3 | LC-PC1에서 `ping 192.168.10.98` | Reply | 응답 수신 |
| 4 | LC-PC1에서 `ping 192.168.10.34` | `Destination host unreachable` | 응답 없음 |
| 5 | BR-R1에서 `show ip route ospf` | `O E2 172.16.10.0/24` | 해당 줄 존재 |
| 6 | HQ-R1에서 인증 뒤 `show ip eigrp neighbors` | 192.168.99.10 | 이웃이 그대로 있다 |

## 7. 복구

1. (7-01) 받을 것 필터를 지운다: `router eigrp 20` 안에서 `no distribute-list prefix LC-IN in gi0/2`
2. (7-02) 알릴 것 필터를 빼고 다시 건다: `router eigrp 20` 안에서 `redistribute ospf 1 metric 100000 100 255 1 1500`을 `route-map` 없이 다시 입력한다.
3. (7-03) 인증을 풀려면 양쪽 Gi0/2(HQ-R1), Gi0/1(LC-R1)에서 `no ip authentication mode eigrp 20 md5`와 `no ip authentication key-chain eigrp 20 EIGRPKEY`를 입력한다.
4. (7-04) 한결물류와의 연결을 끊어야 하면 HQ-R1의 Gi0/2에서 `shutdown`을 입력한다. 새봄상사 망은 영향을 받지 않는다.
5. (7-05) 실습을 처음 상태로 돌리려면 `_실습/새봄상사.pkt`를 저장하지 않고 닫고 다시 연다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 7~9번을 AMM 형식 MP로 분리. EIGRP 키 자리 `<key>`로 표기. 번호(7~9)는 다른 문서의 참조 때문에 `commands.md`에 유지 |
