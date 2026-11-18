# 2. 로컬 Git — 내 컴퓨터 안에서 먼저

> 상위: [13일차 · Git 과 GitHub](README.md) · 절차는 [로컬 Git 실습](lesson-2-lab.md), 대본은 [STEP 2](commands.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-13-002-DO |
| 유형 | D&O (개념) |
| 목적 | 인터넷 없이 동작하는 로컬 Git의 명령(`init`, `add`, `commit`, `status`, `log`, `diff`), `.gitignore`, 되돌리기를 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- `git init`, `add`, `commit`, `status`, `log`, `diff`를 손에 익힌다.
- `git status`의 빨강과 초록이 [세 자리](lesson-1.md) 중 어디인지 읽는다.
- `.gitignore`로 올리면 안 되는 것을 제외한다.
- 잘못 담은 것을 되돌린다(`restore`).

## 1. 목적

Git을 GitHub와 묶어서 생각하기 쉽다. 그러나 Git은 인터넷 없이도 완전히 동작한다. 이 절은 WSL 안에서만 한다. GitHub는 3번 절에서 다룬다. 비행기 안에서도 커밋은 된다. `push`만 못 할 뿐이다.

## 2. 구성 요소

### 맨 처음 한 번: 이름표와 에디터

| 설정 | 명령 | 이유 |
|---|---|---|
| 이름 | `git config --global user.name "<이름>"` | 커밋마다 박힌다 |
| 이메일 | `git config --global user.email "<이메일>"` | 커밋마다 박힌다. GitHub 계정 이메일과 맞추면 좋다 |
| 에디터 | `git config --global core.editor nano` | 안 하면 `git commit`에서 vim이 떠서 빠져나오지 못한다 |
| 기본 브랜치 | `git config --global init.defaultBranch main` | 기본 브랜치 이름 |
| 확인 | `git config --list` | 설정 목록 |

{% hint style="warning" %}
CAUTION: `core.editor nano`를 먼저 설정한다. 설정하지 않으면 `git commit`에서 vim이 열려 10분을 잃는다. 열렸다면 `Esc`, `:q!`, Enter를 차례로 누른다.
{% endhint %}

### 저장소 만들기와 상태 보기

| 명령 | 뜻 |
|---|---|
| `git init` | `.git/`이 생긴다. 여기부터 Git이 지켜본다 |
| `ls -a` | 숨김 폴더 `.git`을 확인한다(10일차 `ls -a` 회수) |
| `git status` | 지금 어느 자리인지 알려 주는 나침반이다. 막히면 일단 `git status` |

`git init` 직후 `git status`의 출력은 다음과 같다.

```
On branch main
No commits yet
nothing to commit (create/copy files and use "git add" to track)
```

파일을 만들고 다시 보면 다음과 같다.

```
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        index.html            ← 빨강 = ① 작업 디렉터리에만 있다
```

### 담고 계산하기: `add`와 `commit`

| 명령 | 뜻 | 자리 이동 |
|---|---|---|
| `git add <파일>` | 이 파일을 이번 커밋에 넣겠다 | ① → ② |
| `git add .` | 지금 폴더의 변경 전부 | ① → ② |
| `git commit -m "<메시지>"` | 담은 것을 확정 | ② → ③ |
| `git commit -am "<메시지>"` | 이미 추적 중인 파일은 add 생략 | ① → ③ (새 파일은 안 된다) |

{% hint style="warning" %}
CAUTION: `-am`은 새 파일에는 적용되지 않는다. "분명 커밋했는데 파일이 없다"의 1번 원인이다.
{% endhint %}

### 이력 읽기: `log`와 `diff`

| 명령 | 뜻 |
|---|---|
| `git log` | 전체 이력 |
| `git log --oneline` | 한 줄씩 |
| `git log --oneline --graph --all` | 그림으로(브랜치를 볼 때) |
| `git log --oneline \| head -5` | 10일차 파이프 회수 |
| `git diff` | ① 작업 디렉터리와 ② 스테이지의 차이(아직 안 담은 변경) |
| `git diff --staged` | ② 스테이지와 ③ 마지막 커밋의 차이(담긴 변경) |

```
a3f9c21 (HEAD -> main) 로그인 폼 추가
8b2e104 첫 페이지 추가
```

```
-<h1>안녕하세요</h1>
+<h1>안녕하세요</h1>
+<p>반갑습니다</p>
```

`-`는 뺀 줄, `+`는 더한 줄이다. 12일차 `diff`와 같은 표기이다.

### `.gitignore`: 올리면 안 되는 것

```gitignore
# 비밀 — 절대 올리지 않는다
.env
*.key
id_rsa
secret.conf

# 로그 · 임시
*.log
tmp/

# OS 가 만드는 것
.DS_Store
```

{% hint style="danger" %}
WARNING: 비밀번호, API 키, 개인키를 커밋하면 파일을 지워도 이력에 남는다. GitHub에 올라간 키는 몇 분 안에 자동 수집된다. 12일차에 만든 `~/.ssh/id_ed25519`(개인키)는 어떤 저장소에도 들어가면 안 된다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `.gitignore`는 아직 추적하지 않는 파일에만 적용된다. 이미 커밋한 파일은 `git rm --cached <파일>`로 추적에서 뺀다.
{% endhint %}

### 되돌리기

| 하고 싶은 일 | 명령 | 위험도 |
|---|---|---|
| 담은 것을 빼기(② → ①) | `git restore --staged <파일>` | 안전 |
| 고친 것을 버리기(① 초기화) | `git restore <파일>` | 수정분이 사라진다 |
| 마지막 커밋 메시지만 고치기 | `git commit --amend` | 주의(이미 push했으면 쓰지 않는다) |

{% hint style="danger" %}
WARNING: AI가 `git reset --hard`, `git push --force`, `rm -rf .git`을 답으로 주면 3초 멈춘다. 셋 다 되돌릴 수 없다. 11일차 `ufw reset`, 10일차 `chmod 777`과 같은 자리의 명령이다.
{% endhint %}

## 3. 동작 원리

색 변화로 자리를 읽는다.

1. 파일을 만들거나 고친다. `git status`가 빨강(Untracked 또는 Changes not staged)을 보인다. 자리는 ①이다.
2. `git add`를 한다. `git status`가 초록(Changes to be committed)을 보인다. 자리는 ②이다.
3. `git commit`을 한다. `git status`가 `working tree clean`을 보인다. 자리는 ③이다.

명령 사이마다 `git status`를 쳐서 "지금 어느 자리인가"를 확인한다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| Untracked | Git이 아직 추적하지 않는 새 파일 |
| `HEAD` | 지금 보고 있는 커밋(현재 브랜치의 끝) |
| working tree clean | 작업 디렉터리에 커밋하지 않은 변경이 없는 상태 |
| `.gitignore` | 추적에서 제외할 파일 패턴 목록 |

## 그림 목록

| 번호 | 그림 | 설명 |
|---|---|---|
| 1 | 세 자리 그림 | [1. 버전 관리란](lesson-1.md)의 그림을 `git status` 색과 함께 다시 그린다 |

## 강의 메모

- `git config core.editor nano`를 STEP 2 맨 처음에 설정한다. 이것 하나로 사고 절반이 사라진다.
- `git status`를 명령 사이마다 치게 한다. "지금 어느 자리인가"를 반복해서 묻는다.
- 빨강, `add`, 초록, `commit`, clean. 이 색 변화를 눈으로 보는 것이 이 절의 전부다.
- `.gitignore`와 키 유출 경고는 시간이 없어도 반드시 다룬다. 실제 사고가 가장 많은 지점이다.
- 실습은 30분이다. 되돌리기는 시간이 없으면 표만 보여주고 넘어간다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `git add` 없이 `git commit`을 하면 어떻게 되는가? 직접 해 보고 적는다.
- [ ] `git status`의 빨강과 초록은 각각 세 자리 중 어디인가?
- [ ] `.gitignore`에 `*.log`를 적었는데 이미 커밋한 `app.log`는 사라지는가? 실수로 `secret.conf`를 커밋하고 파일을 지운 뒤 다시 커밋하면 안전한가? 이유와 함께 적는다.
