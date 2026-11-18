# Ubuntu 워드프레스 도커 배포

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-DKR-018-MP |
| 목적 | 하나의 Ubuntu 컨테이너 안에 Apache, PHP, MariaDB, WordPress를 설치해 웹 사이트를 구성한다 |
| 적용 대상 | 도커 엔진이 설치된 Linux, 인터넷 연결, 호스트의 8080번 포트가 비어 있음 |
| 소요 시간 | 약 30분 |
| 확인 상태 | 미검증 (원본 페이지의 절차를 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [도커 허브 이미지 공유 실습](docker-hub-image-share.md) | CLD-DKR-017-MP | 이 컨테이너를 이미지로 공유 |
| [도커 컨테이너 실행과 관리](docker-container-run.md) | CLD-DKR-008-MP | 컨테이너 기본 조작 |
| [도커 실습 (Docker Practice)](docker-1/README.md) | - | Compose로 서비스를 분리하는 방식 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 도커 엔진 | 설치 완료 | |
| 2 | 이미지 | `ubuntu:22.04` | 원본은 `ubuntu:latest`였다 |
| 3 | 브라우저 | | 접속 확인용 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 이 구성은 한 컨테이너에서 두 서비스(MariaDB, Apache)를 실행한다. 한 서비스에 장애가 나면 다른 서비스에 영향이 가고 관리와 디버깅이 어렵다. 운영 환경에서는 서비스별로 컨테이너를 분리한다. 이 문서는 학습용이다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `-p 8080:80`은 호스트의 8080번 포트를 모든 네트워크 인터페이스에 연다. 내 PC에서만 확인하려면 5-A-01에서 `-p 127.0.0.1:8080:80`을 쓴다.
{% endhint %}

{% hint style="danger" %}
WARNING: 이 컨테이너에는 볼륨이 없다. 컨테이너를 삭제(`docker rm`)하면 데이터베이스와 업로드 파일이 모두 사라진다. 보존이 필요하면 볼륨을 연결한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 도커가 동작한다 | `docker --version`이 버전을 출력한다 |
| 2 | 8080번 포트가 비어 있다 | `ss -tln` 출력에 `:8080`이 없다 |
| 3 | 사용할 DB 비밀번호를 정한다 | 안전한 곳에 기록했다. 이 문서에는 `<DB 비밀번호>`로 쓴다 |

## 5. 절차

### A. 컨테이너 생성

1. (5-A-01) Ubuntu 컨테이너를 만들고 진입한다: `docker run -it --name ubuntu-wordpress -p 8080:80 ubuntu:22.04` → 결과: 컨테이너 셸 프롬프트가 열린다.

{% hint style="info" %}
NOTE: 컨테이너를 중지한 뒤 다시 진입하려면 `docker start ubuntu-wordpress` 후 `docker exec -it ubuntu-wordpress bash`를 쓴다.
{% endhint %}

### B. 패키지 설치 (컨테이너 안)

1. (5-B-01) 패키지 목록을 갱신한다: `apt-get update` → 결과: 오류 없이 끝난다.
2. (5-B-02) 패키지를 설치한다: `apt-get install -y apache2 php php-mysql mariadb-server curl` → 결과: 설치가 끝난다.

### C. MariaDB 설정 (컨테이너 안)

1. (5-C-01) MariaDB를 시작한다: `service mariadb start` → 결과: 오류 없이 시작된다.
2. (5-C-02) 데이터베이스와 사용자를 만든다: `mysql -uroot` 로 접속해 아래 SQL을 입력한다.

```sql
CREATE DATABASE wp_database;
CREATE USER 'wp_user'@'localhost' IDENTIFIED BY '<DB 비밀번호>';
GRANT ALL PRIVILEGES ON wp_database.* TO 'wp_user'@'localhost';
FLUSH PRIVILEGES;
```

→ 결과: 각 문장 뒤에 `Query OK`가 출력된다. `wp_database` 데이터베이스와 `wp_user` 사용자가 만들어진다.

3. (5-C-03) `exit`로 MariaDB 클라이언트를 종료한다.

### D. WordPress 설치 (컨테이너 안)

1. (5-D-01) WordPress를 내려받는다: `curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz` → 결과: `wordpress.tar.gz` 파일이 생긴다.
2. (5-D-02) Apache 문서 디렉터리에 푼다: `tar -xzf wordpress.tar.gz -C /var/www/html` → 결과: `/var/www/html/wordpress`가 생긴다.
3. (5-D-03) 압축 파일을 삭제한다: `rm wordpress.tar.gz`
4. (5-D-04) 소유자를 바꾼다: `chown -R www-data:www-data /var/www/html/wordpress`
5. (5-D-05) 권한을 설정한다: `chmod -R 755 /var/www/html/wordpress`

### E. Apache 시작과 WordPress 초기 설정

1. (5-E-01) Apache를 시작한다: `service apache2 start` → 결과: 오류 없이 시작된다.
2. (5-E-02) 브라우저에서 `http://<서버 IP>:8080/wordpress`를 연다 → 결과: WordPress 설치 화면이 열린다.
3. (5-E-03) 데이터베이스 정보를 입력한다: 데이터베이스 이름 `wp_database`, 사용자 이름 `wp_user`, 비밀번호 `<DB 비밀번호>`, 데이터베이스 호스트 `localhost`다.
4. (5-E-04) 설정을 마치고 관리자 계정을 만든다: 관리자 비밀번호는 `<관리자 비밀번호>`로 따로 정한다 → 결과: 로그인 화면으로 넘어간다.

### F. 컨테이너 중지와 재시작

1. (5-F-01) 컨테이너를 중지한다: `docker stop ubuntu-wordpress`
2. (5-F-02) 컨테이너를 시작한다: `docker start ubuntu-wordpress` → 결과: 컨테이너가 시작된다.
3. (5-F-03) 서비스를 다시 시작한다: `docker exec ubuntu-wordpress service mariadb start` 후 `docker exec ubuntu-wordpress service apache2 start`

{% hint style="info" %}
NOTE: 컨테이너를 시작해도 MariaDB와 Apache는 자동으로 시작되지 않는다. 이 컨테이너의 시작 명령은 셸뿐이기 때문이다. 5-F-03을 매번 실행해야 한다. 미검증이다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `docker ps` | 컨테이너가 실행 중이다 | `ubuntu-wordpress`가 `Up`이다 |
| 2 | 브라우저로 `http://<서버 IP>:8080/wordpress` | WordPress가 응답한다 | 설치 화면 또는 사이트 화면이 열린다 |

## 7. 복구

1. (7-01) 컨테이너를 중지한다: `docker stop ubuntu-wordpress`
2. (7-02) 컨테이너를 삭제한다: `docker rm ubuntu-wordpress` → 결과: 컨테이너와 안의 데이터가 삭제된다. 5-C-02, 5-D-01부터 다시 수행하면 새로 구성된다.

## 8. 비교

| 구분 | 내용 |
|---|---|
| 장점 | 하나의 컨테이너라 관리가 단순하다. 설정과 자원 사용을 한곳에서 본다 |
| 단점 | 한 컨테이너에서 두 서비스가 실행되어 충돌 가능성이 커진다. 컨테이너가 중지되면 WordPress와 데이터베이스가 함께 중단된다 |

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 대화체 문장과 이모지를 삭제하고 MP 형식으로 재작성. 예시 비밀번호(`wp_password`)를 `<DB 비밀번호>`로 바꾸고 `ubuntu:latest`를 `ubuntu:22.04`로 고정했다. 포트 개방 CAUTION, 볼륨 부재 WARNING, 서비스 수동 시작 NOTE, 복구 절차를 추가했다 |
