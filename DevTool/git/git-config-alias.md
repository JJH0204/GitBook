# [생성형 AI] Git 설정 범위와 별칭 (config·alias)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-GIT-022-REF |
| 목적 | `git config`의 세 범위와 자주 쓰는 설정·별칭을 찾아 쓴다 |
| 적용 대상 | Git 2.23 이상, Windows·macOS·Linux |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (Git 2.53.0, Linux, 2026-11-19. 임시 설정 파일과 임시 저장소에서 아래 명령을 실행해 출력을 확인했다. `core.editor`, `core.autocrlf`는 값 저장만 확인했고 편집기 동작은 확인하지 않았다) |
| 개정 | R1 (2026-11-19) |

사용자 이름과 이메일의 첫 설정은 DEV-GIT-002-MP를 따른다.

## 범위

| 범위 | 옵션 | 저장 위치 | 적용 대상 |
|---|---|---|---|
| system | `--system` | Git 설치 폴더 | 이 컴퓨터의 모든 사용자 |
| global | `--global` | 사용자 홈의 `.gitconfig` | 이 사용자의 모든 저장소 |
| local | `--local` (기본) | 저장소의 `.git/config` | 그 저장소만 |

좁은 범위가 이긴다. 같은 키가 global과 local에 있으면 local 값이 쓰인다.

실행 예: global에 `Global Name`, local에 `Local Name`을 설정한 뒤 확인한다.

```text
$ git config user.name
Local Name
$ git config --show-origin --show-scope --get-all user.name
global	file:<경로>/.gitconfig	Global Name
local	file:.git/config	Local Name
```

## 조회·수정 명령

| 목적 | 명령 | 출력·결과 |
|---|---|---|
| 값 하나 읽기 | `git config <키>` | 유효한 값 하나 |
| 전체 목록과 범위 | `git config --list --show-scope` | `global	user.name=...`처럼 범위가 앞에 붙는다 |
| 어느 파일에서 왔는지 | `git config --list --show-origin` | `file:<경로>	<키>=<값>` |
| 설정하기 | `git config --global <키> "<값>"` | 출력 없음 |
| 지우기 | `git config --global --unset <키>` | 출력 없음 |
| 파일 직접 편집 | `git config --global --edit` | 에디터가 열린다 |

## 자주 쓰는 설정

| 키 | 값 예 | 효과 |
|---|---|---|
| `init.defaultBranch` | `main` | `git init`이 만드는 첫 브랜치 이름 |
| `pull.rebase` | `true` | `git pull`이 병합 대신 재배치를 한다(DEV-GIT-015-MP) |
| `core.editor` | `nano` | 커밋 메시지 에디터 |
| `core.autocrlf` | `input` | 커밋 시 줄 끝 CRLF를 LF로 바꾼다(macOS·Linux 권장). Windows는 `true`가 흔하다 |

## 별칭(alias)

| 설정 명령 | 이후 입력 | 동작 |
|---|---|---|
| `git config --global alias.st "status -sb"` | `git st` | 짧은 상태 표시 |
| `git config --global alias.lg "log --oneline --graph --all"` | `git lg` | 모든 브랜치의 그래프 |

별칭 목록은 `git config --global --get-regexp '^alias'`로 본다. 지울 때는 `git config --global --unset alias.<이름>`을 쓴다.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 신규 작성 (생성형 AI 초안) |
