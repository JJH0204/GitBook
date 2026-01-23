# Account Management

## /etc/passwd

: 계정 정보가 저장된 파일

```shell
root:x:0:0:root:/root:/bin/bash
# 계정이름:비밀번호:UserID:GroupID:사용자이름:HomeDir:지정된 shell
```

* UID, GID는 매우 중요하다
* 시스템에 따라 계정 생성 시 시작하는 값은 다르다. (500\~ 또는 1000\~)
* **UID, GID를 임의로 조작하여 0으로 변경하면 해당 user는 관리자 권한을 얻음으로 매우 주의해야 한다.**

***

## /etc/shadow

: [암호화](file:///6408728/security/Brute-force%20Attack.md)(Encrypted)된 계정 비밀번호가 저장된 파일

```shell
root:$6$dp4zP54GVKNmwh6C$Uo0nNEP1ogBK8hMc1QDxHh/dCGuqUHv6NxqXRNBzJMphTOPHx4kiDTpi8zk5iXMLSCSAlGyQFYFwAK8frQTFy.::0:99999:7:::
# 계정이름:Password:LastChanged:Min:Max:Warning:InActive:로그인 금지 기간:Reserve
```

* 총 9개의 필드로 구성
* Password: 해당 계정의 비밀번호가 암호화 되어 저장됨
* LastChanged: "1970년 1월 1일"부터 패스워드 수정 일 기록록
* Min/Max: 패스워드가 변경되기 전 최소 또는 최대 사용 가능한 기간(day)
* Warning: 패스워드 기간 만료 전 경고 메시지를 출력하는 기간(day)
* InActive: 접속 차단 기간 (day)
* 로그인 금지 기간: Month/day/year 형태로 값을 입력, 해당 기간 동안 접속 불가능
* Reserve: 예약된 필드

### 주요 특징

* **암호화**: 비밀번호는 해시화되어 저장돼 있어. 해시화 알고리즘은 MD5, SHA-256, SHA-512 등이 사용돼.
* **접근 권한**: 파일은 root와 shadow 그룹만 접근할 수 있어, 일반 사용자는 접근할 수 없지.
* **비밀번호 관리**: `passwd` 명령어로 비밀번호를 변경하고, `chage` 명령어로 비밀번호의 만료 정보를 관리해.

{% hint style="info" %}
salt

/etc/shadow 파일에 저장된 패스워드에 적용된 암호화([해싱](file:///6408728/cs_basics/Hashing.md)) 알고리즘 결과에 임의의 문자열을 추가해 같은 비밀번호를 사용하더라도 다른 암호화 결과가 나오도록 하는 기법
{% endhint %}

```shell
test:$6$3qbYuf1Yd.5HptnY$xAirZpuUJzS9ftdrWxjBJOK7xaEQp0xPCDNkPGPqhgvJxIVDQ8ZPioTjhf0jXJ13c3Q0nJp8oS5VHtzBHy5q51:19986:0:99999:7:::
test1:$6$IjZ5ZEIVe1qvJi9G$k2W4sr9OkioC.KXNQbpxG8.QCa.pDiylXkYrAqhfYlYa04yPPTH2PF3u4jaal50fw.0LyAVB65n6I1xodZ3uX/:19986:0:99999:7:::
# test와 test1은 같은 비밀번호를 사용하지만 암호화된 패스워드는 달라진 이유
```

* $6$: 사이 값을 통해 사용된 해싱 알고리즘을 알 수 있다.

***

## Permission

> \[!Note] 권한 관리는 시스템 보안에서 매우 중요한 사항이다. 시스템 해킹의 주요 목적은 관리자 권한을 빼앗아 시스템을 장악하는 것이 목적이기 때문이다. 그래서 이러한 권한을 어떻게 관리하고 운영 하는지 개념을 익히는 것이 필수이다.

(원문 링크: Permission.md)

***

## 계정 암호화 적용 여부 수정

```sh
echo "test:1234" | chpasswd -c NONE   # 암호화 적용 안함
echo "test:1234" | chpasswd -c SHA512 # Linux 기본 알고리즘
```

## /etc/login.defs

* 계정(암호화/권한)관리를 위한 설정 파일

```
117 UMASK           022
144 UID_MIN                  1000
204 ENCRYPT_METHOD SHA512
```

## 비밀번호 정책(복잡성) 설정

* 복잡성 설정 파일 설치 여부 확인

```sh
dnf list installed libpwquality
```

* 비밀번호 정책 파일

```sh
vi /etc/security/pwquality.conf
```

예시 파일 내용 (주석 처리된 형태):

```
6  # difok = 1      # 이전에 사용한 비밀번호와 유사성 점검하는 값(문자열 비교)
11 # minlen = 8     # 비밀번호 최소 길이
15 # dcredit = 0    # 숫자 사용 개수 (음수: 최소, 양수: 최대)
20 # ucredit = 0    # 대문자 사용 개수 (음수: 최소, 양수: 최대)
25 # lcredit = 0    # 소문자 사용 개수 (음수:최소, 양수:최대)
30 # ocredit = 0    # 특수문자 사용 개수 (음수:최소, 양수:최대)
38 # maxrepeat = 0  # 연속해서 나오는 문자 검사
47 # gecoscheck = 0 # (bool 값) /etc/passwd 5필드 값 검사여부
```

## 사용자 비밀번호 변경 스크립트

{% code title="change-passwords.sh" %}
```bash
#! /bin/bash

for user in $(awk -F: "$3 >= 1000 {print $1}" /etc/passwd); do
        chage -d O $user
done
```
{% endcode %}

* /etc/passwd 파일에 저장된 계정들 중 ID 값이 1000이상 들을 user 변수에 저장
* 순차적으로 반복하며 user의 비밀번호를 변경

## 계정 잠금 인계값

```sh
vi /etc/security/faillock.conf
```

예시 설정 (주석 처리된 형태):

```
32 # deny = 3         # 로그인 시도 횟수 (횟수 만큼 실패 시 계정 잠금)
38 # fail_interval = 900 # 인증 간격 (단위. 초)
45 # unlock_time = 600   # 계정 잠금 시간 (단위. 초)
```

```
tss:!!:19964::::::
# /etc/shadow 의 두번째 필드가 !로 시작하면 잠겨있는 계정
```

* 직접 잠금 해제 예시

```sh
awk -F: '{if ($2 ~ /^!\$/) print $1}' /etc/shadow

passwd -u sshd
Unlocking password for user sshd.
passwd: Warning: unlocked password would be empty.
passwd: Unsafe operation (use -f to force)
```

관련 awk 레퍼런스: https://recipes4dev.tistory.com/171

## 패스워드 만료일 설정

* 계정 패스워드 만료일 확인

```bash
chage -l 계정이름 | grep -i "^password expires"
```

* 계정 패스워드 변경일 갱신

```bash
chage -d날짜 계정이름
```

* 계정 패스워드 만료일 설정
