# [생성형 AI] Docker Compose 파일 작성법

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-DKR-021-REF |
| 유형 | REF (표) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | Compose 파일의 최상위 키, 서비스 키, 자주 쓰는 명령을 찾는다 |
| 확인 상태 | 미검증 (일반 지식과 Compose 공식 문서의 알려진 문법을 정리한 것이며 이 환경에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 기존 쪽이 다루지 않은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 파일과 최상위 키

파일 이름은 `compose.yaml`을 권장하고 `docker-compose.yml`도 인식한다. 최신 Compose는 최상위 `version` 키를 쓰지 않는다(무시되며 경고가 나올 수 있다).

| 최상위 키 | 설명 |
|---|---|
| `services` | 실행할 컨테이너 정의. 필수 |
| `volumes` | 명명된 볼륨 정의 |
| `networks` | 사용자 정의 네트워크 정의. 생략하면 프로젝트 전용 기본 네트워크를 만든다 |
| `secrets`, `configs` | 비밀값과 설정 파일 정의 |

## 2. 서비스 키

| 키 | 설명 | 예 |
|---|---|---|
| `image` | 사용할 이미지 | `image: nginx:stable` |
| `build` | 이미지를 Dockerfile로 빌드한다 | `build: ./app` |
| `ports` | 포트 게시 | `"127.0.0.1:8080:80"` |
| `environment` | 환경 변수 | `MARIADB_DATABASE: app` |
| `env_file` | 환경 변수 파일 | `.env` |
| `volumes` | 볼륨·바인드 마운트 | `db-data:/var/lib/mysql` |
| `depends_on` | 시작 순서 | `db` |
| `restart` | 재시작 정책 | `unless-stopped` |
| `healthcheck` | 상태 검사 명령 | `test`, `interval`, `retries` |
| `command` | 이미지의 기본 명령을 덮어쓴다 | |

`depends_on`은 기본적으로 컨테이너가 시작되기만 기다리고 서비스가 준비되기를 기다리지 않는다. 준비까지 기다리려면 `healthcheck`를 정의하고 `depends_on`에 `condition: service_healthy`를 쓴다.

## 3. 예

같은 Compose 프로젝트의 서비스는 서비스 이름으로 서로 접속한다(`db`).

```yaml
services:
  web:
    image: nginx:stable
    ports:
      - "127.0.0.1:8080:80"
    depends_on:
      db:
        condition: service_healthy
  db:
    image: mariadb:11
    environment:
      MARIADB_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
    volumes:
      - db-data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 10s
      retries: 5
volumes:
  db-data:
```

`${DB_ROOT_PASSWORD}`는 같은 폴더의 `.env` 파일에서 읽는다. `.env`는 저장소에 올리지 않는다.

{% hint style="warning" %}
CAUTION: 비밀번호를 `compose.yaml`에 직접 적지 않는다. 파일을 공유하거나 커밋하면 노출된다. `healthcheck.sh`는 mariadb 공식 이미지의 도구이며, 이미지 버전에 따라 다를 수 있으므로 확인이 필요하다.
{% endhint %}

## 4. 명령

| 명령 | 설명 |
|---|---|
| `docker compose up -d` | 서비스를 만들고 백그라운드로 실행한다 |
| `docker compose ps` | 서비스 상태를 본다 |
| `docker compose logs -f <서비스>` | 로그를 실시간으로 본다 |
| `docker compose exec <서비스> <명령>` | 실행 중인 컨테이너에서 명령을 실행한다 |
| `docker compose config` | 변수를 풀어 최종 설정을 출력한다. 문법 검사에 쓴다 |
| `docker compose down` | 컨테이너와 네트워크를 삭제한다. 볼륨은 남는다 |
| `docker compose down -v` | 볼륨까지 삭제한다 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [도커 컨테이너 이미지화와 Compose 공유](docker-hub-compose-share.md) | CLD-DKR-016-MP | Compose 실습 |
| [도커 볼륨과 데이터 보존](docker-volume.md) | CLD-DKR-020-DO | 볼륨 |
| [도커 네트워크](docker-network.md) | CLD-DKR-019-DO | 네트워크 |
