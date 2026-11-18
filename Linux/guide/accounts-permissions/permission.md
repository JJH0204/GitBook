# 파일 및 디렉터리 접근 권한

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-ACC-008-DO |
| 유형 | D&O (개념·원리) |
| 목적 | 파일 권한 표기, 숫자 표기, umask, 실효 권한, 특수 권한을 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 직접 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 권한을 바꾸는 절차는 LNX-ACC-010-MP를 따른다. 권한 관리가 중요한 이유는 시스템 침해의 주된 목표가 관리자 권한 탈취이기 때문이다.
{% endhint %}

## 1. 목적

리눅스는 파일과 디렉터리마다 소유자, 소유 그룹, 권한을 둔다. 이 문서는 `ls -l`의 권한 표기를 읽는 법과 권한이 정해지는 원리를 설명한다.

## 2. 구성 요소

`ls -l`의 첫 열은 10글자다. 예: `-rw-------`

| 위치 | 예 | 뜻 |
|---|---|---|
| 1 | `-` | 종류. `-` 파일, `d` 디렉터리, `l` 심볼릭 링크 |
| 2~4 | `rw-` | 소유자(user) 권한 |
| 5~7 | `---` | 소유 그룹(group) 권한 |
| 8~10 | `---` | 그 밖의 사용자(other) 권한 |

| 글자 | 뜻 | 숫자 | 파일에서 | 디렉터리에서 |
|---|---|---|---|---|
| `r` | 읽기 | 4 | 내용을 읽는다 | 목록을 본다 |
| `w` | 쓰기 | 2 | 내용을 바꾼다 | 안에서 파일을 만들고 지운다 |
| `x` | 실행 | 1 | 프로그램으로 실행한다 | 안으로 들어간다(`cd`) |
| `-` | 권한 없음 | 0 | | |

예: `-rw-------`는 파일이고, 소유자만 읽고 쓸 수 있으며, 그룹과 다른 사용자는 아무 권한이 없다. 숫자로 600이다.

### 숫자 표기

세 자리 수는 소유자, 그룹, 그 밖의 사용자 순이다. 각 자리는 r(4), w(2), x(1)의 합이다.

| 숫자 | 글자 | 뜻 |
|---|---|---|
| 755 | `rwxr-xr-x` | 소유자는 모든 권한, 나머지는 읽기와 실행 |
| 644 | `rw-r--r--` | 소유자는 읽기와 쓰기, 나머지는 읽기 |
| 777 | `rwxrwxrwx` | 모든 사용자에게 모든 권한. 보안상 쓰지 않는다 |

## 3. 동작 원리

### umask

새로 만든 파일과 디렉터리의 기본 권한은 최대 권한에서 umask 값을 뺀 값이다.

| 대상 | 최대 권한 | umask 022 적용 결과 |
|---|---|---|
| 파일 | 666 | 644 |
| 디렉터리 | 777 | 755 |

* 기본 umask는 `/etc/login.defs`의 `UMASK`와 셸 설정 파일에서 정한다. RHEL 계열 root는 `022`, 일반 사용자는 `002` 또는 `022`다.
* umask를 느슨하게 바꾸면 새 파일을 다른 사용자가 읽을 수 있게 된다. 서버 전체에 영향을 주므로 함부로 바꾸지 않는다.

### 실제 ID와 유효 ID

| 구분 | 뜻 |
|---|---|
| Real UID/GID (RUID, RGID) | 사용자를 식별하는 번호. 로그인한 사람을 가리킨다 |
| Effective UID/GID (EUID, EGID) | 권한 판단에 쓰는 번호 |

* 로그인 직후에는 두 값이 같다.
* setuid 비트가 있는 파일을 실행하는 동안에는 유효 ID가 파일 소유자로 바뀐다.
* `/etc/passwd`에서 UID를 0으로 주면 그 계정이 root 권한을 갖는다. LNX-ACC-001-REF의 WARNING을 따른다.
* `sudo` 권한은 `/etc/sudoers`에서 관리한다. 편집은 `visudo`로 한다.

### 특수 권한

| 이름 | 숫자 | 표기 위치 | 효과 |
|---|---|---|---|
| setuid | 4000 | 소유자 `x` 자리가 `s` | 실행 중에 파일 소유자의 권한을 잠시 빌린다 |
| setgid | 2000 | 그룹 `x` 자리가 `s` | 실행 중에 파일 그룹의 권한을 얻는다. 디렉터리에서는 새 파일이 디렉터리의 그룹을 이어받는다 |
| sticky bit | 1000 | 그 밖의 사용자 `x` 자리가 `t` | 디렉터리 안의 파일을 소유자만 지울 수 있다. `/tmp`가 그 예다 |

setuid 예시(`ls -l /usr/bin/passwd`)다. 일반 사용자가 `passwd`로 root 소유의 `/etc/shadow`를 바꿀 수 있는 이유다.

```
-rwsr-xr-x. 1 root root 32656 May 15  2022 /usr/bin/passwd
```

setuid가 설정된 파일은 권한 상승 공격의 표적이 된다. 점검에는 아래 명령을 쓴다.

```bash
find / -user root -perm /4000
```

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| UID / GID | 사용자 번호 / 그룹 번호 |
| umask | 새 파일 권한에서 뺄 값 |
| setuid / setgid | 실행 중 소유자 / 그룹 권한을 얻는 비트 |
| sticky bit | 디렉터리에서 남의 파일 삭제를 막는 비트 |
| `/etc/sudoers` | `sudo` 권한 설정 파일 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [파일 권한 변경 (chmod, chown, umask)](permissionchange.md) | LNX-ACC-010-MP | 권한 변경 절차 |
| [사용자 계정 관리 설정 파일](account-management.md) | LNX-ACC-001-REF | UID, GID 필드 |
| [백도어 공격](../../../Security/security/offensive-security/system/backdoor-attack.md) | | setuid 파일 악용 |
| [기타 유용한 명령어](../commands/misccommands.md) | | 명령어 모음 |

외부 자료는 아래와 같다.

* [sudo와 su 차이 (velog)](https://velog.io/@lenyleny/Linux-sudosusu-%EC%B0%A8%EC%9D%B4-%EA%B7%B8%EB%A6%AC%EA%B3%A0-%EC%99%80-%EC%B0%A8%EC%9D%B4-rootadminuser-%EC%B0%A8%EC%9D%B4)
* [/etc/sudoers 수정 (tistory)](https://mans-daily.tistory.com/entry/%EB%A6%AC%EB%88%85%EC%8A%A4UbuntuCentOS-etcsudoers-%ED%8C%8C%EC%9D%BC%EC%9D%84-%EC%88%98%EC%A0%95%ED%95%98%EC%97%AC-sudo-%EA%B6%8C%ED%95%9C-%EB%B0%8F-root-%EA%B6%8C%ED%95%9C-%EB%B6%80%EC%97%AC%ED%95%98%EA%B8%B0)
* [특수 권한 (naver 블로그)](https://blog.naver.com/doctor-kick/222158625480)
* [특수 권한 (tistory)](https://eunguru.tistory.com/115)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `-rwxr-x---`를 숫자로 바꾸면 얼마이고, 누가 무엇을 할 수 있을까?
- [ ] 일반 사용자가 `passwd`로 `/etc/shadow`를 바꿀 수 있는 이유를 setuid로 설명해 보자.
- [ ] umask가 022일 때 새 디렉터리 권한이 755가 되는 과정을 설명해 보자.
