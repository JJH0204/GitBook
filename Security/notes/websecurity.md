# 웹 보안 참고 링크 (Web Security)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-NOT-001-DO |
| 유형 | D&O (개념, 참고 링크 모음) |
| 목적 | 웹 보안 학습에 쓰는 문서와 브라우저 보안 개념을 정리한다 |
| 확인 상태 | 미검증 (원본 링크와 과제 메모를 정리했다. 2절의 브라우저 보안 표는 원본에 없던 보충이다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

웹 보안 학습 문서를 한곳에 모으고, 웹 보안의 기본 개념을 짧게 정리한다.

## 2. 구성 요소

### 2.1 브라우저 보안 개념 (보충)

| 개념 | 설명 |
|---|---|
| SOP (Same-Origin Policy) | 출처(스킴, 호스트, 포트)가 다른 문서끼리 데이터를 읽지 못하게 하는 브라우저 정책이다 |
| CORS (Cross-Origin Resource Sharing) | 서버가 응답 헤더로 다른 출처의 접근을 허용하는 방법이다. SOP를 완화하는 장치다 |
| `HttpOnly` 쿠키 속성 | JavaScript에서 쿠키를 읽지 못하게 한다 |
| `Secure` 쿠키 속성 | HTTPS 연결에서만 쿠키를 보낸다 |
| `SameSite` 쿠키 속성 | 다른 사이트에서 시작된 요청에 쿠키를 보낼지 제한한다 (`Strict`, `Lax`, `None`) |
| CSP (Content Security Policy) | 스크립트·리소스를 불러올 수 있는 출처를 응답 헤더로 제한한다 |

### 2.2 학습 자료

| 자료 | 문서 |
|---|---|
| OWASP | [owasp.md](../owasp-top10/owasp.md) |
| DVWA | [dvwa.md](../dvwa/dvwa.md) (SEC-DVW-001-MP) |
| Bee-Box | [bee-box.md](../security/tools/toolbox/bee-box.md) |
| HTTP 상태 코드 | [httpstatuscode.md](../../Network/protocols/httpstatuscode.md) (NET-PRT-011-REF) |
| HTTP 메서드 | [http_method.md](../../Network/protocols/http_method.md) (NET-PRT-010-REF) |
| OWASP Juice Shop | [juiceshop.md](juiceshop.md) (SEC-NOT-006-DO) |

### 2.3 OWASP Juice Shop 개인 과제 메모

{% hint style="danger" %}
WARNING: 점검은 과제용으로 제공된 Juice Shop 실습 환경에서만 한다. 허가받지 않은 시스템에 수행하는 것은 불법이다.
{% endhint %}

| 항목 | 내용 |
|---|---|
| 기한 | 11월 25일까지 (원본 기록. 연도는 적혀 있지 않다) |
| 방식 | 다양한 도구로 자동·수동 점검(정보 수집, 취약점 점검·분석) 후 취약점 공략 |
| 성공 기준 | 포인트 획득 (점수판에서 확인, 별 순서대로) |
| 제출물 | 모의해킹 결과 보고서 (평가 반영) |
| 보고서 범위 | 많은 취약점 중 3~5개를 골라 20쪽 전후로 작성 |
| 상반기 프로젝트 | 11월 18일 진행·제출, 이름 `project_1118` (원본 기록) |

## 3. 참조

* [OWASP Juice Shop 프로젝트 (외부)](https://owasp.org/www-project-juice-shop/)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 같은 출처 정책(SOP)이 없다면 어떤 일이 생길지 내 말로 적어 본다.
- [ ] 쿠키 속성 세 가지 중 내가 직접 설정해 본 것과 그 결과를 적는다.
