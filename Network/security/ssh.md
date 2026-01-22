# SSH

* 원격 Linux 서버에 연결하는 가장 일반적인 방식
* Secure Shell, Secure Socket Shell 이라 부르며 원격 서버에 연결할 수 있도록 해 주는 암호화된 [네트워크 프로토콜](/broken/pages/937a1352a75b0b512686dfca3357893a284fb1fe)이다.
* 암호화를 통해 호스트와 클라이언트가 안전하게 통신할 수 있다.
* 클라이언트가 원격 서버의 터미널에 접속하여 명령을 입력하면, 호스트가 명령 실행 결과를 클라이언트에 전달한다.
* 가끔 워게임이나 CTF 문제에 접속하기 위해 SSH를 사용한다.

## SSH 사용법

```shell
ssh user@HOST -p PORT -i [개인 키 파일 경로]
```

* ssh 접속할 때는 원격 서버에 존재하는 계정으로 접속
  * user에 접속할 계정(사용자 이름)을 작성한다.
* HOST에는 접속하려는 원격 서버의 ip 또는 도메인을 작성한다.
* 특정 포트로 접속하고 싶은 경우 -p 옵션을 사용한다.

### 접속 클라이언트 인증 방법

{% stepper %}
{% step %}
### 패스워드

* `ssh user@HOST` 명령을 실행하면 패스워드를 입력한 후 원격 서버에 접속할 수 있다.
* 패스워드를 충분히 긴 길이로 설정하지 않으면 [Brute-force Attack](file:///2435498/security/Brute-force%20Attack.md) 공격을 통해 패스워드를 유추할 수 있기에 권장하지 않는다.

```shell
# 원격 서버 정보
Host: host3.dreamhack.games
Port: 11051/tcp → 31337/tcp
```

```shell
# 원격 서버 로그인 정보
ssh with 
id: bguser
pw: bgpw
```

* `ssh bguser@host3.dreamhack.games -p 11051` 를 입력 후 `bgpw`를 입력하면 서버에 접속할 수 있게 된다.
{% endstep %}

{% step %}
### 개인 키

* 원격 서버에 공개 키를 저장, 클라이언트가 사용할 개인 키를 지정하여 알맞는 사용자인지 검증하는 방법
* 공개 키-개인 키 쌍은 `ssh-keygen` 명령을 통해 생성할 수 있다.
* 개인 키 파일을 이용해 원격 서버에 접속할 때 -i 옵션을 사용한다.

```shell
# 원격 서버 정보
Host: host3.dreamhack.games
Port: 11051/tcp → 31337/tcp
```

```shell
# 로그인 정보
ssh with id: bguser
```

* `ssh bguser@host3.dreamhack.games -p 11051 -i [다운받은 개인 키 파일 경로]` 명령어를 통해 서버 접속이 가능하다.
{% endstep %}
{% endstepper %}

### 접속 종료

```shell
exit
```
