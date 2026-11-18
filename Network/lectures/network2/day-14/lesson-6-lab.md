# Compose 실습

> 상위: [14일차 · 도커 기초](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-14-013-MP |
| 목적 | `compose.yaml`로 웹과 DB를 한 번에 띄우고, 서비스 이름 통신과 DB 포트 비공개를 확인하며, `.env`와 `.env.example`로 비밀을 분리해 저장소에 올린다 |
| 적용 대상 | Windows 10/11의 WSL(Ubuntu 24.04), Docker Engine 29.x와 `docker compose` v2, 5번 절의 Dockerfile이 있는 저장소 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 명령을 정리한 것이며 `docker compose up` 이후는 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-6.md](lesson-6.md) | LEC-N2-14-006-DO | 환경을 코드로 |
| [lesson-5-lab.md](lesson-5-lab.md) | LEC-N2-14-012-MP | Dockerfile 실습 |
| [commands.md](commands.md) | LEC-N2-14-008-REF | 14일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 저장소 폴더 | 예: `~/myweb`, `Dockerfile`과 `site/`가 있다 | 5번 절의 결과 |
| 2 | `docker compose` | v2.x | `docker-compose-plugin`에 포함 |
| 3 | `mariadb` 이미지 | 공식 이미지 | 4번 절에서 받았다면 재사용된다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `.env`는 Git에 올리지 않는다. 구역 B에서 `.gitignore`에 `.env`를 넣은 뒤에 `git add`한다. 올린 비밀은 지워도 이력에 남는다.
{% endhint %}

{% hint style="danger" %}
WARNING: `docker compose down -v`는 쓰지 않는다. `-v`가 볼륨까지 지워 DB 데이터가 사라진다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 4번 절 실습의 `db`, 5번 절의 `mysite`, `friend` 컨테이너가 남아 있으면 이름과 포트가 겹친다. 구역 A에서 먼저 정리한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Compose가 있다 | `docker compose version`이 `v2.x`를 출력한다 |
| 2 | 저장소에 Dockerfile이 있다 | `cd ~/myweb && ls Dockerfile site/`가 오류 없이 나온다 |
| 3 | 8080번이 비어 있다 | 구역 A 이후 `docker ps`에 8080을 쓰는 컨테이너가 없다 |

## 5. 절차

### A. 정리와 `compose.yaml` 쓰기

1. (5-A-01) 남은 컨테이너를 지운다: `docker rm -f db mysite friend 2>/dev/null`
2. (5-A-02) 저장소로 이동한다: `cd ~/myweb`
3. (5-A-03) `nano compose.yaml`로 파일을 열고 아래 내용을 입력한 뒤 저장한다. 들여쓰기는 공백 2칸이다(탭 금지).

```yaml
services:
  web:
    build: .
    ports:
      - "8080:80"
    restart: unless-stopped

  db:
    image: mariadb
    environment:
      MARIADB_ROOT_PASSWORD: ${DB_PASSWORD}
      MARIADB_DATABASE: testdb
    volumes:
      - dbdata:/var/lib/mysql
    restart: unless-stopped

volumes:
  dbdata:
```

→ 결과: `db`에는 `ports`가 없다.

### B. 비밀 분리

1. (5-B-01) 비밀 파일을 만든다: `echo "DB_PASSWORD=<password>" > .env`
2. (5-B-02) Git 제외 목록에 넣는다: `echo ".env" >> .gitignore`
3. (5-B-03) 빈 양식을 만든다: `printf '# cp .env.example .env\nDB_PASSWORD=<password를 직접 정한다>\n' > .env.example`
4. (5-B-04) `git status`를 실행한다. → 결과: `.env`가 목록에 없고 `.env.example`, `compose.yaml`, `.gitignore`가 보인다.

### C. 띄우기

1. (5-C-01) 문법을 검사한다: `docker compose config` → 결과: 오류 없이 합쳐진 설정이 출력된다.
2. (5-C-02) 띄운다: `docker compose up -d`
3. (5-C-03) `docker compose ps`를 실행한다. → 결과: `web`과 `db`가 `Up`이다.
4. (5-C-04) `docker compose logs -f db`를 실행한다. → 결과: `ready for connections`가 보이면 `Ctrl+C`로 나온다.
5. (5-C-05) `curl localhost:8080`을 실행한다. → 결과: 내 포트폴리오가 나온다.

### D. 이름으로 통한다, 문은 안 열렸다

1. (5-D-01) `docker compose exec web sh -c "getent hosts db"`를 실행한다. → 결과: `db`의 컨테이너 IP가 나온다.
2. (5-D-02) `sudo ss -tulnp | grep 3306`을 실행한다. → 결과: 아무것도 나오지 않는다.

### E. Git에 올리고 내렸다 올려 보기

1. (5-E-01) 담는다: `git add compose.yaml .env.example .gitignore`
2. (5-E-02) 커밋한다: `git commit -m "Compose 추가 — 환경 전체를 저장소에"`
3. (5-E-03) 올린다: `git push`
4. (5-E-04) 내린다: `docker compose down` → 결과: 컨테이너와 네트워크가 삭제되고 볼륨은 남는다.
5. (5-E-05) 다시 올린다: `docker compose up -d` → 결과: 데이터가 그대로 있다.

### F. `clone` 한 줄 재현(선택)

1. (5-F-01) 새 폴더에 받는다: `cd ~ && git clone https://github.com/<아이디>/myweb.git demo && cd demo`
2. (5-F-02) 양식을 복사한다: `cp .env.example .env`
3. (5-F-03) `nano .env`로 비밀번호를 각자 정한다.
4. (5-F-04) 띄운다: `docker compose up -d` → 결과: 웹과 DB가 선다. `web`이 8080을 쓰므로 5-E의 스택을 먼저 `docker compose down`한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `docker compose ps` | 두 서비스 `Up` | `web`, `db`가 모두 보인다 |
| 2 | `docker compose exec web sh -c "getent hosts db"` | IP 출력 | 주소가 한 줄 나온다 |
| 3 | `sudo ss -tulnp \| grep 3306` | 출력 없음 | 3306 줄이 없다 |
| 4 | `git status` 또는 `git ls-files` | `.env`가 추적되지 않는다 | 목록에 `.env`가 없다 |
| 5 | `down` 후 `up -d` | 데이터 유지 | 볼륨 `dbdata`가 남아 있다 |

## 7. 복구

1. (7-01) 스택을 내린다: `docker compose down`
2. (7-02) 데이터까지 지우려면(데이터가 사라진다): `docker volume rm myweb_dbdata`. 볼륨 이름은 `docker volume ls`로 확인한다.
3. (7-03) `.env`를 지운다: `rm .env`
4. (7-04) `demo` 폴더를 지운다: `rm -rf ~/demo`

{% hint style="danger" %}
WARNING: `docker system prune -a`와 `docker compose down -v`는 쓰지 않는다. 전부 지우거나 DB 볼륨을 지운다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-6.md`와 `commands.md`의 STEP 6 실습 항목을 AMM 형식으로 재작성. 예제 비밀번호를 `<password>`로 바꿈 |
