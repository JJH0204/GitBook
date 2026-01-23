# Compile

* C 로 작성된 소스 코드를 어셈블리어로 번역
* 이 과정에서 컴파일러는 소스 코드의 문법을 검사
* 문법적 오류가 있다면 컴파일을 멈추고 에러를 출력
* 몇몇 조건을 만족하면 최적화 기술을 적용해 효율적인 어셈블리 코드를 생성한다. gcc 에서는 `-O -O0 -O1 -O2 -O3 -Os -Ofast -Og` 등의 옵션을 사용하여 최적화를 적용 할 수 있다.
* 컴파일 예시

```c
// Name: opt.c
// Compile: gcc -o opt opt.c -O2

#include <stdio.h>

int main() {
  int x = 0;
  for (int i = 0; i < 100; i++) x += i; // x에 0부터 99까지의 값 더하기
  printf("%d", x);
}
```

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

> 반복문을 어셈블리어로 옮기지 않고 반복문의 결과로 x가 가질 값을 직접 계산하여 대입하는 코드를 생성한다.

* 아래와 같이 `-S` 옵션을 이용하면 소스 코드를 어셈블리 코드로 컴파일할 수 있다.

```sh
$ gcc -S add.i -o add.S
$ cat add.S
```

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
