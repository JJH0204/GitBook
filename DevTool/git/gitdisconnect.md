# 사용하지 않는 PC의 Git 접근 해제

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-GIT-001-MP |
| 목적 | 더 이상 쓰지 않는 PC에서 Git 사용자 정보, SSH 키, 저장된 자격 증명을 제거해 그 PC로 저장소에 접근하지 못하게 한다 |
| 적용 대상 | Windows 10/11 또는 macOS/Linux, Git 2.x, 터미널 사용 가능 |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 문서로 다시 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서의 절차는 서로 독립이다. 필요한 구역만 수행할 수 있다. 다만 PC를 폐기하거나 양도할 때는 구역 A~D를 모두 수행한다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [git.md](git.md) | DEV-GIT-002-MP | Git 기본 설정 |
| [gitsshkey.md](gitsshkey.md) | DEV-GIT-003-MP | Git SSH 키 생성과 등록 |
| [how2usegit.md](how2usegit.md) | DEV-GIT-004-MP | Git 사용법 (GitHub Desktop) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 터미널 | Git Bash, PowerShell, macOS 터미널 중 하나 | |
| 2 | 대상 PC 사용자 권한 | 본인 계정 | 관리자 권한은 필요하지 않다 |
| 3 | GitHub 웹 접속 가능한 다른 기기 | 브라우저 | 구역 E에서 사용 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: SSH 키를 삭제하면 그 키로만 접속하던 서버와 저장소에 이 PC로 다시 접속할 수 없다. 키를 다른 곳에 백업하지 않았다면 삭제 전에 구역 B의 1~2단계로 백업한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 터미널을 연다 | 프롬프트가 나타난다 |
| 2 | Git이 설치돼 있는지 확인한다: `git --version` | 버전 번호가 출력된다 |
| 3 | 이 PC에서 아직 커밋하지 않은 작업이 있는지 확인한다 | 각 저장소에서 `git status`의 결과가 `nothing to commit`이다 |

## 5. 절차

### A. Git 전역 설정의 사용자 정보 제거

1. (5-A-01) 현재 설정을 확인한다: `git config --global --list` → 결과: `user.name`, `user.email` 행이 보인다.
2. (5-A-02) 사용자 이름을 제거한다: `git config --global --unset user.name`
3. (5-A-03) 이메일을 제거한다: `git config --global --unset user.email` → 결과: 두 명령 모두 오류 없이 끝난다.

### B. SSH 키 삭제

1. (5-B-01) 키 파일 목록을 확인한다: `ls ~/.ssh` (PowerShell: `dir $HOME\.ssh`) → 결과: `id_rsa`, `id_rsa.pub`, 또는 `id_ed25519` 계열 파일이 보인다.
2. (5-B-02) 필요하면 백업한다: 개인 키 파일을 안전한 이동식 저장 장치에 복사한다.
3. (5-B-03) 개인 키와 공개 키를 삭제한다: `rm ~/.ssh/<키 파일 이름>` 과 `rm ~/.ssh/<키 파일 이름>.pub` (PowerShell: `Remove-Item`) → 결과: `ls ~/.ssh`에 해당 파일이 더 이상 없다.

{% hint style="info" %}
NOTE: 키 이름이 `id_rsa`가 아닐 수 있다(`id_ed25519` 등). 5-B-01에서 확인한 실제 이름을 쓴다.
{% endhint %}

### C. 캐시된 자격 증명 삭제

1. (5-C-01) 자격 증명 캐시 데몬을 종료한다: `git credential-cache exit` → 결과: 오류 없이 끝난다. (캐시 데몬이 없으면 아무 변화가 없다. 이 명령은 메모리 캐시만 지운다.)

### D. Windows 자격 증명 관리자 항목 삭제 (Windows만)

1. (5-D-01) `자격 증명 관리자`를 연다: 시작 메뉴에서 검색한다.
2. (5-D-02) `Windows 자격 증명`을 연다.
3. (5-D-03) `git:https://github.com` 형태의 항목을 찾는다.
4. (5-D-04) 항목을 펼쳐 `제거`를 누른다 → 결과: 항목이 목록에서 사라진다.

### E. GitHub 쪽 접근 해제 (다른 기기에서)

1. (5-E-01) GitHub에 로그인해 `Settings > SSH and GPG keys`를 연다.
2. (5-E-02) 이 PC에서 쓰던 키를 찾아 `Delete`를 누른다. → 결과: 목록에서 키가 사라진다.
3. (5-E-03) `Settings > Applications`에서 이 PC에서 허용한 인증 앱(예: GitHub Desktop)의 접근을 취소한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `git config --global user.name` | 출력이 없다 | 빈 출력 |
| 2 | `ls ~/.ssh` | 삭제한 키 파일이 없다 | 목록에 해당 파일 없음 |
| 3 | `git ls-remote <비공개 저장소 주소>` | 인증 실패 또는 자격 증명 입력 요구가 나온다 | 저장소 목록이 출력되지 않는다 |

## 7. 복구

1. (7-01) 사용자 정보를 다시 설정한다: DEV-GIT-002-MP를 따른다.
2. (7-02) SSH 키를 새로 만든다: DEV-GIT-003-MP를 따른다. 삭제한 키는 복구되지 않는다(5-B-02에서 백업한 경우만 복사해 되돌린다).

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지 `git.md`의 "사용하지 않는 PC에서 git 연결 해제하기"를 AMM 형식으로 재작성 |
