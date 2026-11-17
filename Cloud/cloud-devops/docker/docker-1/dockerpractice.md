# Docker Compose 워드프레스 실습

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-DK1-001-MP |
| 목적 | Docker Compose로 워드프레스 5.x와 MariaDB 컨테이너를 실행하고, 두 이미지를 Docker Hub에 업로드한다 |
| 적용 대상 | Docker Engine과 Docker Compose v2(`docker compose`)가 설치된 Linux 또는 Docker Desktop. 호스트 80번 포트와 3306번 포트가 비어 있어야 한다. Docker Hub 계정이 필요하다 |
| 소요 시간 | 약 30분 |
| 확인 상태 | 미검증 (원본 페이지의 설정과 명령을 정리한 것이며 이 문서로 다시 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 확인 상태가 미검증이다. 실행 결과가 다르면 작성자 메모 대신 이 문서의 개정 이력에 기록한다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [docker_install.md](../docker_install.md) | - | Ubuntu 환경 도커 설치 |
| [docker-hub-image-share.md](../docker-hub-image-share.md) | - | 도커 허브 이미지 공유 실습 |
| [docker_hub.md](../docker_hub.md) | - | 도커 허브 활용 가이드 |
| [docker_commend.md](../docker_commend.md) | - | 도커 필수 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Docker Engine, Docker Compose | Compose v2 | `docker compose version`으로 확인한다 |
| 2 | Docker Hub 계정 | 무료 계정 | 구역 C에서 사용 |
| 3 | 웹 브라우저 | 최신 버전 | 워드프레스 화면 확인용 |
| 4 | 이미지 | `wordpress:5.0.3-apache`, `mariadb:latest` | 구역 A 실행 시 내려받는다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 이 실습의 `docker-compose.yml`은 MariaDB 3306번 포트를 호스트에 공개한다. 외부에서 접근 가능한 서버에서는 `ports`의 `"3306:3306"` 항목을 삭제한다. 비밀번호는 `<꺾쇠>` 값을 직접 정한 값으로 바꿔 쓴다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `wordpress:5.0.3-apache`는 오래된 버전이며 보안 패치가 없다. 인터넷에 공개하지 않고 실습용으로만 쓴다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Docker가 실행 중이다 | `docker info`가 오류 없이 서버 정보를 출력한다 |
| 2 | 80번 포트가 비어 있다 | `ss -ltn 'sport = :80'`의 출력에 LISTEN 행이 없다 (Windows: `netstat -ano \| findstr :80`) |
| 3 | 3306번 포트가 비어 있다 | `ss -ltn 'sport = :3306'`의 출력에 LISTEN 행이 없다 |
| 4 | 작업 폴더를 만든다 | `mkdir wp-practice && cd wp-practice` 후 `pwd`가 새 폴더를 가리킨다 |

## 5. 절차

### A. Compose로 컨테이너 실행

1. (5-A-01) 작업 폴더에 `docker-compose.yml` 파일을 만들고 아래 내용을 저장한다. 이 파일은 컨테이너 여러 개의 설정을 한 번에 정의한다. → 결과: 파일이 저장된다.

{% code title="docker-compose.yml" %}
```yml
services:
  wordpress:
    image: wordpress:5.0.3-apache
    ports:
      - "80:80"
    depends_on:
      - mariadb
    environment:
      WORDPRESS_DB_HOST: mariadb
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: <워드프레스 DB 비밀번호>
      WORDPRESS_DB_NAME: wordpress
    restart: always

  mariadb:
    image: mariadb:latest
    ports:
      - "3306:3306"
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: <DB 루트 비밀번호>
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: <워드프레스 DB 비밀번호>
    restart: always

volumes:
  db_data: {}
```
{% endcode %}

2. (5-A-02) 두 `<워드프레스 DB 비밀번호>` 자리에 같은 값을 넣고 `<DB 루트 비밀번호>`를 정해 넣는다. → 결과: 파일에 `<`로 시작하는 자리 표시자가 남아 있지 않다.
3. (5-A-03) 컨테이너를 백그라운드로 실행한다: `docker compose up -d` → 결과: 이미지를 내려받은 뒤 `wordpress`와 `mariadb` 컨테이너가 `Started`로 표시된다.
4. (5-A-04) 실행 상태를 확인한다: `docker compose ps` → 결과: 두 서비스의 상태가 `running`(또는 `Up`)이다.

### B. 워드프레스 접속과 페이지 작성

1. (5-B-01) 브라우저에서 `http://localhost`를 연다. → 결과: 워드프레스 설치 화면(언어 선택)이 나타난다.
2. (5-B-02) 설치 화면에서 사이트 제목, 관리자 이름, 비밀번호, 이메일을 입력하고 설치를 마친다. → 결과: 로그인 화면이 나타난다.
3. (5-B-03) 관리자 계정으로 로그인해 대시보드를 연다. → 결과: 대시보드가 나타난다.
4. (5-B-04) 대시보드에서 글을 하나 작성해 발행한다. → 결과: `http://localhost`에서 발행한 글이 보인다.

### C. 이미지에 태그를 달아 Docker Hub에 업로드

{% hint style="info" %}
NOTE: 5-C-02의 태그는 내려받은 이미지에 이름을 붙이는 작업이다. 5-B-04에서 작성한 글은 `db_data` 볼륨의 DB에 저장되므로 이 이미지에 포함되지 않는다. 원본 페이지의 "변경 사항을 포함한 이미지"가 이 절차로 충족되는지는 확인이 필요하다.
{% endhint %}

1. (5-C-01) Docker Hub에 로그인한다: `docker login` → 결과: `Login Succeeded`가 출력된다.
2. (5-C-02) 두 이미지에 태그를 단다. → 결과: 오류 없이 끝난다.

```
docker image tag mariadb:latest <Docker Hub 사용자명>/dockerhub_test:mariadb
docker image tag wordpress:5.0.3-apache <Docker Hub 사용자명>/dockerhub_test:wordpress
```

3. (5-C-03) 두 이미지를 업로드한다. → 결과: 각 명령이 `digest: sha256:...`으로 끝난다.

```
docker image push <Docker Hub 사용자명>/dockerhub_test:mariadb
docker image push <Docker Hub 사용자명>/dockerhub_test:wordpress
```

4. (5-C-04) 이미지 이름을 확인한다: `docker images` → 결과: `<Docker Hub 사용자명>/dockerhub_test`의 `mariadb`, `wordpress` 태그가 목록에 보인다.
5. (5-C-05) 브라우저에서 Docker Hub의 `<Docker Hub 사용자명>/dockerhub_test` 저장소를 연다. → 결과: 두 태그가 표시된다.

{% hint style="info" %}
NOTE: 원본 작성자의 메모: 애플리케이션(app)만 Docker Hub에 직접 올려 관리하는 방식은 비효율적이다. 애플리케이션이 돌아가는 환경(OS)까지 이미지로 구성해 Hub에 올려 관리하는 쪽이 낫다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `docker compose ps` | 두 서비스가 실행 중이다 | 상태가 모두 `running` |
| 2 | 브라우저에서 `http://localhost` | 발행한 글이 보인다 | 글 제목이 표시된다 |
| 3 | `docker images` | 태그를 단 이미지가 있다 | `mariadb`, `wordpress` 태그 2개 |
| 4 | Docker Hub 저장소 화면 | 업로드한 태그가 있다 | 태그 2개 표시 |

## 7. 복구

{% hint style="danger" %}
WARNING: `docker compose down -v`는 `db_data` 볼륨을 삭제한다. 5-B-04에서 작성한 글과 워드프레스 설정이 모두 사라지며 되돌릴 수 없다. 데이터를 남기려면 `-v` 없이 7-01만 수행한다.
{% endhint %}

1. (7-01) 컨테이너를 중지하고 삭제한다: `docker compose down` → 결과: 두 컨테이너와 기본 네트워크가 `Removed`로 표시된다. 볼륨은 남는다.
2. (7-02) 볼륨까지 지운다: `docker compose down -v` → 결과: `db_data` 볼륨이 삭제된다.
3. (7-03) 로컬 태그를 지운다: `docker image rm <Docker Hub 사용자명>/dockerhub_test:mariadb <Docker Hub 사용자명>/dockerhub_test:wordpress` → 결과: 태그가 `Untagged`로 표시된다. Docker Hub에 올린 이미지는 웹 화면에서 직접 삭제한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM 형식으로 재작성. 비밀번호와 Docker Hub 계정명을 자리 표시자로 바꾸고, 워드프레스 접속 절차와 정리 절차를 추가했다. Excalidraw 참조 문구와 평문 메모를 정리했다 |
