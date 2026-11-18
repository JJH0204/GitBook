# vsftpd FTP 서버 구축과 평문 확인 실습

> 상위: [12일차 · 리눅스 서버 구축](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-12-013-MP |
| 목적 | vsftpd로 FTP 서버를 구축하고, `tcpdump`로 FTP 비밀번호가 평문으로 흐르는 것과 SFTP가 암호화되는 것을 확인한다 |
| 적용 대상 | Ubuntu Server 24.04 LTS VM(9일차 VM), 창 3개(`①` 작업, `②` 클라이언트, `③` 관찰) |
| 소요 시간 | 약 25분 |
| 확인 상태 | 미검증 (원본 강의 노트와 실습 명령 대본을 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1.md](lesson-1.md) | LEC-N2-12-001-DO | 서버 구축의 공통 문법 |
| [lesson-3.md](lesson-3.md) | LEC-N2-12-003-DO | FTP 서버 (vsftpd) |
| [lesson-1-lab.md](lesson-1-lab.md) | LEC-N2-12-011-MP | ufw 방화벽 켜기 실습 |
| [commands.md](commands.md) | LEC-N2-12-010-REF | 12일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Ubuntu Server VM | 24.04 LTS | 인터넷 연결(`apt`) 필요 |
| 2 | SSH 창 3개 | `ssh student@192.168.x.x` | `①` 작업, `②` 클라이언트, `③` 관찰 |
| 3 | 패키지 | `vsftpd`, `ftp` | 서버와 검증용 클라이언트 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: FTP는 비밀번호를 평문으로 보낸다. 이 실습은 VM 안의 `lo`(루프백) 구간에서만 캡처한다. 다른 사람의 통신을 캡처하지 않는다. 실습 뒤에는 FTP 서버를 끈다(7절).
{% endhint %}

{% hint style="warning" %}
CAUTION: `chroot_local_user=YES`를 켜면 `allow_writeable_chroot=YES`를 반드시 같이 추가한다. 빠뜨리면 `500 OOPS: vsftpd: refusing to run with writable root inside chroot()`로 접속이 거부된다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | SSH 창 3개를 연다 | 창마다 프롬프트가 보인다 |
| 2 | 인터넷이 된다 | `sudo apt update`가 오류 없이 끝난다 |
| 3 | 로그인에 쓸 리눅스 계정 비밀번호를 안다 | 문서에서는 `<password>`로 표기한다 |

## 5. 절차

### A. 설치 (창 ①)

1. (5-A-01) 목록을 갱신한다: `sudo apt update`
2. (5-A-02) 서버와 클라이언트를 설치한다: `sudo apt install vsftpd ftp -y` → 결과: 오류 없이 끝난다.

### B. 설정 (창 ①)

1. (5-B-01) 설정을 백업한다: `sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak`
2. (5-B-02) 편집기를 연다: `sudo nano /etc/vsftpd.conf`
3. (5-B-03) 아래 표에 따라 고친다(Ubuntu 24.04 기본 `vsftpd.conf` 기준).

| 줄 | 항목 | 기본 상태 | 할 일 |
|---|---|---|---|
| 25 | `anonymous_enable=NO` | 이미 NO | 그대로(확인만) |
| 28 | `local_enable=YES` | 이미 YES | 그대로(확인만) |
| 31 | `write_enable=YES` | `#` 주석 | 주석 해제 |
| 114 | `chroot_local_user=YES` | `#` 주석 | 주석 해제 |
| - | `allow_writeable_chroot=YES` | 파일에 없다 | 맨 아래에 새로 추가 |
| - | `pasv_min_port=40000` | 파일에 없다 | 맨 아래에 새로 추가 |
| - | `pasv_max_port=40010` | 파일에 없다 | 맨 아래에 새로 추가 |

4. (5-B-04) 맨 아래에 세 줄을 붙인다:

```
allow_writeable_chroot=YES
pasv_min_port=40000
pasv_max_port=40010
```

5. (5-B-05) 저장하고 나간다: `Ctrl+O`, `Enter`, `Ctrl+X`

### C. 기동과 확인 (창 ①)

1. (5-C-01) 재시작한다: `sudo systemctl restart vsftpd` → 결과: 오류 없이 끝난다.
2. (5-C-02) 상태를 본다: `systemctl status vsftpd --no-pager | head -5` → 결과: `active (running)`.
3. (5-C-03) 포트를 본다: `sudo ss -tulnp | grep -E ':21 '` → 결과: `0.0.0.0:21 LISTEN`.

{% hint style="info" %}
NOTE: 실패하면 `sudo journalctl -u vsftpd -n 20 --no-pager`를 본다. `refusing to run with writable root inside chroot()`가 보이면 `allow_writeable_chroot=YES`를 빠뜨린 것이다.
{% endhint %}

### D. 방화벽 개방 (창 ①, ufw를 켠 경우만)

1. (5-D-01) 제어 포트를 연다: `sudo ufw allow 21/tcp`
2. (5-D-02) 패시브 포트 범위를 연다: `sudo ufw allow 40000:40010/tcp` → 결과: `Rule added`가 보인다.

### E. 클라이언트 검증 (창 ②)

1. (5-E-01) 업로드할 파일을 만든다: `cd ~ ; echo "FTP 로 올릴 파일" > upload.txt`
2. (5-E-02) 접속한다: `ftp localhost`
3. (5-E-03) `Name:`에 `student`를 입력한다(리눅스 계정).
4. (5-E-04) `Password:`에 `<password>`를 입력한다. 화면에는 보이지 않는다. → 결과: `230 Login successful`.
5. (5-E-05) `ls`를 입력한다. → 결과: 홈 폴더의 목록이 나온다.
6. (5-E-06) `put upload.txt`를 입력한다. → 결과: `226 Transfer complete`.
7. (5-E-07) `get upload.txt downloaded.txt`를 입력한다. → 결과: `226 Transfer complete`.
8. (5-E-08) `bye`를 입력한다.

### F. 평문 캡처 (창 ③과 ②)

1. (5-F-01) 창 ③에서 캡처를 시작한다: `sudo tcpdump -i lo -n -A 'tcp port 21'`
2. (5-F-02) 창 ②에서 접속한다: `ftp localhost`
3. (5-F-03) 로그인만 하고 `bye`를 입력한다.
4. (5-F-04) 창 ③을 본다. → 결과: `USER student`와 `PASS ...` 줄이 그대로 보인다.
5. (5-F-05) 창 ③에서 `Ctrl+C`로 캡처를 멈춘다.

### G. 암호화 비교 (창 ③과 ②)

1. (5-G-01) 창 ③에서 캡처를 시작한다: `sudo tcpdump -i lo -n -A 'tcp port 22'`
2. (5-G-02) 창 ②에서 접속한다: `sftp student@192.168.x.x`
3. (5-G-03) 바로 `bye`를 입력한다.
4. (5-G-04) 창 ③을 본다. → 결과: 알아볼 수 없는 문자만 흐른다.
5. (5-G-05) `Ctrl+C`로 캡처를 멈춘다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `sudo ss -tulnp \| grep ':21 '` | LISTEN | `0.0.0.0:21`이 보인다 |
| 2 | `ftp localhost`에서 `put`과 `get` | 전송 성공 | `226 Transfer complete` 두 번 |
| 3 | FTP 캡처 | 평문 | `USER`, `PASS` 줄이 읽힌다 |
| 4 | SFTP 캡처 | 암호화 | 읽을 수 있는 계정 정보가 없다 |

수업 종료 시 점검: FTP가 연결을 두 개 쓰는 이유와 평문이 왜 문제인지 말할 수 있다.

## 7. 복구

1. (7-01) FTP 서버를 끈다: `sudo systemctl disable --now vsftpd` → 결과: `ss -tulnp | grep :21`에 아무것도 나오지 않는다.
2. (7-02) ufw 규칙을 지운다(5-D를 했다면): `sudo ufw status numbered`로 번호를 확인하고 `sudo ufw delete <번호>`를 두 번 실행한다.
3. (7-03) 설정을 원복한다(선택): `sudo cp /etc/vsftpd.conf.bak /etc/vsftpd.conf`

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-3.md`의 구축 절과 `commands.md` STEP 3을 AMM 형식 MP로 분리. 캡처 예시의 비밀번호 표기를 `<password>`로 바꿈 |
