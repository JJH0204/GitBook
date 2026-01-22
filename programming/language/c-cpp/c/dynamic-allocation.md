# Dynamic allocation

```c
//DynamicAllocation.c
#include <stdio.h>
#include <stdlib.h> // 반드시 포함해야 함

/* 구조체 */
typedef struct {
    char * name;
    int age;
} person;

void printDynamicAlloc(person * p);

/* 예제 1 */
void Ex_Fun(void)
{
    /* 동적 할당 사용 방법 */
    person * person_1 = (person *)malloc(sizeof(person));
    /*
    malloc()은 "void 포인터"를 반환합니다. 따라서 데이터 타입을 "person *"로 설정해야 합니다.
    sizeof는 실제 함수가 아니며, 컴파일러가 이를 해석하여 person 구조체의 실제 메모리 크기로 변환합니다.
    */
   printDynamicAlloc(person_1);

   /* 구조체 멤버에 접근하려면 "->"를 사용할 수 있습니다 */
   person_1->name = "Jaeho";
   person_1->age = 27;

   printDynamicAlloc(person_1);

   /* 동적으로 할당된 구조체를 다 사용한 후에는 "free"를 사용하여 해제할 수 있습니다 */
   free(person_1);

   printDynamicAlloc(person_1);
}

/* 확인 함수 */
void printDynamicAlloc(person * p)
{
    if (p == NULL)
    {
        printf("메모리가 정리되었습니다~\n");
        return;
    }

    printf("사람 이름: %s, 나이: %d\n", p->name, p->age);
}

/* 연습 */
typedef struct {
  int x;
  int y;
} point;

int main(void)
{
    // Ex_Fun();

    point * mypoint = NULL;

    /* mypoint가 가리키는 새로운 point 구조체를 동적으로 할당합니다 */
    mypoint = (point*)malloc(sizeof(point));

    mypoint->x = 10;
    mypoint->y = 5;
    printf("mypoint 좌표: %d, %d\n", mypoint->x, mypoint->y);

    free(mypoint);

    return 0;
}
```
