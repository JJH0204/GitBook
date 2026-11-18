# 사용자 계정 관리 설정 파일

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-ACC-001-REF |
| 유형 | REF (설정 파일 필드 표) |
| 목적 | 계정과 비밀번호 정책을 정하는 설정 파일의 필드와 키를 참조한다 |
| 적용 대상 | RHEL 계열 Linux (Rocky, AlmaLinux, CentOS Stream 포함). 읽기는 일반 사용자 가능, 편집은 root 권한 필요 |
| 확인 상태 | 미검증 (원본 페이지와 man 문서 지식을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 표만 담는다. 비밀번호 암호화 원리는 LNX-ACC-005-DO를, 설정을 바꾸는 절차는 LNX-ACC-011-MP, LNX-ACC-012-MP, LNX-ACC-013-MP를 따른다.
{% endhint %}

{% hint style="danger" %}
WARNING: `/etc/passwd`와 `/etc/shadow`를 `vi`로 직접 편집하지 않는다. 동시 편집으로 파일이 깨지면 로그인이 불가능해질 수 있다. 직접 고쳐야 하면 `vipw`(passwd)와 `vipw -s`(shadow)를 쓴다.
{% endhint %}

## 1. /etc/passwd

계정 정보를 저장한다. 한 줄이 계정 한 개이며 필드는 콜론(`:`)으로 나눈다.

```shell
root:x:0:0:root:/root:/bin/bash
# 계정이름:비밀번호:UID:GID:설명:홈 디렉터리:로그인 셸
```

| 번호 | 필드 | 뜻 |
|---|---|---|
| 1 | 계정 이름 | 로그인 이름 |
| 2 | 비밀번호 | `x`는 비밀번호가 `/etc/shadow`에 있다는 표시다 |
| 3 | UID | 사용자 번호. root는 0이다 |
| 4 | GID | 기본 그룹 번호 |
| 5 | 설명 | 사용자 이름 등 주석(GECOS) |
| 6 | 홈 디렉터리 | 로그인 후 시작 위치 |
| 7 | 로그인 셸 | 로그인 때 실행하는 프로그램. `/sbin/nologin`은 로그인을 막는다 |

{% hint style="danger" %}
WARNING: 일반 계정의 UID나 GID를 0으로 바꾸면 그 계정이 root 권한을 얻는다. 계정 UID와 GID는 `usermod`로만 바꾼다.
{% endhint %}

* 일반 계정 UID는 배포판마다 500 또는 1000부터 시작한다. RHEL 7 이상은 1000부터다(`/etc/login.defs`의 `UID_MIN`).

## 2. /etc/shadow

암호화한 비밀번호와 만료 정보를 저장한다. 필드는 9개다.

```shell
<사용자명>:$6$<salt>$<해시>:<LastChanged>:0:99999:7:::
# 계정이름:Password:LastChanged:Min:Max:Warning:Inactive:Expire:Reserved
```

| 번호 | 필드 | 뜻 |
|---|---|---|
| 1 | 계정 이름 | `/etc/passwd`의 계정 이름과 같다 |
| 2 | Password | 암호화한 비밀번호. `!` 또는 `!!`로 시작하면 잠긴 계정이다. `!!`는 비밀번호가 설정되지 않았다는 뜻이다 |
| 3 | LastChanged | 비밀번호를 마지막으로 바꾼 날. 1970-01-01부터 센 일수다. 0이면 다음 로그인 때 변경을 강제한다 |
| 4 | Min | 변경 후 다시 바꿀 수 없는 최소 일수 |
| 5 | Max | 비밀번호 최대 사용 일수. 99999는 사실상 만료 없음이다 |
| 6 | Warning | 만료 전 경고를 시작하는 일수 |
| 7 | Inactive | 만료 후 계정이 비활성화되기까지의 유예 일수 |
| 8 | Expire | 계정 만료일. 1970-01-01부터 센 일수다 |
| 9 | Reserved | 예약 필드. 쓰지 않는다 |

* 파일 권한은 배포판마다 다르다. RHEL 계열은 `----------`(모드 000, root 소유)이고, Debian 계열은 `-rw-r-----`(root:shadow)다. 일반 사용자는 읽을 수 없다.
* 비밀번호를 바꾸려면 `passwd`, 만료 정보를 바꾸려면 `chage`를 쓴다. 절차는 LNX-ACC-013-MP를 따른다.

## 3. /etc/login.defs

계정 생성과 비밀번호 알고리즘의 기본값을 정한다. 아래 값은 RHEL 계열의 예다.

| 키 | 예 | 뜻 |
|---|---|---|
| `UMASK` | `022` | 새 파일의 기본 권한 마스크. LNX-ACC-008-DO를 따른다 |
| `UID_MIN` | `1000` | 일반 계정에 부여하는 UID의 시작값 |
| `ENCRYPT_METHOD` | `SHA512` | 비밀번호 해시 알고리즘 |

## 4. /etc/security/pwquality.conf

비밀번호 복잡성 규칙을 정한다. 모든 항목은 기본적으로 주석(`#`) 처리돼 있다. 적용 절차는 LNX-ACC-011-MP를 따른다.

| 키 | 예 | 뜻 |
|---|---|---|
| `difok` | `1` | 이전 비밀번호와 달라야 하는 문자 수 |
| `minlen` | `8` | 비밀번호 최소 길이 |
| `dcredit` | `0` | 숫자. 음수는 최소 필요 개수, 양수는 길이 계산에 반영하는 최대 개수 |
| `ucredit` | `0` | 대문자. 값의 해석은 `dcredit`와 같다 |
| `lcredit` | `0` | 소문자. 값의 해석은 `dcredit`와 같다 |
| `ocredit` | `0` | 특수문자. 값의 해석은 `dcredit`와 같다 |
| `maxrepeat` | `0` | 같은 문자의 연속 허용 개수. 0이면 검사하지 않는다 |
| `gecoscheck` | `0` | 1이면 `/etc/passwd`의 설명 필드 단어를 비밀번호에 쓰지 못하게 한다 |

## 5. /etc/security/faillock.conf

로그인 실패 시 계정을 잠그는 규칙을 정한다. 적용 절차는 LNX-ACC-012-MP를 따른다.

| 키 | 예 | 뜻 |
|---|---|---|
| `deny` | `3` | 이 횟수만큼 실패하면 계정을 잠근다 |
| `fail_interval` | `900` | 실패 횟수를 세는 기간(초) |
| `unlock_time` | `600` | 잠금 유지 시간(초). 0이면 관리자가 풀 때까지 잠긴다 |

## 6. chpasswd -c

`chpasswd`는 `<사용자명>:<비밀번호>` 형식의 입력으로 비밀번호를 일괄 설정한다. `-c`는 저장 방식을 고른다.

| 값 | 뜻 |
|---|---|
| `SHA512` | SHA-512로 해시해 저장한다. RHEL 계열 기본값이다 |
| `NONE` | 해시하지 않고 그대로 저장한다 |

{% hint style="danger" %}
WARNING: `-c NONE`은 비밀번호를 평문으로 `/etc/shadow`에 쓴다. 로그인이 되지 않거나 비밀번호가 노출될 수 있다. 실습 목적 외에는 쓰지 않는다.
{% endhint %}

```shell
echo "<사용자명>:<비밀번호>" | chpasswd -c SHA512
```

{% hint style="warning" %}
CAUTION: 위 명령은 비밀번호가 셸 기록(history)에 남는다. 실습이 끝나면 `history -c`로 지우고 비밀번호를 바꾼다.
{% endhint %}

## 7. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [리눅스 비밀번호 암호화 구조](linuxpasswd.md) | LNX-ACC-005-DO | 해시와 salt 원리 |
| [파일 및 디렉터리 접근 권한](permission.md) | LNX-ACC-008-DO | umask와 권한 |
| [계정·그룹 명령어 표](accountcommandsreference.md) | LNX-ACC-009-REF | useradd, usermod, chage 옵션 |
| [비밀번호 복잡성 정책 설정](passwordpolicy.md) | LNX-ACC-011-MP | pwquality 적용 |
| [로그인 실패 계정 잠금 설정](accountlock.md) | LNX-ACC-012-MP | faillock 적용과 해제 |
| [비밀번호 만료 설정과 강제 변경](passwordexpiry.md) | LNX-ACC-013-MP | chage 사용 |
| [무차별 대입 공격](../../../Security/security/offensive-security/pentest/brute-force/brute-force-attack.md) | | 비밀번호 정책이 필요한 이유 |

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 REF로 재작성했다. 비밀번호 정책, 잠금, 만료 절차는 별도 MP(LNX-ACC-011~013)로 나눴다. `/etc/shadow` 8번 필드를 계정 만료일(일수)로 정정했다. 샘플 해시는 `$6$<salt>$<해시>`로 바꿨다 |
