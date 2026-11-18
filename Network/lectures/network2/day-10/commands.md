# 0. 10일차 실습 명령어 — 수업 흐름 그대로 (이어치기 대본)

> 상위: [10일차 · 서버 기초](README.md)
> 오전은 9일차 이월(리눅스 기본 명령), 오후는 서버 기초다. 무선·PT 공유기 실습은 11일차로 옮겼다. → [11일차 대본](../day-11/commands.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-10-013-REF |
| 유형 | REF (명령·표) |
| 목적 | 10일차 실습의 창 구성, 표기 약속, 실습별 문서 위치, 새로 나온 명령 사전을 한 장에서 찾는다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 VM에서 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본은 실습 절차 전체를 이 페이지에 담고 있었다. 한 파일 한 유형 원칙에 따라 절차는 MP 문서로, 안 될 때 점검표는 TS 문서로 분리했다. 이 페이지는 실습 중 화면에 띄워 두는 참조다. 단계별 대본은 아래 "실습별 문서"의 MP를 연다.
{% endhint %}

## 1. 실습별 문서

| 순서 | 구분 | Task ID | 문서 | 시간 |
|---|---|---|---|---|
| STEP 0 | 몸풀기 | LEC-N2-10-014-MP | [STEP 0. VM 켜고 SSH 접속](lesson-0-lab.md) | 약 10분 |
| STEP 1 | 오전 | LEC-N2-10-015-MP | [STEP 1. 이동](lesson-1-lab.md) | 약 20분 |
| STEP 2 | 오전 | LEC-N2-10-016-MP | [STEP 2. 파일 다루기, nano, 파이프](lesson-2-lab.md) | 약 30분 |
| STEP 3 | 오전 | LEC-N2-10-017-MP | [STEP 3. 권한, sudo, apt](lesson-3-lab.md) | 약 20분 |
| STEP 4 | 오전 | LEC-N2-10-018-MP | [STEP 4. 리눅스의 네트워크](lesson-4-lab.md) | 약 15분 |
| STEP 5 | 오전 | LEC-N2-10-019-MP | [STEP 5. AI로 묻고 검증하기](lesson-5-lab.md) | 약 20분 |
| 오후 준비 + STEP 6 | 오후 | LEC-N2-10-020-MP | [STEP 6. 서버와 LISTEN 관찰](lesson-6-lab.md) | 약 30분 |
| STEP 7 | 오후 | LEC-N2-10-021-MP | [STEP 7. TCP 3-way handshake 관찰](lesson-7-lab.md) | 약 25분 |
| STEP 8 | 오후 | LEC-N2-10-022-MP | [STEP 8. 포트 번호와 소켓](lesson-8-lab.md) | 약 10분 |
| STEP 9 | 오후 | LEC-N2-10-023-MP | [STEP 9. NAT와 포트포워딩 확인](lesson-9-lab.md) | 약 20분 |
| STEP 10 | 오후 | LEC-N2-10-024-MP | [STEP 10. DNS와 DHCP 리눅스판](lesson-10-lab.md) | 약 20분 |
| 부록 B | 점검 | LEC-N2-10-027-TS | [10일차 실습 문제 해결](troubleshooting.md) | - |

## 2. 읽는 법 — 9일차 약속과 창 번호

- 코드 블록 하나는 한 창에서 끊지 않고 이어 입력하는 한 덩어리다.
- `#` 뒤 글자는 설명이다. 입력하지 않아도 된다. `$`는 입력하지 않는다.
- 위치 표기는 다음과 같다.

| 표기 | 뜻 |
|---|---|
| 마우스(VirtualBox) | VirtualBox 화면에서 마우스로 조작 |
| Windows PowerShell | 내 Windows의 PowerShell 창 |
| Windows 브라우저 | 내 Windows의 브라우저 |
| Ubuntu | SSH로 접속한 Ubuntu 터미널 창 |
| Ubuntu ①, ②, ③ | 오후에 같은 VM에 연 창 3개 |

- 오전에는 SSH로 접속한 Ubuntu 창 하나를 쓴다.
- 오후에는 같은 VM에 창 3개를 연다.
  - ① 서버 창: 서버 프로그램을 띄운다. 띄우면 그 창은 점유된다.
  - ② 클라이언트 창: 요청을 보낸다.
  - ③ 관찰 창: `ss`, `tcpdump`로 지켜본다.

## 3. 오늘의 그림

```
        [ 강의실 공유기 192.168.0.1 ]   ← 브릿지: VM이 직접 IP를 받는다
                   │
 Windows ── 창① ② ③ ssh student@192.168.x.x ──▶ Ubuntu VM 192.168.x.x
 브라우저 ── http://192.168.x.x:8080 ───────────▶ (오후 웹서버)
```

## 4. 부록 A — 오늘 새로 나온 명령 사전

### 오전 — 리눅스 기본

| 명령 | 뜻(약자) | 예 |
|---|---|---|
| `pwd` | **p**rint **w**orking **d**irectory | `pwd` |
| `ls` | **l**i**s**t | `ls -al` |
| `cd` | **c**hange **d**irectory | `cd /etc`, `cd ..`, `cd` |
| `mkdir` | **m**a**k**e **dir**ectory | `mkdir -p a/b` |
| `touch` | 빈 파일 만들기 | `touch a.txt` |
| `cp` | **c**o**p**y | `cp -r src dst` |
| `mv` | **m**o**v**e (이름 바꾸기) | `mv a b` |
| `rm` | **r**e**m**ove. 휴지통 없음 | `rm -r dir` |
| `cat` | con**cat**enate. 내용 출력 | `cat a.txt` |
| `less`, `head`, `tail` | 넘겨보기, 앞, 뒤 | `tail -n 5 a` |
| `nano` | 편집기 | `nano a.txt` |
| `grep` | 줄 찾기 | `grep -i word file` |
| `echo` | 글자 출력 | `echo hi >> a` |
| `chmod` | **ch**ange **mod**e (권한) | `chmod 755 a` |
| `chown` | **ch**ange **own**er | `sudo chown root:root a` |
| `ip` | 네트워크 확인 | `ip a`, `ip route` |
| `man`, `--help` | 도움말 | `man ls` (q 종료) |
| `history` | 입력한 명령 기록 | `history \| tail` |

### 오후 — 서버 기초

| 명령 | 뜻 | 예 |
|---|---|---|
| `ss -tulnp` | 열린 포트, 누가 LISTEN하는가 | `sudo ss -tulnp` |
| `ss -tn` | 맺어진 TCP 연결(소켓) | `ss -tn \| grep :22` |
| `python3 -m http.server` | 1분 웹서버 | `python3 -m http.server 8080` |
| `curl` | 웹 요청(클라이언트) | `curl localhost:8080`, `curl -s ifconfig.me` |
| `nc` (netcat) | TCP/UDP로 직접 말 걸기 | `nc -l 5000`, `nc -u 127.0.0.1 5001` |
| `tcpdump` | 패킷 엿보기 | `sudo tcpdump -i lo -n tcp port 5000` |
| `dig` | DNS 조회 | `dig +short MX gmail.com` |
| `resolvectl` | DNS 설정 확인 | `resolvectl status` |
| `/etc/services` | 포트 번호표 | `grep -w ssh /etc/services` |
| `/etc/hosts` | 이름 수첩 | `sudo nano /etc/hosts` |
| `/etc/netplan/*.yaml` | 네트워크 설정 | `sudo cat /etc/netplan/*.yaml` |
