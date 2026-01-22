# Strings

```c
#include <stdio.h>
/*must include*/
#include <string.h>

void concept(void)
{
    /*Defining*/
    char *name = "Jung Jaeho";
    /*
    same as
    char name[] = "Jung Jaeho";
    char name[11] = "Jung Jaeho";
    */

    /*string formatting with printf*/
    int age = 27;
    printf("%s is %d years old.\n", name, age);

    /*string Length*/
    printf("%lu\n", strlen(name));

    /*string comparison*/
    if (strncmp(name, "Jung Jaeho", 10) == 0)
    {
        printf("Helle, Jaeho!\n");
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
    char *first_name = "John";
    /* define last_name */
    char last_name[] = "Doe";
    char name[100];

    last_name[0] = 'B';
    sprintf(name, "%s %s", first_name, last_name);
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
