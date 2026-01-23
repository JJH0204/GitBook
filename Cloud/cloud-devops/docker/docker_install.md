# Docker\_install

* 우분투 리눅스 22.04에 [도커 엔진 설치](https://docs.docker.com/engine/install/ubuntu/)후 [도커](/broken/pages/f2e496ba96d43b71584a986e02ec027673a84321)를 사용

## 도커 설치

아래 명령어를 순서대로 실행하여 도커 엔진을 설치한다.

{% stepper %}
{% step %}
### 준비: 패키지 목록 갱신 및 필수 패키지 설치

```bash
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg
```
{% endstep %}

{% step %}
### Docker GPG 키 추가

```bash
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```
{% endstep %}

{% step %}
### Docker 저장소 설정

```bash
echo \
  "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  \"$(. /etc/os-release && echo \"$VERSION_CODENAME\")\" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
{% endstep %}

{% step %}
### Docker 엔진 및 관련 패키지 설치

```bash
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
{% endstep %}
{% endstepper %}

## 도커 설치 확인

```bash
sudo docker run hello-world
```

* "Hello from Docker!"가 출력되면 도커 엔진이 설치된 것이다.

## 관련 문서

* [Docker\_Build](/broken/pages/3967193d0af3381c948781c85245cca5f5a71ac0)
