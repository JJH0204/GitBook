# [생성형 AI] 커밋 전 자동 검사 (Git 훅)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-GIT-021-MP |
| 목적 | 커밋 메시지 형식을 검사하는 훅을 만들고 팀 저장소에서 공유한다 |
| 적용 대상 | Git 2.9 이상(`core.hooksPath` 사용), Linux·macOS·Git Bash |
| 소요 시간 | 약 10분 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (Git 2.53.0, Linux, 2026-11-19. 임시 저장소에서 `commit-msg` 훅이 잘못된 메시지를 막고 올바른 메시지를 통과시키는 것, `core.hooksPath` 해제 후 훅이 동작하지 않는 것을 확인했다. Windows는 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [git-commit-message.md](git-commit-message.md) | DEV-GIT-023-REF | [생성형 AI] 커밋 메시지 작성 규칙 |
| [git-concepts.md](git-concepts.md) | DEV-GIT-007-DO | [생성형 AI] Git 기본 개념 — 작업 트리·스테이징·커밋 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Git | 2.9 이상 | |
| 2 | 셸 | `sh` 호환 | Windows는 Git Bash |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 훅은 내 컴퓨터에서 자동 실행되는 스크립트다. 모르는 저장소를 받았다면 `core.hooksPath`를 그 저장소의 폴더로 바꾸기 전에 스크립트 내용을 읽는다.
{% endhint %}

{% hint style="info" %}
NOTE: `.git/hooks/` 안의 파일은 저장소에 커밋되지 않고 `clone`으로 전달되지 않는다. 팀이 공유하려면 아래 B처럼 일반 폴더에 두고 `core.hooksPath`로 지정한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 저장소 폴더에 있다 | `git status` |

## 5. 절차

**A. 훅 종류 알기**

| 훅 | 실행 시점 | 0이 아닌 종료 코드의 효과 |
|---|---|---|
| `pre-commit` | 커밋 메시지를 입력하기 전 | 커밋을 중단한다 |
| `commit-msg` | 메시지를 입력한 뒤. 첫 인수가 메시지 파일 경로다 | 커밋을 중단한다 |
| `pre-push` | `git push` 직전 | 푸시를 중단한다 |

**B. commit-msg 훅 만들기**

1. (SUBTASK 5-B-01) 폴더를 만든다: `mkdir githooks` → 결과: 폴더가 생긴다.
2. (SUBTASK 5-B-02) `githooks/commit-msg` 파일을 아래 내용으로 만든다. → 결과: 파일이 있다.

```sh
#!/bin/sh
first=$(head -n 1 "$1")
case "$first" in
  feat:*|fix:*|docs:*) exit 0 ;;
  *) echo "commit-msg: subject must start with feat:, fix: or docs:"; exit 1 ;;
esac
```

3. (SUBTASK 5-B-03) 실행 권한을 준다: `chmod +x githooks/commit-msg` → 결과: 출력이 없다.
4. (SUBTASK 5-B-04) 훅 폴더를 지정한다: `git config core.hooksPath githooks` → 결과: 출력이 없다.

**C. 동작 확인**

1. (SUBTASK 5-C-01) 잘못된 메시지로 커밋한다: `git commit --allow-empty -m "hello"` → 결과: `commit-msg: subject must start with feat:, fix: or docs:`가 출력되고 종료 코드 1로 커밋이 만들어지지 않는다.
2. (SUBTASK 5-C-02) 올바른 메시지로 커밋한다: `git commit --allow-empty -m "fix: ok"` → 결과: 커밋이 만들어진다.
3. (SUBTASK 5-C-03) 훅을 건너뛴다: `git commit --no-verify -m "hello"` → 결과: 검사 없이 커밋된다. 긴급할 때만 쓴다.

**D. 팀에 공유**

1. (SUBTASK 5-D-01) `githooks/` 폴더를 커밋한다: `git add githooks`, `git commit -m "docs: add hooks"` → 결과: 폴더가 이력에 들어간다. 위 훅을 그대로 쓰면 이 메시지도 검사를 통과해야 한다.
2. (SUBTASK 5-D-02) 받는 사람은 복제 후 한 번 `git config core.hooksPath githooks`를 실행한다. → 결과: 같은 검사가 적용된다. 이 설정은 `clone`으로 자동 전달되지 않는다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `git config --get core.hooksPath` | `githooks` | 값이 있다 |
| 2 | 잘못된 메시지로 커밋 | 거부된다 | 커밋 목록에 안 늘어난다 |

## 7. 복구

1. (7-01) 훅을 끈다: `git config --unset core.hooksPath` → 결과: 이후 `hello` 같은 메시지로도 커밋된다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 신규 작성 (생성형 AI 초안) |
