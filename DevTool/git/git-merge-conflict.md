# [생성형 AI] 병합 충돌 해결

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-GIT-009-TS |
| 유형 | TS (문제 해결) |
| 목적 | `git merge`가 `CONFLICT`로 멈췄을 때 원인을 찾아 해결하거나 병합을 취소한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (Git 2.53.0, Linux, 2026-11-19에서 충돌을 일부러 만들어 해결 절차를 실행했다. `git mergetool`, rebase 충돌은 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 1. 증상

`git merge <브랜치>` 또는 `git pull` 실행 뒤 다음 출력이 나온다.

```text
Auto-merging a.txt
CONFLICT (content): Merge conflict in a.txt
Automatic merge failed; fix conflicts and then commit the result.
```

`git status -s`에서 충돌 파일은 `UU`로 표시된다.

## 2. 가능 원인

| 번호 | 원인 | 확인 방법 |
|---|---|---|
| 1 | 두 브랜치가 같은 파일의 같은 줄을 서로 다르게 수정했다 | `git status`의 `both modified` 목록 |
| 2 | 한쪽은 파일을 지우고 다른 쪽은 수정했다 | `git status`의 `deleted by us/them` |
| 3 | 원격에 새 커밋이 있는데 로컬 커밋이 있는 상태로 `git pull`했다 | DEV-GIT-013-MP 참조 |

## 3. 격리 절차

1. (3-01) 충돌 파일 목록을 본다: `git diff --name-only --diff-filter=U` → 결과: 충돌 파일 이름만 출력된다.
2. (3-02) 파일을 연다. 충돌 표식이 보인다.

```text
<<<<<<< HEAD
line from main
=======
line from c1
>>>>>>> c1
```

| 표식 | 뜻 |
|---|---|
| `<<<<<<< HEAD` ~ `=======` | 현재 브랜치(병합을 받는 쪽)의 내용 |
| `=======` ~ `>>>>>>> c1` | 병합해 오는 브랜치(`c1`)의 내용 |

## 4. 시정 조치

**A. 직접 해결**

1. (4-A-01) 표식 세 줄(`<<<<<<<`, `=======`, `>>>>>>>`)을 지우고 남길 내용만 편집한다.
2. (4-A-02) 파일을 스테이징한다: `git add a.txt` → 결과: `git status -s`에서 `UU`가 `M`으로 바뀐다.
3. (4-A-03) 병합 커밋을 만든다: `git commit` → 결과: 병합 커밋이 생긴다. 메시지 편집기가 열리면 기본 메시지를 저장한다.

**B. 병합 취소**

1. (4-B-01) 병합 중에 `git merge --abort`를 실행한다 → 결과: 병합 전 상태로 돌아간다. 병합이 진행 중이 아니면 `fatal: There is no merge to abort (MERGE_HEAD missing).`가 출력된다.

**C. 한쪽 내용 선택**

1. (4-C-01) 현재 브랜치 것으로 정한다: `git checkout --ours -- <파일>` 또는 병합해 온 것으로 정한다: `git checkout --theirs -- <파일>` 후 `git add <파일>`한다.

{% hint style="warning" %}
CAUTION: 표식을 지우지 않고 커밋하면 `<<<<<<<` 줄이 그대로 파일에 들어간다. 커밋 전에 `git diff --check`로 남은 표식을 찾는다.
{% endhint %}

## 5. 재발 방지

| 번호 | 방법 |
|---|---|
| 1 | 작업 시작 전에 `git pull`로 최신 상태를 받는다 |
| 2 | 브랜치를 짧게 유지하고 자주 `main`을 병합해 온다 |
| 3 | 같은 파일을 여러 명이 동시에 크게 고치지 않도록 나눈다 |

## 6. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [git-branch-merge.md](git-branch-merge.md) | DEV-GIT-008-MP | [생성형 AI] 브랜치 만들기와 병합 |
| [git-remote-sync.md](git-remote-sync.md) | DEV-GIT-013-MP | [생성형 AI] 원격 저장소와 push·pull |

## 7. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 신규 작성 (생성형 AI 초안) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 충돌을 직접 겪었다면 어떤 상황에서 났고 어떻게 해결했는가?
- [ ] 충돌이 났을 때 어느 쪽 내용을 남길지는 무엇을 보고 판단해야 할까?
