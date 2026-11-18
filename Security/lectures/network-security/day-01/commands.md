# 0. 실습 명령어 모음

> 상위: [1일차 프로젝트 시작](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-01-005-REF |
| 유형 | REF (명령 표) |
| 목적 | 1일차 실습에서 입력하는 Git 명령과 기대 결과를 수업 흐름 순서대로 모은다 |
| 확인 상태 | 미검증 (원본 대본을 표로 정리한 것이다. 화면 예시는 원본이 Git 2.55(Windows)에서 실제로 친 결과이며 이번에 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

실습하는 동안 띄워 둔다. 명령은 모두 Windows의 Git Bash에서 입력한다. 해시와 날짜는 입력할 때마다 다르다. 절차(단계별 결과 포함)는 두 실습 문서에 있다.

| 문서 | Task ID | 다루는 번호 |
|---|---|---|
| [3-1. Git 설정과 저장소 가져오기 실습](lesson-3-lab.md) | LEC-SN-01-006-MP | 0~3번 |
| [4-1. 계획서 작성과 첫 커밋 실습](lesson-4-lab.md) | LEC-SN-01-007-MP | 4~7번 |

## 수업 흐름

| 단계 | 내용 | 언제 | 노트 |
|---|---|---|---|
| 0 | 설치 확인 | 수업 전 | |
| 1 | Git 처음 설정, GitHub 이메일 설정 | 15:20 Git 시간 (7분) | 3 |
| 2 | GitHub에 저장소 만들기 | 15:20 Git 시간 (5분) | 3 |
| 3 | 내 PC로 가져오기 | 15:20 Git 시간 (8분) | 3 |
| 4 | 계획서 파일 만들기 | 17:00 개인 실습 시작 | 4 |
| 5 | 첫 커밋과 push | 개인 실습 중, 계획서 초안이 나오면 | 4 |
| 6 | README 고치고 한 번 더 | 개인 실습 끝 무렵 | 4 |
| 7 | 집에 가기 전에 | 18:00 | |

## 0. 설치 확인 (수업 전)

| 명령 | 기대 결과 |
|---|---|
| `git --version` | `git version 2.x` |
| `code --version` | VS Code 버전 |

## 1. Git 처음 설정 (PC마다 한 번)

먼저 브라우저에서 GitHub의 `Settings > Emails`를 열고 `Keep my email addresses private`와 `Block command line pushes that expose my email`을 켠다. 켜면 `<숫자>+<아이디>@users.noreply.github.com` 형태의 noreply 주소가 나타난다.

| 명령 | 하는 일 |
|---|---|
| `git config --global user.name "<이름>"` | 커밋의 작성자 이름 |
| `git config --global user.email "<GitHub의 noreply 주소>"` | 커밋의 작성자 이메일 |
| `git config --global core.quotepath false` | 한글 파일 이름을 그대로 보여 준다 |
| `git config --global --list` | 설정 확인. 세 줄(`user.name`, `user.email`, `core.quotepath=false`)이 보이면 된다 |

설치할 때 들어간 다른 줄이 함께 보여도 된다.

## 2. GitHub에 저장소 만들기 (브라우저)

| 항목 | 값 |
|---|---|
| 메뉴 | 오른쪽 위 `+` > `New repository` |
| Repository name | `my-netsec-project` |
| 공개 여부 | `Public` |
| README | 파일 추가를 켠다 |
| 주소 복사 | 초록색 `Code` 버튼의 HTTPS 주소 |

## 3. 내 PC로 가져오기

| 명령 | 하는 일 |
|---|---|
| `cd ~` | 내 사용자 폴더로 간다 |
| `pwd` | 지금 있는 곳. `/c/Users/<이름>`이 보인다 |
| `git clone https://github.com/<아이디>/my-netsec-project.git` | 저장소를 가져온다 |
| `cd my-netsec-project` | 저장소 폴더로 들어간다 |
| `ls` | `README.md` 하나가 보인다 |
| `git status` | `nothing to commit, working tree clean` (GitHub와 내 PC가 같은 상태) |
| `code .` | VS Code로 이 폴더를 연다 |

## 4. 계획서 파일 만들기

| 명령 또는 동작 | 결과 |
|---|---|
| `mkdir 01_요구사항` | 폴더가 생긴다 |
| `git status` | 여전히 `nothing to commit`. Git은 빈 폴더를 기록하지 않는다 |
| VS Code에서 `01_요구사항/프로젝트_계획서.md`를 만들고 [4번 노트](lesson-4.md)의 양식을 붙여 넣은 뒤 Ctrl+S | 파일이 저장된다 |
| `git status` | `Untracked files:` 아래 `01_요구사항/`이 빨간 글씨로 보인다 |

## 5. 첫 커밋과 push

| 명령 | 기대 결과 |
|---|---|
| `git add .` | 바뀐 파일을 모두 스테이지에 올린다 |
| `git status` | `Changes to be committed:` 아래 `new file:   01_요구사항/프로젝트_계획서.md`가 초록 글씨 |
| `git commit -m "1일차: 프로젝트 계획서 초안"` | `[main d7be5b8] 1일차: 프로젝트 계획서 초안`, `1 file changed, 48 insertions(+)` (해시와 줄 수는 다르다) |
| `git push` | 처음이면 GitHub 로그인 창이 뜬다. 끝에 `87a0577..d7be5b8  main -> main` 같은 줄이 보이면 성공 |
| `git log --oneline` | 커밋 두 개. 위가 내 커밋, 아래가 `Initial commit` |

로그인 창에서는 `Sign in with your browser`를 누르고 브라우저에서 허락한다. `d7be5b8`은 커밋의 짧은 지문이고 48은 새로 생긴 줄 수다.

## 6. README 고치고 한 번 더

[4번 노트](lesson-4.md)의 README 양식으로 `README.md`를 바꾸고 저장한 뒤 같은 순서를 한 번 더 밟는다.

| 명령 | 기대 결과 |
|---|---|
| `git status` | `modified: README.md` |
| `git add README.md` | 파일을 지정해 스테이지에 올린다 |
| `git commit -m "1일차: README에 프로젝트 소개 추가"` | 커밋 |
| `git push` | GitHub로 보낸다 |
| `git log --oneline` | 커밋 세 개 |

## 7. 집에 가기 전에 (교실 PC를 같이 쓴다면)

Git Credential Manager는 GitHub 로그인을 Windows에 저장해 둔다. 다음 사람이 이 PC에서 push하면 내 계정으로 올라간다.

| 순서 | 동작 |
|---|---|
| 1 | Windows 시작 메뉴에서 `자격 증명 관리자`를 연다 |
| 2 | `Windows 자격 증명`에서 `git:https://github.com` 항목을 제거한다 |

## 자주 막히는 곳

| 보이는 것 | 원인 | 해결 |
|---|---|---|
| `Author identity unknown` | 1번 설정을 건너뛰었다 | 1번의 `user.name`, `user.email`을 입력하고 다시 commit |
| 파일 이름이 `"\353\260..."`처럼 보인다 | 한글 이름을 숫자로 바꿔 보여 준다 | `git config --global core.quotepath false` |
| `nothing to commit` | 빈 폴더만 만들었거나 파일을 저장하지 않았다 | VS Code에서 저장했는지, 폴더 안에 파일이 있는지 본다 |
| `LF will be replaced by CRLF` | 줄바꿈 방식을 Windows에 맞춘다는 안내다 | 오류가 아니다. 그대로 진행한다 |
| `GH007: Your push would publish a private email address` | 개인 이메일로 커밋했다 | 1번의 `user.email`을 noreply 주소로 고치고 `git commit --amend --reset-author --no-edit` 뒤에 다시 push |
| push가 다른 계정 이름으로 거절된다 | 이 PC에 다른 사람의 로그인이 남아 있다 | 7번처럼 자격 증명을 지우고 다시 push |
| `rejected`와 `fetch first` | GitHub 웹에서 직접 고친 내용이 있다 | `git pull` 뒤에 다시 `git push` |
| `not a git repository` | 저장소 폴더 밖에 있다 | `cd ~/my-netsec-project` |

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 대본을 명령 표와 점검표로 정리하고 절차는 두 MP(LEC-SN-01-006-MP, LEC-SN-01-007-MP)로 분리. 번호(0~7)는 다른 일차의 참조 때문에 유지 |
