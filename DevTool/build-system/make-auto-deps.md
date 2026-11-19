# [생성형 AI] Makefile 헤더 의존성 자동 추적

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-BLD-009-MP |
| 목적 | 헤더 파일을 고치면 그 헤더를 쓰는 `.c`만 다시 컴파일되게 Makefile을 만든다 |
| 적용 대상 | GNU Make 4 이상, gcc |
| 소요 시간 | 약 10분 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (GNU Make 4.4.1, gcc 15.2.0, Linux, 2026-11-19. 아래 명령을 모두 실행했다) |
| 개정 | R1 (2026-11-19) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [make-basics.md](make-basics.md) | DEV-BLD-007-MP | [생성형 AI] Makefile 작성과 make 사용 |
| [gcc-build-stages.md](../compiler-debug/gcc-build-stages.md) | DEV-CMP-006-DO | [생성형 AI] gcc 빌드 4단계와 자주 쓰는 옵션 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | GNU Make | 4 이상 | `make --version` |
| 2 | gcc | | `-MMD`, `-MP` 옵션 사용 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: Makefile의 명령 줄은 공백이 아닌 탭 문자로 시작해야 한다. 공백이면 `missing separator` 오류가 난다.
{% endhint %}

## 4. 준비

작업 폴더에 세 파일을 만든다.

`util.h`

```c
#define VALUE 1
```

`main.c`

```c
#include <stdio.h>
#include "util.h"
int main(void) { printf("%d\n", VALUE); return 0; }
```

`util.c`

```c
#include "util.h"
int util(void) { return VALUE; }
```

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 세 파일이 있다 | `ls` |

## 5. 절차

**A. Makefile 작성**

1. (SUBTASK 5-A-01) `Makefile`을 아래 내용으로 만든다(명령 줄 앞은 탭). → 결과: 파일이 생긴다.

```make
CC := gcc
CFLAGS := -Wall -Wextra -MMD -MP
OBJS := main.o util.o

app: $(OBJS)
	$(CC) $(OBJS) -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f app $(OBJS) $(OBJS:.o=.d)

-include $(OBJS:.o=.d)
.PHONY: clean
```

| 요소 | 역할 |
|---|---|
| `-MMD` | 컴파일할 때 `<이름>.d` 파일에 "이 `.o`는 이 `.c`와 이 헤더들에 의존한다"는 규칙을 쓴다. 시스템 헤더는 뺀다 |
| `-MP` | `.d`의 각 헤더에 빈 규칙을 더한다. 헤더를 지워도 `No rule to make target` 오류가 나지 않는다 |
| `-include $(OBJS:.o=.d)` | `.d` 파일을 읽는다. 파일이 아직 없어도(첫 빌드) 오류를 내지 않는다 |

**B. 확인**

1. (SUBTASK 5-B-01) 처음 빌드한다: `make` → 결과: `gcc ... -c main.c`, `gcc ... -c util.c`, `gcc main.o util.o -o app`가 차례로 출력된다.
2. (SUBTASK 5-B-02) 생성된 규칙을 본다: `cat main.d` → 결과: `main.o: main.c util.h`와 `util.h:`가 나온다.
3. (SUBTASK 5-B-03) 다시 실행한다: `make` → 결과: `make: 'app' is up to date.`
4. (SUBTASK 5-B-04) 헤더를 고친다: `sed -i 's/VALUE 1/VALUE 2/' util.h` (macOS는 `sed -i ''`) → 결과: 출력이 없다.
5. (SUBTASK 5-B-05) 빌드한다: `make` → 결과: `main.c`와 `util.c`가 모두 다시 컴파일된다. 둘 다 `util.h`를 포함한다.
6. (SUBTASK 5-B-06) 실행한다: `./app` → 결과: `2`
7. (SUBTASK 5-B-07) 다시 `make`를 실행한다. → 결과: `make: 'app' is up to date.`

**C. -MP의 효과**

1. (SUBTASK 5-C-01) `-MP` 없이 빌드하고 헤더를 지운다: `CFLAGS`에서 `-MP`를 빼고 `make clean`, `make`, `rm util.h`, `make` 순서로 실행한다. → 결과: `make: *** No rule to make target 'util.h', needed by 'main.o'.  Stop.`
2. (SUBTASK 5-C-02) `-MP`를 넣고 같은 순서로 실행한다(헤더는 먼저 복구한다). → 결과: make 오류 대신 컴파일러의 `compilation terminated.`가 나온다. 문제가 "규칙 없음"에서 "헤더 없음"으로 정확히 드러난다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 헤더 수정 후 `make` | 헤더를 포함한 `.c`가 다시 컴파일된다 | `-c` 컴파일 줄이 출력된다 |
| 2 | 수정 없이 `make` | 아무것도 하지 않는다 | `up to date` |

## 7. 복구

1. (7-01) 산출물을 지운다: `make clean` → 결과: `app`, `.o`, `.d` 파일이 지워진다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 신규 작성 (생성형 AI 초안) |
