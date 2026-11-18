# STEP 0. VM 켜고 SSH 접속 — 몸풀기

> 상위: [10일차 · 서버 기초](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-10-014-MP |
| 목적 | 9일차에 만든 Ubuntu VM을 켜고, 오늘의 VM 주소를 확인하고, SSH로 접속해 SSH 서버가 살아 있는지 확인한다 |
| 적용 대상 | VirtualBox 7.x, Ubuntu Server 24.04 LTS VM(브릿지 어댑터), Windows PowerShell |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 강의 노트의 대본을 정리한 것이며 VM에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [commands.md](commands.md) | LEC-N2-10-013-REF | 0. 10일차 실습 명령어 |
| [../day-09/lesson-2-lab.md](../day-09/lesson-2-lab.md) | LEC-N2-09-005-MP | Ubuntu Server VM 설치와 SSH 서버 구축 실습 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Windows PC | PowerShell 사용 가능 | |
| 2 | VirtualBox와 9일차 VM | Ubuntu Server 24.04 LTS | 지우지 않고 11, 12일차에도 쓴다 |
| 3 | 강의실 공유기 | 브릿지 어댑터로 VM이 IP를 받는 망 | |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 브릿지와 DHCP 때문에 VM 주소가 지난주와 다를 수 있다. 수업 시작마다 `ip a`로 확인한다. 지난주 주소로 접속하면 다른 사람의 PC에 닿거나 접속이 실패한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 9일차에 만든 VM이 VirtualBox 목록에 있다 | VM 이름이 보인다 |
| 2 | VM 네트워크가 브릿지 어댑터다 | VM 설정 > 네트워크에서 확인한다 |

## 5. 절차

### A. VM 시작과 주소 확인

1. (5-A-01) VirtualBox에서 VM을 시작한다. 헤드리스 시작을 권장한다. → 결과: VM이 부팅된다.
2. (5-A-02) VM 창의 로그인 프롬프트에서 로그인한다.
3. (5-A-03) VM 창에서 `ip a`를 입력한다. → 결과: `enp0s3`의 `inet 192.168.x.x/24`가 보인다. 이 주소를 칠판에 적는다.

### B. SSH 접속

1. (5-B-01) Windows PowerShell을 연다.
2. (5-B-02) `ssh student@<VM IP>`를 입력한다. `<VM IP>`는 5-A-03에서 확인한 주소다. → 결과: 비밀번호를 묻는다.
3. (5-B-03) 비밀번호 `<password>`를 입력한다. 입력해도 화면에 보이지 않는 것이 정상이다. → 결과: `student@ubuntu:~$` 프롬프트가 나온다.

### C. SSH 서버 상태 확인

1. (5-C-01) Ubuntu 창에서 `sudo systemctl status ssh`를 입력한다. → 결과: `active (running)`과 `Server listening on 0.0.0.0 port 22`가 보인다.
2. (5-C-02) `q`를 눌러 상태 화면에서 나온다.
3. (5-C-03) 칠판에 "오늘의 주소"를 적는다: 내 VM IP, 게이트웨이, `port 22`. 오후에 하나씩 지운다.

{% hint style="info" %}
NOTE: 9일차에 `enable --now`로 켜 둔 덕분에 재부팅해도 SSH가 알아서 떠 있다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `ip a` | `192.168.x.x/24`가 보인다 | 주소가 칠판에 적혀 있다 |
| 2 | Windows에서 SSH 접속 | `student@ubuntu:~$` 프롬프트 | 접속 성공 |
| 3 | `sudo systemctl status ssh` | `active (running)` | `Server listening on 0.0.0.0 port 22` 확인 |

## 7. 복구

1. (7-01) 접속이 되지 않으면 VM 창에서 `ip a`로 주소를 다시 확인한다.
2. (7-02) 주소가 맞는데 실패하면 [LEC-N2-10-027-TS](troubleshooting.md)를 본다.
3. (7-03) SSH 서비스가 꺼져 있으면 `sudo systemctl enable --now ssh`를 입력한다(9일차 절차).

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 STEP 0을 AMM 형식 MP로 분리 |
