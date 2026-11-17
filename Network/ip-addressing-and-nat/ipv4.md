# IPv4 주소 체계 (IPv4)

IPv4 개요

* 4개의 옥텟으로 구성된다. (1옥텟 = 8bit = 256개의 경우의 수)
* 총 32bit로 구성된 데이터
* 표현 가능한 주소 범위: 0.0.0.0 \~ 255.255.255.255
* 가장 앞자리는 IP class를 표현
* 내부 사설망 IP는 관리자가 임의로 IP를 할당해 사용 가능
  * 단, 127.0.0.1은 사용 불가
* 외부 통신을 위해 외부 IP로 변환하는 NAT 서버를 사용

{% hint style="info" %}
"127.0.0.1"은 루프백(loopback) 주소로, 호스트 자체를 가리키므로 사설망 할당용으로 사용할 수 없다.
{% endhint %}

<table data-view="cards"><thead><tr><th>관련 문서</th><th data-card-target data-type="content-ref">링크</th></tr></thead><tbody><tr><td>IP Class</td><td><a href="ipv4.md">바로가기</a></td></tr><tr><td>공인IP와 사설IP</td><td></td></tr><tr><td>네트워크 주소</td><td></td></tr><tr><td>브로드캐스트 주소</td><td></td></tr></tbody></table>

## IP 클래스별 주소 범위와 사설망 대역

* Class A : 0.0.0.0 \~ 127.255.255.255
  * 사설망 대역: 10.
* Class B : 128.0.0.0 \~ 191.255.255.255
  * 사설망 대역: 172.16. \~ 172.31.
* Class C : 192.0.0.0 \~ 223.255.255.255
  * 사설망 대역: 192.168.
