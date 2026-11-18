# 4. 스위칭 실습 — VLAN · 트렁크 · Router-on-a-stick · EtherChannel

> 상위: [7일차 · 스위칭 심화](README.md)
> 실습 중에는 이 문서 대신 [7일차 실습 명령어 대본](commands.md)을 띄워 따라 친다. 이 문서는 왜 그렇게 하는지, 무엇을 봐야 하는지를 함께 적는다.

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N1-07-004-MP |
| 목적 | 스위치 두 대에 VLAN 10·20을 만들고, 트렁크, Router-on-a-stick, EtherChannel을 순서대로 구성해 단계마다 되는 것과 안 되는 것을 확인한다 |
| 적용 대상 | Cisco Packet Tracer, 라우터 1대(2911), 스위치 2대(2960), PC 4대. 새 파일에서 처음부터 시작한다 |
| 소요 시간 | 약 110분 (준비 15 + STEP 1 20 + STEP 2 15 + STEP 3 20 + STEP 4 30 + STEP 5 10) |
| 확인 상태 | 미검증 (원본 강의 노트를 옮긴 것이며 Packet Tracer에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

이론 세 편을 한 장의 그림에서 순서대로 쌓는다. "나누고 → 잇고 → 넘고 → 묶는다" 순서다. 오늘도 실패를 먼저 보고 해결한다(6일차 재분배 실습과 같은 리듬이다).

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1.md](lesson-1.md) | LEC-N1-07-001-DO | 1. VLAN — 스위치 한 대를 여러 대처럼 |
| [lesson-2.md](lesson-2.md) | LEC-N1-07-002-DO | 2. 트렁크와 VLAN 간 라우팅 |
| [lesson-3.md](lesson-3.md) | LEC-N1-07-003-DO | 3. 선 두 줄을 하나로 — STP 다시 보기와 EtherChannel |
| [lesson-4-troubleshooting.md](lesson-4-troubleshooting.md) | LEC-N1-07-005-TS | 스위칭 실습 문제 해결 |
| [commands.md](commands.md) | LEC-N1-07-007-REF | 0. 7일차 실습 명령어 |
| [4일차 commands.md](../day-04/commands.md) | LEC-N1-04-009-REF | 0. 4일차 실습 명령어 (CLI 입력 요령) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Packet Tracer | 이전 일차와 같은 버전 | 새 파일에서 시작한다 |
| 2 | 라우터 R1 | 2911 | 1대 |
| 3 | 스위치 SW1, SW2 | 2960 | 2대 |
| 4 | PC0~PC3 | PC | 4대 |
| 5 | 케이블 | Copper Straight-Through, Copper Cross-Over | 스위치끼리는 크로스오버 |

오늘의 토폴로지는 코리아IT 2층(SW1)·3층(SW2)이다.

```
                     [R1]
                      │ G0/0  (.10 · .20)
                      │ trunk
                      │ Gi0/1
  PC0 ──Fa0/1──┐      │      ┌──Fa0/1── PC2
             [SW1]════════════[SW2]
  PC1 ──Fa0/2──┘ Fa0/23 ═══ Fa0/23 └──Fa0/2── PC3
                 Fa0/24 ═══ Fa0/24   ← STEP 4
```

| | VLAN 10 영업 (192.168.10.0/24) | VLAN 20 개발 (192.168.20.0/24) |
|---|---|---|
| 2층 SW1 | PC0 `192.168.10.1` (Fa0/1) | PC1 `192.168.20.1` (Fa0/2) |
| 3층 SW2 | PC2 `192.168.10.2` (Fa0/1) | PC3 `192.168.20.2` (Fa0/2) |
| 게이트웨이 | R1 G0/0.10 `192.168.10.254` | R1 G0/0.20 `192.168.20.254` |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 8일차는 오늘 만든 파일 위에서 진행한다. 실습을 마치면 반드시 `7일차_스위칭.pkt`로 저장한다.
{% endhint %}

{% hint style="info" %}
NOTE: 선을 꽂거나 포트를 켤 때마다 STP 확인에 30초가 걸려 링크 점이 주황으로 보인다. STEP 4에서 두 번째 선의 한쪽 끝은 계속 주황이다. 고장이 아니라 STP가 막은 것이다.
{% endhint %}

{% hint style="info" %}
NOTE: 이 실습은 Packet Tracer 안에서만 진행한다. 실제 장비에는 적용하지 않는다. 입력하는 주소는 모두 사설 주소다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 새 Packet Tracer 파일을 연다 | 빈 작업 영역이 보인다 |
| 2 | 4일차 CLI 입력 요령(Tab, `?`, 축약)을 안다 | `conf` + `Tab`이 `configure`로 완성된다 |
| 3 | 오늘 질문 세 개를 확인한다: 스위치 한 대를 나눌 수 있나, 층을 넘어 이을 수 있나, 선 두 줄을 둘 다 쓸 수 있나 | 실습 끝에 각각 답한다 |

## 5. 절차

### A. 그림 만들기 (15분)

1. (SUBTASK 5-A-01) 라우터 1대(2911), 스위치 2대(2960), PC 4대를 배치한다. → 결과: 장비 7대가 작업 영역에 있다.
2. (SUBTASK 5-A-02) PC와 스위치를 Copper Straight-Through로 잇는다(PC0·PC1은 SW1 Fa0/1·Fa0/2, PC2·PC3은 SW2 Fa0/1·Fa0/2). → 결과: 링크 점이 생긴다.
3. (SUBTASK 5-A-03) R1 G0/0과 SW1 Gi0/1을 Copper Straight-Through로 잇는다. → 결과: 링크 점이 생긴다.
4. (SUBTASK 5-A-04) SW1 Fa0/23과 SW2 Fa0/23을 Copper Cross-Over로 잇는다. → 결과: 링크 점이 생긴다.
5. (SUBTASK 5-A-05) 아직 Fa0/24는 잇지 않는다. 두 번째 선은 STEP 4의 주인공이다.
6. (SUBTASK 5-A-06) PC 4대에 IP·마스크·게이트웨이를 입력한다(2절 표, 마스크 `255.255.255.0`). → 결과: `ipconfig`에 입력한 값이 보인다.
7. (SUBTASK 5-A-07) SW1 CLI에서 이름만 붙인다. → 결과: 프롬프트가 `SW1#`로 바뀐다.

```bash
enable
configure terminal
no ip domain-lookup
hostname SW1
end
```

8. (SUBTASK 5-A-08) SW2 CLI에서 같은 방식으로 `hostname SW2`를 설정한다. → 결과: 프롬프트가 `SW2#`로 바뀐다.
9. (SUBTASK 5-A-09) 스위치 사이 링크 양쪽이 초록인지 확인한다. 주황이면 30초 기다린다. → 결과: 양쪽 초록이다.

### B. STEP 1 — VLAN: 나눴더니 오히려 안 된다 (20분)

1. (SUBTASK 5-B-01) 나누기 전에 PC0 Command Prompt에서 `ping 192.168.10.2`를 입력한다. → 결과: 응답이 온다(모든 포트가 VLAN 1이다).
2. (SUBTASK 5-B-02) (관찰, 권장) 시뮬레이션 모드에서 `Edit Filters`로 ARP와 ICMP만 켠다. PC0에서 `arp -d` 후 `ping 192.168.10.2`를 입력한다. → 결과: ARP가 개발팀 PC1·PC3에도 전달된다. 스위치 전체가 브로드캐스트 도메인 하나이기 때문이다.
3. (SUBTASK 5-B-03) SW1 CLI에서 VLAN을 만들고 포트에 넣는다. → 결과: `show vlan brief`에서 Fa0/1은 10, Fa0/2는 20에 보인다.

```bash
configure terminal
vlan 10
 name SALES
vlan 20
 name DEV
 exit
interface fa0/1
 switchport mode access
 switchport access vlan 10
interface fa0/2
 switchport mode access
 switchport access vlan 20
end
show vlan brief
```

4. (SUBTASK 5-B-04) SW2 CLI에서 같은 설정을 입력한다. VLAN은 스위치마다 따로 만든다. → 결과: SW2의 `show vlan brief`에도 10 SALES·20 DEV가 보인다.
5. (SUBTASK 5-B-05) PC0에서 `ping 192.168.10.2`를 입력한다. → 결과: 실패한다. PC0과 PC2는 같은 VLAN 10인데 스위치 사이 Fa0/23이 VLAN 1 액세스 포트여서 VLAN 10 프레임이 지나가지 못한다. 이 실패가 트렁크가 필요한 이유다.

### C. STEP 2 — 트렁크: 같은 VLAN은 넘고 다른 VLAN은 못 넘는다 (15분)

1. (SUBTASK 5-C-01) SW1 CLI에서 Fa0/23을 트렁크로 만든다. → 결과: 오류 없이 끝난다.

```bash
configure terminal
interface fa0/23
 switchport mode trunk
end
```

2. (SUBTASK 5-C-02) SW2 CLI에서 같은 설정을 입력한다. SW1만 설정해도 DTP로 붙을 수 있으나 양쪽 다 못 박는다. → 결과: 오류 없이 끝난다.
3. (SUBTASK 5-C-03) SW2에서 `show interfaces trunk`를 입력한다. → 결과: Fa0/23이 `trunking`, Native vlan `1`이다.
4. (SUBTASK 5-C-04) SW2에서 `show vlan brief`를 입력한다. → 결과: Fa0/23이 목록에서 사라져 있다. 모든 VLAN의 통로가 되었기 때문이며 정상이다.
5. (SUBTASK 5-C-05) PC0에서 `ping 192.168.10.2`와 `ping 192.168.20.1`을 차례로 입력한다. → 결과: PC2(같은 VLAN 10, 3층)는 성공하고 PC1(VLAN 20, 옆자리)은 실패한다. 트렁크는 같은 VLAN끼리의 통로이고, 다른 VLAN은 다른 네트워크라 라우터가 필요하다.
6. (SUBTASK 5-C-06) PC1에서 `ping 192.168.20.2`를 입력한다. → 결과: PC3(20 → 20)으로 성공한다. 태그 20도 같은 선을 탄다.
7. (SUBTASK 5-C-07) (관찰) 시뮬레이션 모드에서 PC0 `arp -d` 후 `ping 192.168.10.2`를 입력한다. → 결과: 이번에는 ARP가 PC1·PC3으로 가지 않는다. 5-B-02와 비교하면 브로드캐스트 도메인이 나뉜 것이 보인다.

### D. STEP 3 — Router-on-a-stick: "태그 먼저, 주소 나중" (20분)

1. (SUBTASK 5-D-01) SW1 CLI에서 라우터 쪽 포트 Gi0/1을 트렁크로 만든다. 라우터에 태그 10·20을 둘 다 넘겨야 한다. → 결과: 오류 없이 끝난다.

```bash
configure terminal
interface g0/1
 switchport mode trunk
end
```

2. (SUBTASK 5-D-02) R1 CLI에서 물리 포트를 켜고 서브인터페이스에 일부러 태그 없이 IP부터 입력한다.

```bash
enable
configure terminal
no ip domain-lookup
hostname R1
interface g0/0
 no shutdown
 exit
interface g0/0.10
 ip address 192.168.10.254 255.255.255.0
```

→ 결과: `% Configuring IP routing on a LAN subinterface is only allowed if that subinterface is already configured as part of an IEEE 802.10, IEEE 802.1Q, or ISL vLAN.`가 출력된다. 서브인터페이스가 어느 태그 담당인지 아직 모르기 때문이다.

3. (SUBTASK 5-D-03) 같은 서브인터페이스에서 순서대로 다시 입력한다. 물리 포트 `g0/0`에는 IP를 넣지 않는다. → 결과: 이번에는 거절되지 않는다.

```bash
 encapsulation dot1Q 10
 ip address 192.168.10.254 255.255.255.0
 exit
interface g0/0.20
 encapsulation dot1Q 20
 ip address 192.168.20.254 255.255.255.0
end
```

4. (SUBTASK 5-D-04) `show ip interface brief`를 입력한다. → 결과: G0/0, G0/0.10, G0/0.20이 모두 up/up이다.
5. (SUBTASK 5-D-05) `show ip route`를 입력한다. → 결과: `C 192.168.10.0/24 ... GigabitEthernet0/0.10`과 `C 192.168.20.0/24 ... GigabitEthernet0/0.20`이 보인다. 물리 포트는 하나인데 `C`가 두 줄이다. 선 하나에 네트워크 두 개가 붙어 있다.
6. (SUBTASK 5-D-06) PC0에서 `ping 192.168.20.1`, `ping 192.168.20.2`, `tracert 192.168.20.1`을 차례로 입력한다. → 결과: 모두 성공한다. `tracert`의 1홉은 `192.168.10.254`(R1), 2홉은 `192.168.20.1`이다.
7. (SUBTASK 5-D-07) `Ctrl + S`로 중간 저장한다. → 결과: 파일이 저장된다.

{% hint style="info" %}
NOTE: 옆자리로 가는 패킷이 라우터를 들렀다 온다. 모든 부서 간 트래픽이 SW1–R1 선 한 줄과 SW1–SW2 선 한 줄에 몰린다. STEP 4의 동기다.
{% endhint %}

### E. STEP 4 — 두 번째 선 → STP → EtherChannel (30분)

**E-1. 선을 하나 더 꽂는다**

1. (SUBTASK 5-E-01) SW1 Fa0/24와 SW2 Fa0/24를 Copper Cross-Over로 잇는다. 30초 기다린다. → 결과: 30초가 지나도 한쪽 끝이 주황으로 남는다.
2. (SUBTASK 5-E-02) 두 스위치 CLI에서 `show spanning-tree vlan 10`을 입력한다. → 결과: 한쪽에 `This bridge is the root`가 보이고, 다른 쪽에서 Fa0/23은 `Root FWD`, Fa0/24는 `Altn BLK`다.

| | 대장(루트) 쪽 | 대장 아닌 쪽 |
|---|---|---|
| 표시 | `This bridge is the root` | Root ID에 상대 MAC |
| Fa0/23 | Desg FWD | Root FWD |
| Fa0/24 | Desg FWD | Altn BLK |

3. (SUBTASK 5-E-03) 막힌 선이 어느 쪽에 있는지 기록한다. 대장은 MAC이 작은 쪽이므로 옆 사람과 결과가 달라도 정상이다. → 결과: 선 두 줄 중 하나가 놀고 있다는 것이 확인된다. 4일차 STP의 대가다.

**E-2. 둘을 하나로 묶는다**

구호는 "끄고, 똑같이, 묶고, 켠다"이다.

4. (SUBTASK 5-E-04) SW1 CLI에서 입력한다. → 결과: 오류 없이 끝난다.

```bash
configure terminal
interface range fa0/23 - 24
 shutdown
 switchport mode trunk
 channel-group 1 mode active
 no shutdown
 exit
interface port-channel 1
 switchport mode trunk
end
```

5. (SUBTASK 5-E-05) SW2 CLI에서 같은 설정을 입력한다. 한쪽만 하면 묶이지 않는다. → 결과: 오류 없이 끝난다.
6. (SUBTASK 5-E-06) 30초 기다린 뒤 `show etherchannel summary`를 입력한다. → 결과: `1  Po1(SU)  LACP  Fa0/23(P) Fa0/24(P)`가 보인다.
7. (SUBTASK 5-E-07) `show spanning-tree vlan 10`을 입력한다. → 결과: Fa0/23·Fa0/24가 사라지고 `Po1` 한 줄만 `FWD`다. 막힌 선이 없다.
8. (SUBTASK 5-E-08) `show interfaces trunk`를 입력한다. → 결과: Port 칸이 `Po1`이다.

| 명령 | 묶기 전 | 묶은 뒤 |
|---|---|---|
| `show etherchannel summary` | (없음) | `Po1(SU)` · `Fa0/23(P) Fa0/24(P)` |
| `show spanning-tree vlan 10` | Fa0/23 · Fa0/24 (하나 BLK) | `Po1` 한 줄, FWD |
| `show interfaces trunk` | Fa0/23 | Po1 |

**E-3. 선 하나를 뽑아 본다**

9. (SUBTASK 5-E-09) PC0에서 `ping -t 192.168.10.2`를 입력한다. 멈출 때는 `Ctrl + C`를 쓴다. `-t`가 동작하지 않는 Packet Tracer 버전에서는 선을 뽑은 직후에 일반 `ping`으로 확인한다. → 결과: ping이 계속 응답한다.
10. (SUBTASK 5-E-10) ping이 도는 동안 Fa0/24 선을 삭제한다(X 도구). → 결과: ping이 끊기지 않는다.
11. (SUBTASK 5-E-11) SW1에서 `show etherchannel summary`를 입력한다. → 결과: `Fa0/24(D)`이지만 `Po1(SU)`는 그대로다.
12. (SUBTASK 5-E-12) Fa0/24 선을 다시 꽂는다. → 결과: 잠시 후 `Fa0/24(P)`로 복귀한다.

| | STP만 있을 때 선이 끊기면 | EtherChannel에서 선이 끊기면 |
|---|---|---|
| 동작 | 막아 둔 선을 다시 계산해서 연다 | Po1은 그대로, 남은 선으로 계속 |
| 끊김 | 최대 30~50초 | 사실상 없음 |

13. (SUBTASK 5-E-13) 스위치 둘에서 `copy running-config startup-config`를 입력하고 `Ctrl + S`로 파일을 저장한다. → 결과: 저장이 끝난다.

### F. STEP 5 — 마무리 튜닝: 대장 지명 · PortFast (10분, 생략 가능)

1. (SUBTASK 5-F-01) SW1 CLI에서 SW1을 루트 브리지로 지명한다. → 결과: `show spanning-tree vlan 10`에 `This bridge is the root`와 Priority `24586`(24576 + VLAN 10)이 보인다.

```bash
configure terminal
spanning-tree vlan 1,10,20 root primary
end
show spanning-tree vlan 10
```

2. (SUBTASK 5-F-02) SW1의 PC0 포트에만 PortFast를 켠다. → 결과: PortFast 경고 문구가 출력된다(정상).

```bash
configure terminal
interface fa0/1
 spanning-tree portfast
end
```

3. (SUBTASK 5-F-03) PC0 선과 PC1 선을 둘 다 삭제한 뒤 다시 연결한다. → 결과: PC0(Fa0/1)은 바로 초록, PC1(Fa0/2)은 주황이 30초 남는다. 3일차 주황 점이 사라진 것이 보인다.
4. (SUBTASK 5-F-04) SW1과 SW2에서 나머지 PC 포트에도 PortFast를 켠다. → 결과: 오류 없이 끝난다.

```bash
configure terminal
interface range fa0/1 - 2
 spanning-tree portfast
end
```

{% hint style="danger" %}
WARNING: Fa0/23 · Fa0/24 · Po1 · Gi0/1(스위치·라우터 연결 포트)에는 PortFast를 켜지 않는다. 켜면 STP의 안전장치를 끄는 것이어서 루프가 생길 수 있다.
{% endhint %}

5. (SUBTASK 5-F-05) 모든 장비에서 `copy running-config startup-config`를 입력하고 파일을 `7일차_스위칭.pkt`로 저장한다. → 결과: 저장이 끝난다. 8일차에 이어 쓴다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 두 스위치 `show vlan brief` | 10 SALES · 20 DEV와 PC 포트가 보인다 | Fa0/1은 10, Fa0/2는 20 |
| 2 | `show interfaces trunk` | 트렁크가 맺어져 있다 | Status `trunking` |
| 3 | R1 `show ip route` | 서브인터페이스 네트워크가 보인다 | `C` 두 줄 (g0/0.10, g0/0.20) |
| 4 | PC0 → PC1, PC0 → PC3 ping | VLAN 간 통신이 된다 | 모두 응답 |
| 5 | 두 스위치 `show etherchannel summary` | 묶음이 정상이다 | `Po1(SU)`, `Fa0/23(P) Fa0/24(P)` |
| 6 | `show spanning-tree` | 막힌 선이 없다 | BLK가 없다 |
| 7 | 선 하나를 뽑은 상태에서 ping | 통신이 이어진다 | 응답이 끊기지 않는다 |
| 8 | PC 4대 서로 전부 ping | 전부 성공한다 | 12방향 모두 응답 |

## 7. 복구

실습 설정을 처음 상태로 되돌린다.

1. (SUBTASK 7-01) 두 스위치에서 EtherChannel을 해제한다: `interface range fa0/23 - 24` → `no channel-group 1` → `exit` → `no interface port-channel 1`. → 결과: `show etherchannel summary`에 묶음이 없다.
2. (SUBTASK 7-02) PC 포트의 VLAN을 되돌린다: `interface range fa0/1 - 2` → `no switchport access vlan` → `no spanning-tree portfast`. → 결과: 두 포트가 VLAN 1에 보인다.
3. (SUBTASK 7-03) VLAN을 지운다: `no vlan 10`, `no vlan 20`. → 결과: `show vlan brief`에 10·20이 없다.
4. (SUBTASK 7-04) R1의 서브인터페이스를 지운다: `no interface g0/0.10`, `no interface g0/0.20`. → 결과: `show ip interface brief`에 서브인터페이스가 없다.
5. (SUBTASK 7-05) 저장하지 않은 채 파일을 닫아도 원래 상태로 돌아간다. 저장한 파일은 새 파일로 다시 시작하는 편이 빠르다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 강의 노트 `lesson-4.md`를 AMM 형식(MP)으로 재작성. 막힘 해결 표는 `lesson-4-troubleshooting.md`(TS)로 분리 |
