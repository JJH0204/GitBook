# [생성형 AI] .gitignore 작성

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-GIT-011-MP |
| 목적 | 빌드 산출물, 로그, 비밀값 파일이 커밋되지 않도록 `.gitignore`를 만든다 |
| 적용 대상 | Git 2.x, Windows·macOS·Linux |
| 소요 시간 | 약 5분 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (Git 2.53.0, Linux, 2026-11-19에서 임시 저장소로 `git status -s`, `git check-ignore -v`, `git rm --cached` 결과를 확인했다) |
| 개정 | R1 (2026-11-19) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [git-concepts.md](git-concepts.md) | DEV-GIT-007-DO | [생성형 AI] Git 기본 개념 — 작업 트리·스테이징·커밋 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Git | 2.x | |
| 2 | 텍스트 편집기 | 아무 편집기 | |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 비밀번호, 토큰, 키가 든 파일은 한 번이라도 커밋하면 이력에 남는다. `.gitignore`를 나중에 추가해도 이미 커밋한 내용은 지워지지 않는다. 커밋하기 전에 먼저 `.gitignore`에 넣는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 저장소 루트 폴더로 이동한다 | `git rev-parse --show-toplevel`이 현재 폴더를 출력한다 |

## 5. 절차

**A. 규칙 작성**

1. (SUBTASK 5-A-01) 저장소 루트에 `.gitignore` 파일을 만들고 다음을 적는다.

```text
build/
*.log
.env
!keep.log
```

2. (SUBTASK 5-A-02) 확인용 파일을 만든다: `mkdir -p build`, `echo o > build/x.o`, `echo k=1 > .env`, `echo l > a.log`, `echo l > keep.log`
3. (SUBTASK 5-A-03) 상태를 본다: `git status -s` → 결과: `.gitignore`와 `keep.log`만 `??`로 나타난다. `build/`, `a.log`, `.env`는 나타나지 않는다.

**B. 어느 규칙이 적용됐는지 확인**

1. (SUBTASK 5-B-01) `git check-ignore -v a.log build/x.o .env keep.log` 실행 → 결과: 각 파일에 적용된 규칙이 `파일:줄:패턴 경로` 형식으로 나온다. `keep.log`는 `!keep.log` 줄이 표시되는데 이는 제외를 해제한 규칙이다.

**C. 이미 추적 중인 파일을 무시**

`.gitignore`는 아직 추적하지 않는 파일에만 작용한다. 이미 커밋한 파일은 규칙을 추가해도 변경이 계속 보인다.

1. (SUBTASK 5-C-01) `.gitignore`에 규칙(예: `*.tmp`)을 추가한다. → 결과: 이미 추적 중인 `tracked.tmp`는 수정하면 여전히 ` M tracked.tmp`로 나온다.
2. (SUBTASK 5-C-02) 추적을 해제한다: `git rm --cached tracked.tmp` → 결과: `git status -s`에 `D  tracked.tmp`가 나온다. 작업 폴더의 파일은 남는다.
3. (SUBTASK 5-C-03) 커밋한다: `git commit -m "stop tracking tracked.tmp"`

### 패턴 문법

| 패턴 | 뜻 |
|---|---|
| `build/` | `build` 폴더 전체 |
| `*.log` | 확장자가 `.log`인 모든 파일 |
| `!keep.log` | 앞 규칙에서 제외된 파일을 다시 포함한다 |
| `# 설명` | 주석 |

규칙은 위에서 아래로 읽고 뒤 규칙이 앞 규칙을 덮는다. 폴더 자체가 제외되면 그 안의 파일은 `!`로 되살릴 수 없다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `git status -s` | 무시할 파일이 목록에 없다 | `.env`, `a.log`, `build/`가 없다 |
| 2 | `git ls-files` | 추적 목록에 비밀값 파일이 없다 | `.env`가 없다 |

## 7. 복구

1. (7-01) 규칙을 지우거나 줄을 삭제한다 → 결과: 해당 파일이 `git status -s`에 다시 나타난다.
2. (7-02) 무시된 파일을 강제로 추가하려면 `git add -f <파일>`을 쓴다 → 결과: 해당 파일이 `A  <파일>`로 스테이징된다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 신규 작성 (생성형 AI 초안) |
