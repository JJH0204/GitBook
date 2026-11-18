# 2-1. GRE 터널과 장애 시험 실습

> 상위: [11일차 VPN과 IPv6](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-11-006-MP |
| 목적 | 보안 라이선스를 켜고, 지사를 인터넷에 잇고, GRE 터널과 터널 위 OSPF를 만든 뒤, 예비 시리얼 회선을 해지하고 주 회선 장애 때 터널로 넘어가는 것을 확인한다 |
| 적용 대상 | Cisco Packet Tracer의 `_실습/새봄상사.pkt` (HQ-R1, BR-R1, ISP-R1 2911 라우터, BR-PC1). 10일차까지의 구성이 들어 있다. 격리된 가상 실습망이며 실제 장비와 연결하지 않는다 |
| 소요 시간 | 약 45분 (라이선스와 재시작 7, 인터넷 회선과 /32 경로 10, 터널 8, OSPF 8, 해지와 장애 시험 12) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이 환경에서 패킷트레이서를 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-2.md](lesson-2.md) | LEC-SN-11-002-DO | GRE 터널로 지사 잇기 |
| [lesson-1.md](lesson-1.md) | LEC-SN-11-001-DO | VPN과 터널 |
| [commands.md](commands.md) | LEC-SN-11-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-SN-11-007-MP | 다음 실습. IPSec 암호화와 암호화 전후 비교 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Cisco Packet Tracer | `_실습/새봄상사.pkt` 파일 | 10일차까지의 본사와 지사 구성이 들어 있다 |
| 2 | 라우터 | 2911 (HQ-R1, BR-R1, ISP-R1) | BR-R1과 ISP-R1은 Se0/0/1이 비어 있어야 한다 |
| 3 | 케이블 | Serial DCE | ISP-R1 Se0/0/1과 BR-R1 Se0/0/1을 잇는다. ISP-R1을 먼저 누른다 |
| 4 | PC | BR-PC1 (192.168.20.10), 서버 (192.168.10.98) | 장애 시험에 쓴다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 라이선스를 켜기 전에 `copy running-config startup-config`로 저장한다. 저장하지 않고 `reload`하면 설정이 사라진다.
{% endhint %}

{% hint style="info" %}
NOTE: 출력 예시는 IOS 15 형식이다. 패킷트레이서 버전에 따라 줄 구성이 조금 다를 수 있다. 주소 203.0.113.0/24는 문서용 주소이며 이 실습의 가상 인터넷에서만 쓴다.
{% endhint %}

{% hint style="info" %}
NOTE: OSPF 인증 키는 `<key>` 자리에 실습용 값을 직접 정해 넣는다. 문서와 저장소에 실제 값을 적지 않는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | `_실습/새봄상사.pkt`를 열었다 | 10일차의 ACL 구성이 들어 있다 |
| 2 | HQ-R1과 BR-R1의 설정을 저장했다 | `copy running-config startup-config`가 오류 없이 끝난다 |
| 3 | 1번 노트 설명을 시작할 때 1번 절차(라이선스)를 먼저 건다 | 재시작이 설명 시간에 겹쳐 끝난다 |

## 5. 절차

### A. 보안 라이선스와 재시작 (HQ-R1, BR-R1 모두)

1. (5-A-01) 설정을 저장하고 라이선스를 켠다.

```
copy running-config startup-config
configure terminal
license boot module c2900 technology-package securityk9
```

→ 결과: 약관 질문이 나온다.

2. (5-A-02) 약관 질문에 `yes`를 입력한다. → 결과: 라이선스가 적용 대기 상태가 된다.
3. (5-A-03) 저장하고 재시작한다.

```
end
copy running-config startup-config
reload
```

→ 결과: 라우터가 다시 켜진다. `show version`의 기술 패키지 목록에서 securityk9가 켜져 있다.

### B. 지사의 인터넷 회선, 터널 끝으로 가는 길

1. (5-B-01) Serial DCE 케이블로 ISP-R1을 먼저 눌러 Se0/0/1에, 이어서 BR-R1의 Se0/0/1에 잇는다. → 결과: 두 포트에 링크 표시가 생긴다.
2. (5-B-02) ISP-R1에 입력한다.

```
configure terminal
interface se0/0/1
 ip address 203.0.113.5 255.255.255.252
 clock rate 64000
 no shutdown
 end
```

→ 결과: 오류 없이 `ISP-R1#`로 돌아온다.

3. (5-B-03) BR-R1에 입력한다.

```
configure terminal
interface se0/0/1
 description To ISP
 ip address 203.0.113.6 255.255.255.252
 no shutdown
 exit
ip route 203.0.113.2 255.255.255.255 203.0.113.5
 end
```

→ 결과: Se0/0/1이 up/up이 된다.

4. (5-B-04) HQ-R1에 입력하고, 지사의 공인 주소로 ping을 보낸다.

```
configure terminal
ip route 203.0.113.6 255.255.255.255 203.0.113.1
 end
ping 203.0.113.6
```

→ 결과: Reply가 온다.

### C. 터널 인터페이스

1. (5-C-01) HQ-R1에 입력한다.

```
configure terminal
interface tunnel 0
 description GRE to BR-R1
 ip address 192.168.99.13 255.255.255.252
 tunnel source se0/0/1
 tunnel destination 203.0.113.6
 end
```

→ 결과: 오류 없이 입력된다.

2. (5-C-02) BR-R1에 입력하고 상대 터널 주소로 ping을 보낸다.

```
configure terminal
interface tunnel 0
 description GRE to HQ-R1
 ip address 192.168.99.14 255.255.255.252
 tunnel source se0/0/1
 tunnel destination 203.0.113.2
 end
ping 192.168.99.13
```

→ 결과: Reply가 온다. 터널의 두 끝을 모두 만든 뒤에 터널이 올라온다.

### D. 터널 위로 OSPF

1. (5-D-01) HQ-R1과 BR-R1 모두에 입력한다.

```
configure terminal
router ospf 1
 network 192.168.99.12 0.0.0.3 area 0
 no passive-interface tunnel0
 exit
interface tunnel 0
 ip ospf authentication message-digest
 ip ospf message-digest-key 1 md5 <key>
 end
```

→ 결과: 오류 없이 입력된다. 양쪽 키가 같아야 이웃이 맺어진다.

2. (5-D-02) HQ-R1에만 `ip nat inside`를 더한다.

```
configure terminal
interface tunnel 0
 ip nat inside
 end
```

→ 결과: 오류 없이 입력된다.

3. (5-D-03) `show ip ospf neighbor`를 입력한다. → 결과: Tunnel0 쪽 이웃(192.168.255.2)이 FULL로 더해진다.

### E. 예비 회선 해지와 장애 시험

1. (5-E-01) HQ-R1과 BR-R1 모두 Se0/0/0을 끈다.

```
configure terminal
interface se0/0/0
 description Backup serial (terminated, 11일차)
 shutdown
 end
```

→ 결과: Se0/0/0이 administratively down이 된다.

2. (5-E-02) BR-PC1에서 `ping -t 192.168.10.98`을 걸어 둔다. → 결과: Reply가 계속 온다.
3. (5-E-03) HQ-R1의 Gi0/1을 `shutdown`한다. → 결과: ping이 몇 번 끊긴 뒤 다시 Reply가 온다. 끊긴 ping 개수를 센다.
4. (5-E-04) 경로와 경유지를 확인한다.

| 어디서 | 명령 | 기대하는 결과 |
|---|---|---|
| BR-R1 | `show ip route ospf` | 본사 대역이 `via 192.168.99.13, Tunnel0` |
| BR-PC1 | `tracert 192.168.10.98` | 192.168.20.1, 192.168.99.13, 192.168.10.98 |

→ 결과: tracert에 ISP-R1이 보이지 않는다.

5. (5-E-05) 끊긴 ping 개수를 기록한 뒤 HQ-R1의 Gi0/1을 `no shutdown`한다. → 결과: 본사 대역이 다시 주 회선으로 돌아간다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | HQ-R1에서 `ping 192.168.99.14` | Reply | 응답 수신 |
| 2 | HQ-R1에서 `show ip ospf neighbor` | Tunnel0 쪽 이웃 FULL | 이웃 상태 FULL |
| 3 | 장애 시험 중 BR-PC1의 `ping -t` | 몇 개 빠진 뒤 Reply | 응답 재개 |
| 4 | 장애 중 BR-R1의 `show ip route ospf` | Tunnel0 경유 | `Tunnel0` 포함 |
| 5 | BR-PC1에서 `tracert 192.168.10.98` | ISP-R1 없이 한 칸 | 인터넷 구간이 안 보인다 |

## 7. 복구

1. (7-01) 터널이 꼬이면 터널을 지우고 예비 회선으로 돌아간다. 4일차의 예비 회선으로 돌아가는 것이다.

```
configure terminal
no interface tunnel 0
interface se0/0/0
 no shutdown
 end
```

2. (7-02) 장애 시험 뒤 HQ-R1의 Gi0/1이 `shutdown`으로 남아 있으면 `no shutdown`을 입력한다.
3. (7-03) 다음 실습(LEC-SN-11-007-MP)으로 넘어가기 전에 HQ-R1, BR-R1, ISP-R1을 `copy running-config startup-config`로 저장한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 1~5번을 AMM 형식 MP로 분리. 저장 CAUTION과 OSPF 키 `<key>` 표기 추가. 번호(1~5)는 다른 문서의 참조 때문에 `commands.md`에 유지 |
