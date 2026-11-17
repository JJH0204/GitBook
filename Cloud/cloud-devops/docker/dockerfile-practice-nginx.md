# Dockerfile 실습: Nginx 웹 페이지 이미지

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-DKR-011-MP |
| 목적 | `nginx:alpine` 기반으로 웹 페이지 이미지를 두 버전(`latest`, `second`)으로 빌드하고 각각 컨테이너로 실행한다 |
| 적용 대상 | 도커 엔진이 설치된 Linux(원본은 Rocky Linux), 호스트의 80번 포트가 비어 있음 |
| 소요 시간 | 약 15분 |
| 확인 상태 | 미검증 (원본 페이지의 실습을 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [Dockerfile 작성법 및 실습](dockerfile.md) | CLD-DKR-010-REF | 지시어 표 |
| [도커 이미지 빌드](docker_build.md) | CLD-DKR-009-MP | 빌드 절차 |
| [Dockerfile 이미지 쿠버네티스 배포 명령](dockerfile-k8s-deploy.md) | CLD-DKR-014-REF | 이어서 배포할 때 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 도커 엔진 | 설치 완료 | |
| 2 | 기반 이미지 | `nginx:alpine` | 빌드 중 내려받는다 |
| 3 | 텍스트 편집기 | `vi` 등 | |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: `-p 80:80`은 호스트의 80번 포트를 모든 네트워크 인터페이스에 연다. 같은 네트워크의 다른 기기가 접속할 수 있다. 내 PC에서만 확인하려면 `-p 127.0.0.1:80:80`을 쓴다.
{% endhint %}

{% hint style="warning" %}
CAUTION: v1과 v2 컨테이너는 같은 호스트 포트를 쓰므로 동시에 실행할 수 없다. 5-B-01에서 v1을 먼저 삭제한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 도커가 동작한다 | `docker --version`이 버전을 출력한다 |
| 2 | 80번 포트가 비어 있다 | `ss -tln` 출력에 `:80`이 없다 |

## 5. 절차

### A. v1 이미지 빌드와 실행

1. (5-A-01) 작업 디렉터리를 만들고 이동한다: `mkdir ./myweb && cd ./myweb`
2. (5-A-02) `index.html`을 만든다: `vi index.html`
3. (5-A-03) 아래 내용을 저장한다.

```html
<!DOCTYPE html>
<html>
<head>
    <title>Welcome my web!</title>
</head>
<body>
    <h1>Hello World!</h1>
</body>
</html>
```

4. (5-A-04) `Dockerfile`을 만든다: `vi Dockerfile`
5. (5-A-05) 아래 내용을 저장한다.

```dockerfile
# Use an official Nginx runtime as a parent image
FROM nginx:alpine

# Copy the web page to the container
COPY index.html /usr/share/nginx/html/
```

{% hint style="info" %}
NOTE: 원본은 파일명을 `index.hmtl`로 잘못 적었고 대상 경로 끝의 `/`가 없었다. 파일명을 `index.html`로 정정하고, 파일을 디렉터리 안에 복사한다는 뜻이 분명하도록 `/`를 붙였다. 미검증이다.
{% endhint %}

6. (5-A-06) 이미지를 빌드한다: `docker build -t my-web-app .` → 결과: 오류 없이 끝난다.
7. (5-A-07) 이미지를 확인한다: `docker images` → 결과: `my-web-app`이 `latest` 태그로 보인다. 원본 기준 크기는 약 52.5MB다.
8. (5-A-08) 컨테이너를 실행한다: `docker run -d -p 80:80 --name my-web-app my-web-app` → 결과: 컨테이너 ID가 출력된다.
9. (5-A-09) 컨테이너 정보를 확인한다: `docker container inspect <컨테이너 ID>` → 결과: JSON 정보가 출력된다.
10. (5-A-10) 접속을 확인한다: `curl http://localhost:80` → 결과: `Hello World!`가 포함된 HTML이 출력된다.

### B. v2 이미지 빌드와 실행

1. (5-B-01) v1 컨테이너를 중지하고 삭제한다: `docker rm -f my-web-app` → 결과: `my-web-app`이 출력된다.

{% hint style="danger" %}
WARNING: `docker rm -f`는 실행 중인 컨테이너를 즉시 삭제한다. 이 컨테이너는 실습용이다. 이름(`my-web-app`)이 맞는지 `docker ps`로 확인한 뒤 실행한다.
{% endhint %}

2. (5-B-02) `index.html`을 수정한다: `vi index.html` → `<title>`을 `Welcome my web app!`으로, `<h1>`을 `Hello World! Hello World!`로 바꾼다.
3. (5-B-03) 두 번째 태그로 빌드한다: `docker build -t my-web-app:second .` → 결과: 오류 없이 끝난다.
4. (5-B-04) 이미지를 확인한다: `docker images` → 결과: `my-web-app`이 `latest`와 `second` 두 태그로 보인다.
5. (5-B-05) 컨테이너를 실행한다: `docker run -d -p 80:80 --name my-web-app-v2 my-web-app:second` → 결과: 컨테이너 ID가 출력된다.
6. (5-B-06) 접속을 확인한다: `curl http://localhost:80` → 결과: `Hello World! Hello World!`가 포함된 HTML이 출력된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 5-A-10 `curl http://localhost:80` | v1 페이지가 응답한다 | `<h1>Hello World!</h1>`이 보인다 |
| 2 | `docker images` | 태그 두 개가 있다 | `latest`와 `second`가 보인다 |
| 3 | 5-B-06 `curl http://localhost:80` | v2 페이지가 응답한다 | `Hello World! Hello World!`가 보인다 |

## 7. 복구

1. (7-01) 컨테이너를 삭제한다: `docker rm -f my-web-app-v2`
2. (7-02) 이미지를 삭제한다: `docker rmi my-web-app:second my-web-app:latest`
3. (7-03) 작업 디렉터리를 삭제한다: `cd .. && rm -r ./myweb`

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | `dockerfile.md`의 "my-web-app v1/v2" 실습을 독립 MP로 분리. `index.hmtl` 오타 정정, v1 삭제 단계(포트 충돌 방지), 포트 개방 CAUTION, 확인·복구 절차를 추가했다 |
