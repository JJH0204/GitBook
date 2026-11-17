# A1 인젝션 취약점 모음 (Injection)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-BWA-001-DO |
| 유형 | D&O (개념) |
| 목적 | bWAPP의 A1 인젝션 항목을 개념별로 나누고 각 항목의 상세 문서를 안내한다 |
| 적용 대상 | 허가받은 격리 실습 환경(자신이 소유·관리하는 VM 또는 의도적 취약 앱인 bWAPP) |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="danger" %}
WARNING: 허가받지 않은 시스템에 이 문서의 내용을 시도하는 것은 불법이다. 격리된 실습망에서만 수행한다.
{% endhint %}

## 1. 목적

인젝션은 사용자 입력이 HTML, SQL, 운영체제 명령, 서버 측 지시문 같은 해석기의 일부로 처리될 때 생긴다. bWAPP의 A1 항목은 해석기별로 나뉜다. 이 문서는 항목 목록과 공통 원인, 공통 방어를 정리한다.

## 2. 구성 요소

| 번호 | 항목 | 해석되는 대상 | 상세 문서 |
|---|---|---|---|
| 1 | HTML Injection - Reflected (GET) | 브라우저의 HTML | [반사형 HTML 인젝션 GET](html-injection-reflected_get.md) |
| 2 | HTML Injection - Reflected (POST) | 브라우저의 HTML | [반사형 HTML 인젝션 POST](html-injection-reflected_post.md) |
| 3 | HTML Injection - Reflected (URL) | 브라우저의 HTML | [반사형 HTML 인젝션 URL](html-injection-reflected_url.md) |
| 4 | HTML Injection - Stored (Blog) | 브라우저의 HTML | [저장형 HTML 인젝션 블로그](html-injection-stored_blog.md) |
| 5 | iFrame Injection | 브라우저의 HTML | [아이프레임 인젝션](iframe-injection.md) |
| 6 | OS Command Injection | 서버의 셸 | [OS 커맨드 인젝션](os_command_injection.md) |
| 7 | PHP Injection | PHP 인터프리터 | [PHP 코드 인젝션](php_injection.md) |
| 8 | SSI Injection | 웹 서버의 SSI 지시문 | [SSI 인젝션](ssi_injection.md) |
| 9 | SQL Injection | 데이터베이스 | [SQL 인젝션 실습](../dvwa/sql_injection.md) |
| 10 | XML / XPath Injection | XML 처리기 | 원본에 상세 문서 없음 |
| 11 | LDAP | 디렉터리 질의 | 원본에 상세 문서 없음(원본의 링크는 다른 저장소 경로여서 제거했다) |

## 3. 동작 원리

1. 애플리케이션이 사용자 입력을 문자열로 받는다.
2. 입력을 검증·인코딩하지 않고 해석기가 읽는 문장에 이어 붙인다.
3. 해석기가 입력 중의 특수 문자를 문법으로 해석한다.
4. 개발자가 의도하지 않은 동작이 일어난다.

## 4. 탐지·방어

| 방어 | 내용 |
|---|---|
| 입력과 코드의 분리 | 매개변수화된 쿼리처럼 입력을 값으로만 전달하는 API를 쓴다 |
| 출력 인코딩 | HTML에는 HTML 이스케이프, URL에는 URL 인코딩을 맥락에 맞게 적용한다 |
| 서버 측 검증 | 허용 목록(allowlist)으로 형식과 길이를 검증한다 |
| 최소 권한 | 웹 프로세스와 DB 계정의 권한을 줄인다 |
| 로그 점검 | 웹 서버 로그에서 `<`, `'`, `;`, `%3c`, `%27` 같은 특수 문자와 그 인코딩이 반복되는 요청을 찾는다 |

## 5. 약어와 용어

| 용어 | 뜻 |
|---|---|
| 인젝션 | 입력이 코드나 문법으로 해석되는 취약점 |
| SSI | Server Side Includes. 웹 서버가 HTML 안의 지시문을 실행하는 기능 |
| OWASP A1 | 구판 OWASP Top 10의 첫 항목(인젝션) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 인젝션이 생기는 공통 원인을 내 말로 설명한다.
- [ ] 입력 검증과 출력 인코딩 중 내가 실습에서 확인한 것은 무엇이었는지 적는다.
