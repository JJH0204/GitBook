# BOF

* buffer: 데이터 입출력을 위해 사용되는 임시 저장소, 시스템 마다 크기는 다름
* 악의 적으로 shell 코드를 삽입 → buffer를 초과하는 데이터를 입력 → 다른 메모리를 침범(override)하며 shell code를 실행하도록 만듬(악성 코드)
* stack overflow, heap overflow

## 메모리 형태

***

https://st-lab.tistory.com/198

* kernel memory: 운영체제
* stack memory: 지역, 매개 변수 / 함수
* 라이브러리 memory
* heap memory: 동적 변수
* data memory: 전역, 정적 변수
* code memory: 기계어/어셈블리어

## Stack Buffer Overflow

***

### \[원리]

* 지정된 버퍼 사이즈를 넘기는 큰 크기의 데이터를 강제로 입력하여 다른 메모리 영역을 침범하는 공격 방식
* RET / EBP / Buffer\[8] > 임의의코드 / tttt / aaaaaaaaaaaaaa
* RET(리턴 함수 주소) 대신 임의의 코드를 실행하게 되어 악영향을 주게됨

### \[원인]

* 문자열 처리 함수에서 입력값에 대한 길이 체크를 하지 않아 발생하는 취약점
  * strcpy strcat gets fscanf scanf sprintf sscanf vfscanf vsprintf vscanf vsscanf streadd strecpy strtrns 등 취약한 함수들

### \[방안]

* 안전한 함수를 사용
* 값을 입력 받을 때 길이를 검사
* ASLR (Address Space Layout Randomization)\
  : 메모리를 참조할 때마다 랜덤으로 주소를 할당해 BOF 공격을 힘들게 한다.
* Stack Guard\
  : Canary\
  : 메모리에 위/변조가 발생했는지 함께 식별할 수 있는 값을 저장해 확인하는 방법
* NX (No-eXecute) bit\
  : 스택/힙에서 스크립트(또는 명령어, 함수)를 실행하는 권한을 비활성화 하는 방법\
  : 우회 공격 기법 → RTL(Return To Library) / ROP(Return Oriented Programming)

### \[검사]

#### NX

```bash
dmesg | grep NX
[    0.000000] NX (Execute Disable) protection: active
[    0.262920] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    0.263003] input: Sleep Button as /devices/LNXSYSTM:00/LNXSLPBN:00/input/input1
[    1.447050] input: Video Bus as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A03:00/LNXVID/input5
```

* NX 동작 여부 확인

#### ASLR

```bash
cat /proc/sys/kernel/randomize_va_space
2
```

* ASLR 실행 여부 확인
  * 0 (비활성화)
  * 1 (stack 만)
  * 2 (stack, heap 모두 검사)

### 실습

{% stepper %}
{% step %}
### 실습 1

#### 취약한 C 예제 코드

```c
# SBOF.c
# include <stdio.h>
int main(int argc, char* argv[])
{
    char cBuf[0x100] = {0, };   # 버퍼 역할을 할 배열 할당(인덱스 값 8)
    printf("Input: ");
    gets(cBuf);                  # BOF Attack에 취약한 함수 사용

    return 0;
}
```

#### 빌드 명령어

```
gcc -o SBOF SBOF.c -z execstack -z morelro -fno-stack-protector -no-pie
```

* execstack: 스택에서 쉘 실행 권한 제공
* morelro: 방해 받지 않도록 설정
* -fno-stack-protector: stack 보호 기능 해제

#### 스택 보호 기능 비활성화

```
echo 0 > /proc/sys/kernel/randomize_va_space
```

#### 실행 결과 확인 (예시)

```
./SBOF
Input: 2222...2222
Segmentation fault (core dumped)
```

**디버깅 도구를 활용**

* gdb: ../dev\_tools/gdb.md
{% endstep %}

{% step %}

{% endstep %}

{% step %}
### 실습 2
{% endstep %}

{% step %}
#### 예제 코드
{% endstep %}

{% step %}
```c
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char* argv[])
{
    char secret[16] = "secret message";
    char barrier[4] = {};
    char name[8] = {};
    memset(barrier, 0, 4);
    printf("Your Name: ");
    read(0, name, 12);
    printf("Your Name is %s\n", name);
  
    return 0;
}
```
{% endstep %}

{% step %}
* 컴파일 후 실행 예시
{% endstep %}

{% step %}
```
./sbof1
qwerqwerqwerqwerqwer
Your Name: Your Name is qwerqwerqwersecret message
[root@Linux1 tmp]# qwerqwer
-bash: qwerqwer: command not found
```
{% endstep %}

{% step %}
* 설명
  1. 12 바이트만 읽고 뒤에 secret message가 출력된다.
  2. 12 바이트를 초과한 문자열은 bash 쉘로 넘어가 실행되었다.
* 이를 활용한 공격 방법
{% endstep %}

{% step %}
```
./sbof1
123456789012pwd
Your Name: Your Name is 123456789012secret message
[root@Linux1 tmp]# pwd
/tmp
```
{% endstep %}

{% step %}
1. 의도적으로 12바이트를 초과한 문자부터 실행할 명령어를 작성
2. 해당 명령어를 실행한 결과가 자동으로 출력되는 것을 알 수 있음
{% endstep %}

{% step %}
#### 어셈블리(예시 출력)
{% endstep %}

{% step %}
```
disas main
Dump of assembler code for function main:
   0x0000000000401146 <+0>:     push   %rbp
   0x0000000000401147 <+1>:     mov    %rsp,%rbp
   0x000000000040114a <+4>:     sub    $0x30,%rsp
   0x000000000040114e <+8>:     mov    %edi,-0x24(%rbp)
   0x0000000000401151 <+11>:    mov    %rsi,-0x30(%rbp)
   0x0000000000401155 <+15>:    movabs $0x6d20746572636573,%rax
   0x000000000040115f <+25>:    movabs $0x656761737365,%rdx
   0x0000000000401169 <+35>:    mov    %rax,-0x10(%rbp)
   0x000000000040116d <+39>:    mov    %rdx,-0x8(%rbp)
   0x0000000000401171 <+43>:    movl   $0x0,-0x14(%rbp)
   0x0000000000401178 <+50>:    movq   $0x0,-0x1c(%rbp)
   0x0000000000401180 <+58>:    lea    -0x14(%rbp),%rax
   0x0000000000401184 <+62>:    mov    $0x4,%edx
   0x0000000000401189 <+67>:    mov    $0x0,%esi
   0x000000000040118e <+72>:    mov    %rax,%rdi
   0x0000000000401191 <+75>:    call   0x401040 <memset@plt>
   0x0000000000401196 <+80>:    mov    $0x402010,%edi
   0x000000000040119b <+85>:    mov    $0x0,%eax
   0x00000000004011a0 <+90>:    call   0x401030 <printf@plt>
   0x00000000004011a5 <+95>:    lea    -0x1c(%rbp),%rax
   0x00000000004011a9 <+99>:    mov    $0xc,%edx
   0x00000000004011ae <+104>:   mov    %rax,%rsi
   0x00000000004011b1 <+107>:   mov    $0x0,%edi
   0x00000000004011b6 <+112>:   call   0x401050 <read@plt>
   0x00000000004011bb <+117>:   lea    -0x1c(%rbp),%rax
   0x00000000004011bf <+121>:   mov    %rax,%rsi
   0x00000000004011c2 <+124>:   mov    $0x40201c,%edi
   0x00000000004011c7 <+129>:   mov    $0x0,%eax
   0x00000000004011cc <+134>:   call   0x401030 <printf@plt>
   0x00000000004011d1 <+139>:   mov    $0x0,%eax
   0x00000000004011d6 <+144>:   leave
   0x00000000004011d7 <+145>:   ret
End of assembler dump.

x/s 0x401050
0x401050 <read@plt>:    "\377%\322/"
```
{% endstep %}

{% step %}
* 참고: %rsi 등으로 표기된 것은 레지스터입니다.
{% endstep %}
{% endstepper %}

#### 관련 자료

* Assembly Language: ../cs\_basics/Assembly%20Language.md
