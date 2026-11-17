# 리눅스 기본 필수 명령어

### 전원 끄기

* `halt`: 리눅스만 끄기
* `halt -p`: 리눅스와 PC 모두 끄기
* `shutdown -h now`: 지금 당장 컴퓨터를 끄도록 하는 명령어
* `shutdown -P +n`: n분 뒤 시스템이 종료되도록 스케줄로 등록하는 명령어
* `shutdown -c`: 방금 스케줄로 등록한 종료 명령 취소
* `reboot`: 재부팅
* `shutdown -r now`: 재부팅
* `shutdown -r +n`: n분 뒤 재부팅 스케줄 등록
* `shutdown -r h:m`: h시 m분에 재부팅 스케줄 등록
* `shutdown -k +n`: 종료 메시지를 접속 중인 사용자들에게 전달

***

### 화면 청소

* `clear`

### 가상 콘솔

* `Ctrl + Alt + F1~F6`: 가상 콘솔을 최대 6개 만들 수 있다.
* `chvt n`: n번째 가상 콘솔로 이동

### Run-level

* `init n`: 0\~6까지 사용할 수 있지만 2, 4번은 사용하지 않는다.
  * `init 0`: power off (종료 모드)
  * `init 1`: Rescue (복구 모드) — 비밀번호를 잊었을 때 다시 설정할 수 있도록 중요
  * `init 3`: TextMode (텍스트 모드)
  * `init 5`: GUIMode (그래픽 모드) — 최소 버전에서는 동작하지 않을 수 있음
  * `init 6`: reboot (재부팅)

현재 런 레벨 확인:

```bash
ls -al /etc/systemd/system/default.target
systemctl get-default
```

런 레벨 변경:

```bash
ln -sf /usr/lib/systemd/system/multi-user.target
systemctl set-default multi-user.target
systemctl isolate multi-user.target
```

런레벨별 설명 (스텝퍼 형식):

{% hint style="info" %}
리눅스의 전통적인 런레벨(0\~6)을 사용한 개념 설명입니다. 배포판/시스템에 따라 일부 값(예: 2, 4)의 사용 여부가 다를 수 있습니다.
{% endhint %}

{% stepper %}
{% step %}
### 0

Power off (종료)
{% endstep %}

{% step %}
### 1

Rescue (복구, 비밀번호 재설정)
{% endstep %}

{% step %}
### 3

TextMode (텍스트)
{% endstep %}

{% step %}
### 5

GUIMode (그래픽)
{% endstep %}

{% step %}
### 6

reboot (재부팅)
{% endstep %}
{% endstepper %}

{% hint style="info" %}
`init 1` (Rescue 모드)은 시스템 복구나 비밀번호 재설정 등 중요한 작업에 사용되므로 주의해서 사용하세요.
{% endhint %}

### 디렉토리 이동

* `cd '디렉토리'`
* `cd` : 사용자 계정의 홈 디렉토리로 이동

### 디렉토리 정보 출력

* `ls '옵션'`
  * `-a`: 숨김 파일 포함 출력

### 파일 정보 출력

* `cat '옵션' '파일이름'`

### 명령어 사용 기록 확인

* `history '옵션'`
  * `-c`: 사용 기록 삭제(메모리)

참고: `.bash_history`는 로그아웃할 때 메모리에 저장된 히스토리 정보를 자동으로 저장합니다.

### 시스템 종료 및 재부팅 명령어 정리

| 명령어        | 설명                          | 옵션                                                     | 사용 방법                 | 예제                                                                                                                                |
| ---------- | --------------------------- | ------------------------------------------------------ | --------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `shutdown` | 시스템 종료 또는 재부팅 (root 권한만 가능) | <p><code>-r</code>: 재부팅<br><code>-h</code>: 시스템 종료</p> | `shutdown '옵션' '시간값'` | <p><code>shutdown -h now</code> : 즉시 종료<br><code>shutdown -h +5</code> : 5분 뒤 종료<br><code>shutdown -r 10:00</code> : 10시에 재부팅</p> |
| `init`     | `shutdown`과 동일              | (없음)                                                   | `init [[런레벨]]`        | `init 0` : 즉시 종료                                                                                                                  |
| `reboot`   | 시스템 재부팅                     | `-f`: 강제                                               | `reboot '옵션'`         | `reboot -f`                                                                                                                       |
| `halt`     | 시스템 종료                      | `-f`: 강제                                               | `halt '옵션'`           | `halt -f`                                                                                                                         |

### 쉘 와일드카드 (Wildcards)

| 기호  | 설명  |
| --- | --- |
| \*  | 모든 것 |
| ?   | 1글자 |
