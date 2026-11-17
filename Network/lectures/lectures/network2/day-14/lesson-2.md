# 2. 설치와 첫 컨테이너 — 여섯 단계가 한 줄로 ⭐

> 상위: [14일차 · 도커 기초](README.md) · 대본 [STEP 2](commands.md)

## 🎯 학습 목표

- **Docker 공식 저장소**로 Docker Engine 을 설치한다 — 그 과정이 **12일차 여섯 단계** 그대로임을 확인한다 ⭐
- `sudo` 없이 `docker` 를 쓰도록 설정한다 (⚠️ **재로그인** 필요)
- `docker run` 한 줄로 웹서버를 띄우고 **여섯 단계와 대조**한다 ⭐
- `pull` · `run` · `ps` 의 관계를 안다
- **포트 충돌**을 직접 만나고 피한다

## 🌉 다리 놓기: "12일차에 FTP 서버 하나 세우던 일"

12일차에 서버 하나를 세우는 데 이렇게 했다.

```bash
sudo apt install vsftpd                  # ① 설치
sudo nano /etc/vsftpd.conf               # ② 설정
sudo systemctl enable --now vsftpd       # ③ 기동
sudo ss -tulnp | grep vsftpd             # ④ 확인
sudo ufw allow 21/tcp                    # ⑤ 개방
ftp localhost                            # ⑥ 검증
```

오늘은 이렇게 한다.

```bash
docker run -d -p 8080:80 nginx
```

> 🗣 **"①②③이 한 줄에 들어갔습니다. 어디로 갔을까요?"**
> → **이미지 안에** 이미 들어 있다. 누군가 ①설치와 ②설정을 **미리 해서 포장**해 둔 것이 이미지다.

---

## 📖 ① 수업 시작 점검 — WSL 부터 확인한다 🚨

Docker 는 **systemd 서비스**로 돌고, 네트워크를 많이 건드린다. 그래서 먼저 세 가지를 본다.

```bash
ps -p 1 -o comm=                   # systemd 라고 나와야 한다 (12일차에 켜 뒀다)
ip route get 1.1.1.1 | head -1     # ⭐ src 뒤가 내 WSL 주소 — 오늘 계속 쓴다
sudo ufw status numbered           # 22 · 80 이 열려 있다 (3번 절에서 쓴다)
```

| 보이는 주소 | WSL 모드 | 내 Windows 에서 `localhost` | 옆자리에서 |
|-------------|----------|------------------------------|------------|
| `172.x.x.x` | **NAT** (기본) | ✅ | ❌ |
| `192.168.x.x` (Windows 와 같음) | **mirrored** | ✅ | ✅ |

> 📌 **검증은 「내 Windows 브라우저 + `localhost`」가 기본**이다 — 두 모드 모두에서 동작한다.
> 🚨 `ps -p 1` 이 systemd 가 아니면 `/etc/wsl.conf` 에 `[boot]` / `systemd=true` 를 넣고 Windows 에서 `wsl --shutdown`.

---

## 📖 ② 설치 — 공식 저장소에서 (= 또 여섯 단계다) ⭐

> 🗣 **"오늘 설치하는 것은 Docker 입니다. 그런데 설치 순서가 어디서 본 것 같지 않나요?"**

**STEP 1. 충돌 패키지 정리** — 우분투가 들고 있는 옛 버전과 섞이면 사고가 난다

```bash
for p in docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc; do
  sudo apt remove -y $p 2>/dev/null
done
```

**STEP 2. 공식 저장소 등록** (① 설치의 준비 — 13일차 GitHub 키 등록과 같은 "믿을 수 있는 출처" 작업)

```bash
sudo apt update
sudo apt install -y ca-certificates curl
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

> 💡 `$(. /etc/os-release && echo ...)` 는 **우분투 코드명**을 자동으로 넣는다. 24.04 면 `noble`.
> 📌 **GPG 키**를 먼저 받는 이유 — "이 저장소에서 온 패키지가 **진짜 Docker 가 만든 것**인지" 확인하려고. 13일차 SSH 키와 같은 **신뢰의 문제**다.

**STEP 3. 설치** (① 설치)

```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

| 패키지 | 무엇인가 |
|--------|----------|
| `docker-ce` | **데몬**(dockerd) — 실제로 컨테이너를 돌리는 쪽 |
| `docker-ce-cli` | **명령어** `docker` — 우리가 치는 쪽 |
| `containerd.io` | 컨테이너 **런타임** (더 아래 층) |
| `docker-buildx-plugin` | 이미지 **빌드** 확장 → [5_Dockerfile](lesson-5.md) |
| `docker-compose-plugin` | **`docker compose`** 명령 → [6_환경을_코드로](lesson-6.md) ⭐ |

> 🛑 **`apt install docker.io` 나 snap 으로 깔지 않는다.** 버전이 낡고 `docker compose` 가 없다. 공식 저장소로 간다.

**STEP 4. 기동과 확인** (③ 기동 · ④ 확인)

```bash
sudo systemctl enable --now docker       # ③ 기동 — 12일차 그 명령 그대로!
systemctl is-active docker               # active
docker --version                         # Docker version 29.x.x
docker compose version                   # Docker Compose version v2.x.x
```

> ⭐ **보라.** Docker 를 설치하는 과정도 **① 설치 → ③ 기동 → ④ 확인** 이다.
> **12일차의 여섯 단계는 Docker 자신에게도 적용된다.**
> 🔎 `apt install` 만 하고 `is-active` 를 안 보면 13일차 nginx 처럼 **"설치는 됐는데 안 돌고 있는"** 상태를 놓친다.

---

## 📖 ③ `sudo` 없이 쓰기 — ⚠️ 재로그인이 필요하다

```bash
docker ps
```

```
permission denied while trying to connect to the Docker daemon socket
```

> 🔎 **10일차 권한 회수 지점.** `docker` 명령은 `/var/run/docker.sock` 이라는 **소켓 파일**을 통해 데몬과 말한다.
> 그 파일의 그룹이 `docker` 라서, 그 그룹에 속하지 않으면 못 읽는다.

```bash
ls -l /var/run/docker.sock          # srw-rw---- 1 root docker
sudo usermod -aG docker $USER
```

```bash
exit                                 # ⚠️ 반드시 로그아웃 — 그룹은 로그인할 때 읽는다
```

```bash
# 터미널을 새로 열어 다시 들어온 뒤
id -nG | tr ' ' '\n' | grep docker   # docker 가 보인다
docker ps                            # 에러 없이 빈 표 → 성공
```

> 🚨 **오늘 1번 질문이 이것이다.** `usermod` 만 하고 재로그인을 안 하면 계속 permission denied 다.
> (급하면 `newgrp docker` 로 그 터미널만 적용할 수도 있다)
> 📌 `docker` 그룹은 **사실상 root 권한**이다 — 11일차 최소 권한 관점에서는 주의할 일이다. 실습 환경이라 쓴다.

---

## 📖 ④ 첫 컨테이너 — `hello-world`

```bash
docker run hello-world
```

```
Unable to find image 'hello-world:latest' locally     ← 내 PC 에 없다
latest: Pulling from library/hello-world              ← Docker Hub 에서 받는다
Hello from Docker!
```

**무슨 일이 일어났나 — 세 단계**

```
 ① 로컬에 이미지가 있나?  없다
 ② 레지스트리(Docker Hub)에서 pull 한다      (13일차 git clone 과 같은 발상)
 ③ 그 이미지로 컨테이너를 만들어 실행
```

```bash
docker images        # 받은 이미지 목록 (붕어빵 틀)
docker ps            # 돌아가는 컨테이너 — 비어 있다!
docker ps -a         # 끝난 것까지 — Exited (0) ⭐
```

> 🔎 **`hello-world` 는 인사하고 바로 끝난다.** 컨테이너는 **할 일이 끝나면 멈춘다** — VM 과 다른 점이다.
> 📌 컨테이너는 **"안에서 돌릴 프로세스가 살아 있는 동안"** 만 산다. 그래서 `ps -a` 에 `Exited` 로 남는다.

---

## 📖 ⑤ 웹서버를 띄운다 ⭐

```bash
docker run -d -p 8080:80 --name web nginx
```

| 조각 | 뜻 | 12일차 대응 |
|------|-----|-------------|
| `run` | 이미지로 컨테이너를 만들어 **실행** | ③ 기동 |
| `-d` | **백그라운드**(detached) | `systemctl` 처럼 뒤에서 돈다 |
| `-p 8080:80` | **호스트 8080 → 컨테이너 80** | 10일차 포트 · [3_도커_핵심명령](lesson-3.md) |
| `--name web` | 이름 붙이기 (없으면 랜덤) | |
| `nginx` | 쓸 **이미지** | ① 설치 + ② 설정이 **이 안에** |

```bash
docker ps                               # ④ 확인 — Up 몇 초
sudo ss -tulnp | grep 8080              # ④ 확인 — 10일차 그 명령 그대로!
curl localhost:8080                     # ⑥ 검증 — Welcome to nginx!
```

```
🪟 내 Windows 브라우저 → http://localhost:8080
```

> 🗣 **"방금 웹서버 하나를 1초 만에 세웠습니다. 13일차에는 몇 분 걸렸죠?"**
> 🔎 `ss` 에 `docker-proxy` 가 보인다 — **Docker 가 8080 을 대신 듣고** 컨테이너로 넘겨 준다는 뜻이다.

### 여섯 단계와 대조 ⭐

| 단계 | 12일차 (apt) | 오늘 (docker) |
|------|--------------|---------------|
| ① 설치 | `apt install nginx` | **이미지 안에 있다** |
| ② 설정 | `nano /etc/nginx/...` | **이미지 안에 있다** (바꾸려면 → [5_Dockerfile](lesson-5.md)) |
| ③ 기동 | `systemctl enable --now` | **`docker run -d`** |
| ④ 확인 | `systemctl status` · `ss` | **`docker ps`** · `ss` |
| ⑤ 개방 | `ufw allow 80/tcp` | **`-p 8080:80`** ⚠️ → [3_도커_핵심명령](lesson-3.md) |
| ⑥ 검증 | 브라우저 | **같다** |

> 📌 **순서는 그대로다.** 단지 ①②가 **남이 미리 해 둔 것**으로 바뀌었을 뿐이다.
> 그래서 12일차의 **"서버 종류는 달라도 세우는 순서는 같다"** 가 오늘도 유효하다.

---

## 📖 ⑥ 포트 충돌 — 일부러 만나 본다 (네 번째)

13일차에 세운 nginx 가 **80번**을 쓰고 있다. 컨테이너를 80번으로 띄워 보자.

```bash
docker run -d -p 80:80 --name web2 nginx
```

```
Error response from daemon: ... failed to bind host port for 0.0.0.0:80 ... address already in use
```

> 🔎 10일차 `python3 -m http.server` · 12일차 bind9 · 13일차 nginx 에 이어 **네 번째**다. **한 포트에 한 프로그램.**
> 그래서 우리는 **8080** 을 썼다.

```bash
docker ps -a | grep web2                # Created 상태로 남아 있다
docker rm web2                          # 실패한 컨테이너 정리
sudo ss -tulnp | grep ':80 '            # 80번은 호스트 nginx 가 쓰는 중
```

> 💡 **왼쪽이 호스트, 오른쪽이 컨테이너.** `-p 8080:80` = **"내 8080 으로 오면 컨테이너의 80 으로"**
> 11일차 PT 공유기의 **포트포워딩과 똑같은 모양**이다.
> ⭐ 여기서 [1번 절의 "공존"](lesson-1.md) 이 보인다 — **호스트 nginx(80) 와 컨테이너 nginx(8080) 가 지금 같이 살아 있다.**

---

## 🧪 실습 / 질문

- `docker ps` 에는 없는데 `docker ps -a` 에는 있다. 그 컨테이너는 어떤 상태인가?
- `docker run -d -p 9090:80 nginx` 를 하나 더 띄우면? `docker images` 는 몇 줄이 되나?
- `-p 80:8080` 이라고 거꾸로 쓰면 어떻게 되나?
- ①설치와 ②설정은 어디로 갔을까? 설정을 바꾸고 싶으면 어떻게 해야 할까?
- `sudo` 없이 `docker` 가 되게 한 뒤 **재로그인이 필요한 이유**는?

## 📝 강의 메모

- ⏱ **설치가 오늘의 최대 병목이다.** `apt` 미러가 느리면 5~10분을 먹는다
  - 👉 **STEP 0 몸풀기 중에 STEP 2 의 저장소 등록 + `apt update` 까지 미리 돌려 두면** 체감이 확 줄어든다
- ⭐⭐ **"Docker 설치도 여섯 단계"** 를 꼭 짚는다 — 12일차 표를 칠판에 다시 그려 놓고 ①③④ 에 체크
- ⭐ `docker run -d -p 8080:80 nginx` 는 **설명 전에 먼저 치게 한다.** 1초 만에 뜨는 걸 보고 나서 설명하면 집중도가 다르다
- ⚠️ `usermod -aG docker` 후 **재로그인**을 반드시 시킨다. 안 하면 반 전체가 `permission denied` 로 멈춘다
  - 재로그인 전에 `ls -l /var/run/docker.sock` 을 보여 주면 **"왜 그룹이 필요한지"** 가 10일차 권한으로 설명된다
- 포트 충돌(⑥)은 **일부러 낸다.** 네 번째 만남이라 이제는 학생이 먼저 원인을 말한다
- 🤖 **AI 활용** — `docker run` 의 옵션을 해석하게 시킨다("이 명령에서 `-d` 와 `-p` 가 뭘 하나?"). 10일차 검증 원칙대로 **문서와 대조**
- 🚨 **설치가 끝까지 안 되는 PC 가 나오면** — 2인 1조로 묶고, 그 PC 는 `docker ps` 가 되는 짝의 화면으로 따라간다. 설치에 수업 전체를 쓰지 않는다
- ⏱ 35분 (설치 20 + 실습 15)
