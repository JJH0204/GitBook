# Bandit Level 01~10 풀이

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-CTF-006-TS |
| 유형 | TS (문제 해결, 풀이 방법론) |
| 목적 | Bandit 레벨 0에서 10까지 각 레벨의 목표와 접근 방법(사용 명령어, 개념)을 정리한다 |
| 확인 상태 | 미검증 (원본 메모를 정리한 것이며 레벨을 다시 풀어 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본에 적힌 각 레벨의 비밀번호는 모두 삭제했다. 원본에 없던 명령(레벨 0~4의 파일 읽기 명령)은 파일명 규칙을 설명하려고 보충했으며 미검증이다. SSH 접속 호스트는 `<Bandit 호스트>`로 적는다. 플랫폼 소개는 [Bandit 워게임](badit.md) (SEC-CTF-002-DO)이다.
{% endhint %}

{% hint style="danger" %}
WARNING: Bandit 서버는 워게임 운영자가 풀이를 허용한 환경이다. 같은 명령을 허가받지 않은 서버에서 쓰는 것은 불법이다.
{% endhint %}

## 1. 증상

각 레벨의 목표는 "다음 레벨 비밀번호가 있는 곳을 찾는 것"이다. 접속은 `ssh bandit<레벨 번호>@<Bandit 호스트> -p 2220`로 한다.

## 2. 가능 원인

| 레벨 | 목표 | 핵심 개념 |
|---|---|---|
| 0→1 | 홈 디렉터리의 `readme` 파일을 읽는다 | `ls`, `cat` |
| 1→2 | 이름이 `-`인 파일을 읽는다 | 옵션으로 오해되는 파일명 |
| 2→3 | 이름에 공백이 있는 파일을 읽는다 | 공백이 든 파일명 처리 |
| 3→4 | `inhere`의 숨김 파일을 읽는다 | 숨김 파일 (`ls -a`) |
| 4→5 | `inhere`에서 사람이 읽을 수 있는 유일한 파일을 읽는다 | `file`로 파일 유형 확인 |
| 5→6 | 사람이 읽을 수 있고, 1033바이트이며, 실행 불가인 파일을 찾는다 | `find` 조건 조합 |
| 6→7 | 서버 전체에서 소유자 `bandit7`, 그룹 `bandit6`, 33바이트인 파일을 찾는다 | `find` 소유자·그룹·크기 조건 |
| 7→8 | `data.txt`에서 `millionth` 옆 단어를 찾는다 | `grep` |
| 8→9 | `data.txt`에서 한 번만 나오는 줄을 찾는다 | `sort`, `uniq -u` |
| 9→10 | `data.txt`의 읽을 수 있는 문자열 중 `=` 여러 개 뒤의 것을 찾는다 | `strings` |

## 3. 격리 절차와 시정 조치 (풀이 방법)

### 3.1 레벨 0→1, 1→2, 2→3, 3→4

1. (3.1-01) 홈 디렉터리 파일을 확인한다: `ls` → 결과: 파일 목록이 보인다.
2. (3.1-02) 파일을 읽는다: `cat readme` → 결과: 다음 레벨 비밀번호가 나온다.
3. (3.1-03) 이름이 `-`인 파일은 경로를 붙여 읽는다: `cat ./-` → 결과: `-`가 옵션이 아니라 파일명으로 해석된다.
4. (3.1-04) 공백이 든 이름은 따옴표로 감싼다: `cat "spaces in this filename"`
5. (3.1-05) 숨김 파일은 `ls -a inhere`로 찾아 읽는다.

{% hint style="info" %}
NOTE: 원본은 이 네 레벨의 명령을 적지 않았다. 3.1절 명령은 레벨 목표 문구에서 도출한 것이며 미검증이다. 원본에는 "비밀번호는 서버가 저장하지 않으므로 직접 메모하라"는 안내가 있었다.
{% endhint %}

### 3.2 레벨 4→5

원본의 방법은 타입이 파일인 항목의 유형을 출력하는 것이다.

```sh
find . -type f -exec file {} +
```

1. 위 명령을 실행한다. → 결과: 각 파일의 유형이 나온다.
2. `ASCII text`로 표시된 파일을 읽는다.

### 3.3 레벨 5→6

원본은 `grep -v`로 특정 문자열을 제외하는 방법을 쓴다.

```sh
find . -type f -size 1033c ! -perm /a=x -exec file {} + | grep -i "ASCII text" | grep -v "with very long"
```

| 조건 | 뜻 |
|---|---|
| `-size 1033c` | 크기가 1033바이트 |
| `! -perm /a=x` | 누구에게도 실행 권한이 없음 |
| `grep -i "ASCII text"` | 사람이 읽을 수 있는 파일 |
| `grep -v "with very long"` | "with very long lines"가 든 줄 제외 |

크기 조건만 줘도 후보가 하나로 좁혀지는 경우가 있다: `find . -type f -size 1033c`

### 3.4 레벨 6→7

```sh
find / -type f -user bandit7 -group bandit6 -size 33c 2>/dev/null
```

| 옵션 | 뜻 |
|---|---|
| `-user <사용자 이름>` | 소유자 조건 |
| `-group <그룹 이름>` | 그룹 조건 |
| `2>/dev/null` | 표준 오류(2번)를 버려 권한 오류 출력을 없앤다 |

### 3.5 레벨 7→8, 8→9, 9→10

1. (3.5-01) 레벨 7→8: `grep millionth data.txt` → 결과: `millionth`가 든 줄이 나온다.
2. (3.5-02) 레벨 8→9: `sort data.txt | uniq -u` → 결과: 한 번만 나오는 줄이 나온다. `sort`는 같은 줄이 이웃하도록 정렬하고, `uniq -u`는 중복 없는 줄만 출력한다.
3. (3.5-03) 레벨 9→10: `strings data.txt` → 결과: 읽을 수 있는 문자열이 나오며, `=` 여러 개 뒤의 줄이 대상이다.

## 4. 참조

| 구분 | 링크 |
|---|---|
| 명령어 설명 | [ls](https://manpages.ubuntu.com/manpages/noble/man1/ls.1.html), [cat](https://manpages.ubuntu.com/manpages/noble/man1/cat.1.html), [file](https://manpages.ubuntu.com/manpages/noble/man1/file.1.html), [find](https://manpages.ubuntu.com/manpages/noble/man1/find.1.html), [grep](https://manpages.ubuntu.com/manpages/noble/man1/grep.1.html) |
| 파이프와 리다이렉션 | [Piping and Redirection](https://ryanstutorials.net/linuxtutorial/piping.php) |
| 파일명 처리 | [Advanced Bash-scripting Guide - Special Characters](https://linux.die.net/abs-guide/special-chars.html) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `find`의 조건을 조합하면 어떻게 후보를 줄이는가?
- [ ] 이 레벨들에서 처음 알게 된 명령어와 그 쓰임은 무엇인가?
