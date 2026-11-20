# [생성형 AI] 커밋 하나만 가져오기 (cherry-pick)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-GIT-017-MP |
| 목적 | 다른 브랜치의 커밋 하나를 현재 브랜치에 복사한다 |
| 적용 대상 | Git 2.23 이상, Windows·macOS·Linux |
| 소요 시간 | 약 5분 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (Git 2.53.0, Linux, 2026-11-19. 임시 저장소에서 `-x` 복사와 충돌 후 `--abort`를 실행해 확인했다) |
| 개정 | R1 (2026-11-19) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [git-branch-merge.md](git-branch-merge.md) | DEV-GIT-008-MP | [생성형 AI] 브랜치 만들기와 병합 |
| [git-merge-conflict.md](git-merge-conflict.md) | DEV-GIT-009-TS | [생성형 AI] 병합 충돌 해결 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Git | 2.23 이상 | |
| 2 | 가져올 커밋의 해시 | 7자리 이상 | `git log --oneline <브랜치>`로 찾는다 |

## 3. 안전 사항

{% hint style="info" %}
NOTE: `cherry-pick`은 같은 변경을 새 커밋으로 복사한다. 해시가 원본과 다르다. 브랜치를 나중에 병합하면 같은 변경이 중복으로 보일 수 있다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 작업 트리가 깨끗하다 | `git status -s`가 아무것도 출력하지 않는다 |
| 2 | 받을 브랜치에 있다 | `git branch --show-current` |

## 5. 절차

**A. 커밋 가져오기**

1. (SUBTASK 5-A-01) 원본 브랜치에서 해시를 찾는다: `git log --oneline dev` → 결과: `b82cd5c dev2`, `8b7140d dev1` 같은 목록이 나온다.
2. (SUBTASK 5-A-02) 받을 브랜치로 이동한다: `git switch main` → 결과: `Switched to branch 'main'`
3. (SUBTASK 5-A-03) 출처를 남기며 복사한다: `git cherry-pick -x <해시>` → 결과: `[main <새 해시>] dev1`
4. (SUBTASK 5-A-04) 메시지를 확인한다: `git log -1` → 결과: 본문 끝에 `(cherry picked from commit <원본 해시>)`가 붙어 있다. `-x`를 빼면 이 줄이 없다.

**B. 충돌이 났을 때**

1. (SUBTASK 5-B-01) 출력의 `CONFLICT (content): Merge conflict in <파일>`을 확인한다. → 결과: `git status -sb`에 `UU <파일>`이 나온다.
2. (SUBTASK 5-B-02) 파일을 고치고 `git add <파일>` 후 `git cherry-pick --continue`를 실행한다. 방법은 DEV-GIT-009-TS를 따른다. → 결과: 새 커밋이 만들어진다.
3. (SUBTASK 5-B-03) 포기하려면 `git cherry-pick --abort`를 실행한다. → 결과: 시작 전 상태로 돌아간다.

{% hint style="warning" %}
CAUTION: 충돌이 해결되지 않은 상태에서 `git switch`를 실행하면 `fatal: cannot switch branch while cherry-picking`으로 거부된다. `--continue`나 `--abort`로 먼저 끝낸다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `git log --oneline -3` | 복사한 커밋이 맨 위에 있다 | 제목이 원본과 같다 |
| 2 | `git status` | 진행 중 표시가 없다 | `cherry-pick in progress`가 없다 |

## 7. 복구

1. (7-01) 복사한 커밋을 지운다: `git reset --hard HEAD~1` → 결과: 복사 이전으로 돌아간다. `push` 전에만 쓴다. 비교는 DEV-GIT-010-REF를 따른다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 신규 작성 (생성형 AI 초안) |
