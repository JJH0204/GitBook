# 0. 13일차 실습 명령어 — 수업 흐름 그대로 (이어치기 대본)

> 상위: [13일차 · Git 과 GitHub](README.md) · 절차는 [로컬 Git 실습](lesson-2-lab.md), [GitHub 연결 실습](lesson-3-lab.md), [브랜치와 충돌 실습](lesson-4-lab.md), [nginx 배포 실습](lesson-5-lab.md)

## 문서 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-13-007-REF |
| 유형 | REF (명령어 대본, 표) |
| 목적 | 13일차 실습 명령을 수업 흐름 순서대로 모아, 실습 중 화면에 띄우거나 인쇄해 따라 치게 한다 |
| 확인 상태 | 미검증 (원본 명령 대본을 정리한 것이며 이번 재작성에서 실행해 확인하지 않았다. 원본에는 2026-10-16 WSL Ubuntu 24.04, git 2.43.0 실측 기록이 있다) |
| 개정 | R1 (2026-11-18) |

STEP 1~5는 모두 WSL 터미널에서 CLI로 한다. `[브라우저]` 표시만 Windows 브라우저에서 한다.

## 읽는 법 (10일차 약속 그대로)

- `[WSL]`은 WSL 터미널, `[브라우저]`는 Windows 브라우저, `[마우스]`는 마우스 클릭이다.
- `#` 뒤의 글은 설명이다. 안 쳐도 된다.
- `<꺾쇠>`는 본인 값으로 바꾼다. `<아이디>`는 GitHub 사용자명이다.

{% hint style="warning" %}
CAUTION: GitHub 계정은 수업 전에 미리 가입해 온다. 이메일 인증에 시간이 걸린다.
{% endhint %}

---

## STEP 0. 몸풀기 (10분)

```bash
# [WSL]
ip route get 1.1.1.1 | head -1        # src 뒤가 내 WSL 주소. 가장 정확하다
ip -br a | grep eth0                  # 172.x = NAT, 192.168.x = mirrored
sudo ufw status                       # 12일차에 켜 두고 왔다 → active
systemctl is-active ssh vsftpd smbd named apache2 mariadb   # 지난주 세운 서버 6종
sudo ss -tulnp | grep ':80 '          # apache2가 80을 쓰는 중. 기억해 둔다
git --version                         # 없으면: sudo apt install -y git
```

- 도입 질문: "서버는 세웠다. 이제 거기에 무엇을 올릴지를 배운다."
- WSL 네트워크 모드를 칠판에 적는다. STEP 5 검증이 여기에 걸린다.
  - `172.x.x.x` = NAT. 검증은 내 Windows의 `localhost`로만 한다.
  - `192.168.x.x` = mirrored. 옆자리에서도 보인다(보너스).

---

## STEP 1. 맨 처음 한 번 (5분) — [로컬 Git 실습](lesson-2-lab.md) 구역 A

```bash
# [WSL]
git config --global user.name  "<이름>"
git config --global user.email "<이메일>"
git config --global core.editor nano          # 빠뜨리면 vim이 뜬다
git config --global init.defaultBranch main
git config --list | head -10
```

{% hint style="warning" %}
CAUTION: `core.editor nano`를 빠뜨리면 `git commit`에서 vim이 열린다. `Esc`, `:q!`, Enter로 빠져나온다.
{% endhint %}

---

## STEP 2. 로컬 Git (30분) — [로컬 Git 실습](lesson-2-lab.md) 구역 B~E

### 2-1 [WSL] 저장소 만들기

```bash
mkdir ~/myweb && cd ~/myweb
git init
ls -a                                  # .git/ 확인
git status                             # No commits yet
```

### 2-2 [WSL] 빨강, 초록, clean

```bash
echo "<h1>안녕하세요</h1>" > index.html
git status                             # 빨강: Untracked (① 작업 디렉터리)

git add index.html
git status                             # 초록: Changes to be committed (② 스테이지)

git commit -m "첫 페이지 추가"
git status                             # clean (③ 저장소)
```

명령마다 "지금 어느 자리인가"를 묻는다.

### 2-3 [WSL] 이력과 변경 보기

```bash
echo "<p>반갑습니다</p>" >> index.html
git diff                               # 아직 안 담은 변경 (- 와 +)
git add .
git diff --staged                      # 담긴 변경
git commit -m "인사말 추가"

git log --oneline
git log --oneline | head -5            # 10일차 파이프 회수
```

### 2-4 [WSL] `.gitignore`

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

{% hint style="danger" %}
WARNING: 비밀번호와 키를 커밋하면 지워도 이력에 남는다. 12일차에 만든 `~/.ssh/id_ed25519`는 어떤 저장소에도 들어가면 안 된다.
{% endhint %}

STEP 2 체크: `git status`의 빨강과 초록이 세 자리 중 어디인지 말할 수 있다.

---

## STEP 3. GitHub 연결 (30분) — [GitHub 연결 실습](lesson-3-lab.md)

### 3-1 [WSL] 공개키 확인 (12일차 그 키)

```bash
ls -l ~/.ssh/
cat ~/.ssh/id_ed25519.pub              # ssh-ed25519 AAAA... 로 시작
```

없으면 만든다.

```bash
ssh-keygen -t ed25519 -C "<이메일>"     # Enter 세 번
cat ~/.ssh/id_ed25519.pub
```

### 3-2 [브라우저] GitHub에 공개키 등록

```
프로필 → Settings → SSH and GPG keys → New SSH key
  Title: <키 이름>
  Key:   (3-1 출력을 통째로 붙여넣기)
→ Add SSH key
```

{% hint style="danger" %}
WARNING: `.pub`가 붙은 쪽만 붙여 넣는다. 개인키(`id_ed25519`)는 붙여 넣지 않는다.
{% endhint %}

### 3-3 [WSL] 연결 확인

```bash
ssh -T git@github.com                  # yes 입력
```

```
Hi <아이디>! You've successfully authenticated, but GitHub does not provide shell access.
```

이 문장이 성공이다. "shell access를 주지 않는다"는 정상이다.

### 3-4 [브라우저] 빈 저장소 만들기

```
New repository → 이름 myweb → Public
"Add a README file" 체크 해제 → Create repository
```

### 3-5 [WSL] 연결하고 올리기

```bash
cd ~/myweb
git remote add origin git@github.com:<아이디>/myweb.git
git remote -v
git branch -M main
git push -u origin main
```

```
[브라우저] GitHub 저장소 새로고침 → 내 파일이 보인다
```

### 3-6 [WSL] 이후의 흐름

```bash
echo "<p>13일차</p>" >> index.html
git commit -am "내용 추가"
git push                               # -u 덕분에 짧아졌다
```

STEP 3 체크: GitHub 웹에서 내 커밋 이력이 보인다.

---

## STEP 4. 브랜치와 충돌 (25분) — [브랜치와 충돌 실습](lesson-4-lab.md)

### 4-1 [WSL] 갈라서 합치기

```bash
git switch -c feature/about
echo "<h2>소개</h2>" > about.html
git add about.html && git commit -m "소개 페이지 추가"

git switch main
ls                                     # about.html이 없다
git merge feature/about
ls                                     # 생겼다
git log --oneline --graph --all
git branch -d feature/about
```

### 4-2 [WSL] 충돌 일부러 내기

{% hint style="warning" %}
CAUTION: 순서가 생명이다. 먼저 갈라진 뒤 양쪽에 각각 커밋해야 충돌이 난다. `main`에 먼저 커밋하고 브랜치를 만들면 `Fast-forward`로 조용히 합쳐지고 충돌이 나지 않는다.
{% endhint %}

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

### 4-3 [WSL] 충돌 풀기

```bash
nano index.html                        # 표시줄 전부 지우고 남길 내용만
git add index.html
git commit -m "제목 충돌 해결"
git log --oneline --graph --all
git push
```

포기하려면 `git merge --abort`를 실행한다.

STEP 4 체크: 충돌을 내고 스스로 풀었다.

---

## STEP 5. 서버에 배포 (20분) — [nginx 배포 실습](lesson-5-lab.md)

### 5-1 [WSL] nginx, 여섯 단계 또 한 번

```bash
sudo ss -tulnp | grep ':80 '           # 지금 80은 apache2가 쓰는 중
sudo apt install -y nginx              # 1 설치. 에러 없이 조용히 끝난다
sudo systemctl is-active nginx         # failed ← 설치는 됐는데 기동은 실패했다
sudo journalctl -u nginx -n 5 --no-pager   # 진짜 이유는 여기에 있다
```

```
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
```

{% hint style="warning" %}
CAUTION: apt 화면만 보면 성공처럼 보인다. 설치 스크립트가 기동 실패를 삼키기 때문이다. 그래서 ④ 확인 단계가 있다.
{% endhint %}

"또 그 에러다. 포트 하나는 한 프로그램만." (10일차, 12일차에 이어 세 번째)

```bash
sudo systemctl disable --now apache2   # 12일차 Apache를 내린다 (삭제는 하지 않는다)
sudo systemctl enable --now nginx      # 3 기동
sudo ss -tulnp | grep ':80 '           # 4 확인. 이제 nginx
sudo ufw status numbered | grep 80     # 5 개방. 이미 열려 있으면 그대로
```

```
[브라우저] http://localhost  →  Welcome to nginx!     6 검증
```

### 5-2 [WSL] 내 코드 받아오기

```bash
cd /var/www
sudo git clone https://github.com/<아이디>/myweb.git mysite
ls /var/www/mysite
```

### 5-3 [WSL] nginx가 그 폴더를 보게

```bash
sudo nano /etc/nginx/sites-available/default
#   root /var/www/html;  →  root /var/www/mysite;

sudo nginx -t                          # 문법 검사
sudo systemctl reload nginx
```

```
[브라우저] http://localhost  →  내가 만든 페이지
mirrored 모드면 옆자리에서 http://<내 Windows IP> 로도 열린다 (NAT이면 안 되는 것이 정상)
```

### 5-4 [WSL] 고치고 반영 (배포의 한살이)

```bash
cd ~/myweb
nano index.html
git commit -am "환영 문구 수정"
git push

cd /var/www/mysite
sudo git pull                          # 한 줄로 반영
```

```
[브라우저] 새로고침 → 바뀌었다
```

{% hint style="danger" %}
WARNING: 서버에서 직접 고치지 않는다. 다음 `pull`에서 충돌이 난다.
{% endhint %}

### 5-5 [WSL] 오늘 연 문 점검

```bash
sudo ss -tulnp | grep LISTEN
sudo ufw status numbered
```

STEP 5 체크: 브라우저에 내 페이지가 떴다. mirrored 모드이면 옆자리 브라우저에서도 뜬다.

---

## 부록. 안 될 때 30초 점검

| 증상 | 원인 | 해결 |
|---|---|---|
| `git commit`에서 못 빠져나온다 | vim이 떴다 | `Esc`, `:q!`, Enter. `git config --global core.editor nano` |
| `Permission denied (publickey)` | 공개키 미등록, 잘못된 키 | `cat ~/.ssh/id_ed25519.pub` 재등록, `ssh -T git@github.com` |
| `push`가 `rejected` | 원격이 더 최신 | `git pull` 먼저. 충돌이 나면 풀고 `git push` |
| 첫 `push`가 거부됨 | 저장소 생성 때 README를 체크했다 | `git pull --rebase origin main` 후 push |
| `fatal: not a git repository` | `git init`을 안 했다, 다른 폴더이다 | `pwd` 확인 후 `cd ~/myweb` |
| `localhost`가 타임아웃 | `ufw allow 80/tcp`를 안 했다 | `sudo ufw status`로 확인하고 연다 |
| 옆자리에서만 안 보임 | WSL이 NAT 모드이다 | 정상이다. `ip -br a`로 `172.x`를 확인하고 `localhost`로 검증한다 |
| nginx가 `Address already in use` | apache2가 80을 점유했다 | `sudo systemctl disable --now apache2` 후 `sudo systemctl enable --now nginx` |
| `apt install nginx`가 성공한 것 같은데 안 뜬다 | 설치는 성공, 기동만 실패했다 | `systemctl is-active nginx`, `journalctl -u nginx -n 5` |
| 충돌을 냈는데 `Fast-forward`가 뜬다 | 브랜치를 만들기 전에 main에 커밋했다 | 4-2 순서대로. 갈라진 뒤 양쪽에 각각 커밋한다 |
| `Welcome to nginx`만 뜬다 | `root` 경로 수정 또는 `reload`를 안 했다 | `nginx -t` 후 `systemctl reload nginx` |
| `sudo git pull`이 충돌 | 서버에서 직접 고쳤다 | `sudo git checkout -- .` 후 다시 pull(수정분은 사라진다) |

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | AMM 형식으로 재작성. 이모지 제거, 실습 절차는 각 MP 문서로 연결 |
