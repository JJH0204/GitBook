# A2 Broken\_Auth

## CAPTCHA Bypassing

\
\
&#x20;

* 아이디 패스워드에 대한 페이로드가 필요하다

\
&#x20;   \
총 30개 조합으로 대입 공격 시행

&#x20; \
꼭 활성화 확인

* 캡챠는 프록시 설정으로 유지하고 아이디/패스워드 대입이 가능하다
* CAPTCHA BROKEN

## Forgotten Function

* 이메일을 입력하면 패스워드를 알려줄 것 같다.
* 이메일을 안다면 시크릿 메시지를 알 수 있다. > 비밀번호를 알 수 있다.

medium

## Insecure Login Forms

&#x20;\
\
\
\
<br>

medium

<br>

* 나중에 선언된 변수가 적용됨

{% code title="client-side reconstruction.js" %}
```
```
{% endcode %}

```javascript
var a = bWAPP.charAt(0); var d = bWAPP.charAt(3); var r = bWAPP.charAt(16);
var b = bWAPP.charAt(1); var e = bWAPP.charAt(4); var j = bWAPP.charAt(9);
var c = bWAPP.charAt(2); var f = bWAPP.charAt(5); var g = bWAPP.charAt(4);
var j = bWAPP.charAt(9); var h = bWAPP.charAt(6); var l = bWAPP.charAt(11);
var g = bWAPP.charAt(4); var i = bWAPP.charAt(7); var x = bWAPP.charAt(4);
var l = bWAPP.charAt(11); var p = bWAPP.charAt(23); var m = bWAPP.charAt(4);
var s = bWAPP.charAt(17); var k = bWAPP.charAt(10); var d = bWAPP.charAt(23);
var t = bWAPP.charAt(2); var n = bWAPP.charAt(12); var e = bWAPP.charAt(4);
var a = bWAPP.charAt(1); var o = bWAPP.charAt(13); var f = bWAPP.charAt(5);
var b = bWAPP.charAt(1); var q = bWAPP.charAt(15); var h = bWAPP.charAt(9);
var c = bWAPP.charAt(2); var h = bWAPP.charAt(2); var i = bWAPP.charAt(7);
var j = bWAPP.charAt(5); var i = bWAPP.charAt(7); var y = bWAPP.charAt(22);
var g = bWAPP.charAt(1); var p = bWAPP.charAt(4); var p = bWAPP.charAt(28);
var l = bWAPP.charAt(11); var k = bWAPP.charAt(14);
var q = bWAPP.charAt(12); var n = bWAPP.charAt(12);
var m = bWAPP.charAt(4); var o = bWAPP.charAt(19);
```

```javascript
var secret = (d + "" + j + "" + k + "" + q + "" + x + "" + t + "" +o + "" + g + "" + h + "" + d + "" + p);
```

## Logout Management

<br>

* 웹 페이지에서는 아무 정보도 얻을 수 없다.
* 프록시를 설정해서 확인한다.
* 별다른 내용이 없다.
* 로그인을 하고 다시 뒤로가기를 하니 다시 로그인이 되었다.
* 세션 관리가 재대로 이뤄지지 않는 것 같다.

{% code title="example request" %}
```
Referer: http://192.168.56.122/bWAPP/ba_logout.php
...
PHPSESSID=0c8f5635616d89c3400772ee194fbf44
```
{% endcode %}

위 페이지를 이동할 떄 세션 처리가 정상적으로 이뤄지지 않아 잘못된 인증을 허용하여 로그아웃 후 뒤로가기를 통해 다시 로그인이 되는 상황이다.

medium 이상에서는 함수로 세션을 처리하는 것 같다.

## Password Attacks

{% stepper %}
{% step %}
### 브루트 포스 패스워드 공격

* 브루트 포스 패스워드 공격으로 확인 가능
{% endstep %}

{% step %}
### 또 다른 방법

\
\
<br>

* 비밀번호를 어렵게 만들어야 하는 이유
* 조합이 다양해 질수록 경우의 수가 기하급수적으로 상승한다.
* 테스트를 위해 값을 수정

\
\
&#x20;

* "Successfull login!" 과 같은 결과가 나올때까지 진행

<br>

* "Successfull login!"에 1이 표시되어야 하는데 철자를 잘못 입력해서 뜨지 않았다.
* 하지만 찾긴했다.

값을 넣고 포워드 하면 로그인에 성공한다.
{% endstep %}
{% endstepper %}

## Weak Passwords

## Administrative Portals

```
http://192.168.56.122/bWAPP/smgmt_admin_portal.php?admin=1
```

medium

\
<br>

## Cookies (session 하이제킹)

[cookie](file:///2237607/web/cookie.md)

\
\
<br>

(좌)일반 계정 (우)관리자 계정 접속

&#x20;<br>

관리자 세션의 쿠키로 변경

* 일반 계정이 없어서 발생한 에러&#x20;
* 일반 계정이 있다면 관리자로 로그인이 가능할 것이다.

### https

http와 같다

## Session ID in URL

(내용 없음)

## Strong Sessions
