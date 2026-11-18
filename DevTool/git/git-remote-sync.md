# [생성형 AI] 원격 저장소와 push·pull

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-GIT-013-MP |
| 목적 | 원격 저장소의 개념과 `push`, `fetch`, `pull`의 차이를 로컬 폴더 원격으로 연습해 익힌다 |
| 적용 대상 | Git 2.x, Windows·macOS·Linux |
| 소요 시간 | 약 15분 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (Git 2.53.0, Linux, 2026-11-19에서 로컬 bare 저장소를 원격으로 삼아 실행했다. GitHub 등 네트워크 원격과 인증은 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: GitHub 원격의 인증(SSH 키)은 DEV-GIT-003-MP, GUI 사용은 DEV-GIT-004-MP를 따른다. 이 문서의 명령은 원격이 GitHub이어도 같다. 주소만 다르다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [gitsshkey.md](gitsshkey.md) | DEV-GIT-003-MP | Git SSH 키 생성과 등록 |
| [gitbashcommands.md](gitbashcommands.md) | DEV-GIT-005-REF | Git Bash 기본 명령어 |
| [git-merge-conflict.md](git-merge-conflict.md) | DEV-GIT-009-TS | [생성형 AI] 병합 충돌 해결 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Git | 2.x | |
| 2 | 임시 폴더 | 쓰기 가능 | 연습 후 삭제한다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: `git push --force`는 원격 이력을 덮어쓴다. 공유 브랜치에는 쓰지 않는다. 이 문서의 절차에는 쓰지 않는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 사용자 이름과 이메일을 설정한다 | DEV-GIT-002-MP 기능 확인 통과 |
| 2 | 임시 폴더로 이동한다 | `pwd`가 연습용 폴더를 가리킨다 |

## 5. 절차

**A. 원격 만들기와 첫 push**

1. (SUBTASK 5-A-01) 원격 역할의 bare 저장소를 만든다: `git init --bare origin.git` → 결과: `origin.git` 폴더가 생긴다.
2. (SUBTASK 5-A-02) 복제한다: `git clone origin.git w1` → 결과: 빈 저장소라는 경고가 나온다.
3. (SUBTASK 5-A-03) `cd w1` 후 `git remote -v`를 실행한다 → 결과: `origin`의 fetch, push 주소가 나온다.
4. (SUBTASK 5-A-04) 파일을 커밋하고 `git push -u origin main`을 실행한다 → 결과: `* [new branch]      main -> main`과 `branch 'main' set up to track 'origin/main'.`
5. (SUBTASK 5-A-05) `git branch -vv`를 실행한다 → 결과: `* main <해시> [origin/main] <메시지>`로 추적 관계가 보인다.

**B. 다른 사람이 먼저 push한 경우**

1. (SUBTASK 5-B-01) 같은 원격을 다른 폴더로 복제한다: `cd ..`, `git clone origin.git w2`
2. (SUBTASK 5-B-02) `w2`에서 파일 `b`를 커밋하고 `git push`한다 → 결과: push가 성공한다.
3. (SUBTASK 5-B-03) `w1`에서 파일 `c`를 커밋하고 `git push`한다 → 결과: 실패한다.

```text
 ! [rejected]        main -> main (fetch first)
error: failed to push some refs to '<원격 주소>'
hint: Updates were rejected because the remote contains work that you do not
hint: have locally.
```

4. (SUBTASK 5-B-04) 원격 변경을 내려받는다: `git fetch` → 결과: `origin/main`이 갱신된다. 작업 트리와 `main`은 바뀌지 않는다.
5. (SUBTASK 5-B-05) 상태를 본다: `git status -sb` → 결과: 첫 줄이 `## main...origin/main [ahead 1, behind 1]`이다. 로컬에만 1개, 원격에만 1개 커밋이 있다는 뜻이다.
6. (SUBTASK 5-B-06) 병합 방식으로 합친다: `git pull --no-rebase --no-edit` → 결과: `b` 파일이 들어오고 병합 커밋이 만들어진다.
7. (SUBTASK 5-B-07) `git push` → 결과: `<이전 해시>..<새 해시>  main -> main`

### 명령 비교

| 명령 | 원격에서 받기 | 작업 트리·브랜치 변경 | 용도 |
|---|---|---|---|
| `git fetch` | 한다 | 하지 않는다(`origin/main`만 갱신) | 받을 내용을 먼저 확인한다 |
| `git pull` | 한다 | `fetch` 뒤 병합(또는 rebase)한다 | 바로 반영한다 |
| `git push` | 보낸다 | 원격 브랜치를 갱신한다 | 로컬 커밋을 공유한다 |

{% hint style="info" %}
NOTE: 갈라진 브랜치에서 `git pull`은 병합 방식을 정하는 설정(`pull.rebase`)이 없으면 방식을 선택하라는 안내를 낼 수 있다. 이 환경에서는 `--no-rebase` 옵션을 명시했다. 이 환경의 `git config pull.rebase`는 값이 없었다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `git log --oneline --graph --all` | 두 폴더의 커밋이 모두 보인다 | `b`, `c` 커밋이 있다 |
| 2 | `git status -sb` | 로컬과 원격이 일치한다 | `ahead`/`behind`가 없다 |
| 3 | `git remote show origin` | 원격 정보가 출력된다 | `HEAD branch: main` |

## 7. 복구

1. (7-01) 연습 폴더를 지운다: `rm -rf origin.git w1 w2` → 결과: 폴더가 없어진다. 연습 폴더만 지운다. 경로를 확인한 뒤 실행한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 신규 작성 (생성형 AI 초안) |
