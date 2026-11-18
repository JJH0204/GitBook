# Dockerfile 작성법 및 실습

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-DKR-010-REF |
| 유형 | REF (지시어 표) |
| 목적 | Dockerfile의 구성과 지시어 형식, 사용 예를 찾는다 |
| 확인 상태 | 미검증 (원본 페이지와 Dockerfile 공식 문서 지식을 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 실습 3건과 쿠버네티스 배포 명령은 파일을 나눴다. 실습은 CLD-DKR-011-MP ~ 013-MP, 배포 명령은 CLD-DKR-014-REF를 따른다. 원본의 DevOps 순환 설명은 [도커 핵심 이론](dockertheory.md)(CLD-DKR-002-DO)으로 옮겼다.
{% endhint %}

## 1. Dockerfile 구성

| 번호 | 항목 | 내용 |
|---|---|---|
| 1 | 정의 | 이미지를 빌드할 때 단계별로 필요한 명령과 설정을 적은 파일이다. 운영체제, 버전, 환경 변수, 파일 시스템, 사용자 등을 정의한다 |
| 2 | 파일명 | 확장자 없이 `Dockerfile`이다. `docker build`는 이 이름의 파일을 자동으로 찾는다 |
| 3 | 다른 이름 사용 | `docker build -f <파일명> .`으로 원하는 이름의 파일을 쓴다 |
| 4 | 시작 | `FROM` 지시어로 시작한다. 이후 지시어를 위에서 아래로 순서대로 실행한다 |
| 5 | 형식 | `지시어 인자`. `#`으로 시작하는 줄은 주석이다 |

```dockerfile
# 주석
지시어 인자

# --- 예시 ---
FROM ubuntu:22.04
```

## 2. 지시어 표

| 지시어 | 형식 | 설명 | 예 |
|---|---|---|---|
| `FROM` | `FROM <이미지>:<태그>` | 기반(base) 이미지를 지정한다. 보통 운영체제나 런타임의 공식 이미지를 Docker Hub에서 가져온다 | `FROM ubuntu:18.04` |
| `ENV` | `ENV <변수명> <값>` 또는 `ENV <변수명>=<값>` | 환경 변수를 지정한다. 파일 안에서 `$변수명` 또는 `${변수명}`으로 쓴다 | `ENV PYTHON_VERSION=3.11.2` |
| `RUN` | `RUN <명령어>` 또는 `RUN ["명령어", "인자1", "인자2"]` | 이미지를 빌드할 때 실행한다. 패키지 설치, 권한 설정 등에 쓴다. 결과가 이미지에 반영된다 | `RUN apt-get update`<br>`RUN ["/bin/bash", "-c", "echo hello"]` |
| `COPY` | `COPY <src> <dest>` | 빌드 컨텍스트의 파일이나 디렉터리를 이미지의 `dest`로 복사한다 | `COPY . /app` |
| `ADD` | `ADD <src> <dest>` | `COPY`와 같이 복사하며, `src`에 URL을 쓸 수 있고 압축 파일(tar)은 자동으로 풀어 넣는다 | `ADD index.html /var/www/html` |
| `WORKDIR` | `WORKDIR <디렉터리>` | 이후 지시어를 실행할 작업 디렉터리를 지정한다. 리눅스의 `cd`와 비슷하다 | `WORKDIR /home/user` |
| `USER` | `USER <사용자명\|UID>[:<그룹명\|GID>]` | 이후 명령을 실행할 사용자나 그룹을 지정한다. 사용자는 미리 만들어져 있어야 한다 | `USER <사용자명>` |
| `EXPOSE` | `EXPOSE <포트>[/<프로토콜>]` | 컨테이너가 사용하는 포트와 프로토콜(TCP, UDP)을 문서화한다. 프로토콜을 생략하면 TCP다 | `EXPOSE 80/tcp` |
| `ENTRYPOINT` | `ENTRYPOINT ["명령어", "인자1"]` | 컨테이너 시작 시 실행할 명령을 지정한다 | `ENTRYPOINT ["echo", "hello"]` |
| `CMD` | `CMD ["명령어", "인자1"]` 또는 `CMD ["인자1", "인자2"]` | 컨테이너 시작 시 실행할 기본 명령을 지정하거나, `ENTRYPOINT`에 넘길 기본 인자를 지정한다 | `CMD ["echo", "hello"]` |
| `LABEL` | `LABEL <키>=<값>` | 이미지에 메타데이터(레이블)를 지정한다 | `LABEL maintainer="<이름>"` |

원본의 지시어 요약에는 `RUN`, `CMD`, `LABEL`, `EXPOSE`, `ENV`, `ADD`/`COPY`, `WORKDIR`이 있었다. 위 표에 모두 포함했다. 원본에서 `WORLDIR`로 적힌 철자는 `WORKDIR`로 정정했다.

## 3. 구분이 필요한 지시어

### 3.1 `COPY`와 `ADD`

| 비교 항목 | `COPY` | `ADD` |
|---|---|---|
| 로컬 파일·디렉터리 복사 | 가능 | 가능 |
| URL에서 받기 | 불가 | 가능 |
| tar 압축 자동 해제 | 안 함 | 함 |
| 권장 | 단순 복사에는 `COPY`를 쓴다 | URL 내려받기나 자동 해제가 필요할 때만 쓴다 |

### 3.2 `CMD`와 `ENTRYPOINT`

| 비교 항목 | `CMD` | `ENTRYPOINT` |
|---|---|---|
| 역할 | 기본 실행 명령 또는 기본 인자 | 고정 실행 명령 |
| 여러 개 작성 | 마지막 `CMD`만 쓴다 | 마지막 `ENTRYPOINT`만 쓴다 |
| `docker run <이미지> <인자>` | `CMD`가 무시되고 `<인자>`가 명령이 된다 | `<인자>`가 `ENTRYPOINT`의 인자로 붙는다 |

`ENTRYPOINT`와 `CMD`를 함께 쓴 예다.

```dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]
```

| 실행 | 실제 실행 명령 |
|---|---|
| `docker run <이미지>` | `python app.py` |
| `docker run <이미지> test.py` | `python test.py` |

{% hint style="warning" %}
CAUTION: `EXPOSE`는 포트를 문서화할 뿐 호스트 포트를 열지 않는다. 호스트에서 접속하려면 `docker run -p <호스트 포트>:<컨테이너 포트>`를 쓴다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `ENV`와 `COPY`로 비밀번호, 토큰, `.env` 내용을 이미지에 넣지 않는다. 이미지를 공유하면 그 값도 함께 공유된다.
{% endhint %}

## 4. 실습 문서

| Task ID | 문서 | 내용 |
|---|---|---|
| CLD-DKR-011-MP | [Dockerfile 실습: Nginx 웹 페이지 이미지](dockerfile-practice-nginx.md) | `nginx:alpine` 기반 이미지를 v1, v2로 빌드한다 |
| CLD-DKR-012-MP | [Dockerfile 실습: Ubuntu Apache 이미지](dockerfile-practice-apache.md) | Ubuntu 기반 Apache 이미지를 빌드한다 |
| CLD-DKR-013-MP | [Dockerfile 실습: Fedora Nginx 이미지](dockerfile-practice-fedora.md) | Fedora 기반 Nginx 이미지를 빌드한다 |
| CLD-DKR-014-REF | [Dockerfile 이미지 쿠버네티스 배포 명령](dockerfile-k8s-deploy.md) | 빌드한 이미지를 `kubectl`로 배포한다 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [도커 이미지 빌드](docker_build.md) | CLD-DKR-009-MP | `docker build` 절차 |
| [Dockerfile 공식 문서](https://docs.docker.com/engine/reference/builder/) | - | 외부 문서 |

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 지시어 설명을 표로 재구성. `COPY`/`ADD`, `CMD`/`ENTRYPOINT` 비교와 `EXPOSE`, 비밀값 CAUTION을 추가. 실습 3건과 `kubectl` 명령은 별도 파일로 분리했고 DevOps 순환은 CLD-DKR-002-DO로 옮겼다 |
