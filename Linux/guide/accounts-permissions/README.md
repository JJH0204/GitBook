---
description: 사용자, 그룹, 비밀번호 정책, 파일 권한
---

# 계정 및 권한 관리

계정 설정 파일, 사용자·그룹 관리 명령, 비밀번호 정책, 파일 권한을 다룬다. 문서 번호(Task ID)는 `LNX-ACC-<번호>-<유형>` 형식이다. 유형은 D&O(개념), MP(절차), REF(표)다. 이 폴더의 명령은 실습용 가상 환경(RHEL 계열)을 전제로 한다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| LNX-ACC-001-REF | 표 | [사용자 계정 관리 설정 파일](account-management.md) | passwd, shadow, login.defs, pwquality, faillock 필드를 참조한다 |
| LNX-ACC-002-MP | 절차 | [사용자 생성 명령어 (useradd)](usercreationcommands.md) | 계정을 만들고 비밀번호를 설정한다 |
| LNX-ACC-003-REF | 표 | [사용자 조회 명령어 (who, w, id)](userquerycommands.md) | 로그인 사용자와 UID·그룹을 조회한다 |
| LNX-ACC-004-MP | 절차 | [사용자 수정 및 삭제 명령어](usermanagementcommands.md) | 계정을 수정하고 삭제한다 |
| LNX-ACC-005-DO | 개념 | [리눅스 비밀번호 암호화 구조](linuxpasswd.md) | 해시와 salt 원리를 이해한다 |
| LNX-ACC-006-DO | 개념 | [그룹 관리 및 설정 (/etc/group)](groupmanagement.md) | 그룹 파일 구조를 이해한다 |
| LNX-ACC-007-MP | 절차 | [그룹 관리 명령어 (groupadd)](groupmanagementcommands.md) | 그룹을 만들고 구성원을 관리한다 |
| LNX-ACC-008-DO | 개념 | [파일 및 디렉터리 접근 권한](permission.md) | 권한 표기, umask, 특수 권한을 이해한다 |
| LNX-ACC-009-REF | 표 | [계정·그룹 명령어 표](accountcommandsreference.md) | 명령 옵션을 찾는다 |
| LNX-ACC-010-MP | 절차 | [파일 권한 변경 (chmod, chown, umask)](permissionchange.md) | 권한과 소유자를 바꾼다 |
| LNX-ACC-011-MP | 절차 | [비밀번호 복잡성 정책 설정](passwordpolicy.md) | pwquality를 설정한다 |
| LNX-ACC-012-MP | 절차 | [로그인 실패 계정 잠금 설정](accountlock.md) | faillock을 설정하고 잠금을 푼다 |
| LNX-ACC-013-MP | 절차 | [비밀번호 만료 설정과 강제 변경](passwordexpiry.md) | chage로 만료를 관리한다 |

## 읽는 순서

1. LNX-ACC-001-REF와 LNX-ACC-005-DO로 계정 파일과 비밀번호 저장 방식을 이해한다.
2. LNX-ACC-002-MP로 계정을 만들고 LNX-ACC-003-REF로 조회한다.
3. LNX-ACC-006-DO와 LNX-ACC-007-MP로 그룹을 관리한다.
4. LNX-ACC-008-DO와 LNX-ACC-010-MP로 파일 권한을 다룬다.
5. LNX-ACC-011-MP, LNX-ACC-012-MP, LNX-ACC-013-MP로 비밀번호 정책을 적용한다.
6. 명령 옵션은 LNX-ACC-009-REF에서 찾는다.
