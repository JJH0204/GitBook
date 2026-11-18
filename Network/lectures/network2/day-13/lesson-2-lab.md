# 로컬 Git 실습

> 상위: [13일차 · Git 과 GitHub](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-13-008-MP |
| 목적 | WSL에서 Git을 설정하고, 저장소를 만들어 `add`, `commit`, `diff`, `log`로 이력을 만들며, `.gitignore`로 비밀 파일을 제외한다 |
| 적용 대상 | Windows 10/11의 WSL(Ubuntu 24.04), Git 2.43 |
| 소요 시간 | 약 35분 |
| 확인 상태 | 미검증 (원본에 "2026-10-16 WSL Ubuntu 24.04 / git 2.43.0에서 실측"이라는 기록이 있으나, 이 문서는 이번 재작성에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1.md](lesson-1.md) | LEC-N2-13-001-DO | 버전 관리란 |
| [lesson-2.md](lesson-2.md) | LEC-N2-13-002-DO | 로컬 Git |
| [commands.md](commands.md) | LEC-N2-13-007-REF | 13일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | WSL(Ubuntu) | 24.04 | 이 실습은 WSL 터미널에서만 한다 |
| 2 | Git | 2.43 | 없으면 `sudo apt install -y git` |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 비밀번호, 키, 개인키(`~/.ssh/id_ed25519`)를 저장소에 넣지 않는다. 한 번 커밋하면 파일을 지워도 이력에 남는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 구역 A의 3단계(`core.editor nano`)를 건너뛰면 `git commit`에서 vim이 열린다. 열렸다면 `Esc`, `:q!`, Enter를 차례로 누른다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Git이 설치되어 있다 | `git --version`이 버전을 출력한다 |
| 2 | WSL 터미널이 열려 있다 | 프롬프트가 `<사용자>@<호스트>:~$` 형태이다 |

## 5. 절차

### A. 맨 처음 한 번

1. (5-A-01) 이름을 설정한다: `git config --global user.name "<이름>"`
2. (5-A-02) 이메일을 설정한다: `git config --global user.email "<이메일>"`
3. (5-A-03) 에디터를 nano로 설정한다: `git config --global core.editor nano` → 결과: 오류 없이 끝난다.
4. (5-A-04) 기본 브랜치를 설정한다: `git config --global init.defaultBranch main`
5. (5-A-05) 설정을 확인한다: `git config --list | head -10` → 결과: 앞의 네 값이 출력에 포함된다.

### B. 저장소 만들기

1. (5-B-01) 폴더를 만들고 이동한다: `mkdir ~/myweb && cd ~/myweb`
2. (5-B-02) 저장소를 만든다: `git init` → 결과: `Initialized empty Git repository` 메시지가 나온다.
3. (5-B-03) 숨김 파일을 확인한다: `ls -a` → 결과: `.git/`이 보인다.
4. (5-B-04) 상태를 확인한다: `git status` → 결과: `No commits yet`이 보인다.

### C. 빨강, 초록, clean

1. (5-C-01) 파일을 만든다: `echo "<h1>안녕하세요</h1>" > index.html`
2. (5-C-02) `git status`를 실행한다. → 결과: `Untracked files`에 `index.html`이 빨강으로 보인다(① 작업 디렉터리).
3. (5-C-03) 스테이지에 담는다: `git add index.html`
4. (5-C-04) `git status`를 실행한다. → 결과: `Changes to be committed`에 초록으로 보인다(② 스테이지).
5. (5-C-05) 커밋한다: `git commit -m "첫 페이지 추가"` → 결과: 커밋 한 줄 요약이 출력된다.
6. (5-C-06) `git status`를 실행한다. → 결과: `nothing to commit, working tree clean`(③ 저장소).

### D. 이력과 변경 보기

1. (5-D-01) 줄을 추가한다: `echo "<p>반갑습니다</p>" >> index.html`
2. (5-D-02) `git diff`를 실행한다. → 결과: 추가한 줄이 `+`로 보인다(아직 담지 않은 변경).
3. (5-D-03) 담는다: `git add .`
4. (5-D-04) `git diff --staged`를 실행한다. → 결과: 담긴 변경이 `+`로 보인다.
5. (5-D-05) 커밋한다: `git commit -m "인사말 추가"`
6. (5-D-06) `git log --oneline`을 실행한다. → 결과: 커밋 두 줄이 보인다.
7. (5-D-07) `git log --oneline | head -5`를 실행한다. → 결과: 같은 이력이 최대 5줄까지 출력된다.

### E. `.gitignore`

{% hint style="danger" %}
WARNING: `.gitignore`를 만들기 전에는 `.env`, `*.key`, `id_rsa` 같은 파일을 이 폴더에 두지 않는다. 12일차에 만든 `~/.ssh/id_ed25519`는 어떤 저장소에도 복사하지 않는다.
{% endhint %}

1. (5-E-01) `nano .gitignore`로 파일을 연다.
2. (5-E-02) 아래 다섯 줄을 입력하고 저장한다(`Ctrl+O`, Enter, `Ctrl+X`).

```
.env
*.key
id_rsa
*.log
tmp/
```

3. (5-E-03) 담는다: `git add .gitignore`
4. (5-E-04) 커밋한다: `git commit -m ".gitignore 추가"` → 결과: 커밋 한 줄 요약이 출력된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `git status` | `working tree clean` | 문구가 그대로 보인다 |
| 2 | `git log --oneline` | 커밋 3개 | 세 줄이 보인다 |
| 3 | `touch test.log && git status` | `test.log`가 목록에 없다 | `.gitignore`가 `*.log`를 제외한다 |
| 4 | 단계 5-C의 `git status` 색 | 빨강, 초록, clean | 각 색이 세 자리 중 어디인지 말한다 |

## 7. 복구

1. (7-01) 담은 것을 빼려면: `git restore --staged <파일>` → 결과: 스테이지에서 작업 디렉터리로 돌아간다.
2. (7-02) 고친 것을 버리려면: `git restore <파일>`

{% hint style="danger" %}
WARNING: `git restore <파일>`은 수정분이 사라진다. 되돌릴 수 없다.
{% endhint %}

3. (7-03) 실습 폴더를 처음부터 다시 하려면: `rm -rf ~/myweb`을 실행한다. → 결과: 폴더와 `.git/`이 삭제된다. [GitHub 연결 실습](lesson-3-lab.md)에서 이 저장소를 쓰므로 그 실습 이후에는 실행하지 않는다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-2.md`와 `commands.md`의 실습 항목을 AMM 형식으로 재작성 |
