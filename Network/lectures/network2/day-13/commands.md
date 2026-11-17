# 0. 13일차 실습 명령어 — 수업 흐름 그대로 (이어치기 대본)

> 상위: [13일차 · Git 과 GitHub](README.md)
> 📌 **STEP 1~5** 는 전부 **WSL 터미널에서 CLI 로** 한다. 🌐 표시는 Windows 브라우저.

## 📌 읽는 법 — 10일차 약속 그대로

- `🐧` = WSL 터미널 · `🌐` = Windows 브라우저 · `🖱` = 마우스 클릭
- ⚠️ **GitHub 계정은 수업 전에 미리 가입**해 와야 한다 (이메일 인증 때문에 시간을 먹는다)

---

# ▶ STEP 0 · 몸풀기 (10분)

```bash
ip route get 1.1.1.1 | head -1        # ⭐ src 뒤가 내 WSL 주소 — 이게 가장 정확하다
ip -br a | grep eth0                  # 🚨 172.x = NAT · 192.168.x = mirrored
sudo ufw status                       # 12일차에 켜 두고 왔다 → active
systemctl is-active ssh vsftpd smbd named apache2 mariadb   # 지난주 세운 서버 6종
sudo ss -tulnp | grep ':80 '          # apache2 가 80 을 쓰는 중 ⭐ 기억해 둘 것
git --version                         # 없으면: sudo apt install -y git
```

> 🗣 **"서버는 세웠습니다. 이제 거기에 뭘 올릴지를 배웁니다."**
> 🚨 **WSL 네트워크 모드를 칠판에 적는다** — 오늘 STEP 5 검증이 여기에 걸린다
> - `172.x.x.x` = **NAT**(기본) → 검증은 **내 Windows 의 `localhost`** 로만
> - `192.168.x.x` = **mirrored** → 옆자리에서도 보인다 (보너스)

---

# ▶ STEP 1 · 맨 처음 한 번 (5분) — [2_로컬_Git](lesson-2.md)

```bash
git config --global user.name  "본인 이름"
git config --global user.email "본인@이메일"
git config --global core.editor nano          # ⭐⭐ 이거 안 하면 vim 지옥
git config --global init.defaultBranch main
git config --list | head -10
```

> 🚨 **`core.editor nano` 를 빠뜨리면** `git commit` 에서 vim 이 뜬다 → `Esc` `:q!` Enter 로 탈출

---

# ▶ STEP 2 · 로컬 Git (30분) — [2_로컬_Git](lesson-2.md) ⭐

### 2-1 🐧 저장소 만들기

```bash
mkdir ~/myweb && cd ~/myweb
git init
ls -a                                  # .git/ 확인
git status                             # No commits yet
```

### 2-2 🐧 빨강 → 초록 → clean ⭐

```bash
echo "<h1>안녕하세요</h1>" > index.html
git status                             # 🔴 Untracked (① 작업 디렉터리)

git add index.html
git status                             # 🟢 Changes to be committed (② 스테이지)

git commit -m "첫 페이지 추가"
git status                             # clean ✅ (③ 저장소)
```

> 🗣 명령마다 **"지금 어느 자리죠?"** 를 묻는다

### 2-3 🐧 이력과 변경 보기

```bash
echo "<p>반갑습니다</p>" >> index.html
git diff                               # 아직 안 담은 변경 (- 와 +)
git add .
git diff --staged                      # 담긴 변경
git commit -m "인사말 추가"

git log --oneline
git log --oneline | head -5            # 10일차 파이프 회수
```

### 2-4 🐧 `.gitignore` 🚨

```bash
nano .gitignore
```

```
.env
*.key
id_rsa
*.log
tmp/
```

```bash
git add .gitignore
git commit -m ".gitignore 추가"
```

> 🚨 **비밀번호 · 키를 커밋하면 지워도 이력에 남는다.** 12일차에 만든 `~/.ssh/id_ed25519` 는 **어떤 저장소에도** 들어가면 안 된다

**✅ STEP 2 체크** — `git status` 의 빨강/초록이 세 자리 중 어디인지 말할 수 있다

---

# ▶ STEP 3 · GitHub 연결 (30분) — [3_GitHub와_원격저장소](lesson-3.md) ⭐⭐

### 3-1 🐧 공개키 확인 (12일차 그 키)

```bash
ls -l ~/.ssh/
cat ~/.ssh/id_ed25519.pub              # ssh-ed25519 AAAA... 로 시작
```

없으면:

```bash
ssh-keygen -t ed25519 -C "본인@이메일"   # Enter 세 번
cat ~/.ssh/id_ed25519.pub
```

### 3-2 🌐 GitHub 에 공개키 등록

```
프로필 → Settings → SSH and GPG keys → New SSH key
  Title: KoreaIT WSL
  Key:   (3-1 출력을 통째로 붙여넣기)
→ Add SSH key
```

> 🚨 **`.pub` 가 붙은 쪽만** 붙여넣는다

### 3-3 🐧 연결 확인 ⭐

```bash
ssh -T git@github.com                  # yes 입력
```

```
Hi <아이디>! You've successfully authenticated, but GitHub does not provide shell access.
```

> ✅ 이 문장이 성공이다 ("shell access 안 준다"는 **정상**)

### 3-4 🌐 빈 저장소 만들기

```
New repository → 이름 myweb → Public
⚠️ "Add a README file" 체크 해제!  → Create repository
```

### 3-5 🐧 연결하고 올리기

```bash
cd ~/myweb
git remote add origin git@github.com:<아이디>/myweb.git
git remote -v
git branch -M main
git push -u origin main
```

```
🌐 GitHub 저장소 새로고침 → 내 파일이 보인다 ⭐
```

### 3-6 🐧 이후의 흐름

```bash
echo "<p>13일차</p>" >> index.html
git commit -am "내용 추가"
git push                               # -u 덕분에 짧아졌다
```

**✅ STEP 3 체크** — GitHub 웹에서 내 커밋 이력이 보인다

---

# ▶ STEP 4 · 브랜치와 충돌 (25분) — [4_브랜치와_협업](lesson-4.md)

### 4-1 🐧 갈라서 합치기

```bash
git switch -c feature/about
echo "<h2>소개</h2>" > about.html
git add about.html && git commit -m "소개 페이지 추가"

git switch main
ls                                     # 🔎 about.html 이 없다!
git merge feature/about
ls                                     # 🔎 생겼다
git log --oneline --graph --all
git branch -d feature/about
```

### 4-2 🐧 충돌 일부러 내기 ⭐

> 🚨 **순서가 생명이다.** **먼저 갈라진 뒤** 양쪽에 **각각** 커밋해야 충돌이 난다.
> main 에 먼저 커밋하고 그다음에 브랜치를 만들면 **Fast-forward** 로 조용히 합쳐진다 — 충돌이 안 난다.

```bash
git switch -c feature/title            # ① 먼저 갈라진다
echo "<h1>KoreaIT Academy</h1>" > index.html
git commit -am "제목 변경 (feature)"

git switch main                        # ② 돌아와서 같은 줄을 다르게 고친다
echo "<h1>코리아IT</h1>" > index.html
git commit -am "제목 변경 (main)"

git merge feature/title                # ③ CONFLICT 발생
cat index.html                         # 표시줄 3종 확인
git status --short                     # UU index.html
```

### 4-3 🐧 충돌 풀기

```bash
nano index.html                        # 표시줄 전부 지우고 남길 내용만
git add index.html
git commit -m "제목 충돌 해결"
git log --oneline --graph --all
git push
```

> 🆘 포기하려면 `git merge --abort`

**✅ STEP 4 체크** — 충돌을 내고 스스로 풀었다

---

# ▶ STEP 5 · 서버에 배포 (20분) — [5_서버에_배포해보기](lesson-5.md) ⭐⭐

### 5-1 🐧 nginx — 여섯 단계 또 한 번

```bash
sudo ss -tulnp | grep ':80 '           # 지금 80 은 apache2 가 쓰는 중
sudo apt install -y nginx              # 1 설치 — ⚠️ 에러 없이 조용히 끝난다
sudo systemctl is-active nginx         # failed  ← 설치는 됐는데 기동은 실패했다
sudo journalctl -u nginx -n 5 --no-pager   # ⭐ 진짜 이유는 여기에 있다
```

```
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)   ⭐ 일부러 본다
```

> 🚨 **apt 화면만 보면 성공처럼 보인다.** 설치 스크립트가 기동 실패를 삼키기 때문이다(실측 확인).
> 🗣 **"그래서 ④ 확인 단계가 있는 겁니다."** — 12일차 여섯 단계의 존재 이유를 여기서 한 번 더

> 🗣 **"또 그 에러. 포트 하나는 한 프로그램만."** (10일차 · 12일차에 이어 세 번째)

```bash
sudo systemctl disable --now apache2   # 12일차 Apache 를 내린다 (삭제는 안 한다)
sudo systemctl enable --now nginx      # 3 기동
sudo ss -tulnp | grep ':80 '           # 4 확인 — 이제 nginx
sudo ufw status numbered | grep 80     # 5 개방 — 이미 열려 있으면 그대로
```

```
🌐 http://localhost  →  Welcome to nginx!     6 검증
```

### 5-2 🐧 내 코드 받아오기

```bash
cd /var/www
sudo git clone https://github.com/<아이디>/myweb.git  mysite
ls /var/www/mysite
```

### 5-3 🐧 nginx 가 그 폴더를 보게

```bash
sudo nano /etc/nginx/sites-available/default
#   root /var/www/html;  →  root /var/www/mysite;

sudo nginx -t                          # 문법 검사
sudo systemctl reload nginx
```

```
🌐 http://localhost  →  내가 만든 페이지 ⭐⭐
🙋 mirrored 모드면 옆자리에서 http://<내 Windows IP> 로도 열린다 (NAT 이면 안 되는 게 정상)
```

### 5-4 🐧 고치고 → 반영 (배포의 한살이)

```bash
cd ~/myweb
nano index.html
git commit -am "환영 문구 수정"
git push

cd /var/www/mysite
sudo git pull                          # 한 줄로 반영
```

```
🌐 새로고침 → 바뀌었다
```

> ⚠️ **서버에서 직접 고치지 않는다.** 다음 `pull` 에서 충돌이 난다

### 5-5 🐧 오늘 연 문 점검

```bash
sudo ss -tulnp | grep LISTEN
sudo ufw status numbered
```

**✅ STEP 5 체크** — 옆자리 브라우저에 내 페이지가 떴다

---

# ⚠️ 부록 · 안 될 때 30초 점검

| 증상 | 원인 | 해결 |
|------|------|------|
| `git commit` 에서 못 빠져나온다 | **vim** 이 떴다 | `Esc` → `:q!` → Enter · `git config --global core.editor nano` |
| `Permission denied (publickey)` | 공개키 미등록 · 잘못된 키 | `cat ~/.ssh/id_ed25519.pub` 재등록 · `ssh -T git@github.com` |
| `push` 가 `rejected` | 원격이 더 최신 | `git pull` 먼저 → 충돌 나면 풀고 → `git push` |
| 첫 `push` 가 거부됨 | 저장소 만들 때 **README 체크**함 | `git pull --rebase origin main` 후 push |
| `fatal: not a git repository` | `git init` 안 함 · 다른 폴더 | `pwd` 확인 → `cd ~/myweb` |
| 🌐 `localhost` 가 타임아웃 | **`ufw allow 80/tcp`** 안 함 | `sudo ufw status` → 열기 |
| 🙋 옆자리에서만 안 보임 | **WSL 이 NAT 모드** | 정상이다. `ip -br a` 로 `172.x` 확인 → `localhost` 로 검증 |
| nginx 가 `Address already in use` | **apache2 가 80 점유** | `sudo systemctl disable --now apache2` → `sudo systemctl enable --now nginx` |
| `apt install nginx` 가 성공한 것 같은데 안 뜬다 | **설치는 성공 · 기동만 실패** | `systemctl is-active nginx` → `journalctl -u nginx -n 5` |
| 충돌을 냈는데 `Fast-forward` 가 뜬다 | 브랜치 **만들기 전에** main 에 커밋했다 | 4-2 순서대로 — **갈라진 뒤** 양쪽에 각각 커밋 |
| 🌐 Welcome to nginx 만 뜬다 | `root` 경로 수정 · `reload` 안 함 | `nginx -t` → `systemctl reload nginx` |
| `sudo git pull` 이 충돌 | 서버에서 직접 고쳤다 | `sudo git checkout -- .` 후 다시 pull |
