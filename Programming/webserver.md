# WebServer

{% stepper %}
{% step %}
### 간단 명령어 — 설치 및 기본 작업

```sh
[root@localhost home]# dnf install httpd mariadb php -y  // 툴 설치
[root@localhost home]# systemctl start httpd // 툴 실행
[root@localhost home]# cd /var/www/html
[root@localhost html]# vi index.html
[root@localhost html]# ls -al
```

설치 → 서비스 시작 → 웹 루트로 이동 → index.html 편집 → 파일목록 확인
{% endstep %}

{% step %}
### 포트 개방 (방화벽)

예시:

```
firewall-cmd ~~
```

{% hint style="info" %}
주요 옵션:

* `--list-all`: 방화벽 정보 출력
* `--permanent`: 재부팅 후에도 적용 (영구 적용)
  * `--add-service=[서비스이름]`
* `--reload`: 방화벽 정책 변경 후 적용 (필수)
{% endhint %}
{% endstep %}

{% step %}
### systemctl — 서비스 관리

```sh
[root@localhost home]# systemctl start httpd    // 툴 실행
[root@localhost home]# systemctl enable httpd   // 툴 등록
# status, stop, restart, disable 등 추가 명령어들
```

관련 자료: https://www.kernelpanic.kr/20
{% endstep %}
{% endstepper %}

### 필요 툴

* [HTML](/broken/pages/7ef44fc4ba51d6e5bb1559bb8a499b77d7ff77b0) 또는 [php](file:///0903665/programming/php.md)
* [Mariadb](file:///0903665/database/Mariadb.md)
* [httpd](/broken/pages/61d7c097fa19a82502b1c34720fb8a63a329aeb0)

### httpd 홈 디렉토리

경로:

```
/etc/httpd
```

* 웹 서비스 관련 데이터 저장 디렉토리
* `httpd.conf`에서 웹 서비스 관련 설정을 수정할 수 있다.
  * `<Directory/>접근 권한 정보</Directory>`
  * `LogLevel` : 로그 심각도 수준
  * `DocumentRoot ~~` : 웹 페이지 소스 저장 경로 (기본: `/var/www/html/`)

### 웹 서비스 기본 포트

* port: 80
* FQDN 예시: 임의의 ip(192.169.1.101):80

### 웹 접속 과정

* `http://192.168.1.101` → `/var/www/html/index.html` (또는 `.php` 등) 실행
* `http://192.168.1.101/추가경로` → `/var/www/html/추가경로`로 접근

### 참고

* [php](file:///0903665/programming/php.md)
