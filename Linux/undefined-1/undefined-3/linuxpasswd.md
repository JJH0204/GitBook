# linuxpasswd

## /etc/passwd

: 계정 정보가 저장된 파일

{% code title="/etc/passwd" %}
```shell
root:x:0:0:root:/root:/bin/bash

# 계정이름:비밀번호:UserID:GroupID:사용자이름:HomeDir:지정된 shell
```
{% endcode %}

* UID, GID는 매우 중요하다.
* 시스템에 따라 계정 생성 시 시작하는 값은 다르다. (500\~ 또는 1000\~)

{% hint style="warning" %}
UID, GID를 임의로 조작하여 0으로 변경하면 해당 user는 관리자 권한을 얻음으로 매우 주의해야 합니다.
{% endhint %}

***

## /etc/shadow

: [암호화](file:///6408728/security/Brute-force%20Attack.md)(Encrypted)된 계정 비밀번호가 저장된 파일

{% code title="/etc/shadow" %}
```shell
root:$6$dp4zP54GVKNmwh6C$Uo0nNEP1ogBK8hMc1QDxHh/dCGuqUHv6NxqXRNBzJMphTOPHx4kiDTpi8zk5iXMLSCSAlGyQFYFwAK8frQTFy.::0:99999:7:::

# 계정이름:Password:LastChanged:Min:Max:Warning:InActive:로그인 금지 기간:Reserve
```
{% endcode %}

* 총 9개의 필드로 구성
* Password: 해당 계정의 비밀번호가 암호화 되어 저장됨
* LastChanged: "1970년 1월 1일"부터 패스워드 수정 횟수를 기록하는 필드
* Min/Max: 패스워드가 변경되기 전 최소 또는 최대 사용 가능한 기간(day)
* Warning: 패스워드 기간 만료 전 경고 메시지를 출력하는 기간(day)
* InActive: 접속 차단 기간 (day)
* 로그인 금지 기간: Month/day/year 형태로 값을 입력, 해당 기간 동안 접속 불가능
* Reserve: 예약된 필드

***

## salt

{% hint style="info" %}
/etc/shadow 파일에 저장된 패스워드에 적용된 암호화([해싱](file:///6408728/cs_basics/Hashing.md)) 알고리즘 결과에 임의의 문자열을 추가해 같은 비밀번호를 사용하더라도 다른 암호화 결과가 나오도록 하는 기법
{% endhint %}

{% code title="예시 (/etc/shadow 일부)" %}
```shell
test:$6$3qbYuf1Yd.5HptnY$xAirZpuUJzS9ftdrWxjBJOK7xaEQp0xPCDNkPGPqhgvJxIVDQ8ZPioTjhf0jXJ13c3Q0nJp8oS5VHtzBHy5q51:19986:0:99999:7:::
test1:$6$IjZ5ZEIVe1qvJi9G$k2W4sr9OkioC.KXNQbpxG8.QCa.pDiylXkYrAqhfYlYa04yPPTH2PF3u4jaal50fw.0LyAVB65n6I1xodZ3uX/:19986:0:99999:7:::

# test와 test1은 같은 비밀번호를 사용하지만 암호화된 패스워드는 달라진 이유
```
{% endcode %}

* $6$: 사이 값을 통해 사용된 해싱 알고리즘을 알 수 있다.

***

## Permission

> \[!Note] 권한 관리는 시스템 보안에서 매우 중요한 사항이다. 시스템 해킹의 주요 목적은 관리자 권한을 빼앗아 시스템을 장악하는 것이 목적이기 때문이다. 그래서 이러한 권한을 어떻게 관리하고 운영 하는지 개념을 익히는 것이 필수이다.

참고: Permission 관련 자세한 내용은 Permission.md를 참조하세요.
