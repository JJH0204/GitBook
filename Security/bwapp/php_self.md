# PHP SELF 환경변수 취약점

자기 자신의 PHP 파일 경로(파일명)를 저장하는 변수:

{% code title="예" %}
```php
$_SERVER['PHP_SELF']
```
{% endcode %}
