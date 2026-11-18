# macOS 환경 변수 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-ENV-002-MP |
| 목적 | macOS 터미널에서 환경 변수를 확인하고, 임시 또는 영구로 설정한다 |
| 적용 대상 | macOS, 기본 셸 zsh (bash를 쓰는 경우는 NOTE 참조) |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리하고 설정 방법을 보충한 것이며 직접 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본 페이지에는 "새 환경 변수 설정" 단계의 내용이 없었다. 구역 C와 D는 이번 개정에서 보충한 내용이다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [macOS Python 환경 설정](pythonidesetupformac.md) | DEV-ENV-001-MP | pyenv 설치 시 `~/.zshrc`를 수정한다 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | macOS 터미널 | `Terminal.app` 또는 iTerm2 | |
| 2 | 텍스트 편집기 | `nano`(기본 제공) 또는 VS Code | 구역 D에서 사용 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: `~/.zshrc`의 `PATH` 줄을 잘못 쓰면 `ls`, `git` 같은 명령을 찾지 못한다. 수정 전에 7절의 백업 단계(7-01)를 먼저 수행한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 터미널을 연다 | 프롬프트가 나타난다 |
| 2 | 사용 중인 셸을 확인한다: `echo $SHELL` | `/bin/zsh`가 출력되면 zsh이고 `/bin/bash`가 출력되면 bash다 |

{% hint style="info" %}
NOTE: macOS 10.15(Catalina) 이후 기본 셸은 zsh이며 설정 파일은 `~/.zshrc`다. bash를 쓰면 `~/.bash_profile`을 수정한다. 이 문서의 `~/.zshrc`는 bash에서 `~/.bash_profile`로 바꿔 읽는다.
{% endhint %}

## 5. 절차

### A. 전체 환경 변수 확인

1. (5-A-01) 전체 환경 변수를 출력한다: `printenv` → 결과: `NAME=값` 형식의 줄이 여러 개 출력된다.
2. (5-A-02) 출력에서 `SHELL`, `HOME`, `PATH`, `LANG` 줄을 찾는다. → 결과: 아래 예와 같은 형식의 줄이 보인다.

{% code title="printenv 출력 (일부, 값은 환경마다 다르다)" %}
```
SHELL=/bin/zsh
HOME=/Users/<사용자명>
USER=<사용자명>
PATH=/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
LANG=ko_KR.UTF-8
HOMEBREW_PREFIX=/opt/homebrew
```
{% endcode %}

### B. 특정 환경 변수 확인

1. (5-B-01) 변수 하나의 값을 출력한다: `echo $<변수 이름>` → 결과: 그 변수의 값이 한 줄로 출력된다. 변수가 없으면 빈 줄이 출력된다.
2. (5-B-02) `PATH`를 확인한다: `echo $PATH` → 결과: 디렉터리가 `:`로 이어진 한 줄이 출력된다.
3. (5-B-03) `PATH`를 한 줄에 하나씩 보려면 다음을 입력한다: `echo $PATH | tr ':' '\n'` → 결과: 디렉터리가 줄마다 하나씩 출력된다.

{% hint style="info" %}
NOTE: `PATH`는 명령어를 찾는 디렉터리 목록이다. 앞에 있는 디렉터리가 먼저 검색된다.
{% endhint %}

### C. 환경 변수 임시 설정 (현재 터미널 창에만 적용)

1. (5-C-01) 변수를 설정한다: `export <변수 이름>="<값>"` (예: `export MY_NAME="demo"`) → 결과: 출력 없이 끝난다.
2. (5-C-02) 값을 확인한다: `echo $<변수 이름>` → 결과: 설정한 값이 출력된다.
3. (5-C-03) 터미널 창을 닫고 새로 연다. 같은 명령을 다시 실행한다. → 결과: 빈 줄이 출력된다. 임시 설정은 새 창에 유지되지 않는다.

### D. 환경 변수 영구 설정

1. (5-D-01) 설정 파일을 만들거나 연다: `nano ~/.zshrc` → 결과: 편집기 화면이 열린다.
2. (5-D-02) 파일 맨 아래에 줄을 추가한다. → 결과: 아래 예 중 하나가 입력된다.

{% code title="~/.zshrc" %}
```bash
# 새 변수 추가
export MY_NAME="demo"

# PATH 앞쪽에 디렉터리 추가 (기존 PATH를 반드시 뒤에 붙인다)
export PATH="<추가할 디렉터리>:$PATH"
```
{% endcode %}

3. (5-D-03) 저장하고 닫는다: `Ctrl+O`, `Enter`, `Ctrl+X` → 결과: 터미널 프롬프트로 돌아온다.
4. (5-D-04) 현재 창에 반영한다: `source ~/.zshrc` → 결과: 오류 없이 끝난다. 새로 여는 터미널 창에는 자동으로 반영된다.
5. (5-D-05) 값을 확인한다: `echo $MY_NAME` → 결과: `demo`가 출력된다.

{% hint style="danger" %}
WARNING: `export PATH="<추가할 디렉터리>"`처럼 `:$PATH`를 빼면 기존 PATH가 사라져 대부분의 명령이 동작하지 않는다. 이때는 터미널 창을 닫고 새로 열어 7-01의 백업으로 되돌린다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 새 터미널 창을 열고 `echo $MY_NAME` | 설정한 값이 출력된다 | `demo` 출력 |
| 2 | `echo $PATH \| tr ':' '\n'` | 추가한 디렉터리가 목록에 있다 | 추가한 디렉터리가 보인다 |
| 3 | `which ls` | 경로가 출력된다 | `/bin/ls` 출력 |

## 7. 복구

1. (7-01) 수정 전에 백업한다: `cp ~/.zshrc ~/.zshrc.bak` (파일이 없으면 이 단계는 건너뛴다.)
2. (7-02) 설정 파일에서 추가한 줄을 지운다: `nano ~/.zshrc`
3. (7-03) 현재 창의 변수를 지운다: `unset MY_NAME` → 결과: `echo $MY_NAME`이 빈 줄을 출력한다.
4. (7-04) 파일이 망가졌다면 백업으로 되돌린다: `cp ~/.zshrc.bak ~/.zshrc`

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지 `macosenvvariablesetup.md`를 AMM 형식으로 재작성. 출력 예의 사용자명·경로를 일반화하고, 내용이 없던 설정 방법(zsh/bash 구분, `export`, 영구 설정)을 보충 |
