# Ubuntu 환경 도커 설치

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-DKR-005-MP |
| 목적 | Ubuntu 22.04에 공식 저장소로 도커 엔진(Docker Engine)을 설치하고 동작을 확인한다 |
| 적용 대상 | Ubuntu 22.04 LTS, `sudo` 권한, 인터넷 연결 |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 페이지와 공식 문서의 절차를 정리한 것이며 이 문서로 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [도커 이미지 빌드](docker_build.md) | CLD-DKR-009-MP | 설치 후 이미지 빌드 |
| [RHEL 계열 도커 설치](docker-install-rhel.md) | CLD-DKR-006-MP | Ubuntu가 아닌 경우 |
| [Docker 공식 설치 문서 (Ubuntu)](https://docs.docker.com/engine/install/ubuntu/) | - | 외부 문서 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 설치 대상 서버 | Ubuntu 22.04 LTS | |
| 2 | 계정 | `sudo` 사용 가능 | |
| 3 | 네트워크 | `download.docker.com` 접속 가능 | |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 이 절차는 시스템에 패키지 저장소와 서비스를 추가한다. 운영 서버에서는 변경 승인을 받은 뒤 수행한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 운영체제 버전을 확인한다: `lsb_release -a` | `Release: 22.04`가 출력된다 |
| 2 | 도커가 이미 설치돼 있는지 확인한다: `docker --version` | `command not found`가 나온다. 버전이 나오면 설치된 것이므로 이 절차를 중단한다 |

## 5. 절차

### A. 도커 엔진 설치

1. (5-A-01) 패키지 목록을 갱신한다: `sudo apt-get update` → 결과: 오류 없이 끝난다.
2. (5-A-02) 필수 패키지를 설치한다: `sudo apt-get install ca-certificates curl gnupg` → 결과: 설치가 끝난다.
3. (5-A-03) 키 저장 디렉터리를 만든다: `sudo mkdir -m 0755 -p /etc/apt/keyrings`
4. (5-A-04) Docker GPG 키를 내려받아 등록한다: `curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg` → 결과: `/etc/apt/keyrings/docker.gpg` 파일이 생긴다.
5. (5-A-05) 저장소를 등록한다.

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

→ 결과: `/etc/apt/sources.list.d/docker.list` 파일이 생긴다.

{% hint style="info" %}
NOTE: 원본은 이 명령의 `arch`와 `VERSION_CODENAME` 부분에 따옴표 이스케이프(`\"`)가 들어 있었다. 공식 문서 형식으로 고쳤다. 미검증이다.
{% endhint %}

6. (5-A-06) 패키지 목록을 다시 갱신한다: `sudo apt-get update` → 결과: `download.docker.com` 저장소가 목록에 나온다.
7. (5-A-07) 도커 엔진과 관련 패키지를 설치한다: `sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin` → 결과: 설치가 끝난다.

### B. 일반 사용자에게 도커 사용 권한 부여 (선택)

{% hint style="danger" %}
WARNING: `docker` 그룹 구성원은 호스트의 root 권한과 사실상 같은 권한을 얻는다. 신뢰하는 사용자만 추가한다.
{% endhint %}

1. (5-B-01) 사용자를 `docker` 그룹에 추가한다: `sudo usermod -aG docker <사용자명>` → 결과: 오류 없이 끝난다.
2. (5-B-02) 로그아웃 후 다시 로그인한다 → 결과: 새 로그인 세션에서 그룹이 적용된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `docker --version` | 버전이 출력된다 | `Docker version`으로 시작하는 줄이 나온다 |
| 2 | `sudo docker run hello-world` | 테스트 이미지가 실행된다 | `Hello from Docker!`가 출력된다 |
| 3 | (구역 B 수행 시) `docker run hello-world` | `sudo` 없이 실행된다 | `Hello from Docker!`가 출력된다 |

## 7. 복구

1. (7-01) 도커 패키지를 제거한다: `sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`
2. (7-02) 저장소 파일을 제거한다: `sudo rm /etc/apt/sources.list.d/docker.list /etc/apt/keyrings/docker.gpg`
3. (7-03) 구역 B를 수행했다면 그룹에서 제거한다: `sudo gpasswd -d <사용자명> docker`

{% hint style="danger" %}
WARNING: 이미지, 컨테이너, 볼륨 데이터는 `/var/lib/docker`에 있다. 이 디렉터리를 삭제하면 모든 도커 데이터가 사라진다. 이 문서에서는 삭제하지 않는다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 설치 단계를 MP 형식으로 재작성. 저장소 등록 명령의 이스케이프를 공식 형식으로 정정, `docker` 그룹 추가(선택)와 복구 절차를 추가했다 |
