# 참조에 의한 전달 (Call by Ref)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-PTR-004-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | C에서 함수가 호출한 쪽의 변수를 바꾸려면 포인터를 값으로 넘겨야 하는 이유를 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 정정한 곳. (1) EX1·EX2의 `int n;`은 초기화하지 않고 출력해 값이 정해지지 않는다(UB). `int n = 0;`으로 초기화했다. (2) EX3 조각에 필요한 `point` 타입 정의를 추가했다. (3) Exercise에 빠져 있던 `#include <stdio.h>`를 추가하고 `int main()`을 `int main(void)`로 바꿨다. 영어 설명문은 한국어로 옮겼고 코드 안 영어 주석은 그대로 뒀다.
{% endhint %}

## 1. 정의

C의 함수 인자는 항상 값으로 복사되어 전달된다(값에 의한 전달). "참조에 의한 전달"은 C 문법에 없고, 변수의 주소(포인터)를 값으로 넘겨 호출한 쪽 변수를 간접 수정하는 방식으로 흉내 낸다.

## 2. 구성 요소

| 방식 | 매개변수 | 호출 | 호출한 쪽 변수 |
|---|---|---|---|
| 값 전달 | `int n` | `addone(n)` | 바뀌지 않는다 (복사본만 바뀐다) |
| 포인터 전달 | `int *n` | `addone(&n)` | 바뀐다 (`*n`으로 원본에 접근) |
| 구조체 포인터 전달 | `point *p` | `move(&pt)` | 멤버가 바뀐다 (`p->x`) |

`p->x`는 `(*p).x`와 같다.

## 3. 예제 코드

아래 조각은 서로 다른 예제이며 각각 `main` 안에서 쓴다는 가정이다. EX1과 EX2는 같은 함수 이름 `addone`을 쓰므로 한 파일에 함께 넣을 수 없다.

### 3-1. EX1: 값에 의한 전달 (호출한 쪽 변수에 영향 없음)

```c
/*EX1*/
void addone(int n) {
    // n is local variable which only exists within the function scope
    n++; // therefore incrementing it has no effect
}

int n = 0;
printf("Before: %d\n", n);
addone(n);
printf("After: %d\n", n);
```

예상 출력: `Before: 0`, `After: 0`.

### 3-2. EX2: 포인터 전달 (호출한 쪽 변수 수정)

```c
/*EX2*/
void addone(int *n) {
    // n is a pointer here which points to a memory-address outside the function scope
    (*n)++; // this will effectively increment the value of n
}

int n = 0;
printf("Before: %d\n", n);
addone(&n);
printf("After: %d\n", n);
```

예상 출력: `Before: 0`, `After: 1`. `(*n)++`의 괄호를 빼면 `*n++`는 포인터를 증가시키므로 의도와 다르다.

### 3-3. EX3: 포인터로 구조체 멤버 수정

```c
/*EX3*/
typedef struct {
    int x;
    int y;
} point;

void move(point * p) {
    (*p).x++;   // p->x++;
    (*p).y++;   // p->y++;
}
```

호출: `point pt = {0, 0}; move(&pt);` 후 `pt`는 `{1, 1}`이다.

### 3-4. Exercise: 나이를 1 올리는 `birthday`

`person` 구조체와, 포인터로 `age`를 1 올리는 `birthday` 함수다.

```c
#include <stdio.h>

typedef struct {
  char * name;
  int age;
} person;

/* function declaration */
void birthday(person * p);

/* write your function here */
void birthday(person * p)
{
    p -> age++;
}

int main(void) {
  person john;
  john.name = "John";
  john.age = 27;

  printf("%s is %d years old.\n", john.name, john.age);
  birthday(&john);
  printf("Happy birthday! %s is now %d years old.\n", john.name, john.age);

  return 0;
}
```

## 4. 코드 설명

1. 포인터를 넘기면 포인터 자체는 복사되지만, 가리키는 대상은 같다. 그래서 `*n`을 바꾸면 호출한 쪽 변수가 바뀐다.
2. `birthday(&john)`은 `john`의 주소를 넘긴다. `p->age++`가 원본의 `age`를 27에서 28로 올린다.
3. 예상 출력: `John is 27 years old.`, `Happy birthday! John is now 28 years old.`
4. `john.name`은 문자열 리터럴을 가리키는 포인터다. 이 문자열을 수정하면 UB이므로 `const char *`가 더 안전하다. 이 예제는 읽기만 한다.

## 5. 한계·주의

* `NULL`일 수 있는 포인터를 받는 함수는 역참조 전에 `p != NULL`을 검사한다. 예제는 항상 유효한 주소를 넘긴다.
* 호출한 쪽에 `const`가 아닌 변수를 넘길 때만 쓴다. 읽기 전용 인자는 `const person *p`로 받아 수정 실수를 막는다.
* 지역 변수의 주소를 저장해 두고 함수 종료 후 쓰면 UB다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 값에 의한 전달과 포인터 전달에서 `n`이 바뀌는지 여부가 달라지는 이유를 내 말로 설명해 보자.
- [ ] C에 "참조에 의한 전달"이 문법으로 없다고 하는 이유를 적어 보자.
- [ ] 내가 쓴 함수 중 포인터 인자를 받는 것이 있다면, 그 인자를 `const`로 바꿀 수 있는지 적어 보자.
