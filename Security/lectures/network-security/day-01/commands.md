# 0. 실습 명령어 모음

> 상위: [1일차 프로젝트 시작](README.md)

수업 흐름 순서대로 적은 대본입니다. 실습하는 동안 띄워 둡니다. 명령은 모두 Windows의 Git Bash에서 칩니다. 화면 예시는 Git 2.55(Windows)에서 실제로 친 결과이고, 해시와 날짜는 칠 때마다 다릅니다.

| 단계 | 내용 | 언제 | 노트 |
|------|------|------|------|
| 0 | 설치 확인 | 수업 전 | |
| 1 | Git 처음 설정, GitHub 이메일 설정 | 15:20 Git 시간 (7분) | 3 |
| 2 | GitHub에 저장소 만들기 | 15:20 Git 시간 (5분) | 3 |
| 3 | 내 PC로 가져오기 | 15:20 Git 시간 (8분) | 3 |
| 4 | 계획서 파일 만들기 | 17:00 개인 실습 시작 | 4 |
| 5 | 첫 커밋과 push | 개인 실습 중, 계획서 초안이 나오면 | 4 |
| 6 | README 고치고 한 번 더 | 개인 실습 끝 무렵 | 4 |
| 7 | 집에 가기 전에 | 18:00 | |

## 0. 설치 확인 (수업 전)

```bash
git --version        # git version 2.x 가 나와야 한다
code --version       # VS Code 버전이 나와야 한다
```

## 1. Git 처음 설정 (PC마다 한 번)

먼저 브라우저에서 GitHub의 이메일 설정을 엽니다. 오른쪽 위 프로필 사진, Settings, Emails 순서입니다.

1. Keep my email addresses private를 켭니다. 그 아래에 `숫자+아이디@users.noreply.github.com` 형태의 주소가 나타납니다. 이것이 noreply 주소입니다.
2. Block command line pushes that expose my email도 켭니다. 개인 이메일이 찍힌 커밋을 push하면 GitHub가 거절해 줍니다.

Git Bash로 돌아와 칩니다.

```bash
git config --global user.name "홍길동"
git config --global user.email "<GitHub 의 noreply 주소>"
git config --global core.quotepath false     # 한글 파일 이름을 그대로 보여 준다
git config --global --list                   # 아래 세 줄이 보이면 된다
```

```
user.name=홍길동
user.email=12345678+hong@users.noreply.github.com
core.quotepath=false
```

설치할 때 들어간 다른 줄이 함께 보여도 괜찮습니다. 이 세 줄이 있으면 됩니다.

## 2. GitHub에 저장소 만들기 (브라우저)

1. github.com에 로그인하고 오른쪽 위 `+` 에서 New repository를 누릅니다.
2. Repository name에 `my-netsec-project` 를 적습니다.
3. Public을 고릅니다.
4. README 파일 추가를 켜고 Create repository를 누릅니다.
5. 초록색 Code 버튼을 눌러 HTTPS 주소를 복사합니다.

## 3. 내 PC로 가져오기

```bash
cd ~                                       # 내 사용자 폴더로 간다
pwd                                        # 지금 있는 곳. /c/Users/<이름> 이 보인다
git clone https://github.com/<아이디>/my-netsec-project.git
cd my-netsec-project
ls                                         # README.md 하나가 보인다
git status
```

```
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

GitHub와 내 PC가 같은 상태이고, 바뀐 것이 없다는 뜻입니다. 이제 VS Code로 이 폴더를 엽니다.

```bash
code .
```

## 4. 계획서 파일 만들기

```bash
mkdir 01_요구사항
git status
```

```
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

폴더를 만들었는데 Git은 아무것도 바뀌지 않았다고 합니다. Git은 빈 폴더를 기록하지 않습니다. 폴더 안에 파일이 생겨야 보입니다.

VS Code에서 `01_요구사항` 폴더 안에 `프로젝트_계획서.md` 를 만들고, [4번 노트](lesson-4.md)의 양식을 붙여 넣은 뒤 저장합니다(Ctrl+S).

```bash
git status
```

```
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	01_요구사항/

nothing added to commit but untracked files present (use "git add" to track)
```

`01_요구사항/` 이 빨간 글씨로 보입니다. Git이 처음 보는 파일(Untracked)이 생겼다는 뜻입니다.

## 5. 첫 커밋과 push

```bash
git add .
git status
```

```
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   01_요구사항/프로젝트_계획서.md
```

초록 글씨로 바뀌었습니다. 스테이지에 올라갔습니다.

```bash
git commit -m "1일차: 프로젝트 계획서 초안"
```

```
[main d7be5b8] 1일차: 프로젝트 계획서 초안
 1 file changed, 48 insertions(+)
 create mode 100644 01_요구사항/프로젝트_계획서.md
```

내 PC의 저장소에 기록이 남았습니다. `d7be5b8` 이 이 커밋의 짧은 지문이고, 48은 새로 생긴 줄 수입니다(계획서를 얼마나 채웠는지에 따라 다릅니다). 아직 GitHub에는 가지 않았습니다.

```bash
git push                                   # 처음이면 GitHub 로그인 창이 뜬다
```

로그인 창에서 Sign in with your browser를 누르고 브라우저에서 허락하면 push가 이어집니다. 끝에 이런 줄이 보이면 성공입니다.

```
To https://github.com/<아이디>/my-netsec-project.git
   87a0577..d7be5b8  main -> main
```

GitHub의 기록이 `87a0577` 에서 `d7be5b8` 로 한 칸 나아갔다는 뜻입니다.

```bash
git log --oneline
```

```
d7be5b8 1일차: 프로젝트 계획서 초안
87a0577 Initial commit
```

커밋이 두 개입니다. 아래가 GitHub가 README를 만들 때 남긴 커밋, 위가 방금 내가 남긴 커밋입니다. 브라우저에서 내 저장소를 새로 고쳐 `01_요구사항` 폴더가 보이면 성공입니다.

## 6. README 고치고 한 번 더

[4번 노트](lesson-4.md)의 README 양식으로 `README.md` 를 바꾸고 저장한 뒤 같은 순서를 한 번 더 밟습니다.

```bash
git status                                 # modified: README.md
git add README.md
git commit -m "1일차: README에 프로젝트 소개 추가"
git push
git log --oneline                          # 커밋이 세 개
```

이번에는 `git add .` 대신 파일 이름을 적었습니다. 이번 기록에 넣을 파일을 골라 담는 것이 스테이지의 쓰임입니다.

## 7. 집에 가기 전에 (교실 PC를 같이 쓴다면)

Git Credential Manager는 GitHub 로그인을 Windows에 저장해 둡니다. 다음 사람이 이 PC에서 push하면 내 계정으로 올라갑니다.

1. Windows 시작 메뉴에서 자격 증명 관리자를 엽니다.
2. Windows 자격 증명에서 `git:https://github.com` 항목을 제거합니다.

## 자주 막히는 곳

| 보이는 것 | 원인 | 해결 |
|-----------|------|------|
| `Author identity unknown` | 1번 설정을 건너뛰었다 | 1번의 `user.name`, `user.email` 을 치고 다시 commit |
| 파일 이름이 `"\353\260..."` 처럼 보인다 | 한글 이름을 숫자로 바꿔 보여 준다 | `git config --global core.quotepath false` |
| `nothing to commit` | 빈 폴더만 만들었거나 파일을 저장하지 않았다 | VS Code에서 저장했는지, 폴더 안에 파일이 있는지 본다 |
| `LF will be replaced by CRLF` | 줄바꿈 방식을 Windows에 맞춘다는 안내다 | 오류가 아니다. 그대로 진행한다 |
| `GH007: Your push would publish a private email address` | 개인 이메일로 커밋했다 | 1번의 `user.email` 을 noreply 주소로 고치고 `git commit --amend --reset-author --no-edit` 뒤에 다시 push |
| push가 다른 계정 이름으로 거절된다 | 이 PC에 다른 사람의 로그인이 남아 있다 | 7번처럼 자격 증명을 지우고 다시 push |
| `rejected` 와 `fetch first` | GitHub 웹에서 직접 고친 내용이 있다 | `git pull` 뒤에 다시 `git push` |
| `not a git repository` | 저장소 폴더 밖에 있다 | `cd ~/my-netsec-project` |
