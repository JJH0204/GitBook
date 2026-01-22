# zabbix

* [공식사이트](https://www.zabbix.com/)

### 구축과정

{% stepper %}
{% step %}
### 사전 업데이트 및 필수 패키지 설치

```bash
dnf update -y && dnf install -y httpd php php-mysqli mariadb-server
dnf install -y php-fpm # fpm-fcgi
```
{% endstep %}

{% step %}
### 외부 저장소 추가

```bash
rpm -Uvh https://repo.zabbix.com/zabbix/7.0/alma/9/x86_64/zabbix-release-7.0-2.el9.noarch.rpm && dnf clean all
```
{% endstep %}

{% step %}
### Zabbix 관련 프로그램 설치 및 서비스 설정

```bash
dnf install -y zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent

firewall-cmd --permanent --add-service=http
firewall-cmd --reload

systemctl start httpd mariadb
systemctl enable httpd mariadb

mysql_secure_installation
```
{% endstep %}

{% step %}
### DB 초기 세팅

```sql
# DB 접속
mysql -u root -p

# DB 생성
create database zabbix_db character set utf8 collate utf8_bin;

# 사용자 생성
create user 'zabbix_user'@'localhost' identified by '비밀번호';

# 사용자 권한 설정
grant all privileges on zabbix_db.* to 'zabbix_user'@'localhost' with grant option;

# 사용자에게 추가 지급할 권한(로그 생성 권한)
set global log_bin_trust_function_creators = 1;

# 권한 적용
flush privileges;
```
{% endstep %}

{% step %}
### DB 생성(스키마 추가)

```bash
cd /usr/share/zabbix-sql-scripts/mysql/

# DB 생성 스크립트 실행하며 함께 설정 값 전달
zcat ./server.sql.gz | mysql --default-character-set=utf8mb4 -u[사용자 이름] -p'사용자 비번' [적용할 DB]

# DB 확인
mysql -u root -p
show databases; use zabbix_db; show tables;
```
{% endstep %}

{% step %}
### Zabbix 환경설정

```bash
cd /etc/zabbix

# 서버 설정 파일 수정
vi zabbix_server.conf

# 파일 내에서 아래 값들 수정
# 107 DBName=zabbix_db
# 123 DBUser=[DB 사용자 이름]
# 131 DBPassword=[사용자 패스워드]
:wq
```

에이전트 설정:

```bash
# 에이전트 파일 수정
vi zabbix_agentd.conf
# 117 Server=127.0.0.1
# 171 ServerActive=127.0.0.1
# 182 Hostname=Zabbix server
:wq
```

서비스 시작/활성화:

```bash
systemctl start zabbix-server zabbix-agent
systemctl enable zabbix-server zabbix-agent
systemctl restart httpd php-fpm
```
{% endstep %}

{% step %}
### PHP 설정 (Zabbix 웹 연동)

```bash
vi /etc/php-fpm.d/www.conf

# 아래 항목들을 추가
php_value[max_execution_time] = 300
php_value[memory_limit] = 128M
php_value[post_max_size] = 16M
php_value[upload_max_filesize] = 2M
php_value[max_input_time] = 300
php_value[max_input_vars] = 10000
php_value[always_populate_raw_post_data] = -1
php_value[data.timezone] = Asia/Seoul
:wq

systemctl restart zabbix-agent httpd php-fpm
```
{% endstep %}

{% step %}
### Zabbix 웹 파일 배치 (httpd 루트에 복사)

```bash
cd /usr/share/zabbix
ls

mkdir /var/www/html/zabbix
cp -R /usr/share/zabbix/* /var/www/html/zabbix
cd /var/www/html/zabbix
ls
```

웹 접속:

* 브라우저에서: http://IP/zabbix

스크린샷: &#x20;

* 서버와 DB가 같은 장치에 설치되어 있는 경우 포트는 0 가능 &#x20;
* 설정에 문제가 있다면 /etc/zabbix/web/zabbix.conf.php 에서 수정 가능&#x20;

기본 로그인:

* id: Admin
* pw: zabbix
{% endstep %}
{% endstepper %}

### 인터페이스

* SNMP를 통해 Agent와 NMS가 통신
* 이때 Agent-d 사용
* Zabbix는 SNMP를 개선한 zbx를 사용&#x20;

### Agent 추가

다운로드 페이지:

* https://www.zabbix.com/download\_agents&#x20;
* 에이전트 추가를 위한 파일 설치
* 운영체제와 환경에 맞는 파일 설치

{% tabs %}
{% tab title="Windows" %}
#### Windows 설정 요약

스크린샷(설정 파일 예시):&#x20;

* 172.0.0.1 → Zabbix 서버 IP로 수정
* ListenPort 주석 해제 (설정 파일에 따라)
* Hostname → 원하는 이름으로 수정

서비스 실행:

* zabbix\_agentd.exe 실행(관리자 권한)&#x20;
* 서비스에서 Zabbix 서비스 시작&#x20;

방화벽 규칙 추가(Windows 방화벽):&#x20;

* 포트: TCP 10050 허용

서버 측 포트 개방(예: firewalld):

```bash
firewall-cmd --permanent --add-port=10051/tcp
firewall-cmd --reload
```
{% endtab %}

{% tab title="CentOS / RHEL (Alma 등)" %}
#### CentOS 계열 에이전트 설치 및 설정

```bash
cd /etc/yum.repos.d/
rpm -Uvh https://repo.zabbix.com/zabbix/7.0/alma/9/x86_64/zabbix-release-7.0-2.el9.noarch.rpm
dnf clean all
dnf install -y zabbix-agent
vi /etc/zabbix/zabbix_agentd.conf

systemctl start zabbix-agent
systemctl enable zabbix-agent
firewall-cmd --permanent --add-port=10050/tcp
firewall-cmd --reload
```

설정 파일에서 Server, ServerActive, Hostname 등을 적절히 수정하세요.
{% endtab %}

{% tab title="Ubuntu / Debian" %}
#### Ubuntu 계열 에이전트 설치 및 설정

레포지토리 추가:

```bash
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu24.04_all.deb
dpkg -i ./zabbix-release_7.0-2+ubuntu24.04_all.deb
```

에이전트 설치:

```bash
apt update
apt install -y zabbix-agent
```

설정 파일 수정:

```bash
vi /etc/zabbix/zabbix_agentd.conf
# Server=#zabbix 서버 ip
# ServerActive=#zabbix 서버 ip
# Hostname=#원하는 이름
:wq
```

서비스 재시작 및 방화벽 설정:

```bash
systemctl start zabbix-agent
systemctl enable zabbix-agent

firewall-cmd --permanent --add-port=10050/tcp
firewall-cmd --reload
```
{% endtab %}
{% endtabs %}

### 에이전트 추가(서버에서)

* Zabbix 웹 UI 접속 후:
  * Monitoring > Hosts > Create host&#x20;
  * Hosts 목록에서 Create host 선택&#x20;
  * Windows 설정에 맞게 입력&#x20;

{% hint style="info" %}
항목 요약:

* DB 이름: zabbix\_db
* DB 사용자: zabbix\_user
* 웹 기본 계정: Admin / zabbix
* 방화벽 포트: 에이전트(10050), 서버(10051) 등 필요에 따라 오픈
{% endhint %}
