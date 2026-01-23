# gdb

{% stepper %}
{% step %}
### 설치

```bash
dnf install -y gdb
```
{% endstep %}

{% step %}
### 디버깅 실행

```bash
gdb SBOF
```

출력 예시:

```
############################
GNU gdb (GDB) Rocky Linux 10.2-13.el9
Copyright (C) 2021 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "x86_64-redhat-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<https://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from sbop...
(No debugging symbols found in sbop)
##############################
(gdb)
```
{% endstep %}
{% endstepper %}

### 함수 디버깅

gdb에서 함수의 어셈블리 코드를 확인하려면 `disas <함수이름>` (예: `disas main`)을 사용합니다.

Dump of assembler code for function main:

```asm
   0x0000000000401136 <+0>:     push   %rbp
   0x0000000000401137 <+1>:     mov    %rsp,%rbp
   0x000000000040113a <+4>:     sub    $0x110,%rsp
   0x0000000000401141 <+11>:    mov    %edi,-0x104(%rbp)
   0x0000000000401147 <+17>:    mov    %rsi,-0x110(%rbp)
   0x000000000040114e <+24>:    movq   $0x0,-0x100(%rbp)
   0x0000000000401159 <+35>:    movq   $0x0,-0xf8(%rbp)
   0x0000000000401164 <+46>:    movq   $0x0,-0xf0(%rbp)
   0x000000000040116f <+57>:    movq   $0x0,-0xe8(%rbp)
   0x000000000040117a <+68>:    movq   $0x0,-0xe0(%rbp)
   0x0000000000401185 <+79>:    movq   $0x0,-0xd8(%rbp)
   0x0000000000401190 <+90>:    movq   $0x0,-0xd0(%rbp)
   0x000000000040119b <+101>:   movq   $0x0,-0xc8(%rbp)
   0x00000000004011a6 <+112>:   movq   $0x0,-0xc0(%rbp)
   0x00000000004011b1 <+123>:   movq   $0x0,-0xb8(%rbp)
   0x00000000004011bc <+134>:   movq   $0x0,-0xb0(%rbp)
   0x00000000004011c7 <+145>:   movq   $0x0,-0xa8(%rbp)
   0x00000000004011d2 <+156>:   movq   $0x0,-0xa0(%rbp)
   0x00000000004011dd <+167>:   movq   $0x0,-0x98(%rbp)
   0x00000000004011e8 <+178>:   movq   $0x0,-0x90(%rbp)
   0x00000000004011f3 <+189>:   movq   $0x0,-0x88(%rbp)
   0x00000000004011fe <+200>:   movq   $0x0,-0x80(%rbp)
   0x0000000000401206 <+208>:   movq   $0x0,-0x78(%rbp)
   0x000000000040120e <+216>:   movq   $0x0,-0x70(%rbp)
   0x0000000000401216 <+224>:   movq   $0x0,-0x68(%rbp)
   0x000000000040121e <+232>:   movq   $0x0,-0x60(%rbp)
   0x0000000000401226 <+240>:   movq   $0x0,-0x58(%rbp)
   0x000000000040122e <+248>:   movq   $0x0,-0x50(%rbp)
   0x0000000000401236 <+256>:   movq   $0x0,-0x48(%rbp)
   0x000000000040123e <+264>:   movq   $0x0,-0x40(%rbp)
   0x0000000000401246 <+272>:   movq   $0x0,-0x38(%rbp)
   0x000000000040124e <+280>:   movq   $0x0,-0x30(%rbp)
   0x0000000000401256 <+288>:   movq   $0x0,-0x28(%rbp)
   0x000000000040125e <+296>:   movq   $0x0,-0x20(%rbp)
   0x0000000000401266 <+304>:   movq   $0x0,-0x18(%rbp)
   0x000000000040126e <+312>:   movq   $0x0,-0x10(%rbp)
   0x0000000000401276 <+320>:   movq   $0x0,-0x8(%rbp)
   0x000000000040127e <+328>:   mov    $0x402010,%edi
   0x0000000000401283 <+333>:   mov    $0x0,%eax
   0x0000000000401288 <+338>:   call   0x401030 <printf@plt> # 함수를 호출하는 명령어를 저장한 메모리 주소
   0x000000000040128d <+343>:   lea    -0x100(%rbp),%rax # 함수 존재
   0x0000000000401294 <+350>:   mov    %rax,%rdi
   0x0000000000401297 <+353>:   mov    $0x0,%eax
   0x000000000040129c <+358>:   call   0x401040 <gets@plt> # 함수 호출 명령어
   0x00000000004012a1 <+363>:   mov    $0x0,%eax
   0x00000000004012a6 <+368>:   leave
   0x00000000004012a7 <+369>:   ret
End of assembler dump.
```

{% hint style="info" %}
* 어셈블리 언어를 알아야 해석할 수 있습니다.
* 메모리 주소를 호출해서 디버깅 가능합니다.
{% endhint %}

gdb에서 특정 메모리 주소의 문자열을 확인하는 예:

```gdb
(gdb) x/s 0x401288 # printf함수를 call하는 메모리
0x401288 <main+338>:    "\350\243\375\377\377H\215\205"
```

{% hint style="warning" %}
gdb에서 나가려면 q를 입력하세요.
{% endhint %}
