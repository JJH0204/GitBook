# 일반 시스템 명령어 (history, tree, su)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-LAC-008-REF |
| 유형 | REF (명령 표) |
| 목적 | 달력, 날짜, 시간 측정, 메시지 전송, 이력, 사용자 전환 등 단일 용도 명령의 위치와 요약을 제공한다 |
| 확인 상태 | 미검증 (원본 페이지를 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 페이지의 명령은 같은 스페이스의 [기타 유용한 명령어](../../../commands/misccommands.md)(LNX-CMD-004-REF)에 옵션, 형식, 예, 주의 사항이 이미 정리돼 있다. 중복을 피하려고 이 문서는 한 줄 요약과 링크만 둔다. 상세는 그 문서를 본다.
{% endhint %}

## 1. 명령 요약

| 명령어 | 한 줄 요약 | 상세 |
|---|---|---|
| `cal` | 달력을 출력한다 | LNX-CMD-004-REF |
| `clear` | 터미널 화면을 지운다 | LNX-CMD-004-REF |
| `strings` | 바이너리 파일 안의 출력 가능한 문자열을 추출한다 | LNX-CMD-004-REF |
| `base64` | Base64로 인코딩하거나 디코딩한다 | LNX-CMD-004-REF |
| `tr` | 입력의 문자를 치환하거나 삭제한다 | LNX-CMD-004-REF |
| `mktemp` | 임시 파일을 만들고 경로를 출력한다 | LNX-CMD-004-REF |
| `date` | 날짜와 시간을 표시하거나 바꾼다 | LNX-CMD-004-REF |
| `tty` | 현재 단말기의 파일 경로를 출력한다 | LNX-CMD-004-REF |
| `time` | 명령 실행 시간을 측정한다 (`real`, `user`, `sys`) | LNX-CMD-004-REF |
| `wall` | 로그인한 모든 사용자에게 메시지를 보낸다 | LNX-CMD-004-REF |
| `write` | 지정한 사용자 한 명에게 메시지를 보낸다 | LNX-CMD-004-REF |
| `history` | 명령 사용 기록을 출력한다. `-c`는 메모리의 기록을 지운다 | LNX-CMD-004-REF |
| `tree` | 디렉터리 계층 구조를 출력한다 | LNX-CMD-004-REF |
| `chmod` | 파일과 디렉터리의 권한을 바꾼다 | LNX-CMD-004-REF |
| `su - <사용자명>` | 대상 사용자의 로그인 셸로 전환한다 | LNX-CMD-004-REF |
| `exit` | 현재 셸에서 로그아웃한다 | LNX-CMD-004-REF |

{% hint style="warning" %}
CAUTION: `history -c`로 메모리의 기록을 지운 뒤 셸을 종료하면 이번 세션의 기록이 `~/.bash_history`에도 남지 않는다. 원본은 `.bash_history`가 "시스템 종료 때" 저장된다고 적었으나 bash는 셸 종료 때 저장하므로 정정했다. 미검증이다.
{% endhint %}

## 2. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [misccommands.md](../../../commands/misccommands.md) | LNX-CMD-004-REF | 기타 유용한 명령어 |

## 3. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | REF 형식으로 재작성. 같은 내용이 있는 LNX-CMD-004-REF로 연결하고 한 줄 요약만 남겼다 |
