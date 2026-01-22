# DevSecOpsHackingCompetition

\==⚠ Switch to EXCALIDRAW VIEW in the MORE OPTIONS menu of this document. ⚠==\
You can decompress Drawing data with the command palette: 'Decompress current Excalidraw file'. For more info check in plugin settings under 'Saving'

## Text Elements

취약한 서버

* 웹 개발 프로세스 이해
* 보안 취약점 학습 ^yiZ2u0hx

안드로이드 모바일 앱 ^80PJ6R7J

탐지 시스템 ^O7GA9SXS

로그 시스템 ^swn7gNVC

보안 관제 솔루션 ^MIhAXZxF

기타 ^8OUxvpXW

보고서 작성

{% stepper %}
{% step %}
### 탐지 히스토리

(내용: 탐지 히스토리)
{% endstep %}

{% step %}
### 데이터 분석 결과

(내용: 데이터 분석 결과)
{% endstep %}

{% step %}
### 해결 방안

(내용: 해결 방안)
{% endstep %}
{% endstepper %}

의도된 취약점 10 ^rErxPLF0

어떤 웹 서비스를 만들까? ^2B83gtpT

어떻게 만들까? ^mE2mBRWi

SNS 플랫폼\
오피스 플랫폼\
(사내 홈페이지)\
여행\
학원 ^C9cun7S3

서버와 사용자의 잦은 상호작용 ^VX3sNktE

DB의 필요성 ^kMOVUyvN

접근 제어 ^FJraAjqv

파일 업로드 ^8h9XLOnC

텍스트 업로드 ^FghHqxU8

검색 ^KeS7cuCO

파일 다운로드 ^JQIjo2SI

리다이렉트 ^HNsOI8Js

외부 API ^Wsje09aN

프론트 엔드: HTML + CSS + JS ^cLMSLORC

백 엔드: python ^KfcBjqrS

프로젝트 가칭\
오로라(Aurora): Firewall + LED, 불 에너지 밝은 빛

* 두 팀이 함께해서 '오로라' 처럼 아름다운 빛을 만들자는 의미에서 착안 ^tIxhJxzH

docker compose up --build ^QB1Epc97

docker-compose.yml ^eVpevpqZ

build: . # 해당 위치의 Dockerfile을 읽어 온다. ^u1yqFQIE

Dockerfile ^VGE3YyGg

```dockerfile
FROM python:3.11-slim                            # 기본 이미지 가져옴
ENV PYTHONDONTWRITEBYTECODE=1 \   # .pyc 파일 생성 못하도록 설정
    PYTHONUNBUFFERED=1 \                  # 출력을 버퍼링 하지 않고 즉시 출력
    POETRY_VERSION=1.7.1                     # Poetry 버전 지정
...
...
RUN apt-get update \
    && apt-get install -y --no-install-recommends \               # 필요한 패키지 설치

RUN curl -sSL https://install.python-poetry.org | python3 -    # Poetry 설치 후 환경 변수에 추가

COPY pyproject.toml poetry.lock* ./           # 프로젝트 의존성 추가
RUN poetry install --no-root --no-dev

COPY . .                                            # 프로젝트 파일 복사 및 설치
RUN poetry install --no-dev ^7De4Lki4
```

docker-compose.yml ^YSQTPxiM

volumes:

```yaml
    - .:/app          # 프로젝트 로컬 디렉터리 /app에 마운트
```

ports:

```yaml
  - "8000:8000"     # 호스트 8000포트 컨테이너의 8000포트와 매핑 ^EkrEJUOf
```

실행 ^KvvrnQId

프로젝트 구조 예시:

Aurora/ # 프로젝트 루트 디렉토리 │ ├── app/ # 애플리케이션 디렉토리 │ ├── app.py # Flask 메인 애플리케이션 파일 │ │ └── routes: # API 엔드포인트들 │ │ ├── / # → 메인 페이지 (GET) │ │ ├── /api/health # → 상태 체크 (GET) │ │ ├── /api/hello # → Hello World (GET) │ │ └── /api/greet # → 인사 메시지 (POST) │ │ │ └── templates/ # HTML 템플릿 디렉토리 │ └── index.html # 메인 페이지 템플릿 │ ├── CSS # → 내장된 스타일 │ └── JavaScript # → API 호출 및 UI 상호작용 │ ├── Dockerfile # 다단계 빌드 설정 │ ├── Stage 1 (builder) # → Python 패키지 설치 │ └── Stage 2 (final) # → 실행 환경 구성 │ ├── docker-compose.yml # 컨테이너 구성 │ └── services: │ └── web # → 웹 서비스 설정 │ ├── 포트: 80 # → 호스트:컨테이너 포트 매핑 │ └── 볼륨: app # → 소스 코드 마운트 │ └── requirements.txt # Python 패키지 의존성 ├── flask==3.0.0 # → 웹 프레임워크 ├── python-dotenv==1.0.0 # → 환경 변수 관리 └── gunicorn==21.2.0 # → WSGI 서버 ^pxSqEXaH

````

브라우저 ^7cRT5jf4

Docker 80 포트 ^6lVLU8vU

Gunicorn WSGI 서버 ^aVi57R3A

Flask 애플리케이션 ^kLZZzCoe

라우트 분기 ^OBVoSnLv

home 함수 ^UBUzHwnw

index.html ^hfXDmIkQ

health_check 함수 ^AjhPj7ox

hello 함수 ^gK9yrpnU

greet 함수 ^kNaFYj9i

DOM 업데이트 ^ErJ3yBm5

{% stepper %}
{% step %}
## HTTP 요청 흐름

- HTTP 요청 ^qzD1z74B
- 포트 포워딩 ^rFwzulUs
- 요청 전달 ^0XhU48V4
- URL 라우팅 ^tfshntWF
{% endstep %}

{% step %}
## 메인 페이지 처리

- 메인 페이지 ^I5SxXADl
- 템플릿 렌더링 ^cGTvP35L
- HTML 반환 ^aGKFwI5r
{% endstep %}

{% step %}
## API 처리 예시

- Hello 요청 ^DwTqJ19Y
- 인사 요청 ^y2WCO3Lr
- JSON 응답 ^hdqZMFGx / ^DprOOjOE / ^axWtlpn2
{% endstep %}

{% step %}
## 응답 및 자바스크립트 동작

- HTTP 응답 ^ZmBXiQQP / ^2Ed0zOwK
- JavaScript 실행 ^eWY660J2
- API 요청 ^80c5ELX2
{% endstep %}
{% endstepper %}

상태 확인 ^GrH0fWG2

- [데이터베이스 접근 필요] ^u23zc0Cb
- [사용자 정보 필요] ^ANyompgR

MariaDB ^zpHrNqAM

Whitenoise ^JNk9bIrW

Django ^GS7ofyQ4 / ^BX12PD8Y

Gunicorn ^5PcPepdZ

웹 브라우저 ^GgbFerVY

동적 컨텐츠 요청 ^kbMKgbhn

정적 파일 요청 ^ISbbJOG2

인증이 필요한 요청 ^uvmghYLw

HTTP 요청 ^zqoqRrcQ

WSGI 요청 전달 ^SYqFpjkv

URL 라우팅 ^RVjlQ5U0

뷰 로직 처리 ^AZRaAs0Y

데이터베이스 쿼리 ^xkha2oGg

데이터 반환 ^YfoKoKLY

템플릿 렌더링 ^eCZqz61v

HTTP 응답 생성 ^kakPJE3s

HTML 응답 ^DgwlBHno

정적 파일 요청 (CSS, JS, 이미지) ^mj6e2PDV

요청 전달 ^ZOKmplTr

압축/캐시된 파일 확인 ^2Wmd2Xox

정적 파일 반환 ^eCG4Ihm3

정적 파일 응답 ^JuWdaDSt

인증 필요 요청 ^ryNNqdyR

요청 전달 ^DeVYxxrv

URL 라우팅 ^HE4aPnXr

인증 미들웨어 처리 ^j4aLwkt8

세션 확인 ^ozn7SOeL

사용자 데이터 조회 ^oXg6GCVE

사용자 정보 ^9MqcQI1R

뷰 로직 처리 ^X0WQwP3B

템플릿 렌더링 ^lLtSzHqV

인증 처리된 응답 ^bQaeL1ab

최종 응답 ^mJb3i30H

opt ^70TN2CoS / ^nyo2SdER

---

Gunicorn과 Whitenoise는 프로젝트에서 각각 다음과 같은 중요한 역할을 수행합니다:

### Gunicorn (Green Unicorn)
- Django 애플리케이션을 위한 WSGI 서버입니다
- 주요 역할:
  - HTTP 요청을 받아 Django 애플리케이션으로 전달
  - 다중 워커 프로세스를 통한 동시 요청 처리
  - 프로덕션 환경에서 안정적인 성능 제공
- 현재 프로젝트에서는:
  - docker-compose.yml에서 포트 80으로 웹 서비스 제공
  - docker-entrypoint.sh에서 `gunicorn aurora.wsgi:application --bind 0.0.0.0:80` 명령으로 실행

### Whitenoise
- 정적 파일(static files) 서빙을 위한 미들웨어입니다
- 주요 역할:
  - CSS, JavaScript, 이미지 등의 정적 파일을 효율적으로 제공
  - 파일 압축 및 캐싱을 통한 성능 최적화
  - 별도의 웹 서버(nginx 등) 없이도 정적 파일 서빙 가능
- 현재 프로젝트에서는:
  - settings.py의 미들웨어에 `whitenoise.middleware.WhiteNoiseMiddleware` 설정
  - `python manage.py collectstatic` 명령으로 수집된 정적 파일들을 /app/staticfiles 디렉토리에서 서빙

이 두 컴포넌트의 조합으로:  
Gunicorn이 HTTP 요청을 처리하고 Django 애플리케이션을 실행  
Whitenoise가 정적 파일 요청을 효율적으로 처리  
별도의 nginx와 같은 웹 서버 없이도 프로덕션급 성능 제공  
이는 컨테이너화된 환경에서 간단하면서도 효율적인 웹 서버 구성을 가능하게 합니다. ^D3n3ddLN

Whitenoise ^kG1RLfQP  
MariaDB ^vJU8MSOL  
웹 브라우저 ^FsBJ495B  
Gunicorn ^INdVhaDi

Project Files ^23aJrtvI

apps 디렉토리 및 주요 파일:
- aurora/ 프로젝트 설정 ^b1bxREn2
- templates/ HTML 템플릿 ^pj73QPva
- static/ 정적 파일 ^D295Zo9u
- media/ 사용자 업로드 ^OgZWY0PP
- docker-compose.yml Docker 구성 ^68CaoRRA
- Dockerfile Docker 이미지 ^6QN0MJDv
- requirements.txt Python 의존성 ^37aj0Lsx

앱들:
- accounts/ 사용자 계정 관리 ^Ci18iseM
- core/ 핵심 기능 ^en8c6PVM
- posts/ 게시물 관리 ^JmD5laqI

AURORA ^fckn9ooX

검색 ^zGZ01hA5  
피드 ^ZxF7MHaZ  
좋아요 ^gFS5zkeQ

UI 관련 고찰:
- UI가 멋지고 이쁠 필요가 있을까?
  - 있지 하지만 시간이 부족해
  - 어느 정도 타협의 필요성
  - 퀄리티는 추후 보완

Private 온프레미스 (사내홈페이지 느낌)
- 사내 홈페이지 - 사원증? 사원ID/PW (DB) + 아이디에 따른 직위
- 사원의 직위에 따른 접근제어(페이지/게시물/업로드 제한)
- 공지, 부서페이지 게시물(파일/텍스트 업로드, 검색)
- 페이지 내 사내 메시지(정보 노출, 파일 업로드 및 다운로드)
- + 온프레미스 환경을 관리감독하는 관제솔루션 ^TLDHjEbY

학원홈페이지 기능 목록:
- 접근제어 - 로그인, 담당별 분류(강사/학생)
- 파일 업로드 - 과제 제출 or 공유
- 텍스트 업로드 - 공지사항
- 검색 - 게시물/과제 검색
- 파일 다운로드 - 과제 다운로드
- 리다이렉트 - 로그인 후 대시보드
- 외부 API - 지도API, SMS 알림 ^rZgUSFrW

레시피 공유 플랫폼 상세 기능 / 취약점 분석
- 회원 관리 시스템: SQL Injection, 무차별 대입 공격, 세션 하이재킹
- 레시피 업로드 시스템: 파일 업로드(webshell, 확장자 우회), 저장형 XSS
- 미디어 관리: 대용량 파일 업로드 취약
- 댓글/평점: CSRF, XSS
- 검색/필터링: SQL injection ^GDBT85j0

여행 플래너 플랫폼 취약점 목록 (요약)
- 크로스사이트 스크립팅(XSS)
- 불충분한 HTTPS
- SQL 인젝션
- 불완전한 비밀번호 저장
- CSRF
- 파일 업로드 취약점
- DDoS
- 경로 탐색 공격(Directory Traversal)
- API 키 유출, 인증/권한 부여 문제 ^oC8ubJKN

SNS 관련 메모:
- 결국 테마(음식/여행/학원/회사)를 지우고 기능에만 초점을 맞춘다면 SNS 기능이 남는다. ^ENVtRorF

인증/권한 관련:
- Password ^fPgGIeG9
- Login ^4SavFDan
- ID ^5MzAjr8c
- 캡챠 ^5O8lCVBi
- 로그인/회원가입 흐름 메모 ^A8VlzAtx
- SQL injection ^kI9kdKbg

공인/개인 계정 관련:
- 계정 권한 차이를 이용한 취약점
- 파일 업로드 권한 분리 (개인 = jpg,png, avi, mp4 / 공인 = php 등 웹쉘 가능) ^vqYDlYr0

프로젝트 목표/성과물
{% stepper %}
{% step %}
## 1 웹 사이트 포트폴리오

(포트폴리오 사이트)
{% endstep %}

{% step %}
## 모의 해킹 결과 보고서

(모의해킹 결과)
{% endstep %}

{% step %}
## 자기소개서 이력서 작업

(이력서 / 자기소개서)
{% endstep %}
{% endstepper %}

aurora_1.0 ^nDxjPPqh

모의해킹, 보안 솔루션 적용, 피드백 루프 등 메모:
- 장점은 살리고 단점 해결 ^v0pGHOLL
- 비포 에프터 ^Lx1gwcmD
- 보안 솔루션을 사용해 직접 피드백 ^pSDShHKE

개발 환경 및 도구:
- Host (windows) ^Yx03NiFx
- VScode ^fGNqELO4
- kind - 컨테이너 ^GpUZdnTt
- git action/docker image push ^C8GCpsSG

인프라 아키텍처 메모:
- Master node: 웹 대시보드, 모니터링 ^DskHwui0
- Web-service node: Django Web, MariaDB, WAF ^uepWQ0ry
- Security node: suricata, loganalize ^CPn81AvY
- 외부 네트워크, 방화벽 규칙 등 (여러 메모)

배포 예시:
- Docker hub의 krjaeh0/aurora:latest 이미지를 이용해 도커 컨테이너를 실행하는 방식으로 웹 서버 구축 ^UHQr2ecC
- krjaeh0/aurora:latest 이미지로 컨테이너 실행 시 내부에 MariaDB와 Django가 실행됨 ^eWiZ0n1F

윈도우 / WSL / Kubernetes 메모:
- windows, wsl, Kubernetes Cluster 구조 및 노드 메모 (Control, Worker 등)
- 네트워크 대역 예시: 192.168.0.0/16, 10.0.~~, 172.~~~~~ 등

포트/네트워크 메모 (요약):
- 0.0.0.0/0, 80/tcp ^6XwFRvTZ
- 192.168.0.0/16, 5000-5010/tcp ^r5sEn4Hq
- 기타 포트 범위 메모

WAF 적용 방법 요약:
- Way_1: 웹 서버 또는 프록시 서버에 WAF 설정하기
  - Nginx + ModSecurity 연동 (설치 및 구성)
  - Apache + ModSecurity 연동 (설치 및 구성)
  - 클라우드 기반 WAF 서비스 ^PKCU8M74

Django 보안 강화(요약):
- 보안 미들웨어 활성화 (SecurityMiddleware)
- X_FRAME_OPTIONS, CONTENT_SECURITY_POLICY 등
- CSRF 및 XSS 방지 (Django 기본 기능 활용)
- 사용자 입력 검증 (SQL injection 방지) ^8YP0svFM

way_3 ^PTEoQXaE

---

## Embedded Images / Files
(원본 문서에 포함된 이미지는 Excalidraw 도면과 함께 첨부되어 있습니다.)

## Drawing (compressed JSON)
```compressed-json
N4KAkARALgngDgUwgLgAQQQDwMYEMA2AlgCYBOuA7hADTgQBuCpAzoQPYB2KqATLZMzYBXUtiRoIACyhQ4zZAHoFAc0JRJQgEYA6bGwC2CgF7N6hbEcK4OCtptbErHALRY8RMpWdx8Q1TdIEfARcZgRmBShcZQUebQBGAE5tHho6IIR9BA4oZm4AbXAwUDBSiBJuCABVRIBRKuIoACkAcQBpABYAZQBZDoAZYgARFoBmZWIufjLYRErA7CiOZWC0

0shMbmcOxIB2FPiABgAOPd340Y7j+N3pyBgt+KvtADZDxJ4X0+OfnhuAVjuEAoJHU3EuySSR0+uz2p1G8SBkgQhGU0m4F2O2n+h3iPCubz2HTxgKKkGsK3EqEOQOYUFIbAA1ggAMJsfBsUiVADE8QQfL5azKmlw2EZygZQg4xDZHK5Em5ADNFQhsIlEkLIIrCPh8F1YKsJIIPJqIHSGcyAOqgyTcPhks30pkIfUwQ3oY0VIGStEccJ5NCIh1sOCi
...
(중략 — 원본 compressed-json 그대로 유지)
````

(도면 데이터가 매우 큽니다. 필요 시 Excalidraw 뷰로 전환하여 확인하세요.)

***

끝.
