# 도커 컨테이너 실행과 관리

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-DKR-008-MP |
| 목적 | Nginx 이미지로 컨테이너를 실행하고, 상태 확인, 중지, 재시작, 삭제까지 수행한다 |
| 적용 대상 | 도커 엔진이 설치된 Linux, `docker` 명령 사용 가능, 호스트의 80번 포트가 비어 있음 |
| 소요 시간 | 약 15분 |
| 확인 상태 | 미검증 (원본 `dockertheory.md`의 명령 메모를 절차로 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [Ubuntu 환경 도커 설치](docker_install.md) | CLD-DKR-005-MP | 도커 설치 |
| [도커 핵심 이론](dockertheory.md) | CLD-DKR-002-DO | 컨테이너 수명 주기 |
| [도커 필수 명령어](docker_commend.md) | CLD-DKR-007-REF | 옵션 표 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 도커 엔진 | 설치 완료 | `docker --version`이 출력된다 |
| 2 | 이미지 | `nginx:stable` | Docker Hub에서 내려받는다 |
| 3 | 브라우저 또는 `curl` | | 접속 확인용 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: `-p 80:80`은 호스트의 80번 포트를 모든 네트워크 인터페이스에 연다. 같은 네트워크의 다른 기기가 이 서비스에 접속할 수 있다. 내 PC에서만 확인하려면 5-A-03에서 `-p 127.0.0.1:80:80`을 쓴다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 도커가 동작한다 | `docker --version`이 버전을 출력한다 |
| 2 | 80번 포트가 비어 있다 | `ss -tln` 출력에 `:80`이 없다 |
| 3 | 같은 이름의 컨테이너가 없다 | `docker ps -a`에 `linux-web`이 없다 |

## 5. 절차

### A. 이미지 받기와 컨테이너 실행

1. (5-A-01) 이미지를 내려받는다: `docker image pull nginx:stable` → 결과: `Status: Downloaded newer image for nginx:stable`이 출력된다.
2. (5-A-02) 이미지 목록을 확인한다: `docker image ls` → 결과: `nginx`가 `stable` 태그로 보인다.
3. (5-A-03) 컨테이너를 백그라운드로 실행한다: `docker container run --name linux-web -d -p 80:80 nginx:stable` → 결과: 컨테이너 ID(긴 문자열)가 출력된다.

{% hint style="info" %}
NOTE: 옵션 의미는 다음과 같다. `--name linux-web`은 컨테이너 이름, `-d`는 백그라운드 실행, `-p 80:80`은 `<호스트 포트>:<컨테이너 포트>` 연결이다. `-d`를 빼면 컨테이너의 출력이 현재 터미널에 붙어 터미널을 쓸 수 없다.
{% endhint %}

### B. 상태 확인

1. (5-B-01) 실행 중인 컨테이너를 확인한다: `docker container ls` → 결과: `linux-web`이 `Up` 상태로 보인다.
2. (5-B-02) 접속을 확인한다: `curl http://localhost:80` → 결과: Nginx 기본 페이지 HTML이 출력된다.
3. (5-B-03) 자원 사용량을 확인한다: `docker stats linux-web` → 결과: CPU, 메모리 사용량이 갱신되며 출력된다. `Ctrl+C`로 끝낸다.

### C. 중지와 재시작

1. (5-C-01) 컨테이너를 중지한다: `docker container stop linux-web` → 결과: `linux-web`이 출력된다.
2. (5-C-02) 중지 상태를 확인한다: `docker container ls -a` → 결과: `linux-web`의 상태가 `Exited`다.
3. (5-C-03) 컨테이너를 시작한다: `docker container start linux-web` → 결과: `docker container ls`에 `Up` 상태로 나타난다. 컨테이너 ID는 중지 전과 같다.

### D. 컨테이너 삭제

{% hint style="danger" %}
WARNING: 컨테이너를 삭제하면 볼륨에 두지 않은 컨테이너 안의 데이터가 사라진다. `docker rm -f`는 실행 중인 컨테이너도 즉시 삭제한다. 삭제 전에 `docker ps -a`로 대상 이름을 확인한다.
{% endhint %}

1. (5-D-01) 컨테이너를 중지한다: `docker container stop linux-web`
2. (5-D-02) 컨테이너를 삭제한다: `docker container rm linux-web` → 결과: `linux-web`이 출력된다. 실행 중이면 삭제가 거부된다.
3. (5-D-03) 이미지가 남았는지 확인한다: `docker image ls` → 결과: `nginx:stable`이 그대로 있다. 컨테이너를 삭제해도 이미지는 삭제되지 않는다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 5-B-01 후 `docker container ls` | `linux-web`이 실행 중이다 | 상태가 `Up`이다 |
| 2 | 5-B-02 `curl http://localhost:80` | 웹 페이지가 응답한다 | HTML이 출력된다 |
| 3 | 5-D-02 후 `docker container ls -a` | 컨테이너가 없다 | `linux-web`이 목록에 없다 |

## 7. 복구

1. (7-01) 삭제한 컨테이너를 다시 만든다: 5-A-03을 다시 수행한다. 컨테이너 안에서 바뀐 데이터는 복구되지 않는다.
2. (7-02) 이미지를 삭제했다면 5-A-01로 다시 내려받는다.
3. (7-03) 포트 충돌(`port is already allocated`)이 나면 5-A-03의 호스트 포트를 `8080`처럼 비어 있는 값으로 바꾼다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | `dockertheory.md`의 실행·중지·삭제 명령 메모를 독립 MP로 분리. 포트 개방 CAUTION과 삭제 WARNING, 확인·복구 절차를 추가했다. 원본의 `latest` 태그 대신 `nginx:stable`을 사용했다 |
