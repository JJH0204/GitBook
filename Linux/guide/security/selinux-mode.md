# SELinux 모드 변경

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-SEC-004-MP |
| 목적 | SELinux 모드를 임시로 또는 영구로 바꾸고 확인한다 |
| 적용 대상 | RHEL 계열 9, root 또는 sudo 권한 |
| 소요 시간 | 약 10분 (영구 변경은 재부팅 시간 추가) |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [selinux.md](selinux.md) | LNX-SEC-003-DO | SELinux 보안 모듈 (모드와 설정 값) |
| [selinux-context.md](selinux-context.md) | LNX-SEC-005-MP | SELinux 파일 컨텍스트 변경 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 대상 서버 | RHEL 계열 9, SELinux 설치됨 | |
| 2 | 콘솔 접근 | 가상 머신 화면 또는 물리 콘솔 | 재부팅 후 확인에 사용 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: Permissive 또는 Disabled로 바꾸면 SELinux의 접근 차단이 멈춰 보안이 약해진다. 문제 원인을 찾는 동안만 Permissive를 쓰고, 끝나면 Enforcing으로 되돌린다. 운영 서버에서는 Disabled를 쓰지 않는다. 필요한 예외는 LNX-SEC-005-MP처럼 레이블이나 정책으로 허용한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 설정 파일 변경은 재부팅해야 적용된다. 재부팅하면 서비스가 중단된다. 점검 시간을 확보한 뒤 수행한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 현재 모드를 확인한다: `getenforce` | `Enforcing`, `Permissive`, `Disabled` 중 하나가 출력된다 |
| 2 | 설정 파일을 백업한다: `cp /etc/sysconfig/selinux /etc/sysconfig/selinux.bak` | `ls /etc/sysconfig/selinux.bak`가 파일을 보여 준다 |

## 5. 절차

### A. 임시 변경 (재부팅하면 원래대로 돌아간다)

1. (5-A-01) 상태를 확인한다: `sestatus` → 결과: `Current mode`와 `Mode from config file`이 출력된다.
2. (5-A-02) Permissive로 바꾼다: `setenforce 0` → 결과: 오류 없이 끝난다.
3. (5-A-03) 모드를 확인한다: `getenforce` → 결과: `Permissive`가 출력된다.
4. (5-A-04) Enforcing으로 되돌린다: `setenforce 1` → 결과: 오류 없이 끝난다.

사용법은 `setenforce [ Enforcing | Permissive | 1 | 0 ]`이다. `setenforce`는 설정 파일을 바꾸지 않는다. Disabled로는 `setenforce`로 바꿀 수 없다.

### B. 설정 파일로 영구 변경

1. (5-B-01) 설정 파일을 연다: `vi /etc/sysconfig/selinux`
2. (5-B-02) `SELINUX=` 줄을 원하는 값(`enforcing`, `permissive`, `disabled`)으로 바꾼다 → 결과: 해당 줄이 `SELINUX=<모드>`가 된다.
3. (5-B-03) 저장하고 재부팅한다: `reboot`
4. (5-B-04) 재부팅 후 모드를 확인한다: `getenforce` → 결과: 5-B-02에서 지정한 모드가 출력된다.

{% hint style="warning" %}
CAUTION: `disabled`에서 `enforcing`으로 되돌릴 때는 파일 레이블이 없어 부팅이 실패할 수 있다. 재부팅 전에 `touch /.autorelabel`을 입력해 부팅 시 전체 파일의 레이블을 다시 붙이게 한다. 재레이블링은 오래 걸린다. 미검증이다.
{% endhint %}

### C. 부트 인자로 SELinux 끄기·켜기

{% hint style="danger" %}
WARNING: 부트 인자 `selinux=0`은 SELinux를 완전히 끈다. 보안이 크게 약해진다. 재부팅해야 적용된다.
{% endhint %}

1. (5-C-01) 끈다: `grubby --update-kernel ALL --args selinux=0`
2. (5-C-02) 다시 켠다: `grubby --update-kernel ALL --remove-args selinux`
3. (5-C-03) 재부팅 후 모드를 확인한다: `getenforce` → 결과: 5-C-01 후에는 `Disabled`, 5-C-02 후에는 `Enforcing` 또는 설정 파일 값이 출력된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `getenforce` | 의도한 모드다 | 지정한 모드와 같다 |
| 2 | `sestatus` | `Current mode`와 `Mode from config file`이 같다 | 두 값이 일치한다 |
| 3 | 서비스 접속 시험 | 서비스가 정상이다 | 거부 로그(`grep denied /var/log/audit/audit.log`)가 새로 쌓이지 않는다 |

## 7. 복구

1. (7-01) 임시 변경이면 `setenforce 1`을 입력한다.
2. (7-02) 설정 파일 변경이면 백업을 되돌린다: `cp /etc/sysconfig/selinux.bak /etc/sysconfig/selinux`
3. (7-03) 재부팅한다: `reboot`
4. (7-04) 부트 인자를 바꿨다면 5-C-02를 수행한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `selinux.md`의 모드 변경 부분을 분리해 MP로 재작성. 보안 약화 WARNING, 재부팅 CAUTION, 복구를 추가했다. 재레이블링 안내(`/.autorelabel`)는 원본에 없던 내용이다 |
