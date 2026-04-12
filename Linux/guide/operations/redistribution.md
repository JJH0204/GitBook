# Redistribution

[관련자료](https://simpleisit.tistory.com/20)

다른 라우팅 프로토콜을 채용한 라우터와 라우팅 테이블을 공유해야 할 경우, 각 라우팅 프로토콜마다 존재하는 redistribution 기능을 이용해 별도 설정을 할 수 있다.

{% hint style="warning" %}
서로 다른 라우터 간 중복된 대역을 광고할 경우 에러가 발생할 수 있으므로, 반드시 한쪽 라우터에서만 광고를 진행해야 합니다.\
또한 redistribution 설정 전 네트워크 설정을 완벽하게 해 두어야 원활한 연결을 기대할 수 있습니다.
{% endhint %}

## RIP <> EIGRP

***

윗 네트워크 = RIP 프로토콜 (이하 RIP 네트워크)\
아랫 네트워크 = EIGRP 프로토콜 (이하 EIGRP 네트워크)

위 두 네트워크를 연결하는 네트워크 대역을 설정하고 포트에 IP를 할당한 상태이다.

{% stepper %}
{% step %}
### EIGRP 라우터 설정

EIGRP 라우터에 접속하여 추가된 네트워크를 EIGRP에 추가한다.

예:

{% code title="EIGRP 설정" %}
```
```
{% endcode %}

```bash
router eigrp 100
network <추가된 네트워크> <와일드카드>
```

설정이 추가되었는지 확인한다.
{% endstep %}

{% step %}
### RIP 라우터에서 redistribution 설정

RIP 라우터에 접속하여 EIGRP로부터의 경로를 RIP로 redistribute 한다.

예:

{% code title="RIP 설정" %}
```
```
{% endcode %}

```bash
router rip
redistribute eigrp 100 metric 0
network <연결할 네트워크> <와일드카드>
no auto-summary
```

이후 라우팅 테이블을 확인하면 광고가 정상적으로 이뤄진 것을 확인할 수 있다.
{% endstep %}
{% endstepper %}

## OSPF <> EIGRP

***

* 꼭 OSPF의 backbone과 연결할 필요는 없다.
