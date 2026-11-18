# 어셈블리어 기초 (Assembly)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-ARC-004-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | 어셈블리어의 명령어 형식, Intel·AT&T 문법 차이, 함수 프롤로그·에필로그를 예제로 읽는다 |
| 확인 상태 | 미검증 (예제 출력은 원본 그대로이며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 정정한 곳은 해당 절에 "NOTE"로 표시했다. 원본의 레지스터 설명(범용, 인덱스, 포인터)은 [PRG-ARC-012-DO](x8664architecture.md)와 중복되어 그쪽으로 일원화했다. 확인이 더 필요한 항목은 응답의 확인 필요 목록에도 적었다.
{% endhint %}

## 1. 목적

어셈블리어는 기계어(0과 1)에 가까운 언어로, 임베디드 시스템과 커널 프로그래밍, 리버스 엔지니어링에서 쓴다. 이 문서는 명령어 형식과 두 가지 표기 문법, 그리고 C 코드가 어셈블리로 바뀐 예를 읽는 방법을 정리한다.

## 2. 구성 요소

### 2.1 명령어 형식

`연산코드(Opcode) 피연산자1(Operand1) 피연산자2(Operand2)`로 구성한다.

| 예 (Intel 문법) | 의미 |
|---|---|
| `add eax, ebx` | eax = eax + ebx (첫 피연산자가 목적지, 둘째가 출발지) |
| `sub eax, ebx` | eax = eax − ebx |
| `mov eax, 1` | eax = 1 |

Intel 문법의 `sub a, b`는 a = a − b다. 첫 피연산자가 목적지이고, AT&T 문법은 피연산자 순서가 반대다.

{% hint style="info" %}
NOTE: 원본의 "Add 1 2 -> 2 + 1"은 피연산자 번호와 순서가 모호해 위 표로 바꿨다. 원본의 "(1234 / %1%2%3%4)"는 의미를 알 수 없어 삭제하고 아래 표로 대체했다.
{% endhint %}

### 2.2 Intel 문법과 AT&T 문법

| 항목 | Intel 문법 | AT&T 문법 |
|---|---|---|
| 피연산자 순서 | 목적지, 출발지 | 출발지, 목적지 |
| 레지스터 표기 | `eax` | `%eax` |
| 상수 표기 | `1` | `$1` |
| 크기 표기 | `dword ptr [ebp-8]` | 명령어 접미사(`movl`) |
| 예: eax = ebx | `mov eax, ebx` | `movl %ebx, %eax` |
| 주 사용처 | Windows 도구, 디버거 | GNU 도구(gcc, gdb) 기본값 |

gcc는 기본으로 AT&T 문법을 출력한다. `gcc -S -masm=intel`로 Intel 문법을 출력할 수 있다.

### 2.3 레지스터

레지스터의 종류와 크기, 하위 레지스터 이름은 [PRG-ARC-012-DO](x8664architecture.md)에 있다. 아래 32비트 예제에 나오는 레지스터는 다음과 같다.

| 레지스터 | 예제에서의 역할 |
|---|---|
| eax | 연산 결과, 반환 값 |
| ebp | 스택 프레임 기준 포인터 |
| esp | 스택 꼭대기 포인터 |
| ebx, esi, edi | 호출 규약상 보존해야 하는 레지스터(함수가 저장·복원한다) |
| ecx | 반복 횟수(`rep stos`) |

## 3. 동작 원리

### 3.1 예제 C 코드

{% code title="addtest.c" %}
```c
#include <stdio.h>

int main(int argc, char* argv[])
{
    int a = 1;
    int b = 2;
    int c = a + b;

    printf("a: %d, b: %d, c: %d\n", a, b, c);

    return 0;
}
```
{% endcode %}

### 3.2 컴파일 및 실행 (터미널)

```bash
$ vi ./addtest.c
$ gcc -o addtest addtest.c
$ ./addtest
a: 1, b: 2, c: 3
```

{% hint style="info" %}
NOTE: 원본의 프롬프트(`[root@Linux1 tmp]#`)는 `$`로 바꿨다. 일반 사용자 권한으로 충분하다.
{% endhint %}

### 3.3 어셈블리 예제 (MSVC 32비트 디버그 빌드)

다음 목록은 Microsoft Visual C++로 32비트(IA-32) 디버그 빌드한 `main`의 디스어셈블리다(Intel 문법). 위 3.2의 gcc Linux 64비트 빌드와는 다른 환경이다.

{% hint style="warning" %}
CAUTION: 이 예제는 32비트 MSVC 출력이라 레지스터가 eax, ebp, esp이고 인자를 스택으로 넘긴다. 64비트 gcc가 출력하는 코드는 rbp, rsp를 쓰고 인자를 rdi, rsi 등으로 넘긴다. 원본의 C 소스는 `printf`에 인자 4개를 넘기지만 이 목록은 `push eax`와 형식 문자열 `push`만 보이므로 원본 목록이 중간을 생략했거나 다른 소스의 결과일 수 있다. 확인 필요.
{% endhint %}

{% code title="어셈블리 예제" %}
```assembly
push        ebp                         # 이전 ebp를 스택에 저장
mov         ebp,esp                     # 현재 esp를 ebp로 복사해 스택 프레임 기준점으로 삼는다
sub         esp,0E4h                    # 지역 변수 공간으로 0xE4(228) 바이트를 확보 (스택은 낮은 주소로 자란다)
push        ebx                         # 보존 레지스터 ebx 저장
push        esi                         # 보존 레지스터 esi 저장
push        edi                         # 보존 레지스터 edi 저장
lea         edi,[ebp+FFFFFF1Ch]         # edi = ebp - 0xE4 (확보한 공간의 시작)
mov         ecx,39h                     # 반복 횟수 0x39 (4바이트 x 57 = 228바이트)
mov         eax,0CCCCCCCCh              # 채울 값
rep stos    dword ptr es:[edi]          # 스택 프레임을 0xCCCCCCCC로 채움 (MSVC 디버그 빌드의 초기화)
mov         ecx,9AC003h                 # 디버그 빌드 보조 호출의 인자
call        009A1316                    # 함수 호출 (MSVC 디버그 빌드의 초기화 함수)
mov         dword ptr [ebp-8],1         # a = 1
mov         dword ptr [ebp-14h],2       # b = 2
mov         eax,dword ptr [ebp-8]       # eax = a
add         eax,dword ptr [ebp-14h]     # eax = a + b
mov         dword ptr [ebp-20h],eax     # c = eax
mov         eax,dword ptr [ebp-20h]     # eax = c (최적화하지 않은 빌드라 다시 읽는다)
push        eax
push        9A7D08h                     # 형식 문자열 주소
call        009A10CD                    # printf 호출
add         esp,8                       # 호출자가 인자 8바이트를 정리 (cdecl)
xor         eax,eax                     # 반환 값 0
pop         edi                         # 보존 레지스터 edi 복원
pop         esi                         # esi 복원
pop         ebx                         # ebx 복원
add         esp,0E4h                    # 지역 변수 공간 해제
cmp         ebp,esp                     # 스택 포인터 검증
call        009A123F                    # _RTC_CheckEsp 호출 (스택 검사)
mov         esp,ebp                     # 스택 프레임 해제
pop         ebp                         # 이전 ebp 복원
ret                                     # 호출자로 복귀
```
{% endcode %}

| 구간 | 이름 | 역할 |
|---|---|---|
| `push ebp` ~ `call 009A1316` | 프롤로그 | 프레임 설정, 지역 변수 공간 확보, 보존 레지스터 저장 |
| `rep stos` | 디버그 초기화 | 지역 변수 공간을 0xCCCCCCCC로 채워 초기화하지 않은 변수를 찾기 쉽게 한다 |
| `mov [ebp-8],1` ~ `call printf` | 본문 | 변수 대입, 덧셈, 출력 |
| `pop edi` ~ `ret` | 에필로그 | 보존 레지스터 복원, 프레임 해제, 복귀 |

{% hint style="info" %}
NOTE: 원본 주석 정정 내역. `pop edi # 결과값 pop`은 보존 레지스터 복원이다. `cmp ebp,esp` 뒤의 `call 009A123F # printf 함수 호출`은 스택 검사(_RTC_CheckEsp)이고 printf는 앞의 `call 009A10CD`다. `push esi/edi/ebx`의 주석 "주소/만드는/과정"은 의미 없는 조각이라 삭제했다. `call 009A1316`의 정확한 함수명은 확인 필요.
{% endhint %}

### 3.4 온라인 어셈블리 확인

* [Compiler Explorer](https://godbolt.org/): C 코드를 컴파일러·옵션별 어셈블리로 보여 주는 사이트

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| Opcode / Operand | 연산코드 / 피연산자 |
| 프롤로그 / 에필로그 | 함수 시작·끝의 프레임 설정·해제 코드 |
| cdecl | x86 32비트 C 호출 규약. 인자는 스택에 두고 호출자가 정리한다 |
| MSVC | Microsoft Visual C++ 컴파일러 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [x8664architecture.md](x8664architecture.md) | PRG-ARC-012-DO | x86-64 아키텍처 및 레지스터 |
| [assemble.md](assemble.md) | PRG-ARC-003-DO | 어셈블 과정 |
| [어셈블리어 개념과 명령어 정리 (velog)](https://velog.io/@hey-chocopie/Libasm-2.-%EC%96%B4%EC%85%88%EB%B8%94%EB%A6%AC%EC%96%B4%EB%9E%80-%EA%B0%9C%EB%85%90-%EB%B0%8F-%ED%8A%B9%EC%A7%95-%EC%A0%95%EB%A6%AC-%EB%AA%85%EB%A0%B9%EC%96%B4-%EC%A0%95%EB%A6%AC) | | 외부 문서 |
| [시스템 프로그래밍 4-1주차 (velog)](https://velog.io/@msung99/%EC%8B%9C%EC%8A%A4%ED%85%9C-%ED%94%84%EB%A1%9C%EA%B7%B8%EB%9E%98%EB%B0%8D-4-1%EC%A3%BC%EC%B0%A8) | | 외부 문서 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 같은 `mov` 명령을 Intel 문법과 AT&T 문법으로 각각 써 보고, 가장 헷갈리는 차이를 적어 본다.
- [ ] 함수가 시작할 때 `push ebp` / `mov ebp, esp`를 하는 이유를 내 말로 설명해 본다.
