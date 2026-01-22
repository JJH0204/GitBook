# HTML Injection   Reflected\_POST

* 클라이언트가 서버에 요청하는 메소드가 POST의 경우 URL에 파라미터 정보가 표시되지 않는다.

## proxy set

* 프록시로 잡아서 확인할 수 있다.
* POST 방식에서 요청값에 특수문자들이 인코딩되어 요청된다.
* [더블 인코딩](file:///2237607/security/DoubleEncoding.md) 된 경우도 있다.
