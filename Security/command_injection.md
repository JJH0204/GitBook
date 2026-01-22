# Command\_Injection

위와 같은 구조일때 ''안에 들어갈 명령어를 원하는 명령어로 바꾼다면 실행이 가능할 것 같다.

* &: 둘 이상의 명령어를 연결할 때 사용하는 기호를 사용해 injection

ping 명령어 실행 후 입력한 명령어 실행

192.168.56.000 = ping -c 4 192.168.56.000

{% stepper %}
{% step %}
### 1. 기본 테스트: 세션과 요청

아래 curl 명령으로 세션 쿠키와 security=low 상태에서 취약점 페이지에 요청을 보낸다:

{% code title="실행 예" %}
```bash
curl --cookie "PHPSESSID=aqsgn666ja2jubcdvc40euees2; security=low" http://192.168.56.118/vulnerabilities/exec/ --data "ip=-c 2 192.168.56.102&Submit=Submit"
```
{% endcode %}

결과: ip 라는 곳에 명령어를 저장하게 되고 Submit 버튼을 누르는 것을 확인할 수 있음.
{% endstep %}

{% step %}
### 2. 명령어 연속 실행: 세미콜론 사용

다음과 같이 세미콜론(;)으로 명령어를 이어서 실행할 수 있다:

{% code title="실행 예 (명령 추가)" %}
```bash
curl --cookie "PHPSESSID=aqsgn666ja2jubcdvc40euees2; security=low" http://192.168.56.118/vulnerabilities/exec/ --data "ip=-c 2 192.168.56.102;cat /etc/passwd&Submit=Submit"
```
{% endcode %}

결과: ; 은 순차 실행. & 은 백그라운드(랜덤) 실행.
{% endstep %}

{% step %}
### 3. 소스 형태 확인 및 파라미터

소스 형태를 보면:

* ip : 프록시 툴을 활용해 변수 이름 확인 가능
* 어떤 명령어든 검사 없이 변수에 저장 후 cmd로 실행
{% endstep %}

{% step %}
### 4. 보안 레벨 올리기 및 필터 우회 시도

보안 레벨을 올려 방어가 어떻게 바뀌는지 확인:

* && 과 ; 를 공백으로 만드는 것 만으로는 완전히 방어하지 못함.
* 모든 연결 키워드를 공백으로 변경 시도했으나, 파이프라인(|)을 방어할 때 실수가 있어 여전히 명령어 실행이 가능했음.
{% endstep %}
{% endstepper %}

{% hint style="info" %}
토큰 기반 방어 메커니즘 설명(예시)
{% endhint %}

<details>

<summary>토큰/validation 기반 방어 (펼치기)</summary>

* token을 사용하는 것이 주 특징
* 1회성 인증에 사용되는 token을 이용해 세션의 일치 확인
* 입력 받은 값을 '.'을 기준으로 4개의 옥텟으로 나누고 각 옥텟이 숫자인지 검사하는 등 디테일한 검사를 하기에 command injection을 방어할 수 있게 된다.
* 다만, 다른 공격 기법과 융합해 공격하면 뚫릴 수도 있다.

</details>
