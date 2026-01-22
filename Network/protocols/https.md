# HTTPS

## HTTP의 문제점

* HTTP의 응답과 요청은 평문으로 전달된다.
* 누군가 중간에서 가로챈다면 중요한 정보가 유출될 수 있다.
* HTTPS(HTTP over Secure socket layer)는 [TLS(Transport Layer Security)](/broken/pages/2d77ca8dcfb1d4623182dc7626281b4b275e07b8) 프로토콜을 도입해 위 문제점을 보완한다.

***

## HTTPS

* 초기에는 민감한 데이터를 취급하는 웹 서비스(금융, 정부 시스템 등) 위주로 사용되었다.
* 현재 개발되는 서비스들은 규모에 상관없이 HTTPS를 사용하는 추세이다.
* 웹 서버의 URL이 `http://` = HTTP 프로토콜, `https://` = HTTPS 프로토콜
* HTTP 메시지와 달리 HTTPS 메시지의 요청과 응답 내용은 복호화 키가 없으면 확인할 수 없다.

{% hint style="info" %}
HTTPS는 TLS를 사용해 통신 내용을 암호화함으로써 중간자 공격 등으로부터 데이터를 보호한다. 자세한 내용은 [TLS(Transport Layer Security)](/broken/pages/2d77ca8dcfb1d4623182dc7626281b4b275e07b8)를 참고하세요.
{% endhint %}
