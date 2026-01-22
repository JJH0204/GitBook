# CTF\_TechSupport

## Nmap

* 공격할 대상 서버의 IP가 56.109로 추측된다.
* 22(ssh), 80(http), 139, 445(samba) 서비스가 동작 중인 것으로 보인다.

{% stepper %}
{% step %}
### HTTP 조사

* `http://192.168.56.109/` 로 접속했지만 별 다른 소득은 없다.
* `dirb http://192.168.56.109/`로 접속 가능한 웹 서버 디렉터리를 조사한다.
* `http://192.168.56.109/phpinfo.php`
* `http://192.168.56.109/wordpress/index.php`
  * US:- +18436457766 (전화번호인 것 같다.)
  * 그 외에는 전부 테마의 기본 페이지인 것 같다.
* `http://192.168.56.109/wordpress/xmlrpc.php`\
  XML-RPC server accepts POST requests only.\
  [XML-RPC](https://ko.wikipedia.org/wiki/XML-RPC) 서버는 POST 요청만 허용합니다.
* `http://192.168.56.109/wordpress/wp-login.php`
* `http://192.168.56.109/wordpress/wp-content/plugins/redirection/`
{% endstep %}

{% step %}
### Samba 조사

* 분명 이 서버에 samba 도 함께 동작하고 있었다.
* Samba 서비스를 활용해서 원격 접속할 수 있는 방법을 찾아보자.
* 참고: [Samba](file:///5659318/linux_admin/Samba.md)
* 공격자 서버에서 samba 클라이언트 설정을 하고 접속 시도
* 패스워드가 뭘까? 방금 찾은 전화번호?
* 공백을 입력하니 samba server에 접속할 수 있었다.
* CIFS 마운트 명령 예시:

```bash
mount -t cifs //[Samba 서버 IP 주소]/[공유 Section 명] [mount할 디렉터리] -o username=[Samba 서버 접근 ID] -o password=[Samba 서버 접근 ID의 Password]
```

* 실제 사용한 명령:

```bash
mount -t cifs //192.168.56.109/websvr ./samb -o username=root -o password=
```

* 마운트된 곳에서 발견한 것:
  * admin:7sKvntXdPEJaxazce9PXi24zaFrLiKWCk
* 아쉽게도 이 admin 암호는 암호화되어 있는 것 같다.
* 암호화를 풀어보려 했지만 별 소득은 없었다.
* 이걸로 SSH 로그인을 시도해볼까?
{% endstep %}

{% step %}
### SSH 시도

* SSH 접속 시도 예:

```bash
ssh admin@192.168.56.109
```

* 웹 탐색 중 발견한 의심스러운 쿼리(예시, SQL 인젝션 가능성):

```txt
http://192.168.56.109/kb/question.php?ID=1%20UNION%20SELECT%20concat(user,char(58),password)%20FROM%20mysql.user%20
```
{% endstep %}
{% endstepper %}

## searchsploit

(검색 도구로 취약점 스캔을 진행할 수 있음 — 별도 결과는 기록되지 않음.)
