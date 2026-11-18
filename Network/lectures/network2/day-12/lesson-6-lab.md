# Postfix와 SMTP 직접 입력 실습

> 상위: [12일차 · 리눅스 서버 구축](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-12-016-MP |
| 목적 | Postfix를 Local only로 설치하고, `nc`로 SMTP 대화를 직접 입력해 같은 서버의 사서함에 메일 한 통을 배달한다 |
| 적용 대상 | Ubuntu Server 24.04 LTS VM(9일차 VM). 오늘 수업에서는 하지 않고 13일차에 한다 |
| 소요 시간 | 약 15분 |
| 확인 상태 | 미검증 (원본 강의 노트와 실습 명령 대본을 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-5.md](lesson-5.md) | LEC-N2-12-005-DO | DNS 서버 (bind9) |
| [lesson-6.md](lesson-6.md) | LEC-N2-12-006-DO | 메일 서버 |
| [commands.md](commands.md) | LEC-N2-12-010-REF | 12일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Ubuntu Server VM | 24.04 LTS | 인터넷 연결(`apt`) 필요 |
| 2 | SSH 창 2개 | `ssh student@192.168.x.x` | `①` 작업, `②` 클라이언트 |
| 3 | 패키지 | `postfix`, `mailutils` | `nc`는 기본 설치돼 있다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 설치 중 파란 화면에서 `Internet Site`를 고르지 않는다. `Local only`를 고른다. Internet Site를 고르면 바깥으로 메일을 보내려다 실패 로그만 쌓인다.
{% endhint %}

{% hint style="info" %}
NOTE: 이 실습은 같은 서버의 계정(`student@localhost`)에게만 보낸다. 외부 주소로 보내지 않는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | SSH 창 2개를 연다 | 창마다 프롬프트가 보인다 |
| 2 | 인터넷이 된다 | `sudo apt update`가 오류 없이 끝난다 |
| 3 | 파란 화면 조작을 안다 | Tab으로 이동, Enter로 확정 |

## 5. 절차

### A. 설치 (창 ①)

1. (5-A-01) 설치한다: `sudo apt install postfix mailutils -y`
2. (5-A-02) 파란 화면이 나오면 `Local only`를 선택한다(Tab으로 이동, Enter로 확정). → 결과: 다음 화면으로 넘어간다.
3. (5-A-03) 메일 이름은 기본값 그대로 Enter를 누른다. → 결과: 설치가 끝난다.

### B. 확인 (창 ①)

1. (5-B-01) 상태를 본다: `systemctl status postfix --no-pager | head -5` → 결과: `active`.
2. (5-B-02) 포트를 본다: `sudo ss -tulnp | grep ':25 '` → 결과: `127.0.0.1:25`. 나 자신에게만 열려 있다.

### C. SMTP 대화 (창 ②)

1. (5-C-01) 접속한다: `nc localhost 25` → 결과: `220 ... ESMTP Postfix`로 서버가 인사한다.
2. (5-C-02) 아래를 한 줄씩 입력한다. 줄마다 응답 `250`(DATA는 `354`)을 확인한 뒤 다음 줄로 간다.

```
HELO student.local
MAIL FROM:<student@localhost>
RCPT TO:<student@localhost>
DATA
Subject: 12일차 첫 메일

리눅스 서버가 보낸 편지입니다.
.
QUIT
```

→ 결과: 마침표 한 줄 뒤에 `250 2.0.0 Ok: queued as ...`가 나온다.

{% hint style="info" %}
NOTE: 마침표 한 개만 있는 줄(`.`)이 본문 끝 신호다.
{% endhint %}

### D. 도착 확인 (창 ②)

1. (5-D-01) 사서함을 연다: `mail` → 결과: 방금 보낸 편지의 번호와 제목이 보인다.
2. (5-D-02) 번호를 입력해 읽고 `q`로 나간다. → 결과: 본문이 보인다.
3. (5-D-03) 파일로 확인한다: `cat /var/mail/student | tail -20`
4. (5-D-04) 배달 기록을 본다: `sudo tail -20 /var/log/mail.log` → 결과: 배달 기록이 보인다.

### E. 실제 도메인의 메일 설정 구경 (창 ②)

1. (5-E-01) MX를 조회한다: `dig +short MX gmail.com` → 결과: 메일 서버 이름이 나온다.
2. (5-E-02) TXT를 조회한다: `dig +short TXT gmail.com | head -3` → 결과: `v=spf1 ...`이 보인다(발신자 인증).

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `sudo ss -tulnp \| grep ':25 '` | 루프백에서만 LISTEN | `127.0.0.1:25` |
| 2 | `nc localhost 25`의 대화 | 큐에 들어간다 | `queued as`가 보인다 |
| 3 | `mail` | 편지가 있다 | 제목 `12일차 첫 메일`이 보인다 |

수업 종료 시 점검: `MAIL FROM`에 아무 주소나 쓸 수 있다는 사실이 무엇을 뜻하는지 말할 수 있다.

## 7. 복구

1. (7-01) Postfix를 끈다: `sudo systemctl disable --now postfix` → 결과: `ss -tulnp | grep ':25 '`에 아무것도 나오지 않는다.
2. (7-02) 받은 편지를 지운다(선택): `mail`에서 `d *`를 입력한 뒤 `q`로 나간다.
3. (7-03) 패키지를 제거한다(선택): `sudo apt remove postfix mailutils -y`

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-6.md`의 구축 절과 `commands.md` STEP 6을 AMM 형식 MP로 분리 |
