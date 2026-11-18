# 2-1. SALES-IN과 access-class 실습

> 상위: [10일차 ACL과 첫 침해사고](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-10-007-MP |
| 목적 | 영업팀 ACL(SALES-IN)을 HQ-DSW1과 HQ-R1 두 곳에 걸고 장애 시험으로 확인한 뒤, 모든 장비의 VTY에 `access-class`를 걸어 관리자 PC만 접속시킨다 |
| 적용 대상 | 허가받은 격리 실습 환경. Cisco Packet Tracer의 `_실습/새봄상사.pkt`, HQ-R1(2911), HQ-DSW1(3560), HQ-SW1, HQ-SW2, BR-R1, BR-SW1 (IOS 15 형식) |
| 소요 시간 | 약 32분 (대본 2번 8분, 3번 6분, 4번 8분, 5번 10분) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이번 재작성에서 다시 실행하지 않았다. 3560의 SVI에 `ip access-group`이 걸리는지 수업 전에 확인해야 한다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-2.md](lesson-2.md) | LEC-SN-10-002-DO | 정책표에서 ACL로 |
| [lesson-1.md](lesson-1.md) | LEC-SN-10-001-DO | ACL의 원리 |
| [lesson-1-lab.md](lesson-1-lab.md) | LEC-SN-10-006-MP | 선행 실습. NAT-INSIDE 줄 끼워 넣기 |
| [commands.md](commands.md) | LEC-SN-10-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-SN-10-008-MP | 다음 실습. 사고 01 탐지와 대응 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Packet Tracer 파일 | `_실습/새봄상사.pkt` (9일차 설정과 1-1 실습을 마친 상태) | |
| 2 | HQ-DSW1, HQ-R1 | 영업팀(VLAN 10) 게이트웨이. HQ-DSW1은 `interface vlan 10`, HQ-R1은 `interface gi0/0.10` | |
| 3 | Sales-PC1, HR-PC1, Admin-PC, NET-PC | 영업팀 PC, 인사팀 PC(8일차 DHCP로 192.168.10.42), 관리자 PC(192.168.10.150), 인터넷 쪽 PC | HR-PC1의 `ipconfig`로 주소를 먼저 확인한다 |
| 4 | 장비 여섯 대 | HQ-R1, BR-R1, HQ-DSW1, HQ-SW1, HQ-SW2, BR-SW1 | 구역 D에서 VTY에 건다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 구역 D의 `access-class`는 콘솔(CLI 탭)에서만 건다. 원격 접속으로 걸면 관리자 PC 주소가 틀렸을 때 내 접속이 끊겨 장비에 들어갈 수 없다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 구역 C에서 HQ-DSW1의 Gi0/1을 끈다. 시험이 끝나면 반드시 `no shutdown`으로 되살린다.
{% endhint %}

{% hint style="info" %}
NOTE: 장비 화면은 IOS 15 형식이다. 패킷트레이서 버전에 따라 값과 줄 구성이 다를 수 있다. `ip access-group`이 3560 SVI에서 거절되면 HQ-R1에만 걸고 장애 뒤의 동작만 본다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | HR-PC1에서 `ipconfig`를 입력한다 | 주소가 192.168.10.42이다 |
| 2 | 1-1 실습(LEC-SN-10-006-MP)이 끝나 있다 | HQ-R1의 `show access-lists NAT-INSIDE`에 5번 줄이 있다 |

## 5. 절차

### A. SALES-IN 만들기

1. (5-A-01) HQ-DSW1에서 `configure terminal`, `ip access-list extended SALES-IN`을 입력한다.
2. (5-A-02) 아래 다섯 줄을 차례로 입력하고 `end`를 입력한다.

```
 10 permit ip 192.168.10.0 0.0.0.31 192.168.10.96 0.0.0.31
 20 deny ip 192.168.10.0 0.0.0.31 192.168.10.32 0.0.0.31 log
 30 deny ip 192.168.10.0 0.0.0.31 192.168.10.64 0.0.0.31 log
 40 deny ip 192.168.10.0 0.0.0.31 192.168.10.128 0.0.0.31 log
 50 permit ip any any
```

3. (5-A-03) HQ-R1에서 같은 `configure terminal`, `ip access-list extended SALES-IN`과 다섯 줄을 입력한다. → 결과: 두 장비의 `show access-lists SALES-IN`이 같은 다섯 줄을 보인다.

### B. 두 곳에 걸기

1. (5-B-01) HQ-DSW1에서 `configure terminal`, `interface vlan 10`을 입력한다.
2. (5-B-02) `ip access-group SALES-IN in`, `end`를 입력한다.
3. (5-B-03) HQ-R1에서 `configure terminal`, `interface gi0/0.10`을 입력한다.
4. (5-B-04) `ip access-group SALES-IN in`, `end`를 입력한다. → 결과: 두 장비의 `show ip interface`에 `Inbound access list is SALES-IN`이 보인다.

### C. 확인과 장애 시험

1. (5-C-01) Sales-PC1에서 `ping 192.168.10.98`(서버)을 입력한다. → 결과: Reply.
2. (5-C-02) Sales-PC1에서 `ping 192.168.10.42`(인사팀)를 입력한다. → 결과: 닿을 수 없음(`Destination ... unreachable` 또는 `Request timed out`).
3. (5-C-03) Sales-PC1에서 `ping 198.51.100.10`(인터넷)을 입력한다. → 결과: Reply.
4. (5-C-04) HQ-DSW1에서 `show access-lists SALES-IN`을 입력하고 20번 줄의 적중 횟수를 적어 둔다.
5. (5-C-05) HQ-DSW1에서 `configure terminal`, `interface gi0/1`, `shutdown`을 입력한다. → 결과: HQ-R1이 Active가 된다.
6. (5-C-06) Sales-PC1에서 `ping 192.168.10.42`를 다시 입력한다. → 결과: 여전히 닿을 수 없다.
7. (5-C-07) HQ-R1에서 `show access-lists SALES-IN`을 입력한다. → 결과: 20번 줄의 적중 횟수가 늘어 있다.
8. (5-C-08) HQ-DSW1에서 `interface gi0/1`, `no shutdown`, `end`를 입력해 되살린다.

### D. access-class

여섯 장비(HQ-R1, BR-R1, HQ-DSW1, HQ-SW1, HQ-SW2, BR-SW1)에 같은 일을 콘솔(CLI 탭)에서 한다. 라우터는 `line vty 0 4`, 스위치는 `line vty 0 15`다.

1. (5-D-01) 장비 하나의 CLI 탭에서 `configure terminal`을 입력한다.
2. (5-D-02) 아래 네 줄을 차례로 입력한다.

```
ip access-list standard MGMT-ONLY
 permit host 192.168.10.150
 exit
line vty 0 4
 access-class MGMT-ONLY in
 end
```

3. (5-D-03) 나머지 다섯 장비에서 같은 일을 반복한다. 스위치는 `line vty 0 15`를 쓴다.
4. (5-D-04) Admin-PC에서 `telnet 192.168.10.130`을 입력한다. → 결과: 비밀번호 창이 뜬다.
5. (5-D-05) Sales-PC1에서 `telnet 192.168.10.29`를 입력한다. → 결과: 연결 거부.
6. (5-D-06) NET-PC에서 `telnet 203.0.113.2`를 입력한다. → 결과: 연결 거부.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | Sales-PC1에서 서버, 인터넷으로 ping | Reply | 두 곳 모두 Reply |
| 2 | Sales-PC1에서 HR-PC1로 ping | 닿을 수 없음 | Reply가 없다 |
| 3 | 장애 전후의 `show access-lists SALES-IN` | 20번 줄 횟수가 늘어난다 | 장애 전에는 HQ-DSW1, 뒤에는 HQ-R1의 횟수가 늘었다 |
| 4 | Admin-PC, Sales-PC1, NET-PC의 `telnet` | Admin-PC만 비밀번호 창 | Sales-PC1과 NET-PC는 연결 거부 |

## 7. 탐지·방어

확인 상태: 미검증 (일반 지식으로 짧게 정리했다).

| 항목 | 내용 |
|---|---|
| 원인 | 부서 사이와 VTY에 패킷 필터가 없으면 침해된 PC 하나가 다른 부서와 장비로 번진다 |
| 완화 | SALES-IN을 게이트웨이 두 장비에 같이 건다. VTY에 `access-class`를 건다. 12일차에 텔넷을 SSH로 바꾼다 |
| 로그에서 보이는 흔적 | `show access-lists`의 20, 30, 40번 줄 적중 횟수 증가. `log` 줄의 `%SEC-6-IPACCESSLOGP` 계열 기록 |

## 8. 복구

1. (8-01) HQ-DSW1에서 `interface vlan 10`, `no ip access-group SALES-IN in`을 입력한다. HQ-R1에서 `interface gi0/0.10`, `no ip access-group SALES-IN in`을 입력한다. → 결과: 영업팀이 업무 통신을 다시 쓴다.
2. (8-02) 관리자 PC까지 막혔다면 콘솔에서 `line vty 0 4`(스위치는 `0 15`), `no access-class MGMT-ONLY in`을 입력한다.
3. (8-03) HQ-DSW1의 Gi0/1이 꺼져 있다면 `interface gi0/1`, `no shutdown`을 입력한다.

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 2~5번과 `lesson-2.md`의 설정 안내를 AMM 형식 MP로 분리. 격리 환경 적용 대상과 탐지·방어 절 추가 |
