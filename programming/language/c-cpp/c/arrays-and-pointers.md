# Arrays and Pointers

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
    printf("&vowels[%d]: %p, pvowels + %d: %p, vowels + %d: %p\n", i, &vowels[i], i, pvowels + i, i, vowels + i);
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

    // 각 행에 대해 ncols 요소에 대한 메모리 할당
    pvowels[0] = (char *) malloc(ncols * sizeof(char));
    pvowels[1] = (char *) malloc(ncols * sizeof(char));

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

int main() {
    int i, j;
    /* TODO: 여기서 2D 포인터 변수를 정의하세요 */
    int **pnumbers;

    /* TODO: 세 행을 저장할 메모리를 할당하는 다음 줄을 완성하세요 */
    pnumbers = (int **) malloc(3 * sizeof(int *));

    /* TODO: 각 행의 개별 요소를 저장할 메모리를 할당하세요 */
    pnumbers[0] = (int *) malloc(1 * sizeof(int));
    pnumbers[1] = (int *) malloc(2 * sizeof(int));
    pnumbers[2] = (int *) malloc(3 * sizeof(int));

    pnumbers[0][0] = 1;
    pnumbers[1][0] = 1;
    pnumbers[1][1] = 1;
    pnumbers[2][0] = 1;
    pnumbers[2][1] = 2;
    pnumbers[2][2] = 1;

    for (i = 0; i < 3; i++) {
        for (j = 0; j <= i; j++) {
            printf("%d", pnumbers[i][j]);
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
