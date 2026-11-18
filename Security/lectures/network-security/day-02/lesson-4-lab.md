# 4-1. 새봄상사 본사 라우터·스위치 접근 보안 실습

> 상위: [2일차 주소 설계와 장비 접근 보안](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-02-007-MP |
| 목적 | 패킷트레이서에 본사 토폴로지를 만들고, HQ-R1과 HQ-SW1의 콘솔, VTY, 관리자 모드에 잠금을 걸고, 영업팀 주소를 줘 확인한 뒤 저장한다 |
| 적용 대상 | Cisco Packet Tracer, 2911 라우터 1대, 2960 스위치 1대, PC 2대. 강사와 함께 새봄상사 주소로 진행하는 구간 (16:10~16:50) |
| 소요 시간 | 약 35분 (토폴로지 5, 라우터 12, 스위치 5, PC와 확인 8, 텔넷 5, 저장 2) |
| 확인 상태 | 미검증 (원본 강의 노트와 대본을 정리한 것이며 패킷트레이서에서 실행해 확인하지 않았다. 출력 예시는 IOS 15 형식) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-4.md](lesson-4.md) | LEC-SN-02-004-DO | 시스코 CLI와 장비 접근 보안 (모드, 세 문, secret과 7번 방식) |
| [lesson-3.md](lesson-3.md) | LEC-SN-02-003-DO | 서브네팅과 우리 회사 주소 설계 (새봄상사 설계표) |
| [commands.md](commands.md) | LEC-SN-02-005-REF | 실습 명령어 모음 (1~6번, 자주 막히는 곳) |
| [lesson-4-personal-lab.md](lesson-4-personal-lab.md) | LEC-SN-02-008-MP | 다음 실습. 내 회사 주소로 바꾸고 설정 파일 커밋 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Cisco Packet Tracer | Cisco Networking Academy 로그인 필요 | 교실 PC에 설치되어 있다 |
| 2 | 라우터 | 2911 | 이름 HQ-R1 |
| 3 | 스위치 | 2960 | 이름 HQ-SW1 |
| 4 | PC | 2대 | 이름 Sales-PC1, Sales-PC2 |
| 5 | 케이블 | Copper Straight-Through | |
| 6 | 실습용 비밀번호 | 수업에서 정한 비밀번호 하나 | 문서에서는 `<password>`로 적는다 |

## 3. 안전 사항

{% hint style="info" %}
NOTE: 이 실습은 패킷트레이서 안의 가상 장비에서만 한다. 실제 장비나 교실 네트워크 장비에 이 명령을 입력하지 않는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 비밀번호를 잊으면 패킷트레이서에서는 복구가 번거롭다. 칠판의 실습용 비밀번호를 그대로 쓰고, 잊었다면 장비를 지우고 다시 놓는다.
{% endhint %}

{% hint style="info" %}
NOTE: 구역 B의 `<password>`에는 수업에서 정한 실습용 비밀번호를 넣는다. 실제 장비나 실제 계정의 비밀번호를 쓰지 않는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 저장소 폴더에 `_실습`이 있다 | 없으면 `mkdir 00_작업계획 02_설계 configs _실습`으로 만든다 |
| 2 | 패킷트레이서가 열리고 로그인되어 있다 | 빈 작업 화면이 보인다 |
| 3 | 새봄상사 설계표를 확인한다 | 영업팀 게이트웨이 192.168.10.1, 마스크 255.255.255.224 ([3번 노트](lesson-3.md) 6절) |

## 5. 절차

### A. 토폴로지

1. (5-A-01) 2911 라우터 1대, 2960 스위치 1대, PC 2대를 작업 화면에 놓는다. → 결과: 장비 네 대가 보인다.
2. (5-A-02) Copper Straight-Through 케이블로 PC 두 대를 스위치의 Fa0/1, Fa0/2에 연결한다. → 결과: 선 두 개가 그려진다.
3. (5-A-03) 스위치의 Gi0/1을 라우터의 Gi0/0에 연결한다. → 결과: 선이 하나 더 그려진다.
4. (5-A-04) 장비 표시 이름을 HQ-R1, HQ-SW1, Sales-PC1, Sales-PC2로 바꾼다. → 결과: 바뀐 이름이 화면에 보인다.
5. (5-A-05) File, Save As로 저장소의 `_실습` 폴더에 `새봄상사.pkt`로 저장한다. → 결과: 파일이 생긴다. 함께 하는 실습은 매 회차 이 파일에서 한다.

이 시점에 라우터 쪽 불빛은 빨강이다. 구역 B에서 포트를 켜면 초록이 된다.

### B. 본사 라우터 HQ-R1

`!`로 시작하는 줄은 설명이라 입력하지 않아도 된다. HQ-R1을 눌러 CLI 탭을 연다.

1. (5-B-01) 관리자 모드에서 설정 모드로 들어간다.
   ```
   enable
   configure terminal
   ```
   → 결과: 프롬프트가 `Router(config)#`로 바뀐다. 이름은 다음 단계에서 바꾼다.
2. (5-B-02) 이름을 바꾸고 엉뚱한 이름 조회를 끈다.
   ```
   hostname HQ-R1
   no ip domain-lookup
   ```
   → 결과: 프롬프트가 `HQ-R1(config)#`로 바뀐다.
3. (5-B-03) 관리자 모드 잠금을 건다: `enable secret <password>` → 결과: 오류 없이 다음 줄로 넘어간다.

{% hint style="danger" %}
WARNING: 아래 두 회선(콘솔, VTY)의 `login`을 빼면 비밀번호를 걸어도 잠금이 걸리지 않는다. 콘솔은 비밀번호를 묻지 않고 들어와진다. 두 회선 모두 `login`까지 입력한다.
{% endhint %}

4. (5-B-04) 콘솔 회선에 잠금을 건다.
   ```
   line console 0
    password <password>
    login
    exec-timeout 5 0
    exit
   ```
   → 결과: 프롬프트가 `HQ-R1(config)#`로 돌아온다.
5. (5-B-05) 원격(VTY) 회선에 잠금을 건다.
   ```
   line vty 0 4
    password <password>
    login
    exec-timeout 5 0
    exit
   ```
   → 결과: 프롬프트가 `HQ-R1(config)#`로 돌아온다.
6. (5-B-06) 회선 비밀번호를 가리고 접속 경고문을 건다.
   ```
   service password-encryption
   banner motd # Authorized access only. All access is logged. #
   ```
   → 결과: 오류 없이 다음 줄로 넘어간다.
7. (5-B-07) 영업팀 게이트웨이 주소를 주고 포트를 켠다.
   ```
   interface gi0/0
    description HQ Sales LAN
    ip address 192.168.10.1 255.255.255.224
    no shutdown
    end
   ```
   → 결과: 아래 두 줄이 뜨고 불빛이 초록으로 바뀐다.
   ```
   %LINK-5-CHANGED: Interface GigabitEthernet0/0, changed state to up
   %LINEPROTO-5-UPDOWN: Line protocol on Interface GigabitEthernet0/0, changed state to up
   ```
8. (5-B-08) 포트 상태를 확인한다: `show ip interface brief` → 결과: GigabitEthernet0/0의 Status와 Protocol이 모두 up이다.
   ```
   Interface              IP-Address      OK? Method Status                Protocol
   GigabitEthernet0/0     192.168.10.1    YES manual up                    up
   GigabitEthernet0/1     unassigned      YES unset  administratively down down
   GigabitEthernet0/2     unassigned      YES unset  administratively down down
   ```
9. (5-B-09) 설정을 확인한다: `show running-config` → 결과: 아래 줄들이 보인다.

| 찾을 줄 | 확인할 것 |
|---|---|
| `enable secret 5 $1$...` | enable 비밀번호가 해시로 보인다 |
| `password 7 ...` (line con 0, line vty 0 4 아래) | 회선 비밀번호가 7번 문자열로 보인다 |
| `login`, `exec-timeout 5 0` | 두 회선 모두에 있다 |
| `banner motd ^C...^C` | 배너. 감싼 `#`은 `^C`로 바뀌어 보인다 |
| `ip address 192.168.10.1 255.255.255.224` | 새봄상사 설계표의 게이트웨이와 마스크 |

### C. 스위치 HQ-SW1

스위치의 VTY 회선은 0번부터 15번까지다. 스위치에 관리 주소를 주는 일은 3일차에 관리 VLAN을 만들 때 한다. HQ-SW1을 눌러 CLI 탭을 연다.

1. (5-C-01) 같은 잠금을 건다. `<password>`는 구역 B와 같은 값이다.
   ```
   enable
   configure terminal
   hostname HQ-SW1
   no ip domain-lookup
   enable secret <password>
   line console 0
    password <password>
    login
    exec-timeout 5 0
    exit
   line vty 0 15
    password <password>
    login
    exec-timeout 5 0
    exit
   service password-encryption
   banner motd # Authorized access only. All access is logged. #
   end
   ```
   → 결과: 프롬프트가 `HQ-SW1#`로 바뀐다.
2. (5-C-02) 설정을 저장한다: `copy running-config startup-config` → 결과: `[OK]`가 보인다.

### D. PC 설정과 확인

1. (5-D-01) Sales-PC1을 눌러 Desktop, IP Configuration에서 주소를 입력한다: IP 192.168.10.2, 마스크 255.255.255.224, 기본 게이트웨이 192.168.10.1 → 결과: 입력 칸에 값이 들어간다.
2. (5-D-02) Sales-PC2도 같은 방법으로 입력한다: IP 192.168.10.3, 마스크 255.255.255.224, 기본 게이트웨이 192.168.10.1 → 결과: 입력 칸에 값이 들어간다.
3. (5-D-03) Sales-PC1의 Command Prompt에서 게이트웨이로 ping을 보낸다: `ping 192.168.10.1` → 결과: `Reply from 192.168.10.1: bytes=32 time<1ms TTL=255`이 나온다. 처음 한두 개가 `Request timed out`이어도 나머지가 `Reply`면 정상이다. 상대의 MAC 주소를 알아내는 동안 시간이 걸린 것이다.
4. (5-D-04) 같은 PC에서 Sales-PC2로 ping을 보낸다: `ping 192.168.10.3` → 결과: `Reply`가 나온다.
5. (5-D-05) 다른 대역 실험을 한다. Sales-PC2의 IP 주소만 192.168.10.40(인사팀 대역)으로 바꾼다. → 결과: 입력 칸에 값이 들어간다.
6. (5-D-06) Sales-PC1에서 ping을 보낸다: `ping 192.168.10.40` → 결과: `Reply from 192.168.10.1: Destination host unreachable.`가 나온다. 답한 쪽이 라우터(192.168.10.1)다. `Request timed out`이 섞여 나올 수도 있다.
7. (5-D-07) Sales-PC2를 192.168.10.3으로 되돌린다. → 결과: 입력 칸이 192.168.10.3이다.

### E. 텔넷으로 두드려 보기

{% hint style="danger" %}
WARNING: 허가받지 않은 시스템에 이 절차를 수행하는 것은 불법이다. 격리된 실습망에서만 수행한다. 이 접속은 패킷트레이서 안의 내 라우터(HQ-R1)에만 한다.
{% endhint %}

1. (5-E-01) Sales-PC1의 Command Prompt에서 라우터로 원격 접속한다: `telnet 192.168.10.1` → 결과: 배너가 먼저 보이고 `Password:`를 묻는다.
2. (5-E-02) VTY 비밀번호 `<password>`를 입력한다. → 결과: `HQ-R1>`가 보인다. 입력하는 동안 화면에 아무것도 나오지 않는 것은 정상이다.
3. (5-E-03) `enable`을 입력하고 enable secret `<password>`를 입력한다. → 결과: `HQ-R1#`가 보인다.
4. (5-E-04) `exit`로 나온다. → 결과: 텔넷 접속이 끝난다.

```
Trying 192.168.10.1 ...Open
Authorized access only. All access is logged.

User Access Verification

Password:
HQ-R1>enable
Password:
HQ-R1#exit
```

### F. 저장

1. (5-F-01) HQ-R1에서 설정을 저장한다: `copy running-config startup-config` → 결과: 파일 이름을 묻는 줄이 나온다.
2. (5-F-02) 파일 이름을 묻는 줄에서 Enter만 누른다. → 결과: `Building configuration...`과 `[OK]`가 보인다.
3. (5-F-03) 패킷트레이서에서 Ctrl+S를 누른다. → 결과: `_실습/새봄상사.pkt`가 저장된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | HQ-R1에서 `show ip interface brief` | Gi0/0이 up, up | 두 칸 모두 up |
| 2 | Sales-PC1에서 `ping 192.168.10.1` | Reply | 한두 개 시간 초과 뒤 Reply |
| 3 | Sales-PC1에서 `ping 192.168.10.3` | Reply | 해당 |
| 4 | Sales-PC2를 .40으로 바꾸고 `ping 192.168.10.40` | `Destination host unreachable`, 답한 쪽은 192.168.10.1 | 라우터가 답한다 |
| 5 | Sales-PC1에서 `telnet 192.168.10.1` | 배너, VTY 비밀번호, enable secret 순서로 묻는다 | `HQ-R1#`에 도달 |
| 6 | HQ-R1에서 `show running-config` | `enable secret 5`, `password 7` | 평문 비밀번호가 보이지 않는다 |

## 7. 복구

1. (7-01) 저장하기 전에 꼬였다면 HQ-R1에서 `reload`를 입력하고 저장 여부를 묻는 줄에 `no`를 입력한다. → 결과: 마지막으로 저장한 상태로 돌아온다. 이어서 확인 줄에서 Enter를 누른다.
2. (7-02) 첫 설정이라 되돌릴 저장본이 없거나 비밀번호를 잊었다면 장비를 지우고 다시 놓는다.
3. (7-03) Sales-PC2의 주소를 192.168.10.3으로 되돌린다(5-D-07).
4. (7-04) `_실습/새봄상사.pkt`는 새봄상사 그대로 남겨 3일차 함께 하는 실습에 쓴다.

## 8. 자주 막히는 곳

| 보이는 것 | 원인 | 해결 |
|---|---|---|
| `% Invalid input detected at '^' marker` | 철자가 틀렸거나 모드가 다르다 | `^`가 가리키는 곳 근처를 고친다. 프롬프트로 지금 모드를 본다 |
| `% Incomplete command` | 명령이 덜 끝났다 | 끝에 `?`를 입력해 다음에 올 것을 본다 |
| `Translating "..."`에서 멈춘다 | 틀린 명령을 도메인 이름으로 알고 찾는 중이다 | Ctrl+Shift+6으로 끊고 `no ip domain-lookup` |
| CLI가 갑자기 처음 화면으로 돌아갔다 | `exec-timeout` 5분이 지나 연결이 끊겼다 | Enter를 누르고 비밀번호를 다시 입력한다. 잠금이 작동한 것이다 |
| `show ip interface brief`에서 administratively down | `no shutdown`을 빼먹었다 | 인터페이스에 들어가 `no shutdown` |
| `show ip interface brief`에서 up, down | 선이 빠졌거나 상대 쪽 포트가 꺼져 있다 | 연결과 상대 장비를 확인 |
| PC에서 게이트웨이 ping이 안 된다 | PC의 마스크나 게이트웨이가 틀렸다 | 설계표와 PC 설정을 한 칸씩 비교 |
| 텔넷에서 `Password required, but none set` | VTY에 비밀번호를 걸지 않았다 | 5-B-05를 다시 입력한다 |
| 텔넷에서 enable 뒤 `% No password set` | enable secret을 빠뜨렸다 | `enable secret <password>` |
| 텔넷이 `Connection timed out` | 주소가 틀렸거나 라우터 포트가 꺼져 있다 | 먼저 게이트웨이로 ping이 되는지 본다 |
| 다시 열었더니 설정이 사라졌다 | 장비 설정이나 .pkt를 저장하지 않았다 | `copy running-config startup-config`와 Ctrl+S |

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 1~6번과 `lesson-4.md`의 실습 부분을 AMM 형식 MP로 분리. 비밀번호를 `<password>`로 통일, 텔넷 단계 앞에 WARNING 추가 |
