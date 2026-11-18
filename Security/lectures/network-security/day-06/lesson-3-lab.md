# 3-1. RIP 제거와 OSPF 구성 실습

> 상위: [6일차 OSPF와 Git 브랜치](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-06-007-MP |
| 목적 | 패킷트레이서의 본사·지사 라우터에서 RIP과 그 흔적을 지우고, 루프백과 라우터 ID를 정한 뒤 OSPF를 켜서 이웃·경로·비용을 확인하고 장애 시험을 한다 |
| 적용 대상 | Cisco Packet Tracer의 `_실습/새봄상사.pkt`(HQ-R1, BR-R1 2911 라우터, 5일차까지의 RIP 구성). ospf 브랜치에서 작업한다. 격리된 가상 실습망이며 실제 장비와 연결하지 않는다 |
| 소요 시간 | 약 50분 (RIP 걷어 내기 8분, 루프백 5분, OSPF 켜기 12분, 확인 15분, 장애 시험 10분) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이 환경에서 패킷트레이서를 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-3.md](lesson-3.md) | LEC-SN-06-003-DO | RIP에서 OSPF로 |
| [lesson-1.md](lesson-1.md) | LEC-SN-06-001-DO | OSPF: 소문 대신 지도 |
| [lesson-2-lab.md](lesson-2-lab.md) | LEC-SN-06-006-MP | 이전 실습. ospf 브랜치 만들기 |
| [lesson-4-lab.md](lesson-4-lab.md) | LEC-SN-06-008-MP | 다음 실습. passive와 인증 |
| [commands.md](commands.md) | LEC-SN-06-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Cisco Packet Tracer | `_실습/새봄상사.pkt` | 5일차까지의 RIP 구성이 들어 있다 |
| 2 | 라우터 | HQ-R1, BR-R1 (2911) | Gi0/1 주 회선, Se0/0/0 예비 회선 |
| 3 | 지사 PC | BR-PC1 | 장애 시험의 `ping -t`에 쓴다 |
| 4 | 본사 서버 | 192.168.10.98 | ping 대상 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 이 실습은 ospf 브랜치에서 한다. 시작 전에 `git branch`로 `* ospf`인지 확인한다. 구역 B 뒤에는 지사와 본사가 서로를 모르는 상태가 되므로 ping이 끊기는 것이 정상이다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 구역 E의 장애 시험 뒤에는 반드시 `no shutdown`으로 주 회선을 살린다.
{% endhint %}

{% hint style="info" %}
NOTE: 출력 예시는 IOS 15 형식이다. 패킷트레이서 버전에 따라 줄 구성이 조금 다를 수 있다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 브랜치가 ospf다 | `git branch`에 `* ospf` |
| 2 | `_실습/새봄상사.pkt`를 연다 | 본사·지사 장비가 보인다 |
| 3 | 5일차 구성이 살아 있다 | HQ-R1에서 `show ip route`에 `R` 줄이 있다 |
| 4 | 두 라우터를 저장했다 | `copy running-config startup-config`가 끝난다 |

## 5. 절차

### A. RIP과 그 흔적 걷어 내기

1. (5-A-01) HQ-R1에서 RIP, 예비 정적 경로, 포트의 RIP 인증 줄, key chain을 지운다.

```
configure terminal
no router rip
no ip route 192.168.20.0 255.255.255.0 192.168.99.6 250
interface gi0/1
 no ip rip authentication mode md5
 no ip rip authentication key-chain RIPKEY
interface gi0/0.10
 no ip rip authentication mode md5
 no ip rip authentication key-chain RIPKEY
interface gi0/0.20
 no ip rip authentication mode md5
 no ip rip authentication key-chain RIPKEY
interface gi0/0.30
 no ip rip authentication mode md5
 no ip rip authentication key-chain RIPKEY
interface gi0/0.40
 no ip rip authentication mode md5
 no ip rip authentication key-chain RIPKEY
interface gi0/0.99
 no ip rip authentication mode md5
 no ip rip authentication key-chain RIPKEY
 exit
no key chain RIPKEY
```

→ 결과: 오류 없이 끝난다.

2. (5-A-02) BR-R1에서 같은 일을 한다.

```
configure terminal
no router rip
no ip route 0.0.0.0 0.0.0.0 192.168.99.5 250
interface gi0/1
 no ip rip authentication mode md5
 no ip rip authentication key-chain RIPKEY
interface gi0/0
 no ip rip authentication mode md5
 no ip rip authentication key-chain RIPKEY
 exit
no key chain RIPKEY
```

→ 결과: 오류 없이 끝난다.

3. (5-A-03) 두 라우터에서 `do show ip route`를 입력한다. → 결과: C와 L 줄만 남는다. 지사와 본사가 서로를 모르는 상태다.

### B. 루프백과 라우터 ID

1. (5-B-01) HQ-R1에서 루프백 0과 라우터 ID를 정한다.

```
interface loopback 0
 description Router ID
 ip address 192.168.255.1 255.255.255.255
router ospf 1
 router-id 192.168.255.1
```

→ 결과: 프롬프트가 `HQ-R1(config-router)#`다.

2. (5-B-02) BR-R1에서 같은 줄을 192.168.255.2로 입력한다. → 결과: 프롬프트가 `BR-R1(config-router)#`다.

### C. OSPF 켜기

1. (5-C-01) HQ-R1의 `router ospf 1` 안에서 `network`를 입력한다.

```
 network 192.168.10.0 0.0.0.255 area 0
 network 192.168.99.0 0.0.0.7 area 0
 network 192.168.255.1 0.0.0.0 area 0
 end
```

2. (5-C-02) BR-R1의 `router ospf 1` 안에서 `network`를 입력한다.

```
 network 192.168.20.0 0.0.0.255 area 0
 network 192.168.99.0 0.0.0.7 area 0
 network 192.168.255.2 0.0.0.0 area 0
 end
```

→ 결과: `%OSPF-5-ADJCHG: ... from LOADING to FULL, Loading Done` 알림이 뜬다. 이웃이 맺어진 것이다.

### D. 확인과 창고 루프백

1. (5-D-01) HQ-R1에서 아래 명령을 입력한다.

```
show ip ospf neighbor
show ip route ospf
show ip ospf interface gi0/1
show ip ospf interface se0/0/0
```

| 볼 것 | 기대하는 결과 |
|---|---|
| 이웃 | 192.168.255.2가 Gi0/1(FULL/DR 또는 BDR)과 Se0/0/0(FULL/ -)에 |
| 지사 경로 | `O 192.168.20.0/27 [110/2] via 192.168.99.2` 한 줄 |
| 포트 비용 | Gi0/1은 Cost 1, Se0/0/0은 Cost 64 |

2. (5-D-02) 창고 네트워크가 `192.168.20.33/32`로 보이면 BR-R1에서 고친다.

```
configure terminal
interface loopback 1
 ip ospf network point-to-point
 end
```

→ 결과: 잠시 뒤 본사 경로표에 `O 192.168.20.32/27`이 보인다.

### E. 장애 시험

1. (5-E-01) BR-PC1에서 `ping -t 192.168.10.98`을 건다. → 결과: Reply가 이어진다.
2. (5-E-02) HQ-R1에서 주 회선을 끈다.

```
configure terminal
interface gi0/1
 shutdown
 end
show ip route ospf
```

→ 결과: `[110/65] via 192.168.99.6, Serial0/0/0` 줄이 보인다.

3. (5-E-03) 빠진 ping 개수를 센다. 4일차, 5일차 기록과 비교한다.
4. (5-E-04) 주 회선을 되살린다.

```
configure terminal
interface gi0/1
 no shutdown
 end
```

→ 결과: 경로가 다시 `[110/2] via 192.168.99.2, Gi0/1`로 돌아온다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | HQ-R1에서 `show ip ospf neighbor` | 192.168.255.2 두 줄 | 모두 FULL |
| 2 | HQ-R1에서 `show ip route ospf` | `O 192.168.20.0/27 [110/2]` via Gi0/1 | 해당 줄 존재 |
| 3 | `show ip ospf interface` | Gi0/1 Cost 1, Se0/0/0 Cost 64 | 비용 일치 |
| 4 | 주 회선 shutdown 중 `show ip route ospf` | `[110/65]` via Se0/0/0 | 예비 회선으로 전환 |
| 5 | 본사 경로표의 창고 | `O 192.168.20.32/27` | /27로 보인다 |
| 6 | BR-PC1에서 `ping 192.168.10.98` | Reply | 응답 수신 |

## 7. 복구

1. (7-01) 주 회선이 꺼진 채라면 HQ-R1의 Gi0/1에서 `no shutdown`을 입력한다.
2. (7-02) OSPF가 꼬였으면 `no router ospf 1`로 지우고 main 브랜치의 `configs/` 설정을 붙여 넣는다.
3. (7-03) 실험이 실패했으면 패킷트레이서를 저장하지 않고 닫고 `git switch main`으로 RIP 판으로 돌아간다.
4. (7-04) 다음 실습(LEC-SN-06-008-MP)으로 넘어가기 전에 `copy running-config startup-config`로 두 라우터를 저장한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 2~6번을 AMM 형식 MP로 분리 |
