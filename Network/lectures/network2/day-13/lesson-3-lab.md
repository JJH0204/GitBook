# GitHub 연결 실습

> 상위: [13일차 · Git 과 GitHub](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-13-009-MP |
| 목적 | 12일차 SSH 공개키를 GitHub에 등록하고, 빈 저장소를 만들어 로컬 저장소를 `push`하며, `clone`으로 복제본을 받는다 |
| 적용 대상 | WSL(Ubuntu 24.04), Git 2.43, GitHub 계정, 포트 22 통신이 가능한 망 |
| 소요 시간 | 약 30분(키 등록 15분 포함) |
| 확인 상태 | 미검증 (원본 강의 노트와 대본을 정리한 것이며 GitHub 계정으로 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-3.md](lesson-3.md) | LEC-N2-13-003-DO | GitHub와 원격 저장소 |
| [lesson-2-lab.md](lesson-2-lab.md) | LEC-N2-13-008-MP | 로컬 Git 실습(`~/myweb` 저장소를 만든다) |
| [commands.md](commands.md) | LEC-N2-13-007-REF | 13일차 실습 명령어 |
| [12일차 · 리눅스 서버 구축](../day-12/README.md) | | SSH 키 생성과 `authorized_keys` |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | WSL(Ubuntu) | 24.04 | 터미널 |
| 2 | 웹 브라우저 | Windows | GitHub 가입, 저장소 생성, 결과 확인 |
| 3 | GitHub 계정 | 이메일 인증 완료 | 수업 전에 미리 가입한다 |
| 4 | `~/myweb` 저장소 | 커밋 3개 | [로컬 Git 실습](lesson-2-lab.md)의 결과물 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: GitHub에 붙여 넣는 것은 `.pub`가 붙은 공개키뿐이다. `~/.ssh/id_ed25519`(개인키)를 붙여 넣거나 저장소에 올리면 그 키로 열리는 모든 서버가 위험해진다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 저장소를 만들 때 "Add a README file"을 체크하지 않는다. 체크하면 첫 `push`가 거부된다.
{% endhint %}

{% hint style="info" %}
NOTE: 이 문서의 `<아이디>`는 본인의 GitHub 사용자명이다. 화면 공유나 캡처로 키 내용과 사용자명이 노출되지 않게 한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | GitHub 계정에 로그인되어 있다 | 브라우저 우측 상단에 프로필이 보인다 |
| 2 | `~/myweb`에 커밋이 있다 | `cd ~/myweb && git log --oneline`이 3줄을 출력한다 |
| 3 | 포트 22 통신이 된다 | 구역 C의 `ssh -T`가 응답한다 |

## 5. 절차

### A. 공개키 확인

1. (5-A-01) 키 폴더를 확인한다: `ls -l ~/.ssh/` → 결과: `id_ed25519`와 `id_ed25519.pub`가 보인다.
2. (5-A-02) 공개키를 출력한다: `cat ~/.ssh/id_ed25519.pub` → 결과: `ssh-ed25519 AAAA...`로 시작하는 한 줄이 나온다.
3. (5-A-03) 키가 없으면 만든다: `ssh-keygen -t ed25519 -C "<이메일>"` → 결과: 저장 위치와 암호 질문에 Enter를 세 번 누르면 키 한 쌍이 생긴다(암호는 비워도 된다).
4. (5-A-04) 5-A-02를 다시 실행해 공개키를 출력한다.

### B. GitHub에 공개키 등록

1. (5-B-01) 브라우저에서 GitHub 우측 상단 프로필을 누르고 `Settings`를 선택한다.
2. (5-B-02) 왼쪽 메뉴에서 `SSH and GPG keys`를 선택한다.
3. (5-B-03) `New SSH key`를 누른다. → 결과: 등록 화면이 열린다.
4. (5-B-04) Title에 `<키 이름>`(예: `WSL-lab`)을 입력한다.
5. (5-B-05) Key에 5-A-02 출력 전체를 붙여 넣는다.
6. (5-B-06) `Add SSH key`를 누른다. → 결과: 목록에 키가 추가된다.

### C. 연결 확인

1. (5-C-01) WSL에서 `ssh -T git@github.com`을 실행한다. → 결과: 처음에는 호스트 지문 확인 질문이 나온다.
2. (5-C-02) `yes`를 입력한다. → 결과: 아래 문장이 출력된다.

```
Hi <아이디>! You've successfully authenticated, but GitHub does not provide shell access.
```

3. (5-C-03) 이 문장을 확인한다. "shell access를 주지 않는다"는 정상이다.

### D. 빈 저장소 만들고 올리기

1. (5-D-01) 브라우저에서 `New repository`를 누른다.
2. (5-D-02) 이름에 `myweb`을 입력하고 `Public`을 선택한다.
3. (5-D-03) "Add a README file" 체크가 해제된 것을 확인하고 `Create repository`를 누른다. → 결과: 빈 저장소 화면이 나타난다.
4. (5-D-04) WSL에서 이동한다: `cd ~/myweb`
5. (5-D-05) 원격을 등록한다: `git remote add origin git@github.com:<아이디>/myweb.git`
6. (5-D-06) 확인한다: `git remote -v` → 결과: `origin`의 fetch, push 주소 두 줄이 나온다.
7. (5-D-07) 브랜치 이름을 정한다: `git branch -M main`
8. (5-D-08) 올린다: `git push -u origin main` → 결과: `Branch 'main' set up to track` 메시지가 나온다.
9. (5-D-09) 브라우저에서 저장소 화면을 새로고침한다. → 결과: 내 파일이 보인다.

### E. 이후의 흐름

1. (5-E-01) 줄을 추가한다: `echo "<p>13일차</p>" >> index.html`
2. (5-E-02) 커밋한다: `git commit -am "내용 추가"`
3. (5-E-03) 올린다: `git push` → 결과: `-u` 덕분에 `origin main`을 생략해도 올라간다.

### F. 복제본 받기

1. (5-F-01) 홈으로 이동한다: `cd ~`
2. (5-F-02) 복제한다: `git clone git@github.com:<아이디>/myweb.git myweb2` → 결과: `myweb2` 폴더가 생긴다.
3. (5-F-03) 이력을 확인한다: `cd myweb2 && git log --oneline` → 결과: 원본과 같은 이력이 따라온다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `ssh -T git@github.com` | `successfully authenticated` | 문장이 출력된다 |
| 2 | GitHub 웹 저장소 화면 | 파일과 커밋 이력 | 내 커밋이 보인다 |
| 3 | `git push` (`-u` 이후) | 인자 없이 성공 | 오류가 없다 |
| 4 | `myweb2`의 `git log --oneline` | 원본과 같은 이력 | 커밋 수가 같다 |

{% hint style="warning" %}
CAUTION: 증상별 조치는 다음과 같다. `Permission denied (publickey)`는 공개키를 재등록하고 `ssh -T`를 다시 실행한다. `push`가 `rejected`이면 `git pull`을 먼저 하고, 충돌이 나면 풀고 `git push`를 다시 한다. 첫 `push`가 거부되면(저장소 생성 때 README를 체크한 경우) `git pull --rebase origin main` 후 `git push`를 한다.
{% endhint %}

## 7. 복구

1. (7-01) 잘못 등록한 키를 지운다: GitHub `Settings > SSH and GPG keys`에서 해당 키의 `Delete`를 누른다. → 결과: 목록에서 사라진다.
2. (7-02) 원격 주소를 잘못 넣었으면 바꾼다: `git remote set-url origin git@github.com:<아이디>/myweb.git`
3. (7-03) 연습용 저장소를 지우려면 GitHub 저장소 `Settings` 맨 아래 `Delete this repository`를 사용한다.

{% hint style="danger" %}
WARNING: 저장소 삭제는 되돌릴 수 없다. 이 저장소는 4, 5번 실습에서 계속 쓰므로 실습이 모두 끝난 뒤에 지운다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-3.md`와 `commands.md`의 실습 항목을 AMM 형식으로 재작성. 예시 사용자명 `hong-gildong`을 `<아이디>`로 바꿈 |
