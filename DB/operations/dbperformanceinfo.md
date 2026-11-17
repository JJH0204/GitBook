# DB 서버 자원 확인과 성능 튜닝

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-OPS-003-REF |
| 유형 | REF (명령 표) |
| 목적 | DB 서버의 메모리, swap, CPU, 디스크, OS·DB 버전을 확인하고 swap 사용 정도(`vm.swappiness`)를 조정하는 명령을 참조한다 |
| 확인 상태 | 미검증 (원본 페이지와 Linux 지식을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본 제목은 "DB 성능 튜닝 및 사용자 관리"였다. 사용자 관리는 [DB 사용자 계정 생성과 권한 관리](dbusermanagement.md)(DB-OPS-004-MP)와 [MariaDB 원격 접속 허용 설정](mariadb-remote-access.md)(DB-OPS-005-MP)으로 나눴고, 이 페이지는 자원 확인과 튜닝만 다뤄 제목을 바꿨다.
{% endhint %}

## 1. 자원 확인 명령

| 대상 | 명령 | 출력 | 비고 |
|---|---|---|---|
| 메모리, swap 요약 | `free` | 총량, 사용량, 여유량 | `-m`은 MB, `-h`는 사람이 읽기 쉬운 단위 |
| 총 메모리 | `grep MemTotal /proc/meminfo` | `MemTotal: <값> kB` | |
| 총 swap | `grep SwapTotal /proc/meminfo` | `SwapTotal: <값> kB` | |
| CPU 정보 | `cat /proc/cpuinfo` | 코어별 모델, 클럭 | |
| 디스크 사용량 | `df -h` | 파일 시스템별 사용량 | |
| 커널 버전 | `cat /proc/version` | 커널 버전 문자열 | |
| 배포판 버전 | `cat /etc/rocky-release` | 예: Rocky Linux 버전 | 배포판마다 파일이 다르다 |
| 모든 커널 매개변수 | `sysctl -a` | `이름 = 값` 목록 | |
| DB 버전 | `mysql --version` | 예: `mysql  Ver 15.1 Distrib 10.5.22-MariaDB, for Linux (x86_64) using  EditLine wrapper` | |

## 2. swap 개념

| 항목 | 내용 |
|---|---|
| swap | 물리 메모리가 부족할 때 디스크를 임시 메모리로 쓰는 영역이다. 비상용 메모리로 이해한다 |
| 크기 | 원본은 "통상 메모리의 1.5~2배를 swap 파티션으로 할당"이라고 적었다 |
| `vm.swappiness` | 커널이 swap을 쓰는 적극성을 0~100으로 정하는 값이다. 기본값은 60이다 |

{% hint style="info" %}
NOTE: swap 크기와 `vm.swappiness` 권장값은 메모리 크기와 용도에 따라 다르다. 원본의 "1.5~2배"와 "40~60"은 일반 지침이며 현재의 DB 서버 권장과 다를 수 있다. 데이터베이스 전용 서버는 swap 사용을 줄이도록 더 낮은 값을 권하는 자료가 있다. 확인 필요.
{% endhint %}

## 3. swappiness 변경

{% hint style="warning" %}
CAUTION: `vm.swappiness`를 바꾸면 서버의 메모리 동작이 달라진다. 운영 서버에서는 현재 값을 먼저 기록해 두고, 변경 후 성능을 관찰한다.
{% endhint %}

| 번호 | 목적 | 명령 | 기대 결과 |
|---|---|---|---|
| 1 | 현재 값 확인 | `sysctl vm.swappiness` | `vm.swappiness = 60` |
| 2 | 즉시 변경 (재부팅 시 사라진다) | `sudo sysctl -w vm.swappiness=40` | `vm.swappiness = 40` |
| 3 | 영구 적용 | `sudo vi /etc/sysctl.conf`로 `vm.swappiness=40` 줄을 추가하거나 수정한다 | 파일에 줄이 저장된다 |
| 4 | 파일 내용 즉시 적용 | `sudo sysctl -p` | 설정 값이 출력된다 |
| 5 | 변경 확인 | `sysctl vm.swappiness` | 설정한 값 |

{% hint style="info" %}
NOTE: 원본은 `/etc/sysctl.conf` 수정만 적었다. 파일 내용을 즉시 반영하는 `sysctl -p`는 원본에 없던 내용이다.
{% endhint %}

## 4. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지 `dbperformanceinfo.md`의 자원 확인·swap 부분을 REF로 재작성. 사용자 관리는 DB-OPS-004-MP, DB-OPS-005-MP로 분리 |
