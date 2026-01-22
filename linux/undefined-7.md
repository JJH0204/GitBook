# 사용자 생성 명령어

아래는 사용자 계정 관련 주요 명령어들의 설명, 옵션, 사용 방법 및 예제입니다.

***

## useradd

설명\
사용자 추가(계정 생성). adduser와 동일한 목적.

* 새 계정의 홈 디렉토리: /home/계정명
* 계정 정보는 /etc/passwd, /etc/shadow, /etc/group 등에 저장됨

옵션

* -s: 로그인 시 사용할 기본 쉘 지정
* -d: 사용자의 홈 디렉토리 지정
* -e: 사용자의 계정 만기일 지정
* -f: 사용자의 계정 유효일(비활성화까지의 여유 일수) 지정
* -c: comment(설명)
* -G: 사용자의 2차 그룹(GID) 지정
* -u: UID 지정
* -g: 기본 그룹 지정

사용 방법

{% code title="사용 예" %}
```bash
useradd '옵션' '사용자명'
```
{% endcode %}

예제

{% code title="예제" %}
```bash
useradd admin
```
{% endcode %}

***

## passwd

설명\
계정의 패스워드를 생성하거나 변경하는 명령어. 변경된 패스워드는 /etc/shadow 파일에 기록됨.

옵션

* -S: 계정 상태 표시
  * PS: 정상
  * NP: 패스워드 없음
  * LK: lock 상태(또는 NP 상태)
* -d: 계정 패스워드 삭제
* -l: 계정을 lock 상태로 변경
* -u: 계정의 lock 상태 해제

사용 방법

{% code title="사용 예" %}
```bash
passwd '옵션' '사용자명'
```
{% endcode %}

예제

{% code title="예제" %}
```bash
passwd -S admin
```
{% endcode %}

***

## su

설명\
현재 사용자 계정을 로그아웃하지 않고 다른 사용자 계정으로 전환하여 해당 사용자의 권한을 획득하는 명령어.\
switch user 또는 substitute user의 줄임말.

옵션\
(표에 옵션이 명시되지 않음 — 일반적으로 - 또는 -- 옵션을 사용 가능: 예: `-` 또는 `-l`으로 로그인 셸 환경 로드 등)

사용 방법

{% code title="사용 예" %}
```bash
su '사용자명'
```
{% endcode %}

예제

{% code title="예제" %}
```bash
su admin
```
{% endcode %}
