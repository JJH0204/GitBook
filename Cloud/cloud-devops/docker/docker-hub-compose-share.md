# 도커 컨테이너 이미지화와 Compose 공유

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-DKR-016-MP |
| 목적 | 실행 중인 컨테이너 여러 개를 이미지로 저장해 Docker Hub에 올리고, `docker-compose.yml`로 같은 환경을 다른 사용자가 실행하게 한다 |
| 적용 대상 | 도커 엔진과 Docker Compose v2(`docker compose`)가 설치된 환경, Docker Hub 계정 |
| 소요 시간 | 약 30분 |
| 확인 상태 | 미검증 (원본 `docker_hub.md` 후반부를 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [도커 허브 활용 가이드](docker_hub.md) | CLD-DKR-015-MP | 로그인, 올리기, 내려받기 |
| [도커 허브 이미지 공유 실습](docker-hub-image-share.md) | CLD-DKR-017-MP | 컨테이너 하나를 공유하는 경우 |
| [도커 필수 명령어](docker_commend.md) | CLD-DKR-007-REF | `commit`, `tag` |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 도커 엔진 | 설치 완료 | |
| 2 | Docker Compose | v2(`docker compose`) | v1 설치 환경은 `docker-compose`로 읽는다 |
| 3 | Docker Hub 계정 | `<사용자명>` | |
| 4 | 실행 중인 컨테이너 3개 | WAF(ModSecurity CRS), PHP-FPM 웹, MariaDB | 원본 예시 구성이다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `docker commit`은 컨테이너 파일 시스템 전체를 이미지로 만든다. 컨테이너 안에 비밀번호, 설정 파일, 개인 정보가 있으면 이미지에 포함되고, 공개 저장소에 올리면 누구나 내려받을 수 있다. 올리기 전에 내용을 확인하고 필요하면 비공개 저장소를 쓴다.
{% endhint %}

{% hint style="danger" %}
WARNING: 볼륨에 저장된 데이터(예: 데이터베이스 파일)는 `docker commit`에 포함되지 않는다. 데이터까지 공유해야 하면 별도로 내보내야 한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 저장할 컨테이너의 ID를 확인한다: `docker ps` | 컨테이너 3개의 ID가 보인다 |
| 2 | Docker Hub에 로그인한다: `docker login` | `Login Succeeded`가 출력된다 |

## 5. 절차

### A. 컨테이너를 이미지로 저장

1. (5-A-01) WAF 컨테이너를 저장한다: `docker commit <WAF 컨테이너 ID> <사용자명>/modsecurity-crs:latest` → 결과: 이미지 ID(sha256)가 출력된다.
2. (5-A-02) PHP-FPM 웹 컨테이너를 저장한다: `docker commit <웹 컨테이너 ID> <사용자명>/fakerweb:latest` → 결과: 이미지 ID가 출력된다.
3. (5-A-03) MariaDB 컨테이너를 저장한다: `docker commit <DB 컨테이너 ID> <사용자명>/mariadb-fakerdb:10.5` → 결과: 이미지 ID가 출력된다.
4. (5-A-04) 이미지를 확인한다: `docker images` → 결과: 세 이미지가 보인다.
5. (5-A-05) 이름이나 태그를 바꿔야 하면 `docker tag <원본 이미지> <사용자명>/<이름>:<태그>`를 실행한다.

### B. Docker Hub에 올리기

1. (5-B-01) 로그인 상태를 확인한다: `docker login` → 결과: `Login Succeeded`가 출력된다.
2. (5-B-02) WAF 이미지를 올린다: `docker push <사용자명>/modsecurity-crs:latest` → 결과: `digest: sha256:...`이 출력된다.
3. (5-B-03) 웹 이미지를 올린다: `docker push <사용자명>/fakerweb:latest` → 결과: 같은 형식으로 끝난다.
4. (5-B-04) DB 이미지를 올린다: `docker push <사용자명>/mariadb-fakerdb:10.5` → 결과: 같은 형식으로 끝난다.

### C. `docker-compose.yml` 작성

1. (5-C-01) 공유할 디렉터리에 `docker-compose.yml`을 만든다: `vi docker-compose.yml`
2. (5-C-02) 아래 내용을 저장한다.

```yaml
services:
  waf:
    image: <사용자명>/modsecurity-crs:latest
    ports:
      - "8081:80"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 30s
      timeout: 10s
      retries: 5

  web:
    image: <사용자명>/fakerweb:latest
    ports:
      - "8080:80"

  db:
    image: <사용자명>/mariadb-fakerdb:10.5
    environment:
      MYSQL_ROOT_PASSWORD: <DB 루트 비밀번호>
      MYSQL_DATABASE: fakerdb
```

{% hint style="info" %}
NOTE: 원본의 `version: '3.9'` 줄은 Compose v2에서 쓰지 않는 항목이라 삭제했다. 원본의 `root_password` 값은 비밀번호이므로 `<DB 루트 비밀번호>`로 바꿨다. 실제 값은 `.env` 파일이나 실행 시 환경 변수로 넘기고, 그 파일은 공유하지 않는다. 미검증이다.
{% endhint %}

### D. 다른 사용자의 실행

1. (5-D-01) 도커를 설치한다: [Ubuntu 환경 도커 설치](docker_install.md)(CLD-DKR-005-MP)를 따른다.
2. (5-D-02) 공유받은 `docker-compose.yml`이 있는 디렉터리로 이동한다.

{% hint style="warning" %}
CAUTION: `ports`의 `8081:80`, `8080:80`은 호스트의 8081, 8080번 포트를 모든 네트워크 인터페이스에 연다. 내 PC에서만 쓰려면 `127.0.0.1:8081:80`처럼 주소를 붙인다.
{% endhint %}

3. (5-D-03) 서비스를 실행한다: `docker compose up -d` → 결과: `waf`, `web`, `db` 컨테이너가 `Started`로 출력된다. Compose v1 환경에서는 `docker-compose up -d`를 쓴다.
4. (5-D-04) 상태를 확인한다: `docker compose ps` → 결과: 세 서비스가 `running`이다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 브라우저로 `http://localhost:8081/` 접속 | WAF가 응답한다 | 페이지가 열린다 |
| 2 | 브라우저로 `http://localhost:8080/` 접속 | 웹 애플리케이션이 응답한다 | 페이지가 열린다 |
| 3 | `docker compose ps` | 세 서비스가 실행 중이다 | 상태가 모두 `running`이다 |

데이터베이스는 Compose가 만든 내부 네트워크에서 다른 서비스가 연결한다. 호스트 포트를 열지 않았다.

## 7. 복구

1. (7-01) 서비스를 중지하고 컨테이너를 삭제한다: `docker compose down` → 결과: 컨테이너와 네트워크가 삭제된다. 볼륨은 남는다.

{% hint style="danger" %}
WARNING: `docker compose down -v`는 볼륨과 그 안의 데이터를 삭제한다. 데이터가 필요하면 `-v`를 쓰지 않는다.
{% endhint %}

2. (7-02) 로컬 이미지를 삭제한다: `docker rmi <사용자명>/modsecurity-crs:latest <사용자명>/fakerweb:latest <사용자명>/mariadb-fakerdb:10.5`

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | `docker_hub.md` 후반부의 컨테이너 커밋·Compose 공유를 독립 MP로 분리. 컨테이너 ID와 계정명을 자리표시자로 바꾸고, DB 비밀번호를 `<DB 루트 비밀번호>`로 바꿨다. `version` 키 삭제, `docker compose up -d` 사용, 이미지 내용·볼륨 WARNING과 포트 개방 CAUTION을 추가했다 |
