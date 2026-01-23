# DBPerformanceInfo

## Swap

* 비상용 메모리(하드웨어에 할당한)
* 통상 메모리의 1.5\~2배를 swap 파티션으로 할당

확인:

```sh
free
```

옵션: -m, -h&#x20;

커널 옵션 확인:

```sh
sysctl -a
```

swap 메모리 설정 변경:

```sh
sysctl -w vm.swappiness=40
```

{% hint style="info" %}
설정 영구 적용: /etc/sysctl.conf에 변경값을 추가 또는 수정합니다.
{% endhint %}

예:

```sh
vi /etc/sysctl.conf
```

{% hint style="info" %}
통상 vm.swappiness 값은 40\~60 사이로 설정합니다.
{% endhint %}

## 메모리 정보

확인:

```sh
grep MemTotal /proc/meminfo
grep SwapTotal /proc/meminfo
```

## CPU 정보

확인:

```sh
cat /proc/cpuinfo
```

## 디스크 확인

```sh
df -h
```

## 커널 / OS 버전 확인

```sh
cat /proc/version       # 리눅스 커널 버전
cat /etc/rocky-release  # 리눅스 배포판 버전 (예: Rocky)
```

## DB(예: MariaDB) 사용자 및 권한 관리

DB 사용자 및 그룹 추가:

```sh
groupadd -g 505 dba            # DB 관리자 그룹 생성
useradd -u 505 -G dba rocky    # 사용자 rocky 생성 및 dba 그룹에 추가
```

DB 버전 예시:

```
mysql  Ver 15.1 Distrib 10.5.22-MariaDB, for Linux (x86_64) using  EditLine wrapper
```

DB 계정 추가:

```sql
create user 'jaeho'@'localhost' identified by 'choa0306@@';
```

DB 계정 열람:

```sql
select User, Password from mysql.user;
```

DB 권한 보기:

```sql
show grants;
```

특정 사용자 권한 정보 확인:

```sql
show grants for 'jaeho'@'localhost';
```

설정 파일 위치:

```
vi /etc/my.cnf
/etc/my.cnf.d
vi /etc/my.cnf.d/mariadb-server.cnf
```

bind-address 예시:

```
bind-address=127.0.0.1    # 원격 접속 비허용
bind-address=0.0.0.0      # 모든 네트워크 원격 접속 허용
bind-address=192.168.56.0/24 # 해당 내트워크 시스템만 접속 허용
```

추가 설정 예:

```
Port=5000 # 서비스 포트 설정
```

패스워드로 접속:

```sh
mysql -u root -p
```

원격 접속 계정 예시:

```sql
create user 'test1'@'%' identified by '1234';
grant all privileges on school.* to 'test1'@'%';
show grants for 'test1'@'%';
```

특정 호스트만 허용된 사용자 예시:

```sql
create user 'test2'@'192.168.56.101' identified by '4231';

-- test2는 192.168.56.101 시스템에서만 접속 가능
grant select, insert on school.student to 'test2'@'192.168.56.101';

-- 변경 사항 적용
flush privileges;
```

권한 회수:

```sql
-- revoke 명령으로 권한 삭제 가능
revoke all on school.* from 'test3'@'localhost';
```

계정 삭제:

```sql
drop user test1;
drop user 'test1'@'%';
```

한번에 권한 지급:

```sql
grant all privileges on school.* to 'test3'@'localhost' identified by '1234';
```

한번에 회수:

```sql
revoke all on school.* from 'test3'@'localhost';
```
