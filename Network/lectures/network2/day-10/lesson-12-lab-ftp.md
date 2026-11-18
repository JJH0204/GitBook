# FTP 맛보기 — Windows PC 와 리눅스 VM 파일 주고받기

> 상위: [10일차 · 서버 기초](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-10-025-MP |
| 목적 | 리눅스 VM에 FTP 서버(vsftpd)를 올리고, Windows 터미널의 `ftp`로 파일을 내려받고 올리고, SCP로 같은 일을 한다 |
| 적용 대상 | Ubuntu Server 24.04 LTS VM(브릿지, `student` 계정), Windows PowerShell(내장 `ftp`), 인터넷 연결 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 강의 노트의 설명을 절차로 정리한 것이며 VM에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-12.md](lesson-12.md) | LEC-N2-10-012-REF | 12. 10일차 복습(FTP 두 연결 설명) |
| [lesson-12-troubleshooting.md](lesson-12-troubleshooting.md) | LEC-N2-10-028-TS | FileZilla 500 에러 분석 |
| [../day-09/lesson-2-lab.md](../day-09/lesson-2-lab.md) | LEC-N2-09-005-MP | SSH 서버 구축(같은 순서) |
| [../day-12/lesson-3.md](../day-12/lesson-3.md) | - | 12일차: `vsftpd.conf` 설정 본편 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Ubuntu VM | 24.04 LTS, 브릿지, `student` 계정 | |
| 2 | Windows PowerShell | 내장 `ftp` 클라이언트 | 따로 설치하지 않는다 |
| 3 | `sudo` 자격 | `<password>` | |
| 4 | 주고받을 테스트 파일 | 짧은 텍스트 파일 | 사진, zip은 `binary` 후 사용 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: FTP는 아이디와 비밀번호가 평문으로 흘러간다. 이 실습은 수업 VM에서만 한다. 실제 계정과 실제 비밀번호를 쓰지 않는다. 실무에서는 SFTP 또는 SCP를 쓴다. 12일차에 `tcpdump`로 비밀번호가 그대로 보이는 장면을 직접 본다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 설정 파일(`/etc/vsftpd.conf`)은 이 실습에서 고치지 않는다. 본격적인 설정은 12일차에 한다.
{% endhint %}

{% hint style="info" %}
NOTE: 서버 종류는 달라도 세우는 순서는 같다. SSH 때와 명령이 같고 이름만 `openssh-server`에서 `vsftpd`로 바뀐다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | VM 주소를 안다 | VM에서 `ip a`로 `192.168.x.x`를 확인한다 |
| 2 | VM에 SSH로 접속된다 | `student@ubuntu:~$` 프롬프트 |
| 3 | 인터넷이 된다 | `ping -c 2 8.8.8.8` |

## 5. 절차

### A. 리눅스 쪽 — FTP 서버 올리기

1. (5-A-01) VM에서 `sudo apt install vsftpd`를 입력한다. 설치 확인을 물으면 `Y`를 입력한다. → 결과: `vsftpd`가 설치된다.
2. (5-A-02) `sudo systemctl enable --now vsftpd`를 입력한다. → 결과: 서비스가 켜지고 자동 시작으로 등록된다.
3. (5-A-03) `sudo systemctl status vsftpd`를 입력한다. → 결과: `active (running)`이 보인다. `q`로 나온다.
4. (5-A-04) `ss -tln | grep ':21'`을 입력한다. → 결과: 21번 포트 LISTEN이 보인다.
5. (5-A-05) 테스트 파일을 만든다: `echo "ftp test" > ~/ftp-test.txt`. → 결과: `~/ftp-test.txt`가 생긴다.

### B. Windows 쪽 — 내장 `ftp` 접속

1. (5-B-01) Windows 터미널에서 `ftp <VM IP>`를 입력한다. → 결과: 연결되고 사용자 이름을 묻는다.
2. (5-B-02) 사용자에 `student`를 입력한다. → 결과: 암호를 묻는다.
3. (5-B-03) 암호에 `<password>`를 입력한다. 입력해도 화면에 보이지 않는 것이 정상이다. → 결과: `ftp>` 프롬프트가 나온다.
4. (5-B-04) `ls`를 입력한다. → 결과: 서버의 파일 목록이 나온다.
5. (5-B-05) `get ftp-test.txt`를 입력한다. → 결과: 파일이 내 PC로 내려온다.
6. (5-B-06) `put <내 PC의 파일 이름>`을 입력한다. → 결과: 파일이 서버로 올라간다.

{% hint style="warning" %}
CAUTION: 확인 상태가 미검증이다. Ubuntu의 `vsftpd` 기본 설정은 쓰기를 허용하지 않는 것으로 알려져 있다(`write_enable` 비활성). 그렇다면 `put`은 `550` 또는 `553` 응답으로 실패한다. `get`과 `ls`는 영향이 없다. `put`이 실패하면 12일차에 `/etc/vsftpd.conf`를 설정한 뒤 다시 시도한다.
{% endhint %}

7. (5-B-07) `ls`를 다시 입력한다. → 결과: 올린 파일이 보인다.
8. (5-B-08) `bye`를 입력한다. → 결과: 연결이 종료된다.

| 명령 | 뜻 |
|---|---|
| `ls` / `dir` | 서버 쪽 목록 |
| `cd` | 서버 쪽 폴더 이동 |
| `lcd` | 내 PC 쪽 폴더 이동(local cd) |
| `get` / `put` | 내려받기 / 올리기 |
| `binary` | 이진 모드 |
| `bye` | 종료 |

{% hint style="warning" %}
CAUTION: 사진이나 zip을 주고받을 때는 `get`, `put` 전에 `binary`를 먼저 입력한다. Windows `ftp`의 기본은 텍스트 모드라서 파일이 깨질 수 있다.
{% endhint %}

### C. SCP — SSH로 파일 보내기 (22번)

1. (5-C-01) Windows PowerShell에서 다음 명령을 입력한다.

```powershell
scp <보낼 파일> student@<VM IP>:/home/student/
```

→ 결과: 암호를 묻고 `<password>`를 입력하면 전송이 끝난다. 포트가 22 하나뿐이라 간단하고 암호화까지 된다.

2. (5-C-02) VM에서 `ls ~`를 입력한다. → 결과: 보낸 파일이 보인다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `sudo systemctl status vsftpd` | `active (running)` | 실행 중이다 |
| 2 | Windows `ftp`에서 `get ftp-test.txt` | 파일이 내려온다 | 파일이 PC에 있다 |
| 3 | `put` 후 `ls` | 올린 파일이 보인다 | 서버 목록에 있다 |
| 4 | SCP 전송 | VM의 `~`에 파일이 보인다 | 파일이 있다 |

## 7. 복구

1. (7-01) FTP 서버를 끄려면 VM에서 `sudo systemctl disable --now vsftpd`를 입력한다. → 결과: 21번 포트가 닫힌다.
2. (7-02) 설치까지 되돌리려면 `sudo apt remove -y vsftpd`를 입력한다. 12일차에 다시 설치하므로 지워도 된다.
3. (7-03) 테스트 파일을 지우려면 `rm ~/ftp-test.txt`와 올린 파일을 삭제한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `lesson-12.md`의 "FTP 맛보기"를 AMM 형식 MP로 분리. 원본에 없던 21번 LISTEN 확인(5-A-04), 테스트 파일 생성(5-A-05)을 추가하고, `ftp>` 명령 표는 원본 그대로 유지 |
