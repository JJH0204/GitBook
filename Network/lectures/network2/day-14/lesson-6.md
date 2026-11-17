# 6. 환경을 코드로 — Compose 로 한 줄 재현 ⭐

> 상위: [14일차 · 도커 기초](README.md) · 대본 [STEP 6](commands.md)

## 🎯 학습 목표

- 컨테이너가 **여러 개**가 되면 명령줄로는 관리가 안 된다는 것을 체감한다
- **`compose.yaml`** 에 환경(서비스 · 포트 · 볼륨 · 변수)을 적는다
- 컨테이너끼리는 **서비스 이름으로** 통한다는 것을 확인한다 — DB 는 **밖에 안 연다** ⭐
- **비밀은 `.env` 로 빼고 `.gitignore` 에**, 대신 **`.env.example` 을 커밋**한다 ⭐
- `git clone` → **`docker compose up -d`** 로 환경을 **한 줄에 되살린다** ⭐⭐

## 🌉 다리 놓기: "이 명령을 어떻게 전달하죠?"

[4번 절](lesson-4.md) 에서 DB 를 띄운 명령을 다시 보자.

```bash
docker run -d --name db -e MARIADB_ROOT_PASSWORD=example-password -e MARIADB_DATABASE=testdb \
  -v dbdata:/var/lib/mysql -p 127.0.0.1:3306:3306 mariadb
```

여기에 [5번 절](lesson-5.md) 의 웹 컨테이너까지 합치면 **외워야 할 명령이 두 줄**이다.

> 🗣 **"이걸 옆자리에, 그리고 3개월 뒤의 나에게 어떻게 전달하죠? 카톡으로요?"**

13일차에 우리는 같은 문제를 이미 풀었다. **코드는 기억하지 말고 Git 에 적어 둔다.**
환경도 똑같이 하면 된다 — **명령을 파일로 적는다.** 그 파일이 **`compose.yaml`** 이다.

```
  13일차:  Git = 코드
  5번 절:  Git = 코드 + 돌리는 방법 (Dockerfile · 컨테이너 하나)
  6번 절:  Git = 코드 + 환경 전체 (Compose · 여러 컨테이너 · 포트 · 볼륨 · 변수)  ⭐
```

> 📌 `docker compose` 명령은 [2번 절](lesson-2.md) 에서 설치한 **`docker-compose-plugin`** 에 들어 있다. 따로 설치할 것이 없다.

```bash
docker compose version
```

---

## 📖 ① `compose.yaml` — 명령줄을 그대로 옮긴 것

```bash
cd ~/myweb
nano compose.yaml
```

```yaml
services:
  web:
    build: .                       # ← 5번 절의 docker build -t … .
    ports:
      - "8080:80"                  # ← -p 8080:80
    restart: unless-stopped

  db:
    image: mariadb                 # ← 이미지를 그대로 받아 쓴다
    environment:
      MARIADB_ROOT_PASSWORD: ${DB_PASSWORD}
      MARIADB_DATABASE: testdb
    volumes:
      - dbdata:/var/lib/mysql      # ← -v dbdata:/var/lib/mysql
    restart: unless-stopped
    # ⭐ ports 가 없다! 밖에 열지 않는다

volumes:
  dbdata:
```

**명령줄 ↔ 파일 대응**

| `docker run` 옵션 | `compose.yaml` |
|-------------------|----------------|
| `--name web` | `services:` 아래의 **이름** `web` |
| `-p 8080:80` | `ports: ["8080:80"]` |
| `-e KEY=VALUE` | `environment:` |
| `-v 이름:/경로` | `volumes:` (+ 맨 아래 `volumes:` 선언) |
| 이미지 이름 | `image:` |
| `docker build … .` | **`build: .`** |
| (없음) | `restart: unless-stopped` — 재부팅 후 자동 기동 ⭐ |

> 💡 **`version:` 줄은 쓰지 않는다.** 지금 Compose(v2)에서는 **쓸모가 없어져** `version is obsolete` 경고만 나온다.
> 📌 파일 이름은 `compose.yaml` 이 요즘 표준이다 (`docker-compose.yml` 도 그대로 인식된다).

---

## 📖 ② 비밀은 `.env` 로 — 그리고 `.env.example` 을 커밋한다 ⭐

위 파일에서 비밀번호를 `${DB_PASSWORD}` 로 비워 뒀다. 값은 **옆 파일**에 둔다.

```bash
nano .env
```

```
DB_PASSWORD=example-password
```

```bash
# Git 에는 올리지 않는다 (13일차 .gitignore)
echo ".env" >> .gitignore
```

**그런데 `.env` 를 안 올리면 옆자리는 뭘 넣어야 할지 모른다.** 그래서 **빈 양식**을 올린다.

```bash
nano .env.example
```

```
# 각자 복사해서 쓰세요:  cp .env.example .env
DB_PASSWORD=여기에_직접_정하세요
```

```bash
git add compose.yaml .env.example .gitignore
git commit -m "Compose 추가 — 환경 전체를 저장소에"
git push
```

| 파일 | Git 에 올리나 | 무엇이 들어가나 |
|------|---------------|-----------------|
| `compose.yaml` | **올린다** | 구조 — 서비스 · 포트 · 볼륨 |
| `.env.example` | **올린다** | **변수 이름만** (값은 비움) |
| `.env` | 🚨 **안 올린다** | 실제 비밀번호 |

> 🚨 **13일차의 그 원칙** — 비밀은 커밋하면 **지워도 이력에 남는다**. 처음부터 안 올린다.
> 📌 **"구조는 공개, 값은 비공개"** 가 실무의 기본형이다. 16일차 **Secret** 도 같은 방식으로 다룬다.

---

## 📖 ③ 띄워 본다 — 한 줄

```bash
docker compose config               # ⭐ 먼저 문법 검사 (12일차 nginx -t · named-checkconf 습관)
docker compose up -d
```

```bash
docker compose ps                   # 두 서비스가 Up
docker compose logs -f db           # ready for connections 확인 (Ctrl+C)
curl localhost:8080                 # 내 포트폴리오
```

> 🔎 **컨테이너 이름이 `myweb-web-1` 처럼 바뀐다** — Compose 는 **폴더 이름을 프로젝트 이름**으로 쓴다.

### 컨테이너끼리는 **이름으로** 통한다 ⭐

```bash
docker compose exec web sh -c "getent hosts db"     # db 의 컨테이너 IP 가 나온다
```

> ⭐ **`db` 라는 호스트 이름이 그대로 통한다.** Compose 가 서비스마다 **내부 DNS 이름**을 만들어 준다.
> 10일차 **DNS = 이름 → 주소** 가 컨테이너 안에서도 그대로 쓰인다.

```bash
sudo ss -tulnp | grep 3306          # ⭐ 아무것도 안 나온다
```

> ⭐⭐ **이게 이 절의 보안 결말이다.** 웹은 DB 에 **이름으로** 닿는데, 호스트에는 **3306 이 아예 열리지 않았다.**
> 11일차 **최소 개방**의 완성형 — `-p` 를 **안 쓰는 것**이 가장 안전한 선택이다.
> 📌 3번 절에서 본 `ufw` 우회 문제도 **`-p` 를 안 쓰면 생기지 않는다.**

**내리기**

```bash
docker compose stop                 # 멈춤 (데이터·컨테이너 유지)
docker compose down                 # 컨테이너·네트워크 삭제 (볼륨은 남는다) ⭐
docker compose up -d                # 다시 올리면 데이터가 그대로
```

> 🛑 **`docker compose down -v` 는 3초 멈춤** — `-v` 가 **볼륨까지** 지운다. DB 데이터가 날아간다.

---

## 📖 ④ 결말 — `clone` 한 줄로 환경이 선다 ⭐⭐

[5번 절 ⑤](lesson-5.md) 에서 옆자리 저장소를 띄워 봤다. 이제는 **DB 까지 포함한 환경 전체**가 이렇게 선다.

```bash
cd ~
git clone https://github.com/<아이디>/myweb.git demo && cd demo
cp .env.example .env && nano .env        # 비밀번호만 각자 정한다
docker compose up -d
```

```
  세 줄.  웹 + DB + 볼륨 + 네트워크가 선다.
```

| 12일차 (apt) | 오늘 (Compose) |
|--------------|----------------|
| 여섯 단계 × 서버 개수 | **`up -d` 한 줄** |
| 설정 파일이 `/etc` 에 흩어진다 | **파일 하나에 모여 있다** |
| 옆자리에 전달 = 구두 설명 | **`git clone`** |
| 되돌리기 = 기억에 의존 | **`down` → `up`** |

> 🗣 **"오늘 우리가 한 일은 서버를 세운 게 아닙니다. 서버를 세우는 방법을 파일로 적어 Git 에 넣은 겁니다."**
> 📌 **15 · 16일차**에는 이 저장소를 그대로 들고 간다. 같은 환경을 **쿠버네티스 매니페스트**로 다시 적어 올린다.

---

## 🧪 실습 / 질문

- `compose.yaml` 의 `db` 에 `ports` 를 쓰지 않았다. 그런데 웹은 어떻게 DB 에 접속하나?
- `.env` 는 Git 에 올리지 않고 `.env.example` 은 올린다. 각각의 이유는?
- `docker compose down` 과 `docker compose down -v` 의 차이는?
- `restart: unless-stopped` 가 12일차의 어느 명령과 같은 역할인가? (힌트: `systemctl enable`)
- 포트를 안 연 DB 를 내가 직접 들여다보려면 어떻게 하면 될까?

## 📝 강의 메모

- ⏱ **20분 · 시간이 모자라면 강사 시연으로 간다.** 단, **①의 대응표**와 **③의 `ss | grep 3306` 이 비는 장면**은 반드시 보여줄 것
- ⭐⭐ **"ports 가 없는 db"** 가 이 절의 하이라이트다 — 3번 절에서 놀랐던 방화벽 함정의 **해답**이 여기 있다
  - 칠판: `-p` 를 쓴 것(web) 과 안 쓴 것(db) 을 그려 **문이 몇 개인지** 세게 한다
- ⭐ **`.env` / `.env.example` 한 쌍**은 실무에서 매일 쓰는 습관이다. 13일차 `.gitignore` 를 다시 꺼내 연결할 것
- `docker compose config` 를 **먼저** 치는 습관 — 12일차 `nginx -t` · `named-checkconf` 와 같은 자리
- ⚠️ YAML 은 **들여쓰기가 문법**이다. 탭 금지, 공백 2칸으로 통일. `config` 가 에러를 잡아 준다
- ⚠️ 4번 절에서 띄운 `db` 컨테이너가 남아 있으면 **이름이나 볼륨이 겹칠 수 있다** → `docker rm -f db` 로 먼저 정리
- 📌 **쿠버네티스는 이름만 꺼낸다** — "컨테이너가 수백 개가 되면 쓰는 도구가 따로 있다" 한 줄 (이 과정에서는 다루지 않는다)
