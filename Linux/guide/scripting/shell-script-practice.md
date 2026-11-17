# 쉘 스크립트 작성과 실행

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-SCR-003-MP |
| 목적 | 실습용 디렉터리에서 쉘 스크립트 네 개(인자 출력, 환경 변수 전달, 구구단, 권한 일괄 변경)를 작성하고 실행 권한을 주어 실행한다 |
| 적용 대상 | 리눅스(bash 4 이상). 일반 사용자 권한 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 예제를 정정해 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [shell-script.md](shell-script.md) | LNX-SCR-001-DO | 쉘 스크립트 프로그래밍 기초 |
| [shell-script-syntax.md](shell-script-syntax.md) | LNX-SCR-002-REF | 쉘 스크립트 문법 참조 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 터미널 | bash 4 이상 | `bash --version`으로 확인한다 |
| 2 | 실습 디렉터리 | `~/shell-lab` | 5-A에서 만든다. 이 디렉터리 밖의 파일은 건드리지 않는다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 구역 E의 스크립트는 현재 디렉터리의 모든 `*.txt` 파일 권한을 바꾼다. 반드시 `~/shell-lab`에서만 실행한다. 홈 디렉터리 등 다른 곳에서 실행하면 관련 없는 파일의 권한이 바뀐다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 터미널을 연다 | 프롬프트가 나타난다 |
| 2 | bash 위치를 확인한다: `command -v bash` | `/usr/bin/bash` 또는 `/bin/bash`가 출력된다 |

## 5. 절차

### A. 실습 디렉터리 만들기

1. (5-A-01) 디렉터리를 만든다: `mkdir -p ~/shell-lab` → 결과: 오류 없이 끝난다.
2. (5-A-02) 이동한다: `cd ~/shell-lab` → 결과: `pwd`가 `~/shell-lab`의 절대 경로를 출력한다.

### B. 인자를 출력하는 스크립트

1. (5-B-01) 스크립트를 작성한다.

```bash
cat > date.sh <<'EOF2'
#!/bin/bash
echo "${0}: ${1}-${2}-${3}"
EOF2
```

→ 결과: `date.sh` 파일이 생긴다.

2. (5-B-02) 실행 권한 없이 실행한다: `./date.sh 2024 9 23` → 결과: `Permission denied`가 출력된다. `echo $?`는 `126`이다.
3. (5-B-03) 실행 권한을 준다: `chmod +x date.sh` → 결과: `ls -l date.sh`의 권한 열에 `x`가 보인다.
4. (5-B-04) 실행한다: `./date.sh 2024 9 23` → 결과: `./date.sh: 2024-9-23`이 출력된다.
5. (5-B-05) 종료 코드를 확인한다: `echo $?` → 결과: `0`이 출력된다.

### C. 환경 변수 전달

1. (5-C-01) 스크립트를 작성한다.

```bash
cat > show.sh <<'EOF2'
#!/bin/bash
echo "hello_world=${hello_world}"
EOF2
chmod +x show.sh
```

→ 결과: 오류 없이 끝난다.

2. (5-C-02) 변수를 선언만 하고 실행한다: `hello_world="Local Word"; ./show.sh` → 결과: `hello_world=`가 출력된다(값이 비어 있다).
3. (5-C-03) 환경 변수로 내보낸다: `export hello_world="Global Export Word"` → 결과: 오류 없이 끝난다.
4. (5-C-04) 다시 실행한다: `./show.sh` → 결과: `hello_world=Global Export Word`가 출력된다.

### D. 구구단 스크립트

1. (5-D-01) 스크립트를 작성한다.

```bash
cat > dan.sh <<'EOF2'
#!/bin/bash
function dan()
{
        for ((j=1; j<10; j++)); do
                echo "${j}단"
                for ((i=1; i<10; i++)); do
                        result=$(( j * i ))
                        echo "$j x $i = $result"
                done
                echo "--------------"
        done
}

dan
EOF2
chmod +x dan.sh
```

→ 결과: 오류 없이 끝난다.

2. (5-D-02) 실행한다: `./dan.sh | head -n 12` → 결과: `1단`, `1 x 1 = 1` … `1 x 9 = 9`, `--------------`, `2단`이 출력된다.

### E. 파일 권한 일괄 변경 스크립트

1. (5-E-01) 대상 파일을 만든다: `touch test1.txt test2.txt test3.txt` → 결과: 오류 없이 끝난다.
2. (5-E-02) 스크립트를 작성한다.

```bash
cat > auto.sh <<'EOF2'
#!/bin/bash
# 사용법: ./auto.sh <권한 모드>
if [ $# -ne 1 ]; then
        echo "사용법: ${0} <권한 모드>" >&2
        exit 1
fi
chmod "${1}" ./*.txt && echo "Success"
EOF2
chmod +x auto.sh
```

→ 결과: 오류 없이 끝난다.

{% hint style="warning" %}
CAUTION: 다음 단계는 현재 디렉터리의 `*.txt` 권한을 바꾼다. 5-A-02에서 이동한 `~/shell-lab`인지 `pwd`로 먼저 확인한다.
{% endhint %}

3. (5-E-03) 실행한다: `./auto.sh 755` → 결과: `Success`가 출력된다.
4. (5-E-04) 권한을 확인한다: `ls -l *.txt` → 결과: 세 파일의 권한이 `-rwxr-xr-x`다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `./date.sh 2024 9 23` | `./date.sh: 2024-9-23` | 출력이 일치한다 |
| 2 | 새 터미널에서 `./show.sh` (구역 C 이후) | `hello_world=` | 값이 비어 있다. `export`가 그 쉘에만 적용되기 때문이다 |
| 3 | `./dan.sh \| tail -n 2` | `9 x 9 = 81`, `--------------` | 두 줄이 일치한다 |
| 4 | `./auto.sh` (인자 없음) 후 `echo $?` | 사용법 메시지 | 종료 코드 `1` |

## 7. 복구

1. (7-01) 환경 변수를 지운다: `unset hello_world` → 결과: `./show.sh`가 `hello_world=`를 출력한다.

{% hint style="danger" %}
WARNING: 다음 단계의 `rm -r`은 `~/shell-lab` 안의 모든 파일을 복구 없이 삭제한다. 경로에 오타가 없는지 확인한 뒤 실행한다.
{% endhint %}

2. (7-02) 실습 파일을 지운다: `cd ~ && rm -r ~/shell-lab` → 결과: `ls ~/shell-lab`이 `No such file or directory`를 출력한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `shell-script.md`의 예제(매개 변수, 환경 변수, 구구단, 자동화)를 절차 형식으로 재작성. `/shell` 디렉터리 대신 `~/shell-lab`을 쓰고, 자동화 스크립트의 인자 검사와 종료 코드를 보강했다 |
