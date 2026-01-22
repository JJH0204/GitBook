# HTTP\_Method

요청 대상에 대해 서버가 수행하길 바라는 동작입니다.

HTTP 표준 메소드는 보통 아래 **8개**를 말합니다.

* GET
* POST
* PUT
* PATCH
* DELETE
* HEAD
* OPTIONS
* TRACE

<details>

<summary>GET</summary>

리소스를 가져오는 요청입니다.

</details>

<details>

<summary>POST</summary>

요청 대상에게 데이터를 보내는 메소드입니다.\
전송할 데이터는 보통 HTTP body에 포함됩니다.

</details>

<details>

<summary>PUT</summary>

리소스를 **대체**하는 요청입니다.\
리소스가 없으면 생성하는 서버도 있습니다.

</details>

<details>

<summary>PATCH</summary>

리소스를 **부분 변경**하는 요청입니다.

</details>

<details>

<summary>DELETE</summary>

리소스를 삭제하는 요청입니다.

</details>

<details>

<summary>HEAD</summary>

GET과 동일하지만 **body 없이 header만** 받습니다.

</details>

<details>

<summary>OPTIONS</summary>

서버가 지원하는 메소드/옵션을 조회합니다.\
CORS preflight에도 사용됩니다.

</details>

<details>

<summary>TRACE</summary>

요청이 중간에 어떻게 처리되는지 추적합니다.\
실무에서는 보통 꺼둡니다.

</details>
