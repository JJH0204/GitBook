# 정적 변수 및 함수 (Static)

{% code title="static.c" %}
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
    printf("%d ", sum(55));
    printf("%d ", sum(45));
    printf("%d ", sum(50));
    return 0;
}
```
{% endcode %}
