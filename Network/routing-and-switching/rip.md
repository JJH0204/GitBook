# RIP

Distance Vector 라우팅 방식으로 오로지 거리([Hop](/broken/pages/09c50c809a0fdb36d13ac93d50a7a7c74bab7c73))와 방향을 기준으로 최적 경로를 설정

* AS(Autonomous System) 내부를 구성하는 내부용 라우팅 프로토콜(IGP)
* 경로를 설정하는 기준은 거리(Hop)카운트로 최대 15개 까지만 허용
* [라우팅 광고](/broken/pages/1311afe6176e10ecf4ab9f1b968edc045e8925f0)를 참고하여 주기적으로 라우팅 테이블을 업데이트

#### 장점

* 소규모 네트워크에서 효율적
* 비교적 구성이 간편
* 모든 제조사 라우터에서 지원하는 프로토콜 (호환성 좋음)

#### 단점

* Hop 수가 16 이상이면 네트워크를 찾지 못함
* 속도, 거리, 지연 등 고려하지 않아 최적의 경로 산정에 비효율적일 때가 있다.

연결 과정

{% stepper %}
{% step %}
### 시작 상태

아래와 같이 서브넷팅한 네트워크를 장치에 할당한 상태에서 시작합니다. (topology를 라우터의 [Loopback](/broken/pages/bfcf977eb17b47ff785a9206bb3566d9ab5f75ef) 을 이용해 간소화한 상태)

아직 라우팅이 되어 있지 않아 서로 간 통신이 불가능한 상태입니다.
{% endstep %}

{% step %}
### 현재 라우팅 테이블 확인

다음 명령으로 라우팅 테이블을 확인합니다:

{% code title="명령" %}
```
```
{% endcode %}

```bash
sh ip route
```
{% endstep %}

{% step %}
### RIP 설정

라우터 설정 모드로 들어가서 RIP를 설정합니다:

{% code title="명령" %}
```
```
{% endcode %}

```bash
conf t
router rip
network [연결된 네트워크]
```

`network [연결된 네트워크]` 를 통해 연결된 네트워크 정보를 모두 입력하고, 다른 라우터에도 동일한 과정을 진행합니다.
{% endstep %}

{% step %}
### 라우팅 광고 및 확인

호스트 간 라우팅 광고 설정이 끝나면, 다른 라우터의 가상 단말로 Ping을 날려 전달되는지 확인합니다.

현재 라우터에 적용된 라우팅 프로토콜 정보를 확인하려면:

{% code title="명령" %}
```
```
{% endcode %}

```bash
sh ip protocols
```

````

![](../../assets/images/Pasted%20image%2020240821221545.png)
{% endstep %}
{% endstepper %}

연결 2
{% stepper %}
{% step %}
## RIP 버전 전환 안내

RIP 프로토콜은 버전이 두 가지(RIPv1, RIPv2)가 있습니다. 이전 연결은 RIPv1을 통해 이루어진 것이고, 지금은 RIPv2로 연결하려 합니다.

기존의 v1 연결은 다음 명령으로 제거할 수 있습니다:

{% code title="명령" %}
```bash
no router rip
````

````

굳이 삭제하지 않아도, 기존 라우팅이 유지된 상태에서 아래와 같이 입력하면 바로 버전 전환이 가능합니다.

</div>

<div data-gb-custom-block data-tag="step">

## RIPv2로 전환

기존 router rip 설정으로 들어가서 버전을 변경합니다:

<div data-gb-custom-block data-tag="code" data-title='명령'>

```bash
router rip
version 2
````
{% endstep %}
{% endstepper %}

RIP v2 특징

* 다른 RIP 버전의 라우터와 통신 불가능 (호환성 떨어짐)
* auto-summary 기능을 끌 수 있다. (라우팅에 필요한 세부 정보를 활용할 수 있다.)
* key chain 기능으로 암호화 가능하다.

최근에는 RIPv2를 사용하는 것이 일반적입니다.

관련 링크

* [Redistribution](file:///2435498/linux_admin/Redistribution.md)
