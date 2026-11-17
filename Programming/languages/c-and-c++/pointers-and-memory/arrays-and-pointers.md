# 배열과 포인터 (Pointers)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-PTR-002-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 배열 이름이 포인터로 바뀌는 규칙(감쇠)과 `malloc`으로 만드는 동적 1차원·2차원 배열을 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 정정한 곳. (1) `%p`에 `void *` 인자를 넘기도록 `(void *)` 형변환을 추가했다. (2) `malloc` 반환값 검사를 추가했다(실패 시 해제 후 반환). (3) `int main()`을 `int main(void)`로 바꿨다. (4) 파스칼 삼각형 출력에 공백을 추가했다. 원본은 `%d`만 써서 `11`처럼 값이 붙어 구분되지 않았다. (5) 반복문 들여쓰기를 맞췄다.
{% endhint %}

## 1. 정의

배열 이름은 대부분의 표현식에서 첫 요소를 가리키는 포인터로 바뀐다. 이를 배열 감쇠(array decay)라 한다. 그래서 `vowels[i]`와 `*(vowels + i)`가 같다.

예외 두 가지는 감쇠하지 않는다.

* `sizeof(vowels)`는 배열 전체 크기다(포인터 크기가 아니다).
* `&vowels`는 배열 전체를 가리키는 포인터(`char (*)[5]`)다.

배열과 포인터는 같은 것이 아니다. `char vowels[5]`는 5바이트 저장 공간이고, `char *pvowels`는 주소 하나를 담는 변수다.

## 2. 구성 요소

| 표현 | 의미 | 비고 |
|---|---|---|
| `vowels[i]` | i번째 요소 | `*(vowels + i)`와 같다 |
| `&vowels[i]` | i번째 요소의 주소 | `vowels + i`와 같다 |
| `pvowels + i` | 포인터에서 i개 요소만큼 이동한 주소 | 이동 단위는 요소 크기 |
| `char **pp` | 포인터를 가리키는 포인터 | 동적 2차원 배열의 행 포인터 배열 |
| `malloc(n * sizeof(char))` | n개 `char` 공간 할당 | 반환값이 `NULL`인지 검사한다 |

## 3. 예제 코드

```c
#include <stdio.h>
#include <stdlib.h>

/*EX_1*/
void Ex_Fun_1(void);
void Ex_Fun_2(void);
void Ex_Fun_3(void);

void Ex_Fun_1(void)
{
    char vowels[] = {'A', 'E', 'I', 'O', 'U'};
    char *pvowels = vowels;
    int i;

    // 주소 출력
    for (i = 0; i < 5; i++) {
        printf("&vowels[%d]: %p, pvowels + %d: %p, vowels + %d: %p\n", i, (void *)&vowels[i], i, (void *)(pvowels + i), i, (void *)(vowels + i));
    }

    // 값 출력
    for (i = 0; i < 5; i++) {
        printf("vowels[%d]: %c, *(pvowels + %d): %c, *(vowels + %d): %c\n", i, vowels[i], i, *(pvowels + i), i, *(vowels + i));
    }
}

void Ex_Fun_2(void)
{
    // 다섯 문자를 저장할 메모리 할당
    int n = 5;
    char *pvowels = (char *) malloc(n * sizeof(char));
    int i;

    if (pvowels == NULL) {
        return;
    }

    pvowels[0] = 'A';
    pvowels[1] = 'E';
    *(pvowels + 2) = 'I';
    pvowels[3] = 'O';
    *(pvowels + 4) = 'U';

    for (i = 0; i < n; i++) {
        printf("%c ", pvowels[i]);
    }

    printf("\n");

    free(pvowels);
}

void Ex_Fun_3(void)
{
    int nrows = 2;
    int ncols = 5;
    int i, j;

    // nrows 포인터에 대한 메모리 할당
    char **pvowels = (char **) malloc(nrows * sizeof(char *));
    if (pvowels == NULL) {
        return;
    }

    // 각 행에 대해 ncols 요소에 대한 메모리 할당
    pvowels[0] = (char *) malloc(ncols * sizeof(char));
    pvowels[1] = (char *) malloc(ncols * sizeof(char));
    if (pvowels[0] == NULL || pvowels[1] == NULL) {
        free(pvowels[0]);   // free(NULL)은 안전하다
        free(pvowels[1]);
        free(pvowels);
        return;
    }

    pvowels[0][0] = 'A';
    pvowels[0][1] = 'E';
    pvowels[0][2] = 'I';
    pvowels[0][3] = 'O';
    pvowels[0][4] = 'U';

    pvowels[1][0] = 'a';
    pvowels[1][1] = 'e';
    pvowels[1][2] = 'i';
    pvowels[1][3] = 'o';
    pvowels[1][4] = 'u';

    for (i = 0; i < nrows; i++) {
        for(j = 0; j < ncols; j++) {
            printf("%c ", pvowels[i][j]);
        }

        printf("\n");
    }

    // 개별 행 메모리 해제
    free(pvowels[0]);
    free(pvowels[1]);

    // 최상위 포인터 메모리 해제
    free(pvowels);
}

/*Exercise*/
/*파스칼의 삼각형의 첫 일곱 행은 아래와 같습니다. 행 i는 i개의 요소를 포함합니다.
따라서 첫 세 행의 숫자를 저장하려면 1 + 2 + 3 = 6개의 메모리 슬롯이 필요합니다.*/

int main(void) {
    int i, j;
    /* TODO: 여기서 2D 포인터 변수를 정의하세요 */
    int **pnumbers;

    /* TODO: 세 행을 저장할 메모리를 할당하는 다음 줄을 완성하세요 */
    pnumbers = (int **) malloc(3 * sizeof(int *));
    if (pnumbers == NULL) {
        return 1;
    }

    /* TODO: 각 행의 개별 요소를 저장할 메모리를 할당하세요 */
    pnumbers[0] = (int *) malloc(1 * sizeof(int));
    pnumbers[1] = (int *) malloc(2 * sizeof(int));
    pnumbers[2] = (int *) malloc(3 * sizeof(int));
    if (pnumbers[0] == NULL || pnumbers[1] == NULL || pnumbers[2] == NULL) {
        free(pnumbers[0]);
        free(pnumbers[1]);
        free(pnumbers[2]);
        free(pnumbers);
        return 1;
    }

    pnumbers[0][0] = 1;
    pnumbers[1][0] = 1;
    pnumbers[1][1] = 1;
    pnumbers[2][0] = 1;
    pnumbers[2][1] = 2;
    pnumbers[2][2] = 1;

    for (i = 0; i < 3; i++) {
        for (j = 0; j <= i; j++) {
            printf("%d ", pnumbers[i][j]);
        }
        printf("\n");
    }

    for (i = 0; i < 3; i++) {
        /* TODO: 각 행에 할당된 메모리를 해제하세요 */
        free(pnumbers[i]);
    }

    /* TODO: 최상위 포인터를 해제하세요 */
    free(pnumbers);

    return 0;
}
```

## 4. 코드 설명

### 4-1. `Ex_Fun_1` (배열 이름과 포인터)

1. `char *pvowels = vowels;`는 배열이 첫 요소의 포인터로 감쇠해 대입된다.
2. `&vowels[i]`, `pvowels + i`, `vowels + i`는 모두 i번째 요소의 같은 주소다. 5개 줄에서 세 값이 일치한다.
3. `vowels[i]`, `*(pvowels + i)`, `*(vowels + i)`는 모두 같은 문자를 출력한다. 주소 값 자체는 실행할 때마다 다르다.
4. 이 함수는 `main`에서 호출하지 않는다. 확인하려면 `main`에서 호출한다.

### 4-2. `Ex_Fun_2` (동적 1차원 배열)

1. `malloc(n * sizeof(char))`로 5바이트를 할당하고 `NULL`이면 반환한다.
2. `pvowels[i]`와 `*(pvowels + i)` 표기를 섞어 값을 넣는다. 둘은 같은 동작이다.
3. 출력: `A E I O U `
4. `free(pvowels)`로 해제한다. 이후 `pvowels`는 쓰지 않는다.

### 4-3. `Ex_Fun_3` (동적 2차원 배열)

1. `char **pvowels`는 행 포인터 2개를 담는 배열이다.
2. 각 행에 `char` 5개를 따로 할당한다. 행이 메모리에서 서로 떨어져 있을 수 있어 `char vowels[2][5]` 배열과 메모리 배치가 다르다.
3. 해제는 할당의 역순이다. 행을 먼저 해제하고 최상위 포인터를 해제한다. 최상위를 먼저 해제하면 행 포인터를 잃어 누수가 된다.

### 4-4. `main` (파스칼의 삼각형)

1. 행 포인터 3개와, 행마다 1·2·3개의 `int`를 할당한다.
2. 값을 대입한다(1 / 1 1 / 1 2 1).
3. 출력:
```
1 
1 1 
1 2 1 
```
4. 행을 해제한 뒤 최상위 포인터를 해제한다.

## 5. 한계·주의

* `malloc`은 실패하면 `NULL`을 반환한다. 반환값을 검사하지 않고 쓰면 `NULL` 역참조(UB)다.
* 함수 인자로 넘긴 배열은 포인터로 바뀌므로 함수 안에서 `sizeof`로 배열 크기를 구할 수 없다.
* 해제한 포인터를 다시 `free`하면(이중 해제) UB이고, 해제하지 않으면 메모리 누수(버그)다. 해제 직후 `p = NULL;`을 대입하면 이중 해제와 해제 후 사용을 막는다. 자세한 구분은 [동적 메모리 할당](dynamic-allocation.md)을 본다.
* 범위 밖 접근은 UB다. `vowels[5]`는 존재하지 않는다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `vowels[i]`와 `*(vowels + i)`가 같은 이유를 내 말로 설명해 보자.
- [ ] 배열 이름이 포인터로 바뀌지 않는 경우(`sizeof`, `&`)가 왜 중요한지 적어 보자.
- [ ] 동적 2차원 배열을 해제할 때 순서를 지켜야 하는 이유를 적어 보자.
