# HTTP 상태 코드 (HTTP Status Code)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-PRT-011-REF |
| 유형 | REF (코드 표) |
| 목적 | HTTP 응답 상태 코드의 의미를 찾아본다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 네트워크 지식을 정리한 것이며 출처를 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

클라이언트와 서버는 요청과 응답을 주고받아 웹 페이지를 표시한다. 서버가 요청 처리 결과를 알리는 세 자리 숫자를 상태 코드(Status Code)라고 한다.

## 1. 분류

| 범위 | 분류 | 의미 |
|---|---|---|
| 1xx | Informational (정보 제공) | 요청을 받았고 처리를 계속한다 |
| 2xx | Success (성공) | 요청을 정상 처리했다 |
| 3xx | Redirection (리다이렉션) | 요청을 완료하려면 추가 동작이 필요하다 |
| 4xx | Client Error (클라이언트 오류) | 요청이 잘못됐다 |
| 5xx | Server Error (서버 오류) | 서버가 요청을 처리하지 못했다 |

## 2. 1xx 정보 제공

| 코드 | 이름 | 설명 |
|---|---|---|
| 100 | Continue | 계속 진행해도 된다 |
| 101 | Switching Protocols | 프로토콜을 전환한다(예: WebSocket, HTTP/1.1에서 HTTP/2로 업그레이드) |
| 102 | Processing | 처리 중이다. WebDAV에서 정의한 코드로, 타임아웃 전에 서버가 응답 중임을 알린다 |
| 103 | Early Hints | 최종 응답 전에 미리 읽을 리소스 힌트를 준다 |

## 3. 2xx 성공

| 코드 | 이름 | 설명 |
|---|---|---|
| 200 | OK | 성공 |
| 201 | Created | 리소스가 생성됐다 |
| 202 | Accepted | 요청을 받았지만 처리는 끝나지 않았다 |
| 203 | Non-Authoritative Information | 원 서버가 아닌 프록시가 응답을 변형했다 |
| 204 | No Content | 응답은 했지만 전달할 콘텐츠가 없다 |
| 205 | Reset Content | 클라이언트가 문서 화면(예: 입력 양식)을 초기화해야 한다 |
| 206 | Partial Content | 전체 중 일부만 전달했다(Range 요청) |
| 207 | Multi-Status | 여러 리소스의 상태를 바디에 담아 알린다(WebDAV) |

## 4. 3xx 리다이렉션

| 코드 | 이름 | 설명 |
|---|---|---|
| 300 | Multiple Choices | 선택할 수 있는 경로가 여럿이다 |
| 301 | Moved Permanently | 요청한 URL이 영구적으로 다른 URL로 이동했다 |
| 302 | Found | 임시로 다른 URL에 있다 |
| 303 | See Other | 다른 URL을 GET으로 조회해야 한다 |
| 304 | Not Modified | 마지막 요청 이후 수정되지 않았다. 캐시를 쓴다 |
| 305 | Use Proxy | 프록시를 거쳐야 한다. 폐기됐다 |
| 306 | (Unused) | 예약된 코드이며 쓰지 않는다 |
| 307 | Temporary Redirect | 임시 이동이다. 요청 메서드를 유지한다 |
| 308 | Permanent Redirect | 영구 이동이다. 요청 메서드를 유지한다 |

## 5. 4xx 클라이언트 오류

| 코드 | 이름 | 설명 |
|---|---|---|
| 400 | Bad Request | 잘못된 요청 |
| 401 | Unauthorized | 인증이 필요하거나 인증에 실패했다 |
| 402 | Payment Required | 결제 필요(예약된 코드) |
| 403 | Forbidden | 접근이 금지됐다 |
| 404 | Not Found | 리소스를 찾을 수 없다 |
| 405 | Method Not Allowed | 허용되지 않은 메서드 |
| 406 | Not Acceptable | 요청의 수락 조건에 맞는 응답을 만들 수 없다 |
| 407 | Proxy Authentication Required | 프록시 인증이 필요하다 |
| 408 | Request Timeout | 요청 대기 시간이 초과됐다 |
| 409 | Conflict | 리소스의 현재 상태와 충돌한다 |
| 410 | Gone | 리소스가 영구히 사라졌다 |
| 413 | Content Too Large | 요청 바디가 너무 크다 |
| 414 | URI Too Long | URI가 너무 길다 |
| 415 | Unsupported Media Type | 지원하지 않는 미디어 형식 |
| 429 | Too Many Requests | 요청이 너무 많다 |
| 451 | Unavailable For Legal Reasons | 법적 사유로 제공할 수 없다 |

## 6. 5xx 서버 오류

| 코드 | 이름 | 설명 |
|---|---|---|
| 500 | Internal Server Error | 서버 내부 오류 |
| 501 | Not Implemented | 구현되지 않은 기능 |
| 502 | Bad Gateway | 게이트웨이나 프록시가 상위 서버에서 잘못된 응답을 받았다 |
| 503 | Service Unavailable | 과부하나 점검으로 서비스를 제공할 수 없다 |
| 504 | Gateway Timeout | 게이트웨이나 프록시가 상위 서버의 응답을 기다리다 시간이 초과됐다 |
| 505 | HTTP Version Not Supported | 지원하지 않는 HTTP 버전 |
| 507 | Insufficient Storage | 저장 공간이 부족하다(WebDAV) |

{% hint style="info" %}
NOTE: 원본에서 정정한 내용이다. (1) 401의 이름 "Unauthentication"을 표준 이름 Unauthorized로 고쳤다. (2) 203을 "신뢰할 수 없는 정보"에서 "프록시가 변형한 응답"으로, 205를 "새로고침(F5) 표시"에서 "화면 초기화"로 고쳤다. (3) 원본은 207을 "203~206의 혼합 상태"라 했지만 207은 WebDAV의 여러 리소스 상태 응답이다. (4) 원본이 "미할당"이라 한 103(Early Hints), 308(Permanent Redirect)은 현재 할당돼 있어 추가했다. (5) 408, 504의 이름을 표준 이름(Request Timeout, Gateway Timeout)으로 고쳤다. (6) 원본 5xx의 506은 "미할당"이 아니고 Variant Also Negotiates이며, 매우 드물어 표에서 뺐다. 원본의 미할당 범위 나열과 비표준 코드(444 등)는 뺐다. 4xx와 5xx에서 원본에 없던 409, 410, 413~415, 429, 451은 일반 규격 지식으로 추가했다. 확인 필요.
{% endhint %}

## 7. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [http.md](http.md) | NET-PRT-007-DO | HTTP 프로토콜 |
| [http_method.md](http_method.md) | NET-PRT-010-REF | HTTP 메서드 상세 |

외부 자료:

* [HTTP 상태 코드 표 1xx~5xx 전체 요약 정리](https://hongong.hanbit.co.kr/http-%EC%83%81%ED%83%9C-%EC%BD%94%EB%93%9C-%ED%91%9C-1xx-5xx-%EC%A0%84%EC%B2%B4-%EC%9A%94%EC%95%BD-%EC%A0%95%EB%A6%AC/)
