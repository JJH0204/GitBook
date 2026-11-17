# SELinux 보안 모듈

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-SEC-003-DO |
| 유형 | D&O (개념·원리) |
| 목적 | SELinux의 모드, 컨텍스트(레이블), 로그, 주요 파일을 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 직접 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 모드를 바꾸는 절차는 LNX-SEC-004-MP, 파일 레이블을 바꾸는 절차는 LNX-SEC-005-MP를 따른다.
{% endhint %}

## 1. 목적

SELinux(Security-Enhanced Linux)는 커널에서 동작하는 리눅스용 보안 아키텍처다. 일반 권한(소유자, 그룹, 기타)과 별개로 프로세스와 파일에 레이블을 붙이고, 정책이 허용한 접근만 통과시킨다. root 권한을 가진 프로세스도 정책을 벗어난 접근은 막힌다.

## 2. 구성 요소

| 구성 요소 | 위치·명령 | 역할 |
|---|---|---|
| 상태 조회 | `sestatus` | SELinux 상태, 모드, 정책 이름을 출력한다 |
| 현재 모드 조회 | `getenforce` | 실행 중인 모드를 출력한다 |
| 설정 파일 | `/etc/sysconfig/selinux` | 부팅 시 적용할 모드(`SELINUX=`)와 정책 종류(`SELINUXTYPE=`)를 정한다 |
| 정책 파일 | `/etc/selinux/targeted/policy/policy.33` | 컴파일된 바이너리 정책이다. 텍스트로 읽을 수 없다 |
| 감사 로그 | `/var/log/audit/audit.log` | SELinux가 기록한 접근 거부와 시스템 호출 기록이다 |
| 컨텍스트 조회 | `ls -Z` | 파일의 레이블을 출력한다 |
| 정책 관리 도구 | `semanage` | 레이블 규칙, 로그인 매핑을 관리한다 |

### 모드

| 모드 | 활성 | 기록 | 적용(차단) |
|---|---|---|---|
| Enforcing | 예 | 예 | 예 |
| Permissive | 예 | 예 | 아니오 |
| Disabled | 아니오 | 아니오 | 아니오 |

### `sestatus` 출력 예

```sh
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing   # 적용 중인 모드
Mode from config file:          enforcing   # 설정 파일의 모드
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33
```

### 컨텍스트(레이블) 구성

`ls -Zl /etc/selinux/targeted/policy/`의 출력 예는 다음과 같다.

```sh
-rw-r--r--. 1 root root unconfined_u:object_r:semanage_store_t:s0 3462772 Aug 30 09:01 policy.33
```

| 필드 | 예 | 뜻 |
|---|---|---|
| 사용자(User) | `unconfined_u` | SELinux 사용자. `policy.33`에 정의되며 셸에서 만들 수 없다 |
| 역할(Role) | `object_r` | 사용자가 수행할 수 있는 역할 |
| 유형(Type) | `semanage_store_t` | 객체 유형. 정책은 유형을 기준으로 접근을 허용한다(예: `httpd_sys_content_t`는 웹 서버가 읽을 수 있는 내용) |
| 보안 레벨 | `s0` | 기본값은 `s0`다 |

### 설정 파일의 값

| 항목 | 값 | 뜻 |
|---|---|---|
| `SELINUX=` | `enforcing` | 정책을 적용한다 |
| | `permissive` | 경고만 출력한다 |
| | `disabled` | 정책을 로드하지 않는다 |
| `SELINUXTYPE=` | `targeted` | 지정한 프로세스만 보호한다(기본) |
| | `minimum` | targeted 정책에서 일부 프로세스만 보호한다 |
| | `mls` | 다중 보안 레벨(Multi Level Security) 보호 |

RHEL 8까지는 `SELINUX=disabled`가 SELinux를 완전히 끄지만, 이후 버전은 정책이 없는 상태로 실행된다. 완전히 끄려면 커널 인자 `selinux=0`을 쓴다.

## 3. 동작 원리

1. 프로세스가 파일에 접근을 요청한다.
2. 커널이 일반 권한(소유자, 그룹, 기타)을 먼저 검사한다.
3. 통과하면 SELinux가 프로세스의 유형과 파일의 유형을 정책에 대조한다.
4. 정책이 허용하면 접근한다. 허용하지 않으면 Enforcing 모드는 차단하고, Permissive 모드는 허용하되 `/var/log/audit/audit.log`에 기록한다.

감사 로그 예(요약)는 다음과 같다. `subj=`가 프로세스 컨텍스트다.

```sh
type=SYSCALL msg=audit(<타임스탬프>:148): arch=c000003e syscall=46 success=yes ... comm="firewalld" exe="/usr/bin/python3.9" subj=system_u:system_r:firewalld_t:s0
```

## 4. 약어·용어

| 용어 | 풀이 |
|---|---|
| SELinux | Security-Enhanced Linux |
| MLS | Multi Level Security. 다중 보안 레벨 |
| 컨텍스트(Context) | 파일과 프로세스에 붙는 `사용자:역할:유형:레벨` 레이블 |
| `semanage.conf` | `/etc/selinux/semanage.conf`. `semanage`가 정책 저장소와 통신하는 방식을 정하는 설정 파일 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [selinux-mode.md](selinux-mode.md) | LNX-SEC-004-MP | SELinux 모드 변경 |
| [selinux-context.md](selinux-context.md) | LNX-SEC-005-MP | SELinux 파일 컨텍스트 변경 |
| [SELinux (velog)](https://velog.io/@ujeongoh/SELinux-Security-Enhanced-Linux) | | 외부 자료 |
| [Red Hat: SELinux 모드 변경](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/using_selinux/changing-selinux-states-and-modes_using-selinux) | | 공식 문서 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] Enforcing과 Permissive의 차이를 로그와 차단 관점에서 설명해 보자.
- [ ] 파일 권한이 `777`인데도 SELinux 때문에 접근이 거부되는 상황을 설명해 보자.
- [ ] 컨텍스트의 네 필드 중 `targeted` 정책에서 가장 중요한 것은 무엇이고, 그 이유는 무엇일까?

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본을 D&O로 재작성하고 모드 변경과 레이블 변경 절차를 LNX-SEC-004-MP, LNX-SEC-005-MP로 분리했다. 라이선스 전문이 대부분이던 `semanage.conf` 전체 인용을 삭제했다 |
