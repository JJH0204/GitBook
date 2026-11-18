# 파일 권한 변경 (chmod, chown, umask)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-ACC-010-MP |
| 목적 | `chmod`로 권한을, `chown`으로 소유자와 그룹을, `umask`로 기본 권한을 바꾼다 |
| 적용 대상 | Linux 전반 (RHEL 계열 기준). `chmod`는 파일 소유자나 root, `chown`은 root 권한 필요 |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 페이지와 man 문서 지식을 정리한 것이며 이 문서로 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 새로 분리한 절차 문서다. 권한 표기와 원리는 LNX-ACC-008-DO를 따른다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [파일 및 디렉터리 접근 권한](permission.md) | LNX-ACC-008-DO | 권한 개념 |
| [계정·그룹 명령어 표](accountcommandsreference.md) | LNX-ACC-009-REF | 명령 옵션 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Linux 터미널 | | |
| 2 | 연습용 파일 | 새로 만든 `sample.txt`와 `sampledir` | 시스템 파일로 연습하지 않는다 |
| 3 | root 권한 | `sudo` | 구역 B에서 필요 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `chmod -R`와 `chown -R`를 `/`, `/etc`, `/usr` 같은 시스템 디렉터리에 실행하지 않는다. 시스템이 부팅되지 않거나 `sudo`, `ssh`가 동작하지 않을 수 있다. 대상 경로를 `ls -ld <경로>`로 확인한 뒤 실행한다.
{% endhint %}

{% hint style="danger" %}
WARNING: `chmod 777`은 모든 사용자에게 쓰기를 허용한다. 쓰지 않는다. 필요한 권한만 부여한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: umask는 셸에서 실행하면 그 셸에서만 적용된다. 영구 적용을 위한 `/etc/login.defs`나 `/etc/profile` 수정은 서버 전체에 영향을 주므로 이 문서에서 다루지 않는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 연습용 파일을 만든다: `touch sample.txt && mkdir sampledir` | `ls -ld sample.txt sampledir`가 두 항목을 보여 준다 |
| 2 | 현재 권한을 기록한다 | `ls -l sample.txt`의 첫 열을 적어 둔다 |

## 5. 절차

### A. 권한 변경 (chmod)

1. (5-A-01) 숫자로 지정한다: `chmod 755 sample.txt` → 결과: 출력 없이 끝난다.
2. (5-A-02) 확인한다: `ls -l sample.txt` → 결과: 첫 열이 `-rwxr-xr-x`다.
3. (5-A-03) 글자로 권한을 제거한다: `chmod ugo-r sample.txt` → 결과: 소유자, 그룹, 그 밖의 사용자의 읽기 권한이 사라진다.
4. (5-A-04) 글자로 권한을 추가한다: `chmod ugo+wx sample.txt` → 결과: 세 대상에 쓰기와 실행이 추가된다. (`u` 소유자, `g` 그룹, `o` 그 밖의 사용자, `a` 전체)
5. (5-A-05) 연습을 마치고 권한을 정리한다: `chmod 644 sample.txt` → 결과: `ls -l sample.txt`의 첫 열이 `-rw-r--r--`다.

### B. 소유자·그룹 변경 (chown)

1. (5-B-01) 소유자를 바꾼다: `sudo chown <사용자명> sample.txt` → 결과: 출력 없이 끝난다.
2. (5-B-02) 그룹만 바꾼다: `sudo chown :<그룹> sample.txt` → 결과: 출력 없이 끝난다.
3. (5-B-03) 소유자와 그룹을 함께 바꾼다: `sudo chown <사용자명>:<그룹> sample.txt` → 결과: `ls -l sample.txt`의 소유자와 그룹이 바뀐다.
4. (5-B-04) 디렉터리 아래 전체를 바꾼다: `sudo chown -R <사용자명>:<그룹> sampledir` → 결과: `sampledir` 안의 모든 항목이 바뀐다.

{% hint style="info" %}
NOTE: 원본은 `사용자.그룹`(점) 형식을 썼다. 점 형식은 오래된 표기라 일부 환경에서 경고가 난다. 콜론(`:`) 형식을 쓴다.
{% endhint %}

### C. 기본 권한 확인과 변경 (umask)

1. (5-C-01) 현재 umask를 확인한다: `umask` → 결과: `0022` 같은 값이 나온다.
2. (5-C-02) 새 파일을 만들어 권한을 본다: `touch umask-test && ls -l umask-test` → 결과: umask 022에서 `-rw-r--r--`(644)다.
3. (5-C-03) 이 셸에서만 umask를 바꾼다: `umask 077` → 결과: 출력 없이 끝난다.
4. (5-C-04) 새 파일을 만들어 확인한다: `touch umask-test2 && ls -l umask-test2` → 결과: `-rw-------`(600)이다.
5. (5-C-05) umask를 되돌린다: `umask 022` → 결과: 출력 없이 끝난다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `ls -l sample.txt` (5-A-05 후) | `-rw-r--r--` | 644 |
| 2 | `ls -l sample.txt` (5-B-03 후) | 소유자와 그룹이 지정값이다 | 5-B-03에서 지정한 값과 같다 |
| 3 | `umask` (5-C-05 후) | `0022` | 작업 전 값과 같다 |

## 7. 복구

1. (7-01) 연습 파일을 지운다: `rm -r sample.txt sampledir umask-test umask-test2`
2. (7-02) 소유자를 되돌려야 하면 4번 준비의 기록값으로 `chown`을 다시 실행한다.
3. (7-03) 새 셸을 열면 umask는 기본값으로 돌아온다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `permission.md`의 chmod, chown, umask 사용 예를 절차로 분리해 새로 작성했다. `chown` 점 형식을 콜론 형식으로 바꿨다 |
