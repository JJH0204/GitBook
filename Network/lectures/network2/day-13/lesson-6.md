# 6. 오늘의 문제 🎯

> 상위: [13일차 · Git 과 GitHub](README.md)
> 💡 **진행 방법**: 각자 먼저 풀게 한 뒤 → `정답 및 해설` 콜아웃을 펼쳐 함께 확인한다.

---

## Q1. 세 자리 — [1_버전관리란](lesson-1.md) · [2_로컬_Git](lesson-2.md)

You edited `index.html` and ran `git commit -m "fix"` **without** `git add`.
What happens to your change?
(`git add` 없이 `git commit` 을 했다. 수정한 내용은 어떻게 되나?)

- A. 커밋에 포함된다
- B. **커밋되지 않는다 — 스테이지가 비어 있다**
- C. 파일이 삭제된다
- D. 자동으로 add 된다

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- 커밋은 **스테이지(②)에 담긴 것**만 묶는다. 담지 않았으면 담을 게 없다
- `nothing added to commit but untracked files present` 같은 메시지가 뜬다
- 비유: **장바구니에 안 담고 계산대에 간 것**
- 예외처럼 보이는 `git commit -am` 은 **이미 추적 중인 파일**만 자동으로 담는다 — **새 파일은 안 된다**
{% endhint %}

---

## Q2. 공개키와 개인키 ⭐ — [3_GitHub와_원격저장소](lesson-3.md) · 12일차

Which file do you paste into GitHub's "New SSH key" screen?
(GitHub 의 SSH key 등록 화면에 붙여 넣는 것은?)

- A. `~/.ssh/id_ed25519`
- B. **`~/.ssh/id_ed25519.pub`**
- C. `~/.ssh/known_hosts`
- D. `~/.ssh/config`

{% hint style="success" %}
**정답 및 해설**

**정답: B — `.pub` 가 붙은 공개키**
- **공개키 = 자물쇠**. 남에게 줘도 된다. **개인키 = 열쇠**. 절대 밖으로 내보내지 않는다
- 12일차에 서버의 `~/.ssh/authorized_keys` 에 넣은 것과 **같은 파일**이다. 자물쇠를 하나 더 다는 것
- 🚨 A(개인키)를 올리면 **그 키로 열리는 모든 서버가 뚫린다**
{% endhint %}

---

## Q3. 비밀이 커밋됐다 — [2_로컬_Git](lesson-2.md)

You committed `secret.conf` containing a password, then deleted the file and committed again.
Is the password safe?
(비밀번호가 든 파일을 커밋한 뒤, 파일을 지우고 다시 커밋했다. 안전한가?)

- A. 안전하다 — 파일이 없으니까
- B. **안전하지 않다 — 이력에 그대로 남아 있다**
- C. 안전하다 — `.gitignore` 에 추가하면 된다
- D. GitHub 가 자동으로 지워 준다

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- Git 은 **이력을 지우지 않는다.** `git log` 로 과거 커밋을 열면 **그대로 보인다**
- 이미 공개 저장소에 올라갔다면 **그 비밀번호 · 키는 유출된 것**으로 보고 **즉시 교체**해야 한다
- 예방: **`.gitignore` 를 먼저** 만든다. `.env` · `*.key` · `id_rsa` · `*.conf`
- `.gitignore` 는 **아직 추적 안 하는 파일**에만 듣는다 → 이미 커밋한 건 `git rm --cached`
{% endhint %}

---

## Q4. clone 과 pull — [3_GitHub와_원격저장소](lesson-3.md)

You already have the repository on your machine and want the latest changes. Which command?
(이미 저장소가 있고 최신 변경만 받고 싶다. 무엇을 쓰나?)

- A. `git clone`
- B. **`git pull`**
- C. `git push`
- D. `git init`

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- **`clone`** = **처음** 한 번. 저장소를 **통째로 복제**하고 **새 폴더**를 만든다
- **`pull`** = 이미 있는 저장소를 **최신으로** (= `fetch` + `merge`)
- `push` 는 **올리기**, `init` 은 **새 저장소 만들기**
- ⚠️ 다른 곳에서 고쳤다면 **`push` 전에 `pull`** — 안 하면 `rejected`
{% endhint %}

---

## Q5. 충돌 ⭐ — [4_브랜치와_협업](lesson-4.md)

When does Git report a merge conflict?
(Git 이 충돌을 알리는 경우는?)

- A. 브랜치를 만들 때마다
- B. 두 브랜치가 **서로 다른 파일**을 고쳤을 때
- C. **두 브랜치가 같은 파일의 같은 줄을 다르게 고쳤을 때**
- D. 커밋 메시지가 같을 때

{% hint style="success" %}
**정답 및 해설**

**정답: C**
- 다른 파일이거나 **같은 파일의 다른 줄**이면 Git 이 **알아서 합친다**
- **같은 줄**이 겹치면 Git 은 고를 수 없으니 **사람에게 묻는다** — 그게 충돌이다
- 푸는 법: 표시줄 3종(`<<<<<<<` · `=======` · `>>>>>>>`)을 **전부 지우고** 남길 내용만 → `add` → `commit`
- 포기하려면 `git merge --abort`
{% endhint %}

---

## Q6. merge 방향 — [4_브랜치와_협업](lesson-4.md)

You want to merge `feature/login` **into** `main`. Where do you run `git merge`?
(`feature/login` 을 `main` 에 합치려면 어디서 `merge` 를 치나?)

- A. `feature/login` 에서 `git merge main`
- B. **`main` 으로 이동한 뒤 `git merge feature/login`**
- C. 어디서 쳐도 같다
- D. GitHub 에서만 가능하다

{% hint style="success" %}
**정답 및 해설**

**정답: B — 받는 쪽에서 친다**
- `git merge X` = **"지금 있는 브랜치에 X 를 끌어온다"**
- 그래서 **합쳐 넣을 곳(main)으로 먼저 이동**해야 한다
- A 를 치면 **반대로** `feature/login` 에 `main` 이 합쳐진다
- 11일차 ACL 재분배의 **"받는 쪽에서 친다"** 와 같은 감각
{% endhint %}

---

## Q7. 배포가 안 된다 ⭐ — [5_서버에_배포해보기](lesson-5.md) · 11 · 12일차

On your server, `curl localhost` returns the page, but a classmate's browser times out.
What should you check **first**?
(서버에서 `curl localhost` 는 되는데 옆자리 브라우저는 타임아웃이다. 먼저 볼 것은?)

- A. `git pull` 을 다시 한다
- B. nginx 를 재설치한다
- C. **`sudo ufw status` — 80번이 열려 있나**
- D. GitHub 저장소 권한

{% hint style="success" %}
**정답 및 해설**

**정답: C**
- **로컬은 되는데 밖에서만 안 된다 = 거의 확실히 방화벽** (12일차 진단 그대로)
- `sudo ufw allow 80/tcp` 를 빠뜨린 것이다. **여섯 단계의 ⑤ 개방**
- **타임아웃**은 조용히 버려졌다는 뜻(`deny`), `Connection refused` 면 **서비스가 안 떠 있는** 쪽을 본다
- 네 단계 좁히기: ① `ss -tulnp` → ② `curl localhost` → ③ `ufw status` → ④ `ip a` · `ping`
{% endhint %}

---

## 📝 강의 메모

- ⭐ **Q2(공개키/개인키)** 와 **Q3(비밀 유출)** 은 무슨 일이 있어도 다룬다 — 실제 사고가 가장 많은 두 지점
- Q7 은 **11 · 12일차와 오늘을 한 줄로 꿰는** 문제. "오늘 배운 게 지난주와 어떻게 이어지는지" 를 보여준다
- Q5 · Q6 은 4번 절을 건너뛰었다면 **같이 건너뛴다**
