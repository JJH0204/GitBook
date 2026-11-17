# 5. 서버에 배포해 보기 — `git clone` 한 줄 ⭐

> 상위: [13일차 · Git 과 GitHub](README.md) · 대본 [STEP 5](commands.md)

## 🎯 학습 목표

- **배포**가 무엇인지 한 줄로 말한다
- 서버에서 `git clone` 으로 코드를 받아 **웹으로 띄운다**
- 코드를 고치고 **`push` → 서버에서 `pull`** 로 반영한다
- 12일차 **여섯 단계**가 여기서 어떻게 적용되는지 확인한다

## 🌉 다리 놓기: "그래서 이게 서버랑 무슨 상관인가요?"

오늘 우리는 코드를 **관리**하고 **올리는** 법을 배웠다. 그런데 아직 **내 WSL 안에서만** 논 셈이다.

> 🗣 **"12일차에 서버 세우는 여섯 단계를 배웠죠. 오늘 배운 Git 은 그중 어디에 들어갈까요?"**

```
 ① 설치      ② 설정      ③ 기동      ④ 확인      ⑤ 개방      ⑥ 검증
 nginx 설치   설정 파일    systemctl    ss         ufw allow   브라우저
                  ▲
          여기에 들어갈 "내용물" 을 Git 으로 가져온다
```

**배포(Deploy) = 내가 만든 것을 돌아가는 서버에 올려 사람들이 쓰게 하는 일.**

---

## 📖 ① 웹서버 하나 세우기 — 그런데 80번이 이미 차 있다 ⭐

12일차에 **Apache** 를 세웠다. 오늘은 **nginx** 를 쓴다. 그냥 설치하면 어떻게 될까?

```bash
sudo ss -tulnp | grep ':80 '              # 지금 80 을 누가 쓰나 → apache2
sudo apt install -y nginx                 # 1 설치 — ⚠️ 에러 없이 조용히 끝난다
sudo systemctl is-active nginx            # failed ← 기동은 실패했다
sudo journalctl -u nginx -n 5 --no-pager  # 이유는 여기
```

```
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
```

> 🚨 **설치 화면에는 에러가 안 나온다.** 패키지 설치 스크립트가 기동 실패를 삼키기 때문이다.
> 그래서 **설치 성공 ≠ 서비스 동작**이고, 12일차 여섯 단계에 **④ 확인**이 따로 있는 것이다.

> 🗣 **"또 그 에러입니다."** 10일차 `python3 -m http.server` 두 번 · 12일차 bind9 와 `systemd-resolved` — **포트 하나는 한 프로그램만.**

**둘 중 하나를 고른다. 오늘은 nginx 로 간다.**

```bash
sudo systemctl disable --now apache2      # Apache 를 내린다 (12일차에 세운 것)
sudo ss -tulnp | grep ':80 '              # 비었다
sudo systemctl enable --now nginx         # 3 기동
sudo ss -tulnp | grep ':80 '              # 4 확인 — nginx 가 LISTEN
sudo ufw status numbered | grep 80        # 5 개방 — 12일차에 이미 열었다면 그대로
sudo ufw allow 80/tcp                     # 없으면 연다
```

```
🌐 내 Windows 브라우저 → http://localhost        6 검증
   "Welcome to nginx!" 가 보이면 성공
```

> 💡 **또 여섯 단계다.** 서버 종류만 바뀌었을 뿐이다 → [12일차 공통 문법](../day-12/lesson-1.md)
> ⚠️ **5 를 빠뜨리면** `localhost` 로는 되는데 **밖에서만 타임아웃** — 12일차 진단 그대로
> 📌 **Apache 를 지우지는 않았다.** 되돌리려면 `nginx` 를 내리고 `apache2` 를 올리면 된다

---

## 📖 ② 웹서버는 어느 폴더를 보여주나

```bash
grep -n "root" /etc/nginx/sites-available/default | head -3
ls /var/www/html
```

```
root /var/www/html;          ← 이 폴더의 파일을 보여준다
```

> 📌 **웹서버 = "이 폴더를 인터넷에 보여주는 프로그램"** 이다. 그 폴더에 **내 파일**을 넣으면 내 사이트가 된다.

---

## 📖 ③ `git clone` 으로 내 코드 가져오기 ⭐

```bash
cd /var/www
sudo git clone https://github.com/hong-gildong/myweb.git  mysite
ls /var/www/mysite                  # index.html · about.html
```

> 📌 **서버에서는 HTTPS 로 clone 한다.** 공개 저장소를 **읽기만** 할 때는 키가 필요 없다.
> 서버에 개인키를 두지 않는 편이 **더 안전**하다 (11일차 최소 권한).

**nginx 가 이 폴더를 보게 한다.**

```bash
sudo nano /etc/nginx/sites-available/default
```

```
root /var/www/mysite;        # /var/www/html 에서 변경
```

```bash
sudo nginx -t                       # 문법 검사 (12일차 습관)
sudo systemctl reload nginx         # 재시작이 아니라 리로드
```

```
🌐 http://localhost  →  내가 만든 "안녕하세요" 페이지
```

> 🗣 **"방금 여러분이 만든 코드가, 여러분이 세운 서버에서, 브라우저에 떴습니다."**
> 🙋 **mirrored 모드라면 옆자리에서도** `http://<내 Windows IP>` 로 열린다 → 모드 확인은 [README](README.md)
> NAT 모드면 옆자리에서는 안 보인다 — **정상**이다. 공개하는 법은 16일차에서.

---

## 📖 ④ 고치고 → 반영하기 (배포의 한살이)

```
 🐧 내 작업 폴더 ~/myweb          🌐 GitHub            🐧 서버 /var/www/mysite
     수정 → commit  ──push──▶   저장소   ──pull──▶    반영
```

```bash
# 내 작업 폴더에서
cd ~/myweb
nano index.html
git commit -am "환영 문구 수정"
git push

# 서버 폴더에서
cd /var/www/mysite
sudo git pull                       # 한 줄로 반영
```

```
🌐 브라우저 새로고침 → 바뀌었다
```

> ⭐ **이것이 배포의 가장 단순한 형태**다. 실무에서는 이 `pull` 을 **자동으로** 돌린다(CI/CD) — 그 출발점이 오늘 친 이 한 줄이다.
> ⚠️ **서버에서 직접 파일을 고치지 않는다.** 고치면 다음 `pull` 에서 **충돌**이 난다.
> **고치는 곳은 내 작업 폴더 하나** — 이 규칙이 배포의 기본이다.

---

## 📖 ⑤ 오늘 연 문 점검 (11일차 습관)

```bash
sudo ss -tulnp | grep LISTEN        # 22 · 80 … 몇 개인가
sudo ufw status numbered            # 규칙이 의도와 맞나
```

> 🗣 **"서버를 하나 세울 때마다 문이 하나 늘어납니다."** → 11일차 공격 표면

---

## 🧪 실습 / 질문

- `sudo ufw allow 80/tcp` 를 빼먹으면 어떤 증상이 나타날까? 어떻게 확인하나?
- 서버의 `/var/www/mysite/index.html` 을 **직접** 고치면 다음 `git pull` 에서 무슨 일이?
- 서버에서 `clone` 할 때 SSH 가 아니라 HTTPS 를 쓴 이유는?
- 이 과정을 **자동으로** 돌리려면 무엇이 더 필요할까?

## 📝 강의 메모

- ⭐⭐ **"내 코드가 내 서버에서 브라우저에 뜨는" 순간**이 13일차의 결말이다
  - 🚨 **WSL 모드부터 확인**: NAT 이면 `localhost` 로만, mirrored 면 옆자리까지. **`localhost` 는 두 모드 다 된다**
- ⭐ **80번 충돌(①)** 은 오늘의 좋은 교재다 — 10일차 · 12일차에서 두 번 만난 그 에러를 **세 번째**로 만난다
- 여섯 단계 표를 **다시 칠판에** — nginx 로 한 번 더 돌면 "정말 순서가 같구나"가 굳는다
- `nginx -t` 문법 검사 → `reload` 는 12일차 bind9 `named-checkconf` 와 같은 습관. 짚어 줄 것
- ⚠️ `/var/www` 는 주인이 root 라 `sudo` 가 필요하다 — 10일차 권한 회수 지점
- 🚨 **설치는 조용히 성공하고 기동만 실패한다** — `is-active` · `journalctl` 로 들여다보는 장면을 꼭 보여줄 것
- 📌 12일차에 세운 **Apache 는 끄기만** 한다(삭제 금지). 16일차에 되살려 비교할 수도 있다
- ⚠️ **서버에서 직접 수정 금지** 규칙을 꼭 말할 것. 안 하면 다음 수업에 충돌로 온다
- ⏱ 20분. 시간이 모자라면 **④(push → pull 반영)까지는 반드시** — ③까지만 하면 감흥이 반이다
