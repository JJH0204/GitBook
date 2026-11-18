# 로그인 실패 계정 잠금 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-ACC-012-MP |
| 목적 | 로그인 실패 횟수에 따른 자동 잠금(`faillock`)을 설정하고, 잠긴 계정을 확인해 해제한다 |
| 적용 대상 | RHEL 계열 Linux 8.2 이상, root 권한 필요 |
| 소요 시간 | 약 15분 |
| 확인 상태 | 미검증 (원본 페이지와 man 문서 지식을 정리한 것이며 이 문서로 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 "계정 잠금 인계값"(임계값) 절을 절차로 분리했다. 배포판 버전에 따라 `faillock` 기능이 PAM 설정에서 꺼져 있을 수 있다. 5-A-02에서 활성 여부를 확인한다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [사용자 계정 관리 설정 파일](account-management.md) | LNX-ACC-001-REF | `faillock.conf`, shadow 필드 표 |
| [계정·그룹 명령어 표](accountcommandsreference.md) | LNX-ACC-009-REF | `passwd -l/-u`, `usermod -L/-U` |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Linux 터미널 | RHEL 계열 8.2 이상 | |
| 2 | root 권한이 있는 두 번째 세션 | 콘솔 또는 별도 SSH 세션 | 설정 중 잠금 사고에 대비한다 |
| 3 | 시험용 계정 | 임시 계정 | root나 실제 계정으로 시험하지 않는다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 잠금 설정을 잘못하면 관리자 계정을 포함한 모든 계정이 로그인 불가가 될 수 있다. 설정하는 동안 root 세션 하나를 열어 둔 채 유지하고, 시험이 끝나기 전에 닫지 않는다.
{% endhint %}

{% hint style="danger" %}
WARNING: shadow 비밀번호 필드가 `!!`인 계정(비밀번호가 없는 시스템 계정)에 `passwd -u`를 실행하면 비밀번호가 빈 계정이 될 수 있다. `passwd`가 `Unsafe operation` 경고를 내면 `-f`로 강제하지 않는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `deny` 값이 너무 작으면(예: 1) 오타 한 번에 잠긴다. 3 이상으로 설정한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 설정 파일을 백업한다: `cp /etc/security/faillock.conf /etc/security/faillock.conf.bak` | 백업 파일이 있다 |
| 2 | 두 번째 root 세션을 연다 | 두 세션 모두 `id -u`가 `0`이다 |
| 3 | 시험용 계정을 만든다 | LNX-ACC-002-MP를 따른다 |

## 5. 절차

### A. 잠금 설정

1. (5-A-01) 설정 파일을 연다: `vi /etc/security/faillock.conf`
2. (5-A-02) 아래 키의 앞 `#`을 지우고 값을 쓴다 → 결과: 설정이 저장된다.

```
deny = 3
fail_interval = 900
unlock_time = 600
```

3. (5-A-03) PAM에서 `faillock`이 활성인지 확인한다: `grep -r faillock /etc/pam.d/` → 결과: `system-auth`와 `password-auth`에 `pam_faillock.so` 줄이 있다. 없으면 `authselect current`로 프로필을 확인하고, 조직 절차에 따라 `authselect enable-feature with-faillock`을 실행한다.

### B. 잠금 시험

1. (5-B-01) 시험 계정으로 로그인을 3회 실패시킨다. 예: 다른 터미널에서 `su - <시험 계정>`을 틀린 비밀번호로 3회 실행한다 → 결과: 4번째 시도부터 올바른 비밀번호도 거부된다.
2. (5-B-02) 실패 기록을 확인한다: `faillock --user <시험 계정>` → 결과: 실패 시도 목록이 나온다.

### C. 잠금 해제

1. (5-C-01) 로그인 실패로 인한 잠금을 푼다: `faillock --user <시험 계정> --reset` → 결과: 출력 없이 끝난다.
2. (5-C-02) 해제를 확인한다: `faillock --user <시험 계정>` → 결과: 실패 기록이 비어 있다.

### D. 수동 잠금 계정 조회와 해제

`passwd -l`이나 `usermod -L`로 관리자가 잠근 계정은 `faillock`이 아니라 shadow 필드로 구분한다.

1. (5-D-01) 잠긴 계정을 찾는다: `awk -F: '$2 ~ /^!/ {print $1}' /etc/shadow` → 결과: 잠겼거나 비밀번호가 없는 계정 이름이 나온다. 시스템 계정이 다수 포함된다.
2. (5-D-02) 대상의 상태를 확인한다: `passwd -S <사용자명>` → 결과: 두 번째 필드가 `LK`다.
3. (5-D-03) 비밀번호가 설정된 계정만 해제한다: `passwd -u <사용자명>` → 결과: `Unlocking password for user <사용자명>.`과 `passwd: Success`가 나온다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 5-B-01 | 3회 실패 후 잠긴다 | 4번째 시도가 거부된다 |
| 2 | 5-C-01 후 로그인 | 로그인된다 | 올바른 비밀번호로 로그인된다 |

## 7. 복구

1. (7-01) 설정을 되돌린다: `cp /etc/security/faillock.conf.bak /etc/security/faillock.conf`
2. (7-02) 시험 계정을 삭제한다: LNX-ACC-004-MP의 구역 B를 따른다.

## 8. 참조 자료

* [awk 사용법 (tistory)](https://recipes4dev.tistory.com/171)

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지의 `faillock.conf`와 계정 잠금 해제 설명을 절차로 분리해 새로 작성했다. `faillock --reset` 절차와 잠금 사고 대비 단계를 추가했다. 원본의 `passwd -u sshd` 예시는 `Unsafe operation` 경고가 나는 사례라 WARNING으로 바꿨다 |
