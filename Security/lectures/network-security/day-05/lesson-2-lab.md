# 2-1. 정적 경로를 RIP으로 바꾸는 실습

> 상위: [5일차 동적 라우팅 RIP](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-05-006-MP |
| 목적 | 주 회선의 정적 경로를 지우고 RIPv2를 켠 뒤, 예비 회선을 passive로 두고 창고 네트워크 전파와 장애 시험을 확인한다 |
| 적용 대상 | Cisco Packet Tracer의 `_실습/새봄상사.pkt`, 2911 라우터 HQ-R1과 BR-R1 (IOS 15 형식) |
| 소요 시간 | 약 40분 (대본 1~5번: 4분, 15분, 7분, 5분, 9분) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이번 재작성에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-2.md](lesson-2.md) | LEC-SN-05-002-DO | 정적에서 RIP으로 |
| [lesson-1.md](lesson-1.md) | LEC-SN-05-001-DO | 동적 라우팅과 RIP |
| [commands.md](commands.md) | LEC-SN-05-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-SN-05-007-MP | 다음 실습. 거짓 경로 시연, passive, 인증 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Packet Tracer 파일 | `_실습/새봄상사.pkt` (4일차 설정이 들어 있는 것) | |
| 2 | HQ-R1, BR-R1 | 2911, 주 회선 Gi0/1(192.168.99.0/30), 예비 회선 Se0/0/0(192.168.99.4/30) | |
| 3 | BR-PC1 | 지사 PC | 장애 시험에서 `ping -t`를 건다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 구역 E에서 주 회선을 끈다. 시험이 끝나면 반드시 `no shutdown`으로 되살린다. 되살리지 않으면 이후 실습의 경로표가 맞지 않는다.
{% endhint %}

{% hint style="info" %}
NOTE: 장비 화면은 IOS 15 형식이다. 패킷트레이서 버전에 따라 값과 줄 구성이 다를 수 있다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | `_실습/새봄상사.pkt`를 연다 | 4일차 토폴로지가 보인다 |
| 2 | HQ-R1에서 `show running-config \| include ip route`를 입력한다 | 지사로 가는 주 경로와 관리 거리 250의 예비 경로가 모두 보인다 |
| 3 | BR-R1에서 `show running-config \| include ip route`를 입력한다 | 주 기본 경로와 관리 거리 250의 예비 기본 경로가 모두 보인다 |

## 5. 절차

### A. 주 정적 경로 걷어 내기

1. (5-A-01) HQ-R1에서 지사로 가는 주 경로를 지운다: `no ip route 192.168.20.0 255.255.255.224 192.168.99.2`
2. (5-A-02) BR-R1에서 본사로 가는 주 기본 경로를 지운다: `no ip route 0.0.0.0 0.0.0.0 192.168.99.1`
3. (5-A-03) 두 라우터에서 `show ip route static`을 입력한다. → 결과: 예비 경로(관리 거리 250)만 남아 떠오른다.

### B. RIP 켜기

1. (5-B-01) HQ-R1에서 RIP 설정으로 들어간다: `router rip`
2. (5-B-02) 아래 네 줄을 차례로 입력한다.

```
 version 2
 no auto-summary
 network 192.168.10.0
 network 192.168.99.0
```

3. (5-B-03) BR-R1에서 `router rip`으로 들어가 아래 네 줄을 차례로 입력한다.

```
 version 2
 no auto-summary
 network 192.168.20.0
 network 192.168.99.0
```

4. (5-B-04) 약 60초 기다린다.
5. (5-B-05) 각 라우터에서 `end`, `show ip route rip`, `show ip protocols`를 차례로 입력한다. → 결과: HQ-R1의 `192.168.20.0/27` 줄이 Gi0/1과 Se0/0/0 두 갈래로 보인다. 두 줄 모두 `[120/1]`이다.

### C. 예비 회선 passive

1. (5-C-01) 두 라우터에서 `configure terminal`, `router rip`을 입력한다.
2. (5-C-02) 두 라우터에서 `passive-interface se0/0/0`, `end`를 입력한다.
3. (5-C-03) 두 라우터에서 `clear ip route *`를 입력한다.
4. (5-C-04) `show ip route rip`을 입력한다. → 결과: R 줄이 Gi0/1 하나로 줄어든다.

### D. 창고 네트워크

1. (5-D-01) BR-R1에서 `configure terminal`, `interface loopback 1`을 입력한다.
2. (5-D-02) `description BR warehouse (simulated)`를 입력한다.
3. (5-D-03) `ip address 192.168.20.33 255.255.255.224`, `end`를 입력한다.
4. (5-D-04) HQ-R1에서 아무것도 입력하지 않고 약 30초 기다린다.
5. (5-D-05) HQ-R1에서 `show ip route rip`을 입력한다. → 결과: `R 192.168.20.32/27`이 새로 보인다.

### E. 장애 시험과 예비 경로 /24

1. (5-E-01) BR-PC1에서 `ping -t 192.168.10.98`을 건다. → 결과: Reply가 계속 나온다.
2. (5-E-02) HQ-R1에서 `configure terminal`, `interface gi0/1`, `shutdown`, `end`를 입력한다.
3. (5-E-03) HQ-R1에서 `show ip route`를 입력한다. → 결과: 지사 경로가 예비 경로로 바뀐다. `[250/0] via 192.168.99.6`이 보인다.
4. (5-E-04) BR-PC1의 ping에서 빠진 응답 개수를 센다. → 결과: 몇 개가 빠진 뒤 다시 Reply가 나온다.
5. (5-E-05) HQ-R1에서 `ping 192.168.20.33`을 입력한다. → 결과: 통하지 않는다. 예비 경로가 192.168.20.0/27 하나만 가리키기 때문이다.
6. (5-E-06) 예비 경로를 /24로 바꾼다: `configure terminal`에서 `no ip route 192.168.20.0 255.255.255.224 192.168.99.6 250`, `ip route 192.168.20.0 255.255.255.0 192.168.99.6 250`, `end`를 차례로 입력한다.
7. (5-E-07) HQ-R1에서 `ping 192.168.20.33`을 입력한다. → 결과: Reply가 나온다.
8. (5-E-08) 주 회선을 되살린다: `configure terminal`, `interface gi0/1`, `no shutdown`, `end`. → 결과: 약 1분 뒤 `show ip route rip`에 `R` 줄이 다시 보인다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 두 라우터의 `show ip route rip` | 상대 쪽 네트워크가 `R` 줄로 보인다 | HQ-R1에 `192.168.20.0/27`, BR-R1에 `192.168.10.x` 줄이 있다 |
| 2 | 예비 회선이 RIP을 타지 않는지 확인 | R 줄이 Gi0/1 하나다 | Se0/0/0 줄이 없다 |
| 3 | HQ-R1의 `show ip route rip` | 창고 네트워크가 보인다 | `R 192.168.20.32/27`이 있다 |
| 4 | 장애 시험 중 HQ-R1에서 창고로 ping | Reply | 예비 경로 /24로 통한다 |

## 7. 복구

1. (7-01) 주 회선이 꺼져 있다면 HQ-R1에서 `interface gi0/1`, `no shutdown`을 입력한다.
2. (7-02) RIP이 꼬였다면 두 라우터에서 `no router rip`으로 지우고, `configs/`의 4일차 설정에서 정적 경로를 다시 넣는다.
3. (7-03) 파일을 저장하지 않았다면 `_실습/새봄상사.pkt`를 저장하지 않고 닫고 다시 연다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 1~5번과 `lesson-2.md`의 설정 안내를 AMM 형식 MP로 분리 |
