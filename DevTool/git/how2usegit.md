# Git 사용법 (GitHub Desktop)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-GIT-004-MP |
| 목적 | GitHub Desktop에 로그인하고 저장소를 만들거나 가져와 변경 사항을 커밋·푸시한다 |
| 적용 대상 | Windows 10/11, macOS, GitHub Desktop |
| 소요 시간 | 약 15분 |
| 확인 상태 | 미검증 (원본 페이지를 정리한 것이며 이 환경에서 GitHub Desktop을 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: GitHub Desktop은 GitHub이 만든 무료 Git 클라이언트다. 명령어를 쓰지 않고 Git을 쓸 수 있어 처음 쓰는 사람에게 맞다. Windows와 macOS만 지원하므로 Git 명령어는 별도로 알아야 한다. 명령어 사용법은 DEV-GIT-005-REF를 따른다. 원본 페이지의 Git Bash 탭은 DEV-GIT-005-REF로 분리했다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [gitbashcommands.md](gitbashcommands.md) | DEV-GIT-005-REF | Git Bash 기본 명령어 |
| [gitsshkey.md](gitsshkey.md) | DEV-GIT-003-MP | Git SSH 키 생성과 등록 |
| [gitdisconnect.md](gitdisconnect.md) | DEV-GIT-001-MP | 사용하지 않는 PC의 Git 접근 해제 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | [Git](https://git-scm.com/book/ko/v2/%EC%8B%9C%EC%9E%91%ED%95%98%EA%B8%B0-Git-%EC%84%A4%EC%B9%98) | 2.x | 설치 안내 링크 |
| 2 | [GitHub 계정](https://github.com/signup) | | 가입 페이지 |
| 3 | [GitHub Desktop](https://github.com/apps/desktop) | 최신 버전 | |
| 4 | 코드 에디터 | [VS Code](https://code.visualstudio.com/), [Sublime Text](https://www.sublimetext.com/) 등 | 취향에 따라 고른다 |

## 3. 안전 사항

{% hint style="info" %}
NOTE: 브랜치(branch)는 버전 관리를 위한 상위 개념이다. 이 문서에서는 현재 브랜치를 확인하는 기능이 있다는 것만 알면 된다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | GitHub Desktop을 설치한다 | 앱이 실행된다 |
| 2 | GitHub 계정이 있는지 확인한다 | 웹에서 로그인된다 |

## 5. 절차

### A. 로그인

1. (5-A-01) 계정 설정을 연다. Windows: `File > Options > Accounts`, macOS: `GitHub Desktop > Settings` (구버전은 `Preferences`).
2. (5-A-02) GitHub 계정으로 로그인한다. → 결과: 계정 이름이 표시된다.

### B. 저장소 준비 (셋 중 하나를 고른다)

**B-1. 새 저장소 만들기**

1. (5-B1-01) `Create a New Repository...`를 누른다.
2. (5-B1-02) 이름과 로컬 경로를 입력하고 만든다. → 결과: 로컬 저장소가 만들어진다.
3. (5-B1-03) GitHub에도 만들려면 `Publish repository`를 누른다. → 결과: GitHub에 같은 이름의 저장소가 생긴다.

**B-2. 기존 저장소 가져오기**

1. (5-B2-01) `Clone a Repository...`를 누른다.
2. (5-B2-02) 가져올 저장소와 저장할 로컬 경로를 선택한다. → 결과: 로컬 폴더에 저장소가 복제된다.

**B-3. 이미 있는 로컬 폴더 등록**

1. (5-B3-01) `Add an Existing Repository...`를 누른다.
2. (5-B3-02) 이미 Git 저장소인 폴더를 선택한다. → 결과: `Current repository` 목록에 추가된다.

### C. 변경 사항 반영

1. (5-C-01) 작업 전에 `Fetch origin`을 누른다. → 결과: 원격에 새 변경이 있으면 버튼이 `Pull origin`으로 바뀐다.
2. (5-C-02) 버튼이 `Pull origin`이면 누른다. → 결과: 원격 변경 사항이 로컬에 적용된다.
3. (5-C-03) 파일을 수정한다. → 결과: `Changes` 탭에 수정한 파일이 표시된다.
4. (5-C-04) 커밋 메시지를 입력하고 `Commit`을 누른다. → 결과: `History` 탭에 커밋이 추가된다.
5. (5-C-05) `Push origin`을 누른다. → 결과: GitHub 저장소에 커밋이 올라간다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 웹에서 GitHub 저장소를 연다 | 방금 커밋한 메시지가 보인다 | 커밋 목록에 있다 |

## 7. 복구

1. (7-01) 커밋 전 변경을 취소한다: `Changes` 탭에서 파일을 우클릭해 `Discard changes`를 누른다.
2. (7-02) 계정 연결을 해제한다: DEV-GIT-001-MP를 따른다.

## 8. 화면 구성 (참조)

| 항목 | 역할 |
|---|---|
| Current repository | Desktop이 관리하는 저장소 목록을 보여 준다. 우클릭하면 추가 도구를 쓸 수 있다 |
| Current Branch | 현재 저장소의 브랜치를 보여 준다 |
| Fetch origin | GitHub 저장소의 변경 사항을 확인해 가져온다 |
| Changes | 수정된 파일을 표시한다. 수정 사항을 취소하거나 커밋할 수 있다 |
| History | 커밋 기록과 각 커밋의 수정 내용을 보여 준다 |

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 탭 구조를 풀어 GitHub Desktop 절차로 재작성하고 Git Bash 내용을 DEV-GIT-005-REF로 분리 |
