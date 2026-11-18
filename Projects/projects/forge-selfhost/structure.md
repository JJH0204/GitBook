# forge 구성 지도: compose, 네트워크, 볼륨

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-FRG-101-REF |
| 유형 | REF (구성 요소·네트워크·볼륨 목록) |
| 목적 | Gitea와 Plane 두 compose 스택의 서비스, 네트워크 경계, 볼륨 배치를 보이고 같은 구조를 따라 만들 수 있게 한다 |
| 확인 상태 | 미검증 (형상 보관본 compose 파일과 구축 기록을 읽고 쓴 것이며 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="warning" %}
WARNING: 공개 문서라서 도메인, IP, 계정, 비밀번호, 키, 호스트 포트 번호는 쓰지 않았다. 해당 위치는 `<값 생략>`으로 표시한다.
{% endhint %}

## 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [README.md](README.md) | - | 자체 호스팅 개발 서버 (forge) |
| [process.md](process.md) | PRJ-FSH-002-DO | 도입 과정 |
| [backup.md](backup.md) | PRJ-FRG-102-MP | forge 백업 파이프라인 |

## 이 영역이 하는 일

한 대의 Windows 호스트 위에서 WSL2 배포판 하나를 띄우고, 그 안의 Docker로 두 스택을 독립된 compose 프로젝트로 실행한다. 한 스택은 코드 저장소(Gitea + PostgreSQL)이고 다른 하나는 이슈 관리(Plane 공식 스택 13개 서비스)이다. 두 스택은 서로 다른 compose 네트워크에 있으며 서로 통신하지 않는다. 호스트 밖으로는 필요한 포트만 연다.

## 구성 요소

### 호스트 계층

| 계층 | 역할 | 출처 |
|---|---|---|
| Windows 11 호스트 | 24시간 가동. 작업 스케줄러(점검, 헬스체크, 오프사이트), 방화벽, VPN 클라이언트 서비스 실행 | `PLAN.md` 1절 |
| WSL2 배포판 1개 | systemd를 PID 1로 쓰고 Docker를 네이티브로 실행(Docker Desktop 미사용). 가상 디스크는 SSD에 둠 | `PLAN.md` Phase 1, 9 |
| `/srv/gitea`, `/srv/plane`, `/srv/backup` | 스택별 compose 파일과 데이터, 백업 산출물 작업 폴더 | `PLAN.md` 1절 |
| WSL 내부 스크립트 3종 | 기동(`selfhost-up.sh`), 정상 종료(`selfhost-down.sh`), 백업(`selfhost-backup.sh`) | `PLAN.md` Phase 6 |

{% hint style="info" %}
NOTE: WSL 내부 스크립트 3종의 본문은 형상 보관본에 없다(Windows 쪽 스크립트만 보관됨). 동작 설명은 구축 기록 기준이다.
{% endhint %}

### Gitea 스택 (`gitea/docker-compose.yml`)

| 서비스 | 이미지 | 메모리 상한 | 호스트에 연 포트 | 데이터 볼륨 |
|---|---|---|---|---|
| `db` | `postgres:17.10-alpine` | 2g | 없음 | `/srv/gitea/pgdata` |
| `gitea` | `gitea/gitea:1.27.1` | 4g | 웹 1개, SSH 1개(컨테이너 22번을 호스트의 다른 번호로 매핑) `<값 생략>` | `/srv/gitea/data` |

- 이미지 태그는 모두 버전 고정이다. `:latest`를 쓰지 않는다.
- `gitea`는 `depends_on`의 `condition: service_healthy`로 `db`의 `pg_isready` 헬스체크(10초 간격, 최대 12회)가 통과한 뒤 시작한다.
- 두 서비스 모두 `restart: always`이다.
- 비밀번호는 compose 파일에 쓰지 않고 `.env`의 변수(`POSTGRES_PASSWORD`)로 주입한다. `.env`는 소유자만 읽도록 둔다(0600).
- 컨테이너 시간대는 호스트 시간대 파일을 읽기 전용으로 마운트해 맞춘다.

### Plane 스택 (`plane/docker-compose.yaml`)

| 서비스 | 이미지 | 역할 |
|---|---|---|
| `web`, `space`, `admin` | `makeplane/plane-frontend`, `-space`, `-admin` | 화면(워크스페이스, 공개 공간, 관리자 콘솔) |
| `live` | `makeplane/plane-live` | 실시간 편집 서버 |
| `api` | `makeplane/plane-backend` | REST API |
| `worker`, `beat-worker` | `makeplane/plane-backend` | 비동기 작업, 주기 작업 |
| `migrator` | `makeplane/plane-backend` | DB 마이그레이션(`on-failure`로 재시작, 끝나면 종료) |
| `plane-db` | `postgres:15.7-alpine` | 데이터베이스 |
| `plane-redis` | `valkey/valkey:7.2.11-alpine` | 캐시, 세션 |
| `plane-mq` | `rabbitmq:3.13.6-management-alpine` | 작업 큐 |
| `plane-minio` | `minio/minio:latest` | 첨부파일 저장(S3 호환) |
| `proxy` | `makeplane/plane-proxy` | 앞단 리버스 프록시. 호스트에 포트를 여는 유일한 서비스 |

- 앱 계열 이미지 태그는 `APP_RELEASE` 변수로 한 번에 고정한다. 구축 기록은 자동 추적(`stable`) 대신 특정 릴리스를 명시했다.
- 공통 환경변수는 YAML 앵커(`x-db-env`, `x-redis-env`, `x-app-env` 등)로 한 번 정의하고 `<<: [*app-env, *db-env, ...]`로 서비스에 합친다.
- 각 서비스의 인스턴스 수는 `*_REPLICAS` 변수로 조절한다(기본 1).
- 프록시의 HTTP/HTTPS 포트는 `LISTEN_HTTP_PORT`, `LISTEN_HTTPS_PORT` 변수로 바꾼다. 구축 기록에는 기본 80/443을 바꿔 쓴 것으로 되어 있다.

{% hint style="warning" %}
CAUTION: `plane-minio`만 `latest` 태그다. 다른 이미지는 고정이므로 이 서비스가 재생성될 때 버전이 달라질 수 있다. 원본 compose 그대로이며 의도인지 원본에 없음, 확인 필요.
{% endhint %}

## 네트워크 구조

```
[팀원 기기]  --(VPN 오버레이, 노드 공유)-->  Windows 호스트 <값 생략>
                                               |  방화벽: 서비스 포트를 VPN 대역에서만 허용
                                               v
                                  WSL2 배포판 (Docker)
          ┌──────────────────────────┴──────────────────────────┐
   compose 프로젝트 A (gitea)                      compose 프로젝트 B (plane)
   [gitea] --- 내부망 --- [db]                     [proxy] -> web / space / admin / live / api
      |                                                              |
   호스트 포트: 웹 1, SSH 1                         worker / beat-worker / migrator
                                                   plane-db / plane-redis / plane-mq / plane-minio
                                                   (전부 내부망, 호스트 포트 없음)
                                                   호스트 포트: 프록시 HTTP(S)
```

| 경계 | 규칙 | 근거 |
|---|---|---|
| 인터넷 | 포트포워딩 0건. 서비스는 VPN 오버레이 안에서만 접근 | `PLAN.md` 0절 |
| 호스트 방화벽 | 서비스 포트를 VPN 대역에서만 허용 | `PLAN.md` 1절 |
| 팀원 접근 | 팀원을 VPN 네트워크에 넣지 않고 노드 하나만 공유(단방향). ACL로 서비스 포트만 허용 | `PLAN.md` 0절, Phase 5 |
| 데이터베이스·캐시·큐·스토리지 | 호스트로 포트를 발행하지 않음. compose 내부 네트워크에서만 도달 | `gitea/docker-compose.yml` 주석, `PLAN.md` Phase 4 검증 |
| Gitea 가입 | `DISABLE_REGISTRATION`, `REQUIRE_SIGNIN_VIEW`를 모두 켬(VPN 안이어도 이중 잠금) | `gitea/docker-compose.yml` |

{% hint style="info" %}
NOTE: 두 compose 파일에는 `networks:` 항목이 없다. 각 프로젝트의 기본 네트워크가 자동 생성되며, 프로젝트가 다르므로 두 스택은 분리된다.
{% endhint %}

## 볼륨 구조

| 스택 | 대상 | 종류 | 위치(컨테이너 안) | 백업 대상 |
|---|---|---|---|---|
| Gitea | 저장소, LFS, 설정(`app.ini`) | 호스트 바인드 마운트 `/srv/gitea/data` | `/data` | 예(스냅샷) |
| Gitea | PostgreSQL 데이터 | 호스트 바인드 마운트 `/srv/gitea/pgdata` | `/var/lib/postgresql/data` | 예(덤프) |
| Plane | PostgreSQL | 이름 있는 볼륨 `pgdata` | `/var/lib/postgresql/data` | 예(덤프) |
| Plane | 첨부파일 | 이름 있는 볼륨 `uploads` | `/export` | 예(`/srv/plane` 경로 백업에 포함되는지는 확인 필요) |
| Plane | Valkey, RabbitMQ | 이름 있는 볼륨 `redisdata`, `rabbitmq_data` | `/data`, `/var/lib/rabbitmq` | 원본에 없음, 확인 필요 |
| Plane | 프록시 설정·인증서 | 이름 있는 볼륨 `proxy_config`, `proxy_data` | `/config`, `/data` | 원본에 없음 |
| Plane | 앱 로그 | 이름 있는 볼륨 `logs_api`, `logs_worker`, `logs_beat-worker`, `logs_migrator` | `/code/plane/logs` | 불필요 |

- Gitea는 바인드 마운트라서 호스트 경로를 그대로 백업할 수 있다. Plane은 이름 있는 볼륨이라서 도커가 관리하는 경로에 있고, 구축 기록의 백업 명령은 `/srv/plane` 경로를 대상으로 한다. 이 경로 아래에 볼륨이 있는지는 원본에 없음, 확인 필요.
- 가상 디스크는 구축 후 가장 낡은 HDD에서 SSD로 옮겼다. 옮길 때는 복사, 해시 대조, 레지스트리 경로 변경 순으로 하고 원본을 남겨 롤백할 수 있게 했다(`PLAN.md` Phase 9).

## 데이터 흐름

```
Gitea  요청 -> gitea 컨테이너 -> db(PostgreSQL)   메타데이터(계정, 이슈, 설정)
                             -> /data            저장소(git), LFS 객체, app.ini

Plane  요청 -> proxy -> web/space/admin(화면), api(REST), live(실시간)
        api -> plane-db  메타데이터(워크스페이스, 이슈)
            -> plane-redis  캐시
            -> plane-mq  <- worker / beat-worker  비동기·주기 작업
            -> plane-minio  첨부파일
```

## 핵심 설정 해설

### 1. 메모리 폭주를 컨테이너 안에 가둔다 (`gitea/docker-compose.yml`)

```yaml
  gitea:
    image: gitea/gitea:1.27.1
    ...
    mem_limit: 4g
```

과거 NAS에서 대용량 저장소가 서버 메모리를 소진한 사고가 있었다. 그래서 `mem_limit`으로 폭주가 호스트 전체가 아니라 해당 컨테이너만 죽이도록 한다(`db`는 2g).

### 2. git 서버 정책은 `app.ini`의 `[git.config]`에 둔다 (`gitea/app.ini.excerpt`)

```ini
[git.config]
pack.threads = 1
pack.windowMemory = 128m
pack.deltaCacheSize = 64m
core.bigFileThreshold = 16m
receive.maxInputSize = 536870912

[cron.repo_health_check]
ENABLED = false
```

- `receive.maxInputSize`(512MiB)로 대용량 비-LFS push를 서버가 거부한다. 구축 기록에서 600MB push는 거부되고 50MB push는 통과한 것으로 되어 있다.
- 파일 주석에 따르면 Gitea는 `HOME_PATH`의 gitconfig만 읽는다. 컨테이너 안의 다른 gitconfig에 쓴 값은 서버가 무시한다. 구축 중 이 실수로 한도가 적용되지 않은 채 600MB push가 통과했다.
- 일일 저장소 자체 점검(`repo_health_check`)을 끈다. 과거 메모리 사고의 트리거였다. 환경변수로 점이 들어간 섹션 이름을 만들면 존재하지 않는 섹션이 생기므로 `app.ini`에 직접 쓴다(구축 기록).

### 3. 비밀값은 compose 밖에 둔다

- Gitea는 `.env`, Plane은 `plane.env`에 둔다. 형상 보관본은 `env.sample`, `plane.env.sample`이며 값은 마스킹되어 있다.
- Plane의 `DATABASE_URL`, `AMQP_URL` 기본값에는 기본 자격증명이 들어 있다. 비밀번호만 바꾸고 URL을 안 바꾸면 연결이 깨진다. 비밀번호에 `@ : / #`가 들어가도 URL이 깨지므로 영숫자만 쓴다(구축 기록).

## 따라 만들기

확인 상태: 미검증. 각 단계 뒤에 기대 결과를 적었다.

1. WSL2 배포판을 만들고 systemd를 켠 뒤 Docker를 설치한다. 기대 결과: `docker info`가 응답하고 재부팅 후에도 `docker.service`가 자동 기동한다.
2. `/srv/gitea`에 `docker-compose.yml`과 `.env`를 둔다(비밀번호는 무작위 값, `.env` 권한 0600, 이미지 태그 고정). 기대 결과: `docker compose config`가 오류 없이 출력된다.
3. `docker compose up -d`로 기동하고 웹 설치 마법사에서 관리자 계정을 만든다. 기대 결과: `db`가 healthy가 된 뒤 `gitea`가 시작하고, 웹과 SSH로 clone이 된다.
4. `app.ini`에 `[git.config]`와 `[cron.repo_health_check]`를 직접 쓰고 재시작한다. 기대 결과: `grep -E '^\[' app.ini`로 섹션 이름이 의도대로 보이고, 한도를 넘는 push가 거부된다.
5. `/srv/plane`에 Plane 공식 compose와 `plane.env`를 두고 `APP_RELEASE`를 고정한다. 기본 자격증명과 두 URL을 함께 교체하고 프록시 포트를 정한다. 기대 결과: 서비스가 모두 Up이고 `migrator`는 종료 상태이다.
6. 호스트에 발행된 포트를 확인한다. 기대 결과: Gitea 웹·SSH와 Plane 프록시 포트만 보이고 DB, 캐시, 큐, 스토리지 포트는 보이지 않는다.
7. 호스트 방화벽을 VPN 대역에서만 허용하도록 설정하고, 다른 기기에서 접속과 차단을 모두 시험한다. 기대 결과: VPN 안에서는 접속되고 밖에서는 접속되지 않는다.

## 알려진 한계·주의

- 호스트가 단일 장비이고 단일 디스크에 가상 디스크가 있다. 디스크 장애는 서비스 정지로 이어지며, 복구는 백업에 의존한다([백업 파이프라인](backup.md)).
- WSL 배포판은 유휴 상태가 되면 종료된다. 구축 기록은 상주 프로세스로 배포판을 붙잡는 방식을 썼다(세부는 [도입 과정](process.md)).
- Postgres 메이저 버전이 스택마다 다르다(Gitea 17, Plane 15). 복원은 같은 메이저 버전에 해야 한다.
- Plane compose의 `plane-minio`는 `latest` 태그이다.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 최초 작성 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 데이터베이스와 스토리지 포트를 호스트에 열지 않기로 한 이유를 내 말로 적어 보자.
- [ ] Gitea와 Plane을 하나의 compose가 아니라 두 프로젝트로 나눠 둔 것이 운영에서 무엇을 쉽게 했는지 적어 보자.
- [ ] 설정을 파일에 썼는데 적용되지 않았던 경험을 한 가지 적어 보자.
