# 14일차 · 도커 기초

> 2단계 · 서버 구축 및 활용. 상위: [네트워크 2](../README.md)
> 이전: [13일차 · Git 과 GitHub](../day-13/README.md) · 다음: [15일차 · 쿠버네티스 입문](../day-15/README.md)

## 개요

13일차에 포트폴리오를 두 군데에 올렸다.

- ① GitHub Pages: 주소가 생겼다. 그런데 HTML, CSS, JS만 올라간다.
- ② 내 WSL의 nginx: 무엇이든 올릴 수 있다. 그런데 그 환경은 내 PC 안에만 있다.

"①은 게시판을 못 올리고, ②는 옮길 수가 없습니다. 오늘은 그 사이를 메웁니다."

오늘의 답은 이렇다. 환경을 코드로 적어 Git에 넣고, 어디서든 한 줄로 되살린다.

```bash
docker run -d -p 8080:80 nginx        # 12일차 여섯 단계가 한 줄로
docker compose up -d                  # 웹 + DB 환경 전체가 한 줄로
```

| 질문 | 오늘의 답 | 노트 |
|---|---|---|
| 왜 컨테이너를 쓰나? | 재현, 속도, 청소, 공존. 특히 "제 컴퓨터에선 됐는데요"가 사라진다 | 1 |
| VM과 뭐가 다른가? | 커널을 공유한다. 9일차 하이퍼바이저와 비교한다 | 1 |
| 여섯 단계가 한 줄이 된다고? | 이미지에 ①②가 들어 있다(Docker 설치 자체도 여섯 단계이다) | 2 |
| 밖에서 어떻게 접속하나? | `-p 8080:80`. 10일차 포트 회수 | 3 |
| 방화벽은? | Docker는 `ufw`를 우회한다(대조 실험으로 확인) | 3 |
| 컨테이너를 지우면 데이터는? | 사라진다. 그래서 볼륨과 바인드 마운트 | 4 |
| 내 포트폴리오를 담으려면? | Dockerfile을 13일차 저장소에 넣는다. 옆자리 저장소를 `clone`, `build`, `run` 해 본다 | 5 |
| 웹 + DB 환경 전체는? | `compose.yaml`, 비밀은 `.env`, DB는 문을 열지 않는다 | 6 |

## 오늘의 목표

- 컨테이너를 쓰는 이유를 네 가지로 들고 13일차의 두 한계와 연결해 설명한다.
- 컨테이너와 가상머신의 차이를 커널 관점에서 설명한다(9일차 회수).
- 이미지, 컨테이너, 레지스트리 세 단어를 구분한다.
- 공식 저장소로 Docker Engine을 설치하고, 그 과정이 12일차 여섯 단계임을 확인한다.
- `run`, `ps`, `logs`, `exec`, `stop`, `rm`으로 컨테이너를 다룬다.
- `-p` 포트 매핑을 이해하고, Docker가 방화벽을 우회하는 것을 대조 실험으로 확인한다.
- 볼륨과 바인드 마운트로 데이터를 살려 두고 13일차 폴더를 컨테이너에 연결한다.
- Dockerfile로 내 포트폴리오를 이미지로 만들어 Git 저장소에 넣는다.
- Compose로 웹 + DB 환경을 파일 하나에 적고 `clone` 후 `up -d`로 재현한다.

## 문서 목록과 읽는 순서

실습 중에는 0번(명령어 대본)을 화면에 띄워 둔다.

| 순서 | Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|---|
| 1 | LEC-N2-14-008-REF | REF | [0. 14일차 실습 명령어 — 수업 흐름 그대로 (이어치기 대본)](commands.md) | STEP 0~6 명령 대본, 안 될 때 점검표 |
| 2 | LEC-N2-14-001-DO | D&O | [1. 왜 컨테이너인가 — 그리고 VM 과 무엇이 다른가](lesson-1.md) | 이유 네 가지, VM 비교, 이미지와 컨테이너와 레지스트리 |
| 3 | LEC-N2-14-002-DO | D&O | [2. 설치와 첫 컨테이너 — 여섯 단계가 한 줄로](lesson-2.md) | 설치도 여섯 단계, `docker` 그룹, `run`, 포트 충돌 |
| 4 | LEC-N2-14-009-MP | MP | [설치와 첫 컨테이너 실습](lesson-2-lab.md) | Docker 설치, `hello-world`, `nginx` |
| 5 | LEC-N2-14-003-DO | D&O | [3. 핵심 명령과 포트 — 그리고 방화벽 함정](lesson-3.md) | 명령 대응표, `exec`, `-p`, `ufw` 우회 원리와 대응 |
| 6 | LEC-N2-14-010-MP | MP | [핵심 명령과 방화벽 대조 실습](lesson-3-lab.md) | 명령 짝 맞추기, 대조 실험, 로컬 바인딩 |
| 7 | LEC-N2-14-004-DO | D&O | [4. 데이터와 볼륨 — 지우면 사라진다](lesson-4.md) | 컨테이너 레이어, 바인드 마운트, 볼륨, 정리 |
| 8 | LEC-N2-14-011-MP | MP | [볼륨과 DB 실습](lesson-4-lab.md) | 사라지는 데이터, 포트폴리오 연결, MariaDB 볼륨 |
| 9 | LEC-N2-14-005-DO | D&O | [5. Dockerfile — 내 포트폴리오를 이미지로](lesson-5.md) | Dockerfile, `.dockerignore`, 저장소 관리, 재현성 |
| 10 | LEC-N2-14-012-MP | MP | [Dockerfile 실습](lesson-5-lab.md) | 빌드, 실행, `push`, 옆자리 저장소 재현 |
| 11 | LEC-N2-14-006-DO | D&O | [6. 환경을 코드로 — Compose 로 한 줄 재현](lesson-6.md) | `compose.yaml`, 서비스 이름 통신, `.env`와 `.env.example` |
| 12 | LEC-N2-14-013-MP | MP | [Compose 실습](lesson-6-lab.md) | 웹 + DB 기동, DB 포트 비공개, `down`과 `up` |
| 13 | LEC-N2-14-007-INS | INS | [7. 오늘의 문제](lesson-7.md) | 문제 10문항 |

## 오늘의 진행: 4시간(240분)

| 순서 | 내용 | 이론 | 실습 | 누적 |
|---|---|---|---|---|
| 0 | 몸풀기: WSL 점검, 13일차 결과물 둘, 설치 미리 걸기 | 5분 | 5분 | 10분 |
| 1 | 왜 컨테이너인가 + VM 비교(판서) | 30분 | | 40분 |
| 2 | 설치(공식 저장소), 첫 컨테이너, 여섯 단계와 대조 | 10분 | 25분 | 75분 |
| | 쉬는 시간 10분 | | | 85분 |
| 3 | 핵심 명령, `-p` 포트, `ufw` 대조 실험 | 15분 | 25분 | 125분 |
| 4 | 볼륨, 13일차 폴더 연결, DB 컨테이너 | 10분 | 15분 | 150분 |
| | 쉬는 시간 10분 | | | 160분 |
| 5 | Dockerfile, 내 포트폴리오를 이미지로, 옆자리 재현 | 10분 | 25분 | 195분 |
| 6 | Compose, 환경 전체를 저장소에 | 5분 | 15분 | 215분 |
| 7 | 오늘의 문제 | 15분 | | 230분 |

{% hint style="info" %}
NOTE: 필수는 2, 3, 5번이다. 시간이 모자라면 6(강사 시연), 4(DB는 시연만), 1(압축) 순으로 줄인다.
{% endhint %}

{% hint style="danger" %}
WARNING: 3번의 "Docker가 `ufw`를 우회한다"는 11, 12일차를 배운 우리 반에서 반드시 짚는다. 안 하면 잘못된 보안 감각이 남는다.
{% endhint %}

{% hint style="info" %}
NOTE: 5번의 옆자리 저장소 띄우기는 오늘의 주장을 증명하는 장면이다. 시간을 남겨 둔다.
{% endhint %}

## 오늘의 실습 환경: WSL + Docker Engine(apt 공식 저장소)

```
   Windows  ──localhost──▶  WSL (Ubuntu 24.04)
                                 ├─ nginx            : 80      ← 13일차에 세운 것 (그대로 둔다)
                                 └─ Docker Engine (29.x)
                                      ├─ web  : 8080 → 80      (내 포트폴리오)
                                      └─ db   : 포트 없음        (Compose 내부에서만)
```

| 항목 | 내용 |
|---|---|
| Docker Desktop | 쓰지 않는다. 12일차부터 쓰던 WSL 안에 Docker Engine을 직접 설치한다. 리눅스 서버에서 하는 모습 그대로이고 12, 13일차 환경(사용자, SSH 키, 저장소)을 그대로 쓸 수 있다 |
| 13일차 nginx | 80번을 쓰고 있다. 컨테이너는 8080으로 띄워 포트 충돌을 직접 보고 피한다 |

### 수업 시작 전 점검: 세 줄

```bash
ps -p 1 -o comm=                   # systemd 여야 한다 (아니면 /etc/wsl.conf 에 [boot] systemd=true)
ip route get 1.1.1.1 | head -1     # src 뒤가 내 WSL 주소. 오늘 검증에 쓴다
sudo ufw status numbered           # 22, 80 (3번 절 대조 실험의 출발점)
```

### WSL 모드에 따른 차이: 오늘은 `curl`로 통일한다

| | NAT(`172.x`, 기본) | mirrored(`192.168.x`) |
|---|---|---|
| Windows `http://localhost:8080`(`-p 8080:80`) | 된다 | 된다 |
| 옆자리에서 | 안 된다 | 된다 |
| Windows `localhost:8080`(`-p 127.0.0.1:8080:80`) | 안 열린다 | 열릴 수 있다 |
| WSL `curl http://<내 IP>:8080`(로컬 바인딩) | refused | refused |

{% hint style="danger" %}
WARNING: mirrored 모드는 Windows와 WSL이 `127.0.0.1`을 공유한다. 그래서 "로컬에만 열었는데 Windows에서 보이는" 것이 정상이다. 검증 기준은 `curl http://<내 IP>:8080`이다. 두 모드에서 같은 결과가 나온다.
{% endhint %}

{% hint style="info" %}
NOTE: Docker 설치 전에 Windows에서 `wsl --shutdown` 후 WSL을 백업해 두면 마음이 편하다. `wsl --export Ubuntu D:\wsl-backup.tar`로 만들고 되돌릴 때는 `wsl --import`를 쓴다.
{% endhint %}

## AI 활용

- Dockerfile, `compose.yaml` 초안, `docker run` 옵션 해석, 오류 메시지 읽기에 쓴다.
- 10일차 [AI 검증 원칙](../day-10/lesson-5.md)을 그대로 따른다. 초안은 AI, 확인은 공식 문서이다.

{% hint style="danger" %}
WARNING: `docker system prune -a`, `docker compose down -v`, `docker rm -f $(docker ps -aq)`가 AI의 답에 있으면 3초 멈춘다. 전부 지운다.
{% endhint %}

## 강의 메모

- 도입: 학생이 13일차 결과물 두 개(Pages 주소, `http://localhost`)를 동시에 열어 놓고 시작한다. "정적만 올라가는 곳"과 "옮길 수 없는 내 환경" 사이의 빈칸이 오늘이다.
- 오늘의 회수는 다음과 같다.
  1. 9일차 호스트, 게스트, 하이퍼바이저 → 컨테이너와 VM(그림을 나란히 그린다).
  2. 12일차 여섯 단계 → `docker run` 한 줄, Docker 설치 자체도 여섯 단계.
  3. 10일차 포트, 소켓, 권한(소켓 파일) → `-p 8080:80`, `ss -tulnp`, `docker.sock` 그룹.
  4. 11, 12일차 `ufw` → Docker는 이것을 우회한다(그리고 6번 절에서 `-p`를 쓰지 않는 것으로 해결한다).
  5. 12일차 파일 공유(NFS, Samba) → 바인드 마운트("복사가 아니라 연결").
  6. 12일차 MariaDB 직접 설치 → DB 컨테이너(몇 분 대 몇 초).
  7. 13일차 Git 저장소, `.gitignore`, Pages → Dockerfile, `.dockerignore`, `.env`.
- 최대 병목은 여섯 가지이다.
  1. 설치 시간. `apt` 미러가 느리면 10분 넘게 걸린다. STEP 0에서 저장소 등록까지 미리 돌려 두고 그 사이 판서한다.
  2. `sudo` 없이 `docker`를 쳐서 `permission denied`. `usermod -aG docker` 후 재로그인이 필수이다.
  3. 포트 충돌. 13일차 nginx가 80을 점유한다. 오히려 좋은 교재이다(10, 12, 13일차에 이어 네 번째).
  4. WSL에 systemd가 켜져 있어야 `systemctl`이 먹는다(12일차에 썼으니 이미 켜져 있다).
  5. mirrored 모드 학생의 `127.0.0.1` 바인딩 혼란. `curl http://<내 IP>:8080` 기준으로 통일한다.
  6. Pages가 깨질 수 있다. 5번 절에서 `site/`로 옮길 때 설정의 폴더를 `/site`로 바꾸게 안내한다.
- 발표용 Excalidraw 그림은 아직 없다. VM 대 컨테이너, 여섯 단계 대조표, 포트 매핑은 판서로 그린다.

## 자료 조사로 확인한 것(2026-10-17, 직접 실행 아님)

교실 PC에서 실행 검증은 아직 하지 않았다. 아래는 공식 문서와 릴리스 노트 기준으로 맞춘 내용이다.

1. 설치 방식을 공식 저장소(apt)로 바꿨다. 종전 대본의 `get.docker.com` 스크립트 대신이다. 현재 Docker 공식 문서는 키를 `/etc/apt/keyrings/docker.asc`에 두고 `/etc/apt/sources.list.d/docker.sources`(deb822 형식)를 쓴다. 패키지는 `docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`이며 Compose는 이 플러그인에 포함이라 따로 설치하지 않는다. 지원 목록에 Ubuntu 24.04(noble)가 있다. `docker.io`와 snap은 쓰지 않는다.
2. 버전: Docker Engine 최신은 29.x 계열(2026-10 기준 29.9.1)이다. 수업에서 `docker --version`이 29.x로 나오는 것이 정상이다.
3. `ufw` 우회는 여전히 사실이고 설계상 그렇다. Docker 문서가 공개 포트의 트래픽이 방화벽 규칙이 적용되기 전에 라우팅된다고 명시한다. 제대로 막는 자리는 `DOCKER-USER` 체인이고, 입문 단계의 답은 `-p 127.0.0.1:...` 또는 `-p`를 쓰지 않는 것(6번 절)이다.
4. 종전 노트의 오류를 고쳤다. "`127.0.0.1` 바인딩 데모는 NAT, mirrored 둘 다 성립한다"는 틀렸다. mirrored 모드는 Windows와 WSL이 `127.0.0.1`을 공유하므로(마이크로소프트 문서) Windows 브라우저에서 열린다. 검증을 `curl http://<내 IP>:8080`으로 바꿨다(두 모드 공통).
5. MariaDB 이미지: `MARIADB_ROOT_PASSWORD`는 필수이다(없으면 컨테이너가 죽는다). 클라이언트 명령은 `mariadb`이다(최근 이미지에서 `mysql` 이름 제거). 초기화 중에는 접속이 안 되므로 `ready for connections` 대기가 필요하다.
6. Compose 파일에 `version:`을 쓰지 않는다. v2에서 무의미해져 `version is obsolete` 경고만 난다. 파일명은 `compose.yaml`이다.
7. 남은 미검증(교실 PC에서 확인할 것)은 다음과 같다.
   - `apt` 설치 후 데몬 기동. WSL에서 `systemctl is-active docker`가 `active`인지 본다(실패 시 `journalctl -u docker`, `ip_forward` 확인).
   - `ufw` 대조 실험의 실제 결과. 호스트 8000이 막히고 컨테이너 8080이 열리는지 본다(특히 mirrored 모드 PC).
   - `docker build`, `compose up` 실행, 옆자리 저장소 `clone` 후 빌드.
   - 이번 준비에서 명령 실행 검증은 하지 않았다(자료 조사로 대체). 교실 전날 리허설을 권한다.
