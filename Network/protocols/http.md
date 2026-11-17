# HTTP 프로토콜 (HTTP)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-PRT-007-DO |
| 유형 | D&O (개념) |
| 목적 | HTTP의 요청·응답 구조와 메시지 형식을 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 네트워크 지식을 정리한 것이며 출처를 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

HTTP(Hypertext Transfer Protocol)는 클라이언트와 서버의 데이터 교환을 요청(Request)과 응답(Response) 형식으로 정의한 응용 계층 프로토콜이다. 팀 버너스 리(Tim Berners-Lee)가 속한 팀이 제안한 이후 현대 웹 서비스의 바탕이 됐다. 기본 동작은 클라이언트가 요청하면 서버가 응답하는 것이다.

## 2. 구성 요소

### 2.1 포트

| 항목 | 값 |
|---|---|
| 기본 포트 | TCP 80 |
| 자주 쓰는 대체 포트 | TCP 8080 |
| 전송 프로토콜 | TCP |

웹 서버는 HTTP 서비스를 해당 포트에서 대기시킨다. 클라이언트가 그 포트로 HTTP 요청을 보내면 서버가 해석해 응답한다.

{% hint style="info" %}
NOTE: 원본은 "TCP/80 또는 TCP/8080"으로 적었다. 8080은 대체 포트로 관례적으로 쓰이며 기본 포트가 아니므로 구분했다. 확인 필요.
{% endhint %}

### 2.2 메시지 구조

요청과 응답은 시작 줄, 헤더, 빈 줄, 바디로 구성된다.

| 구성 | 설명 |
|---|---|
| 시작 줄 (Start line) | 첫 줄이다. 요청과 응답에서 역할이 다르다 |
| 헤더 (Headers) | 필드 이름과 값의 쌍이다. 메시지나 바디의 속성을 나타낸다. 0개 이상이다 |
| 빈 줄 | 헤더의 끝을 나타낸다 |
| 바디 (Body) | 빈 줄 뒤의 모든 내용이다. 전송하려는 데이터가 담긴다 |

각 줄은 CRLF(캐리지 리턴 + 라인 피드)로 구분한다. 영문 표기에서 Headers(전체)와 Header(한 줄)를 구분한다.

### 2.3 요청 (Request)

서버에게 특정 동작을 요구하는 메시지다. 서버는 동작이 가능한지, 요청 권한이 있는지 검토해 처리한다.

| 시작 줄 요소 | 설명 |
|---|---|
| 메서드 (Method) | 요청 대상에 수행할 동작. [http_method.md](http_method.md) 참조 |
| 요청 대상 (Request target) | 메서드의 대상 |
| HTTP 버전 | 클라이언트가 쓰는 HTTP 버전 |

세 요소는 공백으로 구분한다.

### 2.4 응답 (Response)

요청 결과를 반환하는 메시지다. 요청의 수행 여부와 사유를 나타내는 상태 정보와, 클라이언트에 보낼 리소스가 담긴다.

| 시작 줄 요소 | 설명 |
|---|---|
| HTTP 버전 | 서버가 쓰는 HTTP 버전 |
| 상태 코드 (Status Code) | 처리 결과를 나타내는 세 자리 숫자. [httpstatuscode.md](httpstatuscode.md) 참조 |
| 처리 사유 (Reason Phrase) | 상태 코드의 이유를 짧게 적은 문구 |

세 요소는 공백으로 구분한다.

## 3. 동작 원리

```
클라이언트                         서버
   | -- GET /index.html HTTP/1.1 --> |
   |    Host: example.com            |
   | <-- HTTP/1.1 200 OK ----------- |
   |     Content-Type: text/html     |
   |     (바디: HTML)                |
```

1. 클라이언트가 TCP 연결을 맺는다.
2. 클라이언트가 요청 메시지를 보낸다.
3. 서버가 요청을 해석해 응답 메시지를 보낸다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| CRLF | Carriage Return + Line Feed. 줄 구분 문자 (`\r\n`) |
| URI | Uniform Resource Identifier. 자원 식별자 |
| 헤더 필드 | 이름과 값으로 이뤄진 메시지 속성 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [http_method.md](http_method.md) | NET-PRT-010-REF | HTTP 메서드 상세 |
| [httpstatuscode.md](httpstatuscode.md) | NET-PRT-011-REF | HTTP 상태 코드 |
| [https.md](https.md) | NET-PRT-008-DO | HTTPS 프로토콜 |

외부 자료:

* [HTTP 표준 문서 RFC 2616 5절](https://www.rfc-editor.org/rfc/rfc2616.html#section-5)
* [CRLF 설명 (j-log)](https://krjaeh0.gitbook.io/j-log/programming/cs_basics/data_representation/encoding-and-formats/crlf)
* [상태 코드 설명 (j-log)](https://krjaeh0.gitbook.io/j-log/programming/cs_basics/web_technologies/http-and-urls/rfc_2616_code)

{% hint style="info" %}
NOTE: RFC 2616은 폐기됐고 현재는 RFC 9110(의미 규칙)과 RFC 9112(HTTP/1.1 메시지 형식)가 대체한다. 원본 링크는 보존했다. 확인 필요.
{% endhint %}

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 브라우저 주소창에 주소를 입력하고 페이지가 뜰 때까지 일어나는 일을 내 말로 적어 본다.
- [ ] 요청과 응답의 시작 줄이 서로 다른 이유는 무엇일까? 내 생각을 적어 본다.
