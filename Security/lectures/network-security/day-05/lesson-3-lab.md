# 3-1. 거짓 경로 시연과 RIP 보호 실습

> 상위: [5일차 동적 라우팅 RIP](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-05-007-MP |
| 목적 | 강사의 패킷트레이서에서 거짓 경로 광고가 서버 통신을 가로채는 것을 확인하고, 사무실 쪽 포트를 passive로 두고 RIP 인증을 걸어 거짓 경로를 막는다 |
| 적용 대상 | 허가받은 격리 실습 환경. Cisco Packet Tracer의 `_실습/새봄상사.pkt` 안의 가상 장비만 대상이다. 구역 A는 강사 시연이고, 구역 B~C는 학생과 함께 한다 |
| 소요 시간 | 약 45분 (대본 6~8번: 15분, 10분, 15분. 나머지는 확인) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이번 재작성에서 다시 실행하지 않았다. 패킷트레이서가 RIP 인증과 passive 뒤의 수신 동작을 어떻게 처리하는지 수업 전에 확인해야 한다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-3.md](lesson-3.md) | LEC-SN-05-003-DO | RIP을 지키기 |
| [lesson-2-lab.md](lesson-2-lab.md) | LEC-SN-05-006-MP | 선행 실습. 정적 경로를 RIP으로 바꾸기 |
| [commands.md](commands.md) | LEC-SN-05-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |
| [lesson-4-lab.md](lesson-4-lab.md) | LEC-SN-05-008-MP | 다음 실습. 내 회사에 적용 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Packet Tracer 파일 | `_실습/새봄상사.pkt` (2-1 실습을 마친 상태) | |
| 2 | HQ-R1, BR-R1, HQ-SW1 | 2911 라우터 두 대, 2960 스위치 | |
| 3 | FAKE-R | 2911 라우터 한 대 (구역 A에서만 놓는다, 강사 화면에서만) | 시연용 가상 장비 |
| 4 | Dev-PC1 | 서버 쪽 통신을 확인하는 PC | `tracert`를 입력한다 |
| 5 | 실습용 키 | 수업에서 정한 값 하나 (`<password>`로 표기) | |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 허가받지 않은 시스템에 이 절차를 수행하는 것은 불법이다. 격리된 실습망에서만 수행한다. 구역 A의 거짓 경로 광고는 강사의 패킷트레이서 안(시뮬레이터의 가상 장비)에서만 하고, 실제 장비나 실제 회사 망에서 하지 않는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 인증을 걸면 지사 경로가 잠시 사라진다. 양쪽 라우터에 모두 걸 때까지 기다린다. 끝내 돌아오지 않으면 7절 복구를 따른다.
{% endhint %}

{% hint style="info" %}
NOTE: 학생은 공격 장비를 직접 만들지 않는다. 구역 A는 강사 시연이고, 학생은 구역 B와 C에서 막는 설정을 한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 2-1 실습(LEC-SN-05-006-MP)이 끝나 있다 | 두 라우터의 `show ip route rip`에 상대 쪽 경로가 R 줄로 있다 |
| 2 | 예비 회선이 passive다 | `show ip route rip`의 R 줄이 Gi0/1 하나다 |
| 3 | 패킷트레이서가 `key chain`과 `ip rip authentication mode md5`를 받아들이는지 확인한다 | 명령이 거절되지 않는다. 거절되면 강사에게 알리고 구역 C는 설정 줄만 기록한다 |

## 5. 절차

### A. 거짓 경로 시연 (강사만)

1. (5-A-01) 강사 화면에서 2911 라우터를 하나 놓고 이름을 FAKE-R로 바꾼다. → 결과: 라우터가 토폴로지에 놓인다.
2. (5-A-02) FAKE-R의 Gi0/0을 HQ-SW1의 Fa0/3(영업팀 VLAN 10)에 잇는다.
3. (5-A-03) FAKE-R에서 아래 줄을 차례로 입력한다.

```
enable
configure terminal
hostname FAKE-R
interface gi0/0
 ip address 192.168.10.20 255.255.255.224
 no shutdown
interface loopback 0
 ip address 192.168.10.97 255.255.255.240
router rip
 version 2
 no auto-summary
 network 192.168.10.0
 end
```

4. (5-A-04) 약 60초 기다린 뒤 HQ-R1에서 `show ip route rip`을 입력한다. → 결과: 아래 줄이 보인다.

```
HQ-R1#show ip route rip
R       192.168.10.96/28 [120/1] via 192.168.10.20, 00:00:08, GigabitEthernet0/0.10
```

5. (5-A-05) Dev-PC1에서 `tracert 192.168.10.98`을 입력한다. → 결과: 두 번째 칸이 192.168.10.20(가짜 장비)이고 그 뒤로 끊긴다. 서버로 가던 통신이 가짜 장비로 빨려 들어간 것이다.
6. (5-A-06) FAKE-R은 구역 C가 끝날 때까지 그대로 둔다.

### B. 사무실 쪽 passive

1. (5-B-01) HQ-R1에서 `configure terminal`, `router rip`을 입력한다.
2. (5-B-02) 아래 다섯 줄을 차례로 입력한다.

```
 passive-interface gi0/0.10
 passive-interface gi0/0.20
 passive-interface gi0/0.30
 passive-interface gi0/0.40
 passive-interface gi0/0.99
```

3. (5-B-03) `end`, `clear ip route *`를 입력한다.
4. (5-B-04) 약 60초 뒤 `show ip route rip`을 입력한다. → 결과: `192.168.10.96/28 via 192.168.10.20`이 다시 생겨 있다. passive는 듣기를 막지 않기 때문이다.
5. (5-B-05) BR-R1에서 `configure terminal`, `router rip`을 입력한다.
6. (5-B-06) `passive-interface gi0/0`, `passive-interface loopback 1`, `end`를 차례로 입력한다. → 결과: 지사 사무실 쪽 포트로 알림이 나가지 않는다.

### C. RIP 인증

1. (5-C-01) 두 라우터에서 열쇠고리를 만든다. `<password>`는 수업에서 정한 값 하나로 바꾼다.

```
configure terminal
key chain RIPKEY
 key 1
  key-string <password>
  exit
 exit
```

2. (5-C-02) HQ-R1에서 주 회선 gi0/1에 인증을 건다.

```
interface gi0/1
 ip rip authentication mode md5
 ip rip authentication key-chain RIPKEY
```

3. (5-C-03) HQ-R1의 서브인터페이스 gi0/0.10, gi0/0.20, gi0/0.30, gi0/0.40, gi0/0.99에도 같은 두 줄을 건다. 인터페이스마다 아래 형식으로 입력한다. 마지막에 `end`를 입력한다.

```
interface gi0/0.10
 ip rip authentication mode md5
 ip rip authentication key-chain RIPKEY
```

4. (5-C-04) BR-R1에서 gi0/1과 gi0/0에 같은 두 줄을 건다. 마지막에 `end`를 입력한다.

```
interface gi0/1
 ip rip authentication mode md5
 ip rip authentication key-chain RIPKEY
interface gi0/0
 ip rip authentication mode md5
 ip rip authentication key-chain RIPKEY
 end
```

5. (5-C-05) 두 라우터에서 `clear ip route *`를 입력하고 약 60초 기다린다.
6. (5-C-06) HQ-R1에서 `show ip route rip`을 입력한다. → 결과: `192.168.10.96/28`이 사라지고, 지사 경로(192.168.20.0/27, 192.168.20.32/27)는 그대로 있다.
7. (5-C-07) Dev-PC1에서 `tracert 192.168.10.98`을 입력한다. → 결과: 다시 서버에 닿는다.
8. (5-C-08) 강사가 FAKE-R을 토폴로지에서 지운다. → 결과: 영업팀 자리의 가짜 장비가 없어진다.
9. (5-C-09) 세 장비(HQ-R1, BR-R1, HQ-SW1)에서 `write memory`를 입력해 저장한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | HQ-R1 `show ip route rip` (인증 뒤) | 지사 경로가 있고 가짜 경로가 없다 | `192.168.10.96/28`이 없다 |
| 2 | Dev-PC1 `tracert 192.168.10.98` | 서버에 닿는다 | 가짜 장비(192.168.10.20)를 지나지 않는다 |
| 3 | 두 라우터 `show running-config` | RIP이 켜진 포트에 인증 줄이 있다 | gi0/1, 서브인터페이스, BR-R1 gi0/0 모두 |
| 4 | HQ-R1 `show ip protocols` | passive로 둔 포트가 나열된다 | 사무실 쪽 포트가 모두 보인다 |

## 7. 탐지·방어

확인 상태: 미검증 (일반 지식으로 짧게 정리했다).

| 항목 | 내용 |
|---|---|
| 원인 | RIP이 켜진 포트로 들어온 알림을 인증 없이 받아들이고, 가장 구체적인 줄(/28)이 /27보다 우선하는 규칙이 있다 |
| 완화 | 이웃이 없는 포트는 passive로 둔다. RIP이 켜진 포트에는 인증을 건다. 가능하면 사무실 쪽 포트에서 RIP 자체를 켜지 않는다. 스위치 포트 보안으로 모르는 장비가 꽂히는 것을 막는다 |
| 로그에서 보이는 흔적 | 경로표에 처음 보는 이웃(예: 사무실 대역의 주소)을 `via`로 하는 R 줄이 생긴다. 설계에 없는 프리픽스가 보인다. `show ip route rip`을 정기적으로 설정 텍스트와 비교하면 알아챈다 |

## 8. 복구

1. (8-01) 인증을 걸고 지사 경로가 돌아오지 않으면 두 라우터의 인증 포트에서 `no ip rip authentication mode md5`를 입력해 인증을 푼다.
2. (8-02) 양쪽 key-string이 글자 하나까지 같은지 `show running-config`로 비교한 뒤 다시 건다.
3. (8-03) RIP이 꼬이면 두 라우터에서 `no router rip`으로 지우고 `configs/`의 4일차 설정에서 정적 경로를 다시 넣는다.
4. (8-04) 시연이 끝난 FAKE-R이 토폴로지에 남아 있으면 지운다.

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 6~8번과 `lesson-3.md`의 설정 안내를 AMM 형식 MP로 분리. 격리 환경 WARNING과 탐지·방어 절 추가. 키 값을 `<password>`로 교체 |
