# STEP 3. 권한 · sudo · apt

> 상위: [10일차 · 서버 기초](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-10-017-MP |
| 목적 | 권한 문자열을 읽고, `chmod`로 실행 권한을 바꾸고, `sudo`와 `apt`로 프로그램을 설치한다 |
| 적용 대상 | Ubuntu Server 24.04 LTS VM, SSH 접속 창 하나, 인터넷 연결 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 강의 노트의 대본을 정리한 것이며 VM에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-3.md](lesson-3.md) | LEC-N2-10-003-DO | 3. 사용자 · 권한 · sudo |
| [lesson-2-lab.md](lesson-2-lab.md) | LEC-N2-10-016-MP | STEP 2. 파일 다루기 · nano · 파이프 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | SSH로 접속한 Ubuntu 창 | `student@ubuntu` | 창 하나 |
| 2 | `student`의 `sudo` 자격과 비밀번호 | `<password>` | |
| 3 | `~/lab/server.txt` | STEP 2의 결과물 | |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `sudo`는 관리자 권한이다. 이 실습에서는 아래 절차에 적힌 명령만 `sudo`로 입력한다. `sudo` 뒤에 `rm`을 붙이지 않는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `/etc/shadow`에는 비밀번호 해시가 들어 있다. 5-A-04의 출력은 3줄만 보고, 캡처하거나 공유하지 않는다.
{% endhint %}

{% hint style="info" %}
NOTE: 강의실 전원이 `apt update`를 입력하면 느리다. 다 같이 입력하고 기다린다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | STEP 2를 마쳤다 | `ls ~/lab`에 `server.txt`, `docs`가 있다 |
| 2 | 인터넷이 된다 | `ping -c 2 8.8.8.8`이 응답한다 |

## 5. 절차

### A. 권한 읽기

1. (5-A-01) `cd ~/lab`을 입력한다. → 결과: 프롬프트가 `~/lab`으로 바뀐다.
2. (5-A-02) `ls -l`을 입력한다. → 결과: `-rw-rw-r-- ... server.txt`, `drwxrwxr-x ... docs`가 보인다.
3. (5-A-03) `ls -l /etc/shadow`를 입력한다. → 결과: `-rw-r----- ... root shadow`
4. (5-A-04) `cat /etc/shadow`를 입력한다. → 결과: `Permission denied`
5. (5-A-05) `sudo cat /etc/shadow | head -n 3`을 입력한다. → 결과: 비밀번호를 묻는다. `<password>`를 입력하면 관리자 권한으로 3줄이 출력된다.

### B. 실행 파일 만들고 권한 바꾸기

1. (5-B-01) 다음 명령으로 스크립트를 만든다.

```bash
echo 'echo "안녕, $(whoami)! 지금은 $(date +%H:%M)"' > hello.sh
```

→ 결과: 오류 없이 끝난다.

2. (5-B-02) `./hello.sh`를 입력한다. → 결과: `Permission denied`. `x` 권한이 없다.
3. (5-B-03) `ls -l hello.sh`를 입력한다. → 결과: `-rw-rw-r--`
4. (5-B-04) `chmod u+x hello.sh`를 입력한다. → 결과: 주인에게 실행 권한이 생긴다.
5. (5-B-05) `ls -l hello.sh`를 입력한다. → 결과: `-rwxrw-r--`
6. (5-B-06) `./hello.sh`를 입력한다. → 결과: `안녕, student! 지금은 HH:MM`이 출력된다.
7. (5-B-07) `chmod 700 hello.sh`를 입력한다. → 결과: 주인만 전부 가능해진다.
8. (5-B-08) `ls -l hello.sh`를 입력한다. → 결과: `-rwx------`
9. (5-B-09) `chmod 644 server.txt`를 입력한다. 일반 파일의 표준 권한이다.
10. (5-B-10) `ls -l server.txt`를 입력한다. → 결과: `-rw-r--r--`

### C. 프로그램 설치

1. (5-C-01) `sudo apt update`를 입력한다. → 결과: 창고 목록이 갱신된다.
2. (5-C-02) `sudo apt install -y tree`를 입력한다. → 결과: `tree`가 설치된다.
3. (5-C-03) `tree ~/lab`을 입력한다. → 결과: `~/lab`이 나무 모양으로 출력된다.
4. (5-C-04) `apt install -y cowsay`를 `sudo` 없이 입력한다. → 결과: 권한 오류가 난다.
5. (5-C-05) `sudo apt install -y cowsay`를 입력한다. → 결과: `cowsay`가 설치된다.
6. (5-C-06) `/usr/games/cowsay "sudo 는 마스터키"`를 입력한다. → 결과: 소가 말하는 그림이 출력된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `./hello.sh` | 인사 문장이 출력된다 | 실행된다 |
| 2 | `tree ~/lab` | 트리가 출력된다 | `tree`가 설치되어 있다 |
| 3 | `ls -l server.txt` | `-rw-r--r--` | 644다 |

## 7. 복구

1. (7-01) 설치한 프로그램을 지우려면 `sudo apt remove -y tree cowsay`를 입력한다.
2. (7-02) 권한을 되돌리려면 `chmod 664 hello.sh` 또는 `chmod 644 <파일>`을 입력한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 STEP 3을 AMM 형식 MP로 분리 |
