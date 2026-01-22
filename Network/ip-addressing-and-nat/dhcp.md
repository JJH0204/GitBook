# DHCP

DHCP (Dynamic Host Configuration Protocol)는 네트워크 장치들에게 IP 주소를 동적으로 할당하고 기타 네트워크 구성 정보를 관리하는 프로토콜입니다. DHCP를 사용하면 네트워크에 연결하는 장치들에게 수동으로 IP 주소를 할당할 필요가 없어 네트워크 관리가 훨씬 간편해집니다 ([TechTerms](https://techterms.com/definition/dhcp)) ([Lifewire](https://www.lifewire.com/what-is-dhcp-2625848)).

#### DHCP의 작동 방식

{% stepper %}
{% step %}
### IP 주소 요청

네트워크에 연결하려는 장치(클라이언트)는 네트워크 시작 시 DHCP 서버에게 IP 주소를 요청합니다.
{% endstep %}

{% step %}
### IP 주소 할당

DHCP 서버는 사용 가능한 IP 주소 중 하나를 선택하여 해당 장치에 할당합니다. 이 과정은 자동으로 이루어지며, 할당된 IP 주소는 일정 기간 동안만 유효합니다(이를 '임대'라고 함).
{% endstep %}

{% step %}
### 네트워크 정보 구성

DHCP는 IP 주소 외에도 서브넷 마스크, 기본 게이트웨이, DNS 서버 정보 등을 장치에 제공합니다.
{% endstep %}
{% endstepper %}

#### DHCP의 장점

* 자동화: DHCP는 IP 주소와 네트워크 설정을 자동으로 관리하여 네트워크 관리자의 부담을 줄여 줍니다.
* 유연성: 장치가 네트워크에 자주 연결되거나 연결이 끊기는 환경에서 IP 주소를 효율적으로 관리할 수 있습니다.
* 스케일링: DHCP를 사용하면 큰 네트워크도 쉽게 확장할 수 있습니다. 새로운 장치가 네트워크에 추가될 때마다 자동으로 IP 주소를 할당받을 수 있기 때문입니다.

대부분의 홈 네트워크 및 소규모 비즈니스에서는 라우터가 DHCP 서버 역할을 하며, 큰 조직이나 네트워크에서는 전용 서버가 이 역할을 수행하기도 합니다. DHCP는 네트워크 설정의 복잡성을 줄이고 사용자가 네트워크에 빠르고 쉽게 연결할 수 있도록 도와줍니다 ([TechTerms](https://techterms.com/definition/dhcp)) ([Lifewire](https://www.lifewire.com/what-is-dhcp-2625848)).

더 자세한 정보를 원하시면, 다음 링크에서 확인하실 수 있습니다: [TechTerms - DHCP Definition](https://techterms.com/definition/dhcp) 및 [Lifewire - What Is DHCP?](https://www.lifewire.com/what-is-dhcp-2625848).

### router DHCP Set

* 관련링크: https://freewings.tistory.com/45
