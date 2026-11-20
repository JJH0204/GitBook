# [생성형 AI] 메모리 오류 찾기 (AddressSanitizer)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-CMP-008-MP |
| 목적 | gcc의 `-fsanitize` 옵션으로 힙 버퍼 오버플로, 해제 후 사용, 메모리 누수, 정수 오버플로를 실행 중에 잡는다 |
| 적용 대상 | Linux x86-64, gcc 15.2에서 확인(하위 버전 미확인) (macOS는 clang에서 같은 옵션이 동작하나 실행하지 않았다) |
| 소요 시간 | 약 15분 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (gcc 15.2.0, Linux, 2026-11-19. 아래 네 예제를 컴파일·실행해 보고서 첫 줄을 확인했다. Windows MinGW는 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [gcc-build-stages.md](gcc-build-stages.md) | DEV-CMP-006-DO | [생성형 AI] gcc 빌드 4단계와 자주 쓰는 옵션 |
| [debugger.md](debugger.md) | DEV-CMP-002-DO | 디버거 개요 (Debugger) |
| [gdb.md](gdb.md) | DEV-CMP-003-MP | GDB 디버거 사용법 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | gcc | `libasan`, `libubsan` 포함 | 없으면 링크 오류가 난다. 배포판 패키지에서 설치한다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 아래 예제는 일부러 잘못된 코드다. 연습용 빈 폴더에서만 실행한다. sanitizer를 켠 빌드는 느리고 메모리를 더 쓰므로 배포 빌드에 쓰지 않는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | gcc를 쓸 수 있다 | `gcc --version` |
| 2 | `-g`(디버그 정보)를 함께 쓴다 | 보고서에 소스 줄 번호가 나오게 한다 |

## 5. 절차

**A. 힙 버퍼 오버플로**

1. (SUBTASK 5-A-01) `bad.c`를 만든다. → 결과: 파일이 있다.

```c
#include <stdlib.h>
int main(void) {
    int *p = malloc(4 * sizeof(int));
    p[4] = 1;
    free(p);
    return 0;
}
```

2. (SUBTASK 5-A-02) 컴파일한다: `gcc -g -fsanitize=address bad.c -o bad` → 결과: 오류 없이 `bad`가 생긴다. 이 코드는 일반 컴파일에서 경고도 없다.
3. (SUBTASK 5-A-03) 실행한다: `./bad` → 결과: `ERROR: AddressSanitizer: heap-buffer-overflow`, `WRITE of size 4`, `#0 ... in main .../bad.c:4`가 출력된다. 4번째 줄이 문제 위치이고, 보고서 아래쪽 `allocated by thread T0 here:`가 `malloc`한 줄(`bad.c:3`)을 알려 준다. 요소 4개짜리 배열의 `p[4]`는 범위 밖이다.

**B. 해제 후 사용**

1. (SUBTASK 5-B-01) `uaf.c`를 만든다. → 결과: 파일이 있다.

```c
#include <stdlib.h>
int main(void){ int *p=malloc(4); free(p); return *p; }
```

2. (SUBTASK 5-B-02) `gcc -g -fsanitize=address uaf.c -o uaf` 후 `./uaf`를 실행한다. → 결과: `ERROR: AddressSanitizer: heap-use-after-free`, `READ of size 4`, `#0 ... in main .../uaf.c:2`

**C. 메모리 누수**

1. (SUBTASK 5-C-01) `leak.c`를 만든다. → 결과: 파일이 있다.

```c
#include <stdlib.h>
int main(void) { void *p = malloc(16); p = 0; return 0; }
```

2. (SUBTASK 5-C-02) `gcc -g -fsanitize=address leak.c -o leak` 후 `./leak`를 실행한다. → 결과: 종료 시점에 `ERROR: LeakSanitizer: detected memory leaks`, `Direct leak of 16 byte(s) in 1 object(s)`, 마지막 줄 `SUMMARY: AddressSanitizer: 16 byte(s) leaked in 1 allocation(s).`

**D. 정수 오버플로 (UndefinedBehaviorSanitizer)**

1. (SUBTASK 5-D-01) `ub.c`를 만든다. → 결과: 파일이 있다.

```c
#include <limits.h>
#include <stdio.h>
int main(void) { int x = INT_MAX; x = x + 1; printf("%d\n", x); return 0; }
```

2. (SUBTASK 5-D-02) `gcc -g -fsanitize=undefined ub.c -o ub` 후 `./ub`를 실행한다. → 결과: `ub.c:3:37: runtime error: signed integer overflow: 2147483647 + 1 cannot be represented in type 'int'`가 나오고 프로그램은 `-2147483648`을 출력한 뒤 종료 코드 0으로 끝난다. 부호 있는 정수 오버플로는 C에서 정의되지 않은 동작이며, UBSan은 기본으로 진단만 하고 멈추지 않는다.

| 옵션 | 잡는 것 |
|---|---|
| `-fsanitize=address` | 힙·스택·전역 버퍼 오버플로, 해제 후 사용, 누수(Linux 기본) |
| `-fsanitize=undefined` | 부호 있는 정수 오버플로, 널 포인터 접근 등 정의되지 않은 동작 |

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `./bad` | 보고서가 나온다 | 첫 오류 줄에 `heap-buffer-overflow` |
| 2 | 보고서의 첫 `#0` 줄 | 소스 파일과 줄 번호 | `bad.c:4` |
| 3 | 오류를 고친 코드(`p[3]`)로 다시 실행 | 보고서가 없다 | 출력 없이 종료 코드 0 |

## 7. 복구

1. (7-01) 연습 파일을 지운다: `rm -f bad uaf leak ub bad.c uaf.c leak.c ub.c` → 결과: 폴더가 비워진다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 신규 작성 (생성형 AI 초안) |
