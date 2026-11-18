# 런레벨 정의표 (Runlevel)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-STB-005-DO |
| 유형 | D&O (개념·구조) + 대응표 |
| 목적 | 런레벨 0~6의 의미와 systemd target의 대응을 설명한다 |
| 확인 상태 | 미검증 (원본 표와 systemd 일반 지식을 정리한 것이며 직접 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

런레벨(runlevel)은 시스템이 어떤 상태로 동작할지 정하는 번호다. 전통적인 SysV init은 0~6의 번호를 쓰고, 현재 대부분의 배포판이 쓰는 systemd는 같은 개념을 target(`*.target`)이라는 이름으로 나타낸다. 이 문서는 두 체계의 대응을 정리한다.

## 2. 구성 요소

### 2.1 런레벨과 systemd target 대응표

| 런레벨 | 기능 (원본 표) | 대응 systemd target | 비고 |
|:-:|---|---|---|
| 0 | 지금 즉시 종료 | `poweroff.target` | 전원을 끈다 |
| 1 | 단일 사용자 복구 모드 | `rescue.target` | root만 쓰는 복구 모드다 |
| 2 | 다중 사용자 모드 | `multi-user.target` | 배포판에 따라 네트워크 파일 시스템 없는 다중 사용자 모드다 |
| 3 | 텍스트 모드 | `multi-user.target` | 네트워크가 있는 다중 사용자 텍스트 모드다 |
| 4 | 사용 안 함 | `multi-user.target` | 사용자 정의용이다 |
| 5 | X 윈도우(그래픽) 모드 | `graphical.target` | 그래픽 로그인을 쓴다 |
| 6 | 재부팅 | `reboot.target` | |

{% hint style="info" %}
NOTE: 원본 표는 0, 1, 3, 5, 6을 "재시작"이라고 적었다. 런레벨 0과 6은 종료와 재부팅이고, 1, 3, 5는 그 상태로 전환하는 것이다. 이 문서는 "기능" 열로 정리했다. systemd에서 런레벨 2~4가 모두 `multi-user.target`으로 연결되는 것은 일반 지식이며 미검증이다.
{% endhint %}

### 2.2 관련 명령

| 명령 | 동작 |
|---|---|
| `runlevel` | 이전과 현재 런레벨을 표시한다 |
| `systemctl get-default` | 부팅 시 기본 target을 표시한다 |
| `systemctl set-default <target>` | 부팅 시 기본 target을 바꾼다 |
| `systemctl isolate <target>` | 실행 중인 시스템을 지정한 target으로 즉시 전환한다 |
| `init <번호>` | 런레벨 번호로 전환한다 (systemd에서는 호환 명령) |

## 3. 동작 원리

1. 부트 로더가 커널을 올린다.
2. 커널이 init(systemd)을 실행한다.
3. systemd가 기본 target(`default.target`)에 필요한 서비스를 순서대로 시작한다.
4. 시스템이 해당 target(런레벨)의 상태가 된다.

`systemctl isolate`는 지정한 target에 속하지 않는 서비스를 중지한다. 기본 target을 바꾸는 `set-default`는 다음 부팅부터 적용된다.

{% hint style="danger" %}
WARNING: `systemctl isolate poweroff.target`과 `reboot.target`은 즉시 시스템을 종료하거나 재부팅한다. `rescue.target`은 원격 접속(SSH) 세션을 끊을 수 있다. `systemctl set-default`를 잘못 설정하면 다음 부팅에서 원하는 상태로 올라오지 않는다. 변경 전에 `systemctl get-default`로 현재 값을 기록하고, 콘솔 접근 수단(복구 콘솔 또는 가상 머신 콘솔)을 확보한 뒤 실행한다.
{% endhint %}

## 4. 약어와 용어

| 용어 | 뜻 |
|---|---|
| 런레벨(runlevel) | SysV init의 동작 상태 번호 0~6 |
| target | systemd의 동작 상태 단위. 런레벨에 대응한다 |
| 단일 사용자 모드 | 관리자만 쓰는 복구용 상태 |
| 다중 사용자 모드 | 여러 사용자와 네트워크 서비스를 쓰는 상태 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [리눅스 기본 필수 명령어](../commands/linuxcommand.md) | LNX-CMD-002-REF | 전원, 런레벨 명령 |
| [LILO 부트 로더](lilo.md) | LNX-STB-004-DO | 부팅 과정 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 서버에 런레벨 3(텍스트 모드)을 쓰는 이유를 내 말로 설명해 보자.
- [ ] 런레벨 1(복구 모드)이 필요한 상황을 경험하거나 상상해서 적어 보자.
- [ ] SysV 런레벨과 systemd target의 차이를 내 말로 정리해 보자.
