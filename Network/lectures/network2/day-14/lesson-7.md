# 7. 오늘의 문제

> 상위: [14일차 · 도커 기초](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-14-007-INS |
| 유형 | INS (점검) |
| 목적 | 14일차 내용(VM과 컨테이너, 이미지와 컨테이너, 포트 매핑, 방화벽 우회, 데이터 보존, DB 공개, `EXPOSE`, Dockerfile, Pages의 한계, Compose)을 문제 10문항으로 점검한다 |
| 확인 상태 | 미검증 (원본 문제의 정답과 해설을 다시 읽고 확인했으며 명령을 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 점검 방법

- 각자 먼저 푼 뒤 정답 및 해설 알림을 펼쳐 함께 확인한다.
- 합격 기준: 10문항 중 8문항 이상 정답이다. Q4(방화벽 우회)와 Q10(Compose)은 반드시 맞힌다.

## 점검 항목

### Q1. VM과 컨테이너 — [1. 왜 컨테이너인가](lesson-1.md)

What is the key difference between a virtual machine and a container?
(가상머신과 컨테이너의 결정적 차이는?)

- A. 컨테이너가 더 안전하다
- B. 컨테이너는 호스트의 커널을 공유한다
- C. VM은 네트워크를 못 쓴다
- D. 컨테이너는 리눅스에서만 만들 수 있다

{% hint style="info" %}
정답 및 해설

정답: B

- VM은 게스트 OS를 통째로 올린다(9일차 하이퍼바이저). 컨테이너는 커널을 공유하고 나머지만 가진다.
- 여기서 전부 파생된다. 가볍다, 1초 만에 뜬다, 대신 격리가 약하다.
- A는 반대이다. 커널을 공유하므로 격리는 VM이 더 강하다.
- C는 틀렸고, D는 "리눅스 컨테이너는 리눅스 커널이 필요하다"와 혼동한 것이다.
{% endhint %}

### Q2. 이미지와 컨테이너 — [1. 왜 컨테이너인가](lesson-1.md), [2. 설치와 첫 컨테이너](lesson-2.md)

You ran `docker run nginx` three times. How many **images** and **containers** do you have?
(`docker run nginx`를 세 번 했다. 이미지와 컨테이너는 각각 몇 개인가?)

- A. 이미지 3, 컨테이너 3
- B. 이미지 1, 컨테이너 3
- C. 이미지 3, 컨테이너 1
- D. 이미지 1, 컨테이너 1

{% hint style="info" %}
정답 및 해설

정답: B

- 이미지는 붕어빵 틀(읽기 전용), 컨테이너는 구워진 붕어빵이다.
- 이미지는 처음 한 번만 내려받고(`pull`) 그것으로 컨테이너를 여러 개 만든다.
- 확인: `docker images`(틀), `docker ps -a`(붕어빵).
{% endhint %}

### Q3. 포트 매핑 — [3. 핵심 명령과 포트](lesson-3.md), 10일차

In `docker run -d -p 8080:80 nginx`, which number does a classmate type in their browser?
(`-p 8080:80`에서 밖에서 브라우저에 치는 번호는?)

- A. 80
- B. 8080
- C. 둘 다 가능
- D. 포트를 칠 필요가 없다

{% hint style="info" %}
정답 및 해설

정답: B

- 왼쪽이 호스트, 오른쪽이 컨테이너이다. 밖에서는 호스트 번호(8080)로 들어온다.
- `http://localhost:8080`을 호스트(WSL)가 받아서 컨테이너의 80으로 넘긴다.
- 11일차 PT 공유기의 포트포워딩과 같은 그림이다(`External 80 → 192.168.0.10:80`).
{% endhint %}

### Q4. 방화벽 함정 — [3. 핵심 명령과 포트](lesson-3.md), 11일차, 12일차

`ufw` is active and you never allowed port 8080. You run `docker run -d -p 8080:80 nginx`.
Can a classmate reach it?
(`ufw`가 켜져 있고 8080을 허용한 적이 없다. 밖(내 Windows)에서 접속할 수 있나?)

- A. 아니다. ufw가 막는다
- B. 그렇다. Docker가 iptables를 직접 건드려 ufw를 우회한다
- C. 재부팅 후에만 된다
- D. root로 실행했을 때만 된다

{% hint style="info" %}
정답 및 해설

정답: B

- Docker는 `-p`를 쓸 때 `iptables`에 자기 규칙을 `ufw`보다 앞에 넣는다.
- 그래서 "`ufw`를 켰으니 안전하다"는 잘못된 믿음이다.
- 대응: 밖에 열 이유가 없으면 `-p 127.0.0.1:8080:80`으로 로컬에만 바인딩한다.
- 한 줄: `-p`는 방화벽에 구멍을 뚫는 것과 같다. 꼭 필요한 것만 `-p`한다.
{% endhint %}

### Q5. 데이터가 사라졌다 — [4. 데이터와 볼륨](lesson-4.md)

You edited a file inside a container with `docker exec`, then ran `docker rm -f` and started a new one.
Your edit is gone. Why?
(컨테이너 안에서 고친 파일이 `docker rm` 후 사라졌다. 왜?)

- A. 이미지가 손상되어서
- B. 컨테이너 레이어에만 쓰였고, 컨테이너를 지우면 그 레이어가 사라져서
- C. nginx가 덮어써서
- D. 권한이 없어서

{% hint style="info" %}
정답 및 해설

정답: B

- 이미지는 읽기 전용이고 변경은 컨테이너 레이어에만 쌓인다. `rm`은 그 레이어를 버린다.
- 남겨야 할 것은 밖에 둔다. 바인드 마운트(`-v /호스트:/컨테이너`) 또는 볼륨(`-v 이름:/컨테이너`)이다.
- 이 성질이 단점만은 아니다. "실험하고 지우면 깨끗하다"가 같은 이야기이다.
{% endhint %}

### Q6. DB 컨테이너 — [4. 데이터와 볼륨](lesson-4.md), 11일차

Which is the safer way to publish a database container?
(DB 컨테이너를 띄울 때 더 안전한 쪽은?)

- A. `-p 3306:3306`
- B. `-p 127.0.0.1:3306:3306`
- C. `-P`
- D. `--network host`

{% hint style="info" %}
정답 및 해설

정답: B

- `127.0.0.1`을 붙이면 WSL 자기 자신에서만 접근된다. 밖(Windows, 옆자리)에서는 보이지 않는다.
- 11일차 "DB 포트를 Anywhere로 여는 것은 사고의 단골"과 같은 이야기이다.
- A는 교실 전체에 DB를 공개하는 셈이다.
- 웹 컨테이너만 DB에 닿으면 되므로 밖에 열 이유가 없다(최소 개방).
{% endhint %}

### Q7. Dockerfile — [5. Dockerfile](lesson-5.md)

Which statement about `EXPOSE 80` is correct?
(`EXPOSE 80`에 대한 설명으로 맞는 것은?)

- A. 호스트의 80번 포트를 연다
- B. 방화벽에 80번을 허용한다
- C. 쓰는 포트를 표시할 뿐, 실제로 여는 것은 `docker run -p`
- D. 컨테이너 안에서 80번을 LISTEN 하게 만든다

{% hint style="info" %}
정답 및 해설

정답: C

- `EXPOSE`는 문서용 표시이다. 이것만으로는 밖에서 접속되지 않는다.
- 실제로 여는 것은 `docker run -p 8080:80`이다.
- D도 아니다. LISTEN은 안에서 도는 프로그램(nginx)이 하는 일이다.
{% endhint %}

### Q8. 13일차와 14일차를 한 줄로 — [5. Dockerfile](lesson-5.md), 13일차

Why put the `Dockerfile` into your Git repository?
(Dockerfile을 Git 저장소에 넣는 이유는?)

- A. 파일 크기를 줄이려고
- B. 코드뿐 아니라 "돌리는 방법"까지 함께 관리하려고
- C. GitHub가 자동으로 빌드해 주니까
- D. Docker Hub에 올리려면 필수라서

{% hint style="info" %}
정답 및 해설

정답: B

- 13일차 Git = 내 코드. 14일차 Git = 내 코드 + 돌리는 방법.
- 그래서 다른 서버에서 두 줄이면 끝난다: `git clone ...`, `docker build -t x . && docker run -d -p 8080:80 x`.
- 단 `.dockerignore`에 `.git`과 비밀 파일을 반드시 넣는다(13일차 `.gitignore`와 같은 사고).
{% endhint %}

### Q9. 왜 컨테이너인가 — [1. 왜 컨테이너인가](lesson-1.md), 13일차

13일차에 포트폴리오를 **GitHub Pages**와 **내 WSL 서버** 두 곳에 올렸다.
컨테이너는 그중 어떤 한계를 해결하는가?

- A. Pages의 주소가 너무 길다
- B. Pages는 정적 파일만 올라가고, 내 서버 환경은 다른 PC로 옮길 수 없다
- C. Git의 용량 제한
- D. 브랜치를 더 많이 만들 수 있다

{% hint style="info" %}
정답 및 해설

정답: B

- GitHub Pages는 정적 호스팅이다. HTML, CSS, JS만 올라간다. DB, 로그인, 게시판은 올릴 수 없다.
- 내 WSL 서버는 무엇이든 올리지만 그 환경이 내 PC 안에만 있다. 옮기려면 12일차 여섯 단계를 처음부터 해야 한다.
- 컨테이너는 "프로그램과 그 환경"을 한 덩어리로 묶어 옮긴다. 그래서 둘 사이의 빈칸을 메운다.
- 증거는 5번 절의 옆자리 재현이다. 옆자리 저장소를 `clone`, `build`, `run` 세 줄로 내 PC에서 띄운 그 장면이다.
{% endhint %}

### Q10. Compose — [6. 환경을 코드로](lesson-6.md), 11일차

`compose.yaml`에서 `db` 서비스에는 `ports`를 쓰지 않았다. 그런데 `web`은 DB에 잘 접속한다. 왜인가?

- A. Docker가 모든 포트를 자동으로 연다
- B. 같은 Compose 안의 컨테이너는 서비스 이름(`db`)으로 내부 통신한다. 호스트에 포트를 열 필요가 없다
- C. `.env` 파일이 포트를 열어 준다
- D. `restart: unless-stopped` 때문이다

{% hint style="info" %}
정답 및 해설

정답: B

- Compose가 서비스마다 내부 DNS 이름을 만들어 준다(10일차 DNS = 이름 → 주소).
- `sudo ss -tulnp | grep 3306`이 아무것도 출력하지 않는다. 호스트에 문이 열리지 않았다는 뜻이다.
- 그래서 3번 절의 `ufw` 우회 문제도 생기지 않는다. `-p`를 쓰지 않는 것이 가장 안전하다(11일차 최소 개방의 완성).
- 비밀번호는 `.env`에 두고 `.gitignore`에 넣는다. 대신 `.env.example`을 커밋한다. "구조는 공개, 값은 비공개"이다.
{% endhint %}

## 합격 판정

| 번호 | 항목 | 기준 | 합격/불합격 |
|---|---|---|---|
| 1 | 정답 수 | 10문항 중 8문항 이상 | |
| 2 | Q4, Q10 | 모두 정답 | |

## 강의 메모

- Q4(방화벽 우회)는 무슨 일이 있어도 다룬다. 11, 12일차를 배운 반에서 이것이 빠지면 잘못된 보안 감각이 남는다.
- Q4와 Q10은 한 쌍이다. Q4가 문제이고 Q10이 답이다. 두 문항을 붙여서 짚으면 오늘 보안이 한 줄로 정리된다.
- Q3, Q6은 10, 11일차 회수 문제이다. 오늘 배운 것이 지난주와 어떻게 이어지는지 확인하는 자리이다.
- Q9, Q8, Q10 순서로 마무리하면 오늘의 서사가 그대로 복습된다(왜, 코드와 환경, 환경 전체).
- 15분이다. 시간이 모자라면 Q2, Q5, Q7은 눈으로만 읽고 Q4, Q9, Q10에 집중한다.
- 끝맺음 한 줄: "오늘 우리는 서버를 세운 것이 아니라 세우는 방법을 저장소에 적었다." 16일차 배포를 예고한다.
