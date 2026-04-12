# Permission

{% hint style="info" %}
`ls -l`을 통해 파일/디렉토리의 사용자 권한을 확인할 수 있습니다. 아래는 그 출력에서 권한 필드의 의미와 이를 읽고 쓰고 수정하는 방법입니다.
{% endhint %}

파일 권한 필드(예: -rw-r--r--)는 순서대로 의미가 부여됩니다.

| 값   | 의미        | 비고                            |
| --- | --------- | ----------------------------- |
| -   | 타입        | -: 파일, d: 디렉토리, l: 링크         |
| rw- | 소유자 권한    | r: 읽기, w: 쓰기, x: 실행, -: 권한 없음 |
| r-- | 그룹 권한     | r: 읽기, w: 쓰기, x: 실행, -: 권한 없음 |
| r-- | 다른 사용자 권한 | r: 읽기, w: 쓰기, x: 실행, -: 권한 없음 |

예시(.hash\_history)의 권한을 분석하면:

*
  * : 타입은 파일이다.
* rw-: 사용자는 해당 파일을 읽고 쓸 수 있지만, 실행은 불가능하다.
* \---: 그룹에서는 해당 파일에 대한 모든 권한이 없다.
* \---: 다른 사용자 또한 해당 파일에 대한 모든 권한이 없다.

숫자로 표현하기

* r = 4
* w = 2
* x = 1

예: 777 = 모든 사용자가 모든 권한을 가짐

권한 수정 명령어

{% code title="chmod 사용 예" %}
```bash
chmod [권한레벨] [바꿀파일이름]
# 예) chmod 755 sample.txt
```
{% endcode %}

옵션으로 권한을 수정할 수도 있습니다:

{% code title="chmod 옵션 예" %}
```bash
# 예) 권한 제거
chmod ugo-r sample.txt

# 예) 권한 추가
chmod ugo+wx sample.txt

# u = user
# g = group
# o = other
```
{% endcode %}

소유자 변경

{% code title="chown 사용 예" %}
```bash
# 사용자 소유자 변경
chown [계정이름] [대상파일(디렉토리)]
# 예) chown jang sample.txt

# 그룹만 변경 (앞에 점)
chown .[그룹이름] [대상파일(디렉토리)]
# 예) chown .buseo4 jang1.txt

# 소유자와 그룹을 동시에 변경
chown 사용자.그룹 대상파일
# 예) chown jang.jang jang1.txt

# 디렉토리의 하위 항목까지 재귀적으로 변경
chown -R jang.jang dir
```
{% endcode %}

참고: 소유자 변경(chown)은 루트 사용자만 가능합니다.

### Umask

* 파일의 기본 퍼미션 값: 644
* 디렉토리의 기본 퍼미션 값: 755
* 기본 권한은 umask 값에 의해 결정됩니다.
  * 예: 파일(666) - umask(022) = 644
* umask 값을 임의로 바꾸면 보안에 취약해질 수 있으므로 주의해야 합니다.

{% hint style="warning" %}
umask를 임의로 바꾸는 것은 권한 설정에 큰 영향을 주므로 신중히 다루어야 합니다.
{% endhint %}

### 관리자 권한 관리

* 관련 블로그 포스트: https://velog.io/@lenyleny/Linux-sudosusu-%EC%B0%A8%EC%9D%B4-%EA%B7%B8%EB%A6%AC%EA%B3%A0-%EC%99%80-%EC%B0%A8%EC%9D%B4-rootadminuser-%EC%B0%A8%EC%9D%B4
* /etc/passwd의 UID, GID를 root와 같은 값으로 주었을 때 root와 같은 시스템 권한을 가질 수 있음
* 계정 권한은 Real(RUID, RGID)과 Effective(EUID, EGID)로 나뉘어 관리됨

{% hint style="info" %}
Real: 사용자 식별에 사용하는 아이디(또는 그룹)\
Effective: 사용자의 권한을 식별하는데 사용하는 아이디(또는 그룹)

* 최초 로그인 시 Real과 Effective은 동일합니다. (SetUID 비트가 설정된 파일을 실행하기 전까지)
* /etc/sudoers 설정 등으로 권한을 관리합니다: https://mans-daily.tistory.com/entry/%EB%A6%AC%EB%88%85%EC%8A%A4UbuntuCentOS-etcsudoers-%ED%8C%8C%EC%9D%BC%EC%9D%84-%EC%88%98%EC%A0%95%ED%95%98%EC%97%AC-sudo-%EA%B6%8C%ED%95%9C-%EB%B0%8F-root-%EA%B6%8C%ED%95%9C-%EB%B6%80%EC%97%AC%ED%95%98%EA%B8%B0
{% endhint %}

### 특수 권한

관련 자료:

* https://blog.naver.com/doctor-kick/222158625480
* https://eunguru.tistory.com/115

SetUID 비트 예시:

{% code title="SetUID 예시 (ls -l 출력)" %}
```
-rwsr-xr-x. 1 root root 32656 May 15  2022 /usr/bin/passwd
```
{% endcode %}

* s: setUID 비트가 설정된 파일이라는 뜻
* 이 파일을 실행할 때 지정된 사용자의 권한(대부분 root)을 잠시 빌려 실행함
* 사용자 권한의 s = 4000, 그룹 권한의 s = 2000

참고 링크: ../security/Backdoor%20Attack.md

특정 사용자 또는 특정 권한을 가진 파일 찾기 예시

{% code title="find 예시" %}
```bash
find / -user root -perm /4000
```
{% endcode %}
