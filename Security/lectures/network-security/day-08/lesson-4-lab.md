# 4-1. 가짜 DHCP 서버 시연과 스누핑·HSRP 인증 실습

> 상위: [8일차 DHCP와 게이트웨이 이중화](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-08-009-MP |
| 목적 | 패킷트레이서의 가상 실습망에서 가짜 DHCP 서버가 PC의 게이트웨이를 바꾸는 것을 보고, DHCP 스누핑으로 막은 뒤, HSRP 인증으로 게이트웨이 이중화를 지킨다 |
| 적용 대상 | 허가받은 격리 실습 환경. Cisco Packet Tracer의 `_실습/새봄상사.pkt` (2911 라우터, 3560 스위치, 2960 스위치 세 대). 3-1 실습을 마친 상태. 실제 네트워크에 연결하지 않는다 |
| 소요 시간 | 약 25분 (가짜 서버 시연 7분, 스누핑 12분, HSRP 인증 6분) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이 환경에서 패킷트레이서를 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-4.md](lesson-4.md) | LEC-SN-08-004-DO | DHCP와 HSRP를 지키기 |
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-SN-08-008-MP | L3 스위치 설치와 HSRP 장애 시험 (HSRP 구성의 출처) |
| [commands.md](commands.md) | LEC-SN-08-005-REF | 실습 명령어 모음 (8~10번, 자주 막히는 곳 포함) |
| [lesson-4-personal-lab.md](lesson-4-personal-lab.md) | LEC-SN-08-010-MP | 다음 실습. 내 회사 파일 적용과 기록 커밋 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Cisco Packet Tracer | `_실습/새봄상사.pkt` 파일 | 3-1 실습까지의 구성이 들어 있다 |
| 2 | 스위치 | HQ-SW1, HQ-SW2, BR-SW1 (2960) | 스누핑을 건다 |
| 3 | 라우터와 L3 스위치 | HQ-R1, HQ-DSW1 | HSRP 인증을 건다 |
| 4 | 서버 | Server-PT 한 대 (FAKE-DHCP) | 구역 A의 강사 시연에서만 쓴다 |
| 5 | PC | Sales-PC1 | 주소를 다시 받는다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 허가받지 않은 시스템에 이 절차를 수행하는 것은 불법이다. 격리된 실습망에서만 수행한다. 가짜 DHCP 서버 시연은 패킷트레이서의 가상 실습망 안에서만 하고, 실제 회사망이나 실습 PC의 네트워크에 DHCP 서버를 꽂지 않는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 구역 A의 가짜 서버는 강사 파일에서만 만든다. 학생 파일과 `configs/network.pkt`에는 가짜 서버를 두지 않는다. 시연이 끝나면 DHCP 서비스를 끄고 서버를 지운다.
{% endhint %}

{% hint style="warning" %}
CAUTION: HSRP 인증은 두 장비에 같은 순간에 건다. 한쪽에만 걸면 두 장비가 서로의 알림을 무시하고 둘 다 Active가 되어 가상 주소가 갈라진다.
{% endhint %}

{% hint style="info" %}
NOTE: 인증 키 자리는 `<password>`다. 실습용 값을 직접 정해 넣고 문서에 적지 않는다. `standby ... authentication md5 key-string`이 거절되면 평문 인증(`standby 10 authentication <password>`)으로 바꾼다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 3-1 실습을 마쳤다 | HQ-DSW1이 네 그룹 Active다 |
| 2 | 본사 PC와 지사 PC가 DHCP로 주소를 받았다 | HQ-R1의 `show ip dhcp binding`에 일곱 줄이 있다 |
| 3 | 여섯 장비의 설정을 저장했다 | 각 장비에서 `copy running-config startup-config` |

## 5. 절차

### A. 가짜 DHCP 서버 시연 (강사 파일에서만)

1. (5-A-01) Server-PT를 놓고 이름을 FAKE-DHCP로 바꾼다.
2. (5-A-02) FAKE-DHCP를 HQ-SW1의 Fa0/3(영업팀 VLAN)에 잇는다.
3. (5-A-03) FAKE-DHCP의 Desktop, IP Configuration에서 고정 주소를 넣는다: IP 192.168.10.25, 마스크 255.255.255.224, 게이트웨이 192.168.10.25.
4. (5-A-04) Services, DHCP에서 Service를 `On`으로 두고 값을 넣은 뒤 `Save`를 누른다: Default Gateway 192.168.10.25, Start IP Address 192.168.10.21, Subnet Mask 255.255.255.224.
5. (5-A-05) Sales-PC1의 IP Configuration을 `Static`으로 바꿨다가 `DHCP`로 바꾼다. 게이트웨이가 192.168.10.25가 될 때까지 몇 번 반복한다. → 결과: 게이트웨이 칸에 192.168.10.25가 보인다. 진짜 서버와 가짜 서버 중 먼저 답한 쪽의 설정을 받은 것이다.
6. (5-A-06) Sales-PC1에서 `tracert 192.168.20.1`을 입력한다. → 결과: 첫 줄부터 답이 없다. 패킷이 가짜 서버로 가서 멈춘다.

### B. DHCP 스누핑

1. (5-B-01) HQ-SW1에서 스누핑을 켜고 서버 쪽 포트를 믿는 포트로 정한다. → 결과: `show ip dhcp snooping`에 Gi0/1이 Trusted yes로 보인다.

```
configure terminal
ip dhcp snooping
ip dhcp snooping vlan 10,20,30,40
no ip dhcp snooping information option
interface gi0/1
 ip dhcp snooping trust
 end
show ip dhcp snooping
```

2. (5-B-02) HQ-SW2에 같은 설정을 넣는다. 믿는 포트는 Gi0/1(HQ-SW1 쪽)뿐이다.
3. (5-B-03) BR-SW1에 설정을 넣는다. VLAN은 10 하나다.

```
configure terminal
ip dhcp snooping
ip dhcp snooping vlan 10
no ip dhcp snooping information option
interface gi0/1
 ip dhcp snooping trust
 end
```

4. (5-B-04) 강사가 Sales-PC1을 다시 DHCP로 받는다. 몇 번을 받아도 확인한다. → 결과: 게이트웨이가 192.168.10.1이다.
5. (5-B-05) 강사가 FAKE-DHCP의 DHCP 서비스를 끄고 서버를 지운다. → 결과: 토폴로지에 가짜 서버가 없다.
6. (5-B-06) 학생이 모든 PC(지사 PC 포함)를 다시 DHCP로 받는다. → 결과: 모든 PC가 주소를 받는다.

### C. HSRP 인증

1. (5-C-01) HQ-DSW1에 인증을 건다. → 결과: 오류 없이 프롬프트가 돌아온다.

```
configure terminal
interface vlan 10
 standby 10 authentication md5 key-string <password>
interface vlan 20
 standby 20 authentication md5 key-string <password>
interface vlan 30
 standby 30 authentication md5 key-string <password>
interface vlan 40
 standby 40 authentication md5 key-string <password>
 end
```

2. (5-C-02) HQ-DSW1에만 건 상태에서 HQ-R1의 `show standby brief`를 입력한다. → 결과: 두 장비가 모두 Active다.
3. (5-C-03) HQ-R1에도 같은 줄을 건다. 서브인터페이스는 `interface gi0/0.10`, `.20`, `.30`, `.40`이다.
4. (5-C-04) 양쪽에서 `show standby brief`를 입력한다. → 결과: Active와 Standby가 하나씩이다.
5. (5-C-05) 여섯 장비(HQ-R1, BR-R1, HQ-DSW1, HQ-SW1, HQ-SW2, BR-SW1)에서 저장한다: `copy running-config startup-config`

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 스누핑 전 Sales-PC1의 게이트웨이 | 192.168.10.25 | 가짜에게 받았다 |
| 2 | 스누핑 뒤 Sales-PC1을 여러 번 다시 받기 | 192.168.10.1 | 매번 진짜 게이트웨이 |
| 3 | HQ-SW1에서 `show ip dhcp snooping` | Gi0/1 Trusted yes | 믿는 포트가 하나 |
| 4 | 본사와 지사의 모든 PC를 DHCP로 다시 받기 | 주소를 받는다 | 모두 성공 |
| 5 | 인증 뒤 양쪽 `show standby brief` | Active와 Standby 하나씩 | 둘 다 Active가 아니다 |

## 탐지·방어

| 항목 | 내용 |
|---|---|
| 원인 | DHCP 클라이언트는 먼저 답한 서버를 믿는다. HSRP 장비는 우선순위가 높다고 알리는 장비에게 Active를 넘긴다 |
| 완화 | 모든 포트를 믿지 않는 것에서 시작하고 진짜 서버 쪽 포트만 `ip dhcp snooping trust`로 연다. HSRP는 그룹마다 인증을 건다. 믿는 포트는 스위치마다 하나씩만 둔다 |
| 흔적 | HQ-R1의 `show ip dhcp binding`에 우리가 준 주소가 없는 PC. 스누핑을 켰다면 스위치 로그에 버려진 답이 들어온 포트. `show ip dhcp snooping binding`의 포트, MAC, 주소 표 |
| 남는 위험 | 인증은 진짜 장비가 가짜에게 Active를 내주는 것만 막는다. 주소 고갈 공격은 `ip dhcp snooping limit rate`(더 해 볼 것)와 12일차 포트 보안으로 다룬다 |

{% hint style="info" %}
NOTE: 이 절은 원본에 없던 표 형식 정리이며 내용은 원본 4번 노트에서 가져왔다.
{% endhint %}

## 7. 복구

1. (7-01) 스누핑을 켠 뒤 주소를 못 받으면 해당 스위치에서 `no ip dhcp snooping`으로 끄고 믿는 포트부터 다시 본다. 옵션 82 줄(`no ip dhcp snooping information option`)이 빠졌는지도 본다.
2. (7-02) HSRP 인증 뒤 둘 다 Active이면 두 장비의 키 문자열과 트렁크(`show interfaces trunk`)를 비교한다. 급하면 양쪽에서 `no standby <그룹 번호> authentication md5 key-string <password>`로 되돌린다.
3. (7-03) 가짜 서버가 남아 있으면 Services에서 DHCP를 `Off`로 하고 서버를 지운다.
4. (7-04) 실습을 처음 상태로 돌리려면 `_실습/새봄상사.pkt`를 저장하지 않고 닫고 다시 연다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 8~10번을 AMM 형식 MP로 분리. 격리 실습 환경 WARNING과 탐지·방어 절 추가. 인증 키 자리 `<password>`로 표기. 번호(8~10)는 다른 문서의 참조 때문에 `commands.md`에 유지 |
