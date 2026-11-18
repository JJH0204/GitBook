# 설치와 첫 컨테이너 실습

> 상위: [14일차 · 도커 기초](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-14-009-MP |
| 목적 | WSL(Ubuntu)에 Docker Engine을 공식 저장소로 설치하고, `hello-world`와 `nginx` 컨테이너를 띄워 포트 매핑과 포트 충돌을 확인한다 |
| 적용 대상 | Windows 10/11의 WSL(Ubuntu 24.04), systemd 활성, 인터넷 연결, Docker Engine 29.x |
| 소요 시간 | 약 35분(설치 20분 포함) |
| 확인 상태 | 미검증 (원본에 "2026-10-17 자료 조사 기준, 직접 실행 아님"이라는 기록이 있으며, 이 문서도 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-2.md](lesson-2.md) | LEC-N2-14-002-DO | 설치와 첫 컨테이너 |
| [commands.md](commands.md) | LEC-N2-14-008-REF | 14일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | WSL(Ubuntu) | 24.04 | 12일차부터 쓰는 환경. Docker Desktop은 쓰지 않는다 |
| 2 | 인터넷 | 저장소와 이미지 내려받기 | `apt` 미러가 느리면 10분 넘게 걸린다 |
| 3 | 13일차 nginx | 80번 사용 중 | 구역 F의 포트 충돌에 쓴다. 그대로 둔다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `apt install docker.io`나 snap으로 설치하지 않는다. 버전이 낡고 `docker compose`가 없다. 구역 B의 공식 저장소를 쓴다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 구역 C의 `usermod` 뒤에는 반드시 로그아웃 후 다시 로그인한다. 그렇지 않으면 `permission denied`가 계속된다.
{% endhint %}

{% hint style="info" %}
NOTE: 설치 전에 Windows PowerShell에서 `wsl --shutdown` 후 `wsl --export Ubuntu D:\wsl-backup.tar`로 WSL을 백업해 두면 복구가 쉽다. 되돌릴 때는 `wsl --import`를 쓴다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | systemd가 켜져 있다 | `ps -p 1 -o comm=`가 `systemd`를 출력한다. 아니면 `/etc/wsl.conf`에 `[boot]`, `systemd=true`를 넣고 Windows에서 `wsl --shutdown` |
| 2 | WSL 주소를 안다 | `ip route get 1.1.1.1 \| head -1`의 `src` 뒤 주소를 적는다 |
| 3 | 방화벽 상태를 안다 | `sudo ufw status numbered`에 22, 80이 보인다 |
| 4 | 13일차 nginx가 80번을 쓴다 | `sudo ss -tulnp \| grep ':80 '`에 `nginx`가 보인다 |

## 5. 절차

### A. 충돌 패키지 정리

1. (5-A-01) 충돌 패키지를 제거한다.

```bash
for p in docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc; do
  sudo apt remove -y $p 2>/dev/null
done
```

→ 결과: 오류 없이 끝난다(없는 패키지는 무시된다).

### B. 공식 저장소 등록

1. (5-B-01) 필수 패키지를 설치한다: `sudo apt update && sudo apt install -y ca-certificates curl`
2. (5-B-02) 키 폴더를 만든다: `sudo install -m 0755 -d /etc/apt/keyrings`
3. (5-B-03) GPG 키를 받는다: `sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc`
4. (5-B-04) 키를 읽을 수 있게 한다: `sudo chmod a+r /etc/apt/keyrings/docker.asc`
5. (5-B-05) 저장소 파일을 만든다.

```bash
sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

6. (5-B-06) 목록을 갱신한다: `sudo apt update` → 결과: `download.docker.com` 줄이 오류 없이 보인다.

### C. 설치, 기동, 확인

1. (5-C-01) 설치한다: `sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`
2. (5-C-02) 기동한다: `sudo systemctl enable --now docker`
3. (5-C-03) 상태를 확인한다: `systemctl is-active docker` → 결과: `active`.
4. (5-C-04) 버전을 확인한다: `docker --version` → 결과: `Docker version 29.x.x`.
5. (5-C-05) Compose를 확인한다: `docker compose version` → 결과: `Docker Compose version v2.x.x`.

### D. `sudo` 없이 쓰기

1. (5-D-01) `docker ps`를 실행한다. → 결과: `permission denied while trying to connect to the Docker daemon socket`.
2. (5-D-02) 소켓의 그룹을 확인한다: `ls -l /var/run/docker.sock` → 결과: `srw-rw---- 1 root docker`.
3. (5-D-03) 그룹에 추가한다: `sudo usermod -aG docker $USER`
4. (5-D-04) 로그아웃한다: `exit`
5. (5-D-05) 터미널을 새로 열고 그룹을 확인한다: `id -nG | tr ' ' '\n' | grep docker` → 결과: `docker`가 보인다.
6. (5-D-06) `docker ps`를 실행한다. → 결과: 오류 없이 빈 표가 나온다.

### E. 첫 컨테이너

1. (5-E-01) `docker run hello-world`를 실행한다. → 결과: `Pulling from library/hello-world`와 `Hello from Docker!`가 보인다.
2. (5-E-02) `docker images`를 실행한다. → 결과: `hello-world` 이미지가 보인다.
3. (5-E-03) `docker ps`를 실행한다. → 결과: 비어 있다.
4. (5-E-04) `docker ps -a`를 실행한다. → 결과: `hello-world`가 `Exited (0)`으로 보인다.

### F. 웹서버 한 줄과 포트 충돌

1. (5-F-01) 웹서버를 띄운다: `docker run -d -p 8080:80 --name web nginx`
2. (5-F-02) `docker ps`를 실행한다. → 결과: `web`이 `Up` 상태이다.
3. (5-F-03) 포트를 확인한다: `sudo ss -tulnp | grep 8080` → 결과: `docker-proxy`가 8080을 듣고 있다.
4. (5-F-04) `curl localhost:8080`을 실행한다. → 결과: `Welcome to nginx!`가 보인다.
5. (5-F-05) Windows 브라우저에서 `http://localhost:8080`을 연다. → 결과: nginx 환영 페이지가 보인다.
6. (5-F-06) 80번으로 하나 더 띄운다: `docker run -d -p 80:80 --name web2 nginx` → 결과: `address already in use` 오류가 나온다.
7. (5-F-07) 실패한 컨테이너를 확인한다: `docker ps -a | grep web2` → 결과: `Created` 상태로 남아 있다.
8. (5-F-08) 정리한다: `docker rm web2`
9. (5-F-09) 80번 사용자를 확인한다: `sudo ss -tulnp | grep ':80 '` → 결과: 호스트 nginx가 쓰고 있다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `systemctl is-active docker` | `active` | 문자열이 그대로 보인다 |
| 2 | `docker ps`(재로그인 후, `sudo` 없이) | 오류 없는 표 | `permission denied`가 없다 |
| 3 | `curl localhost:8080` | nginx 환영 페이지 | `Welcome to nginx!`가 보인다 |
| 4 | 호스트 nginx(80)와 컨테이너 nginx(8080) | 둘 다 응답 | `curl -I localhost`와 `curl -I localhost:8080`이 모두 `200`이다 |

## 7. 복구

1. (7-01) 실습 컨테이너를 지운다: `docker rm -f web`
2. (7-02) `hello-world`를 지운다: `docker rm $(docker ps -aq -f status=exited)`
3. (7-03) 이미지를 지운다: `docker rmi hello-world`

{% hint style="warning" %}
CAUTION: 이후 실습에서 `web` 컨테이너를 계속 쓴다. 이 절의 7-01은 하루 실습이 모두 끝난 뒤에 실행한다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-2.md`와 `commands.md`의 STEP 2 실습 항목을 AMM 형식으로 재작성 |
