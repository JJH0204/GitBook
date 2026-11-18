# 0. 실습 명령어 모음

> 상위: [5일차 동적 라우팅 RIP](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-05-005-REF |
| 유형 | REF (명령 대본) |
| 목적 | 5일차 실습에서 입력하는 명령과 기대 결과를 수업 흐름 순서대로 모은다 |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이번 재작성에서 다시 실행하지 않았다. 장비 화면은 IOS 15 형식이며 패킷트레이서 버전에 따라 다를 수 있다) |
| 개정 | R1 (2026-11-18) |

실습하는 동안 띄워 둔다. 1~8번은 `_실습/새봄상사.pkt`에서 새봄상사의 주소로 강사와 함께 입력하고(6번은 강사 시연), 9~12번은 개인 실습에서 `configs/network.pkt`를 열어 같은 일을 내 회사의 설계로 한다. 단계별 결과와 복구는 세 실습 문서에 있다.

{% hint style="danger" %}
WARNING: 허가받지 않은 시스템에 이 절차를 수행하는 것은 불법이다. 6번 거짓 경로 시연은 강사의 패킷트레이서 안(시뮬레이터의 가상 장비)에서만 한다.
{% endhint %}

| 문서 | Task ID | 다루는 번호 |
|---|---|---|
| [2-1. 정적 경로를 RIP으로 바꾸는 실습](lesson-2-lab.md) | LEC-SN-05-006-MP | 1~5번 |
| [3-1. 거짓 경로 시연과 RIP 보호 실습](lesson-3-lab.md) | LEC-SN-05-007-MP | 6~8번 |
| [4-1. 내 회사 RIP 전환과 비교 기록 실습](lesson-4-lab.md) | LEC-SN-05-008-MP | 9~12번 |

## 수업 흐름

| 단계 | 내용 | 언제 | 노트 |
|---|---|---|---|
| 0 | 작업 계획서 | 14:00 (20분) | README |
| 1 | 주 정적 경로 걷어 내기 | 함께 (4분) | 2 |
| 2 | RIP 켜기와 확인 | 함께 (15분) | 2 |
| 3 | 예비 회선 passive | 함께 (7분) | 2 |
| 4 | 창고 네트워크 | 함께 (5분) | 2 |
| 5 | 장애 시험, 예비 경로를 /24로 | 함께 (9분) | 2 |
| 6 | 거짓 경로 시연 | 강사 시연 (15분) | 3 |
| 7 | 사무실 쪽 passive | 함께 (10분) | 3 |
| 8 | RIP 인증 | 함께 (15분) | 3 |
| 9 | 내 회사로 RIP 바꾸기 | 17:00 개인 (20분) | 2, 3 |
| 10 | 장애 시험과 비교 기록 | 개인 (20분) | 4 |
| 11 | 설정 텍스트 | 개인 (8분) | 4 |
| 12 | 결과 기록과 커밋 | 개인 (10분) | |

1~5번을 마친 뒤 쉬는 시간이다.

## 0. 작업 계획서 (14:00~14:20)

```bash
cd ~/my-netsec-project
git pull
```

VS Code에서 `00_작업계획/05일차.md`를 만들고 [README](README.md)의 새봄상사 예시를 보며 1~5번 칸을 채운다.

```bash
git add .
git commit -m "5일차: 작업 계획서"
git push
```

## 1. 주 정적 경로 걷어 내기

```
HQ-R1(config)#no ip route 192.168.20.0 255.255.255.224 192.168.99.2
BR-R1(config)#no ip route 0.0.0.0 0.0.0.0 192.168.99.1
```

`show ip route static`을 입력하면 두 라우터 모두 예비 경로(관리 거리 250)가 떠올라 있다.

## 2. RIP 켜기와 확인

HQ-R1에서 입력한다.

```
router rip
 version 2
 no auto-summary
 network 192.168.10.0
 network 192.168.99.0
```

BR-R1에서 입력한다.

```
router rip
 version 2
 no auto-summary
 network 192.168.20.0
 network 192.168.99.0
```

1분쯤 기다린 뒤 확인한다.

```
end
show ip route rip
show ip protocols
```

HQ-R1의 192.168.20.0/27 줄이 Gi0/1과 Se0/0/0 두 갈래로 보이는지 찾는다.

## 3. 예비 회선 passive

두 라우터 모두에서 입력한다.

```
configure terminal
router rip
 passive-interface se0/0/0
 end
clear ip route *
show ip route rip
```

R 줄이 Gi0/1 하나로 줄면 된다.

## 4. 창고 네트워크

BR-R1에서 입력한다.

```
configure terminal
interface loopback 1
 description BR warehouse (simulated)
 ip address 192.168.20.33 255.255.255.224
 end
```

본사 라우터에서는 아무것도 입력하지 않고 30초쯤 기다린 뒤 `show ip route rip`에서 `192.168.20.32/27`을 찾는다.

## 5. 장애 시험, 예비 경로를 /24로

BR-PC1에서 `ping -t 192.168.10.98`을 걸고, HQ-R1에서 주 회선을 끈다.

```
configure terminal
interface gi0/1
 shutdown
 end
show ip route
```

예비 경로로 넘어가는 것을 확인한 뒤, HQ-R1에서 창고(192.168.20.33)로 ping을 입력한다. 통하지 않는다. 예비 경로를 /24로 바꾼다.

```
configure terminal
no ip route 192.168.20.0 255.255.255.224 192.168.99.6 250
ip route 192.168.20.0 255.255.255.0 192.168.99.6 250
end
ping 192.168.20.33
```

통하면 주 회선을 되살린다.

```
configure terminal
interface gi0/1
 no shutdown
 end
```

## 6. 거짓 경로 시연 (강사 시연)

강사의 패킷트레이서(시뮬레이터의 가상 장비)에서만 한다. 2911 라우터를 하나 놓고 이름을 FAKE-R로 바꾼 뒤, Gi0/0을 HQ-SW1의 Fa0/3(영업팀 VLAN 10)에 잇는다.

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

1분쯤 뒤 HQ-R1에서 확인한다.

```
HQ-R1#show ip route rip
R       192.168.10.96/28 [120/1] via 192.168.10.20, 00:00:08, GigabitEthernet0/0.10
```

Dev-PC1에서 `tracert 192.168.10.98`을 입력하면 두 번째 칸이 192.168.10.20(가짜 장비)이고 그 뒤로 끊긴다. 서버로 가던 통신이 가짜 장비로 빨려 들어간 것이다. FAKE-R은 8번이 끝날 때까지 그대로 둔다.

## 7. 사무실 쪽 passive

HQ-R1에서 입력한다.

```
configure terminal
router rip
 passive-interface gi0/0.10
 passive-interface gi0/0.20
 passive-interface gi0/0.30
 passive-interface gi0/0.40
 passive-interface gi0/0.99
 end
clear ip route *
```

1분쯤 뒤 `show ip route rip`을 확인하면 `192.168.10.96/28 via 192.168.10.20`이 다시 생겨 있다. passive는 듣기를 막지 않는다.

BR-R1에도 사무실 쪽을 passive로 둔다.

```
configure terminal
router rip
 passive-interface gi0/0
 passive-interface loopback 1
 end
```

## 8. RIP 인증

두 라우터에 같은 열쇠고리를 만든다. `<password>`는 수업에서 정한 실습용 값 하나로 바꾼다.

```
configure terminal
key chain RIPKEY
 key 1
  key-string <password>
  exit
 exit
```

HQ-R1은 주 회선과 서브인터페이스 다섯 개에 인증을 건다.

```
interface gi0/1
 ip rip authentication mode md5
 ip rip authentication key-chain RIPKEY
interface gi0/0.10
 ip rip authentication mode md5
 ip rip authentication key-chain RIPKEY
interface gi0/0.20
 ip rip authentication mode md5
 ip rip authentication key-chain RIPKEY
interface gi0/0.30
 ip rip authentication mode md5
 ip rip authentication key-chain RIPKEY
interface gi0/0.40
 ip rip authentication mode md5
 ip rip authentication key-chain RIPKEY
interface gi0/0.99
 ip rip authentication mode md5
 ip rip authentication key-chain RIPKEY
 end
```

BR-R1은 주 회선과 Gi0/0에 건다.

```
interface gi0/1
 ip rip authentication mode md5
 ip rip authentication key-chain RIPKEY
interface gi0/0
 ip rip authentication mode md5
 ip rip authentication key-chain RIPKEY
 end
```

두 라우터에서 `clear ip route *`를 입력하고 1분쯤 뒤 확인한다.

```
show ip route rip
```

HQ-R1에서 `192.168.10.96/28`이 사라지고, 지사 경로(192.168.20.0/27, 192.168.20.32/27)는 그대로 있으면 된다. Dev-PC1의 `tracert 192.168.10.98`이 다시 서버에 닿는다. 확인한 뒤 FAKE-R을 지우고, 세 장비를 저장한다.

## 9. 내 회사로 RIP 바꾸기 (개인 실습)

`_실습/새봄상사.pkt`를 저장하고 닫은 뒤 `configs/network.pkt`를 연다.

1. 1~5번을 내 주소로 한다. `network`에는 내 본사, 지사, 연결 대역의 클래스 단위 주소를 적는다.
2. 7번(passive)과 8번(인증)을 한다. 6번 시연은 하지 않는다.
3. 창고 네트워크는 내 지사 /24 안의 두 번째 /27로 만든다.

## 10. 장애 시험과 비교 기록

1. 5번의 장애 시험을 내 망에서 하고 빠진 ping 개수를 센다.
2. 창고 네트워크를 만든 뒤 본사 경로표에 나타나기까지 몇 초 걸렸는지 적는다.
3. [4번 노트](lesson-4.md)의 양식으로 `03_구축/라우팅_비교.md`를 쓴다.

## 11. 설정 텍스트

HQ-R1, BR-R1의 설정 텍스트를 덮어쓰고 diff를 본다.

```bash
git diff configs/HQ-R1.txt
```

## 12. 결과 기록과 커밋

`00_작업계획/05일차.md`의 결과 칸을 채우고, README 진행 현황에 한 줄을 더한다.

```markdown
| 5 | 정적에서 RIPv2로, passive와 인증, 두 방식 비교 | [작업 계획서](00_작업계획/05일차.md), [라우팅 비교](03_구축/라우팅_비교.md), [설정](configs/) |
```

```bash
git add .
git commit -m "5일차: RIPv2 전환, passive와 인증, 정적과 비교"
git push
```

## 자주 막히는 곳

| 보이는 것 | 원인 | 해결 |
|-----------|------|------|
| R 줄이 하나도 없다 | 한쪽이 `version 2`가 아니거나 `network`에 연결 대역이 없다 | `show ip protocols`로 버전과 켜진 포트를 본다 |
| `network 192.168.10.0 255.255.255.224`가 거절된다 | RIP의 `network`는 마스크를 받지 않는다 | `network 192.168.10.0` |
| 지사 경로가 /24로 보인다 | `no auto-summary`를 빠뜨렸다 | 양쪽에 `no auto-summary` |
| passive를 걸었는데 경로가 두 갈래 그대로다 | 이미 배운 경로가 남아 있다 | `clear ip route *` |
| 인증을 걸자 지사 경로가 사라졌다 | 반대쪽에 아직 인증을 걸지 않았거나 키가 다르다 | 양쪽 key-string을 글자 하나까지 맞춘다 |
| 인증 뒤에도 가짜 경로가 남아 있다 | 영업팀 서브인터페이스(gi0/0.10)에 인증을 걸지 않았다 | 8번의 서브인터페이스 블록 |
| `ip rip authentication`이 거절된다 | 패킷트레이서 버전이 지원하지 않는다 | 강사에게 알린다. passive까지만 하고 인증은 설정 줄로만 기록한다 |
| 루프백이 경로표에 /32로 보인다 | 루프백 주소의 마스크를 /32로 줬다 | 255.255.255.224 |

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 대본을 AMM REF 형식으로 재작성. 평서체 변환. 실습 절차는 세 MP(LEC-SN-05-006-MP, -007-MP, -008-MP)로 분리. 번호(0~12)는 다른 문서의 참조 때문에 유지. 키 값 표기를 `<password>`로 교체 |
