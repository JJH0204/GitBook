# [생성형 AI] 다른 저장소를 하위 폴더로 포함 (submodule)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-GIT-019-MP |
| 목적 | 다른 저장소를 특정 커밋에 고정해 하위 폴더로 포함하고, 복제·갱신·제거한다 |
| 적용 대상 | Git 2.23 이상, Windows·macOS·Linux |
| 소요 시간 | 약 15분 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (Git 2.53.0, Linux, 2026-11-19. 로컬 저장소 두 개로 추가·복제·`update --init`·`update --remote`·`deinit` 제거를 실행해 확인했다. 인터넷 원격과 인증이 필요한 저장소는 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [git-remote-sync.md](git-remote-sync.md) | DEV-GIT-013-MP | [생성형 AI] 원격 저장소와 push·pull |
| [git-concepts.md](git-concepts.md) | DEV-GIT-007-DO | [생성형 AI] Git 기본 개념 — 작업 트리·스테이징·커밋 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Git | 2.23 이상 | |
| 2 | 포함할 저장소의 주소 | HTTPS 또는 SSH 주소 | 아래 예는 연습용 로컬 경로 `../lib`다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 서브모듈은 브랜치가 아니라 특정 커밋 하나를 가리킨다. 서브모듈 폴더 안에서 한 커밋은 그 폴더의 저장소에 `push`해야 하고, 상위 저장소에는 "가리키는 커밋이 바뀌었다"는 기록만 커밋된다. 둘 다 `push`하지 않으면 다른 사람이 받을 수 없다.
{% endhint %}

{% hint style="info" %}
NOTE: Git 2.38.1 이상은 로컬 경로(`file` 프로토콜) 서브모듈을 기본으로 막는다. 연습에서만 `-c protocol.file.allow=always`를 붙인다. 실제 원격(HTTPS·SSH)에는 붙이지 않는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 상위 저장소에 커밋이 하나 이상 있다 | `git log --oneline -1` |
| 2 | 작업 트리가 깨끗하다 | `git status -s` |

## 5. 절차

**A. 추가**

1. (SUBTASK 5-A-01) 서브모듈을 추가한다: `git submodule add <주소> <폴더>` (연습: `git -c protocol.file.allow=always submodule add ../lib vendor/lib`) → 결과: `Cloning into '<경로>/vendor/lib'...`, `done.`
2. (SUBTASK 5-A-02) 상태를 확인한다: `git status -s` → 결과: `A  .gitmodules`와 `A  vendor/lib`가 나온다.
3. (SUBTASK 5-A-03) `.gitmodules`를 확인한다: `cat .gitmodules` → 결과: `[submodule "vendor/lib"]`, `path = vendor/lib`, `url = <주소>`가 있다.
4. (SUBTASK 5-A-04) 커밋한다: `git commit -m "add submodule"` → 결과: 상위 저장소가 서브모듈의 현재 커밋 해시를 기록한다. `git ls-tree HEAD`에서 서브모듈 폴더가 `blob`이 아닌 `tree`로 보인다.

**B. 복제할 때 함께 받기**

1. (SUBTASK 5-B-01) 한 번에 받는다: `git clone --recurse-submodules <상위 주소>` → 결과: 서브모듈 폴더에 파일이 채워진다.
2. (SUBTASK 5-B-02) 그냥 `git clone`만 했다면 서브모듈 폴더는 비어 있다. 이어서 `git submodule update --init`을 실행한다. → 결과: `Submodule path 'vendor/lib': checked out '<해시>'`

**C. 서브모듈을 최신으로 올리기**

1. (SUBTASK 5-C-01) 원격의 최신 커밋을 받는다: `git submodule update --remote` → 결과: `Submodule path 'vendor/lib': checked out '<새 해시>'`
2. (SUBTASK 5-C-02) 변화를 확인한다: `git status -s`, `git diff --submodule` → 결과: ` M vendor/lib`와 `Submodule vendor/lib <옛>..<새>:` 아래에 새 커밋 제목이 나온다.
3. (SUBTASK 5-C-03) 가리키는 커밋을 기록한다: `git add vendor/lib`, `git commit -m "update submodule"` → 결과: 새 해시가 상위 저장소에 기록된다.

**D. 목록 확인**

1. (SUBTASK 5-D-01) `git submodule status` → 결과: `<해시> vendor/lib (heads/main)` 형태. 해시 앞 `+`는 기록과 다른 커밋을 체크아웃했다는 뜻, `-`는 아직 받지 않았다는 뜻이다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `ls <서브모듈 폴더>` | 파일이 있다 | 비어 있지 않다 |
| 2 | `git submodule status` | 목록에 경로가 있다 | 줄 앞에 `-`가 없다 |

## 7. 복구

서브모듈을 제거한다.

1. (7-01) 등록을 해제한다: `git submodule deinit -f <폴더>` → 결과: `Cleared directory '<폴더>'`, `Submodule '<폴더>' (<주소>) unregistered for path '<폴더>'`
2. (7-02) 상위 저장소에서 지운다: `git rm -f <폴더>` → 결과: `git status -s`에 `M  .gitmodules`와 `D  <폴더>`가 나온다.
3. (7-03) 커밋한다: `git commit -m "remove submodule"` → 결과: 제거가 기록된다.
4. (7-04) 내부 복사본이 `.git/modules/<폴더>`에 남아 있다. 디스크를 비우려면 이 폴더를 삭제한다. 삭제는 실행하지 않았으므로 미검증이다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 신규 작성 (생성형 AI 초안) |
