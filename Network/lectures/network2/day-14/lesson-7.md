# 6. 오늘의 문제 🎯

> 상위: [14일차 · 도커 기초](README.md)
> 💡 **진행 방법**: 각자 먼저 풀게 한 뒤 → `정답 및 해설` 콜아웃을 펼쳐 함께 확인한다.

---

## Q1. VM 과 컨테이너 — [1_컨테이너란](lesson-1.md)

What is the key difference between a virtual machine and a container?
(가상머신과 컨테이너의 결정적 차이는?)

- A. 컨테이너가 더 안전하다
- B. **컨테이너는 호스트의 커널을 공유한다**
- C. VM 은 네트워크를 못 쓴다
- D. 컨테이너는 리눅스에서만 만들 수 있다

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- VM 은 **게스트 OS 를 통째로** 올린다(9일차 하이퍼바이저). 컨테이너는 **커널을 공유**하고 나머지만 가진다
- 여기서 전부 파생된다 — **가볍다 · 1초 만에 뜬다 · 대신 격리가 약하다**
- A 는 반대다. 커널을 공유하므로 **격리는 VM 이 더 강하다**
- C 는 틀렸고, D 는 **"리눅스 컨테이너는 리눅스 커널이 필요하다"** 와 혼동한 것
{% endhint %}

---

## Q2. 이미지와 컨테이너 — [1_컨테이너란](lesson-1.md) · [2_첫_컨테이너](lesson-2.md)

You ran `docker run nginx` three times. How many **images** and **containers** do you have?
(`docker run nginx` 를 세 번 했다. 이미지와 컨테이너는 각각 몇 개인가?)

- A. 이미지 3 · 컨테이너 3
- B. **이미지 1 · 컨테이너 3**
- C. 이미지 3 · 컨테이너 1
- D. 이미지 1 · 컨테이너 1

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- **이미지 = 붕어빵 틀**(읽기 전용) · **컨테이너 = 구워진 붕어빵**
- 이미지는 **처음 한 번만** 내려받고(`pull`), 그걸로 컨테이너를 **여러 개** 만든다
- 확인: `docker images` (틀) · `docker ps -a` (붕어빵)
{% endhint %}

---

## Q3. 포트 매핑 — [3_도커_핵심명령](lesson-3.md) · 10일차

In `docker run -d -p 8080:80 nginx`, which number does a classmate type in their browser?
(`-p 8080:80` 에서 밖에서 브라우저에 치는 번호는?)

- A. 80
- B. **8080**
- C. 둘 다 가능
- D. 포트를 칠 필요가 없다

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- **왼쪽이 호스트, 오른쪽이 컨테이너**. 밖에서는 **호스트 번호(8080)** 로 들어온다
- `http://localhost:8080` → 호스트(WSL)가 받아서 **컨테이너의 80** 으로 넘긴다
- 11일차 PT 공유기의 **포트포워딩과 같은 그림**이다 (`External 80 → 192.168.0.10:80`)
{% endhint %}

---

## Q4. 방화벽 함정 🚨 ⭐ — [3_도커_핵심명령](lesson-3.md) · 11 · 12일차

`ufw` is active and you never allowed port 8080. You run `docker run -d -p 8080:80 nginx`.
Can a classmate reach it?
(`ufw` 가 켜져 있고 8080 을 허용한 적이 없다. 밖(내 Windows)에서 접속할 수 있나?)

- A. 아니다 — ufw 가 막는다
- B. **그렇다 — Docker 가 iptables 를 직접 건드려 ufw 를 우회한다**
- C. 재부팅 후에만 된다
- D. root 로 실행했을 때만 된다

{% hint style="success" %}
**정답 및 해설**

**정답: B 🚨**
- Docker 는 `-p` 를 쓸 때 **`iptables` 에 자기 규칙을 `ufw` 보다 앞에** 넣는다
- 그래서 **"`ufw` 를 켰으니 안전하다"** 는 **잘못된 믿음**이다
- 대응: 밖에 열 이유가 없으면 **`-p 127.0.0.1:8080:80`** 으로 **로컬에만** 바인딩한다
- 한 줄 — **"`-p` 는 방화벽에 구멍을 뚫는 것과 같다. 꼭 필요한 것만 `-p` 한다"**
{% endhint %}

---

## Q5. 데이터가 사라졌다 — [4_데이터와_볼륨](lesson-4.md)

You edited a file inside a container with `docker exec`, then ran `docker rm -f` and started a new one.
Your edit is gone. Why?
(컨테이너 안에서 고친 파일이 `docker rm` 후 사라졌다. 왜?)

- A. 이미지가 손상되어서
- B. **컨테이너 레이어에만 쓰였고, 컨테이너를 지우면 그 레이어가 사라져서**
- C. nginx 가 덮어써서
- D. 권한이 없어서

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- 이미지는 **읽기 전용**이고, 변경은 **컨테이너 레이어**에만 쌓인다. `rm` 은 그 레이어를 버린다
- 남겨야 할 것은 **밖에 둔다** — **바인드 마운트**(`-v /호스트:/컨테이너`) 또는 **볼륨**(`-v 이름:/컨테이너`)
- 이 성질이 단점만은 아니다 — **"실험하고 지우면 깨끗하다"** 가 같은 이야기다
{% endhint %}

---

## Q6. DB 컨테이너 — [4_데이터와_볼륨](lesson-4.md) · 11일차

Which is the safer way to publish a database container?
(DB 컨테이너를 띄울 때 더 안전한 쪽은?)

- A. `-p 3306:3306`
- B. **`-p 127.0.0.1:3306:3306`**
- C. `-P`
- D. `--network host`

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- `127.0.0.1` 을 붙이면 **WSL 자기 자신에서만** 접근된다. 밖(Windows·옆자리)에서는 **안 보인다**
- 11일차 **"DB 포트를 Anywhere 로 여는 것은 사고의 단골"** 과 같은 이야기
- A 는 **교실 전체에 DB 를 공개**하는 셈이다
- 웹 컨테이너만 DB 에 닿으면 되므로, **밖에 열 이유가 없다** (최소 개방)
{% endhint %}

---

## Q7. Dockerfile ⭐ — [5_Dockerfile](lesson-5.md)

Which statement about `EXPOSE 80` is correct?
(`EXPOSE 80` 에 대한 설명으로 맞는 것은?)

- A. 호스트의 80번 포트를 연다
- B. 방화벽에 80번을 허용한다
- C. **쓰는 포트를 표시할 뿐, 실제로 여는 것은 `docker run -p`**
- D. 컨테이너 안에서 80번을 LISTEN 하게 만든다

{% hint style="success" %}
**정답 및 해설**

**정답: C**
- `EXPOSE` 는 **문서용 표시**다. 이것만으로는 **밖에서 접속되지 않는다**
- 실제로 여는 것은 **`docker run -p 8080:80`**
- D 도 아니다 — LISTEN 은 **안에서 도는 프로그램(nginx)** 이 하는 일이다
{% endhint %}

---

## Q8. 13·14일차를 한 줄로 ⭐ — [5_Dockerfile](lesson-5.md) · 13일차

Why put the `Dockerfile` into your Git repository?
(Dockerfile 을 Git 저장소에 넣는 이유는?)

- A. 파일 크기를 줄이려고
- B. **코드뿐 아니라 "돌리는 방법"까지 함께 관리하려고**
- C. GitHub 가 자동으로 빌드해 주니까
- D. Docker Hub 에 올리려면 필수라서

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- 13일차 Git = **내 코드**. 14일차 Git = **내 코드 + 돌리는 방법**
- 그래서 다른 서버에서 **두 줄**이면 끝난다
  `git clone ...` → `docker build -t x . && docker run -d -p 8080:80 x`
- 🚨 단, **`.dockerignore` 에 `.git` 과 비밀 파일**을 반드시 넣는다 (13일차 `.gitignore` 와 같은 사고)
{% endhint %}

---

## Q9. 왜 컨테이너인가 ⭐ — [1_컨테이너란](lesson-1.md) · 13일차

13일차에 포트폴리오를 **GitHub Pages** 와 **내 WSL 서버** 두 곳에 올렸다.
컨테이너는 그중 **어떤 한계**를 해결하는가?

- A. Pages 의 주소가 너무 길다
- B. **Pages 는 정적 파일만 올라가고, 내 서버 환경은 다른 PC 로 옮길 수 없다**
- C. Git 의 용량 제한
- D. 브랜치를 더 많이 만들 수 있다

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- **GitHub Pages** = 정적 호스팅. HTML · CSS · JS 만. **DB · 로그인 · 게시판은 못 올린다**
- **내 WSL 서버** = 뭐든 올리지만, 그 환경이 **내 PC 안에만** 있다. 옮기려면 12일차 여섯 단계를 처음부터
- 컨테이너는 **"프로그램 + 그 환경"을 한 덩어리로 묶어 옮긴다** → 그래서 둘 사이의 빈칸을 메운다
- 증거는 5번 절 ⑤ — **옆자리 저장소를 `clone` → `build` → `run` 세 줄로** 내 PC 에서 띄운 그 장면
{% endhint %}

---

## Q10. Compose ⭐⭐ — [6_환경을_코드로](lesson-6.md) · 11일차

`compose.yaml` 에서 `db` 서비스에는 `ports` 를 쓰지 않았다. 그런데 `web` 은 DB 에 잘 접속한다. 왜인가?

- A. Docker 가 모든 포트를 자동으로 연다
- B. **같은 Compose 안의 컨테이너는 서비스 이름(`db`)으로 내부 통신한다 — 호스트에 포트를 열 필요가 없다**
- C. `.env` 파일이 포트를 열어 준다
- D. `restart: unless-stopped` 때문이다

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- Compose 가 서비스마다 **내부 DNS 이름**을 만들어 준다 (10일차 DNS = 이름 → 주소)
- `sudo ss -tulnp | grep 3306` 이 **아무것도 안 뽑는다** = 호스트에 문이 안 열렸다
- ⭐ 그래서 **3번 절의 `ufw` 우회 문제도 생기지 않는다** — `-p` 를 **안 쓰는 것**이 가장 안전하다 (11일차 최소 개방의 완성)
- 📌 비밀번호는 `.env` 에 두고 **`.gitignore`** 에, 대신 **`.env.example`** 을 커밋한다 — "구조는 공개, 값은 비공개"
{% endhint %}

---

## 📝 강의 메모

- ⭐⭐ **Q4(방화벽 우회)** 는 무슨 일이 있어도 다룬다. 11 · 12일차를 배운 반에서 이게 빠지면 **잘못된 보안 감각**이 남는다
  - **Q10 과 한 쌍**이다 — Q4 가 문제, Q10 이 답이다. 두 문항을 **붙여서** 짚으면 오늘 보안이 한 줄로 정리된다
- **Q3 · Q6** 은 10 · 11일차 회수 문제 — "오늘 배운 게 지난주와 어떻게 이어지는지" 를 확인하는 자리
- **Q9 → Q8 → Q10** 순서로 마무리하면 오늘의 서사가 그대로 복습된다 (왜 → 코드+환경 → 환경 전체)
- ⏱ 15분. 시간이 모자라면 **Q2 · Q5 · Q7 은 눈으로만** 읽고 **Q4 · Q9 · Q10** 에 집중한다
- 📌 끝맺음 한 줄 — **"오늘 우리는 서버를 세운 게 아니라, 세우는 방법을 저장소에 적었다."** → 16일차 배포 예고
