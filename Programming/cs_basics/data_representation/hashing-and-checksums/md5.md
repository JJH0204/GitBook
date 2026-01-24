# MD5

MD5는 메시지 다이제스트 알고리즘 5(Message Digest Algorithm 5)의 줄임말로, 1991년에 로널드 리베스트가 설계했어. 이 알고리즘은 입력 데이터를 고정된 128비트 해시 값으로 변환해줘. 해시 값은 흔히 32자리의 16진수로 표현되는데, 이는 데이터의 "디지털 지문" 같은 역할을 해 ([Wikipedia](https://en.wikipedia.org/wiki/MD5)) ([DebugPointer](https://debugpointer.com/security/md5-hash-overview)).

#### MD5 알고리즘의 동작 원리

{% stepper %}
{% step %}
### 패딩

입력 데이터에 1비트와 여러 개의 0비트를 추가해서 길이를 512비트의 배수가 되게 해.
{% endstep %}

{% step %}
### 길이 추가

원래 데이터의 길이를 64비트로 표현해서 마지막에 붙여.
{% endstep %}

{% step %}
### 초기화

4개의 32비트 변수를 특정 값으로 초기화해.
{% endstep %}

{% step %}
### 블록 처리

각 512비트 블록을 4번의 라운드로 나누어 처리해. 각 라운드마다 16개의 연산이 이루어지지.
{% endstep %}

{% step %}
### 출력

모든 블록 처리가 끝나면 4개의 변수 값이 최종 128비트 해시를 형성해 ([DebugPointer](https://debugpointer.com/security/md5-hash-overview)) ([Simplilearn.com](https://www.simplilearn.com/tutorials/cyber-security-tutorial/md5-algorithm)).
{% endstep %}
{% endstepper %}

#### MD5의 사용 사례

MD5는 데이터 무결성 검사, 패스워드 저장, 디지털 서명 검증, 파일 중복 제거 등 다양한 분야에서 사용돼. 예를 들어, 파일이 전송 중에 변조되지 않았는지 확인할 때 MD5 해시 값을 비교해서 검증할 수 있어 ([DebugPointer](https://debugpointer.com/security/md5-hash-overview)) ([Simplilearn.com](https://www.simplilearn.com/tutorials/cyber-security-tutorial/md5-algorithm)).

{% hint style="warning" %}
#### MD5의 취약점

MD5는 충돌 공격(다른 입력 데이터가 같은 해시 값을 생성하는 경우)에 취약해. 1996년 이후로 MD5의 여러 보안 취약점이 발견되었고, 현재는 중요한 보안 목적으로는 사용되지 않아. 특히 SSL 인증서나 디지털 서명 같은 곳에서는 사용하면 안 돼. MD5의 충돌 문제로 인해 SHA-256 같은 더 안전한 해시 알고리즘이 권장돼 ([Wikipedia](https://en.wikipedia.org/wiki/MD5)) ([Simplilearn.com](https://www.simplilearn.com/tutorials/cyber-security-tutorial/md5-algorithm)).
{% endhint %}

더 자세한 정보를 원하면 아래 링크를 참고해:

* [Wikipedia](https://en.wikipedia.org/wiki/MD5)
* [DebugPointer](https://debugpointer.com/)
* [Simplilearn](https://www.simplilearn.com/)
