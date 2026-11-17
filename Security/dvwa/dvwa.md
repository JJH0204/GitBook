# DVWA 취약점 실습 (DVWA)

DVWA(Damn Vulnerable Web Application)는 웹 취약점을 학습하기 위해 의도적으로 취약하게 만든 PHP/MySQL 웹 앱이다. 허가받은 격리 실습 환경에서만 구동한다. 이 폴더의 문서는 취약점 개념, 실습 환경에서 관찰되는 현상, 보안 수준별 차이, 탐지·방어를 다룬다.

| 문서 | Task ID | 유형 | 다루는 내용 |
|---|---|---|---|
| [DVWA 가상머신 환경 설정](dvwa_setup.md) | SEC-DVW-001-MP | MP | 실습 VM 접속, 네트워크, 로그인 |
| [크로스 사이트 요청 위조 (CSRF)](csrf.md) | SEC-DVW-002-DO | D&O | 요청 위조, 토큰 방어 |
| [크로스 사이트 스크립팅 (XSS)](xss.md) | SEC-DVW-003-DO | D&O | 반사형·저장형, 출력 인코딩 |
| [SQL 인젝션 실습 (DVWA)](sql-injection.md) | SEC-DVW-004-DO | D&O | 수동·자동 점검, 준비된 질의 |
| [파일 인클루전 (LFI/RFI)](file_inclusion.md) | SEC-DVW-005-DO | D&O | 파일 포함, 허용 목록 |
| [파일 업로드 취약점 (File Upload)](file_upload.md) | SEC-DVW-006-DO | D&O | MIME·확장자·메타데이터 검증 |
| [취약한 캡차 (Insecure CAPTCHA)](insecure-captcha.md) | SEC-DVW-007-DO | D&O | 캡차 검증 로직 |
| [커맨드 인젝션 (Command Injection)](command_injection.md) | 미부여 | 미작업 | 실행형 명령 문자열 중심 |
| [SQL 인젝션 실습 (bWAPP)](sql_injection.md) | 미부여 | 미작업 | 페이로드 목록 중심 |

{% hint style="warning" %}
CAUTION: 마지막 두 문서는 실행형 공격 문자열이 핵심이어서 재작성하지 않고 원본을 유지했다.
{% endhint %}
