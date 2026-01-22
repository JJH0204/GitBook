# STP

* Spanning Tree Protocol (즉, 가지치기 기능)
* 연결된 스위치 간에 여러 포트가 연결된 경우 유효한 연결 한 개만 남기고 나머지 연결을 비활성화시키는 기능<br>
* 즉, 단일 경로를 제공하는데 사용된다.
* VLAN마다 설정 가능하다. (VLAN마다 사용할 연결을 다르게 설정할 수 있다.)

## 포트 비활성화 규칙 (Port Election)

{% stepper %}
{% step %}
### Priority 기반 선출

* Priority 값이 낮은 Switch가 우선으로 선택된다.
* Priority 값이 같을 경우에는 BID(Bridge ID)의 Address가 가장 낮은 Switch가 우선이다.
* Root Switch의 모든 포트는 Forward(전송) 상태가 된다.<br>

{% hint style="info" %}
Priority 값은 VLAN 연결마다 따로 설정 가능하다.\
설정 시 0을 포함해 4096의 배수로 설정해야 한다.
{% endhint %}
{% endstep %}

{% step %}
### Root Port 선택 (Non-Root Switch에서)

Non-Root Switch는 Root Switch로 향하는 하나의 Root Port를 선택한다.

선택 기준:

* Root Switch로 향하는 Cost가 가장 적은 포트
* Cost가 같은 경우 Port ID가 낮은 포트가 선택된다
{% endstep %}

{% step %}
### 각 세그먼트에서 DP(Designated Port) 선출

* 각 세그먼트마다 하나의 DP가 선출된다.
* 그 외 포트는 non-DP가 되어 BLK(차단) 상태가 되어 데이터 송수신이 불가능해진다.
{% endstep %}
{% endstepper %}

## 자동 갱신 주기

스위치 간 신호 확인은 2초에 한 번(최대 20초) 대기 후 연결 여부를 결정한다.\
연결이 동기화되는데 총 55초(20 + 15 + 20)가 소요된다.\
(구체적 타이밍은 스위치 종류에 따라 달라질 수 있다.)
