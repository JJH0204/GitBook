# SSL 및 TLS 프로토콜

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-NSC-003-DO |
| 유형 | D&O (개념) |
| 목적 | SSL/TLS의 역할, 핸드셰이크 흐름, 인증서 종류, 버전별 상태, HTTPS와의 관계를 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 보안 지식을 정리한 것이며 출처를 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 대화체를 평서체로 바꾸고, 외부 링크는 "참조" 절로 옮겼다. SSL의 버전별 폐기 현황은 원본에 없던 내용을 보충했다.
{% endhint %}

## 1. 목적

SSL(Secure Sockets Layer)은 1990년대 중반 넷스케이프(Netscape)가 개발한 암호화 프로토콜이다. 인터넷 통신에서 기밀성, 인증, 데이터 무결성을 제공하려고 만들었다. TLS(Transport Layer Security)는 SSL의 후속 표준이다. 오늘날 "SSL"이라 부르는 것은 대부분 TLS를 가리킨다.

## 2. 구성 요소

### 2.1 SSL/TLS가 제공하는 보호

| 보호 항목 | 설명 | 수단 |
|---|---|---|
| 기밀성(프라이버시) | 전송 중 도청돼도 내용을 해독하지 못한다 | 대칭 키 암호 |
| 무결성 | 전송 중 변조되지 않았음을 확인한다 | 메시지 인증 코드, 디지털 서명 |
| 인증 | 서버(선택적으로 클라이언트)가 주장하는 주체임을 확인한다. 피싱을 막는 데 도움이 된다 | 인증서(공개 키 기반) |

### 2.2 버전별 상태

| 버전 | 상태 | 비고 |
|---|---|---|
| SSL 2.0, SSL 3.0 | 폐기 | 취약점이 있어 쓰지 않는다 |
| TLS 1.0, TLS 1.1 | 폐기 | 취약점 때문에 IETF가 2021년 폐기했다(RFC 8996) |
| TLS 1.2 | 사용 가능 | 널리 쓰인다(RFC 5246) |
| TLS 1.3 | 권장 | 2018년 표준화(RFC 8446). 보안과 성능이 개선됐다 |

{% hint style="warning" %}
CAUTION: 운영 환경에서는 TLS 1.2 이상만 허용한다. SSL과 TLS 1.0, 1.1은 비활성화한다.
{% endhint %}

### 2.3 인증서

인증서는 서버의 신원을 증명하고 공개 키를 전달한다. 신뢰할 수 있는 인증 기관(CA, Certificate Authority)이 발급한다. 검증 수준에 따라 세 종류가 있다.

| 종류 | 약어 | 검증 내용 |
|---|---|---|
| 도메인 유효성 검사 | DV | 도메인 소유 여부만 확인한다 |
| 조직 유효성 검사 | OV | 도메인 소유와 조직의 실재를 확인한다 |
| 확장 유효성 검사 | EV | 조직을 더 엄격히 확인한다 |

### 2.4 HTTPS

HTTPS는 HTTP를 TLS 위에서 동작시키는 방식이다. 웹 브라우저와 서버 사이의 HTTP 메시지가 모두 암호화되어 도청과 변조를 막는다. 기본 포트는 443/tcp다. 자세한 동작은 [HTTPS](../protocols/https.md)를 참고한다.

### 2.5 기반 암호 기술

TLS는 공개 키 암호(비대칭 키)와 대칭 키 암호를 함께 쓴다. 공개 키 암호는 키 교환과 인증에, 대칭 키 암호는 실제 데이터 암호화에 쓴다.

## 3. 동작 원리

통신을 시작하면 클라이언트와 서버가 핸드셰이크(handshake)로 암호 방식과 키를 협상한다. TLS 1.2의 단순화한 흐름은 다음과 같다.

1. 클라이언트가 지원하는 TLS 버전과 암호 방식 목록을 서버에 보낸다(ClientHello).
2. 서버가 사용할 버전·암호 방식과 인증서를 클라이언트에 보낸다(ServerHello, Certificate).
3. 클라이언트가 인증서의 서명, 유효 기간, 도메인 일치 여부를 검증한다.
4. 클라이언트와 서버가 키 교환으로 같은 세션 키를 만든다.
5. 양쪽이 핸드셰이크 완료를 확인한다(Finished).
6. 이후 데이터는 세션 키로 암호화해 주고받는다.

{% hint style="info" %}
NOTE: TLS 1.3은 핸드셰이크 왕복 횟수가 줄고, 서버 인증서 이후 메시지도 암호화한다. 위 순서는 개념을 설명하기 위한 TLS 1.2 기준 요약이다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| SSL | Secure Sockets Layer |
| TLS | Transport Layer Security |
| CA | Certificate Authority. 인증 기관 |
| DV / OV / EV | 인증서 검증 수준 |
| PKCS | Public Key Cryptography Standards. 공개 키 암호 표준 |
| 세션 키 | 한 번의 연결에서만 쓰는 대칭 키 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [https.md](../protocols/https.md) | | HTTPS |
| [TLS 1.2 표준 RFC 5246](https://www.rfc-editor.org/rfc/rfc5246.html) | | 외부 문서 |
| [Cloudflare: What is SSL](https://www.cloudflare.com/learning/ssl/what-is-ssl/) | | 외부 문서 |
| [Cloudwards: SSL vs TLS](https://www.cloudwards.net/ssl-vs-tls/) | | 외부 문서 |
| [SSL.com: What is HTTPS](https://www.ssl.com/faqs/what-is-https/) | | 외부 문서 |
| [SSL.com: What is SSL](https://www.ssl.com/faqs/faq-what-is-ssl/) | | 외부 문서 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 브라우저 주소창의 자물쇠 아이콘이 무엇을 보증하고 무엇은 보증하지 않는지 적는다.
- [ ] 대칭 키와 공개 키 암호를 왜 함께 쓰는지 내 말로 설명해 본다.
- [ ] 인증서 만료나 도메인 불일치 경고를 본 경험이 있다면 어떤 상황이었는지 적는다.
