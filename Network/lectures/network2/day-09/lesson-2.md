# 2. 가상머신과 설치 — 내 PC 안에 서버 한 대 더

> 상위: [9일차 · 리눅스 설명](README.md)
> 실습 중에는 이 노트 대신 [Ubuntu Server VM 설치와 SSH 서버 구축 실습](lesson-2-lab.md)(LEC-N2-09-005-MP)과 [9일차 실습 명령어](commands.md)(LEC-N2-09-004-REF)를 본다.

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-09-002-DO |
| 유형 | D&O (개념) |
| 목적 | 가상화의 용어, VM 설정값과 이유, 네트워크 어댑터 모드, 설치 화면별 선택, 첫 서버 구축의 원리(`apt`, `systemctl`), SSH 접속, 스냅샷, 막히는 곳을 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- 가상화, 호스트, 게스트, 하이퍼바이저를 구분한다.
- VirtualBox에 VM을 만들고 Ubuntu Server 24.04 LTS를 설치한다.
- VM의 네트워크 어댑터를 브릿지(Bridged)로 두는 뜻을 안다.
- `apt`로 openssh-server를 설치하고 `systemctl`로 켠다. 이것이 첫 서버 구축이다.
- Windows 터미널에서 `ssh student@<서버 IP>`로 VM에 접속한다.

## 1. 목적

"서버를 사러 갈 수는 없으니까"라는 질문에 답한다.

[1. 운영체제와 리눅스](lesson-1.md)에서 서버는 리눅스라고 했다. 그런데 연습하려고 서버를 한 대 살 수는 없다. 1단계에서는 라우터를 사지 않고 패킷 트레이서 안에 만들었다. 오늘은 리눅스 서버를 내 PC 안에 만든다. 그것이 가상머신(VM)이다.

## 2. 구성 요소

### 가상화: 컴퓨터 안의 컴퓨터

```
 ┌──────────── 호스트 (내 Windows PC · 진짜 하드웨어) ────────────┐
 │                                                               │
 │   [ Windows 앱들 ]    [ VirtualBox (하이퍼바이저) ]             │
 │                         ├── VM1: Ubuntu Server  ← 게스트       │
 │                         └── VM2: (나중에 더 만들 수 있다)        │
 └───────────────────────────────────────────────────────────────┘
```

| 번호 | 용어 | 뜻 | 오늘 |
|---|---|---|---|
| 1 | 호스트(Host) | 진짜 컴퓨터 | 내 Windows PC |
| 2 | 게스트(Guest) | 그 안에 만든 가짜 컴퓨터 | Ubuntu VM |
| 3 | 하이퍼바이저 | 게스트에게 CPU, 메모리, 디스크를 나눠주는 프로그램 | VirtualBox |
| 4 | 이미지(ISO) | 설치 DVD를 파일 하나로 만든 것 | `ubuntu-24.04.x-live-server-amd64.iso` |

비유: 집 안에 원룸 한 칸을 들이는 것이다. 집(호스트)의 전기, 수도(CPU, RAM)를 나눠 쓰지만 원룸(VM) 안에서 무슨 짓을 해도 본채는 멀쩡하다. 마음껏 부숴도 되고, 망가지면 지우고 다시 만들면 끝이다. 그래서 스냅샷이 있다(아래).

- 클라우드(15, 16일차)의 서버도 사실 거대한 호스트 위의 VM이다. 오늘 하는 일이 클라우드의 축소판이다.
- 14일차 Docker는 VM보다 가벼운 "칸막이" 방식이다. 그때 비교한다.

### VM 설정값과 이유

| 설정 | 값 | 이유 |
|---|---|---|
| 이름 | `ubuntu-server` | 자유 |
| ISO | Ubuntu Server 24.04 LTS | 화면 없는 서버판(Desktop 판 아님) |
| 무인 설치(Unattended) | 건너뛰기 체크 | 켜 두면 VirtualBox가 알아서 설치해 버린다. 과정을 직접 보기 위해 끈다 |
| CPU | 2 | |
| RAM | 2048MB | 호스트 RAM 8GB 기준. 16GB 이상이면 4096 |
| 디스크 | 25GB(동적 할당) | 실제로는 쓴 만큼만 파일이 커진다 |
| 네트워크 | 브릿지 어댑터 | 아래 |

![](../../../.gitbook/assets/lectures/Pasted-Image-20260919150649_707.png)

### 네트워크 어댑터 모드

| 모드 | 한 줄 | 쓰임 |
|---|---|---|
| 브릿지(Bridged) | VM이 공유기에 랜선을 직접 꽂은 PC처럼 된다 | 오늘 우리가 쓰는 것 |
| NAT(기본값) | VM이 호스트 뒤에 숨어서 인터넷에 나간다 | 밖에서 들어오려면 포트포워딩이 필요하다 |
| 호스트 전용 | 호스트와 VM끼리만 통신한다 | 인터넷 없이 실험 |

설정 위치는 `설정 > 네트워크 > 어댑터 1 > 다음에 연결됨: 브릿지 어댑터`이다. 이름은 지금 인터넷이 되는 랜카드를 고른다.

```
        [ 강의실 공유기 ]
              │
      ┌───────┼────────────┐
  내 Windows  │        옆자리 PC
      └── 내 Ubuntu VM  ←── 브릿지: 공유기에서 IP 를 "직접" 받는다
```

- 브릿지로 두면 VM은 강의실 망의 주소(`192.168.x.x` 등)를 하나 차지한다.
- 그래서 포트포워딩이 필요 없다. Windows에서 그 주소로 바로 SSH가 된다.

{% hint style="info" %}
NOTE: 그 주소는 누가 줬을까? 정체는 DHCP이며 10일차에 밝힌다. → [10일차](../day-10/README.md)
{% endhint %}

{% hint style="warning" %}
CAUTION: 브릿지 주소는 매번 바뀔 수 있다. 수업을 시작할 때마다 VM에서 `ip a`로 확인한다.
{% endhint %}

### Ubuntu Server 설치 화면별 선택

설치는 키보드로 한다: 방향키 위아래로 이동, Space로 체크, Enter로 확정, Tab으로 다음 칸 이동.

| 화면 | 선택 | 메모 |
|---|---|---|
| Language | English | 한국어는 콘솔에서 글자가 깨진다 |
| Keyboard | English (US) | 한국 키보드도 US로 두면 된다 |
| Type of install | Ubuntu Server | (minimized 아님) |
| Network | 기본값(`enp0s3` DHCP) | 여기서 강의실 망의 IP가 보인다. 2일차에 배운 내용의 회수 지점이다. 적어 둔다 |
| Proxy, Mirror | 기본값 | 미러 테스트가 느리면 기다린다 |
| Storage | Use an entire disk, 기본값 | 가상 디스크라 안전하다 |
| Profile | 이름, 서버 이름 `ubuntu`, 사용자 `student`, 비밀번호 | 비밀번호를 잊지 않는다 |
| Ubuntu Pro | Skip | |
| SSH | 체크하지 않고 Done | 설치가 끝난 뒤 직접 구축한다(아래) |
| Featured snaps | 아무것도 선택 안 함 | Docker는 14일차에 직접 설치한다 |

설치가 끝나면 `Reboot Now`를 선택하고, `Please remove the installation medium`이 나오면 Enter를 누른다. 설치에 10~20분 걸리며, 이 시간에 [1. 운영체제와 리눅스](lesson-1.md)를 이야기한다.

첫 로그인 화면은 다음과 같다.

```
ubuntu login: student
Password:                  ← ⚠️ 쳐도 화면에 아무것도 안 나온다. 고장이 아니다!
student@ubuntu:~$          ← 성공
```

## 3. 동작 원리

### 첫 서버 구축: OpenSSH 서버

8일차 Server0에서는 체크박스 하나로 서비스를 켰다. 리눅스에서는 설치, 켜기, 확인 순서로 한다. 실제 명령 순서는 [Ubuntu Server VM 설치와 SSH 서버 구축 실습](lesson-2-lab.md)에 있다.

**1) 설치: 패키지 관리자 `apt`**

```bash
sudo apt update                    # 창고(저장소)의 최신 목록 받기
sudo apt install openssh-server    # SSH 서버 프로그램 설치 → 물어보면 y
```

| 패키지 관리자 | 어디서 | 비유 |
|---|---|---|
| `apt` | Ubuntu, Debian | 앱스토어. 검증된 창고에서 받아 설치한다 |
| `dnf` | Rocky, RHEL | 같은 일, 다른 계열 |
| `brew` | macOS | |
| `pip` | Python 라이브러리 | |

- `sudo`는 관리자 권한으로 한 번 실행한다는 뜻이다(시스코 `enable`과 비슷한 발상이며 10일차 오전에 자세히 배운다).
- 명령의 모양은 전부 같다: `명령어 [옵션] [대상1] [대상2] ...`. 예: `apt install openssh-server`

**2) 켜기: `systemctl`**

```bash
sudo systemctl enable --now ssh    # enable = 부팅할 때마다 자동 시작 · --now = 지금 바로 켜기
```

비유: 가게 문 열기다. `--now`는 지금 문을 연다. `enable`은 내일부터 매일 아침 자동으로 문을 연다. 서버는 재부팅돼도 알아서 다시 떠야 하므로 둘 다 쓴다.

**3) 확인: `systemctl status`**

```bash
sudo systemctl status ssh          # q 로 나가기
```

![](../../../.gitbook/assets/lectures/Pasted-Image-20260919164156_803.png)

| 줄 | 뜻 |
|---|---|
| `Loaded: ... ; enabled;` | 부팅 때 자동 시작이 켜져 있다 |
| `Active: active (running)` | 지금 돌고 있다(초록색) |
| `Server listening on 0.0.0.0 port 22.` | 22번 문을 열고 손님을 기다린다. 정체는 10일차 오후에 밝힌다 |

"방금 여러분은 리눅스에 서버를 하나 구축했다." 12일차에 만들 DNS, 메일, FTP 서버도 똑같이 설치, 켜기, 확인 3단계다.

### Windows에서 SSH 접속

Windows 터미널(PowerShell)에서 접속한다.

```powershell
# 🐧 VM 창에서 먼저:  ip a   → 192.168.x.x 를 확인한다
ssh student@192.168.x.x
# 처음엔 "Are you sure you want to continue connecting (yes/no)?" → yes
```

8일차에 스위치에 SSH로 들어갔다. 오늘은 리눅스 서버에 SSH로 들어간다. 명령 모양이 거의 같다.

| 일차 | 대상 | 명령 |
|---|---|---|
| 8일차 | 스위치 | `ssh -l admin 192.168.10.253` |
| 오늘 | 리눅스 서버 | `ssh student@192.168.x.x` |

- VM 창을 쓰지 않고 SSH를 쓰는 이유: 복사, 붙여넣기, 한글, 창 여러 개가 된다. 그리고 현업이 이렇게 일한다.
- VM 창은 최소화해 두면 된다. VirtualBox에서 "헤드리스 시작"을 하면 창 없이 켜진다.

### 스냅샷: 되돌리기 버튼

- VirtualBox `머신 > 스냅샷 찍기`는 지금 상태를 사진으로 저장한다.
- 설치 직후 `설치완료` 스냅샷을 찍어 두면, 무슨 짓을 해도 5초 만에 복구한다.
- 12일차 서버 구축 전에도 한 번 더 찍는다.

## 4. 막히는 곳

| 증상 | 원인 | 해결 |
|---|---|---|
| VM 시작 시 `VT-x is not available`, 현저히 느림 | BIOS에서 가상화(VT-x / AMD-V, SVM)가 꺼짐 | 재부팅, BIOS에서 Virtualization을 Enabled로 변경 |
| 가상화는 켰는데 여전히 안 됨 | Windows Hyper-V와 충돌 | VirtualBox 7은 대부분 공존한다. 안 되면 Plan B |
| 로그인 비밀번호가 안 쳐진다 | 원래 화면에 안 보인다 | 그냥 치고 Enter |
| `ssh: connect ... refused` | SSH 서버 미설치 또는 꺼짐, IP를 잘못 봄 | `sudo systemctl status ssh`를 확인하고 안 돌면 `sudo systemctl enable --now ssh`. VM에서 `ip a`로 주소 재확인 |
| VM이 `10.0.2.15`를 받았다 | 어댑터가 아직 NAT | 설정, 네트워크에서 브릿지 어댑터로 바꾸고 재부팅 |
| 설치 중 미러, 업데이트에서 멈춤 | 강의실 네트워크 혼잡 | 기다리거나 `Continue without updating` |

### Plan B: WSL

VirtualBox가 도저히 안 되는 PC는 WSL(Windows Subsystem for Linux)로 오늘 명령어 실습을 전부 할 수 있다.

```powershell
wsl --install -d Ubuntu-24.04      # 관리자 PowerShell · 재부팅 후 사용자 이름/비밀번호 설정
```

- 오늘(9일차) 명령어, 권한, `apt`는 동일하다.
- 10일차 이후 포트, 서버 구축, 방화벽은 VM과 다르게 보이는 부분이 있다. 가능하면 다음 주 전에 VirtualBox를 해결해 오게 한다.

## 5. 질문과 실습

- 실습 STEP 0, 1, 2 → [0. 9일차 실습 명령어](commands.md), [Ubuntu Server VM 설치와 SSH 서버 구축 실습](lesson-2-lab.md)
- "VM에서 `rm -rf`로 다 지워버리면 내 Windows도 지워지나?" → 아니다. 원룸만 부서진다. 스냅샷으로 복구한다.
- "그 `192.168.x.x`는 누가 줬나?" → 10일차 DHCP에서 다룬다. 지금은 "공유기가 줬다"까지만 답한다.

## 6. 약어·용어

| 용어 | 뜻 |
|---|---|
| VM (Virtual Machine) | 가상머신. 컴퓨터 안에 만든 가짜 컴퓨터 |
| 호스트 / 게스트 | 진짜 컴퓨터 / 그 안의 가상 컴퓨터 |
| 하이퍼바이저 | 게스트에게 자원을 나눠주는 프로그램(VirtualBox) |
| ISO | 설치 디스크 이미지 파일 |
| 브릿지 / NAT / 호스트 전용 | VirtualBox 네트워크 어댑터 모드 |
| 스냅샷 | VM의 특정 시점 상태를 저장한 것 |
| `apt` | Debian 계열 패키지 관리자 |
| `systemctl` | 서비스 시작, 중지, 자동 시작을 관리하는 명령 |
| SSH | 원격 접속 프로토콜(기본 22번 포트) |
| WSL | Windows 안에서 리눅스를 돌리는 기능 |

## 강의 메모

- ISO는 사전 공지로 미리 받게 한다. 수업 시작 전에 확인한다.
- VirtualBox 7의 무인 설치(Unattended)는 반드시 건너뛰게 한다. 켜면 계정이 `vboxuser`로 자동 생성된다.
- SSH는 설치 화면에서 체크하지 않고 설치 후 `apt`, `systemctl`로 직접 구축한다. "첫 서버 구축" 경험이 목적이다(2026-09-19 수업에서 이렇게 진행했다).
- 설치가 빨리 끝난 학생에게는 스냅샷을 찍게 하고 [1. 파일 시스템과 이동](../day-10/lesson-1.md)을 먼저 읽게 한다.
- 브릿지를 고른 이유는 오늘 깊게 설명하지 않는다. "공유기에 직접 꽂은 셈"까지만 말한다.
  - 대신 어댑터 설정을 빠뜨린 학생이 나온다. `ip a`가 `10.0.2.15`면 NAT 그대로이므로 바로 잡아 준다.
  - 이 선택이 11일차 서버 보안의 출발점이 된다(교실의 다른 PC가 내 서버에 닿는다). → [11일차](../day-11/lesson-3.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 호스트, 게스트, 하이퍼바이저를 "원룸" 비유가 아닌 내 말로 설명해 본다.
- [ ] 브릿지와 NAT 중 오늘 브릿지를 쓴 이유와, 그 선택으로 달라지는 점을 적는다.
- [ ] 8일차 Server0의 체크박스와 오늘 `apt`, `systemctl`로 서버를 켠 방식의 차이를 적는다.
