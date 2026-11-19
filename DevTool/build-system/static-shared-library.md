# [생성형 AI] 정적 라이브러리와 공유 라이브러리 만들기

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-BLD-008-MP |
| 목적 | C 코드를 정적 라이브러리(`.a`)와 공유 라이브러리(`.so`)로 만들어 링크하고 차이를 확인한다 |
| 적용 대상 | Linux, gcc, `ar`, `ldd`, `readelf` (macOS는 확장자 `.dylib`, Windows는 `.dll`이며 명령이 다르다) |
| 소요 시간 | 약 15분 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증됨 (gcc 15.2.0, Linux, 2026-11-19. 아래 명령을 모두 실행했다. macOS·Windows는 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [gcc-build-stages.md](../compiler-debug/gcc-build-stages.md) | DEV-CMP-006-DO | [생성형 AI] gcc 빌드 4단계와 자주 쓰는 옵션 |
| [build-error-diagnosis.md](../compiler-debug/build-error-diagnosis.md) | DEV-CMP-007-TS | [생성형 AI] 컴파일·링크 오류 진단 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | gcc, binutils(`ar`, `nm`, `readelf`) | Linux | `gcc --version` |
| 2 | `ldd` | glibc 제공 | 실행 파일이 찾는 공유 라이브러리를 보여 준다 |

## 3. 안전 사항

{% hint style="info" %}
NOTE: 연습은 빈 폴더에서 한다. 아래에서 만드는 파일은 `add.c`, `add.h`, `main.c`, `libadd.a`, `libadd.so`와 실행 파일이다.
{% endhint %}

## 4. 준비

작업 폴더에 세 파일을 만든다.

`add.c`

```c
int add(int a, int b) { return a + b; }
```

`add.h`

```c
#ifndef ADD_H
#define ADD_H
int add(int a, int b);
#endif
```

`main.c`

```c
#include <stdio.h>
#include "add.h"
int main(void) { printf("%d\n", add(2, 3)); return 0; }
```

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 세 파일이 있다 | `ls`에 `add.c add.h main.c`가 보인다 |

## 5. 절차

**A. 정적 라이브러리**

1. (SUBTASK 5-A-01) 오브젝트 파일을 만든다: `gcc -c add.c -o add.o` → 결과: `add.o`가 생긴다.
2. (SUBTASK 5-A-02) 묶는다: `ar rcs libadd.a add.o` → 결과: `libadd.a`가 생긴다.
3. (SUBTASK 5-A-03) 내용을 확인한다: `ar t libadd.a` → 결과: `add.o`
4. (SUBTASK 5-A-04) 링크한다: `gcc main.c -L. -ladd -o app_static` → 결과: `app_static`이 생긴다. `-L.`은 현재 폴더에서 라이브러리를 찾으라는 뜻이고, `-ladd`는 `libadd`를 뜻한다.
5. (SUBTASK 5-A-05) 실행한다: `./app_static` → 결과: `5`

**B. 공유 라이브러리**

1. (SUBTASK 5-B-01) 공유 라이브러리를 만든다: `gcc -fPIC -shared add.c -o libadd.so` → 결과: `libadd.so`가 생긴다. `-fPIC`는 위치와 무관한 코드로 컴파일하라는 옵션이다.
2. (SUBTASK 5-B-02) 링크 대상을 공유 쪽으로 두려면 `libadd.a`를 다른 이름으로 옮긴다: `mv libadd.a libadd.a.bak` → 결과: 폴더에 `libadd.so`만 남는다.
3. (SUBTASK 5-B-03) 링크한다: `gcc main.c -L. -ladd -o app_shared` → 결과: 오류 없이 `app_shared`가 생긴다.
4. (SUBTASK 5-B-04) 그냥 실행한다: `./app_shared` → 결과: `error while loading shared libraries: libadd.so: cannot open shared object file: No such file or directory`, 종료 코드 127. 링크 시점의 `-L.`은 실행 시점에 쓰이지 않는다.
5. (SUBTASK 5-B-05) 찾는 위치를 환경 변수로 준다: `LD_LIBRARY_PATH=. ./app_shared` → 결과: `5`
6. (SUBTASK 5-B-06) 의존 목록을 본다: `ldd app_shared` → 결과: `libadd.so => not found`가 보인다(5-B-05의 환경 변수는 그 명령에만 적용됐다).

**C. 실행 파일에 탐색 경로 넣기**

1. (SUBTASK 5-C-01) 실행 파일 위치 기준 경로를 넣어 링크한다: `gcc main.c -L. -Wl,-rpath,'$ORIGIN' -ladd -o app_rpath` → 결과: `app_rpath`가 생긴다. `$ORIGIN`은 실행 파일이 있는 폴더이며 셸이 해석하지 않도록 작은따옴표로 감싼다.
2. (SUBTASK 5-C-02) 실행한다: `./app_rpath` → 결과: 환경 변수 없이 `5`
3. (SUBTASK 5-C-03) 기록을 확인한다: `readelf -d app_rpath | grep -E "NEEDED|RUNPATH"` → 결과: `Shared library: [libadd.so]`와 `Library runpath: [$ORIGIN]`가 나온다.

**D. 둘 다 있을 때의 선택**

1. (SUBTASK 5-D-01) 이름을 되돌린다: `mv libadd.a.bak libadd.a` → 결과: 폴더에 `.a`와 `.so`가 모두 있다.
2. (SUBTASK 5-D-02) `-ladd`로 링크한다: `gcc main.c -L. -ladd -o app_both` 후 `ldd app_both | grep add` → 결과: `libadd.so => not found`. 같은 폴더에 둘 다 있으면 링커가 `.so`를 먼저 고른다.
3. (SUBTASK 5-D-03) 정적을 강제한다: `gcc main.c -L. -l:libadd.a -o app_s2` 후 `ldd app_s2 | grep -c add` → 결과: `0`. 이 실행 파일은 `libadd`에 의존하지 않는다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `./app_static` | `5` | 출력이 `5`다 |
| 2 | `./app_rpath` | `5` | 환경 변수 없이 실행된다 |
| 3 | 정적과 공유의 차이 | 정적은 `ldd`에 `libadd`가 없고, 공유는 있다 | 5-D-02, 5-D-03 결과와 같다 |

| 구분 | 정적 (`.a`) | 공유 (`.so`) |
|---|---|---|
| 링크 시점 | 실행 파일에 복사된다 | 실행 시 로드한다 |
| 라이브러리 파일이 실행 때 필요한가 | 아니오 | 예 |
| 라이브러리 수정 후 | 다시 링크해야 반영된다 | 파일만 교체하면 반영된다 |
| 여러 프로그램이 공유 | 각자 복사본 | 한 파일을 함께 쓴다 |

## 7. 복구

1. (7-01) 연습 파일을 지운다: `rm -f add.o libadd.a libadd.a.bak libadd.so app_static app_shared app_rpath app_both app_s2` → 결과: 소스 3개만 남는다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 신규 작성 (생성형 AI 초안) |
