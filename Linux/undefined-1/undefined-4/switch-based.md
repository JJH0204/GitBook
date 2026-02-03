# Switch Based

스위치에 연결된 포트를 기반으로 VLAN을 구성하는 기술

## 과정1

{% stepper %}
{% step %}
### VLAN 생성 및 포트 할당

* Subnetting을 통해 단말 장치에 우선적으로 독립된 IP를 할당한다.\
  링크: ../network/Subnetting.md
* 스위치 접속 및 전역 설정 모드 진입:

```
enable
conf t
```

* VLAN 생성:

```
vlan <번호>
name <vlan이름>
exit
```

* 포트 접속 및 VLAN 할당:

```
int <포트이름>
switchport mode access
switchport access vlan <번호>
exit
```

위 과정을 VLAN 개수만큼 반복 수행한다.
{% endstep %}

{% step %}
### Switch 간 연결(Trunk) 설정

* 스위치 간 연결 정보를 각 스위치에서 관리해야 한다.\
  연결 방식: Trunk (관리 규칙: trunk protocol)\
  관련 링크: ../network/VTP\_Revision.md, trunk%20protocol.md
* 다른 스위치와 연결된 포트 설정:

```
int <포트이름>
switchport mode trunk
exit
```

이 설정은 서로 연결된 스위치 각각에서 수행해야 한다.
{% endstep %}

{% step %}
### Router (Gateway) 설정

* 라우터 접속 및 전역 설정 모드 진입:

```
enable
conf t
```

* 인터페이스 활성화: (참고 링크: obsidian://open?vault=MyNote\&file=Gateway%20%EC%84%A4%EC%A0%95)

```
no shutdown
```

* 스위치와 연결된 인터페이스의 VLAN 서브인터페이스 접속:

```
int <인터페이스>.<vlan번호>
```

* 트렁크(Encapsulation) 설정:

```
encapsulation <protocol이름> <vlan번호>
# 예: encapsulation dot1Q 10
```

* Gateway IP 할당:

```
ip address <아이피> <서브넷마스크>
```
{% endstep %}
{% endstepper %}

## Native VLAN

***

링크: Native%20VLAN.md

## Switch 연결 관리

***

Switch 끼리 연결되어 있는 경우 이 연결 정보를 각 Switch에서 관리해야 한다.\
이 연결 방식을 Trunk라고 하고 관리 규칙을 trunk protocol이라고 한다.\
관련 링크: trunk%20protocol.md

## Router 설정

***

같은 네트워크의 장치끼리 통신은 원활하지만 다른 네트워크와 통신을 불가능한 상태다. 이 문제를 Router 설정을 통해 해결할 수 있다.

## VTP

***

링크: ../network/VTP.md

{% hint style="info" %}
VLAN 생성 및 Trunk 설정은 각 스위치에서 개별적으로 적용해야 합니다. Router의 서브인터페이스 및 encapsulation 설정은 스위치 측의 트렁크 설정과 일치해야 합니다.
{% endhint %}
