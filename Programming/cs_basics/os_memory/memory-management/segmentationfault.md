# 세그멘테이션 결함 상세 (Segfault)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-MEM-004-TS |
| 유형 | TS (문제 해결) |
| 목적 | 세그멘테이션 결함(SIGSEGV)의 원인을 분류하고 원인별로 격리·시정한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 C/운영체제 지식을 정리한 것이며 예제를 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본은 위키백과 문서 번역이었다. 정정 요지: (1) 예제 `const char *s`는 현대 컴파일러에서 컴파일 오류이므로 런타임 오류 예제는 `char *s`로 고쳤다. (2) 오탈자("오류이")와 빈 소제목을 정리했다. (3) 오래된 OpenBSD 4.0 GDB 출력의 줄 번호가 코드와 맞지 않아 제거했다. 원인 표와 격리 절차는 새로 추가했다.
{% endhint %}

## 1. 증상

* Linux/macOS에서 프로그램이 `Segmentation fault`를 출력하고 종료한다. 종료 신호는 `SIGSEGV`(11)다.
* Windows에서는 접근 위반(access violation, 예외 코드 `0xC0000005`)으로 표시된다.
* 읽기 전용 영역에 쓰기를 시도하거나 매핑되지 않은 주소에 접근할 때 발생한다.

## 2. 가능 원인

| 번호 | 원인 | 예 | 시정 |
|---|---|---|---|
| 1 | 널 포인터 역참조 | `int *p = NULL; *p = 1;` | 사용 전 `NULL` 검사 |
| 2 | 읽기 전용 영역에 쓰기 | `char *s = "hi"; s[0] = 'H';` | 쓸 문자열은 배열 `char s[] = "hi";`로 선언 |
| 3 | 해제 후 사용(use-after-free) | `free(p); *p = 1;` | 해제 직후 `p = NULL;` |
| 4 | 배열 경계 초과 | `a[10]`에 접근하는데 크기가 10 | 인덱스 범위 검사 |
| 5 | 스택 오버플로 | 종료 조건 없는 재귀 | 재귀 깊이 제한 또는 반복문으로 변경 |
| 6 | 초기화하지 않은 포인터 사용 | `int *p; *p = 1;` | 선언 시 `NULL` 또는 유효 주소로 초기화 |

{% hint style="info" %}
NOTE: 위 동작은 모두 C 표준에서 정의되지 않은 동작(UB)이다. 항상 세그멘테이션 결함이 나는 것은 아니다. 조용히 잘못된 값을 쓰는 경우도 있으므로 결함이 없다고 안전한 것이 아니다.
{% endhint %}

## 3. 격리 절차

1. 디버그 정보를 넣어 컴파일한다: `gcc -g -O0 -o segfault segfault.c` → 결과: `segfault` 실행 파일이 생긴다.
2. 디버거로 실행한다: `gdb ./segfault`, 프롬프트에서 `run` → 결과: `Program received signal SIGSEGV, Segmentation fault.`와 함께 오류가 난 소스 줄이 표시된다.
3. 호출 경로를 확인한다: `bt` → 결과: 호출 스택이 출력된다.
4. 문제 줄의 포인터 값을 확인한다: `print <변수명>` → 결과: `0x0`이면 원인 1, 해제된 변수면 원인 3이다.
5. 원인이 불분명하면 AddressSanitizer로 다시 컴파일한다: `gcc -g -fsanitize=address -o segfault segfault.c` → 결과: 실행 시 오류 종류(heap-use-after-free 등)와 줄 번호가 출력된다.

## 4. 예제

### 4.1 읽기 전용 영역에 쓰기

{% code title="segfault.c" %}
```c
#include <stdio.h>

int main(void) {
    char *s = "hello world";   // 문자열 리터럴은 읽기 전용 데이터 구획에 놓인다
    *s = 'H';                  // 읽기 전용 영역에 쓰기: 정의되지 않은 동작, 보통 SIGSEGV
    printf("%s\n", s);
    return 0;
}
```
{% endcode %}

프로그램이 로드될 때 운영체제는 문자열 상수를 읽기 전용 구획에 둔다. `s`는 그 위치를 가리키고, `*s = 'H'`는 읽기 전용 영역에 쓰려는 시도이므로 운영체제가 `SIGSEGV`를 보낸다.

{% code title="터미널" %}
```bash
$ gcc segfault.c -g -o segfault
$ ./segfault
Segmentation fault
```
{% endcode %}

원본의 `const char *s` 버전은 컴파일 단계에서 막힌다.

{% code title="컴파일 오류 (GCC, 원본 예시)" %}
```bash
$ gcc segfault.c -g -o segfault
segfault.c: In function 'main':
segfault.c:4: error: assignment of read-only location
```
{% endcode %}

세그멘테이션 결함이 발생하는 조건과 알려 주는 방식은 운영체제와 컴파일러에 따라 다르다. 현대 컴파일러는 `const` 위반을 오류 또는 경고로 알려 준다. 컴파일러가 못 찾는 경우가 런타임 결함이다.

### 4.2 널 포인터 역참조

대부분의 운영체제는 주소 0 근처의 첫 페이지를 접근 불가로 둔다. 널 포인터를 통한 읽기·쓰기는 흔한 오류이기 때문이다.

{% code title="널 포인터 예제" %}
```c
int main(void) {
    int *ptr = (int *)0x00000000;
    *ptr = 1;   // 주소 0에 쓰기: 정의되지 않은 동작, 보통 SIGSEGV
    return 0;
}
```
{% endcode %}

## 5. 원인 메커니즘

1. CPU가 가상 주소에 접근한다.
2. 메모리 관리 장치(MMU)가 페이지 테이블로 주소를 변환한다.
3. 매핑이 없거나 권한이 없으면 CPU가 페이지 폴트(page fault) 예외를 낸다.
4. 커널이 이 접근이 유효하지 않다고 판단하면 프로세스에 `SIGSEGV`를 보낸다. 유효한 경우(예: 아직 올리지 않은 페이지)에는 페이지를 올리고 재실행한다.

관련 내용은 [가상 메모리와 페이징](virtualmemory.md)을 본다.

## 6. 비교 (C#)

C#의 관리 코드에서 `null`을 역참조하면 `NullReferenceException`이 발생한다. 런타임이 예외로 잡아 주므로 프로세스가 즉시 종료되지는 않는다. C/C++은 이 검사가 없어 운영체제가 결함으로 종료시킨다.

## 7. 약어·용어

| 용어 | 뜻 |
|---|---|
| SIGSEGV | 잘못된 메모리 참조를 알리는 유닉스 신호 (11번) |
| 페이지 폴트 | 변환할 수 없거나 권한이 없는 접근 시 CPU가 내는 예외 |
| MMU | Memory Management Unit. 가상 주소를 물리 주소로 변환하는 하드웨어 |
| UB | Undefined Behavior. 표준이 결과를 정하지 않은 동작 |

## 8. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [memorylayout.md](memorylayout.md) | PRG-MEM-002-DO | 메모리 레이아웃 (Layout) |
| [memorysegment.md](memorysegment.md) | PRG-MEM-003-DO | 메모리 세그먼트 (Segment) |
| [virtualmemory.md](virtualmemory.md) | PRG-MEM-008-DO | 가상 메모리와 페이징 |

* [위키백과: 세그멘테이션 오류](https://ko.wikipedia.org/wiki/%EC%84%B8%EA%B7%B8%EB%A9%98%ED%85%8C%EC%9D%B4%EC%85%98_%EC%98%A4%EB%A5%98)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 세그멘테이션 결함을 직접 겪었다면 어떤 코드였고 어떻게 찾았는지 적어 본다.
- [ ] 문자열 리터럴에 쓰면 왜 실패하는지 메모리 레이아웃과 연결해 적어 본다.
- [ ] C#에서 같은 실수가 다르게 나타나는 이유를 적어 본다.
