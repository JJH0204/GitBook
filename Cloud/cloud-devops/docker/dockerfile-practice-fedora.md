# Dockerfile 실습: Fedora Nginx 이미지

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-DKR-013-MP |
| 목적 | Fedora 기반 이미지에 Nginx를 설치하는 Dockerfile을 작성하고 빌드해 실행한다 |
| 적용 대상 | 도커 엔진이 설치된 Linux(원본은 Rocky Linux), 인터넷 연결, 호스트의 80번 포트가 비어 있음 |
| 소요 시간 | 약 15분 |
| 확인 상태 | 미검증 (원본 페이지의 실습을 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [Dockerfile 작성법 및 실습](dockerfile.md) | CLD-DKR-010-REF | 지시어 표 |
| [도커 이미지 빌드](docker_build.md) | CLD-DKR-009-MP | 빌드 절차 |
| [Dockerfile 실습: Ubuntu Apache 이미지](dockerfile-practice-apache.md) | CLD-DKR-012-MP | 같은 구조의 Ubuntu 버전 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 도커 엔진 | 설치 완료 | |
| 2 | 기반 이미지 | `fedora` | 태그를 생략하면 `latest`다 |
| 3 | 텍스트 편집기 | `vi` 등 | |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 원본은 `FROM fedora`로 태그를 생략했다. 태그를 생략하면 `latest`가 적용되어 빌드 시점마다 다른 버전이 될 수 있다. 재현이 필요하면 `fedora:<버전>`으로 고정한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `-p 80:80`은 호스트의 80번 포트를 모든 네트워크 인터페이스에 연다. 내 PC에서만 확인하려면 `-p 127.0.0.1:80:80`을 쓴다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 도커가 동작한다 | `docker --version`이 버전을 출력한다 |
| 2 | 80번 포트가 비어 있다 | `ss -tln` 출력에 `:80`이 없다 |

## 5. 절차

### A. 파일 준비

1. (5-A-01) 작업 디렉터리를 만들고 이동한다: `mkdir ./fedora && cd ./fedora`
2. (5-A-02) 빈 `index.html`을 만든다: `touch index.html` → 결과: 현재 디렉터리에 `index.html`이 생긴다.
3. (5-A-03) `Dockerfile`을 연다: `vi Dockerfile`
4. (5-A-04) 아래 내용을 저장한다.

```dockerfile
# Fedora 기반 Nginx Dockerfile
FROM fedora

# 유지보수자 정보
LABEL maintainer="<이름>"

# 시스템 업데이트 및 nginx 설치
RUN dnf -y update && dnf -y install nginx

# 웹 파일 추가
ADD index.html /usr/share/nginx/html/

# 작업 디렉터리 설정
WORKDIR /usr/share/nginx/html

# 기본 페이지 확인용 문자열 추가
RUN ["/bin/sh", "-c", "echo hello >> index.html"]

# Nginx 포트 노출 표시
EXPOSE 80

# Nginx 실행 명령 설정
CMD ["nginx", "-g", "daemon off;"]
```

{% hint style="info" %}
NOTE: 원본의 `MAINTAINER`(폐기된 지시어)를 `LABEL maintainer`로 바꾸고 개인 이름과 이메일은 `<이름>`으로 바꿨다. 미검증이다.
{% endhint %}

### B. 빌드와 실행

1. (5-B-01) 이미지를 빌드한다: `docker build -t nginxweb .` → 결과: 오류 없이 끝난다.
2. (5-B-02) 컨테이너를 실행한다: `docker run -d -p 80:80 --name fedora-nginx-web nginxweb` → 결과: 컨테이너 ID가 출력된다.
3. (5-B-03) 접속을 확인한다: `curl http://localhost:80` → 결과: `hello`가 출력된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `docker ps` | 컨테이너가 실행 중이다 | `fedora-nginx-web`이 `Up` 상태다 |
| 2 | `curl http://localhost:80` | 웹 서버가 응답한다 | `hello`가 출력된다 |

## 7. 복구

1. (7-01) 컨테이너를 중지하고 삭제한다: `docker stop fedora-nginx-web && docker rm fedora-nginx-web`
2. (7-02) 이미지를 삭제한다: `docker rmi nginxweb`
3. (7-03) 작업 디렉터리를 삭제한다: `cd .. && rm -r ./fedora`

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | `dockerfile.md`의 "Fedora in Rockey Docker"를 독립 MP로 분리. `MAINTAINER`와 개인 정보를 정정하고 `latest` 태그 CAUTION, 확인·복구 절차를 추가했다 |
