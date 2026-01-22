# CTF\_Venus

## \[정보수집]

### 1. IP 검색

```
nmap 192.168.56.0/24
```

* 192.168.56.112: 서비스 중인 서버 IP
* 22/tcp: ssh 서비스 활성화
* 8080/tcp: http 서비스 활성화

### 2. 서비스 탐색

{% stepper %}
{% step %}
### nmap 전체 서비스 스캔

```
nmap 192.168.56.112 -sV -v -p-
```

***
{% endstep %}

{% step %}
### 웹 디렉터리 탐색 (dirb)

```
dirb http://192.168.56.112:8080/
```

***

* django 관리자 로그인 페이지: `http://192.168.56.112:8080/admin`
* 일반 사용자 로그인 페이지: `http://192.168.56.112:8080/`
{% endstep %}

{% step %}
### 취약점 스캔 (nikto)

```
nikto -h http://192.168.56.112:8080/
```

***

* 무한 로딩... 무슨 문제인지 모르겠지만 나중에 다시 시도해보자
{% endstep %}

{% step %}
### admin 디렉터리 상세 탐색

```
dirb http://192.168.56.112:8080/admin -f
```

***

* dirb 결과에 추가로 세부 탐색 진행
*
* 두 페이지를 더 발견했다.
{% endstep %}

{% step %}
### 추가 탐색 (gobuster)

```
gobuster dir -u http://192.169.56.112:8080/ -w /usr/share/dirb/wordlists/common.txt/admin
```

***

* 다른 툴로 검출할 것이 없는지 다시 탐색 진행
* admin 페이지 외 다른 유의미한 정보를 담는 페이지는 없다.
{% endstep %}
{% endstepper %}

## \[웹 접속]

### `http://192.168.56.112:8080/`

#### login page

* Credentials guest:guest can be used to access the guest account. (guest / guest 를 통해 guest 계정으로 로그인 가능하다고 한다.)

#### enter page

* Venus에 대한 설명이 적혀있다.
* 온도: 464C, 표면 압력: 93bar, 대기 조성: 이산화탄소 96.5%, 질소 3.5%
* 별다른 내용은 없다.
* 로그인 과정에서 오고가는 패킷 중 보내는 패킷에 대한 내용이다.
* 웹 페이지의 관리자 권한으로 로그인할 수 있는 방법으로 보내는 패킷을 변조하는 것이 가능할 것 같다.

## \[브루트 포스 공격]

{% stepper %}
{% step %}
### hydra로 로그인 무차별 대입 시도

```
hydra 192.168.56.112 -s 8080 http-form-post "/:username=^USER^&password=^PASS^:Invalid username." -L weakuser.txt -P weakpass.txt
```

* 웹 페이지 관리자 권한으로 로그인할 수 있는 계정을 알아내기 위해 무차별 대입 공격을 진행
* `weakuser.txt` 파일 생성
* guest, venus, magellan 추가 저장&#x20;
{% endstep %}

{% step %}
### 계정으로 로그인

* 찾은 계정 이름과 패스워드로 로그인&#x20;
* 로그인 과정에서 주고 받은 패킷 정보  &#x20;
{% endstep %}

{% step %}
### 쿠키 분석

* [쿠키](file:///5659318/web/cookie.md) 값 형태가 이상하다. (의도적으로 쿠키를 암호화한 것 같다.)
* guest:guest > Z3Vlc3Q6dGhyZmc= > (base64) guest:thrfg &#x20;
* venus:123456 > 쿠키에 변화가 없다
* venus; dmVudXM6aXJhaGY=; venus:irahf > magellan:irahf
* magellan; bWFnZWxsYW46aXJhaGZ2bmF0cmJ5YnRsMTk4OQ==; magellan:irahfvnatrbybtl1989 > ROT13 디코딩
{% endstep %}

{% step %}
### 권한 상승 / 로컬 탐색

* 시스템에서 SUID 파일 검색:

```
find / -perm -u=s -type f 2>/dev/null
```

* 취약점이 있는 프로그램을 찾는다. &#x20;
* 추가 탐색 스크린샷&#x20;
{% endstep %}

{% step %}
### 악성코드 전송 및 실행 (개요)

* 해당 프로그램에서 사용할 수 있는 악성코드를 설치한다.
* 칼리 웹 서버를 통해 피해자 서버로 악성코드를 옮긴다.
* make로 컴파일한다.
* 실행한다.&#x20;
{% endstep %}
{% endstepper %}
