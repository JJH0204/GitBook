# PHP 기초 문법 및 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-PHP-001-DO |
| 유형 | D&O (개념) |
| 목적 | PHP 파일의 기본 구조와 `phpinfo()` 함수의 출력, 운영 환경에서의 제한 방법을 설명한다 |
| 확인 상태 | 미검증 (원본과 PHP 문서를 읽고 작성했으며 이 환경에서 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

PHP는 서버에서 실행되는 스크립트 언어다. 웹 서버가 `.php` 파일을 PHP 인터프리터에 넘기면 `<?php ... ?>` 태그 안의 코드가 실행되고, 태그 밖의 텍스트는 그대로 출력된다.

## 2. 구성 요소

| 요소 | 역할 |
|---|---|
| `<?php` | PHP 코드 구간을 시작한다 |
| `?>` | PHP 코드 구간을 끝낸다. 파일 전체가 PHP 코드이면 생략한다(끝 뒤의 공백·개행이 응답에 섞이는 문제를 막는다) |
| `phpinfo()` | 설치된 PHP의 버전, 빌드 옵션, `php.ini` 설정, 로드된 확장, 환경 변수를 HTML로 출력한다 |
| `php.ini` | PHP 설정 파일. `disable_functions`로 함수 사용을 막는다 |

## 3. 예제 코드

{% code title="example.php" %}
```php
<?php
phpinfo(); // PHP 정보 출력 함수
```
{% endcode %}

* 원본의 닫는 태그 `?>`는 생략했다. 동작은 같다.
* 브라우저로 이 파일을 열면 PHP 설정 표가 출력된다.

## 4. 한계와 주의

{% hint style="danger" %}
WARNING: `phpinfo()` 출력에는 PHP 버전, 서버 경로, 환경 변수, 설정값이 포함된다. 공격자가 서버를 파악하는 데 쓰이므로 운영(실서비스) 서버에 `phpinfo()`를 호출하는 파일을 두지 않는다.
{% endhint %}

운영 환경에서는 `php.ini`의 `disable_functions`에 함수 이름을 지정해 실행을 막는다.

```ini
disable_functions = phpinfo
```

{% hint style="info" %}
NOTE: `disable_functions`는 `php.ini`에서만 설정할 수 있고 설정 변경 후 PHP(또는 웹 서버)를 다시 시작해야 반영된다. 원본의 "제한을 설정한다"는 이 설정을 가리킨다.
{% endhint %}

## 5. 참조

* PHP 공식 문서: `phpinfo()`, `disable_functions` (php.net)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 웹 서버가 `.php` 파일을 요청받았을 때 어떤 순서로 처리하는지 내 말로 설명하면?
- [ ] `phpinfo()`를 운영 서버에 남겨 두면 어떤 위험이 있는가?
