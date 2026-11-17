# HTTP 상태 코드

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-HTU-004-REF |
| 유형 | REF (코드 표) |
| 목적 | 상태 코드 다섯 분류와 자주 쓰는 코드를 빠르게 찾는다 |
| 확인 상태 | 미검증 (원본과 일반 웹 지식을 정리했다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 상태 코드 전체 표의 정본은 [HTTP 상태 코드 (NET-PRT-011-REF)](../../../../Network/protocols/httpstatuscode.md)이다. 이 문서는 요약만 둔다.
{% endhint %}

HTTP 상태 코드는 RFC 2616에서 정리된 이래 약 40여 개가 정의되어 있다. RFC 2616은 폐기됐으며 RFC 7231을 거쳐 현행 규격은 RFC 9110이다. 코드는 첫 자리 숫자에 따라 5개 분류로 나뉜다.

## 1. 분류와 대표 코드

| 범위 | 의미 | 대표 코드 |
|---|---|---|
| 1xx | 요청을 받았고 처리를 계속한다 | 100 Continue |
| 2xx | 요청이 정상 처리됐다 | 200 OK: 성공 |
| 3xx | 요청을 완료하려면 클라이언트의 추가 동작이 필요하다 | 302 Found: 다른 URL로 이동한다 |
| 4xx | 클라이언트의 잘못된 요청으로 처리에 실패했다 | 400 Bad Request: 요청이 문법에 맞지 않는다<br>401 Unauthorized: 인증이 필요하거나 인증에 실패했다<br>403 Forbidden: 리소스에 접근할 권한이 없다<br>404 Not Found: 리소스가 없다 |
| 5xx | 요청은 유효하지만 서버 오류로 처리에 실패했다 | 500 Internal Server Error: 서버 내부 오류<br>503 Service Unavailable: 과부하·점검 등으로 일시적으로 처리할 수 없다 |

## 2. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [httpstatuscode.md](../../../../Network/protocols/httpstatuscode.md) | NET-PRT-011-REF | HTTP 상태 코드 (전체 표) |
| [http.md](../../../../Network/protocols/http.md) | NET-PRT-007-DO | HTTP 프로토콜 |
