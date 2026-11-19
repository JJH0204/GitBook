# [생성형 AI] 브랜치 만들기와 병합

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-GIT-008-MP |
| 목적 | 브랜치를 만들어 작업하고 `main`에 병합한 뒤 브랜치를 지운다 |
| 적용 대상 | Git 2.23 이상(`git switch` 사용), Windows·macOS·Linux |
| 소요 시간 | 약 10분 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (Git 2.53.0, Linux, 2026-11-19에서 임시 저장소로 병합 커밋과 fast-forward 병합을 실행해 확인했다) |
| 개정 | R1 (2026-11-19) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [git-concepts.md](git-concepts.md) | DEV-GIT-007-DO | [생성형 AI] Git 기본 개념 — 작업 트리·스테이징·커밋 |
| [git-merge-conflict.md](git-merge-conflict.md) | DEV-GIT-009-TS | [생성형 AI] 병합 충돌 해결 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Git | 2.23 이상 | `git --version`으로 확인한다 |
| 2 | 커밋이 하나 이상 있는 저장소 | 브랜치 `main` | 연습은 새 임시 폴더에서 한다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: `git branch -D`는 병합되지 않은 브랜치도 지운다. 병합 여부를 확인한 뒤 소문자 `-d`를 먼저 쓴다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 저장소 폴더로 이동한다 | `git status`에 `On branch main`이 보인다 |
| 2 | 작업 트리가 깨끗하다 | `git status -s`가 아무것도 출력하지 않는다 |

## 5. 절차

**A. 브랜치에서 작업**

1. (SUBTASK 5-A-01) 새 브랜치를 만들고 이동한다: `git switch -c feature` → 결과: `Switched to a new branch 'feature'`
2. (SUBTASK 5-A-02) 파일을 만들고 커밋한다: `echo f > f.txt`, `git add f.txt`, `git commit -m "add f"` → 결과: 커밋 한 줄이 출력된다.

**B. main에 병합**

1. (SUBTASK 5-B-01) `main`으로 돌아온다: `git switch main` → 결과: `Switched to branch 'main'`. 작업 트리에서 `f.txt`가 사라진다.
2. (SUBTASK 5-B-02) 병합한다: `git merge feature -m "merge feature"` → 결과: `main`에도 커밋이 있었다면 `Merge made by the 'ort' strategy.`가 출력된다.
3. (SUBTASK 5-B-03) 이력을 확인한다: `git log --oneline --graph` → 결과: 두 갈래가 합쳐지는 그래프가 보인다.

```text
*   5ff3461 merge feature
|\
| * d62c206 add f
* | 10b464b add m
|/
* b912f54 second
```

**C. 브랜치 정리**

1. (SUBTASK 5-C-01) 병합된 브랜치를 지운다: `git branch -d feature` → 결과: `Deleted branch feature (was d62c206).`
2. (SUBTASK 5-C-02) 목록을 확인한다: `git branch` → 결과: `* main`만 남는다.

### 병합 방식 두 가지

| 상황 | 결과 | 출력 |
|---|---|---|
| `main`이 갈라진 뒤 새 커밋이 없다 | 포인터만 앞으로 이동(fast-forward). 병합 커밋이 생기지 않는다 | `Fast-forward` |
| 양쪽에 새 커밋이 있다 | 부모가 둘인 병합 커밋이 생긴다 | `Merge made by the 'ort' strategy.` |
| 같은 줄을 양쪽에서 수정했다 | 자동 병합이 멈춘다 | `CONFLICT (content)` → DEV-GIT-009-TS |

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `git log --oneline` | 병합한 브랜치의 커밋이 `main` 이력에 보인다 | `add f`가 목록에 있다 |
| 2 | `git branch` | 지운 브랜치가 없다 | `feature`가 없다 |
| 3 | `ls` | 병합한 파일이 작업 트리에 있다 | `f.txt`가 있다 |

## 7. 복구

1. (7-01) 병합 직후 되돌린다: `git reset --hard HEAD~1` → 결과: 병합 이전 커밋으로 돌아간다. 아직 push하지 않은 병합에만 쓴다. 자세한 비교는 DEV-GIT-010-REF를 따른다.
2. (7-02) 지운 브랜치를 되살린다: `git branch feature <해시>` → 결과: 지울 때 출력된 해시에서 브랜치가 다시 만들어진다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 신규 작성 (생성형 AI 초안) |
