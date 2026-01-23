# docker hub image share

WordPress가 구동 중인 Ubuntu 컨테이너를 Docker Hub에 공유하려면, 컨테이너의 상태를 Docker 이미지로 저장하고 이를 Docker Hub에 푸시하면 됩니다. 아래는 단계별 방법입니다.

{% stepper %}
{% step %}
### Docker Hub 계정 생성 및 로그인

#### Docker Hub 계정 생성

* https://hub.docker.com/ 에 접속해 계정을 생성.

#### Docker CLI에서 로그인

Docker CLI에서 Docker Hub에 로그인:

```bash
docker login
```

* Docker Hub 사용자 이름과 비밀번호를 입력.
{% endstep %}

{% step %}
### 컨테이너를 이미지로 저장

WordPress가 구동 중인 Ubuntu 컨테이너를 Docker 이미지로 저장하려면 아래 절차를 따르세요.

#### 실행 중인 컨테이너 확인

현재 실행 중인 컨테이너 확인:

```bash
docker ps
```

* 여기서 WordPress 컨테이너의 컨테이너 ID 또는 이름을 확인.

#### 컨테이너를 이미지로 저장

`docker commit` 명령어를 사용해 컨테이너를 이미지로 변환:

```bash
docker commit <컨테이너 ID> <Docker Hub 사용자 이름>/<이미지 이름>:<태그>
```

예시:

```bash
docker commit abc123 mydockerhubuser/ubuntu-wordpress:latest
```
{% endstep %}

{% step %}
### 이미지 확인 및 테스트

이미지가 제대로 생성되었는지 확인:

```bash
docker images
```

이미지를 테스트하려면 새 컨테이너를 실행:

```bash
docker run -it -p 8080:80 mydockerhubuser/ubuntu-wordpress:latest
```
{% endstep %}

{% step %}
### Docker Hub에 이미지 업로드

이미지를 Docker Hub로 푸시:

```bash
docker push <Docker Hub 사용자 이름>/<이미지 이름>:<태그>
```

예시:

```bash
docker push mydockerhubuser/ubuntu-wordpress:latest
```
{% endstep %}

{% step %}
### Docker Hub에서 확인

* Docker Hub 웹사이트에 로그인 후, Repositories에서 업로드한 이미지를 확인.
{% endstep %}

{% step %}
### 다른 사용자가 사용하는 방법

다른 사용자는 아래 명령으로 이미지를 다운로드하고 사용할 수 있음:

```bash
docker pull <Docker Hub 사용자 이름>/<이미지 이름>:<태그>
```

예시:

```bash
docker pull mydockerhubuser/ubuntu-wordpress:latest
```

다운로드한 이미지를 기반으로 컨테이너 실행:

```bash
docker run -it -p 8080:80 mydockerhubuser/ubuntu-wordpress:latest
```
{% endstep %}
{% endstepper %}

주의사항:

{% stepper %}
{% step %}
### 이미지 크기 최적화

* 불필요한 파일이나 캐시를 정리해서 이미지 크기를 최소화하세요.

예시:

```bash
apt-get clean && rm -rf /var/lib/apt/lists/*
```
{% endstep %}

{% step %}
### 비밀번호와 민감한 정보 확인

* 이미지에 데이터베이스 비밀번호나 환경 변수가 하드코딩되지 않도록 주의하세요.
{% endstep %}

{% step %}
### Dockerfile 사용 권장

* 이미지 공유를 위해 Dockerfile을 사용하는 것이 일반적입니다. 이를 통해 이미지 생성 과정을 재현 가능하게 만들 수 있습니다.
{% endstep %}
{% endstepper %}

이 과정을 통해 WordPress가 실행되는 Ubuntu 컨테이너를 Docker Hub에 공유할 수 있습니다. 추가로 궁금한 점이 있으면 알려주세요! 😊
