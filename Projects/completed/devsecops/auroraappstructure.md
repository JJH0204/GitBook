# Aurora 앱 구조 (Aurora)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-DSO-002-REF |
| 유형 | REF (구조·구성 목록) |
| 목적 | Aurora 웹 서비스의 파일 구조, 컨테이너 구성, 요청 처리 흐름을 찾아본다 |
| 확인 상태 | 미검증 (원본 메모를 정리한 것이며 코드를 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

원본 메모에는 두 단계의 구조가 섞여 있다. 1단계는 Flask 예제, 2단계는 Django 기반 Aurora다. 이 문서는 둘을 나누어 정리한다.

## 1. 1단계: Flask 예제 구조

| 경로 | 설명 |
|---|---|
| `Aurora/` | 프로젝트 루트 |
| `app/app.py` | Flask 메인 애플리케이션 |
| `app/templates/index.html` | 메인 페이지 템플릿(내장 CSS, API를 호출하는 JavaScript 포함) |
| `Dockerfile` | 다단계 빌드. Stage 1(builder)은 Python 패키지 설치, Stage 2(final)는 실행 환경 |
| `docker-compose.yml` | `web` 서비스. 호스트:컨테이너 포트 80 매핑, 소스 코드를 볼륨으로 마운트 |
| `requirements.txt` | `flask==3.0.0`, `python-dotenv==1.0.0`, `gunicorn==21.2.0` |

### 라우트

| 경로 | 메서드 | 설명 |
|---|---|---|
| `/` | GET | 메인 페이지 |
| `/api/health` | GET | 상태 확인 |
| `/api/hello` | GET | Hello World |
| `/api/greet` | POST | 인사 메시지 |

### 요청 흐름

1. 브라우저가 Docker의 80 포트로 HTTP 요청을 보낸다.
2. Gunicorn WSGI 서버가 요청을 받아 Flask 애플리케이션에 전달한다.
3. URL 라우팅이 `home`, `health_check`, `hello`, `greet` 함수 중 하나로 분기한다.
4. `home`은 `index.html`을 렌더링해 HTML로 반환한다. API 함수는 JSON으로 응답한다.
5. 브라우저의 JavaScript가 응답을 받아 DOM을 갱신한다.

## 2. 2단계: Django 기반 Aurora 구조

| 경로·앱 | 설명 |
|---|---|
| `aurora/` | 프로젝트 설정 |
| `templates/` | HTML 템플릿 |
| `static/` | 정적 파일 |
| `media/` | 사용자 업로드 |
| `docker-compose.yml` | Docker 구성 |
| `Dockerfile` | Docker 이미지 |
| `requirements.txt` | Python 의존성 |
| `accounts/` 앱 | 사용자 계정 관리 |
| `core/` 앱 | 핵심 기능 |
| `posts/` 앱 | 게시물 관리. 기능은 검색, 피드, 좋아요 |

### 구성 요소와 역할

| 구성 요소 | 역할 | 프로젝트에서의 설정 |
|---|---|---|
| Gunicorn | Django를 위한 WSGI 서버. 요청을 받아 Django에 전달하고 다중 워커로 동시 요청을 처리한다 | `docker-entrypoint.sh`에서 `gunicorn aurora.wsgi:application --bind 0.0.0.0:80` 실행. `docker-compose.yml`에서 포트 80으로 서비스 |
| WhiteNoise | 정적 파일 서빙 미들웨어. 압축·캐싱을 지원하고 별도 웹 서버(nginx 등) 없이 정적 파일을 제공한다 | `settings.py` 미들웨어에 `whitenoise.middleware.WhiteNoiseMiddleware` 설정. `python manage.py collectstatic`으로 수집한 파일을 `/app/staticfiles`에서 서빙 |
| MariaDB | 데이터베이스 | 뷰 로직이 쿼리한다 |
| 웹 브라우저 | 클라이언트 | |

### 요청 흐름

| 요청 종류 | 처리 순서 |
|---|---|
| 동적 콘텐츠 | 브라우저 → Gunicorn(WSGI 요청 전달) → URL 라우팅 → 뷰 로직 → DB 쿼리·데이터 반환 → 템플릿 렌더링 → HTML 응답 |
| 정적 파일(CSS, JS, 이미지) | 브라우저 → WhiteNoise(압축·캐시된 파일 확인) → 정적 파일 반환 |
| 인증이 필요한 요청 | URL 라우팅 → 인증 미들웨어 → 세션 확인 → 사용자 데이터 조회 → 뷰 로직 → 템플릿 렌더링 → 인증 처리된 응답 |

## 3. Dockerfile 예시(원본)

주석이 줄 끝에 붙어 있던 원본을 한 줄 주석으로 옮겼다. 줄 끝 주석은 Dockerfile에서 오류가 된다. `...`은 원본에서 생략된 부분이다.

```dockerfile
# 기본 이미지
FROM python:3.11-slim
# .pyc 파일 생성 방지, 출력 즉시 표시, Poetry 버전 지정
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    POETRY_VERSION=1.7.1
...
...
# 필요한 패키지 설치
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
...

# Poetry 설치
RUN curl -sSL https://install.python-poetry.org | python3 -

# 프로젝트 의존성 추가
COPY pyproject.toml poetry.lock* ./
RUN poetry install --no-root --no-dev

# 프로젝트 파일 복사 및 설치
COPY . .
RUN poetry install --no-dev
```

`docker-compose.yml`의 주요 항목은 다음과 같다. 실행은 `docker compose up --build`다.

| 항목 | 값 | 의미 |
|---|---|---|
| `build` | `.` | 해당 위치의 Dockerfile을 읽는다 |
| `volumes` | `.:/app` | 프로젝트 로컬 디렉터리를 `/app`에 마운트한다 |
| `ports` | `"8000:8000"` | 호스트 8000번 포트를 컨테이너 8000번 포트에 연결한다 |

{% hint style="info" %}
NOTE: 원본 메모의 불일치를 표시한다. (1) 이 Dockerfile은 Poetry를 쓰지만 1단계 구조는 `requirements.txt`를 쓴다. 단계가 달라 생긴 차이로 보이며 확인 필요. (2) 포트가 8000(compose 예시)과 80(Gunicorn 실행 명령)으로 다르다. (3) Poetry 1.2 이후 `--no-dev`는 폐기 예정이며 `--without dev`를 쓴다. 미검증.
{% endhint %}
