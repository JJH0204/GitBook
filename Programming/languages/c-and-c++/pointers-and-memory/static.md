# 정적 변수 및 함수 (Static)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-PTR-006-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | `static` 지역 변수의 수명과 `static` 함수·전역 변수의 링키지(linkage)를 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 정정한 곳. (1) 인자 없는 함수 정의를 `(void)`로 바꿨다(`ExNoneStatic`, `ExStatic`, `ExCode`). (2) `ExStaticFun`이 호출되지 않아 미사용 함수 경고가 나므로 `main`에서 호출하고 줄 바꿈을 추가했다. (3) `main` 출력 끝에 줄 바꿈을 추가했다.
{% endhint %}

## 1. 정의

`static`은 문맥에 따라 두 가지 의미를 가진다.

* 지역 변수에 쓰면 저장 기간(storage duration)이 프로그램 전체가 된다. 함수가 끝나도 값이 유지된다.
* 파일 범위의 함수나 전역 변수에 쓰면 링키지가 내부(internal linkage)가 되어 그 파일 밖에서 보이지 않는다.

## 2. 구성 요소

| 구분 | 선언 위치 | 수명 | 보이는 범위 |
|---|---|---|---|
| 일반 지역 변수 | 함수 안 | 함수 실행 동안 | 함수 안 |
| `static` 지역 변수 | 함수 안 | 프로그램 전체 | 함수 안 |
| 일반 전역 변수 | 파일 범위 | 프로그램 전체 | 다른 파일에서도 접근 가능(외부 링키지) |
| `static` 전역 변수 | 파일 범위 | 프로그램 전체 | 해당 파일 안 |
| 일반 함수 | 파일 범위 | | 다른 파일에서도 호출 가능(외부 링키지) |
| `static` 함수 | 파일 범위 | | 해당 파일 안 |

* `static` 지역 변수는 한 번만 초기화되며 초기값은 상수식이어야 한다. 초기화하지 않으면 0이다.
* 다른 파일에서 함수를 쓰게 하지 않으려면 `static`을 붙여 이름 충돌을 막는다.

## 3. 예제 코드

{% code title="static.c" %}
```c
//static.c
#include <stdio.h>

/*What is a static variable*/
int ExNoneStatic(void)
{
    int count = 0;
    count++;
    return count;
}

int ExStatic(void)
{
    static int count = 0;
    count++;
    return count;
}

void ExCode(void)
{
    /*None Static*/
    printf("%d ", ExNoneStatic());
    printf("%d\n", ExNoneStatic());

    /*Static*/
    printf("%d ", ExStatic());
    printf("%d\n", ExStatic());
}

static void ExStaticFun(void)
{
    printf("I am a static function.\n");
}
/*기본적으로 C에서 함수는 외부 링키지를 가져 다른 파일에서도 보입니다. 함수를 static으로 선언하면 내부 링키지가 되어 이를 포함하는 파일로 범위가 축소됩니다.*/
// static과 전역 변수의 차이?
// 파일 범위의 static 변수는 해당 파일 안에서만 접근할 수 있는 반면, static이 아닌 전역 변수는 파일 외부에서도 접근할 수 있습니다. (함수 안의 static 변수는 그 함수 안에서만 보이지만 프로그램 실행 내내 값이 유지됩니다.)

/*Exercise*/
int sum (int num)
{
    static int i = 0;
    i += num;
    return i;
}

int main(void)
{
    ExCode();
    ExStaticFun();
    printf("%d ", sum(55));
    printf("%d ", sum(45));
    printf("%d\n", sum(50));
    return 0;
}
```
{% endcode %}

## 4. 코드 설명

1. `ExNoneStatic()`은 호출할 때마다 `count`를 0으로 만들고 1을 더하므로 항상 1을 반환한다. 출력: `1 1`.
2. `ExStatic()`의 `static int count`는 처음 한 번만 0이 되고 호출 사이에 값이 유지된다. 출력: `1 2`.
3. `ExStaticFun()`은 `static` 함수라 이 파일 안에서만 호출된다. 출력: `I am a static function.`
4. `sum`은 `static int i`에 인자를 누적한다. 세 번 호출 결과: `55 100 150`.
5. 각 `printf`는 별도 호출이라 호출 순서가 보장되어 출력이 위와 같다. 한 `printf` 안에 `sum(...)`을 여러 번 넣으면 인자 평가 순서가 정해지지 않아 결과가 달라질 수 있다.

## 5. 한계·주의

* `static` 지역 변수는 호출 사이에 상태를 가지므로 함수가 재진입(reentrant)하지 않고, 여러 스레드에서 동시에 쓰면 데이터 경쟁(data race)이 생긴다.
* 상태를 숨기고 싶을 때 파일 범위 `static` 변수를 쓰고, 접근용 함수만 외부에 공개한다.
* 헤더 파일에 `static` 변수를 정의하면 그 헤더를 포함한 `.c` 파일마다 별개의 복사본이 생긴다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `static` 지역 변수와 일반 지역 변수의 수명 차이를 내 말로 설명해 보자.
- [ ] `static` 함수와 일반 함수가 링크 단계에서 어떻게 다르게 취급되는지 적어 보자.
- [ ] `static` 지역 변수를 썼다가 문제가 될 수 있는 상황(여러 스레드 등)을 적어 보자.
