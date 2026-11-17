# Git 기본 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-GIT-002-MP |
| 목적 | Git 전역 사용자 이름과 이메일을 설정해 커밋에 작성자가 기록되게 한다 |
| 적용 대상 | Windows 10/11, macOS, Linux, Git 2.x |
| 소요 시간 | 약 3분 |
| 확인 상태 | 미검증 (`git config` 기본 사용법을 기준으로 작성했으며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본 페이지에는 설정 절차가 없고 연결 해제 절차만 있었다. 연결 해제는 DEV-GIT-001-MP로 분리했다. 이 문서의 설정 명령은 해제 절차의 반대 동작이다.
{% endhint %}

## 1. 참조

### 1.1 내부 문서

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [gitdisconnect.md](gitdisconnect.md) | DEV-GIT-001-MP | 사용하지 않는 PC의 Git 접근 해제 |
| [gitsshkey.md](gitsshkey.md) | DEV-GIT-003-MP | Git SSH 키 생성과 등록 |
| [gitbashcommands.md](gitbashcommands.md) | DEV-GIT-005-REF | Git Bash 기본 명령어 |

### 1.2 외부 자료

| 자료 | 설명 |
|---|---|
| [깃과 옵시디언 연동 방법](https://alive-wong.tistory.com/65) | Git 저장소를 옵시디언 노트와 연동하는 방법을 설명한 블로그 글 |
| [깃 저장소 병합 방법](https://velog.io/@jisuuuu/Git-Repository%EB%93%A4-%ED%95%98%EB%82%98%EB%A1%9C-%ED%95%A9%EC%B9%98%EA%B8%B0) | 저장소 여러 개를 하나로 합치는 방법 |
| [커밋 버전 이전으로 되돌리는 방법](https://medium.com/@kwoncharles/git-%EC%9D%B4%EC%A0%A0-commit%EC%9C%BC%EB%A1%9C-%EB%8F%8C%EC%95%84%EA%B0%80%EA%B8%B0-cf6caed43ed5) | 이전 커밋으로 되돌리는 방법 |
| [깃 클론](https://ittrue.tistory.com/91) | `git clone` 사용법 |
| [git pull 오류](https://goddaehee.tistory.com/253) | `git pull` 오류 해결 사례 |
| [git stash clear](https://iiii.tistory.com/156) | `git stash` 항목을 지우는 방법 |
| [git add 명령어](https://hygge-wavy.tistory.com/m/94) | `git add` 사용법 |
| [GitHub 저장소에 팀원 초대](https://velog.io/@gmlstjq123/%EB%82%B4-Github-Repository%EB%A1%9C-%ED%8C%80%EC%9B%90-%EC%B4%88%EB%8C%80%ED%95%98%EA%B8%B0) | 저장소에 협업자를 초대하는 방법 |
| [Git 웹 사용 글](https://brunch.co.kr/@everiwon/42) | Git 사용법을 소개한 브런치 글 |
| [Naver Cloud SourceCommit LFS 사용](https://guide.ncloud-docs.com/docs/sourcecommit-use-lfs) | 대용량 파일(Git LFS) 커밋 관련 공식 안내 |
| [Git LFS 커밋 관련 글](https://sbjjsurfing.tistory.com/110) | 대용량 파일(Git LFS) 커밋 관련 블로그 글 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Git | 2.x | `git --version`으로 확인한다 |
| 2 | 터미널 | Git Bash, PowerShell, macOS 터미널 중 하나 | |
| 3 | 이름과 이메일 | 커밋에 기록할 값 | GitHub에 등록한 이메일을 쓴다 |

## 3. 안전 사항

{% hint style="info" %}
NOTE: 전역 설정(`--global`)은 이 PC의 모든 저장소에 적용된다. 공용 PC에서는 설정 후 DEV-GIT-001-MP로 제거한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 터미널을 연다 | 프롬프트가 나타난다 |
| 2 | Git이 설치돼 있는지 확인한다 | `git --version`에 버전 번호가 출력된다 |

## 5. 절차

### A. 사용자 정보 설정

1. (5-A-01) 사용자 이름을 설정한다: `git config --global user.name "<이름>"`
2. (5-A-02) 이메일을 설정한다: `git config --global user.email "<이메일>"` → 결과: 두 명령 모두 오류 없이 끝난다.
3. (5-A-03) 설정을 확인한다: `git config --global --list` → 결과: `user.name`, `user.email` 행에 입력한 값이 보인다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `git config --global user.name` | 설정한 이름이 출력된다 | 입력값과 일치 |
| 2 | `git config --global user.email` | 설정한 이메일이 출력된다 | 입력값과 일치 |

## 7. 복구

1. (7-01) 설정을 지운다: `git config --global --unset user.name`, `git config --global --unset user.email`

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 연결 해제 절차를 DEV-GIT-001-MP로 분리하고, 사용자 정보 설정 절차와 참조 표로 재작성 |
