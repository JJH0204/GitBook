# [생성형 AI] 변경 임시 저장 (stash)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-GIT-012-MP |
| 목적 | 커밋하지 않은 변경을 임시로 치워 두고 브랜치를 옮긴 뒤 다시 꺼낸다 |
| 적용 대상 | Git 2.x, Windows·macOS·Linux |
| 소요 시간 | 약 5분 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (Git 2.53.0, Linux, 2026-11-19에서 임시 저장소로 `push`, `list`, `pop`, `apply`, `drop`을 실행해 확인했다) |
| 개정 | R1 (2026-11-19) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [git-undo.md](git-undo.md) | DEV-GIT-010-REF | [생성형 AI] 변경 되돌리기 명령 정리 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Git | 2.x | |
| 2 | 커밋이 있는 저장소 | | 추적 중인 파일이 하나 이상 있어야 한다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: stash는 이 PC의 저장소 안에만 저장된다. 원격으로 올라가지 않으므로 PC를 바꾸기 전에는 커밋해서 push한다.
{% endhint %}

{% hint style="info" %}
NOTE: 기본 `git stash push`는 추적 중인 파일의 변경만 저장한다. 새로 만든 untracked 파일은 작업 트리에 남는다. 함께 저장하려면 `-u`를 쓴다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 저장소 안에서 변경이 있는 상태다 | `git status -s`에 ` M <파일>`이 보인다 |

## 5. 절차

**A. 저장**

1. (SUBTASK 5-A-01) 변경을 저장한다: `git stash push -m "wip1"` → 결과: `Saved working directory and index state On main: wip1`. 추적 파일의 변경이 사라진다.
2. (SUBTASK 5-A-02) untracked 파일까지 저장하려면 `git stash push -u -m "wip2"`를 실행한다 → 결과: 새 파일도 작업 트리에서 사라진다.
3. (SUBTASK 5-A-03) 목록을 본다: `git stash list` → 결과: 최근 항목이 `stash@{0}`이다.

```text
stash@{0}: On main: wip2
stash@{1}: On main: x
stash@{2}: On main: wip1
```

**B. 꺼내기**

1. (SUBTASK 5-B-01) 최근 항목을 꺼내고 목록에서 지운다: `git stash pop` → 결과: 변경이 복원되고 `Dropped refs/stash@{0} (<해시>)`가 출력된다.
2. (SUBTASK 5-B-02) 목록에서 지우지 않고 적용하려면 `git stash apply stash@{<번호>}`를 쓴다 → 결과: 변경이 복원되고 항목은 남는다.
3. (SUBTASK 5-B-03) 항목을 지운다: `git stash drop stash@{<번호>}` → 결과: `Dropped ...`가 출력된다.

{% hint style="warning" %}
CAUTION: 복원하려는 untracked 파일과 같은 이름의 파일이 작업 트리에 이미 있으면 `apply`가 `u.txt already exists, no checkout` 오류로 untracked 복원에 실패한다. 이름이 겹치는 파일을 옮기고 다시 실행한다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 저장 직후 `git status -s` | 저장한 변경이 사라진다 | 추적 파일의 ` M`이 없다 |
| 2 | `git stash pop` 후 `git status -s` | 변경이 돌아온다 | 저장 전과 같은 ` M` 목록 |

## 7. 복구

1. (7-01) 잘못 지운 항목은 `drop` 출력의 해시로 되살린다: `git stash apply <해시>` → 결과: 변경이 복원된다. 해시를 기록해 두지 않았다면 `git fsck --unreachable`로 찾는다. 이 환경에서는 `fsck` 경로를 실행하지 않았다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 신규 작성 (생성형 AI 초안) |
