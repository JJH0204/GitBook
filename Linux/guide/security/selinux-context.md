# SELinux 파일 컨텍스트 변경

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-SEC-005-MP |
| 목적 | 파일의 SELinux 유형(type)을 조회, 변경, 복원하고 경로별 규칙을 등록한다 |
| 적용 대상 | RHEL 계열 9, SELinux Enforcing 또는 Permissive, root 또는 sudo 권한 |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [selinux.md](selinux.md) | LNX-SEC-003-DO | SELinux 보안 모듈 (컨텍스트 구성) |
| [selinux-mode.md](selinux-mode.md) | LNX-SEC-004-MP | SELinux 모드 변경 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 대상 서버 | RHEL 계열 9, SELinux 사용 | |
| 2 | `semanage` 명령 | `policycoreutils-python-utils` 패키지 | 없으면 `dnf install -y policycoreutils-python-utils` |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 시스템 디렉터리나 서비스 데이터 디렉터리의 유형을 잘못 바꾸면 서비스가 파일에 접근하지 못해 중단될 수 있다. 변경 전에 `ls -Z`로 원래 유형을 기록한다.
{% endhint %}

{% hint style="info" %}
NOTE: `chcon`으로 바꾼 유형은 `restorecon`이나 파일 시스템 재레이블링 때 원래대로 돌아간다. 영구 변경은 `semanage fcontext`로 규칙을 등록한 뒤 `restorecon`을 쓴다. 미검증이다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | SELinux가 켜져 있다 | `getenforce`가 `Enforcing` 또는 `Permissive`를 출력한다 |
| 2 | 시험용 작업 디렉터리를 정한다 | `<작업 디렉터리>`로 `cd`한다 |

## 5. 절차

### A. 컨텍스트 조회

1. (5-A-01) 파일의 컨텍스트를 조회한다: `ls -Zl <파일 경로>` → 결과: `사용자:역할:유형:레벨` 필드가 출력된다.

### B. 유형 임시 변경과 복원

1. (5-B-01) 시험 파일을 만든다: `touch test.html`
2. (5-B-02) 유형을 지정한다: `chcon -t admin_home_t test.html` → 결과: 오류 없이 끝난다.
3. (5-B-03) 결과를 확인한다: `ls -Zl test.html` → 결과: 유형이 `admin_home_t`로 출력된다.
4. (5-B-04) 원래 유형으로 복원한다: `restorecon test.html` → 결과: 오류 없이 끝난다.
5. (5-B-05) 복원을 확인한다: `ls -Zl test.html` → 결과: 경로 규칙에 맞는 기본 유형이 출력된다.

### C. 경로 규칙 등록

1. (5-C-01) 경로 규칙을 등록한다: `semanage fcontext -a -t httpd_sys_content_t "<디렉터리 경로>(/.*)?"` → 결과: 오류 없이 끝난다. 예: 경로가 `/test`이면 `"/test(/.*)?"`다.
2. (5-C-02) 규칙을 파일에 적용한다: `restorecon -Rv <디렉터리 경로>` → 결과: 변경된 파일 목록이 출력된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `ls -Zl <파일 경로>` | 의도한 유형이다 | 유형 필드가 지정한 값이다 |
| 2 | `semanage fcontext -l \| grep <디렉터리 경로>` | 등록한 규칙이 보인다 | 규칙 한 줄 이상 |

## 7. 복구

1. (7-01) 등록한 경로 규칙을 삭제한다: `semanage fcontext -d "<디렉터리 경로>(/.*)?"`
2. (7-02) 파일 유형을 원래대로 돌린다: `restorecon -Rv <디렉터리 경로>`
3. (7-03) 시험 파일을 지운다: `rm test.html`

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `selinux.md`의 레이블 부분을 분리해 MP로 재작성. 영구 변경(`semanage` 규칙 후 `restorecon`) 안내와 복구는 원본에 없던 내용이다 |
