# 커맨드 인젝션 분석 다이어그램

## Code Block

`http://192.168.56.147/?id=%22%3E%3C/a%3E%3Cscript%3Ealert(%22cmd%22)%3C/script%3E%3Ca%20href=%22`와 같은 URL 인젝션은 **XSS(크로스 사이트 스크립팅)** 공격을 위해 설계된 페이로드입니다. 여기서 `<script>alert("cmd")</script>`는 브라우저에서 실행되어 **팝업 경고창**을 띄우는 자바스크립트 코드입니다. 그러나 이 방식은 클라이언트 측에서 실행되므로 서버의 커맨드 라인에 접근할 수 없습니다.

#### 클라이언트 측 XSS와 서버 측 Command Injection의 차이점

{% stepper %}
{% step %}
### XSS (크로스 사이트 스크립팅)

* 브라우저에서 실행되는 스크립트를 통해 사용자의 세션을 탈취하거나, 다른 브라우저 리소스에 접근하는 클라이언트 측 공격입니다.
* 서버 시스템 명령어를 실행할 수 없고, 주로 사용자 정보 탈취, 악성 스크립트 삽입, 페이지 변조에 사용됩니다.
{% endstep %}

{% step %}
### Command Injection (커맨드 인젝션)

* 서버에서 사용자의 입력을 직접 **시스템 명령어**로 실행할 수 있을 때 발생하는 서버 측 취약점입니다.
* 서버의 입력값 검증이 충분하지 않아 발생하며, 사용자가 전달한 입력이 서버의 셸 명령어로 실행됩니다.
* 이를 위해서는 서버 측 코드가 PHP의 `system()`이나 `exec()` 함수 등으로 **입력을 시스템 명령어로 실행**하도록 설정되어 있어야 합니다.
{% endstep %}
{% endstepper %}

#### Command Injection을 위한 서버 측 취약점이 필요

위 URL처럼 XSS 방식으로는 Command Injection을 할 수 없습니다. 서버에서 사용자의 입력을 시스템 명령어로 실행하는 취약점이 없다면, 클라이언트 측 XSS 페이로드를 통해 Command Injection을 수행할 수는 없습니다.

#### Command Injection을 테스트하려면

Command Injection을 수행하려면 서버가 `?id=<input>`에 전달된 값을 **명령어로 실행**하도록 설정된 경우를 찾아야 합니다. 예를 들어, 서버에서 PHP 코드가 다음과 같이 작성된 경우가 있을 수 있습니다.

{% code title="vulnerable.php" %}
```php
<?php
if (isset($_GET['id'])) {
    $id = $_GET['id'];
    system("ping " . $id);  // 사용자가 전달한 id가 명령어에 포함되어 실행됨
}
?>
```
{% endcode %}

이와 같은 경우에는, 다음과 같이 `id` 매개변수에 명령어를 추가하여 Command Injection을 시도할 수 있습니다.

```
http://192.168.56.147/?id=8.8.8.8; whoami
```

위 요청은 `ping 8.8.8.8; whoami` 명령어를 실행하게 되어, `ping` 명령어 뒤에 `whoami` 명령어가 추가로 실행될 수 있습니다. 그러나 이는 서버 측 코드가 위와 같은 방식으로 작성되어 있을 때만 가능합니다.

#### 결론

지금 시도한 페이로드는 XSS 공격을 위한 것이며, 서버 측 명령어 실행을 위한 취약점이 있는지와는 별개의 문제입니다. Command Injection을 테스트하려면, 서버가 입력값을 시스템 명령어로 실행하는 경우를 찾아야 합니다.

***

id 값에 임의의 값을 넣으니 data\_dir/{넣은 값}.txt 파일을 찾아 출력한다.

http://192.168.56.147/?id=1%20&&%20ls%20-al%20&&%2025

1 && sl -al && 25 > cat 1 && ls -al && 25.txt 가 될 것을 예상하고 명령어 입력

1 이후에 입력되는 값들이 무시되었다. 원리를 분석해보자

더보기 버튼에 id 변수에 저장할 다음 값이 저장되어 있다.

`?id=">alert("cmd")<a href="`

를 넣으면 동작할까?

alert("cmd")더보기

의도

의도한 결과가 출력 되는 것을 확인했다. 이 방법을 이용해 원하는 스크립트를 실행 시키면 될 것 같다.

XSS 와 Command Injection의 차이를 제대로 이해하지 못하고 있었다.

http://192.168.56.147/?id=;pwd;%2025

command 가 먹힌다.

cat /etc/passwd

who

whoami

uname -a

ifconfig

/etc/shadow 파일에는 접근 할 수 없었다.

### 참고 링크

9pYa0aIX: Excalidraw/comminjection.md#Code Block
