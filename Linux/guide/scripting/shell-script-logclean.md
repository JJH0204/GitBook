# 오래된 로그 파일 정리 스크립트 작성

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-SCR-004-MP |
| 목적 | 로그 디렉터리에서 2일 이상 지난 `.log` 파일은 gzip으로 압축하고 3일 이상 지난 파일은 삭제하는 스크립트를 작성해 실습 디렉터리에서 실행한다 |
| 적용 대상 | 리눅스(GNU `find`, `touch`, `gzip`). 일반 사용자 권한 |
| 소요 시간 | 약 15분 |
| 확인 상태 | 미검증 (원본 과제의 예시 스크립트를 정정해 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [find_time.md](../commands/find_time.md) | LNX-CMD-006-REF | find 시간 옵션 및 파일 속성 |
| [shell-script-syntax.md](shell-script-syntax.md) | LNX-SCR-002-REF | 쉘 스크립트 문법 참조 |
| [logrotate.md](../logging-monitoring/logrotate.md) | LNX-LOG-002-DO | 로그 회전 관리 (Logrotate) |
| [cron-register.md](cron-register.md) | LNX-SCR-007-MP | cron 작업 등록과 확인 |
| [find 명령 mtime 정리(외부 블로그)](https://inpa.tistory.com/entry/LINUX-%F0%9F%93%9A-find-%EB%AA%85%EB%A0%B9-mtime-ctime-atime-%EC%98%B5%EC%85%98-n-n-%EA%B0%9C%EB%85%90-%EC%A0%95%EB%A6%AC) | | 원본 페이지의 관련 자료 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 터미널 | bash | |
| 2 | 시험용 디렉터리 | `~/shell-lab/log-test` | 5-A에서 만든다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 이 문서의 스크립트는 조건에 맞는 파일을 복구 없이 삭제한다. 실습은 시험용 디렉터리에서만 한다. `/var/log`를 인자로 주면 서비스가 쓰는 로그와 감사 기록이 삭제될 수 있다. 운영 서버의 `/var/log`는 이 스크립트 대신 logrotate(LNX-LOG-002-DO)로 관리한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | GNU `find`와 `touch -d`를 쓸 수 있다 | `find --version`이 버전을 출력한다 |
| 2 | 시간 조건의 의미를 안다 | LNX-CMD-006-REF의 `-mtime` 표를 읽는다 |

{% hint style="info" %}
NOTE: `-mtime`은 파일 나이를 24시간 단위로 환산하고 소수점 이하를 버린다. `-mtime +1`은 48시간 이상, `-mtime +2`는 72시간 이상 지난 파일이다. 원본은 "3일 이상 삭제"에 `+1`을, "2일 이상 압축"에 `1`(24~48시간)을 썼다. 이 문서는 `+2`와 `+1`로 정정했다.
{% endhint %}

## 5. 절차

### A. 시험 파일 만들기

1. (5-A-01) 디렉터리를 만든다: `mkdir -p ~/shell-lab/log-test` → 결과: 오류 없이 끝난다.
2. (5-A-02) 이동한다: `cd ~/shell-lab/log-test` → 결과: `pwd`가 시험용 디렉터리를 출력한다.
3. (5-A-03) 수정 시각이 다른 파일 네 개를 만든다: `touch new.log; touch -d "1 day ago" d1.log; touch -d "2 days ago" d2.log; touch -d "3 days ago" d3.log` → 결과: 오류 없이 끝난다.
4. (5-A-04) 확인한다: `ls -l --time-style=long-iso` → 결과: 네 파일의 수정 시각이 현재, 1일, 2일, 3일 전이다.

### B. 스크립트 작성

1. (5-B-01) 스크립트를 작성한다.

```bash
cat > ~/shell-lab/logclean.sh <<'EOF2'
#!/bin/bash
# 사용법: ./logclean.sh <로그 디렉터리> [--run]
# --run이 없으면 대상만 출력한다(시험 실행).
dir="${1:?사용법: $0 <로그 디렉터리> [--run]}"

if [ "${2}" = "--run" ]; then
        echo "[삭제] 72시간 이상 지난 .log"
        find "$dir" -type f -name "*.log" -mtime +2 -print -delete
        echo "[압축] 48시간 이상 지난 .log"
        find "$dir" -type f -name "*.log" -mtime +1 -print -exec gzip {} +
else
        echo "[시험 실행] 삭제 대상"
        find "$dir" -type f -name "*.log" -mtime +2 -print
        echo "[시험 실행] 압축 대상"
        find "$dir" -type f -name "*.log" -mtime +1 -print
fi
EOF2
chmod +x ~/shell-lab/logclean.sh
```

→ 결과: 오류 없이 끝난다.

### C. 시험 실행과 실행

1. (5-C-01) 시험 실행한다: `~/shell-lab/logclean.sh ~/shell-lab/log-test` → 결과: 삭제 대상에 `d3.log`, 압축 대상에 `d2.log`와 `d3.log`가 나온다. `new.log`와 `d1.log`는 나오지 않는다.

{% hint style="danger" %}
WARNING: 다음 단계는 `d3.log`를 삭제한다. 5-C-01의 삭제 대상이 `d3.log` 하나뿐인지 확인한 뒤 실행한다.
{% endhint %}

2. (5-C-02) 실행한다: `~/shell-lab/logclean.sh ~/shell-lab/log-test --run` → 결과: 삭제 구역에 `d3.log`, 압축 구역에 `d2.log`가 출력된다.
3. (5-C-03) 결과를 확인한다: `ls -l --time-style=long-iso` → 결과: `new.log`, `d1.log`, `d2.log.gz`만 남는다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `ls ~/shell-lab/log-test` | `d1.log  d2.log.gz  new.log` | `d3.log`가 없고 `d2.log.gz`가 있다 |
| 2 | `gzip -l ~/shell-lab/log-test/d2.log.gz` | 압축 정보 출력 | 오류가 없다 |
| 3 | `~/shell-lab/logclean.sh` (인자 없음) 후 `echo $?` | 사용법 메시지 | 종료 코드가 `0`이 아니다 |

{% hint style="info" %}
NOTE: `gzip`은 압축 파일의 수정 시각을 원본과 같게 유지한다. 그래서 `d2.log.gz`는 이름이 `*.log`가 아니므로 다음 실행에서 다시 압축되지 않는다. `.gz`를 일정 기간 뒤 삭제하려면 `-name "*.log.gz"` 조건을 가진 `find`를 추가한다.
{% endhint %}

## 7. 복구

삭제한 파일은 복구되지 않는다. 시험 환경을 정리한다.

{% hint style="danger" %}
WARNING: 다음 단계의 `rm -r`은 지정한 디렉터리와 스크립트를 복구 없이 삭제한다. 경로를 확인한 뒤 실행한다.
{% endhint %}

1. (7-01) 시험 파일과 스크립트를 지운다: `rm -r ~/shell-lab/log-test ~/shell-lab/logclean.sh` → 결과: `ls ~/shell-lab`에 두 항목이 없다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `shell-script.md`의 "과제" 절을 절차 형식으로 재작성. 시간 조건(`+1`→`+2`, `1`→`+1`), 변수 이름 오타(`ziplog`), 백틱 안 `rm`, 따옴표 없는 `*.log`, `/var/log` 직접 삭제를 정정했다 |
