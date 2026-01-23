# Dockerfile

* 도커 이미지를 빌드하는 데 단계적으로 필요한 명령어와 모든 설정이 정의된 파일
* 도커 이미지를 빌드하기 위해서 꼭 필요하다.
* 운영체제와 버전, 환경 변수, 파일 시스템, 사용자 등 정의한다.

## Dockerfile 구성

* 도커 파일의 파일명은 확장자 없이 Dockerfile이다.
* [Docker\_Build](/broken/pages/3967193d0af3381c948781c85245cca5f5a71ac0) 명령어를 사용하면 자동으로 이름이 Dockerfile인 파일을 찾아 이미지를 빌드한다.
* -f 옵션으로 원하는 이름의 도커 파일을 사용할 수도 있다.
* dockerfile 구성

```dockerfile
# 주석
명령어 인자

# --- 예시 ---
FROM ubuntu:22.04
```

## Dockerfile 명령어

* Docker file은 FROM 명령어로 시작한다.
* 이후 순서대로 명령어를 실행한다.
* [도커 공식 문서](https://docs.docker.com/engine/reference/builder/)

### FROM

`FROM 이미지:태그`\
생성할 이미지의 기반이 되는 base 이미지를 지정합니다. 보통 사용할 운영체제의 공식 이미지를 Dockerhub에서 가져옵니다.

➡️ `FROM ubuntu:18.04`

### ENV

`ENV 변수명 값` or `ENV 변수명=값`\
Dockerfile 내에서 사용하는 환경 변수를 지정합니다. 파일 내에서 변수는 `$변수명` 혹은 `${변수명}` 형태로 표현합니다.

➡️ `ENV PYTHON_VERSION 3.11.2` → `.../python/$PYTHON_VERSION/...`

### RUN

`RUN 명령어` or `RUN ["명령어", "인자1", "인자2"]`\
이미지를 빌드할 때 실행할 명령어를 작성합니다. 필요한 패키지를 설치하거나, 파일 권한 설정 등의 작업을 수행합니다.

➡️ `RUN apt-get update`\
➡️ `RUN ["/bin/bash", "-c", "echo hello"]`

### COPY

`COPY <src> <dest>`\
src 파일이나 디렉토리를 이미지 파일 시스템의 dest로 복사합니다.

➡️ `COPY . /app`

### ADD

`ADD <src> <dest>`\
src 파일이나 디렉토리, URL을 이미지 파일 시스템의 dest로 복사합니다.

➡️ `ADD . /app`

### WORKDIR

`WORKDIR 디렉토리`\
Dockerfile 내의 명령을 수행할 작업 디렉토리를 지정합니다. 리눅스의 `cd` 명령어와 유사합니다.

➡️ `WORKDIR /home/user`

### USER

`USER 사용자명|UID` or `USER 사용자명|UID[:그룹명|GID]`\
명령을 수행할 사용자 혹은 그룹을 지정합니다.

➡️ `USER $username`

### EXPOSE

`EXPOSE 포트` or `EXPOSE 포트/프로토콜`\
컨테이너가 실행 중일 때 들어오는 네트워크 트래픽을 리슨할 포트와 프로토콜을 지정합니다. 사용할 수 있는 프로토콜은 TCP와 UDP이며, 기본적으로 TCP가 지정됩니다.

➡️ `EXPOSE 80/tcp`

### ENTRYPOINT

`ENTRYPOINT 명령어 인자1 인자2` or `ENTRYPOINT ["명령어", "인자1", "인자2"]`\
컨테이너가 실행될 때 수행할 명령어를 지정합니다.

➡️ `ENTRYPOINT ["echo", "hello"]`

### CMD

`CMD 명령어 인자1 인자2` or `CMD ["명령어", "인자1", "인자2"]` or `CMD ["인자1", "인자2"]`\
컨테이너가 실행될 때 수행할 명령어를 지정하거나, `ENTRYPOINT` 명령어에 인자를 전달합니다.

➡️ `CMD ["echo", "hello"]`

* Dockerfile 내에 `CMD` 명령이 여러 개 존재하면 마지막 `CMD`를 사용합니다.
* `docker run`의 인자를 작성하면 `CMD` 명령어는 무시됩니다. `ENTRYPOINT`가 있는 경우, `docker run`의 인자가 `ENTRYPOINT`의 인자로 들어갑니다.

예: Dockerfile이 아래과 같을 때,

* `docker run [이미지]`로 컨테이너를 실행하면 `python app.py`를 실행합니다.
* `docker run [이미지] test.py`로 컨테이너를 실행하면 `python test.py`를 실행합니다.

```shell
ENTRYPOINT ["python"]
CMD ["app.py"]
```

## DevOps

{% stepper %}
{% step %}
### 기획, 개발

요구사항 정의 및 애플리케이션 개발 수행.
{% endstep %}

{% step %}
### CI(빌드, 테스트), CD(배포)

코드 변경 시 자동 빌드, 테스트, 배포 파이프라인 실행.
{% endstep %}

{% step %}
### 운영, 모니터링

배포된 서비스 운영 및 성능/장애 모니터링.
{% endstep %}

{% step %}
### 수정 -> 반복

발생한 피드백 또는 버그를 수정하고 다시 1단계로 돌아가 반복.
{% endstep %}
{% endstepper %}

## Dockerfile 문법

```
# dockerfile command
FROM [image name]      # 베이스 이미지 pulling
RUN                    # 결과를 이미지 반영
CMD                    # 컨테이너 시작시 실행되는 명령어
LABEL                  # 이미지에 레이블을 지정
EXPOSE                 # 컨테이너 에서 노출하는 포트를 지정
ENV                    # 환경변수 설정
ADD / COPY             # 이미지에 파일 복사
WORLDIR                # 명령어를 실행할 때 작업 디렉토리 설정
```

## Dockerfile Practice in Rockey Docker

my-web-app v1

{% code title="Dockerfile (my-web-app-v1)" %}
```my-web-app-v1
# mkdir ./myweb && cd ./myweb
# vi index.html
	<!DOCTYPE html>
	<html>
	<head>
	    <title>Welcome my web!</title>
	</head>
	<body>
	    <h1>Hello World!</h1>
	</body>
	</html>

# vi Dockerfile
	# Use an official Nginx runtime as a parent image
	FROM nginx:alpine

	# Copy the updated web page to the container
	COPY index.hmtl /usr/share/nginx/html

# docker build -t my-web-app .
# docker images
> REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
> my-web-app   latest    438c3152c8d1   33 minutes ago   52.5MB

# docker run -d -p 80:80 --name my-web-app my-web-app

# docker container inspect [container-id]
```
{% endcode %}

my-web-app v2

{% code title="Dockerfile (my-web-app-v2)" %}
```my-web-app-v2
# vi index.html
	<!DOCTYPE html>
	<html>
	<head>
	    <title>Welcome my web app!</title>
	</head>
	<body>
	    <h1>Hello World! Hello World!</h1>
	</body>
	</html>

# vi Dockerfile
	# Use an official Nginx runtime as a parent image
	FROM nginx:alpine

	# Copy the updated web page to the container
	COPY index.hmtl /usr/share/nginx/html

# docker build -t my-web-app:second .
# docker images
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
my-web-app   second    ddd4afede45f   23 seconds ago   52.5MB
my-web-app   latest    438c3152c8d1   33 minutes ago   52.5MB

# docker run -d -p 80:80 --name my-web-app-v2 my-web-app:second
```
{% endcode %}

업데이트 된 이미지를 k8s를 통해 배포\
k8s cluster, kubectl cli 명령어 사용 필요

* `kubectl create deployment my-web-app --image=my-web-app:latest`: create image
* `kubectl expose --type=LoadBalancer --port:80 --target:80`
* `kubectl get services`
* `kubectl set image deployment/my-web-app my-web-app=my-web-app:v2`: version upgrade
* `kubectl rollout status deployment/my-web-app`
* `kubectl delete deployment/my-web-app`: delete image
* `kubectl service my-web-app`: service start

## Ubuntu Apache in Rockey Docker

```
# mkdir ./ubuntu && cd ./ubuntu
# touch index.html
# vi Dockerfile
```

{% code title="Dockerfile (Ubuntu Apache)" %}
```dockerfile
# Ubuntu 기반 apache2 Dockerfile
FROM ubuntu:18.04

# 유지보수자 정보
MAINTAINER jinyeong <jinyeong@kit.com>

# 시스템 업데이트 및 apache2 설치
RUN apt -y update && install -y apache2

# 웹 파일 추가
ADD index.html /var/www/html

# 작업 디렉토리 설정
WORKDIR /var/www/html

# 기본 페이지 확인용 파일 생성
RUN ["/bin/sh", "-c", "echo hello >> index.html"]

# apache2를 외부에서 접근 가능하도록 포트 노출
EXPOSE 80

# apache2 실행 명령 설정
CMD ["apache2ctl", "-D", "FOREGROUND"]
```
{% endcode %}

```
# docker build -t apacheweb .
# docker run -d -p 80:80 --name ubuntu-apache-web apacheweb
```

## Fedora in Rockey Docker

```
# mkdir ./fedora && cd ./fedora
# touch index.html
# vi Dockerfile
```

{% code title="Dockerfile (Fedora Nginx)" %}
```dockerfile
# Fedora 기반 Nginx Dockerfile
FROM fedora

# 유지보수자 정보
MAINTAINER jinyeong <jinyeong@kit.com>

# 시스템 업데이트 및 nginx 설치
RUN dnf -y update && dnf -y install nginx

# 웹 파일 추가
ADD index.html /usr/share/nginx/html

# 작업 디렉토리 설정
WORKDIR /usr/share/nginx/html

# 기본 페이지 확인용 파일 생성
RUN ["/bin/sh", "-c", "echo hello >> index.html"]

# Nginx를 외부에서 접근 가능하도록 포트 노출
EXPOSE 80

# Nginx 실행 명령 설정
CMD ["nginx", "-g", "daemon off;"]
```
{% endcode %}

```
# docker build -t nginxweb .
# docker run -d -p 80:80 --name fedora-nginx-web nginxweb
```
