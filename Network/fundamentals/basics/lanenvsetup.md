# LANEnvSetup

{% stepper %}
{% step %}
### 장비 배치

네트워크를 구성하고자 하는 곳에 총 3개의 장치가 개별적으로 놓여있다.
{% endstep %}

{% step %}
### 스위치로 묶기

이를 하나의 네트워크로 묶기 위해 L2 Switch(그냥 Switch라고 해도 됨)를 사용한다.
{% endstep %}

{% step %}
### IP 할당

하나의 스위치로 모든 기기를 연결했다고 데이터 통신이 가능한 것은 아니다.\
각 PC에 접속해 각각의 독립된 IP를 할당해야 한다.

여기서 [Subnet Mask](/broken/pages/c4ca2e01935cb0fafbda6aec7631cd818c96c148)에 대한 내용이 중요하다.\
192.168.10.0/24 대역을 사용한다는 의미에서 255.255.255.0 입력
{% endstep %}

{% step %}
### 나머지 장비 설정

다른 PC 들도 아래와 같이 설정했다.

* PC: 192.168.10.2
* server: 192.168.10.3
{% endstep %}

{% step %}
### 연결 확인

잘 연결되었는지 테스트해본다.

통신이 잘 이뤄진다. 이렇게 LAN 환경은 구축이 되었다.
{% endstep %}
{% endstepper %}

{% hint style="warning" %}
주의할 점: IP 대역(네트워크 주소)을 신경 써야 한다. 다른 대역의 IP를 사용하면 같은 네트워크로 인식되지 않아 통신할 수 없다.
{% endhint %}

* [단말 원격 접속](/broken/pages/4d8fcb02b44dc2d1577ea80cfdf80d2fe1a608e2)
* [VLAN](/broken/pages/aaed20016af6fda2b281077600407792b3295d97)
* [STP](/broken/pages/dbf77dffab3bfeda430beae055a42f3c6bc84511)
