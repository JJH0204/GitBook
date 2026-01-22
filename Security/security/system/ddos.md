# DDoS

* 분산 서비스 거부 공격
* hping3 / SlowHTTPTest / GoldenEye / LOIC 등 다양한 Attack Tool이 있다.
* 대다수 공격자는 대량의 zombi pc를 만들어 공격에 활용
* 이때 공격자 PC를 C\&C라고 하고 공격에 사용되는 zombi pc 를 zombi system, zombi pc 들을 zombi net이라고 한다.

{% hint style="info" %}
일반적으로 DDoS 공격은 공격 도구와 봇넷(zombi net)을 조합해 대규모 트래픽/요청을 발생시켜 서비스 불능을 유발합니다.
{% endhint %}

## Basics DoS Attack

```
hping3 --icmp [IP] [추가 옵션]
```

* \--icmp: 공격 패킷 형태(ping 패킷 외 다른 패킷 설정 가능)

## SYN Flooding Attack

***

* TCP 핸드 셰이크 원리를 이용한 공격
* Layer4 공격에 포함
* [관련자료](https://m.blog.naver.com/techtrip/222561492285)

### hping3 tool 을 활용한 SYN Floodin

{% code title="예: SYN Flooding with hping3" %}
```sh
hping3 [Victim_IP] -S [추가 옵션]
```
{% endcode %}

### SYN Flooding 공격 패턴

{% stepper %}
{% step %}
### 소스IP 변조를 통한 반사 공격

* 소스IP주소를 스푸핑 하여 핸드 셰이크 프로세스를 비정상적으로 만드는 방식
* Land Attack, Smurf Attack 등
{% endstep %}

{% step %}
### SYN/ACK 패킷 차단 후 공격

* 서버가 보낸 SYN/ACK에 대한 응답(ACK)을 차단하거나 무시하도록 만들어 연결 자원을 고갈시키는 방식
{% endstep %}

{% step %}
### 봇넷을 활용한 DDoS 형태의 공격

* 다수의 zombi pc(봇)를 동원해 대량의 SYN 패킷 등을 전송하여 서비스 불능 유발
{% endstep %}
{% endstepper %}

### 공격 방어

* [IDS](/broken/pages/0d63d92e675686084c8c6ec5c59232835d025ecf) / IPS / UTM(IDS, IPS 통합) 시스템 활용

## DDoS 공격 현황

***

* [https://horizon.netscout.com/](https://horizon.netscout.com/)
