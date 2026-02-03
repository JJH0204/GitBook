# iptables

{% hint style="info" %}
* CentOS에서는 firewalld를 이용해 접근 제어를 하기 때문에 iptables를 사용하지 않게 되었다.
* 기존에 firewalld를 사용하고 있다면 둘 중 하나만 활성화하여 사용해야 한다.
* 관련자료: https://linuxstory1.tistory.com/entry/iptables-%EA%B8%B0%EB%B3%B8-%EB%AA%85%EB%A0%B9%EC%96%B4-%EB%B0%8F-%EC%98%B5%EC%85%98-%EB%AA%85%EB%A0%B9%EC%96%B4
{% endhint %}

{% stepper %}
{% step %}
### 설치

```sh
dnf install -y iptables-services iptables-utils
systemctl start iptables
systemctl enable iptables
```
{% endstep %}

{% step %}
### 기존 서비스 비활성화

```sh
systemctl stop firewalld
systemctl disable firewalld
```
{% endstep %}

{% step %}
### Chain(zone) 설정 확인

```sh
iptables -L
```

예시 출력:

```sh
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
ACCEPT     all  --  anywhere             anywhere             state RELATED,ESTABLISHED
ACCEPT     icmp --  anywhere             anywhere
ACCEPT     all  --  anywhere             anywhere
ACCEPT     tcp  --  anywhere             anywhere             state NEW tcp dpt:ssh
REJECT     all  --  anywhere             anywhere             reject-with icmp-host-prohibited

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination
REJECT     all  --  anywhere             anywhere             reject-with icmp-host-prohibited

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
```
{% endstep %}

{% step %}
### 정책 추가

예: 특정 출발지 IP를 차단

```sh
iptables -A INPUT -s 192.168.1.8 -j DROP
```

* 출발지(192.168.1.8)에서 들어오는 패킷은 DROP한다.
* IP는 대역으로 설정 가능(예: 192.168.0.0/16)
*   목적지도 설정 가능:

    ```sh
    iptables -A INPUT -s 192.168.1.8 -d 192.168.1.110 -j DROP
    ```
* 프로토콜도 설정 가능
* 추가 후 서비스 재시작 필요

추가 후 예시:

```sh
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
ACCEPT     all  --  anywhere             anywhere             state RELATED,ESTABLISHED
ACCEPT     icmp --  anywhere             anywhere
ACCEPT     all  --  anywhere             anywhere
ACCEPT     tcp  --  anywhere             anywhere             state NEW tcp dpt:ssh
REJECT     all  --  anywhere             anywhere             reject-with icmp-host-prohibited
DROP       all  --  192.168.1.8          anywhere # 추가된 것을 확인가능

# 정책은 위에서 아래로 순차적으로 적용되기 때문에 불필요한 정책은 제거해야 한다.
Chain FORWARD (policy ACCEPT)
target     prot opt source               destination
REJECT     all  --  anywhere             anywhere             reject-with icmp-host-prohibited

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
```
{% endstep %}

{% step %}
### 정책 삭제

* 정책 파일을 열어서 직접 삭제 가능
{% endstep %}

{% step %}
### 설정 파일

```
/etc/sysconfig/iptables
```

* 방화벽 정책 파일(iptables)
* 방화벽 환경 설정 파일(iptables-config)
{% endstep %}
{% endstepper %}
