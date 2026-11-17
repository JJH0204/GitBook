# 리눅스 명령어 마인드맵

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-CMD-003-REF |
| 유형 | REF (분류 표) |
| 목적 | 리눅스 명령어의 분류와 상세 문서 위치를 한눈에 찾는다 |
| 확인 상태 | 미검증 (원본 마인드맵의 항목을 표로 옮긴 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본은 Excalidraw 마인드맵의 텍스트 추출본이었다. 그림 데이터 안내 문구와 제목만 있는 항목은 삭제하고, 이 문서는 분류 표로 재구성했다.
{% endhint %}

## 1. 명령어 분류

| 분류 | 상세 문서 |
|---|---|
| 도움말 명령어 | [도움말 명령어 (man, info)](helpcommands.md) |
| 기본 필수 명령어 (전원, 런레벨, 이동, 목록) | [리눅스 기본 필수 명령어](linuxcommand.md) |
| 기타 명령어 (cal, date, time, wall, su 등) | [기타 유용한 명령어](misccommands.md) |
| 텍스트 파일 명령어 | [텍스트 파일 처리 명령어](textfilecommands.md) |
| 파일 시간 속성과 `find` | [find 시간 옵션 및 파일 속성](find_time.md) |
| 사용자 생성 명령어 | [사용자 생성 명령어 (useradd)](../accounts-permissions/usercreationcommands.md) |
| 사용자 조회 명령어 | [사용자 조회 명령어 (who, w, id)](../accounts-permissions/userquerycommands.md) |
| 사용자 계정 관리 명령어 | [사용자 수정 및 삭제 명령어](../accounts-permissions/usermanagementcommands.md) |
| 그룹 관리 명령어 | [그룹 관리 명령어 (groupadd)](../accounts-permissions/groupmanagementcommands.md) |
| 디렉터리 관련 명령어 | [디렉터리 조작 명령어 (pwd, cd, mkdir)](../operations/linux_admin/commands/directorycommands.md) |
| 파일 관련 명령어 | [파일 조작 명령어 (ls, cp, rm)](../operations/linux_admin/commands/filecommands.md) |
| 파일 비교 명령어 | [파일 비교 명령어 (diff, cmp, comm)](../operations/linux_admin/commands/filecomparisoncommands.md) |
| 네트워크 명령어 | [네트워크 진단 명령어](../network-remote/networkcommands.md) |
| 리눅스 기본 디렉터리 | [리눅스 기본 디렉터리 구조](../basic-usage/linuxbasicdirectorydescription.md) |

## 2. 사용자 관련 파일

| 파일 | 설명 |
|---|---|
| `/etc/default/useradd` | `useradd`의 기본값을 정의한 파일 |
| `/etc/passwd` | 계정 정보 파일. 로그인 시 사용하며 항목은 `:`로 구분한다 |
| `/etc/shadow` | 암호화된 비밀번호를 저장한 파일 |
| `/etc/login.defs` | 계정 생성의 기본값을 정의한 파일 |

## 3. 리다이렉션

{% hint style="danger" %}
WARNING: `>`는 대상 파일의 기존 내용을 지우고 덮어쓴다. `>`의 대상으로 중요한 파일(예: `/etc/passwd`)을 지정하지 않는다. 내용을 보존하려면 `>>`를 쓴다.
{% endhint %}

| 기호 | 형식 | 설명 |
|---|---|---|
| `>` | `<명령어> > <파일>` | 표준 출력을 파일로 보낸다 (덮어쓰기) |
| `>>` | `<명령어> >> <파일>` | 표준 출력을 파일 끝에 추가한다 |
| `<` | `<명령어> < <파일>` | 파일에서 표준 입력을 받는다 |

## 4. 용어

| 용어 | 설명 |
|---|---|
| MIME (Multipurpose Internet Mail Extensions) | 이메일에 첨부한 파일을 텍스트 문자 형태로 변환해 메일과 함께 전송하기 위해 만든 형식 |

## 5. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 마인드맵 텍스트를 분류 표로 재구성. 제목만 있던 항목은 상세 문서 링크로 대체하고 "왜? 이렇지?" 항목과 Excalidraw 안내 문구를 삭제했다. 시스템 종료 명령어 항목은 기본 필수 명령어 문서에 합쳤다 |
