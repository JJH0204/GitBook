# VLAN

* Virtual LAN의 약자
* 가상의 논리적으로 분리된 네트워크를 구축할 때 사용한다.
* 물리적 구성과 상관없이 우선적으로 적용된다.
* switch의 기본 기능

## VLAN 설정 방법

{% tabs %}
{% tab title="Mac Based" %}
Mac 주소를 기반으로 VLAN을 구분하여 설정하는 방식입니다.

* 장치의 MAC 주소를 기준으로 VLAN을 할당합니다.
* 이동이 잦은 단말(예: 노트북)에 대해 MAC 기반으로 고정된 VLAN을 부여할 수 있습니다.
{% endtab %}

{% tab title="IP Based" %}
IP 주소를 기반으로 VLAN을 구분하는 방식입니다.

* 특정 IP 대역을 VLAN에 매핑하여 트래픽을 분리합니다.
* IP 변경이나 DHCP 환경에서는 관리상의 고려가 필요합니다.
{% endtab %}

{% tab title="Switch Based" %}
스위치에서 포트 또는 설정을 통해 VLAN을 구성하는 방식입니다.\
자세한 내용은 기존 문서를 참고하세요: [Switch Based](file:///2435498/linux_admin/Switch%20Based.md)
{% endtab %}

{% tab title="Policy Based" %}
정책(예: 사용자, 역할, 트래픽 유형 등)을 기반으로 VLAN을 동적으로 할당하는 방식입니다.

* 보다 세밀한 제어가 가능하지만 관리 복잡도가 올라갈 수 있습니다.
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Switch Based를 제외하면 환경 변화(예: 사용자의 이동, IP 변경 등)에 즉각 반영하기 어려워 실제 운영 환경에서는 잘 사용하지 않는 편입니다.
{% endhint %}
