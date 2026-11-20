# [생성형 AI] 버그가 생긴 커밋 찾기 (bisect)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-GIT-018-MP |
| 목적 | 이진 탐색으로 오류가 처음 생긴 커밋을 찾는다 |
| 적용 대상 | Git 2.23 이상, Windows·macOS·Linux |
| 소요 시간 | 약 10분 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (Git 2.53.0, Linux, 2026-11-19. 커밋 8개짜리 임시 저장소에서 `git bisect run`으로 5번째 커밋을 찾는 것을 확인했다. 손으로 `good`/`bad`를 입력하는 단계는 같은 명령이며 별도로 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [git-inspect.md](git-inspect.md) | DEV-GIT-014-REF | [생성형 AI] 상태·이력 확인 명령 정리 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Git | 2.23 이상 | |
| 2 | 정상이던 과거 커밋 | 해시 또는 태그 | 오류가 없던 것이 확실한 시점 |
| 3 | 오류 판정 방법 | 명령 하나 | 오류가 있으면 0이 아닌 종료 코드를 돌려주는 스크립트 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: `bisect` 중에는 과거 커밋이 작업 트리에 체크아웃된다. 커밋하지 않은 변경은 먼저 커밋하거나 `git stash`(DEV-GIT-012-MP)로 치운다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 작업 트리가 깨끗하다 | `git status -s`가 아무것도 출력하지 않는다 |
| 2 | 현재 커밋(`HEAD`)에 오류가 있다 | 판정 명령을 실행해 실패한다 |
| 3 | 과거 커밋에 오류가 없다 | `git switch --detach <해시>` 후 판정 명령이 성공한다. 끝나면 `git switch -` 로 돌아온다 |

## 5. 절차

**A. 직접 판정하며 찾기**

1. (SUBTASK 5-A-01) 시작한다: `git bisect start` → 결과: 출력이 없다.
2. (SUBTASK 5-A-02) 현재 커밋을 오류로 표시한다: `git bisect bad` → 결과: `status: waiting for good commit(s), bad commit known`
3. (SUBTASK 5-A-03) 정상 커밋을 알린다: `git bisect good <해시>` → 결과: `Bisecting: 3 revisions left to test after this (roughly 2 steps)`와 함께 중간 커밋이 체크아웃된다.
4. (SUBTASK 5-A-04) 이 커밋에서 프로그램을 실행·테스트한다. → 결과: 오류 유무를 알게 된다.
5. (SUBTASK 5-A-05) 판정을 입력한다: 오류가 있으면 `git bisect bad`, 없으면 `git bisect good` → 결과: 다음 중간 커밋이 체크아웃된다.
6. (SUBTASK 5-A-06) 5-A-04, 5-A-05를 반복한다. → 결과: 남은 후보가 없으면 `<해시> is the first bad commit`과 그 커밋의 정보가 출력된다.
7. (SUBTASK 5-A-07) 종료한다: `git bisect reset` → 결과: 시작 전 브랜치로 돌아온다.

**B. 스크립트로 자동 판정**

1. (SUBTASK 5-B-01) 시작한다: `git bisect start HEAD <정상 해시>` → 결과: 5-A-03과 같은 안내가 나온다.
2. (SUBTASK 5-B-02) 판정 명령을 지정한다: `git bisect run <명령>` → 결과: 명령이 0을 돌려주면 `good`, 1~127(125 제외)이면 `bad`로 자동 판정하고, 끝에 `<해시> is the first bad commit`과 `bisect found first bad commit`이 출력된다.
3. (SUBTASK 5-B-03) 종료한다: `git bisect reset` → 결과: 시작 전 브랜치로 돌아온다.

실행 예: 파일 `s.txt`에 `bug`라는 줄이 들어간 시점을 찾는다.

```bash
git bisect start HEAD HEAD~7
git bisect run sh -c '! grep -q bug s.txt'
git bisect reset
```

종료 코드 125는 "이 커밋은 판정할 수 없다(빌드 실패 등)"는 뜻으로, 그 커밋을 건너뛴다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 찾은 커밋의 변경을 본다: `git show <해시>` | 오류 원인이 되는 변경이 있다 | 변경 내용이 증상과 관련 있다 |
| 2 | `git status` | `bisect` 표시가 없다 | `git bisect reset` 후 `On branch <이름>` |

## 7. 복구

1. (7-01) 중간에 그만둔다: `git bisect reset` → 결과: 시작 전 브랜치로 돌아온다.
2. (7-02) 직전 판정을 잘못 입력했다면 `git bisect log > bisect.txt`로 기록을 저장하고, 해당 줄을 고친 뒤 `git bisect reset`, `git bisect replay bisect.txt`를 차례로 실행한다. → 결과: 기록대로 판정이 재현된다. `replay`는 실행하지 않았으므로 미검증이다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 신규 작성 (생성형 AI 초안) |
