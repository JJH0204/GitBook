# 0. 14일차 실습 명령어 — 수업 흐름 그대로 (이어치기 대본)

> 상위: [14일차 · 도커 기초](README.md)
> 📌 `🐧` = WSL 안 · `🪟`·`🌐` = Windows 브라우저 · `🙋` = 옆자리 (mirrored 모드일 때만)
> 🚨 **검증 기준은 `curl` 과 `localhost`** 로 통일한다 — WSL 모드에 상관없이 같은 결과가 나온다

---

# ▶ STEP 0 · 몸풀기 (10분)

### 0-1 🐧 환경 점검 — 세 줄

```bash
ps -p 1 -o comm=                       # systemd 여야 한다 (12일차에 켰다)
ip route get 1.1.1.1 | head -1         # ⭐ src 뒤가 내 WSL 주소 — 오늘 계속 쓴다
sudo ufw status numbered               # 22 · 80 이 열려 있다
```

### 0-2 🐧 13일차 결과물 확인 — **두 개**

```bash
curl -I localhost                      # ② 내 WSL nginx 살아 있나
sudo ss -tulnp | grep ':80 '           # 80 은 호스트 nginx 가 쓰는 중 ⭐ 기억해 둘 것
ls /var/www/mysite                     # 13일차에 clone 한 내 포트폴리오
```

```
🌐 ① 각자 GitHub Pages 주소도 브라우저에 열어 둔다 (오늘 도입에 쓴다)
```

### 0-3 🐧 설치 미리 걸어 두기 ⏱ (시간 절약 — 이 사이에 STEP 1 판서를 한다)

```bash
sudo apt update
sudo apt install -y ca-certificates curl
```

> 💾 가능하면 **WSL 백업** 한 번: 🪟 PowerShell 에서 `wsl --shutdown` 후 `wsl --export Ubuntu D:\wsl-backup.tar`

---

# ▶ STEP 1 · 왜 컨테이너인가 (판서 30분) — [1_컨테이너란](lesson-1.md) ⭐

> 🗣 **도입** — 브라우저 두 탭을 나란히 띄워 놓고
> **"①Pages 는 게시판을 못 올리고, ②내 WSL 은 옮길 수가 없습니다. 오늘은 그 사이를 메웁니다."**
>
> 칠판 1 — **13일차의 두 벽** (정적만 / 내 PC 안에만)
> 칠판 2 — **왜 쓰나 네 가지**: 재현 · 속도 · 청소 · 공존
> 칠판 3 — **9일차 하이퍼바이저 그림** 옆에 **컨테이너 그림** 나란히
> 핵심 한 줄 — **"VM 은 OS 를 통째로, 컨테이너는 커널을 공유"**
> 칠판 4 — **레지스트리 ↔ GitHub** 대응 (`pull` 이라는 단어가 같다)

---

# ▶ STEP 2 · 설치와 첫 컨테이너 (35분) — [2_첫_컨테이너](lesson-2.md) ⭐

### 2-1 🐧 충돌 패키지 정리

```bash
for p in docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc; do
  sudo apt remove -y $p 2>/dev/null
done
```

### 2-2 🐧 공식 저장소 등록

```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

```bash
sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
```

### 2-3 🐧 설치 · 기동 · 확인 (= 여섯 단계 ①③④) ⭐

```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker     # ③ 기동 — 12일차 그 명령 그대로
systemctl is-active docker             # ④ 확인 — active
docker --version                       # Docker version 29.x.x
docker compose version                 # v2.x.x
```

> 🗣 **"Docker 를 설치하는 과정도 여섯 단계였습니다."** → 칠판의 12일차 표에 ①③④ 체크

### 2-4 🐧 sudo 없이 쓰기 ⚠️ 재로그인 필수

```bash
docker ps                              # permission denied — 왜?
ls -l /var/run/docker.sock             # srw-rw---- root docker  ← 10일차 권한
sudo usermod -aG docker $USER
exit                                   # ⚠️ 반드시 로그아웃
```

```bash
# 터미널 새로 열고
id -nG | tr ' ' '\n' | grep docker     # docker 가 보인다
docker ps                              # 빈 표 → 성공
```

### 2-5 🐧 hello-world

```bash
docker run hello-world
docker images                          # 받은 이미지 (붕어빵 틀)
docker ps                              # 비어 있다!
docker ps -a                           # Exited (0) ⭐ 할 일이 끝나면 멈춘다
```

### 2-6 🐧 웹서버 한 줄 ⭐

```bash
docker run -d -p 8080:80 --name web nginx
docker ps                              # Up
sudo ss -tulnp | grep 8080             # docker-proxy 가 듣고 있다
curl localhost:8080                    # Welcome to nginx!
```

```
🪟 내 Windows 브라우저 → http://localhost:8080
```

> 칠판: **여섯 단계 대조표** 오른쪽 칸 채우기 (①② = 이미지 안 · ③ = `run -d` · ④ = `ps` · ⑤ = `-p`)

### 2-7 🐧 포트 충돌 일부러 (네 번째)

```bash
docker run -d -p 80:80 --name web2 nginx    # address already in use
docker ps -a | grep web2                    # Created 로 남는다
docker rm web2
sudo ss -tulnp | grep ':80 '                # 호스트 nginx 가 쓰는 중
```

> ⭐ **지금 nginx 가 두 개 살아 있다** (호스트 80 · 컨테이너 8080) = 1번 절의 "공존"

**✅ STEP 2 체크** — 이미지와 컨테이너를 구분해 말할 수 있다

---

# ▶ STEP 3 · 핵심 명령과 방화벽 함정 (40분) — [3_도커_핵심명령](lesson-3.md) ⭐⭐

### 3-1 🐧 12일차 명령과 짝 맞추기

```bash
docker ps                              # ← systemctl status
docker logs web                        # ← journalctl -u
docker logs -f web                     # 실시간 — 🪟 브라우저 새로고침하며 로그가 쌓이는 것 보기 (Ctrl+C)
docker stop web  && docker ps -a
docker start web && docker ps
```

### 3-2 🐧 컨테이너 안에 들어가기

```bash
docker exec -it web bash
```

```bash
ls /usr/share/nginx/html
cat /etc/nginx/conf.d/default.conf     # ②설정이 여기 들어 있다
ps -ef                                 # ⭐ nginx 뿐이다 — "포장된 프로세스"
hostname
exit
```

### 3-3 🚨 방화벽 함정 — 오늘의 15분 ⭐⭐ (대조 실험)

**(ㄱ) 호스트 서비스 8000 · (ㄴ) 컨테이너 8080 — 둘 다 ufw 에 없다**

```bash
cd /tmp && python3 -m http.server 8000 &     # (ㄱ) 호스트 프로세스
docker ps | grep web                          # (ㄴ) 컨테이너는 이미 떠 있다
sudo ufw status numbered                       # 8000 · 8080 둘 다 없다!
```

```
🪟 Windows 브라우저
   http://localhost:8000   → ❌ 막힌다 (ufw 가 일했다)
   http://localhost:8080   → ✅ 열린다  ⚠️  ← 왜?
```

**범인 확인 — 어느 환경에서나 보인다**

```bash
sudo iptables -t nat -L DOCKER -n | head             # DNAT: 8080 → 컨테이너:80
sudo iptables -L FORWARD -n --line-numbers | head    # DOCKER 체인이 ufw 보다 앞
```

> 🗣 **"ufw 는 INPUT 에서 심사합니다. Docker 트래픽은 FORWARD 로 빠져나가 심사대를 안 지납니다."**

**대응 — 로컬에만 바인딩**

```bash
docker rm -f web
docker run -d -p 127.0.0.1:8080:80 --name web nginx
sudo ss -tulnp | grep 8080                   # 127.0.0.1:8080 으로만 ⭐
```

```bash
MYIP=$(ip route get 1.1.1.1 | awk '{print $7; exit}')
curl -m 3 http://127.0.0.1:8080              # ✅ 된다
curl -m 3 http://$MYIP:8080                  # ❌ refused ⭐ 닫혔다는 증거 (두 모드 공통)
```

> 🚨 **mirrored 모드 학생은 🪟 브라우저 `localhost:8080` 이 여전히 열린다** — 실패가 아니다
> (Windows 와 WSL 이 `127.0.0.1` 을 공유한다) → **검증은 위의 `curl http://$MYIP:8080` 로 통일**

```bash
kill %1                                      # (ㄱ) 호스트 서비스 정리 ⚠️ 꼭 한다
```

**✅ STEP 3 체크** — ufw 를 켜 두고도 컨테이너 포트가 열렸던 이유를 설명할 수 있다

---

# ▶ STEP 4 · 데이터와 볼륨 (25분) — [4_데이터와_볼륨](lesson-4.md)

### 4-1 🐧 "고쳤는데 사라졌어요" 체험

```bash
docker exec -it web bash -c 'echo "<h1>내가 고침</h1>" > /usr/share/nginx/html/index.html'
curl localhost:8080                    # 바뀌었다

docker rm -f web
docker run -d -p 127.0.0.1:8080:80 --name web nginx
curl localhost:8080                    # ⚠️ 원래대로
```

### 4-2 🐧 바인드 마운트 — 13일차 포트폴리오 연결 ⭐

```bash
docker rm -f web
docker run -d -p 8080:80 \
  -v /var/www/mysite:/usr/share/nginx/html:ro \
  --name web nginx

curl localhost:8080                    # 13일차 내 포트폴리오 ⭐
```

```
🪟 http://localhost:8080   —  Pages · 호스트 nginx · 컨테이너 세 곳에서 같은 코드가 돈다
```

```bash
cd /var/www/mysite && sudo git pull    # 폴더만 갱신 → 컨테이너 그대로인데 내용이 바뀐다
```

### 4-3 🐧 볼륨과 DB (12일차 MariaDB 회수)

```bash
docker volume create dbdata
docker run -d --name db \
  -e MARIADB_ROOT_PASSWORD=example-password \
  -e MARIADB_DATABASE=testdb \
  -v dbdata:/var/lib/mysql \
  -p 127.0.0.1:3306:3306 \
  mariadb

docker logs -f db                      # ⏳ "ready for connections" 까지 기다린다 (Ctrl+C)
docker exec -it db mariadb -uroot -pexample-password testdb \
  -e "CREATE TABLE t(id INT); INSERT INTO t VALUES(1); SELECT * FROM t;"
```

### 4-4 🐧 지워도 살아남나 ⭐

```bash
docker rm -f db
docker run -d --name db \
  -e MARIADB_ROOT_PASSWORD=example-password \
  -v dbdata:/var/lib/mysql \
  -p 127.0.0.1:3306:3306 mariadb

docker logs -f db                      # 두 번째는 더 빠르다 (초기화를 건너뛴다)
docker exec -it db mariadb -uroot -pexample-password testdb -e "SELECT * FROM t;"
```

> ⭐ **컨테이너는 지웠는데 데이터는 남았다** — 이게 볼륨이다

**✅ STEP 4 체크** — 데이터를 살려 두는 두 가지 방법을 말할 수 있다

---

# ▶ STEP 5 · Dockerfile (35분) — [5_Dockerfile](lesson-5.md) ⭐

### 5-1 🐧 13일차 저장소에 Dockerfile 쓰기

```bash
cd ~/myweb                             # 각자 13일차 저장소 폴더
mkdir -p site && mv index.html about.html site/ 2>/dev/null
ls site/

nano Dockerfile
```

```
FROM nginx:alpine
COPY ./site /usr/share/nginx/html
EXPOSE 80
```

```bash
nano .dockerignore
```

```
.git
.env
*.key
*.log
```

> ⚠️ **Pages 를 쓰는 저장소면** `site/` 로 옮기는 순간 Pages 가 깨질 수 있다
> → Pages 설정에서 폴더를 **`/site`** 로 바꾸거나, 옮기지 말고 `COPY . /usr/share/nginx/html` 로 쓴다

### 5-2 🐧 굽고 띄우기

```bash
docker build -t mysite:1.0 .           # ⚠️ 맨 뒤 점(.) 빠뜨리지 말 것
docker images | grep -E "mysite|nginx" # alpine 이 얼마나 작은지 비교

docker rm -f web
docker run -d -p 8080:80 --name mysite mysite:1.0
curl localhost:8080
```

```
🪟 http://localhost:8080  →  내 이미지로 띄운 내 포트폴리오 ⭐
```

### 5-3 🐧 Git 에 올리기 ⭐

```bash
git add Dockerfile .dockerignore site/
git commit -m "Dockerfile 추가 — 컨테이너로 돌리는 방법까지 저장소에"
git push
```

> 🗣 **"13일차 Git = 내 코드. 오늘부터 Git = 내 코드 + 돌리는 방법."**

### 5-4 🐧 재현성 실험 — 옆자리 저장소를 띄운다 ⭐⭐

```bash
cd ~
git clone https://github.com/<옆자리_아이디>/<저장소>.git friend
cd friend && docker build -t friend:1.0 . && docker run -d -p 8090:80 --name friend friend:1.0
curl localhost:8090
```

```
🪟 http://localhost:8090  →  옆자리 포트폴리오가 내 PC 에서 ⭐ "환경을 묻지 않았다"
```

**✅ STEP 5 체크** — Dockerfile 로 내 이미지를 만들어 띄웠고, 남의 저장소도 그대로 띄웠다

---

# ▶ STEP 6 · 환경을 코드로 · Compose (20분) — [6_환경을_코드로](lesson-6.md) ⭐

> ⏱ 시간이 모자라면 **강사 시연**으로. 단 `ss | grep 3306` 이 **비는 장면**은 반드시 보여준다

### 6-1 🐧 compose.yaml

```bash
docker rm -f db mysite friend 2>/dev/null     # 이름·포트 충돌 방지
cd ~/myweb
nano compose.yaml
```

```yaml
services:
  web:
    build: .
    ports:
      - "8080:80"
    restart: unless-stopped

  db:
    image: mariadb
    environment:
      MARIADB_ROOT_PASSWORD: ${DB_PASSWORD}
      MARIADB_DATABASE: testdb
    volumes:
      - dbdata:/var/lib/mysql
    restart: unless-stopped
    # ⭐ ports 없음 — 밖에 열지 않는다

volumes:
  dbdata:
```

### 6-2 🐧 비밀은 .env · 양식은 커밋

```bash
echo "DB_PASSWORD=example-password" > .env
echo ".env" >> .gitignore
printf '# cp .env.example .env\nDB_PASSWORD=여기에_직접_정하세요\n' > .env.example
```

### 6-3 🐧 띄우기

```bash
docker compose config                  # ⭐ 먼저 문법 검사 (nginx -t 습관)
docker compose up -d
docker compose ps
docker compose logs -f db              # ready for connections (Ctrl+C)
curl localhost:8080
```

### 6-4 🐧 이름으로 통한다 · 문은 안 열렸다 ⭐⭐

```bash
docker compose exec web sh -c "getent hosts db"    # db 의 IP — 이름이 통한다
sudo ss -tulnp | grep 3306                          # ⭐ 아무것도 안 나온다
```

> ⭐ **웹은 DB 에 닿는데 호스트에는 문이 없다** = 11일차 최소 개방의 완성형

### 6-5 🐧 Git 에 올리고 · 내려 보기

```bash
git add compose.yaml .env.example .gitignore
git commit -m "Compose 추가 — 환경 전체를 저장소에"
git push

docker compose down                    # 컨테이너·네트워크 삭제 (볼륨은 남는다)
docker compose up -d                   # 다시 올리면 데이터 그대로
```

> 🛑 **`docker compose down -v` 는 3초 멈춤** — 볼륨까지 지운다

**✅ STEP 6 체크** — `git clone` → `cp .env.example .env` → `docker compose up -d` 세 줄로 환경이 선다

---

# 🧹 마무리 · 정리 (5분)

```bash
docker compose ps                               # 지금 도는 것
docker ps -a                                    # 쌓인 것 확인
docker rm $(docker ps -aq -f status=exited)     # 멈춘 것 정리
docker images
sudo ss -tulnp | grep LISTEN                    # 오늘 연 문 — 몇 개인가
sudo ufw status numbered
```

> 🛑 **`docker system prune -a` · `docker compose down -v` 는 3초 멈춤**
> 🗣 **"오늘 우리는 서버를 세운 게 아니라, 세우는 방법을 저장소에 적었습니다."** → 16일차 예고

---

# ⚠️ 부록 · 안 될 때 30초 점검

| 증상 | 원인 | 해결 |
|------|------|------|
| `permission denied ... docker daemon socket` | `usermod` 후 **재로그인 안 함** | 터미널 새로 열기 (또는 `newgrp docker`) |
| `docker: command not found` | 저장소 등록 실패 | `cat /etc/apt/sources.list.d/docker.sources` 확인 → `apt update` 다시 |
| `Unit docker.service not found` / 기동 실패 | systemd 가 꺼져 있다 | `ps -p 1 -o comm=` → `/etc/wsl.conf` 에 `[boot]` `systemd=true` → 🪟 `wsl --shutdown` |
| 데몬이 안 뜬다 | 네트워크 초기화 실패 | `journalctl -u docker -n 30 --no-pager` 로 **원문을 읽는다** · `cat /proc/sys/net/ipv4/ip_forward` 가 1 인지 |
| `address already in use` | 그 포트를 **이미 누가** 쓴다 | `sudo ss -tulnp \| grep :<포트>` → 다른 번호로 |
| 컨테이너가 바로 **Exited** | 안에서 돌 프로세스가 **끝났다** / 필수 변수 누락 | `docker logs <이름>` 으로 이유 확인 |
| DB 접속 `Can't connect` | 아직 **초기화 중** | `docker logs -f db` 에 `ready for connections` 확인 |
| `mysql: command not found` (DB 안에서) | 최근 MariaDB 는 이름이 바뀜 | **`mariadb`** 로 쓴다 |
| `docker build` 에서 `requires exactly 1 argument` | 맨 뒤 **`.`** 빠뜨림 | `docker build -t 이름:태그 .` |
| 🪟 `127.0.0.1` 바인딩인데 열린다 | **mirrored 모드** (정상) | 검증은 `curl http://$MYIP:8080` 로 |
| 🙋 옆자리에서만 안 열림 | **NAT 모드** (정상) | `localhost` 기준으로 검증 |
| 🌐 바뀐 내용이 안 보임 | 이미지를 **다시 안 구웠다** | `docker build` → `rm -f` → `run` (또는 `compose up -d --build`) |
| Compose 에서 `version is obsolete` 경고 | `version:` 줄이 남아 있다 | 그 줄을 **지운다** (동작에는 문제 없음) |
| Compose YAML 에러 | 들여쓰기(탭) | 공백 2칸 · `docker compose config` 로 검사 |
