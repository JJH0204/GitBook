# HTTPStatusCode

* 클라이언트와 서버 간의 무수한 패킷 송/수신을 통해 하나의 웹 페이지가 화면에 표시된다.
* 요청과 응답으로 구성된다.
* 요청에 대한 서버의 상태를 응답하는데 이때 응답하는 내용을 **Status Code**라고 한다.

[자료링크](https://hongong.hanbit.co.kr/http-%EC%83%81%ED%83%9C-%EC%BD%94%EB%93%9C-%ED%91%9C-1xx-5xx-%EC%A0%84%EC%B2%B4-%EC%9A%94%EC%95%BD-%EC%A0%95%EB%A6%AC/)

<details>

<summary>1xx: Information(정보 제공)</summary>

* 요청에 필요한 정보 제공
* 100: 계속
* 101: Switching Protocol(프로토콜 전환)
  * http 1.1 > http 2.0로 버전 변경이 필요할 때
* 102: Processing(처리중)
  * 클라이언트에서 timeout이 걸리기 전에 서버에서 응답하는 코드
  * 클라이언트가 에러로 판단하지 않도록 만듬
* 103\~199: Unassigned(할당되지 않음)

</details>

<details>

<summary>2xx: Success(성공)</summary>

* 클라이언트의 요청에 서버가 정상적으로 응답한 상태
* 200: OK(성공)
* 201: Created(생성됨)
  * 여러 리소스가 정상적으로 생성되었다는 의미
* 202: Accepted(허용됨)
  * 클라이언트의 요청은 확인되었지만 처리되지 않음을 의미
* 응답은 성공했지만 몇 가지 에러가 있을 때
  * 203: Non-Authentication Information
    * 신뢰할 수 없는 정보
    * 신뢰할 수 없는 다른 서버로부터 받은 응답
    * 비인가 서버의 응답
    * proxy tool을 통해 받은 응답의 경우 여기에 해당할 수 있다.
  * 204: No Content
    * 응답은 했지만 전달할 콘텐츠가 없다.
  * 205: Reset Content
    * 콘텐츠 재설정이 필요할 때
    * F5/새로고침이 필요할 때 표시
  * 206: Partial Content
    * 전체 콘텐츠 중 일부만 전달했을 때
  * 207: Multi Status
    * 다중 상태/처리는 성공했지만 여러 에러(203\~206)가 혼합된 상태인 경우
* 208\~299: Unassigned

</details>

<details>

<summary>3xx: Redirection(리다이렉션)</summary>

* 웹 문서 경로가 바뀌거나 해서 완전한 처리를 위해 기다리는 상태
* 300: Multiple choices
  * 여러 선택 항목이 있을 경우
  * 클라이언트의 요청에 복수의 경로가 있는 경우
* 301: Moved Permanently
  * 영구 이동
  * 요청한 URL이 영구적으로 다른 URL로 이동한 경우
* 302: Found
  * 응답한 URL외 다른 URL을 찾음
* 303: See Other
  * 다른 위치 보기
* 304: Not Modified
  * 수정되지 않음
  * 클라이언트가 서버에 요청한 웹 페이지가 요청 이후 수정되지 않음을 의미
* 305: Use Proxy
  * 프록시 사용
  * 클라이언트의 요청에 응답에 특정 콘텐츠가 프록시 서버에서 데이터를 가져와야 할 경우
* 306: Unused
  * 이전 버전에서 사용
* 307: Temporary Redirect
  * 임시 리다이렉션
  * 영구적이지 않은 경로 이동
* 308\~399: Unassigned

</details>

<details>

<summary>4xx: Client Error(클라이언트 에러)</summary>

* 없는 페이지를 요청하거나, 요청 내용이 잘못되었을 때 서버 응답
* 400: Bad Request
  * 잘못된 요청
* 401: Unauthentication
  * 잘못된 인증/권한 없음
* 402: Payment Required
  * 결제 필요
* 403: Forbidden
  * 금지된 접근
* 404: Not Found
  * 찾을 수 없음
* 405: Method Not Allowed
  * 허용되지 않은 메소드
* 406: Not Acceptable
  * 수용할 수 없는 요청
* 407: Proxy Authentication Required
  * 프록시 서버에 인증 필요
* 408: Request Time Out
  * 응답 시간 초과
* 409\~417
* 418\~421: Unassigned
* 422\~429
* 431, 444, 451
* 452\~499: Unassigned

</details>

<details>

<summary>5xx: Server Error(서버 에러)</summary>

* 서버 자체에 에러로 인해 클라이언트에 전달하는 응답 (과부하, DB 처리 과정에서 에러 등)
* 500: Internal Server Error
  * 내부 서버 오류
* 501: Not Implemented
  * 구현되지 않음
* 502: Bad Gateway
  * 불량 게이트웨이
  * 게이트웨이/프록시에서 잘못된 정보를 받아 응답을 할 수 없는 경우
* 503: Service Unavailable
  * 서비스 제공 불가
* 504: Gateway Time Out
  * 게이트웨이 응답 시간 초과
* 505: Http version Not Supported
  * http 버전 미지원
* 506: Unassigned
* 507: Insuffcient Storage
  * 용량 부족
* 512\~599: Unassigned

</details>
