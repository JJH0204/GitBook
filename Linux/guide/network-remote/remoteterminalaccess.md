# RemoteTerminalAccess

Switch / Router 에 원격 접속을 하기 위해서는 적절한 설정이 필요하다.

## Switch / Router 공통

{% stepper %}
{% step %}
### 장치에 접속

장치 콘솔 또는 시리얼로 접속합니다.
{% endstep %}

{% step %}
### conf t 모드 활성화

전역 설정 모드로 진입합니다. 예: enable -> configure terminal
{% endstep %}

{% step %}
### 인터페이스 접속

VTY 라인으로 이동합니다. 예: line vty 0 4
{% endstep %}

{% step %}
### password 설정

VTY 접속용 비밀번호를 설정합니다. 예: password <암호>
{% endstep %}

{% step %}
### login 설정

VTY에서 비밀번호 인증을 사용하도록 설정합니다. 예: login
{% endstep %}

{% step %}
### 저장

설정 변경을 저장합니다. 예: do write memory
{% endstep %}
{% endstepper %}

## Switch

스위치에 IP를 할당하려면 VLAN 1에 할당해야 합니다. (디폴트 IP 값으로 적용됩니다.)

{% stepper %}
{% step %}
### 인터페이스 접속

VLAN 1 인터페이스로 이동합니다. 예: int vlan 1
{% endstep %}

{% step %}
### IP 설정

IP 주소와 서브넷 마스크를 설정합니다. 예: ip address <아이피> <서브넷마스크>
{% endstep %}

{% step %}
### 인터페이스 활성화

인터페이스를 활성화합니다. 예: no shutdown
{% endstep %}

{% step %}
### 종료

인터페이스 설정을 마치고 빠져나옵니다. 예: exit
{% endstep %}
{% endstepper %}

스위치가 외부와 통신할 수 있도록 외부로 통하는 게이트웨이를 설정합니다.

{% stepper %}
{% step %}
### 디폴트 게이트웨이 설정

예: ip default-gateway <게이트웨이>
{% endstep %}

{% step %}
### 종료

설정을 마치고 빠져나옵니다. 예: exit
{% endstep %}
{% endstepper %}

## Router

라우터는 스위치와 달리 기본 설정만 잘 구성되어 있다면 추가 설정 없이 게이트웨이를 통해 접속이 가능합니다.

## 접속 방법

{% hint style="info" %}
명령어 예시:
{% endhint %}

```bash
telnet <접속할아이피>
```
