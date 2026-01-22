# Static

```c
//static.c
#include <stdio.h>

/*What is a static variable*/
int ExNoneStatic()
{
    int count = 0;
    count++;
    return count;
}

int ExStatic()
{
    static int count = 0;
    count++;
    return count;
}

void ExCode()
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
    printf("I am a static function.");
}
/*기본적으로 C에서 함수는 전역적입니다. 함수를 static으로 선언하면 해당 함수의 범위가 이를 포함하는 파일로 축소됩니다.*/
// static과 전역 변수의 차이?
// static 변수는 이를 포함하는 파일 내에서만 접근할 수 있는 반면, 전역 변수는 파일 외부에서도 접근할 수 있습니다.

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
    printf("%d ", sum(55));
    printf("%d ", sum(45));
    printf("%d ", sum(50));
    return 0;
}
```
