# HTTP

## HTTP (Hyper Text Transfer Protocol)

* 서버 클라이언트의 데이터 교환을 요청(Request), 응답(Response) 형식으로 정의한 [프로토콜](/broken/pages/937a1352a75b0b512686dfca3357893a284fb1fe)
* 팀 버너스 리(Team Berners-Lee)와 그의 팀이 제정한 이후, 현대 웹 서비스의 바탕이 되는 [프로토콜](/broken/pages/937a1352a75b0b512686dfca3357893a284fb1fe)로 자리 잡았다.
* 기본 메커니즘은 클라이언트가 서버에 요청하면, 서버가 응답하는 것 뿐
* 웹 서버는 HTTP 서비스를 HTTP [서비스 포트](/broken/pages/b2e635cd8e73f704e1289d6371bac83146676118)에 대기 시킨다.
* 포트는 일반적으로 TCP/80 또는 TCP/8080로 정해진다.
* 클라이언트가 [서비스 포트](/broken/pages/b2e635cd8e73f704e1289d6371bac83146676118)에 HTTP 요청을 전송 > 이를 해석해 적절한 응답을 반환한다.

## HTTP 메시지

* 클라이언트가 전송하는 HTTP 요청, 서버가 반환하는 HTTP 응답이 있다.
* 기능과 세부 구조의 차이를 제외하고 HTTP 헤더와 바디로 구성되는 공통점이 있다.

#### HTTP 헤더 (Headers)

* 각 줄은 [CRLF](file:///2435498/cs_basics/CRLF.md) 로 구분
* 첫 줄은 시작 줄(Start line), 나머지 줄은 헤더(Header)라 부른다.
* 영문 표기에 주의해야 한다. (Headers와 Header)
* 헤더의 끝은 빈 줄로 나타낸다.
* 시작 줄의 역할은 요청과 응답에서 차이가 있다.
* 헤더는 필드와 값으로 구성, HTTP 메시지 또는 바디의 속성을 나타낸다.
* 하나의 HTTP 메시지에는 0개 이상의 헤더가 있을 수 있다.

#### HTTP 바디 (Body)

* 헤드의 끝을 나타내는 [CRLF](file:///2435498/cs_basics/CRLF.md) 뒤 모든 줄을 말한다.
* 클라이언트나 서버에게 전송하려는 데이터가 바디에 담긴다.

## HTTP 요청 (Request)

서버에게 특정 동작을 요구하는 메시지. 서버는 해당 동작을 실현 가능한지, 클라이언트가 그러한 동작을 요청할 권한이 있는지 등을 검토하여 적절할 때 이를 처리한다.

#### 시작 줄

* HTTP의 시작 줄은 [메소드(Method)](/broken/pages/9a24bfc5d07c91697e2167974e8b209a6eba8dca), 요청 대상(Request target), HTTP 버전으로 구성된다.
* 각각은 띄어쓰기로 구분된다.
* 요청 URI는 메소드의 대상을, HTTP 버전은 클라이언트가 사용하는 HTTP 프로토콜의 버전을 의미

#### 헤더와 바디

* 시작 줄을 제외한 헤더와 바디는 HTTP 메시지에서 설명한 것과 같다.
* 자세한 내용은 [HTTP 표준 문서](https://www.rfc-editor.org/rfc/rfc2616.html#section-5)

## HTTP 응답 (Response)

* HTTP 요청에 대한 결과를 반환하는 메시지
* 상태(Status)정보(요청을 수행했는지, 하지 않았는지, 안 했다면 이유가 무엇인지 등), 클라이언트에 전송할 리소스가 응답에 포함된다.

#### 시작 줄

* HTTP 응답의 시작 줄은 HTTP 버전, 상태 코드(Status Code), 처리 사유(Reason Phrase)로 구성된다.
* 위 요소들은 띄어쓰기로 구분된다.
* **HTTP 버전**: 서버에서 사용하는 HTTP 버전을 의미
* [**상태 코드(Status Code)**](file:///2435498/web/RFC_2616_Code.md): 요청에 대한 처리 결과를 세 자릿수로 표현
* 처리 사유는 상태 코드가 발생한 이유를 짧게 기술한 것
