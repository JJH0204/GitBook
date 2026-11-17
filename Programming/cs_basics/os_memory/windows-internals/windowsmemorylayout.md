# Windows PE 메모리 레이아웃

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-WIN-001-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | Windows PE 파일의 섹션 구성과 프로세스의 스택·힙 구성, 구획별 권한을 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 PE 형식 지식을 정리한 것이며 코드를 컴파일하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이전 정정을 유지했다. 스택 예제의 함수는 `void func()`가 아니라 `int func()`다(void 함수에서 `return 0;`은 오류). 힙은 "전역으로 접근 가능하도록 설계"된 것이 아니라 포인터를 공유할 때만 여러 함수·스레드가 접근한다. 추가: .bss, .reloc, .rsrc 섹션, ASLR·DEP, 섹션 권한 표, 힙 예제의 `#include <stdlib.h>`와 `free`.
{% endhint %}

## 1. 목적

Windows 실행 파일(PE, Portable Executable)은 PE 헤더와 1개 이상의 섹션으로 구성된다. 섹션은 유사한 용도의 데이터를 모은 영역이다. 이 문서는 섹션이 프로세스 가상 메모리에 어떻게 올라오는지와 스택·힙을 설명한다. 일반 구조는 [메모리 레이아웃](../memory-management/memorylayout.md)을 본다.

## 2. 구성 요소

PE 헤더에는 섹션별로 다음 정보가 있다.

* 섹션의 이름
* 섹션의 크기
* 섹션이 로드될 주소의 오프셋
* 섹션의 속성과 권한

Windows는 PE를 실행할 때 이 정보로 각 섹션을 가상 메모리의 알맞은 구획에 매핑한다. 필수로 존재해야 하는 섹션은 정해져 있지 않다. 일반적으로 `.text`, `.data`, `.rdata`가 쓰인다.

### 2.1 섹션 표

| 섹션 | 내용 | 일반적 권한 |
|---|---|---|
| `.text` | 실행 가능한 기계 코드 | 읽기, 실행 |
| `.data` | 컴파일 시점에 값이 정해진 전역 변수 | 읽기, 쓰기 |
| `.rdata` | 전역 상수, 가져오기(import)할 DLL·함수 정보 | 읽기 |
| `.bss` | 초기화하지 않은 전역 변수(파일에는 크기만 기록) | 읽기, 쓰기 |
| `.idata` | 가져오기 테이블(과거 별도 섹션, 현재는 대부분 `.rdata`에 포함) | 링커에 따라 다름 |
| `.reloc` | 베이스 재배치 정보(ASLR로 로드 주소가 바뀔 때 사용) | 읽기 |
| `.rsrc` | 리소스(아이콘, 문자열, 대화상자 등) | 읽기 |

{% hint style="info" %}
NOTE: 섹션 이름과 병합 방식은 컴파일러·링커 설정마다 다르다. MSVC는 `.bss`를 별도로 두지 않고 `.data`에 포함해 만들기도 한다. 위 표는 일반적인 구성이다.
{% endhint %}

### 2.2 섹션이 아닌 메모리

| 영역 | 설명 | 권한 |
|---|---|---|
| 스택 | 스레드마다 하나씩 가진다. 지역 변수와 함수 복귀 주소를 저장한다. 낮은 주소 방향으로 자란다(기본 크기 1 MiB는 링커 설정으로 바꾼다) | 읽기, 쓰기 |
| 힙 | 실행 중 동적으로 할당받는 영역 | 읽기, 쓰기. 명시적으로 요청하면 실행도 가능하다 |

## 3. 동작 원리

1. 사용자가 PE를 실행한다.
2. 로더가 PE 헤더를 읽는다.
3. 로더가 섹션을 가상 메모리에 매핑하고 섹션 속성대로 권한을 설정한다.
4. 로더가 가져오기 테이블의 DLL을 로드하고 함수 주소를 채운다.
5. 프로세스의 스레드가 시작되며 스택이 만들어지고, 이후 힙이 필요할 때 할당된다.

### 3.1 보호 기법

| 기법 | 설명 |
|---|---|
| DEP(Data Execution Prevention) | 데이터 영역(스택, 힙, `.data`)에서 코드를 실행하지 못하게 한다 |
| ASLR(Address Space Layout Randomization) | 실행마다 이미지·스택·힙의 주소를 바꾼다. `.reloc` 정보가 필요하다 |
| W^X 원칙 | 쓰기와 실행을 동시에 허용하지 않는다. 공격자가 코드를 삽입해 실행하기 어렵게 한다 |

원본이 설명한 대로 `.text`에 쓰기 권한을 주지 않는 것이 현대 운영체제의 기본이다. 쓰기가 가능하면 공격자가 악의적인 코드를 삽입하기 쉬워진다.

## 4. 예제 코드

각 예제는 개념 설명용이며 `...`는 생략을 뜻한다.

### 4.1 `.text`

아래 정수 31337을 반환하는 `main`이 컴파일되면 기계 코드 `55 48 89 e5 b8 69 7a 00 00 5d c3`(x86-64, 최적화 없음)으로 변환된다. 이 기계 코드는 코드 구획에 위치한다.

```c
int main() { return 31337; }
```

* `55`는 `push rbp`, `48 89 e5`는 `mov rbp, rsp`, `b8 69 7a 00 00`은 `mov eax, 31337`(0x7A69), `5d`는 `pop rbp`, `c3`은 `ret`다.

### 4.2 `.data`

컴파일 시점에 값이 정해진 전역 변수가 위치한다. CPU가 읽고 써야 하므로 읽기/쓰기 권한이 부여된다.

```c
int data_num = 31337;
char data_rwstr[] = "writable_data";   // .data

int main() { /* ... */ }
```

### 4.3 `.rdata`

컴파일 시점에 값이 정해진 전역 상수와 참조할 [DLL](../executables-and-linking/dll.md) 및 외부 함수 정보가 저장된다. 읽기만 가능하다. 과거에는 DLL 정보를 `.idata`에 저장했으나 최근에는 대부분 `.rdata`에 저장한다.

```c
const char data_rostr[] = "readonly_data";
char *str_ptr = "readonly";   // str_ptr은 .data, 문자열 "readonly"는 .rdata

int main() { /* ... */ }
```

* `str_ptr`은 전역 변수이므로 `.data`에 있다.
* `str_ptr`이 가리키는 문자열 `"readonly"`는 상수 문자열이므로 `.rdata`에 있다.

### 4.4 스택

각 스레드는 자신만의 스택을 가진다. 아래 코드에서 지역 변수 `choice`가 스택에 저장된다.

```c
int func() {
  int choice = 0;

  scanf("%d", &choice);

  if (choice)
    call_true();
  else
    call_false();

  return 0;
}
```

* `call_true`, `call_false`는 예시용 함수이며 정의되어 있어야 컴파일된다.
* `int func()`는 값을 반환하므로 `return 0;`이 유효하다. `void func()`라면 `return;`을 써야 한다.

### 4.5 힙

힙은 프로그램이 동적으로 할당받은 공간이다. 스택보다 큰 데이터도 저장할 수 있고, 포인터를 공유하면 여러 함수와 스레드에서 접근할 수 있다. 아래 코드에서 `heap_data_ptr`은 지역 변수라 스택에 있고, `malloc`으로 할당받은 힙 영역의 주소를 가리킨다.

```c
#include <stdio.h>
#include <stdlib.h>

int main() {
  int *heap_data_ptr = malloc(sizeof(*heap_data_ptr));  // 동적 할당한 힙 영역의 주소
  if (heap_data_ptr == NULL) return 1;                   // 할당 실패 검사
  *heap_data_ptr = 31337;                                // 힙 영역에 값을 씀
  printf("%d\n", *heap_data_ptr);                        // 힙 영역의 값을 사용함
  free(heap_data_ptr);                                   // 사용 후 해제
  return 0;
}
```

## 5. 약어·용어

| 용어 | 뜻 |
|---|---|
| PE | Portable Executable. Windows 실행 파일 형식 |
| 섹션 | 유사한 용도의 데이터를 모은 PE 내부 영역 |
| DEP | Data Execution Prevention |
| ASLR | Address Space Layout Randomization |
| IAT | Import Address Table. 가져온 함수의 주소 표 |

## 6. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [memorylayout.md](../memory-management/memorylayout.md) | PRG-MEM-002-DO | 메모리 레이아웃 (Layout) |
| [dll.md](../executables-and-linking/dll.md) | | 동적 링크 라이브러리 (DLL) |
| [windowssystemfile.md](windowssystemfile.md) | PRG-WIN-002-REF | 가상 메모리 시스템 파일 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `.data`와 `.rdata`에 놓이는 변수의 차이를 내 말로 적어 본다.
- [ ] `.text`에 쓰기 권한이 없어야 하는 이유를 적어 본다.
- [ ] 변수 하나를 골라 스택, 힙, `.data` 중 어디에 놓이는지와 이유를 적어 본다.
