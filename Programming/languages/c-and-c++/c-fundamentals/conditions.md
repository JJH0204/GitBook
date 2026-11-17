# 조건문 (Conditions)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-CFD-003-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | `if`/`else`로 조건에 따라 실행 경로를 나누는 방법을 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 정정한 곳. `int main()`을 `int main(void)`로 바꾸고 `return 0;`을 추가했다.
{% endhint %}

## 1. 정의

조건문은 조건식의 참·거짓에 따라 실행할 코드를 선택한다. C에서 0은 거짓, 0이 아닌 값은 참이다.

## 2. 구성 요소

| 요소 | 문법 | 역할 |
|---|---|---|
| `if` | `if (조건) { ... }` | 조건이 참이면 블록을 실행한다 |
| `else` | `else { ... }` | 앞의 조건이 거짓이면 실행한다 |
| `else if` | `else if (조건) { ... }` | 여러 조건을 순서대로 검사한다 |
| 비교 연산자 | `==`, `!=`, `<`, `>`, `<=`, `>=` | 두 값을 비교해 0 또는 1을 만든다 |
| 논리 연산자 | `&&`, `||`, `!` | 조건을 결합한다. `&&`, `||`는 왼쪽 결과로 결정되면 오른쪽을 평가하지 않는다 |

## 3. 예제 코드

{% code title="conditions.c" %}
```c
#include <stdio.h>

void guessNumber(int guess)
{
    // TODO: write your code here
    if (guess == 555)
    {
        printf("Correct. You guessed it!\n");
    }
    else
    {
        if (guess < 555)
        {
            printf("Your guess is too low.\n");
        }
        else
        {
            printf("Your guess is too high.\n");
        }
    }
}

int main(void)
{
    guessNumber(500);
    guessNumber(600);
    guessNumber(555);
    return 0;
}
```
{% endcode %}

## 4. 코드 설명

1. `guessNumber(500)`: 555가 아니고 555보다 작으므로 `Your guess is too low.`를 출력한다.
2. `guessNumber(600)`: 555보다 크므로 `Your guess is too high.`를 출력한다.
3. `guessNumber(555)`: `Correct. You guessed it!`를 출력한다.
4. 안쪽 `if`/`else`는 `else if`로 평탄하게 쓸 수 있다.

## 5. 한계·주의

* `=`(대입)와 `==`(비교)를 혼동하면 조건이 항상 참 또는 거짓이 되는 버그가 난다. `if (guess = 555)`는 컴파일되지만 의도와 다르다.
* 중괄호를 생략하면 다음 한 문장만 블록에 속한다. 한 줄이라도 중괄호를 쓰는 편이 안전하다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `=`와 `==`를 혼동했을 때 어떤 일이 벌어지는지 내 말로 설명해 보자.
- [ ] `if` 안에 `if`를 넣은 구조와 `else if`를 쓴 구조 중 어느 쪽이 읽기 쉬운지, 이유와 함께 적어 보자.
- [ ] 조건문을 쓰다가 놓쳤던 경계값(예: 같은 값) 사례가 있다면 적어 보자.
