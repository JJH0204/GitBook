# CTF\_Earth

{% hint style="info" %}
Attacker

* ip: 192.168.56.105/24

Victim

* 같은 동일한 네트워크 대역에 있다고 가정하고 진행
{% endhint %}

## \[1-1] Victim 대상 찾기

netdiscover, nmap 등 scanning tool을 활용해 피해자 PC의 IP를 찾는다.

* `nmap 192.168.56.0/24`<br>
* `netdiscover -r 192.168.56.0/24`<br>

{% hint style="info" %}
Attacker

* ip: 192.168.56.105/24

Victim

* ip: 192.168.56.104/24
* ssh, http, https 서비스가 동작 중임을 확인했다.
* ssh 접속을 먼저 시도하는 것은 흔적(Log)을 남길 수 있기 때문에 지양하고, ip 를 활용해 web 접속을 시도한다.
{% endhint %}

***

## \[1-2] Browser 접속

victim server에서 서비스 중인 웹 서비스를 활용해 접속을 시도한다.

* browser 접속: `http://192.168.56.104/`<br>
* browser 접속: `https://192.168.56.104/`<br>

{% hint style="info" %}
`http://(또는 https://)ip/`를 활용한 웹 서비스 접속이 원활하지 않다. 다른 접속 방법을 찾아야 한다.
{% endhint %}

### https 프로토콜의 특성 활용한 도메인 이름 찾기

* 브라우저의 기능을 활용해 https의 설정(key)를 볼 수 있다.\
  &#x20;&#x20;
* 찾은 도메인 이름으로 사이트에 접속할 수 있도록 host 파일을 수정한다.
  * `sudo vi /etc/hosts`
  * `192.168.56.104 earth.local`
  * `192.168.56.104 terratest.earth.local`
  * 저장
* 도메인 이름으로 웹 서비스에 접속한다.\
  &#x20;

{% hint style="info" %}
https ssl key 설정을 통해 알아낸 도메인 이름(earth.local / terratest.earth.local)으로 웹 서비스 접속에 성공했다.

* `http://earth.local/`, `http://terratest.earth.local/`, `https://earth.local/` → 웹 서비스 페이지로 접속
* `https://terratest.earth.local/` → 더미 페이지로 접속
{% endhint %}

### 서비스 분석

* 실제 기능을 사용(또는 F12, 개발자 툴을 활용)하며 서비스 특징을 분석한다.
* 텍스트 입력\
  \
  지구로 보낼 메시지를 입력할 수 있는 입력 칸이 활성화 되어 있다.
* 암호 입력<br>
* 전송 버튼<br>
* 이전 메시지 기록\
  \
  지구로 보내는 메시지는 함께 입력한 암호와 조합해 암호화하여 저장된다. 사이트에서 사용하고 있는 암호화 로직이 무엇인지 찾을 필요가 있어 보인다.

### dirb 툴을 활용한 scanning

* dirb tool
* 웹 페이지에 생성될 가능성이 있는 모든 디렉토리 이름을(웹 개발자가 서비스를 구축할 때 자주 사용하는 디렉토리 이름을) 대입하여 접속 가능 여부를 출력한다.
