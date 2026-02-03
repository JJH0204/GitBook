# linux\_basic\_commands

## 전원 끄기 및 재부팅

* `halt`: 리눅스만 끄기
* `halt -p`: 리눅스와 PC 모두 끄기
* `shutdown -h now`: 지금 당장 컴퓨터를 끄도록 하는 명령어
* `shutdown -P +n`: n분 뒤 시스템 종료 스케줄 등록
* `shutdown -c`: 종료 스케줄 취소
* `reboot`: 재부팅
* `shutdown -r now`: 즉시 재부팅
* `shutdown -r +n`: n분 뒤 재부팅 스케줄 등록
* `shutdown -r h:m`: h시 m분에 재부팅 스케줄 등록
* `shutdown -k +n`: 종료 메시지를 접속 중인 사용자에게 전달

## 화면 청소

* `clear`: 화면을 깨끗하게 초기화

## 가상 콘솔

* `ctrl + alt + f1~f6`: 최대 6개 가상 콘솔 생성
* `chvt n`: n번째 가상 콘솔로 이동

## Run-level

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

## 디렉토리 이동

* `cd '디렉토리'`: 디렉토리 이동
* `cd`: 홈 디렉토리로 이동

## 디렉토리 정보 출력

* `ls '옵션'`: 디렉토리 내 파일/폴더 목록 출력
  * `-a`: 숨김 파일 포함 출력
