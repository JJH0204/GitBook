# Bandit Level 10~20 풀이

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-CTF-007-TS |
| 유형 | TS (문제 해결, 풀이 방법론) |
| 목적 | Bandit 레벨 10에서 16까지 각 레벨의 목표와 접근 방법(인코딩 해독, 반복 압축 해제, 로컬 포트 접속)을 정리한다 |
| 확인 상태 | 미검증 (원본 메모를 정리한 것이며 레벨을 다시 풀어 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본 제목은 10~20이지만 내용은 레벨 15→16까지만 있다. 원본에 적힌 비밀번호와 SSH 개인 키 출력은 모두 삭제했다. 원본의 한국어 번역 인용 블록은 목표 설명으로 합쳤다. 레벨 11, 15의 명령은 원본에 없어 보충했으며 미검증이다. 플랫폼 소개는 [Bandit 워게임](badit.md) (SEC-CTF-002-DO)이다.
{% endhint %}

{% hint style="danger" %}
WARNING: 이 문서의 접속과 포트 연결은 워게임 운영자가 허용한 Bandit 서버에서만 수행한다. 허가받지 않은 시스템에 수행하는 것은 불법이다.
{% endhint %}

## 1. 증상

| 레벨 | 목표 |
|---|---|
| 10→11 | `data.txt`가 Base64로 인코딩돼 있다 |
| 11→12 | `data.txt`의 알파벳이 13칸 회전(ROT13)돼 있다 |
| 12→13 | `data.txt`가 여러 번 압축된 파일의 헥스 덤프다. `/tmp` 아래에 작업 디렉터리를 만들어 푼다 |
| 13→14 | `/etc/bandit_pass/bandit14`는 사용자 `bandit14`만 읽을 수 있다. 이 레벨은 비밀번호 대신 다음 레벨 접속용 SSH 개인 키를 준다 |
| 14→15 | 현재 레벨 비밀번호를 `localhost`의 30000번 포트에 제출하면 다음 비밀번호가 나온다 |
| 15→16 | 현재 레벨 비밀번호를 `localhost`의 30001번 포트에 SSL/TLS로 제출하면 다음 비밀번호가 나온다 |

## 2. 가능 원인

| 레벨 | 원인(문제가 쓰는 개념) |
|---|---|
| 10→11 | Base64는 암호화가 아니라 인코딩이다. 누구나 되돌릴 수 있다 |
| 11→12 | ROT13은 고정된 치환이다. 같은 연산을 다시 하면 복원된다 |
| 12→13 | 압축 형식은 파일 앞부분의 매직 넘버로 식별한다. 확장자는 중요하지 않다 |
| 13→14 | 개인 키는 비밀번호 없이 인증하는 수단이다 |
| 14→15 | 서비스는 포트로 구분되며 `nc`로 직접 접속할 수 있다 |
| 15→16 | TLS 서비스에는 TLS 클라이언트(`openssl s_client`)가 필요하다 |

## 3. 격리 절차와 시정 조치 (풀이 방법)

### 3.1 레벨 10→11

1. (3.1-01) 디코딩한다: `base64 -d data.txt` → 결과: 비밀번호가 든 문장이 나온다.

### 3.2 레벨 11→12

1. (3.2-01) 알파벳을 13칸 회전시킨다: `cat data.txt | tr 'A-Za-z' 'N-ZA-Mn-za-m'` → 결과: 평문이 나온다.

{% hint style="info" %}
NOTE: 원본은 이 레벨의 명령을 적지 않았다. 위 `tr` 명령은 ROT13의 일반적인 구현이며 미검증이다.
{% endhint %}

### 3.3 레벨 12→13

1. (3.3-01) 작업 디렉터리를 만든다: `mktemp -d` → 결과: 추측하기 어려운 이름의 임시 디렉터리가 생긴다.
2. (3.3-02) 데이터 파일을 복사한다: `cp data.txt <작업 디렉터리>/`
3. (3.3-03) 헥스 덤프를 원래 바이너리로 되돌린다: `xxd -r data.txt origin.gz`
4. (3.3-04) 파일 유형을 확인한다: `file origin.gz`
5. (3.3-05) 유형에 맞게 확장자를 바꾸고 푼다.

| 파일 유형 출력 | 확장자 | 해제 명령 |
|---|---|---|
| `gzip compressed data` | `.gz` | `gzip -d <파일>` |
| `bzip2 compressed data` | `.bz2` | `bzip2 -d <파일>` |
| `POSIX tar archive` | `.tar` | `tar -xf <파일>` |

6. (3.3-06) 3.3-04와 3.3-05를 파일 유형이 텍스트(`ASCII text`)가 될 때까지 반복한다. → 결과: 비밀번호가 든 파일이 나온다. 원본의 경우 gzip, bzip2, gzip, tar, tar, bzip2 순서의 압축이 여러 번 겹쳐 있었다.

### 3.4 레벨 13→14

1. (3.4-01) 받은 개인 키로 다음 레벨에 접속한다: `ssh -i ./sshkey.private bandit14@localhost -p 2220` → 결과: `bandit14` 계정으로 접속된다.
2. (3.4-02) 접속한 뒤 `/etc/bandit_pass/bandit14`를 읽어 현재 레벨 비밀번호를 얻는다: `cat /etc/bandit_pass/bandit14`

### 3.5 레벨 14→15

1. (3.5-01) 앞 단계에서 얻은 비밀번호를 `nc localhost 30000`으로 연결한 뒤 입력해 제출한다. → 결과: 다음 레벨 비밀번호가 응답으로 나온다.

{% hint style="info" %}
NOTE: 원본은 `nc` 명령을 적지 않고 사용 가능한 명령 목록만 적었다. `nc localhost 30000`은 보충이며 미검증이다.
{% endhint %}

### 3.6 레벨 15→16

1. (3.6-01) TLS로 연결한다: `openssl s_client -connect localhost:30001` → 결과: 연결과 인증서 정보가 출력된다.
2. (3.6-02) 현재 레벨 비밀번호를 입력해 제출한다. → 결과: 다음 레벨 비밀번호가 응답으로 나온다.

{% hint style="info" %}
NOTE: 응답에 `DONE`, `RENEGOTIATING`, `KEYUPDATE`가 나오면 `openssl s_client` 맨 페이지의 "CONNECTED COMMANDS" 절을 읽는다(원본 안내). 3.6절 명령은 보충이며 미검증이다.
{% endhint %}

## 4. 탐지·방어

| 항목 | 원인 | 완화 방법 |
|---|---|---|
| 인코딩 저장 | Base64·ROT13을 암호화로 착각한다 | 비밀은 인코딩이 아니라 암호화·해시로 보호한다 |
| 개인 키 노출 | 키 파일이 읽기 가능한 곳에 있다 | 키 권한을 `600`으로 제한하고 패스프레이즈를 건다 |
| 로컬 포트 서비스 | 비밀번호를 평문 포트로 받는다 | TLS를 쓰고 접근을 인증된 주체로 제한한다 |

{% hint style="info" %}
NOTE: 4절은 일반 지식으로 보충한 것이며 미검증이다.
{% endhint %}

## 5. 참조

| 구분 | 링크 |
|---|---|
| Base64 | [Base64 (Wikipedia)](https://en.wikipedia.org/wiki/Base64) |
| ROT13 | [ROT13 (Wikipedia)](https://en.wikipedia.org/wiki/ROT13) |
| 헥스 덤프 | [Hex dump (Wikipedia)](https://en.wikipedia.org/wiki/Hex_dump) |
| SSH 키 | [SSH/OpenSSH/Keys](https://help.ubuntu.com/community/SSH/OpenSSH/Keys) |
| TLS | [TLS (Wikipedia)](https://en.wikipedia.org/wiki/Transport_Layer_Security), [OpenSSL Cookbook](https://www.feistyduck.com/library/openssl-cookbook/online/testing-with-openssl/index.html) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 인코딩, 암호화, 압축은 각각 어떻게 다른가?
- [ ] 반복 압축 해제처럼 같은 일을 되풀이할 때 어떻게 자동화할 것인가?
