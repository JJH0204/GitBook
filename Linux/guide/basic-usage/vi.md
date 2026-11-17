# vi 편집기 사용법

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-BAS-003-MP |
| 목적 | `vi`로 파일을 열고 편집해 저장하고 종료한다 |
| 적용 대상 | Linux 전반(RHEL 계열 실습 환경 포함), `vi` 또는 `vim` 설치, 일반 사용자 권한(대상 파일에 쓰기 권한 필요) |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 문서로 다시 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [vimodes.md](vimodes.md) | LNX-BAS-002-DO | vi 편집 모드 |
| [vireference.md](vireference.md) | LNX-BAS-004-REF | vi 명령 키 표 |
| [FreeCodeCamp: Vim beginner's guide](https://www.freecodecamp.org/news/vim-beginners-guide/) | | 외부 문서 |
| [Red Hat: Get started with the vi editor](https://www.redhat.com/sysadmin/get-started-vi-editor) | | 외부 문서 |
| [Red Hat: Introduction to the vi editor](https://www.redhat.com/sysadmin/introduction-vi-editor) | | 외부 문서 |
| [FOSS Linux: How to use the vi editor](https://www.fosslinux.com/27013/how-to-use-the-vi-editor-in-linux-with-examples.htm) | | 외부 문서 |
| [TutorialsPoint: Unix vi editor](https://www.tutorialspoint.com/unix/unix-vi-editor.htm) | | 외부 문서 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 터미널 | Linux 셸 | |
| 2 | `vi` 또는 `vim` | 설치된 버전 | `vi --version` 또는 `which vi`로 확인한다 |
| 3 | 연습 파일 | `~/vi-test.txt` | 구역 A에서 만든다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `:q!`와 `ZQ`는 저장하지 않은 변경을 모두 버린다. 되돌릴 수 없다. 5-D-03 단계 전에 버려도 되는 내용인지 확인한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 중요한 시스템 설정 파일(`/etc/` 아래)을 편집하기 전에 `cp <파일> <파일>.bak`으로 복사본을 만든다. 잘못 저장하면 서비스가 시작되지 않을 수 있다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 터미널을 연다 | 프롬프트가 나타난다 |
| 2 | `vi`가 있는지 확인한다: `which vi` | 경로가 출력된다 |
| 3 | 모드 개념을 읽는다 | LNX-BAS-002-DO를 읽었다 |

## 5. 절차

### A. 파일 열기

1. (5-A-01) 연습 파일을 연다: `vi ~/vi-test.txt` → 결과: 빈 화면이 나타나고 `vi`가 명령 모드로 시작한다.

### B. 글자 입력

1. (5-B-01) 삽입 모드로 전환한다: `i`를 누른다 → 결과: 화면 아래에 `-- INSERT --`가 나타난다(vim 기준).
2. (5-B-02) 글자를 입력한다: `hello vi` → 결과: 글자가 화면에 나타난다.
3. (5-B-03) 명령 모드로 돌아간다: `Esc`를 누른다 → 결과: `-- INSERT --` 표시가 사라진다.

### C. 저장

1. (5-C-01) 마지막 행 모드로 들어간다: `:`를 입력한다 → 결과: 화면 맨 아래에 `:`가 나타난다.
2. (5-C-02) 저장 명령을 입력한다: `w`를 입력하고 `Enter`를 누른다 → 결과: 화면 아래에 저장된 줄 수와 글자 수가 나타난다.

### D. 종료

1. (5-D-01) 변경 없이 종료할 때: `:q`를 입력하고 `Enter`를 누른다. → 결과: 셸 프롬프트로 돌아간다. 저장하지 않은 변경이 있으면 종료되지 않고 경고가 나타난다.
2. (5-D-02) 저장하고 종료할 때: `:wq`를 입력하고 `Enter`를 누른다. 명령 모드에서 `ZZ`를 눌러도 같다. → 결과: 셸 프롬프트로 돌아간다.

{% hint style="danger" %}
WARNING: 다음 단계는 저장하지 않은 변경을 버린다.
{% endhint %}

3. (5-D-03) 저장하지 않고 강제 종료할 때: `:q!`를 입력하고 `Enter`를 누른다. → 결과: 변경을 버리고 셸 프롬프트로 돌아간다.

### E. 다시 열어 확인

1. (5-E-01) 파일 내용을 출력한다: `cat ~/vi-test.txt` → 결과: `hello vi`가 출력된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `cat ~/vi-test.txt` | 입력한 내용이 출력된다 | `hello vi` 출력 |
| 2 | `vi ~/vi-test.txt` 후 `:q` | 변경이 없으면 바로 종료된다 | 경고 없이 프롬프트로 돌아온다 |

## 7. 복구

1. (7-01) 실수로 편집한 내용을 되돌린다: 명령 모드에서 `u`를 누른다. → 결과: 직전 변경이 취소된다.
2. (7-02) 연습 파일을 지운다: `rm ~/vi-test.txt`

{% hint style="danger" %}
WARNING: `rm`은 되돌릴 수 없다. 경로가 연습 파일인지 확인한 뒤 실행한다.
{% endhint %}

3. (7-03) 시스템 파일을 잘못 저장했다면 백업에서 복원한다: `cp <파일>.bak <파일>` (권한이 필요하면 `sudo`).

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지 `vi.md`를 AMM 형식으로 재작성. 모드 설명은 LNX-BAS-002-DO로, 키 목록은 LNX-BAS-004-REF로 분리. 외부 링크는 참조 절로 이동, 검색 링크 삭제. `u` 실행 취소 추가 |
