# ubuntu wordpress docker

아래는 Ubuntu 기반의 단일 컨테이너에서 WordPress와 MariaDB를 함께 구성하는 방법을 GitBook에 적합하게 정리한 문서야. 원본 구조와 내용을 유지하면서, 단계별 설치를 stepper 블록으로 정리했고 장단점은 좌우 컬럼으로 배치했어.

{% stepper %}
{% step %}
### Ubuntu 기반 Docker 컨테이너 생성

#### 컨테이너 생성 및 진입

먼저 Ubuntu 기반의 Docker 컨테이너를 생성하고 실행:

```bash
docker run -it --name ubuntu-wordpress -p 8080:80 ubuntu:latest
```

컨테이너가 실행되면 내부로 들어가게 돼. 만약 컨테이너를 생성한 후 다시 진입하려면:

```bash
docker exec -it ubuntu-wordpress bash
```
{% endstep %}

{% step %}
### 필요한 패키지 설치

컨테이너 내부에서 아래 명령어로 Apache, PHP, MariaDB 등을 설치:

```bash
apt-get update
apt-get install -y apache2 php php-mysql mariadb-server curl
```
{% endstep %}

{% step %}
### MariaDB 설정

MariaDB 서비스를 시작하고 데이터베이스를 설정:

```bash
service mariadb start

# MariaDB 설정
mysql -uroot <<EOF
CREATE DATABASE wp_database;
CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'wp_password';
GRANT ALL PRIVILEGES ON wp_database.* TO 'wp_user'@'localhost';
FLUSH PRIVILEGES;
EOF
```

이제 `wp_database` 데이터베이스와 `wp_user` 사용자가 생성되었어.
{% endstep %}

{% step %}
### WordPress 설치

WordPress를 다운로드하고 Apache 서버 디렉토리에 배치:

```bash
curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz
tar -xzf wordpress.tar.gz -C /var/www/html
rm wordpress.tar.gz
chown -R www-data:www-data /var/www/html/wordpress
chmod -R 755 /var/www/html/wordpress
```
{% endstep %}

{% step %}
### Apache 서버 시작

Apache 서버를 시작:

```bash
service apache2 start
```
{% endstep %}

{% step %}
### WordPress 초기 설정

1. 브라우저에서 `http://<서버 IP>:8080/wordpress`에 접속.
2. WordPress 설치 화면에서 데이터베이스 정보를 입력:
   * 데이터베이스 이름: `wp_database`
   * 사용자 이름: `wp_user`
   * 비밀번호: `wp_password`
   * 데이터베이스 호스트: `localhost`
3. 설정을 완료하고 관리자 계정을 생성.
{% endstep %}

{% step %}
### 컨테이너 유지 및 관리

#### 컨테이너 종료 후 재시작

컨테이너를 중지하거나 재시작하려면:

```bash
docker stop ubuntu-wordpress
docker start ubuntu-wordpress
```

#### 컨테이너 재진입

컨테이너 내부로 다시 접속하려면:

```bash
docker exec -it ubuntu-wordpress bash
```
{% endstep %}
{% endstepper %}

{% columns %}
{% column %}
#### 장점

* 하나의 컨테이너로 관리가 단순해짐.
* 설정 및 리소스 사용을 통합하여 관리 가능.
{% endcolumn %}

{% column %}
#### 단점

* 한 컨테이너에서 두 가지 서비스(MariaDB, Apache)가 실행되므로 충돌 가능성 증가.
* 컨테이너가 중지되면 WordPress와 데이터베이스가 모두 다운됨.
{% endcolumn %}
{% endcolumns %}

{% hint style="warning" %}
단일 컨테이너에 여러 서비스를 실행하면 관리 및 디버깅이 어려워지고, 서비스 간 장애 전파(한 서비스 장애가 전체에 영향)를 피하기 어려워. 운영 환경에서는 보통 서비스별로 컨테이너를 분리하는 것을 권장해.
{% endhint %}

다른 질문이나 추가로 Dockerfile, systemd-less 실행(예: supervisord), 또는 볼륨/백업 설정 예시가 필요하면 알려줘! 😊
