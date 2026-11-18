# 3-1. Git 설정과 저장소 가져오기 실습

> 상위: [1일차 프로젝트 시작](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-01-006-MP |
| 목적 | Git 사용자 정보와 GitHub 이메일 보호를 설정하고, GitHub에 빈 저장소를 만들어 내 PC로 clone한다 |
| 적용 대상 | Windows PC의 Git Bash, Git 2.x, VS Code, GitHub 계정 (교실 PC 또는 개인 PC) |
| 소요 시간 | 약 20분 (수업 시간표의 Git 시간 안) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이번 재작성에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-3.md](lesson-3.md) | LEC-SN-01-003-DO | Git과 GitHub |
| [commands.md](commands.md) | LEC-SN-01-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |
| [lesson-4-lab.md](lesson-4-lab.md) | LEC-SN-01-007-MP | 다음 실습. 계획서 작성과 첫 커밋 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Windows PC | Git for Windows(Git Bash, Git Credential Manager 포함), VS Code | 학원이 교실 PC에 미리 설치한다 |
| 2 | GitHub 계정 | 이메일 인증을 마친 계정 | 학생이 수업 전에 만든다 |
| 3 | 인터넷 | github.com 접속과 push가 가능해야 한다 | 학원 방화벽이 막으면 실습이 멈춘다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 개인 이메일로 커밋하면 공개 저장소에 그 이메일이 남고, 지워도 커밋 기록에서 사라지지 않는다. 구역 B에서 noreply 주소를 먼저 설정한다.
{% endhint %}

{% hint style="info" %}
NOTE: 아래 예시의 이름, 아이디, 이메일은 예제 값이다. `<꺾쇠>` 부분은 본인의 값으로 바꾼다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Git Bash를 연다 | 프롬프트가 나타난다 |
| 2 | `git --version`을 입력한다 | `git version 2.x`가 출력된다 |
| 3 | `code --version`을 입력한다 | VS Code 버전이 출력된다 |
| 4 | 브라우저에서 GitHub에 로그인한다 | 오른쪽 위에 내 프로필 사진이 보인다 |

## 5. 절차

### A. GitHub 이메일 보호 설정 (브라우저)

1. (5-A-01) GitHub 오른쪽 위 프로필 사진을 누르고 `Settings`, `Emails` 순서로 연다.
2. (5-A-02) `Keep my email addresses private`를 켠다. → 결과: `<숫자>+<아이디>@users.noreply.github.com` 형태의 주소가 나타난다. 이것이 noreply 주소다.
3. (5-A-03) `Block command line pushes that expose my email`을 켠다. → 결과: 개인 이메일이 찍힌 커밋을 push하면 GitHub가 거절한다.
4. (5-A-04) noreply 주소를 복사해 둔다.

### B. Git 처음 설정 (PC마다 한 번)

1. (5-B-01) 사용자 이름을 설정한다: `git config --global user.name "<이름>"`
2. (5-B-02) 이메일을 설정한다: `git config --global user.email "<GitHub의 noreply 주소>"`
3. (5-B-03) 한글 파일 이름을 그대로 보이게 한다: `git config --global core.quotepath false`
4. (5-B-04) 설정을 확인한다: `git config --global --list` → 결과: 아래 세 줄이 보인다. 설치할 때 들어간 다른 줄이 함께 보여도 된다.

```
user.name=<이름>
user.email=<숫자>+<아이디>@users.noreply.github.com
core.quotepath=false
```

### C. GitHub에 저장소 만들기 (브라우저)

1. (5-C-01) github.com에 로그인하고 오른쪽 위 `+`에서 `New repository`를 누른다.
2. (5-C-02) `Repository name`에 `my-netsec-project`를 적는다.
3. (5-C-03) `Public`을 고른다.
4. (5-C-04) README 파일 추가를 켜고 `Create repository`를 누른다. → 결과: README.md 하나가 있는 저장소 화면이 열린다.
5. (5-C-05) 초록색 `Code` 버튼을 눌러 HTTPS 주소를 복사한다.

### D. 내 PC로 가져오기 (clone)

1. (5-D-01) 사용자 폴더로 이동한다: `cd ~`
2. (5-D-02) 현재 위치를 확인한다: `pwd` → 결과: `/c/Users/<이름>`이 보인다.
3. (5-D-03) 저장소를 가져온다: `git clone https://github.com/<아이디>/my-netsec-project.git` → 결과: 오류 없이 끝난다.
4. (5-D-04) 폴더로 들어간다: `cd my-netsec-project`
5. (5-D-05) 파일 목록을 확인한다: `ls` → 결과: `README.md` 하나가 보인다.
6. (5-D-06) 상태를 확인한다: `git status` → 결과: 아래와 같이 나온다.

```
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

GitHub와 내 PC가 같은 상태이고, 바뀐 것이 없다는 뜻이다.

7. (5-D-07) VS Code로 폴더를 연다: `code .` → 결과: VS Code 창에 `README.md`가 보인다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `git config --global user.email` | noreply 주소가 출력된다 | `@users.noreply.github.com`으로 끝난다 |
| 2 | `git config --global core.quotepath` | `false`가 출력된다 | 해당 |
| 3 | `git status` (저장소 폴더 안) | `nothing to commit, working tree clean` | 해당 |
| 4 | 브라우저의 `Settings > Emails` | 두 옵션이 켜져 있다 | 둘 다 켜짐 |

## 7. 복구

1. (7-01) 사용자 정보를 지운다: `git config --global --unset user.name`과 `git config --global --unset user.email`
2. (7-02) 내 PC의 저장소 폴더를 지우려면 탐색기에서 `my-netsec-project` 폴더를 삭제한다. GitHub의 저장소는 그대로 남는다.
3. (7-03) GitHub의 저장소를 지우려면 저장소의 `Settings` 맨 아래 `Delete this repository`를 쓴다. 지운 저장소는 되돌릴 수 없다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 0~3번과 `lesson-3.md`의 설정 안내를 AMM 형식 MP로 분리. 이메일 설정을 설정 명령보다 먼저 배치 |
