# Ubuntu Server VM 설치와 SSH 서버 구축 실습

> 상위: [9일차 · 리눅스 설명](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-09-005-MP |
| 목적 | VirtualBox에 Ubuntu Server 24.04 LTS VM을 만들어 설치하고, openssh-server를 직접 구축해 Windows에서 SSH로 접속한다 |
| 적용 대상 | Windows 10/11 호스트, VirtualBox 7.x, Ubuntu Server 24.04 LTS, 강의실 공유기(DHCP) 연결 |
| 소요 시간 | 약 60분(설치 대기 10~20분 포함) |
| 확인 상태 | 미검증 (원본 강의 노트와 실습 명령 대본을 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1.md](lesson-1.md) | LEC-N2-09-001-DO | 운영체제와 리눅스 |
| [lesson-2.md](lesson-2.md) | LEC-N2-09-002-DO | 가상머신과 설치 |
| [commands.md](commands.md) | LEC-N2-09-004-REF | 9일차 실습 명령어 |
| [10일차 · 서버 기초](../day-10/README.md) | | 다음 시간. 같은 VM을 계속 쓴다 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Windows PC | Windows 10/11, RAM 8GB 이상 권장, 디스크 여유 25GB 이상 | 호스트 |
| 2 | VirtualBox | 7.x | virtualbox.org |
| 3 | Ubuntu Server ISO | 24.04 LTS, `...live-server-amd64.iso`(약 3GB) | ubuntu.com/download/server |
| 4 | 강의실 공유기 | DHCP 동작 | 브릿지 어댑터로 주소를 받는다 |
| 5 | PowerShell(Windows 터미널) | OpenSSH 클라이언트 포함 | 구역 C에서 사용 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 무인 설치(Unattended)를 켜 두면 VirtualBox가 계정을 `vboxuser`로 자동 생성하고 설치 과정을 건너뛴다. 구역 B의 1단계에서 반드시 건너뛰기를 체크한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 이 VM은 10, 11, 12일차에 계속 쓴다. 실습이 끝나도 VM을 삭제하지 않는다. 종료는 `sudo poweroff`로 한다. VM 창을 X로 닫지 않는다.
{% endhint %}

{% hint style="info" %}
NOTE: 비밀번호는 `<password>`로 표기한다. 설치 화면에서 직접 정한 값을 입력하고, 잊지 않도록 따로 적어 둔다. 로그인 시 비밀번호는 입력해도 화면에 아무것도 표시되지 않는다. 고장이 아니다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | VirtualBox 7.x를 설치한다 | VirtualBox를 실행하면 관리자 화면이 열린다 |
| 2 | Ubuntu Server 24.04 LTS ISO를 받는다 | 파일 크기가 약 3GB이다 |
| 3 | BIOS 가상화가 켜져 있다 | 작업 관리자 > 성능 > CPU에서 `가상화: 사용`이 표시된다 |

## 5. 절차

### A. VM 만들기

1. (5-A-01) VirtualBox에서 `새로 만들기`를 누른다. → 결과: VM 생성 창이 열린다.
2. (5-A-02) 이름에 `ubuntu-server`를 입력한다.
3. (5-A-03) ISO 이미지에서 받은 ISO 파일을 선택한다.
4. (5-A-04) `무인 설치 건너뛰기`(Skip Unattended Installation)를 체크한다. → 결과: 체크 표시가 보인다.
5. (5-A-05) 메모리를 `2048MB`, CPU를 `2`로 설정한다.
6. (5-A-06) 디스크를 `25GB`로 설정하고 생성을 완료한다. → 결과: 왼쪽 목록에 `ubuntu-server`가 나타난다.
7. (5-A-07) `설정 > 네트워크 > 어댑터 1 > 다음에 연결됨`에서 `브릿지 어댑터`를 선택한다.
8. (5-A-08) 이름 항목에서 지금 인터넷이 되는 랜카드를 선택한다. → 결과: 어댑터 1이 브릿지 어댑터로 표시된다.

### B. Ubuntu Server 설치

사용 키: 방향키 위아래로 이동, Space로 체크, Enter로 확정.

1. (5-B-01) VM을 `시작`한다. → 결과: 설치 화면이 나타난다.
2. (5-B-02) `Try or Install Ubuntu Server`를 선택하고 Enter를 누른다.
3. (5-B-03) Language는 `English`, Keyboard는 `English (US)`를 선택한다.
4. (5-B-04) 설치 유형은 `Ubuntu Server`(기본)를 선택한다.
5. (5-B-05) Network 화면은 기본값으로 두고, 표시된 강의실 망의 IP를 적어 둔다. → 결과: `192.168.x.x` 형태의 주소가 보인다.
6. (5-B-06) Proxy와 Mirror는 기본값으로 둔다.
7. (5-B-07) Storage는 `Use an entire disk`를 선택하고 `Done`, `Continue`를 차례로 누른다.
8. (5-B-08) Profile에 이름, server name `ubuntu`, username `student`, 비밀번호 `<password>`를 입력한다.
9. (5-B-09) Ubuntu Pro 화면에서 `Skip for now`를 선택한다.
10. (5-B-10) SSH Setup 화면에서 아무것도 체크하지 않고 `Done`을 누른다. → 결과: SSH 서버는 설치되지 않는다(구역 C에서 직접 설치한다).
11. (5-B-11) Featured snaps는 아무것도 선택하지 않고 `Done`을 누른다.
12. (5-B-12) 설치가 끝나길 기다린다(10~20분). → 결과: `Reboot Now`가 표시된다.
13. (5-B-13) `Reboot Now`를 선택하고, `remove the installation medium` 메시지가 나오면 Enter를 누른다. → 결과: `ubuntu login:` 프롬프트가 나타난다.
14. (5-B-14) VirtualBox에서 `머신 > 스냅샷 찍기`를 선택하고 이름을 `설치완료`로 저장한다. → 결과: 스냅샷 목록에 `설치완료`가 보인다.

### C. SSH 서버 직접 구축

1. (5-C-01) VM 창에서 `ubuntu login:`에 `student`를 입력한다.
2. (5-C-02) 비밀번호 `<password>`를 입력하고 Enter를 누른다. → 결과: `student@ubuntu:~$` 프롬프트가 나타난다.
3. (5-C-03) 패키지 목록을 갱신한다: `sudo apt update` → 결과: 목록 갱신 로그가 출력된다.
4. (5-C-04) openssh-server를 설치한다: `sudo apt install openssh-server` → 결과: 설치 확인을 물으면 `y`를 입력하고, 설치가 끝난다.
5. (5-C-05) 부팅 시 자동 시작과 즉시 시작을 켠다: `sudo systemctl enable --now ssh` → 결과: 오류 없이 끝난다.
6. (5-C-06) 상태를 확인한다: `sudo systemctl status ssh` (나가기는 `q`) → 결과: 아래 세 줄이 보인다.

```
Loaded: ... ssh.service; enabled; ...        ← enabled = 부팅 때 자동 시작
Active: active (running) since ...           ← 지금 돌고 있다
... sshd[2610]: Server listening on 0.0.0.0 port 22.   ← 22번 문을 열고 기다린다
```

### D. Windows에서 SSH 접속

1. (5-D-01) VM 창에서 IP를 확인한다: `ip a` → 결과: `192.168.x.x` 주소가 보인다.
2. (5-D-02) Windows에서 PowerShell을 연다.
3. (5-D-03) 접속한다: `ssh student@<VM의 IP>` → 결과: `Are you sure you want to continue connecting (yes/no)?`가 나타난다.
4. (5-D-04) `yes`를 입력한다.
5. (5-D-05) 비밀번호 `<password>`를 입력한다. → 결과: PowerShell에 `student@ubuntu:~$` 프롬프트가 나타난다.
6. (5-D-06) VM 창을 최소화한다. 이후 실습은 PowerShell 창에서 한다.

### E. 첫 명령 확인

1. (5-E-01) `whoami`를 입력한다. → 결과: `student`
2. (5-E-02) `hostname`을 입력한다. → 결과: `ubuntu`
3. (5-E-03) `cat /etc/os-release`를 입력한다. → 결과: `Ubuntu 24.04 LTS`
4. (5-E-04) `uname -r`을 입력한다. → 결과: 커널 버전이 출력된다. 리눅스는 커널의 이름이다.
5. (5-E-05) `date`를 입력한다. → 결과: 서버 시각이 출력된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `sudo systemctl status ssh` | `active (running)` | 초록색 `active (running)`이 표시된다 |
| 2 | PowerShell에서 `ssh student@<VM의 IP>` | 로그인 성공 | `student@ubuntu:~$` 프롬프트가 보인다 |
| 3 | `ip a`의 주소 | 강의실 망 주소 | `10.0.2.15`가 아니다 |

{% hint style="warning" %}
CAUTION: `Connection refused`가 나오면 두 가지를 확인한다. 하나, `sudo systemctl status ssh`가 `running`인지 확인한다. 둘, `ip a`로 주소를 다시 확인한다. 주소가 `10.0.2.15`이면 어댑터가 아직 NAT이므로 5-A-07을 다시 수행하고 VM을 재부팅한다. 그 밖의 증상은 [가상머신과 설치](lesson-2.md)의 "막히는 곳"을 따른다.
{% endhint %}

## 7. 복구

1. (7-01) 실습을 마칠 때 VM을 종료한다: `sudo poweroff` → 결과: VM이 종료되고 SSH 연결이 끊긴다. 정상이다.
2. (7-02) 설치나 설정이 꼬였으면 스냅샷 `설치완료`로 되돌린다: VirtualBox `머신 > 스냅샷`에서 `설치완료`를 복원한다. → 결과: 설치 직후 상태로 돌아간다.
3. (7-03) VirtualBox가 동작하지 않는 PC는 WSL로 대체한다. → [가상머신과 설치](lesson-2.md)의 Plan B

{% hint style="info" %}
NOTE: VM은 삭제하지 않는다. 10, 11, 12일차에 이 VM을 계속 쓴다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-2.md`와 `commands.md`의 실습 항목을 AMM 형식으로 재작성 |
