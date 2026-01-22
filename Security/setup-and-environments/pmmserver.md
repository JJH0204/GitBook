# PMMServer

Percona Monitoring & Management

## 설치 방법

* 소스 코드
* 패키지 관리자 (클라이언트)
* docker (서버)

## 서버 설치

{% stepper %}
{% step %}
### docker 설치

```sh
dnf update -y
dnf install -y docker
```
{% endstep %}

{% step %}
### 이미지 설치

```sh
docker pull percona/pmm-server:latest
```

```sh
docker images
```
{% endstep %}

{% step %}
### 볼륨 생성

```sh
docker volume create pmm-data
```
{% endstep %}

{% step %}
### 실행 중인 도커 이미지 확인

```sh
docker ps
docker ps -a
```
{% endstep %}

{% step %}
### 이미지 실행

```sh
docker run --detach --restart always --publish 443:443 -v pmm-data:/srv --name pmm-server docker.io/percona/pmm-server:latest
```

* 기본 계정: admin/admin
{% endstep %}
{% endstepper %}

## Agent 설정

{% stepper %}
{% step %}
### pmm 패키지 설치

```sh
dnf install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm
dnf install -y pmm2-client
pmm-admin --version
```
{% endstep %}

{% step %}
### Node 등록

```sh
pmm-admin config --server-insecure-tls --server-url=https://admin:choa0306@@@192.168.56.123:443
```
{% endstep %}

{% step %}
### DB 서버

#### pmm agent 설정 파일 편집

```sh
vi /usr/local/percona/pmm2/config/pmm-agent.yaml
```

#### DB 설치 여부 확인

```sh
dnf install -y mariadb
systemctl start mariadb
mysql -u root -p
```

#### pmm 계정 생성

```sql
CREATE USER 'pmm'@'127.0.0.1' IDENTIFIED BY '1234' WITH MAX_USER_CONNECTIONS 10;
```

#### 계정 권한 할당

```sql
grant select, process, super, replication client, reload, show view on *.* to 'pmm'@'127.0.0.1';
grant select, update, drop, delete on performance_schema.* to 'pmm'@'127.0.0.1';
flush privileges;
show grants for 'pmm'@'127.0.0.1';
```

#### 설정 파일 내용 추가 (예시)

```sh
vi /usr/local/percona/pmm2/config/pmm-agent.yaml
```

```yaml
slow_query_log = ON
slow_query_log_file = /log/slow_query.log
long_query_time = 1
log_output = FILE
performance_schema = ON
```

#### pmm-server 연동

```sh
pmm-admin add mysql --query-source=perfschema --username=pmm --password=1234
```
{% endstep %}

{% step %}
#### 예시: 원격 호스트 등록 및 Docker 네트워크 예제

```sh
pmm-admin add mysql --query-source=perfschema --username=pmm --password=1234 --host=wordpress-db-1 --port=3306

docker network create mynetwork
docker run -d --name mariadb --network=mynetwork -e MYSQL_ROOT_PASSWORD=rootpass mariadb
docker run -d --name pmm-client --network=mynetwork percona/pmm-client:latest

docker start wordpress-db-1
```
{% endstep %}
{% endstepper %}
