# [생성형 AI] 변경 되돌리기 명령 정리

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-GIT-010-REF |
| 유형 | REF (명령어 표) |
| 목적 | 상황별로 `restore`, `reset`, `revert`, `reflog` 중 무엇을 쓸지 고른다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (Git 2.53.0, Linux, 2026-11-19에서 표의 명령을 임시 저장소에서 실행해 결과를 확인했다. 원격에 push한 커밋의 되돌리기는 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="danger" %}
WARNING: `git restore <파일>`과 `git reset --hard`는 커밋하지 않은 변경을 지운다. 지운 변경은 Git으로 복구할 수 없다. 실행 전에 `git status`와 `git diff`로 지워질 내용을 확인한다.
{% endhint %}

## 1. 상황별 선택표

| 상황 | 명령 | 작업 트리 | 이력 |
|---|---|---|---|
| 수정한 파일을 마지막 커밋 상태로 되돌린다 | `git restore <파일>` | 변경 삭제 | 변화 없음 |
| `git add`를 취소한다 | `git restore --staged <파일>` | 유지 | 변화 없음 |
| 방금 커밋을 취소하고 변경은 스테이징 상태로 둔다 | `git reset --soft HEAD~1` | 유지 | 커밋 제거 |
| 방금 커밋을 취소하고 변경은 스테이징 해제 상태로 둔다 | `git reset --mixed HEAD~1` (기본값) | 유지 | 커밋 제거 |
| 방금 커밋과 변경을 모두 버린다 | `git reset --hard HEAD~1` | 변경 삭제 | 커밋 제거 |
| 이미 push한 커밋을 취소한다 | `git revert <해시>` | 취소 내용이 반영됨 | 취소 커밋 추가 |
| `reset`으로 잃은 커밋을 찾는다 | `git reflog` | - | 조회만 |

## 2. 실행 결과

### 2.1 restore

```bash
echo junk >> a.txt
git restore a.txt          # 수정 삭제. a.txt가 마지막 커밋 내용으로 돌아온다
echo staged >> a.txt
git add a.txt
git restore --staged a.txt # git status -s 출력: " M a.txt" (수정은 남고 스테이징만 풀림)
```

### 2.2 reset 세 가지

`git reset --soft HEAD~1` 뒤 `git status -s`는 `A  r.txt`(스테이징 유지), `git reset --mixed HEAD~1` 뒤에는 `?? r.txt`(새 파일이 untracked로 돌아감)를 출력했다. `--hard`는 파일 내용까지 이전 커밋 상태로 만들었다.

### 2.3 revert

```bash
git revert --no-edit HEAD
```

```text
[main cd5ba07] Revert "r3"
 1 file changed, 1 deletion(-)
```

`revert`는 이력을 지우지 않고 반대 변경을 새 커밋으로 추가한다. 공유 브랜치에서는 `reset` 대신 이것을 쓴다.

### 2.4 reflog로 복구

`reset --hard` 뒤에도 `HEAD`가 거쳐 간 커밋은 `git reflog`에 남는다.

```text
ceb903d HEAD@{0}: reset: moving to HEAD~2
cd5ba07 HEAD@{1}: revert: Revert "r3"
66d89e3 HEAD@{2}: commit: r3
```

되돌리려면 `git reset --hard HEAD@{1}`처럼 `reflog`의 항목을 지정한다. 커밋하지 않은 변경은 `reflog`에도 없다. reflog 항목은 기본 설정에서 일정 기간 뒤 정리된다.

{% hint style="warning" %}
CAUTION: 이미 원격에 push한 커밋을 `reset`으로 지우면 다른 사람의 저장소와 이력이 어긋난다. 공유한 커밋은 `revert`로 되돌린다.
{% endhint %}

## 3. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [git-concepts.md](git-concepts.md) | DEV-GIT-007-DO | [생성형 AI] Git 기본 개념 — 작업 트리·스테이징·커밋 |
| [git-stash.md](git-stash.md) | DEV-GIT-012-MP | [생성형 AI] 변경 임시 저장 (stash) |

## 4. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 신규 작성 (생성형 AI 초안) |
