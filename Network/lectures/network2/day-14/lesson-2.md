# 2. 설치와 첫 컨테이너 — 여섯 단계가 한 줄로

> 상위: [14일차 · 도커 기초](README.md) · 절차는 [설치와 첫 컨테이너 실습](lesson-2-lab.md), 대본은 [STEP 2](commands.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-14-002-DO |
| 유형 | D&O (개념) |
| 목적 | Docker 설치도 12일차 여섯 단계임을 보이고, `docker run` 한 줄이 여섯 단계의 ①②를 이미지에 넣은 것임을 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- Docker 공식 저장소로 Docker Engine을 설치하는 과정이 12일차 여섯 단계 그대로임을 확인한다.
- `sudo` 없이 `docker`를 쓰도록 설정하는 이유(소켓 파일과 그룹, 재로그인)를 안다.
- `docker run` 한 줄로 웹서버를 띄우고 여섯 단계와 대조한다.
- `pull`, `run`, `ps`의 관계를 안다.
- 포트 충돌을 직접 만나고 피한다.

## 1. 목적

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

①②③이 한 줄에 들어갔다. 어디로 갔는가? 이미지 안에 이미 들어 있다. 누군가 ①설치와 ②설정을 미리 해서 포장해 둔 것이 이미지이다.

## 2. 구성 요소

### 수업 시작 점검: WSL부터 확인한다

Docker는 systemd 서비스로 돌고 네트워크를 많이 건드린다. 그래서 먼저 세 가지를 본다.

```bash
ps -p 1 -o comm=                   # systemd 라고 나와야 한다 (12일차에 켜 뒀다)
ip route get 1.1.1.1 | head -1     # src 뒤가 내 WSL 주소. 오늘 계속 쓴다
sudo ufw status numbered           # 22, 80 이 열려 있다 (3번 절에서 쓴다)
```

| 보이는 주소 | WSL 모드 | 내 Windows에서 `localhost` | 옆자리에서 |
|---|---|---|---|
| `172.x.x.x` | NAT(기본) | 된다 | 안 된다 |
| `192.168.x.x`(Windows와 같음) | mirrored | 된다 | 된다 |

{% hint style="info" %}
NOTE: 검증은 「내 Windows 브라우저와 `localhost`」가 기본이다. 두 모드 모두에서 동작한다.
{% endhint %}

{% hint style="danger" %}
WARNING: `ps -p 1`이 systemd가 아니면 `/etc/wsl.conf`에 `[boot]`와 `systemd=true`를 넣고 Windows에서 `wsl --shutdown`을 실행한다. 그렇지 않으면 `systemctl`이 동작하지 않는다.
{% endhint %}

### 설치: 공식 저장소에서(이것도 여섯 단계이다)

오늘 설치하는 것은 Docker이다. 그런데 설치 순서가 어디서 본 것 같지 않은가?

| STEP | 하는 일 | 여섯 단계 |
|---|---|---|
| 1 | 충돌 패키지 정리. 우분투가 들고 있는 옛 버전과 섞이면 사고가 난다 | |
| 2 | 공식 저장소 등록(GPG 키, `docker.sources`) | ① 설치의 준비 |
| 3 | `docker-ce` 등 설치 | ① 설치 |
| 4 | `systemctl enable --now docker`, `is-active`, 버전 확인 | ③ 기동, ④ 확인 |

STEP 2는 13일차 GitHub 키 등록과 같은 "믿을 수 있는 출처" 작업이다. GPG 키를 먼저 받는 이유는 이 저장소에서 온 패키지가 진짜 Docker가 만든 것인지 확인하려는 것이다. 13일차 SSH 키와 같은 신뢰의 문제이다.

`$(. /etc/os-release && echo ...)`는 우분투 코드명을 자동으로 넣는다. 24.04이면 `noble`이다.

| 패키지 | 무엇인가 |
|---|---|
| `docker-ce` | 데몬(`dockerd`). 실제로 컨테이너를 돌리는 쪽 |
| `docker-ce-cli` | 명령어 `docker`. 우리가 치는 쪽 |
| `containerd.io` | 컨테이너 런타임(더 아래 층) |
| `docker-buildx-plugin` | 이미지 빌드 확장 → [5. Dockerfile](lesson-5.md) |
| `docker-compose-plugin` | `docker compose` 명령 → [6. 환경을 코드로](lesson-6.md) |

{% hint style="danger" %}
WARNING: `apt install docker.io`나 snap으로 설치하지 않는다. 버전이 낡고 `docker compose`가 없다. 공식 저장소를 쓴다.
{% endhint %}

Docker를 설치하는 과정도 ① 설치, ③ 기동, ④ 확인이다. 12일차의 여섯 단계는 Docker 자신에게도 적용된다. `apt install`만 하고 `is-active`를 보지 않으면 13일차 nginx처럼 "설치는 됐는데 안 돌고 있는" 상태를 놓친다.

### `sudo` 없이 쓰기: 재로그인이 필요하다

처음에 `docker ps`를 치면 다음 오류가 난다.

```
permission denied while trying to connect to the Docker daemon socket
```

10일차 권한 회수 지점이다. `docker` 명령은 `/var/run/docker.sock`이라는 소켓 파일을 통해 데몬과 말한다. 그 파일의 그룹이 `docker`라서 그 그룹에 속하지 않으면 읽지 못한다(`srw-rw---- 1 root docker`). 그룹은 로그인할 때 읽으므로 `usermod -aG docker $USER` 뒤에 반드시 로그아웃하고 다시 들어와야 한다.

{% hint style="warning" %}
CAUTION: `usermod`만 하고 재로그인을 하지 않으면 계속 `permission denied`이다. 급하면 `newgrp docker`로 그 터미널만 적용할 수도 있다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `docker` 그룹은 사실상 root 권한이다. 11일차 최소 권한 관점에서는 주의할 일이다. 실습 환경이라 쓴다.
{% endhint %}

### 첫 컨테이너: `hello-world`

`docker run hello-world`의 출력은 다음과 같다.

```
Unable to find image 'hello-world:latest' locally     ← 내 PC 에 없다
latest: Pulling from library/hello-world              ← Docker Hub 에서 받는다
Hello from Docker!
```

일어난 일은 세 단계이다.

```
 ① 로컬에 이미지가 있나?  없다
 ② 레지스트리(Docker Hub)에서 pull 한다      (13일차 git clone 과 같은 발상)
 ③ 그 이미지로 컨테이너를 만들어 실행
```

`hello-world`는 인사하고 바로 끝난다. 컨테이너는 할 일이 끝나면 멈춘다. VM과 다른 점이다. 컨테이너는 안에서 돌릴 프로세스가 살아 있는 동안만 산다. 그래서 `docker ps`에는 없고 `docker ps -a`에 `Exited (0)`으로 남는다.

### 웹서버 한 줄: `docker run -d -p 8080:80 --name web nginx`

| 조각 | 뜻 | 12일차 대응 |
|---|---|---|
| `run` | 이미지로 컨테이너를 만들어 실행 | ③ 기동 |
| `-d` | 백그라운드(detached) | `systemctl`처럼 뒤에서 돈다 |
| `-p 8080:80` | 호스트 8080 → 컨테이너 80 | 10일차 포트, [3. 핵심 명령과 포트](lesson-3.md) |
| `--name web` | 이름 붙이기(없으면 랜덤) | |
| `nginx` | 쓸 이미지 | ① 설치와 ② 설정이 이 안에 있다 |

`ss`에 `docker-proxy`가 보인다. Docker가 8080을 대신 듣고 컨테이너로 넘겨 준다는 뜻이다.

### 여섯 단계와 대조

| 단계 | 12일차(apt) | 오늘(docker) |
|---|---|---|
| ① 설치 | `apt install nginx` | 이미지 안에 있다 |
| ② 설정 | `nano /etc/nginx/...` | 이미지 안에 있다(바꾸려면 → [5. Dockerfile](lesson-5.md)) |
| ③ 기동 | `systemctl enable --now` | `docker run -d` |
| ④ 확인 | `systemctl status`, `ss` | `docker ps`, `ss` |
| ⑤ 개방 | `ufw allow 80/tcp` | `-p 8080:80` (주의 → [3. 핵심 명령과 포트](lesson-3.md)) |
| ⑥ 검증 | 브라우저 | 같다 |

순서는 그대로이다. 단지 ①②가 남이 미리 해 둔 것으로 바뀌었을 뿐이다. 그래서 12일차의 "서버 종류는 달라도 세우는 순서는 같다"가 오늘도 유효하다.

### 포트 충돌: 일부러 만나 본다(네 번째)

13일차에 세운 nginx가 80번을 쓰고 있다. 컨테이너를 `-p 80:80`으로 띄우면 다음 오류가 난다.

```
Error response from daemon: ... failed to bind host port for 0.0.0.0:80 ... address already in use
```

10일차 `python3 -m http.server`, 12일차 bind9, 13일차 nginx에 이어 네 번째이다. 한 포트에 한 프로그램이다. 그래서 8080을 썼다.

`-p 8080:80`에서 왼쪽이 호스트, 오른쪽이 컨테이너이다. "내 8080으로 오면 컨테이너의 80으로"라는 뜻이다. 11일차 PT 공유기의 포트포워딩과 같은 모양이다. 이때 [1번 절의 "공존"](lesson-1.md)이 보인다. 호스트 nginx(80)와 컨테이너 nginx(8080)가 지금 같이 살아 있다.

## 3. 동작 원리

1. `docker run`이 로컬 이미지를 찾는다.
2. 없으면 레지스트리에서 `pull`한다.
3. 이미지로 컨테이너를 만들고 `-p`가 있으면 호스트 포트를 컨테이너 포트로 넘기는 규칙을 만든다.
4. 컨테이너 안의 프로세스(nginx)가 살아 있는 동안 컨테이너가 `Up` 상태로 유지된다.
5. 프로세스가 끝나면 컨테이너가 `Exited`가 된다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| Docker Engine | 데몬(`dockerd`)과 명령(`docker`)을 합친 실행 환경 |
| 데몬(daemon) | 뒤에서 계속 도는 서비스 프로세스 |
| GPG 키 | 패키지가 진짜 출처에서 왔는지 확인하는 서명 키 |
| `docker.sock` | `docker` 명령이 데몬과 말하는 소켓 파일 |
| detached(`-d`) | 터미널을 붙잡지 않고 백그라운드로 실행 |
| 포트 매핑(`-p`) | 호스트 포트를 컨테이너 포트로 연결 |

## 그림 목록

| 번호 | 그림 | 설명 |
|---|---|---|
| 1 | 여섯 단계 대조표 | 12일차 표를 칠판에 다시 그리고 ①③④에 체크한다. 오른쪽 칸은 오늘 채운다 |
| 2 | 포트 매핑 | `-p 8080:80`의 왼쪽(호스트)과 오른쪽(컨테이너) |

## 강의 메모

- 설치가 오늘의 최대 병목이다. `apt` 미러가 느리면 5~10분이 걸린다. STEP 0 몸풀기 중에 STEP 2의 저장소 등록과 `apt update`까지 미리 돌려 두면 체감이 줄어든다.
- "Docker 설치도 여섯 단계"를 꼭 짚는다. 12일차 표를 칠판에 다시 그려 놓고 ①③④에 체크한다.
- `docker run -d -p 8080:80 nginx`는 설명 전에 먼저 치게 한다. 1초 만에 뜨는 것을 보고 나서 설명하면 집중도가 다르다.
- `usermod -aG docker` 후 재로그인을 반드시 시킨다. 안 하면 반 전체가 `permission denied`로 멈춘다. 재로그인 전에 `ls -l /var/run/docker.sock`을 보여 주면 "왜 그룹이 필요한지"가 10일차 권한으로 설명된다.
- 포트 충돌은 일부러 낸다. 네 번째 만남이라 이제는 학생이 먼저 원인을 말한다.
- AI 활용: `docker run`의 옵션을 해석하게 시킨다("이 명령에서 `-d`와 `-p`가 뭘 하나?"). 10일차 검증 원칙대로 문서와 대조한다.
- 설치가 끝까지 안 되는 PC가 나오면 2인 1조로 묶고, `docker ps`가 되는 짝의 화면으로 따라간다. 설치에 수업 전체를 쓰지 않는다.
- 소요는 35분(설치 20, 실습 15)이다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `docker ps`에는 없는데 `docker ps -a`에는 있는 컨테이너는 어떤 상태이고 왜 그렇게 되는가?
- [ ] 여섯 단계 중 ①설치와 ②설정은 어디로 갔는가? 설정을 바꾸고 싶으면 어떻게 해야 하겠는가?
- [ ] `sudo` 없이 `docker`가 되게 한 뒤 재로그인이 필요한 이유는 무엇인가?
