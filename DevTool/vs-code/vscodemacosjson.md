# macOS VS Code C 및 C++ 설정 파일 예시

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-VSC-004-REF |
| 유형 | REF (설정 파일 내용) |
| 목적 | macOS에서 clang/clang++로 빌드·디버그하는 VS Code 설정 파일 3개의 내용을 참조한다 |
| 확인 상태 | 미검증 (원본 페이지의 JSON을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 적용 절차는 DEV-VSC-003-MP를 따른다. 세 파일은 모두 작업 폴더의 `.vscode/` 안에 둔다. 원본의 불필요한 빈 줄은 제거했다.
{% endhint %}

## 1. 파일 표

| 파일 | 역할 |
|---|---|
| `c_cpp_properties.json` | IntelliSense(코드 자동 완성·오류 표시)가 쓸 컴파일러와 표준을 지정한다 |
| `tasks.json` | 활성 파일을 `clang++`로 빌드하는 작업을 정의한다 |
| `launch.json` | 빌드한 실행 파일을 `lldb`로 디버그하는 설정을 정의한다 |

{% hint style="info" %}
NOTE: `launch.json`의 `preLaunchTask` 값은 `tasks.json`의 `label` 값과 글자까지 같아야 한다. 아래 두 파일에서는 둘 다 `C/C++: clang++ build active file`이다.
{% endhint %}

{% hint style="info" %}
NOTE: `intelliSenseMode`의 `macos-clang-arm64`는 Apple Silicon용이다. Intel Mac에서는 `macos-clang-x64`를 쓴다.
{% endhint %}

## 2. c_cpp_properties.json

{% code title="c_cpp_properties.json" %}
```json
{
  "configurations": [
    {
      "name": "Mac",
      "includePath": ["${workspaceFolder}/**"],
      "defines": [],
      "macFrameworkPath": [
        "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks"
      ],
      "compilerPath": "/usr/bin/clang",
      "intelliSenseMode": "macos-clang-arm64",
      "cStandard": "c11",
      "cppStandard": "c++17",
      "compilerArgs": ["-std=c++17", "-stdlib=libc++"]
    }
  ],
  "version": 4
}
```
{% endcode %}

## 3. tasks.json

{% code title="tasks.json" %}
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "type": "cppbuild",
      "label": "C/C++: clang++ build active file",
      "command": "/usr/bin/clang++",
      "args": [
        "-std=c++17",
        "-stdlib=libc++",
        "-fdiagnostics-color=always",
        "-g",
        "${file}",
        "-o",
        "${fileDirname}/${fileBasenameNoExtension}"
      ],
      "options": {
        "cwd": "${fileDirname}"
      },
      "problemMatcher": ["$gcc"],
      "group": {
        "kind": "build",
        "isDefault": true
      },
      "detail": "compiler: /usr/bin/clang++"
    }
  ]
}
```
{% endcode %}

## 4. launch.json

{% code title="launch.json" %}
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "C/C++: clang++ 활성 파일 빌드 및 디버그",
      "type": "cppdbg",
      "request": "launch",
      "program": "${fileDirname}/${fileBasenameNoExtension}",
      "args": [],
      "stopAtEntry": false,
      "cwd": "${fileDirname}",
      "environment": [],
      "externalConsole": false,
      "MIMode": "lldb",
      "preLaunchTask": "C/C++: clang++ build active file"
    }
  ]
}
```
{% endcode %}

## 5. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본의 JSON을 REF 문서로 분리하고 서식을 정리. `launch.json`의 `version`을 `2.0.0`에서 `0.2.0`으로, `tasks.json`의 `fdiagnostics-color=always`를 `-fdiagnostics-color=always`로 정정 |
