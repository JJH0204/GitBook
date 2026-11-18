# 2-1. 지사 장비 설치와 정적 경로 실습

> 상위: [4일차 정적 라우팅과 지사 연결](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-04-006-MP |
| 목적 | 패킷트레이서에서 지사 라우터와 스위치를 놓고 잠근 뒤, 본사와 /30으로 잇고 정적 경로와 기본 경로로 지사 PC에서 본사 서버까지 통신시킨다 |
| 적용 대상 | Cisco Packet Tracer의 `_실습/새봄상사.pkt` (2911 라우터, 2960 스위치, PC). 격리된 가상 실습망이며 실제 장비와 연결하지 않는다 |
| 소요 시간 | 약 35분 (수업 시간표의 지사 연결 시간 안) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이 환경에서 패킷트레이서를 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-2.md](lesson-2.md) | LEC-SN-04-002-DO | 지사 연결과 정적 경로 |
| [lesson-1.md](lesson-1.md) | LEC-SN-04-001-DO | 라우팅과 경로표 |
| [commands.md](commands.md) | LEC-SN-04-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-SN-04-007-MP | 다음 실습. 예비 회선과 장애 시험 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Cisco Packet Tracer | `_실습/새봄상사.pkt` 파일 | 3일차까지의 본사 구성이 들어 있다 |
| 2 | 라우터 | 2911 (BR-R1) | 새로 놓는다 |
| 3 | 스위치 | 2960 (BR-SW1) | 새로 놓는다 |
| 4 | PC | BR-PC1, BR-PC2 | 새로 놓는다 |
| 5 | 본사 장비 | HQ-R1, 본사 서버(192.168.10.98) | 3일차에 구성한 장비 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 구역 C에서 본사에만 경로를 넣은 상태로 ping이 실패하는 것은 의도한 시험이다. 실패하면 오류가 아니라 지사 라우터에 경로가 없는 상태이므로 구역 C의 다음 단계로 넘어간다.
{% endhint %}

{% hint style="info" %}
NOTE: 비밀번호는 `<password>` 자리에 실습용 값을 직접 정해 넣는다. 문서에 실제로 쓰는 비밀번호를 적지 않는다.
{% endhint %}

{% hint style="info" %}
NOTE: 출력 예시는 IOS 15 형식이다. 패킷트레이서 버전에 따라 줄 구성이 조금 다를 수 있다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 오늘의 작업 계획서 1~5번 칸을 커밋했다 | `git log`에 4일차 작업 계획서 커밋이 있다 |
| 2 | `_실습/새봄상사.pkt`를 연다 | 본사 장비와 서버가 보인다 |
| 3 | Options의 Preferences에서 `Always Show Port Labels`를 켠다 | 장비 옆에 포트 이름이 항상 보인다 |
| 4 | HQ-R1의 Gi0/1이 비어 있다 | 케이블이 연결되지 않았다 |

## 5. 절차

### A. 지사 장비 놓기와 잠금

1. (5-A-01) 2911 라우터(BR-R1), 2960 스위치(BR-SW1), PC 두 대(BR-PC1, BR-PC2)를 화면 오른쪽에 놓는다.
2. (5-A-02) HQ-R1의 Gi0/1과 BR-R1의 Gi0/1을 잇는다(번개 모양 케이블). → 결과: 양쪽 포트에 링크 표시가 생긴다.
3. (5-A-03) BR-R1의 Gi0/0과 BR-SW1의 Gi0/1을 잇는다.
4. (5-A-04) BR-PC1을 BR-SW1의 Fa0/1에, BR-PC2를 Fa0/2에 잇는다.
5. (5-A-05) BR-R1 CLI에서 2일차의 잠금을 건다. `hostname`만 BR-R1로 바꾼다.

```
enable
configure terminal
hostname BR-R1
no ip domain-lookup
enable secret <password>
line console 0
 password <password>
 login
 exec-timeout 5 0
 exit
line vty 0 4
 password <password>
 login
 exec-timeout 5 0
 exit
service password-encryption
banner motd # Authorized access only. All access is logged. #
```

→ 결과: 프롬프트가 `BR-R1(config)#`로 바뀌어 있다.

6. (5-A-06) BR-SW1에는 같은 잠금(VTY는 `line vty 0 15`)을 건다.
7. (5-A-07) BR-SW1에 3일차의 스위치 보안을 더한다.

```
vtp mode transparent
vlan 10
 name SALES
vlan 999
 name UNUSED
interface range fa0/1 - 10 , gi0/1
 switchport mode access
 switchport access vlan 10
interface range fa0/11 - 24 , gi0/2
 switchport mode access
 switchport access vlan 999
 shutdown
 end
```

→ 결과: 프롬프트가 `BR-SW1#`로 돌아온다. 지사 라우터와 스위치 사이(Gi0/1)는 트렁크가 아니라 VLAN 10의 access 포트다. 지사에는 부서가 하나뿐이라 라우터가 태그를 다룰 필요가 없다.

### B. 주소 주기

1. (5-B-01) HQ-R1에서 주 회선 포트에 주소를 준다.

```
configure terminal
interface gi0/1
 description To BR-R1 primary
 ip address 192.168.99.1 255.255.255.252
 no shutdown
 end
```

2. (5-B-02) BR-R1에서 두 포트에 주소를 준다.

```
configure terminal
interface gi0/0
 description BR Sales LAN
 ip address 192.168.20.1 255.255.255.224
 no shutdown
interface gi0/1
 description To HQ-R1 primary
 ip address 192.168.99.2 255.255.255.252
 no shutdown
 end
```

3. (5-B-03) PC의 주소를 아래 표대로 준다.

| PC | IP 주소 | 서브넷 마스크 | 기본 게이트웨이 |
|---|---|---|---|
| BR-PC1 | 192.168.20.2 | 255.255.255.224 | 192.168.20.1 |
| BR-PC2 | 192.168.20.3 | 255.255.255.224 | 192.168.20.1 |

4. (5-B-04) BR-R1에서 `ping 192.168.99.1`을 입력한다. → 결과: Reply가 오면 두 라우터가 이어진 것이다.

### C. 정적 경로와 기본 경로

1. (5-C-01) HQ-R1에 지사로 가는 길만 먼저 넣는다.

```
HQ-R1(config)#ip route 192.168.20.0 255.255.255.224 192.168.99.2
```

2. (5-C-02) BR-PC1의 명령 프롬프트에서 본사 서버로 ping을 친다: `ping 192.168.10.98` → 결과: 실패한다.

```
Reply from 192.168.20.1: Destination host unreachable.
```

답한 쪽이 지사 라우터(192.168.20.1)다. 지사 라우터가 본사로 가는 길을 모른다.

3. (5-C-03) BR-R1에 기본 경로를 넣는다.

```
BR-R1(config)#ip route 0.0.0.0 0.0.0.0 192.168.99.1
```

4. (5-C-04) BR-PC1에서 같은 ping을 다시 친다. → 결과: Reply가 온다.

### D. 확인

1. (5-D-01) BR-PC1에서 `tracert 192.168.10.98`을 입력한다. → 결과: 세 칸(192.168.20.1, 192.168.99.1, 192.168.10.98)이 보인다.
2. (5-D-02) 두 라우터에서 `show ip route`를 입력한다. → 결과: 경로표가 나온다.
3. (5-D-03) 두 라우터에서 `show ip route static`을 입력한다. → 결과: S 줄만 나온다. 본사에는 `S 192.168.20.0/27 [1/0] via 192.168.99.2`, 지사에는 `S* 0.0.0.0/0 [1/0] via 192.168.99.1`이 있어야 한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | BR-R1에서 `ping 192.168.99.1` | Reply | 5개 모두 성공 |
| 2 | BR-PC1에서 `ping 192.168.10.98` | Reply | 응답 수신 |
| 3 | BR-PC1에서 `tracert 192.168.10.98` | 세 칸 | 192.168.20.1, 192.168.99.1, 192.168.10.98 순서 |
| 4 | HQ-R1에서 `show ip route static` | `S 192.168.20.0/27 [1/0] via 192.168.99.2` | 해당 줄 존재 |
| 5 | BR-R1에서 `show ip route static` | `S* 0.0.0.0/0 [1/0] via 192.168.99.1` | 해당 줄 존재 |

## 7. 복구

1. (7-01) 경로를 잘못 넣었으면 같은 줄 앞에 `no`를 붙여 지운다.

```
no ip route 192.168.20.0 255.255.255.224 192.168.99.2
```

2. (7-02) 실습을 처음 상태로 돌리려면 `_실습/새봄상사.pkt`를 저장하지 않고 닫고 다시 연다.
3. (7-03) 다음 실습(LEC-SN-04-007-MP)으로 넘어가기 전에 `copy running-config startup-config`로 두 라우터를 저장한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 1~4번을 AMM 형식 MP로 분리. 비밀번호 자리 `<password>`로 표기. 번호(1~4)는 다른 문서의 참조 때문에 `commands.md`에 유지 |
