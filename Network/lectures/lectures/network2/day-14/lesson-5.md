# 5. Dockerfile — 내 포트폴리오를 이미지로 ⭐

> 상위: [14일차 · 도커 기초](README.md) · 대본 [STEP 5](commands.md)

## 🎯 학습 목표

- **Dockerfile** 이 12일차 ①설치 · ②설정을 **적어 두는 문서**임을 이해한다
- `FROM` · `COPY` · `RUN` · `EXPOSE` · `CMD` 를 읽고 쓴다
- `docker build` 로 **내 이미지**를 만들어 띄운다
- 13일차 **Git 저장소에 Dockerfile 을 넣어** 코드와 환경을 함께 관리한다 ⭐
- **옆자리 저장소를 `clone` 해서 똑같이 띄워** 재현성을 눈으로 확인한다 ⭐⭐

## 🌉 다리 놓기: "①②는 누가 해 둔 걸까?"

[2_첫_컨테이너](lesson-2.md) 에서 이런 질문을 남겼다.

> 🗣 **"여섯 단계 중 ①설치와 ②설정은 어디로 갔죠?"**
> → **이미지 안에 있다. 누군가 미리 해서 포장해 둔 것.**

오늘은 **그 포장을 내가 한다.** 그 레시피를 적는 문서가 **Dockerfile** 이다.

```
 Dockerfile  ──docker build──▶  이미지  ──docker run──▶  컨테이너
  (레시피 · Git 에 들어간다)      (붕어빵 틀)              (붕어빵)
```

> 📌 [4번 절](lesson-4.md) 의 바인드 마운트는 **"내 코드를 빌려 보여주는"** 방식이었다.
> Dockerfile 은 **"내 코드를 이미지에 넣어 통째로 옮기는"** 방식이다. 옮기려면 이쪽이어야 한다.

---

## 📖 ① Dockerfile = 여섯 단계의 ①②를 적은 문서

```dockerfile
FROM nginx:alpine                          # 바탕 이미지 (① 설치의 출발점)
COPY ./site /usr/share/nginx/html          # 내 파일을 넣는다 (② 설정)
EXPOSE 80                                  # 이 포트를 쓴다 (문서용 표시)
CMD ["nginx", "-g", "daemon off;"]         # 켤 때 실행할 명령 (③ 기동)
```

| 명령어 | 뜻 | 12일차 대응 |
|--------|-----|-------------|
| **`FROM`** | **바탕 이미지** — 맨 위에 꼭 하나 | OS 를 고르는 것 |
| **`COPY`** | 호스트 파일을 **이미지 안으로** | 설정 파일 넣기 |
| **`RUN`** | **빌드할 때** 실행 (`apt install` 등) | ① 설치 |
| **`WORKDIR`** | 기본 작업 폴더 | `cd` |
| **`EXPOSE`** | 쓰는 포트 **표시** (여는 건 `-p`) ⚠️ | — |
| **`CMD`** | **컨테이너가 켜질 때** 실행 | ③ 기동 |

> ⚠️ **`EXPOSE` 는 포트를 열지 않는다.** 문서용 표시일 뿐이고, 실제로 여는 것은 **`docker run -p`** 다.
> 3번 절의 방화벽 이야기와 헷갈리기 쉬운 지점 — **"`-p` 만이 문을 연다"**.

> 💡 **`RUN` 과 `CMD` 의 차이** — `RUN` 은 **붕어빵 틀을 만들 때** 한 번, `CMD` 는 **붕어빵을 구울 때마다**.

---

## 📖 ② 내 이미지 만들기 — 13일차 포트폴리오로 ⭐

13일차에 만든 작업 폴더(`~/myweb` 등 각자 저장소 이름)를 그대로 쓴다.

```bash
cd ~/myweb
ls                                  # index.html · about.html · README.md …
mkdir -p site
mv index.html about.html site/ 2>/dev/null
ls site/
nano Dockerfile
```

```dockerfile
FROM nginx:alpine
COPY ./site /usr/share/nginx/html
EXPOSE 80
```

> 📌 `nginx` 이미지는 `CMD` 가 **이미 들어 있어서** 생략해도 된다. `FROM` 이 물려준다.
> 📌 `:alpine` = 알파인 리눅스 기반의 **가벼운 판**. `nginx:latest` 보다 몇 배 작다 (`docker images` 로 비교해 볼 것)

```bash
docker build -t mysite:1.0 .
```

| 조각 | 뜻 |
|------|-----|
| `build` | Dockerfile 로 **이미지를 굽는다** |
| `-t mysite:1.0` | 이름**:태그** (태그 = 버전) |
| `.` | **빌드 컨텍스트** = 이 폴더를 Docker 에 넘긴다 ⚠️ 점을 빠뜨리면 에러 |

```bash
docker images | grep -E "mysite|nginx"      # 내 이미지와 바탕 이미지
docker rm -f web 2>/dev/null
docker run -d -p 8080:80 --name mysite mysite:1.0
curl localhost:8080                          # 내가 만든 페이지 ⭐
```

```
🪟 http://localhost:8080  →  내 이미지로 띄운 내 포트폴리오
```

> 🗣 **"이제 이 이미지 하나만 있으면, 어느 서버에서든 `docker run` 한 줄로 똑같이 뜹니다."**
> → [1번 절](lesson-1.md) 의 **"제 컴퓨터에선 됐는데요가 사라진다"** 가 여기서 증명된다

---

## 📖 ③ `.dockerignore` — 13일차 `.gitignore` 와 같은 발상

```bash
nano .dockerignore
```

```
.git
.env
*.key
node_modules
*.log
```

> 🚨 **`.git` 폴더를 이미지에 넣지 않는다.** 이력 전체가 딸려 들어가 **이미지가 커지고**, 과거 커밋에 남은 **비밀이 함께 배포**된다.
> 13일차 **"비밀은 지워도 이력에 남는다"** 와 정확히 같은 사고다.
> 💡 `.dockerignore` 는 **빌드 컨텍스트**(②의 `.`)에서 제외할 목록이다. `.gitignore` 가 커밋에서 빼는 것과 자리가 같다.

---

## 📖 ④ Git 저장소에 Dockerfile 을 넣는다 ⭐⭐

```bash
cd ~/myweb
git status                          # Dockerfile · .dockerignore · site/ 가 보인다
git add Dockerfile .dockerignore site/
git commit -m "Dockerfile 추가 — 컨테이너로 돌리는 방법까지 저장소에"
git push
```

> ⭐ **이것이 오늘의 결말이다.**
> 13일차에는 **코드**만 Git 에 있었다. 이제 **"이 코드를 어떤 환경에서 어떻게 돌리는지"** 까지 Git 에 들어갔다.

```
  13일차:  Git = 내 코드
  14일차:  Git = 내 코드 + 돌리는 방법(Dockerfile)   ⭐
```

> ⚠️ **GitHub Pages 를 쓰고 있는 저장소라면** — `index.html` 을 `site/` 로 옮기면 Pages 주소가 깨질 수 있다.
> 👉 **둘 중 하나**로 간다: ① Pages 설정에서 **폴더를 `/site`** 로 바꾼다 ② 또는 `site/` 로 옮기지 않고 **`COPY . /usr/share/nginx/html`** 로 쓰고 `.dockerignore` 로 걸러낸다.
> 📌 **13일차 결과물(Pages)을 깨지 않는 것**이 중요하다. 수업에서는 ①을 권한다.

---

## 📖 ⑤ 재현성 실험 — 옆자리 저장소를 띄워 본다 ⭐⭐

> 🗣 **"말로만 '어디서나 똑같이 돈다' 고 하면 안 믿기죠. 옆자리 것을 띄워 봅시다."**

```bash
cd ~
git clone https://github.com/<옆자리_아이디>/<저장소>.git friend
cd friend
docker build -t friend:1.0 .
docker run -d -p 8090:80 --name friend friend:1.0
curl localhost:8090
```

```
🪟 http://localhost:8090  →  옆자리 포트폴리오가 내 PC 에서 돈다
```

| 내가 한 일 | 내가 **하지 않은** 일 |
|------------|----------------------|
| `clone` → `build` → `run` | nginx 설치 · 설정 파일 수정 · 포트 열기 · 버전 맞추기 |

> ⭐ **이 장면이 14일차의 핵심 증거다.** 옆자리 PC 환경을 하나도 묻지 않았는데 **똑같이 떴다.**
> 📌 12일차에 서버 하나 세우는 데 여섯 단계 × 여러 명령이 필요했다. 지금은 **세 줄**이다.
> 👉 16일차에는 **이 이미지를 그대로** 쿠버네티스 클러스터에 올린다.

---

## 📖 ⑥ 고치면 다시 굽는다

```bash
nano site/index.html                # 내용 수정
docker build -t mysite:1.1 .        # 태그를 올린다 ⭐
docker rm -f mysite
docker run -d -p 8080:80 --name mysite mysite:1.1
```

> 💡 **이미지는 고칠 수 없다. 다시 굽는다.** (읽기 전용이니까)
> 🔎 두 번째 빌드는 **훨씬 빠르다** — 바뀐 층부터만 다시 굽는다(레이어 캐시). [1_컨테이너란](lesson-1.md) 의 레이어가 여기서 보인다.
> 📌 태그(`1.0` → `1.1`)를 올리면 **문제가 생겼을 때 이전 이미지로 바로 되돌릴 수 있다** — 13일차 커밋과 같은 역할

```bash
docker images | grep mysite         # 1.0 과 1.1 이 모두 있다 = 되돌릴 수 있다
```

---

## 🧪 실습 / 질문

- `RUN` 과 `CMD` 는 각각 언제 실행되나?
- `EXPOSE 80` 만 쓰고 `-p` 를 안 쓰면 밖에서 접속이 될까?
- `docker build -t mysite:1.0` 에서 맨 뒤의 `.` 은 무슨 뜻인가? 빠뜨리면?
- `.git` 을 `.dockerignore` 에 넣는 이유를 두 가지 말해보자
- ⑤에서 옆자리 저장소가 **내 PC 에서 그대로 뜬 이유**를 한 문장으로 설명해보자
- 바인드 마운트(4번 절)와 `COPY`(오늘) 중, **다른 서버로 옮길 때** 쓸 것은?

## 📝 강의 메모

- ⭐⭐ **"①②는 누가 해 둔 걸까?" → "오늘은 내가 한다"** 로 열면 2번 절과 깔끔히 이어진다
- ⭐⭐ **⑤(옆자리 저장소 띄우기)가 오늘의 가장 좋은 장면이다.** 반드시 시간을 남긴다
  - 저장소 주소를 **칠판이나 채팅방에 서로 공유**하게 하면 빠르다
  - 공개 저장소여야 `clone` 이 된다 — 13일차에 공개로 만들었는지 확인
- ⭐ **④(Git 에 Dockerfile 을 넣는 장면)** 이 13 · 14일차를 하나로 묶는다. **"코드 + 돌리는 방법"** 을 칠판에 적을 것
- 🚨 **Pages 가 깨질 수 있다는 주의(④)** 를 빼먹지 말 것 — 13일차 결과물이 눈앞에서 깨지면 학생 체감이 크다
- ⚠️ `docker build` 끝의 **`.` 을 빠뜨리는** 실수가 1위. `"docker build" requires exactly 1 argument` 가 그 증상
- `EXPOSE` 가 포트를 **열지 않는다**는 점은 3번 절의 방화벽 이야기와 묶어서 한 번 더
- 🤖 **AI 활용** — Dockerfile 초안을 받게 하되, **`FROM` 의 태그**와 **`COPY` 경로**는 직접 확인시킨다(10일차 검증 원칙)
- ⏱ 35분. 시간이 모자라면 **⑥(재빌드)를 생략**하고 ⑤는 남긴다 — ⑤가 오늘의 증거다
