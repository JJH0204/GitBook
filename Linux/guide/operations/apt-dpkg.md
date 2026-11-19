# [생성형 AI] 패키지 관리 도구 (APT, dpkg)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-OPS-004-REF |
| 유형 | REF (명령 표) |
| 목적 | Debian 계열(Ubuntu 등)의 패키지 관리 명령 `apt`, `dpkg`를 참조하고 RPM 계열 명령과 대응시킨다 |
| 확인 상태 | 일부 확인 (Ubuntu 26.04에서 `dpkg -l`, `dpkg -S`, `dpkg -L`, `apt list --installed`, `apt-cache policy`, `apt search`를 실행했다. 설치·삭제·갱신 명령은 실행하지 않아 미검증) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: RHEL 계열의 `rpm`, `dnf`는 [패키지 관리 도구 (RPM, DNF)](linuxpackagemanagementtool.md)(LNX-OPS-002-REF)에 있다.
{% endhint %}

## 1. apt (저장소 기반)

| 명령어 | 설명 | 형식 | 비고 |
|---|---|---|---|
| `apt update` | 저장소의 패키지 목록을 갱신한다. 패키지를 바꾸지 않는다 | `apt update` | 설치·업그레이드 전에 먼저 실행한다 |
| `apt upgrade` | 설치된 패키지를 새 버전으로 올린다. 설치된 패키지를 제거하지 않는다 | `apt upgrade` | root 권한 |
| `apt install` | 패키지를 설치한다 | `apt install <패키지>` | 의존 패키지도 함께 설치한다 |
| `apt remove` | 패키지를 제거한다. 설정 파일은 남는다 | `apt remove <패키지>` | |
| `apt purge` | 패키지와 설정 파일을 제거한다 | `apt purge <패키지>` | 설정이 사라진다 |
| `apt autoremove` | 더 이상 필요 없는 의존 패키지를 제거한다 | `apt autoremove` | |
| `apt search` | 이름과 설명에서 검색한다 | `apt search <검색어>` | `^<이름>$` 정규식도 쓸 수 있다 |
| `apt show` | 패키지 정보를 출력한다 | `apt show <패키지>` | |
| `apt list --installed` | 설치된 패키지를 출력한다 | `apt list --installed` | 출력 끝에 `[installed]`, `[installed,automatic]`(의존으로 설치됨)가 붙는다 |
| `apt-cache policy` | 설치된 버전과 후보 버전, 저장소를 출력한다 | `apt-cache policy <패키지>` | `Installed:`와 `Candidate:` 확인 |

{% hint style="warning" %}
CAUTION: `apt purge`와 `apt autoremove`는 설정과 패키지를 지운다. 대상 목록을 먼저 확인한다(실행 전 요약에서 `n`을 입력하면 취소된다). 운영 서버에서는 `apt upgrade` 전에 변경 내용을 점검하고 점검 시간을 확보한다.
{% endhint %}

## 2. dpkg (패키지 파일·설치 상태)

| 명령어 | 설명 | 형식 | 예 |
|---|---|---|---|
| `dpkg -l` | 설치된 패키지를 출력한다. 첫 열 `ii`는 설치됨이다 | `dpkg -l [<패턴>]` | `dpkg -l bash` |
| `dpkg -L` | 패키지가 설치한 파일 목록을 출력한다 | `dpkg -L <패키지>` | `dpkg -L cron` |
| `dpkg -S` | 파일이 어느 패키지에 속하는지 찾는다 | `dpkg -S <파일 경로>` | `dpkg -S /usr/bin/ls` |
| `dpkg -i` | 내려받은 `.deb` 파일을 설치한다. 의존 패키지는 자동으로 풀지 않는다 | `dpkg -i <파일>.deb` | |

{% hint style="info" %}
NOTE: `dpkg -S /bin/ls`는 일치하는 경로가 없다는 오류를 냈다. 최신 Debian 계열은 `/bin`이 `/usr/bin`의 심볼릭 링크라서 패키지가 `/usr/bin/ls`로 기록한다. 실제 경로로 조회한다(실행 확인).
{% endhint %}

## 3. RPM 계열과의 대응

| 하는 일 | Debian 계열 | RHEL 계열 |
|---|---|---|
| 설치 | `apt install <패키지>` | `dnf install <패키지>` |
| 제거 | `apt remove <패키지>` | `dnf remove <패키지>` |
| 전체 갱신 | `apt update` 후 `apt upgrade` | `dnf upgrade` |
| 설치된 패키지 목록 | `dpkg -l` | `rpm -qa` |
| 파일의 소속 패키지 | `dpkg -S <파일>` | `rpm -qf <파일>` |
| 패키지의 파일 목록 | `dpkg -L <패키지>` | `rpm -ql <패키지>` |

## 4. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성 |
