# 4-1. 계획서 작성과 첫 커밋 실습

> 상위: [1일차 프로젝트 시작](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-01-007-MP |
| 목적 | 프로젝트 계획서와 README를 작성해 커밋하고 GitHub에 push한 뒤, 공용 PC의 로그인 정보를 지운다 |
| 적용 대상 | Windows PC의 Git Bash, VS Code, 3-1 실습(LEC-SN-01-006-MP)을 마친 `my-netsec-project` 저장소 |
| 소요 시간 | 약 60분 (개인 실습 시간 17:00~18:00. 이 중 명령 입력은 약 15분) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이번 재작성에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-4.md](lesson-4.md) | LEC-SN-01-004-DO | 프로젝트 계획서 (양식, 작성 요령, 새봄상사 예시) |
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-SN-01-006-MP | 선행 실습. Git 설정과 저장소 가져오기 |
| [commands.md](commands.md) | LEC-SN-01-005-REF | 실습 명령어 모음 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Windows PC | Git Bash, VS Code | 3-1 실습과 같은 PC |
| 2 | 계획서 양식 | [lesson-4.md](lesson-4.md)의 5절(계획서), 8절(README) | 복사해 붙여 넣는다 |
| 3 | 내 가상 회사 | 이름, 업종, 부서, 지킬 것 | 실제 회사 이름은 쓰지 않는다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 계획서와 README에 실제 회사 이름, 개인 이메일, 전화번호, 실제 비밀번호를 쓰지 않는다. push한 내용은 지워도 커밋 기록에 남는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 교실 PC를 여러 사람이 쓴다면 구역 D에서 저장된 GitHub 로그인을 반드시 지운다. 지우지 않으면 다음 사람이 이 PC에서 push할 때 내 계정으로 올라간다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Git Bash에서 저장소 폴더로 이동한다: `cd ~/my-netsec-project` | `git status`가 `nothing to commit, working tree clean`을 출력한다 |
| 2 | VS Code로 폴더를 연다: `code .` | `README.md`가 보인다 |
| 3 | 내 회사의 업종과 부서를 정해 둔다 | [lesson-4.md](lesson-4.md)의 2절 기준(본사 15~30명, 부서 3개 이상, 부서당 30명 이하)을 만족한다 |

## 5. 절차

### A. 계획서 파일 만들기

1. (5-A-01) 폴더를 만든다: `mkdir 01_요구사항`
2. (5-A-02) 상태를 확인한다: `git status` → 결과: `nothing to commit, working tree clean`. Git은 빈 폴더를 기록하지 않으므로 아직 아무것도 바뀌지 않은 것으로 보인다.
3. (5-A-03) VS Code에서 `01_요구사항` 폴더 안에 `프로젝트_계획서.md`를 만든다.
4. (5-A-04) [lesson-4.md](lesson-4.md)의 5절 양식을 붙여 넣는다.
5. (5-A-05) 3절 시간표 순서대로 칸을 채운다: 회사 소개 5분, 부서와 사용자 10분, 연결 요구사항 10분, 지킬 것과 걱정되는 것 15분, 일정과 완료 기준 5분.
6. (5-A-06) 저장한다: Ctrl+S
7. (5-A-07) Git Bash에서 `git status`를 입력한다. → 결과: `Untracked files:` 아래 `01_요구사항/`이 빨간 글씨로 보인다. Git이 처음 보는 파일이 생겼다는 뜻이다.

### B. 첫 커밋과 push

1. (5-B-01) 변경 파일을 스테이지에 올린다: `git add .`
2. (5-B-02) 상태를 확인한다: `git status` → 결과: `Changes to be committed:` 아래 `new file:   01_요구사항/프로젝트_계획서.md`가 초록 글씨로 보인다.
3. (5-B-03) 커밋한다: `git commit -m "1일차: 프로젝트 계획서 초안"` → 결과: 아래와 같이 나온다. 해시와 줄 수는 사람마다 다르다.

```
[main d7be5b8] 1일차: 프로젝트 계획서 초안
 1 file changed, 48 insertions(+)
 create mode 100644 01_요구사항/프로젝트_계획서.md
```

내 PC의 저장소에 기록이 남았다. 아직 GitHub에는 가지 않았다.

4. (5-B-04) GitHub로 보낸다: `git push` → 결과: 처음이면 GitHub 로그인 창이 뜬다.
5. (5-B-05) 로그인 창에서 `Sign in with your browser`를 누르고 브라우저에서 허락한다. → 결과: push가 이어지고 끝에 아래와 비슷한 줄이 보인다.

```
To https://github.com/<아이디>/my-netsec-project.git
   87a0577..d7be5b8  main -> main
```

GitHub의 기록이 `87a0577`에서 `d7be5b8`로 한 칸 나아갔다는 뜻이다.

6. (5-B-06) 기록을 확인한다: `git log --oneline` → 결과: 커밋이 두 개 보인다. 아래가 GitHub가 README를 만들 때 남긴 커밋, 위가 방금 남긴 커밋이다.

```
d7be5b8 1일차: 프로젝트 계획서 초안
87a0577 Initial commit
```

7. (5-B-07) 브라우저에서 내 저장소를 새로 고친다. → 결과: `01_요구사항` 폴더가 보인다.

### C. README 고치고 한 번 더

1. (5-C-01) VS Code에서 `README.md`를 연다.
2. (5-C-02) [lesson-4.md](lesson-4.md)의 8절 README 양식으로 바꾸고 저장한다.
3. (5-C-03) 상태를 확인한다: `git status` → 결과: `modified: README.md`가 보인다.
4. (5-C-04) 파일을 지정해 스테이지에 올린다: `git add README.md` (이번 기록에 넣을 파일을 골라 담는 것이 스테이지의 쓰임이다.)
5. (5-C-05) 커밋한다: `git commit -m "1일차: README에 프로젝트 소개 추가"`
6. (5-C-06) 보낸다: `git push`
7. (5-C-07) 기록을 확인한다: `git log --oneline` → 결과: 커밋이 세 개 보인다.

### D. 집에 가기 전에 (교실 PC를 같이 쓸 때)

Git Credential Manager는 GitHub 로그인을 Windows에 저장해 둔다.

1. (5-D-01) Windows 시작 메뉴에서 `자격 증명 관리자`를 연다.
2. (5-D-02) `Windows 자격 증명`을 연다.
3. (5-D-03) `git:https://github.com` 항목을 펼쳐 `제거`를 누른다. → 결과: 항목이 목록에서 사라진다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | GitHub 저장소 화면 | `README.md`와 `01_요구사항/프로젝트_계획서.md`가 보인다 | 두 파일 모두 보임 |
| 2 | `git log` (Author 줄) | 이메일이 noreply 주소다 | `@users.noreply.github.com`으로 끝남 |
| 3 | `git log --oneline` | 내가 쓴 커밋이 있다 | 커밋 3개 (Initial commit, 계획서, README) |
| 4 | VS Code 미리보기(Ctrl+Shift+V) | 표가 깨지지 않고, README의 링크를 누르면 계획서가 열린다 | 해당 |
| 5 | 계획서 4번 칸 | 걱정 문장에 누가, 어디서, 무엇을이 들어 있다 | 모든 행에 해당 |
| 6 | 저장소 주소 | 강사에게 알려 주었다 | 전달 완료 |
| 7 | 자격 증명 관리자 | `git:https://github.com` 항목이 없다 (교실 PC) | 항목 없음 |

## 7. 복구

1. (7-01) 커밋하기 전에 `user.email`이 개인 이메일인 것을 알았다면 [3-1 실습](lesson-3-lab.md)의 5-B-02로 noreply 주소로 고친다.
2. (7-02) 이미 커밋했다면 `git commit --amend --reset-author --no-edit`을 입력한 뒤 다시 push한다. push한 뒤에 고치면 이미 올라간 기록이 바뀌므로 강사와 먼저 상의한다.
3. (7-03) push가 `GH007: Your push would publish a private email address`로 거절되면 7-01, 7-02를 따른다.
4. (7-04) push가 다른 계정 이름으로 거절되면 이 PC에 다른 사람의 로그인이 남은 것이다. 구역 D로 자격 증명을 지우고 다시 push한다.
5. (7-05) push가 `rejected`와 `fetch first`로 거절되면 GitHub 웹에서 직접 고친 내용이 있는 것이다. `git pull`을 입력한 뒤 다시 `git push`한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 4~7번과 `lesson-4.md`의 작성 순서, 확인 표, README 안내를 AMM 형식 MP로 분리. 개인 이메일 커밋 거절과 로그인 잔존 문제를 복구 절로 정리 |
