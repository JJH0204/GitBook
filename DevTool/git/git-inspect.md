# [생성형 AI] 상태·이력 확인 명령 정리

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-GIT-014-REF |
| 유형 | REF (명령어 표) |
| 목적 | 변경과 이력을 읽는 `status`, `diff`, `log`, `show`, `blame`, `grep`의 쓰임을 참조한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (Git 2.53.0, Linux, 2026-11-19에서 표의 명령을 임시 저장소에서 실행해 오류 없이 출력되는 것을 확인했다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 명령들은 읽기 전용이다. 저장소를 바꾸지 않는다.
{% endhint %}

## 1. 현재 상태

| 명령 | 보여 주는 것 |
|---|---|
| `git status` | 브랜치, 스테이징 여부, untracked 파일을 설명문과 함께 보여 준다 |
| `git status -s` | 같은 내용을 두 글자 코드로 줄여 보여 준다(`??`, `A`, `M`, `D`, `UU`) |
| `git status -sb` | 짧은 출력에 브랜치와 원격 대비 `ahead`/`behind`를 붙인다 |
| `git branch -vv` | 브랜치별 최근 커밋과 추적 중인 원격 브랜치 |

## 2. 변경 비교

| 명령 | 비교 대상 |
|---|---|
| `git diff` | 작업 트리와 스테이징 영역 |
| `git diff --staged` (`--cached`) | 스테이징 영역과 마지막 커밋 |
| `git diff HEAD` | 작업 트리와 마지막 커밋 |
| `git diff <A> <B>` | 두 커밋·브랜치 |
| `git diff --stat` | 파일별 변경 줄 수 요약 |
| `git diff --name-status <A> <B>` | 변경된 파일 이름과 `A`(추가), `M`(수정), `D`(삭제) |
| `git diff --check` | 충돌 표식, 줄 끝 공백 같은 문제를 찾는다 |

## 3. 이력 조회

| 명령 | 보여 주는 것 |
|---|---|
| `git log --oneline` | 커밋을 한 줄씩 |
| `git log --oneline --graph --all` | 모든 브랜치를 그래프로 |
| `git log -n 5` | 최근 5개 |
| `git log --stat` | 커밋마다 변경 파일과 줄 수 |
| `git log --author=<이름>` | 작성자로 거른다 |
| `git log --since=<날짜>` | 기간으로 거른다(예: `2020-01-01`) |
| `git log -- <파일>` | 그 파일을 바꾼 커밋만 |
| `git log -p -- <파일>` | 그 파일의 변경 내용까지 |
| `git show <해시>` | 한 커밋의 메시지와 변경 내용 |
| `git show <해시>:<파일>` | 그 커밋 시점의 파일 내용 |

## 4. 찾기

| 명령 | 보여 주는 것 |
|---|---|
| `git grep -n <문자열>` | 추적 중인 파일에서 문자열이 있는 줄 번호 |
| `git blame <파일>` | 줄마다 마지막으로 바꾼 커밋과 작성자 |
| `git blame -L <시작>,<끝> <파일>` | 지정한 줄 범위만 |
| `git check-ignore -v <경로>` | 어떤 `.gitignore` 규칙이 적용됐는지 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [git-concepts.md](git-concepts.md) | DEV-GIT-007-DO | [생성형 AI] Git 기본 개념 — 작업 트리·스테이징·커밋 |
| [gitbashcommands.md](gitbashcommands.md) | DEV-GIT-005-REF | Git Bash 기본 명령어 |
| [gitignore.md](gitignore.md) | DEV-GIT-011-MP | [생성형 AI] .gitignore 작성 |

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 신규 작성 (생성형 AI 초안) |
