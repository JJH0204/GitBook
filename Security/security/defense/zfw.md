# ZFW

* [관련자료](https://byeong9935.tistory.com/3)

일반 장비를 [Firewall](file:///2237607/network/Firewall.md)처럼 사용하는 기능입니다.\
존이 다를 경우 통신을 차단하는 방식으로 구현합니다.

{% stepper %}
{% step %}
### 존 생성

존(zone)을 생성합니다.
{% endstep %}

{% step %}
### 트래픽 방향 설정

트래픽의 방향(예: 인바운드/아웃바운드 등)을 설정합니다.
{% endstep %}

{% step %}
### 트래픽 분류 지정

트래픽을 분류할 기준(포트, 프로토콜, IP 등)을 지정합니다.
{% endstep %}

{% step %}
### 정책 설정

트래픽 분류에 대한 허용/차단 등의 보안 정책을 설정합니다.
{% endstep %}

{% step %}
### 정책 적용

설정한 정책을 실제 존 또는 장비에 적용합니다.
{% endstep %}
{% endstepper %}
