# 2. 로컬 Git — 내 컴퓨터 안에서 먼저 ⭐

> 상위: [13일차 · Git 과 GitHub](README.md) · 대본 [STEP 2](commands.md)

## 🎯 학습 목표

- `git init` · `add` · `commit` · `status` · `log` · `diff` 를 손에 익힌다
- `git status` 의 **빨강 / 초록**이 [세 자리](lesson-1.md) 중 어디인지 읽는다
- `.gitignore` 로 **올리면 안 되는 것**을 제외한다 ⚠️
- 잘못 담은 것을 **되돌린다** (`restore`)

## 🌉 다리 놓기: "인터넷 없이도 Git 이다"

Git 을 GitHub 와 묶어서 생각하기 쉬운데, **Git 은 인터넷 없이도 완전히 동작한다.**
오늘 2번 절은 **내 WSL 안에서만** 한다. GitHub 는 3번에서.

> 🗣 **"비행기 안에서도 커밋은 됩니다. push 만 못 할 뿐이죠."**

---

## 📖 ① 맨 처음 한 번 — 이름표와 에디터

```bash
git config --global user.name  "Hong Gildong"
git config --global user.email "me@example.com"
git config --global core.editor nano          # ⭐ 안 하면 vim 이 떠서 못 빠져나온다
git config --global init.defaultBranch main   # 기본 브랜치 이름
git config --list                             # 확인
```

> ⚠️ **`core.editor nano` 를 꼭 먼저.** 안 하면 `git commit` 에서 **vim** 이 뜨고, 거기서 10분을 잃는다.
> (혹시 열렸다면 `Esc` → `:q!` → Enter)

- 이메일·이름은 **커밋마다 박힌다.** 나중에 GitHub 계정 이메일과 맞추면 좋다

---

## 📖 ② 저장소 만들기 · 상태 보기

```bash
mkdir ~/myweb && cd ~/myweb
git init                      # .git/ 이 생긴다 = 여기부터 Git 이 지켜본다
ls -a                         # 10일차 ls -a 회수 — 숨김 폴더 .git 확인
git status
```

```
On branch main
No commits yet
nothing to commit (create/copy files and use "git add" to track)
```

**파일을 만들고 다시 보자.**

```bash
echo "<h1>안녕하세요</h1>" > index.html
git status
```

```
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        index.html            ← 🔴 빨강 = ① 작업 디렉터리에만 있다
```

> 💡 **`git status` 는 "지금 어느 자리인가"를 알려주는 나침반**이다. 막히면 **일단 `git status`**.

---

## 📖 ③ 담고 · 계산하기 — `add` → `commit`

```bash
git add index.html            # 장바구니에 담기
git status                    # 🟢 초록 = ② 스테이지
git commit -m "첫 페이지 추가"  # 계산하기
git status                    # nothing to commit, working tree clean ✅
```

| 명령 | 뜻 | 자리 이동 |
|------|-----|-----------|
| `git add <파일>` | 이 파일을 **이번 커밋에 넣겠다** | ① → ② |
| `git add .` | **지금 폴더의 변경 전부** | ① → ② |
| `git commit -m "메시지"` | 담은 것을 **확정** | ② → ③ |
| `git commit -am "메시지"` | **이미 추적 중인** 파일은 add 생략 | ① → ③ (새 파일은 안 된다 ⚠️) |

> ⚠️ **`-am` 은 새 파일에는 안 먹는다.** "분명 커밋했는데 파일이 없다"의 1번 원인.

---

## 📖 ④ 이력 읽기 — `log` 와 `diff`

```bash
git log                                  # 전체
git log --oneline                        # 한 줄씩 ⭐
git log --oneline --graph --all          # 그림으로 (브랜치 볼 때)
git log --oneline | head -5              # 10일차 파이프 회수
```

```
a3f9c21 (HEAD -> main) 로그인 폼 추가
8b2e104 첫 페이지 추가
```

**무엇이 바뀌었나**

```bash
echo "<p>반갑습니다</p>" >> index.html
git diff                      # ① 작업 디렉터리 vs ② 스테이지 (아직 안 담은 변경)
git add index.html
git diff --staged             # ② 스테이지 vs ③ 마지막 커밋 (담긴 변경)
```

```
-<h1>안녕하세요</h1>
+<h1>안녕하세요</h1>
+<p>반갑습니다</p>
```

- **`-` 는 뺀 줄, `+` 는 더한 줄** — 12일차 `diff` 와 같은 표기

---

## 📖 ⑤ `.gitignore` — 올리면 안 되는 것 ⚠️

```bash
nano .gitignore
```

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

```bash
git add .gitignore
git commit -m ".gitignore 추가"
```

> 🚨 **오늘 가장 중요한 경고.** **비밀번호 · API 키 · 개인키를 커밋하면 지워도 이력에 남는다.**
> GitHub 에 올라간 키는 **몇 분 안에 자동 수집**된다. 실제 사고의 단골이다.
> → 12일차에 만든 **`~/.ssh/id_ed25519`(개인키)** 는 **어떤 저장소에도 들어가면 안 된다**

> ⚠️ `.gitignore` 는 **아직 추적 안 하는 파일**에만 듣는다. 이미 커밋한 파일은 `git rm --cached <파일>` 로 빼야 한다

---

## 📖 ⑥ 되돌리기 — 3초 멈춤 목록 포함

| 하고 싶은 일 | 명령 | 위험도 |
|--------------|------|--------|
| 담은 걸 **빼기** (② → ①) | `git restore --staged <파일>` | 안전 |
| 고친 걸 **버리기** (① 초기화) | `git restore <파일>` | ⚠️ **수정분이 날아간다** |
| 마지막 **커밋 메시지만** 고치기 | `git commit --amend` | 주의 (이미 push 했으면 쓰지 말 것) |

> 🛑 **AI 가 이걸 주면 3초 멈춘다** — `git reset --hard` · `git push --force` · `rm -rf .git`
> 셋 다 **되돌릴 수 없다.** 11일차 `ufw reset` · 10일차 `chmod 777` 과 같은 자리의 명령이다.

---

## 🧪 실습 / 질문

- `git add` 를 안 하고 `git commit` 하면 어떻게 되나? 직접 해보자
- `git status` 에서 **빨강과 초록**은 각각 세 자리 중 어디인가?
- `.gitignore` 에 `*.log` 를 적었는데 이미 커밋한 `app.log` 는 사라질까?
- 실수로 `secret.conf` 를 커밋했다. 파일을 지우고 다시 커밋하면 안전할까? (→ **아니다**)

## 📝 강의 메모

- ⭐ **`git config core.editor nano` 를 STEP 2 맨 처음에** — 이거 하나로 사고 절반이 사라진다
- `git status` 를 **명령 사이마다 치게** 한다. "지금 어느 자리죠?" 를 반복
- 빨강 → `add` → 초록 → `commit` → clean. 이 **색 변화**를 눈으로 보는 게 이 절의 전부다
- 🚨 **`.gitignore` 와 키 유출 경고는 시간이 없어도 반드시** — 실제 사고가 제일 많은 지점
- ⏱ 실습 30분. 되돌리기(⑥)는 시간 없으면 **표만 보여주고** 넘어간다
