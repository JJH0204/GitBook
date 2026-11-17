# 4. 데이터와 볼륨 — 지우면 사라진다

> 상위: [14일차 · 도커 기초](README.md) · 대본 [STEP 4](commands.md)

## 🎯 학습 목표

- 컨테이너가 **일회용**이라는 뜻을 이해한다
- **바인드 마운트**와 **볼륨**의 차이를 안다
- 13일차에 `clone` 한 **내 포트폴리오 폴더**를 컨테이너에 연결한다 ⭐
- DB 컨테이너(MariaDB)를 띄우고 데이터를 **살려 둔다** — 12일차에 세운 그 MariaDB 를 회수한다

## 🌉 다리 놓기: "고쳤는데 사라졌어요"

[3_도커_핵심명령](lesson-3.md) 에서 `exec` 로 컨테이너 안에 들어가 봤다. 이번엔 안에서 **파일을 고쳐** 보자.

```bash
docker exec -it web bash -c 'echo "<h1>내가 고침</h1>" > /usr/share/nginx/html/index.html'
curl localhost:8080                 # 바뀌었다 ✅

docker rm -f web
docker run -d -p 8080:80 --name web nginx
curl localhost:8080                 # ⚠️ 원래대로 돌아왔다
```

> 🗣 **"컨테이너는 일회용입니다. 지우면 안에 있던 건 전부 사라집니다."**

---

## 📖 ① 컨테이너는 왜 일회용인가

```
 이미지 (읽기 전용)  +  컨테이너 레이어 (쓰기 가능)  =  돌아가는 컨테이너
        ▲ 안 바뀜              ▲ docker rm 하면 사라진다
```

- 컨테이너 안에서 쓴 것은 **컨테이너 레이어**에만 쌓인다
- `docker rm` = **그 레이어를 버리는 것**

> 💡 **이게 단점만은 아니다.** [1번 절](lesson-1.md) 의 **"청소"** 가 바로 이 성질이다.
> 12일차처럼 설정 파일이 `/etc` 에 여기저기 남지 않는다. 대신 **남겨야 할 것은 따로 챙겨야** 한다.

**그래서 데이터는 밖에 둔다.**

```
  컨테이너 (일회용)  ←──  연결  ──→  호스트의 폴더 / 볼륨 (영구)
```

---

## 📖 ② 두 가지 방법 — 바인드 마운트 vs 볼륨

| | **바인드 마운트** | **볼륨** |
|---|---|---|
| 쓰기 | `-v /호스트/경로:/컨테이너/경로` | `-v 이름:/컨테이너/경로` |
| 실체 | **내가 지정한 호스트 폴더** | Docker 가 관리하는 영역 |
| 보기 | `ls /호스트/경로` 로 바로 | `docker volume ls` |
| 좋은 때 | **내 소스코드**를 넣을 때 ⭐ | **DB 데이터** 처럼 Docker 가 알아서 |

### 13일차에 `clone` 한 내 포트폴리오를 그대로 연결한다 ⭐

```bash
ls /var/www/mysite                  # 13일차에 git clone 한 폴더가 아직 있다

docker rm -f web
docker run -d -p 8080:80 \
  -v /var/www/mysite:/usr/share/nginx/html:ro \
  --name web nginx
```

| 조각 | 뜻 |
|------|-----|
| `/var/www/mysite` | **호스트** 폴더 (13일차 `git clone` 한 그것!) |
| `/usr/share/nginx/html` | **컨테이너** 안의 경로 |
| `:ro` | **읽기 전용** — 컨테이너가 못 고친다 (11일차 최소 권한) |

```bash
curl localhost:8080                 # 13일차 내 포트폴리오가 뜬다 ⭐
```

```
🪟 http://localhost:8080  →  GitHub Pages 에 올린 그 페이지가, 이번엔 내 컨테이너에서
```

> ⭐ **13일차와 오늘이 처음으로 맞물리는 지점이다.** 같은 코드가 **세 곳**에서 돌고 있다 —
> **GitHub Pages**(남의 호스팅) · **호스트 nginx**(80) · **컨테이너**(8080).
> 🧪 **이어서 해 보기** — `cd /var/www/mysite && sudo git pull` 로 폴더만 갱신하면?
> **컨테이너를 건드리지 않아도** 새로고침에서 바뀐다. 보여주는 폴더가 같은 폴더니까.

### 12일차 NFS 와 같은 발상 ⭐

12일차에 NFS 는 시간이 없어 넘어갔지만(Samba 로 대체했다), 그 **발상**은 여기서 그대로 쓴다.

| | 파일 공유 (12일차 NFS · Samba) | 바인드 마운트 (오늘) |
|---|---|---|
| 한 줄 | **옮기지 않고** 남의 폴더를 **붙여 쓴다** | **옮기지 않고** 호스트 폴더를 **붙여 쓴다** |
| 명령 | `mount -t nfs 서버:/srv/share /mnt` | `-v /호스트:/컨테이너` |
| 차이 | **네트워크** 건너 | **같은 기계** 안 |

> 💡 **"복사가 아니라 연결"** — 한쪽을 고치면 양쪽에서 보인다. 이 감각이 핵심이다.

---

## 📖 ③ 볼륨 — DB 처럼 Docker 에게 맡길 때 (12일차 MariaDB 회수) ⭐

> 🗣 **"12일차에 MariaDB 를 설치했던 것 기억나죠? 그때 몇 분 걸렸나요?"**

```bash
docker volume create dbdata
docker volume ls
docker volume inspect dbdata        # 호스트의 실제 경로가 보인다
```

```bash
docker run -d --name db \
  -e MARIADB_ROOT_PASSWORD=example-password \
  -e MARIADB_DATABASE=testdb \
  -v dbdata:/var/lib/mysql \
  -p 127.0.0.1:3306:3306 \
  mariadb
```

| 조각 | 뜻 |
|------|-----|
| `-e KEY=VALUE` | **환경 변수** — 이미지에 설정을 넣는 방법 (②설정에 해당) ⭐ |
| `MARIADB_ROOT_PASSWORD` | 이 이미지가 **요구하는** 변수. 없으면 컨테이너가 바로 죽는다 |
| `-v dbdata:/var/lib/mysql` | DB 파일을 **볼륨에** 저장 |
| `-p 127.0.0.1:3306:3306` | ⭐ **밖에 열지 않는다** — 11일차 "DB 는 절대 공개 금지" |

> ⭐ **환경 변수가 "②설정" 의 자리다.** 12일차에는 `nano` 로 설정 파일을 고쳤다. 이미지는 고칠 수 없으니, **밖에서 변수로 넣어 준다.**
> → 이 변수들을 파일에 모아 두면 [Compose](lesson-6.md) 가 된다.

**초기화를 기다린다** — DB 는 처음 뜰 때 데이터 디렉터리를 만든다 (몇 초~십여 초)

```bash
docker logs -f db                   # "ready for connections" 가 보이면 Ctrl+C
```

> ⚠️ 이 줄을 안 기다리고 바로 접속하면 `Can't connect` 가 난다 — **에러가 아니라 아직 준비 중**이다.
> 📌 12일차 ④ 확인 단계와 같은 자리다. 띄웠다고 끝이 아니라 **"받을 준비가 됐는지"** 를 본다.

```bash
docker exec -it db mariadb -uroot -pexample-password -e "SHOW DATABASES;"
```

> 🔎 명령이 `mysql` 이 아니라 **`mariadb`** 다. 최근 MariaDB 이미지는 `mysql` 이름을 뺐다.

**지워도 살아남나 확인** ⭐

```bash
docker exec -it db mariadb -uroot -pexample-password testdb \
  -e "CREATE TABLE t(id INT); INSERT INTO t VALUES(1); SELECT * FROM t;"

docker rm -f db                     # 컨테이너를 통째로 지운다!
docker ps -a | grep db              # 없다

docker run -d --name db \
  -e MARIADB_ROOT_PASSWORD=example-password \
  -v dbdata:/var/lib/mysql \
  -p 127.0.0.1:3306:3306 mariadb

docker logs -f db                   # ready for connections 대기 (두 번째는 더 빠르다)
docker exec -it db mariadb -uroot -pexample-password testdb -e "SELECT * FROM t;"
```

```
+------+
| id   |
+------+
|    1 |     ← 살아 있다! ⭐
+------+
```

> 🗣 **"컨테이너는 지웠는데 데이터는 남았습니다. 이게 볼륨입니다."**
> 💡 **두 번째 기동이 더 빠른 이유** — 볼륨에 데이터가 이미 있어서 초기화를 **건너뛴다**.

> 🚨 **비밀번호를 명령줄에 쓰는 것**은 실습용이다. 실무에서는 **환경 파일(`.env`)** 로 빼고, 그 파일은 **13일차 `.gitignore`** 에 넣는다 → [6_환경을_코드로](lesson-6.md)

---

## 📖 ④ 정리 · 청소

```bash
docker ps -a                                  # 멈춘 컨테이너가 쌓인다
docker rm $(docker ps -aq -f status=exited)   # 멈춘 것 정리
docker volume ls
docker volume rm dbdata                       # ⚠️ 데이터가 사라진다
docker image prune                            # 안 쓰는 이미지
```

> 🛑 **`docker system prune -a` 는 3초 멈춤.** **이미지 · 컨테이너 · 네트워크 · 캐시를 전부** 지운다.
> 11일차 `ufw reset` · 13일차 `git reset --hard` 와 같은 자리의 명령이다.
> 📌 **볼륨은 `prune` 으로도 잘 안 지워진다** — 그래서 데이터를 두는 자리로 적합한 것이다.

---

## 🧪 실습 / 질문

- 컨테이너 안에서 고친 파일이 `docker rm` 후 사라지는 이유는?
- 바인드 마운트와 볼륨 중, **내 소스코드**를 넣을 때는 어느 쪽인가? **DB 데이터**는?
- `/var/www/mysite` 를 `:ro` 없이 연결하면 어떤 위험이 생기나?
- DB 를 `-p 3306:3306` 으로 띄우면 무엇이 위험한가? (11일차 회수)
- `docker volume rm dbdata` 를 하면 ③에서 만든 테이블은?

## 📝 강의 메모

- ⭐ **"고쳤는데 사라졌어요"** 를 **먼저 체험**시킨다. 설명이 필요 없어진다
- ⭐⭐ **②의 바인드 마운트**가 이 절의 중심이다 — **13일차 포트폴리오가 컨테이너에서 뜨는 장면**
  - 같은 코드가 **Pages · 호스트 nginx · 컨테이너** 세 곳에서 도는 것을 칠판에 그린다
- ⭐ **③의 "컨테이너를 지워도 데이터가 남는" 장면**을 반드시 눈으로 보여줄 것
- ⚠️ **DB 초기화 대기**를 설명 없이 넘기면 `Can't connect` 로 질문이 쏟아진다. `docker logs -f` 를 띄워 두고 **기다리는 법**을 가르친다
- ⚠️ DB 를 `127.0.0.1` 에만 바인딩하는 이유를 꼭 말할 것 — 3번 절 방화벽 함정과 **한 세트**다
- 📌 12일차에 **MariaDB 를 직접 설치**했던 반이므로, "그때 몇 분 vs 지금 몇 초" 대조가 잘 먹힌다
- ⏱ 25분. 시간이 모자라면 **③ DB 는 강사 시연만** 하고 ② 바인드 마운트만 따라 치게 한다 (③은 6번 절에서 Compose 로 다시 나온다)
