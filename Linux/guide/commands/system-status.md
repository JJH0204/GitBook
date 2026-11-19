# [생성형 AI] 시스템 상태 조회 명령어 (free, du, lsblk, uptime)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-CMD-010-REF |
| 유형 | REF (명령 표) |
| 목적 | 메모리, 디렉터리 용량, 블록 장치, 가동 시간을 조회하는 명령과 출력 열을 참조한다 |
| 확인 상태 | 일부 확인 (Ubuntu 26.04에서 `free`, `du`, `lsblk`, `uptime`을 실행했다. 다른 배포판의 출력 열은 미검증) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 표의 명령은 모두 읽기 전용이다. 파일 시스템별 사용률은 `df`([df 명령어 참조](../storage-boot/df-command.md)), 프로세스는 `ps`·`top`([프로세스 관리 명령어](process-commands.md))을 쓴다.
{% endhint %}

## 1. 명령 표

| 명령어 | 설명 | 형식 | 주요 옵션 | 예 |
|---|---|---|---|---|
| `free` | 메모리와 스왑 사용량을 출력한다 | `free [옵션]` | `-h`: 사람이 읽기 쉬운 단위(Mi, Gi)<br>`-m`: MiB 단위<br>`-s <초>`: 주기적으로 다시 출력 | `free -h` |
| `du` | 디렉터리·파일이 차지하는 용량을 출력한다 | `du [옵션] <경로>` | `-s`: 합계만<br>`-h`: 사람이 읽기 쉬운 단위<br>`--max-depth=<n>`: 하위 n단계까지 | `du -h --max-depth=1 <디렉터리>` |
| `lsblk` | 블록 장치(디스크, 파티션)를 트리로 출력한다 | `lsblk [옵션]` | `-f`: 파일 시스템 종류, 레이블, UUID 열 추가<br>`-o <열,열>`: 출력 열 지정(`NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT` 등) | `lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT` |
| `uptime` | 가동 시간, 로그인 사용자 수, 부하 평균을 출력한다 | `uptime` | `-p`: 가동 시간만 사람이 읽기 쉬운 형태로 | `uptime` |

## 2. 출력 읽기

### free

| 열 | 뜻 |
|---|---|
| `total` | 전체 메모리 |
| `used` | 사용 중인 메모리 |
| `free` | 아무 용도로도 쓰이지 않는 메모리 |
| `buff/cache` | 디스크 캐시와 버퍼. 필요하면 커널이 회수한다 |
| `available` | 새 프로그램이 쓸 수 있는 추정 메모리. 메모리 부족 판단은 `free`가 아니라 이 열을 본다 |

`free`가 작아도 `available`이 충분하면 정상이다. 실행 확인 예: `total 7.1Gi`, `free 419Mi`, `buff/cache 4.1Gi`, `available 4.1Gi`. 스왑 사용량이 계속 늘어나면 메모리 부족을 의심한다.

### uptime의 부하 평균

`load average`는 최근 1분, 5분, 15분 동안 실행 중이거나 대기 중인 프로세스의 평균 수다. CPU 코어 수와 비교한다. 코어 수보다 지속적으로 크면 대기가 쌓이고 있다는 뜻이다(`nproc`으로 코어 수 확인).

### lsblk의 TYPE

| 값 | 뜻 |
|---|---|
| `disk` | 물리 디스크 |
| `part` | 파티션 |
| `lvm` | LVM 논리 볼륨 |
| `loop` | 파일을 장치처럼 쓰는 루프 장치(snap 패키지 등) |

## 3. 자주 쓰는 조합

| 목적 | 명령 | 읽는 법 |
|---|---|---|
| 용량이 큰 하위 디렉터리 찾기 | `du -h --max-depth=1 <경로> \| sort -h` | 마지막 줄이 가장 크다 |
| 디스크 장치 구조 확인 | `lsblk -f` | 파티션별 파일 시스템과 마운트 위치를 본다 |
| 메모리를 주기적으로 관찰 | `free -h -s 5` | 5초마다 갱신된다. `Ctrl+C`로 끝낸다 |

{% hint style="warning" %}
CAUTION: `du`를 `/` 같은 큰 경로에서 실행하면 오래 걸리고 디스크 입출력을 늘린다. 서비스 중인 서버에서는 대상 디렉터리를 좁힌다.
{% endhint %}

## 4. 관련 문서

| Task ID | 문서 | 용도 |
|---|---|---|
| LNX-STB-007-REF | [df 명령어 참조](../storage-boot/df-command.md) | 파일 시스템별 사용률을 본다 |
| LNX-CMD-007-REF | [프로세스 관리 명령어 (ps, top, kill, nice)](process-commands.md) | 메모리를 많이 쓰는 프로세스를 찾는다 |
| LNX-LOG-004-MP | [시스템 성능 모니터링 (sysstat)](../logging-monitoring/sysstat.md) | 기록 기반 성능 분석을 한다 |

## 5. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성 |
