# DBSecurityAssignment

### \[취약한 Wordpress 서버 구축]

{% stepper %}
{% step %}
### Docker 환경 구축

설치 및 환경 준비를 진행합니다.
{% endstep %}

{% step %}
### Docker 환경 설정 파일

아래는 docker-compose 설정 예시입니다.

{% code title="docker-compose.yml" %}
```
```
{% endcode %}

```yml
version: '3.1'

services:

  wordpress:
    image: wordpress:4.7-php5.6-apache  # PHP 5.6과 워드프레스 4.7이 포함된 이미지
    restart: always
    ports:
      - 8080:80  # 워드프레스 컨테이너에서 포트 80을 호스트의 포트 8080으로 연결
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: exampleuser
      WORDPRESS_DB_PASSWORD: examplepass
      WORDPRESS_DB_NAME: exampledb
    volumes:
      - ./wordpress_data:/var/www/html  # 워드프레스 파일이 저장될 경로

  db:
    image: mariadb:10.5  # MariaDB 10.5 이미지 사용
    restart: always
    environment:
      MARIADB_DATABASE: exampledb
      MARIADB_USER: exampleuser
      MARIADB_PASSWORD: examplepass
      MARIADB_ROOT_PASSWORD: rootpass
    volumes:
      - ./db_data:/var/lib/mysql  # MariaDB 데이터베이스 파일 저장 경로

  phpmyadmin:
    image: phpmyadmin/phpmyadmin  # phpMyAdmin 컨테이너
    restart: always
    ports:
      - 8081:80  # phpMyAdmin 포트 8081에서 실행
    environment:
      PMA_HOST: db
      MYSQL_ROOT_PASSWORD: rootpass
```
{% endstep %}

{% step %}
### 실행

컨테이너 실행:

```sh
docker compose up -d
```
{% endstep %}

{% step %}
### Wordpress 설정

웹에서 워드프레스 초기 설정을 진행합니다.
{% endstep %}
{% endstepper %}

***

### \[DB 보안 설정]

{% stepper %}
{% step %}
#### 1-1. DB 접속

**1.1. DB 실행 여부 확인**

* mariadb:10.5 실행 확인

**1.2. DB 접속**

```sh
# docker exec -it <컨테이터_이름> mysql -u<DB계정> -p
docker exec -it wordpress-db-1 mysql -uroot -p
```

* 사용자: root
* 비밀번호: rootpass
{% endstep %}

{% step %}
#### 1-2. 웹 DB 접속

웹에서 phpMyAdmin 접속:

```
http://192.168.56.125:8081/
```

* 비밀번호는 이전과 동일
{% endstep %}

{% step %}
#### 2. 계정 생성

* 조건 1: test, 1234 - 192.168.56.125 에서 접속 가능하도록 사용자 생성 및 워드프레스 DB의 모든 권한 설정

```sql
grant all privileges on *.* to 'test'@'192.168.56.125' identified by '1234';
```

* 조건 2: local에서 접속 가능한 본인 이름의 사용자 생성

```sql
create user 'jaeho'@'localhost' identified by 'choa0306@@';
```

* 조건 3: test1, 9876 사용자에 대한 권한 설정 및 제거

```sql
grant all privileges on *.* to 'test1'@'%' identified by '9876';
```

(권한 제거)

```sql
revoke all on *.* from 'test1'@'%';
```

* 조건 4: test2, 4321 사용자의 패스워드를 5678로 변경

```sql
create user 'test2'@'localhost' identified by '4321';
```

```sql
ALTER USER 'test2'@'localhost' IDENTIFIED BY '5678';
```

* 변경사항 적용

```sql
flush privileges;
```
{% endstep %}

{% step %}
#### 3. 시스템 메모리 관리

호스트의 메모리와 스왑 확인:

```sh
grep MemTotal /proc/meminfo
grep SwapTotal /proc/meminfo
```
{% endstep %}

{% step %}
#### 4. DB 메모리 확인

**4.1. 명령어**

1. 메모리 설정 변수 확인:

```sql
SHOW VARIABLES LIKE '%buffer%';
```

2. 실제 사용량 확인:

```sql
SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool_bytes%';
```

* Innodb\_buffer\_pool\_bytes\_data: 실제 데이터가 차지하는 메모리(바이트)
* Innodb\_buffer\_pool\_bytes\_free: 사용 가능한 여유 메모리(바이트)
{% endstep %}

{% step %}
#### 4.2. PMM 사용

기본 설정:

* wordpress (192.168.56.125) = PMM-Agent
* PMM-server (192.168.56.126) = PMM-Server

1. PMM-server 구성
2. PMM-Agent 구성
3. node 연결

```sh
pmm-admin config --server-insecure-tls --server-url=https://admin:choa0306@@@192.168.56.126:443
```

4. pmm 계정 생성 (MariaDB에서 실행)

```sql
CREATE USER 'pmm'@'127.0.0.1' IDENTIFIED BY '1234' WITH MAX_USER_CONNECTIONS 10;
grant select, process, super, replication client, reload, show view on *.* to 'pmm'@'127.0.0.1';
grant select, update, drop, delete on performance_schema.* to 'pmm'@'127.0.0.1';
flush privileges;
show grants for 'pmm'@'127.0.0.1';
```

5. Agent 설정 추가 및 실행
{% endstep %}
{% endstepper %}

***

### \[WAF]

(섹션 비어 있음 — 필요 시 WAF 구성 내용을 추가하세요.)

***

## CTF\_Momentum2

### \[정보 수집]

스캐너 예시:

```sh
gobuster dir -w /usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-medium.txt -u http://192.168.56.128/ -x html,php,bak,txt,php.bak
```

Docker 설치 예시 (CentOS 기반 DNF):

```sh
sudo dnf remove docker \
                docker-client \
                docker-client-latest \
                docker-common \
                docker-latest \
                docker-latest-logrotate \
                docker-logrotate \
                docker-engine

# Docker의 공식 리포지터리 추가
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Docker 설치
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Docker 서비스 시작
sudo systemctl start docker

# Docker 부팅 시 자동 실행 설정
sudo systemctl enable docker
```

원터치 docker-compose 예시 (통합 구성):

{% code title="docker-compose.yml (원터치 예시)" %}
```yml
version: '3.1'

services:

  wordpress:
    image: wordpress:4.7-php5.6-apache  # PHP 5.6과 워드프레스 4.7이 포함된 이미지
    container_name: wordpress
    restart: always
    ports:
      - 8080:80  # 워드프레스 컨테이너에서 포트 80을 호스트의 포트 8080으로 연결
    environment:
      WORDPRESS_DB_HOST: wordpress_db
      WORDPRESS_DB_USER: root
      WORDPRESS_DB_PASSWORD: rootpass
      WORDPRESS_DB_NAME: WordpressDB
    networks:
      - wp_network
    volumes:
      - ./wordpress_data:/var/www/html  # 워드프레스 파일이 저장될 경로

  wordpress_db:
    image: mariadb:10.5  # MariaDB 10.5 이미지 사용
    container_name: wordpress_db
    restart: always
    environment:
      MARIADB_DATABASE: WordpressDB
      MARIADB_USER: root
      MARIADB_PASSWORD: rootpass
      MARIADB_ROOT_PASSWORD: rootpass
    networks:
      - wp_network
    volumes:
      - ./db_data:/var/lib/mysql  # MariaDB 데이터베이스 파일 저장 경로

  phpmyadmin:
    image: phpmyadmin/phpmyadmin  # phpMyAdmin 컨테이너
    restart: always
    ports:
      - 8081:80  # phpMyAdmin 포트 8081에서 실행
    environment:
      PMA_HOST: wordpress_db
      MYSQL_ROOT_PASSWORD: rootpass

  waf-proxy:
    build: ./waf-proxy 
    container_name: waf-proxy
    ports: 
      - "8080:80" 
    networks: 
      - wp_network 

  pmm-client: 
    image: percona/pmm-client:latest 
    container_name: pmm-client 
    environment: 
      PMM_SERVER: "192.168.56.126" # PMM 서버의 IP 주소 
    command: /bin/bash -c "while true; do sleep 1000; done"
    networks: 
      - wp_network

networks: 
  wp_network: 
    driver: bridge
```
{% endcode %}

* selinux를 끄는 등의 호스트 설정이 필요할 수 있습니다.
