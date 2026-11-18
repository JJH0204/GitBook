# URL 구조 및 분석 (URL)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-HTU-001-DO |
| 유형 | D&O (개념) |
| 목적 | URL을 구성 요소로 나눠 각 요소의 역할을 설명한다 |
| 확인 상태 | 미검증 (원본과 일반 웹 지식을 정리했다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

URL(Uniform Resource Locator)은 웹에 있는 리소스의 위치를 나타내는 문자열이다. 브라우저는 URL을 사용해 서버에 리소스를 요청한다. URL은 Scheme, Authority(Userinfo, Host, Port), Path, Query, Fragment로 구성된다.

## 2. 구성 요소

다음 URL을 예로 든다.

```
https://user@www.example.com:8443/docs/index.html?lang=ko&page=2#intro
```

| 요소 | 예시 값 | 설명 |
|---|---|---|
| Scheme | `https` | 서버와 통신할 프로토콜을 나타낸다 |
| Userinfo | `user` | Authority의 일부이며 접속 계정 정보다. 생략하는 경우가 대부분이다 |
| Host | `www.example.com` | Authority의 일부이며 접속할 서버의 도메인 이름 또는 IP 주소다 |
| Port | `8443` | Authority의 일부이며 접속할 서버의 포트다. 생략하면 Scheme의 기본 포트를 쓴다(`http` 80, `https` 443) |
| Path | `/docs/index.html` | 서버에서 접근할 리소스 경로이며 `/`로 구분한다 |
| Query | `lang=ko&page=2` | 서버에 전달하는 파라미터이며 `?` 뒤에 위치한다. 항목은 `&`로 구분한다 |
| Fragment | `intro` | 메인 리소스 안의 서브 리소스를 식별한다. `#` 뒤에 위치한다 |

{% hint style="info" %}
NOTE: Fragment는 브라우저가 해석하며 서버로 전송되지 않는다.
{% endhint %}

## 3. 동작 원리

1. 브라우저가 주소창의 문자열을 Scheme, Authority, Path, Query, Fragment로 분해한다.
2. 브라우저가 Host의 도메인 이름을 DNS로 IP 주소로 바꾼다.
3. 브라우저가 Port(생략 시 기본 포트)로 서버에 연결한다.
4. 브라우저가 Path와 Query를 요청 대상으로 담아 HTTP 요청을 보낸다.
5. 응답을 받은 뒤 Fragment가 가리키는 위치로 화면을 이동한다.

URL에 쓸 수 없는 문자와 구분자와 겹치는 문자는 인코딩한다. 규칙은 [URL 인코딩](url_encoding.md)(PRG-HTU-002-DO)을 따른다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| URL | Uniform Resource Locator. 리소스의 위치 |
| URI | Uniform Resource Identifier. 리소스 식별자. URL은 URI의 한 종류다 |
| Authority | Userinfo, Host, Port를 묶은 부분 |
| Query | 서버에 전달하는 파라미터 문자열 |
| Fragment | 리소스 안의 위치 식별자 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [webresource.md](../../../../Security/notes/webresource.md) | SEC-NOT-003-DO | 웹 리소스와 URI 개념 |
| [http.md](../../../../Network/protocols/http.md) | NET-PRT-007-DO | HTTP 프로토콜 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 주소창에 URL을 입력하면 Host, Port, Path가 각각 어느 단계에서 쓰이는지 내 말로 설명한다.
- [ ] 직접 본 URL 하나를 골라 Scheme부터 Fragment까지 나눠 적는다.
