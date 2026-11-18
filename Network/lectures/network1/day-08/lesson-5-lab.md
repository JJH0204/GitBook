# 무선랜과 IPv6 맛보기 실습

> 상위: [8일차 · 네트워크 장비에서의 서버 설정](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N1-08-006-MP |
| 목적 | AP를 VLAN 10 액세스 포트에 연결해 무선 노트북이 VLAN 10 주소를 받는 것을 확인하고, IPv6가 스위치 설정 변경 없이 동작함을 확인한다 |
| 적용 대상 | Cisco Packet Tracer, `8일차_서버.pkt`(7일차 회사망 + Server0), AccessPoint-PT, 노트북 모듈 WPC300N |
| 소요 시간 | 약 15분 (선택 실습) |
| 확인 상태 | 미검증 (원본 강의 노트를 옮긴 것이며 Packet Tracer에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-5.md](lesson-5.md) | LEC-N1-08-005-DO | 5. (맛보기) 무선랜과 IPv6 |
| [lesson-6.md](lesson-6.md) | LEC-N1-08-007-MP | 6. 서버 설정 실습 |
| [commands.md](commands.md) | LEC-N1-08-010-REF | 0. 8일차 실습 명령어 (STEP 7) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Packet Tracer | 7일차와 같은 버전 | AP 설정 화면은 버전마다 조금 다르다 |
| 2 | `8일차_서버.pkt` | lesson-6의 STEP 1~4가 끝난 상태 | SW2 Fa0/3이 비어 있어야 한다 |
| 3 | AccessPoint-PT | 1대 | |
| 4 | 노트북 | 1대(Laptop 2) | 무선 모듈 WPC300N으로 교체 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 노트북의 모듈은 전원을 끈 상태에서만 교체한다. 전원이 켜진 상태에서는 모듈을 끌어다 놓을 수 없다.
{% endhint %}

{% hint style="info" %}
NOTE: 이 실습은 선택이다. Wi-Fi 비밀번호는 문서용 예제 값 `example-password`를 쓴다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | `8일차_서버.pkt`를 연다 | R1, SW1, SW2, PC 4대, Server0이 보인다 |
| 2 | 라우터 또는 서버 DHCP가 동작 중인지 확인한다 | PC가 `192.168.10.x`/`192.168.20.x`를 받는다 |
| 3 | Server0의 DNS에 `www.student.local`이 있는지 확인한다 | lesson-6 구역 D를 마친 상태다 |

## 5. 절차

### A. 무선 노트북을 VLAN 10에 붙이기

1. (5-A-01) SW2 CLI에서 `configure terminal`을 입력한다. → 결과: `SW2(config)#` 프롬프트가 나온다.
2. (5-A-02) `interface fa0/3`, `switchport mode access`, `switchport access vlan 10`, `spanning-tree portfast`를 차례로 입력하고 `end`를 입력한다. → 결과: `SW2#` 프롬프트로 돌아온다.
3. (5-A-03) AccessPoint-PT를 배치하고 SW2 Fa0/3에 다이렉트 케이블로 연결한다. → 결과: 링크 점이 초록색이 된다.
4. (5-A-04) AP의 `Config > Port 1`에서 SSID `KoreaIT`, 인증 `WPA2-PSK`, Pass Phrase `example-password`, Encryption `AES`를 입력한다. → 결과: 설정이 저장된다.
5. (5-A-05) 노트북(Laptop 2)의 `Physical` 탭에서 전원을 끈다. → 결과: 전원 버튼이 꺼진다.
6. (5-A-06) 유선 모듈을 빼고 `WPC300N`을 넣는다.
7. (5-A-07) 전원을 켠다. → 결과: 노트북이 부팅된다.
8. (5-A-08) 노트북 `Config > Wireless0`에서 같은 SSID, `WPA2-PSK`, `example-password`를 입력하고 IP를 `DHCP`로 둔다. → 결과: AP와 무선 연결선이 나타난다.
9. (5-A-09) `Desktop > Command Prompt`에서 `ipconfig`를 입력한다. → 결과: `192.168.10.x` 주소가 보인다(R1의 VLAN10 풀 또는 서버의 VLAN10 풀에서 받은 주소).
10. (5-A-10) `ping www.student.local`을 입력한다. → 결과: 응답이 온다.

{% hint style="info" %}
NOTE: 무선인데 VLAN 10 주소를 받는 이유는 AP가 꽂힌 포트가 VLAN 10이기 때문이다. AP는 전파로 된 액세스 포트다.
{% endhint %}

### B. 스위치는 IPv6를 신경 쓰지 않는다

1. (5-B-01) PC0의 `Desktop > IP Configuration`에서 IPv6 수동 주소 `2001:db8:10::1`, 접두사 `64`를 입력한다. → 결과: 주소가 저장된다.
2. (5-B-02) PC2에 IPv6 수동 주소 `2001:db8:10::2`, 접두사 `64`를 입력한다.
3. (5-B-03) PC0의 `Command Prompt`에서 `ping 2001:db8:10::2`를 입력한다. → 결과: 응답이 온다. 스위치 설정은 바꾸지 않았다.

### C. 라우터를 넘는 IPv6 (여유가 있을 때)

1. (5-C-01) R1 CLI에서 `configure terminal`을 입력한다.
2. (5-C-02) `ipv6 unicast-routing`을 입력한다. → 결과: 오류 없이 끝난다.
3. (5-C-03) `interface g0/0.10`, `ipv6 address 2001:db8:10::254/64`를 입력한다.
4. (5-C-04) `interface g0/0.20`, `ipv6 address 2001:db8:20::254/64`를 입력하고 `end`를 입력한다.
5. (5-C-05) `show ipv6 interface brief`를 입력한다. → 결과: 두 서브인터페이스에 IPv6 주소가 보인다.
6. (5-C-06) PC1에 IPv6 `2001:db8:20::1/64`, IPv6 게이트웨이 `2001:db8:20::254`를 입력한다. PC0의 IPv6 게이트웨이에는 `2001:db8:10::254`를 입력한다.
7. (5-C-07) PC0에서 `ping 2001:db8:20::1`을 입력한다. → 결과: 응답이 온다(VLAN을 넘는 IPv6).

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 노트북 `ipconfig` | VLAN 10 대역 주소 | `192.168.10.x` |
| 2 | 노트북 `ping www.student.local` | 응답 | 이름이 풀리고 응답이 온다 |
| 3 | PC0에서 `ping 2001:db8:10::2` | 응답 | 스위치 변경 없이 성공 |
| 4 | PC0에서 `ping 2001:db8:20::1` (구역 C) | 응답 | `ipv6 unicast-routing`과 서브인터페이스 주소 적용 후 성공 |

## 7. 복구

1. (7-01) 무선 구성을 지우려면 AP와 노트북을 삭제한다.
2. (7-02) SW2 Fa0/3 설정을 지우려면 `interface fa0/3`에서 `no switchport access vlan`, `no spanning-tree portfast`를 입력한다.
3. (7-03) IPv6 설정을 지우려면 PC의 IPv6 주소를 비우고 R1에서 `no ipv6 unicast-routing`을 입력한다.
4. (7-04) 파일을 저장하지 않고 닫으면 원본 `8일차_서버.pkt`가 그대로 남는다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 5. 무선랜과 IPv6의 "맛보기 실습" 절과 대본 STEP 7을 MP로 분리 |
