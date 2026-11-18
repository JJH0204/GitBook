# 비밀번호 복잡성 정책 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-ACC-011-MP |
| 목적 | `pwquality`로 비밀번호 최소 길이와 문자 구성 규칙을 설정한다 |
| 적용 대상 | RHEL 계열 Linux 8 이상 (`dnf` 사용), root 권한 필요 |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 페이지와 man 문서 지식을 정리한 것이며 이 문서로 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 원본 `account-management.md`의 "비밀번호 정책(복잡성) 설정" 절을 분리한 절차다. 키 설명은 LNX-ACC-001-REF를 따른다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [사용자 계정 관리 설정 파일](account-management.md) | LNX-ACC-001-REF | `pwquality.conf` 키 표 |
| [리눅스 비밀번호 암호화 구조](linuxpasswd.md) | LNX-ACC-005-DO | 해시 원리 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Linux 터미널 | RHEL 계열 8 이상 | |
| 2 | root 권한 | root 로그인 또는 `sudo` | |
| 3 | 편집기 | `vi` | |
| 4 | 시험용 계정 | 구역 C에서 쓸 임시 계정 | 실제 계정으로 시험하지 않는다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 정책은 이후 비밀번호를 바꿀 때 적용된다. 이미 설정된 비밀번호는 바뀌지 않는다. 너무 엄격한 값(예: `minlen = 20`)은 사용자가 비밀번호를 바꾸지 못하게 만든다.
{% endhint %}

{% hint style="info" %}
NOTE: root가 `passwd`로 다른 사용자의 비밀번호를 바꿀 때는 정책 위반이 경고만 출력되고 통과할 수 있다. 시험은 일반 사용자가 자신의 비밀번호를 바꾸는 방식으로 한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 설정 파일을 백업한다: `cp /etc/security/pwquality.conf /etc/security/pwquality.conf.bak` | `ls /etc/security/pwquality.conf.bak`가 파일을 보여 준다 |
| 2 | root 권한을 확인한다: `id -u` | 출력이 `0`이다 |

## 5. 절차

### A. 패키지 확인

1. (5-A-01) 설치 여부를 확인한다: `dnf list installed libpwquality` → 결과: `libpwquality` 한 줄이 나온다.
2. (5-A-02) 없으면 설치한다: `dnf install libpwquality` → 결과: 설치가 완료된다.

### B. 정책 설정

1. (5-B-01) 설정 파일을 연다: `vi /etc/security/pwquality.conf`
2. (5-B-02) 사용할 키의 앞 `#`을 지우고 값을 쓴다. 예: 최소 8자, 숫자 1개 이상, 대문자 1개 이상이다.

```
minlen = 8
dcredit = -1
ucredit = -1
```

3. (5-B-03) 저장하고 종료한다 → 결과: 파일이 저장된다.
4. (5-B-04) 설정 줄을 확인한다: `grep -E '^[a-z]' /etc/security/pwquality.conf` → 결과: 5-B-02에서 쓴 세 줄이 나온다.

### C. 정책 시험

1. (5-C-01) 시험용 계정을 만든다: LNX-ACC-002-MP로 `<시험 계정>`을 만들고 임시 비밀번호를 설정한다.
2. (5-C-02) 시험 계정으로 전환한다: `su - <시험 계정>`
3. (5-C-03) 비밀번호 변경을 실행한다: `passwd`
4. (5-C-04) 정책을 어기는 값(예: 소문자 5자)을 입력한다 → 결과: `BAD PASSWORD`로 시작하는 메시지가 나오고 거부된다.
5. (5-C-05) `exit`로 root로 돌아온다 → 결과: root 프롬프트가 나온다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 5-C-04의 약한 비밀번호 입력 | 거부된다 | `BAD PASSWORD` 메시지 |
| 2 | 규칙을 만족하는 값 입력 | 변경된다 | `all authentication tokens updated successfully` |

## 7. 복구

1. (7-01) 백업으로 되돌린다: `cp /etc/security/pwquality.conf.bak /etc/security/pwquality.conf` → 결과: 파일이 작업 전 상태다.
2. (7-02) 시험 계정을 삭제한다: LNX-ACC-004-MP의 구역 B를 따른다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지의 "비밀번호 정책(복잡성) 설정" 절을 절차로 분리해 새로 작성했다. 시험 단계와 복구를 추가했다 |
