# SSL

SSL(Secure Sockets Layer)은 인터넷 통신의 보안을 위해 개발된 암호화 기반의 프로토콜입니다. 원래 1995년 넷스케이프(Netscape)에 의해 개발되었고, 인터넷 통신에서 프라이버시, 인증, 데이터 무결성을 보장하기 위한 목적으로 만들어졌습니다. SSL은 현대의 TLS(Transport Layer Security) 암호화의 전신입니다 ([Connect, Protect and Build Everywhere](https://www.cloudflare.com/learning/ssl/what-is-ssl/)).

#### SSL/TLS의 작동 원리

SSL/TLS는 클라이언트와 서버 간의 안전한 통신을 보장하기 위해 암호화와 인증을 사용합니다. 통신이 시작되면, 두 장치 간에 "핸드셰이크(handshake)"라는 과정을 통해 암호화 알고리즘과 키 교환을 협상합니다. 이를 통해 안전한 연결이 설정되고, 전송되는 데이터는 암호화되어 제3자가 데이터를 엿볼 수 없게 만듭니다​ ([Cloudwards](https://www.cloudwards.net/ssl-vs-tls/))​​ ([Connect, Protect and Build Everywhere](https://www.cloudflare.com/learning/ssl/what-is-ssl/))​.

{% hint style="info" %}
핸드셰이크 과정에서는 암호화 알고리즘(예: 대칭/비대칭 암호), 키 교환 방식, 인증서 교환 등이 협상됩니다. 이 과정을 통해 세션 키가 생성되고 이후 데이터 전송은 해당 세션 키로 암호화됩니다.
{% endhint %}

#### SSL/TLS의 중요성

* 프라이버시 보호: SSL/TLS는 전송되는 데이터를 암호화하여, 데이터가 전송 중에 도청되더라도 해독할 수 없게 만듭니다.
* 데이터 무결성: 디지털 서명을 통해 데이터가 전송 중에 변조되지 않았음을 보장합니다.
* 인증: 서버와 클라이언트가 실제로 자신이 주장하는 주체임을 확인할 수 있습니다. 이를 통해 피싱 공격 등을 방지할 수 있습니다​ ([Connect, Protect and Build Everywhere](https://www.cloudflare.com/learning/ssl/what-is-ssl/))​​ ([SSL.com](https://www.ssl.com/faqs/what-is-https/))​.

#### SSL/TLS의 최신 버전

현재 SSL은 더 이상 사용되지 않으며, 그 후속 버전인 TLS가 표준으로 자리 잡았습니다. 가장 최신 버전은 TLS 1.3으로, 2018년에 정의되었고 이전 버전보다 보안성과 성능이 개선되었습니다. TLS 1.2도 여전히 널리 사용되고 있지만, TLS 1.0과 1.1은 많은 보안 취약점 때문에 더 이상 사용되지 않습니다​ ([SSL.com](https://www.ssl.com/faqs/faq-what-is-ssl/))​.

{% hint style="warning" %}
참고: SSL(구버전)은 더 이상 사용되지 않으므로, 실제 운영 환경에서는 TLS(특히 TLS 1.2 이상)를 사용해야 합니다.
{% endhint %}

#### SSL 인증서

SSL/TLS를 사용하려면 SSL 인증서가 필요합니다. 이 인증서는 웹사이트나 서버의 신원을 확인하고, 공용 키를 통해 데이터를 암호화하는 데 사용됩니다. 인증서는 신뢰할 수 있는 인증 기관(CA)이 발급하며, 도메인 유효성 검사(DV), 조직 유효성 검사(OV), 확장 유효성 검사(EV) 등 다양한 검증 수준이 있습니다​ ([Connect, Protect and Build Everywhere](https://www.cloudflare.com/learning/ssl/what-is-ssl/))​​ ([SSL.com](https://www.ssl.com/faqs/what-is-https/))​.

#### HTTPS

HTTPS는 HTTP에 SSL/TLS 암호화를 추가한 프로토콜입니다. 이를 통해 웹 브라우저와 서버 간의 모든 통신이 암호화되어 데이터가 안전하게 전송될 수 있습니다. 또한, HTTPS를 사용하면 웹사이트의 신뢰성을 높이고, SEO에도 긍정적인 영향을 미칠 수 있습니다​ ([SSL.com](https://www.ssl.com/faqs/what-is-https/))​.

<details>

<summary>더 자세한 정보(외부 링크)</summary>

* Cloudflare: https://www.cloudflare.com/learning/ssl/what-is-ssl/
* Cloudwards: https://www.cloudwards.net/ssl-vs-tls/
* SSL.com: https://www.ssl.com/faqs/what-is-https/
* SSL.com(FAQ): https://www.ssl.com/faqs/faq-what-is-ssl/

</details>
