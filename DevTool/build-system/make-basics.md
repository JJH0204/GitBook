# [생성형 AI] Makefile 작성과 make 사용

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-BLD-007-MP |
| 목적 | 소스 두 개를 컴파일해 실행 파일로 묶는 최소 Makefile을 쓰고, 바뀐 파일만 다시 빌드되는 것을 확인한다 |
| 적용 대상 | GNU Make 4.x, gcc, Linux·macOS(Windows는 MinGW 환경) |
| 소요 시간 | 약 15분 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (GNU Make 4.4.1, gcc 15.2.0, Linux, 2026-11-19에서 이 문서의 파일과 명령을 실행해 출력을 확인했다. macOS, Windows는 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: CMake와 Ninja는 빌드 파일을 만들어 주는 도구다(DEV-BLD-001-DO, DEV-BLD-003-DO). `make`는 직접 쓴 Makefile을 읽어 빌드한다. 작은 프로젝트에서는 Makefile이 가장 단순하다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [cmake.md](cmake.md) | DEV-BLD-001-DO | CMake 개요 및 활용 |
| [ninja.md](ninja.md) | DEV-BLD-003-DO | Ninja 빌드 시스템 |
| [../compiler-debug/gcc-build-stages.md](../compiler-debug/gcc-build-stages.md) | DEV-CMP-006-DO | [생성형 AI] gcc 빌드 4단계와 자주 쓰는 옵션 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | gcc | 아무 버전 | `gcc --version` |
| 2 | make | GNU Make 4.x | `make --version` |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: Makefile의 명령 줄은 공백이 아니라 탭 문자로 시작해야 한다. 공백이면 `*** missing separator.  Stop.` 오류가 난다. 편집기가 탭을 공백으로 바꾸지 않게 설정한다.
{% endhint %}

## 4. 준비

작업 폴더에 소스 세 개를 만든다.

`util.h`
```c
int add(int a, int b);
```

`util.c`
```c
#include "util.h"
int add(int a, int b) { return a + b; }
```

`main.c`
```c
#include <stdio.h>
#include "util.h"
int main(void) {
    printf("%d\n", add(2, 3));
    return 0;
}
```

## 5. 절차

**A. Makefile 작성**

1. (SUBTASK 5-A-01) 같은 폴더에 `Makefile`을 만든다. 명령 줄 앞은 탭이다.

```make
CC = gcc
CFLAGS = -Wall -O2
OBJS = main.o util.o

app: $(OBJS)
	$(CC) $(OBJS) -o $@

%.o: %.c util.h
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) app

.PHONY: clean
```

| 요소 | 뜻 |
|---|---|
| `app: $(OBJS)` | 규칙. `app`(목표)을 만들려면 `$(OBJS)`(선행 조건)가 필요하다 |
| 탭 줄 | 목표를 만드는 명령 |
| `$@`, `$<` | 자동 변수. 목표 이름, 첫 선행 조건 |
| `%.o: %.c` | 패턴 규칙. 모든 `.c`에서 `.o`를 만든다 |
| `.PHONY: clean` | `clean`이 파일 이름이 아닌 동작임을 알린다 |

**B. 빌드**

1. (SUBTASK 5-B-01) `make` 실행 → 결과:

```text
gcc -Wall -O2 -c main.c -o main.o
gcc -Wall -O2 -c util.c -o util.o
gcc main.o util.o -o app
```

2. (SUBTASK 5-B-02) `./app` 실행 → 결과: `5`가 출력된다.
3. (SUBTASK 5-B-03) `make`를 다시 실행한다 → 결과: `make: 'app' is up to date.` 컴파일이 일어나지 않는다.
4. (SUBTASK 5-B-04) `touch util.h` 후 `make`를 실행한다 → 결과: `main.o`, `util.o`가 다시 컴파일되고 링크된다. 패턴 규칙의 선행 조건에 `util.h`를 넣었기 때문이다.

**C. 정리와 변수 덮어쓰기**

1. (SUBTASK 5-C-01) `make clean` 실행 → 결과: `rm -f main.o util.o app`
2. (SUBTASK 5-C-02) `make -n` 실행 → 결과: 명령을 실행하지 않고 출력만 한다.
3. (SUBTASK 5-C-03) `make CFLAGS="-O0" -B` 실행 → 결과: 모든 목표를 강제로 다시 만들며 `gcc -O0 -c ...`로 컴파일된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `./app` | 5 출력 | 출력이 `5` |
| 2 | 변경 없이 `make` | 재빌드 없음 | `up to date` |
| 3 | `make clean` 후 `ls` | `.o`와 `app`이 없다 | 목록에 없다 |

## 7. 복구

1. (7-01) `make clean`으로 산출물을 지운다. 소스와 Makefile은 지워지지 않는다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 신규 작성 (생성형 AI 초안) |
