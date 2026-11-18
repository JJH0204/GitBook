# 3-1. 사고 01 탐지, 증거, 대응 실습

> 상위: [10일차 ACL과 첫 침해사고](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-10-008-MP |
| 목적 | 감시용 ACL(LC-WATCH)로 한결물류에서 인사팀으로 가는 접근을 탐지하고, 증거를 파일로 저장한 뒤, 경계 ACL(LC-IN)로 막고 끊긴 EIGRP 이웃을 복구한다 |
| 적용 대상 | 허가받은 격리 실습 환경. Cisco Packet Tracer의 `_실습/새봄상사.pkt` 안의 가상 장비(HQ-R1, LC-R1, LC-PC1)만 대상이다. 학생은 한결물류 관리자와 새봄상사 담당자 역할을 번갈아 한다 |
| 소요 시간 | 약 32분 (대본 6번 7분, 7번 8분, 8번 5분, 9번 7분, 10번 5분) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이번 재작성에서 다시 실행하지 않았다. 패킷트레이서가 ACL `log` 기록을 띄우는지 수업 전에 확인해야 한다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-3.md](lesson-3.md) | LEC-SN-10-003-DO | 사고 01: 인수한 회사의 우회 접근 |
| [lesson-1.md](lesson-1.md) | LEC-SN-10-001-DO | ACL의 원리 (줄 번호 끼워 넣기) |
| [lesson-2-lab.md](lesson-2-lab.md) | LEC-SN-10-007-MP | 선행 실습 |
| [commands.md](commands.md) | LEC-SN-10-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |
| [personal-lab.md](personal-lab.md) | LEC-SN-10-010-MP | 개인 실습. 사고 01 보고서 작성 |
| [침해사고 분석 보고서](../incident-report.md) | 양식 | 보고서 양식 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Packet Tracer 파일 | `_실습/새봄상사.pkt` (2-1 실습을 마친 상태) | |
| 2 | HQ-R1 | 한결물류와 맞닿은 포트 Gi0/2 | 새봄상사 담당자 역할 |
| 3 | LC-R1, LC-PC1 | 한결물류 라우터와 PC (172.16.10.10) | 한결물류 관리자, 직원 역할. 강사는 수업 전에 정적 경로를 미리 넣어 둔다 |
| 4 | 증거 폴더 | `05_진단과_대응/증거/` | VS Code에서 만든다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 허가받지 않은 시스템에 이 절차를 수행하는 것은 불법이다. 격리된 실습망에서만 수행한다. 구역 A의 정적 경로와 ping은 자기 실습 파일의 시뮬레이터 안(가상 장비)에서만 하고, 실제 회사 망이나 타인의 장비에서 하지 않는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 구역 D에서 LC-IN을 걸면 약 15초 뒤 EIGRP 이웃이 끊기고 한결물류와의 경로가 사라진다. 의도된 장애이며 구역 E의 5번 줄로 복구한다.
{% endhint %}

{% hint style="info" %}
NOTE: 장비 화면은 IOS 15 형식이다. 패킷트레이서가 `log` 기록을 띄우지 않으면 `show access-lists`의 적중 횟수만으로 탐지한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 2-1 실습(LEC-SN-10-007-MP)이 끝나 있다 | HQ-R1의 `show access-lists SALES-IN`이 나온다 |
| 2 | HQ-R1과 LC-R1이 EIGRP 이웃이다 | HQ-R1 `show ip eigrp neighbors`에 192.168.99.10이 보인다 |
| 3 | `05_진단과_대응/증거/` 폴더를 만든다 | VS Code 탐색기에 폴더가 보인다 |

## 5. 절차

### A. 한결물류 관리자 역할: 정적 경로

학생은 자기 파일에서 이 구역을 먼저 한다. 강사 파일에서는 강사가 수업 전에 해 두었다.

1. (5-A-01) LC-R1에서 `configure terminal`을 입력한다.
2. (5-A-02) `ip route 192.168.10.0 255.255.255.0 192.168.99.9`, `end`를 입력한다. → 결과: LC-R1이 본사 대역 전체를 HQ-R1로 보내는 경로를 가진다.
3. (5-A-03) 역할을 새봄상사 담당자로 바꾼다.

### B. 감시용 ACL

1. (5-B-01) HQ-R1에서 `configure terminal`, `ip access-list extended LC-WATCH`를 입력한다.
2. (5-B-02) 아래 세 줄을 차례로 입력하고 `exit`를 입력한다.

```
 10 permit eigrp host 192.168.99.10 any
 20 permit ip 172.16.10.0 0.0.0.255 192.168.10.96 0.0.0.31
 30 permit ip any any log
```

3. (5-B-03) `interface gi0/2`, `ip access-group LC-WATCH in`, `end`를 차례로 입력한다. → 결과: 아무것도 끊기지 않는다.

### C. 탐지와 증거 저장

1. (5-C-01) 한결물류 직원 역할로 LC-PC1에서 `ping 192.168.10.42`를 입력한다. → 결과: HQ-R1 화면에 `%SEC-6-IPACCESSLOGDP: list LC-WATCH permitted icmp 172.16.10.10 -> 192.168.10.42 ...` 줄이 뜬다. 로그가 뜨지 않는 버전이면 다음 단계의 적중 횟수로 판단한다.
2. (5-C-02) HQ-R1에서 `show access-lists LC-WATCH`를 입력한다. → 결과: 30번 줄의 적중 횟수가 0이 아니다. 0이 아니면 업무 밖의 통신이 있다는 뜻이다.
3. (5-C-03) `05_진단과_대응/증거/01_acl_log.txt`에 5-C-01의 로그 줄과 그때의 시각을 붙여 넣는다.
4. (5-C-04) `증거/01_acl_count.txt`에 `show access-lists LC-WATCH` 출력을 붙여 넣는다.
5. (5-C-05) LC-R1에서 `show ip route static`을 입력하고 `증거/01_lc-r1_route.txt`에 붙여 넣는다. → 결과: `S 192.168.10.0/24 ... via 192.168.99.9` 줄이 파일에 있다.

### D. LC-IN으로 바꾸기

1. (5-D-01) HQ-R1에서 `configure terminal`, `ip access-list extended LC-IN`을 입력한다.
2. (5-D-02) 아래 두 줄을 차례로 입력하고 `exit`를 입력한다.

```
 10 permit ip 172.16.10.0 0.0.0.255 192.168.10.96 0.0.0.31
 20 deny ip any any log
```

3. (5-D-03) `interface gi0/2`, `no ip access-group LC-WATCH in`, `ip access-group LC-IN in`, `end`를 차례로 입력한다.
4. (5-D-04) 약 15초 기다린다. → 결과: `%DUAL-5-NBRCHANGE: EIGRP-IPv4 20: Neighbor 192.168.99.10 (GigabitEthernet0/2) is down: holding time expired`가 뜬다. 20번 줄이 EIGRP 알림까지 버렸기 때문이다.
5. (5-D-05) 이 줄과 시각을 `증거/01_eigrp_down.txt`에 붙여 넣는다.

### E. EIGRP 복구와 확인

1. (5-E-01) HQ-R1에서 `configure terminal`, `ip access-list extended LC-IN`을 입력한다.
2. (5-E-02) `5 permit eigrp host 192.168.99.10 any`, `end`를 입력한다. → 결과: `Neighbor 192.168.99.10 ... is up`이 뜬다.
3. (5-E-03) LC-PC1에서 `ping 192.168.10.42`를 입력한다. → 결과: 닿을 수 없음.
4. (5-E-04) LC-PC1에서 `ping 192.168.10.98`을 입력한다. → 결과: Reply.
5. (5-E-05) HQ-R1에서 `show ip eigrp neighbors`를 입력한다. → 결과: 192.168.99.10이 보인다.
6. (5-E-06) HQ-R1에서 `show access-lists LC-IN`을 입력한다. → 결과: 20번 줄에 적중 횟수가 있다.
7. (5-E-07) 5-E-03~06의 출력을 `증거/01_after.txt`에 붙여 넣는다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | LC-PC1에서 인사팀 PC로 ping | 닿을 수 없음 | Reply가 없다. LC-IN 20번 줄 횟수가 늘었다 |
| 2 | LC-PC1에서 서버로 ping | Reply | 서버 VLAN은 업무라 허락된다 |
| 3 | HQ-R1 `show ip eigrp neighbors` | 192.168.99.10 | 이웃이 살아 있다 |
| 4 | `05_진단과_대응/증거/` | 증거 파일이 있다 | 01_acl_log, 01_acl_count, 01_lc-r1_route, 01_eigrp_down, 01_after 다섯 개 |

## 7. 탐지·방어

확인 상태: 미검증 (일반 지식으로 짧게 정리했다).

| 항목 | 내용 |
|---|---|
| 원인 | 신뢰 경계에서 경로 정보만 거르고 패킷은 거르지 않았다. 연결 규정이 없어 상대의 경로 변경을 알 수 없었다 |
| 완화 | 경계 포트에 "필요한 것만 여는" ACL을 건다. 적용 전에 감시용 ACL로 실제 흐름을 본다. 라우팅 프로토콜 알림은 ACL의 첫 줄에서 허락한다 |
| 로그에서 보이는 흔적 | `%SEC-6-IPACCESSLOGDP`의 출발지 172.16.10.10과 업무 밖 목적지. `show access-lists LC-WATCH` 30번 줄과 `LC-IN` 20번 줄의 적중 횟수. ACL 적용 직후의 `%DUAL-5-NBRCHANGE` |

## 8. 복구

1. (8-01) 업무가 멈추면 HQ-R1에서 `interface gi0/2`, `no ip access-group LC-IN in`, `ip access-group LC-WATCH in`을 입력해 감시용 ACL로 되돌리고 기록을 다시 본다.
2. (8-02) 완전히 되돌리려면 `no ip access-group LC-WATCH in`으로 포트에서 ACL을 뗀다. → 결과: 경계가 ACL 없이 원래대로 동작한다.
3. (8-03) 한결물류 관리자 역할로 LC-R1에서 `no ip route 192.168.10.0 255.255.255.0 192.168.99.9`를 입력해 실습용 정적 경로를 지운다.

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 6~10번과 `lesson-3.md`의 설정 안내를 AMM 형식 MP로 분리. 격리 환경 WARNING, 탐지·방어 절, 복구 절 추가 |
