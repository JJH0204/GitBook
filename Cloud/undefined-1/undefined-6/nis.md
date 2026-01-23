# NIS

NIS는 분산 데이터베이스 시스템으로, 네트워크의 여러 시스템 간에 일관된 구성 파일을 유지하기 위해 사용됩니다. 원래 Sun Microsystems에서 UNIX 기반 시스템을 중앙 관리하기 위해 개발되었습니다.

### NIS의 주요 특징

{% stepper %}
{% step %}
### 클라이언트-서버 아키텍처

* NIS는 클라이언트-서버 모델을 사용합니다.
* 마스터 서버와 슬레이브 서버로 나뉘며, 마스터 서버는 주요 데이터를 저장하고 관리합니다.
* 슬레이브 서버는 마스터 서버의 백업 역할을 하며, 클라이언트 요청을 처리합니다.
{% endstep %}

{% step %}
### NIS 도메인

* NIS는 도메인 개념을 사용하지만, 계층적 구조는 아닙니다.
* 따라서 네트워크를 하나의 도메인으로 묶어서 관리할 수 있습니다.
{% endstep %}

{% step %}
### NIS 맵

* NIS는 다양한 맵을 사용해 정보를 저장합니다.
  * 예: `passwd.byname` 맵은 사용자 이름을 키로 해서 암호 정보를 저장합니다.
  * 예: `hosts.byname` 맵은 호스트 이름을 키로 해서 IP 주소를 저장합니다.
* 주요 맵: `passwd`, `group`, `hosts`, `networks`, `protocols`, `services` 등
{% endstep %}
{% endstepper %}

### NIS의 사용 사례

* 중앙 관리
  * NIS를 사용하면 모든 사용자와 호스트 정보를 중앙에서 관리할 수 있어, 새로운 사용자나 시스템을 추가할 때 각 시스템에서 개별 설정을 할 필요가 없습니다.
* 네트워크 관리
  * 네트워크 내의 IP 주소, 네트워크 마스크, 호스트 이름 등의 정보를 일관되게 유지할 수 있어 네트워크 관리가 간편해집니다.

{% hint style="warning" %}
#### NIS와 보안

NIS는 암호화되지 않은 통신을 사용하므로 민감한 데이터가 도청될 위험이 있습니다. 이러한 보안 한계 때문에 더 강력한 보안 기능을 제공하는 NIS+나 LDAP로 대체되는 경우가 많습니다.
{% endhint %}

<details>

<summary>참고 자료 (자세한 내용)</summary>

* IBM - NIS 개요: https://www.ibm.com/docs/en/aix/7.1?topic=services-network-information-service-nis-overview
* Oracle - NIS 개요: https://docs.oracle.com/cd/E36784\_01/html/E36871/nis-overview.html
* Wikipedia - Network Information Service: https://en.wikipedia.org/wiki/Network\_Information\_Service
* Oracle 문서: https://docs.oracle.com/cd/E19253-01/816-4556/anis1-25461/index.html

</details>
