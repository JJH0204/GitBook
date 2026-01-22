# CSRF

* 요청 대행 공격

공격자는 권한이 없는 상태에서 권한이 있는 사용자에게 특정 명령어를 실행하도록 요청하여 공격자가 원하는 대로 서비스를 장악하는 공격

관리자의 패스워드를 1234 / 1234로 변경하는 예:

```
http://192.168.56.118/vulnerabilities/csrf/?password_new=1234&password_conf=1234&Change=Change#
```

* GET 방식의 메소드인 점 확인
* 피해자가 메일을 클릭하여 실행하는 것만으로도 계정의 비밀번호가 공격자 마음대로 바뀐다.

예시 HTML:

```
<p><img src=URL></p>
```

* 피해자가 이메일을 열람하면서 자동으로 HTML 코드가 실행되어 피해 발생
* width, height 값을 0으로 설정하면 이미지(대상 요소)도 사라짐

피해자 입장

* dvwa, 이메일 로그아웃 - 웹 브라우저 닫기
* 메일 확인, dvwa 로그인 -> 공격자가 정한 비밀번호로 변경됨

{% stepper %}
{% step %}
### 시연 단계: 공격자 측

1. 악성 요청(URL)을 준비하고 이메일 등으로 피해자에게 보낸다.
2. URL은 GET 파라미터로 비밀번호 변경 요청을 포함한다.

예:

```
http://192.168.56.118/vulnerabilities/csrf/?password_new=1234&password_conf=1234&Change=Change#
```
{% endstep %}

{% step %}
### 시연 단계: 피해자 측

1. 피해자가 이메일(또는 기타 매체)에서 악성 콘텐츠를 열람한다.
2. 열람만으로도 브라우저가 자동으로 해당 URL에 요청을 보내면 비밀번호가 변경된다.
{% endstep %}
{% endstepper %}

## 취약도 수준별 특징

{% hint style="info" %}
low&#x20;

* 보안 코드 없이 사용자의 입력을 무조건 신뢰하고 값을 비교하여 처리한다.
{% endhint %}

{% hint style="warning" %}
midium&#x20;

* 도메인 이름이 URL에 포함되어 있는지 대소문자 구분 없이 검사하지만 의미는 없다.
{% endhint %}

{% hint style="success" %}
hight&#x20;

* 사용자 토큰 요구
* mysql\_real\_escape\_string: 태그에 임의의 값이 들어가는 것을 사전에 검출
* CSRF 공격이 거의 불가능해짐
{% endhint %}
