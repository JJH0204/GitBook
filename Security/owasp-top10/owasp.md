# OWASP Top 10 개요

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-OWA-001-DO |
| 유형 | D&O + REF (개념 개요와 항목 표) |
| 목적 | OWASP Top 10의 성격과 항목별 대표 방어를 한 표로 정리한다 |
| 적용 대상 | 웹 애플리케이션 보안 학습. 표의 기준 연도는 OWASP Top 10:2021이다 |
| 확인 상태 | 미검증 (일반 지식을 정리한 것이며 공식 문서와 대조하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본은 공식 사이트 링크(임베드, 버튼)만 있고 기준 연도가 없었다. 아래 표는 2021년판 기준이다. OWASP Top 10은 개정되므로 최신 개정판은 공식 사이트에서 확인한다. 이 저장소의 일부 문서는 2013년판 또는 2017년판 번호를 쓴다(예: `A8 CSRF`는 2013년판 번호).
{% endhint %}

## 1. 목적

OWASP Top 10은 OWASP 재단이 발표하는 웹 애플리케이션의 가장 심각한 보안 위험 10가지 목록이다. 개발 요구사항, 점검 기준, 교육의 출발점으로 쓴다. 순위는 개정판마다 바뀌고 항목이 합쳐지거나 새로 생긴다.

## 2. 구성 요소 (2021년판 항목 표)

| 번호 | 이름 | 설명 | 대표 방어 |
|---|---|---|---|
| A01 | Broken Access Control | 권한 없는 사용자가 다른 사용자의 데이터나 기능에 접근한다 | 서버 측 권한 검사, 기본 거부 |
| A02 | Cryptographic Failures | 암호화 누락이나 약한 알고리즘으로 민감 데이터가 노출된다 | 전송 구간 TLS, 저장 시 암호화, 검증된 알고리즘 사용 |
| A03 | Injection | 입력값이 질의나 명령으로 해석된다(SQL, OS 명령, XSS 포함) | 매개변수화된 질의, 입력 검증, 출력 인코딩 |
| A04 | Insecure Design | 설계 단계의 결함. 구현을 고쳐도 해결되지 않는다 | 위협 모델링, 보안 설계 패턴 |
| A05 | Security Misconfiguration | 기본 설정, 불필요한 기능, 상세 오류 메시지가 남아 있다 | 하드닝 절차, 불필요한 기능 제거, 설정 점검 |
| A06 | Vulnerable and Outdated Components | 취약하거나 지원이 끝난 라이브러리·구성 요소를 쓴다 | 구성 요소 목록 관리, 패치, 취약점 점검 |
| A07 | Identification and Authentication Failures | 약한 비밀번호 정책, 세션 관리 미흡으로 인증이 무력화된다 | 다중 인증, 세션 갱신·만료, 로그인 시도 제한 |
| A08 | Software and Data Integrity Failures | 검증 없는 업데이트, 직렬화 데이터, CI/CD 변조를 신뢰한다 | 서명 검증, 파이프라인 접근 통제 |
| A09 | Security Logging and Monitoring Failures | 로그와 알림이 없어 침해를 늦게 발견한다 | 보안 이벤트 로깅, 알림, 대응 절차 |
| A10 | Server-Side Request Forgery (SSRF) | 서버가 공격자가 지정한 주소로 요청을 보낸다 | 허용 목록 기반 주소 검증, 내부망 접근 차단 |

{% hint style="info" %}
NOTE: 이 표의 항목 이름과 번호는 2021년판에 대한 기억을 정리한 것이다. 공식 문서와 대조하지 않았다.
{% endhint %}

## 3. 동작 원리

이 목록은 공격 절차가 아니라 위험 분류다. 아래 순서로 쓴다.

1. 점검 대상 애플리케이션의 기능을 항목 표와 대조한다.
2. 해당하는 항목의 대표 방어가 적용되어 있는지 확인한다.
3. 적용되지 않은 항목을 위험도 순으로 정리해 수정한다.

실습 문서와의 대응은 다음과 같다.

| 항목 | 관련 문서 |
|---|---|
| A03 Injection | [A1 인젝션 (bWAPP)](../bwapp/a1-injection.md), [DVWA 취약점 실습](../dvwa/dvwa.md) |
| 번호 체계 참고 | [웹 보안 노트](../notes/websecurity.md) |

## 4. 참조

* [OWASP Top 10 공식 사이트](https://owasp.org/Top10/)

## 5. 약어와 용어

| 용어 | 뜻 |
|---|---|
| OWASP | Open Worldwide Application Security Project. 웹 보안 비영리 재단 |
| XSS | Cross-Site Scripting |
| SSRF | Server-Side Request Forgery |
| TLS | Transport Layer Security |
| CI/CD | 지속적 통합과 배포 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] OWASP Top 10이 "공격 방법 목록"이 아니라 "위험 분류"인 이유를 내 말로 적는다.
- [ ] 내가 만든(또는 쓰는) 웹 서비스에 해당할 만한 항목 하나와 그 방어를 적는다.
