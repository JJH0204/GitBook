# CentOS Basic Command

### 전원 끄기

* `halt`: 리눅스만 끄기
* `halt -p`: 리눅스와 PC 모두 끄기
* `shutdown -h now`: 지금 당장 컴퓨터를 끄도록 하는 명령어
* `shutdown -P +n`: n 분 뒤 시스템이 종료되도록 스케줄 등록
* `shutdown -c`: 방금 스케줄로 등록한 종료 명령 취소
* `reboot`: 재부팅
* `shutdown -r now`: 즉시 재부팅
* `shutdown -r +n`: n분 뒤 재부팅 스케줄 등록
* `shutdown -r h:m`: h시 m분에 재부팅 스케줄 등록
* `shutdown -k +n`: 종료 메시지를 접속 중인 사용자들에게 전달

***

### 화면 청소

```
clear
```

### 가상 콘솔

* 키 조합: `Ctrl + Alt + F1` \~ `Ctrl + Alt + F6` — 가상 콘솔을 최대 6개 사용할 수 있음
* 특정 가상 콘솔로 이동:

```
chvt n
```

### Run-level (런 레벨)

```
init n
```

* 사용 가능한 값: 0\~6 (일반적으로 2, 4는 사용하지 않음)

{% stepper %}
{% step %}
### init 0

power off (종료 모드)
{% endstep %}

{% step %}
### init 1

Rescue (복구 모드)\
주의: 비밀번호를 잊었을 때 재설정할 수 있도록 사용
{% endstep %}

{% step %}
### init 3

TextMode (텍스트 모드)
{% endstep %}

{% step %}
### init 5

GUIMode (그래픽 모드)\
※ 최소 버전에서는 동작하지 않을 수 있음
{% endstep %}

{% step %}
### init 6

reboot (재부팅)
{% endstep %}
{% endstepper %}

현재 런레벨 확인:

```
ls -al /etc/systemd/system/default.target
systemctl get-default
```

런레벨 변경:

```
ln -sf /usr/lib/systemd/system/multi-user.target
systemctl set-default multi-user.target
systemctl isolate multi-user.target
```

{% hint style="info" %}
런레벨 변경은 시스템 동작 모드에 직접 영향을 줍니다. 특히 GUI/텍스트 모드 전환이나 기본 타겟 변경 시 주의하세요.
{% endhint %}

### 디렉토리 이동

```
cd '디렉토리'
```

* `cd` 만 입력하면 사용자 계정의 홈 디렉토리로 이동

### 디렉토리 정보 출력

```
ls '옵션'
```

* `-a`: 숨김 파일 포함 출력

### 파일 정보 출력

```
cat '옵션' '파일이름'
```

### 명령어 사용 기록 확인

```
history '옵션'
```

* `-c`: 사용 기록 삭제(메모리)
* 참고: `.bash_history`는 로그아웃할 때 메모리에 저장된 히스토리 정보를 자동으로 저장

{% hint style="warning" %}
`history -c`로 메모리에서만 지우며, 이미 `.bash_history`에 저장된 기록은 별도로 삭제해야 합니다.
{% endhint %}

## 리눅스 자동 업데이트 끄기

```
gsettings set org.gnome.software download-updates false
systemctl disable dnf-makecache.service
systemctl disable dnf-makecache.timer
```

## IP 변경

#### 설정 파일 경로

```
/etc/NetworkManager/system-connections/enp0s3.nmconnection
```

#### 랜카드 끄기

```
nmcli connection down enp0s3
```

#### 랜카드 켜기

```
nmcli connection up enp0s3
```

## 절대 경로와 상대 경로

* 절대 경로: 디렉토리(폴더) 경로를 처음부터 끝까지 모두 작성

```
cd /etc/passwd
```

* 상대 경로: 현재 디렉토리 기준으로 목표까지의 경로 표현

```
cd ../passwd
```

## 텍스트 편집기

* vi, nano, gedit
