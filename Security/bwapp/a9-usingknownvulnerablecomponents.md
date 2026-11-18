# [생성형 AI] A9 알려진 취약 컴포넌트 공격

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-BWA-017-DO |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 유형 | D&O (개념) |
| 목적 | 알려진 취약 컴포넌트 사용이 왜 위험한지와 bWAPP A9 항목별 원인·방어를 이해한다 |
| 적용 대상 | 허가받은 격리 실습 환경(자신이 소유·관리하는 VM 또는 의도적 취약 앱인 bWAPP) |
| 확인 상태 | 미검증 (원본과 일반 지식을 정리한 것이며 CVE 번호는 원문과 대조하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="danger" %}
WARNING: 허가받지 않은 시스템에 이 문서의 내용을 시도하는 것은 불법이다. 격리된 실습망에서만 수행한다.
{% endhint %}

## 1. 목적

이미 공개된 취약점이 있는 소프트웨어(CMS, 서버 구성 요소, 라이브러리)를 패치하지 않고 쓰면, 새로운 기법 없이 공개 정보만으로 공격당한다. 이 문서는 원본의 항목 이름을 보존하고 항목별 원인과 방어를 정리한다. 실행형 공격 URL과 페이로드는 싣지 않는다.

## 2. 구성 요소

| 항목 | 취약점 성격 | 참고 번호 (미검증) | 방어 |
|---|---|---|---|
| Drupal SQL Injection (Drupageddon) | Drupal 7 코어의 데이터베이스 추상화 계층 SQL 인젝션 | CVE-2014-3704 | Drupal 코어를 패치된 버전으로 올린다 |
| Heartbleed Vulnerability | OpenSSL의 TLS heartbeat 구현에서 범위를 확인하지 않아 서버 메모리가 노출된다 | CVE-2014-0160 | OpenSSL 업데이트, 노출 가능성이 있던 키·인증서 재발급 |
| PHP CGI Remote Code Execution | CGI 방식으로 PHP를 실행할 때 쿼리 문자열이 PHP 명령줄 옵션으로 해석된다 | CVE-2012-1823 | PHP 업데이트, 가능하면 CGI 대신 FPM 같은 방식 사용 |
| PHP Eval Function | 입력을 코드로 평가한다. 원본 메모: code 인젝션과 같다 | - | [PHP 코드 인젝션](php_injection.md) 참조 |
| phpMyAdmin BBCode Tag XSS | phpMyAdmin의 오류 페이지(`error.php`)가 입력을 걸러내지 않고 출력하는 XSS | 원본에 번호 없음 | phpMyAdmin 업데이트, 관리 도구는 내부망·접근 제한 뒤에 둔다 |
| Shellshock Vulnerability (CGI) | bash가 환경 변수에 든 함수 정의 뒤의 명령까지 실행한다. CGI는 요청 헤더를 환경 변수로 넘기므로 노출된다 | CVE-2014-6271 계열 | bash 업데이트, 불필요한 CGI 제거 |

원본의 항목별 상태는 다음과 같다.

* Drupageddon: 원본 메모는 "반응 없음"이다. 실습에서 재현되지 않았다.
* PHP CGI: bWAPP 관리자 영역의 `/bWAPP/admin/phpinfo.php` 페이지가 대상이다. 참조: [CGI](https://krjaeh0.gitbook.io/j-log/programming/cs_basics/web_technologies/web-basics/cgi)
* phpMyAdmin BBCode: 대상 경로는 `/phpmyadmin/error.php`다. 참조: [BBCode](https://krjaeh0.gitbook.io/j-log/programming/cs_basics/web_technologies/web-basics/bbcode)
* Heartbleed, Shellshock: 원본에 내용이 비어 있다.

{% hint style="warning" %}
CAUTION: 원본에는 PHP CGI와 phpMyAdmin 항목에 실습 서버 대상 요청 URL(옵션을 쿼리 문자열로 넘기는 형태)이 있었다. 실행 가능한 공격 요청이므로 삭제했다.
{% endhint %}

## 3. 동작 원리

1. 공개된 취약점은 번호(CVE)와 패치와 함께 알려진다.
2. 공격자는 서비스의 버전·구성 요소를 식별해 공개 정보와 대조한다.
3. 패치가 없는 시스템은 공개된 방식으로 공격당한다. 공격의 어려움이 아니라 패치 지연이 문제다.

## 4. 탐지·방어

| 구분 | 내용 |
|---|---|
| 자산 목록 | 사용 중인 소프트웨어와 버전을 목록(SBOM 등)으로 관리한다 |
| 패치 관리 | 보안 업데이트를 정해진 기한 안에 적용한다. 지원이 끝난 버전은 교체한다 |
| 취약점 점검 | 의존성 점검 도구와 취약점 스캐너를 허가받은 자산에만 정기 실행한다 |
| 노출 최소화 | 관리 도구(phpMyAdmin, phpinfo 페이지)와 불필요한 CGI를 외부에 열지 않는다 |
| 로그 흔적 | 알려진 취약점 경로(예: `phpinfo.php`, `error.php`)로 향하는 요청, 비정상 헤더 값, 비정상적으로 큰 응답이 접근 로그에 남는다. WAF·IDS 시그니처가 이를 탐지한다 |

## 5. 약어와 용어

| 용어 | 뜻 |
|---|---|
| CVE | Common Vulnerabilities and Exposures. 공개 취약점 식별 번호 |
| CGI | Common Gateway Interface. 웹 서버가 외부 프로그램을 실행해 응답을 만드는 방식 |
| SBOM | Software Bill of Materials. 소프트웨어 구성 요소 목록 |
| 취약 컴포넌트 | 알려진 취약점이 있는 라이브러리·프레임워크·소프트웨어 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 알려진 취약점이 있는 컴포넌트를 쓰고 있는지 어떻게 파악하겠는가?
- [ ] 당장 패치할 수 없을 때 어떤 임시 완화책을 쓰겠는가?
