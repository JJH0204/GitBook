# [생성형 AI] 파일 ACL 설정 (setfacl, getfacl)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-LAS-005-MP |
| 유형 | MP (절차) |
| 목적 | 기본 권한(소유자, 그룹, 기타)으로 표현할 수 없는 사용자별 권한을 파일 ACL로 부여하고 확인하고 제거한다 |
| 적용 대상 | RHEL 계열 9 등 ACL을 지원하는 파일 시스템(ext4, xfs)과 `acl` 패키지, 파일 소유자 또는 root |
| 소요 시간 | 약 15분 |
| 확인 상태 | 미검증 (이 환경에 `setfacl`, `getfacl`이 없어 실행하지 못했다. 공식 man 문서의 알려진 동작을 정리한 것이다) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 개정 | R1 (2026-11-19) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [permission.md](../../../accounts-permissions/permission.md) | LNX-ACC-008-DO | 파일 및 디렉터리 접근 권한 |
| [permissionchange.md](../../../accounts-permissions/permissionchange.md) | LNX-ACC-010-MP | 파일 권한 변경 |
| [acl.md](acl.md) | LNX-LAS-001-DO | 라우터 접근 제어 목록 (ACL) (다른 개념이다) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 대상 서버 | RHEL 계열 9 | |
| 2 | `acl` 패키지 | `getfacl`, `setfacl` 포함 | `dnf install acl`로 설치한다. 설치가 안 되어 있으면 명령이 없다는 오류가 나온다 |
| 3 | 실습용 사용자 2개와 실습 디렉터리 | 예: `<사용자1>`, `<사용자2>`, `/srv/acl-lab` | |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: ACL은 기본 권한과 별도로 저장된다. `chmod`로 그룹 권한을 바꾸면 ACL의 마스크(mask)가 함께 바뀌어 부여한 권한이 줄어들 수 있다. ACL을 쓴 파일은 `ls -l`의 권한 문자열 끝에 `+`가 붙는다.
{% endhint %}

{% hint style="info" %}
NOTE: 파일 시스템이 ACL을 지원하지 않으면 `setfacl`이 `Operation not supported` 오류를 낸다. 파일 시스템 종류는 `findmnt -no FSTYPE <경로>`로 확인한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 명령이 있다 | `getfacl --version`이 버전을 출력한다 |
| 2 | 실습 파일을 만든다: `mkdir -p /srv/acl-lab && touch /srv/acl-lab/file.txt` | `ls -l /srv/acl-lab/file.txt`가 파일을 보여 준다 |

## 5. 절차

### A. 현재 ACL 읽기

1. (5-A-01) ACL을 출력한다: `getfacl /srv/acl-lab/file.txt` → 결과: `# owner`, `# group`, `user::`, `group::`, `other::` 줄이 출력된다. 처음에는 기본 권한과 같은 3줄이다.

### B. 사용자·그룹별 권한 부여

1. (5-B-01) 특정 사용자에게 읽기·쓰기를 부여한다: `setfacl -m u:<사용자1>:rw /srv/acl-lab/file.txt` → 결과: 오류 없이 끝난다.
2. (5-B-02) 특정 그룹에게 읽기를 부여한다: `setfacl -m g:<그룹>:r /srv/acl-lab/file.txt` → 결과: 오류 없이 끝난다.
3. (5-B-03) 확인한다: `getfacl /srv/acl-lab/file.txt` → 결과: `user:<사용자1>:rw-`, `group:<그룹>:r--`, `mask::` 줄이 추가된다.
4. (5-B-04) `ls -l /srv/acl-lab/file.txt`를 입력한다 → 결과: 권한 문자열 끝에 `+`가 붙는다.

### C. 디렉터리 기본 ACL

1. (5-C-01) 새로 만드는 파일이 ACL을 물려받게 한다: `setfacl -d -m u:<사용자1>:rwx /srv/acl-lab` → 결과: 오류 없이 끝난다.
2. (5-C-02) 확인한다: `getfacl /srv/acl-lab` → 결과: `default:user:<사용자1>:rwx` 줄이 출력된다.
3. (5-C-03) 디렉터리 안에 새 파일을 만든다: `touch /srv/acl-lab/new.txt` → 결과: `getfacl /srv/acl-lab/new.txt`에 `user:<사용자1>` 항목이 있다.

### D. 항목 제거

1. (5-D-01) 항목 하나를 지운다: `setfacl -x u:<사용자1> /srv/acl-lab/file.txt` → 결과: 해당 `user:` 줄이 사라진다.
2. (5-D-02) 파일의 ACL을 모두 지운다: `setfacl -b /srv/acl-lab/file.txt` → 결과: `getfacl`이 기본 권한 3줄만 출력하고 `ls -l`의 `+`가 사라진다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `<사용자1>`로 `cat /srv/acl-lab/file.txt` | 파일이 읽힌다 | 5-B-01 후 오류가 없다 |
| 2 | `<사용자2>`로 같은 명령 | 거부된다 | 5-B-01 후 `Permission denied`가 나온다(기본 권한이 `other` 읽기 없음일 때) |
| 3 | `getfacl` 출력의 `mask::` | 부여한 권한을 포함한다 | 유효 권한이 의도와 같다 |

## 7. 복구

1. (7-01) 실습 파일의 ACL을 모두 지운다: `setfacl -R -b /srv/acl-lab`
2. (7-02) 실습 디렉터리를 지운다: `rm -r /srv/acl-lab` → 결과: 디렉터리가 사라진다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성 |
