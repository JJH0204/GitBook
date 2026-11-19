# [생성형 AI] 브랜치 재배치와 커밋 정리 (rebase)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-GIT-015-MP |
| 목적 | 브랜치를 최신 `main` 위로 옮기고, 아직 공유하지 않은 커밋을 합치거나 지운다 |
| 적용 대상 | Git 2.23 이상, Windows·macOS·Linux |
| 소요 시간 | 약 15분 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (Git 2.53.0, Linux, 2026-11-19. 임시 저장소에서 재배치, 충돌 후 `--continue`, 대화형 재배치의 `squash`·`drop`·`reword`를 실행해 확인했다. 에디터를 여는 단계는 환경 변수로 대체해 실행했다) |
| 개정 | R1 (2026-11-19) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [git-branch-merge.md](git-branch-merge.md) | DEV-GIT-008-MP | [생성형 AI] 브랜치 만들기와 병합 |
| [git-merge-conflict.md](git-merge-conflict.md) | DEV-GIT-009-TS | [생성형 AI] 병합 충돌 해결 |
| [git-undo.md](git-undo.md) | DEV-GIT-010-REF | [생성형 AI] 변경 되돌리기 명령 정리 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Git | 2.23 이상 | `git --version`으로 확인한다 |
| 2 | 연습용 저장소 | `main`과 `feature` 브랜치 | 새 임시 폴더에서 연습한다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 재배치는 커밋을 새 커밋으로 다시 만든다. 이미 `push`해서 다른 사람이 받은 커밋은 재배치하지 않는다. 강제 푸시가 필요해지고 다른 사람의 이력이 어긋난다.
{% endhint %}

{% hint style="info" %}
NOTE: 재배치 직전의 상태는 `ORIG_HEAD`와 `git reflog`에 남는다. 잘못되면 7절로 되돌린다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 작업 트리가 깨끗하다 | `git status -s`가 아무것도 출력하지 않는다 |
| 2 | 재배치할 브랜치로 이동했다 | `git branch --show-current`가 `feature`를 출력한다 |
| 3 | 커밋이 아직 `push`되지 않았다 | `git status -sb` 첫 줄에 `[ahead N]`만 있거나 원격 표시가 없다 |

## 5. 절차

**A. 브랜치를 최신 main 위로 옮기기**

1. (SUBTASK 5-A-01) 재배치 전 그래프를 확인한다: `git log --oneline --graph --all` → 결과: `feature`가 `main`의 옛 커밋에서 갈라진 모양이다.
2. (SUBTASK 5-A-02) 재배치한다: `git rebase main` → 결과: `Successfully rebased and updated refs/heads/feature.`
3. (SUBTASK 5-A-03) 그래프를 다시 확인한다: `git log --oneline --graph` → 결과: 병합 커밋 없이 한 줄로 이어지고 `feature`의 커밋 해시가 바뀐다.
4. (SUBTASK 5-A-04) `main`에 반영한다: `git switch main` 후 `git merge feature` → 결과: `Fast-forward`가 출력된다.

**B. 충돌이 났을 때**

1. (SUBTASK 5-B-01) 출력에서 `CONFLICT (content): Merge conflict in <파일>`을 확인한다. → 결과: 상태가 `HEAD (no branch)`이고 파일이 `UU`로 표시된다(`git status -sb`).
2. (SUBTASK 5-B-02) 파일의 `<<<<<<<`, `=======`, `>>>>>>>` 표시를 편집해 최종 내용으로 만든다. 방법은 DEV-GIT-009-TS를 따른다.
3. (SUBTASK 5-B-03) 해결한 파일을 올린다: `git add <파일>` → 결과: 출력이 없다.
4. (SUBTASK 5-B-04) 재배치를 이어 간다: `git rebase --continue` → 결과: `Successfully rebased and updated refs/heads/<브랜치>`.
5. (SUBTASK 5-B-05) 중단하려면 `git rebase --abort`를 실행한다. → 결과: 재배치 이전 상태로 돌아간다.

**C. 커밋 정리 (대화형 재배치)**

1. (SUBTASK 5-C-01) 최근 두 커밋을 대상으로 시작한다: `git rebase -i HEAD~2` → 결과: 에디터에 `pick <해시> <제목>` 줄이 커밋마다 한 줄씩 열린다. 오래된 커밋이 위에 있다.
2. (SUBTASK 5-C-02) 줄 맨 앞 단어를 바꾼다. → 결과: 아래 표의 동작이 적용된다.
3. (SUBTASK 5-C-03) 에디터를 저장하고 닫는다. `squash`·`reword`는 메시지 편집 창이 한 번 더 열린다. → 결과: `Successfully rebased and updated refs/heads/<브랜치>`.
4. (SUBTASK 5-C-04) 결과를 확인한다: `git log --oneline` → 결과: 합치거나 지운 커밋이 반영되어 있다.

| 단어 | 동작 |
|---|---|
| `pick` | 그대로 쓴다 |
| `reword` | 커밋 메시지만 고친다 |
| `squash` | 앞 줄 커밋에 합치고 메시지도 합친다 |
| `fixup` | 앞 줄 커밋에 합치고 이 커밋의 메시지는 버린다 |
| `drop` | 커밋을 지운다 |

실행 예: 커밋 `wip1`, `wip2`가 있을 때 둘째 줄을 `squash`로 바꾸면 커밋 두 개가 하나가 된다.

```text
pick   2cc2817 wip1
squash 9f1a3c0 wip2
```

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `git log --oneline --graph` | 갈라진 선 없이 한 줄이다 | 병합 커밋이 없다 |
| 2 | `git status` | 재배치 중 표시가 없다 | `rebase in progress`가 없다 |
| 3 | 프로젝트 빌드·테스트 | 재배치 전과 같이 통과한다 | 오류 0건 |

## 7. 복구

1. (7-01) 재배치 중이면 취소한다: `git rebase --abort` → 결과: 시작 전 상태로 돌아간다.
2. (7-02) 끝난 재배치를 직전 상태로 되돌린다: `git reset --hard ORIG_HEAD` → 결과: 재배치 이전 커밋으로 돌아간다. 이후에 만든 변경이 있으면 사라지므로 `ORIG_HEAD`를 `git rev-parse --short ORIG_HEAD`로 먼저 확인한다.
3. (7-03) `ORIG_HEAD`가 덮어써졌으면 `git reflog`에서 `rebase (start)` 바로 앞 줄의 `HEAD@{<번호>}`를 찾아 `git reset --hard 'HEAD@{<번호>}'`를 실행한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 신규 작성 (생성형 AI 초안) |
