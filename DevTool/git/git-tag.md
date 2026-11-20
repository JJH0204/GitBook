# [생성형 AI] 태그로 버전 표시 (tag)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-GIT-016-MP |
| 목적 | 특정 커밋에 버전 이름을 붙이고 원격에 올린다 |
| 적용 대상 | Git 2.23 이상, Windows·macOS·Linux |
| 소요 시간 | 약 10분 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (Git 2.53.0, Linux, 2026-11-19. 임시 저장소와 로컬 bare 저장소를 원격으로 두고 생성·조회·push·삭제를 실행해 확인했다) |
| 개정 | R1 (2026-11-19) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [git-concepts.md](git-concepts.md) | DEV-GIT-007-DO | [생성형 AI] Git 기본 개념 — 작업 트리·스테이징·커밋 |
| [git-remote-sync.md](git-remote-sync.md) | DEV-GIT-013-MP | [생성형 AI] 원격 저장소와 push·pull |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Git | 2.23 이상 | |
| 2 | 커밋이 하나 이상 있는 저장소 | | 원격에 올릴 때만 `origin`이 필요하다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 이미 공개한 태그를 지우거나 다른 커밋으로 옮기면 그 태그를 받은 사람의 저장소와 어긋난다. 공개한 태그는 지우지 않고 새 버전 태그를 만든다.
{% endhint %}

{% hint style="info" %}
NOTE: `git push`는 태그를 보내지 않는다. 태그는 따로 `push`해야 한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 태그를 붙일 커밋이 `HEAD`다 | `git log --oneline -1`로 확인한다 |

## 5. 절차

**A. 태그 만들기**

1. (SUBTASK 5-A-01) 가벼운 태그를 만든다: `git tag v0.1` → 결과: 출력이 없다.
2. (SUBTASK 5-A-02) 주석 태그를 만든다: `git tag -a v1.0 -m "release 1.0"` → 결과: 출력이 없다. 만든 사람, 날짜, 메시지가 함께 저장된다.
3. (SUBTASK 5-A-03) 지난 커밋에 붙인다: `git tag v0.1 <해시>` → 결과: 그 커밋에 태그가 붙는다.

| 종류 | 명령 | 저장하는 것 | 용도 |
|---|---|---|---|
| 가벼운 태그 | `git tag <이름>` | 커밋 가리킴만 | 임시 표시 |
| 주석 태그 | `git tag -a <이름> -m "<메시지>"` | 가리킴 + 만든 사람·날짜·메시지 | 배포 버전 |

**B. 조회**

1. (SUBTASK 5-B-01) 목록을 본다: `git tag` → 결과: `v0.1`, `v1.0`이 이름순으로 나온다.
2. (SUBTASK 5-B-02) 패턴으로 거른다: `git tag -l "v1.*"` → 결과: `v1.0`만 나온다.
3. (SUBTASK 5-B-03) 메시지와 함께 본다: `git tag -n` → 결과: `v0.1            c1`, `v1.0            release 1.0`처럼 한 줄 메시지가 붙는다.
4. (SUBTASK 5-B-04) 태그 내용을 본다: `git show v1.0` → 결과: `tag v1.0`, `Tagger:`, 메시지, 커밋 정보가 나온다.
5. (SUBTASK 5-B-05) 가장 가까운 태그를 확인한다: `git describe` → 결과: 태그가 `HEAD`에 있으면 `v1.0`, 그 뒤로 커밋이 더 있으면 `v1.0-<커밋 수>-g<해시>` 형태다.

**C. 원격에 올리기**

1. (SUBTASK 5-C-01) 태그 하나를 올린다: `git push origin v1.0` → 결과: `* [new tag]         v1.0 -> v1.0`
2. (SUBTASK 5-C-02) 남은 태그를 모두 올린다: `git push origin --tags` → 결과: 원격에 없던 태그마다 `[new tag]`가 출력된다.
3. (SUBTASK 5-C-03) 원격 태그를 확인한다: `git ls-remote --tags origin` → 결과: `refs/tags/v1.0`이 보인다. 주석 태그는 `refs/tags/v1.0^{}` 줄이 하나 더 나온다.

**D. 태그 시점 확인**

1. (SUBTASK 5-D-01) 그 시점 파일을 본다: `git switch --detach v1.0` → 결과: 분리된 HEAD(detached HEAD) 상태가 된다. 태그 이름만으로 `git switch v1.0`을 실행하면 `fatal: a branch is expected, got tag 'v1.0'` 오류가 난다.
2. (SUBTASK 5-D-02) 돌아온다: `git switch main` → 결과: `main`으로 이동한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `git tag` | 만든 태그가 보인다 | 이름이 있다 |
| 2 | `git ls-remote --tags origin` | 올린 태그가 보인다 | `refs/tags/<이름>`이 있다 |

## 7. 복구

1. (7-01) 로컬 태그를 지운다: `git tag -d v0.1` → 결과: `Deleted tag 'v0.1' (was <해시>)`
2. (7-02) 원격 태그를 지운다: `git push origin --delete v0.1` → 결과: ` - [deleted]         v0.1`

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 신규 작성 (생성형 AI 초안) |
