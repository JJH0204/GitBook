# 문자열 (Strings)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-CFD-007-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | C 문자열의 표현 방식과 `<string.h>` 함수(길이, 비교, 이어 붙이기) 사용법을 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 정정한 곳. (1) `char *name`을 `const char *name`으로 바꿨다(문자열 리터럴은 수정할 수 없다). (2) `sprintf`를 `snprintf(name, sizeof name, ...)`로 바꿔 버퍼 크기를 제한했다. 나머지 구조와 주석은 원본 그대로다.
{% endhint %}

## 1. 정의

C에는 문자열 전용 자료형이 없다. 문자열은 `'\0'`(널 문자)로 끝나는 `char` 배열이다. `"abc"`는 `'a'`, `'b'`, `'c'`, `'\0'` 4바이트다.

## 2. 구성 요소

### 2-1. 문자열을 정의하는 두 방식

| 방식 | 예 | 수정 가능 여부 |
|---|---|---|
| 리터럴을 가리키는 포인터 | `const char *s = "John";` | 불가. 내용을 수정하면 UB다 |
| `char` 배열 | `char s[] = "Doe";` | 가능. 리터럴을 배열로 복사한다 |

`char *s = "..."`는 리터럴을 가리키는 포인터다. C에서 컴파일은 되지만 수정하면 UB이므로 `const char *`를 쓴다.

### 2-2. `<string.h>` 함수

| 함수 | 역할 | 주의 |
|---|---|---|
| `strlen(s)` | 널 문자 앞까지 길이를 구한다 | 반환 형식은 `size_t`. `printf`는 `%zu`(C99)를 쓴다 |
| `strcmp(a, b)` | 두 문자열을 비교한다. 같으면 0 | 길이가 달라도 비교한다 |
| `strncmp(a, b, n)` | 앞 n글자까지 비교한다. 같으면 0 | n글자까지만 같으면 0이다(접두사 비교) |
| `strncat(dst, src, n)` | `src`의 최대 n글자를 `dst` 뒤에 붙이고 널 문자를 쓴다 | n은 복사할 최대 글자 수이지 `dst` 크기가 아니다 |
| `snprintf(buf, size, fmt, ...)` | 형식화한 문자열을 `buf`에 쓴다 | `size`는 널 문자 포함 버퍼 크기 |

## 3. 예제 코드

{% code title="strings.c" %}
```c
#include <stdio.h>
/*must include*/
#include <string.h>

void concept(void)
{
    /*Defining*/
    const char *name = "Jung Jaeho";
    /*
    similar to (단, 아래 배열은 수정 가능하지만 리터럴을 가리키는 포인터로는 내용을 수정하면 UB)
    char name[] = "Jung Jaeho";
    char name[11] = "Jung Jaeho";
    */

    /*string formatting with printf*/
    int age = 27;
    printf("%s is %d years old.\n", name, age);

    /*string Length*/
    printf("%zu\n", strlen(name));

    /*string comparison*/
    if (strncmp(name, "Jung Jaeho", 10) == 0)
    {
        printf("Hello, Jaeho!\n");
    }
    else
    {
        printf("You are not Jaeho.\n");
    }

    /*String Concatenation*/
    char First_name[20] = "Jung";
    char Last_name[20] = "Jaeho";

    strncat(First_name, Last_name, 5);
    printf("%s\n", First_name);
    strncat(First_name, Last_name, 20);
    printf("%s\n", First_name);
}

void exercise(void)
{
    // 포인터 표기법을 사용하여 문자열 first_name을 John 값으로 정의하고, 로컬 배열 표기법을 사용하여 문자열 last_name을 Doe 값으로 정의합니다.
    /* define first_name */
    const char *first_name = "John";
    /* define last_name */
    char last_name[] = "Doe";
    char name[100];

    last_name[0] = 'B';
    snprintf(name, sizeof name, "%s %s", first_name, last_name);
    // printf("test: %s\n",name);
    if (strncmp(name, "John Boe", 100) == 0)
    {
        printf("Done!\n");
    }
    name[0] = '\0';
    strncat(name, first_name, 4);
    strncat(name, last_name, 20);
    printf("%s\n", name);
}

int main(void)
{
    concept();
    exercise();
    return 0;
}
```
{% endcode %}

## 4. 코드 설명

### 4-1. `concept()`

1. `name`은 리터럴 `"Jung Jaeho"`(공백 포함 10글자 + 널 문자)를 가리킨다. 출력: `Jung Jaeho is 27 years old.`
2. `strlen(name)`은 10이다. 널 문자는 세지 않는다.
3. `strncmp(name, "Jung Jaeho", 10)`은 앞 10글자가 같으므로 0이다. 출력: `Hello, Jaeho!`
4. `First_name`은 `"Jung"`(4글자)에 `"Jaeho"` 5글자를 붙여 `JungJaeho`(9글자)가 된다.
5. 같은 `Last_name`을 한 번 더 붙이면 `JungJaehoJaeho`(14글자)다. `strncat`은 `src`가 5글자뿐이라 5글자만 복사한다. 필요한 공간은 14글자 + 널 문자 = 15바이트로 `First_name[20]`에 들어간다.

### 4-2. `exercise()`

1. `first_name`은 리터럴 포인터, `last_name`은 수정 가능한 배열이다.
2. `last_name[0] = 'B'`로 `"Boe"`가 된다. 이 줄은 배열이므로 안전하다. `first_name[0] = 'B'` 같은 수정은 UB다.
3. `snprintf`가 `name`에 `John Boe`를 쓴다. 비교가 일치하므로 `Done!`을 출력한다.
4. `name[0] = '\0'`으로 빈 문자열로 만든 뒤 `John`, `Boe`를 차례로 붙인다. 출력: `JohnBoe`.

## 5. 한계·주의

* `strncat`의 세 번째 인자가 `dst`의 남은 공간보다 커도 `src`가 짧으면 안전하지만, `src`가 길면 버퍼를 넘어 UB다. 안전하게 쓰려면 `sizeof dst - strlen(dst) - 1`로 남은 공간을 계산해 넘긴다.
* `strncmp`는 접두사만 같아도 0이다. 전체가 같은지 보려면 `strcmp`를 쓴다.
* 널 문자 없는 배열에 `strlen`, `%s`를 쓰면 범위 밖을 읽는 UB다.
* 사용자 입력은 `gets`(C11에서 삭제)를 쓰지 않는다. `fgets`나 크기를 지정한 `scanf("%19s", ...)`를 쓰고 `scanf`의 반환값을 검사한다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 문자열이 널 문자로 끝난다는 사실이 `strlen`, `strcat` 등의 동작에 어떤 영향을 주는지 내 말로 설명해 보자.
- [ ] `const char *s = "..."`와 `char s[] = "..."`의 차이를 내 말로 적어 보자.
- [ ] `strncmp`가 접두사만 같아도 0을 반환해서 생길 수 있는 문제를 예를 들어 적어 보자.
