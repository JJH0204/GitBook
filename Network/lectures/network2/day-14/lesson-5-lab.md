# Dockerfile 실습

> 상위: [14일차 · 도커 기초](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-14-012-MP |
| 목적 | 13일차 포트폴리오로 Dockerfile을 쓰고 이미지를 빌드해 띄우며, 저장소에 올린 뒤 옆자리 저장소를 `clone`, `build`, `run`해 재현성을 확인한다 |
| 적용 대상 | Windows 10/11의 WSL(Ubuntu 24.04), Docker Engine 29.x, 13일차의 GitHub 저장소(공개) |
| 소요 시간 | 약 35분 |
| 확인 상태 | 미검증 (원본 명령을 정리한 것이며 `docker build`, 옆자리 `clone` 이후는 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-5.md](lesson-5.md) | LEC-N2-14-005-DO | Dockerfile |
| [lesson-4-lab.md](lesson-4-lab.md) | LEC-N2-14-011-MP | 볼륨과 DB 실습 |
| [commands.md](commands.md) | LEC-N2-14-008-REF | 14일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 13일차 저장소 폴더 | 예: `~/myweb`, GitHub에 공개로 올라가 있다 | 옆자리가 `clone`할 수 있어야 한다 |
| 2 | 옆자리 저장소 주소 | `https://github.com/<옆자리 아이디>/<저장소>.git` | 구역 D에서 쓴다 |
| 3 | `nginx:alpine` 이미지 | 공식 이미지 | 처음 빌드할 때 받는다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `.dockerignore`에 `.git`, `.env`, `*.key`를 반드시 넣는다. 넣지 않으면 이력과 비밀이 이미지에 들어가 함께 배포된다.
{% endhint %}

{% hint style="warning" %}
CAUTION: GitHub Pages를 쓰는 저장소는 `index.html`을 `site/`로 옮기면 Pages가 깨질 수 있다. Pages 설정의 폴더를 `/site`로 바꾸거나, 옮기지 않고 `COPY . /usr/share/nginx/html`을 쓴다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `docker build` 끝의 `.`을 빠뜨리지 않는다. 빠뜨리면 `"docker build" requires exactly 1 argument`가 나온다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 13일차 폴더에서 작업한다 | `cd ~/myweb && git status`가 정상 출력된다 |
| 2 | 8080번이 비어 있다 | `docker ps`에 8080을 쓰는 컨테이너가 없다. 있으면 `docker rm -f web` |
| 3 | 옆자리 저장소가 공개이다 | 브라우저로 주소를 열면 로그인 없이 보인다 |

## 5. 절차

### A. Dockerfile 쓰기

1. (5-A-01) 폴더로 이동한다: `cd ~/myweb`
2. (5-A-02) `site/` 폴더를 만든다: `mkdir -p site`
3. (5-A-03) 페이지 파일을 옮긴다: `mv index.html about.html site/ 2>/dev/null`
4. (5-A-04) `ls site/`를 실행한다. → 결과: `index.html` 등이 보인다.
5. (5-A-05) `nano Dockerfile`로 파일을 열고 아래 세 줄을 입력한 뒤 저장한다.

```dockerfile
FROM nginx:alpine
COPY ./site /usr/share/nginx/html
EXPOSE 80
```

6. (5-A-06) `nano .dockerignore`로 파일을 열고 아래 다섯 줄을 입력한 뒤 저장한다.

```
.git
.env
*.key
node_modules
*.log
```

### B. 굽고 띄우기

1. (5-B-01) 이미지를 만든다: `docker build -t mysite:1.0 .` → 결과: `naming to ... mysite:1.0` 같은 완료 메시지가 나온다.
2. (5-B-02) `docker images | grep -E "mysite|nginx"`를 실행한다. → 결과: 내 이미지와 바탕 이미지가 보인다(`alpine`이 작다).
3. (5-B-03) 이전 컨테이너를 지운다: `docker rm -f web 2>/dev/null`
4. (5-B-04) 띄운다: `docker run -d -p 8080:80 --name mysite mysite:1.0`
5. (5-B-05) `curl localhost:8080`을 실행한다. → 결과: 내 포트폴리오 HTML이 나온다.
6. (5-B-06) Windows 브라우저에서 `http://localhost:8080`을 연다. → 결과: 내 이미지로 띄운 내 포트폴리오가 보인다.

### C. Git에 올리기

1. (5-C-01) `git status`를 실행한다. → 결과: `Dockerfile`, `.dockerignore`, `site/`가 보인다.
2. (5-C-02) 담는다: `git add Dockerfile .dockerignore site/`
3. (5-C-03) 커밋한다: `git commit -m "Dockerfile 추가 — 컨테이너로 돌리는 방법까지 저장소에"`
4. (5-C-04) 올린다: `git push` → 결과: 원격에 반영된다.

### D. 재현성 실험: 옆자리 저장소

1. (5-D-01) 홈으로 이동한다: `cd ~`
2. (5-D-02) 옆자리 저장소를 받는다: `git clone https://github.com/<옆자리 아이디>/<저장소>.git friend`
3. (5-D-03) 폴더로 이동한다: `cd friend`
4. (5-D-04) 빌드한다: `docker build -t friend:1.0 .`
5. (5-D-05) 8090번으로 띄운다: `docker run -d -p 8090:80 --name friend friend:1.0`
6. (5-D-06) `curl localhost:8090`을 실행한다. → 결과: 옆자리 포트폴리오 HTML이 나온다.
7. (5-D-07) Windows 브라우저에서 `http://localhost:8090`을 연다. → 결과: 옆자리 포트폴리오가 내 PC에서 보인다.

### E. 고치면 다시 굽는다

1. (5-E-01) 내 저장소로 돌아간다: `cd ~/myweb`
2. (5-E-02) `nano site/index.html`로 내용을 수정한다.
3. (5-E-03) 태그를 올려 빌드한다: `docker build -t mysite:1.1 .` → 결과: 첫 빌드보다 빠르다(레이어 캐시).
4. (5-E-04) 이전 컨테이너를 지운다: `docker rm -f mysite`
5. (5-E-05) 새 이미지로 띄운다: `docker run -d -p 8080:80 --name mysite mysite:1.1`
6. (5-E-06) `docker images | grep mysite`를 실행한다. → 결과: `1.0`과 `1.1`이 모두 보인다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `curl localhost:8080` | 내 포트폴리오 | 내 `index.html` 내용이 보인다 |
| 2 | `curl localhost:8090` | 옆자리 포트폴리오 | 옆자리 내용이 보인다 |
| 3 | 옆자리 PC 환경을 묻지 않았는가 | nginx 설치, 설정 수정, 포트 열기 없이 떴다 | 실습에서 한 일이 `clone`, `build`, `run`뿐이다 |
| 4 | `docker images \| grep mysite` | 태그 두 개 | `1.0`, `1.1`이 보인다 |

## 7. 복구

1. (7-01) 실습 컨테이너를 지운다: `docker rm -f mysite friend`
2. (7-02) 옆자리 폴더를 지운다: `rm -rf ~/friend`
3. (7-03) 이미지를 지운다: `docker rmi mysite:1.0 mysite:1.1 friend:1.0`
4. (7-04) `site/`로 옮긴 파일을 되돌리려면: `mv site/* .`로 옮긴 뒤 `git status`로 확인한다. Pages 폴더 설정을 바꿨다면 함께 되돌린다.

{% hint style="warning" %}
CAUTION: 6번 절([Compose 실습](lesson-6-lab.md))이 이 저장소의 Dockerfile을 쓴다. 7-04는 그 실습이 끝난 뒤에 실행한다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-5.md`와 `commands.md`의 STEP 5 실습 항목을 AMM 형식으로 재작성 |
