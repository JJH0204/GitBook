# WAF

## Web Application Firewall - 웹 방화벽

웹 서비스가 동작 중인 서버에서 자체적으로 사용할 수 있는 방화벽 어플리케이션

## 준비

### 웹 서비스 활성화

### httpd 모듈 확인

```bash
httpd -M
```

### mod\_security 모듈 설치

{% code title="설치 명령" %}
```bash
dnf install -y mod_security
```
{% endcode %}

### 경로 확인

{% code title="mod_security.conf 편집" %}
```bash
vi ./mod_security.conf
```
{% endcode %}

파일 예시 내용:

```
    SecRuleEngine On           // 설정 적용여부 결정 (비활: Off)
    SecRequestBodyAccess On    // 웹 소스 본문<body>도 점검
    SecRule REQUEST_HEADERS:Content-Type "text/xml" \ 
         "id:'200000',phase:1,t:none,t:lowercase,pass,nolog,ctl:requestBodyProcessor=XML"
    SecRequestBodyLimit 13107200        // 메모리 제안
    SecRequestBodyNoFilesLimit 131072   
    SecRequestBodyInMemoryLimit 131072  
    SecRequestBodyLimitAction Reject    // 메모리 제안을 초과하면 수행할 액션

    SecPcreMatchLimit 1000     //
```

## Rules 생성

### 파일 경로

```
/etc/httpd/modsecurity.d
```

### 파일 내용

```bash
vi ./local_rules/modsecurity_localrules.conf
```

### crs 링크

https://owasp.org/www-project-modsecurity-core-rule-set/

### Rules 작성

기본 액션 설정 예:

```
SecDefaultAction "탐지되었을 때 기본 액션"
```

예시:

```
SecDefaultAction "phase:2,deny,log,status:406"
```

* 차단/로그화/클라이언트 메시지 설정

룰 예시:

```
SecRule REQUEST_URI "/etc/passwd" "id:'500001'"
SecRule REQUEST_URI "../../" "id:'500002'"
SecRule ARGS "<[Ss][Cc][Rr][Ii][Pp][Tt]>" "id:'500003'" # XSS 공격 탐지
```

* 차단/탐지 하고 싶은 내용 작성

## 테스트

### 웹 서버 접속

### /etc/passwd

* 406 에러 코드 확인

### ../../

* 406 에러 코드 확인

### /etc/shadow

* 404 에러: 별도의 룰 설정을 하지 않았기 때문에 발생

## 로그 확인

### audit

### debug

* 아직 별 내용이 없다.

## CRS 설정

### 설치

{% code title="CRS 설치" %}
```bash
dnf install -y mod_security_crs
```
{% endcode %}

!\[]\(../../assets/images/Pasted%20image%2020241015153434.png)

### 설치 경로

```
/usr/share/mod_modsecurity_crs/rules
```

### Rule 확인 (wordpress)

```bash
vi ./REQUEST-903.9002-WORDPRESS-EXCLUSION-RULES.conf
```
