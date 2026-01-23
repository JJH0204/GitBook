# CModularizationError

## 개발 · 개발환경

VScode로 스택을 구현한 후 모듈화를 위해 파일을 나눠서 저장했다.

* [MyStack.h](/broken/pages/ebea2a0ad4ecc2b6a08b4c601f55fb6f755afb92)
* [MyStack.c](/broken/pages/e0dcedf6e8fb81d35c92891af1f6b744ec323bf5)
* [Main.c](/broken/pages/fba645a7a1d4e4adb7211d5ffc6744439d493375)

VS Code에서는 다음과 같은 에러가 발생했다.

```
admin@adminui-MacBookAir 6_usingStack % cd "/Users/admin/Documents/GitHub/DevBasics/DSNA/6_usingStack/" && gcc reverseString.c -o reverseString &&
 "/Users/admin/Documents/GitHub/DevBasics/DSNA/6_usingStack/"reverseString
ld: Undefined symbols:
  _createStack, referenced from:
      _reverseString in reverseString-42ca62.o
  _pop, referenced from:
      _reverseString in reverseString-42ca62.o
  _push, referenced from:
      _reverseString in reverseString-42ca62.o
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

반면 Xcode에서 컴파일 시 정상적으로 작동했다.

```
current stack: 7 number

[7]-[U]

[6]-[O]

[5]-[Y]

[4]-[E]

[3]-[V]

[2]-[O]

[1]-[L]

Pop - [U]

current stack: 6 number

[6]-[O]

[5]-[Y]

[4]-[E]

[3]-[V]

[2]-[O]

[1]-[L]

Peek - [O]

current stack: 6 number

[6]-[O]

[5]-[Y]

[4]-[E]

[3]-[V]

[2]-[O]

[1]-[L]

Program ended with exit code: 0
```

무엇이 이 둘의 차이를 만들었을까?

{% stepper %}
{% step %}
### 작성 IDE 차이?

만약에, 코드를 작성했던 IDE의 파일 생성 방식의 차이 때문이라면 Xcode에서 정상 작동했던 코드를 VSCode에서 프로젝트 파일 통째로 불러와서 실행하면 실행되지 않을까?

#### 결과

```
cd "/Users/admin/Documents/C_test/C_test/" && gcc main.c -o main && "/Users/admin/Documents/C_test/C_test/"main
admin@adminui-MacBookAir C_test % cd "/Users/admin/Documents/C_test/C_test/" && gcc main.c -o main && "/Users/admin/Documents/C_test/C_test/"main
ld: Undefined symbols:
  _createStack, referenced from:
      _main in main-c2b05d.o
  _deleteStack, referenced from:
      _main in main-c2b05d.o
  _displayStack, referenced from:
      _main in main-c2b05d.o
      _main in main-c2b05d.o
      _main in main-c2b05d.o
  _peek, referenced from:
      _main in main-c2b05d.o
  _pop, referenced from:
      _main in main-c2b05d.o
  _push, referenced from:
      _main in main-c2b05d.o
      _main in main-c2b05d.o
      _main in main-c2b05d.o
      _main in main-c2b05d.o
      _main in main-c2b05d.o
      _main in main-c2b05d.o
      _main in main-c2b05d.o
      ...
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

덕분에 VSCode 자체의 문제인 점은 확인했다. 문제 해결을 위해 VSCode의 세팅 부분을 확인해야겠다.
{% endstep %}

{% step %}
### clang의 의미와 점검

clang은 C/C++ 프론트엔드로, LLVM을 백엔드로 사용하는 컴파일러이다. (GCC 대체 목표)

> GCC와 Clang의 차이점 관련 글을 참고하여, Clang의 동작 차이 때문에 오류가 발생했을 수 있다고 판단했다. GCC를 사용하도록 환경을 바꿔볼 필요가 있다.

#### 1) gcc 설치 여부 확인

```
gcc -v
```

출력 예:

```
Apple clang version 15.0.0 (clang-1500.0.40.1)

Target: arm64-apple-darwin23.4.0

Thread model: posix

InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
```

Apple clang으로 표시되면 GCC가 설치되어 있지 않은 것으로 보인다. 설치 경로를 확인해보니 GCC가 설치된 적은 없어 보였다. 다만 다른 경로에 있을 수도 있다는 글을 보고 아래 위치를 확인했다:

```
/Library/Developer/CommandLineTools/usr/bin/
```

위 경로에 이미 GCC와 clang이 있는 것을 확인했다. 환경변수만 바꾸면 될 것 같았다.

(참고 문서)

* \[Mac OS 환경변수 설정방법]
* [XCode 삭제방법](/broken/pages/63b0b76e92d79c7f229d640fba7b839c6510dfca)

#### 2) XCode.app 삭제 후 버전(설치여부) 확인

```
gcc -v

Apple clang version 15.0.0 (clang-1500.3.9.4)

Target: arm64-apple-darwin23.4.0

Thread model: posix

InstalledDir: /Library/Developer/CommandLineTools/usr/bin
```

이전에 확인했던 설치 경로로 설정이 바뀌었다. 만약 위 경로에 파일이 없다면 XCode를 다시 설치해야 한다.

#### 3) VSCode에서 GCC로 빌드 시 에러

VSCode에서 빌드하면 다음 에러가 나왔다:

```
 *  작업 실행 중: C/C++: gcc 활성 파일 빌드 

빌드를 시작하는 중...
/usr/bin/gcc -fdiagnostics-color=always -g /Users/admin/Documents/GitHub/DevBasics/DSNA/6_usingStack/reverseString.c -o /Users/admin/Documents/GitHub/DevBasics/DSNA/6_usingStack/reverseString
Undefined symbols for architecture arm64:
  "_createStack", referenced from:
      _reverseString in reverseString-fede55.o
  "_pop", referenced from:
      _reverseString in reverseString-fede55.o
  "_push", referenced from:
      _reverseString in reverseString-fede55.o
ld: symbol(s) not found for architecture arm64
clang: error: linker command failed with exit code 1 (use -v to see invocation)

빌드가 완료되었지만, 오류가 발생했습니다.

 *  터미널 프로세스를 시작하지 못했습니다(종료 코드: -1). 
 *  터미널이 작업에서 다시 사용됩니다. 닫으려면 아무 키나 누르세요. 
```

에러와 동시에 VSCode에서 두 알림이 등장했다: tasks.json에서 컴파일 패스 경로 변경 경고와 CMake 관련 구성 알림. 확인을 누르니 아래 파일들이 열렸다.

* [tasks.json](/broken/pages/dd4d43cae30140d3dabed56017f077e9aae0bb31)
* [launch.json](/broken/pages/e20a0c9f16add42a6be983fb4f38ba1449567946)

또한 c\_cpp\_properties.json도 C 개발 환경 설정에 필요한 파일임을 알게 되었다. 한 번도 이들 파일을 세팅한 경험이 없으니 이 때문에 에러가 발생했을 수 있다.
{% endstep %}
{% endstepper %}

## 중간 정리

VSCode를 처음 설정할 때 더 상세히 설정했더라면 이 고생을 덜었을 것 같다는 생각이 들었다. 특히 헤더 파일 링크가 작동하는지 여부가 초기 설정에 따라 달라질 수 있다는 점을 몰랐다. 지금은 VSCode 설정 방법을 다시 공부할 계획이다.

참고 문서:

* Mac Clang C++17 컴파일러 환경 설정: [Mac Clang C++17 컴파일러 환경 설정](https://headf1rst.github.io/c++/clang-c++17/)
* vscode for mac: [vscode for mac](file:///4766478/dev_tools/vscode%20for%20mac.md)
* settings.json: [settings.json](file:///4766478/dev_tools/settings.json.md)
* Windows C/C++ 개발환경 설정: [windows c/c++ 개발환경 설정](https://blog.amylo.diskstation.me/algorithm/Starting_Algorithm_with_VSCode_C++/)

<details>

<summary>터미널을 이용해 강제로 컴파일러에 파일들을 전달하는 방식 사용 (원문 포함)</summary>

```
PS E:\Document\DevBasics> cd "DSNA"
PS E:\Document\DevBasics\DSNA> cd "6_usingStack"
PS E:\Document\DevBasics\DSNA\6_usingStack> gcc reverseString.c Stack.c Stack.h -o reverseString
PS E:\Document\DevBasics\DSNA\6_usingStack> reverseString
reverseString : 'reverseString' 용어가 cmdlet, 함수, 스크립트 파일 또는 실행할 수 있는 프로그램 이름으로 인식되지 않습니다. 이름이 정확한지 확인하고 경로가 포
함된 경우 경로가 올바른지 검증한 다음 다시 시도하십시오.
위치 줄:1 문자:1
+ reverseString
+ ~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (reverseString:String) [], CommandNotFoundException
    + FullyQualifiedErrorId : CommandNotFoundException


Suggestion [3,General]: reverseString 명령이 현재 위치에 있지만 이 명령을 찾을 수 없습니다. Windows PowerShell은 기본적으로 현재 위치에서 명령을 로드하지 않습니다. 이 명령을 신뢰하는 경우 대신 ".\reverseString"을(를) 입력하십시오. 자세한 내용은 "get-help about_Command_Precedence"를 참조하십시오.
PS E:\Document\DevBasics\DSNA\6_usingStack> reverseString.exe
reverseString.exe : 'reverseString.exe' 용어가 cmdlet, 함수, 스크립트 파일 또는 실행할 수 있는 프로그램 이름으로 인식되지 않습니다. 이름이 정확한지 확인하고 경 
로가 포함된 경우 경로가 올바른지 검증한 다음 다시 시도하십시오.
위치 줄:1 문자:1
+ reverseString.exe
+ ~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (reverseString.exe:String) [], CommandNotFoundException
    + FullyQualifiedErrorId : CommandNotFoundException


Suggestion [3,General]: reverseString.exe 명령이 현재 위치에 있지만 이 명령을 찾을 수 없습니다. Windows PowerShell은 기본적으로 현재 위치에서 명령을 로드하지 않습니다. 이 명령을 신뢰하는 경우 대신 ".\reverseString.exe"을(를) 입력하십시오. 자세한 내용은 "get-help about_Command_Precedence"를 참조하십시오.
PS E:\Document\DevBasics\DSNA\6_usingStack> .\reverseString
PS E:\Document\DevBasics\DSNA\6_usingStack> 
```

</details>

> 강제로 링크 값 전달하여 빌드한 생성파일을 터미널에서 실행한 결과(원문 포함):

```
/Users/admin/Documents/GitHub/DevBasics/DSNA/6_usingStack/reverseString ; exit;

admin@adminui-MacBookAir ~ % /Users/admin/Documents/GitHub/DevBasics/DSNA/6_usingStack/reverseString ; exit;

zsh: segmentation fault  /Users/admin/Documents/GitHub/DevBasics/DSNA/6_usingStack/reverseString
```

실행은 되었으나 다른 에러(무한루프 등)가 발생했다.

## 결론

1. VSCode는 자체적으로 링크(링커에 여러 소스/오브젝트 파일을 묶는 작업)를 관리해 주지 않는다. 빌드 구성(명령에 포함할 파일 목록 등)을 직접 설정해야 한다.
2. gcc 등 컴파일 명령어로 링크에 포함할 파일을 한 번에 묶어서 컴파일(예: gcc main.c Stack.c -o main)해야 한다.
3. CMake 등을 사용하면 빌드와 파일 단위 소스 코드 관리를 좀 더 편리하게 할 수 있다. (관련: [CMake](file:///4766478/dev_tools/CMake.md))

***

관련 파일

* [tasks.json](/broken/pages/dd4d43cae30140d3dabed56017f077e9aae0bb31)
* [launch.json](/broken/pages/e20a0c9f16add42a6be983fb4f38ba1449567946)
* [MyStack.h](/broken/pages/ebea2a0ad4ecc2b6a08b4c601f55fb6f755afb92)
* [MyStack.c](/broken/pages/e0dcedf6e8fb81d35c92891af1f6b744ec323bf5)
* [Main.c](/broken/pages/fba645a7a1d4e4adb7211d5ffc6744439d493375)
