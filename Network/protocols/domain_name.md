# Domain\_name

* URL 구성 요소 중 Host는 웹 브라우저가 접속할 웹 서버의 주소를 나타낸다.
* Host는 Domain name, [IP address](/broken/pages/3b1b1f23acd5a1429c41572a7251b720941d57cf)의 값을 가질 수 있다.
* 일반적으로 도메인의 특성을 반영한 이름을 정의하여 IP 대신 사용한다.
* Domain name을 Host 값으로 사용하면 DNS(Domain Name Server)에 질의하고, DNS가 IP address를 사용한다.
* 웹 브라우저에서 `http://example.com`에 접속할 경우, DNS에 질의해 얻은 example.com의 IP와 통신한다.
* Domain name에 대한 정보는 `nslookup` 명령어를 사용해 확인할 수 있다.
