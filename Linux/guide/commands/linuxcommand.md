# 리눅스 기본 필수 명령어

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-CMD-002-REF |
| 유형 | REF (명령 표) |
| 목적 | 전원 관리, 런레벨, 이동, 목록 출력, 이력, 와일드카드 등 기본 명령을 참조한다 |
| 확인 상태 | 미검증 (원본 페이지와 systemd, coreutils 문서 지식을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 전원 끄기와 재부팅

{% hint style="danger" %}
WARNING: 이 절의 명령은 실행 즉시 또는 지정한 시각에 시스템을 종료하거나 재부팅한다. 저장하지 않은 작업과 접속 중인 사용자의 세션이 끊긴다. 원격 서버에서는 종료 후 다시 접속할 수 없다. 실행 전에 대상 호스트가 맞는지 확인한다.
{% endhint %}

| 명령어 | 설명 |
|---|---|
| `halt` | 운영체제만 정지한다 |
| `halt -p` | 운영체제를 정지하고 전원도 끈다 |
| `shutdown -h now` | 지금 바로 종료한다 |
| `shutdown -h +<n>` | n분 뒤 종료하도록 예약한다 |
| `shutdown -P +<n>` | n분 뒤 전원까지 끄도록 예약한다 |
| `shutdown -c` | 예약한 종료를 취소한다 |
| `shutdown -r now` | 지금 바로 재부팅한다 |
| `shutdown -r +<n>` | n분 뒤 재부팅하도록 예약한다 |
| `shutdown -r <hh:mm>` | 지정한 시각에 재부팅하도록 예약한다 |
| `shutdown -k +<n>` | 실제로 종료하지 않고 접속 중인 사용자에게 종료 경고 메시지만 보낸다 |
| `reboot` | 재부팅한다 |

### 종료 명령 비교

| 명령어 | 설명 | 옵션 | 형식 | 예 |
|---|---|---|---|---|
| `shutdown` | 종료 또는 재부팅 (root 권한 필요) | `-r`: 재부팅<br>`-h`: 종료 | `shutdown <옵션> <시간>` | `shutdown -h +5`: 5분 뒤 종료<br>`shutdown -r 10:00`: 10시에 재부팅 |
| `init` | 런레벨(시스템 상태)을 바꾼다 | 없음 | `init <런레벨>` | `init 0`: 종료 상태로 전환 |
| `reboot` | 재부팅한다 | `-f`: 강제 | `reboot [옵션]` | `reboot -f` |
| `halt` | 종료한다 | `-f`: 강제 | `halt [옵션]` | `halt -f` |

{% hint style="info" %}
NOTE: 원본은 `init`을 "`shutdown`과 동일"이라고 적었다. `init`은 런레벨을 전환하는 명령이며, `init 0`과 `init 6`이 종료와 재부팅에 해당한다. 그에 맞게 정정했다. `-f`(강제)는 서비스를 정상 종료하지 않고 바로 실행하므로 데이터 손실 위험이 크다. 미검증이다.
{% endhint %}

## 2. 런레벨

`init <n>`의 n은 0~6이다. 원본은 2, 4를 쓰지 않는다고 적었으며 배포판에 따라 다르다.

| 런레벨 | 모드 | 설명 |
|---|---|---|
| 0 | 종료 | 전원을 끈다 |
| 1 | 복구 | 비밀번호를 잊었을 때 다시 설정하는 데 쓴다 |
| 3 | 텍스트 모드 | `multi-user.target`에 대응한다 |
| 5 | 그래픽 모드 | `graphical.target`에 대응한다. 최소 설치에서는 동작하지 않을 수 있다 |
| 6 | 재부팅 | 재부팅한다 |

{% hint style="danger" %}
WARNING: `init 0`, `init 6`은 즉시 종료·재부팅한다. `init 1`은 다른 사용자의 접속을 끊고 복구 모드로 들어간다. 운영 중인 서버에서는 실행하지 않는다.
{% endhint %}

### 현재 런레벨 확인

```bash
ls -al /etc/systemd/system/default.target
systemctl get-default
```

### 런레벨 변경

```bash
systemctl set-default multi-user.target
systemctl isolate multi-user.target
```

| 명령 | 효과 |
|---|---|
| `systemctl set-default <타깃>` | 다음 부팅부터 쓰는 기본 타깃을 바꾼다 |
| `systemctl isolate <타깃>` | 지금 바로 해당 타깃으로 전환한다 |

{% hint style="info" %}
NOTE: 원본에는 `ln -sf /usr/lib/systemd/system/multi-user.target` 명령이 있었다. 링크 이름이 빠져 있어 그대로는 동작하지 않는다. 완전한 형식은 `ln -sf /usr/lib/systemd/system/multi-user.target /etc/systemd/system/default.target`이며 `systemctl set-default`와 같은 결과다. 이 문서는 `systemctl set-default`만 남겼다. 런레벨 표는 [런레벨 정의표](../storage-boot/runlevel.md)를 함께 본다. 미검증이다.
{% endhint %}

## 3. 화면, 콘솔, 이동, 출력

| 명령어 | 설명 | 예 |
|---|---|---|
| `clear` | 터미널 화면을 지운다 | `clear` |
| `Ctrl + Alt + F1`~`F6` | 가상 콘솔로 전환한다 (최대 6개) | |
| `chvt <n>` | n번째 가상 콘솔로 이동한다 | `chvt 2` |
| `cd <디렉터리>` | 디렉터리로 이동한다 | `cd /etc` |
| `cd` | 현재 사용자의 홈 디렉터리로 이동한다 | |
| `ls [옵션]` | 디렉터리 내용을 출력한다. `-a`는 숨김 파일을 포함한다 | `ls -a` |
| `cat [옵션] <파일>` | 파일 내용을 출력한다 | `cat /etc/hostname` |
| `history [옵션]` | 명령어 사용 기록을 출력한다. `-c`는 메모리의 기록을 삭제한다 | `history` |

{% hint style="info" %}
NOTE: `.bash_history` 파일에는 셸이 종료될 때 메모리의 기록이 저장된다. 원본은 로그아웃 시점으로 적었다. 자세한 설명은 [기타 유용한 명령어](misccommands.md)의 `history` 항목을 본다. 미검증이다.
{% endhint %}

## 4. 쉘 와일드카드

| 기호 | 설명 | 예 |
|---|---|---|
| `*` | 0개 이상의 모든 문자 | `ls *.txt` |
| `?` | 정확히 1개 문자 | `ls file?.txt` |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [misccommands.md](misccommands.md) | LNX-CMD-004-REF | 기타 유용한 명령어 |
| [runlevel.md](../storage-boot/runlevel.md) | | 런레벨 정의표 (Runlevel) |

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | REF 형식으로 재작성. 종료 명령에 WARNING 추가, `init` 설명과 불완전한 `ln -sf` 명령을 정정하고 런레벨 단계 목록을 표로 합쳤다 |
