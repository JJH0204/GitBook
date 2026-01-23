# ACL

* [관련자료](https://simpleisit.tistory.com/21)

## Access Control List

* 접근 제어 목록
* 라우터를 통하는 트래픽을 검사 후 분류해 지정된 처리를 수행

### 제어기준

* standard : 출발지 IP만 제어 기준에 적용
* extended : 출발지 IP를 포함해 목적지 IP 사용되는 프로토콜(port)등 좀 더 상세한 설정을 적용

{% hint style="warning" %}
ACL 설정은 목적지와 가까운 라우터에서 진행하세요.\
(라우터에서 실행하는 검사 횟수 = 트래픽 = 부하)
{% endhint %}

### ACL Standard Set

#### 방법

{% code title="Standard ACL 명령어" %}
```
```
{% endcode %}

### ACL Extended Set (추천)

#### 방법

{% code title="Extended ACL 명령어" %}
```
```
{% endcode %}

예시)

```
```

해석) 10.10.10.0에서 출발해 192.168.10.1로 향하는 http 트래픽을 허용

※ 서브넷 설정은 와일드카드로 적용됨(단일 네트워크의 경우 0.0.0.0)

### ACL 적용

{% stepper %}
{% step %}
### 1단계 — Access-list 설정

access-list를 구성합니다.
{% endstep %}

{% step %}
### 2단계 — 인터페이스에 ACL 적용

적용할 인터페이스에 접속한 뒤 아래 명령으로 적용합니다.

{% code title="인터페이스에 ACL 적용" %}
```
```
{% endcode %}

* in: 인터페이스를 통해 라우터로 들어오는 패킷에 대해 적용
* out: 인터페이스를 통해 라우터 밖으로 나가는 패킷에 대해 적용
{% endstep %}
{% endstepper %}

### ACL 정책 적용 기준

* Access-list는 위에서 아래로 순서대로 적용됩니다.
* ACL에 명시되지 않은 트래픽은 Deny(차단) 됩니다.
  * 필요한 다른 트래픽을 허용하려면 마지막에 `permit ip any any`를 추가해야 합니다.

### 그 외 정보

* tcp 기반 서비스: http, https, ftp
* icmp 기반 서비스: ping
  * ping을 허용 또는 차단할 때는 `echo`와 `echo-reply`를 모두 허용/차단해야 합니다.

### 네트워크 보안에 사용되는 ACL

* [RACL](file:///6408728/network/RACL.md)
* [DACL](file:///6408728/security/DACL.md)
