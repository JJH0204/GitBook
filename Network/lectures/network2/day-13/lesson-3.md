# 3. GitHub 와 원격 저장소 — SSH 키는 12일차 그것 ⭐⭐

> 상위: [13일차 · Git 과 GitHub](README.md) · 대본 [STEP 3](commands.md)

## 🎯 학습 목표

- **Git 과 GitHub 의 차이**를 설명한다
- **12일차에 만든 SSH 키**를 GitHub 에 등록해 인증한다 ⭐
- `remote add` · `push` · `pull` · `clone` 을 구분해서 쓴다
- HTTPS 와 SSH 두 방식의 차이를 안다

## 🌉 다리 놓기: "지난주에 만든 그 키, 오늘 또 씁니다"

12일차에 우리는 **비밀번호 없이 SSH 로 들어가는 법**을 배웠다.

```bash
ssh-keygen -t ed25519              # 열쇠 한 쌍을 만들고
# 공개키를 서버의 ~/.ssh/authorized_keys 에 넣었다
```

> 🗣 **"그때 만든 공개키, 오늘은 GitHub 에 넣습니다. 하는 일이 완전히 똑같습니다."**

| | 12일차 (내 서버) | 오늘 (GitHub) |
|---|---|---|
| 개인키 | 내 WSL `~/.ssh/id_ed25519` | **같은 것** |
| 공개키를 어디에 | 서버의 `~/.ssh/authorized_keys` | **GitHub 설정 화면** |
| 결과 | 비밀번호 없이 `ssh` | 비밀번호 없이 `push` |

**열쇠와 자물쇠 비유 그대로다.** 자물쇠(공개키)를 하나 더 다는 것뿐이다.

---

## 📖 ① Git 과 GitHub — 다시 한 번

| | Git | GitHub |
|---|---|---|
| 정체 | **프로그램** (내 컴퓨터) | **웹 서비스** (남의 서버) |
| 없으면 | 버전 관리를 못 한다 | **불편할 뿐, 버전 관리는 된다** |
| 비슷한 것 | — | GitLab · Bitbucket · 사내 Git 서버 |

> 💡 **비유.** Git = **카메라**, GitHub = **사진 공유 앱**. 카메라만 있어도 사진은 찍힌다.

**원격 저장소를 두는 이유 세 가지**
1. **백업** — 내 WSL 이 날아가도 코드는 산다
2. **협업** — 여럿이 같은 저장소에 모인다
3. **배포** — 서버에서 `git clone` 으로 받는다 → [5_서버에_배포해보기](lesson-5.md)

---

## 📖 ② 인증 — HTTPS 냐 SSH 냐

| | HTTPS | **SSH** ⭐ |
|---|---|---|
| 주소 | `https://github.com/user/repo.git` | `git@github.com:user/repo.git` |
| 인증 | 토큰(비밀번호 아님) 매번 | **키 한 번 등록하면 끝** |
| 포트 | 443 | **22** (10일차 포트표!) |
| 수업에서 | 사내망이 22를 막을 때만 | **이쪽으로 한다** |

> ⚠️ GitHub 는 **비밀번호 인증을 폐지**했다. HTTPS 를 쓰려면 **Personal Access Token** 을 따로 만들어야 한다.
> → 그래서 **SSH 가 더 간단하다.** 게다가 우리는 **이미 키가 있다.**

---

## 📖 ③ 공개키 등록 ⭐ — 12일차 그대로

```bash
# 🐧 WSL — 키가 있나 확인
ls -l ~/.ssh/
cat ~/.ssh/id_ed25519.pub          # 공개키 (ssh-ed25519 AAAA... 로 시작)
```

키가 없으면 12일차처럼 만든다.

```bash
ssh-keygen -t ed25519 -C "me@example.com"     # Enter 세 번 (암호는 비워도 된다)
```

**복사해서 GitHub 에 붙인다.**

```
🌐 GitHub → 우측 상단 프로필 → Settings → SSH and GPG keys
   → New SSH key → Title: "KoreaIT WSL" → Key: (붙여넣기) → Add SSH key
```

**연결 확인** ⭐

```bash
ssh -T git@github.com
```

```
Hi hong-gildong! You've successfully authenticated, but GitHub does not provide shell access.
```

> ✅ 이 문장이 뜨면 성공이다. **"shell access 는 안 준다"** 는 건 정상 — GitHub 는 로그인용 서버가 아니니까.
> 🚨 **`id_ed25519`(개인키, `.pub` 없는 쪽)는 절대 올리지 않는다.** 등록하는 건 **`.pub`** 뿐이다 → [2_로컬_Git](lesson-2.md) `.gitignore`

---

## 📖 ④ 원격 저장소 연결 · 올리기

**GitHub 에서 빈 저장소를 먼저 만든다** (README 체크 **해제** — 안 그러면 첫 push 가 충돌한다)

```
🌐 GitHub → New repository → 이름 myweb → Public → Create
```

```bash
# 🐧 WSL — 2번 절에서 만든 ~/myweb 에서
cd ~/myweb
git remote add origin git@github.com:hong-gildong/myweb.git
git remote -v                       # 확인
git branch -M main
git push -u origin main             # 첫 push
```

| 명령 | 뜻 |
|------|-----|
| `remote add origin <주소>` | "**origin** 이라는 별명으로 이 원격을 등록" |
| `origin` | 관례적인 별명일 뿐 (다른 이름도 된다) |
| `push -u origin main` | 올리고, **앞으로 `git push` 만 쳐도 되게** 기억시킨다 |

```bash
# 이후부터는
git add .
git commit -m "내용 수정"
git push
```

---

## 📖 ⑤ 받아오기 — `pull` 과 `clone`

| 명령 | 언제 |
|------|------|
| **`git clone <주소>`** | **처음** — 저장소를 통째로 복제 (폴더가 새로 생긴다) |
| **`git pull`** | **이미 있는** 저장소를 최신으로 (= `fetch` + `merge`) |

```bash
cd ~
git clone git@github.com:hong-gildong/myweb.git  myweb2
cd myweb2 && git log --oneline        # 이력까지 통째로 따라온다 ⭐
```

> 💡 **`clone` 은 복사가 아니라 "이력째 복제"** 다. 그래서 `myweb2` 에서도 과거로 돌아갈 수 있다.

> ⚠️ **다른 PC·웹에서 고쳤다면 `push` 전에 `pull` 먼저.** 안 하면 `rejected` 가 난다.

---

## 🧪 실습 / 질문

- `ssh -T git@github.com` 이 `Permission denied (publickey)` 라면 무엇을 확인하겠나?
- 공개키와 개인키 중 GitHub 에 올리는 것은? 나머지 하나는 어디에 있어야 하나?
- `clone` 과 `pull` 은 각각 언제 쓰나?
- GitHub 가 내일 문을 닫으면 내 코드는 사라질까? (→ **아니다.** 왜?)

## 📝 강의 메모

- ⭐⭐ **이 절이 오늘의 하이라이트다.** 12일차 키 인증을 **그대로 재사용**하는 장면에서 "아, 그게 이거였구나"가 나온다
  - 칠판에 **12일차 그림(열쇠/자물쇠)** 을 다시 그리고 자물쇠 하나만 GitHub 로 바꿔 그린다
- 🚨 **개인키/공개키 혼동**이 1번 사고다. **`.pub` 가 붙은 것만 올린다** 를 세 번 말할 것
- ⚠️ 저장소 만들 때 **"Add a README" 체크 해제** — 체크하면 첫 push 가 거부되고 수습에 10분
- `ssh -T` 성공 메시지의 **"does not provide shell access"** 를 미리 설명 — 에러로 착각한다
- 🌐 GitHub 화면은 **강사 화면을 띄워 놓고** 같이 클릭한다. 영문 UI 라 헤맨다
- ⏱ 실습 30분 중 **키 등록에 15분**은 잡아 둘 것
