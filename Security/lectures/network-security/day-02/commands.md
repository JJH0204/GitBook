# 0. 실습 명령어 모음

> 상위: [2일차 주소 설계와 장비 접근 보안](README.md)

수업 흐름 순서대로 적은 대본입니다. Git 명령은 Git Bash에서, 장비 명령은 패킷트레이서의 CLI 탭에서, PC 명령은 패킷트레이서 PC의 Command Prompt에서 칩니다. 장비 화면의 출력 예시는 IOS 15 형식을 따라 적었고, 패킷트레이서 버전에 따라 조금 다를 수 있습니다.

| 단계 | 내용 | 언제 | 노트 |
|------|------|------|------|
| 0 | 작업 계획서 | 14:00 (30분) | README |
| 1 | 패킷트레이서 토폴로지 | 16:10 함께 (5분) | 4 |
| 2 | 본사 라우터 HQ-R1 | 함께 (12분) | 4 |
| 3 | 스위치 HQ-SW1 | 함께 (5분) | 4 |
| 4 | PC 설정과 확인, 다른 대역 실험 | 함께 (8분) | 4 |
| 5 | 텔넷으로 두드려 보기 | 함께 (5분) | 4 |
| 6 | 저장 | 함께 (2분) | 4 |
| 7 | 내 회사 주소 설계표 | 17:00 개인 (12분) | 3 |
| 8 | 내 주소로 바꾸고 확인 | 개인 (12분) | 4 |
| 9 | 저장하고 설정 텍스트 뽑기 | 개인 (10분) | 4 |
| 10 | 결과 기록과 커밋 | 개인 (10분) | |

1~6번은 `_실습/새봄상사.pkt` 에서 새봄상사의 주소로 강사와 함께 칩니다. 7~10번은 개인 실습에서 그 파일을 `configs/network.pkt` 로 따로 저장한 뒤 내 회사의 주소로 바꿉니다. 3일차부터는 두 파일을 각각 이어 씁니다.

## 0. 작업 계획서 (14:00~14:30)

```bash
cd ~/my-netsec-project
git pull                                   # 다른 곳에서 고친 것이 있으면 받아 온다
```

```
Already up to date.
```

1일차와 다른 PC라면 [1일차 대본](../day-01/commands.md)의 1번(Git 설정)과 3번(clone)을 먼저 합니다.

오늘 쓸 폴더를 한 번에 만듭니다.

```bash
mkdir 00_작업계획 02_설계 configs _실습
```

VS Code에서 `00_작업계획/02일차.md` 를 만들고 [1일차 4번 노트](../day-01/lesson-4.md) 10번 절의 양식을 붙여 넣습니다. [README](README.md)의 새봄상사 예시를 보며 1~5번 칸을 채웁니다. 1일차 계획서를 고쳤다면 함께 커밋합니다.

```bash
git add .
git status                                 # 00_작업계획/02일차.md 가 초록 글씨로 보인다
git commit -m "2일차: 작업 계획서"
git push
```

`02_설계` 와 `configs` 는 아직 비어 있어서 커밋되지 않습니다. 1일차에 본 빈 폴더 이야기입니다.

## 1. 패킷트레이서 토폴로지

1. 2911 라우터 1대, 2960 스위치 1대, PC 2대를 놓습니다.
2. Copper Straight-Through 케이블로 PC 두 대를 스위치의 Fa0/1, Fa0/2에, 스위치의 Gi0/1을 라우터의 Gi0/0에 연결합니다.
3. 장비 표시 이름을 HQ-R1, HQ-SW1, Sales-PC1, Sales-PC2로 바꿉니다.
4. File, Save As로 저장소의 `_실습` 폴더에 `새봄상사.pkt` 로 저장합니다. 함께 하는 실습은 매 회차 이 파일에서 합니다.

이 시점에 라우터 쪽 불빛은 빨강입니다. 2번에서 포트를 켜면 초록이 됩니다.

## 2. 본사 라우터 HQ-R1

`<실습용 비밀번호>` 는 수업에서 정한 비밀번호 하나로 바꿔 칩니다. `!` 로 시작하는 줄은 설명이라 치지 않아도 됩니다.

```
enable
configure terminal
hostname HQ-R1
no ip domain-lookup
enable secret <실습용 비밀번호>
!
! 콘솔: 직접 꽂고 들어오는 문
line console 0
 password <실습용 비밀번호>
 login
 exec-timeout 5 0
 exit
!
! VTY: 원격으로 들어오는 문
line vty 0 4
 password <실습용 비밀번호>
 login
 exec-timeout 5 0
 exit
!
service password-encryption
banner motd # Authorized access only. All access is logged. #
!
interface gi0/0
 description HQ Sales LAN
 ip address 192.168.10.1 255.255.255.224
 no shutdown
 end
```

`no shutdown` 을 치면 아래와 같은 알림이 뜨고 불빛이 초록으로 바뀝니다.

```
%LINK-5-CHANGED: Interface GigabitEthernet0/0, changed state to up
%LINEPROTO-5-UPDOWN: Line protocol on Interface GigabitEthernet0/0, changed state to up
```

확인합니다.

```
show ip interface brief
show running-config
```

```
Interface              IP-Address      OK? Method Status                Protocol
GigabitEthernet0/0     192.168.10.1    YES manual up                    up
GigabitEthernet0/1     unassigned      YES unset  administratively down down
GigabitEthernet0/2     unassigned      YES unset  administratively down down
```

GigabitEthernet0/0의 Status와 Protocol이 모두 up이면 됩니다. `show running-config` 에서는 아래 줄들을 찾아봅니다.

| 찾을 줄 | 확인할 것 |
|---------|-----------|
| `enable secret 5 $1$...` | enable 비밀번호가 해시로 보인다 |
| `password 7 ...` (line con 0, line vty 0 4 아래) | 회선 비밀번호가 7번 문자열로 보인다 |
| `login`, `exec-timeout 5 0` | 두 회선 모두에 있다 |
| `banner motd ^C...^C` | 배너. 감싼 `#` 은 `^C` 로 바뀌어 보인다 |
| `ip address 192.168.10.1 255.255.255.224` | 새봄상사 설계표의 게이트웨이와 마스크 |

## 3. 스위치 HQ-SW1

라우터와 같은 잠금을 겁니다. 스위치의 VTY 회선은 0번부터 15번까지입니다. 스위치에 관리 주소를 주는 일은 3일차에 관리 VLAN을 만들 때 합니다.

```
enable
configure terminal
hostname HQ-SW1
no ip domain-lookup
enable secret <실습용 비밀번호>
line console 0
 password <실습용 비밀번호>
 login
 exec-timeout 5 0
 exit
line vty 0 15
 password <실습용 비밀번호>
 login
 exec-timeout 5 0
 exit
service password-encryption
banner motd # Authorized access only. All access is logged. #
end
copy running-config startup-config
```

## 4. PC 설정과 확인

PC를 누르고 Desktop, IP Configuration에서 설정합니다.

| PC | IP 주소 | 서브넷 마스크 | 기본 게이트웨이 |
|----|---------|---------------|-----------------|
| Sales-PC1 | 192.168.10.2 | 255.255.255.224 | 192.168.10.1 |
| Sales-PC2 | 192.168.10.3 | 255.255.255.224 | 192.168.10.1 |

Sales-PC1의 Command Prompt에서 칩니다.

```
ping 192.168.10.1
ping 192.168.10.3
```

```
Pinging 192.168.10.1 with 32 bytes of data:

Request timed out.
Reply from 192.168.10.1: bytes=32 time<1ms TTL=255
Reply from 192.168.10.1: bytes=32 time<1ms TTL=255
Reply from 192.168.10.1: bytes=32 time<1ms TTL=255
```

처음 한두 개가 `Request timed out` 이어도 나머지가 `Reply` 면 정상입니다. 상대의 MAC 주소를 알아내는 동안 시간이 걸린 것입니다.

이어서 다른 대역 실험을 합니다. Sales-PC2의 IP 주소만 192.168.10.40(인사팀 대역)으로 바꾸고 Sales-PC1에서 다시 칩니다.

```
ping 192.168.10.40
```

```
Reply from 192.168.10.1: Destination host unreachable.
```

같은 스위치에 꽂혀 있어도 통하지 않습니다. 답한 쪽이 라우터(192.168.10.1)입니다. `Request timed out` 이 섞여 나올 수도 있습니다. 확인한 뒤 Sales-PC2를 192.168.10.3으로 되돌립니다.

## 5. 텔넷으로 두드려 보기

Sales-PC1의 Command Prompt에서 라우터에 원격 접속합니다.

```
telnet 192.168.10.1
```

```
Trying 192.168.10.1 ...Open
Authorized access only. All access is logged.

User Access Verification

Password:
HQ-R1>enable
Password:
HQ-R1#exit
```

VTY 비밀번호, enable secret을 차례로 칩니다. 비밀번호를 칠 때 화면에 아무것도 나오지 않는 것은 정상입니다. 관리자 모드(`#`)까지 들어가면 `exit` 로 나옵니다.

## 6. 저장

HQ-R1에서 칩니다.

```
copy running-config startup-config
```

```
Destination filename [startup-config]?
Building configuration...
[OK]
```

파일 이름을 묻는 줄에서는 Enter만 누릅니다. 패킷트레이서도 Ctrl+S로 저장합니다. 함께 하는 실습은 여기까지입니다.

## 7. 내 회사 주소 설계표 (개인 실습)

VS Code에서 `02_설계/IP_설계표.md` 를 만들고 [3번 노트](lesson-3.md) 8번 절의 양식을 채웁니다. 8번 단계의 주소는 모두 이 표에서 가져옵니다.

## 8. 내 주소로 바꾸고 확인

먼저 File, Save As로 `configs/network.pkt` 로 따로 저장합니다. 지금부터 바꾸는 것은 내 회사 파일이고, `_실습/새봄상사.pkt` 는 새봄상사 그대로 남아 3일차의 함께 하는 실습에 쓰입니다.

이제 HQ-R1의 CLI 탭을 열면 콘솔 비밀번호부터 묻습니다. 2번에서 건 잠금이 작동하는 것입니다. 콘솔 비밀번호, enable secret을 차례로 치고 들어갑니다.

```
User Access Verification

Password:
HQ-R1>enable
Password:
HQ-R1#
```

영업팀 게이트웨이 주소를 내 설계표의 값으로 바꿉니다. `ip address` 를 다시 치면 이전 주소를 덮어씁니다.

```
configure terminal
interface gi0/0
 ip address <내 영업팀 게이트웨이> <내 마스크>
 end
show ip interface brief
```

PC 두 대의 주소도 바꿉니다.

| PC | IP 주소 | 서브넷 마스크 | 기본 게이트웨이 |
|----|---------|---------------|-----------------|
| Sales-PC1 | 내 영업팀의 둘째 주소 | 내 마스크 | 내 영업팀 게이트웨이 |
| Sales-PC2 | 내 영업팀의 셋째 주소 | 내 마스크 | 내 영업팀 게이트웨이 |

4번과 5번의 확인을 내 주소로 다시 합니다.

```
ping <내 영업팀 게이트웨이>
ping <Sales-PC2 의 주소>
telnet <내 영업팀 게이트웨이>
```

작업 계획서 4번 칸의 확인 방법을 하나씩 해 보고, 결과를 6번 칸에 적어 둡니다.

## 9. 저장하고 설정 텍스트 뽑기

HQ-R1에서 칩니다.

```
copy running-config startup-config
terminal length 0
show running-config
```

`terminal length 0` 은 `--More--` 에서 멈추지 않고 끝까지 출력하라는 명령입니다.

1. CLI 탭 아래의 Copy 버튼을 누릅니다.
2. VS Code에서 `configs/HQ-R1.txt` 를 만들고 붙여 넣은 뒤 `Building configuration...` 위의 줄과 끝의 프롬프트를 지우고 저장합니다.
3. 패킷트레이서도 Ctrl+S로 저장합니다.

## 10. 결과 기록과 커밋

`00_작업계획/02일차.md` 의 6번 결과 칸을 채웁니다. `README.md` 의 진행 현황 표에 한 줄을 더합니다.

```markdown
| 2 | 주소 설계표, 본사 라우터 접근 보안 | [작업 계획서](00_작업계획/02일차.md), [IP 설계표](02_설계/IP_설계표.md), [HQ-R1 설정](configs/HQ-R1.txt) |
```

```bash
git status
```

```
Changes not staged for commit:
	modified:   00_작업계획/02일차.md
	modified:   README.md

Untracked files:
	02_설계/
	_실습/
	configs/
```

```bash
git add .
git commit -m "2일차: 주소 설계표, 본사 라우터 접근 보안 설정"
git push
git log --oneline                          # 맨 위 두 줄이 오늘의 계획과 결과
```

교실 PC를 같이 쓴다면 [1일차 대본](../day-01/commands.md) 7번처럼 자격 증명을 지우고 갑니다.

## 자주 막히는 곳

| 보이는 것 | 원인 | 해결 |
|-----------|------|------|
| `% Invalid input detected at '^' marker` | 철자가 틀렸거나 모드가 다르다 | `^` 가 가리키는 곳 근처를 고친다. 프롬프트로 지금 모드를 본다 |
| `% Incomplete command` | 명령이 덜 끝났다 | 끝에 `?` 를 쳐서 다음에 올 것을 본다 |
| `Translating "..."` 에서 멈춘다 | 틀린 명령을 도메인 이름으로 알고 찾는 중이다 | Ctrl+Shift+6으로 끊고 `no ip domain-lookup` |
| CLI가 갑자기 처음 화면으로 돌아갔다 | `exec-timeout` 5분이 지나 연결이 끊겼다 | Enter를 누르고 비밀번호를 다시 친다. 잠금이 작동한 것이다 |
| `show ip interface brief` 에서 administratively down | `no shutdown` 을 빼먹었다 | 인터페이스에 들어가 `no shutdown` |
| `show ip interface brief` 에서 up, down | 선이 빠졌거나 상대 쪽 포트가 꺼져 있다 | 연결과 상대 장비를 확인 |
| PC에서 게이트웨이 ping이 안 된다 | PC의 마스크나 게이트웨이가 틀렸다 | 설계표와 PC 설정을 한 칸씩 비교 |
| 8번 뒤에 ping이 안 된다 | 라우터와 PC 중 한쪽만 내 주소로 바꿨다 | 라우터 Gi0/0과 두 PC가 모두 같은 대역인지 본다 |
| 텔넷에서 `Password required, but none set` | VTY에 비밀번호를 걸지 않았다 | 2번의 `line vty 0 4` 부분을 다시 친다 |
| 텔넷에서 enable 뒤 `% No password set` | enable secret을 빠뜨렸다 | `enable secret <실습용 비밀번호>` |
| 텔넷이 `Connection timed out` | 주소가 틀렸거나 라우터 포트가 꺼져 있다 | 먼저 게이트웨이로 ping이 되는지 본다 |
| 비밀번호가 기억나지 않는다 | 패킷트레이서에서는 복구가 번거롭다 | 장비를 지우고 다시 놓는 편이 빠르다 |
| 다시 열었더니 설정이 사라졌다 | 장비 설정이나 .pkt를 저장하지 않았다 | `copy running-config startup-config` 와 Ctrl+S |
| 저장소에 network.pkt가 없다 | 다른 폴더에 저장했다 | Save As로 `configs` 폴더에 다시 저장 |
