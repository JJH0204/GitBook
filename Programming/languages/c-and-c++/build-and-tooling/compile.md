# 컴파일 과정 (Compile)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-BLD-002-DO |
| 유형 | D&O (원리) + 옵션 표 |
| 목적 | 컴파일 단계의 역할, gcc 최적화 옵션, 어셈블리 출력 방법을 설명한다 |
| 확인 상태 | 미검증 (원본 출력을 읽고 정리했으며 이 환경에서 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

컴파일은 전처리된 C 소스 코드를 어셈블리어로 번역하는 단계다. 이 과정에서 컴파일러는 소스 코드의 문법을 검사한다. 문법 오류가 있으면 컴파일을 멈추고 에러를 출력한다.

## 2. 구성 요소

### 2-1. gcc 빌드 단계와 옵션

| 단계 | 입력 → 출력 | gcc 옵션 | 문서 |
|---|---|---|---|
| 전처리 | `.c` → `.i` | `-E` | [PRG-BLD-001-DO](preprocessing.md) |
| 컴파일 | `.i` → `.s` | `-S` | 이 문서 |
| 어셈블 | `.s` → `.o` | `-c` | |
| 링크 | `.o` 여러 개 → 실행 파일 | (옵션 없음) | [PRG-BLD-003-TS](cmodularizationerror.md) |

### 2-2. 최적화 옵션

몇몇 조건을 만족하면 컴파일러는 최적화 기술을 적용해 효율적인 어셈블리 코드를 생성한다. gcc에서는 다음 옵션으로 최적화를 적용한다.

| 옵션 | 설명 |
|---|---|
| `-O0` | 최적화하지 않는다 |
| `-O`, `-O1` | 기본 최적화. `-O`는 `-O1`과 같다 |
| `-O2` | `-O1`보다 많은 최적화를 한다 |
| `-O3` | `-O2`보다 많은 최적화를 한다 |
| `-Os` | 코드 크기를 줄이는 쪽으로 최적화한다 |
| `-Ofast` | `-O3`에 표준을 엄격히 따르지 않는 최적화(예: 빠른 부동소수점 연산)를 더한다 |
| `-Og` | 디버깅 경험을 해치지 않는 범위의 최적화다 |

## 3. 동작 원리

### 3-1. 최적화 예

{% code title="opt.c" %}
```c
// Name: opt.c
// Compile: gcc -o opt opt.c -O2

#include <stdio.h>

int main(void) {
  int x = 0;
  for (int i = 0; i < 100; i++) x += i; // x에 0부터 99까지의 값 더하기
  printf("%d", x);
  return 0;
}
```
{% endcode %}

위 코드를 `-O2`로 컴파일한 `main` 함수의 어셈블리는 다음과 같다(디스어셈블러 출력, 환경 미기재).

```
0x0000000000000560 <+0>:     lea    rsi,[rip+0x1bd]        ; 0x724
0x0000000000000567 <+7>:     sub    rsp,0x8
0x000000000000056b <+11>:    mov    edx,0x1356  ; hex((0+99)*50) = '0x1356' = sum(0,1,...,99) 
0x0000000000000570 <+16>:    mov    edi,0x1
0x0000000000000575 <+21>:    xor    eax,eax
0x0000000000000577 <+23>:    call   0x540 <__printf_chk@plt>
0x000000000000057c <+28>:    xor    eax,eax
0x000000000000057e <+30>:    add    rsp,0x8
0x0000000000000582 <+34>:    ret
```

반복문을 어셈블리로 옮기지 않고 결과 값(`0x1356` = 4950)을 컴파일러가 직접 계산해 `edx`에 대입한다.

### 3-2. 어셈블리 코드 출력

`-S` 옵션은 소스 코드를 어셈블리 코드로 컴파일하고 멈춘다.

```sh
$ gcc -S add.i -o add.s
$ cat add.s
```

{% hint style="info" %}
NOTE: 원본은 출력 파일 이름을 `add.S`(대문자)로 썼다. gcc는 대문자 `.S`를 전처리가 필요한 어셈블리 입력으로 취급하므로 출력 이름은 소문자 `.s`로 정정했다.
{% endhint %}

출력 예는 다음과 같다. Intel 문법(`.intel_syntax noprefix`)으로 출력되어 있다. x86에서 gcc는 `-masm=intel` 옵션으로 이 문법을 선택한다(확인 필요).

```
        .file   "add.c"
        .intel_syntax noprefix
        .text
        .globl  add
        .type   add, @function
add:
.LFB0:
        .cfi_startproc
        push    rbp
        .cfi_def_cfa_offset 16
        .cfi_offset 6, -16
        mov     rbp, rsp
        .cfi_def_cfa_register 6
        mov     DWORD PTR -4[rbp], edi
        mov     DWORD PTR -8[rbp], esi
        mov     edx, DWORD PTR -4[rbp]
        mov     eax, DWORD PTR -8[rbp]
        add     eax, edx
        add     eax, 3
        pop     rbp
        .cfi_def_cfa 7, 8
        ret
        .cfi_endproc
.LFE0:
        .size   add, .-add
        .ident  "GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0"
        .section        .note.GNU-stack,"",@progbits
```

| 줄 | 설명 |
|---|---|
| `mov DWORD PTR -4[rbp], edi` | 첫 인자 `a`를 스택에 저장한다 |
| `mov DWORD PTR -8[rbp], esi` | 둘째 인자 `b`를 스택에 저장한다 |
| `add eax, edx` | `a + b`를 계산한다 |
| `add eax, 3` | `+ 3`을 더한다. 반환값은 `eax`에 둔다 |
| `.ident "GCC: ... 7.5.0"` | 어셈블리를 만든 컴파일러 버전이다 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `-O0`과 `-O2`로 같은 코드를 컴파일하면 어떤 차이를 보게 될 것이라 예상하는가?
- [ ] 컴파일 단계와 링크 단계에서 각각 발견되는 오류의 예를 하나씩 들어 보자.
