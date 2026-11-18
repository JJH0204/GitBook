# 6. 환경을 코드로 — Compose 로 한 줄 재현

> 상위: [14일차 · 도커 기초](README.md) · 절차는 [Compose 실습](lesson-6-lab.md), 대본은 [STEP 6](commands.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-14-006-DO |
| 유형 | D&O (개념) |
| 목적 | 여러 컨테이너를 `compose.yaml` 한 파일에 적는 이유와 구조, 서비스 이름 통신, `.env`와 `.env.example`, `clone` 후 `up -d`로 환경을 되살리는 흐름을 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- 컨테이너가 여러 개가 되면 명령줄로는 관리가 안 된다는 것을 체감한다.
- `compose.yaml`에 환경(서비스, 포트, 볼륨, 변수)을 적는다.
- 컨테이너끼리는 서비스 이름으로 통한다는 것을 확인한다. DB는 밖에 열지 않는다.
- 비밀은 `.env`로 빼고 `.gitignore`에 넣고, 대신 `.env.example`을 커밋한다.
- `git clone` 후 `docker compose up -d`로 환경을 한 줄에 되살린다.

## 1. 목적

[4. 데이터와 볼륨](lesson-4.md)에서 DB를 띄운 명령은 길었다.

```bash
docker run -d --name db -e MARIADB_ROOT_PASSWORD=<password> -e MARIADB_DATABASE=testdb \
  -v dbdata:/var/lib/mysql -p 127.0.0.1:3306:3306 mariadb
```

여기에 [5. Dockerfile](lesson-5.md)의 웹 컨테이너까지 합치면 외워야 할 명령이 두 줄이다. 이것을 옆자리와 3개월 뒤의 나에게 어떻게 전달하는가? 13일차에 같은 문제를 이미 풀었다. 코드는 기억하지 말고 Git에 적어 둔다. 환경도 똑같이 한다. 명령을 파일로 적는다. 그 파일이 `compose.yaml`이다.

```
  13일차:  Git = 코드
  5번 절:  Git = 코드 + 돌리는 방법 (Dockerfile · 컨테이너 하나)
  6번 절:  Git = 코드 + 환경 전체 (Compose · 여러 컨테이너 · 포트 · 볼륨 · 변수)
```

`docker compose` 명령은 [2. 설치와 첫 컨테이너](lesson-2.md)에서 설치한 `docker-compose-plugin`에 들어 있다. 따로 설치할 것이 없다(`docker compose version`).

## 2. 구성 요소

### `compose.yaml`: 명령줄을 그대로 옮긴 것

```yaml
services:
  web:
    build: .                       # ← 5번 절의 docker build -t … .
    ports:
      - "8080:80"                  # ← -p 8080:80
    restart: unless-stopped

  db:
    image: mariadb                 # ← 이미지를 그대로 받아 쓴다
    environment:
      MARIADB_ROOT_PASSWORD: ${DB_PASSWORD}
      MARIADB_DATABASE: testdb
    volumes:
      - dbdata:/var/lib/mysql      # ← -v dbdata:/var/lib/mysql
    restart: unless-stopped
    # ports 가 없다. 밖에 열지 않는다

volumes:
  dbdata:
```

| `docker run` 옵션 | `compose.yaml` |
|---|---|
| `--name web` | `services:` 아래의 이름 `web` |
| `-p 8080:80` | `ports: ["8080:80"]` |
| `-e KEY=VALUE` | `environment:` |
| `-v 이름:/경로` | `volumes:`(맨 아래 `volumes:` 선언 포함) |
| 이미지 이름 | `image:` |
| `docker build … .` | `build: .` |
| (없음) | `restart: unless-stopped`. 재부팅 후 자동 기동 |

`version:` 줄은 쓰지 않는다. 지금 Compose(v2)에서는 쓸모가 없어져 `version is obsolete` 경고만 난다. 파일 이름은 `compose.yaml`이 요즘 표준이다(`docker-compose.yml`도 그대로 인식된다).

### 비밀은 `.env`로: 그리고 `.env.example`을 커밋한다

위 파일에서 비밀번호를 `${DB_PASSWORD}`로 비워 뒀다. 값은 옆 파일 `.env`에 두고(`DB_PASSWORD=<password>`) `.gitignore`에 `.env`를 넣는다. 그런데 `.env`를 올리지 않으면 옆자리는 무엇을 넣어야 할지 모른다. 그래서 빈 양식 `.env.example`을 올린다.

| 파일 | Git에 올리나 | 무엇이 들어가나 |
|---|---|---|
| `compose.yaml` | 올린다 | 구조. 서비스, 포트, 볼륨 |
| `.env.example` | 올린다 | 변수 이름만(값은 비운다) |
| `.env` | 올리지 않는다 | 실제 비밀번호 |

{% hint style="danger" %}
WARNING: 13일차의 원칙이다. 비밀은 커밋하면 지워도 이력에 남는다. 처음부터 올리지 않는다. "구조는 공개, 값은 비공개"가 실무의 기본형이다. 16일차 Secret도 같은 방식으로 다룬다.
{% endhint %}

### 띄워 본다: 한 줄

`docker compose config`로 먼저 문법을 검사한다(12일차 `nginx -t`, `named-checkconf` 습관). 이어서 `docker compose up -d`로 띄운다. `docker compose ps`에 두 서비스가 `Up`이어야 한다.

컨테이너 이름이 `myweb-web-1`처럼 바뀐다. Compose는 폴더 이름을 프로젝트 이름으로 쓴다.

#### 컨테이너끼리는 이름으로 통한다

`docker compose exec web sh -c "getent hosts db"`는 `db`의 컨테이너 IP를 보여 준다. `db`라는 호스트 이름이 그대로 통한다. Compose가 서비스마다 내부 DNS 이름을 만들어 준다. 10일차 DNS(이름 → 주소)가 컨테이너 안에서도 그대로 쓰인다.

`sudo ss -tulnp | grep 3306`은 아무것도 출력하지 않는다. 이것이 이 절의 보안 결말이다. 웹은 DB에 이름으로 닿는데 호스트에는 3306이 아예 열리지 않았다. 11일차 최소 개방의 완성형이다. `-p`를 쓰지 않는 것이 가장 안전한 선택이다. 3번 절에서 본 `ufw` 우회 문제도 `-p`를 쓰지 않으면 생기지 않는다.

#### 내리기

| 명령 | 효과 |
|---|---|
| `docker compose stop` | 멈춤(데이터와 컨테이너 유지) |
| `docker compose down` | 컨테이너와 네트워크 삭제(볼륨은 남는다) |
| `docker compose up -d` | 다시 올리면 데이터가 그대로 있다 |

{% hint style="danger" %}
WARNING: `docker compose down -v`는 3초 멈추고 실행한다. `-v`가 볼륨까지 지운다. DB 데이터가 날아간다.
{% endhint %}

### 결말: `clone` 한 줄로 환경이 선다

[5. Dockerfile](lesson-5.md)에서 옆자리 저장소를 띄워 봤다. 이제는 DB까지 포함한 환경 전체가 이렇게 선다.

```
  git clone → cp .env.example .env (비밀번호만 각자 정한다) → docker compose up -d
  세 줄.  웹 + DB + 볼륨 + 네트워크가 선다.
```

| 12일차(apt) | 오늘(Compose) |
|---|---|
| 여섯 단계 곱하기 서버 개수 | `up -d` 한 줄 |
| 설정 파일이 `/etc`에 흩어진다 | 파일 하나에 모여 있다 |
| 옆자리에 전달 = 구두 설명 | `git clone` |
| 되돌리기 = 기억에 의존 | `down` 후 `up` |

오늘 우리가 한 일은 서버를 세운 것이 아니다. 서버를 세우는 방법을 파일로 적어 Git에 넣은 것이다. 15, 16일차에는 이 저장소를 그대로 들고 간다. 같은 환경을 쿠버네티스 매니페스트로 다시 적어 올린다.

## 3. 동작 원리

1. `compose.yaml`이 서비스(web, db)와 각 서비스의 이미지, 포트, 볼륨, 변수를 선언한다.
2. `docker compose up -d`가 `.env`의 값을 `${DB_PASSWORD}`에 채워 넣는다.
3. 서비스마다 컨테이너를 만들고, 하나의 내부 네트워크에 연결한다.
4. 내부 네트워크에서는 서비스 이름(`db`)이 그 컨테이너의 IP로 풀린다(내부 DNS).
5. `ports`가 있는 서비스(web)만 호스트에 포트가 열린다. `ports`가 없는 서비스(db)는 밖에서 보이지 않는다.
6. `down`은 컨테이너와 네트워크를 지우고 볼륨은 남기므로 다시 `up -d` 하면 데이터가 이어진다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| Compose | 여러 컨테이너를 파일 하나로 정의하고 한 번에 다루는 도구 |
| 서비스(service) | `compose.yaml`의 한 구성 단위(예: `web`, `db`) |
| YAML | 들여쓰기로 구조를 쓰는 설정 파일 형식 |
| `.env` | 변수 값을 담은 파일. Git에 올리지 않는다 |
| `.env.example` | 변수 이름만 적은 빈 양식. Git에 올린다 |
| `restart: unless-stopped` | 재부팅 후 자동 기동. 12일차 `systemctl enable`에 해당 |
| 매니페스트(manifest) | 쿠버네티스에서 환경을 적는 파일(16일차) |

## 그림 목록

| 번호 | 그림 | 설명 |
|---|---|---|
| 1 | Git이 담는 것의 변화 | 13일차 코드, 5번 절 코드와 Dockerfile, 6번 절 코드와 환경 전체 |
| 2 | 문이 몇 개인가 | `-p`를 쓴 web과 쓰지 않은 db를 그려 문의 수를 센다 |

## 강의 메모

- 20분이다. 시간이 모자라면 강사 시연으로 간다. 단 `compose.yaml` 대응표와 `ss | grep 3306`이 비는 장면은 반드시 보여 준다.
- `ports`가 없는 db가 이 절의 하이라이트이다. 3번 절에서 놀랐던 방화벽 함정의 해답이 여기 있다. 칠판에 `-p`를 쓴 것(web)과 쓰지 않은 것(db)을 그려 문이 몇 개인지 세게 한다.
- `.env`와 `.env.example` 한 쌍은 실무에서 매일 쓰는 습관이다. 13일차 `.gitignore`를 다시 꺼내 연결한다.
- `docker compose config`를 먼저 치는 습관은 12일차 `nginx -t`, `named-checkconf`와 같은 자리이다.
- YAML은 들여쓰기가 문법이다. 탭 금지, 공백 2칸으로 통일한다. `config`가 오류를 잡아 준다.
- 4번 절에서 띄운 `db` 컨테이너가 남아 있으면 이름이나 볼륨이 겹칠 수 있다. `docker rm -f db`로 먼저 정리한다.
- 쿠버네티스는 이름만 꺼낸다. "컨테이너가 수백 개가 되면 쓰는 도구가 따로 있다" 한 줄이다(이 과정에서는 다루지 않는다).

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `compose.yaml`의 `db`에 `ports`를 쓰지 않았다. 그런데 웹은 어떻게 DB에 접속하는가?
- [ ] `.env`는 Git에 올리지 않고 `.env.example`은 올린다. 각각의 이유는 무엇인가? `docker compose down`과 `docker compose down -v`의 차이는 무엇인가?
- [ ] `restart: unless-stopped`는 12일차의 어느 명령과 같은 역할인가? 포트를 열지 않은 DB를 직접 들여다보려면 어떻게 하겠는가?
