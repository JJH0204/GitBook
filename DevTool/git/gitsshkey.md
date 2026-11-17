# Git SSH 키 생성과 등록

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-GIT-003-MP |
| 목적 | SSH 키 쌍을 만들고 GitHub에 공개 키를 등록해 SSH 주소로 저장소를 클론한다 |
| 적용 대상 | Windows 10/11 (Git Bash), macOS, Linux, Git 2.x, OpenSSH 사용 가능 |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 페이지에는 SSH 키 생성 절차가 없었다. `ssh-keygen`과 GitHub의 표준 절차를 기준으로 작성했으며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 개인 기록: MyNote 저장소의 용량이 커져 HTTP 주소로 클론하기 어려웠다. 그래서 SSH 연결을 쓰기로 했다. 이 문서는 그 SSH 연결을 만드는 절차다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [git.md](git.md) | DEV-GIT-002-MP | Git 기본 설정 |
| [gitdisconnect.md](gitdisconnect.md) | DEV-GIT-001-MP | 사용하지 않는 PC의 Git 접근 해제 |
| [외부] [Git SSH로 GitHub Repository Clone](https://velog.io/@euisuk-chung/Git-SSH%EB%A1%9C-GitHub-Repository-Clone) | | 원본 페이지가 가리키던 SSH 연동 블로그 글 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 터미널 | Git Bash, macOS 터미널, Linux 터미널 중 하나 | |
| 2 | GitHub 계정 | 로그인 가능 | |
| 3 | 이메일 | GitHub에 등록한 이메일 | 키 주석으로 쓴다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 개인 키(`id_ed25519`, 확장자 없음)는 다른 사람에게 보내거나 GitHub에 붙여 넣지 않는다. 등록하는 것은 `.pub` 확장자의 공개 키뿐이다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 같은 이름의 키 파일이 이미 있으면 `ssh-keygen`이 덮어쓸지 묻는다. 기존 키를 쓰고 있다면 `n`을 입력하고 다른 파일 이름을 지정한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 터미널을 연다 | 프롬프트가 나타난다 |
| 2 | SSH 클라이언트가 있는지 확인한다 | `ssh -V`에 버전이 출력된다 |
| 3 | 기존 키를 확인한다 | `ls ~/.ssh`에 `id_ed25519`가 없다 |

## 5. 절차

### A. 키 생성

1. (5-A-01) 키를 만든다: `ssh-keygen -t ed25519 -C "<이메일>"`
2. (5-A-02) 저장 위치를 묻으면 Enter를 누른다. → 결과: 기본 위치 `~/.ssh/id_ed25519`가 쓰인다.
3. (5-A-03) 암호(passphrase)를 입력하고 한 번 더 입력한다. → 결과: `Your public key has been saved in ~/.ssh/id_ed25519.pub`가 출력된다.

### B. 에이전트에 키 추가

1. (5-B-01) ssh-agent를 시작한다: `eval "$(ssh-agent -s)"` → 결과: `Agent pid <번호>`가 출력된다.
2. (5-B-02) 개인 키를 추가한다: `ssh-add ~/.ssh/id_ed25519` → 결과: `Identity added`가 출력된다.

### C. GitHub에 공개 키 등록

1. (5-C-01) 공개 키를 출력한다: `cat ~/.ssh/id_ed25519.pub` → 결과: `ssh-ed25519`로 시작하는 한 줄이 출력된다.
2. (5-C-02) 그 한 줄 전체를 복사한다.
3. (5-C-03) GitHub에 로그인해 `Settings > SSH and GPG keys`를 연다.
4. (5-C-04) `New SSH key`를 누른다.
5. (5-C-05) `Title`에 PC를 구분할 이름을 입력한다.
6. (5-C-06) `Key`에 복사한 내용을 붙여 넣고 `Add SSH key`를 누른다. → 결과: 목록에 키가 나타난다.

### D. 연결 시험과 클론

1. (5-D-01) 연결을 시험한다: `ssh -T git@github.com`
2. (5-D-02) 처음 접속이면 `Are you sure you want to continue connecting`에 `yes`를 입력한다. → 결과: `Hi <사용자명>! You've successfully authenticated`로 시작하는 메시지가 나온다.
3. (5-D-03) SSH 주소로 클론한다: `git clone git@github.com:<사용자명>/<저장소 이름>.git` → 결과: 저장소 폴더가 만들어진다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `ssh -T git@github.com` | 인증 성공 메시지 | `successfully authenticated` 포함 |
| 2 | `git clone git@github.com:<사용자명>/<저장소 이름>.git` | 클론 완료 | 저장소 폴더가 있다 |

## 7. 복구

1. (7-01) GitHub의 `Settings > SSH and GPG keys`에서 등록한 키의 `Delete`를 누른다.
2. (7-02) PC의 키 파일을 삭제한다: DEV-GIT-001-MP의 구역 B를 따른다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `git.md`의 "Git SSH 키 연동 설정" 메모를 보존하고 키 생성·등록 절차를 새로 작성 |
