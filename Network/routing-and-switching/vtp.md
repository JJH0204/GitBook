# VLAN 트렁킹 프로토콜 (VTP)

* VLAN Trunking Protocol의 약자
* VLAN 정보를 동기화 하는데 사용되는 기능
* 3가지 모드: Server, Client, Transparent

## 모드 설명

{% stepper %}
{% step %}
### Server

* VLAN 설정을 공유하는 주체
* Revision 값이 높은 Server 모드의 Switch를 기준으로 VLAN 설정을 공유한다.
* 공유를 위해 VTP Domain이 같아야 하며, 스위치들이 Trunk로 연결되어야 한다.
{% endstep %}

{% step %}
### Client

* 서버와 동기화, VLAN의 정보를 받아온다.
* VLAN 정보를 생성하거나 삭제할 수 없음
{% endstep %}

{% step %}
### Transparent

* Server/Client 와 VLAN 정보를 동기화 하지 않는다.
* 단, 중간 다리 역할로 다른 Client로 Server의 VLAN 정보를 넘겨주기는 함
* Client와 달리 VLAN 정보를 생성/삭제 할 수 있지만 공유할 수는 없다.
* 완전 독립 모드
{% endstep %}
{% endstepper %}

## 명령어

* `vtp mode <모드>`
  * 스위치의 모드를 설정한다. (예: server, client, transparent)
* `vtp domain <이름>`
  * 스위치의 도메인 이름을 설정한다.
* `show vtp status`
  * VTP 설정 상태 확인
* 그 외
  * `vtp password` (비밀번호 설정/확인)
  * `vtp version` (VTP 버전 설정/확인)

## VTP 리비전 번호 (VTP Revision)

{% hint style="info" %}
* Trunk 연결 정보가 수정되면 값이 0으로 초기화된다.
* VLAN 관련 명령어 동작 시 값이 1씩 증가한다.
{% endhint %}
