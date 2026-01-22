# OSPF

* [관련자료](https://nirsa.tistory.com/32)

## Open Shortest Path First

* 라우터 라우팅 프로토콜
* 최적 경로를 계산할 때 SPF(Shortest Path First) 또는 다익스트라 알고리즘을 이용해 목적지까지 최적의 경로를 계산

### 장점

* area 단위로 구성되어 대규모 네트워크를 안정적으로 운영할 수 있다.
* 표준 라우팅 프로토콜이다.
* 다른 라우팅 프로토콜에 비해 convergence time이 빠르다.
* Stub이라는 강력한 축약 기능을 지원한다.

### 특징

* 경계 대역을 광고할 때 Area Num을 사용한다.
* No Auto\~ 가 필요 없다.

### 명령어

* OSPF 환경 설정

{% code title="OSPF 설정" %}
```
```
{% endcode %}

* 네트워크와 Area 설정

{% code title="네트워크 설정" %}
```
```
{% endcode %}

설명: 라우터와 연결된 네트워크의 구역을 설정 및 외부와 공유

### 주의사항

{% hint style="warning" %}
* Area Num가 0인 구역을 backbone area 라고 부르며 외부와 통신하기 위해서는 꼭 backbone area와 연결되어 있어야 가능하다.\
  (backbone 설정 없이 area num을 1이상 설정하면 네트워크 통신이 불가능해진다.)
* Virtual-link 기능으로 우회할 수 있지만 물리적 환경이 어쩔 수 없을 때만 사용
{% endhint %}

### 관리 명령어

{% code title="OSPF 정보 확인" %}
```
```
{% endcode %}

{% code title="이웃 정보 출력" %}
```
```
{% endcode %}

{% code title="라우팅 경로 정보 출력" %}
```
```
{% endcode %}

{% code title="인터페이스별 OSPF 정보" %}
```
```
{% endcode %}

그 외에도 많은 명령어가 있음.

### 관련

[Redistribution](file:///2435498/linux_admin/Redistribution.md)
